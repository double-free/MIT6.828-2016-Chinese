### 简介
---
lab3 将主要实现能运行被保护的用户模式环境（protected user-mode environment，即 process）的内核服务。我们将增加数据结构来记录进程、创建进程、为其装载一个程序镜像。我们还要让 JOS 内核能够处理进程产生的系统调用和异常。

### Part A: 用户环境和异常处理
---
>**Exercise 1.** 
Modify `mem_init()` in `kern/pmap.c` to allocate and map the envs array. This array consists of exactly `NENV` instances of the `Env` structure allocated much like how you allocated the pages array. Also like the pages array, the memory backing envs should also be mapped user read-only at UENVS (defined in `inc/memlayout.h`) so user processes can read from this array.

首先，最大进程个数 NENV(1024) 以及进程描述符 struct Env 的定义可以在 inc/env.h 中找到。同时，我们在 kern/env.h 以及 kern/env.c 中可以找到三个全局变量的定义：
```
extern struct Env *envs;		// All environments
extern struct Env *curenv;		// Current environment
static struct Env *env_free_list;	// Free environment list
```
我们需要将 envs 指针指向一个由 Env 结构体组成的数组，就像我们在 lab2 中对 pages 指针做的一样。同时，JOS 还需要将不活动的 Env 记录在 env_free_list 之中，类似于 page_free_list。curenv 指针记录着现在执行的进程。在第一个进程运行之前，为NULL。
在 kern/pmap.c 中添加以下两行代码，基本就是仿造之前对 pages 的处理。
```
	// 分配空间并初始化
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
	memset(envs, 0, NENV * sizeof(struct Env));
```
```
	// 将虚拟内存的 UENVS 段映射到 envs 的物理地址
	//////////////////////////////////////////////////////////////////////
	// Map the 'envs' array read-only by the user at linear address UENVS
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
```
check_kern_pgdir() 成功。
>**Exercise 2.** 
In the file `env.c`, finish coding the following functions:
`env_init()`
Initialize all of the Env structures in the `envs` array and add them to the `env_free_list`. Also calls `env_init_percpu`, which configures the segmentation hardware with separate segments for privilege level 0 (kernel) and privilege level 3 (user).
`env_setup_vm()`
Allocate a page directory for a new environment and initialize the kernel portion of the new environment's address space.
`region_alloc()`
Allocates and maps physical memory for an environment
`load_icode()`
You will need to parse an ELF binary image, much like the boot loader already does, and load its contents into the user address space of a new environment.
`env_create()`
Allocate an environment with `env_alloc` and call `load_icode` to load an ELF binary into it.
`env_run()`
Start a given environment running in user mode.

看上去挺复杂的一个练习。每个函数逐一说明。

**env_init()**

作用是初始化 envs 这个数组以及 env_free_list。需要注意的主要是链表的顺序，要求第一个被使用是 envs[0]，所以我们从后往前插入（类似于栈，后进先出）。
```
void
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i = NENV;
	while (i>0) {
		i--;
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &env[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
}
```
**env_setup_vm()**

新建并初始化进程的页目录，一个页目录占用空间 4kB。需要注意两点：
 1. 进程的页目录与内核的页目录基本相同，仅需修改一下 UVPT，所以可以直接 memcpy。
 2. 需要增加页引用。

