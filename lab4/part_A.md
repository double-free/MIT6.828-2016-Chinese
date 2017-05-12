### Part A: 多处理器支持及协同多任务处理
---
我们首先需要把 JOS 扩展到在多处理器系统中运行。然后实现一些新的 JOS 系统调用来允许用户进程创建新的进程。我们还要实现协同轮询调度，在当前进程不使用 CPU 时允许内核切换到另一个进程。
#### 多处理器支持
我们即将使 JOS 能够支持“对称多处理” (Symmetric MultiProcessing, SMP)。这种模式使所有 CPU 能对等地访问内存、I/O 总线等系统资源。虽然 CPU 在 SMP 下以同样的方式工b作，在启动过程中他们可以被分为两个类型：引导处理器(BootStrap Processor, BSP) 负责初始化系统以及启动操作系统；应用处理器( Application Processors, AP ) 在操作系统拉起并运行后由 BSP 激活。哪个 CPU 作为 BSP 由硬件和 BIOS 决定。也就是说目前我们所有的 JOS 代码都运行在 BSP 上。
在 SMP 系统中，每个 CPU 都有一个附属的 LAPIC 单元。LAPIC 单元用于传递中断，并给它所属的 CPU 一个唯一的 ID。在 lab4 中，我们将会用到 LAPIC 单元的以下基本功能 ( 见`kern/lapic.c1 )：

- 读取 APIC ID 来判断我们的代码运行在哪个 CPU 之上。
- 从 BSP 发送`STARTUP` 跨处理器中断 (InterProcessor Interrupt, IPI) 来启动 AP。
- 在 part C 中，我们为 LAPIC 的内置计时器编程来触发时钟中断以支持抢占式多任务处理。

处理器通过映射在内存上的 I/O (Memory-Mapped I/O, MMIO) 来访问它的 LAPIC。在 MMIO 中，**物理内存**的一部分被硬连接到一些 I/O 设备的寄存器，因此，访问内存的 load/store 指令可以被用于访问设备的寄存器。实际上，我们在 lab1 中已经接触过这样的 IO hole，如`0xA0000`被用来写 VGA 显示缓冲。LAPIC 开始于**物理地址** `0xFE000000` ( 4GB以下32MB处 )。如果用以前的映射算法（将`0xF0000000` 映射到 `0x00000000`，也就是说内核空间最高只能到物理地址`0x0FFFFFFF`）显然太高了。因此，JOS 在 `MMIOBASE` (即 虚拟地址`0xEF800000`) 预留了 4MB 来映射这类设备。我们需要写一个函数来分配这个空间并在其中映射设备内存。

>**Exercise 1.**
Implement `mmio_map_region` in `kern/pmap.c`. To see how this is used, look at the beginning of `lapic_init` in `kern/lapic.c`. You'll have to do the next exercise, too, before the tests for `mmio_map_region` will run.

`lapic_init()`函数的一开始就调用了该函数，将从 `lapicaddr`  开始的 4kB 物理地址映射到虚拟地址，并返回其起始地址。注意到，它是以页为单位对齐的，每次都 map 一个页的大小。
```
	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
```
因此实际就是调用 boot_map_region 来建立所需要的映射，需要注意的是，每次需要更改base的值，使得每次都是映射到一个新的页面。
```
void *
mmio_map_region(physaddr_t pa, size_t size)
{
	static uintptr_t base = MMIOBASE;

	size_t rounded_size = ROUNDUP(size, PGSIZE);

	if (base + rounded_size > MMIOLIM) panic("overflow MMIOLIM");
	boot_map_region(kern_pgdir, base, rounded_size, pa, PTE_W|PTE_PCD|PTE_PWT);
	uintptr_t res_region_base = base;	
	base += rounded_size;		
	return (void *)res_region_base;
}
```

#### 引导应用处理器
在启动 APs 之前，BSP 需要先搜集多处理器系统的信息，例如 CPU 的总数，CPU 各自的 APIC ID，LAPIC 单元的 MMIO 地址。`kern/mpconfig.c` 中的 `mp_init()` 函数通过阅读 BIOS 区域内存中的 MP 配置表来获取这些信息。
`boot_aps()` 函数驱动了 AP 的引导。APs 从实模式开始，如同 `boot/boot.S` 中 bootloader 的启动过程。因此 `boot_aps()` 将 AP 的入口代码 (`kern/mpentry.S`) 拷贝到实模式可以寻址的内存区域 (`0x7000`, `MPENTRY_PADDR`)。
此后，`boot_aps()` 通过发送 `STARTUP` 这个跨处理器中断到各 LAPIC 单元的方式，逐个激活 APs。激活方式为：初始化 AP 的 `CS:IP` 值使其从入口代码执行。通过一些简单的设置，AP 开启分页进入保护模式，然后调用 C 语言编写的 `mp_main()`。`boot_aps()` 等待 AP 发送 `CPU_STARTED` 信号，然后再唤醒下一个。
>**Exercise 2.**
Read `boot_aps()` and `mp_main()` in `kern/init.c`, and the assembly code in `kern/mpentry.S`. Make sure you understand the control flow transfer during the bootstrap of APs. Then modify your implementation of `page_init()` in `kern/pmap.c` to avoid adding the page at `MPENTRY_PADDR` to the free list, so that we can safely copy and run AP bootstrap code at that physical address. Your code should pass the updated `check_page_free_list()` test (but might fail the updated `check_kern_pgdir()` test, which we will fix soon).

实际上就是标记 `MPENTRY_PADDR` 开始的一个物理页为已使用，只需要在 `page_init()` 中做一个特例处理即可。唯一需要注意的就是确定这个特殊页在哪个区间内。
```
...
size_t mp_page = MPENTRY_PADDR/PGSIZE;
for (i = 1; i < npages_basemem; i++) {
	if (i == mp_page) {
		pages[i].pp_ref = 1;
		continue;
	}
	pages[i].pp_ref = 0;
	pages[i].pp_link = page_free_list;
	page_free_list = &pages[i];
}
...
```
现在执行 `make qemu`，可以通过 `check_kern_pgdir()` 测试了，Exercise 1, 2 完成。

>**Question 1.**
Compare `kern/mpentry.S` side by side with `boot/boot.S`. Bearing in mind that `kern/mpentry.S` is compiled and linked to run above `KERNBASE` just like everything else in the kernel, what is the purpose of macro `MPBOOTPHYS`? Why is it necessary in `kern/mpentry.S` but not in `boot/boot.S`? In other words, what could go wrong if it were omitted in `kern/mpentry.S`? 
Hint: recall the differences between the link address and the load address that we have discussed in Lab 1. 

注意 `kern/mpentry.S` 注释中的一段话，说明了这两者的区别。
```
# This code is similar to boot/boot.S except that
#    - it does not need to enable A20
#    - it uses MPBOOTPHYS to calculate absolute addresses of its
#      symbols, rather than relying on the linker to fill them
```
此外，还有个关键问题就是 `MPBOOTPHYS` 宏的作用。
`kern/mpentry.S` 是运行在 `KERNBASE` 之上的，与其他的内核代码一样。也就是说，类似于 `mpentry_start`, `mpentry_end`, `start32` 这类地址，都位于 `0xf0000000` 之上，显然，实模式是无法寻址的。再仔细看 `MPBOOTPHYS` 的定义：
```
#define MPBOOTPHYS(s) ((s) - mpentry_start + MPENTRY_PADDR)
```
其意义可以表示为，从 `mpentry_start` 到 `MPENTRY_PADDR` 建立映射，将 `mpentry_start + offset` 地址转为 `MPENTRY_PADDR + offset` 地址。查看`kern/init.c`，发现已经完成了这部分地址的内容拷贝。
```
static void
boot_aps(void)
{
	extern unsigned char mpentry_start[], mpentry_end[];
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	...
}
```
因此，实模式下就可以通过 `MPBOOTPHYS` 宏的转换，运行这部分代码。`boot.S` 中不需要这个转换是因为代码的本来就被加载在实模式可以寻址的地方。

#### CPU 状态和初始化
当写一个多处理器操作系统时，分清 CPU 的私有状态 ( per-CPU state) 及全局状态 (global state) 非常关键。 `kern/cpu.h` 定义了大部分的 per-CPU 状态。
我们需要注意的 per-CPU 状态有：

- Per-CPU 内核栈

因为多 CPU 可能同时陷入内核态，我们需要给每个处理器一个独立的内核栈。`percpu_kstacks[NCPU][KSTKSIZE]` 
在 Lab2 中，我们将 BSP 的内核栈映射到了 KSTACKTOP 下方。相似地，在 Lab4 中，我们需要把每个 CPU 的内核栈都映射到这个区域，每个栈之间留下一个空页作为缓冲区避免 overflow。CPU 0 ，即 BSP 的栈还是从 `KSTACKTOP` 开始，间隔 `KSTACKGAP` 的距离就是 CPU 1 的栈，以此类推。

- Per-CPU TSS 以及 TSS 描述符

为了指明每个 CPU 的内核栈位置，需要任务状态段 (Task State Segment, TSS)，其功能在 Lab3 中已经详细讲过。

- Per-CPU 当前环境指针

因为每个 CPU 能够同时运行各自的用户进程，我们重新定义了基于`cpus[cpunum()]` 的 `curenv`。

- Per-CPU 系统寄存器

所有的寄存器，包括系统寄存器，都是 CPU 私有的。因此，初始化这些寄存器的指令，例如 `lcr3(), ltr(), lgdt(), lidt()` 等，必须在每个 CPU 都执行一次。

>**Exercise 3.**
Modify `mem_init_mp()` (in `kern/pmap.c`) to map per-CPU stacks starting at `KSTACKTOP`, as shown in `inc/memlayout.h`. The size of each stack is `KSTKSIZE` bytes plus `KSTKGAP` bytes of unmapped guard pages. Your code should pass the new check in `check_kern_pgdir()`.

比较简单的一个练习，起初只 map 了BSP，这次是 map 所有的 cpu（包括实际不存在的）。 在 `kern/cpu.h` 中可以找到对 `NCPU` 以及全局变量`percpu_kstacks`的声明。
```
// Maximum number of CPUs
#define NCPU  8
...
// Per-CPU kernel stacks
extern unsigned char percpu_kstacks[NCPU][KSTKSIZE];
```
`percpu_kstacks`的定义在 `kern/mpconfig.c` 中可以找到：
```
// Per-CPU kernel stacks
unsigned char percpu_kstacks[NCPU][KSTKSIZE]
__attribute__ ((aligned(PGSIZE)));
```
此后就是修改 `kern/pmap.c` 中的函数，代码很简单：
```
static void
mem_init_mp(void)
{
	uintptr_t start_addr = KSTACKTOP - KSTKSIZE;	
	for (size_t i=0; i<NCPU; i++) {
		boot_map_region(kern_pgdir, (uintptr_t) start_addr, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
		start_addr -= KSTKSIZE + KSTKGAP;
	}
}
```
但是有个违和感很强的地方，之前已经把 BSP，也就是 cpu 0 的内核栈映射到了`bootstack`对应的物理地址：
```
boot_map_region(kern_pgdir, (uintptr_t) (KSTACKTOP-KSTKSIZE), KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
```
然而这里又映射到了另一片物理地址，具体可以打印出来观察：
```
BSP: map 0xefff8000 to physical address 0x115000
...
cpu 0: map 0xefff8000 to physical address 0x22c000
```
这样做会不会有什么问题呢？
实际上，观察函数 `boot_map_region()` 可以看出，其实新地址覆盖了旧地址。 而页面引用是对虚拟内存来讲的，因此更换物理地址并不需要增加或减少页面引用，这种写法不会有任何问题。当然，我们也可以把之前对 BSP 栈的映射直接注释掉，也能通过检查。

>**Exercise 4.**
The code in `trap_init_percpu()` (`kern/trap.c`) initializes the TSS and TSS descriptor for the BSP. It worked in Lab 3, but is incorrect when running on other CPUs. Change the code so that it can work on all CPUs. (Note: your new code should not use the global `ts` variable any more.)

先注释掉 ts，再根据单个cpu的代码做改动。在 `inc/memlayout.h` 中可以找到 GD_TSS0 的定义：
```
#define GD_TSS0   0x28     // Task segment selector for CPU 0
```
但是并没有其他地方说明其他 CPU 的任务段选择器在哪。因此最大的难点就是找到这个值。实际上，偏移就是 `cpu_id << 3`。
```
// static struct Taskstate ts;
...
	struct Taskstate* this_ts = &thiscpu->cpu_ts;

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	this_ts->ts_esp0 = KSTACKTOP - thiscpu->cpu_id*(KSTKSIZE + KSTKGAP);
	this_ts->ts_ss0 = GD_KD;
	this_ts->ts_iomb = sizeof(struct Taskstate);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));

	// Load the IDT
	lidt(&idt_pd);
```
运行 `make qemu CPUS=4` 成功（虽然我只有2核，似乎初始化的 cpu 个数完全靠用户指定）。

#### 锁
我们现在的代码在初始化 AP 后就会开始自旋。在进一步操作 AP 之前，我们要先处理几个 CPU 同时运行内核代码的竞争情况。最简单的方法是用一个大内核锁 (big kernel lock)。它是一个全局锁，在某个进程进入内核态时锁定，返回用户态时释放。这种模式下，用户进程可以并发地在 CPU 上运行，但是同一时间仅有一个进程可以在内核态，其他需要进入内核态的进程只能等待。
`kern/spinlock.h` 声明了一个大内核锁 `kernel_lock`。它提供了 `lock_kernel()` 和 `unlock_kernel()` 方法用于获得和释放锁。在以下 4 个地方需要使用到大内核锁：
- 在 `i386_init()`，BSP 唤醒其他 CPU 之前获得内核锁
- 在 `mp_main()`，初始化 AP 之后获得内核锁，之后调用 `sched_yield()` 在 AP 上运行进程。
- 在 `trap()`，当从用户态陷入内核态时获得内核锁，通过检查 `tf_Cs` 的低 2bit 来确定该 trap 是由用户进程还是内核触发。
- 在 `env_run()`，在切换回用户模式前释放内核锁。

> **Exercise 5.**
Apply the big kernel lock as described above, by calling `lock_kernel()` and `unlock_kernel()` at the proper locations.

实现比较简单，不用细讲。关键要理解两点：

- 大内核锁的实现
```
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	// 关键代码，体现了循环等待的思想
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
```
其中，在 `inc/x86.h` 中可以找到 `xchg()` 函数的实现，使用它而不是用简单的 if + 赋值 是因为它是一个原子性的操作。
```
static inline uint32_t
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
		     : "+m" (*addr), "=a" (result)  // 输出
		     : "1" (newval)	     	    //  输入
		     : "cc");
	return result;
}
```
这是一段内联汇编，语法在 Lab3 中已经讲解过。`lock` 确保了操作的原子性，其意义是将 addr 存储的值与 newval 交换，并返回 addr 中原本的值。于是，如果最初 `locked = 0`，即未加锁，就能跳出这个 while循环。否则就会利用 `pause` 命令自旋等待。这就确保了当一个 CPU 获得了 BKL，其他 CPU 如果也要获得就只能自旋等待。

- 为什么要在这几处加大内核锁

为了避免多个 CPU 同时运行内核代码，这基本是废话。从根本上来讲，其设计的初衷就是保证独立性。由于分页机制的存在，内核以及每个用户进程都有自己的独立空间。而多进程并发的时候，如果两个进程同时陷入内核态，就无法保证独立性了。例如内核中有某个全局变量 A，cpu1 让 A=1， 而后 cpu2 却让 A=2，显然会互相影响。最初 Linux 设计者为了使系统尽快支持 SMP，直接在内核入口放了一把大锁，保证其独立性。参见这篇非常好的文章 [大内核锁将何去何从](http://blog.csdn.net/universus/article/details/5623971)
其流程大致为：
BPS 启动 AP 前，获取内核锁，所以 AP 会在 mp_main 执行调度之前阻塞，在启动完 AP 后，BPS 执行调度，运行第一个进程，`env_run()` 函数中会释放内核锁，这样一来，其中一个 AP 就可以开始执行调度，运行其他进程。

>**Question 2.**
It seems that using the big kernel lock guarantees that only one CPU can run the kernel code at a time. Why do we still need separate kernel stacks for each CPU? Describe a scenario in which using a shared kernel stack will go wrong, even with the protection of the big kernel lock

例如，在某进程即将陷入内核态的时候（尚未获得锁），其实在 `trap()` 函数之前已经在 `trapentry.S` 中对内核栈进行了操作，压入了寄存器信息。如果共用一个内核栈，那显然会导致信息错误。

#### 轮询调度
下一个任务是让 JOS 内核能够以轮询方式在多个任务之间切换。其原理如下：

- `kern/sched.c` 中的 `sched_yield()` 函数用来选择一个新的进程运行。它将从上一个运行的进程开始，按顺序循环搜索 `envs[]` 数组，选取第一个状态为 `ENV_RUNNABLE` 的进程执行。

- `sched_yield()`不能同时在两个CPU上运行同一个进程。如果一个进程已经在某个 CPU 上运行，其状态会变为 `ENV_RUNNING`。
 
- 程序中已经实现了一个新的系统调用 `sys_yield()`，进程可以用它来唤起内核的 `sched_yield()` 函数，从而将 CPU 资源移交给一个其他的进程。

>**Exercise 6.**
Implement round-robin scheduling in `sched_yield()` as described above. Don't forget to modify `syscall()` to dispatch `sys_yield()`.
Make sure to invoke `sched_yield()` in `mp_main`.
Modify `kern/init.c` to create three (or more!) environments that all run the program `user/yield.c`.

注意以下几个问题：

- 如何找到目前正在运行的进程在 `envs[]` 中的序号？

在 `kern/env.h` 中，可以找到指向 `struct Env`的指针 `curenv`，表示当前正在运行的进程。但是需要注意，不能直接由 `curenv->env_id`得到其序号。在 `inc/env.h` 中有一个宏可以完成这个转换。
```
// The environment index ENVX(eid) equals the environment's offset in the 'envs[]' array.
#define ENVX(envid)		((envid) & (NENV - 1))
```
- 查看 `kern/env.c` 可以发现 `curenv` 可能为 `NULL`。因此要注意特例。

在 `kern/sched.c` 中实现轮询调度。
```
void
sched_yield(void)
{
	struct Env *idle;

	// LAB 4: Your code here.
	idle = curenv;
	size_t idx = idle!=NULL ? ENVX(idle->env_id):-1;
	for (size_t i=0; i<NENV; i++) {
		idx = (idx+1 == NENV) ? 0:idx+1;
		if (envs[idx].env_status == ENV_RUNNABLE) {
			env_run(&envs[idx]);
			return;
		}
	}
	if (idle && idle->env_status == ENV_RUNNING) {
		env_run(idle);
		return;
	}
	// sched_halt never returns
	sched_halt();
}
```
在 `kern/syscall.c` 中添加新的系统调用。
```
// syscall()
...
	case SYS_yield:
		sys_yield();
		break;
