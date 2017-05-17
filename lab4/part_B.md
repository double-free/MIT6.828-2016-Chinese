### Part B: 写时拷贝的 Fork
---
在 Part A 中，我们通过把父进程的所有内存数据拷贝到子进程实现了 `fork()`，这也是 Unix 系统早期的实现。这个拷贝到过程是 `fork()` 时最昂贵的操作。
然而，调用了 `fork()` 之后往往立即就会在子进程中调用 `exec()` ，将子进程的内存更换为新的程序，例如 shell 经常干的（[HW:Shell](http://www.jianshu.com/p/64385b80210b))。这样，复制父进程的内存这个操作就完全浪费了。

因此，后来的 Unix 系统让父、子进程共享同一片物理内存，直到某个进程修改了内存。这被称作 *copy-on-write*。为了实现它，`fork()`时内核只拷贝页面的映射关系，而不拷贝其内容，同时将共享的页面标记为只读 (read-only)。当父子进程中任一方向内存中写入数据时，就会触发 page fault。此时，Unix 就知道应该分配一个私有的可写内存给这个进程。这个优化使得 `fork()` + `exec()` 连续操作变得非常廉价。在执行 `exec()` 之前，只需要拷贝一个页面，即当前的栈。

在 Part B 中，我们将实现上述更佳实现方式的 `fork()`。

#### 用户级别的页错误处理
内核必须要记录进程不同区域出现页面错误时的处理方法。例如，一个栈区域的 page fault 会分配并映射一个新的页。一个 BSS 区域（用于存放程序中未初始化的全局变量、静态变量）的页错误会分配一个新的页面，初始化为0，再映射。
用户级别的页错误处理流程为：
1. 页错误异常，陷入内核
2. 内核修改 `%esp` 切换到进程的异常栈，修改 `%eip` 让进程运行 _pgfault_upcall
3. _pgfault_upcall 将运行 page fault handler，此后不通过内核切换回正常栈

##### 设置页错误处理函数
为处理自己的页错误，进程需要在 JOS 注册一个 page fault handler entrypoint。进程通过 `sys_env_set_pgfault_upcall` 注册自己的 entrypoint，并在 `Env` 结构体中新增 `env_pgfault_upcall` 来记录该信息。

>**Exercise 8.**
Implement the `sys_env_set_pgfault_upcall` system call. Be sure to enable permission checking when looking up the environment ID of the target environment, since this is a "dangerous" system call.

##### 进程的正常栈和异常栈
正常运行时，JOS 的进程会运行在正常栈上，`ESP` 从`USTACKTOP`开始往下生长，栈上的数据存放在 `[USTACKTOP-PGSIZE, USTACKTOP-1]` 上。当出现页错误时，内核会把进程在一个新的栈（异常栈）上面重启，运行指定的用户级别页错误处理函数。也就是说完成了一次进程内的栈切换。这个过程与 trap 的过程很相似。
JOS 的异常栈也只有一个物理页大小，并且它的栈顶定义在虚拟内存 `UXSTACKTOP` 处。当运行在这个栈上时，用户级别页错误处理函数可以使用 JOS 的系统调用来映射新的页，以修复页错误。
每个需要支持用户级页错误处理的函数都需要分配自己的异常栈。可以使用 `sys_page_alloc()` 这个系统调用来实现。

##### 用户页错误处理函数
现在我们需要修改 `kern/trap.c` 以支持用户级别的页错误处理。
如果没有注册 page fault handler，JOS内核就直接销毁进程。否则，内核就会初始化一个 trap frame 记录寄存器状态，在异常栈上处理页错误，恢复进程的执行。`UTrapframe` 在异常栈栈上如下所示。
```
                    <-- UXSTACKTOP
trap-time esp
trap-time eflags
trap-time eip
trap-time eax       start of struct PushRegs
trap-time ecx
trap-time edx
trap-time ebx
trap-time esp
trap-time ebp
trap-time esi
trap-time edi       end of struct PushRegs
tf_err (error code)
fault_va            <-- %esp when handler is run
```
相比 trap 时使用的 `Trapframe`，多了记录错误位置的 `fault_va`，少了段选择器`%cs, %ds, %ss`。这反映了两者最大的不同：是否发生了进程的切换。
如果异常发生时，进程已经在异常栈上运行了，这就说明 page fault handler 本身出现了问题。这时，我们就应该在 `tf->tf_esp` 处分配新的栈，而不是在 `UXSTACKTOP`。首先需要 push 一个空的 32bit word 作为占位符，然后是一个 `UTrapframe` 结构体。
为检查 `tf->tf_esp` 是否已经在异常栈上了，只要检查它是否在区间 `[UXSTACKTOP-PGSIZE, UXSTACKTOP-1]` 上即可。

**以下9，10，11三个练习，建议按照调用顺序来看，即 11（设置handler）->9（切换到异常栈）->10（运行handler，切换回正常栈）。**

>**Exercise 9.**
Implement the code in `page_fault_handler` in `kern/trap.c` required to dispatch page faults to the user-mode handler. Be sure to take appropriate precautions when writing into the exception stack. (What happens if the user environment runs out of space on the exception stack?)

*可参考 Exercise 10 的 `lib/pfentry.S` 中的注释*
较有难度的一个练习。首先需要理解用户级别的页错误处理的步骤是：
**进程A(正常栈) -> 内核 -> 进程A(异常栈) -> 进程A(正常栈)**
那么内核的工作就是修改进程 A 的某些寄存器，并初始化异常栈，确保能顺利切换到异常栈运行。需要注意的是，由于修改了eip， `env_run()` 是不会返回的，因此不会继续运行后面销毁进程的代码。
值得注意的是，如果是嵌套的页错误，为了能实现递归处理，栈留出 32bit 的空位，直接向下生长。

```
void
page_fault_handler(struct Trapframe *tf)
{
	uint32_t fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) panic("Page fault in kernel-mode");
	
	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
		// 初始化异常栈
		struct UTrapframe *utf;
		if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP) {
			// from exception stack
			utf = (struct UTrapframe *)(tf->tf_esp - 4 - sizeof(struct UTrapframe));
		} else {
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W | PTE_P);
		utf->utf_fault_va = fault_va;
		utf->utf_err = tf->tf_trapno;
		utf->utf_regs = tf->tf_regs;
		utf->utf_eip = tf->tf_eip;
		utf->utf_eflags = tf->tf_eflags;
		utf->utf_esp = tf->tf_esp;
		// 修改 esp 完成栈切换，修改 eip 运行 handler
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
		// tf->esp = (uintptr_t)utf - 1; 不需要减1
		tf->tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
	env_destroy(curenv);
}
```
>**Question**
What happens if the user environment runs out of space on the exception stack?

在 `inc/memlayout.h` 中可以找到：
```
#define UXSTACKTOP	UTOP
// Next page left invalid to guard against exception stack overflow;
```
![memlayout.png](http://upload-images.jianshu.io/upload_images/4482847-5b62cf4948a9c45f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

下面一页是空页，内核和用户访问都会报错。

##### 用户模式页错误入口
在处理完页错误之后，现在我们需要编写汇编语句实现从异常栈到正常栈的切换。
>**Exercise 10.**
Implement the `_pgfault_upcall` routine in `lib/pfentry.S`. The interesting part is returning to the original point in the user code that caused the page fault. You'll return directly there, without going back through the kernel. The hard part is simultaneously switching stacks and re-loading the EIP.

汇编苦手，写的很艰难，最终还是参考了[别人的答案](http://blog.csdn.net/bysui/article/details/51842817)。

```
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// 调用用户定义的页错误处理函数
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
	movl _pgfault_handler, %eax
	call *%eax
	addl $4, %esp			// pop function argument

	// LAB 4: Your code here.
	movl 48(%esp), %ebp
	subl $4, %ebp
	movl %ebp, 48(%esp)
	movl 40(%esp), %eax
	movl %eax, (%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	// 跳过 utf_err 以及 utf_fault_va
	addl $8, %esp
	// popal 同时 esp 会增加，执行结束后 %esp 指向 utf_eip
	popal

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	// 跳过 utf_eip
	addl $4, %esp
	// 恢复 eflags
	popfl

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复 trap-time 的栈顶
	popl %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// ret 指令相当于 popl %eip
	ret
```
首先必须要理解异常栈的结构，下图所示的是嵌套异常时的情况。其中左边表示内容，右边表示地址。需要注意的是，上一次异常的栈顶之下间隔 4byte，就是一个新的异常。

![uxstack.png](http://upload-images.jianshu.io/upload_images/4482847-a33e11e5c9c54849.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最难理解的是这一部分：
```
	movl 48(%esp), %ebp  // 使 %ebp 指向 utf_esp
	subl $4, %ebp
	movl %ebp, 48(%esp)  // 更新 utf_esp 值为 utf_esp-4
	movl 40(%esp), %eax
	movl %eax, (%ebp)  // 将 utf_esp-4 地址的内容改为 utf_eip
```
经过这一部分的修改，异常栈更新为（红字标出）：

![uxstack_new.png](http://upload-images.jianshu.io/upload_images/4482847-210592f47937410a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此后就是恢复各寄存器，最后的 `ret` 指令相当于 `popl %eip`，指令寄存器的值修改为 `utf_eip`，达到了返回的效果。 

>**Exercise 11.**
Finish `set_pgfault_handler()` in `lib/pgfault.c`.

该练习是用户用来指定缺页异常处理方式的函数。代码比较简单，但是需要区分清楚 `handler`，`_pgfault_handler`，`_pgfault_upcall` 三个变量。

1. `handler` 是传入的用户自定义页错误处理函数指针。
2. `_pgfault_upcall` 是一个全局变量，在 `lib/pfentry.S` 中完成的初始化。它是页错误处理的总入口，页错误除了运行 page fault handler，还需要切换回正常栈。
3. `_pgfault_handler`  被赋值为handler，会在 `_pgfault_upcall` 中被调用，是页错误处理的一部分。具体代码是：
```
.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
	movl _pgfault_handler, %eax
	call *%eax
	addl $4, %esp
```

```
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
	int r;

	if (_pgfault_handler == 0) {
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
		if (r < 0) {
			panic("pgfault_handler: %e", r);
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
		if (r < 0) {
			panic("pgfault_handler: %e", r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
}
```
若是第一次调用，需要首先分配一个页面作为异常栈，并且将该进程的 upcall 设置为 Exercise 10 中的程序。此后如果需要改变handler，不需要再重复这个工作。
最后直接通过 `make grade` 测试，满足要求。

>**Question**
Why `user/faultalloc` and `user/faultallocbad` behave differently?

两者的 page fault handler 一样，但是一个使用 `cprintf()` 输出，另一个使用 `sys_cput()` 输出。
`sys_cput()`直接通过 `lib/syscall.c` 发起系统调用，其实现在 `kern/syscall.c` 中：
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
它检查了内存，因此在这里 panic 了。中途没有触发过页错误。

而 `cprintf()` 的实现可以在 `lib/printf.c` 中找到：
```
int
vcprintf(const char *fmt, va_list ap)
{
	struct printbuf b;

	b.idx = 0;
	b.cnt = 0;
	vprintfmt((void*)putch, &b, fmt, ap);
	sys_cputs(b.buf, b.idx);

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
	va_end(ap);

	return cnt;
}
```
它在调用 `sys_cputs()` 之前，首先在用户态执行了 `vprintfmt()` 将要输出的字符串存入结构体 `b` 中。在此过程中试图访问 `0xdeadbeef` 地址，触发并处理了页错误（其处理方式是在错误位置处分配一个字符串，内容是 `"this string was faulted in at ..."`），因此在继续调用 `sys_cputs()` 时不会出现 panic。

#### 实现 Copy-on-Write Fork
现在我们已经具备了在用户空间实现 copy-on-write `fork()` 的条件。
如同 `dumbfork()` 一样，`fork()` 也要创建一个新进程，并且在新进程中建立与父进程同样的内存映射。关键的不同点是，`dumbfork()` 拷贝了物理页的内容，而 `fork()` 仅拷贝了映射关系，仅在某个进程需要改写某一页的内容时，才拷贝**这一页**的内容。其基本流程如下：
1. 父进程使用 `set_pgfault_handler`将 `pgfault()` 设为 page fault handler
2. 父进程使用 `sys_exofork()` 建立一个子进程
3. 对每个在 `UTOP` 之下可写页面以及 COW 页面（用 `PTE_COW` 标识），父进程调用 `duppage` 将其“映射”到子进程，同时将其权限改为只读，并用 `PTE_COW` 位来与一般只读页面区别
异常栈的分配方式与此不同，需要在子进程中分配一个新页面。因为 page fault handler 会实实在在地向异常栈写入内容，并在异常栈上运行。如果异常栈页面都用 COW 机制，那就没有能够执行拷贝这个过程的载体了
4. 父进程会为子进程设置 user page fault entrypoint
5. 子进程已经就绪，父进程将其设为 runnable

进程第一次往一个 COW page 写入内容时，会发生 page fault，其流程为：
1. 内核将 page fault 传递至 `_pgfault_upcall`，它会调用 `pgfault()` handler
2. `pgfault()` 检查错误类型，以及页面是否标记为`PTE_COW`
3. `pgfault()` 分配一个新的页面并将 fault page 的内容拷贝进去，然后将旧的映射覆盖，使其映射到该新页面。

>**Exercise 12.**
Implement `fork`, `duppage` and `pgfault` in `lib/fork.c`.
Test your code with the `forktree` program.

非常难的一个练习。

**fork() 函数**

首先从主函数 `fork()` 入手，其大体结构可以仿造 `user/dumbfork.c` 写，但是有关键几处不同：

- 设置 page fault handler，即 page fault upcall 调用的函数

- duppage 的范围不同，`fork()` 不需要复制内核区域的映射

- 为子进程设置 page fault upcall，之所以这么做，是因为 `sys_exofork()` 并不会复制父进程的 `e->env_pgfault_upcall` 给子进程。

```
envid_t
fork(void)
{
	// LAB 4: Your code here.
	// panic("fork not implemented");

	set_pgfault_handler(pgfault);
	envid_t e_id = sys_exofork();
	if (e_id < 0) panic("fork: %e", e_id);
	if (e_id == 0) {
		// child
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	// parent
	// extern unsigned char end[];
	// for ((uint8_t *) addr = UTEXT; addr < end; addr += PGSIZE)
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
			// dup page to child
			duppage(e_id, PGNUM(addr));
		}
	}
	// alloc page for exception stack
	int r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
	if (r < 0) panic("fork: %e",r);

	// DO NOT FORGET
	extern void _pgfault_upcall();
	r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
	if (r < 0) panic("fork: set upcall for child fail, %e", r);

	// mark the child environment runnable
	if ((r = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return e_id;
}
```

**duppage() 函数**

该函数的作用是复制父、子进程的页面映射。尤其注意一个权限问题。由于 `sys_page_map()` 页面的权限有硬性要求，因此必须要修正一下权限。之前没有修正导致一直报错，后来发现页面权限为 `0x865`，不符合 `sys_page_map()` 要求。
```
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	// panic("duppage not implemented");

	envid_t this_env_id = sys_getenvid();
	void * va = (void *)(pn * PGSIZE);

	int perm = uvpt[pn] & 0xFFF;
	if ( (perm & PTE_W) || (perm & PTE_COW) ) {
		// marked as COW and read-only
		perm |= PTE_COW;
		perm &= ~PTE_W;
	}
	// IMPORTANT: adjust permission to the syscall
	perm &= PTE_SYSCALL;
	// cprintf("fromenvid = %x, toenvid = %x, dup page %d, addr = %08p, perm = %03x\n",this_env_id, envid, pn, va, perm);
	if((r = sys_page_map(this_env_id, va, envid, va, perm)) < 0) 
		panic("duppage: %e",r);
	if((r = sys_page_map(this_env_id, va, this_env_id, va, perm)) < 0) 
		panic("duppage: %e",r);
	return 0;
}
```

**pgfault() 函数**

这是 _pgfault_upcall 中调用的页错误处理函数。在调用之前，父子进程的页错误地址都引用同一页物理内存，该函数作用是分配一个物理页面使得两者独立。
首先，它分配一个页面，映射到了交换区 `PFTEMP` 这个虚拟地址，然后通过 `memmove()` 函数将 `addr` 所在页面拷贝至 `PFTEMP`，此时有两个物理页保存了同样的内容。再将 `addr` 也映射到 `PFTEMP` 对应的物理页，最后解除了 `PFTEMP` 的映射，此时就只有 `addr` 指向新分配的物理页了，如此就完成了错误处理。

```
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0) {
		panic("pgfault: invalid user trap frame");
	}
	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// panic("pgfault not implemented");
	envid_t envid = sys_getenvid();
	if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
		panic("pgfault: page allocation failed %e", r);

	addr = ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
	if ((r = sys_page_unmap(envid, addr)) < 0)
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
		panic("pgfault: page unmap failed (%e)", r);
}
```
可以通过 `make run-forktree` 验证结果。