```
static int
env_setup_vm(struct Env *e)
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;

	// Now, set e->env_pgdir and initialize the page directory.
	//
	// Hint:
	//    - The VA space of all envs is identical above UTOP
	//	(except at UVPT, which we've set below).
	//	See inc/memlayout.h for permissions and layout.
	//	Can you use kern_pgdir as a template?  Hint: Yes.
	//	(Make sure you got the permissions right in Lab 2.)
	//    - The initial VA below UTOP is empty.
	//    - You do not need to make any more calls to page_alloc.
	//    - Note: In general, pp_ref is not maintained for
	//	physical pages mapped only above UTOP, but env_pgdir
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

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
**region_alloc()**

为进程分配内存并完成映射。重点就是想到要利用 lab2 中的 page_alloc() 完成分配内存页， page_insert() 完成虚拟地址到物理页的映射。
```
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t pgnum = ROUNDUP(len, PGSIZE) / PGSIZE;
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	struct PageInfo *pginfo = NULL;
	cprintf("Allocate size: %d, Start from: %08x\n", len, va);
	for (size_t i=0; i<pgnum; i++) {
		pginfo = page_alloc(0);
		if (! pginfo) {
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
		}
		int r = page_insert(e->env_pgdir, pginfo, (void *)va_start, PTE_W | PTE_U | PTE_P);
		if (r < 0) {
			panic("region_alloc: %e" , r);
		}
		cprintf("Va_start = %08x\n",va_start);
		va_start += PGSIZE;
	}
}
```
**load_icode()**

这是本 exercise 最难的一个函数。作用是将 ELF 二进制文件读入内存，由于 JOS 暂时还没有自己的文件系统，实际就是从 \*binary 这个内存地址读取。可以从 boot/main.c 中找到灵感。
大概需要做的事：
1. 根据 ELF header 得出 Programm header。
2.  遍历所有 Programm header，分配好内存，加载类型为 ELF_PROG_LOAD 的段。
3. 分配用户栈。

需要思考的问题：
1. 怎么切换页目录？
lcr3([页目录物理地址]) 将地址加载到 cr3 寄存器。
2. 怎么更改函数入口？
将 env->env_tf.tf_eip 设置为 elf->e_entry，等待之后的 env_pop_tf() 调用。

```
static void
load_icode(struct Env *e, uint8_t *binary)
{
	struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	if (elf->e_magic != ELF_MAGIC) {
		panic("load_icode: not an ELF file");
	}
	ph = (struct Proghdr *)(binary + elf->e_phoff);
	eph = ph + elf->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for (; ph<eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
			if (ph->p_filesz > ph->p_memsz) {
				panic("load_icode: file size is greater than memory size");
			}
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
		}
	}
	e->env_tf.tf_eip = elf->e_entry;
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	
	// LAB 3: Your code here.
	region_alloc(e, (void *) USTACKTOP-PGSIZE, PGSIZE);
	lcr3(PADDR(kern_pgdir));
}
```
**env_create()**

作用是新建一个进程。调用已经写好的 env_alloc() 函数即可，之后更改类型并且利用 load_icode() 读取 ELF。
```
void
env_create(uint8_t *binary, enum EnvType type)
{
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
	if (r<0) {
		panic("env_create: %e",r);
	}
	e->env_type = type;
	load_icode(e, binary);
}
```
**env_run()**

启动某个进程。注释已经非常详细地说明了怎么做，主要说下 env_pop_tf() 这个函数。该函数的作用是将 struct Trapframe 中存储的寄存器状态 pop 到相应寄存器中。查看之前写的 load_icode() 函数中的 `e->env_tf.tf_eip = elf->e_entry` 这一句，经过 env_pop_tf() 之后，指令寄存器的值即设置到了可执行文件的入口。
```
void
env_run(struct Env *e)
{
	// Step 1: If this is a context switch (a new environment is running):
	//	   1. Set the current environment (if any) back to
	//	      ENV_RUNNABLE if it is ENV_RUNNING (think about
	//	      what other states it can be in),
	//	   2. Set 'curenv' to the new environment,
	//	   3. Set its status to ENV_RUNNING,
	//	   4. Update its 'env_runs' counter,
	//	   5. Use lcr3() to switch to its address space.
	// Step 2: Use env_pop_tf() to restore the environment's
	//	   registers and drop into user mode in the
	//	   environment.

	// Hint: This function loads the new environment's state from
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// panic("env_run not yet implemented");
	if (curenv && curenv->env_status == ENV_RUNNING) {
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
	e->env_status = ENV_RUNNING;
	e->env_runs++;
	lcr3(PADDR(e->env_pgdir));
	
	env_pop_tf(&e->env_tf);
}
```
至此结束，本次 exercise 结束后运行并不会成功，会报错 Triple fault。然后 gdb 停止在：
```
=> 0x800a1c:	int    $0x30
0x00800a1c in ?? ()
```
原因是此时系统已经进入用户空间，执行了 hello 直到使用系统调用。然而由于 JOS 还没有允许从用户态到内核态的切换，CPU 会产生一个保护异常，然而这个异常也没有程序进行处理，于是生成了 double fault 异常，这个异常同样没有处理。所以报错 triple fault。也就是说，看到执行到了 int 这个中断，实际上就是本次 exercise 顺利结束，这个系统调用是为了在终端输出字符。
#### 处理中断和异常
上一节中，`int $0x30`这个系统调用指令是一条死路：一旦进程进入用户模式，内核将无法再次获得控制权。异常和中断都是“受保护的控制权转移” (protected control transfers)，使处理器从用户模式转到内核模式，用户模式代码无法干扰内核或者其他进程的运行。区别在于，中断是由处理器外部的异步事件产生；而异常是由目前处理的代码产生，例如除以0。
为保证切换是被保护的，处理器的中断、异常机制使得正在运行的代码无须选择在哪里以什么方式进入内核。相反，处理器将保证内核在严格的限制下才能被进入。在 x86 架构下，一共有两个机制提供这种保护：
1. **中断描述符表(Interrupt Descriptor Table, IDT)**
处理器将确保从一些内核预先定义的条目才能进入内核，而不是由中断或异常发生时运行的代码决定。
x86 支持最多 256 个不同中断和异常的条目。每个包含一个中断向量，是一个 0~255 之间的数*（那为什么叫向量？）*，代表中断来源：不同的设备以及错误类型。CPU 利用这些向量作为中断描述符表的索引。而这个表是内核定义在私有内存上（用户没有权限），就像全局描述符表(Global Descripter Table, GDT)一样。从表中恰当的条目，处理器可以获得：
 - 需要加载到指令指针寄存器(EIP)的值，该值指向内核中处理这类异常的代码。
 - 需要加载到代码段寄存器(CS)的值，其中最低两位表示优先级（这也是为什么说可以寻址 2^46 的空间而不是 2^48)。 在JOS 中，所有的异常都在内核模式处理，优先级为0 (用户模式为3)。
2. **任务状态段(Task State Segment, TSS)**
处理器需要保存中断和异常出现时的自身状态，例如 EIP 和 CS，以便处理完后能返回原函数继续执行。但是存储区域必须禁止用户访问，避免恶意代码或 bug 的破坏。
因此，当 x86 处理器处理从用户到内核的模式转换时，也会切换到内核栈。而 TSS 指明段选择器和栈地址。处理器将 SS, ESP, EFLAGS, CS, EIP 压入新栈，然后从 IDT 读取 CS 和 EIP，根据新栈设置 ESP 和 SS。
JOS 仅利用 TSS 来定义需要切换的内核栈。由于内核模式在 JOS 优先级是 0，因此处理器用 TSS 的 ESP0 和 SS0 来定义内核栈，无需 TSS 结构体中的其他内容。其中， SS0 种存储的是 `GD_KD(0x10)`，ESP0 种存储的是 `KSTACKTOP(0xf0000000)`。相关定义在`inc/memlayout.h`中可以找到。

#### 中断和异常的类型
x86 的所有异常可以用中断向量 0\~31 表示，对应 IDT 的第 0\~31 项。例如，页错误产生一个中断向量为 14 的异常。大于 32 的中断向量表示的都是中断，其中，软件中断用 `int` 指令产生，而硬件中断则由硬件在需要关注的时候产生。

#### 一个例子
通过一个例子来理解上面的知识。假设处理器正在执行用户环境的代码，遇到了"除0"异常。
1. 处理器切换到内核栈，利用了上文 TSS 中的 ESP0 和 SS0。
2. 处理器将异常参数 push 到了内核栈。一般情况下，按顺序 push `SS, ESP, EFLAGS, CS, EIP`

                     +--------------------+ KSTACKTOP             
                     | 0x00000 | old SS   |     " - 4
                     |      old ESP       |     " - 8
                     |     old EFLAGS     |     " - 12
                     | 0x00000 | old CS   |     " - 16
                     |      old EIP       |     " - 20 <---- ESP 
                     +--------------------+      
存储这些寄存器状态的意义是：SS(堆栈选择器) 的低 16 位与 ESP 共同确定当前栈状态；EFLAGS(标志寄存器)存储当前FLAG；CS(代码段寄存器) 和 EIP(指令指针寄存器) 确定了当前即将执行的代码地址，E 代表"扩展"至32位。根据这些信息，就能保证处理中断结束后能够恢复到中断前的状态。
3. 因为我们将处理一个"除0"异常，其对应中断向量是0，因此，处理器读取 IDT 的条目0，设置 `CS:EIP` 指向该条目对应的处理函数。
4. 处理函数获得程序控制权并且处理该异常。例如，终止进程的运行。

对于某些特殊的 x86 异常，除了以上 5 个参数以外，还需要存储一个 *error code*。

                     +--------------------+ KSTACKTOP             
                     | 0x00000 | old SS   |     " - 4
                     |      old ESP       |     " - 8
                     |     old EFLAGS     |     " - 12
                     | 0x00000 | old CS   |     " - 16
                     |      old EIP       |     " - 20
                     |     error code     |     " - 24 <---- ESP
                     +--------------------+     
例如，页错误异常（中断向量=14）就是一个重要的例子，它就需要额外存储一个 error code。
#### 嵌套的异常和中断
内核和用户进程都会引起异常和中断。然而，仅在从用户环境进入内核时才会切换栈。如果中断发生时已经在内核态了(此时， `CS` 寄存器的低 2bit 为 `00`) ，那么 CPU 就直接将状态压入内核栈，不再需要切换栈。这样，内核就能处理内核自身引起的"嵌套异常"，这是实现保护的重要工具。
如果处理器已经处于内核态，然后发生了嵌套异常，由于它并不进行栈切换，所以无须存储 `SS` 和 `ESP` 寄存器状态。对于不包含 error code 的异常，在进入处理函数前内核栈状态如下所示：

                     +--------------------+ <---- old ESP
                     |     old EFLAGS     |     " - 4
                     | 0x00000 | old CS   |     " - 8
                     |      old EIP       |     " - 12
                     +--------------------+             
对于包含了 error code 的异常，则将 error code 继续 push 到 `EIP`之后。
警告：如果 CPU 处理嵌套异常的时候，无法将状态 push 到内核栈（由于栈空间不足等原因），则 CPU 无法恢复当前状态，只能重启。当然，这是内核设计中必须避免的。
#### 建立中断描述符表(IDT)
通过上文，已经了解到了建立 IDT 以及处理异常所需要的基本信息。头文件 `inc/trap.h` 和 `kern/trap.h` 包含了与中断和异常相关的定义，需要仔细阅读。其中 `kern/trap.h` 包含内核私有定义，而 `inc/trap.h` 包含对内核以及用户进程和库都有用的定义。
每个异常和中断都应该在 `trapentry.S` 和 `trap_init()` 有自己的处理函数，并在 IDT 中将这些处理函数的地址初始化。每个处理函数都需要在栈上新建一个 `struct Trapframe`（见 `inc/trap.h`)，以其地址为参数调用 `trap()` 函数，然后进行异常处理。
>**Exercise 4.** 
Edit `trapentry.S` and `trap.c` and implement the features described above. The macros `TRAPHANDLER` and `TRAPHANDLER_NOEC` in `trapentry.S` should help you, as well as the T_* defines in `inc/trap.h`. You will need to add an entry point in `trapentry.S` (using those macros) for each trap defined in `inc/trap.h`, and you'll have to provide `_alltraps` which the TRAPHANDLER macros refer to. You will also need to modify `trap_init()` to initialize the `idt` to point to each of these entry points defined in `trapentry.S`; the `SETGATE` macro will be helpful here.
Your `_alltraps` should:
1. push values to make the stack look like a struct Trapframe
2. load `GD_KD` into `%ds` and `%es`
3. `pushl %esp` to pass a pointer to the Trapframe as an argument to `trap()`
4. call trap (can trap ever return?)

>Consider using the `pushal` instruction; it fits nicely with the layout of the `struct Trapframe`.
Test your trap handling code using some of the test programs in the `user` directory that cause exceptions before making any system calls, such as `user/divzero`. You should be able to get `make grade` to succeed on the `divzero`, `softint`, and `badsegment` tests at this point.

较难的一个练习，首先第一步是搞明白`TRAPHANDLER`这段汇编代码的意义：
```
#define TRAPHANDLER(name, num)	
	.globl name;		
	.type name, @function;	
	.align 2;
	name:
	/*
	*  pushl $0;    // if no error code 
	*/
	pushl $(num);							
	jmp _alltraps
```
1. .global/ .globl ：用来定义一个全局的符号，格式如下:
`.global symbol` 或者 `.globl symbol`
汇编函数如果需要在其他文件调用，需要把函数声明为全局的，此时就会用到 `.global`这个伪操作。
2. .type : 用来指定一个符号的类型是函数类型或者是对象类型,对象类型一般是数据, 格式如下:
`.type symbol, @object`
`.type symbol, @function`
3. .align : 用来指定内存对齐方式，格式如下：
 `.align size` 
表示按 size 字节对齐内存。

这一步做了什么？光看这里很难理解，提示说是构造一个 `Trapframe` 结构体来保存现场，但是这里怎么直接就 push 中断向量了？实际上，在上文已经指出， cpu 自身会先 push 一部分寄存器（见例子所述），而其他则由用户和操作系统决定。由于中断向量是操作系统定义的，所以从这部分开始就已经不属于 cpu 的工作范畴了。
 
在 `trapentry.S` 中：
```
TRAPHANDLER_NOEC(handler0, T_DIVIDE)
TRAPHANDLER_NOEC(handler1, T_DEBUG)
TRAPHANDLER_NOEC(handler2, T_NMI)
TRAPHANDLER_NOEC(handler3, T_BRKPT)
TRAPHANDLER_NOEC(handler4, T_OFLOW)
TRAPHANDLER_NOEC(handler5, T_BOUND)
TRAPHANDLER_NOEC(handler6, T_ILLOP)
TRAPHANDLER_NOEC(handler7, T_DEVICE)
TRAPHANDLER(handler8, T_DBLFLT)
// 9 deprecated since 386
TRAPHANDLER(handler10, T_TSS)
TRAPHANDLER(handler11, T_SEGNP)
TRAPHANDLER(handler12, T_STACK)
TRAPHANDLER(handler13, T_GPFLT)
TRAPHANDLER(handler14, T_PGFLT)
// 15 reserved by intel
TRAPHANDLER_NOEC(handler16, T_FPERR)
TRAPHANDLER(handler17, T_ALIGN)
TRAPHANDLER_NOEC(handler18, T_MCHK)
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
// system call (interrupt)
TRAPHANDLER_NOEC(handler48, T_SYSCALL)
```
该部分主要作用是声明函数。该函数是全局的，但是在 C 文件中使用的时候需要使用 `void name();` 再声明一下。
```
_alltraps:
pushl %ds
pushl %es
pushal

movw $GD_KD, %ax
movw %ax, %ds
movw %ax, %es
pushl %esp
call trap
```
这部分较有难度，首先要搞明白，栈是从高地址向低地址生长，而结构体在内存中的存储是从低地址到高地址。而 cpu 以及`TRAPHANDLER`宏已经将压栈工作进行到了中断向量部分，若要形成一个 `Trapframe`，则还应该依次压入 `ds`, `es`以及 `struct PushRegs`中的各寄存器（倒序，可使用 `pusha`指令）。此后还需要更改数据段为内核的数据段。**注意，不能用立即数直接给段寄存器赋值。**因此不能直接写`movw $GD_KD, %ds`。

在`kern/trap.c` 中：
```
void
trap_init(void)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	void handler0();
	void handler1();
	void handler2();
	void handler3();
	void handler4();
	void handler5();
	void handler6();
	void handler7();
	void handler8();

	void handler10();
	void handler11();
	void handler12();
	void handler13();
	void handler14();

	void handler16();
	void handler17();
	void handler18();
	void handler19();
	void handler48();

	SETGATE(idt[T_DIVIDE], 1, GD_KT, handler0, 0);
	SETGATE(idt[T_DEBUG], 1, GD_KT, handler1, 0);
	SETGATE(idt[T_NMI], 1, GD_KT, handler2, 0);
	SETGATE(idt[T_BRKPT], 1, GD_KT, handler3, 0);
	SETGATE(idt[T_OFLOW], 1, GD_KT, handler4, 0);
	SETGATE(idt[T_BOUND], 1, GD_KT, handler5, 0);
	SETGATE(idt[T_ILLOP], 1, GD_KT, handler6, 0);
	SETGATE(idt[T_DEVICE], 1, GD_KT, handler7, 0);
	SETGATE(idt[T_DBLFLT], 1, GD_KT, handler8, 0);

	SETGATE(idt[T_TSS], 1, GD_KT, handler10, 0);
	SETGATE(idt[T_SEGNP], 1, GD_KT, handler11, 0);
	SETGATE(idt[T_STACK], 1, GD_KT, handler12, 0);
	SETGATE(idt[T_GPFLT], 1, GD_KT, handler13, 0);
	SETGATE(idt[T_PGFLT], 1, GD_KT, handler14, 0);
	
	SETGATE(idt[T_FPERR], 1, GD_KT, handler16, 0);
	SETGATE(idt[T_ALIGN], 1, GD_KT, handler17, 0);
	SETGATE(idt[T_MCHK], 1, GD_KT, handler18, 0);
	SETGATE(idt[T_SIMDERR], 1, GD_KT, handler19, 0);

	// interrupt
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 0);
	
	// Per-CPU setup 
	trap_init_percpu();
}
```
重点是两个问题。
1. 函数如何声明？
这个问题其实已经在 trapentry.S 的注释里回答了。注意该函数已经是全局的了，不需要再添加 extern 画蛇添足。
2. SETGATE 如何使用？
参见 `inc/mmu.h` 中的函数定义。
```
#define SETGATE(gate, istrap, sel, off, dpl)			
{								
	(gate).gd_off_15_0 = (uint32_t) (off) & 0xffff;		
	(gate).gd_sel = (sel);					
	(gate).gd_args = 0;					
	(gate).gd_rsv1 = 0;					
	(gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;	
	(gate).gd_s = 0;					
	(gate).gd_dpl = (dpl);					
	(gate).gd_p = 1;					
	(gate).gd_off_31_16 = (uint32_t) (off) >> 16;		
}
```
gate
这是一个 `struct Gatedesc`。
istrap
该中断是 trap(exception) 则为1，是 interrupt 则为0。
sel
代码段选择器。进入内核的话是 `GD_KT`。
off
相对于段的偏移，简单来说就是函数地址。
dpl(Descriptor Privileged Level)
权限描述符。

>**Question 1**
What is the purpose of having an individual handler function for each exception/interrupt? (i.e., if all exceptions/interrupts were delivered to the same handler, what feature that exists in the current implementation could not be provided?)

每个异常和中断处理方式不同，例如 除0 异常不会返回程序继续执行，而 I/O 操作中断会返回程序继续执行。用一个handler难以实现。

>**Question 2**
Did you have to do anything to make the `user/softint` program behave correctly? The grade script expects it to produce a general protection fault (trap 13), but `softint`'s code says int $14. Why should this produce interrupt vector 13? What happens if the kernel actually allows `softint`'s int $14 instruction to invoke the kernel's page fault handler (which is interrupt vector 14)?

`user/softint.c`内容如下：
```
// buggy program - causes an illegal software interrupt

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
}
```
`grade-lab3`中对应的评分标准如下：
```
@test(10)
def test_softint():
    r.user_test("softint")
    r.match('Welcome to the JOS kernel monitor!',
            'Incoming TRAP frame at 0xefffffbc',
            'TRAP frame at 0xf.......',
            '  trap 0x0000000d General Protection',
            '  eip  0x008.....',
            '  ss   0x----0023',
            '.00001000. free env 0000100')
