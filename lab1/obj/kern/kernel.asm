
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 e0 18 10 f0       	push   $0xf01018e0
f0100050:	e8 22 09 00 00       	call   f0100977 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 0a 07 00 00       	call   f0100785 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 fc 18 10 f0       	push   $0xf01018fc
f0100087:	e8 eb 08 00 00       	call   f0100977 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 7f 13 00 00       	call   f0101430 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 19 10 f0       	push   $0xf0101917
f01000c3:	e8 af 08 00 00       	call   f0100977 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 29 07 00 00       	call   f010080a <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 32 19 10 f0       	push   $0xf0101932
f0100110:	e8 62 08 00 00       	call   f0100977 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 32 08 00 00       	call   f0100951 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f0100126:	e8 4c 08 00 00       	call   f0100977 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 d2 06 00 00       	call   f010080a <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 4a 19 10 f0       	push   $0xf010194a
f0100152:	e8 20 08 00 00       	call   f0100977 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 ee 07 00 00       	call   f0100951 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 6e 19 10 f0 	movl   $0xf010196e,(%esp)
f010016a:	e8 08 08 00 00       	call   f0100977 <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 c0 1a 10 f0 	movzbl -0xfefe540(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a c0 19 10 f0 	movzbl -0xfefe640(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d a0 19 10 f0 	mov    -0xfefe660(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 64 19 10 f0       	push   $0xf0101964
f01002c8:	e8 aa 06 00 00       	call   f0100977 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 01 10 00 00       	call   f010147d <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 70 19 10 f0       	push   $0xf0101970
f010064b:	e8 27 03 00 00       	call   f0100977 <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 c0 1b 10 f0       	push   $0xf0101bc0
f0100691:	68 de 1b 10 f0       	push   $0xf0101bde
f0100696:	68 e3 1b 10 f0       	push   $0xf0101be3
f010069b:	e8 d7 02 00 00       	call   f0100977 <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 90 1c 10 f0       	push   $0xf0101c90
f01006a8:	68 ec 1b 10 f0       	push   $0xf0101bec
f01006ad:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006b2:	e8 c0 02 00 00       	call   f0100977 <cprintf>
f01006b7:	83 c4 0c             	add    $0xc,%esp
f01006ba:	68 f5 1b 10 f0       	push   $0xf0101bf5
f01006bf:	68 0c 1c 10 f0       	push   $0xf0101c0c
f01006c4:	68 e3 1b 10 f0       	push   $0xf0101be3
f01006c9:	e8 a9 02 00 00       	call   f0100977 <cprintf>
	return 0;
}
f01006ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d3:	c9                   	leave  
f01006d4:	c3                   	ret    

f01006d5 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006d5:	55                   	push   %ebp
f01006d6:	89 e5                	mov    %esp,%ebp
f01006d8:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006db:	68 16 1c 10 f0       	push   $0xf0101c16
f01006e0:	e8 92 02 00 00       	call   f0100977 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006e5:	83 c4 08             	add    $0x8,%esp
f01006e8:	68 0c 00 10 00       	push   $0x10000c
f01006ed:	68 b8 1c 10 f0       	push   $0xf0101cb8
f01006f2:	e8 80 02 00 00       	call   f0100977 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 0c 00 10 00       	push   $0x10000c
f01006ff:	68 0c 00 10 f0       	push   $0xf010000c
f0100704:	68 e0 1c 10 f0       	push   $0xf0101ce0
f0100709:	e8 69 02 00 00       	call   f0100977 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 c1 18 10 00       	push   $0x1018c1
f0100716:	68 c1 18 10 f0       	push   $0xf01018c1
f010071b:	68 04 1d 10 f0       	push   $0xf0101d04
f0100720:	e8 52 02 00 00       	call   f0100977 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 00 23 11 00       	push   $0x112300
f010072d:	68 00 23 11 f0       	push   $0xf0112300
f0100732:	68 28 1d 10 f0       	push   $0xf0101d28
f0100737:	e8 3b 02 00 00       	call   f0100977 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010073c:	83 c4 0c             	add    $0xc,%esp
f010073f:	68 44 29 11 00       	push   $0x112944
f0100744:	68 44 29 11 f0       	push   $0xf0112944
f0100749:	68 4c 1d 10 f0       	push   $0xf0101d4c
f010074e:	e8 24 02 00 00       	call   f0100977 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100753:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100758:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010075d:	83 c4 08             	add    $0x8,%esp
f0100760:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100765:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010076b:	85 c0                	test   %eax,%eax
f010076d:	0f 48 c2             	cmovs  %edx,%eax
f0100770:	c1 f8 0a             	sar    $0xa,%eax
f0100773:	50                   	push   %eax
f0100774:	68 70 1d 10 f0       	push   $0xf0101d70
f0100779:	e8 f9 01 00 00       	call   f0100977 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010077e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100783:	c9                   	leave  
f0100784:	c3                   	ret    

f0100785 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
f0100788:	57                   	push   %edi
f0100789:	56                   	push   %esi
f010078a:	53                   	push   %ebx
f010078b:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010078e:	89 eb                	mov    %ebp,%ebx
	cprintf("H%x Wo%s\n", 57616, &i);
	*/
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f0100790:	68 2f 1c 10 f0       	push   $0xf0101c2f
f0100795:	e8 dd 01 00 00       	call   f0100977 <cprintf>
	while (ebp != 0) {
f010079a:	83 c4 10             	add    $0x10,%esp
		ptr_ebp = (uint32_t *)ebp;
		cprintf("ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f010079d:	8d 7d d0             	lea    -0x30(%ebp),%edi
	*/
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
f01007a0:	eb 57                	jmp    f01007f9 <mon_backtrace+0x74>
		ptr_ebp = (uint32_t *)ebp;
f01007a2:	89 de                	mov    %ebx,%esi
		cprintf("ebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
f01007a4:	ff 73 18             	pushl  0x18(%ebx)
f01007a7:	ff 73 14             	pushl  0x14(%ebx)
f01007aa:	ff 73 10             	pushl  0x10(%ebx)
f01007ad:	ff 73 0c             	pushl  0xc(%ebx)
f01007b0:	ff 73 08             	pushl  0x8(%ebx)
f01007b3:	ff 73 04             	pushl  0x4(%ebx)
f01007b6:	53                   	push   %ebx
f01007b7:	68 9c 1d 10 f0       	push   $0xf0101d9c
f01007bc:	e8 b6 01 00 00       	call   f0100977 <cprintf>
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01007c1:	83 c4 18             	add    $0x18,%esp
f01007c4:	57                   	push   %edi
f01007c5:	ff 73 04             	pushl  0x4(%ebx)
f01007c8:	e8 b4 02 00 00       	call   f0100a81 <debuginfo_eip>
f01007cd:	83 c4 10             	add    $0x10,%esp
f01007d0:	85 c0                	test   %eax,%eax
f01007d2:	75 23                	jne    f01007f7 <mon_backtrace+0x72>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr;
			cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line,info.eip_fn_namelen,  info.eip_fn_name, fn_offset);
f01007d4:	83 ec 08             	sub    $0x8,%esp
f01007d7:	8b 43 04             	mov    0x4(%ebx),%eax
f01007da:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007dd:	50                   	push   %eax
f01007de:	ff 75 d8             	pushl  -0x28(%ebp)
f01007e1:	ff 75 dc             	pushl  -0x24(%ebp)
f01007e4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007e7:	ff 75 d0             	pushl  -0x30(%ebp)
f01007ea:	68 41 1c 10 f0       	push   $0xf0101c41
f01007ef:	e8 83 01 00 00       	call   f0100977 <cprintf>
f01007f4:	83 c4 20             	add    $0x20,%esp
		}
		ebp = *ptr_ebp;
f01007f7:	8b 1e                	mov    (%esi),%ebx
	*/
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
f01007f9:	85 db                	test   %ebx,%ebx
f01007fb:	75 a5                	jne    f01007a2 <mon_backtrace+0x1d>
			cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line,info.eip_fn_namelen,  info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
	}
	return 0;
}
f01007fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100802:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100805:	5b                   	pop    %ebx
f0100806:	5e                   	pop    %esi
f0100807:	5f                   	pop    %edi
f0100808:	5d                   	pop    %ebp
f0100809:	c3                   	ret    

f010080a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010080a:	55                   	push   %ebp
f010080b:	89 e5                	mov    %esp,%ebp
f010080d:	57                   	push   %edi
f010080e:	56                   	push   %esi
f010080f:	53                   	push   %ebx
f0100810:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100813:	68 cc 1d 10 f0       	push   $0xf0101dcc
f0100818:	e8 5a 01 00 00       	call   f0100977 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010081d:	c7 04 24 f0 1d 10 f0 	movl   $0xf0101df0,(%esp)
f0100824:	e8 4e 01 00 00       	call   f0100977 <cprintf>
f0100829:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010082c:	83 ec 0c             	sub    $0xc,%esp
f010082f:	68 51 1c 10 f0       	push   $0xf0101c51
f0100834:	e8 a0 09 00 00       	call   f01011d9 <readline>
f0100839:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010083b:	83 c4 10             	add    $0x10,%esp
f010083e:	85 c0                	test   %eax,%eax
f0100840:	74 ea                	je     f010082c <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100842:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100849:	be 00 00 00 00       	mov    $0x0,%esi
f010084e:	eb 0a                	jmp    f010085a <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100850:	c6 03 00             	movb   $0x0,(%ebx)
f0100853:	89 f7                	mov    %esi,%edi
f0100855:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100858:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010085a:	0f b6 03             	movzbl (%ebx),%eax
f010085d:	84 c0                	test   %al,%al
f010085f:	74 63                	je     f01008c4 <monitor+0xba>
f0100861:	83 ec 08             	sub    $0x8,%esp
f0100864:	0f be c0             	movsbl %al,%eax
f0100867:	50                   	push   %eax
f0100868:	68 55 1c 10 f0       	push   $0xf0101c55
f010086d:	e8 81 0b 00 00       	call   f01013f3 <strchr>
f0100872:	83 c4 10             	add    $0x10,%esp
f0100875:	85 c0                	test   %eax,%eax
f0100877:	75 d7                	jne    f0100850 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f0100879:	80 3b 00             	cmpb   $0x0,(%ebx)
f010087c:	74 46                	je     f01008c4 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010087e:	83 fe 0f             	cmp    $0xf,%esi
f0100881:	75 14                	jne    f0100897 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100883:	83 ec 08             	sub    $0x8,%esp
f0100886:	6a 10                	push   $0x10
f0100888:	68 5a 1c 10 f0       	push   $0xf0101c5a
f010088d:	e8 e5 00 00 00       	call   f0100977 <cprintf>
f0100892:	83 c4 10             	add    $0x10,%esp
f0100895:	eb 95                	jmp    f010082c <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100897:	8d 7e 01             	lea    0x1(%esi),%edi
f010089a:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010089e:	eb 03                	jmp    f01008a3 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008a0:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008a3:	0f b6 03             	movzbl (%ebx),%eax
f01008a6:	84 c0                	test   %al,%al
f01008a8:	74 ae                	je     f0100858 <monitor+0x4e>
f01008aa:	83 ec 08             	sub    $0x8,%esp
f01008ad:	0f be c0             	movsbl %al,%eax
f01008b0:	50                   	push   %eax
f01008b1:	68 55 1c 10 f0       	push   $0xf0101c55
f01008b6:	e8 38 0b 00 00       	call   f01013f3 <strchr>
f01008bb:	83 c4 10             	add    $0x10,%esp
f01008be:	85 c0                	test   %eax,%eax
f01008c0:	74 de                	je     f01008a0 <monitor+0x96>
f01008c2:	eb 94                	jmp    f0100858 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008c4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008cb:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008cc:	85 f6                	test   %esi,%esi
f01008ce:	0f 84 58 ff ff ff    	je     f010082c <monitor+0x22>
f01008d4:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008d9:	83 ec 08             	sub    $0x8,%esp
f01008dc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008df:	ff 34 85 20 1e 10 f0 	pushl  -0xfefe1e0(,%eax,4)
f01008e6:	ff 75 a8             	pushl  -0x58(%ebp)
f01008e9:	e8 a7 0a 00 00       	call   f0101395 <strcmp>
f01008ee:	83 c4 10             	add    $0x10,%esp
f01008f1:	85 c0                	test   %eax,%eax
f01008f3:	75 21                	jne    f0100916 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f01008f5:	83 ec 04             	sub    $0x4,%esp
f01008f8:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01008fb:	ff 75 08             	pushl  0x8(%ebp)
f01008fe:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100901:	52                   	push   %edx
f0100902:	56                   	push   %esi
f0100903:	ff 14 85 28 1e 10 f0 	call   *-0xfefe1d8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010090a:	83 c4 10             	add    $0x10,%esp
f010090d:	85 c0                	test   %eax,%eax
f010090f:	78 25                	js     f0100936 <monitor+0x12c>
f0100911:	e9 16 ff ff ff       	jmp    f010082c <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100916:	83 c3 01             	add    $0x1,%ebx
f0100919:	83 fb 03             	cmp    $0x3,%ebx
f010091c:	75 bb                	jne    f01008d9 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010091e:	83 ec 08             	sub    $0x8,%esp
f0100921:	ff 75 a8             	pushl  -0x58(%ebp)
f0100924:	68 77 1c 10 f0       	push   $0xf0101c77
f0100929:	e8 49 00 00 00       	call   f0100977 <cprintf>
f010092e:	83 c4 10             	add    $0x10,%esp
f0100931:	e9 f6 fe ff ff       	jmp    f010082c <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100936:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100939:	5b                   	pop    %ebx
f010093a:	5e                   	pop    %esi
f010093b:	5f                   	pop    %edi
f010093c:	5d                   	pop    %ebp
f010093d:	c3                   	ret    

f010093e <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010093e:	55                   	push   %ebp
f010093f:	89 e5                	mov    %esp,%ebp
f0100941:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100944:	ff 75 08             	pushl  0x8(%ebp)
f0100947:	e8 0f fd ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f010094c:	83 c4 10             	add    $0x10,%esp
f010094f:	c9                   	leave  
f0100950:	c3                   	ret    

f0100951 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100951:	55                   	push   %ebp
f0100952:	89 e5                	mov    %esp,%ebp
f0100954:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100957:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010095e:	ff 75 0c             	pushl  0xc(%ebp)
f0100961:	ff 75 08             	pushl  0x8(%ebp)
f0100964:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100967:	50                   	push   %eax
f0100968:	68 3e 09 10 f0       	push   $0xf010093e
f010096d:	e8 52 04 00 00       	call   f0100dc4 <vprintfmt>
	return cnt;
}
f0100972:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100975:	c9                   	leave  
f0100976:	c3                   	ret    

