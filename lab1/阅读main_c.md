### 准备知识
---
- **ELF文件**

"Executable and Linkable Format" 的简称。当编译和链接一个 C 程序的时候，编译器将每个 C 源码文件 (.c) 转为一个对象文件 (.o) ，对象文件中存放的是机器能理解的二进制格式的汇编语言指令。然后，链接器 (linker) 将所有对象文件结合为一个二进制映像 (image) 文件，即ELF文件。
- **硬盘布局**

bootloader (boot.S and main.c) 存放在启动盘的第一个 sector
kernel (必须为 elf 文件)存放在第二个 sector
- **启动步骤**

 1. 将BIOS读入内存并执行
 2. BIOS将初始化设备，设置好中断，将设备的第一个sector读入内存并跳转。
 3. 执行到bootloader时，`boot.S`将开启保护模式，并设置好栈指针使得系统可以执行 C 程序。然后执行`bootmain()`。
 4. `main.c`中的`bootmain`会读入 kernel 并且跳转。

### 阅读代码
---
用到了在 inc/elf.h 中定义的两个结构体
```
struct Elf {   // ELF文件头
	uint32_t e_magic;	// must equal ELF_MAGIC
	uint8_t e_elf[12];
	uint16_t e_type;
	uint16_t e_machine;
	uint32_t e_version;
	uint32_t e_entry;
	uint32_t e_phoff;   // program header起始位置
	uint32_t e_shoff;   // section header起始位置
	uint32_t e_flags;
	uint16_t e_ehsize;   // ELF文件头本身大小
	uint16_t e_phentsize;
	uint16_t e_phnum;   // program header个数
	uint16_t e_shentsize;
	uint16_t e_shnum;
	uint16_t e_shstrndx;
};

struct Proghdr {   // 程序头表
	uint32_t p_type;
	uint32_t p_offset;   // 段相对于ELF文件开头的偏移
	uint32_t p_va;
	uint32_t p_pa;   // 物理地址
	uint32_t p_filesz;
	uint32_t p_memsz;   // 在内存中的大小
	uint32_t p_flags;   // 读，写，执行权限
	uint32_t p_align;
};
```