...
```
将 `kern/init.c` 中运行的用户进程改为以下：
```
// i386_init()
...
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_yield, ENV_TYPE_USER);
...
```
运行 `make qemu CPUS=2` 可以看到三个进程通过调用 `sys_yield` 切换了5次。
```
Hello, I am environment 00001000.
Hello, I am environment 00001001.
Back in environment 00001000, iteration 0.
Hello, I am environment 00001002.
Back in environment 00001001, iteration 0.
Back in environment 00001000, iteration 1.
Back in environment 00001002, iteration 0.
Back in environment 00001001, iteration 1.
Back in environment 00001000, iteration 2.
Back in environment 00001002, iteration 1.
Back in environment 00001001, iteration 2.
Back in environment 00001000, iteration 3.
Back in environment 00001002, iteration 2.
Back in environment 00001001, iteration 3.
Back in environment 00001000, iteration 4.
Back in environment 00001002, iteration 3.
All done in environment 00001000.
[00001000] exiting gracefully
[00001000] free env 00001000
Back in environment 00001001, iteration 4.
Back in environment 00001002, iteration 4.
All done in environment 00001001.
All done in environment 00001002.
[00001001] exiting gracefully
[00001001] free env 00001001
[00001002] exiting gracefully
[00001002] free env 00001002
No runnable environments in the system!
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
K> 
```
记录一下自己遇到的问题：
这个 exercise 出现了 triple fault 报错，查了很久原因。由于是triple fault 肯定是 trap 过程中的错误，仔细检查发现是自己的 exercise4 的做法出现了问题，一个非常二的错误。
```
// 错误版本，显然没有更改 thiscpu 中的值
	struct Taskstate this_ts = thiscpu->cpu_ts;