f0100977 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100977:	55                   	push   %ebp
f0100978:	89 e5                	mov    %esp,%ebp
f010097a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010097d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100980:	50                   	push   %eax
f0100981:	ff 75 08             	pushl  0x8(%ebp)
f0100984:	e8 c8 ff ff ff       	call   f0100951 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100989:	c9                   	leave  
f010098a:	c3                   	ret    

f010098b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010098b:	55                   	push   %ebp
f010098c:	89 e5                	mov    %esp,%ebp
f010098e:	57                   	push   %edi
f010098f:	56                   	push   %esi
f0100990:	53                   	push   %ebx
f0100991:	83 ec 14             	sub    $0x14,%esp
f0100994:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100997:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010099a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010099d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009a0:	8b 1a                	mov    (%edx),%ebx
f01009a2:	8b 01                	mov    (%ecx),%eax
f01009a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009ae:	eb 7f                	jmp    f0100a2f <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009b3:	01 d8                	add    %ebx,%eax
f01009b5:	89 c6                	mov    %eax,%esi
f01009b7:	c1 ee 1f             	shr    $0x1f,%esi
f01009ba:	01 c6                	add    %eax,%esi
f01009bc:	d1 fe                	sar    %esi
f01009be:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009c1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009c4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009c7:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009c9:	eb 03                	jmp    f01009ce <stab_binsearch+0x43>
			m--;
f01009cb:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009ce:	39 c3                	cmp    %eax,%ebx
f01009d0:	7f 0d                	jg     f01009df <stab_binsearch+0x54>
f01009d2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009d6:	83 ea 0c             	sub    $0xc,%edx
f01009d9:	39 f9                	cmp    %edi,%ecx
f01009db:	75 ee                	jne    f01009cb <stab_binsearch+0x40>
f01009dd:	eb 05                	jmp    f01009e4 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009df:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009e2:	eb 4b                	jmp    f0100a2f <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009e4:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009e7:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009ea:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009ee:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009f1:	76 11                	jbe    f0100a04 <stab_binsearch+0x79>
			*region_left = m;
f01009f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009f6:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01009f8:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009fb:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a02:	eb 2b                	jmp    f0100a2f <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a04:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a07:	73 14                	jae    f0100a1d <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a09:	83 e8 01             	sub    $0x1,%eax
f0100a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a12:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a14:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a1b:	eb 12                	jmp    f0100a2f <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a1d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a20:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a22:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a26:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a28:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a2f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a32:	0f 8e 78 ff ff ff    	jle    f01009b0 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a38:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a3c:	75 0f                	jne    f0100a4d <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a41:	8b 00                	mov    (%eax),%eax
f0100a43:	83 e8 01             	sub    $0x1,%eax
f0100a46:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a49:	89 06                	mov    %eax,(%esi)
f0100a4b:	eb 2c                	jmp    f0100a79 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a50:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a52:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a55:	8b 0e                	mov    (%esi),%ecx
f0100a57:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a5a:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a5d:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a60:	eb 03                	jmp    f0100a65 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a62:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a65:	39 c8                	cmp    %ecx,%eax
f0100a67:	7e 0b                	jle    f0100a74 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a69:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a6d:	83 ea 0c             	sub    $0xc,%edx
f0100a70:	39 df                	cmp    %ebx,%edi
f0100a72:	75 ee                	jne    f0100a62 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a74:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a77:	89 06                	mov    %eax,(%esi)
	}
}
f0100a79:	83 c4 14             	add    $0x14,%esp
f0100a7c:	5b                   	pop    %ebx
f0100a7d:	5e                   	pop    %esi
f0100a7e:	5f                   	pop    %edi
f0100a7f:	5d                   	pop    %ebp
f0100a80:	c3                   	ret    

f0100a81 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a81:	55                   	push   %ebp
f0100a82:	89 e5                	mov    %esp,%ebp
f0100a84:	57                   	push   %edi
f0100a85:	56                   	push   %esi
f0100a86:	53                   	push   %ebx
f0100a87:	83 ec 3c             	sub    $0x3c,%esp
f0100a8a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a90:	c7 03 44 1e 10 f0    	movl   $0xf0101e44,(%ebx)
	info->eip_line = 0;
f0100a96:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a9d:	c7 43 08 44 1e 10 f0 	movl   $0xf0101e44,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100aa4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100aab:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100aae:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ab5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100abb:	76 11                	jbe    f0100ace <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100abd:	b8 3a 73 10 f0       	mov    $0xf010733a,%eax
f0100ac2:	3d 0d 5a 10 f0       	cmp    $0xf0105a0d,%eax
f0100ac7:	77 19                	ja     f0100ae2 <debuginfo_eip+0x61>
f0100ac9:	e9 aa 01 00 00       	jmp    f0100c78 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ace:	83 ec 04             	sub    $0x4,%esp
f0100ad1:	68 4e 1e 10 f0       	push   $0xf0101e4e
f0100ad6:	6a 7f                	push   $0x7f
f0100ad8:	68 5b 1e 10 f0       	push   $0xf0101e5b
f0100add:	e8 04 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ae2:	80 3d 39 73 10 f0 00 	cmpb   $0x0,0xf0107339
f0100ae9:	0f 85 90 01 00 00    	jne    f0100c7f <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100aef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100af6:	b8 0c 5a 10 f0       	mov    $0xf0105a0c,%eax
f0100afb:	2d 7c 20 10 f0       	sub    $0xf010207c,%eax
f0100b00:	c1 f8 02             	sar    $0x2,%eax
f0100b03:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b09:	83 e8 01             	sub    $0x1,%eax
f0100b0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b0f:	83 ec 08             	sub    $0x8,%esp
f0100b12:	56                   	push   %esi
f0100b13:	6a 64                	push   $0x64
f0100b15:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b18:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b1b:	b8 7c 20 10 f0       	mov    $0xf010207c,%eax
f0100b20:	e8 66 fe ff ff       	call   f010098b <stab_binsearch>
	if (lfile == 0)
