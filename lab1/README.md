### Exercise 3
---
**方法：**
打开终端运行`make qemu-gdb`，再打开另一个终端运行`make gdb`，通过`b *0x07c00`设置断点，`c`继续运行直到断点位置，之后`si`逐步查看。

- **At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?**
```
(gdb) 
[   0:7c2d] => 0x7c2d:	ljmp   $0x8,$0x7c32
```
在这一步，执行了一个段间跳转指令，格式为`ljmp $SECTION, $OFFSET`，并且从此开始执行32位代码。
以下指令导致了从实模式到保护模式到转换。`cr0`寄存器的0位置1。
```
(gdb) 
[   0:7c23] => 0x7c23:	mov    %cr0,%eax
0x00007c23 in ?? ()
(gdb) 
[   0:7c26] => 0x7c26:	or     $0x1,%eax
0x00007c26 in ?? ()
(gdb) 
[   0:7c2a] => 0x7c2a:	mov    %eax,%cr0
0x00007c2a in ?? ()
```

- **What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?**

通过阅读 main.c 很容易得出 boot loader 最后的行代码是
```
((void (*)(void)) (ELFHDR->e_entry))();
```
需要找到执行这行代码的汇编指令。使用gdb单步调试，可以整理出各个函数对应的汇编指令。先找到跳出 while 循环的地址：
```
=> 0x7cf7:	cmp    %esi,%ebx    // while 语句比较 pa 和 end_pa
=> 0x7cf9:	jae    0x7d0d    // 大于等于则跳转
```
找到后，直接在 0x7d0d 设置断点，再单步执行到 for 语句。找到跳出 for 循环的地址：
```
=> 0x7d51:	cmp    %esi,%ebx    // for 语句中比较 ph 与 eph
=> 0x7d53:	jae    0x7d6b    // 大于等于则跳转
```
显然，0x7d6b 就是目标代码的位置。设置断点在该内存地址，得到 boot loader 的最后一条指令：
```
=> 0x7d6b:	call   *0x10018
```
这是显然的，因为 e_entry 是结构体 ELF 中的第6个 uint32_t 值，必然是在内存地址 0x10000 + 6 * 4 = 0x10018 位置。这条指令意思是跳转到 0x10018 所存指针指向的地址。
kernel 的第一条指令就是下一条指令：
```
=> 0x10000c:	movw   $0x1234,0x472
```

- **Where is the first instruction of the kernel?**

显然是在内存地址 0x10000c，更多信息可在对应目录下使用 objdump 命令查看
```
~/OS/lab/obj/kern$ objdump -f kernel
kernel:     file format elf32-i386
architecture: i386, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0010000c
```

- **How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?**

根据对 main.c 的分析，显然是通过 ELF 文件头获取所有 program header table，每个 program header table 记录了三个重要信息用以描述段 (segment)：p_pa (物理内存地址)，p_memsz (所占内存大小)，p_offset (相对文件的偏移地址)。根据这三个信息，对每个段，从 p_offset 开始，读取 p_memsz 个 byte 的内容（需要根据扇区(sector)大小对齐），放入 p_pa 开始的内存中。通过 objdump 命令可以查看： 
```
~/OS/lab/obj/kern$ objdump -p kernel
kernel:     file format elf32-i386
Program Header:
    LOAD off    0x00001000 vaddr 0xf0100000 paddr 0x00100000 align 2**12
         filesz 0x00007120 memsz 0x00007120 flags r-x
    LOAD off    0x00009000 vaddr 0xf0108000 paddr 0x00108000 align 2**12
         filesz 0x0000a300 memsz 0x0000a944 flags rw-
   STACK off    0x00000000 vaddr 0x00000000 paddr 0x00000000 align 2**4
         filesz 0x00000000 memsz 0x00000000 flags rwx
```

### Exercise 5
---
- **Change the link address in boot/Makefrag to something wrong, run make clean, recompile the lab with make, and trace into the boot loader again to see what happens.**

找到 boot/Makefrag 文件中的`-Ttext 0x7c00`部分，这就是boot sector 的 load address 以及 link address，通过在 boot/Makefrag 设置`-Ttext <内存地址>` 告诉链接器。
现将其设置为`-Ttext 0x7c10`，执行`make clean`，`make`。
继续将断点设置在 0x7c00，发现执行到以下语句出错：
```
(gdb) 
[   0:7c2d] => 0x7c2d:	ljmp   $0x8,$0x7c42
```
对应 boot.S 中的代码：
```
ljmp    $PROT_MODE_CSEG, $protcseg
```
可以发现，比正确的地址偏移了 0x0010，与设置 boot/Makefrag 时的偏差相同。这是由于链接器计算内存地址是根据 boot/Makefrag 中的设置。然而由于 BIOS 会把 boot loader 固定加载在 0x7c00，于是导致了错误。

