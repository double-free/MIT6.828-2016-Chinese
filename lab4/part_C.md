## 抢占式多进程处理 & 进程间通信

作为 lab4 的最后一步，我们要修改内核使之能抢占一些不配合的进程占用的资源，以及允许进程之间的通信。

### Part I: 时钟中断以及抢占
尝试运行一下 `user/spin` 测试，该测试建立一个子进程，该子进程获得 CPU 资源后就进入死循环，这样内核以及父进程都无法再次获得 CPU。这显然是操作系统需要避免的。为了允许内核从一个正在运行的进程抢夺 CPU 资源，我们需要支持来自硬件时钟的外部硬件中断。

#### Interrupt discipline
外部中断用 IRQ(Interrupt Request) 表示。一共有 16 种 IRQ，在 `picirq.c`中将其增加了 `IRQ_OFFSET` 的偏移映射到了 IDT。
在 `inc/trap.h` 中， `IRQ_OFFSET` 被定义为 32。因此，IDT[32] 包含了时钟中断的处理入口地址。
联想 Lab3 中的内容：
>x86 的所有异常可以用中断向量 0~31 表示，对应 IDT 的第 0~31 项。例如，页错误产生一个中断向量为 14 的异常。大于 32 的中断向量表示的都是中断

相对 xv6，在 JOS 中我们中了一个关键的简化：在内核态时禁用外部设备中断。外部中断使用 `%eflag` 寄存器的 `FL_IF` 位控制。当该位置 1 时，开启中断。由于我们的简化，我们只在进入以及离开内核时需要修改这个位。

我们需要确保在用户态时 `FL_IF` 置 1，使得当有中断发生时，可以被处理。我们在 bootloader 的第一条指令 `cli` 就关闭了中断，然后再也没有开启过。

>**Exercise 13.**
Modify `kern/trapentry.S` and `kern/trap.c` to initialize the appropriate entries in the IDT and provide handlers for IRQs 0 through 15. Then modify the code in `env_alloc()` in kern/env.c to ensure that user environments are always run with interrupts enabled.

比较简单，跟 Lab3 中的 Exercise 4 大同小异。相关的常数定义在 `inc/trap.h` 中可以找到。
在 `kern/trapentry.S` 中加入：
```asm
// IRQs
TRAPHANDLER(handler32, IRQ_OFFSET + IRQ_TIMER)
TRAPHANDLER(handler33, IRQ_OFFSET + IRQ_KBD)
TRAPHANDLER(handler36, IRQ_OFFSET + IRQ_SERIAL)
TRAPHANDLER(handler39, IRQ_OFFSET + IRQ_SPURIOUS)
TRAPHANDLER(handler46, IRQ_OFFSET + IRQ_IDE)
TRAPHANDLER(handler51, IRQ_OFFSET + IRQ_ERROR)
```
在 `kern/trap.c` 的 `trap_init()` 中加入：
```c
	// IRQs
	void handler32();
	void handler33();	
	void handler36();
	void handler39();
	void handler46();
	void handler51();
...
	// IRQs
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, handler32, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, handler33, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, handler36, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, handler39, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, handler46, 0);
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, handler51, 0);
```
在 `kern/env.c` 的 `env_alloc()` 中加入：
```c
	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
```
##### Handling Clock Interrupts
在 `user/spin` 程序中，子进程开启后就陷入死循环，此后 kernel 无法再获得控制权。我们需要让硬件周期性地产生时钟中断，强制将控制权交给 kernel，使得我们能够切换到其他进程。

>**Exercise 14.**
Modify the kernel's `trap_dispatch()` function so that it calls `sched_yield()` to find and run a different environment whenever a clock interrupt takes place.