// 正确版本
	struct Taskstate* this_ts = &thiscpu->cpu_ts;
```

>**Question 3.**
In your implementation of `env_run()` you should have called `lcr3()`. Before and after the call to `lcr3()`, your code makes references (at least it should) to the variable `e`, the argument to `env_run`. Upon loading the `%cr3` register, the addressing context used by the MMU is instantly changed. But a virtual address (namely `e`) has meaning relative to a given address context--the address context specifies the physical address to which the virtual address maps. Why can the pointer e be dereferenced both before and after the addressing switch?

大意是问为什么通过 `lcr3()` 切换了页目录，还能照常对 `e` 解引用。回想在 lab3 中，曾经写过的函数 `env_setup_vm()`。它直接以内核的页目录作为模版稍做修改。因此两个页目录的 `e` 地址映射到同一物理地址。
```
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // use kern_pgdir as template 
	p->pp_ref++;
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;

	return 0;
}
```

>**Question 4.**
Whenever the kernel switches from one environment to another, it must ensure the old environment's registers are saved so they can be restored properly later. Why? Where does this happen?

在进程陷入内核时，会保存当前的运行信息，这些信息都保存在内核栈上。而当从内核态回到用户态时，会恢复之前保存的运行信息。
具体到 JOS 代码中，保存发生在 `kern/trapentry.S`，恢复发生在 `kern/env.c`。可以对比两者的代码。
保存：
```
#define TRAPHANDLER_NOEC(name, num)
	.globl name;							
	.type name, @function;						
	.align 2;							
	name:								
	pushl $0;							
	pushl $(num);							
	jmp _alltraps