### Exercise 6
---
- **Examine the 8 words of memory at 0x00100000 at the point the BIOS enters the boot loader, and then again at the point the boot loader enters the kernel. Why are they different? What is there at the second breakpoint? (You do not really need to use QEMU to answer this question. Just think.)**
```
~/OS/lab/obj/kern$ objdump -h kernel
kernel:     file format elf32-i386
Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  0 .text         00001871  f0100000  00100000  00001000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       00000714  f0101880  00101880  00002880  2**5
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .stab         000038d1  f0101f94  00101f94  00002f94  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .stabstr      000018bb  f0105865  00105865  00006865  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  4 .data         0000a300  f0108000  00108000  00009000  2**12
                  CONTENTS, ALLOC, LOAD, DATA
  5 .bss          00000644  f0112300  00112300  00013300  2**5
                  ALLOC
  6 .comment      00000034  00000000  00000000  00013300  2**0
                  CONTENTS, READONLY
```
注意到，VMA 和 LMA 并不相同。kernel 告诉 boot loader 将其加载到 load address = 0x00100000，然而执行却在 link address = 0xf0100000。exercise 7 将揭示原因。
除了段信息，ELF 还包含了一个重要信息：e_entry。它存储了程序的 entry point 的链接地址，即程序第一条指令执行的地址。
```
~/OS/lab/obj/kern$ objdump -f kernel
kernel:     file format elf32-i386
architecture: i386, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0010000c
```
这和 exercise 3 的 kernel 的第一条指令的位置相符。
可以看出，boot/main.c 的作用就是从硬盘读取 kernel 的每个 section，然后跳转到 kernel 的 entry point。
我们可以通过验证0x100000开始的内存内容来检查。
首先在 BIOS 进入 boot loader 的时候检查一次（还未读取 kernel 至内存），再在从 boot loader 进入 kernel 的时候检查一次（此时已经将 kernel 读入内存）。
```
(gdb) b *0x7c00
Breakpoint 1 at 0x7c00
(gdb) x/8x 0x100000
0x100000:	0x00000000	0x00000000	0x00000000	0x00000000
0x100010:	0x00000000	0x00000000	0x00000000	0x00000000
(gdb) b *0x7d6b
Breakpoint 2 at 0x7d6b
(gdb) c
Continuing.
[   0:7c00] => 0x7c00:	cli    
Breakpoint 1, 0x00007c00 in ?? ()
(gdb) x/8x 0x100000
0x100000:	0x00000000	0x00000000	0x00000000	0x00000000
0x100010:	0x00000000	0x00000000	0x00000000	0x00000000
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0x7d6b:	call   *0x10018
Breakpoint 2, 0x00007d6b in ?? ()
(gdb) x/8x 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x0000b812	0x220f0011	0xc0200fd8
(gdb) 
```

### Exercise 7
---
- **Use QEMU and GDB to trace into the JOS kernel and stop at the movl %eax, %cr0. Examine memory at 0x00100000 and at 0xf0100000. Now, single step over that instruction using the stepi GDB command. Again, examine memory at 0x00100000 and at 0xf0100000. Make sure you understand what just happened.**

之前的实验中已经发现，kernel 的 load address 和 link address 并不相同。
实际上，操作系统往往将 kernel 链接和运行在虚拟内存的高位，例如 0xf0100000，以将低位留给用户程序。然而，许多机器并没有那么大的物理内存，所以我们不能直接将 kernel 存储在高位。我们使用处理器的内存管理硬件 (memory management hardware) 来将虚拟内存 0xf0100000 ( kernel 的link address，即运行的地址) 映射到物理内存 0x0010000 ( kernel 的 load address)。这样，既可以保证为用户程序留下足够高的虚拟内存，也可以使 kernel 加载到物理内存 0x100000 处。
我们先从 kernel 位于 0x10000c 的第一条指令开始，进行单步调试。
```
=> 0x10000c:	movw   $0x1234,0x472
=> 0x100015:	mov    $0x110000,%eax
=> 0x10001a:	mov    %eax,%cr3
=> 0x10001d:	mov    %cr0,%eax
=> 0x100020:	or     $0x80010001,%eax
=> 0x100025:	mov    %eax,%cr0
(gdb) x/8x 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x0000b812	0x220f0011	0xc0200fd8
(gdb) x/8x 0xf0100000
0xf0100000 <_start+4026531828>:	0x00000000	0x00000000	0x00000000	0x00000000
0xf0100010 <entry+4>:	0x00000000	0x00000000	0x00000000	0x00000000
```
输出8个 word 长度的内存内容进行观察。`<>`中的内容是10进制的偏差，`_start` 和 `entry` 都是 0x0010000c。此时 VMA 开始的内容还未加载。执行`mov    %eax,%cr0`结束后：
```
(gdb) si
=> 0x100028:	mov    $0xf010002f,%eax
(gdb) x/8x 0x100000
0x100000:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0x100010:	0x34000004	0x0000b812	0x220f0011	0xc0200fd8
(gdb) x/8x 0xf0100000
0xf0100000 <_start+4026531828>:	0x1badb002	0x00000000	0xe4524ffe	0x7205c766
0xf0100010 <entry+4>:	0x34000004	0x0000b812	0x220f0011	0xc0200fd8
```
可以看出，VMA 与 LMA 现在具有同样的内容。这是因为0x00100000 被映射到了 0xf0100000 处。
 - 启用分页机制