这个练习本身非常简单，但是我却出现了一个错误，即在 `kern/trap.c` 中的 `trap()` 函数中无法通过这个断言：
```c
	assert(!(read_eflags() & FL_IF));
```
这个问题非常难查，浪费了2天时间。最终在网上多方比较代码后，发现其实是 Lab3 的 Exercise 4 中的遗留问题。它虽然不影响之前的练习，但是这里却暴露出来。实际上是对 `SETGATE` 这个宏理解不够导致的。当时我根据对注释的理解，把 `SETGATE` 的第二个参数都写成了 1。主要是被注释中的 `istrap: 1 for a trap (= exception) gate, 0 for an interrupt gate.` 误导。
```c
SETGATE(idt[T_PGFLT], 1, GD_KT, handler14, 0);
```
但是，根据 `SETGATE` 的注释，其真实的区别在于，设为 1 就会在开始处理中断时将 FL_IF 位重新置1，而设为 0 则保持 FL_IF 位不变。根据这里的需求，显然应该置0。
```c
// Set up a normal interrupt/trap gate descriptor.
// - istrap: 1 for a trap (= exception) gate, 0 for an interrupt gate.
    //   see section 9.6.1.3 of the i386 reference: "The difference between
    //   an interrupt gate and a trap gate is in the effect on IF (the
    //   interrupt-enable flag). An interrupt that vectors through an
    //   interrupt gate resets IF, thereby preventing other interrupts from
    //   interfering with the current interrupt handler. A subsequent IRET
    //   instruction restores IF to the value in the EFLAGS image on the
    //   stack. An interrupt through a trap gate does not change IF."
// - sel: Code segment selector for interrupt/trap handler
// - off: Offset in code segment for interrupt/trap handler
// - dpl: Descriptor Privilege Level -
//	  the privilege level required for software to invoke
//	  this interrupt/trap gate explicitly using an int instruction.
#define SETGATE(gate, istrap, sel, off, dpl)			\
{								\
	(gate).gd_off_15_0 = (uint32_t) (off) & 0xffff;		\
	(gate).gd_sel = (sel);					\
	(gate).gd_args = 0;					\
	(gate).gd_rsv1 = 0;					\
	(gate).gd_type = (istrap) ? STS_TG32 : STS_IG32;	\
	(gate).gd_s = 0;					\
	(gate).gd_dpl = (dpl);					\
	(gate).gd_p = 1;					\
	(gate).gd_off_31_16 = (uint32_t) (off) >> 16;		\
}
```
这个最大的坑解决后，后面的就很简单了。直接在 `trap_dispatch()` 中添加时钟中断的分支即可。
```c
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
		lapic_eoi();
		sched_yield();
		return;
	}
```
总结就是，实在太坑。异常处理的内容实在太多，战线太长了。出了错误非常难找。

### Part II: 进程间通信(IPC)
在之前的 Lab 中，我们一直在讲操作系统是如何隔离各个进程的，怎么让程序感觉独占一台机器的。操作系统的另一个重要功能就是允许进程之间相互通信。

#### IPC in JOS
我们将实现两个系统调用：`sys_ipc_recv` 以及 `sys_ipc_try_send` ，再将他们封装为两个库函数，`ipc_recv` 和 `ipc_send` 以支持通信。
实际上，进程之间发送的信息是由两个部分组成，一个 `int32_t`，一个页面映射(可选)。

#### 发送和接收消息
进程使用 `sys_ipc_recv` 来接收消息。该系统调用会将程序挂起，让出 CPU 资源，直到收到消息。在这个时期，任一进程都能给他发送信息，不限于父子进程。
为了发送信息，进程会调用 `sys_ipc_try_send`，以接收者的进程 id 以及要发送的值为参数。如果接收者已经调用了 `sys_ipc_recv` ，则成功发送消息并返回0。否则返回 `E_IPC_NOT_RECV` 表明目标进程并没有接收消息。
`ipc_send` 库函数将会反复执行 `sys_ipc_try_send` 直到成功。

#### 传递页面
当进程调用 `sys_ipc_recv` 并提供一个虚拟地址 `dstva` (必须位于用户空间) 时，进程表示它希望能接收一个页面映射。如果发送者发送一个页面，该页面就会被映射到接收者的 `dstva`。同时，之前位于 `dstva` 的页面映射会被覆盖。

当进程调用 `sys_ipc_try_send` 并提供一个虚拟地址 `srcva` (必须位于用户空间)，表明发送者希望发送位于 `srcva` 的页面给接收者，权限设置为 `perm`。

在一个成功的 IPC 之后，发送者和接受者将共享一个物理页。

> **Exercise 15.**
Implement `sys_ipc_recv` and `sys_ipc_try_send` in kern/syscall.c. Read the comments on both before implementing them, since they have to work together. When you call `envid2env` in these routines, you should set the `checkperm` flag to 0, meaning that any environment is allowed to send IPC messages to any other environment, and the kernel does no special permission checking other than verifying that the target envid is valid.
Then implement the `ipc_recv` and `ipc_send` functions in `lib/ipc.c`.

首先需要仔细阅读 `inc/env.h` 了解用于传递消息的数据结构。
```c
	// Lab 4 IPC
	bool env_ipc_recving;		// Env is blocked receiving
	void *env_ipc_dstva;		// VA at which to map received page
	uint32_t env_ipc_value;		// Data value sent to us
	envid_t env_ipc_from;		// envid of the sender
	int env_ipc_perm;		// Perm of page mapping received
```
然后需要注意的是通信流程。
1. 调用 `ipc_recv`，设置好 Env 结构体中的相关 field
2. 调用 `ipc_send`，它会通过 envid 找到接收进程，并读取 Env 中刚才设置好的 field，进行通信。
3. 最后返回实际上是在 `ipc_send` 中设置好 reg_eax，在调用结束，退出内核态时返回。

过程看似很简单，其实坑很多。首先从调用过程入手，这部分比较简单。

**lib 部分**
```c
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;
	if (pg != NULL) {
		r = sys_ipc_recv(pg);
	} else {
		r = sys_ipc_recv((void *) UTOP);
	}
	if (r < 0) {
		// failed
		if (from_env_store != NULL) *from_env_store = 0;
		if (perm_store != NULL) *perm_store = 0;
		return r;
	} else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
		return thisenv->env_ipc_value;
	}
}
```