f0100b25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b28:	83 c4 10             	add    $0x10,%esp
f0100b2b:	85 c0                	test   %eax,%eax
f0100b2d:	0f 84 53 01 00 00    	je     f0100c86 <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b33:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b36:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b39:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b3c:	83 ec 08             	sub    $0x8,%esp
f0100b3f:	56                   	push   %esi
f0100b40:	6a 24                	push   $0x24
f0100b42:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b45:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b48:	b8 7c 20 10 f0       	mov    $0xf010207c,%eax
f0100b4d:	e8 39 fe ff ff       	call   f010098b <stab_binsearch>

	if (lfun <= rfun) {
f0100b52:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b55:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b58:	83 c4 10             	add    $0x10,%esp
f0100b5b:	39 d0                	cmp    %edx,%eax
f0100b5d:	7f 40                	jg     f0100b9f <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b5f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b62:	c1 e1 02             	shl    $0x2,%ecx
f0100b65:	8d b9 7c 20 10 f0    	lea    -0xfefdf84(%ecx),%edi
f0100b6b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b6e:	8b b9 7c 20 10 f0    	mov    -0xfefdf84(%ecx),%edi
f0100b74:	b9 3a 73 10 f0       	mov    $0xf010733a,%ecx
f0100b79:	81 e9 0d 5a 10 f0    	sub    $0xf0105a0d,%ecx
f0100b7f:	39 cf                	cmp    %ecx,%edi
f0100b81:	73 09                	jae    f0100b8c <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b83:	81 c7 0d 5a 10 f0    	add    $0xf0105a0d,%edi
f0100b89:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b8c:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100b8f:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b92:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100b95:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100b97:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100b9a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100b9d:	eb 0f                	jmp    f0100bae <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b9f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100ba2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ba5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100ba8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bab:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bae:	83 ec 08             	sub    $0x8,%esp
f0100bb1:	6a 3a                	push   $0x3a
f0100bb3:	ff 73 08             	pushl  0x8(%ebx)
f0100bb6:	e8 59 08 00 00       	call   f0101414 <strfind>
f0100bbb:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bbe:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bc1:	83 c4 08             	add    $0x8,%esp
f0100bc4:	56                   	push   %esi
f0100bc5:	6a 44                	push   $0x44
f0100bc7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bca:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100bcd:	b8 7c 20 10 f0       	mov    $0xf010207c,%eax
f0100bd2:	e8 b4 fd ff ff       	call   f010098b <stab_binsearch>
	if (lline <= rline) {
f0100bd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100bda:	83 c4 10             	add    $0x10,%esp
f0100bdd:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100be0:	0f 8f a7 00 00 00    	jg     f0100c8d <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f0100be6:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100be9:	8d 04 85 7c 20 10 f0 	lea    -0xfefdf84(,%eax,4),%eax
f0100bf0:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100bf4:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bf7:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bfa:	eb 06                	jmp    f0100c02 <debuginfo_eip+0x181>
f0100bfc:	83 ea 01             	sub    $0x1,%edx
f0100bff:	83 e8 0c             	sub    $0xc,%eax
f0100c02:	39 d6                	cmp    %edx,%esi
f0100c04:	7f 34                	jg     f0100c3a <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100c06:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c0a:	80 f9 84             	cmp    $0x84,%cl
f0100c0d:	74 0b                	je     f0100c1a <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c0f:	80 f9 64             	cmp    $0x64,%cl
f0100c12:	75 e8                	jne    f0100bfc <debuginfo_eip+0x17b>
f0100c14:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c18:	74 e2                	je     f0100bfc <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c1a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c1d:	8b 14 85 7c 20 10 f0 	mov    -0xfefdf84(,%eax,4),%edx
f0100c24:	b8 3a 73 10 f0       	mov    $0xf010733a,%eax
f0100c29:	2d 0d 5a 10 f0       	sub    $0xf0105a0d,%eax
f0100c2e:	39 c2                	cmp    %eax,%edx
f0100c30:	73 08                	jae    f0100c3a <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c32:	81 c2 0d 5a 10 f0    	add    $0xf0105a0d,%edx
f0100c38:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c3a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c3d:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c40:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c45:	39 f2                	cmp    %esi,%edx
f0100c47:	7d 50                	jge    f0100c99 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100c49:	83 c2 01             	add    $0x1,%edx
f0100c4c:	89 d0                	mov    %edx,%eax
f0100c4e:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c51:	8d 14 95 7c 20 10 f0 	lea    -0xfefdf84(,%edx,4),%edx
f0100c58:	eb 04                	jmp    f0100c5e <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c5a:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c5e:	39 c6                	cmp    %eax,%esi
f0100c60:	7e 32                	jle    f0100c94 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c62:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c66:	83 c0 01             	add    $0x1,%eax
f0100c69:	83 c2 0c             	add    $0xc,%edx
f0100c6c:	80 f9 a0             	cmp    $0xa0,%cl
f0100c6f:	74 e9                	je     f0100c5a <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c71:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c76:	eb 21                	jmp    f0100c99 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c7d:	eb 1a                	jmp    f0100c99 <debuginfo_eip+0x218>
f0100c7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c84:	eb 13                	jmp    f0100c99 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100c86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c8b:	eb 0c                	jmp    f0100c99 <debuginfo_eip+0x218>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
f0100c8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c92:	eb 05                	jmp    f0100c99 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c94:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c9c:	5b                   	pop    %ebx
f0100c9d:	5e                   	pop    %esi
f0100c9e:	5f                   	pop    %edi
f0100c9f:	5d                   	pop    %ebp
f0100ca0:	c3                   	ret    

f0100ca1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ca1:	55                   	push   %ebp
f0100ca2:	89 e5                	mov    %esp,%ebp
f0100ca4:	57                   	push   %edi
f0100ca5:	56                   	push   %esi
f0100ca6:	53                   	push   %ebx
f0100ca7:	83 ec 1c             	sub    $0x1c,%esp
f0100caa:	89 c7                	mov    %eax,%edi
f0100cac:	89 d6                	mov    %edx,%esi
f0100cae:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cb7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cba:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100cc2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cc5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cc8:	39 d3                	cmp    %edx,%ebx
f0100cca:	72 05                	jb     f0100cd1 <printnum+0x30>
f0100ccc:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100ccf:	77 45                	ja     f0100d16 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cd1:	83 ec 0c             	sub    $0xc,%esp
f0100cd4:	ff 75 18             	pushl  0x18(%ebp)
f0100cd7:	8b 45 14             	mov    0x14(%ebp),%eax
f0100cda:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100cdd:	53                   	push   %ebx
f0100cde:	ff 75 10             	pushl  0x10(%ebp)
f0100ce1:	83 ec 08             	sub    $0x8,%esp
f0100ce4:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100ce7:	ff 75 e0             	pushl  -0x20(%ebp)
f0100cea:	ff 75 dc             	pushl  -0x24(%ebp)
f0100ced:	ff 75 d8             	pushl  -0x28(%ebp)
f0100cf0:	e8 4b 09 00 00       	call   f0101640 <__udivdi3>
f0100cf5:	83 c4 18             	add    $0x18,%esp
f0100cf8:	52                   	push   %edx
f0100cf9:	50                   	push   %eax
f0100cfa:	89 f2                	mov    %esi,%edx
f0100cfc:	89 f8                	mov    %edi,%eax
f0100cfe:	e8 9e ff ff ff       	call   f0100ca1 <printnum>
f0100d03:	83 c4 20             	add    $0x20,%esp
f0100d06:	eb 18                	jmp    f0100d20 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d08:	83 ec 08             	sub    $0x8,%esp
f0100d0b:	56                   	push   %esi
f0100d0c:	ff 75 18             	pushl  0x18(%ebp)
f0100d0f:	ff d7                	call   *%edi
f0100d11:	83 c4 10             	add    $0x10,%esp
f0100d14:	eb 03                	jmp    f0100d19 <printnum+0x78>
f0100d16:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d19:	83 eb 01             	sub    $0x1,%ebx
f0100d1c:	85 db                	test   %ebx,%ebx
f0100d1e:	7f e8                	jg     f0100d08 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d20:	83 ec 08             	sub    $0x8,%esp
f0100d23:	56                   	push   %esi
f0100d24:	83 ec 04             	sub    $0x4,%esp
f0100d27:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d2a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d2d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d30:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d33:	e8 38 0a 00 00       	call   f0101770 <__umoddi3>
f0100d38:	83 c4 14             	add    $0x14,%esp
f0100d3b:	0f be 80 69 1e 10 f0 	movsbl -0xfefe197(%eax),%eax
f0100d42:	50                   	push   %eax
f0100d43:	ff d7                	call   *%edi
}
f0100d45:	83 c4 10             	add    $0x10,%esp
f0100d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d4b:	5b                   	pop    %ebx
f0100d4c:	5e                   	pop    %esi
f0100d4d:	5f                   	pop    %edi
f0100d4e:	5d                   	pop    %ebp
f0100d4f:	c3                   	ret    

f0100d50 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d50:	55                   	push   %ebp
f0100d51:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d53:	83 fa 01             	cmp    $0x1,%edx
f0100d56:	7e 0e                	jle    f0100d66 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d58:	8b 10                	mov    (%eax),%edx
f0100d5a:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d5d:	89 08                	mov    %ecx,(%eax)
f0100d5f:	8b 02                	mov    (%edx),%eax
f0100d61:	8b 52 04             	mov    0x4(%edx),%edx
f0100d64:	eb 22                	jmp    f0100d88 <getuint+0x38>
	else if (lflag)
f0100d66:	85 d2                	test   %edx,%edx
f0100d68:	74 10                	je     f0100d7a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d6a:	8b 10                	mov    (%eax),%edx
f0100d6c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d6f:	89 08                	mov    %ecx,(%eax)
f0100d71:	8b 02                	mov    (%edx),%eax
f0100d73:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d78:	eb 0e                	jmp    f0100d88 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d7a:	8b 10                	mov    (%eax),%edx
f0100d7c:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d7f:	89 08                	mov    %ecx,(%eax)
f0100d81:	8b 02                	mov    (%edx),%eax
f0100d83:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d88:	5d                   	pop    %ebp
f0100d89:	c3                   	ret    

f0100d8a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d8a:	55                   	push   %ebp
f0100d8b:	89 e5                	mov    %esp,%ebp
f0100d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d90:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100d94:	8b 10                	mov    (%eax),%edx
f0100d96:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d99:	73 0a                	jae    f0100da5 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100d9b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100d9e:	89 08                	mov    %ecx,(%eax)
f0100da0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100da3:	88 02                	mov    %al,(%edx)
}
f0100da5:	5d                   	pop    %ebp
f0100da6:	c3                   	ret    

f0100da7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100da7:	55                   	push   %ebp
f0100da8:	89 e5                	mov    %esp,%ebp
f0100daa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100dad:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100db0:	50                   	push   %eax
f0100db1:	ff 75 10             	pushl  0x10(%ebp)
f0100db4:	ff 75 0c             	pushl  0xc(%ebp)
f0100db7:	ff 75 08             	pushl  0x8(%ebp)
f0100dba:	e8 05 00 00 00       	call   f0100dc4 <vprintfmt>
	va_end(ap);
}
f0100dbf:	83 c4 10             	add    $0x10,%esp
f0100dc2:	c9                   	leave  
f0100dc3:	c3                   	ret    