...

_alltraps:
pushl %ds    // 保存当前段寄存器
pushl %es
pushal    // 保存其他寄存器

movw $GD_KD, %ax
movw %ax, %ds
movw %ax, %es
pushl %esp    //  保存当前栈顶指针
call trap
```
恢复：
```
void
env_pop_tf(struct Trapframe *tf)
{
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();

	asm volatile(
		"\tmovl %0,%%esp\n"    // 恢复栈顶指针
		"\tpopal\n"    // 恢复其他寄存器
		"\tpopl %%es\n"    // 恢复段寄存器
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
}
```

#### 系统调用：创建进程
现在我们的内核已经可以运行多个进程，并在其中切换了。不过，现在它仍然只能运行内核最初设定好的程序 (`kern/init.c`) 。现在我们即将实现一个新的系统调用，它允许进程创建并开始新的进程。
Unix 提供了 `fork()` 这个原始的系统调用来创建进程。`fork()`将会拷贝父进程的整个地址空间来创建子进程。在用户空间里，父子进程之间的唯一区别就是它们的进程 ID。`fork()`在父进程中返回其子进程的进程 ID，而在子进程中返回 0。父子进程之间是完全独立的，任意一方修改内存，另一方都不会受到影响。
我们将为 JOS 实现一个更原始的系统调用来创建新的进程。涉及到的系统调用如下：
- `sys_exofork`:
这个系统调用将会创建一个空白进程：在其用户空间中没有映射任何物理内存，并且它是不可运行的。刚开始时，它拥有和父进程相同的寄存器状态。`sys_exofork` 将会在父进程返回其子进程的`envid_t`，子进程返回 0（当然，由于子进程还无法运行，也无法返回值，直到运行：）
- `sys_env_set_status`:
设置指定进程的状态。这个系统调用通常用于在新进程的地址空间和寄存器初始化完成后，将其标记为可运行。
- `sys_page_alloc`:
分配一个物理页并将其映射到指定进程的指定虚拟地址上。
- `sys_page_map`:
从一个进程中拷贝一个页面映射（而非物理页的内容）到另一个。即共享内存。
- `sys_page_unmap`:
删除到指定进程的指定虚拟地址的映射。

>**Exercise 7.**
Implement the system calls described above in `kern/syscall.c`. You will need to use various functions in `kern/pmap.c` and `kern/env.c`, particularly `envid2env()`. For now, whenever you call `envid2env()`, pass 1 in the `checkperm` parameter. Be sure you check for any invalid system call arguments, returning `-E_INVAL` in that case. Test your JOS kernel with `user/dumbfork` and make sure it works before proceeding.

一个比较冗长的练习。重点应该放在阅读 `user/dumbfork.c` 上，以便理解各个系统调用的作用。
在 `user/dumbfork.c` 中，核心是 `duppage()` 函数。它利用 `sys_page_alloc()` 为子进程分配空闲物理页，再使用`sys_page_map()` 将该新物理页映射到内核 **(内核的 env_id = 0)** 的交换区 `UTEMP`，方便在内核态进行 `memmove` 拷贝操作。在拷贝结束后，利用 `sys_page_unmap()` 将交换区的映射删除。
```
void
duppage(envid_t dstenv, void *addr)
{
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		panic("sys_page_unmap: %e", r);
}
```

**sys_exofork() 函数**

该函数主要是分配了一个新的进程，但是没有做内存复制等处理。唯一值得注意的就是如何使子进程返回0。
`sys_exofork()`是一个非常特殊的系统调用，它的定义与实现在 `inc/lib.h` 中，而不是 `lib/syscall.c` 中。
```
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
		     : "=a" (ret)
		     : "a" (SYS_exofork), "i" (T_SYSCALL));
	return ret;
}
```
可以看出，它的返回值是 `%eax` 寄存器的值。那么，它到底是什么时候返回？这就涉及到对整个 进程->内核->进程 的过程的理解。

```
static envid_t
sys_exofork(void)
{
	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");
	struct Env *e;
	int r = env_alloc(&e, curenv->env_id);
	if (r < 0) return r;
	e->env_status = ENV_NOT_RUNNABLE;
	e->env_tf = curenv->env_tf;
	e->env_tf.tf_regs.reg_eax = 0;
	return e->env_id;
}
```
在该函数中，子进程复制了父进程的 trapframe，此后把 trapframe 中的 eax 的值设为了0。最后，返回了子进程的 id。注意，根据 `kern/trap.c` 中的 `trap_dispatch()` 函数，这个返回值仅仅是存放在了父进程的 trapframe 中，还没有返回。而是在返回用户态的时候，即在 `env_run()` 中调用 `env_pop_tf()` 时，才把 trapframe 中的值赋值给各个寄存器。这时候 `lib/syscall.c` 中的函数 `syscall()` 才获得真正的返回值。因此，在这里对子进程 trapframe 的修改，可以使得子进程返回0。

**sys_page_alloc() 函数**
在进程 envid 的目标地址 va 分配一个权限为 perm 的页面。
```
static int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");
	if ((~perm & (PTE_U|PTE_P)) != 0) return -E_INVAL;
	if ((perm & (~(PTE_U|PTE_P|PTE_AVAIL|PTE_W))) != 0) return -E_INVAL;
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
	
	struct PageInfo *pginfo = page_alloc(ALLOC_ZERO);
	if (!pginfo) return -E_NO_MEM;
	struct Env *e;
	int r = envid2env(envid, &e, 1);
	if (r < 0) return -E_BAD_ENV;
	r = page_insert(e->env_pgdir, pginfo, va, perm);
	if (r < 0) {
		page_free(pginfo);
		return -E_NO_MEM;
	}
	return 0;
}
```

**sys_page_map() 函数**
简单来说，就是建立跨进程的映射。
```
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0) return -E_INVAL;
	struct Env *src_e, *dst_e;
	if (envid2env(srcenvid, &src_e, 1)<0 || envid2env(dstenvid, &dst_e, 1)<0) return -E_BAD_ENV;
	pte_t *src_ptab;	
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_ptab);
	if ((*src_ptab & PTE_W) == 0 && (perm & PTE_W) == 1) return -E_INVAL;
	if (page_insert(dst_e->env_pgdir, pp, dstva, perm) < 0) return -E_NO_MEM;
	return 0;
}
```

**sys_page_unmap() 函数**
取消映射。
```
static int
sys_page_unmap(envid_t envid, void *va)
{
	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL;
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
	page_remove(e->env_pgdir, va);
	return 0;
}
```

**sys_env_set_status() 函数**
设置状态，在子进程内存 map 结束后再使用。
```
static int
sys_env_set_status(envid_t envid, int status)
{
	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");
	
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;	
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
	e->env_status = status;
	return 0;
}
```

最后，不要忘记在 `kern/syscall.c` 中添加新的系统调用类型，注意参数的处理。
```
...
	case SYS_exofork:
		retVal = (int32_t)sys_exofork();
		break;
	case SYS_env_set_status:
		retVal = sys_env_set_status(a1, a2);
		break;
	case SYS_page_alloc:
		retVal = sys_page_alloc(a1,(void *)a2, (int)a3);
		break;
	case SYS_page_map:
		retVal = sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
		break;
	case SYS_page_unmap:
		retVal = sys_page_unmap(a1, (void *)a2);
		break;
...
```
make grade 成功。至此，part A 结束。