kern/entry.S 中的关键行：
```
# Turn on paging.
movl	%cr0, %eax
orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
movl	%eax, %cr0
```
inc/mmu.h 中对 CR0_PE (0位)，CR0_PG (31位)，CR0_WP (16位) 的定义：
```
// Control Register flags
#define CR0_PE		0x00000001	// Protection Enable
#define CR0_MP		0x00000002	// Monitor coProcessor
#define CR0_EM		0x00000004	// Emulation
#define CR0_TS		0x00000008	// Task Switched
#define CR0_ET		0x00000010	// Extension Type
#define CR0_NE		0x00000020	// Numeric Errror
#define CR0_WP		0x00010000	// Write Protect
#define CR0_AM		0x00040000	// Alignment Mask
#define CR0_NW		0x20000000	// Not Writethrough
#define CR0_CD		0x40000000	// Cache Disable
#define CR0_PG		0x80000000	// Paging
```
一旦开启了 CR0_PG，内存引用就变成了通过 virtual memory hardware 转换过的物理地址产生的虚拟地址。例如，虚拟地址 0x00000000 到 0x00400000 以及 0xf0000000 到 0xf0400000 都被转为物理地址 0x00000000 到 0x00400000。高低虚拟地址指向同一个物理地址。
- **What is the first instruction after the new mapping is established that would fail to work properly if the mapping weren't in place? Comment out the movl %eax, %cr0 in kern/entry.S, trace into it, and see if you were right.**
```
=> 0x10000c:	movw   $0x1234,0x472
=> 0x100015:	mov    $0x110000,%eax
=> 0x10001a:	mov    %eax,%cr3
=> 0x10001d:	mov    %cr0,%eax
=> 0x100020:	or     $0x80010001,%eax
=> 0x100025:	mov    $0xf010002c,%eax
=> 0x10002a:	jmp    *%eax
=> 0xf010002c <relocated>:	add    %al,(%eax)
relocated () at kern/entry.S:74
74		movl	$0x0,%ebp			# nuke frame pointer
(gdb) 
Remote connection closed
```
报错信息：
```
qemu: fatal: Trying to execute code outside RAM or ROM at 0xf010002c
```
显然，由于未开启分页机制，虚拟地址还未映射到物理地址。

### Exercise 8
---
- **We have omitted a small fragment of code - the code necessary to print octal numbers using patterns of the form "%o". Find and fill in this code fragment.**

很早就留意到，每次进入 JOS 的时候，总会输出一行：
```
6828 decimal is XXX octal!
```
在 kern/init.c 中找到对应代码如下：
```
cprintf("6828 decimal is %o octal!\n", 6828);
```
在 lib/console.c 中找到对应代码如下：
```
		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
```
将其替换为转8进制的代码：
```
		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
			base = 8;
			goto number;
```
- **Explain the interface between printf.c and console.c. Specifically, what function does console.c export? How is this function used by printf.c?**

console.c 暴露接口 cputchar(int c) 提供给 printf.c 中的函数 putch(int ch, int *cnt) 调用。
- **Explain the following from console.c:**
```
// 一页写满，滚动一行。
	if (crt_pos >= CRT_SIZE) {
		int i;
		// 把从第1~n行的内容复制到0~(n-1)行，第n行未变化
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		// 将第n行覆盖为默认属性下的空格
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
		// 清空了最后一行，同步crt_pos
		crt_pos -= CRT_COLS;
	}
```
 - **memmove 函数**