f0100dc4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dc4:	55                   	push   %ebp
f0100dc5:	89 e5                	mov    %esp,%ebp
f0100dc7:	57                   	push   %edi
f0100dc8:	56                   	push   %esi
f0100dc9:	53                   	push   %ebx
f0100dca:	83 ec 2c             	sub    $0x2c,%esp
f0100dcd:	8b 75 08             	mov    0x8(%ebp),%esi
f0100dd0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dd3:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100dd6:	eb 12                	jmp    f0100dea <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100dd8:	85 c0                	test   %eax,%eax
f0100dda:	0f 84 89 03 00 00    	je     f0101169 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100de0:	83 ec 08             	sub    $0x8,%esp
f0100de3:	53                   	push   %ebx
f0100de4:	50                   	push   %eax
f0100de5:	ff d6                	call   *%esi
f0100de7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100dea:	83 c7 01             	add    $0x1,%edi
f0100ded:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100df1:	83 f8 25             	cmp    $0x25,%eax
f0100df4:	75 e2                	jne    f0100dd8 <vprintfmt+0x14>
f0100df6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100dfa:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e01:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e08:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e0f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e14:	eb 07                	jmp    f0100e1d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e16:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e19:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e1d:	8d 47 01             	lea    0x1(%edi),%eax
f0100e20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e23:	0f b6 07             	movzbl (%edi),%eax
f0100e26:	0f b6 c8             	movzbl %al,%ecx
f0100e29:	83 e8 23             	sub    $0x23,%eax
f0100e2c:	3c 55                	cmp    $0x55,%al
f0100e2e:	0f 87 1a 03 00 00    	ja     f010114e <vprintfmt+0x38a>
f0100e34:	0f b6 c0             	movzbl %al,%eax
f0100e37:	ff 24 85 f8 1e 10 f0 	jmp    *-0xfefe108(,%eax,4)
f0100e3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e41:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e45:	eb d6                	jmp    f0100e1d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e4f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e52:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e55:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e59:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e5c:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e5f:	83 fa 09             	cmp    $0x9,%edx
f0100e62:	77 39                	ja     f0100e9d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e64:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e67:	eb e9                	jmp    f0100e52 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e69:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e6c:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e6f:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e72:	8b 00                	mov    (%eax),%eax
f0100e74:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e77:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e7a:	eb 27                	jmp    f0100ea3 <vprintfmt+0xdf>
f0100e7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e7f:	85 c0                	test   %eax,%eax
f0100e81:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e86:	0f 49 c8             	cmovns %eax,%ecx
f0100e89:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e8f:	eb 8c                	jmp    f0100e1d <vprintfmt+0x59>
f0100e91:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e94:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100e9b:	eb 80                	jmp    f0100e1d <vprintfmt+0x59>
f0100e9d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ea0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ea3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ea7:	0f 89 70 ff ff ff    	jns    f0100e1d <vprintfmt+0x59>
				width = precision, precision = -1;
f0100ead:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100eb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100eb3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100eba:	e9 5e ff ff ff       	jmp    f0100e1d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ebf:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100ec5:	e9 53 ff ff ff       	jmp    f0100e1d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100eca:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ecd:	8d 50 04             	lea    0x4(%eax),%edx
f0100ed0:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ed3:	83 ec 08             	sub    $0x8,%esp
f0100ed6:	53                   	push   %ebx
f0100ed7:	ff 30                	pushl  (%eax)
f0100ed9:	ff d6                	call   *%esi
			break;
f0100edb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ede:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100ee1:	e9 04 ff ff ff       	jmp    f0100dea <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ee6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ee9:	8d 50 04             	lea    0x4(%eax),%edx
f0100eec:	89 55 14             	mov    %edx,0x14(%ebp)
f0100eef:	8b 00                	mov    (%eax),%eax
f0100ef1:	99                   	cltd   
f0100ef2:	31 d0                	xor    %edx,%eax
f0100ef4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ef6:	83 f8 06             	cmp    $0x6,%eax
f0100ef9:	7f 0b                	jg     f0100f06 <vprintfmt+0x142>
f0100efb:	8b 14 85 50 20 10 f0 	mov    -0xfefdfb0(,%eax,4),%edx
f0100f02:	85 d2                	test   %edx,%edx
f0100f04:	75 18                	jne    f0100f1e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f06:	50                   	push   %eax
f0100f07:	68 81 1e 10 f0       	push   $0xf0101e81
f0100f0c:	53                   	push   %ebx
f0100f0d:	56                   	push   %esi
f0100f0e:	e8 94 fe ff ff       	call   f0100da7 <printfmt>
f0100f13:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f19:	e9 cc fe ff ff       	jmp    f0100dea <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f1e:	52                   	push   %edx
f0100f1f:	68 8a 1e 10 f0       	push   $0xf0101e8a
f0100f24:	53                   	push   %ebx
f0100f25:	56                   	push   %esi
f0100f26:	e8 7c fe ff ff       	call   f0100da7 <printfmt>
f0100f2b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f31:	e9 b4 fe ff ff       	jmp    f0100dea <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f36:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f39:	8d 50 04             	lea    0x4(%eax),%edx
f0100f3c:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f3f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f41:	85 ff                	test   %edi,%edi
f0100f43:	b8 7a 1e 10 f0       	mov    $0xf0101e7a,%eax
f0100f48:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f4b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f4f:	0f 8e 94 00 00 00    	jle    f0100fe9 <vprintfmt+0x225>
f0100f55:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f59:	0f 84 98 00 00 00    	je     f0100ff7 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f5f:	83 ec 08             	sub    $0x8,%esp
f0100f62:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f65:	57                   	push   %edi
f0100f66:	e8 5f 03 00 00       	call   f01012ca <strnlen>
f0100f6b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f6e:	29 c1                	sub    %eax,%ecx
f0100f70:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f73:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f76:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100f7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f7d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100f80:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f82:	eb 0f                	jmp    f0100f93 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100f84:	83 ec 08             	sub    $0x8,%esp
f0100f87:	53                   	push   %ebx
f0100f88:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f8b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f8d:	83 ef 01             	sub    $0x1,%edi
f0100f90:	83 c4 10             	add    $0x10,%esp
f0100f93:	85 ff                	test   %edi,%edi
f0100f95:	7f ed                	jg     f0100f84 <vprintfmt+0x1c0>
f0100f97:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100f9a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100f9d:	85 c9                	test   %ecx,%ecx
f0100f9f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fa4:	0f 49 c1             	cmovns %ecx,%eax
f0100fa7:	29 c1                	sub    %eax,%ecx
f0100fa9:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fac:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100faf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fb2:	89 cb                	mov    %ecx,%ebx
f0100fb4:	eb 4d                	jmp    f0101003 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fb6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fba:	74 1b                	je     f0100fd7 <vprintfmt+0x213>
f0100fbc:	0f be c0             	movsbl %al,%eax
f0100fbf:	83 e8 20             	sub    $0x20,%eax
f0100fc2:	83 f8 5e             	cmp    $0x5e,%eax
f0100fc5:	76 10                	jbe    f0100fd7 <vprintfmt+0x213>
					putch('?', putdat);
f0100fc7:	83 ec 08             	sub    $0x8,%esp
f0100fca:	ff 75 0c             	pushl  0xc(%ebp)
f0100fcd:	6a 3f                	push   $0x3f
f0100fcf:	ff 55 08             	call   *0x8(%ebp)
f0100fd2:	83 c4 10             	add    $0x10,%esp
f0100fd5:	eb 0d                	jmp    f0100fe4 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0100fd7:	83 ec 08             	sub    $0x8,%esp
f0100fda:	ff 75 0c             	pushl  0xc(%ebp)
f0100fdd:	52                   	push   %edx
f0100fde:	ff 55 08             	call   *0x8(%ebp)
f0100fe1:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fe4:	83 eb 01             	sub    $0x1,%ebx
f0100fe7:	eb 1a                	jmp    f0101003 <vprintfmt+0x23f>
f0100fe9:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fec:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fef:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ff2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100ff5:	eb 0c                	jmp    f0101003 <vprintfmt+0x23f>
f0100ff7:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ffa:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ffd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101000:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101003:	83 c7 01             	add    $0x1,%edi
f0101006:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010100a:	0f be d0             	movsbl %al,%edx
f010100d:	85 d2                	test   %edx,%edx
f010100f:	74 23                	je     f0101034 <vprintfmt+0x270>
f0101011:	85 f6                	test   %esi,%esi
f0101013:	78 a1                	js     f0100fb6 <vprintfmt+0x1f2>
f0101015:	83 ee 01             	sub    $0x1,%esi
f0101018:	79 9c                	jns    f0100fb6 <vprintfmt+0x1f2>
f010101a:	89 df                	mov    %ebx,%edi
f010101c:	8b 75 08             	mov    0x8(%ebp),%esi
f010101f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101022:	eb 18                	jmp    f010103c <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101024:	83 ec 08             	sub    $0x8,%esp
f0101027:	53                   	push   %ebx
f0101028:	6a 20                	push   $0x20
f010102a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010102c:	83 ef 01             	sub    $0x1,%edi
f010102f:	83 c4 10             	add    $0x10,%esp
f0101032:	eb 08                	jmp    f010103c <vprintfmt+0x278>
f0101034:	89 df                	mov    %ebx,%edi
f0101036:	8b 75 08             	mov    0x8(%ebp),%esi
f0101039:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010103c:	85 ff                	test   %edi,%edi
f010103e:	7f e4                	jg     f0101024 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101040:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101043:	e9 a2 fd ff ff       	jmp    f0100dea <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101048:	83 fa 01             	cmp    $0x1,%edx
f010104b:	7e 16                	jle    f0101063 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010104d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101050:	8d 50 08             	lea    0x8(%eax),%edx
f0101053:	89 55 14             	mov    %edx,0x14(%ebp)
f0101056:	8b 50 04             	mov    0x4(%eax),%edx
f0101059:	8b 00                	mov    (%eax),%eax
f010105b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010105e:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101061:	eb 32                	jmp    f0101095 <vprintfmt+0x2d1>
	else if (lflag)
f0101063:	85 d2                	test   %edx,%edx
f0101065:	74 18                	je     f010107f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101067:	8b 45 14             	mov    0x14(%ebp),%eax
f010106a:	8d 50 04             	lea    0x4(%eax),%edx
f010106d:	89 55 14             	mov    %edx,0x14(%ebp)
f0101070:	8b 00                	mov    (%eax),%eax
f0101072:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101075:	89 c1                	mov    %eax,%ecx
f0101077:	c1 f9 1f             	sar    $0x1f,%ecx
f010107a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010107d:	eb 16                	jmp    f0101095 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f010107f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101082:	8d 50 04             	lea    0x4(%eax),%edx
f0101085:	89 55 14             	mov    %edx,0x14(%ebp)
f0101088:	8b 00                	mov    (%eax),%eax
f010108a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010108d:	89 c1                	mov    %eax,%ecx
f010108f:	c1 f9 1f             	sar    $0x1f,%ecx
f0101092:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101095:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101098:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010109b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010a0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010a4:	79 74                	jns    f010111a <vprintfmt+0x356>
				putch('-', putdat);
f01010a6:	83 ec 08             	sub    $0x8,%esp
f01010a9:	53                   	push   %ebx
f01010aa:	6a 2d                	push   $0x2d
f01010ac:	ff d6                	call   *%esi
				num = -(long long) num;