```
可以看出，该程序代码中希望能产生一个缺页异常(`int $14`)，实际上评判却说明产生的是通用保护异常(`int $13`)。这是因为目前系统运行在用户态，权限级别为 3，而 INT 指令是系统指令，权限级别为 0，因此会首先引发 Gerneral Protection Excepetion。即 trap 13。

### Part B: 缺页错误，断点异常以及系统调用
---
#### 处理缺页错误
缺页错误异常，中断向量 14 (`T_PGFLT`)，是一个非常重要的异常类型，lab3 以及 lab4 都强烈依赖于这个异常处理。当程序遇到缺页异常时，它将引起异常的虚拟地址存入 `CR2` 控制寄存器( control register)。在 `trap.c` 中，我们已经提供了`page_fault_handler()` 函数用来处理缺页异常。
> **Exercise 5.** 
Modify `trap_dispatch()` to dispatch page fault exceptions to `page_fault_handler()`. You should now be able to get make grade to succeed on the `faultread`, `faultreadkernel`, `faultwrite`, and `faultwritekernel` tests. If any of them don't work, figure out why and fix them. Remember that you can boot JOS into a particular user program using make run-x or make run-x-nox.

较为简单，实际上就是在`trap_dispatch()`中根据 trap number 进行一个处理分配。目前只需要加入缺页异常即可完成该 exercise。
```
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
		case T_PGFLT:
			page_fault_handler(tf);
			break;
		default:
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
		if (tf->tf_cs == GD_KT)
			panic("unhandled trap in kernel");
		else {
			env_destroy(curenv);
			return;
		}
	}
}
```
在后续的程序中，还会对缺页异常的处理进行完善。
#### 断点异常
断点异常，中断向量 3 (`T_BRKPT`) 允许调试器给程序加上断点。原理是暂时把程序中的某个指令替换为一个 1 字节大小的 `int3`软件中断指令。在 JOS 中，我们将它实现为一个伪系统调用。这样，任何程序（不限于调试器）都能使用断点功能。
>**Exercise 6.**
Modify `trap_dispatch()` to make breakpoint exceptions invoke the kernel monitor. You should now be able to get make grade to succeed on the `breakpoint` test.

跟之前的练习实现方法是一样的。另外需要找到在 `kern/monitor.c` 中的 `void monitor(struct TrapFrame *tf)`函数。改写 trap_dispatch 函数，加入断点处理。
```
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
		case T_PGFLT:
			page_fault_handler(tf);
			break;
		case T_BRKPT:
			monitor(tf);
			break;
		default:
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
		if (tf->tf_cs == GD_KT)
			panic("unhandled trap in kernel");
		else {
			env_destroy(curenv);
			return;
		}
	}
}
```
第一次运行发现并没有通过检验，报的是通用保护异常。一看是权限问题。把 Exercise 4 中的
```
SETGATE(idt[T_BRKPT], 1, GD_KT, handler3, 0);
```
改为：
```
SETGATE(idt[T_BRKPT], 1, GD_KT, handler3, 3);
```
即可完成。
>**Question 3**
The break point test case will either generate a break point exception or a general protection fault depending on how you initialized the break point entry in the IDT (i.e., your call to `SETGATE` from `trap_init`). Why? How do you need to set it up in order to get the breakpoint exception to work as specified above and what incorrect setup would cause it to trigger a general protection fault?

其实就是我描述的权限问题。
>**Question 4**
What do you think is the point of these mechanisms, particularly in light of what the user/softint test program does?

在`inc/mmu.h` 中可以找到：
```
// Gate descriptors for interrupts and traps
struct Gatedesc {
	unsigned gd_off_15_0 : 16;   // low 16 bits of offset in segment
	unsigned gd_sel : 16;        // segment selector
	unsigned gd_args : 5;        // # args, 0 for interrupt/trap gates
	unsigned gd_rsv1 : 3;        // reserved(should be zero I guess)
	unsigned gd_type : 4;        // type(STS_{TG,IG32,TG32})
	unsigned gd_s : 1;           // must be 0 (system)
	unsigned gd_dpl : 2;         // descriptor(meaning new) privilege level
	unsigned gd_p : 1;           // Present
	unsigned gd_off_31_16 : 16;  // high bits of offset in segment
};
```
优先级低的代码无法访问优先级高的代码，优先级高低由 gd_dpl 判断。数字越小越高。

#### 系统调用
用户进程通过系统调用来让内核为他们服务。当用户进程召起一次系统调用，处理器将进入内核态，处理器以及内核合作存储用户进程的状态，内核将执行适当的代码来完成系统调用，最后返回用户进程继续执行。实现细节各个系统有所不同。
JOS 内核使用 `int` 指令来触发一个处理器中断。特别的，我们使用 `int $0x30` 作为系统调用中断。它并不能由硬件产生，因此使用它不会产生歧义。
应用程序会把系统调用号 (**与中断向量不是一个东西**) 以及系统调用参数传递给寄存器。这样，内核就不用在用户栈或者指令流里查询这些信息。系统调用号将存放于`%eax`，参数（至多5个）会存放于`%edx`, `%ecx`,` %ebx`, `%edi` 以及 `%esi`，调用结束后，内核将返回值放回到`%eax`。

>**Exercise 7.**
 Add a handler in the kernel for interrupt vector `T_SYSCALL`. You will have to edit `kern/trapentry.S` and `kern/trap.c`'s `trap_init()`. You also need to change `trap_dispatch()` to handle the system call interrupt by calling `syscall()` (defined in `kern/syscall.c`) with the appropriate arguments, and then arranging for the return value to be passed back to the user process in `%eax`. Finally, you need to implement `syscall()` in `kern/syscall.c`. Make sure `syscall()` returns `-E_INVAL` if the system call number is invalid. You should read and understand `lib/syscall.c` (especially the inline assembly routine) in order to confirm your understanding of the system call interface. Handle all the system calls listed in `inc/syscall.h` by invoking the corresponding kernel function for each call.

又是一个比较烧脑的练习，`kern` 中有一套 `syscall.h syscall.c`，`inc`和`lib`中又有一套`syscall.h syscall.c`。需要理清这两者之间的关系。

**inc/syscall.h**

```
#ifndef JOS_INC_SYSCALL_H
#define JOS_INC_SYSCALL_H

