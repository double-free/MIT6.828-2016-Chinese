### 补充知识
---
#### 补充1. AT&T汇编

由于内核代码采用的gcc编译器使用AT&T的汇编格式，首先补充下关于AT&T汇编的知识。
 - 汇编器命令 (assembler directives)
  - 汇编程序中以`.`开头的不会被翻译成机器指令，而是给编译器一些特殊的指示。
 - 操作数赋值方向
	 - 从左到右。
 - 前缀
	 - 寄存器前缀为`%`，立即数前缀为`$` 。
 - 后缀
	 - 指令最后一个字符用于表示操作数的大小，`b`表示byte（1个字节），`w`表示word（2个字节），`l`表示long（4个字节）。

#### 补充2. A20门和PS/2 Controller

在 8086 中有 20 根地址总线，通过 CS:IP 对的方式寻址，最大访问地址为 1MB，然而，FFFFH:FFFFH = 10FFEFH，也就是说从 100000H 到 10FFEFH 无法访问，当访问这段地址时，会产生 wrap-around，也就是实际访问地址会对 1MB 求模。
到了 80286 中有 24 根地址总线，最大访问地址为 16MB。这个时候，不会产生 wrap-around，为了向下兼容 8086，需要使用第 21 根地址总线。
所以 IBM 的工程师使用 PS/2 Controller 输出端口中多余的端口来管理 A20 gate，也就是第 21 根地址总线（从 0 开始）。
注意下表，`0x60`用于读写数据，`0x64`用于读写状态。

**PS/2 Controller IO Ports**

| IO Port | Access Type | Purpose |
| ------------- |:-------------| :-----|
| 0x60 | Read/Write | Data Port |
| 0x64 | Read | State Register |
| 0x64 | Write | Command Register |

**Status Register**

| Bit | Meaning |
| ------------- |:-------------:|
| 1 | Input buffer status (0 = empty, 1 = full) <br>(must be clear before attempting to write data to IO port 0x60 or IO port 0x64) |

**Command Register**

| Command Byte | Meaning | Response |
| ------------- |:-------------:| :-----|
| 0xD1 | Write next byte to Controller Output Port<br>Note: Check if output buffer is empty first | None |

**PS/2 Controller Output Port**

| Bit | Meaning |
| ------------- |:-------------:|
| 1 | A20 gate (output) |

### boot.S
`boot/boot.S`可以分为两部分，第一部分是在实模式下运行的。

```assemble
#include <inc/mmu.h>

# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

# .set 相当于 #define，用于设置常量
.set PROT_MODE_CSEG, 0x8         # kernel code segment selector
.set PROT_MODE_DSEG, 0x10        # kernel data segment selector
.set CR0_PE_ON,      0x1         # protected mode enable flag


# .globl使得连接程序(ld)能够看到start。
# 作用是使得同一文件夹的其他文件能引用start。
.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
  cld                         # String operations increment

  # Set up the important data segment registers (DS, ES, SS).
  # AX, DS, ES, SS 寄存器全部置0
  xorw    %ax,%ax             # Segment number zero
  movw    %ax,%ds             # -> Data Segment
  movw    %ax,%es             # -> Extra Segment
  movw    %ax,%ss             # -> Stack Segment

  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
  
  # 从PS/2 Controller的I/O Port读取一个byte
  # **** **1* 表示忙, 所以用0x2作test运算
  # 若test结果不为0, jnz跳转回函数起点
seta20.1:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.1
  # 通知PS/2 Controller，将下一个写入0x60的字节写出到 Output Port
  movb    $0xd1,%al               # 0xd1 -> port 0x64
  outb    %al,$0x64

  # 与seta20.1作用相同，等待端口空闲
seta20.2:
  inb     $0x64,%al               # Wait for not busy
  testb   $0x2,%al
  jnz     seta20.2
  # 将0xdf写出到0x60, 再写出到 Output Port, 打开了A20 gate 
  movb    $0xdf,%al               # 0xdf -> port 0x60
  outb    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
  movl    %cr0, %eax
  orl     $CR0_PE_ON, %eax
  movl    %eax, %cr0
  

```
第二部分是在保护模式下运行的
```assemble

  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
  movw    %ax, %ds                # -> DS: Data Segment
  movw    %ax, %es                # -> ES: Extra Segment
  movw    %ax, %fs                # -> FS
  movw    %ax, %gs                # -> GS
  movw    %ax, %ss                # -> SS: Stack Segment
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
  call bootmain

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin

# Bootstrap GDT
.p2align 2                                # force 4 byte alignment
gdt:
  SEG_NULL				# null seg
  SEG(STA_X|STA_R, 0x0, 0xffffffff)	# code seg
  SEG(STA_W, 0x0, 0xffffffff)	        # data seg

gdtdesc:
  .word   0x17                            # sizeof(gdt) - 1
  .long   gdt                             # address gdt

```