f01010ae:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010b1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010b4:	f7 d8                	neg    %eax
f01010b6:	83 d2 00             	adc    $0x0,%edx
f01010b9:	f7 da                	neg    %edx
f01010bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010be:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010c3:	eb 55                	jmp    f010111a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010c5:	8d 45 14             	lea    0x14(%ebp),%eax
f01010c8:	e8 83 fc ff ff       	call   f0100d50 <getuint>
			base = 10;
f01010cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010d2:	eb 46                	jmp    f010111a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01010d4:	8d 45 14             	lea    0x14(%ebp),%eax
f01010d7:	e8 74 fc ff ff       	call   f0100d50 <getuint>
			base = 8;
f01010dc:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01010e1:	eb 37                	jmp    f010111a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f01010e3:	83 ec 08             	sub    $0x8,%esp
f01010e6:	53                   	push   %ebx
f01010e7:	6a 30                	push   $0x30
f01010e9:	ff d6                	call   *%esi
			putch('x', putdat);
f01010eb:	83 c4 08             	add    $0x8,%esp
f01010ee:	53                   	push   %ebx
f01010ef:	6a 78                	push   $0x78
f01010f1:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01010f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f6:	8d 50 04             	lea    0x4(%eax),%edx
f01010f9:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01010fc:	8b 00                	mov    (%eax),%eax
f01010fe:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101103:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101106:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010110b:	eb 0d                	jmp    f010111a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010110d:	8d 45 14             	lea    0x14(%ebp),%eax
f0101110:	e8 3b fc ff ff       	call   f0100d50 <getuint>
			base = 16;
f0101115:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010111a:	83 ec 0c             	sub    $0xc,%esp
f010111d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101121:	57                   	push   %edi
f0101122:	ff 75 e0             	pushl  -0x20(%ebp)
f0101125:	51                   	push   %ecx
f0101126:	52                   	push   %edx
f0101127:	50                   	push   %eax
f0101128:	89 da                	mov    %ebx,%edx
f010112a:	89 f0                	mov    %esi,%eax
f010112c:	e8 70 fb ff ff       	call   f0100ca1 <printnum>
			break;
f0101131:	83 c4 20             	add    $0x20,%esp
f0101134:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101137:	e9 ae fc ff ff       	jmp    f0100dea <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010113c:	83 ec 08             	sub    $0x8,%esp
f010113f:	53                   	push   %ebx
f0101140:	51                   	push   %ecx
f0101141:	ff d6                	call   *%esi
			break;
f0101143:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101146:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101149:	e9 9c fc ff ff       	jmp    f0100dea <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010114e:	83 ec 08             	sub    $0x8,%esp
f0101151:	53                   	push   %ebx
f0101152:	6a 25                	push   $0x25
f0101154:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101156:	83 c4 10             	add    $0x10,%esp
f0101159:	eb 03                	jmp    f010115e <vprintfmt+0x39a>
f010115b:	83 ef 01             	sub    $0x1,%edi
f010115e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101162:	75 f7                	jne    f010115b <vprintfmt+0x397>
f0101164:	e9 81 fc ff ff       	jmp    f0100dea <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101169:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010116c:	5b                   	pop    %ebx
f010116d:	5e                   	pop    %esi
f010116e:	5f                   	pop    %edi
f010116f:	5d                   	pop    %ebp
f0101170:	c3                   	ret    

f0101171 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101171:	55                   	push   %ebp
f0101172:	89 e5                	mov    %esp,%ebp
f0101174:	83 ec 18             	sub    $0x18,%esp
f0101177:	8b 45 08             	mov    0x8(%ebp),%eax
f010117a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010117d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101180:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101184:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101187:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010118e:	85 c0                	test   %eax,%eax
f0101190:	74 26                	je     f01011b8 <vsnprintf+0x47>
f0101192:	85 d2                	test   %edx,%edx
f0101194:	7e 22                	jle    f01011b8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101196:	ff 75 14             	pushl  0x14(%ebp)
f0101199:	ff 75 10             	pushl  0x10(%ebp)
f010119c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010119f:	50                   	push   %eax
f01011a0:	68 8a 0d 10 f0       	push   $0xf0100d8a
f01011a5:	e8 1a fc ff ff       	call   f0100dc4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011ad:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011b3:	83 c4 10             	add    $0x10,%esp
f01011b6:	eb 05                	jmp    f01011bd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011bd:	c9                   	leave  
f01011be:	c3                   	ret    

f01011bf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011bf:	55                   	push   %ebp
f01011c0:	89 e5                	mov    %esp,%ebp
f01011c2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011c5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011c8:	50                   	push   %eax
f01011c9:	ff 75 10             	pushl  0x10(%ebp)
f01011cc:	ff 75 0c             	pushl  0xc(%ebp)
f01011cf:	ff 75 08             	pushl  0x8(%ebp)
f01011d2:	e8 9a ff ff ff       	call   f0101171 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011d7:	c9                   	leave  
f01011d8:	c3                   	ret    

f01011d9 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011d9:	55                   	push   %ebp
f01011da:	89 e5                	mov    %esp,%ebp
f01011dc:	57                   	push   %edi
f01011dd:	56                   	push   %esi
f01011de:	53                   	push   %ebx
f01011df:	83 ec 0c             	sub    $0xc,%esp
f01011e2:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011e5:	85 c0                	test   %eax,%eax
f01011e7:	74 11                	je     f01011fa <readline+0x21>
		cprintf("%s", prompt);
f01011e9:	83 ec 08             	sub    $0x8,%esp
f01011ec:	50                   	push   %eax
f01011ed:	68 8a 1e 10 f0       	push   $0xf0101e8a
f01011f2:	e8 80 f7 ff ff       	call   f0100977 <cprintf>
f01011f7:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011fa:	83 ec 0c             	sub    $0xc,%esp
f01011fd:	6a 00                	push   $0x0
f01011ff:	e8 78 f4 ff ff       	call   f010067c <iscons>
f0101204:	89 c7                	mov    %eax,%edi
f0101206:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101209:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010120e:	e8 58 f4 ff ff       	call   f010066b <getchar>
f0101213:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101215:	85 c0                	test   %eax,%eax
f0101217:	79 18                	jns    f0101231 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101219:	83 ec 08             	sub    $0x8,%esp
f010121c:	50                   	push   %eax
f010121d:	68 6c 20 10 f0       	push   $0xf010206c
f0101222:	e8 50 f7 ff ff       	call   f0100977 <cprintf>
			return NULL;
f0101227:	83 c4 10             	add    $0x10,%esp
f010122a:	b8 00 00 00 00       	mov    $0x0,%eax
f010122f:	eb 79                	jmp    f01012aa <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101231:	83 f8 08             	cmp    $0x8,%eax
f0101234:	0f 94 c2             	sete   %dl
f0101237:	83 f8 7f             	cmp    $0x7f,%eax
f010123a:	0f 94 c0             	sete   %al
f010123d:	08 c2                	or     %al,%dl
f010123f:	74 1a                	je     f010125b <readline+0x82>
f0101241:	85 f6                	test   %esi,%esi
f0101243:	7e 16                	jle    f010125b <readline+0x82>
			if (echoing)
f0101245:	85 ff                	test   %edi,%edi
f0101247:	74 0d                	je     f0101256 <readline+0x7d>
				cputchar('\b');
f0101249:	83 ec 0c             	sub    $0xc,%esp
f010124c:	6a 08                	push   $0x8
f010124e:	e8 08 f4 ff ff       	call   f010065b <cputchar>
f0101253:	83 c4 10             	add    $0x10,%esp
			i--;
f0101256:	83 ee 01             	sub    $0x1,%esi
f0101259:	eb b3                	jmp    f010120e <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010125b:	83 fb 1f             	cmp    $0x1f,%ebx
f010125e:	7e 23                	jle    f0101283 <readline+0xaa>
f0101260:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101266:	7f 1b                	jg     f0101283 <readline+0xaa>
			if (echoing)
f0101268:	85 ff                	test   %edi,%edi
f010126a:	74 0c                	je     f0101278 <readline+0x9f>
				cputchar(c);
f010126c:	83 ec 0c             	sub    $0xc,%esp
f010126f:	53                   	push   %ebx
f0101270:	e8 e6 f3 ff ff       	call   f010065b <cputchar>
f0101275:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101278:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f010127e:	8d 76 01             	lea    0x1(%esi),%esi
f0101281:	eb 8b                	jmp    f010120e <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101283:	83 fb 0a             	cmp    $0xa,%ebx
f0101286:	74 05                	je     f010128d <readline+0xb4>
f0101288:	83 fb 0d             	cmp    $0xd,%ebx
f010128b:	75 81                	jne    f010120e <readline+0x35>
			if (echoing)
f010128d:	85 ff                	test   %edi,%edi
f010128f:	74 0d                	je     f010129e <readline+0xc5>
				cputchar('\n');
f0101291:	83 ec 0c             	sub    $0xc,%esp
f0101294:	6a 0a                	push   $0xa
f0101296:	e8 c0 f3 ff ff       	call   f010065b <cputchar>
f010129b:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010129e:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012a5:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ad:	5b                   	pop    %ebx
f01012ae:	5e                   	pop    %esi
f01012af:	5f                   	pop    %edi
f01012b0:	5d                   	pop    %ebp
f01012b1:	c3                   	ret    

f01012b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012b2:	55                   	push   %ebp
f01012b3:	89 e5                	mov    %esp,%ebp
f01012b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01012bd:	eb 03                	jmp    f01012c2 <strlen+0x10>
		n++;
f01012bf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012c6:	75 f7                	jne    f01012bf <strlen+0xd>
		n++;
	return n;
}
f01012c8:	5d                   	pop    %ebp
f01012c9:	c3                   	ret    

f01012ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012ca:	55                   	push   %ebp
f01012cb:	89 e5                	mov    %esp,%ebp
f01012cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01012d8:	eb 03                	jmp    f01012dd <strnlen+0x13>
		n++;
f01012da:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012dd:	39 c2                	cmp    %eax,%edx
f01012df:	74 08                	je     f01012e9 <strnlen+0x1f>
f01012e1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01012e5:	75 f3                	jne    f01012da <strnlen+0x10>
f01012e7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01012e9:	5d                   	pop    %ebp
f01012ea:	c3                   	ret    

f01012eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012eb:	55                   	push   %ebp
f01012ec:	89 e5                	mov    %esp,%ebp
f01012ee:	53                   	push   %ebx
f01012ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01012f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012f5:	89 c2                	mov    %eax,%edx
f01012f7:	83 c2 01             	add    $0x1,%edx
f01012fa:	83 c1 01             	add    $0x1,%ecx
f01012fd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101301:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101304:	84 db                	test   %bl,%bl
f0101306:	75 ef                	jne    f01012f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101308:	5b                   	pop    %ebx
f0101309:	5d                   	pop    %ebp
f010130a:	c3                   	ret    