/* system call numbers */
enum {
	SYS_cputs = 0,
	SYS_cgetc,
	SYS_getenvid,
	SYS_env_destroy,
	NSYSCALLS
};

#endif /* !JOS_INC_SYSCALL_H */
```
这个头文件主要定义了系统调用号，实际就是一个 enum 而已。

**lib/syscall.c**
```
// System call stubs.

#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	int32_t ret;

	// Generic system call: pass system call number in AX,
	// up to five parameters in DX, CX, BX, DI, SI.
	// Interrupt kernel with T_SYSCALL.
	//
	// The "volatile" tells the assembler not to optimize
	// this instruction away just because we don't use the
	// return value.
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
		     : "=a" (ret)
		     : "i" (T_SYSCALL),
		       "a" (num),
		       "d" (a1),
		       "c" (a2),
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
```
这是系统调用的通用模板，不同的系统调用 (例如sys_cputs,  sys_cgetc) 都会以不同参数调用 syscall 函数。为了了解 syscall 函数到底做了什么，需要看懂其中的内联汇编部分。

**补充知识：GCC内联汇编**

其语法固定为：
`asm volatile (“asm code”：output：input：changed);`
```
    asm volatile("int %1\n"
             : "=a" (ret)
             : "i" (T_SYSCALL),
               "a" (num),
               "d" (a1),
               "c" (a2),
               "b" (a3),
               "D" (a4),
               "S" (a5)
             : "cc", "memory");