```
memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
```
`void * memmove(void *dest, const void *src, size_t num);`
memmove 大部分情况下作用相当于 memcpy，但是加入了缓冲区，当src 和 dest 所指的内存区域重叠时，memmove() 仍然可以正确的处理，不过执行效率上会比使用 memcpy() 略慢些。
![memmove 示意图](http://upload-images.jianshu.io/upload_images/4482847-29279770f39edc59.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 - 参数`int c` **是什么，**`0xff`**和**`0x0700`**又是什么？**
`int c`一共32bit，其中高16位用来表示属性，低16位用来表示字符。因此，与`0xff`作 and 运算就是去掉属性，只看字符内容。与`~0xff`作 and 运算就是去掉字符，只看属性。与`0x0700`作 or 运算就是设为默认属性。

- **Trace the execution of the following code step-by-step:**
```
int x = 1, y = 3, z = 4;
cprintf("x %d, y %x, z %d\n", x, y, z);
```
首先遇到的第一个问题是，在哪里执行这段代码。
查看发现在 kern/monitor.c 中有如下代码：
```
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	return 0;
}
```
实际上就是在这里运行。将代码复制到该函数中。重新编译并且在gdb中设置断点：
```
(gdb) b kern/monitor.c:61
Breakpoint 1 at 0xf0100774: file kern/monitor.c, line 61.
```
生成的汇编代码如下：
```
// 从右向左压入参数
=> 0xf0100774 <mon_backtrace+6>:	push   $0x4
Breakpoint 1, mon_backtrace (argc=0, argv=0x0, tf=0x0) at kern/monitor.c:62
62		cprintf("x %d, y %x, z %d\n", x, y, z);
(gdb) si
=> 0xf0100776 <mon_backtrace+8>:	push   $0x3
0xf0100776	62		cprintf("x %d, y %x, z %d\n", x, y, z);
(gdb) 
=> 0xf0100778 <mon_backtrace+10>:	push   $0x1
0xf0100778	62		cprintf("x %d, y %x, z %d\n", x, y, z);
(gdb) 
=> 0xf010077a <mon_backtrace+12>:	push   $0xf0101b4e
0xf010077a	62		cprintf("x %d, y %x, z %d\n", x, y, z);
(gdb) 
// 跳转到函数
=> 0xf010077f <mon_backtrace+17>:	call   0xf010090b <cprintf>
0xf010077f	62		cprintf("x %d, y %x, z %d\n", x, y, z);
(gdb) 
// epb 内容入栈，保护先前的 ebp 信息
=> 0xf010090b <cprintf>:	push   %ebp
cprintf (fmt=0xf0101b4e "x %d, y %x, z %d\n") at kern/printf.c:27
27	{
(gdb) 
// 将 esp 内容复制到 ebp 中
=> 0xf010090c <cprintf+1>:	mov    %esp,%ebp
0xf010090c	27	{
(gdb) 
// cprintf 预留局部变量空间
=> 0xf010090e <cprintf+3>:	sub    $0x10,%esp
0xf010090e	27	{
(gdb) 
// ebp + 0xc 得出 arg2 的地址，并将该地址(而非内容)移入 eax
=> 0xf0100911 <cprintf+6>:	lea    0xc(%ebp),%eax
31		va_start(ap, fmt);
(gdb) 
// 参数 ap 入栈，即之前的 arg2 地址
=> 0xf0100914 <cprintf+9>:	push   %eax
32		cnt = vcprintf(fmt, ap);
(gdb) 
// 参数 fmt 入栈，即之前的 arg1
=> 0xf0100915 <cprintf+10>:	pushl  0x8(%ebp)
0xf0100915	32		cnt = vcprintf(fmt, ap);
(gdb) 
=> 0xf0100918 <cprintf+13>:	call   0xf01008e5 <vcprintf>
0xf0100918	32		cnt = vcprintf(fmt, ap);
(gdb) 
=> 0xf01008e5 <vcprintf>:	push   %ebp
vcprintf (fmt=0xf0101b4e "x %d, y %x, z %d\n", ap=0xf010ff04 "\001")
    at kern/printf.c:18
18	{
(gdb) 
=> 0xf01008e6 <vcprintf+1>:	mov    %esp,%ebp
0xf01008e6	18	{
(gdb) 
=> 0xf01008e8 <vcprintf+3>:	sub    $0x18,%esp
0xf01008e8	18	{
(gdb) 
=> 0xf01008eb <vcprintf+6>:	movl   $0x0,-0xc(%ebp)
19		int cnt = 0;
(gdb) 
=> 0xf01008f2 <vcprintf+13>:	pushl  0xc(%ebp)
21		vprintfmt((void*)putch, &cnt, fmt, ap);
(gdb) 
=> 0xf01008f5 <vcprintf+16>:	pushl  0x8(%ebp)
0xf01008f5	21		vprintfmt((void*)putch, &cnt, fmt, ap);
(gdb) 
=> 0xf01008f8 <vcprintf+19>:	lea    -0xc(%ebp),%eax
0xf01008f8	21		vprintfmt((void*)putch, &cnt, fmt, ap);
```
**补充1: 如何通过ebp获取参数和局部变量**

|    存储内容     | 内存地址          |
| :-------------: |:-------------:| 
| 第 n 个参数      | ebp + 4 * (n+1) |
| 返回地址      | ebp + 4     |
| 上一级函数 ebp (旧 ebp)  | ebp     |
| 第 m 个局部变量      | ebp - 4 * m |
- **In the call to cprintf(), to what does fmt point? To what does ap point?**

fmt 是 cprintf 函数的第一个参数，即指向字符串`"x %d, y %x, z %d\n"`的指针。从汇编代码中也可以看出，`0xf0101b4e`即该地址。
ap 指向第二个参数的地址。**注意 ap 中存放的是第二个参数的地址，而非第二个参数。**这里很多教程是错误的，关键在于理解 LEA 和 MOV 的差别。用 gdb 观察可证明我们的想法：
```
=> 0xf01008e5 <vcprintf>:	push   %ebp
vcprintf (fmt=0xf0101b4e "x %d, y %x, z %d\n", ap=0xf010ff04 "\001")
    at kern/printf.c:18
18	{
(gdb) p $ebp
$1 = (void *) 0xf010fef8
```
注意到 `ebp + 0xc = 0xf010ff04`，即第二个参数 1 的内存地址，放在了ap中。
- **List (in order of execution) each call to cons_putc, va_arg, and vcprintf. For cons_putc, list its argument as well. For va_arg, list what ap points to before and after the call. For vcprintf list the values of its two arguments.**

***cons_putc 函数***
调用关系为 cprintf -> vcprintf -> vprintfmt -> putch -> cputchar -> cons_putc，设置断点如下：
```
(gdb) b kern/console.c : 458
Breakpoint 1 at 0xf0100661: file kern/console.c, line 458.
```

|    中断序号     | 参数c(int)   | 输出结果(字符) |
| :----: |:----:| :----:|
| 1 | 120 | 'x' |
| 2 | 32 |' '|
| 3 | 49 |'1'|
| 4 | 44 |','|
| 5 | 32 |' '|
| 6 | 121 |'y'|
| 7 | 32 |' '|
| 8 | 51 |'3'|
| 9 | 44 |','|
| 10 | 32 |' '|
| 11 | 122 |'z'|
| 12 | 32 |' '|
| 13 | 52 |'4'|
| 14 | 10 |'\n'|

可以看出使用 ASCII 编码，合起来就输出了：
```x 1, y 3, z 4```
***va_arg 函数***

函数`type va_arg ( va_list ap, type ); `的作用是解析参数，它的第一个参数是ap，第二个参数是要获取的参数的指定类型，然后返回这个指定类型的值，并且把 ap 的位置指向变参表的下一个变量位置，以下是宏定义。
```
#define _INTSIZEOF(n)   ( (sizeof(n) + sizeof(int) - 1) & ~(sizeof(int) - 1) )
#define _crt_va_start(ap,v)  ( ap = (va_list)_ADDRESSOF(v) + _INTSIZEOF(v) )
#define _crt_va_arg(ap,t)    ( *(t *)((ap += _INTSIZEOF(t)) - _INTSIZEOF(t)) )
#define _crt_va_end(ap)      ( ap = (va_list)0 )
```
可以看出 ap 先增加了按 int 对齐的字节，然后再取未增加时的地址转为 type 指针并解引用。
在 lib/printfmt.c 中找到使用 va_arg 的函数：
```
// 输出x = 1 以及 z = 4 的时候调用。(%d)
// 输出y = 3 时候使用 getuint。(%x)
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, long long);
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
}
```
设置断点观察：
```
=> 0xf0100fc4 <vprintfmt+699>:	mov    0x14(%ebp),%eax

Breakpoint 1, vprintfmt (putch=0xf01008d2 <putch>, putdat=0xf010fecc, 
    fmt=0xf0101b4e "x %d, y %x, z %d\n", ap=0xf010ff04 "\001")
    at lib/printfmt.c:75
75			return va_arg(*ap, int);
```
可以看出，此时的 ap 正是我们在上一个问题中看到的那个 ap，存放的是参数 x=1 的内存地址`0xf010ff04`。
```
=> 0xf0100cbf <getuint+42>:	mov    (%eax),%edx

Breakpoint 1, getuint (ap=0xf010febc, lflag=0) at lib/printfmt.c:62
62			return va_arg(*ap, unsigned int);
```
这里需要做个转换，getuint传入的ap参数其实是存放ap的地址。查看该地址的内容可得：
```
(gdb) x 0xf010febc
0xf010febc:	0xf010ff08
```
说明 ap 的值是 `0xf010ff08`，即存放 y=3 的地址。
```
=> 0xf0100fc4 <vprintfmt+699>:	mov    0x14(%ebp),%eax

Breakpoint 1, vprintfmt (putch=0xf01008d2 <putch>, putdat=0xf010fecc, 
    fmt=0xf0101b4e "x %d, y %x, z %d\n", ap=0xf010ff0c "\004")
    at lib/printfmt.c:75
75			return va_arg(*ap, int);
```
说明 ap 的值是 `0xf010ff0c`，即存放 z=4 的地址。
如此即可证明，每次调用 va_arg 都会使得 ap 的位置指向变参表的下一个变量位置。
***vcprintf 函数***
```
=> 0xf01008e5 <vcprintf>:	push   %ebp

Breakpoint 1, vcprintf (fmt=0xf0101b4e "x %d, y %x, z %d\n", 
    ap=0xf010ff04 "\001") at kern/printf.c:18
```
两个参数的值在 gdb 中有显示。

- **Run the following code.**
```
    unsigned int i = 0x00646c72;
    cprintf("H%x Wo%s", 57616, &i);
```
**What is the output? Explain how this output is arrived at in the step-by-step manner of the previous exercise.**
输出是`He110 World`。
57616的16进制形式为 e110，这个很好理解。
输出字符串时，从给定字符串的第一个字符地址开始，按字节读取字符，直到遇到 '\0' 结束。
```
for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
```
于是，Wo%s, &i 的意义是把 i 作为字符串输出。查阅 ASCII 码表可知，0x00 对应 '\0'，0x64 对应 'd'，0x6c 对应 'l'，0x72 对应 'r'。
 - **补充：大端 (big endian) 以及小端 (little endian) 模式**
对于整型、长整型等数据类型，Big endian 认为第一个字节是最高位字节（按照从低地址到高地址的顺序存放数据的高位字节到低位字节）；而 Little endian 则相反，它认为第一个字节是最低位字节（按照从低地址到高地址的顺序存放据的低位字节到高位字节）。
简单理解，就是说小端模式存储的数据按照字符串的读取方法是倒序的。
一般来说，x86 系列 CPU 都是 little-endian 的字节序，PowerPC 通常是 big-endian，网络字节顺序也是 big-endian还有的CPU 能通过跳线来设置 CPU 工作于 Little endian 还是 Big endian 模式。

 可以看出，0x00646c72 存储在内存中从低位到高位应该是：
0x72，0x6c，0x64，0x00。于是按 ASCII 解码得到 'rld'。
如果是在大端 (big endian) 模式下要得到同样的输出，应该改为：
```
    unsigned int i = 0x726c6400;
    cprintf("H%x Wo%s", 57616, &i);
```
- **In the following code, what is going to be printed after 'y='? (note: the answer is not a specific value.) Why does this happen?**
```    
cprintf("x=%d y=%d", 3);
```
输出为：`x = 3, y = -267321588`。
由于第二个参数尚未指定，输出 3 以后无法确定 ap 的值应该变化多少，更无法根据 ap 的值获取参数。
va_arg 取当前栈地址，并将指针移动到下个“参数”所在位置--简单的栈内移动，没有任何标志或者条件能够让你确定可变参函数的参数个数，也不能判断当前栈指针的合法性。

- **Let's say that GCC changed its calling convention so that it pushed arguments on the stack in declaration order, so that the last argument is pushed last. How would you have to change cprintf or its interface so that it would still be possible to pass it a variable number of arguments?**
个人认为需要更改 va_start 以及 va_arg 两个宏的实现。

### Exercise 9
---
- **Determine where the kernel initializes its stack, and exactly where in memory its stack is located. How does the kernel reserve space for its stack? And at which "end" of this reserved area is the stack pointer initialized to point to?**
 - **initialize stack**
 
在 kern/entry.S 中找到初始化 ebp 和 esp 的语句：
```
	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer

	# Set the stack pointer
	movl	$(bootstacktop),%esp
```
 - **stack location**
设置断点观察：
```
(gdb) b kern/entry.S : 74
Breakpoint 1 at 0xf010002f: file kern/entry.S, line 74.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf010002f <relocated>:	mov    $0x0,%ebp
Breakpoint 1, relocated () at kern/entry.S:74
74		movl	$0x0,%ebp			# nuke frame pointer
(gdb) si
=> 0xf0100034 <relocated+5>:	mov    $0xf0110000,%esp
relocated () at kern/entry.S:77
77		movl	$(bootstacktop),%esp
```
显然，栈顶为`0xf0110000`。结合下面的栈大小，可以得出栈位于 `0xf0110000` 到 `0xf0108000`。
 - **stack space**
 
在 kern/entry.S 中找到：
```
bootstack:
	.space		KSTKSIZE
```
在 inc/memlayout.h 中找到以下定义：
```
// Kernel stack.
#define KSTACKTOP	KERNBASE
#define KSTKSIZE	(8*PGSIZE)   		// size of a kernel stack
#define KSTKGAP		(8*PGSIZE)   		// size of a kernel stack guard
```
在 inc/mmu.h 中找到以下定义：
```
#define PGSIZE		4096		// bytes mapped by a page
```
可以看出，栈大小为 32 kB。
 - **stack pointer**
 
由于栈是从内存高位向低位生长，所以stack pointer应该指向的是高位。

|    寄存器     | 含义          |
| :-------------: |:-------------:| 
| EIP     | Instruction Pointer |
| ESP      | Stack Pointer    |
| EBP  | Base Pointer     |

### Exercise 10
---
- **Find the address of the test_backtrace function in obj/kern/kernel.asm, set a breakpoint there, and examine what happens each time it gets called after the kernel starts. How many 32-bit words does each recursive nesting level of test_backtrace push on the stack, and what are those words?**

首先阅读 kern/init.c，在 i386_init 函数中找到：
```
	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
```
这是一个简单的递归调用：
```
void
test_backtrace(int x)
{
	cprintf("entering test_backtrace %d\n", x);
	if (x > 0)
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
}
```
我们并不关心 cprintf 函数，因此我们在最后一次调用时 (x=0) 时记录栈顶 esp：`0xf010ff20`。往后查看可得：
```
(gdb) b *0xf0100076
Breakpoint 1 at 0xf0100076: file kern/init.c, line 18.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf0100076 <test_backtrace+54>:	call   0xf010076e <mon_backtrace>
Breakpoint 1, 0xf0100076 in test_backtrace (x=0) at kern/init.c:18
18			mon_backtrace(0, 0, 0);
(gdb) x/52x $esp
0xf010ff20:	0x00000000	0x00000000	0x00000000	0x00000000
0xf010ff30:	0xf01008ef	0x00000001	0xf010ff58	0xf0100068
0xf010ff40:	0x00000000	0x00000001	0xf010ff78	0x00000000
0xf010ff50:	0xf01008ef	0x00000002	0xf010ff78	0xf0100068
0xf010ff60:	0x00000001	0x00000002	0xf010ff98	0x00000000
0xf010ff70:	0xf01008ef	0x00000003	0xf010ff98	0xf0100068
0xf010ff80:	0x00000002	0x00000003	0xf010ffb8	0x00000000
0xf010ff90:	0xf01008ef	0x00000004	0xf010ffb8	0xf0100068
0xf010ffa0:	0x00000003	0x00000004	0x00000000	0x00000000
0xf010ffb0:	0x00000000	0x00000005	0xf010ffd8	0xf0100068
0xf010ffc0:	0x00000004	0x00000005	0x00000000	0x00010094
0xf010ffd0:	0x00010094	0x00010094	0xf010fff8	0xf01000d4
0xf010ffe0:	0x00000005	0x00001aac	0x00000644	0x00000000
0xf010fff0:	0x00000000	0x00000000	0x00000000	0xf010003e
```
因为栈向下生长，从后往前看即为执行顺序。
在调用函数时，对栈需要进行以下操作：
 1. 将参数由右向左压入栈
 2. 将返回地址 (eip中的内容) 入栈，在 call 指令执行
 3. 将上一个函数的 ebp 入栈
 4. 将 ebx 入栈，保护寄存器状态
 5. 在栈上开辟一个空间存储局部变量

 可以看出，第二列出现的`0x00000005` 到 `0x00000000`都是参数。
在参数前一个存储的是返回地址，`0xf0100068`出现了多次，是 test_backtrace 递归过程中的返回地址。而 `0xf01000d4`出现仅一次，是 i386_init 函数中的返回地址。可以通过查看 obj/kern/kernel.asm 证明。
每两行一个循环，递归调用 test_backtrace 可以总结为：
```
+--------------------------------------------------------------+
 |    next x    |     this x     |  don't know   |  don't know  |
+--------------+----------------+---------------+--------------+
 |  don't know  |    last ebx    |  last ebp     | return addr  |
 +------ -------------------------------------------------------+
```

### Exercise 11
---
- **Implement a backtrace function with the output format:**
```
Stack backtrace:
  ebp f0109e58  eip f0100a62  args 00000001 f0109e80 f0109e98 f0100ed2 00000031
  ebp f0109ed8  eip f01000d6  args 00000000 00000000 f0100058 f0109f28 00000061
  ...
```
难度不大，直接上代码：
```
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t ebp, *ptr_ebp;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
		ptr_ebp = (uint32_t *)ebp;
		cprintf("\tebp %x  eip %x  args %08x %08x %08x %08x %08x\n", 
				ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		ebp = *ptr_ebp;
	}
	return 0;
}
```
主要是根据提示来改写 kern/monitor.c，重点用到的三个tricks：
 1. 利用read_ebp() 函数获取当前ebp值
 2. 利用 ebp 的初始值0判断是否停止
 3. 利用数组指针运算来获取 eip 以及 args

- **The return instruction pointer typically points to the instruction after the call instruction (why?)**
 
 call的函数执行结束后返回上一级函数继续执行。不用解释了。
- **Why can't the backtrace code detect how many arguments there actually are? How could this limitation be fixed?**

自己试着描述了下感觉不够清楚，于是参考了这位大牛的答案：
*https://github.com/clpsz/mit-jos-2014/tree/master/Lab1/Exercise11*
>因为判断有几个参数这种事情是编译器干的，编译器通过函数原型来判断有几个参数。函数内部是没有方法直接获取到有几个参数传过来了这种事情的。
要修复的话，可以把函数的第一个参数设置为总共的参数个数。

### Exercise 12
---
- **Complete the implementation of debuginfo_eip by inserting the call to stab_binsearch to find the line number for an address.
Add a backtrace command to the kernel monitor, and extend your implementation of mon_backtrace to call debuginfo_eip and print a line for each stack frame of the form:**
```
K> backtrace
Stack backtrace:
  ebp f010ff78  eip f01008ae  args 00000001 f010ff8c 00000000 f0110580 00000000
         kern/monitor.c:143: monitor+106
  ebp f010ffd8  eip f0100193  args 00000000 00001aac 00000660 00000000 00000000
         kern/init.c:49: i386_init+59
  ebp f010fff8  eip f010003d  args 00000000 00000000 0000ffff 10cf9a00 0000ffff
         kern/entry.S:70: <unknown>+0
K>
```
这里较为复杂一些，主要还是参考已有的函数进行编写。先上代码，首先是完成二分查找 stab 表确定行号的函数，在 kern/kdebug.c 的173行处：
```
	// Search within [lline, rline] for the line number stab.
	// If found, set info->eip_line to the right line number.
	// If not found, return -1.
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
	}
```
在这里主要需要注意的是两个地方：
 1. 阅读 inc/x86.h，找到 N_SLINE 这个关键 type，对应的行号存储在 n_desc 中。
 2. 获取行号使用的格式 stabs[lline].n_desc，这个可以参考之前的获取函数地址等内容的代码。

 此后是添加命令，在 kern/monitor.c 的第27行：
```
static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display backtrace info", mon_backtrace },
};
```
最后是添加 backtrace 的输出信息，将 kern/monitor.c 的 mon_backtrace 函数改为：
```
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
		ptr_ebp = (uint32_t *)ebp;
		cprintf("\tebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr;
			cprintf("\t\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line,info.eip_fn_namelen,  info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
	}
	return 0;
}
```
实际就是在这里调用 debuginfo_eip 这个函数。传入的 arg1 实际就是返回地址，即`ebp + 4`地址中所存的内容。另外就是注意一个输出方法：
 ```printf("%.*s", length, string)```
作用就是输出 string 的最多 length 个字符。较长的函数名因此可以较美观地显示。

### Lab1 总结
---
经过这个Lab，我们主要了解了以下内容：
1. 启动顺序：BIOS -> Boot Loader -> Kernel
2. 各自的简介：
 - BIOS:
位于 `0x000F 0000` 至 `0x0010 0000`共 64kB 空间中。
初始化 PCI 总线以及其他设备，搜索能启动的设备例如软盘、硬盘、光驱等，如果发现了启动盘，就读取盘内的 boot loader 并移交控制权。
 - Boot Loader:
位于 `0x7c00`与`0x7dff` 共 512 byte 空间之中。
从实模式切换到保护模式，并将 kernel 读取到内存中。跳转到kernel执行。
 - Kernel:
位于 `0x10 0000` 开始的物理内存中。被映射到了`0xf010 0000`的高位地址上。
开启内存分页机制，启用虚拟内存，I/O的实现，栈的初始化。