f010130b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010130b:	55                   	push   %ebp
f010130c:	89 e5                	mov    %esp,%ebp
f010130e:	53                   	push   %ebx
f010130f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101312:	53                   	push   %ebx
f0101313:	e8 9a ff ff ff       	call   f01012b2 <strlen>
f0101318:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010131b:	ff 75 0c             	pushl  0xc(%ebp)
f010131e:	01 d8                	add    %ebx,%eax
f0101320:	50                   	push   %eax
f0101321:	e8 c5 ff ff ff       	call   f01012eb <strcpy>
	return dst;
}
f0101326:	89 d8                	mov    %ebx,%eax
f0101328:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010132b:	c9                   	leave  
f010132c:	c3                   	ret    

f010132d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010132d:	55                   	push   %ebp
f010132e:	89 e5                	mov    %esp,%ebp
f0101330:	56                   	push   %esi
f0101331:	53                   	push   %ebx
f0101332:	8b 75 08             	mov    0x8(%ebp),%esi
f0101335:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101338:	89 f3                	mov    %esi,%ebx
f010133a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010133d:	89 f2                	mov    %esi,%edx
f010133f:	eb 0f                	jmp    f0101350 <strncpy+0x23>
		*dst++ = *src;
f0101341:	83 c2 01             	add    $0x1,%edx
f0101344:	0f b6 01             	movzbl (%ecx),%eax
f0101347:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010134a:	80 39 01             	cmpb   $0x1,(%ecx)
f010134d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101350:	39 da                	cmp    %ebx,%edx
f0101352:	75 ed                	jne    f0101341 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101354:	89 f0                	mov    %esi,%eax
f0101356:	5b                   	pop    %ebx
f0101357:	5e                   	pop    %esi
f0101358:	5d                   	pop    %ebp
f0101359:	c3                   	ret    

f010135a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010135a:	55                   	push   %ebp
f010135b:	89 e5                	mov    %esp,%ebp
f010135d:	56                   	push   %esi
f010135e:	53                   	push   %ebx
f010135f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101365:	8b 55 10             	mov    0x10(%ebp),%edx
f0101368:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010136a:	85 d2                	test   %edx,%edx
f010136c:	74 21                	je     f010138f <strlcpy+0x35>
f010136e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101372:	89 f2                	mov    %esi,%edx
f0101374:	eb 09                	jmp    f010137f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101376:	83 c2 01             	add    $0x1,%edx
f0101379:	83 c1 01             	add    $0x1,%ecx
f010137c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010137f:	39 c2                	cmp    %eax,%edx
f0101381:	74 09                	je     f010138c <strlcpy+0x32>
f0101383:	0f b6 19             	movzbl (%ecx),%ebx
f0101386:	84 db                	test   %bl,%bl
f0101388:	75 ec                	jne    f0101376 <strlcpy+0x1c>
f010138a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010138c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010138f:	29 f0                	sub    %esi,%eax
}
f0101391:	5b                   	pop    %ebx
f0101392:	5e                   	pop    %esi
f0101393:	5d                   	pop    %ebp
f0101394:	c3                   	ret    

f0101395 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101395:	55                   	push   %ebp
f0101396:	89 e5                	mov    %esp,%ebp
f0101398:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010139b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010139e:	eb 06                	jmp    f01013a6 <strcmp+0x11>
		p++, q++;
f01013a0:	83 c1 01             	add    $0x1,%ecx
f01013a3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013a6:	0f b6 01             	movzbl (%ecx),%eax
f01013a9:	84 c0                	test   %al,%al
f01013ab:	74 04                	je     f01013b1 <strcmp+0x1c>
f01013ad:	3a 02                	cmp    (%edx),%al
f01013af:	74 ef                	je     f01013a0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013b1:	0f b6 c0             	movzbl %al,%eax
f01013b4:	0f b6 12             	movzbl (%edx),%edx
f01013b7:	29 d0                	sub    %edx,%eax
}
f01013b9:	5d                   	pop    %ebp
f01013ba:	c3                   	ret    

f01013bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013bb:	55                   	push   %ebp
f01013bc:	89 e5                	mov    %esp,%ebp
f01013be:	53                   	push   %ebx
f01013bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01013c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013c5:	89 c3                	mov    %eax,%ebx
f01013c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013ca:	eb 06                	jmp    f01013d2 <strncmp+0x17>
		n--, p++, q++;
f01013cc:	83 c0 01             	add    $0x1,%eax
f01013cf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013d2:	39 d8                	cmp    %ebx,%eax
f01013d4:	74 15                	je     f01013eb <strncmp+0x30>
f01013d6:	0f b6 08             	movzbl (%eax),%ecx
f01013d9:	84 c9                	test   %cl,%cl
f01013db:	74 04                	je     f01013e1 <strncmp+0x26>
f01013dd:	3a 0a                	cmp    (%edx),%cl
f01013df:	74 eb                	je     f01013cc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013e1:	0f b6 00             	movzbl (%eax),%eax
f01013e4:	0f b6 12             	movzbl (%edx),%edx
f01013e7:	29 d0                	sub    %edx,%eax
f01013e9:	eb 05                	jmp    f01013f0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01013eb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013f0:	5b                   	pop    %ebx
f01013f1:	5d                   	pop    %ebp
f01013f2:	c3                   	ret    

f01013f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013f3:	55                   	push   %ebp
f01013f4:	89 e5                	mov    %esp,%ebp
f01013f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013fd:	eb 07                	jmp    f0101406 <strchr+0x13>
		if (*s == c)
f01013ff:	38 ca                	cmp    %cl,%dl
f0101401:	74 0f                	je     f0101412 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101403:	83 c0 01             	add    $0x1,%eax
f0101406:	0f b6 10             	movzbl (%eax),%edx
f0101409:	84 d2                	test   %dl,%dl
f010140b:	75 f2                	jne    f01013ff <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010140d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101412:	5d                   	pop    %ebp
f0101413:	c3                   	ret    

f0101414 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101414:	55                   	push   %ebp
f0101415:	89 e5                	mov    %esp,%ebp
f0101417:	8b 45 08             	mov    0x8(%ebp),%eax
f010141a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010141e:	eb 03                	jmp    f0101423 <strfind+0xf>
f0101420:	83 c0 01             	add    $0x1,%eax
f0101423:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101426:	38 ca                	cmp    %cl,%dl
f0101428:	74 04                	je     f010142e <strfind+0x1a>
f010142a:	84 d2                	test   %dl,%dl
f010142c:	75 f2                	jne    f0101420 <strfind+0xc>
			break;
	return (char *) s;
}
f010142e:	5d                   	pop    %ebp
f010142f:	c3                   	ret    

f0101430 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101430:	55                   	push   %ebp
f0101431:	89 e5                	mov    %esp,%ebp
f0101433:	57                   	push   %edi
f0101434:	56                   	push   %esi
f0101435:	53                   	push   %ebx
f0101436:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101439:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010143c:	85 c9                	test   %ecx,%ecx
f010143e:	74 36                	je     f0101476 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101440:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101446:	75 28                	jne    f0101470 <memset+0x40>
f0101448:	f6 c1 03             	test   $0x3,%cl
f010144b:	75 23                	jne    f0101470 <memset+0x40>
		c &= 0xFF;
f010144d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101451:	89 d3                	mov    %edx,%ebx
f0101453:	c1 e3 08             	shl    $0x8,%ebx
f0101456:	89 d6                	mov    %edx,%esi
f0101458:	c1 e6 18             	shl    $0x18,%esi
f010145b:	89 d0                	mov    %edx,%eax
f010145d:	c1 e0 10             	shl    $0x10,%eax
f0101460:	09 f0                	or     %esi,%eax
f0101462:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101464:	89 d8                	mov    %ebx,%eax
f0101466:	09 d0                	or     %edx,%eax
f0101468:	c1 e9 02             	shr    $0x2,%ecx
f010146b:	fc                   	cld    
f010146c:	f3 ab                	rep stos %eax,%es:(%edi)
f010146e:	eb 06                	jmp    f0101476 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101470:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101473:	fc                   	cld    
f0101474:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101476:	89 f8                	mov    %edi,%eax
f0101478:	5b                   	pop    %ebx
f0101479:	5e                   	pop    %esi
f010147a:	5f                   	pop    %edi
f010147b:	5d                   	pop    %ebp
f010147c:	c3                   	ret    

f010147d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010147d:	55                   	push   %ebp
f010147e:	89 e5                	mov    %esp,%ebp
f0101480:	57                   	push   %edi
f0101481:	56                   	push   %esi
f0101482:	8b 45 08             	mov    0x8(%ebp),%eax
f0101485:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101488:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010148b:	39 c6                	cmp    %eax,%esi
f010148d:	73 35                	jae    f01014c4 <memmove+0x47>
f010148f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101492:	39 d0                	cmp    %edx,%eax
f0101494:	73 2e                	jae    f01014c4 <memmove+0x47>
		s += n;
		d += n;
f0101496:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101499:	89 d6                	mov    %edx,%esi
f010149b:	09 fe                	or     %edi,%esi
f010149d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014a3:	75 13                	jne    f01014b8 <memmove+0x3b>
f01014a5:	f6 c1 03             	test   $0x3,%cl
f01014a8:	75 0e                	jne    f01014b8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014aa:	83 ef 04             	sub    $0x4,%edi
f01014ad:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014b0:	c1 e9 02             	shr    $0x2,%ecx
f01014b3:	fd                   	std    
f01014b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014b6:	eb 09                	jmp    f01014c1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014b8:	83 ef 01             	sub    $0x1,%edi
f01014bb:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014be:	fd                   	std    
f01014bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014c1:	fc                   	cld    
f01014c2:	eb 1d                	jmp    f01014e1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014c4:	89 f2                	mov    %esi,%edx
f01014c6:	09 c2                	or     %eax,%edx
f01014c8:	f6 c2 03             	test   $0x3,%dl
f01014cb:	75 0f                	jne    f01014dc <memmove+0x5f>
f01014cd:	f6 c1 03             	test   $0x3,%cl
f01014d0:	75 0a                	jne    f01014dc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01014d2:	c1 e9 02             	shr    $0x2,%ecx
f01014d5:	89 c7                	mov    %eax,%edi
f01014d7:	fc                   	cld    
f01014d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014da:	eb 05                	jmp    f01014e1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014dc:	89 c7                	mov    %eax,%edi
f01014de:	fc                   	cld    
f01014df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014e1:	5e                   	pop    %esi
f01014e2:	5f                   	pop    %edi
f01014e3:	5d                   	pop    %ebp
f01014e4:	c3                   	ret    

f01014e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014e5:	55                   	push   %ebp
f01014e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01014e8:	ff 75 10             	pushl  0x10(%ebp)
f01014eb:	ff 75 0c             	pushl  0xc(%ebp)
f01014ee:	ff 75 08             	pushl  0x8(%ebp)
f01014f1:	e8 87 ff ff ff       	call   f010147d <memmove>
}
f01014f6:	c9                   	leave  
f01014f7:	c3                   	ret    