```

|符号   |               描述    |
| :-------------: |:-------------:| 
|a               |          使用%eax, %ax, %al寄存器|
|b               |          使用%ebx, %bx, %bl寄存器|
|c               |          使用%ecx, %cx, %cl寄存器|
|d              |           使用%edx, %dx, %dl寄存器|
|S              |         使用%esi, %si寄存器|
|D              |         使用%edi, %di寄存器|
|i                |         使用立即整数值|

除了这些约束之外, 输出值还包含一个约束修饰符:

|输出修饰符                |             描述|
| :-------------: |:-------------:| 
|+            |      可以读取和写入操作数|
|=            |      只能写入操作数|
|%           |       如果有必要操作数可以和下一个操作数切换|
|&            |       在内联函数完成之前, 可以删除和重新使用操作数|

根据表格内容，可以看出该内联汇编作用就是引发一个`int`中断，中断向量为立即数 `T_SYSCALL`，同时，对寄存器进行操作。看懂这，就清楚了，这一部分应该不需要我们改动，因为我们处理的是中断已经产生后的部分。**当然，还有另一种更简单的思路，**`inc/` **目录下的，其实都是操作系统留给用户的接口**，所以才会在里面看到 `stdio.h`，`assert.h` 等文件。那么，要进行系统调用肯定也是先调用 `inc/` 中的那个，具体处理应该是在 `kern/` 中实现。

**kern/trap.c**

首先不要忘记在 trap_init 中设置好入口，并且权限设为3，使得用户进程能够产生这个中断。
```
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3);
```
另外就是 trap_dispatch 函数中加入相应的处理方法：
```
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, 
							tf->tf_regs.reg_edx,
							tf->tf_regs.reg_ecx,
							tf->tf_regs.reg_ebx,
							tf->tf_regs.reg_edi,
							tf->tf_regs.reg_esi);
			break;