![ELF文件结构](http://upload-images.jianshu.io/upload_images/4482847-a5a265b2f69b39ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

首先，ELF文件格式提供了两种视图，分别是链接视图和执行视图。
链接视图是以节（section）为单位，执行视图是以段（segment）为单位。链接视图就是在链接时用到的视图，而执行视图则是在执行时用到的视图。上图左侧的视角是从链接来看的，右侧的视角是执行来看的。可以看出，一个segment可以包含数个section。
本文关注执行，结构体Proghdr是用于描述段 (segment) 的 program header，可有多个。
#### bootmain()函数

```c
#include <inc/x86.h>
#include <inc/elf.h>

/**********************************************************************
 * This a dirt simple boot loader, whose sole job is to boot
 * an ELF kernel image from the first IDE hard disk.
 *
 * DISK LAYOUT
 *  * This program(boot.S and main.c) is the bootloader.  It should
 *    be stored in the first sector of the disk.
 *
 *  * The 2nd sector onward holds the kernel image.
 *
 *  * The kernel image must be in ELF format.
 *
 * BOOT UP STEPS
 *  * when the CPU boots it loads the BIOS into memory and executes it
 *
 *  * the BIOS intializes devices, sets of the interrupt routines, and
 *    reads the first sector of the boot device(e.g., hard-drive)
 *    into memory and jumps to it.
 *
 *  * Assuming this boot loader is stored in the first sector of the
 *    hard-drive, this code takes over...
 *
 *  * control starts in boot.S -- which sets up protected mode,
 *    and a stack so C code then run, then calls bootmain()
 *
 *  * bootmain() in this file takes over, reads in the kernel and jumps to it.
 **********************************************************************/
// 扇区(sector)大小512
#define SECTSIZE	512   
// 将0x10000设为内核起始地址
#define ELFHDR		((struct Elf *) 0x10000) // scratch space

void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	// 从 0 开始读取 8*512 = 4096 byte 的内容到 ELFHDR
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	// 获得程序头表的起始位置 ph
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	// 获取程序头表结束的位置 eph
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
		// p_pa is the load address of this segment (as well
		// as the physical address)
		// 根据每个 program header 读取 segment
		// 从 p_offset 开始拷贝 p_memsz 个 byte 到 p_pa
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();

bad:
	outw(0x8A00, 0x8A00);
	outw(0x8A00, 0x8E00);
	while (1)
		/* do nothing */;
}
```
**语法难点解析**

- `ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);`
首先将ELFHDR转为 uint8_t 型指针，做加法的时候按照 byte 加，获得程序头表的起始位置，再将这个位置转为 Proghdr 型指针 ph。

- `((void (*)(void)) (ELFHDR->e_entry))();`
将`ELFHDR->e_entry`转为一个无参数，无返回值的函数指针，并执行该函数。

#### 读取segment

*(只从逻辑分析，忽略readsect和waitdisk函数)*
```c
// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;

	// round down to sector boundary
	// 将pa按扇区对齐
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	// 将以byte为单位的offset转为以sector为单位
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		// 此时，offset已经被转为以扇区(sector)为单位
		// 始终是以一个 sector 为单位读取
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}

void
waitdisk(void)
{
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
		/* do nothing */;
}

void
readsect(void *dst, uint32_t offset)
{
	// wait for disk to be ready
	waitdisk();

	outb(0x1F2, 1);		// count = 1
	outb(0x1F3, offset);
	outb(0x1F4, offset >> 8);
	outb(0x1F5, offset >> 16);
	outb(0x1F6, (offset >> 24) | 0xE0);
	outb(0x1F7, 0x20);	// cmd 0x20 - read sectors

	// wait for disk to be ready
	waitdisk();

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
```
**语法难点解析**

- `pa &= ~(SECTSIZE - 1);`
对应汇编码：
```
(gdb) 
=> 0x7cf1:	and    $0xfffffe00,%ebx
0x00007cf1 in ?? ()
```
uint32_t 512的十六进制表示为`0x00000200`，减1后为`0x000001ff`，按位取反得`0xfffffe00`，可以看出作用是将pa的后9 bit全部置0。

### 附录1. main.c生成的汇编代码
为了分析exercise 3，有必要对各个函数的汇编码进行一个review。

```
// 调用 bootmain()
=> 0x7c45:	call   0x7d15
=> 0x7d15:	push   %ebp
=> 0x7d16:	mov    %esp,%ebp
=> 0x7d18:	push   %esi
=> 0x7d19:	push   %ebx

// 从右向左压入参数
=> 0x7d1a:	push   $0x0
=> 0x7d1c:	push   $0x1000
=> 0x7d21:	push   $0x10000
// 调用 readseg((uint32_t) ELFHDR, SECTSIZE*8, 0)
=> 0x7d26:	call   0x7cdc
=> 0x7cdc:	push   %ebp
=> 0x7cdd:	mov    %esp,%ebp
=> 0x7cdf:	push   %edi
=> 0x7ce0:	push   %esi
// 利用偏移获取各参数
// ebp+8 位置是arg1
// ebp+12 位置是arg2
// ebp+16 位置是arg3
=> 0x7ce1:	mov    0x10(%ebp),%edi
=> 0x7ce4:	push   %ebx
=> 0x7ce5:	mov    0xc(%ebp),%esi
=> 0x7ce8:	mov    0x8(%ebp),%ebx
=> 0x7ceb:	shr    $0x9,%edi    // (offset / SECTSIZE)
=> 0x7cee:	add    %ebx,%esi
=> 0x7cf0:	inc    %edi
=> 0x7cf1:	and    $0xfffffe00,%ebx
=> 0x7cf7:	cmp    %esi,%ebx    // while 语句比较 pa 和 end_pa
=> 0x7cf9:	jae    0x7d0d    // 大于等于则跳转
=> 0x7cfb:	push   %edi
=> 0x7cfc:	push   %ebx
=> 0x7cfd:	inc    %edi    // offset++
=> 0x7cfe:	add    $0x200,%ebx    // pa += SECTSIZE
// 调用 readsect((uint8_t*) pa, offset)
=> 0x7d04:	call   0x7c7c
=> 0x7c7c:	push   %ebp
=> 0x7c7d:	mov    %esp,%ebp
=> 0x7c7f:	push   %edi
=> 0x7c80:	mov    0xc(%ebp),%ecx
// 调用 waitdisk(void)
=> 0x7c83:	call   0x7c6a
=> 0x7c6a:	push   %ebp
=> 0x7c6b:	mov    $0x1f7,%edx
=> 0x7c70:	mov    %esp,%ebp
=> 0x7c72:	in     (%dx),%al
=> 0x7c73:	and    $0xffffffc0,%eax
=> 0x7c76:	cmp    $0x40,%al
=> 0x7c78:	jne    0x7c72
=> 0x7c7a:	pop    %ebp
=> 0x7c7b:	ret
// waitdisk 结束，返回 readsect 函数继续执行
=> 0x7c88:	mov    $0x1f2,%edx
=> 0x7c8d:	mov    $0x1,%al
=> 0x7c8f:	out    %al,(%dx)
=> 0x7c90:	mov    $0x1f3,%edx
=> 0x7c95:	mov    %cl,%al
=> 0x7c97:	out    %al,(%dx)
=> 0x7c98:	mov    %ecx,%eax
=> 0x7c9a:	mov    $0x1f4,%edx
=> 0x7c9f:	shr    $0x8,%eax
=> 0x7ca2:	out    %al,(%dx)
=> 0x7ca3:	mov    %ecx,%eax
=> 0x7ca5:	mov    $0x1f5,%edx
=> 0x7caa:	shr    $0x10,%eax
=> 0x7cad:	out    %al,(%dx)
=> 0x7cae:	mov    %ecx,%eax
=> 0x7cb0:	mov    $0x1f6,%edx
=> 0x7cb5:	shr    $0x18,%eax
=> 0x7cb8:	or     $0xffffffe0,%eax
=> 0x7cbb:	out    %al,(%dx)
=> 0x7cbc:	mov    $0x1f7,%edx
=> 0x7cc1:	mov    $0x20,%al
=> 0x7cc3:	out    %al,(%dx)
// 调用 waitdisk(void)
=> 0x7cc4:	call   0x7c6a
=> 0x7c6a:	push   %ebp
=> 0x7c6b:	mov    $0x1f7,%edx
=> 0x7c70:	mov    %esp,%ebp
=> 0x7c72:	in     (%dx),%al
=> 0x7c73:	and    $0xffffffc0,%eax
=> 0x7c76:	cmp    $0x40,%al
=> 0x7c78:	jne    0x7c72
=> 0x7c7a:	pop    %ebp
=> 0x7c7b:	ret
=> 0x7cc9:	mov    0x8(%ebp),%edi
=> 0x7ccc:	mov    $0x80,%ecx
=> 0x7cd1:	mov    $0x1f0,%edx
=> 0x7cd6:	cld
=> 0x7cd7:	repnz insl (%dx),%es:(%edi)  //repeats instruction while Z flag is cleared
=> 0x7cd9:	pop    %edi
=> 0x7cda:	pop    %ebp
=> 0x7cdb:	ret    // 退出 readsect 函数
=> 0x7d09:	pop    %eax
=> 0x7d0a:	pop    %edx
// 返回 while 语句判断
=> 0x7d0b:	jmp    0x7cf7
... // 重复直到跳出 while 循环
=> 0x7d0d:	lea    -0xc(%ebp),%esp
=> 0x7d10:	pop    %ebx
=> 0x7d11:	pop    %esi
=> 0x7d12:	pop    %edi
=> 0x7d13:	pop    %ebp
=> 0x7d14:	ret    // 退出 readseg 函数
=> 0x7d2b:	add    $0xc,%esp
=> 0x7d2e:	cmpl   $0x464c457f,0x10000    // 判断 e_magic
=> 0x7d38:	jne    0x7d71
=> 0x7d3a:	mov    0x1001c,%eax
=> 0x7d3f:	movzwl 0x1002c,%esi
=> 0x7d46:	lea    0x10000(%eax),%ebx
=> 0x7d4c:	shl    $0x5,%esi
=> 0x7d4f:	add    %ebx,%esi    // ebx存放ph，esi存放eph
=> 0x7d51:	cmp    %esi,%ebx    // for 语句中比较 ph 与 eph
=> 0x7d53:	jae    0x7d6b    // 大于等于则跳转
// 压入参数
=> 0x7d55:	pushl  0x4(%ebx)
=> 0x7d58:	pushl  0x14(%ebx)
=> 0x7d5b:	add    $0x20,%ebx
=> 0x7d5e:	pushl  -0x14(%ebx)
//  调用 readseg(ph->p_pa, ph->p_memsz, ph->p_offset)
=> 0x7d61:	call   0x7cdc
... // 重复直到跳出for循环
```
### 附录2. ELF详细介绍

- **ELF executable**
可看作包含加载信息的文件头 (header) 以及一些程序段 (program section)。每个程序段是相邻的代码块或数据块，需要被加载到内存的特定位置。boot loader 不更改代码或数据，只是加载到内存并且执行。
- **ELF binary**
以一个定长 ELF header 开头，然后是变长的 program header，包含了所有需要加载的程序段。
- **program section**
只关注三个会用到的section。
 1. .text
程序的可执行指令。
 2. .rodata 
只读数据。例如 C 编译器产生的 ASCII 字符串常量。
 3. .data
保存程序的初始数据。例如某个有初始值的全局变量 `int x = 5;`。

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
  重点关注的是 .text 部分的 VMA (link address) 和 LMA (load address)。link address 是开始执行该 section 的内存地址。而 load address 则顾名思义，是加载该 section 的内存地址。一般而言这两者是相同的。
boot loader 利用 ELF program header 来决定如何加载 section，而 program header 指定应该读取 ELF 对象的哪个部分进内存，以及应该放在哪里。