```c
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	int r;
	if (pg == NULL) pg = (void *)UTOP;
	do {
		r = sys_ipc_try_send(to_env, val, pg, perm);
		if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
		sys_yield();
	} while (r != 0);
}
```
需要注意的不多。主要的 trick 就一个，如果不需要共享页面，则把作为参数的虚拟地址设为 `UTOP`，这个地址在下面的系统调用实现中，会被忽略掉。


**sys_ipc_recv()**

```c
// 接收
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_recv not implemented");
	
	// wrong, because when we don't want to share page, we set dstva=UTOP
	// but we can still pass value
	// if ( (uintptr_t) dstva >= UTOP) return -E_INVAL;
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;

	envid_t envid = sys_getenvid();
	struct Env *e;
	// do not check permission
	if (envid2env(envid, &e, 0) < 0) return -E_BAD_ENV;
	
	e->env_ipc_recving = true;
	e->env_ipc_dstva = dstva;
	e->env_status = ENV_NOT_RUNNABLE;
	sys_yield();

	return 0;
}
```
这个函数有个大坑，已经注释出来。
- 如果作为参数的虚拟地址在 `UTOP` 之上，只需要忽略，而不是报错退出。因为这种情况是说明接收者只需要接收值，而不需要共享页面（联想在 `lib/ipc.c` 中的处理）。

**sys_ipc_try_send()**

这里的需求与 `sys_page_map()` 非常相似，我一直尝试通过调用 `sys_page_map()` 解决，这样可以避免编写大量重复代码。但是发现其中最大的区别在于，ipc 通信并不限于父子进程之间，而 `sys_page_map()` 最初设计的作用就是用于 `fork()`，因此，需要做一些小小的改动才能用于这里，也就是说改变 `envid2env()` 的参数。
如何改动呢？首先添加一个参数是不考虑的，因为 `syscall()` 目前就支持 5 个参数，如果再增加参数改动幅度太大。而且还需要改动之前 `fork()` 部分的代码。

注意到 `inc/mmu.h` 中，还有可以使用的权限标识位，那么这里是否可以借用一下呢？
```
// The PTE_AVAIL bits aren't used by the kernel or interpreted by the
// hardware, so user processes are allowed to set them arbitrarily.
#define PTE_AVAIL	0xE00	// Available for software use
```
于是，实现为如下
```
static int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	envid_t src_envid = sys_getenvid(); 
	struct Env *dst_e;
	if (envid2env(envid, &dst_e, 0) < 0) {
		return -E_BAD_ENV;
	}

	if (dst_e->env_ipc_recving == false) 
		return -E_IPC_NOT_RECV;
	
	// pass the value
	dst_e->env_ipc_value = value;
	dst_e->env_ipc_perm = 0;

	// pass the page
	if ((uintptr_t)srcva < UTOP) {
		// customerize 0x200 as PTE_NO_CHECK
		unsigned tmp_perm = perm | 0x200;
		int r = sys_page_map(src_envid, srcva, envid, (void *)dst_e->env_ipc_dstva, tmp_perm);
		if (r < 0) return r;
		dst_e->env_ipc_perm = perm;
	}

	dst_e->env_ipc_from = src_envid;
	dst_e->env_status = ENV_RUNNABLE;
	// return from the syscall, set %eax
	dst_e->env_tf.tf_regs.reg_eax = 0;
	dst_e->env_ipc_recving = false;
	return 0;
}
```
同时，修改 `sys_page_map()`：
```
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
	// Hint: This function is a wrapper around page_lookup() and
	//   page_insert() from kern/pmap.c.
	//   Again, most of the new code you write should be to check the
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0) return -E_INVAL;
	struct Env *src_e, *dst_e;
	// add for lab4 exercise 15 for ipc.
	// customerize 0x200 as PTE_NO_CHECK
	// and we assume 0x200 is not used elsewhere, so we restore perm here.
	bool check_perm = (perm & 0x200);
	perm &= (~0x200);
	if (envid2env(srcenvid, &src_e, !check_perm)<0 || envid2env(dstenvid, &dst_e, !check_perm)<0) return -E_BAD_ENV;
	pte_t *src_ptab;	
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_ptab);
	if ((*src_ptab & PTE_W) == 0 && (perm & PTE_W) == 1) return -E_INVAL;
	if (page_insert(dst_e->env_pgdir, pp, dstva, perm) < 0) return -E_NO_MEM;
	return 0;
}
```
另外，在系统调用里也新增这两个分支：
```
// syscall()
	case SYS_ipc_try_send:
		retVal = sys_ipc_try_send(a1, a2, (void *)a3, a4);
		break;
	case SYS_ipc_recv:
		retVal = sys_ipc_recv((void *)a1);
		break;
```
至此 `make grade` 成功。在多核情况下 `make CPUS=2 grade` 也通过。
Lab 4 至此结束。