```
由于已经通过 `lib/syscall.c` 处理，tf 结构体中存储的寄存器状态已经记录了系统调用号，系统调用参数等等。现在我们就可以利用这些信息调用 `kern/syscall.c` 中的函数了。

**kern/syscall.c**

我们在 `kern/trap.c` 中调用的实际上就是这里的 syscall 函数，而不是 `lib/syscall.c` 中的那个。想明白这一点，设置参数也就很简单了，注意返回值的处理。
```
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	
	int32_t retVal = 0;
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char *)a1, a2);
		break;
	case SYS_cgetc:
		retVal = sys_cgetc();
		break;
	case SYS_env_destroy:
		retVal = sys_env_destroy(a1);
		break;
	case SYS_getenvid:
		retVal = sys_getenvid() >= 0;
		break;
	default:
		retVal = -E_INVAL;
	}
	return retVal;
}
```
至此，本 exercise 结束，运行 `make grade` 可以通过 testbss，运行 `make run-hello` 可以打印出 `hello world`，紧接着提示了页错误。
通过 exercise 7，可以看出 JOS系 统调用的步骤为：
1. 用户进程使用 `inc/` 目录下暴露的接口
2. `lib/syscall.c` 中的函数将系统调用号及必要参数传给寄存器，并引起一次 `int $0x30` 中断
3. `kern/trap.c` 捕捉到这个中断，并将 TrapFrame 记录的寄存器状态作为参数，调用处理中断的函数
4. `kern/syscall.c` 处理中断

#### 用户进程启动
用户进程从 `lib/entry.S` 开始运行。经过一些设置，调用了 `lib/libmain.c` 下的 `libmain()` 函数。在 `libmain()` 中，我们需要把全局指针 `thisenv` 指向该程序在 `envs[]` 数组中的位置。
`libmain()` 会调用 `umain`，即用户进程的main函数。在`user/hello.c`中，可以看到其内容为：
```
void
umain(int argc, char **argv)
{
	cprintf("hello, world\n");
	cprintf("i am environment %08x\n", thisenv->env_id);  // 之前就在这里报错，因为thisenv = 0
}
```
在 Exercise 8 中，我们将设置好 thisenv，这样就能正常运行用户进程了。这也是我们第一次用到内存的 `UENVS` 区域。
>**Exercise 8.**
Add the required code to the user library, then boot your kernel. You should see `user/hello` print `"hello, world"` and then print `"i am environment 00001000"`. `user/hello` then attempts to "exit" by calling `sys_env_destroy()` (see lib/libmain.c and lib/exit.c). Since the kernel currently only supports one user environment, it should report that it has destroyed the only environment and then drop into the kernel monitor. You should be able to get make grade to succeed on the hello test.

原以为是个很简单的练习，然而我代码写好了却无法运行成功。这个练习重在检查以前的代码，之前很多代码虽然通过了 `make grade`，却不一定正确。
在 `lib/libmain.c` 中把 `thisenv = 0` 改为：
```
	thisenv = &envs[ENVX(sys_getenvid())];