f01014f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014f8:	55                   	push   %ebp
f01014f9:	89 e5                	mov    %esp,%ebp
f01014fb:	56                   	push   %esi
f01014fc:	53                   	push   %ebx
f01014fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0101500:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101503:	89 c6                	mov    %eax,%esi
f0101505:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101508:	eb 1a                	jmp    f0101524 <memcmp+0x2c>
		if (*s1 != *s2)
f010150a:	0f b6 08             	movzbl (%eax),%ecx
f010150d:	0f b6 1a             	movzbl (%edx),%ebx
f0101510:	38 d9                	cmp    %bl,%cl
f0101512:	74 0a                	je     f010151e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101514:	0f b6 c1             	movzbl %cl,%eax
f0101517:	0f b6 db             	movzbl %bl,%ebx
f010151a:	29 d8                	sub    %ebx,%eax
f010151c:	eb 0f                	jmp    f010152d <memcmp+0x35>
		s1++, s2++;
f010151e:	83 c0 01             	add    $0x1,%eax
f0101521:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101524:	39 f0                	cmp    %esi,%eax
f0101526:	75 e2                	jne    f010150a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101528:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010152d:	5b                   	pop    %ebx
f010152e:	5e                   	pop    %esi
f010152f:	5d                   	pop    %ebp
f0101530:	c3                   	ret    

f0101531 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101531:	55                   	push   %ebp
f0101532:	89 e5                	mov    %esp,%ebp
f0101534:	53                   	push   %ebx
f0101535:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101538:	89 c1                	mov    %eax,%ecx
f010153a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010153d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101541:	eb 0a                	jmp    f010154d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101543:	0f b6 10             	movzbl (%eax),%edx
f0101546:	39 da                	cmp    %ebx,%edx
f0101548:	74 07                	je     f0101551 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010154a:	83 c0 01             	add    $0x1,%eax
f010154d:	39 c8                	cmp    %ecx,%eax
f010154f:	72 f2                	jb     f0101543 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101551:	5b                   	pop    %ebx
f0101552:	5d                   	pop    %ebp
f0101553:	c3                   	ret    

f0101554 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101554:	55                   	push   %ebp
f0101555:	89 e5                	mov    %esp,%ebp
f0101557:	57                   	push   %edi
f0101558:	56                   	push   %esi
f0101559:	53                   	push   %ebx
f010155a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010155d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101560:	eb 03                	jmp    f0101565 <strtol+0x11>
		s++;
f0101562:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101565:	0f b6 01             	movzbl (%ecx),%eax
f0101568:	3c 20                	cmp    $0x20,%al
f010156a:	74 f6                	je     f0101562 <strtol+0xe>
f010156c:	3c 09                	cmp    $0x9,%al
f010156e:	74 f2                	je     f0101562 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101570:	3c 2b                	cmp    $0x2b,%al
f0101572:	75 0a                	jne    f010157e <strtol+0x2a>
		s++;
f0101574:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101577:	bf 00 00 00 00       	mov    $0x0,%edi
f010157c:	eb 11                	jmp    f010158f <strtol+0x3b>
f010157e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101583:	3c 2d                	cmp    $0x2d,%al
f0101585:	75 08                	jne    f010158f <strtol+0x3b>
		s++, neg = 1;
f0101587:	83 c1 01             	add    $0x1,%ecx
f010158a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010158f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101595:	75 15                	jne    f01015ac <strtol+0x58>
f0101597:	80 39 30             	cmpb   $0x30,(%ecx)
f010159a:	75 10                	jne    f01015ac <strtol+0x58>
f010159c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015a0:	75 7c                	jne    f010161e <strtol+0xca>
		s += 2, base = 16;
f01015a2:	83 c1 02             	add    $0x2,%ecx
f01015a5:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015aa:	eb 16                	jmp    f01015c2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015ac:	85 db                	test   %ebx,%ebx
f01015ae:	75 12                	jne    f01015c2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015b0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015b5:	80 39 30             	cmpb   $0x30,(%ecx)
f01015b8:	75 08                	jne    f01015c2 <strtol+0x6e>
		s++, base = 8;
f01015ba:	83 c1 01             	add    $0x1,%ecx
f01015bd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01015c7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015ca:	0f b6 11             	movzbl (%ecx),%edx
f01015cd:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015d0:	89 f3                	mov    %esi,%ebx
f01015d2:	80 fb 09             	cmp    $0x9,%bl
f01015d5:	77 08                	ja     f01015df <strtol+0x8b>
			dig = *s - '0';
f01015d7:	0f be d2             	movsbl %dl,%edx
f01015da:	83 ea 30             	sub    $0x30,%edx
f01015dd:	eb 22                	jmp    f0101601 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01015df:	8d 72 9f             	lea    -0x61(%edx),%esi
f01015e2:	89 f3                	mov    %esi,%ebx
f01015e4:	80 fb 19             	cmp    $0x19,%bl
f01015e7:	77 08                	ja     f01015f1 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01015e9:	0f be d2             	movsbl %dl,%edx
f01015ec:	83 ea 57             	sub    $0x57,%edx
f01015ef:	eb 10                	jmp    f0101601 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01015f1:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015f4:	89 f3                	mov    %esi,%ebx
f01015f6:	80 fb 19             	cmp    $0x19,%bl
f01015f9:	77 16                	ja     f0101611 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01015fb:	0f be d2             	movsbl %dl,%edx
f01015fe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101601:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101604:	7d 0b                	jge    f0101611 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101606:	83 c1 01             	add    $0x1,%ecx
f0101609:	0f af 45 10          	imul   0x10(%ebp),%eax
f010160d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010160f:	eb b9                	jmp    f01015ca <strtol+0x76>

	if (endptr)
f0101611:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101615:	74 0d                	je     f0101624 <strtol+0xd0>
		*endptr = (char *) s;
f0101617:	8b 75 0c             	mov    0xc(%ebp),%esi
f010161a:	89 0e                	mov    %ecx,(%esi)
f010161c:	eb 06                	jmp    f0101624 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010161e:	85 db                	test   %ebx,%ebx
f0101620:	74 98                	je     f01015ba <strtol+0x66>
f0101622:	eb 9e                	jmp    f01015c2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101624:	89 c2                	mov    %eax,%edx
f0101626:	f7 da                	neg    %edx
f0101628:	85 ff                	test   %edi,%edi
f010162a:	0f 45 c2             	cmovne %edx,%eax
}
f010162d:	5b                   	pop    %ebx
f010162e:	5e                   	pop    %esi
f010162f:	5f                   	pop    %edi
f0101630:	5d                   	pop    %ebp
f0101631:	c3                   	ret    
f0101632:	66 90                	xchg   %ax,%ax
f0101634:	66 90                	xchg   %ax,%ax
f0101636:	66 90                	xchg   %ax,%ax
f0101638:	66 90                	xchg   %ax,%ax
f010163a:	66 90                	xchg   %ax,%ax
f010163c:	66 90                	xchg   %ax,%ax
f010163e:	66 90                	xchg   %ax,%ax

f0101640 <__udivdi3>:
f0101640:	55                   	push   %ebp
f0101641:	57                   	push   %edi
f0101642:	56                   	push   %esi
f0101643:	53                   	push   %ebx
f0101644:	83 ec 1c             	sub    $0x1c,%esp
f0101647:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010164b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010164f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101653:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101657:	85 f6                	test   %esi,%esi
f0101659:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010165d:	89 ca                	mov    %ecx,%edx
f010165f:	89 f8                	mov    %edi,%eax
f0101661:	75 3d                	jne    f01016a0 <__udivdi3+0x60>
f0101663:	39 cf                	cmp    %ecx,%edi
f0101665:	0f 87 c5 00 00 00    	ja     f0101730 <__udivdi3+0xf0>
f010166b:	85 ff                	test   %edi,%edi
f010166d:	89 fd                	mov    %edi,%ebp
f010166f:	75 0b                	jne    f010167c <__udivdi3+0x3c>
f0101671:	b8 01 00 00 00       	mov    $0x1,%eax
f0101676:	31 d2                	xor    %edx,%edx
f0101678:	f7 f7                	div    %edi
f010167a:	89 c5                	mov    %eax,%ebp
f010167c:	89 c8                	mov    %ecx,%eax
f010167e:	31 d2                	xor    %edx,%edx
f0101680:	f7 f5                	div    %ebp
f0101682:	89 c1                	mov    %eax,%ecx
f0101684:	89 d8                	mov    %ebx,%eax
f0101686:	89 cf                	mov    %ecx,%edi
f0101688:	f7 f5                	div    %ebp
f010168a:	89 c3                	mov    %eax,%ebx
f010168c:	89 d8                	mov    %ebx,%eax
f010168e:	89 fa                	mov    %edi,%edx
f0101690:	83 c4 1c             	add    $0x1c,%esp
f0101693:	5b                   	pop    %ebx
f0101694:	5e                   	pop    %esi
f0101695:	5f                   	pop    %edi
f0101696:	5d                   	pop    %ebp
f0101697:	c3                   	ret    
f0101698:	90                   	nop
f0101699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016a0:	39 ce                	cmp    %ecx,%esi
f01016a2:	77 74                	ja     f0101718 <__udivdi3+0xd8>
f01016a4:	0f bd fe             	bsr    %esi,%edi
f01016a7:	83 f7 1f             	xor    $0x1f,%edi
f01016aa:	0f 84 98 00 00 00    	je     f0101748 <__udivdi3+0x108>
f01016b0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016b5:	89 f9                	mov    %edi,%ecx
f01016b7:	89 c5                	mov    %eax,%ebp
f01016b9:	29 fb                	sub    %edi,%ebx
f01016bb:	d3 e6                	shl    %cl,%esi
f01016bd:	89 d9                	mov    %ebx,%ecx
f01016bf:	d3 ed                	shr    %cl,%ebp
f01016c1:	89 f9                	mov    %edi,%ecx
f01016c3:	d3 e0                	shl    %cl,%eax
f01016c5:	09 ee                	or     %ebp,%esi
f01016c7:	89 d9                	mov    %ebx,%ecx
f01016c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016cd:	89 d5                	mov    %edx,%ebp
f01016cf:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016d3:	d3 ed                	shr    %cl,%ebp
f01016d5:	89 f9                	mov    %edi,%ecx
f01016d7:	d3 e2                	shl    %cl,%edx
f01016d9:	89 d9                	mov    %ebx,%ecx
f01016db:	d3 e8                	shr    %cl,%eax
f01016dd:	09 c2                	or     %eax,%edx
f01016df:	89 d0                	mov    %edx,%eax
f01016e1:	89 ea                	mov    %ebp,%edx
f01016e3:	f7 f6                	div    %esi
f01016e5:	89 d5                	mov    %edx,%ebp
f01016e7:	89 c3                	mov    %eax,%ebx
f01016e9:	f7 64 24 0c          	mull   0xc(%esp)
f01016ed:	39 d5                	cmp    %edx,%ebp
f01016ef:	72 10                	jb     f0101701 <__udivdi3+0xc1>
f01016f1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01016f5:	89 f9                	mov    %edi,%ecx
f01016f7:	d3 e6                	shl    %cl,%esi
f01016f9:	39 c6                	cmp    %eax,%esi
f01016fb:	73 07                	jae    f0101704 <__udivdi3+0xc4>
f01016fd:	39 d5                	cmp    %edx,%ebp
f01016ff:	75 03                	jne    f0101704 <__udivdi3+0xc4>
f0101701:	83 eb 01             	sub    $0x1,%ebx
f0101704:	31 ff                	xor    %edi,%edi
f0101706:	89 d8                	mov    %ebx,%eax
f0101708:	89 fa                	mov    %edi,%edx
f010170a:	83 c4 1c             	add    $0x1c,%esp
f010170d:	5b                   	pop    %ebx
f010170e:	5e                   	pop    %esi
f010170f:	5f                   	pop    %edi
f0101710:	5d                   	pop    %ebp
f0101711:	c3                   	ret    
f0101712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101718:	31 ff                	xor    %edi,%edi
f010171a:	31 db                	xor    %ebx,%ebx
f010171c:	89 d8                	mov    %ebx,%eax
f010171e:	89 fa                	mov    %edi,%edx
f0101720:	83 c4 1c             	add    $0x1c,%esp
f0101723:	5b                   	pop    %ebx
f0101724:	5e                   	pop    %esi
f0101725:	5f                   	pop    %edi
f0101726:	5d                   	pop    %ebp
f0101727:	c3                   	ret    
f0101728:	90                   	nop
f0101729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101730:	89 d8                	mov    %ebx,%eax
f0101732:	f7 f7                	div    %edi
f0101734:	31 ff                	xor    %edi,%edi
f0101736:	89 c3                	mov    %eax,%ebx
f0101738:	89 d8                	mov    %ebx,%eax
f010173a:	89 fa                	mov    %edi,%edx
f010173c:	83 c4 1c             	add    $0x1c,%esp
f010173f:	5b                   	pop    %ebx
f0101740:	5e                   	pop    %esi
f0101741:	5f                   	pop    %edi
f0101742:	5d                   	pop    %ebp
f0101743:	c3                   	ret    
f0101744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101748:	39 ce                	cmp    %ecx,%esi
f010174a:	72 0c                	jb     f0101758 <__udivdi3+0x118>
f010174c:	31 db                	xor    %ebx,%ebx
f010174e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101752:	0f 87 34 ff ff ff    	ja     f010168c <__udivdi3+0x4c>
f0101758:	bb 01 00 00 00       	mov    $0x1,%ebx
f010175d:	e9 2a ff ff ff       	jmp    f010168c <__udivdi3+0x4c>
f0101762:	66 90                	xchg   %ax,%ax
f0101764:	66 90                	xchg   %ax,%ax
f0101766:	66 90                	xchg   %ax,%ax
f0101768:	66 90                	xchg   %ax,%ax
f010176a:	66 90                	xchg   %ax,%ax
f010176c:	66 90                	xchg   %ax,%ax
f010176e:	66 90                	xchg   %ax,%ax