```
即可通过。记录我自己犯的错误如下：
1. 在 `kern/syscall.c` 的函数 `syscall()` 中：
```
    case SYS_getenvid:
        // retVal = sys_getenvid() >= 0; 错误，应该返回获取的id
        // 返回值不仅是用于判断执行成功与否，也可能携带信息
        retVal = sys_getenvid();
        break;
```
2. 在 `kern/env.c` 的函数 `region_alloc` 中，我原先的写法为：
```
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	
	size_t pgnum = ROUNDUP(len, PGSIZE) / PGSIZE;
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	struct PageInfo *pginfo = NULL;
	for (size_t i=0; i<pgnum; i++) {
		pginfo = page_alloc(0);
		if (! pginfo) {
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
		}
		int r = page_insert(e->env_pgdir, pginfo, (void *)va_start, PTE_W | PTE_U | PTE_P);
		if (r < 0) {
			panic("region_alloc: %e" , r);
		}
		va_start += PGSIZE;
	}
}
```
大致思想是先根据 len 求出要插入多少页，再挨个插入。但是这样存在一个极大的隐患，在这个 Exercise 8 中暴露出来了。错误情况为：
```
Incoming TRAP frame at 0xf0106600
Incoming TRAP frame at 0xf0106588
Incoming TRAP frame at 0xf0106510
Incoming TRAP frame at 0xf0106498
Incoming TRAP frame at 0xf0106420
...
qemu: fatal: Trying to execute code outside RAM or ROM at 0xf00b80a0
```
将分配过程输出后可以看到问题关键：
```
Allocate size: 00000fe4, Start from: 00800020
page size = round_up(4068 / 4096) = 1
insert page at 00800000
region allocation completed...
```
可以看出，这里只插入了一页，然而实际上应该要插入两页才合适。因为页面对齐不是根据某个地址来做的，而是对整个内存的对齐，类似于 `0x00800020` 到 `0x00801014`这段内存，虽然长度不足一页，但实际上横跨了 `0x00800000~0x00801000` 以及 `0x00801000~0x00802000` ，而按照之前的写法，没有插入  `0x00801000~0x00802000` 这一段内存，必然会导致出错。分析出原因，改动就很容易了，将实现改为根据最初地址和最终地址来进行对齐即可。
```
static void
region_alloc(struct Env *e, void *va, size_t len)
{

	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
	struct PageInfo *pginfo = NULL;
	for (int cur_va=va_start; cur_va<va_end; cur_va+=PGSIZE) {
		pginfo = page_alloc(0);
		if (!pginfo) {
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
		}
		cprintf("insert page at %08x\n",cur_va);
		page_insert(e->env_pgdir, pginfo, (void *)cur_va, PTE_U | PTE_W | PTE_P);
	}
}
```

经过一系列的改动，运行成功。自己挖的坑还是得自己填。

#### 页错误 & 内存保护
内存保护是操作系统的关键功能，它确保了一个程序中的错误不会导致其他程序或是操作系统自身的崩溃。
操作系统通常依赖硬件的支持来实现内存保护。操作系统会告诉硬件哪些虚拟地址可用哪些不可用。当某个程序想访问不可用的内存地址或不具备权限时，处理器将在出错指令处停止程序，然后陷入内核。如果错误可以处理，内核就处理并恢复程序运行，否则无法恢复。
作为可以修复的错误，设想某个自动生长的栈。在许多系统中内核首先分配一个页面给栈，如果某个程序访问了页面外的空间，内核会自动分配更多页面以让程序继续。这样，内核只用分配程序需要的栈内存给它，然而程序感觉仿佛可以拥有任意大的栈内存。
系统调用也为内存保护带来了有趣的问题。许多系统调用接口允许用户传递指针给内核，这些指针指向待读写的用户缓冲区。内核处理系统调用的时候会对这些指针解引用。这样就带来了两个问题：
1. 内核的页错误通常比用户进程的页错误严重得多，如果内核在操作自己的数据结构时发生页错误，这就是一个内核bug，会引起系统崩溃。因此，内核需要记住这个错误是来自用户进程。
2. 内核比用户进程拥有更高的内存权限，用户进程给内核传递的指针可能指向一个只有内核能够读写的区域，内核必须谨慎避免解引用这类指针，因为这样可能导致内核的私有信息泄露或破坏内核完整性。

我们将对用户进程传给内核的指针做一个检查来解决这两个问题。内核将检查指针指向的是内存中用户空间部分，页表也允许内存操作。

>**Exercise 9.**
Change `kern/trap.c` to panic if a page fault happens in kernel mode.
Hint: to determine whether a fault happened in user mode or in kernel mode, check the low bits of the `tf_cs`.
Read user_mem_assert in `kern/pmap.c` and implement `user_mem_check` in that same file.
Change `kern/syscall.c` to sanity check arguments to system calls.
Boot your kernel, running user/buggyhello. The environment should be destroyed, and the kernel should not panic. You should see:

	[00001000] user_mem_check assertion failure for va 00000001
	[00001000] free env 00001000
	Destroyed the only environment - nothing more to do!

>Finally, change `debuginfo_eip` in `kern/kdebug.c` to call `user_mem_check` on `usd`, `stabs`, and `stabstr`.

在 `kern/trap.c` 中加入判断页错误来源。原理见 IDT 表部分的讲解。
```
void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// 在这里判断 cs 的低 2bit
	if ((tf->tf_cs & 3) == 0) panic("Page fault in kernel-mode");

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}
```
在 `kern/pmap.c` 中修改检查用户内存的部分。需要注意的是由于需要存储第一个访问出错的地址，`va` 所在的页面需要单独处理一下，不能直接对齐。
```
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
			if (cur_va == start_va) {
				user_mem_check_addr = (uintptr_t)va;
			} else {
				user_mem_check_addr = cur_va;
			}
			return -E_FAULT;
		}
	}
	return 0;
}
```
在 `kern/syscall.c` 中的输出字符串部分加入内存检查。
```
static void
sys_cputs(const char *s, size_t len)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
}
```
在 `kern/kdebug.c` 中的 `debuginfo_eip` 函数中加入内存检查。
```
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
		}
...
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)stabs, stab_end-stabs, PTE_U) < 0) {
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, stabstr_end-stabstr, PTE_U) < 0) {
			return -1;
		}
```
> **Question**
If you now run `user/breakpoint`, you should be able to run `backtrace` from the kernel monitor and see the backtrace traverse into `lib/libmain.c` before the kernel panics with a page fault. What causes this page fault? You don't need to fix it, but you should understand why it happens.

运行 `make run-breakpoint` 并`backtrace` 得到输出：
```
Stack backtrace:
	     ebp efffff20  eip f0100a75  args 00000001 efffff38 f01b4000 00000000 f0172840
	     	     kern/monitor.c:187: monitor+276
	     ebp efffff90  eip f0103833  args f01b4000 efffffbc f0105c64 00000082 00000000
	     	     kern/trap.c:196: trap+169
	     ebp efffffb0  eip f010393b  args efffffbc 00000000 00000000 eebfdfd0 efffffdc
	     	     kern/syscall.c:68: syscall+0
	     ebp eebfdfd0  eip 800073  args 00000000 00000000 eebfdff0 00800049 00000000
	     	     lib/libmain.c:27: libmain+58
Incoming TRAP frame at 0xeffffeac
kernel panic at kern/trap.c:268: Page fault in kernel-mode
```
从输出的 ebp 寄存器内容可以看出，`efffff20`, `efffff90`, `efffffb0`都位于内核栈上，仅有 `eebfdfd0` 位于用户栈上。
这是一个较难的问题，要想清楚搞明白，自然要依靠 gdb。这里使用需要一点技巧。
首先打开终端输入
```
make run-breakpoint-gdb
```
另开一个终端输入
```
make gdb
```
再设置断点为断点异常调用函数中的一句
```
(gdb) b kern/monitor.c:179
```
首先回忆一下，`%ebp` 中实际存放的是一个地址，该地址前后存放了许多关键信息。例如：
```
(gdb) x/8x 0xefffffb0
0xefffffb0:	0xeebfdfd0	0xf010393b	0xefffffbc	0x00000000
0xefffffc0:	0x00000000	0xeebfdfd0	0xefffffdc	0x00000000
```
分别是：
```
调用者ebp   返回地址eip  参数1  参数2
参数3       参数4        参数5  ...
```
查看 `eebfdfd0` 至用户栈顶 `eebfe000` 之间 12 个字节里到底是什么内容：
```
(gdb) x/12x 0xeebfdfd0
0xeebfdfd0:	0xeebfdff0	0x00800073	0x00000000	0x00000000
0xeebfdfe0:	0xeebfdff0	0x00800049	0x00000000	0x00000000
0xeebfdff0:	0x00000000	0x00800031	0x00000000	0x00000000
```
可以看出，按照 backtrace 的逻辑 (**参见lab 1**)，每次希望打印出5个参数，下一次期望打印出
```
ebp eebfdff0  eip 800031  args 00000000 00000000 (此后的内存地址已越界)
```
为了证明这个猜想，修改`kern/monitor.c` 将打印参数改为两个
```
/*
cprintf("\tebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
*/
cprintf("\tebp %x  eip %x  args %08x %08x \n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3]);
```
再进行测试，则得出：
```
Stack backtrace:
	     ebp efffff20  eip f0100a6f  args 00000001 efffff38
	     	     kern/monitor.c:190: monitor+276
	     ebp efffff90  eip f010382d  args f01b4000 efffffbc
	     	     kern/trap.c:196: trap+169
	     ebp efffffb0  eip f0103935  args efffffbc 00000000
	     	     kern/syscall.c:68: syscall+0
	     ebp eebfdfd0  eip 800073  args 00000000 00000000
	     	     lib/libmain.c:27: libmain+58
	     ebp eebfdff0  eip 800031  args 00000000 00000000
	     	     lib/entry.S:34: <unknown>+0
K> 
```
没有再出现 page fault，猜想正确。造成该现象的原因是 `lib/entry.S` 
```
// Entrypoint - this is where the kernel (or our parent environment)
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
	jne args_exist

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
	pushl $0

args_exist:
	call libmain
1:	jmp 1b
```
这里通过 `%esp` 位置来判断是否是内核载入的用户环境。因为只有一个用户环境，所以在载入之初用户栈为空，`%esp` 最初肯定指向`USTACKTOP`。如果是这样，压入两个假参数，此后调用 `libmain`。这就导致了输出大于 2 个参数就出现页错误。