f0101770 <__umoddi3>:
f0101770:	55                   	push   %ebp
f0101771:	57                   	push   %edi
f0101772:	56                   	push   %esi
f0101773:	53                   	push   %ebx
f0101774:	83 ec 1c             	sub    $0x1c,%esp
f0101777:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010177b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010177f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101783:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101787:	85 d2                	test   %edx,%edx
f0101789:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010178d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101791:	89 f3                	mov    %esi,%ebx
f0101793:	89 3c 24             	mov    %edi,(%esp)
f0101796:	89 74 24 04          	mov    %esi,0x4(%esp)
f010179a:	75 1c                	jne    f01017b8 <__umoddi3+0x48>
f010179c:	39 f7                	cmp    %esi,%edi
f010179e:	76 50                	jbe    f01017f0 <__umoddi3+0x80>
f01017a0:	89 c8                	mov    %ecx,%eax
f01017a2:	89 f2                	mov    %esi,%edx
f01017a4:	f7 f7                	div    %edi
f01017a6:	89 d0                	mov    %edx,%eax
f01017a8:	31 d2                	xor    %edx,%edx
f01017aa:	83 c4 1c             	add    $0x1c,%esp
f01017ad:	5b                   	pop    %ebx
f01017ae:	5e                   	pop    %esi
f01017af:	5f                   	pop    %edi
f01017b0:	5d                   	pop    %ebp
f01017b1:	c3                   	ret    
f01017b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017b8:	39 f2                	cmp    %esi,%edx
f01017ba:	89 d0                	mov    %edx,%eax
f01017bc:	77 52                	ja     f0101810 <__umoddi3+0xa0>
f01017be:	0f bd ea             	bsr    %edx,%ebp
f01017c1:	83 f5 1f             	xor    $0x1f,%ebp
f01017c4:	75 5a                	jne    f0101820 <__umoddi3+0xb0>
f01017c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01017ca:	0f 82 e0 00 00 00    	jb     f01018b0 <__umoddi3+0x140>
f01017d0:	39 0c 24             	cmp    %ecx,(%esp)
f01017d3:	0f 86 d7 00 00 00    	jbe    f01018b0 <__umoddi3+0x140>
f01017d9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017dd:	8b 54 24 04          	mov    0x4(%esp),%edx
f01017e1:	83 c4 1c             	add    $0x1c,%esp
f01017e4:	5b                   	pop    %ebx
f01017e5:	5e                   	pop    %esi
f01017e6:	5f                   	pop    %edi
f01017e7:	5d                   	pop    %ebp
f01017e8:	c3                   	ret    
f01017e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017f0:	85 ff                	test   %edi,%edi
f01017f2:	89 fd                	mov    %edi,%ebp
f01017f4:	75 0b                	jne    f0101801 <__umoddi3+0x91>
f01017f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01017fb:	31 d2                	xor    %edx,%edx
f01017fd:	f7 f7                	div    %edi
f01017ff:	89 c5                	mov    %eax,%ebp
f0101801:	89 f0                	mov    %esi,%eax
f0101803:	31 d2                	xor    %edx,%edx
f0101805:	f7 f5                	div    %ebp
f0101807:	89 c8                	mov    %ecx,%eax
f0101809:	f7 f5                	div    %ebp
f010180b:	89 d0                	mov    %edx,%eax
f010180d:	eb 99                	jmp    f01017a8 <__umoddi3+0x38>
f010180f:	90                   	nop
f0101810:	89 c8                	mov    %ecx,%eax
f0101812:	89 f2                	mov    %esi,%edx
f0101814:	83 c4 1c             	add    $0x1c,%esp
f0101817:	5b                   	pop    %ebx
f0101818:	5e                   	pop    %esi
f0101819:	5f                   	pop    %edi
f010181a:	5d                   	pop    %ebp
f010181b:	c3                   	ret    
f010181c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101820:	8b 34 24             	mov    (%esp),%esi
f0101823:	bf 20 00 00 00       	mov    $0x20,%edi
f0101828:	89 e9                	mov    %ebp,%ecx
f010182a:	29 ef                	sub    %ebp,%edi
f010182c:	d3 e0                	shl    %cl,%eax
f010182e:	89 f9                	mov    %edi,%ecx
f0101830:	89 f2                	mov    %esi,%edx
f0101832:	d3 ea                	shr    %cl,%edx
f0101834:	89 e9                	mov    %ebp,%ecx
f0101836:	09 c2                	or     %eax,%edx
f0101838:	89 d8                	mov    %ebx,%eax
f010183a:	89 14 24             	mov    %edx,(%esp)
f010183d:	89 f2                	mov    %esi,%edx
f010183f:	d3 e2                	shl    %cl,%edx
f0101841:	89 f9                	mov    %edi,%ecx
f0101843:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101847:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010184b:	d3 e8                	shr    %cl,%eax
f010184d:	89 e9                	mov    %ebp,%ecx
f010184f:	89 c6                	mov    %eax,%esi
f0101851:	d3 e3                	shl    %cl,%ebx
f0101853:	89 f9                	mov    %edi,%ecx
f0101855:	89 d0                	mov    %edx,%eax
f0101857:	d3 e8                	shr    %cl,%eax
f0101859:	89 e9                	mov    %ebp,%ecx
f010185b:	09 d8                	or     %ebx,%eax
f010185d:	89 d3                	mov    %edx,%ebx
f010185f:	89 f2                	mov    %esi,%edx
f0101861:	f7 34 24             	divl   (%esp)
f0101864:	89 d6                	mov    %edx,%esi
f0101866:	d3 e3                	shl    %cl,%ebx
f0101868:	f7 64 24 04          	mull   0x4(%esp)
f010186c:	39 d6                	cmp    %edx,%esi
f010186e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101872:	89 d1                	mov    %edx,%ecx
f0101874:	89 c3                	mov    %eax,%ebx
f0101876:	72 08                	jb     f0101880 <__umoddi3+0x110>
f0101878:	75 11                	jne    f010188b <__umoddi3+0x11b>
f010187a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010187e:	73 0b                	jae    f010188b <__umoddi3+0x11b>
f0101880:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101884:	1b 14 24             	sbb    (%esp),%edx
f0101887:	89 d1                	mov    %edx,%ecx
f0101889:	89 c3                	mov    %eax,%ebx
f010188b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010188f:	29 da                	sub    %ebx,%edx
f0101891:	19 ce                	sbb    %ecx,%esi
f0101893:	89 f9                	mov    %edi,%ecx
f0101895:	89 f0                	mov    %esi,%eax
f0101897:	d3 e0                	shl    %cl,%eax
f0101899:	89 e9                	mov    %ebp,%ecx
f010189b:	d3 ea                	shr    %cl,%edx
f010189d:	89 e9                	mov    %ebp,%ecx
f010189f:	d3 ee                	shr    %cl,%esi
f01018a1:	09 d0                	or     %edx,%eax
f01018a3:	89 f2                	mov    %esi,%edx
f01018a5:	83 c4 1c             	add    $0x1c,%esp
f01018a8:	5b                   	pop    %ebx
f01018a9:	5e                   	pop    %esi
f01018aa:	5f                   	pop    %edi
f01018ab:	5d                   	pop    %ebp
f01018ac:	c3                   	ret    
f01018ad:	8d 76 00             	lea    0x0(%esi),%esi
f01018b0:	29 f9                	sub    %edi,%ecx
f01018b2:	19 d6                	sbb    %edx,%esi
f01018b4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018bc:	e9 18 ff ff ff       	jmp    f01017d9 <__umoddi3+0x69>
