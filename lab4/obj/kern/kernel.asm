
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
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
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
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 fe 22 f0    	mov    %esi,0xf022fe80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 19 5b 00 00       	call   f0105b7a <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 62 10 f0       	push   $0xf0106220
f010006d:	e8 f1 37 00 00       	call   f0103863 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 c1 37 00 00       	call   f010383d <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 72 75 10 f0 	movl   $0xf0107572,(%esp)
f0100083:	e8 db 37 00 00       	call   f0103863 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 1b 0a 00 00       	call   f0100ab0 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 10 27 f0       	mov    $0xf0271008,%eax
f01000a6:	2d 10 e9 22 f0       	sub    $0xf022e910,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 10 e9 22 f0       	push   $0xf022e910
f01000b3:	e8 a1 54 00 00       	call   f0105559 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 82 05 00 00       	call   f010063f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 8c 62 10 f0       	push   $0xf010628c
f01000ca:	e8 94 37 00 00       	call   f0103863 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 de 13 00 00       	call   f01014b2 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 dd 2f 00 00       	call   f01030b6 <env_init>
	trap_init();
f01000d9:	e8 63 38 00 00       	call   f0103941 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 8d 57 00 00       	call   f0105870 <mp_init>
	lapic_init();
f01000e3:	e8 ad 5a 00 00       	call   f0105b95 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 9d 36 00 00       	call   f010378a <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f01000f4:	e8 ef 5c 00 00       	call   f0105de8 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 fe 22 f0 07 	cmpl   $0x7,0xf022fe88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 44 62 10 f0       	push   $0xf0106244
f010010f:	6a 57                	push   $0x57
f0100111:	68 a7 62 10 f0       	push   $0xf01062a7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 d6 57 10 f0       	mov    $0xf01057d6,%eax
f0100123:	2d 5c 57 10 f0       	sub    $0xf010575c,%eax
f0100128:	50                   	push   %eax
f0100129:	68 5c 57 10 f0       	push   $0xf010575c
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 6e 54 00 00       	call   f01055a6 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 00 23 f0       	mov    $0xf0230020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 33 5a 00 00       	call   f0105b7a <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 00 23 f0       	add    $0xf0230020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 00 23 f0       	sub    $0xf0230020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 90 23 f0       	add    $0xf0239000,%eax
f010016b:	a3 84 fe 22 f0       	mov    %eax,0xf022fe84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 62 5b 00 00       	call   f0105ce3 <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0100196:	05 20 00 23 f0       	add    $0xf0230020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 1c 07 20 f0       	push   $0xf020071c
f01001a9:	e8 d7 30 00 00       	call   f0103285 <env_create>
	// ENV_CREATE(user_yield, ENV_TYPE_USER);
	// ENV_CREATE(user_yield, ENV_TYPE_USER);
	// ENV_CREATE(user_yield, ENV_TYPE_USER);
	// ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
	// Schedule and run the first user environment!
	sched_yield();
f01001ae:	e8 8c 42 00 00       	call   f010443f <sched_yield>

f01001b3 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	77 12                	ja     f01001d7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c5:	50                   	push   %eax
f01001c6:	68 68 62 10 f0       	push   $0xf0106268
f01001cb:	6a 6e                	push   $0x6e
f01001cd:	68 a7 62 10 f0       	push   $0xf01062a7
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 96 59 00 00       	call   f0105b7a <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 b3 62 10 f0       	push   $0xf01062b3
f01001ed:	e8 71 36 00 00       	call   f0103863 <cprintf>

	lapic_init();
f01001f2:	e8 9e 59 00 00       	call   f0105b95 <lapic_init>
	env_init_percpu();
f01001f7:	e8 8a 2e 00 00       	call   f0103086 <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 76 36 00 00       	call   f0103877 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 74 59 00 00       	call   f0105b7a <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 03 12 f0 	movl   $0xf01203c0,(%esp)
f010021f:	e8 c4 5b 00 00       	call   f0105de8 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100224:	e8 16 42 00 00       	call   f010443f <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 c9 62 10 f0       	push   $0xf01062c9
f010023e:	e8 20 36 00 00       	call   f0103863 <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 ee 35 00 00       	call   f010383d <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 72 75 10 f0 	movl   $0xf0107572,(%esp)
f0100256:	e8 08 36 00 00       	call   f0103863 <cprintf>
	va_end(ap);
}
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 f2 22 f0    	mov    0xf022f224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 f2 22 f0    	mov    %edx,0xf022f224
f01002a0:	88 81 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 f2 22 f0 00 	movl   $0x0,0xf022f224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f8 00 00 00    	je     f01003cb <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002d3:	a8 20                	test   $0x20,%al
f01002d5:	0f 85 f6 00 00 00    	jne    f01003d1 <kbd_proc_data+0x10c>
f01002db:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e3:	3c e0                	cmp    $0xe0,%al
f01002e5:	75 0d                	jne    f01002f4 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002e7:	83 0d 00 f0 22 f0 40 	orl    $0x40,0xf022f000
		return 0;
f01002ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f4:	55                   	push   %ebp
f01002f5:	89 e5                	mov    %esp,%ebp
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 36                	jns    f0100335 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f0100305:	89 cb                	mov    %ecx,%ebx
f0100307:	83 e3 40             	and    $0x40,%ebx
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 db                	test   %ebx,%ebx
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 82 40 64 10 f0 	movzbl -0xfef9bc0(%edx),%eax
f010031c:	83 c8 40             	or     $0x40,%eax
f010031f:	0f b6 c0             	movzbl %al,%eax
f0100322:	f7 d0                	not    %eax
f0100324:	21 c8                	and    %ecx,%eax
f0100326:	a3 00 f0 22 f0       	mov    %eax,0xf022f000
		return 0;
f010032b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100330:	e9 a4 00 00 00       	jmp    f01003d9 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100335:	8b 0d 00 f0 22 f0    	mov    0xf022f000,%ecx
f010033b:	f6 c1 40             	test   $0x40,%cl
f010033e:	74 0e                	je     f010034e <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100340:	83 c8 80             	or     $0xffffff80,%eax
f0100343:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100345:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100348:	89 0d 00 f0 22 f0    	mov    %ecx,0xf022f000
	}

	shift |= shiftcode[data];
f010034e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100351:	0f b6 82 40 64 10 f0 	movzbl -0xfef9bc0(%edx),%eax
f0100358:	0b 05 00 f0 22 f0    	or     0xf022f000,%eax
f010035e:	0f b6 8a 40 63 10 f0 	movzbl -0xfef9cc0(%edx),%ecx
f0100365:	31 c8                	xor    %ecx,%eax
f0100367:	a3 00 f0 22 f0       	mov    %eax,0xf022f000

	c = charcode[shift & (CTL | SHIFT)][data];
f010036c:	89 c1                	mov    %eax,%ecx
f010036e:	83 e1 03             	and    $0x3,%ecx
f0100371:	8b 0c 8d 20 63 10 f0 	mov    -0xfef9ce0(,%ecx,4),%ecx
f0100378:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010037c:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037f:	a8 08                	test   $0x8,%al
f0100381:	74 1b                	je     f010039e <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100383:	89 da                	mov    %ebx,%edx
f0100385:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100388:	83 f9 19             	cmp    $0x19,%ecx
f010038b:	77 05                	ja     f0100392 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010038d:	83 eb 20             	sub    $0x20,%ebx
f0100390:	eb 0c                	jmp    f010039e <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100392:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100395:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100398:	83 fa 19             	cmp    $0x19,%edx
f010039b:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039e:	f7 d0                	not    %eax
f01003a0:	a8 06                	test   $0x6,%al
f01003a2:	75 33                	jne    f01003d7 <kbd_proc_data+0x112>
f01003a4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003aa:	75 2b                	jne    f01003d7 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003ac:	83 ec 0c             	sub    $0xc,%esp
f01003af:	68 e3 62 10 f0       	push   $0xf01062e3
f01003b4:	e8 aa 34 00 00       	call   f0103863 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	ba 92 00 00 00       	mov    $0x92,%edx
f01003be:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c3:	ee                   	out    %al,(%dx)
f01003c4:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c7:	89 d8                	mov    %ebx,%eax
f01003c9:	eb 0e                	jmp    f01003d9 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003d0:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003d6:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d7:	89 d8                	mov    %ebx,%eax
}
f01003d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003dc:	c9                   	leave  
f01003dd:	c3                   	ret    

f01003de <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003de:	55                   	push   %ebp
f01003df:	89 e5                	mov    %esp,%ebp
f01003e1:	57                   	push   %edi
f01003e2:	56                   	push   %esi
f01003e3:	53                   	push   %ebx
f01003e4:	83 ec 1c             	sub    $0x1c,%esp
f01003e7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e9:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ee:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f8:	eb 09                	jmp    f0100403 <cons_putc+0x25>
f01003fa:	89 ca                	mov    %ecx,%edx
f01003fc:	ec                   	in     (%dx),%al
f01003fd:	ec                   	in     (%dx),%al
f01003fe:	ec                   	in     (%dx),%al
f01003ff:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100400:	83 c3 01             	add    $0x1,%ebx
f0100403:	89 f2                	mov    %esi,%edx
f0100405:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100406:	a8 20                	test   $0x20,%al
f0100408:	75 08                	jne    f0100412 <cons_putc+0x34>
f010040a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100410:	7e e8                	jle    f01003fa <cons_putc+0x1c>
f0100412:	89 f8                	mov    %edi,%eax
f0100414:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100417:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010041c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100422:	be 79 03 00 00       	mov    $0x379,%esi
f0100427:	b9 84 00 00 00       	mov    $0x84,%ecx
f010042c:	eb 09                	jmp    f0100437 <cons_putc+0x59>
f010042e:	89 ca                	mov    %ecx,%edx
f0100430:	ec                   	in     (%dx),%al
f0100431:	ec                   	in     (%dx),%al
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	83 c3 01             	add    $0x1,%ebx
f0100437:	89 f2                	mov    %esi,%edx
f0100439:	ec                   	in     (%dx),%al
f010043a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100440:	7f 04                	jg     f0100446 <cons_putc+0x68>
f0100442:	84 c0                	test   %al,%al
f0100444:	79 e8                	jns    f010042e <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100446:	ba 78 03 00 00       	mov    $0x378,%edx
f010044b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044f:	ee                   	out    %al,(%dx)
f0100450:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100455:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045a:	ee                   	out    %al,(%dx)
f010045b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100460:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100461:	89 fa                	mov    %edi,%edx
f0100463:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100469:	89 f8                	mov    %edi,%eax
f010046b:	80 cc 07             	or     $0x7,%ah
f010046e:	85 d2                	test   %edx,%edx
f0100470:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100473:	89 f8                	mov    %edi,%eax
f0100475:	0f b6 c0             	movzbl %al,%eax
f0100478:	83 f8 09             	cmp    $0x9,%eax
f010047b:	74 74                	je     f01004f1 <cons_putc+0x113>
f010047d:	83 f8 09             	cmp    $0x9,%eax
f0100480:	7f 0a                	jg     f010048c <cons_putc+0xae>
f0100482:	83 f8 08             	cmp    $0x8,%eax
f0100485:	74 14                	je     f010049b <cons_putc+0xbd>
f0100487:	e9 99 00 00 00       	jmp    f0100525 <cons_putc+0x147>
f010048c:	83 f8 0a             	cmp    $0xa,%eax
f010048f:	74 3a                	je     f01004cb <cons_putc+0xed>
f0100491:	83 f8 0d             	cmp    $0xd,%eax
f0100494:	74 3d                	je     f01004d3 <cons_putc+0xf5>
f0100496:	e9 8a 00 00 00       	jmp    f0100525 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010049b:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004a2:	66 85 c0             	test   %ax,%ax
f01004a5:	0f 84 e6 00 00 00    	je     f0100591 <cons_putc+0x1b3>
			crt_pos--;
f01004ab:	83 e8 01             	sub    $0x1,%eax
f01004ae:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b4:	0f b7 c0             	movzwl %ax,%eax
f01004b7:	66 81 e7 00 ff       	and    $0xff00,%di
f01004bc:	83 cf 20             	or     $0x20,%edi
f01004bf:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	eb 78                	jmp    f0100543 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004cb:	66 83 05 28 f2 22 f0 	addw   $0x50,0xf022f228
f01004d2:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d3:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f01004da:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e0:	c1 e8 16             	shr    $0x16,%eax
f01004e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e6:	c1 e0 04             	shl    $0x4,%eax
f01004e9:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228
f01004ef:	eb 52                	jmp    f0100543 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f6:	e8 e3 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f01004fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0100500:	e8 d9 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100505:	b8 20 00 00 00       	mov    $0x20,%eax
f010050a:	e8 cf fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f010050f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100514:	e8 c5 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100519:	b8 20 00 00 00       	mov    $0x20,%eax
f010051e:	e8 bb fe ff ff       	call   f01003de <cons_putc>
f0100523:	eb 1e                	jmp    f0100543 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100525:	0f b7 05 28 f2 22 f0 	movzwl 0xf022f228,%eax
f010052c:	8d 50 01             	lea    0x1(%eax),%edx
f010052f:	66 89 15 28 f2 22 f0 	mov    %dx,0xf022f228
f0100536:	0f b7 c0             	movzwl %ax,%eax
f0100539:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f010053f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100543:	66 81 3d 28 f2 22 f0 	cmpw   $0x7cf,0xf022f228
f010054a:	cf 07 
f010054c:	76 43                	jbe    f0100591 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054e:	a1 2c f2 22 f0       	mov    0xf022f22c,%eax
f0100553:	83 ec 04             	sub    $0x4,%esp
f0100556:	68 00 0f 00 00       	push   $0xf00
f010055b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100561:	52                   	push   %edx
f0100562:	50                   	push   %eax
f0100563:	e8 3e 50 00 00       	call   f01055a6 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100568:	8b 15 2c f2 22 f0    	mov    0xf022f22c,%edx
f010056e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100574:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010057a:	83 c4 10             	add    $0x10,%esp
f010057d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100582:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100585:	39 d0                	cmp    %edx,%eax
f0100587:	75 f4                	jne    f010057d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100589:	66 83 2d 28 f2 22 f0 	subw   $0x50,0xf022f228
f0100590:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100591:	8b 0d 30 f2 22 f0    	mov    0xf022f230,%ecx
f0100597:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059c:	89 ca                	mov    %ecx,%edx
f010059e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059f:	0f b7 1d 28 f2 22 f0 	movzwl 0xf022f228,%ebx
f01005a6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a9:	89 d8                	mov    %ebx,%eax
f01005ab:	66 c1 e8 08          	shr    $0x8,%ax
f01005af:	89 f2                	mov    %esi,%edx
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b7:	89 ca                	mov    %ecx,%edx
f01005b9:	ee                   	out    %al,(%dx)
f01005ba:	89 d8                	mov    %ebx,%eax
f01005bc:	89 f2                	mov    %esi,%edx
f01005be:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c2:	5b                   	pop    %ebx
f01005c3:	5e                   	pop    %esi
f01005c4:	5f                   	pop    %edi
f01005c5:	5d                   	pop    %ebp
f01005c6:	c3                   	ret    

f01005c7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005c7:	80 3d 34 f2 22 f0 00 	cmpb   $0x0,0xf022f234
f01005ce:	74 11                	je     f01005e1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d0:	55                   	push   %ebp
f01005d1:	89 e5                	mov    %esp,%ebp
f01005d3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005d6:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005db:	e8 a2 fc ff ff       	call   f0100282 <cons_intr>
}
f01005e0:	c9                   	leave  
f01005e1:	f3 c3                	repz ret 

f01005e3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e3:	55                   	push   %ebp
f01005e4:	89 e5                	mov    %esp,%ebp
f01005e6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e9:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005ee:	e8 8f fc ff ff       	call   f0100282 <cons_intr>
}
f01005f3:	c9                   	leave  
f01005f4:	c3                   	ret    

f01005f5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005fb:	e8 c7 ff ff ff       	call   f01005c7 <serial_intr>
	kbd_intr();
f0100600:	e8 de ff ff ff       	call   f01005e3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100605:	a1 20 f2 22 f0       	mov    0xf022f220,%eax
f010060a:	3b 05 24 f2 22 f0    	cmp    0xf022f224,%eax
f0100610:	74 26                	je     f0100638 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100612:	8d 50 01             	lea    0x1(%eax),%edx
f0100615:	89 15 20 f2 22 f0    	mov    %edx,0xf022f220
f010061b:	0f b6 88 20 f0 22 f0 	movzbl -0xfdd0fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100622:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100624:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010062a:	75 11                	jne    f010063d <cons_getc+0x48>
			cons.rpos = 0;
f010062c:	c7 05 20 f2 22 f0 00 	movl   $0x0,0xf022f220
f0100633:	00 00 00 
f0100636:	eb 05                	jmp    f010063d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100638:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010063d:	c9                   	leave  
f010063e:	c3                   	ret    

f010063f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010063f:	55                   	push   %ebp
f0100640:	89 e5                	mov    %esp,%ebp
f0100642:	57                   	push   %edi
f0100643:	56                   	push   %esi
f0100644:	53                   	push   %ebx
f0100645:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100648:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100656:	5a a5 
	if (*cp != 0xA55A) {
f0100658:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100663:	74 11                	je     f0100676 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100665:	c7 05 30 f2 22 f0 b4 	movl   $0x3b4,0xf022f230
f010066c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100674:	eb 16                	jmp    f010068c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100676:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010067d:	c7 05 30 f2 22 f0 d4 	movl   $0x3d4,0xf022f230
f0100684:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100687:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010068c:	8b 3d 30 f2 22 f0    	mov    0xf022f230,%edi
f0100692:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100697:	89 fa                	mov    %edi,%edx
f0100699:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069a:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069d:	89 da                	mov    %ebx,%edx
f010069f:	ec                   	in     (%dx),%al
f01006a0:	0f b6 c8             	movzbl %al,%ecx
f01006a3:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ae:	89 da                	mov    %ebx,%edx
f01006b0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b1:	89 35 2c f2 22 f0    	mov    %esi,0xf022f22c
	crt_pos = pos;
f01006b7:	0f b6 c0             	movzbl %al,%eax
f01006ba:	09 c8                	or     %ecx,%eax
f01006bc:	66 a3 28 f2 22 f0    	mov    %ax,0xf022f228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c2:	e8 1c ff ff ff       	call   f01005e3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c7:	83 ec 0c             	sub    $0xc,%esp
f01006ca:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f01006d1:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d6:	50                   	push   %eax
f01006d7:	e8 36 30 00 00       	call   f0103712 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006dc:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e6:	89 f2                	mov    %esi,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006ee:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f3:	ee                   	out    %al,(%dx)
f01006f4:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100706:	b8 00 00 00 00       	mov    $0x0,%eax
f010070b:	ee                   	out    %al,(%dx)
f010070c:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100711:	b8 03 00 00 00       	mov    $0x3,%eax
f0100716:	ee                   	out    %al,(%dx)
f0100717:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010071c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100721:	ee                   	out    %al,(%dx)
f0100722:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100727:	b8 01 00 00 00       	mov    $0x1,%eax
f010072c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100732:	ec                   	in     (%dx),%al
f0100733:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100735:	83 c4 10             	add    $0x10,%esp
f0100738:	3c ff                	cmp    $0xff,%al
f010073a:	0f 95 05 34 f2 22 f0 	setne  0xf022f234
f0100741:	89 f2                	mov    %esi,%edx
f0100743:	ec                   	in     (%dx),%al
f0100744:	89 da                	mov    %ebx,%edx
f0100746:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100747:	80 f9 ff             	cmp    $0xff,%cl
f010074a:	75 10                	jne    f010075c <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010074c:	83 ec 0c             	sub    $0xc,%esp
f010074f:	68 ef 62 10 f0       	push   $0xf01062ef
f0100754:	e8 0a 31 00 00       	call   f0103863 <cprintf>
f0100759:	83 c4 10             	add    $0x10,%esp
}
f010075c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010075f:	5b                   	pop    %ebx
f0100760:	5e                   	pop    %esi
f0100761:	5f                   	pop    %edi
f0100762:	5d                   	pop    %ebp
f0100763:	c3                   	ret    

f0100764 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100764:	55                   	push   %ebp
f0100765:	89 e5                	mov    %esp,%ebp
f0100767:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076a:	8b 45 08             	mov    0x8(%ebp),%eax
f010076d:	e8 6c fc ff ff       	call   f01003de <cons_putc>
}
f0100772:	c9                   	leave  
f0100773:	c3                   	ret    

f0100774 <getchar>:

int
getchar(void)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077a:	e8 76 fe ff ff       	call   f01005f5 <cons_getc>
f010077f:	85 c0                	test   %eax,%eax
f0100781:	74 f7                	je     f010077a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100783:	c9                   	leave  
f0100784:	c3                   	ret    

f0100785 <iscons>:

int
iscons(int fdnum)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100788:	b8 01 00 00 00       	mov    $0x1,%eax
f010078d:	5d                   	pop    %ebp
f010078e:	c3                   	ret    

f010078f <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010078f:	55                   	push   %ebp
f0100790:	89 e5                	mov    %esp,%ebp
f0100792:	56                   	push   %esi
f0100793:	53                   	push   %ebx
f0100794:	bb c0 68 10 f0       	mov    $0xf01068c0,%ebx
f0100799:	be f0 68 10 f0       	mov    $0xf01068f0,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079e:	83 ec 04             	sub    $0x4,%esp
f01007a1:	ff 73 04             	pushl  0x4(%ebx)
f01007a4:	ff 33                	pushl  (%ebx)
f01007a6:	68 40 65 10 f0       	push   $0xf0106540
f01007ab:	e8 b3 30 00 00       	call   f0103863 <cprintf>
f01007b0:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01007b3:	83 c4 10             	add    $0x10,%esp
f01007b6:	39 f3                	cmp    %esi,%ebx
f01007b8:	75 e4                	jne    f010079e <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01007ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007c2:	5b                   	pop    %ebx
f01007c3:	5e                   	pop    %esi
f01007c4:	5d                   	pop    %ebp
f01007c5:	c3                   	ret    

f01007c6 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c6:	55                   	push   %ebp
f01007c7:	89 e5                	mov    %esp,%ebp
f01007c9:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007cc:	68 49 65 10 f0       	push   $0xf0106549
f01007d1:	e8 8d 30 00 00       	call   f0103863 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d6:	83 c4 08             	add    $0x8,%esp
f01007d9:	68 0c 00 10 00       	push   $0x10000c
f01007de:	68 7c 66 10 f0       	push   $0xf010667c
f01007e3:	e8 7b 30 00 00       	call   f0103863 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e8:	83 c4 0c             	add    $0xc,%esp
f01007eb:	68 0c 00 10 00       	push   $0x10000c
f01007f0:	68 0c 00 10 f0       	push   $0xf010000c
f01007f5:	68 a4 66 10 f0       	push   $0xf01066a4
f01007fa:	e8 64 30 00 00       	call   f0103863 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007ff:	83 c4 0c             	add    $0xc,%esp
f0100802:	68 01 62 10 00       	push   $0x106201
f0100807:	68 01 62 10 f0       	push   $0xf0106201
f010080c:	68 c8 66 10 f0       	push   $0xf01066c8
f0100811:	e8 4d 30 00 00       	call   f0103863 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100816:	83 c4 0c             	add    $0xc,%esp
f0100819:	68 10 e9 22 00       	push   $0x22e910
f010081e:	68 10 e9 22 f0       	push   $0xf022e910
f0100823:	68 ec 66 10 f0       	push   $0xf01066ec
f0100828:	e8 36 30 00 00       	call   f0103863 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082d:	83 c4 0c             	add    $0xc,%esp
f0100830:	68 08 10 27 00       	push   $0x271008
f0100835:	68 08 10 27 f0       	push   $0xf0271008
f010083a:	68 10 67 10 f0       	push   $0xf0106710
f010083f:	e8 1f 30 00 00       	call   f0103863 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100844:	b8 07 14 27 f0       	mov    $0xf0271407,%eax
f0100849:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084e:	83 c4 08             	add    $0x8,%esp
f0100851:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100856:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010085c:	85 c0                	test   %eax,%eax
f010085e:	0f 48 c2             	cmovs  %edx,%eax
f0100861:	c1 f8 0a             	sar    $0xa,%eax
f0100864:	50                   	push   %eax
f0100865:	68 34 67 10 f0       	push   $0xf0106734
f010086a:	e8 f4 2f 00 00       	call   f0103863 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010086f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100874:	c9                   	leave  
f0100875:	c3                   	ret    

f0100876 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100876:	55                   	push   %ebp
f0100877:	89 e5                	mov    %esp,%ebp
f0100879:	57                   	push   %edi
f010087a:	56                   	push   %esi
f010087b:	53                   	push   %ebx
f010087c:	83 ec 2c             	sub    $0x2c,%esp
	// Your code here.
	int x = 1, y = 3, z = 4;
	cprintf("x %d, y %x, z %d\n", x, y, z);
f010087f:	6a 04                	push   $0x4
f0100881:	6a 03                	push   $0x3
f0100883:	6a 01                	push   $0x1
f0100885:	68 62 65 10 f0       	push   $0xf0106562
f010088a:	e8 d4 2f 00 00       	call   f0103863 <cprintf>
	unsigned int i = 0x00646c72;
f010088f:	c7 45 e4 72 6c 64 00 	movl   $0x646c72,-0x1c(%ebp)
	cprintf("H%x Wo%s\n", 57616, &i);
f0100896:	83 c4 0c             	add    $0xc,%esp
f0100899:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010089c:	50                   	push   %eax
f010089d:	68 10 e1 00 00       	push   $0xe110
f01008a2:	68 74 65 10 f0       	push   $0xf0106574
f01008a7:	e8 b7 2f 00 00       	call   f0103863 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ac:	89 eb                	mov    %ebp,%ebx
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
f01008ae:	c7 04 24 7e 65 10 f0 	movl   $0xf010657e,(%esp)
f01008b5:	e8 a9 2f 00 00       	call   f0103863 <cprintf>
	while (ebp != 0) {
f01008ba:	83 c4 10             	add    $0x10,%esp
		
		cprintf("\tebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		/* for the question of lab3 exercise 9
		cprintf("\tebp %x  eip %x  args %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3]);
		*/
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008bd:	8d 7d cc             	lea    -0x34(%ebp),%edi
	cprintf("H%x Wo%s\n", 57616, &i);
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
f01008c0:	eb 57                	jmp    f0100919 <mon_backtrace+0xa3>
		ptr_ebp = (uint32_t *)ebp;
f01008c2:	89 de                	mov    %ebx,%esi
		
		cprintf("\tebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
f01008c4:	ff 73 18             	pushl  0x18(%ebx)
f01008c7:	ff 73 14             	pushl  0x14(%ebx)
f01008ca:	ff 73 10             	pushl  0x10(%ebx)
f01008cd:	ff 73 0c             	pushl  0xc(%ebx)
f01008d0:	ff 73 08             	pushl  0x8(%ebx)
f01008d3:	ff 73 04             	pushl  0x4(%ebx)
f01008d6:	53                   	push   %ebx
f01008d7:	68 60 67 10 f0       	push   $0xf0106760
f01008dc:	e8 82 2f 00 00       	call   f0103863 <cprintf>
		/* for the question of lab3 exercise 9
		cprintf("\tebp %x  eip %x  args %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3]);
		*/
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
f01008e1:	83 c4 18             	add    $0x18,%esp
f01008e4:	57                   	push   %edi
f01008e5:	ff 73 04             	pushl  0x4(%ebx)
f01008e8:	e8 fa 41 00 00       	call   f0104ae7 <debuginfo_eip>
f01008ed:	83 c4 10             	add    $0x10,%esp
f01008f0:	85 c0                	test   %eax,%eax
f01008f2:	75 23                	jne    f0100917 <mon_backtrace+0xa1>
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr;
			cprintf("\t\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line,info.eip_fn_namelen,  info.eip_fn_name, fn_offset);
f01008f4:	83 ec 08             	sub    $0x8,%esp
f01008f7:	8b 43 04             	mov    0x4(%ebx),%eax
f01008fa:	2b 45 dc             	sub    -0x24(%ebp),%eax
f01008fd:	50                   	push   %eax
f01008fe:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100901:	ff 75 d8             	pushl  -0x28(%ebp)
f0100904:	ff 75 d0             	pushl  -0x30(%ebp)
f0100907:	ff 75 cc             	pushl  -0x34(%ebp)
f010090a:	68 90 65 10 f0       	push   $0xf0106590
f010090f:	e8 4f 2f 00 00       	call   f0103863 <cprintf>
f0100914:	83 c4 20             	add    $0x20,%esp
		}
		ebp = *ptr_ebp;
f0100917:	8b 1e                	mov    (%esi),%ebx
	cprintf("H%x Wo%s\n", 57616, &i);
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
f0100919:	85 db                	test   %ebx,%ebx
f010091b:	75 a5                	jne    f01008c2 <mon_backtrace+0x4c>
			cprintf("\t\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line,info.eip_fn_namelen,  info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
	}
	return 0;
}
f010091d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100922:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100925:	5b                   	pop    %ebx
f0100926:	5e                   	pop    %esi
f0100927:	5f                   	pop    %edi
f0100928:	5d                   	pop    %ebp
f0100929:	c3                   	ret    

f010092a <mon_showmappings>:

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f010092a:	55                   	push   %ebp
f010092b:	89 e5                	mov    %esp,%ebp
f010092d:	57                   	push   %edi
f010092e:	56                   	push   %esi
f010092f:	53                   	push   %ebx
f0100930:	83 ec 1c             	sub    $0x1c,%esp
f0100933:	8b 75 0c             	mov    0xc(%ebp),%esi
	// check args
	if (argc != 3) {
f0100936:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f010093a:	74 1a                	je     f0100956 <mon_showmappings+0x2c>
		cprintf("Requir 2 virtual address as arguments.\n");
f010093c:	83 ec 0c             	sub    $0xc,%esp
f010093f:	68 90 67 10 f0       	push   $0xf0106790
f0100944:	e8 1a 2f 00 00       	call   f0103863 <cprintf>
		return -1;
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100951:	e9 52 01 00 00       	jmp    f0100aa8 <mon_showmappings+0x17e>
	}
	char *errChar;
	uintptr_t start_addr = strtol(argv[1], &errChar, 16);
f0100956:	83 ec 04             	sub    $0x4,%esp
f0100959:	6a 10                	push   $0x10
f010095b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010095e:	50                   	push   %eax
f010095f:	ff 76 04             	pushl  0x4(%esi)
f0100962:	e8 16 4d 00 00       	call   f010567d <strtol>
f0100967:	89 c3                	mov    %eax,%ebx
	if (*errChar) {
f0100969:	83 c4 10             	add    $0x10,%esp
f010096c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010096f:	80 38 00             	cmpb   $0x0,(%eax)
f0100972:	74 1d                	je     f0100991 <mon_showmappings+0x67>
		cprintf("Invalid virtual address: %s.\n", argv[1]);
f0100974:	83 ec 08             	sub    $0x8,%esp
f0100977:	ff 76 04             	pushl  0x4(%esi)
f010097a:	68 a2 65 10 f0       	push   $0xf01065a2
f010097f:	e8 df 2e 00 00       	call   f0103863 <cprintf>
		return -1;
f0100984:	83 c4 10             	add    $0x10,%esp
f0100987:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010098c:	e9 17 01 00 00       	jmp    f0100aa8 <mon_showmappings+0x17e>
	}
	uintptr_t end_addr = strtol(argv[2], &errChar, 16);
f0100991:	83 ec 04             	sub    $0x4,%esp
f0100994:	6a 10                	push   $0x10
f0100996:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100999:	50                   	push   %eax
f010099a:	ff 76 08             	pushl  0x8(%esi)
f010099d:	e8 db 4c 00 00       	call   f010567d <strtol>
	if (*errChar) {
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01009a8:	80 3a 00             	cmpb   $0x0,(%edx)
f01009ab:	74 1d                	je     f01009ca <mon_showmappings+0xa0>
		cprintf("Invalid virtual address: %s.\n", argv[2]);
f01009ad:	83 ec 08             	sub    $0x8,%esp
f01009b0:	ff 76 08             	pushl  0x8(%esi)
f01009b3:	68 a2 65 10 f0       	push   $0xf01065a2
f01009b8:	e8 a6 2e 00 00       	call   f0103863 <cprintf>
		return -1;
f01009bd:	83 c4 10             	add    $0x10,%esp
f01009c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009c5:	e9 de 00 00 00       	jmp    f0100aa8 <mon_showmappings+0x17e>
	}
	if (start_addr > end_addr) {
f01009ca:	39 c3                	cmp    %eax,%ebx
f01009cc:	76 1a                	jbe    f01009e8 <mon_showmappings+0xbe>
		cprintf("Address 1 must be lower than address 2\n");
f01009ce:	83 ec 0c             	sub    $0xc,%esp
f01009d1:	68 b8 67 10 f0       	push   $0xf01067b8
f01009d6:	e8 88 2e 00 00       	call   f0103863 <cprintf>
		return -1;
f01009db:	83 c4 10             	add    $0x10,%esp
f01009de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01009e3:	e9 c0 00 00 00       	jmp    f0100aa8 <mon_showmappings+0x17e>
	}
	
	// 
	start_addr = ROUNDDOWN(start_addr, PGSIZE);
f01009e8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end_addr = ROUNDUP(end_addr, PGSIZE);
f01009ee:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01009f4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
f01009fa:	e9 9c 00 00 00       	jmp    f0100a9b <mon_showmappings+0x171>
		pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
f01009ff:	83 ec 04             	sub    $0x4,%esp
f0100a02:	6a 00                	push   $0x0
f0100a04:	53                   	push   %ebx
f0100a05:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0100a0b:	e8 b6 07 00 00       	call   f01011c6 <pgdir_walk>
f0100a10:	89 c6                	mov    %eax,%esi
		if ( !cur_pte || !(*cur_pte & PTE_P)) {
f0100a12:	83 c4 10             	add    $0x10,%esp
f0100a15:	85 c0                	test   %eax,%eax
f0100a17:	74 06                	je     f0100a1f <mon_showmappings+0xf5>
f0100a19:	8b 00                	mov    (%eax),%eax
f0100a1b:	a8 01                	test   $0x1,%al
f0100a1d:	75 13                	jne    f0100a32 <mon_showmappings+0x108>
			cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
f0100a1f:	83 ec 08             	sub    $0x8,%esp
f0100a22:	53                   	push   %ebx
f0100a23:	68 e0 67 10 f0       	push   $0xf01067e0
f0100a28:	e8 36 2e 00 00       	call   f0103863 <cprintf>
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	eb 63                	jmp    f0100a95 <mon_showmappings+0x16b>
		} else {
			cprintf( "Virtual address [%08x] - physical address [%08x], permission: ", cur_addr, PTE_ADDR(*cur_pte));
f0100a32:	83 ec 04             	sub    $0x4,%esp
f0100a35:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a3a:	50                   	push   %eax
f0100a3b:	53                   	push   %ebx
f0100a3c:	68 08 68 10 f0       	push   $0xf0106808
f0100a41:	e8 1d 2e 00 00       	call   f0103863 <cprintf>
			char perm_PS = (*cur_pte & PTE_PS) ? 'S':'-';
f0100a46:	8b 06                	mov    (%esi),%eax
f0100a48:	83 c4 10             	add    $0x10,%esp
f0100a4b:	89 c2                	mov    %eax,%edx
f0100a4d:	81 e2 80 00 00 00    	and    $0x80,%edx
f0100a53:	83 fa 01             	cmp    $0x1,%edx
f0100a56:	19 d2                	sbb    %edx,%edx
f0100a58:	83 e2 da             	and    $0xffffffda,%edx
f0100a5b:	83 c2 53             	add    $0x53,%edx
			char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
f0100a5e:	89 c1                	mov    %eax,%ecx
f0100a60:	83 e1 02             	and    $0x2,%ecx
f0100a63:	83 f9 01             	cmp    $0x1,%ecx
f0100a66:	19 c9                	sbb    %ecx,%ecx
f0100a68:	83 e1 d6             	and    $0xffffffd6,%ecx
f0100a6b:	83 c1 57             	add    $0x57,%ecx
			char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
f0100a6e:	83 e0 04             	and    $0x4,%eax
f0100a71:	83 f8 01             	cmp    $0x1,%eax
f0100a74:	19 c0                	sbb    %eax,%eax
f0100a76:	83 e0 d8             	and    $0xffffffd8,%eax
f0100a79:	83 c0 55             	add    $0x55,%eax
			cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
f0100a7c:	0f be c9             	movsbl %cl,%ecx
f0100a7f:	51                   	push   %ecx
f0100a80:	0f be c0             	movsbl %al,%eax
f0100a83:	50                   	push   %eax
f0100a84:	0f be d2             	movsbl %dl,%edx
f0100a87:	52                   	push   %edx
f0100a88:	68 c0 65 10 f0       	push   $0xf01065c0
f0100a8d:	e8 d1 2d 00 00       	call   f0103863 <cprintf>
f0100a92:	83 c4 10             	add    $0x10,%esp
		}
		cur_addr += PGSIZE;
f0100a95:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	
	// 
	start_addr = ROUNDDOWN(start_addr, PGSIZE);
	end_addr = ROUNDUP(end_addr, PGSIZE);
	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
f0100a9b:	39 fb                	cmp    %edi,%ebx
f0100a9d:	0f 86 5c ff ff ff    	jbe    f01009ff <mon_showmappings+0xd5>
			char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
			cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
		}
		cur_addr += PGSIZE;
	}
	return 0;
f0100aa3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aab:	5b                   	pop    %ebx
f0100aac:	5e                   	pop    %esi
f0100aad:	5f                   	pop    %edi
f0100aae:	5d                   	pop    %ebp
f0100aaf:	c3                   	ret    

f0100ab0 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ab0:	55                   	push   %ebp
f0100ab1:	89 e5                	mov    %esp,%ebp
f0100ab3:	57                   	push   %edi
f0100ab4:	56                   	push   %esi
f0100ab5:	53                   	push   %ebx
f0100ab6:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100ab9:	68 48 68 10 f0       	push   $0xf0106848
f0100abe:	e8 a0 2d 00 00       	call   f0103863 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ac3:	c7 04 24 6c 68 10 f0 	movl   $0xf010686c,(%esp)
f0100aca:	e8 94 2d 00 00       	call   f0103863 <cprintf>

	if (tf != NULL)
f0100acf:	83 c4 10             	add    $0x10,%esp
f0100ad2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100ad6:	74 0e                	je     f0100ae6 <monitor+0x36>
		print_trapframe(tf);
f0100ad8:	83 ec 0c             	sub    $0xc,%esp
f0100adb:	ff 75 08             	pushl  0x8(%ebp)
f0100ade:	e8 2c 33 00 00       	call   f0103e0f <print_trapframe>
f0100ae3:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100ae6:	83 ec 0c             	sub    $0xc,%esp
f0100ae9:	68 ce 65 10 f0       	push   $0xf01065ce
f0100aee:	e8 0f 48 00 00       	call   f0105302 <readline>
f0100af3:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100af5:	83 c4 10             	add    $0x10,%esp
f0100af8:	85 c0                	test   %eax,%eax
f0100afa:	74 ea                	je     f0100ae6 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100afc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100b03:	be 00 00 00 00       	mov    $0x0,%esi
f0100b08:	eb 0a                	jmp    f0100b14 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b0a:	c6 03 00             	movb   $0x0,(%ebx)
f0100b0d:	89 f7                	mov    %esi,%edi
f0100b0f:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100b12:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b14:	0f b6 03             	movzbl (%ebx),%eax
f0100b17:	84 c0                	test   %al,%al
f0100b19:	74 63                	je     f0100b7e <monitor+0xce>
f0100b1b:	83 ec 08             	sub    $0x8,%esp
f0100b1e:	0f be c0             	movsbl %al,%eax
f0100b21:	50                   	push   %eax
f0100b22:	68 d2 65 10 f0       	push   $0xf01065d2
f0100b27:	e8 f0 49 00 00       	call   f010551c <strchr>
f0100b2c:	83 c4 10             	add    $0x10,%esp
f0100b2f:	85 c0                	test   %eax,%eax
f0100b31:	75 d7                	jne    f0100b0a <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100b33:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b36:	74 46                	je     f0100b7e <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b38:	83 fe 0f             	cmp    $0xf,%esi
f0100b3b:	75 14                	jne    f0100b51 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b3d:	83 ec 08             	sub    $0x8,%esp
f0100b40:	6a 10                	push   $0x10
f0100b42:	68 d7 65 10 f0       	push   $0xf01065d7
f0100b47:	e8 17 2d 00 00       	call   f0103863 <cprintf>
f0100b4c:	83 c4 10             	add    $0x10,%esp
f0100b4f:	eb 95                	jmp    f0100ae6 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100b51:	8d 7e 01             	lea    0x1(%esi),%edi
f0100b54:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100b58:	eb 03                	jmp    f0100b5d <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100b5a:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100b5d:	0f b6 03             	movzbl (%ebx),%eax
f0100b60:	84 c0                	test   %al,%al
f0100b62:	74 ae                	je     f0100b12 <monitor+0x62>
f0100b64:	83 ec 08             	sub    $0x8,%esp
f0100b67:	0f be c0             	movsbl %al,%eax
f0100b6a:	50                   	push   %eax
f0100b6b:	68 d2 65 10 f0       	push   $0xf01065d2
f0100b70:	e8 a7 49 00 00       	call   f010551c <strchr>
f0100b75:	83 c4 10             	add    $0x10,%esp
f0100b78:	85 c0                	test   %eax,%eax
f0100b7a:	74 de                	je     f0100b5a <monitor+0xaa>
f0100b7c:	eb 94                	jmp    f0100b12 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100b7e:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100b85:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100b86:	85 f6                	test   %esi,%esi
f0100b88:	0f 84 58 ff ff ff    	je     f0100ae6 <monitor+0x36>
f0100b8e:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100b93:	83 ec 08             	sub    $0x8,%esp
f0100b96:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b99:	ff 34 85 c0 68 10 f0 	pushl  -0xfef9740(,%eax,4)
f0100ba0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ba3:	e8 16 49 00 00       	call   f01054be <strcmp>
f0100ba8:	83 c4 10             	add    $0x10,%esp
f0100bab:	85 c0                	test   %eax,%eax
f0100bad:	75 21                	jne    f0100bd0 <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100baf:	83 ec 04             	sub    $0x4,%esp
f0100bb2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100bb5:	ff 75 08             	pushl  0x8(%ebp)
f0100bb8:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100bbb:	52                   	push   %edx
f0100bbc:	56                   	push   %esi
f0100bbd:	ff 14 85 c8 68 10 f0 	call   *-0xfef9738(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100bc4:	83 c4 10             	add    $0x10,%esp
f0100bc7:	85 c0                	test   %eax,%eax
f0100bc9:	78 25                	js     f0100bf0 <monitor+0x140>
f0100bcb:	e9 16 ff ff ff       	jmp    f0100ae6 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100bd0:	83 c3 01             	add    $0x1,%ebx
f0100bd3:	83 fb 04             	cmp    $0x4,%ebx
f0100bd6:	75 bb                	jne    f0100b93 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100bd8:	83 ec 08             	sub    $0x8,%esp
f0100bdb:	ff 75 a8             	pushl  -0x58(%ebp)
f0100bde:	68 f4 65 10 f0       	push   $0xf01065f4
f0100be3:	e8 7b 2c 00 00       	call   f0103863 <cprintf>
f0100be8:	83 c4 10             	add    $0x10,%esp
f0100beb:	e9 f6 fe ff ff       	jmp    f0100ae6 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bf3:	5b                   	pop    %ebx
f0100bf4:	5e                   	pop    %esi
f0100bf5:	5f                   	pop    %edi
f0100bf6:	5d                   	pop    %ebp
f0100bf7:	c3                   	ret    

f0100bf8 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100bf8:	55                   	push   %ebp
f0100bf9:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100bfb:	83 3d 38 f2 22 f0 00 	cmpl   $0x0,0xf022f238
f0100c02:	75 11                	jne    f0100c15 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c04:	ba 07 20 27 f0       	mov    $0xf0272007,%edx
f0100c09:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c0f:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if (n == 0) {
f0100c15:	85 c0                	test   %eax,%eax
f0100c17:	75 07                	jne    f0100c20 <boot_alloc+0x28>
		return nextfree;
f0100c19:	a1 38 f2 22 f0       	mov    0xf022f238,%eax
f0100c1e:	eb 1c                	jmp    f0100c3c <boot_alloc+0x44>
	}
	result = nextfree;
f0100c20:	8b 0d 38 f2 22 f0    	mov    0xf022f238,%ecx
	nextfree += ROUNDUP(n, PGSIZE);
f0100c26:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100c2c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100c32:	01 ca                	add    %ecx,%edx
f0100c34:	89 15 38 f2 22 f0    	mov    %edx,0xf022f238
	return result;
f0100c3a:	89 c8                	mov    %ecx,%eax
}
f0100c3c:	5d                   	pop    %ebp
f0100c3d:	c3                   	ret    

f0100c3e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100c3e:	55                   	push   %ebp
f0100c3f:	89 e5                	mov    %esp,%ebp
f0100c41:	56                   	push   %esi
f0100c42:	53                   	push   %ebx
f0100c43:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c45:	83 ec 0c             	sub    $0xc,%esp
f0100c48:	50                   	push   %eax
f0100c49:	e8 96 2a 00 00       	call   f01036e4 <mc146818_read>
f0100c4e:	89 c6                	mov    %eax,%esi
f0100c50:	83 c3 01             	add    $0x1,%ebx
f0100c53:	89 1c 24             	mov    %ebx,(%esp)
f0100c56:	e8 89 2a 00 00       	call   f01036e4 <mc146818_read>
f0100c5b:	c1 e0 08             	shl    $0x8,%eax
f0100c5e:	09 f0                	or     %esi,%eax
}
f0100c60:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c63:	5b                   	pop    %ebx
f0100c64:	5e                   	pop    %esi
f0100c65:	5d                   	pop    %ebp
f0100c66:	c3                   	ret    

f0100c67 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100c67:	89 d1                	mov    %edx,%ecx
f0100c69:	c1 e9 16             	shr    $0x16,%ecx
f0100c6c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100c6f:	a8 01                	test   $0x1,%al
f0100c71:	74 52                	je     f0100cc5 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100c73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c78:	89 c1                	mov    %eax,%ecx
f0100c7a:	c1 e9 0c             	shr    $0xc,%ecx
f0100c7d:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0100c83:	72 1b                	jb     f0100ca0 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100c85:	55                   	push   %ebp
f0100c86:	89 e5                	mov    %esp,%ebp
f0100c88:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c8b:	50                   	push   %eax
f0100c8c:	68 44 62 10 f0       	push   $0xf0106244
f0100c91:	68 a8 03 00 00       	push   $0x3a8
f0100c96:	68 81 72 10 f0       	push   $0xf0107281
f0100c9b:	e8 a0 f3 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100ca0:	c1 ea 0c             	shr    $0xc,%edx
f0100ca3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ca9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100cb0:	89 c2                	mov    %eax,%edx
f0100cb2:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100cb5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cba:	85 d2                	test   %edx,%edx
f0100cbc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100cc1:	0f 44 c2             	cmove  %edx,%eax
f0100cc4:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100cca:	c3                   	ret    

f0100ccb <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ccb:	55                   	push   %ebp
f0100ccc:	89 e5                	mov    %esp,%ebp
f0100cce:	57                   	push   %edi
f0100ccf:	56                   	push   %esi
f0100cd0:	53                   	push   %ebx
f0100cd1:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100cd4:	84 c0                	test   %al,%al
f0100cd6:	0f 85 a0 02 00 00    	jne    f0100f7c <check_page_free_list+0x2b1>
f0100cdc:	e9 ad 02 00 00       	jmp    f0100f8e <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100ce1:	83 ec 04             	sub    $0x4,%esp
f0100ce4:	68 f0 68 10 f0       	push   $0xf01068f0
f0100ce9:	68 db 02 00 00       	push   $0x2db
f0100cee:	68 81 72 10 f0       	push   $0xf0107281
f0100cf3:	e8 48 f3 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100cf8:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100cfb:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100cfe:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d01:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100d04:	89 c2                	mov    %eax,%edx
f0100d06:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0100d0c:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100d12:	0f 95 c2             	setne  %dl
f0100d15:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100d18:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100d1c:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100d1e:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d22:	8b 00                	mov    (%eax),%eax
f0100d24:	85 c0                	test   %eax,%eax
f0100d26:	75 dc                	jne    f0100d04 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100d28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d2b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d34:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100d37:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100d39:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100d3c:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d41:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d46:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100d4c:	eb 53                	jmp    f0100da1 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d4e:	89 d8                	mov    %ebx,%eax
f0100d50:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0100d56:	c1 f8 03             	sar    $0x3,%eax
f0100d59:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100d5c:	89 c2                	mov    %eax,%edx
f0100d5e:	c1 ea 16             	shr    $0x16,%edx
f0100d61:	39 f2                	cmp    %esi,%edx
f0100d63:	73 3a                	jae    f0100d9f <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d65:	89 c2                	mov    %eax,%edx
f0100d67:	c1 ea 0c             	shr    $0xc,%edx
f0100d6a:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0100d70:	72 12                	jb     f0100d84 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d72:	50                   	push   %eax
f0100d73:	68 44 62 10 f0       	push   $0xf0106244
f0100d78:	6a 58                	push   $0x58
f0100d7a:	68 8d 72 10 f0       	push   $0xf010728d
f0100d7f:	e8 bc f2 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100d84:	83 ec 04             	sub    $0x4,%esp
f0100d87:	68 80 00 00 00       	push   $0x80
f0100d8c:	68 97 00 00 00       	push   $0x97
f0100d91:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d96:	50                   	push   %eax
f0100d97:	e8 bd 47 00 00       	call   f0105559 <memset>
f0100d9c:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100d9f:	8b 1b                	mov    (%ebx),%ebx
f0100da1:	85 db                	test   %ebx,%ebx
f0100da3:	75 a9                	jne    f0100d4e <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100da5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100daa:	e8 49 fe ff ff       	call   f0100bf8 <boot_alloc>
f0100daf:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100db2:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100db8:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
		assert(pp < pages + npages);
f0100dbe:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0100dc3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100dc6:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100dc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100dcc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100dcf:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100dd4:	e9 52 01 00 00       	jmp    f0100f2b <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100dd9:	39 ca                	cmp    %ecx,%edx
f0100ddb:	73 19                	jae    f0100df6 <check_page_free_list+0x12b>
f0100ddd:	68 9b 72 10 f0       	push   $0xf010729b
f0100de2:	68 a7 72 10 f0       	push   $0xf01072a7
f0100de7:	68 f5 02 00 00       	push   $0x2f5
f0100dec:	68 81 72 10 f0       	push   $0xf0107281
f0100df1:	e8 4a f2 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100df6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100df9:	72 19                	jb     f0100e14 <check_page_free_list+0x149>
f0100dfb:	68 bc 72 10 f0       	push   $0xf01072bc
f0100e00:	68 a7 72 10 f0       	push   $0xf01072a7
f0100e05:	68 f6 02 00 00       	push   $0x2f6
f0100e0a:	68 81 72 10 f0       	push   $0xf0107281
f0100e0f:	e8 2c f2 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e14:	89 d0                	mov    %edx,%eax
f0100e16:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100e19:	a8 07                	test   $0x7,%al
f0100e1b:	74 19                	je     f0100e36 <check_page_free_list+0x16b>
f0100e1d:	68 14 69 10 f0       	push   $0xf0106914
f0100e22:	68 a7 72 10 f0       	push   $0xf01072a7
f0100e27:	68 f7 02 00 00       	push   $0x2f7
f0100e2c:	68 81 72 10 f0       	push   $0xf0107281
f0100e31:	e8 0a f2 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e36:	c1 f8 03             	sar    $0x3,%eax
f0100e39:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100e3c:	85 c0                	test   %eax,%eax
f0100e3e:	75 19                	jne    f0100e59 <check_page_free_list+0x18e>
f0100e40:	68 d0 72 10 f0       	push   $0xf01072d0
f0100e45:	68 a7 72 10 f0       	push   $0xf01072a7
f0100e4a:	68 fa 02 00 00       	push   $0x2fa
f0100e4f:	68 81 72 10 f0       	push   $0xf0107281
f0100e54:	e8 e7 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100e59:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100e5e:	75 19                	jne    f0100e79 <check_page_free_list+0x1ae>
f0100e60:	68 e1 72 10 f0       	push   $0xf01072e1
f0100e65:	68 a7 72 10 f0       	push   $0xf01072a7
f0100e6a:	68 fb 02 00 00       	push   $0x2fb
f0100e6f:	68 81 72 10 f0       	push   $0xf0107281
f0100e74:	e8 c7 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100e79:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100e7e:	75 19                	jne    f0100e99 <check_page_free_list+0x1ce>
f0100e80:	68 48 69 10 f0       	push   $0xf0106948
f0100e85:	68 a7 72 10 f0       	push   $0xf01072a7
f0100e8a:	68 fc 02 00 00       	push   $0x2fc
f0100e8f:	68 81 72 10 f0       	push   $0xf0107281
f0100e94:	e8 a7 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100e99:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100e9e:	75 19                	jne    f0100eb9 <check_page_free_list+0x1ee>
f0100ea0:	68 fa 72 10 f0       	push   $0xf01072fa
f0100ea5:	68 a7 72 10 f0       	push   $0xf01072a7
f0100eaa:	68 fd 02 00 00       	push   $0x2fd
f0100eaf:	68 81 72 10 f0       	push   $0xf0107281
f0100eb4:	e8 87 f1 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100eb9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ebe:	0f 86 f1 00 00 00    	jbe    f0100fb5 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ec4:	89 c7                	mov    %eax,%edi
f0100ec6:	c1 ef 0c             	shr    $0xc,%edi
f0100ec9:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100ecc:	77 12                	ja     f0100ee0 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ece:	50                   	push   %eax
f0100ecf:	68 44 62 10 f0       	push   $0xf0106244
f0100ed4:	6a 58                	push   $0x58
f0100ed6:	68 8d 72 10 f0       	push   $0xf010728d
f0100edb:	e8 60 f1 ff ff       	call   f0100040 <_panic>
f0100ee0:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100ee6:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100ee9:	0f 86 b6 00 00 00    	jbe    f0100fa5 <check_page_free_list+0x2da>
f0100eef:	68 6c 69 10 f0       	push   $0xf010696c
f0100ef4:	68 a7 72 10 f0       	push   $0xf01072a7
f0100ef9:	68 fe 02 00 00       	push   $0x2fe
f0100efe:	68 81 72 10 f0       	push   $0xf0107281
f0100f03:	e8 38 f1 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100f08:	68 14 73 10 f0       	push   $0xf0107314
f0100f0d:	68 a7 72 10 f0       	push   $0xf01072a7
f0100f12:	68 00 03 00 00       	push   $0x300
f0100f17:	68 81 72 10 f0       	push   $0xf0107281
f0100f1c:	e8 1f f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100f21:	83 c6 01             	add    $0x1,%esi
f0100f24:	eb 03                	jmp    f0100f29 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100f26:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f29:	8b 12                	mov    (%edx),%edx
f0100f2b:	85 d2                	test   %edx,%edx
f0100f2d:	0f 85 a6 fe ff ff    	jne    f0100dd9 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f33:	85 f6                	test   %esi,%esi
f0100f35:	7f 19                	jg     f0100f50 <check_page_free_list+0x285>
f0100f37:	68 31 73 10 f0       	push   $0xf0107331
f0100f3c:	68 a7 72 10 f0       	push   $0xf01072a7
f0100f41:	68 08 03 00 00       	push   $0x308
f0100f46:	68 81 72 10 f0       	push   $0xf0107281
f0100f4b:	e8 f0 f0 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100f50:	85 db                	test   %ebx,%ebx
f0100f52:	7f 19                	jg     f0100f6d <check_page_free_list+0x2a2>
f0100f54:	68 43 73 10 f0       	push   $0xf0107343
f0100f59:	68 a7 72 10 f0       	push   $0xf01072a7
f0100f5e:	68 09 03 00 00       	push   $0x309
f0100f63:	68 81 72 10 f0       	push   $0xf0107281
f0100f68:	e8 d3 f0 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100f6d:	83 ec 0c             	sub    $0xc,%esp
f0100f70:	68 b4 69 10 f0       	push   $0xf01069b4
f0100f75:	e8 e9 28 00 00       	call   f0103863 <cprintf>
}
f0100f7a:	eb 49                	jmp    f0100fc5 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f7c:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0100f81:	85 c0                	test   %eax,%eax
f0100f83:	0f 85 6f fd ff ff    	jne    f0100cf8 <check_page_free_list+0x2d>
f0100f89:	e9 53 fd ff ff       	jmp    f0100ce1 <check_page_free_list+0x16>
f0100f8e:	83 3d 40 f2 22 f0 00 	cmpl   $0x0,0xf022f240
f0100f95:	0f 84 46 fd ff ff    	je     f0100ce1 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f9b:	be 00 04 00 00       	mov    $0x400,%esi
f0100fa0:	e9 a1 fd ff ff       	jmp    f0100d46 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100fa5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100faa:	0f 85 76 ff ff ff    	jne    f0100f26 <check_page_free_list+0x25b>
f0100fb0:	e9 53 ff ff ff       	jmp    f0100f08 <check_page_free_list+0x23d>
f0100fb5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100fba:	0f 85 61 ff ff ff    	jne    f0100f21 <check_page_free_list+0x256>
f0100fc0:	e9 43 ff ff ff       	jmp    f0100f08 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100fc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fc8:	5b                   	pop    %ebx
f0100fc9:	5e                   	pop    %esi
f0100fca:	5f                   	pop    %edi
f0100fcb:	5d                   	pop    %ebp
f0100fcc:	c3                   	ret    

f0100fcd <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100fcd:	55                   	push   %ebp
f0100fce:	89 e5                	mov    %esp,%ebp
f0100fd0:	56                   	push   %esi
f0100fd1:	53                   	push   %ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	pages[0].pp_ref = 1;
f0100fd2:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0100fd7:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	size_t mp_page = MPENTRY_PADDR/PGSIZE;
	// cprintf("*****mpentry at %08x, mp_page = %d*****\n", MPENTRY_PADDR, mp_page);
	for (i = 1; i < npages_basemem; i++) {
f0100fdd:	8b 35 44 f2 22 f0    	mov    0xf022f244,%esi
f0100fe3:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0100fe9:	ba 00 00 00 00       	mov    $0x0,%edx
f0100fee:	b8 01 00 00 00       	mov    $0x1,%eax
f0100ff3:	eb 3a                	jmp    f010102f <page_init+0x62>
		if (i == mp_page) {
f0100ff5:	83 f8 07             	cmp    $0x7,%eax
f0100ff8:	75 0e                	jne    f0101008 <page_init+0x3b>
			pages[i].pp_ref = 1;
f0100ffa:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
f0101000:	66 c7 41 3c 01 00    	movw   $0x1,0x3c(%ecx)
			continue;
f0101006:	eb 24                	jmp    f010102c <page_init+0x5f>
		}
		pages[i].pp_ref = 0;
f0101008:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010100f:	89 d1                	mov    %edx,%ecx
f0101011:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f0101017:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f010101d:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f010101f:	89 d3                	mov    %edx,%ebx
f0101021:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx
f0101027:	ba 01 00 00 00       	mov    $0x1,%edx
	// free pages!
	size_t i;
	pages[0].pp_ref = 1;
	size_t mp_page = MPENTRY_PADDR/PGSIZE;
	// cprintf("*****mpentry at %08x, mp_page = %d*****\n", MPENTRY_PADDR, mp_page);
	for (i = 1; i < npages_basemem; i++) {
f010102c:	83 c0 01             	add    $0x1,%eax
f010102f:	39 f0                	cmp    %esi,%eax
f0101031:	72 c2                	jb     f0100ff5 <page_init+0x28>
f0101033:	84 d2                	test   %dl,%dl
f0101035:	74 06                	je     f010103d <page_init+0x70>
f0101037:	89 1d 40 f2 22 f0    	mov    %ebx,0xf022f240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
		pages[i].pp_ref = 1;
f010103d:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0101043:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0101049:	81 c2 04 08 00 00    	add    $0x804,%edx
f010104f:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0101054:	83 c0 08             	add    $0x8,%eax
		}
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0101057:	39 d0                	cmp    %edx,%eax
f0101059:	75 f4                	jne    f010104f <page_init+0x82>
		pages[i].pp_ref = 1;
	}
	size_t first_free_address = PADDR(boot_alloc(0));
f010105b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101060:	e8 93 fb ff ff       	call   f0100bf8 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101065:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010106a:	77 15                	ja     f0101081 <page_init+0xb4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010106c:	50                   	push   %eax
f010106d:	68 68 62 10 f0       	push   $0xf0106268
f0101072:	68 4c 01 00 00       	push   $0x14c
f0101077:	68 81 72 10 f0       	push   $0xf0107281
f010107c:	e8 bf ef ff ff       	call   f0100040 <_panic>
	for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0101081:	05 00 00 00 10       	add    $0x10000000,%eax
f0101086:	c1 e8 0c             	shr    $0xc,%eax
		pages[i].pp_ref = 1;
f0101089:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	}
	for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
		pages[i].pp_ref = 1;
	}
	size_t first_free_address = PADDR(boot_alloc(0));
	for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f010108f:	ba 00 01 00 00       	mov    $0x100,%edx
f0101094:	eb 0a                	jmp    f01010a0 <page_init+0xd3>
		pages[i].pp_ref = 1;
f0101096:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
	}
	for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
		pages[i].pp_ref = 1;
	}
	size_t first_free_address = PADDR(boot_alloc(0));
	for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f010109d:	83 c2 01             	add    $0x1,%edx
f01010a0:	39 c2                	cmp    %eax,%edx
f01010a2:	72 f2                	jb     f0101096 <page_init+0xc9>
f01010a4:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f01010aa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01010b1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010b6:	eb 23                	jmp    f01010db <page_init+0x10e>
		pages[i].pp_ref = 1;
	}
	for (i = first_free_address/PGSIZE; i < npages; i++) {
		pages[i].pp_ref = 0;
f01010b8:	89 d1                	mov    %edx,%ecx
f01010ba:	03 0d 90 fe 22 f0    	add    0xf022fe90,%ecx
f01010c0:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01010c6:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f01010c8:	89 d3                	mov    %edx,%ebx
f01010ca:	03 1d 90 fe 22 f0    	add    0xf022fe90,%ebx
	}
	size_t first_free_address = PADDR(boot_alloc(0));
	for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
		pages[i].pp_ref = 1;
	}
	for (i = first_free_address/PGSIZE; i < npages; i++) {
f01010d0:	83 c0 01             	add    $0x1,%eax
f01010d3:	83 c2 08             	add    $0x8,%edx
f01010d6:	b9 01 00 00 00       	mov    $0x1,%ecx
f01010db:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01010e1:	72 d5                	jb     f01010b8 <page_init+0xeb>
f01010e3:	84 c9                	test   %cl,%cl
f01010e5:	74 06                	je     f01010ed <page_init+0x120>
f01010e7:	89 1d 40 f2 22 f0    	mov    %ebx,0xf022f240
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01010ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010f0:	5b                   	pop    %ebx
f01010f1:	5e                   	pop    %esi
f01010f2:	5d                   	pop    %ebp
f01010f3:	c3                   	ret    

f01010f4 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01010f4:	55                   	push   %ebp
f01010f5:	89 e5                	mov    %esp,%ebp
f01010f7:	53                   	push   %ebx
f01010f8:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	if (page_free_list == NULL) {
f01010fb:	8b 1d 40 f2 22 f0    	mov    0xf022f240,%ebx
f0101101:	85 db                	test   %ebx,%ebx
f0101103:	74 58                	je     f010115d <page_alloc+0x69>
		return NULL;
	}
	struct PageInfo *allocated_page = page_free_list;
	page_free_list = page_free_list->pp_link;
f0101105:	8b 03                	mov    (%ebx),%eax
f0101107:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
	allocated_page->pp_link = NULL;	
f010110c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101112:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101116:	74 45                	je     f010115d <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101118:	89 d8                	mov    %ebx,%eax
f010111a:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101120:	c1 f8 03             	sar    $0x3,%eax
f0101123:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101126:	89 c2                	mov    %eax,%edx
f0101128:	c1 ea 0c             	shr    $0xc,%edx
f010112b:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101131:	72 12                	jb     f0101145 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101133:	50                   	push   %eax
f0101134:	68 44 62 10 f0       	push   $0xf0106244
f0101139:	6a 58                	push   $0x58
f010113b:	68 8d 72 10 f0       	push   $0xf010728d
f0101140:	e8 fb ee ff ff       	call   f0100040 <_panic>
		memset(page2kva(allocated_page), '\0', PGSIZE);
f0101145:	83 ec 04             	sub    $0x4,%esp
f0101148:	68 00 10 00 00       	push   $0x1000
f010114d:	6a 00                	push   $0x0
f010114f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101154:	50                   	push   %eax
f0101155:	e8 ff 43 00 00       	call   f0105559 <memset>
f010115a:	83 c4 10             	add    $0x10,%esp
	}
	return allocated_page;
}
f010115d:	89 d8                	mov    %ebx,%eax
f010115f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101162:	c9                   	leave  
f0101163:	c3                   	ret    

f0101164 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101164:	55                   	push   %ebp
f0101165:	89 e5                	mov    %esp,%ebp
f0101167:	83 ec 08             	sub    $0x8,%esp
f010116a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref > 0 || pp->pp_link != NULL) {
f010116d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101172:	75 05                	jne    f0101179 <page_free+0x15>
f0101174:	83 38 00             	cmpl   $0x0,(%eax)
f0101177:	74 17                	je     f0101190 <page_free+0x2c>
		panic("Double check failed when dealloc page");
f0101179:	83 ec 04             	sub    $0x4,%esp
f010117c:	68 d8 69 10 f0       	push   $0xf01069d8
f0101181:	68 7e 01 00 00       	push   $0x17e
f0101186:	68 81 72 10 f0       	push   $0xf0107281
f010118b:	e8 b0 ee ff ff       	call   f0100040 <_panic>
		return;
	}
	pp->pp_link = page_free_list;
f0101190:	8b 15 40 f2 22 f0    	mov    0xf022f240,%edx
f0101196:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101198:	a3 40 f2 22 f0       	mov    %eax,0xf022f240
}
f010119d:	c9                   	leave  
f010119e:	c3                   	ret    

f010119f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010119f:	55                   	push   %ebp
f01011a0:	89 e5                	mov    %esp,%ebp
f01011a2:	83 ec 08             	sub    $0x8,%esp
f01011a5:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f01011a8:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f01011ac:	83 e8 01             	sub    $0x1,%eax
f01011af:	66 89 42 04          	mov    %ax,0x4(%edx)
f01011b3:	66 85 c0             	test   %ax,%ax
f01011b6:	75 0c                	jne    f01011c4 <page_decref+0x25>
		page_free(pp);
f01011b8:	83 ec 0c             	sub    $0xc,%esp
f01011bb:	52                   	push   %edx
f01011bc:	e8 a3 ff ff ff       	call   f0101164 <page_free>
f01011c1:	83 c4 10             	add    $0x10,%esp
}
f01011c4:	c9                   	leave  
f01011c5:	c3                   	ret    

f01011c6 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01011c6:	55                   	push   %ebp
f01011c7:	89 e5                	mov    %esp,%ebp
f01011c9:	56                   	push   %esi
f01011ca:	53                   	push   %ebx
f01011cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function in
	uint32_t page_dir_idx = PDX(va);
	uint32_t page_tab_idx = PTX(va);
f01011ce:	89 c6                	mov    %eax,%esi
f01011d0:	c1 ee 0c             	shr    $0xc,%esi
f01011d3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	pte_t *pgtab;
	if (pgdir[page_dir_idx] & PTE_P) {
f01011d9:	c1 e8 16             	shr    $0x16,%eax
f01011dc:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f01011e3:	03 5d 08             	add    0x8(%ebp),%ebx
f01011e6:	8b 03                	mov    (%ebx),%eax
f01011e8:	a8 01                	test   $0x1,%al
f01011ea:	74 2e                	je     f010121a <pgdir_walk+0x54>
		pgtab = KADDR(PTE_ADDR(pgdir[page_dir_idx]));
f01011ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011f1:	89 c2                	mov    %eax,%edx
f01011f3:	c1 ea 0c             	shr    $0xc,%edx
f01011f6:	39 15 88 fe 22 f0    	cmp    %edx,0xf022fe88
f01011fc:	77 15                	ja     f0101213 <pgdir_walk+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011fe:	50                   	push   %eax
f01011ff:	68 44 62 10 f0       	push   $0xf0106244
f0101204:	68 ae 01 00 00       	push   $0x1ae
f0101209:	68 81 72 10 f0       	push   $0xf0107281
f010120e:	e8 2d ee ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101213:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101218:	eb 73                	jmp    f010128d <pgdir_walk+0xc7>
	} else {
		if (create) {
f010121a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010121e:	74 72                	je     f0101292 <pgdir_walk+0xcc>
			struct PageInfo *new_pageInfo = page_alloc(ALLOC_ZERO);
f0101220:	83 ec 0c             	sub    $0xc,%esp
f0101223:	6a 01                	push   $0x1
f0101225:	e8 ca fe ff ff       	call   f01010f4 <page_alloc>
			if (new_pageInfo) {
f010122a:	83 c4 10             	add    $0x10,%esp
f010122d:	85 c0                	test   %eax,%eax
f010122f:	74 68                	je     f0101299 <pgdir_walk+0xd3>
				new_pageInfo->pp_ref += 1;
f0101231:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101236:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010123c:	89 c2                	mov    %eax,%edx
f010123e:	c1 fa 03             	sar    $0x3,%edx
f0101241:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101244:	89 d0                	mov    %edx,%eax
f0101246:	c1 e8 0c             	shr    $0xc,%eax
f0101249:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010124f:	72 12                	jb     f0101263 <pgdir_walk+0x9d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101251:	52                   	push   %edx
f0101252:	68 44 62 10 f0       	push   $0xf0106244
f0101257:	6a 58                	push   $0x58
f0101259:	68 8d 72 10 f0       	push   $0xf010728d
f010125e:	e8 dd ed ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101263:	8d 8a 00 00 00 f0    	lea    -0x10000000(%edx),%ecx
f0101269:	89 c8                	mov    %ecx,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010126b:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0101271:	77 15                	ja     f0101288 <pgdir_walk+0xc2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101273:	51                   	push   %ecx
f0101274:	68 68 62 10 f0       	push   $0xf0106268
f0101279:	68 b5 01 00 00       	push   $0x1b5
f010127e:	68 81 72 10 f0       	push   $0xf0107281
f0101283:	e8 b8 ed ff ff       	call   f0100040 <_panic>
				pgtab = (pte_t *) page2kva(new_pageInfo);
				pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
f0101288:	83 ca 07             	or     $0x7,%edx
f010128b:	89 13                	mov    %edx,(%ebx)
			}
		} else {
			return NULL;
		}
	}
	return &pgtab[page_tab_idx];
f010128d:	8d 04 b0             	lea    (%eax,%esi,4),%eax
f0101290:	eb 0c                	jmp    f010129e <pgdir_walk+0xd8>
				pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
			} else {
				return NULL;
			}
		} else {
			return NULL;
f0101292:	b8 00 00 00 00       	mov    $0x0,%eax
f0101297:	eb 05                	jmp    f010129e <pgdir_walk+0xd8>
			if (new_pageInfo) {
				new_pageInfo->pp_ref += 1;
				pgtab = (pte_t *) page2kva(new_pageInfo);
				pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
			} else {
				return NULL;
f0101299:	b8 00 00 00 00       	mov    $0x0,%eax
		} else {
			return NULL;
		}
	}
	return &pgtab[page_tab_idx];
}
f010129e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012a1:	5b                   	pop    %ebx
f01012a2:	5e                   	pop    %esi
f01012a3:	5d                   	pop    %ebp
f01012a4:	c3                   	ret    

f01012a5 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01012a5:	55                   	push   %ebp
f01012a6:	89 e5                	mov    %esp,%ebp
f01012a8:	57                   	push   %edi
f01012a9:	56                   	push   %esi
f01012aa:	53                   	push   %ebx
f01012ab:	83 ec 20             	sub    $0x20,%esp
f01012ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01012b1:	89 d7                	mov    %edx,%edi
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = size / PGSIZE;
f01012b3:	89 c8                	mov    %ecx,%eax
f01012b5:	c1 e8 0c             	shr    $0xc,%eax
f01012b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	cprintf("map region size = %d, %d pages\n",size, pg_num);
f01012bb:	50                   	push   %eax
f01012bc:	51                   	push   %ecx
f01012bd:	68 00 6a 10 f0       	push   $0xf0106a00
f01012c2:	e8 9c 25 00 00       	call   f0103863 <cprintf>
	for (size_t i=0; i<pg_num; i++) {
f01012c7:	83 c4 10             	add    $0x10,%esp
f01012ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01012cd:	be 00 00 00 00       	mov    $0x0,%esi
		pgtab = pgdir_walk(pgdir, (void *)va, 1);
f01012d2:	29 df                	sub    %ebx,%edi
		if (!pgtab) {
			return;
		}
		//cprintf("va = %p\n", va);
		*pgtab = pa | perm | PTE_P;
f01012d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012d7:	83 c8 01             	or     $0x1,%eax
f01012da:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = size / PGSIZE;
	cprintf("map region size = %d, %d pages\n",size, pg_num);
	for (size_t i=0; i<pg_num; i++) {
f01012dd:	eb 28                	jmp    f0101307 <boot_map_region+0x62>
		pgtab = pgdir_walk(pgdir, (void *)va, 1);
f01012df:	83 ec 04             	sub    $0x4,%esp
f01012e2:	6a 01                	push   $0x1
f01012e4:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01012e7:	50                   	push   %eax
f01012e8:	ff 75 e0             	pushl  -0x20(%ebp)
f01012eb:	e8 d6 fe ff ff       	call   f01011c6 <pgdir_walk>
		if (!pgtab) {
f01012f0:	83 c4 10             	add    $0x10,%esp
f01012f3:	85 c0                	test   %eax,%eax
f01012f5:	74 15                	je     f010130c <boot_map_region+0x67>
			return;
		}
		//cprintf("va = %p\n", va);
		*pgtab = pa | perm | PTE_P;
f01012f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01012fa:	09 da                	or     %ebx,%edx
f01012fc:	89 10                	mov    %edx,(%eax)
		va += PGSIZE;
		pa += PGSIZE;
f01012fe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	// Fill this function in
	pte_t *pgtab;
	size_t pg_num = size / PGSIZE;
	cprintf("map region size = %d, %d pages\n",size, pg_num);
	for (size_t i=0; i<pg_num; i++) {
f0101304:	83 c6 01             	add    $0x1,%esi
f0101307:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010130a:	75 d3                	jne    f01012df <boot_map_region+0x3a>
		//cprintf("va = %p\n", va);
		*pgtab = pa | perm | PTE_P;
		va += PGSIZE;
		pa += PGSIZE;
	}
}
f010130c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010130f:	5b                   	pop    %ebx
f0101310:	5e                   	pop    %esi
f0101311:	5f                   	pop    %edi
f0101312:	5d                   	pop    %ebp
f0101313:	c3                   	ret    

f0101314 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101314:	55                   	push   %ebp
f0101315:	89 e5                	mov    %esp,%ebp
f0101317:	53                   	push   %ebx
f0101318:	83 ec 08             	sub    $0x8,%esp
f010131b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 0);
f010131e:	6a 00                	push   $0x0
f0101320:	ff 75 0c             	pushl  0xc(%ebp)
f0101323:	ff 75 08             	pushl  0x8(%ebp)
f0101326:	e8 9b fe ff ff       	call   f01011c6 <pgdir_walk>
	if (!pgtab) {
f010132b:	83 c4 10             	add    $0x10,%esp
f010132e:	85 c0                	test   %eax,%eax
f0101330:	74 32                	je     f0101364 <page_lookup+0x50>
		return NULL;
	}
	if (pte_store) {
f0101332:	85 db                	test   %ebx,%ebx
f0101334:	74 02                	je     f0101338 <page_lookup+0x24>
		*pte_store = pgtab;
f0101336:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101338:	8b 00                	mov    (%eax),%eax
f010133a:	c1 e8 0c             	shr    $0xc,%eax
f010133d:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0101343:	72 14                	jb     f0101359 <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0101345:	83 ec 04             	sub    $0x4,%esp
f0101348:	68 20 6a 10 f0       	push   $0xf0106a20
f010134d:	6a 51                	push   $0x51
f010134f:	68 8d 72 10 f0       	push   $0xf010728d
f0101354:	e8 e7 ec ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101359:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f010135f:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	}
	return pa2page(PTE_ADDR(*pgtab));
f0101362:	eb 05                	jmp    f0101369 <page_lookup+0x55>
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pgtab = pgdir_walk(pgdir, va, 0);
	if (!pgtab) {
		return NULL;
f0101364:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	if (pte_store) {
		*pte_store = pgtab;
	}
	return pa2page(PTE_ADDR(*pgtab));
}
f0101369:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010136c:	c9                   	leave  
f010136d:	c3                   	ret    

f010136e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010136e:	55                   	push   %ebp
f010136f:	89 e5                	mov    %esp,%ebp
f0101371:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101374:	e8 01 48 00 00       	call   f0105b7a <cpunum>
f0101379:	6b c0 74             	imul   $0x74,%eax,%eax
f010137c:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0101383:	74 16                	je     f010139b <tlb_invalidate+0x2d>
f0101385:	e8 f0 47 00 00       	call   f0105b7a <cpunum>
f010138a:	6b c0 74             	imul   $0x74,%eax,%eax
f010138d:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0101393:	8b 55 08             	mov    0x8(%ebp),%edx
f0101396:	39 50 60             	cmp    %edx,0x60(%eax)
f0101399:	75 06                	jne    f01013a1 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010139b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010139e:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01013a1:	c9                   	leave  
f01013a2:	c3                   	ret    

f01013a3 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01013a3:	55                   	push   %ebp
f01013a4:	89 e5                	mov    %esp,%ebp
f01013a6:	56                   	push   %esi
f01013a7:	53                   	push   %ebx
f01013a8:	83 ec 14             	sub    $0x14,%esp
f01013ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01013ae:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *pgtab;
	pte_t **pte_store = &pgtab;
	struct PageInfo *pInfo = page_lookup(pgdir, va, pte_store);
f01013b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01013b4:	50                   	push   %eax
f01013b5:	56                   	push   %esi
f01013b6:	53                   	push   %ebx
f01013b7:	e8 58 ff ff ff       	call   f0101314 <page_lookup>
	if (!pInfo) {
f01013bc:	83 c4 10             	add    $0x10,%esp
f01013bf:	85 c0                	test   %eax,%eax
f01013c1:	74 1f                	je     f01013e2 <page_remove+0x3f>
		return;
	}
	page_decref(pInfo);
f01013c3:	83 ec 0c             	sub    $0xc,%esp
f01013c6:	50                   	push   %eax
f01013c7:	e8 d3 fd ff ff       	call   f010119f <page_decref>
	*pgtab = 0;
f01013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01013cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01013d5:	83 c4 08             	add    $0x8,%esp
f01013d8:	56                   	push   %esi
f01013d9:	53                   	push   %ebx
f01013da:	e8 8f ff ff ff       	call   f010136e <tlb_invalidate>
f01013df:	83 c4 10             	add    $0x10,%esp
}
f01013e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01013e5:	5b                   	pop    %ebx
f01013e6:	5e                   	pop    %esi
f01013e7:	5d                   	pop    %ebp
f01013e8:	c3                   	ret    

f01013e9 <page_insert>:
	return 0;
}
*/
int 
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01013e9:	55                   	push   %ebp
f01013ea:	89 e5                	mov    %esp,%ebp
f01013ec:	57                   	push   %edi
f01013ed:	56                   	push   %esi
f01013ee:	53                   	push   %ebx
f01013ef:	83 ec 10             	sub    $0x10,%esp
f01013f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013f5:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pgtab = pgdir_walk(pgdir, va, 1);
f01013f8:	6a 01                	push   $0x1
f01013fa:	57                   	push   %edi
f01013fb:	ff 75 08             	pushl  0x8(%ebp)
f01013fe:	e8 c3 fd ff ff       	call   f01011c6 <pgdir_walk>
	if (!pgtab) {
f0101403:	83 c4 10             	add    $0x10,%esp
f0101406:	85 c0                	test   %eax,%eax
f0101408:	74 38                	je     f0101442 <page_insert+0x59>
f010140a:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;
	}

	pp->pp_ref++;
f010140c:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pgtab & PTE_P) {
f0101411:	f6 00 01             	testb  $0x1,(%eax)
f0101414:	74 0f                	je     f0101425 <page_insert+0x3c>
		page_remove(pgdir, va);
f0101416:	83 ec 08             	sub    $0x8,%esp
f0101419:	57                   	push   %edi
f010141a:	ff 75 08             	pushl  0x8(%ebp)
f010141d:	e8 81 ff ff ff       	call   f01013a3 <page_remove>
f0101422:	83 c4 10             	add    $0x10,%esp
	}
	*pgtab = page2pa(pp) | perm | PTE_P;
f0101425:	2b 1d 90 fe 22 f0    	sub    0xf022fe90,%ebx
f010142b:	c1 fb 03             	sar    $0x3,%ebx
f010142e:	c1 e3 0c             	shl    $0xc,%ebx
f0101431:	8b 45 14             	mov    0x14(%ebp),%eax
f0101434:	83 c8 01             	or     $0x1,%eax
f0101437:	09 c3                	or     %eax,%ebx
f0101439:	89 1e                	mov    %ebx,(%esi)
	return 0;
f010143b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101440:	eb 05                	jmp    f0101447 <page_insert+0x5e>
int 
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pgtab = pgdir_walk(pgdir, va, 1);
	if (!pgtab) {
		return -E_NO_MEM;
f0101442:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	if (*pgtab & PTE_P) {
		page_remove(pgdir, va);
	}
	*pgtab = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101447:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010144a:	5b                   	pop    %ebx
f010144b:	5e                   	pop    %esi
f010144c:	5f                   	pop    %edi
f010144d:	5d                   	pop    %ebp
f010144e:	c3                   	ret    

f010144f <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010144f:	55                   	push   %ebp
f0101450:	89 e5                	mov    %esp,%ebp
f0101452:	53                   	push   %ebx
f0101453:	83 ec 04             	sub    $0x4,%esp
	//
	// Your code here:
	// panic("mmio_map_region not implemented");
	
	
	size_t rounded_size = ROUNDUP(size, PGSIZE);
f0101456:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101459:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010145f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	if (base + rounded_size > MMIOLIM) panic("overflow MMIOLIM");
f0101465:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f010146b:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f010146e:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101473:	76 17                	jbe    f010148c <mmio_map_region+0x3d>
f0101475:	83 ec 04             	sub    $0x4,%esp
f0101478:	68 54 73 10 f0       	push   $0xf0107354
f010147d:	68 89 02 00 00       	push   $0x289
f0101482:	68 81 72 10 f0       	push   $0xf0107281
f0101487:	e8 b4 eb ff ff       	call   f0100040 <_panic>
	boot_map_region(kern_pgdir, base, rounded_size, pa, PTE_W|PTE_PCD|PTE_PWT);
f010148c:	83 ec 08             	sub    $0x8,%esp
f010148f:	6a 1a                	push   $0x1a
f0101491:	ff 75 08             	pushl  0x8(%ebp)
f0101494:	89 d9                	mov    %ebx,%ecx
f0101496:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f010149b:	e8 05 fe ff ff       	call   f01012a5 <boot_map_region>
	uintptr_t res_region_base = base;	
f01014a0:	a1 00 03 12 f0       	mov    0xf0120300,%eax
	base += rounded_size;
f01014a5:	01 c3                	add    %eax,%ebx
f01014a7:	89 1d 00 03 12 f0    	mov    %ebx,0xf0120300
		
	return (void *)res_region_base;
}
f01014ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014b0:	c9                   	leave  
f01014b1:	c3                   	ret    

f01014b2 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01014b2:	55                   	push   %ebp
f01014b3:	89 e5                	mov    %esp,%ebp
f01014b5:	57                   	push   %edi
f01014b6:	56                   	push   %esi
f01014b7:	53                   	push   %ebx
f01014b8:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01014bb:	b8 15 00 00 00       	mov    $0x15,%eax
f01014c0:	e8 79 f7 ff ff       	call   f0100c3e <nvram_read>
f01014c5:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01014c7:	b8 17 00 00 00       	mov    $0x17,%eax
f01014cc:	e8 6d f7 ff ff       	call   f0100c3e <nvram_read>
f01014d1:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01014d3:	b8 34 00 00 00       	mov    $0x34,%eax
f01014d8:	e8 61 f7 ff ff       	call   f0100c3e <nvram_read>
f01014dd:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01014e0:	85 c0                	test   %eax,%eax
f01014e2:	74 07                	je     f01014eb <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01014e4:	05 00 40 00 00       	add    $0x4000,%eax
f01014e9:	eb 0b                	jmp    f01014f6 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01014eb:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01014f1:	85 f6                	test   %esi,%esi
f01014f3:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01014f6:	89 c2                	mov    %eax,%edx
f01014f8:	c1 ea 02             	shr    $0x2,%edx
f01014fb:	89 15 88 fe 22 f0    	mov    %edx,0xf022fe88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101501:	89 da                	mov    %ebx,%edx
f0101503:	c1 ea 02             	shr    $0x2,%edx
f0101506:	89 15 44 f2 22 f0    	mov    %edx,0xf022f244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010150c:	89 c2                	mov    %eax,%edx
f010150e:	29 da                	sub    %ebx,%edx
f0101510:	52                   	push   %edx
f0101511:	53                   	push   %ebx
f0101512:	50                   	push   %eax
f0101513:	68 40 6a 10 f0       	push   $0xf0106a40
f0101518:	e8 46 23 00 00       	call   f0103863 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010151d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101522:	e8 d1 f6 ff ff       	call   f0100bf8 <boot_alloc>
f0101527:	a3 8c fe 22 f0       	mov    %eax,0xf022fe8c
	memset(kern_pgdir, 0, PGSIZE);
f010152c:	83 c4 0c             	add    $0xc,%esp
f010152f:	68 00 10 00 00       	push   $0x1000
f0101534:	6a 00                	push   $0x0
f0101536:	50                   	push   %eax
f0101537:	e8 1d 40 00 00       	call   f0105559 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010153c:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101541:	83 c4 10             	add    $0x10,%esp
f0101544:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101549:	77 15                	ja     f0101560 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010154b:	50                   	push   %eax
f010154c:	68 68 62 10 f0       	push   $0xf0106268
f0101551:	68 95 00 00 00       	push   $0x95
f0101556:	68 81 72 10 f0       	push   $0xf0107281
f010155b:	e8 e0 ea ff ff       	call   f0100040 <_panic>
f0101560:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101566:	83 ca 05             	or     $0x5,%edx
f0101569:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010156f:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0101574:	c1 e0 03             	shl    $0x3,%eax
f0101577:	e8 7c f6 ff ff       	call   f0100bf8 <boot_alloc>
f010157c:	a3 90 fe 22 f0       	mov    %eax,0xf022fe90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101581:	83 ec 04             	sub    $0x4,%esp
f0101584:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f010158a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101591:	52                   	push   %edx
f0101592:	6a 00                	push   $0x0
f0101594:	50                   	push   %eax
f0101595:	e8 bf 3f 00 00       	call   f0105559 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f010159a:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010159f:	e8 54 f6 ff ff       	call   f0100bf8 <boot_alloc>
f01015a4:	a3 48 f2 22 f0       	mov    %eax,0xf022f248
	memset(envs, 0, NENV * sizeof(struct Env));
f01015a9:	83 c4 0c             	add    $0xc,%esp
f01015ac:	68 00 f0 01 00       	push   $0x1f000
f01015b1:	6a 00                	push   $0x0
f01015b3:	50                   	push   %eax
f01015b4:	e8 a0 3f 00 00       	call   f0105559 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01015b9:	e8 0f fa ff ff       	call   f0100fcd <page_init>

	check_page_free_list(1);
f01015be:	b8 01 00 00 00       	mov    $0x1,%eax
f01015c3:	e8 03 f7 ff ff       	call   f0100ccb <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01015c8:	83 c4 10             	add    $0x10,%esp
f01015cb:	83 3d 90 fe 22 f0 00 	cmpl   $0x0,0xf022fe90
f01015d2:	75 17                	jne    f01015eb <mem_init+0x139>
		panic("'pages' is a null pointer!");
f01015d4:	83 ec 04             	sub    $0x4,%esp
f01015d7:	68 65 73 10 f0       	push   $0xf0107365
f01015dc:	68 1c 03 00 00       	push   $0x31c
f01015e1:	68 81 72 10 f0       	push   $0xf0107281
f01015e6:	e8 55 ea ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015eb:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01015f5:	eb 05                	jmp    f01015fc <mem_init+0x14a>
		++nfree;
f01015f7:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01015fa:	8b 00                	mov    (%eax),%eax
f01015fc:	85 c0                	test   %eax,%eax
f01015fe:	75 f7                	jne    f01015f7 <mem_init+0x145>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101600:	83 ec 0c             	sub    $0xc,%esp
f0101603:	6a 00                	push   $0x0
f0101605:	e8 ea fa ff ff       	call   f01010f4 <page_alloc>
f010160a:	89 c7                	mov    %eax,%edi
f010160c:	83 c4 10             	add    $0x10,%esp
f010160f:	85 c0                	test   %eax,%eax
f0101611:	75 19                	jne    f010162c <mem_init+0x17a>
f0101613:	68 80 73 10 f0       	push   $0xf0107380
f0101618:	68 a7 72 10 f0       	push   $0xf01072a7
f010161d:	68 24 03 00 00       	push   $0x324
f0101622:	68 81 72 10 f0       	push   $0xf0107281
f0101627:	e8 14 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010162c:	83 ec 0c             	sub    $0xc,%esp
f010162f:	6a 00                	push   $0x0
f0101631:	e8 be fa ff ff       	call   f01010f4 <page_alloc>
f0101636:	89 c6                	mov    %eax,%esi
f0101638:	83 c4 10             	add    $0x10,%esp
f010163b:	85 c0                	test   %eax,%eax
f010163d:	75 19                	jne    f0101658 <mem_init+0x1a6>
f010163f:	68 96 73 10 f0       	push   $0xf0107396
f0101644:	68 a7 72 10 f0       	push   $0xf01072a7
f0101649:	68 25 03 00 00       	push   $0x325
f010164e:	68 81 72 10 f0       	push   $0xf0107281
f0101653:	e8 e8 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101658:	83 ec 0c             	sub    $0xc,%esp
f010165b:	6a 00                	push   $0x0
f010165d:	e8 92 fa ff ff       	call   f01010f4 <page_alloc>
f0101662:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101665:	83 c4 10             	add    $0x10,%esp
f0101668:	85 c0                	test   %eax,%eax
f010166a:	75 19                	jne    f0101685 <mem_init+0x1d3>
f010166c:	68 ac 73 10 f0       	push   $0xf01073ac
f0101671:	68 a7 72 10 f0       	push   $0xf01072a7
f0101676:	68 26 03 00 00       	push   $0x326
f010167b:	68 81 72 10 f0       	push   $0xf0107281
f0101680:	e8 bb e9 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101685:	39 f7                	cmp    %esi,%edi
f0101687:	75 19                	jne    f01016a2 <mem_init+0x1f0>
f0101689:	68 c2 73 10 f0       	push   $0xf01073c2
f010168e:	68 a7 72 10 f0       	push   $0xf01072a7
f0101693:	68 29 03 00 00       	push   $0x329
f0101698:	68 81 72 10 f0       	push   $0xf0107281
f010169d:	e8 9e e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016a5:	39 c6                	cmp    %eax,%esi
f01016a7:	74 04                	je     f01016ad <mem_init+0x1fb>
f01016a9:	39 c7                	cmp    %eax,%edi
f01016ab:	75 19                	jne    f01016c6 <mem_init+0x214>
f01016ad:	68 7c 6a 10 f0       	push   $0xf0106a7c
f01016b2:	68 a7 72 10 f0       	push   $0xf01072a7
f01016b7:	68 2a 03 00 00       	push   $0x32a
f01016bc:	68 81 72 10 f0       	push   $0xf0107281
f01016c1:	e8 7a e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016c6:	8b 0d 90 fe 22 f0    	mov    0xf022fe90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01016cc:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f01016d2:	c1 e2 0c             	shl    $0xc,%edx
f01016d5:	89 f8                	mov    %edi,%eax
f01016d7:	29 c8                	sub    %ecx,%eax
f01016d9:	c1 f8 03             	sar    $0x3,%eax
f01016dc:	c1 e0 0c             	shl    $0xc,%eax
f01016df:	39 d0                	cmp    %edx,%eax
f01016e1:	72 19                	jb     f01016fc <mem_init+0x24a>
f01016e3:	68 d4 73 10 f0       	push   $0xf01073d4
f01016e8:	68 a7 72 10 f0       	push   $0xf01072a7
f01016ed:	68 2b 03 00 00       	push   $0x32b
f01016f2:	68 81 72 10 f0       	push   $0xf0107281
f01016f7:	e8 44 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016fc:	89 f0                	mov    %esi,%eax
f01016fe:	29 c8                	sub    %ecx,%eax
f0101700:	c1 f8 03             	sar    $0x3,%eax
f0101703:	c1 e0 0c             	shl    $0xc,%eax
f0101706:	39 c2                	cmp    %eax,%edx
f0101708:	77 19                	ja     f0101723 <mem_init+0x271>
f010170a:	68 f1 73 10 f0       	push   $0xf01073f1
f010170f:	68 a7 72 10 f0       	push   $0xf01072a7
f0101714:	68 2c 03 00 00       	push   $0x32c
f0101719:	68 81 72 10 f0       	push   $0xf0107281
f010171e:	e8 1d e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101723:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101726:	29 c8                	sub    %ecx,%eax
f0101728:	c1 f8 03             	sar    $0x3,%eax
f010172b:	c1 e0 0c             	shl    $0xc,%eax
f010172e:	39 c2                	cmp    %eax,%edx
f0101730:	77 19                	ja     f010174b <mem_init+0x299>
f0101732:	68 0e 74 10 f0       	push   $0xf010740e
f0101737:	68 a7 72 10 f0       	push   $0xf01072a7
f010173c:	68 2d 03 00 00       	push   $0x32d
f0101741:	68 81 72 10 f0       	push   $0xf0107281
f0101746:	e8 f5 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010174b:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101750:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101753:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f010175a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010175d:	83 ec 0c             	sub    $0xc,%esp
f0101760:	6a 00                	push   $0x0
f0101762:	e8 8d f9 ff ff       	call   f01010f4 <page_alloc>
f0101767:	83 c4 10             	add    $0x10,%esp
f010176a:	85 c0                	test   %eax,%eax
f010176c:	74 19                	je     f0101787 <mem_init+0x2d5>
f010176e:	68 2b 74 10 f0       	push   $0xf010742b
f0101773:	68 a7 72 10 f0       	push   $0xf01072a7
f0101778:	68 34 03 00 00       	push   $0x334
f010177d:	68 81 72 10 f0       	push   $0xf0107281
f0101782:	e8 b9 e8 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101787:	83 ec 0c             	sub    $0xc,%esp
f010178a:	57                   	push   %edi
f010178b:	e8 d4 f9 ff ff       	call   f0101164 <page_free>
	page_free(pp1);
f0101790:	89 34 24             	mov    %esi,(%esp)
f0101793:	e8 cc f9 ff ff       	call   f0101164 <page_free>
	page_free(pp2);
f0101798:	83 c4 04             	add    $0x4,%esp
f010179b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010179e:	e8 c1 f9 ff ff       	call   f0101164 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017aa:	e8 45 f9 ff ff       	call   f01010f4 <page_alloc>
f01017af:	89 c6                	mov    %eax,%esi
f01017b1:	83 c4 10             	add    $0x10,%esp
f01017b4:	85 c0                	test   %eax,%eax
f01017b6:	75 19                	jne    f01017d1 <mem_init+0x31f>
f01017b8:	68 80 73 10 f0       	push   $0xf0107380
f01017bd:	68 a7 72 10 f0       	push   $0xf01072a7
f01017c2:	68 3b 03 00 00       	push   $0x33b
f01017c7:	68 81 72 10 f0       	push   $0xf0107281
f01017cc:	e8 6f e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01017d1:	83 ec 0c             	sub    $0xc,%esp
f01017d4:	6a 00                	push   $0x0
f01017d6:	e8 19 f9 ff ff       	call   f01010f4 <page_alloc>
f01017db:	89 c7                	mov    %eax,%edi
f01017dd:	83 c4 10             	add    $0x10,%esp
f01017e0:	85 c0                	test   %eax,%eax
f01017e2:	75 19                	jne    f01017fd <mem_init+0x34b>
f01017e4:	68 96 73 10 f0       	push   $0xf0107396
f01017e9:	68 a7 72 10 f0       	push   $0xf01072a7
f01017ee:	68 3c 03 00 00       	push   $0x33c
f01017f3:	68 81 72 10 f0       	push   $0xf0107281
f01017f8:	e8 43 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01017fd:	83 ec 0c             	sub    $0xc,%esp
f0101800:	6a 00                	push   $0x0
f0101802:	e8 ed f8 ff ff       	call   f01010f4 <page_alloc>
f0101807:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010180a:	83 c4 10             	add    $0x10,%esp
f010180d:	85 c0                	test   %eax,%eax
f010180f:	75 19                	jne    f010182a <mem_init+0x378>
f0101811:	68 ac 73 10 f0       	push   $0xf01073ac
f0101816:	68 a7 72 10 f0       	push   $0xf01072a7
f010181b:	68 3d 03 00 00       	push   $0x33d
f0101820:	68 81 72 10 f0       	push   $0xf0107281
f0101825:	e8 16 e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010182a:	39 fe                	cmp    %edi,%esi
f010182c:	75 19                	jne    f0101847 <mem_init+0x395>
f010182e:	68 c2 73 10 f0       	push   $0xf01073c2
f0101833:	68 a7 72 10 f0       	push   $0xf01072a7
f0101838:	68 3f 03 00 00       	push   $0x33f
f010183d:	68 81 72 10 f0       	push   $0xf0107281
f0101842:	e8 f9 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101847:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010184a:	39 c7                	cmp    %eax,%edi
f010184c:	74 04                	je     f0101852 <mem_init+0x3a0>
f010184e:	39 c6                	cmp    %eax,%esi
f0101850:	75 19                	jne    f010186b <mem_init+0x3b9>
f0101852:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0101857:	68 a7 72 10 f0       	push   $0xf01072a7
f010185c:	68 40 03 00 00       	push   $0x340
f0101861:	68 81 72 10 f0       	push   $0xf0107281
f0101866:	e8 d5 e7 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010186b:	83 ec 0c             	sub    $0xc,%esp
f010186e:	6a 00                	push   $0x0
f0101870:	e8 7f f8 ff ff       	call   f01010f4 <page_alloc>
f0101875:	83 c4 10             	add    $0x10,%esp
f0101878:	85 c0                	test   %eax,%eax
f010187a:	74 19                	je     f0101895 <mem_init+0x3e3>
f010187c:	68 2b 74 10 f0       	push   $0xf010742b
f0101881:	68 a7 72 10 f0       	push   $0xf01072a7
f0101886:	68 41 03 00 00       	push   $0x341
f010188b:	68 81 72 10 f0       	push   $0xf0107281
f0101890:	e8 ab e7 ff ff       	call   f0100040 <_panic>
f0101895:	89 f0                	mov    %esi,%eax
f0101897:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010189d:	c1 f8 03             	sar    $0x3,%eax
f01018a0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018a3:	89 c2                	mov    %eax,%edx
f01018a5:	c1 ea 0c             	shr    $0xc,%edx
f01018a8:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f01018ae:	72 12                	jb     f01018c2 <mem_init+0x410>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018b0:	50                   	push   %eax
f01018b1:	68 44 62 10 f0       	push   $0xf0106244
f01018b6:	6a 58                	push   $0x58
f01018b8:	68 8d 72 10 f0       	push   $0xf010728d
f01018bd:	e8 7e e7 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01018c2:	83 ec 04             	sub    $0x4,%esp
f01018c5:	68 00 10 00 00       	push   $0x1000
f01018ca:	6a 01                	push   $0x1
f01018cc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018d1:	50                   	push   %eax
f01018d2:	e8 82 3c 00 00       	call   f0105559 <memset>
	page_free(pp0);
f01018d7:	89 34 24             	mov    %esi,(%esp)
f01018da:	e8 85 f8 ff ff       	call   f0101164 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018e6:	e8 09 f8 ff ff       	call   f01010f4 <page_alloc>
f01018eb:	83 c4 10             	add    $0x10,%esp
f01018ee:	85 c0                	test   %eax,%eax
f01018f0:	75 19                	jne    f010190b <mem_init+0x459>
f01018f2:	68 3a 74 10 f0       	push   $0xf010743a
f01018f7:	68 a7 72 10 f0       	push   $0xf01072a7
f01018fc:	68 46 03 00 00       	push   $0x346
f0101901:	68 81 72 10 f0       	push   $0xf0107281
f0101906:	e8 35 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010190b:	39 c6                	cmp    %eax,%esi
f010190d:	74 19                	je     f0101928 <mem_init+0x476>
f010190f:	68 58 74 10 f0       	push   $0xf0107458
f0101914:	68 a7 72 10 f0       	push   $0xf01072a7
f0101919:	68 47 03 00 00       	push   $0x347
f010191e:	68 81 72 10 f0       	push   $0xf0107281
f0101923:	e8 18 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101928:	89 f0                	mov    %esi,%eax
f010192a:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0101930:	c1 f8 03             	sar    $0x3,%eax
f0101933:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101936:	89 c2                	mov    %eax,%edx
f0101938:	c1 ea 0c             	shr    $0xc,%edx
f010193b:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0101941:	72 12                	jb     f0101955 <mem_init+0x4a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101943:	50                   	push   %eax
f0101944:	68 44 62 10 f0       	push   $0xf0106244
f0101949:	6a 58                	push   $0x58
f010194b:	68 8d 72 10 f0       	push   $0xf010728d
f0101950:	e8 eb e6 ff ff       	call   f0100040 <_panic>
f0101955:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010195b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101961:	80 38 00             	cmpb   $0x0,(%eax)
f0101964:	74 19                	je     f010197f <mem_init+0x4cd>
f0101966:	68 68 74 10 f0       	push   $0xf0107468
f010196b:	68 a7 72 10 f0       	push   $0xf01072a7
f0101970:	68 4a 03 00 00       	push   $0x34a
f0101975:	68 81 72 10 f0       	push   $0xf0107281
f010197a:	e8 c1 e6 ff ff       	call   f0100040 <_panic>
f010197f:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101982:	39 d0                	cmp    %edx,%eax
f0101984:	75 db                	jne    f0101961 <mem_init+0x4af>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101986:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101989:	a3 40 f2 22 f0       	mov    %eax,0xf022f240

	// free the pages we took
	page_free(pp0);
f010198e:	83 ec 0c             	sub    $0xc,%esp
f0101991:	56                   	push   %esi
f0101992:	e8 cd f7 ff ff       	call   f0101164 <page_free>
	page_free(pp1);
f0101997:	89 3c 24             	mov    %edi,(%esp)
f010199a:	e8 c5 f7 ff ff       	call   f0101164 <page_free>
	page_free(pp2);
f010199f:	83 c4 04             	add    $0x4,%esp
f01019a2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01019a5:	e8 ba f7 ff ff       	call   f0101164 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019aa:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f01019af:	83 c4 10             	add    $0x10,%esp
f01019b2:	eb 05                	jmp    f01019b9 <mem_init+0x507>
		--nfree;
f01019b4:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01019b7:	8b 00                	mov    (%eax),%eax
f01019b9:	85 c0                	test   %eax,%eax
f01019bb:	75 f7                	jne    f01019b4 <mem_init+0x502>
		--nfree;
	assert(nfree == 0);
f01019bd:	85 db                	test   %ebx,%ebx
f01019bf:	74 19                	je     f01019da <mem_init+0x528>
f01019c1:	68 72 74 10 f0       	push   $0xf0107472
f01019c6:	68 a7 72 10 f0       	push   $0xf01072a7
f01019cb:	68 57 03 00 00       	push   $0x357
f01019d0:	68 81 72 10 f0       	push   $0xf0107281
f01019d5:	e8 66 e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01019da:	83 ec 0c             	sub    $0xc,%esp
f01019dd:	68 9c 6a 10 f0       	push   $0xf0106a9c
f01019e2:	e8 7c 1e 00 00       	call   f0103863 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01019e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019ee:	e8 01 f7 ff ff       	call   f01010f4 <page_alloc>
f01019f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019f6:	83 c4 10             	add    $0x10,%esp
f01019f9:	85 c0                	test   %eax,%eax
f01019fb:	75 19                	jne    f0101a16 <mem_init+0x564>
f01019fd:	68 80 73 10 f0       	push   $0xf0107380
f0101a02:	68 a7 72 10 f0       	push   $0xf01072a7
f0101a07:	68 bd 03 00 00       	push   $0x3bd
f0101a0c:	68 81 72 10 f0       	push   $0xf0107281
f0101a11:	e8 2a e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a16:	83 ec 0c             	sub    $0xc,%esp
f0101a19:	6a 00                	push   $0x0
f0101a1b:	e8 d4 f6 ff ff       	call   f01010f4 <page_alloc>
f0101a20:	89 c3                	mov    %eax,%ebx
f0101a22:	83 c4 10             	add    $0x10,%esp
f0101a25:	85 c0                	test   %eax,%eax
f0101a27:	75 19                	jne    f0101a42 <mem_init+0x590>
f0101a29:	68 96 73 10 f0       	push   $0xf0107396
f0101a2e:	68 a7 72 10 f0       	push   $0xf01072a7
f0101a33:	68 be 03 00 00       	push   $0x3be
f0101a38:	68 81 72 10 f0       	push   $0xf0107281
f0101a3d:	e8 fe e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a42:	83 ec 0c             	sub    $0xc,%esp
f0101a45:	6a 00                	push   $0x0
f0101a47:	e8 a8 f6 ff ff       	call   f01010f4 <page_alloc>
f0101a4c:	89 c6                	mov    %eax,%esi
f0101a4e:	83 c4 10             	add    $0x10,%esp
f0101a51:	85 c0                	test   %eax,%eax
f0101a53:	75 19                	jne    f0101a6e <mem_init+0x5bc>
f0101a55:	68 ac 73 10 f0       	push   $0xf01073ac
f0101a5a:	68 a7 72 10 f0       	push   $0xf01072a7
f0101a5f:	68 bf 03 00 00       	push   $0x3bf
f0101a64:	68 81 72 10 f0       	push   $0xf0107281
f0101a69:	e8 d2 e5 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a6e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101a71:	75 19                	jne    f0101a8c <mem_init+0x5da>
f0101a73:	68 c2 73 10 f0       	push   $0xf01073c2
f0101a78:	68 a7 72 10 f0       	push   $0xf01072a7
f0101a7d:	68 c2 03 00 00       	push   $0x3c2
f0101a82:	68 81 72 10 f0       	push   $0xf0107281
f0101a87:	e8 b4 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a8c:	39 c3                	cmp    %eax,%ebx
f0101a8e:	74 05                	je     f0101a95 <mem_init+0x5e3>
f0101a90:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101a93:	75 19                	jne    f0101aae <mem_init+0x5fc>
f0101a95:	68 7c 6a 10 f0       	push   $0xf0106a7c
f0101a9a:	68 a7 72 10 f0       	push   $0xf01072a7
f0101a9f:	68 c3 03 00 00       	push   $0x3c3
f0101aa4:	68 81 72 10 f0       	push   $0xf0107281
f0101aa9:	e8 92 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101aae:	a1 40 f2 22 f0       	mov    0xf022f240,%eax
f0101ab3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101ab6:	c7 05 40 f2 22 f0 00 	movl   $0x0,0xf022f240
f0101abd:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101ac0:	83 ec 0c             	sub    $0xc,%esp
f0101ac3:	6a 00                	push   $0x0
f0101ac5:	e8 2a f6 ff ff       	call   f01010f4 <page_alloc>
f0101aca:	83 c4 10             	add    $0x10,%esp
f0101acd:	85 c0                	test   %eax,%eax
f0101acf:	74 19                	je     f0101aea <mem_init+0x638>
f0101ad1:	68 2b 74 10 f0       	push   $0xf010742b
f0101ad6:	68 a7 72 10 f0       	push   $0xf01072a7
f0101adb:	68 ca 03 00 00       	push   $0x3ca
f0101ae0:	68 81 72 10 f0       	push   $0xf0107281
f0101ae5:	e8 56 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101aea:	83 ec 04             	sub    $0x4,%esp
f0101aed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101af0:	50                   	push   %eax
f0101af1:	6a 00                	push   $0x0
f0101af3:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101af9:	e8 16 f8 ff ff       	call   f0101314 <page_lookup>
f0101afe:	83 c4 10             	add    $0x10,%esp
f0101b01:	85 c0                	test   %eax,%eax
f0101b03:	74 19                	je     f0101b1e <mem_init+0x66c>
f0101b05:	68 bc 6a 10 f0       	push   $0xf0106abc
f0101b0a:	68 a7 72 10 f0       	push   $0xf01072a7
f0101b0f:	68 cd 03 00 00       	push   $0x3cd
f0101b14:	68 81 72 10 f0       	push   $0xf0107281
f0101b19:	e8 22 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b1e:	6a 02                	push   $0x2
f0101b20:	6a 00                	push   $0x0
f0101b22:	53                   	push   %ebx
f0101b23:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101b29:	e8 bb f8 ff ff       	call   f01013e9 <page_insert>
f0101b2e:	83 c4 10             	add    $0x10,%esp
f0101b31:	85 c0                	test   %eax,%eax
f0101b33:	78 19                	js     f0101b4e <mem_init+0x69c>
f0101b35:	68 f4 6a 10 f0       	push   $0xf0106af4
f0101b3a:	68 a7 72 10 f0       	push   $0xf01072a7
f0101b3f:	68 d0 03 00 00       	push   $0x3d0
f0101b44:	68 81 72 10 f0       	push   $0xf0107281
f0101b49:	e8 f2 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b4e:	83 ec 0c             	sub    $0xc,%esp
f0101b51:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b54:	e8 0b f6 ff ff       	call   f0101164 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b59:	6a 02                	push   $0x2
f0101b5b:	6a 00                	push   $0x0
f0101b5d:	53                   	push   %ebx
f0101b5e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101b64:	e8 80 f8 ff ff       	call   f01013e9 <page_insert>
f0101b69:	83 c4 20             	add    $0x20,%esp
f0101b6c:	85 c0                	test   %eax,%eax
f0101b6e:	74 19                	je     f0101b89 <mem_init+0x6d7>
f0101b70:	68 24 6b 10 f0       	push   $0xf0106b24
f0101b75:	68 a7 72 10 f0       	push   $0xf01072a7
f0101b7a:	68 d4 03 00 00       	push   $0x3d4
f0101b7f:	68 81 72 10 f0       	push   $0xf0107281
f0101b84:	e8 b7 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b89:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b8f:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f0101b94:	89 c1                	mov    %eax,%ecx
f0101b96:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b99:	8b 17                	mov    (%edi),%edx
f0101b9b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ba1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ba4:	29 c8                	sub    %ecx,%eax
f0101ba6:	c1 f8 03             	sar    $0x3,%eax
f0101ba9:	c1 e0 0c             	shl    $0xc,%eax
f0101bac:	39 c2                	cmp    %eax,%edx
f0101bae:	74 19                	je     f0101bc9 <mem_init+0x717>
f0101bb0:	68 54 6b 10 f0       	push   $0xf0106b54
f0101bb5:	68 a7 72 10 f0       	push   $0xf01072a7
f0101bba:	68 d5 03 00 00       	push   $0x3d5
f0101bbf:	68 81 72 10 f0       	push   $0xf0107281
f0101bc4:	e8 77 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bc9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bce:	89 f8                	mov    %edi,%eax
f0101bd0:	e8 92 f0 ff ff       	call   f0100c67 <check_va2pa>
f0101bd5:	89 da                	mov    %ebx,%edx
f0101bd7:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101bda:	c1 fa 03             	sar    $0x3,%edx
f0101bdd:	c1 e2 0c             	shl    $0xc,%edx
f0101be0:	39 d0                	cmp    %edx,%eax
f0101be2:	74 19                	je     f0101bfd <mem_init+0x74b>
f0101be4:	68 7c 6b 10 f0       	push   $0xf0106b7c
f0101be9:	68 a7 72 10 f0       	push   $0xf01072a7
f0101bee:	68 d6 03 00 00       	push   $0x3d6
f0101bf3:	68 81 72 10 f0       	push   $0xf0107281
f0101bf8:	e8 43 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101bfd:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c02:	74 19                	je     f0101c1d <mem_init+0x76b>
f0101c04:	68 7d 74 10 f0       	push   $0xf010747d
f0101c09:	68 a7 72 10 f0       	push   $0xf01072a7
f0101c0e:	68 d7 03 00 00       	push   $0x3d7
f0101c13:	68 81 72 10 f0       	push   $0xf0107281
f0101c18:	e8 23 e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c1d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c20:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101c25:	74 19                	je     f0101c40 <mem_init+0x78e>
f0101c27:	68 8e 74 10 f0       	push   $0xf010748e
f0101c2c:	68 a7 72 10 f0       	push   $0xf01072a7
f0101c31:	68 d8 03 00 00       	push   $0x3d8
f0101c36:	68 81 72 10 f0       	push   $0xf0107281
f0101c3b:	e8 00 e4 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c40:	6a 02                	push   $0x2
f0101c42:	68 00 10 00 00       	push   $0x1000
f0101c47:	56                   	push   %esi
f0101c48:	57                   	push   %edi
f0101c49:	e8 9b f7 ff ff       	call   f01013e9 <page_insert>
f0101c4e:	83 c4 10             	add    $0x10,%esp
f0101c51:	85 c0                	test   %eax,%eax
f0101c53:	74 19                	je     f0101c6e <mem_init+0x7bc>
f0101c55:	68 ac 6b 10 f0       	push   $0xf0106bac
f0101c5a:	68 a7 72 10 f0       	push   $0xf01072a7
f0101c5f:	68 db 03 00 00       	push   $0x3db
f0101c64:	68 81 72 10 f0       	push   $0xf0107281
f0101c69:	e8 d2 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c6e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c73:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101c78:	e8 ea ef ff ff       	call   f0100c67 <check_va2pa>
f0101c7d:	89 f2                	mov    %esi,%edx
f0101c7f:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101c85:	c1 fa 03             	sar    $0x3,%edx
f0101c88:	c1 e2 0c             	shl    $0xc,%edx
f0101c8b:	39 d0                	cmp    %edx,%eax
f0101c8d:	74 19                	je     f0101ca8 <mem_init+0x7f6>
f0101c8f:	68 e8 6b 10 f0       	push   $0xf0106be8
f0101c94:	68 a7 72 10 f0       	push   $0xf01072a7
f0101c99:	68 dc 03 00 00       	push   $0x3dc
f0101c9e:	68 81 72 10 f0       	push   $0xf0107281
f0101ca3:	e8 98 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ca8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cad:	74 19                	je     f0101cc8 <mem_init+0x816>
f0101caf:	68 9f 74 10 f0       	push   $0xf010749f
f0101cb4:	68 a7 72 10 f0       	push   $0xf01072a7
f0101cb9:	68 dd 03 00 00       	push   $0x3dd
f0101cbe:	68 81 72 10 f0       	push   $0xf0107281
f0101cc3:	e8 78 e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101cc8:	83 ec 0c             	sub    $0xc,%esp
f0101ccb:	6a 00                	push   $0x0
f0101ccd:	e8 22 f4 ff ff       	call   f01010f4 <page_alloc>
f0101cd2:	83 c4 10             	add    $0x10,%esp
f0101cd5:	85 c0                	test   %eax,%eax
f0101cd7:	74 19                	je     f0101cf2 <mem_init+0x840>
f0101cd9:	68 2b 74 10 f0       	push   $0xf010742b
f0101cde:	68 a7 72 10 f0       	push   $0xf01072a7
f0101ce3:	68 e0 03 00 00       	push   $0x3e0
f0101ce8:	68 81 72 10 f0       	push   $0xf0107281
f0101ced:	e8 4e e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cf2:	6a 02                	push   $0x2
f0101cf4:	68 00 10 00 00       	push   $0x1000
f0101cf9:	56                   	push   %esi
f0101cfa:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101d00:	e8 e4 f6 ff ff       	call   f01013e9 <page_insert>
f0101d05:	83 c4 10             	add    $0x10,%esp
f0101d08:	85 c0                	test   %eax,%eax
f0101d0a:	74 19                	je     f0101d25 <mem_init+0x873>
f0101d0c:	68 ac 6b 10 f0       	push   $0xf0106bac
f0101d11:	68 a7 72 10 f0       	push   $0xf01072a7
f0101d16:	68 e3 03 00 00       	push   $0x3e3
f0101d1b:	68 81 72 10 f0       	push   $0xf0107281
f0101d20:	e8 1b e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d25:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d2a:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101d2f:	e8 33 ef ff ff       	call   f0100c67 <check_va2pa>
f0101d34:	89 f2                	mov    %esi,%edx
f0101d36:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101d3c:	c1 fa 03             	sar    $0x3,%edx
f0101d3f:	c1 e2 0c             	shl    $0xc,%edx
f0101d42:	39 d0                	cmp    %edx,%eax
f0101d44:	74 19                	je     f0101d5f <mem_init+0x8ad>
f0101d46:	68 e8 6b 10 f0       	push   $0xf0106be8
f0101d4b:	68 a7 72 10 f0       	push   $0xf01072a7
f0101d50:	68 e4 03 00 00       	push   $0x3e4
f0101d55:	68 81 72 10 f0       	push   $0xf0107281
f0101d5a:	e8 e1 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d5f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d64:	74 19                	je     f0101d7f <mem_init+0x8cd>
f0101d66:	68 9f 74 10 f0       	push   $0xf010749f
f0101d6b:	68 a7 72 10 f0       	push   $0xf01072a7
f0101d70:	68 e5 03 00 00       	push   $0x3e5
f0101d75:	68 81 72 10 f0       	push   $0xf0107281
f0101d7a:	e8 c1 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101d7f:	83 ec 0c             	sub    $0xc,%esp
f0101d82:	6a 00                	push   $0x0
f0101d84:	e8 6b f3 ff ff       	call   f01010f4 <page_alloc>
f0101d89:	83 c4 10             	add    $0x10,%esp
f0101d8c:	85 c0                	test   %eax,%eax
f0101d8e:	74 19                	je     f0101da9 <mem_init+0x8f7>
f0101d90:	68 2b 74 10 f0       	push   $0xf010742b
f0101d95:	68 a7 72 10 f0       	push   $0xf01072a7
f0101d9a:	68 e9 03 00 00       	push   $0x3e9
f0101d9f:	68 81 72 10 f0       	push   $0xf0107281
f0101da4:	e8 97 e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101da9:	8b 15 8c fe 22 f0    	mov    0xf022fe8c,%edx
f0101daf:	8b 02                	mov    (%edx),%eax
f0101db1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101db6:	89 c1                	mov    %eax,%ecx
f0101db8:	c1 e9 0c             	shr    $0xc,%ecx
f0101dbb:	3b 0d 88 fe 22 f0    	cmp    0xf022fe88,%ecx
f0101dc1:	72 15                	jb     f0101dd8 <mem_init+0x926>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101dc3:	50                   	push   %eax
f0101dc4:	68 44 62 10 f0       	push   $0xf0106244
f0101dc9:	68 ec 03 00 00       	push   $0x3ec
f0101dce:	68 81 72 10 f0       	push   $0xf0107281
f0101dd3:	e8 68 e2 ff ff       	call   f0100040 <_panic>
f0101dd8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ddd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101de0:	83 ec 04             	sub    $0x4,%esp
f0101de3:	6a 00                	push   $0x0
f0101de5:	68 00 10 00 00       	push   $0x1000
f0101dea:	52                   	push   %edx
f0101deb:	e8 d6 f3 ff ff       	call   f01011c6 <pgdir_walk>
f0101df0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101df3:	8d 51 04             	lea    0x4(%ecx),%edx
f0101df6:	83 c4 10             	add    $0x10,%esp
f0101df9:	39 d0                	cmp    %edx,%eax
f0101dfb:	74 19                	je     f0101e16 <mem_init+0x964>
f0101dfd:	68 18 6c 10 f0       	push   $0xf0106c18
f0101e02:	68 a7 72 10 f0       	push   $0xf01072a7
f0101e07:	68 ed 03 00 00       	push   $0x3ed
f0101e0c:	68 81 72 10 f0       	push   $0xf0107281
f0101e11:	e8 2a e2 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101e16:	6a 06                	push   $0x6
f0101e18:	68 00 10 00 00       	push   $0x1000
f0101e1d:	56                   	push   %esi
f0101e1e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101e24:	e8 c0 f5 ff ff       	call   f01013e9 <page_insert>
f0101e29:	83 c4 10             	add    $0x10,%esp
f0101e2c:	85 c0                	test   %eax,%eax
f0101e2e:	74 19                	je     f0101e49 <mem_init+0x997>
f0101e30:	68 58 6c 10 f0       	push   $0xf0106c58
f0101e35:	68 a7 72 10 f0       	push   $0xf01072a7
f0101e3a:	68 f0 03 00 00       	push   $0x3f0
f0101e3f:	68 81 72 10 f0       	push   $0xf0107281
f0101e44:	e8 f7 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e49:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0101e4f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e54:	89 f8                	mov    %edi,%eax
f0101e56:	e8 0c ee ff ff       	call   f0100c67 <check_va2pa>
f0101e5b:	89 f2                	mov    %esi,%edx
f0101e5d:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0101e63:	c1 fa 03             	sar    $0x3,%edx
f0101e66:	c1 e2 0c             	shl    $0xc,%edx
f0101e69:	39 d0                	cmp    %edx,%eax
f0101e6b:	74 19                	je     f0101e86 <mem_init+0x9d4>
f0101e6d:	68 e8 6b 10 f0       	push   $0xf0106be8
f0101e72:	68 a7 72 10 f0       	push   $0xf01072a7
f0101e77:	68 f1 03 00 00       	push   $0x3f1
f0101e7c:	68 81 72 10 f0       	push   $0xf0107281
f0101e81:	e8 ba e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e86:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e8b:	74 19                	je     f0101ea6 <mem_init+0x9f4>
f0101e8d:	68 9f 74 10 f0       	push   $0xf010749f
f0101e92:	68 a7 72 10 f0       	push   $0xf01072a7
f0101e97:	68 f2 03 00 00       	push   $0x3f2
f0101e9c:	68 81 72 10 f0       	push   $0xf0107281
f0101ea1:	e8 9a e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ea6:	83 ec 04             	sub    $0x4,%esp
f0101ea9:	6a 00                	push   $0x0
f0101eab:	68 00 10 00 00       	push   $0x1000
f0101eb0:	57                   	push   %edi
f0101eb1:	e8 10 f3 ff ff       	call   f01011c6 <pgdir_walk>
f0101eb6:	83 c4 10             	add    $0x10,%esp
f0101eb9:	f6 00 04             	testb  $0x4,(%eax)
f0101ebc:	75 19                	jne    f0101ed7 <mem_init+0xa25>
f0101ebe:	68 98 6c 10 f0       	push   $0xf0106c98
f0101ec3:	68 a7 72 10 f0       	push   $0xf01072a7
f0101ec8:	68 f3 03 00 00       	push   $0x3f3
f0101ecd:	68 81 72 10 f0       	push   $0xf0107281
f0101ed2:	e8 69 e1 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ed7:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0101edc:	f6 00 04             	testb  $0x4,(%eax)
f0101edf:	75 19                	jne    f0101efa <mem_init+0xa48>
f0101ee1:	68 b0 74 10 f0       	push   $0xf01074b0
f0101ee6:	68 a7 72 10 f0       	push   $0xf01072a7
f0101eeb:	68 f4 03 00 00       	push   $0x3f4
f0101ef0:	68 81 72 10 f0       	push   $0xf0107281
f0101ef5:	e8 46 e1 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101efa:	6a 02                	push   $0x2
f0101efc:	68 00 10 00 00       	push   $0x1000
f0101f01:	56                   	push   %esi
f0101f02:	50                   	push   %eax
f0101f03:	e8 e1 f4 ff ff       	call   f01013e9 <page_insert>
f0101f08:	83 c4 10             	add    $0x10,%esp
f0101f0b:	85 c0                	test   %eax,%eax
f0101f0d:	74 19                	je     f0101f28 <mem_init+0xa76>
f0101f0f:	68 ac 6b 10 f0       	push   $0xf0106bac
f0101f14:	68 a7 72 10 f0       	push   $0xf01072a7
f0101f19:	68 f7 03 00 00       	push   $0x3f7
f0101f1e:	68 81 72 10 f0       	push   $0xf0107281
f0101f23:	e8 18 e1 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f28:	83 ec 04             	sub    $0x4,%esp
f0101f2b:	6a 00                	push   $0x0
f0101f2d:	68 00 10 00 00       	push   $0x1000
f0101f32:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f38:	e8 89 f2 ff ff       	call   f01011c6 <pgdir_walk>
f0101f3d:	83 c4 10             	add    $0x10,%esp
f0101f40:	f6 00 02             	testb  $0x2,(%eax)
f0101f43:	75 19                	jne    f0101f5e <mem_init+0xaac>
f0101f45:	68 cc 6c 10 f0       	push   $0xf0106ccc
f0101f4a:	68 a7 72 10 f0       	push   $0xf01072a7
f0101f4f:	68 f8 03 00 00       	push   $0x3f8
f0101f54:	68 81 72 10 f0       	push   $0xf0107281
f0101f59:	e8 e2 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f5e:	83 ec 04             	sub    $0x4,%esp
f0101f61:	6a 00                	push   $0x0
f0101f63:	68 00 10 00 00       	push   $0x1000
f0101f68:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101f6e:	e8 53 f2 ff ff       	call   f01011c6 <pgdir_walk>
f0101f73:	83 c4 10             	add    $0x10,%esp
f0101f76:	f6 00 04             	testb  $0x4,(%eax)
f0101f79:	74 19                	je     f0101f94 <mem_init+0xae2>
f0101f7b:	68 00 6d 10 f0       	push   $0xf0106d00
f0101f80:	68 a7 72 10 f0       	push   $0xf01072a7
f0101f85:	68 f9 03 00 00       	push   $0x3f9
f0101f8a:	68 81 72 10 f0       	push   $0xf0107281
f0101f8f:	e8 ac e0 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f94:	6a 02                	push   $0x2
f0101f96:	68 00 00 40 00       	push   $0x400000
f0101f9b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f9e:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101fa4:	e8 40 f4 ff ff       	call   f01013e9 <page_insert>
f0101fa9:	83 c4 10             	add    $0x10,%esp
f0101fac:	85 c0                	test   %eax,%eax
f0101fae:	78 19                	js     f0101fc9 <mem_init+0xb17>
f0101fb0:	68 38 6d 10 f0       	push   $0xf0106d38
f0101fb5:	68 a7 72 10 f0       	push   $0xf01072a7
f0101fba:	68 fc 03 00 00       	push   $0x3fc
f0101fbf:	68 81 72 10 f0       	push   $0xf0107281
f0101fc4:	e8 77 e0 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fc9:	6a 02                	push   $0x2
f0101fcb:	68 00 10 00 00       	push   $0x1000
f0101fd0:	53                   	push   %ebx
f0101fd1:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0101fd7:	e8 0d f4 ff ff       	call   f01013e9 <page_insert>
f0101fdc:	83 c4 10             	add    $0x10,%esp
f0101fdf:	85 c0                	test   %eax,%eax
f0101fe1:	74 19                	je     f0101ffc <mem_init+0xb4a>
f0101fe3:	68 70 6d 10 f0       	push   $0xf0106d70
f0101fe8:	68 a7 72 10 f0       	push   $0xf01072a7
f0101fed:	68 ff 03 00 00       	push   $0x3ff
f0101ff2:	68 81 72 10 f0       	push   $0xf0107281
f0101ff7:	e8 44 e0 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ffc:	83 ec 04             	sub    $0x4,%esp
f0101fff:	6a 00                	push   $0x0
f0102001:	68 00 10 00 00       	push   $0x1000
f0102006:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010200c:	e8 b5 f1 ff ff       	call   f01011c6 <pgdir_walk>
f0102011:	83 c4 10             	add    $0x10,%esp
f0102014:	f6 00 04             	testb  $0x4,(%eax)
f0102017:	74 19                	je     f0102032 <mem_init+0xb80>
f0102019:	68 00 6d 10 f0       	push   $0xf0106d00
f010201e:	68 a7 72 10 f0       	push   $0xf01072a7
f0102023:	68 00 04 00 00       	push   $0x400
f0102028:	68 81 72 10 f0       	push   $0xf0107281
f010202d:	e8 0e e0 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102032:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102038:	ba 00 00 00 00       	mov    $0x0,%edx
f010203d:	89 f8                	mov    %edi,%eax
f010203f:	e8 23 ec ff ff       	call   f0100c67 <check_va2pa>
f0102044:	89 c1                	mov    %eax,%ecx
f0102046:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102049:	89 d8                	mov    %ebx,%eax
f010204b:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102051:	c1 f8 03             	sar    $0x3,%eax
f0102054:	c1 e0 0c             	shl    $0xc,%eax
f0102057:	39 c1                	cmp    %eax,%ecx
f0102059:	74 19                	je     f0102074 <mem_init+0xbc2>
f010205b:	68 ac 6d 10 f0       	push   $0xf0106dac
f0102060:	68 a7 72 10 f0       	push   $0xf01072a7
f0102065:	68 03 04 00 00       	push   $0x403
f010206a:	68 81 72 10 f0       	push   $0xf0107281
f010206f:	e8 cc df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102074:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102079:	89 f8                	mov    %edi,%eax
f010207b:	e8 e7 eb ff ff       	call   f0100c67 <check_va2pa>
f0102080:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102083:	74 19                	je     f010209e <mem_init+0xbec>
f0102085:	68 d8 6d 10 f0       	push   $0xf0106dd8
f010208a:	68 a7 72 10 f0       	push   $0xf01072a7
f010208f:	68 04 04 00 00       	push   $0x404
f0102094:	68 81 72 10 f0       	push   $0xf0107281
f0102099:	e8 a2 df ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010209e:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01020a3:	74 19                	je     f01020be <mem_init+0xc0c>
f01020a5:	68 c6 74 10 f0       	push   $0xf01074c6
f01020aa:	68 a7 72 10 f0       	push   $0xf01072a7
f01020af:	68 06 04 00 00       	push   $0x406
f01020b4:	68 81 72 10 f0       	push   $0xf0107281
f01020b9:	e8 82 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020be:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020c3:	74 19                	je     f01020de <mem_init+0xc2c>
f01020c5:	68 d7 74 10 f0       	push   $0xf01074d7
f01020ca:	68 a7 72 10 f0       	push   $0xf01072a7
f01020cf:	68 07 04 00 00       	push   $0x407
f01020d4:	68 81 72 10 f0       	push   $0xf0107281
f01020d9:	e8 62 df ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020de:	83 ec 0c             	sub    $0xc,%esp
f01020e1:	6a 00                	push   $0x0
f01020e3:	e8 0c f0 ff ff       	call   f01010f4 <page_alloc>
f01020e8:	83 c4 10             	add    $0x10,%esp
f01020eb:	85 c0                	test   %eax,%eax
f01020ed:	74 04                	je     f01020f3 <mem_init+0xc41>
f01020ef:	39 c6                	cmp    %eax,%esi
f01020f1:	74 19                	je     f010210c <mem_init+0xc5a>
f01020f3:	68 08 6e 10 f0       	push   $0xf0106e08
f01020f8:	68 a7 72 10 f0       	push   $0xf01072a7
f01020fd:	68 0a 04 00 00       	push   $0x40a
f0102102:	68 81 72 10 f0       	push   $0xf0107281
f0102107:	e8 34 df ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010210c:	83 ec 08             	sub    $0x8,%esp
f010210f:	6a 00                	push   $0x0
f0102111:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102117:	e8 87 f2 ff ff       	call   f01013a3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010211c:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f0102122:	ba 00 00 00 00       	mov    $0x0,%edx
f0102127:	89 f8                	mov    %edi,%eax
f0102129:	e8 39 eb ff ff       	call   f0100c67 <check_va2pa>
f010212e:	83 c4 10             	add    $0x10,%esp
f0102131:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102134:	74 19                	je     f010214f <mem_init+0xc9d>
f0102136:	68 2c 6e 10 f0       	push   $0xf0106e2c
f010213b:	68 a7 72 10 f0       	push   $0xf01072a7
f0102140:	68 0e 04 00 00       	push   $0x40e
f0102145:	68 81 72 10 f0       	push   $0xf0107281
f010214a:	e8 f1 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010214f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102154:	89 f8                	mov    %edi,%eax
f0102156:	e8 0c eb ff ff       	call   f0100c67 <check_va2pa>
f010215b:	89 da                	mov    %ebx,%edx
f010215d:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0102163:	c1 fa 03             	sar    $0x3,%edx
f0102166:	c1 e2 0c             	shl    $0xc,%edx
f0102169:	39 d0                	cmp    %edx,%eax
f010216b:	74 19                	je     f0102186 <mem_init+0xcd4>
f010216d:	68 d8 6d 10 f0       	push   $0xf0106dd8
f0102172:	68 a7 72 10 f0       	push   $0xf01072a7
f0102177:	68 0f 04 00 00       	push   $0x40f
f010217c:	68 81 72 10 f0       	push   $0xf0107281
f0102181:	e8 ba de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102186:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010218b:	74 19                	je     f01021a6 <mem_init+0xcf4>
f010218d:	68 7d 74 10 f0       	push   $0xf010747d
f0102192:	68 a7 72 10 f0       	push   $0xf01072a7
f0102197:	68 10 04 00 00       	push   $0x410
f010219c:	68 81 72 10 f0       	push   $0xf0107281
f01021a1:	e8 9a de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01021a6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021ab:	74 19                	je     f01021c6 <mem_init+0xd14>
f01021ad:	68 d7 74 10 f0       	push   $0xf01074d7
f01021b2:	68 a7 72 10 f0       	push   $0xf01072a7
f01021b7:	68 11 04 00 00       	push   $0x411
f01021bc:	68 81 72 10 f0       	push   $0xf0107281
f01021c1:	e8 7a de ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021c6:	6a 00                	push   $0x0
f01021c8:	68 00 10 00 00       	push   $0x1000
f01021cd:	53                   	push   %ebx
f01021ce:	57                   	push   %edi
f01021cf:	e8 15 f2 ff ff       	call   f01013e9 <page_insert>
f01021d4:	83 c4 10             	add    $0x10,%esp
f01021d7:	85 c0                	test   %eax,%eax
f01021d9:	74 19                	je     f01021f4 <mem_init+0xd42>
f01021db:	68 50 6e 10 f0       	push   $0xf0106e50
f01021e0:	68 a7 72 10 f0       	push   $0xf01072a7
f01021e5:	68 14 04 00 00       	push   $0x414
f01021ea:	68 81 72 10 f0       	push   $0xf0107281
f01021ef:	e8 4c de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01021f4:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021f9:	75 19                	jne    f0102214 <mem_init+0xd62>
f01021fb:	68 e8 74 10 f0       	push   $0xf01074e8
f0102200:	68 a7 72 10 f0       	push   $0xf01072a7
f0102205:	68 15 04 00 00       	push   $0x415
f010220a:	68 81 72 10 f0       	push   $0xf0107281
f010220f:	e8 2c de ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102214:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102217:	74 19                	je     f0102232 <mem_init+0xd80>
f0102219:	68 f4 74 10 f0       	push   $0xf01074f4
f010221e:	68 a7 72 10 f0       	push   $0xf01072a7
f0102223:	68 16 04 00 00       	push   $0x416
f0102228:	68 81 72 10 f0       	push   $0xf0107281
f010222d:	e8 0e de ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102232:	83 ec 08             	sub    $0x8,%esp
f0102235:	68 00 10 00 00       	push   $0x1000
f010223a:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102240:	e8 5e f1 ff ff       	call   f01013a3 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102245:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f010224b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102250:	89 f8                	mov    %edi,%eax
f0102252:	e8 10 ea ff ff       	call   f0100c67 <check_va2pa>
f0102257:	83 c4 10             	add    $0x10,%esp
f010225a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010225d:	74 19                	je     f0102278 <mem_init+0xdc6>
f010225f:	68 2c 6e 10 f0       	push   $0xf0106e2c
f0102264:	68 a7 72 10 f0       	push   $0xf01072a7
f0102269:	68 1a 04 00 00       	push   $0x41a
f010226e:	68 81 72 10 f0       	push   $0xf0107281
f0102273:	e8 c8 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102278:	ba 00 10 00 00       	mov    $0x1000,%edx
f010227d:	89 f8                	mov    %edi,%eax
f010227f:	e8 e3 e9 ff ff       	call   f0100c67 <check_va2pa>
f0102284:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102287:	74 19                	je     f01022a2 <mem_init+0xdf0>
f0102289:	68 88 6e 10 f0       	push   $0xf0106e88
f010228e:	68 a7 72 10 f0       	push   $0xf01072a7
f0102293:	68 1b 04 00 00       	push   $0x41b
f0102298:	68 81 72 10 f0       	push   $0xf0107281
f010229d:	e8 9e dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01022a2:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022a7:	74 19                	je     f01022c2 <mem_init+0xe10>
f01022a9:	68 09 75 10 f0       	push   $0xf0107509
f01022ae:	68 a7 72 10 f0       	push   $0xf01072a7
f01022b3:	68 1c 04 00 00       	push   $0x41c
f01022b8:	68 81 72 10 f0       	push   $0xf0107281
f01022bd:	e8 7e dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01022c2:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c7:	74 19                	je     f01022e2 <mem_init+0xe30>
f01022c9:	68 d7 74 10 f0       	push   $0xf01074d7
f01022ce:	68 a7 72 10 f0       	push   $0xf01072a7
f01022d3:	68 1d 04 00 00       	push   $0x41d
f01022d8:	68 81 72 10 f0       	push   $0xf0107281
f01022dd:	e8 5e dd ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022e2:	83 ec 0c             	sub    $0xc,%esp
f01022e5:	6a 00                	push   $0x0
f01022e7:	e8 08 ee ff ff       	call   f01010f4 <page_alloc>
f01022ec:	83 c4 10             	add    $0x10,%esp
f01022ef:	39 c3                	cmp    %eax,%ebx
f01022f1:	75 04                	jne    f01022f7 <mem_init+0xe45>
f01022f3:	85 c0                	test   %eax,%eax
f01022f5:	75 19                	jne    f0102310 <mem_init+0xe5e>
f01022f7:	68 b0 6e 10 f0       	push   $0xf0106eb0
f01022fc:	68 a7 72 10 f0       	push   $0xf01072a7
f0102301:	68 20 04 00 00       	push   $0x420
f0102306:	68 81 72 10 f0       	push   $0xf0107281
f010230b:	e8 30 dd ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102310:	83 ec 0c             	sub    $0xc,%esp
f0102313:	6a 00                	push   $0x0
f0102315:	e8 da ed ff ff       	call   f01010f4 <page_alloc>
f010231a:	83 c4 10             	add    $0x10,%esp
f010231d:	85 c0                	test   %eax,%eax
f010231f:	74 19                	je     f010233a <mem_init+0xe88>
f0102321:	68 2b 74 10 f0       	push   $0xf010742b
f0102326:	68 a7 72 10 f0       	push   $0xf01072a7
f010232b:	68 23 04 00 00       	push   $0x423
f0102330:	68 81 72 10 f0       	push   $0xf0107281
f0102335:	e8 06 dd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010233a:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102340:	8b 11                	mov    (%ecx),%edx
f0102342:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102348:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010234b:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102351:	c1 f8 03             	sar    $0x3,%eax
f0102354:	c1 e0 0c             	shl    $0xc,%eax
f0102357:	39 c2                	cmp    %eax,%edx
f0102359:	74 19                	je     f0102374 <mem_init+0xec2>
f010235b:	68 54 6b 10 f0       	push   $0xf0106b54
f0102360:	68 a7 72 10 f0       	push   $0xf01072a7
f0102365:	68 26 04 00 00       	push   $0x426
f010236a:	68 81 72 10 f0       	push   $0xf0107281
f010236f:	e8 cc dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102374:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010237a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010237d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102382:	74 19                	je     f010239d <mem_init+0xeeb>
f0102384:	68 8e 74 10 f0       	push   $0xf010748e
f0102389:	68 a7 72 10 f0       	push   $0xf01072a7
f010238e:	68 28 04 00 00       	push   $0x428
f0102393:	68 81 72 10 f0       	push   $0xf0107281
f0102398:	e8 a3 dc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010239d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01023a0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023a6:	83 ec 0c             	sub    $0xc,%esp
f01023a9:	50                   	push   %eax
f01023aa:	e8 b5 ed ff ff       	call   f0101164 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023af:	83 c4 0c             	add    $0xc,%esp
f01023b2:	6a 01                	push   $0x1
f01023b4:	68 00 10 40 00       	push   $0x401000
f01023b9:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01023bf:	e8 02 ee ff ff       	call   f01011c6 <pgdir_walk>
f01023c4:	89 c7                	mov    %eax,%edi
f01023c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01023c9:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01023ce:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023d1:	8b 40 04             	mov    0x4(%eax),%eax
f01023d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d9:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01023df:	89 c2                	mov    %eax,%edx
f01023e1:	c1 ea 0c             	shr    $0xc,%edx
f01023e4:	83 c4 10             	add    $0x10,%esp
f01023e7:	39 ca                	cmp    %ecx,%edx
f01023e9:	72 15                	jb     f0102400 <mem_init+0xf4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023eb:	50                   	push   %eax
f01023ec:	68 44 62 10 f0       	push   $0xf0106244
f01023f1:	68 2f 04 00 00       	push   $0x42f
f01023f6:	68 81 72 10 f0       	push   $0xf0107281
f01023fb:	e8 40 dc ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102400:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102405:	39 c7                	cmp    %eax,%edi
f0102407:	74 19                	je     f0102422 <mem_init+0xf70>
f0102409:	68 1a 75 10 f0       	push   $0xf010751a
f010240e:	68 a7 72 10 f0       	push   $0xf01072a7
f0102413:	68 30 04 00 00       	push   $0x430
f0102418:	68 81 72 10 f0       	push   $0xf0107281
f010241d:	e8 1e dc ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102422:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102425:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010242c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010242f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102435:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f010243b:	c1 f8 03             	sar    $0x3,%eax
f010243e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102441:	89 c2                	mov    %eax,%edx
f0102443:	c1 ea 0c             	shr    $0xc,%edx
f0102446:	39 d1                	cmp    %edx,%ecx
f0102448:	77 12                	ja     f010245c <mem_init+0xfaa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010244a:	50                   	push   %eax
f010244b:	68 44 62 10 f0       	push   $0xf0106244
f0102450:	6a 58                	push   $0x58
f0102452:	68 8d 72 10 f0       	push   $0xf010728d
f0102457:	e8 e4 db ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010245c:	83 ec 04             	sub    $0x4,%esp
f010245f:	68 00 10 00 00       	push   $0x1000
f0102464:	68 ff 00 00 00       	push   $0xff
f0102469:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010246e:	50                   	push   %eax
f010246f:	e8 e5 30 00 00       	call   f0105559 <memset>
	page_free(pp0);
f0102474:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102477:	89 3c 24             	mov    %edi,(%esp)
f010247a:	e8 e5 ec ff ff       	call   f0101164 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010247f:	83 c4 0c             	add    $0xc,%esp
f0102482:	6a 01                	push   $0x1
f0102484:	6a 00                	push   $0x0
f0102486:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010248c:	e8 35 ed ff ff       	call   f01011c6 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102491:	89 fa                	mov    %edi,%edx
f0102493:	2b 15 90 fe 22 f0    	sub    0xf022fe90,%edx
f0102499:	c1 fa 03             	sar    $0x3,%edx
f010249c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010249f:	89 d0                	mov    %edx,%eax
f01024a1:	c1 e8 0c             	shr    $0xc,%eax
f01024a4:	83 c4 10             	add    $0x10,%esp
f01024a7:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01024ad:	72 12                	jb     f01024c1 <mem_init+0x100f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024af:	52                   	push   %edx
f01024b0:	68 44 62 10 f0       	push   $0xf0106244
f01024b5:	6a 58                	push   $0x58
f01024b7:	68 8d 72 10 f0       	push   $0xf010728d
f01024bc:	e8 7f db ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01024c1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01024c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01024ca:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01024d0:	f6 00 01             	testb  $0x1,(%eax)
f01024d3:	74 19                	je     f01024ee <mem_init+0x103c>
f01024d5:	68 32 75 10 f0       	push   $0xf0107532
f01024da:	68 a7 72 10 f0       	push   $0xf01072a7
f01024df:	68 3a 04 00 00       	push   $0x43a
f01024e4:	68 81 72 10 f0       	push   $0xf0107281
f01024e9:	e8 52 db ff ff       	call   f0100040 <_panic>
f01024ee:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01024f1:	39 d0                	cmp    %edx,%eax
f01024f3:	75 db                	jne    f01024d0 <mem_init+0x101e>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01024f5:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01024fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102500:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102503:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102509:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010250c:	89 0d 40 f2 22 f0    	mov    %ecx,0xf022f240

	// free the pages we took
	page_free(pp0);
f0102512:	83 ec 0c             	sub    $0xc,%esp
f0102515:	50                   	push   %eax
f0102516:	e8 49 ec ff ff       	call   f0101164 <page_free>
	page_free(pp1);
f010251b:	89 1c 24             	mov    %ebx,(%esp)
f010251e:	e8 41 ec ff ff       	call   f0101164 <page_free>
	page_free(pp2);
f0102523:	89 34 24             	mov    %esi,(%esp)
f0102526:	e8 39 ec ff ff       	call   f0101164 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010252b:	83 c4 08             	add    $0x8,%esp
f010252e:	68 01 10 00 00       	push   $0x1001
f0102533:	6a 00                	push   $0x0
f0102535:	e8 15 ef ff ff       	call   f010144f <mmio_map_region>
f010253a:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010253c:	83 c4 08             	add    $0x8,%esp
f010253f:	68 00 10 00 00       	push   $0x1000
f0102544:	6a 00                	push   $0x0
f0102546:	e8 04 ef ff ff       	call   f010144f <mmio_map_region>
f010254b:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010254d:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102553:	83 c4 10             	add    $0x10,%esp
f0102556:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010255c:	76 07                	jbe    f0102565 <mem_init+0x10b3>
f010255e:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102563:	76 19                	jbe    f010257e <mem_init+0x10cc>
f0102565:	68 d4 6e 10 f0       	push   $0xf0106ed4
f010256a:	68 a7 72 10 f0       	push   $0xf01072a7
f010256f:	68 4a 04 00 00       	push   $0x44a
f0102574:	68 81 72 10 f0       	push   $0xf0107281
f0102579:	e8 c2 da ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010257e:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102584:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010258a:	77 08                	ja     f0102594 <mem_init+0x10e2>
f010258c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102592:	77 19                	ja     f01025ad <mem_init+0x10fb>
f0102594:	68 fc 6e 10 f0       	push   $0xf0106efc
f0102599:	68 a7 72 10 f0       	push   $0xf01072a7
f010259e:	68 4b 04 00 00       	push   $0x44b
f01025a3:	68 81 72 10 f0       	push   $0xf0107281
f01025a8:	e8 93 da ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01025ad:	89 da                	mov    %ebx,%edx
f01025af:	09 f2                	or     %esi,%edx
f01025b1:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01025b7:	74 19                	je     f01025d2 <mem_init+0x1120>
f01025b9:	68 24 6f 10 f0       	push   $0xf0106f24
f01025be:	68 a7 72 10 f0       	push   $0xf01072a7
f01025c3:	68 4d 04 00 00       	push   $0x44d
f01025c8:	68 81 72 10 f0       	push   $0xf0107281
f01025cd:	e8 6e da ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01025d2:	39 c6                	cmp    %eax,%esi
f01025d4:	73 19                	jae    f01025ef <mem_init+0x113d>
f01025d6:	68 49 75 10 f0       	push   $0xf0107549
f01025db:	68 a7 72 10 f0       	push   $0xf01072a7
f01025e0:	68 4f 04 00 00       	push   $0x44f
f01025e5:	68 81 72 10 f0       	push   $0xf0107281
f01025ea:	e8 51 da ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01025ef:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi
f01025f5:	89 da                	mov    %ebx,%edx
f01025f7:	89 f8                	mov    %edi,%eax
f01025f9:	e8 69 e6 ff ff       	call   f0100c67 <check_va2pa>
f01025fe:	85 c0                	test   %eax,%eax
f0102600:	74 19                	je     f010261b <mem_init+0x1169>
f0102602:	68 4c 6f 10 f0       	push   $0xf0106f4c
f0102607:	68 a7 72 10 f0       	push   $0xf01072a7
f010260c:	68 51 04 00 00       	push   $0x451
f0102611:	68 81 72 10 f0       	push   $0xf0107281
f0102616:	e8 25 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010261b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102621:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102624:	89 c2                	mov    %eax,%edx
f0102626:	89 f8                	mov    %edi,%eax
f0102628:	e8 3a e6 ff ff       	call   f0100c67 <check_va2pa>
f010262d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102632:	74 19                	je     f010264d <mem_init+0x119b>
f0102634:	68 70 6f 10 f0       	push   $0xf0106f70
f0102639:	68 a7 72 10 f0       	push   $0xf01072a7
f010263e:	68 52 04 00 00       	push   $0x452
f0102643:	68 81 72 10 f0       	push   $0xf0107281
f0102648:	e8 f3 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010264d:	89 f2                	mov    %esi,%edx
f010264f:	89 f8                	mov    %edi,%eax
f0102651:	e8 11 e6 ff ff       	call   f0100c67 <check_va2pa>
f0102656:	85 c0                	test   %eax,%eax
f0102658:	74 19                	je     f0102673 <mem_init+0x11c1>
f010265a:	68 a0 6f 10 f0       	push   $0xf0106fa0
f010265f:	68 a7 72 10 f0       	push   $0xf01072a7
f0102664:	68 53 04 00 00       	push   $0x453
f0102669:	68 81 72 10 f0       	push   $0xf0107281
f010266e:	e8 cd d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102673:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102679:	89 f8                	mov    %edi,%eax
f010267b:	e8 e7 e5 ff ff       	call   f0100c67 <check_va2pa>
f0102680:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102683:	74 19                	je     f010269e <mem_init+0x11ec>
f0102685:	68 c4 6f 10 f0       	push   $0xf0106fc4
f010268a:	68 a7 72 10 f0       	push   $0xf01072a7
f010268f:	68 54 04 00 00       	push   $0x454
f0102694:	68 81 72 10 f0       	push   $0xf0107281
f0102699:	e8 a2 d9 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010269e:	83 ec 04             	sub    $0x4,%esp
f01026a1:	6a 00                	push   $0x0
f01026a3:	53                   	push   %ebx
f01026a4:	57                   	push   %edi
f01026a5:	e8 1c eb ff ff       	call   f01011c6 <pgdir_walk>
f01026aa:	83 c4 10             	add    $0x10,%esp
f01026ad:	f6 00 1a             	testb  $0x1a,(%eax)
f01026b0:	75 19                	jne    f01026cb <mem_init+0x1219>
f01026b2:	68 f0 6f 10 f0       	push   $0xf0106ff0
f01026b7:	68 a7 72 10 f0       	push   $0xf01072a7
f01026bc:	68 56 04 00 00       	push   $0x456
f01026c1:	68 81 72 10 f0       	push   $0xf0107281
f01026c6:	e8 75 d9 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01026cb:	83 ec 04             	sub    $0x4,%esp
f01026ce:	6a 00                	push   $0x0
f01026d0:	53                   	push   %ebx
f01026d1:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f01026d7:	e8 ea ea ff ff       	call   f01011c6 <pgdir_walk>
f01026dc:	8b 00                	mov    (%eax),%eax
f01026de:	83 c4 10             	add    $0x10,%esp
f01026e1:	83 e0 04             	and    $0x4,%eax
f01026e4:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01026e7:	74 19                	je     f0102702 <mem_init+0x1250>
f01026e9:	68 34 70 10 f0       	push   $0xf0107034
f01026ee:	68 a7 72 10 f0       	push   $0xf01072a7
f01026f3:	68 57 04 00 00       	push   $0x457
f01026f8:	68 81 72 10 f0       	push   $0xf0107281
f01026fd:	e8 3e d9 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102702:	83 ec 04             	sub    $0x4,%esp
f0102705:	6a 00                	push   $0x0
f0102707:	53                   	push   %ebx
f0102708:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010270e:	e8 b3 ea ff ff       	call   f01011c6 <pgdir_walk>
f0102713:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102719:	83 c4 0c             	add    $0xc,%esp
f010271c:	6a 00                	push   $0x0
f010271e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102721:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102727:	e8 9a ea ff ff       	call   f01011c6 <pgdir_walk>
f010272c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102732:	83 c4 0c             	add    $0xc,%esp
f0102735:	6a 00                	push   $0x0
f0102737:	56                   	push   %esi
f0102738:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010273e:	e8 83 ea ff ff       	call   f01011c6 <pgdir_walk>
f0102743:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102749:	c7 04 24 5b 75 10 f0 	movl   $0xf010755b,(%esp)
f0102750:	e8 0e 11 00 00       	call   f0103863 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) UPAGES, ROUNDUP(npages*sizeof(struct PageInfo),PGSIZE), PADDR(pages), PTE_U | PTE_P);
f0102755:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010275a:	83 c4 10             	add    $0x10,%esp
f010275d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102762:	77 15                	ja     f0102779 <mem_init+0x12c7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102764:	50                   	push   %eax
f0102765:	68 68 62 10 f0       	push   $0xf0106268
f010276a:	68 bb 00 00 00       	push   $0xbb
f010276f:	68 81 72 10 f0       	push   $0xf0107281
f0102774:	e8 c7 d8 ff ff       	call   f0100040 <_panic>
f0102779:	8b 15 88 fe 22 f0    	mov    0xf022fe88,%edx
f010277f:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0102786:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010278c:	83 ec 08             	sub    $0x8,%esp
f010278f:	6a 05                	push   $0x5
f0102791:	05 00 00 00 10       	add    $0x10000000,%eax
f0102796:	50                   	push   %eax
f0102797:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010279c:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01027a1:	e8 ff ea ff ff       	call   f01012a5 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, (uintptr_t) UENVS, ROUNDUP(NENV*sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01027a6:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027ab:	83 c4 10             	add    $0x10,%esp
f01027ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027b3:	77 15                	ja     f01027ca <mem_init+0x1318>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027b5:	50                   	push   %eax
f01027b6:	68 68 62 10 f0       	push   $0xf0106268
f01027bb:	68 c4 00 00 00       	push   $0xc4
f01027c0:	68 81 72 10 f0       	push   $0xf0107281
f01027c5:	e8 76 d8 ff ff       	call   f0100040 <_panic>
f01027ca:	83 ec 08             	sub    $0x8,%esp
f01027cd:	6a 05                	push   $0x5
f01027cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01027d4:	50                   	push   %eax
f01027d5:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f01027da:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01027df:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01027e4:	e8 bc ea ff ff       	call   f01012a5 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, (uintptr_t) KERNBASE, ROUNDUP(0xffffffff - KERNBASE, PGSIZE), 0, PTE_W | PTE_P);
f01027e9:	83 c4 08             	add    $0x8,%esp
f01027ec:	6a 03                	push   $0x3
f01027ee:	6a 00                	push   $0x0
f01027f0:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01027f5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01027fa:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f01027ff:	e8 a1 ea ff ff       	call   f01012a5 <boot_map_region>
f0102804:	c7 45 c4 00 10 23 f0 	movl   $0xf0231000,-0x3c(%ebp)
f010280b:	83 c4 10             	add    $0x10,%esp
f010280e:	be 00 10 23 f0       	mov    $0xf0231000,%esi
	//             it will fault rather than overwrite another CPU's stack.
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t start_addr = KSTACKTOP - KSTKSIZE;
f0102813:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
	
	for (size_t i=0; i<NCPU; i++) {
f0102818:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010281f:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102825:	77 15                	ja     f010283c <mem_init+0x138a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102827:	56                   	push   %esi
f0102828:	68 68 62 10 f0       	push   $0xf0106268
f010282d:	68 12 01 00 00       	push   $0x112
f0102832:	68 81 72 10 f0       	push   $0xf0107281
f0102837:	e8 04 d8 ff ff       	call   f0100040 <_panic>
f010283c:	8d be 00 00 00 10    	lea    0x10000000(%esi),%edi
		boot_map_region(kern_pgdir, (uintptr_t) start_addr, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W | PTE_P);
f0102842:	83 ec 08             	sub    $0x8,%esp
f0102845:	6a 03                	push   $0x3
f0102847:	57                   	push   %edi
f0102848:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010284d:	89 da                	mov    %ebx,%edx
f010284f:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
f0102854:	e8 4c ea ff ff       	call   f01012a5 <boot_map_region>
		cprintf("cpu %d: map %p to physical address %p\n", i, start_addr, PADDR(percpu_kstacks[i]));
f0102859:	57                   	push   %edi
f010285a:	53                   	push   %ebx
f010285b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010285e:	57                   	push   %edi
f010285f:	68 68 70 10 f0       	push   $0xf0107068
f0102864:	e8 fa 0f 00 00       	call   f0103863 <cprintf>
		start_addr -= KSTKSIZE + KSTKGAP;
f0102869:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uintptr_t start_addr = KSTACKTOP - KSTKSIZE;
	
	for (size_t i=0; i<NCPU; i++) {
f010286f:	89 f8                	mov    %edi,%eax
f0102871:	83 c0 01             	add    $0x1,%eax
f0102874:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102877:	81 c6 00 80 00 00    	add    $0x8000,%esi
f010287d:	83 c4 20             	add    $0x20,%esp
f0102880:	81 fb 00 80 f7 ef    	cmp    $0xeff78000,%ebx
f0102886:	75 97                	jne    f010281f <mem_init+0x136d>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102888:	8b 3d 8c fe 22 f0    	mov    0xf022fe8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010288e:	a1 88 fe 22 f0       	mov    0xf022fe88,%eax
f0102893:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102896:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010289d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01028a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028a5:	8b 35 90 fe 22 f0    	mov    0xf022fe90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028ab:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028ae:	bb 00 00 00 00       	mov    $0x0,%ebx
f01028b3:	eb 55                	jmp    f010290a <mem_init+0x1458>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028b5:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01028bb:	89 f8                	mov    %edi,%eax
f01028bd:	e8 a5 e3 ff ff       	call   f0100c67 <check_va2pa>
f01028c2:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01028c9:	77 15                	ja     f01028e0 <mem_init+0x142e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028cb:	56                   	push   %esi
f01028cc:	68 68 62 10 f0       	push   $0xf0106268
f01028d1:	68 6f 03 00 00       	push   $0x36f
f01028d6:	68 81 72 10 f0       	push   $0xf0107281
f01028db:	e8 60 d7 ff ff       	call   f0100040 <_panic>
f01028e0:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f01028e7:	39 c2                	cmp    %eax,%edx
f01028e9:	74 19                	je     f0102904 <mem_init+0x1452>
f01028eb:	68 90 70 10 f0       	push   $0xf0107090
f01028f0:	68 a7 72 10 f0       	push   $0xf01072a7
f01028f5:	68 6f 03 00 00       	push   $0x36f
f01028fa:	68 81 72 10 f0       	push   $0xf0107281
f01028ff:	e8 3c d7 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102904:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010290a:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010290d:	77 a6                	ja     f01028b5 <mem_init+0x1403>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010290f:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102915:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102918:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010291d:	89 da                	mov    %ebx,%edx
f010291f:	89 f8                	mov    %edi,%eax
f0102921:	e8 41 e3 ff ff       	call   f0100c67 <check_va2pa>
f0102926:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010292d:	77 15                	ja     f0102944 <mem_init+0x1492>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010292f:	56                   	push   %esi
f0102930:	68 68 62 10 f0       	push   $0xf0106268
f0102935:	68 74 03 00 00       	push   $0x374
f010293a:	68 81 72 10 f0       	push   $0xf0107281
f010293f:	e8 fc d6 ff ff       	call   f0100040 <_panic>
f0102944:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010294b:	39 d0                	cmp    %edx,%eax
f010294d:	74 19                	je     f0102968 <mem_init+0x14b6>
f010294f:	68 c4 70 10 f0       	push   $0xf01070c4
f0102954:	68 a7 72 10 f0       	push   $0xf01072a7
f0102959:	68 74 03 00 00       	push   $0x374
f010295e:	68 81 72 10 f0       	push   $0xf0107281
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
f0102968:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010296e:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102974:	75 a7                	jne    f010291d <mem_init+0x146b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102976:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0102979:	c1 e6 0c             	shl    $0xc,%esi
f010297c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102981:	eb 30                	jmp    f01029b3 <mem_init+0x1501>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102983:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102989:	89 f8                	mov    %edi,%eax
f010298b:	e8 d7 e2 ff ff       	call   f0100c67 <check_va2pa>
f0102990:	39 c3                	cmp    %eax,%ebx
f0102992:	74 19                	je     f01029ad <mem_init+0x14fb>
f0102994:	68 f8 70 10 f0       	push   $0xf01070f8
f0102999:	68 a7 72 10 f0       	push   $0xf01072a7
f010299e:	68 78 03 00 00       	push   $0x378
f01029a3:	68 81 72 10 f0       	push   $0xf0107281
f01029a8:	e8 93 d6 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01029b3:	39 f3                	cmp    %esi,%ebx
f01029b5:	72 cc                	jb     f0102983 <mem_init+0x14d1>
f01029b7:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01029bc:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01029bf:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01029c2:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029c5:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01029cb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01029ce:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01029d0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01029d3:	05 00 80 00 20       	add    $0x20008000,%eax
f01029d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01029db:	89 da                	mov    %ebx,%edx
f01029dd:	89 f8                	mov    %edi,%eax
f01029df:	e8 83 e2 ff ff       	call   f0100c67 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029e4:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01029ea:	77 15                	ja     f0102a01 <mem_init+0x154f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029ec:	56                   	push   %esi
f01029ed:	68 68 62 10 f0       	push   $0xf0106268
f01029f2:	68 80 03 00 00       	push   $0x380
f01029f7:	68 81 72 10 f0       	push   $0xf0107281
f01029fc:	e8 3f d6 ff ff       	call   f0100040 <_panic>
f0102a01:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102a04:	8d 94 0b 00 10 23 f0 	lea    -0xfdcf000(%ebx,%ecx,1),%edx
f0102a0b:	39 d0                	cmp    %edx,%eax
f0102a0d:	74 19                	je     f0102a28 <mem_init+0x1576>
f0102a0f:	68 20 71 10 f0       	push   $0xf0107120
f0102a14:	68 a7 72 10 f0       	push   $0xf01072a7
f0102a19:	68 80 03 00 00       	push   $0x380
f0102a1e:	68 81 72 10 f0       	push   $0xf0107281
f0102a23:	e8 18 d6 ff ff       	call   f0100040 <_panic>
f0102a28:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102a2e:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102a31:	75 a8                	jne    f01029db <mem_init+0x1529>
f0102a33:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a36:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f0102a3c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102a3f:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a41:	89 da                	mov    %ebx,%edx
f0102a43:	89 f8                	mov    %edi,%eax
f0102a45:	e8 1d e2 ff ff       	call   f0100c67 <check_va2pa>
f0102a4a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a4d:	74 19                	je     f0102a68 <mem_init+0x15b6>
f0102a4f:	68 68 71 10 f0       	push   $0xf0107168
f0102a54:	68 a7 72 10 f0       	push   $0xf01072a7
f0102a59:	68 82 03 00 00       	push   $0x382
f0102a5e:	68 81 72 10 f0       	push   $0xf0107281
f0102a63:	e8 d8 d5 ff ff       	call   f0100040 <_panic>
f0102a68:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102a6e:	39 f3                	cmp    %esi,%ebx
f0102a70:	75 cf                	jne    f0102a41 <mem_init+0x158f>
f0102a72:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0102a75:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f0102a7c:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f0102a83:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102a89:	81 fe 00 10 27 f0    	cmp    $0xf0271000,%esi
f0102a8f:	0f 85 2d ff ff ff    	jne    f01029c2 <mem_init+0x1510>
f0102a95:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a9a:	eb 2a                	jmp    f0102ac6 <mem_init+0x1614>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a9c:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102aa2:	83 fa 04             	cmp    $0x4,%edx
f0102aa5:	77 1f                	ja     f0102ac6 <mem_init+0x1614>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102aa7:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102aab:	75 7e                	jne    f0102b2b <mem_init+0x1679>
f0102aad:	68 74 75 10 f0       	push   $0xf0107574
f0102ab2:	68 a7 72 10 f0       	push   $0xf01072a7
f0102ab7:	68 8d 03 00 00       	push   $0x38d
f0102abc:	68 81 72 10 f0       	push   $0xf0107281
f0102ac1:	e8 7a d5 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102ac6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102acb:	76 3f                	jbe    f0102b0c <mem_init+0x165a>
				assert(pgdir[i] & PTE_P);
f0102acd:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ad0:	f6 c2 01             	test   $0x1,%dl
f0102ad3:	75 19                	jne    f0102aee <mem_init+0x163c>
f0102ad5:	68 74 75 10 f0       	push   $0xf0107574
f0102ada:	68 a7 72 10 f0       	push   $0xf01072a7
f0102adf:	68 91 03 00 00       	push   $0x391
f0102ae4:	68 81 72 10 f0       	push   $0xf0107281
f0102ae9:	e8 52 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102aee:	f6 c2 02             	test   $0x2,%dl
f0102af1:	75 38                	jne    f0102b2b <mem_init+0x1679>
f0102af3:	68 85 75 10 f0       	push   $0xf0107585
f0102af8:	68 a7 72 10 f0       	push   $0xf01072a7
f0102afd:	68 92 03 00 00       	push   $0x392
f0102b02:	68 81 72 10 f0       	push   $0xf0107281
f0102b07:	e8 34 d5 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102b0c:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102b10:	74 19                	je     f0102b2b <mem_init+0x1679>
f0102b12:	68 96 75 10 f0       	push   $0xf0107596
f0102b17:	68 a7 72 10 f0       	push   $0xf01072a7
f0102b1c:	68 94 03 00 00       	push   $0x394
f0102b21:	68 81 72 10 f0       	push   $0xf0107281
f0102b26:	e8 15 d5 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102b2b:	83 c0 01             	add    $0x1,%eax
f0102b2e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102b33:	0f 86 63 ff ff ff    	jbe    f0102a9c <mem_init+0x15ea>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b39:	83 ec 0c             	sub    $0xc,%esp
f0102b3c:	68 8c 71 10 f0       	push   $0xf010718c
f0102b41:	e8 1d 0d 00 00       	call   f0103863 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102b46:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b4b:	83 c4 10             	add    $0x10,%esp
f0102b4e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b53:	77 15                	ja     f0102b6a <mem_init+0x16b8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b55:	50                   	push   %eax
f0102b56:	68 68 62 10 f0       	push   $0xf0106268
f0102b5b:	68 ea 00 00 00       	push   $0xea
f0102b60:	68 81 72 10 f0       	push   $0xf0107281
f0102b65:	e8 d6 d4 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b6a:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b6f:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b72:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b77:	e8 4f e1 ff ff       	call   f0100ccb <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b7c:	0f 20 c0             	mov    %cr0,%eax
f0102b7f:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b82:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102b87:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b8a:	83 ec 0c             	sub    $0xc,%esp
f0102b8d:	6a 00                	push   $0x0
f0102b8f:	e8 60 e5 ff ff       	call   f01010f4 <page_alloc>
f0102b94:	89 c3                	mov    %eax,%ebx
f0102b96:	83 c4 10             	add    $0x10,%esp
f0102b99:	85 c0                	test   %eax,%eax
f0102b9b:	75 19                	jne    f0102bb6 <mem_init+0x1704>
f0102b9d:	68 80 73 10 f0       	push   $0xf0107380
f0102ba2:	68 a7 72 10 f0       	push   $0xf01072a7
f0102ba7:	68 6c 04 00 00       	push   $0x46c
f0102bac:	68 81 72 10 f0       	push   $0xf0107281
f0102bb1:	e8 8a d4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102bb6:	83 ec 0c             	sub    $0xc,%esp
f0102bb9:	6a 00                	push   $0x0
f0102bbb:	e8 34 e5 ff ff       	call   f01010f4 <page_alloc>
f0102bc0:	89 c7                	mov    %eax,%edi
f0102bc2:	83 c4 10             	add    $0x10,%esp
f0102bc5:	85 c0                	test   %eax,%eax
f0102bc7:	75 19                	jne    f0102be2 <mem_init+0x1730>
f0102bc9:	68 96 73 10 f0       	push   $0xf0107396
f0102bce:	68 a7 72 10 f0       	push   $0xf01072a7
f0102bd3:	68 6d 04 00 00       	push   $0x46d
f0102bd8:	68 81 72 10 f0       	push   $0xf0107281
f0102bdd:	e8 5e d4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102be2:	83 ec 0c             	sub    $0xc,%esp
f0102be5:	6a 00                	push   $0x0
f0102be7:	e8 08 e5 ff ff       	call   f01010f4 <page_alloc>
f0102bec:	89 c6                	mov    %eax,%esi
f0102bee:	83 c4 10             	add    $0x10,%esp
f0102bf1:	85 c0                	test   %eax,%eax
f0102bf3:	75 19                	jne    f0102c0e <mem_init+0x175c>
f0102bf5:	68 ac 73 10 f0       	push   $0xf01073ac
f0102bfa:	68 a7 72 10 f0       	push   $0xf01072a7
f0102bff:	68 6e 04 00 00       	push   $0x46e
f0102c04:	68 81 72 10 f0       	push   $0xf0107281
f0102c09:	e8 32 d4 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102c0e:	83 ec 0c             	sub    $0xc,%esp
f0102c11:	53                   	push   %ebx
f0102c12:	e8 4d e5 ff ff       	call   f0101164 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c17:	89 f8                	mov    %edi,%eax
f0102c19:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102c1f:	c1 f8 03             	sar    $0x3,%eax
f0102c22:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c25:	89 c2                	mov    %eax,%edx
f0102c27:	c1 ea 0c             	shr    $0xc,%edx
f0102c2a:	83 c4 10             	add    $0x10,%esp
f0102c2d:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c33:	72 12                	jb     f0102c47 <mem_init+0x1795>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c35:	50                   	push   %eax
f0102c36:	68 44 62 10 f0       	push   $0xf0106244
f0102c3b:	6a 58                	push   $0x58
f0102c3d:	68 8d 72 10 f0       	push   $0xf010728d
f0102c42:	e8 f9 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102c47:	83 ec 04             	sub    $0x4,%esp
f0102c4a:	68 00 10 00 00       	push   $0x1000
f0102c4f:	6a 01                	push   $0x1
f0102c51:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c56:	50                   	push   %eax
f0102c57:	e8 fd 28 00 00       	call   f0105559 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c5c:	89 f0                	mov    %esi,%eax
f0102c5e:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102c64:	c1 f8 03             	sar    $0x3,%eax
f0102c67:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c6a:	89 c2                	mov    %eax,%edx
f0102c6c:	c1 ea 0c             	shr    $0xc,%edx
f0102c6f:	83 c4 10             	add    $0x10,%esp
f0102c72:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102c78:	72 12                	jb     f0102c8c <mem_init+0x17da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c7a:	50                   	push   %eax
f0102c7b:	68 44 62 10 f0       	push   $0xf0106244
f0102c80:	6a 58                	push   $0x58
f0102c82:	68 8d 72 10 f0       	push   $0xf010728d
f0102c87:	e8 b4 d3 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c8c:	83 ec 04             	sub    $0x4,%esp
f0102c8f:	68 00 10 00 00       	push   $0x1000
f0102c94:	6a 02                	push   $0x2
f0102c96:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c9b:	50                   	push   %eax
f0102c9c:	e8 b8 28 00 00       	call   f0105559 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ca1:	6a 02                	push   $0x2
f0102ca3:	68 00 10 00 00       	push   $0x1000
f0102ca8:	57                   	push   %edi
f0102ca9:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102caf:	e8 35 e7 ff ff       	call   f01013e9 <page_insert>
	assert(pp1->pp_ref == 1);
f0102cb4:	83 c4 20             	add    $0x20,%esp
f0102cb7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102cbc:	74 19                	je     f0102cd7 <mem_init+0x1825>
f0102cbe:	68 7d 74 10 f0       	push   $0xf010747d
f0102cc3:	68 a7 72 10 f0       	push   $0xf01072a7
f0102cc8:	68 73 04 00 00       	push   $0x473
f0102ccd:	68 81 72 10 f0       	push   $0xf0107281
f0102cd2:	e8 69 d3 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cd7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102cde:	01 01 01 
f0102ce1:	74 19                	je     f0102cfc <mem_init+0x184a>
f0102ce3:	68 ac 71 10 f0       	push   $0xf01071ac
f0102ce8:	68 a7 72 10 f0       	push   $0xf01072a7
f0102ced:	68 74 04 00 00       	push   $0x474
f0102cf2:	68 81 72 10 f0       	push   $0xf0107281
f0102cf7:	e8 44 d3 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cfc:	6a 02                	push   $0x2
f0102cfe:	68 00 10 00 00       	push   $0x1000
f0102d03:	56                   	push   %esi
f0102d04:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102d0a:	e8 da e6 ff ff       	call   f01013e9 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d0f:	83 c4 10             	add    $0x10,%esp
f0102d12:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102d19:	02 02 02 
f0102d1c:	74 19                	je     f0102d37 <mem_init+0x1885>
f0102d1e:	68 d0 71 10 f0       	push   $0xf01071d0
f0102d23:	68 a7 72 10 f0       	push   $0xf01072a7
f0102d28:	68 76 04 00 00       	push   $0x476
f0102d2d:	68 81 72 10 f0       	push   $0xf0107281
f0102d32:	e8 09 d3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102d37:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d3c:	74 19                	je     f0102d57 <mem_init+0x18a5>
f0102d3e:	68 9f 74 10 f0       	push   $0xf010749f
f0102d43:	68 a7 72 10 f0       	push   $0xf01072a7
f0102d48:	68 77 04 00 00       	push   $0x477
f0102d4d:	68 81 72 10 f0       	push   $0xf0107281
f0102d52:	e8 e9 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102d57:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d5c:	74 19                	je     f0102d77 <mem_init+0x18c5>
f0102d5e:	68 09 75 10 f0       	push   $0xf0107509
f0102d63:	68 a7 72 10 f0       	push   $0xf01072a7
f0102d68:	68 78 04 00 00       	push   $0x478
f0102d6d:	68 81 72 10 f0       	push   $0xf0107281
f0102d72:	e8 c9 d2 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d77:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d7e:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d81:	89 f0                	mov    %esi,%eax
f0102d83:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102d89:	c1 f8 03             	sar    $0x3,%eax
f0102d8c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d8f:	89 c2                	mov    %eax,%edx
f0102d91:	c1 ea 0c             	shr    $0xc,%edx
f0102d94:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0102d9a:	72 12                	jb     f0102dae <mem_init+0x18fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d9c:	50                   	push   %eax
f0102d9d:	68 44 62 10 f0       	push   $0xf0106244
f0102da2:	6a 58                	push   $0x58
f0102da4:	68 8d 72 10 f0       	push   $0xf010728d
f0102da9:	e8 92 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102dae:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102db5:	03 03 03 
f0102db8:	74 19                	je     f0102dd3 <mem_init+0x1921>
f0102dba:	68 f4 71 10 f0       	push   $0xf01071f4
f0102dbf:	68 a7 72 10 f0       	push   $0xf01072a7
f0102dc4:	68 7a 04 00 00       	push   $0x47a
f0102dc9:	68 81 72 10 f0       	push   $0xf0107281
f0102dce:	e8 6d d2 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102dd3:	83 ec 08             	sub    $0x8,%esp
f0102dd6:	68 00 10 00 00       	push   $0x1000
f0102ddb:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f0102de1:	e8 bd e5 ff ff       	call   f01013a3 <page_remove>
	assert(pp2->pp_ref == 0);
f0102de6:	83 c4 10             	add    $0x10,%esp
f0102de9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102dee:	74 19                	je     f0102e09 <mem_init+0x1957>
f0102df0:	68 d7 74 10 f0       	push   $0xf01074d7
f0102df5:	68 a7 72 10 f0       	push   $0xf01072a7
f0102dfa:	68 7c 04 00 00       	push   $0x47c
f0102dff:	68 81 72 10 f0       	push   $0xf0107281
f0102e04:	e8 37 d2 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e09:	8b 0d 8c fe 22 f0    	mov    0xf022fe8c,%ecx
f0102e0f:	8b 11                	mov    (%ecx),%edx
f0102e11:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102e17:	89 d8                	mov    %ebx,%eax
f0102e19:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0102e1f:	c1 f8 03             	sar    $0x3,%eax
f0102e22:	c1 e0 0c             	shl    $0xc,%eax
f0102e25:	39 c2                	cmp    %eax,%edx
f0102e27:	74 19                	je     f0102e42 <mem_init+0x1990>
f0102e29:	68 54 6b 10 f0       	push   $0xf0106b54
f0102e2e:	68 a7 72 10 f0       	push   $0xf01072a7
f0102e33:	68 7f 04 00 00       	push   $0x47f
f0102e38:	68 81 72 10 f0       	push   $0xf0107281
f0102e3d:	e8 fe d1 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102e42:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102e48:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e4d:	74 19                	je     f0102e68 <mem_init+0x19b6>
f0102e4f:	68 8e 74 10 f0       	push   $0xf010748e
f0102e54:	68 a7 72 10 f0       	push   $0xf01072a7
f0102e59:	68 81 04 00 00       	push   $0x481
f0102e5e:	68 81 72 10 f0       	push   $0xf0107281
f0102e63:	e8 d8 d1 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102e68:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e6e:	83 ec 0c             	sub    $0xc,%esp
f0102e71:	53                   	push   %ebx
f0102e72:	e8 ed e2 ff ff       	call   f0101164 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e77:	c7 04 24 20 72 10 f0 	movl   $0xf0107220,(%esp)
f0102e7e:	e8 e0 09 00 00       	call   f0103863 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e83:	83 c4 10             	add    $0x10,%esp
f0102e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e89:	5b                   	pop    %ebx
f0102e8a:	5e                   	pop    %esi
f0102e8b:	5f                   	pop    %edi
f0102e8c:	5d                   	pop    %ebp
f0102e8d:	c3                   	ret    

f0102e8e <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e8e:	55                   	push   %ebp
f0102e8f:	89 e5                	mov    %esp,%ebp
f0102e91:	57                   	push   %edi
f0102e92:	56                   	push   %esi
f0102e93:	53                   	push   %ebx
f0102e94:	83 ec 1c             	sub    $0x1c,%esp
f0102e97:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
f0102e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e9d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102ea2:	89 c3                	mov    %eax,%ebx
f0102ea4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0102ea7:	8b 45 10             	mov    0x10(%ebp),%eax
f0102eaa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102ead:	8d 84 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%eax
f0102eb4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102eb9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
f0102ebc:	8b 75 14             	mov    0x14(%ebp),%esi
f0102ebf:	83 ce 01             	or     $0x1,%esi
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
f0102ec2:	eb 4c                	jmp    f0102f10 <user_mem_check+0x82>
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
f0102ec4:	83 ec 04             	sub    $0x4,%esp
f0102ec7:	6a 00                	push   $0x0
f0102ec9:	53                   	push   %ebx
f0102eca:	ff 77 60             	pushl  0x60(%edi)
f0102ecd:	e8 f4 e2 ff ff       	call   f01011c6 <pgdir_walk>
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
f0102ed2:	83 c4 10             	add    $0x10,%esp
f0102ed5:	85 c0                	test   %eax,%eax
f0102ed7:	74 10                	je     f0102ee9 <user_mem_check+0x5b>
f0102ed9:	89 f2                	mov    %esi,%edx
f0102edb:	23 10                	and    (%eax),%edx
f0102edd:	39 f2                	cmp    %esi,%edx
f0102edf:	75 08                	jne    f0102ee9 <user_mem_check+0x5b>
f0102ee1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102ee7:	76 21                	jbe    f0102f0a <user_mem_check+0x7c>
			if (cur_va == start_va) {
f0102ee9:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102eec:	75 0f                	jne    f0102efd <user_mem_check+0x6f>
				user_mem_check_addr = (uintptr_t)va;
f0102eee:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ef1:	a3 3c f2 22 f0       	mov    %eax,0xf022f23c
			} else {
				user_mem_check_addr = cur_va;
			}
			return -E_FAULT;
f0102ef6:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102efb:	eb 1d                	jmp    f0102f1a <user_mem_check+0x8c>
		pte_t *cur_pte = pgdir_walk(env->env_pgdir, (void *)cur_va, 0);
		if (cur_pte == NULL || (*cur_pte & (perm|PTE_P)) != (perm|PTE_P) || cur_va >= ULIM) {
			if (cur_va == start_va) {
				user_mem_check_addr = (uintptr_t)va;
			} else {
				user_mem_check_addr = cur_va;
f0102efd:	89 1d 3c f2 22 f0    	mov    %ebx,0xf022f23c
			}
			return -E_FAULT;
f0102f03:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f08:	eb 10                	jmp    f0102f1a <user_mem_check+0x8c>
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	uintptr_t start_va = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t end_va = ROUNDUP((uintptr_t)va + len, PGSIZE);
	for (uintptr_t cur_va=start_va; cur_va<end_va; cur_va+=PGSIZE) {
f0102f0a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f10:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102f13:	72 af                	jb     f0102ec4 <user_mem_check+0x36>
				user_mem_check_addr = cur_va;
			}
			return -E_FAULT;
		}
	}
	return 0;
f0102f15:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f1d:	5b                   	pop    %ebx
f0102f1e:	5e                   	pop    %esi
f0102f1f:	5f                   	pop    %edi
f0102f20:	5d                   	pop    %ebp
f0102f21:	c3                   	ret    

f0102f22 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f22:	55                   	push   %ebp
f0102f23:	89 e5                	mov    %esp,%ebp
f0102f25:	53                   	push   %ebx
f0102f26:	83 ec 04             	sub    $0x4,%esp
f0102f29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f2f:	83 c8 04             	or     $0x4,%eax
f0102f32:	50                   	push   %eax
f0102f33:	ff 75 10             	pushl  0x10(%ebp)
f0102f36:	ff 75 0c             	pushl  0xc(%ebp)
f0102f39:	53                   	push   %ebx
f0102f3a:	e8 4f ff ff ff       	call   f0102e8e <user_mem_check>
f0102f3f:	83 c4 10             	add    $0x10,%esp
f0102f42:	85 c0                	test   %eax,%eax
f0102f44:	79 21                	jns    f0102f67 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f46:	83 ec 04             	sub    $0x4,%esp
f0102f49:	ff 35 3c f2 22 f0    	pushl  0xf022f23c
f0102f4f:	ff 73 48             	pushl  0x48(%ebx)
f0102f52:	68 4c 72 10 f0       	push   $0xf010724c
f0102f57:	e8 07 09 00 00       	call   f0103863 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f5c:	89 1c 24             	mov    %ebx,(%esp)
f0102f5f:	e8 46 06 00 00       	call   f01035aa <env_destroy>
f0102f64:	83 c4 10             	add    $0x10,%esp
	}
}
f0102f67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f6a:	c9                   	leave  
f0102f6b:	c3                   	ret    

f0102f6c <region_alloc>:
// Panic if any allocation attempt fails.
//

static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f6c:	55                   	push   %ebp
f0102f6d:	89 e5                	mov    %esp,%ebp
f0102f6f:	57                   	push   %edi
f0102f70:	56                   	push   %esi
f0102f71:	53                   	push   %ebx
f0102f72:	83 ec 1c             	sub    $0x1c,%esp
f0102f75:	89 c7                	mov    %eax,%edi
		va_start += PGSIZE;
	}
	*/
	
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
f0102f77:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102f7e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102f83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	struct PageInfo *pginfo = NULL;
	for (int cur_va=va_start; cur_va<va_end; cur_va+=PGSIZE) {
f0102f86:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102f8c:	89 d3                	mov    %edx,%ebx
f0102f8e:	eb 4c                	jmp    f0102fdc <region_alloc+0x70>
		pginfo = page_alloc(0);
f0102f90:	83 ec 0c             	sub    $0xc,%esp
f0102f93:	6a 00                	push   $0x0
f0102f95:	e8 5a e1 ff ff       	call   f01010f4 <page_alloc>
f0102f9a:	89 c6                	mov    %eax,%esi
		if (!pginfo) {
f0102f9c:	83 c4 10             	add    $0x10,%esp
f0102f9f:	85 c0                	test   %eax,%eax
f0102fa1:	75 16                	jne    f0102fb9 <region_alloc+0x4d>
			int r = -E_NO_MEM;
			panic("region_alloc: %e" , r);
f0102fa3:	6a fc                	push   $0xfffffffc
f0102fa5:	68 a4 75 10 f0       	push   $0xf01075a4
f0102faa:	68 40 01 00 00       	push   $0x140
f0102faf:	68 b5 75 10 f0       	push   $0xf01075b5
f0102fb4:	e8 87 d0 ff ff       	call   f0100040 <_panic>
		}
		cprintf("insert page at %08x\n",cur_va);
f0102fb9:	83 ec 08             	sub    $0x8,%esp
f0102fbc:	53                   	push   %ebx
f0102fbd:	68 c0 75 10 f0       	push   $0xf01075c0
f0102fc2:	e8 9c 08 00 00       	call   f0103863 <cprintf>
		page_insert(e->env_pgdir, pginfo, (void *)cur_va, PTE_U | PTE_W | PTE_P);
f0102fc7:	6a 07                	push   $0x7
f0102fc9:	53                   	push   %ebx
f0102fca:	56                   	push   %esi
f0102fcb:	ff 77 60             	pushl  0x60(%edi)
f0102fce:	e8 16 e4 ff ff       	call   f01013e9 <page_insert>
	*/
	
	uintptr_t va_start = ROUNDDOWN((uintptr_t)va, PGSIZE);
	uintptr_t va_end = ROUNDUP((uintptr_t)va + len, PGSIZE);
	struct PageInfo *pginfo = NULL;
	for (int cur_va=va_start; cur_va<va_end; cur_va+=PGSIZE) {
f0102fd3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fd9:	83 c4 20             	add    $0x20,%esp
f0102fdc:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102fdf:	72 af                	jb     f0102f90 <region_alloc+0x24>
		cprintf("insert page at %08x\n",cur_va);
		page_insert(e->env_pgdir, pginfo, (void *)cur_va, PTE_U | PTE_W | PTE_P);
	}
	
	// cprintf("region allocation completed...\n");
}
f0102fe1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fe4:	5b                   	pop    %ebx
f0102fe5:	5e                   	pop    %esi
f0102fe6:	5f                   	pop    %edi
f0102fe7:	5d                   	pop    %ebp
f0102fe8:	c3                   	ret    

f0102fe9 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102fe9:	55                   	push   %ebp
f0102fea:	89 e5                	mov    %esp,%ebp
f0102fec:	56                   	push   %esi
f0102fed:	53                   	push   %ebx
f0102fee:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ff1:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102ff4:	85 c0                	test   %eax,%eax
f0102ff6:	75 1a                	jne    f0103012 <envid2env+0x29>
		*env_store = curenv;
f0102ff8:	e8 7d 2b 00 00       	call   f0105b7a <cpunum>
f0102ffd:	6b c0 74             	imul   $0x74,%eax,%eax
f0103000:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103006:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103009:	89 01                	mov    %eax,(%ecx)
		return 0;
f010300b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103010:	eb 70                	jmp    f0103082 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103012:	89 c3                	mov    %eax,%ebx
f0103014:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010301a:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f010301d:	03 1d 48 f2 22 f0    	add    0xf022f248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103023:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103027:	74 05                	je     f010302e <envid2env+0x45>
f0103029:	3b 43 48             	cmp    0x48(%ebx),%eax
f010302c:	74 10                	je     f010303e <envid2env+0x55>
		*env_store = 0;
f010302e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103031:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103037:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010303c:	eb 44                	jmp    f0103082 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010303e:	84 d2                	test   %dl,%dl
f0103040:	74 36                	je     f0103078 <envid2env+0x8f>
f0103042:	e8 33 2b 00 00       	call   f0105b7a <cpunum>
f0103047:	6b c0 74             	imul   $0x74,%eax,%eax
f010304a:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f0103050:	74 26                	je     f0103078 <envid2env+0x8f>
f0103052:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103055:	e8 20 2b 00 00       	call   f0105b7a <cpunum>
f010305a:	6b c0 74             	imul   $0x74,%eax,%eax
f010305d:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103063:	3b 70 48             	cmp    0x48(%eax),%esi
f0103066:	74 10                	je     f0103078 <envid2env+0x8f>
		*env_store = 0;
f0103068:	8b 45 0c             	mov    0xc(%ebp),%eax
f010306b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103071:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103076:	eb 0a                	jmp    f0103082 <envid2env+0x99>
	}

	*env_store = e;
f0103078:	8b 45 0c             	mov    0xc(%ebp),%eax
f010307b:	89 18                	mov    %ebx,(%eax)
	return 0;
f010307d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103082:	5b                   	pop    %ebx
f0103083:	5e                   	pop    %esi
f0103084:	5d                   	pop    %ebp
f0103085:	c3                   	ret    

f0103086 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103086:	55                   	push   %ebp
f0103087:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103089:	b8 20 03 12 f0       	mov    $0xf0120320,%eax
f010308e:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103091:	b8 23 00 00 00       	mov    $0x23,%eax
f0103096:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103098:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010309a:	b8 10 00 00 00       	mov    $0x10,%eax
f010309f:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030a1:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030a3:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030a5:	ea ac 30 10 f0 08 00 	ljmp   $0x8,$0xf01030ac
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01030ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01030b1:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01030b4:	5d                   	pop    %ebp
f01030b5:	c3                   	ret    

f01030b6 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01030b6:	55                   	push   %ebp
f01030b7:	89 e5                	mov    %esp,%ebp
f01030b9:	56                   	push   %esi
f01030ba:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i = NENV;
	while (i>0) {
		i--;
		envs[i].env_id = 0;
f01030bb:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
f01030c1:	8b 15 4c f2 22 f0    	mov    0xf022f24c,%edx
f01030c7:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01030cd:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01030d0:	89 c1                	mov    %eax,%ecx
f01030d2:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030d9:	89 50 44             	mov    %edx,0x44(%eax)
f01030dc:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f01030df:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i = NENV;
	while (i>0) {
f01030e1:	39 d8                	cmp    %ebx,%eax
f01030e3:	75 eb                	jne    f01030d0 <env_init+0x1a>
f01030e5:	89 35 4c f2 22 f0    	mov    %esi,0xf022f24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01030eb:	e8 96 ff ff ff       	call   f0103086 <env_init_percpu>
}
f01030f0:	5b                   	pop    %ebx
f01030f1:	5e                   	pop    %esi
f01030f2:	5d                   	pop    %ebp
f01030f3:	c3                   	ret    

f01030f4 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030f4:	55                   	push   %ebp
f01030f5:	89 e5                	mov    %esp,%ebp
f01030f7:	56                   	push   %esi
f01030f8:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01030f9:	8b 1d 4c f2 22 f0    	mov    0xf022f24c,%ebx
f01030ff:	85 db                	test   %ebx,%ebx
f0103101:	0f 84 6b 01 00 00    	je     f0103272 <env_alloc+0x17e>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103107:	83 ec 0c             	sub    $0xc,%esp
f010310a:	6a 01                	push   $0x1
f010310c:	e8 e3 df ff ff       	call   f01010f4 <page_alloc>
f0103111:	89 c6                	mov    %eax,%esi
f0103113:	83 c4 10             	add    $0x10,%esp
f0103116:	85 c0                	test   %eax,%eax
f0103118:	0f 84 5b 01 00 00    	je     f0103279 <env_alloc+0x185>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010311e:	2b 05 90 fe 22 f0    	sub    0xf022fe90,%eax
f0103124:	c1 f8 03             	sar    $0x3,%eax
f0103127:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010312a:	89 c2                	mov    %eax,%edx
f010312c:	c1 ea 0c             	shr    $0xc,%edx
f010312f:	3b 15 88 fe 22 f0    	cmp    0xf022fe88,%edx
f0103135:	72 12                	jb     f0103149 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103137:	50                   	push   %eax
f0103138:	68 44 62 10 f0       	push   $0xf0106244
f010313d:	6a 58                	push   $0x58
f010313f:	68 8d 72 10 f0       	push   $0xf010728d
f0103144:	e8 f7 ce ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103149:	2d 00 00 00 10       	sub    $0x10000000,%eax
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f010314e:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE); // use kern_pgdir as template 
f0103151:	83 ec 04             	sub    $0x4,%esp
f0103154:	68 00 10 00 00       	push   $0x1000
f0103159:	ff 35 8c fe 22 f0    	pushl  0xf022fe8c
f010315f:	50                   	push   %eax
f0103160:	e8 a9 24 00 00       	call   f010560e <memcpy>
	p->pp_ref++;
f0103165:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f010316a:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010316d:	83 c4 10             	add    $0x10,%esp
f0103170:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103175:	77 15                	ja     f010318c <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103177:	50                   	push   %eax
f0103178:	68 68 62 10 f0       	push   $0xf0106268
f010317d:	68 c4 00 00 00       	push   $0xc4
f0103182:	68 b5 75 10 f0       	push   $0xf01075b5
f0103187:	e8 b4 ce ff ff       	call   f0100040 <_panic>
f010318c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103192:	83 ca 05             	or     $0x5,%edx
f0103195:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010319b:	8b 43 48             	mov    0x48(%ebx),%eax
f010319e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031a3:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031a8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031ad:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031b0:	89 da                	mov    %ebx,%edx
f01031b2:	2b 15 48 f2 22 f0    	sub    0xf022f248,%edx
f01031b8:	c1 fa 02             	sar    $0x2,%edx
f01031bb:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031c1:	09 d0                	or     %edx,%eax
f01031c3:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031c9:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031cc:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031d3:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031da:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031e1:	83 ec 04             	sub    $0x4,%esp
f01031e4:	6a 44                	push   $0x44
f01031e6:	6a 00                	push   $0x0
f01031e8:	53                   	push   %ebx
f01031e9:	e8 6b 23 00 00       	call   f0105559 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031ee:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031f4:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031fa:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103200:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103207:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f010320d:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103214:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010321b:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f010321f:	8b 43 44             	mov    0x44(%ebx),%eax
f0103222:	a3 4c f2 22 f0       	mov    %eax,0xf022f24c
	*newenv_store = e;
f0103227:	8b 45 08             	mov    0x8(%ebp),%eax
f010322a:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010322c:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010322f:	e8 46 29 00 00       	call   f0105b7a <cpunum>
f0103234:	6b c0 74             	imul   $0x74,%eax,%eax
f0103237:	83 c4 10             	add    $0x10,%esp
f010323a:	ba 00 00 00 00       	mov    $0x0,%edx
f010323f:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103246:	74 11                	je     f0103259 <env_alloc+0x165>
f0103248:	e8 2d 29 00 00       	call   f0105b7a <cpunum>
f010324d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103250:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103256:	8b 50 48             	mov    0x48(%eax),%edx
f0103259:	83 ec 04             	sub    $0x4,%esp
f010325c:	53                   	push   %ebx
f010325d:	52                   	push   %edx
f010325e:	68 d5 75 10 f0       	push   $0xf01075d5
f0103263:	e8 fb 05 00 00       	call   f0103863 <cprintf>
	return 0;
f0103268:	83 c4 10             	add    $0x10,%esp
f010326b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103270:	eb 0c                	jmp    f010327e <env_alloc+0x18a>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103272:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103277:	eb 05                	jmp    f010327e <env_alloc+0x18a>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103279:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010327e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103281:	5b                   	pop    %ebx
f0103282:	5e                   	pop    %esi
f0103283:	5d                   	pop    %ebp
f0103284:	c3                   	ret    

f0103285 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103285:	55                   	push   %ebp
f0103286:	89 e5                	mov    %esp,%ebp
f0103288:	57                   	push   %edi
f0103289:	56                   	push   %esi
f010328a:	53                   	push   %ebx
f010328b:	83 ec 34             	sub    $0x34,%esp
f010328e:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int r = env_alloc(&e, 0);
f0103291:	6a 00                	push   $0x0
f0103293:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103296:	50                   	push   %eax
f0103297:	e8 58 fe ff ff       	call   f01030f4 <env_alloc>
	if (r<0) {
f010329c:	83 c4 10             	add    $0x10,%esp
f010329f:	85 c0                	test   %eax,%eax
f01032a1:	79 15                	jns    f01032b8 <env_create+0x33>
		panic("env_create: %e",r);
f01032a3:	50                   	push   %eax
f01032a4:	68 ea 75 10 f0       	push   $0xf01075ea
f01032a9:	68 ab 01 00 00       	push   $0x1ab
f01032ae:	68 b5 75 10 f0       	push   $0xf01075b5
f01032b3:	e8 88 cd ff ff       	call   f0100040 <_panic>
	}
	load_icode(e, binary);
f01032b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	
	struct Proghdr *ph, *eph;
	struct Elf *elf = (struct Elf *)binary;
	if (elf->e_magic != ELF_MAGIC) {
f01032be:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032c4:	74 17                	je     f01032dd <env_create+0x58>
		panic("load_icode: not an ELF file");
f01032c6:	83 ec 04             	sub    $0x4,%esp
f01032c9:	68 f9 75 10 f0       	push   $0xf01075f9
f01032ce:	68 83 01 00 00       	push   $0x183
f01032d3:	68 b5 75 10 f0       	push   $0xf01075b5
f01032d8:	e8 63 cd ff ff       	call   f0100040 <_panic>
	}
	ph = (struct Proghdr *)(binary + elf->e_phoff);
f01032dd:	89 fb                	mov    %edi,%ebx
f01032df:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01032e2:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01032e6:	c1 e6 05             	shl    $0x5,%esi
f01032e9:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f01032eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032ee:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f6:	77 15                	ja     f010330d <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032f8:	50                   	push   %eax
f01032f9:	68 68 62 10 f0       	push   $0xf0106268
f01032fe:	68 88 01 00 00       	push   $0x188
f0103303:	68 b5 75 10 f0       	push   $0xf01075b5
f0103308:	e8 33 cd ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010330d:	05 00 00 00 10       	add    $0x10000000,%eax
f0103312:	0f 22 d8             	mov    %eax,%cr3
f0103315:	eb 60                	jmp    f0103377 <env_create+0xf2>
	for (; ph<eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
f0103317:	83 3b 01             	cmpl   $0x1,(%ebx)
f010331a:	75 58                	jne    f0103374 <env_create+0xef>
			if (ph->p_filesz > ph->p_memsz) {
f010331c:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010331f:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103322:	76 17                	jbe    f010333b <env_create+0xb6>
				panic("load_icode: file size is greater than memory size");
f0103324:	83 ec 04             	sub    $0x4,%esp
f0103327:	68 38 76 10 f0       	push   $0xf0107638
f010332c:	68 8c 01 00 00       	push   $0x18c
f0103331:	68 b5 75 10 f0       	push   $0xf01075b5
f0103336:	e8 05 cd ff ff       	call   f0100040 <_panic>
			}
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f010333b:	8b 53 08             	mov    0x8(%ebx),%edx
f010333e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103341:	e8 26 fc ff ff       	call   f0102f6c <region_alloc>
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103346:	83 ec 04             	sub    $0x4,%esp
f0103349:	ff 73 10             	pushl  0x10(%ebx)
f010334c:	89 f8                	mov    %edi,%eax
f010334e:	03 43 04             	add    0x4(%ebx),%eax
f0103351:	50                   	push   %eax
f0103352:	ff 73 08             	pushl  0x8(%ebx)
f0103355:	e8 b4 22 00 00       	call   f010560e <memcpy>
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f010335a:	8b 43 10             	mov    0x10(%ebx),%eax
f010335d:	83 c4 0c             	add    $0xc,%esp
f0103360:	8b 53 14             	mov    0x14(%ebx),%edx
f0103363:	29 c2                	sub    %eax,%edx
f0103365:	52                   	push   %edx
f0103366:	6a 00                	push   $0x0
f0103368:	03 43 08             	add    0x8(%ebx),%eax
f010336b:	50                   	push   %eax
f010336c:	e8 e8 21 00 00       	call   f0105559 <memset>
f0103371:	83 c4 10             	add    $0x10,%esp
	}
	ph = (struct Proghdr *)(binary + elf->e_phoff);
	eph = ph + elf->e_phnum;

	lcr3(PADDR(e->env_pgdir));
	for (; ph<eph; ph++) {
f0103374:	83 c3 20             	add    $0x20,%ebx
f0103377:	39 de                	cmp    %ebx,%esi
f0103379:	77 9c                	ja     f0103317 <env_create+0x92>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memcpy((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
		}
	}
	e->env_tf.tf_eip = elf->e_entry;
f010337b:	8b 47 18             	mov    0x18(%edi),%eax
f010337e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103381:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	
	// LAB 3: Your code here.
	region_alloc(e, (void *) USTACKTOP-PGSIZE, PGSIZE);
f0103384:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103389:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010338e:	89 f8                	mov    %edi,%eax
f0103390:	e8 d7 fb ff ff       	call   f0102f6c <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103395:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010339a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010339f:	77 15                	ja     f01033b6 <env_create+0x131>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033a1:	50                   	push   %eax
f01033a2:	68 68 62 10 f0       	push   $0xf0106268
f01033a7:	68 99 01 00 00       	push   $0x199
f01033ac:	68 b5 75 10 f0       	push   $0xf01075b5
f01033b1:	e8 8a cc ff ff       	call   f0100040 <_panic>
f01033b6:	05 00 00 00 10       	add    $0x10000000,%eax
f01033bb:	0f 22 d8             	mov    %eax,%cr3
	int r = env_alloc(&e, 0);
	if (r<0) {
		panic("env_create: %e",r);
	}
	load_icode(e, binary);
	e->env_type = type;
f01033be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033c4:	89 50 50             	mov    %edx,0x50(%eax)
	// cprintf("*****env created,id = %d, mode = %d****\n", e->env_id, e->env_tf.tf_cs & 3);
}
f01033c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ca:	5b                   	pop    %ebx
f01033cb:	5e                   	pop    %esi
f01033cc:	5f                   	pop    %edi
f01033cd:	5d                   	pop    %ebp
f01033ce:	c3                   	ret    

f01033cf <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033cf:	55                   	push   %ebp
f01033d0:	89 e5                	mov    %esp,%ebp
f01033d2:	57                   	push   %edi
f01033d3:	56                   	push   %esi
f01033d4:	53                   	push   %ebx
f01033d5:	83 ec 1c             	sub    $0x1c,%esp
f01033d8:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033db:	e8 9a 27 00 00       	call   f0105b7a <cpunum>
f01033e0:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e3:	39 b8 28 00 23 f0    	cmp    %edi,-0xfdcffd8(%eax)
f01033e9:	75 29                	jne    f0103414 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01033eb:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033f5:	77 15                	ja     f010340c <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033f7:	50                   	push   %eax
f01033f8:	68 68 62 10 f0       	push   $0xf0106268
f01033fd:	68 c0 01 00 00       	push   $0x1c0
f0103402:	68 b5 75 10 f0       	push   $0xf01075b5
f0103407:	e8 34 cc ff ff       	call   f0100040 <_panic>
f010340c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103411:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103414:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103417:	e8 5e 27 00 00       	call   f0105b7a <cpunum>
f010341c:	6b c0 74             	imul   $0x74,%eax,%eax
f010341f:	ba 00 00 00 00       	mov    $0x0,%edx
f0103424:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010342b:	74 11                	je     f010343e <env_free+0x6f>
f010342d:	e8 48 27 00 00       	call   f0105b7a <cpunum>
f0103432:	6b c0 74             	imul   $0x74,%eax,%eax
f0103435:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010343b:	8b 50 48             	mov    0x48(%eax),%edx
f010343e:	83 ec 04             	sub    $0x4,%esp
f0103441:	53                   	push   %ebx
f0103442:	52                   	push   %edx
f0103443:	68 15 76 10 f0       	push   $0xf0107615
f0103448:	e8 16 04 00 00       	call   f0103863 <cprintf>
f010344d:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103450:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103457:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010345a:	89 d0                	mov    %edx,%eax
f010345c:	c1 e0 02             	shl    $0x2,%eax
f010345f:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103462:	8b 47 60             	mov    0x60(%edi),%eax
f0103465:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103468:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010346e:	0f 84 a8 00 00 00    	je     f010351c <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103474:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010347a:	89 f0                	mov    %esi,%eax
f010347c:	c1 e8 0c             	shr    $0xc,%eax
f010347f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103482:	39 05 88 fe 22 f0    	cmp    %eax,0xf022fe88
f0103488:	77 15                	ja     f010349f <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010348a:	56                   	push   %esi
f010348b:	68 44 62 10 f0       	push   $0xf0106244
f0103490:	68 cf 01 00 00       	push   $0x1cf
f0103495:	68 b5 75 10 f0       	push   $0xf01075b5
f010349a:	e8 a1 cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010349f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034a2:	c1 e0 16             	shl    $0x16,%eax
f01034a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034a8:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034ad:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034b4:	01 
f01034b5:	74 17                	je     f01034ce <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034b7:	83 ec 08             	sub    $0x8,%esp
f01034ba:	89 d8                	mov    %ebx,%eax
f01034bc:	c1 e0 0c             	shl    $0xc,%eax
f01034bf:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034c2:	50                   	push   %eax
f01034c3:	ff 77 60             	pushl  0x60(%edi)
f01034c6:	e8 d8 de ff ff       	call   f01013a3 <page_remove>
f01034cb:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034ce:	83 c3 01             	add    $0x1,%ebx
f01034d1:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034d7:	75 d4                	jne    f01034ad <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034d9:	8b 47 60             	mov    0x60(%edi),%eax
f01034dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034df:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034e9:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f01034ef:	72 14                	jb     f0103505 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01034f1:	83 ec 04             	sub    $0x4,%esp
f01034f4:	68 20 6a 10 f0       	push   $0xf0106a20
f01034f9:	6a 51                	push   $0x51
f01034fb:	68 8d 72 10 f0       	push   $0xf010728d
f0103500:	e8 3b cb ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f0103505:	83 ec 0c             	sub    $0xc,%esp
f0103508:	a1 90 fe 22 f0       	mov    0xf022fe90,%eax
f010350d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103510:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103513:	50                   	push   %eax
f0103514:	e8 86 dc ff ff       	call   f010119f <page_decref>
f0103519:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010351c:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103520:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103523:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103528:	0f 85 29 ff ff ff    	jne    f0103457 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010352e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103531:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103536:	77 15                	ja     f010354d <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103538:	50                   	push   %eax
f0103539:	68 68 62 10 f0       	push   $0xf0106268
f010353e:	68 dd 01 00 00       	push   $0x1dd
f0103543:	68 b5 75 10 f0       	push   $0xf01075b5
f0103548:	e8 f3 ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010354d:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103554:	05 00 00 00 10       	add    $0x10000000,%eax
f0103559:	c1 e8 0c             	shr    $0xc,%eax
f010355c:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f0103562:	72 14                	jb     f0103578 <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103564:	83 ec 04             	sub    $0x4,%esp
f0103567:	68 20 6a 10 f0       	push   $0xf0106a20
f010356c:	6a 51                	push   $0x51
f010356e:	68 8d 72 10 f0       	push   $0xf010728d
f0103573:	e8 c8 ca ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103578:	83 ec 0c             	sub    $0xc,%esp
f010357b:	8b 15 90 fe 22 f0    	mov    0xf022fe90,%edx
f0103581:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103584:	50                   	push   %eax
f0103585:	e8 15 dc ff ff       	call   f010119f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010358a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103591:	a1 4c f2 22 f0       	mov    0xf022f24c,%eax
f0103596:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103599:	89 3d 4c f2 22 f0    	mov    %edi,0xf022f24c
}
f010359f:	83 c4 10             	add    $0x10,%esp
f01035a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035a5:	5b                   	pop    %ebx
f01035a6:	5e                   	pop    %esi
f01035a7:	5f                   	pop    %edi
f01035a8:	5d                   	pop    %ebp
f01035a9:	c3                   	ret    

f01035aa <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035aa:	55                   	push   %ebp
f01035ab:	89 e5                	mov    %esp,%ebp
f01035ad:	53                   	push   %ebx
f01035ae:	83 ec 04             	sub    $0x4,%esp
f01035b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035b4:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035b8:	75 19                	jne    f01035d3 <env_destroy+0x29>
f01035ba:	e8 bb 25 00 00       	call   f0105b7a <cpunum>
f01035bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01035c2:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01035c8:	74 09                	je     f01035d3 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01035ca:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01035d1:	eb 33                	jmp    f0103606 <env_destroy+0x5c>
	}

	env_free(e);
f01035d3:	83 ec 0c             	sub    $0xc,%esp
f01035d6:	53                   	push   %ebx
f01035d7:	e8 f3 fd ff ff       	call   f01033cf <env_free>

	if (curenv == e) {
f01035dc:	e8 99 25 00 00       	call   f0105b7a <cpunum>
f01035e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e4:	83 c4 10             	add    $0x10,%esp
f01035e7:	3b 98 28 00 23 f0    	cmp    -0xfdcffd8(%eax),%ebx
f01035ed:	75 17                	jne    f0103606 <env_destroy+0x5c>
		curenv = NULL;
f01035ef:	e8 86 25 00 00       	call   f0105b7a <cpunum>
f01035f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035f7:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01035fe:	00 00 00 
		sched_yield();
f0103601:	e8 39 0e 00 00       	call   f010443f <sched_yield>
	}
}
f0103606:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103609:	c9                   	leave  
f010360a:	c3                   	ret    

f010360b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010360b:	55                   	push   %ebp
f010360c:	89 e5                	mov    %esp,%ebp
f010360e:	53                   	push   %ebx
f010360f:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103612:	e8 63 25 00 00       	call   f0105b7a <cpunum>
f0103617:	6b c0 74             	imul   $0x74,%eax,%eax
f010361a:	8b 98 28 00 23 f0    	mov    -0xfdcffd8(%eax),%ebx
f0103620:	e8 55 25 00 00       	call   f0105b7a <cpunum>
f0103625:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103628:	8b 65 08             	mov    0x8(%ebp),%esp
f010362b:	61                   	popa   
f010362c:	07                   	pop    %es
f010362d:	1f                   	pop    %ds
f010362e:	83 c4 08             	add    $0x8,%esp
f0103631:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103632:	83 ec 04             	sub    $0x4,%esp
f0103635:	68 2b 76 10 f0       	push   $0xf010762b
f010363a:	68 14 02 00 00       	push   $0x214
f010363f:	68 b5 75 10 f0       	push   $0xf01075b5
f0103644:	e8 f7 c9 ff ff       	call   f0100040 <_panic>

f0103649 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103649:	55                   	push   %ebp
f010364a:	89 e5                	mov    %esp,%ebp
f010364c:	53                   	push   %ebx
f010364d:	83 ec 04             	sub    $0x4,%esp
f0103650:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// panic("env_run not yet implemented");
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0103653:	e8 22 25 00 00       	call   f0105b7a <cpunum>
f0103658:	6b c0 74             	imul   $0x74,%eax,%eax
f010365b:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f0103662:	74 29                	je     f010368d <env_run+0x44>
f0103664:	e8 11 25 00 00       	call   f0105b7a <cpunum>
f0103669:	6b c0 74             	imul   $0x74,%eax,%eax
f010366c:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103672:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103676:	75 15                	jne    f010368d <env_run+0x44>
		curenv->env_status = ENV_RUNNABLE;
f0103678:	e8 fd 24 00 00       	call   f0105b7a <cpunum>
f010367d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103680:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103686:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;
f010368d:	e8 e8 24 00 00       	call   f0105b7a <cpunum>
f0103692:	6b c0 74             	imul   $0x74,%eax,%eax
f0103695:	89 98 28 00 23 f0    	mov    %ebx,-0xfdcffd8(%eax)
	e->env_status = ENV_RUNNING;
f010369b:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f01036a2:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f01036a6:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036ae:	77 15                	ja     f01036c5 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036b0:	50                   	push   %eax
f01036b1:	68 68 62 10 f0       	push   $0xf0106268
f01036b6:	68 39 02 00 00       	push   $0x239
f01036bb:	68 b5 75 10 f0       	push   $0xf01075b5
f01036c0:	e8 7b c9 ff ff       	call   f0100040 <_panic>
f01036c5:	05 00 00 00 10       	add    $0x10000000,%eax
f01036ca:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036cd:	83 ec 0c             	sub    $0xc,%esp
f01036d0:	68 c0 03 12 f0       	push   $0xf01203c0
f01036d5:	e8 ab 27 00 00       	call   f0105e85 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036da:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&e->env_tf);
f01036dc:	89 1c 24             	mov    %ebx,(%esp)
f01036df:	e8 27 ff ff ff       	call   f010360b <env_pop_tf>

f01036e4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01036e4:	55                   	push   %ebp
f01036e5:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036e7:	ba 70 00 00 00       	mov    $0x70,%edx
f01036ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ef:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01036f0:	ba 71 00 00 00       	mov    $0x71,%edx
f01036f5:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01036f6:	0f b6 c0             	movzbl %al,%eax
}
f01036f9:	5d                   	pop    %ebp
f01036fa:	c3                   	ret    

f01036fb <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01036fb:	55                   	push   %ebp
f01036fc:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036fe:	ba 70 00 00 00       	mov    $0x70,%edx
f0103703:	8b 45 08             	mov    0x8(%ebp),%eax
f0103706:	ee                   	out    %al,(%dx)
f0103707:	ba 71 00 00 00       	mov    $0x71,%edx
f010370c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010370f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103710:	5d                   	pop    %ebp
f0103711:	c3                   	ret    

f0103712 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103712:	55                   	push   %ebp
f0103713:	89 e5                	mov    %esp,%ebp
f0103715:	56                   	push   %esi
f0103716:	53                   	push   %ebx
f0103717:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010371a:	66 a3 a8 03 12 f0    	mov    %ax,0xf01203a8
	if (!didinit)
f0103720:	80 3d 50 f2 22 f0 00 	cmpb   $0x0,0xf022f250
f0103727:	74 5a                	je     f0103783 <irq_setmask_8259A+0x71>
f0103729:	89 c6                	mov    %eax,%esi
f010372b:	ba 21 00 00 00       	mov    $0x21,%edx
f0103730:	ee                   	out    %al,(%dx)
f0103731:	66 c1 e8 08          	shr    $0x8,%ax
f0103735:	ba a1 00 00 00       	mov    $0xa1,%edx
f010373a:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010373b:	83 ec 0c             	sub    $0xc,%esp
f010373e:	68 6a 76 10 f0       	push   $0xf010766a
f0103743:	e8 1b 01 00 00       	call   f0103863 <cprintf>
f0103748:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010374b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103750:	0f b7 f6             	movzwl %si,%esi
f0103753:	f7 d6                	not    %esi
f0103755:	0f a3 de             	bt     %ebx,%esi
f0103758:	73 11                	jae    f010376b <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010375a:	83 ec 08             	sub    $0x8,%esp
f010375d:	53                   	push   %ebx
f010375e:	68 3b 7b 10 f0       	push   $0xf0107b3b
f0103763:	e8 fb 00 00 00       	call   f0103863 <cprintf>
f0103768:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010376b:	83 c3 01             	add    $0x1,%ebx
f010376e:	83 fb 10             	cmp    $0x10,%ebx
f0103771:	75 e2                	jne    f0103755 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103773:	83 ec 0c             	sub    $0xc,%esp
f0103776:	68 72 75 10 f0       	push   $0xf0107572
f010377b:	e8 e3 00 00 00       	call   f0103863 <cprintf>
f0103780:	83 c4 10             	add    $0x10,%esp
}
f0103783:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103786:	5b                   	pop    %ebx
f0103787:	5e                   	pop    %esi
f0103788:	5d                   	pop    %ebp
f0103789:	c3                   	ret    

f010378a <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010378a:	c6 05 50 f2 22 f0 01 	movb   $0x1,0xf022f250
f0103791:	ba 21 00 00 00       	mov    $0x21,%edx
f0103796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010379b:	ee                   	out    %al,(%dx)
f010379c:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037a1:	ee                   	out    %al,(%dx)
f01037a2:	ba 20 00 00 00       	mov    $0x20,%edx
f01037a7:	b8 11 00 00 00       	mov    $0x11,%eax
f01037ac:	ee                   	out    %al,(%dx)
f01037ad:	ba 21 00 00 00       	mov    $0x21,%edx
f01037b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01037b7:	ee                   	out    %al,(%dx)
f01037b8:	b8 04 00 00 00       	mov    $0x4,%eax
f01037bd:	ee                   	out    %al,(%dx)
f01037be:	b8 03 00 00 00       	mov    $0x3,%eax
f01037c3:	ee                   	out    %al,(%dx)
f01037c4:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037c9:	b8 11 00 00 00       	mov    $0x11,%eax
f01037ce:	ee                   	out    %al,(%dx)
f01037cf:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037d4:	b8 28 00 00 00       	mov    $0x28,%eax
f01037d9:	ee                   	out    %al,(%dx)
f01037da:	b8 02 00 00 00       	mov    $0x2,%eax
f01037df:	ee                   	out    %al,(%dx)
f01037e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01037e5:	ee                   	out    %al,(%dx)
f01037e6:	ba 20 00 00 00       	mov    $0x20,%edx
f01037eb:	b8 68 00 00 00       	mov    $0x68,%eax
f01037f0:	ee                   	out    %al,(%dx)
f01037f1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01037f6:	ee                   	out    %al,(%dx)
f01037f7:	ba a0 00 00 00       	mov    $0xa0,%edx
f01037fc:	b8 68 00 00 00       	mov    $0x68,%eax
f0103801:	ee                   	out    %al,(%dx)
f0103802:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103807:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103808:	0f b7 05 a8 03 12 f0 	movzwl 0xf01203a8,%eax
f010380f:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103813:	74 13                	je     f0103828 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103815:	55                   	push   %ebp
f0103816:	89 e5                	mov    %esp,%ebp
f0103818:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010381b:	0f b7 c0             	movzwl %ax,%eax
f010381e:	50                   	push   %eax
f010381f:	e8 ee fe ff ff       	call   f0103712 <irq_setmask_8259A>
f0103824:	83 c4 10             	add    $0x10,%esp
}
f0103827:	c9                   	leave  
f0103828:	f3 c3                	repz ret 

f010382a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010382a:	55                   	push   %ebp
f010382b:	89 e5                	mov    %esp,%ebp
f010382d:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103830:	ff 75 08             	pushl  0x8(%ebp)
f0103833:	e8 2c cf ff ff       	call   f0100764 <cputchar>
	*cnt++;
}
f0103838:	83 c4 10             	add    $0x10,%esp
f010383b:	c9                   	leave  
f010383c:	c3                   	ret    

f010383d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010383d:	55                   	push   %ebp
f010383e:	89 e5                	mov    %esp,%ebp
f0103840:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103843:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010384a:	ff 75 0c             	pushl  0xc(%ebp)
f010384d:	ff 75 08             	pushl  0x8(%ebp)
f0103850:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103853:	50                   	push   %eax
f0103854:	68 2a 38 10 f0       	push   $0xf010382a
f0103859:	e8 8f 16 00 00       	call   f0104eed <vprintfmt>
	return cnt;
}
f010385e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103861:	c9                   	leave  
f0103862:	c3                   	ret    

f0103863 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103863:	55                   	push   %ebp
f0103864:	89 e5                	mov    %esp,%ebp
f0103866:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103869:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010386c:	50                   	push   %eax
f010386d:	ff 75 08             	pushl  0x8(%ebp)
f0103870:	e8 c8 ff ff ff       	call   f010383d <vcprintf>
	va_end(ap);

	return cnt;
}
f0103875:	c9                   	leave  
f0103876:	c3                   	ret    

f0103877 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103877:	55                   	push   %ebp
f0103878:	89 e5                	mov    %esp,%ebp
f010387a:	56                   	push   %esi
f010387b:	53                   	push   %ebx
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:

	struct Taskstate* this_ts = &thiscpu->cpu_ts;
f010387c:	e8 f9 22 00 00       	call   f0105b7a <cpunum>
f0103881:	6b f0 74             	imul   $0x74,%eax,%esi
f0103884:	8d 9e 2c 00 23 f0    	lea    -0xfdcffd4(%esi),%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	this_ts->ts_esp0 = KSTACKTOP - thiscpu->cpu_id*(KSTKSIZE + KSTKGAP);
f010388a:	e8 eb 22 00 00       	call   f0105b7a <cpunum>
f010388f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103892:	0f b6 90 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%edx
f0103899:	c1 e2 10             	shl    $0x10,%edx
f010389c:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f01038a1:	29 d0                	sub    %edx,%eax
f01038a3:	89 86 30 00 23 f0    	mov    %eax,-0xfdcffd0(%esi)
	this_ts->ts_ss0 = GD_KD;
f01038a9:	66 c7 86 34 00 23 f0 	movw   $0x10,-0xfdcffcc(%esi)
f01038b0:	10 00 
	this_ts->ts_iomb = sizeof(struct Taskstate);
f01038b2:	66 c7 86 92 00 23 f0 	movw   $0x68,-0xfdcff6e(%esi)
f01038b9:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (this_ts),
f01038bb:	e8 ba 22 00 00       	call   f0105b7a <cpunum>
f01038c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01038c3:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f01038ca:	83 c0 05             	add    $0x5,%eax
f01038cd:	66 c7 04 c5 40 03 12 	movw   $0x67,-0xfedfcc0(,%eax,8)
f01038d4:	f0 67 00 
f01038d7:	66 89 1c c5 42 03 12 	mov    %bx,-0xfedfcbe(,%eax,8)
f01038de:	f0 
f01038df:	89 da                	mov    %ebx,%edx
f01038e1:	c1 ea 10             	shr    $0x10,%edx
f01038e4:	88 14 c5 44 03 12 f0 	mov    %dl,-0xfedfcbc(,%eax,8)
f01038eb:	c6 04 c5 45 03 12 f0 	movb   $0x99,-0xfedfcbb(,%eax,8)
f01038f2:	99 
f01038f3:	c6 04 c5 46 03 12 f0 	movb   $0x40,-0xfedfcba(,%eax,8)
f01038fa:	40 
f01038fb:	c1 eb 18             	shr    $0x18,%ebx
f01038fe:	88 1c c5 47 03 12 f0 	mov    %bl,-0xfedfcb9(,%eax,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0103905:	e8 70 22 00 00       	call   f0105b7a <cpunum>
f010390a:	6b c0 74             	imul   $0x74,%eax,%eax
f010390d:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f0103914:	80 24 c5 6d 03 12 f0 	andb   $0xef,-0xfedfc93(,%eax,8)
f010391b:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f010391c:	e8 59 22 00 00       	call   f0105b7a <cpunum>
f0103921:	6b c0 74             	imul   $0x74,%eax,%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103924:	0f b6 80 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%eax
f010392b:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103932:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103935:	b8 ac 03 12 f0       	mov    $0xf01203ac,%eax
f010393a:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);

}
f010393d:	5b                   	pop    %ebx
f010393e:	5e                   	pop    %esi
f010393f:	5d                   	pop    %ebp
f0103940:	c3                   	ret    

f0103941 <trap_init>:
}


void
trap_init(void)
{
f0103941:	55                   	push   %ebp
f0103942:	89 e5                	mov    %esp,%ebp
f0103944:	83 ec 08             	sub    $0x8,%esp
	void handler36();
	void handler39();
	void handler46();
	void handler51();

	SETGATE(idt[T_DIVIDE], 0, GD_KT, handler0, 0);
f0103947:	b8 ce 42 10 f0       	mov    $0xf01042ce,%eax
f010394c:	66 a3 60 f2 22 f0    	mov    %ax,0xf022f260
f0103952:	66 c7 05 62 f2 22 f0 	movw   $0x8,0xf022f262
f0103959:	08 00 
f010395b:	c6 05 64 f2 22 f0 00 	movb   $0x0,0xf022f264
f0103962:	c6 05 65 f2 22 f0 8e 	movb   $0x8e,0xf022f265
f0103969:	c1 e8 10             	shr    $0x10,%eax
f010396c:	66 a3 66 f2 22 f0    	mov    %ax,0xf022f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, handler1, 0);
f0103972:	b8 d8 42 10 f0       	mov    $0xf01042d8,%eax
f0103977:	66 a3 68 f2 22 f0    	mov    %ax,0xf022f268
f010397d:	66 c7 05 6a f2 22 f0 	movw   $0x8,0xf022f26a
f0103984:	08 00 
f0103986:	c6 05 6c f2 22 f0 00 	movb   $0x0,0xf022f26c
f010398d:	c6 05 6d f2 22 f0 8e 	movb   $0x8e,0xf022f26d
f0103994:	c1 e8 10             	shr    $0x10,%eax
f0103997:	66 a3 6e f2 22 f0    	mov    %ax,0xf022f26e
	SETGATE(idt[T_NMI], 0, GD_KT, handler2, 0);
f010399d:	b8 de 42 10 f0       	mov    $0xf01042de,%eax
f01039a2:	66 a3 70 f2 22 f0    	mov    %ax,0xf022f270
f01039a8:	66 c7 05 72 f2 22 f0 	movw   $0x8,0xf022f272
f01039af:	08 00 
f01039b1:	c6 05 74 f2 22 f0 00 	movb   $0x0,0xf022f274
f01039b8:	c6 05 75 f2 22 f0 8e 	movb   $0x8e,0xf022f275
f01039bf:	c1 e8 10             	shr    $0x10,%eax
f01039c2:	66 a3 76 f2 22 f0    	mov    %ax,0xf022f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, handler3, 3);
f01039c8:	b8 e4 42 10 f0       	mov    $0xf01042e4,%eax
f01039cd:	66 a3 78 f2 22 f0    	mov    %ax,0xf022f278
f01039d3:	66 c7 05 7a f2 22 f0 	movw   $0x8,0xf022f27a
f01039da:	08 00 
f01039dc:	c6 05 7c f2 22 f0 00 	movb   $0x0,0xf022f27c
f01039e3:	c6 05 7d f2 22 f0 ee 	movb   $0xee,0xf022f27d
f01039ea:	c1 e8 10             	shr    $0x10,%eax
f01039ed:	66 a3 7e f2 22 f0    	mov    %ax,0xf022f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, handler4, 0);
f01039f3:	b8 ea 42 10 f0       	mov    $0xf01042ea,%eax
f01039f8:	66 a3 80 f2 22 f0    	mov    %ax,0xf022f280
f01039fe:	66 c7 05 82 f2 22 f0 	movw   $0x8,0xf022f282
f0103a05:	08 00 
f0103a07:	c6 05 84 f2 22 f0 00 	movb   $0x0,0xf022f284
f0103a0e:	c6 05 85 f2 22 f0 8e 	movb   $0x8e,0xf022f285
f0103a15:	c1 e8 10             	shr    $0x10,%eax
f0103a18:	66 a3 86 f2 22 f0    	mov    %ax,0xf022f286
	SETGATE(idt[T_BOUND], 0, GD_KT, handler5, 0);
f0103a1e:	b8 f0 42 10 f0       	mov    $0xf01042f0,%eax
f0103a23:	66 a3 88 f2 22 f0    	mov    %ax,0xf022f288
f0103a29:	66 c7 05 8a f2 22 f0 	movw   $0x8,0xf022f28a
f0103a30:	08 00 
f0103a32:	c6 05 8c f2 22 f0 00 	movb   $0x0,0xf022f28c
f0103a39:	c6 05 8d f2 22 f0 8e 	movb   $0x8e,0xf022f28d
f0103a40:	c1 e8 10             	shr    $0x10,%eax
f0103a43:	66 a3 8e f2 22 f0    	mov    %ax,0xf022f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, handler6, 0);
f0103a49:	b8 f6 42 10 f0       	mov    $0xf01042f6,%eax
f0103a4e:	66 a3 90 f2 22 f0    	mov    %ax,0xf022f290
f0103a54:	66 c7 05 92 f2 22 f0 	movw   $0x8,0xf022f292
f0103a5b:	08 00 
f0103a5d:	c6 05 94 f2 22 f0 00 	movb   $0x0,0xf022f294
f0103a64:	c6 05 95 f2 22 f0 8e 	movb   $0x8e,0xf022f295
f0103a6b:	c1 e8 10             	shr    $0x10,%eax
f0103a6e:	66 a3 96 f2 22 f0    	mov    %ax,0xf022f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, handler7, 0);
f0103a74:	b8 fc 42 10 f0       	mov    $0xf01042fc,%eax
f0103a79:	66 a3 98 f2 22 f0    	mov    %ax,0xf022f298
f0103a7f:	66 c7 05 9a f2 22 f0 	movw   $0x8,0xf022f29a
f0103a86:	08 00 
f0103a88:	c6 05 9c f2 22 f0 00 	movb   $0x0,0xf022f29c
f0103a8f:	c6 05 9d f2 22 f0 8e 	movb   $0x8e,0xf022f29d
f0103a96:	c1 e8 10             	shr    $0x10,%eax
f0103a99:	66 a3 9e f2 22 f0    	mov    %ax,0xf022f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, handler8, 0);
f0103a9f:	b8 02 43 10 f0       	mov    $0xf0104302,%eax
f0103aa4:	66 a3 a0 f2 22 f0    	mov    %ax,0xf022f2a0
f0103aaa:	66 c7 05 a2 f2 22 f0 	movw   $0x8,0xf022f2a2
f0103ab1:	08 00 
f0103ab3:	c6 05 a4 f2 22 f0 00 	movb   $0x0,0xf022f2a4
f0103aba:	c6 05 a5 f2 22 f0 8e 	movb   $0x8e,0xf022f2a5
f0103ac1:	c1 e8 10             	shr    $0x10,%eax
f0103ac4:	66 a3 a6 f2 22 f0    	mov    %ax,0xf022f2a6

	SETGATE(idt[T_TSS], 0, GD_KT, handler10, 0);
f0103aca:	b8 06 43 10 f0       	mov    $0xf0104306,%eax
f0103acf:	66 a3 b0 f2 22 f0    	mov    %ax,0xf022f2b0
f0103ad5:	66 c7 05 b2 f2 22 f0 	movw   $0x8,0xf022f2b2
f0103adc:	08 00 
f0103ade:	c6 05 b4 f2 22 f0 00 	movb   $0x0,0xf022f2b4
f0103ae5:	c6 05 b5 f2 22 f0 8e 	movb   $0x8e,0xf022f2b5
f0103aec:	c1 e8 10             	shr    $0x10,%eax
f0103aef:	66 a3 b6 f2 22 f0    	mov    %ax,0xf022f2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, handler11, 0);
f0103af5:	b8 0a 43 10 f0       	mov    $0xf010430a,%eax
f0103afa:	66 a3 b8 f2 22 f0    	mov    %ax,0xf022f2b8
f0103b00:	66 c7 05 ba f2 22 f0 	movw   $0x8,0xf022f2ba
f0103b07:	08 00 
f0103b09:	c6 05 bc f2 22 f0 00 	movb   $0x0,0xf022f2bc
f0103b10:	c6 05 bd f2 22 f0 8e 	movb   $0x8e,0xf022f2bd
f0103b17:	c1 e8 10             	shr    $0x10,%eax
f0103b1a:	66 a3 be f2 22 f0    	mov    %ax,0xf022f2be
	SETGATE(idt[T_STACK], 0, GD_KT, handler12, 0);
f0103b20:	b8 0e 43 10 f0       	mov    $0xf010430e,%eax
f0103b25:	66 a3 c0 f2 22 f0    	mov    %ax,0xf022f2c0
f0103b2b:	66 c7 05 c2 f2 22 f0 	movw   $0x8,0xf022f2c2
f0103b32:	08 00 
f0103b34:	c6 05 c4 f2 22 f0 00 	movb   $0x0,0xf022f2c4
f0103b3b:	c6 05 c5 f2 22 f0 8e 	movb   $0x8e,0xf022f2c5
f0103b42:	c1 e8 10             	shr    $0x10,%eax
f0103b45:	66 a3 c6 f2 22 f0    	mov    %ax,0xf022f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, handler13, 0);
f0103b4b:	b8 12 43 10 f0       	mov    $0xf0104312,%eax
f0103b50:	66 a3 c8 f2 22 f0    	mov    %ax,0xf022f2c8
f0103b56:	66 c7 05 ca f2 22 f0 	movw   $0x8,0xf022f2ca
f0103b5d:	08 00 
f0103b5f:	c6 05 cc f2 22 f0 00 	movb   $0x0,0xf022f2cc
f0103b66:	c6 05 cd f2 22 f0 8e 	movb   $0x8e,0xf022f2cd
f0103b6d:	c1 e8 10             	shr    $0x10,%eax
f0103b70:	66 a3 ce f2 22 f0    	mov    %ax,0xf022f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, handler14, 0);
f0103b76:	b8 16 43 10 f0       	mov    $0xf0104316,%eax
f0103b7b:	66 a3 d0 f2 22 f0    	mov    %ax,0xf022f2d0
f0103b81:	66 c7 05 d2 f2 22 f0 	movw   $0x8,0xf022f2d2
f0103b88:	08 00 
f0103b8a:	c6 05 d4 f2 22 f0 00 	movb   $0x0,0xf022f2d4
f0103b91:	c6 05 d5 f2 22 f0 8e 	movb   $0x8e,0xf022f2d5
f0103b98:	c1 e8 10             	shr    $0x10,%eax
f0103b9b:	66 a3 d6 f2 22 f0    	mov    %ax,0xf022f2d6
	
	SETGATE(idt[T_FPERR], 0, GD_KT, handler16, 0);
f0103ba1:	b8 1a 43 10 f0       	mov    $0xf010431a,%eax
f0103ba6:	66 a3 e0 f2 22 f0    	mov    %ax,0xf022f2e0
f0103bac:	66 c7 05 e2 f2 22 f0 	movw   $0x8,0xf022f2e2
f0103bb3:	08 00 
f0103bb5:	c6 05 e4 f2 22 f0 00 	movb   $0x0,0xf022f2e4
f0103bbc:	c6 05 e5 f2 22 f0 8e 	movb   $0x8e,0xf022f2e5
f0103bc3:	c1 e8 10             	shr    $0x10,%eax
f0103bc6:	66 a3 e6 f2 22 f0    	mov    %ax,0xf022f2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, handler17, 0);
f0103bcc:	b8 20 43 10 f0       	mov    $0xf0104320,%eax
f0103bd1:	66 a3 e8 f2 22 f0    	mov    %ax,0xf022f2e8
f0103bd7:	66 c7 05 ea f2 22 f0 	movw   $0x8,0xf022f2ea
f0103bde:	08 00 
f0103be0:	c6 05 ec f2 22 f0 00 	movb   $0x0,0xf022f2ec
f0103be7:	c6 05 ed f2 22 f0 8e 	movb   $0x8e,0xf022f2ed
f0103bee:	c1 e8 10             	shr    $0x10,%eax
f0103bf1:	66 a3 ee f2 22 f0    	mov    %ax,0xf022f2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, handler18, 0);
f0103bf7:	b8 24 43 10 f0       	mov    $0xf0104324,%eax
f0103bfc:	66 a3 f0 f2 22 f0    	mov    %ax,0xf022f2f0
f0103c02:	66 c7 05 f2 f2 22 f0 	movw   $0x8,0xf022f2f2
f0103c09:	08 00 
f0103c0b:	c6 05 f4 f2 22 f0 00 	movb   $0x0,0xf022f2f4
f0103c12:	c6 05 f5 f2 22 f0 8e 	movb   $0x8e,0xf022f2f5
f0103c19:	c1 e8 10             	shr    $0x10,%eax
f0103c1c:	66 a3 f6 f2 22 f0    	mov    %ax,0xf022f2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, handler19, 0);
f0103c22:	b8 2a 43 10 f0       	mov    $0xf010432a,%eax
f0103c27:	66 a3 f8 f2 22 f0    	mov    %ax,0xf022f2f8
f0103c2d:	66 c7 05 fa f2 22 f0 	movw   $0x8,0xf022f2fa
f0103c34:	08 00 
f0103c36:	c6 05 fc f2 22 f0 00 	movb   $0x0,0xf022f2fc
f0103c3d:	c6 05 fd f2 22 f0 8e 	movb   $0x8e,0xf022f2fd
f0103c44:	c1 e8 10             	shr    $0x10,%eax
f0103c47:	66 a3 fe f2 22 f0    	mov    %ax,0xf022f2fe

	// interrupt
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handler48, 3);
f0103c4d:	b8 30 43 10 f0       	mov    $0xf0104330,%eax
f0103c52:	66 a3 e0 f3 22 f0    	mov    %ax,0xf022f3e0
f0103c58:	66 c7 05 e2 f3 22 f0 	movw   $0x8,0xf022f3e2
f0103c5f:	08 00 
f0103c61:	c6 05 e4 f3 22 f0 00 	movb   $0x0,0xf022f3e4
f0103c68:	c6 05 e5 f3 22 f0 ee 	movb   $0xee,0xf022f3e5
f0103c6f:	c1 e8 10             	shr    $0x10,%eax
f0103c72:	66 a3 e6 f3 22 f0    	mov    %ax,0xf022f3e6

	// IRQs
	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, handler32, 0);
f0103c78:	b8 36 43 10 f0       	mov    $0xf0104336,%eax
f0103c7d:	66 a3 60 f3 22 f0    	mov    %ax,0xf022f360
f0103c83:	66 c7 05 62 f3 22 f0 	movw   $0x8,0xf022f362
f0103c8a:	08 00 
f0103c8c:	c6 05 64 f3 22 f0 00 	movb   $0x0,0xf022f364
f0103c93:	c6 05 65 f3 22 f0 8e 	movb   $0x8e,0xf022f365
f0103c9a:	c1 e8 10             	shr    $0x10,%eax
f0103c9d:	66 a3 66 f3 22 f0    	mov    %ax,0xf022f366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, handler33, 0);
f0103ca3:	b8 3c 43 10 f0       	mov    $0xf010433c,%eax
f0103ca8:	66 a3 68 f3 22 f0    	mov    %ax,0xf022f368
f0103cae:	66 c7 05 6a f3 22 f0 	movw   $0x8,0xf022f36a
f0103cb5:	08 00 
f0103cb7:	c6 05 6c f3 22 f0 00 	movb   $0x0,0xf022f36c
f0103cbe:	c6 05 6d f3 22 f0 8e 	movb   $0x8e,0xf022f36d
f0103cc5:	c1 e8 10             	shr    $0x10,%eax
f0103cc8:	66 a3 6e f3 22 f0    	mov    %ax,0xf022f36e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, handler36, 0);
f0103cce:	b8 42 43 10 f0       	mov    $0xf0104342,%eax
f0103cd3:	66 a3 80 f3 22 f0    	mov    %ax,0xf022f380
f0103cd9:	66 c7 05 82 f3 22 f0 	movw   $0x8,0xf022f382
f0103ce0:	08 00 
f0103ce2:	c6 05 84 f3 22 f0 00 	movb   $0x0,0xf022f384
f0103ce9:	c6 05 85 f3 22 f0 8e 	movb   $0x8e,0xf022f385
f0103cf0:	c1 e8 10             	shr    $0x10,%eax
f0103cf3:	66 a3 86 f3 22 f0    	mov    %ax,0xf022f386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, handler39, 0);
f0103cf9:	b8 48 43 10 f0       	mov    $0xf0104348,%eax
f0103cfe:	66 a3 98 f3 22 f0    	mov    %ax,0xf022f398
f0103d04:	66 c7 05 9a f3 22 f0 	movw   $0x8,0xf022f39a
f0103d0b:	08 00 
f0103d0d:	c6 05 9c f3 22 f0 00 	movb   $0x0,0xf022f39c
f0103d14:	c6 05 9d f3 22 f0 8e 	movb   $0x8e,0xf022f39d
f0103d1b:	c1 e8 10             	shr    $0x10,%eax
f0103d1e:	66 a3 9e f3 22 f0    	mov    %ax,0xf022f39e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, handler46, 0);
f0103d24:	b8 4e 43 10 f0       	mov    $0xf010434e,%eax
f0103d29:	66 a3 d0 f3 22 f0    	mov    %ax,0xf022f3d0
f0103d2f:	66 c7 05 d2 f3 22 f0 	movw   $0x8,0xf022f3d2
f0103d36:	08 00 
f0103d38:	c6 05 d4 f3 22 f0 00 	movb   $0x0,0xf022f3d4
f0103d3f:	c6 05 d5 f3 22 f0 8e 	movb   $0x8e,0xf022f3d5
f0103d46:	c1 e8 10             	shr    $0x10,%eax
f0103d49:	66 a3 d6 f3 22 f0    	mov    %ax,0xf022f3d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, handler51, 0);
f0103d4f:	b8 54 43 10 f0       	mov    $0xf0104354,%eax
f0103d54:	66 a3 f8 f3 22 f0    	mov    %ax,0xf022f3f8
f0103d5a:	66 c7 05 fa f3 22 f0 	movw   $0x8,0xf022f3fa
f0103d61:	08 00 
f0103d63:	c6 05 fc f3 22 f0 00 	movb   $0x0,0xf022f3fc
f0103d6a:	c6 05 fd f3 22 f0 8e 	movb   $0x8e,0xf022f3fd
f0103d71:	c1 e8 10             	shr    $0x10,%eax
f0103d74:	66 a3 fe f3 22 f0    	mov    %ax,0xf022f3fe
	
	// Per-CPU setup 
	trap_init_percpu();
f0103d7a:	e8 f8 fa ff ff       	call   f0103877 <trap_init_percpu>
}
f0103d7f:	c9                   	leave  
f0103d80:	c3                   	ret    

f0103d81 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d81:	55                   	push   %ebp
f0103d82:	89 e5                	mov    %esp,%ebp
f0103d84:	53                   	push   %ebx
f0103d85:	83 ec 0c             	sub    $0xc,%esp
f0103d88:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d8b:	ff 33                	pushl  (%ebx)
f0103d8d:	68 7e 76 10 f0       	push   $0xf010767e
f0103d92:	e8 cc fa ff ff       	call   f0103863 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d97:	83 c4 08             	add    $0x8,%esp
f0103d9a:	ff 73 04             	pushl  0x4(%ebx)
f0103d9d:	68 8d 76 10 f0       	push   $0xf010768d
f0103da2:	e8 bc fa ff ff       	call   f0103863 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103da7:	83 c4 08             	add    $0x8,%esp
f0103daa:	ff 73 08             	pushl  0x8(%ebx)
f0103dad:	68 9c 76 10 f0       	push   $0xf010769c
f0103db2:	e8 ac fa ff ff       	call   f0103863 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103db7:	83 c4 08             	add    $0x8,%esp
f0103dba:	ff 73 0c             	pushl  0xc(%ebx)
f0103dbd:	68 ab 76 10 f0       	push   $0xf01076ab
f0103dc2:	e8 9c fa ff ff       	call   f0103863 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103dc7:	83 c4 08             	add    $0x8,%esp
f0103dca:	ff 73 10             	pushl  0x10(%ebx)
f0103dcd:	68 ba 76 10 f0       	push   $0xf01076ba
f0103dd2:	e8 8c fa ff ff       	call   f0103863 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103dd7:	83 c4 08             	add    $0x8,%esp
f0103dda:	ff 73 14             	pushl  0x14(%ebx)
f0103ddd:	68 c9 76 10 f0       	push   $0xf01076c9
f0103de2:	e8 7c fa ff ff       	call   f0103863 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103de7:	83 c4 08             	add    $0x8,%esp
f0103dea:	ff 73 18             	pushl  0x18(%ebx)
f0103ded:	68 d8 76 10 f0       	push   $0xf01076d8
f0103df2:	e8 6c fa ff ff       	call   f0103863 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103df7:	83 c4 08             	add    $0x8,%esp
f0103dfa:	ff 73 1c             	pushl  0x1c(%ebx)
f0103dfd:	68 e7 76 10 f0       	push   $0xf01076e7
f0103e02:	e8 5c fa ff ff       	call   f0103863 <cprintf>
}
f0103e07:	83 c4 10             	add    $0x10,%esp
f0103e0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e0d:	c9                   	leave  
f0103e0e:	c3                   	ret    

f0103e0f <print_trapframe>:

}

void
print_trapframe(struct Trapframe *tf)
{
f0103e0f:	55                   	push   %ebp
f0103e10:	89 e5                	mov    %esp,%ebp
f0103e12:	56                   	push   %esi
f0103e13:	53                   	push   %ebx
f0103e14:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e17:	e8 5e 1d 00 00       	call   f0105b7a <cpunum>
f0103e1c:	83 ec 04             	sub    $0x4,%esp
f0103e1f:	50                   	push   %eax
f0103e20:	53                   	push   %ebx
f0103e21:	68 4b 77 10 f0       	push   $0xf010774b
f0103e26:	e8 38 fa ff ff       	call   f0103863 <cprintf>
	print_regs(&tf->tf_regs);
f0103e2b:	89 1c 24             	mov    %ebx,(%esp)
f0103e2e:	e8 4e ff ff ff       	call   f0103d81 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e33:	83 c4 08             	add    $0x8,%esp
f0103e36:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e3a:	50                   	push   %eax
f0103e3b:	68 69 77 10 f0       	push   $0xf0107769
f0103e40:	e8 1e fa ff ff       	call   f0103863 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e45:	83 c4 08             	add    $0x8,%esp
f0103e48:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e4c:	50                   	push   %eax
f0103e4d:	68 7c 77 10 f0       	push   $0xf010777c
f0103e52:	e8 0c fa ff ff       	call   f0103863 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e57:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103e5a:	83 c4 10             	add    $0x10,%esp
f0103e5d:	83 f8 13             	cmp    $0x13,%eax
f0103e60:	77 09                	ja     f0103e6b <print_trapframe+0x5c>
		return excnames[trapno];
f0103e62:	8b 14 85 20 7a 10 f0 	mov    -0xfef85e0(,%eax,4),%edx
f0103e69:	eb 1f                	jmp    f0103e8a <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103e6b:	83 f8 30             	cmp    $0x30,%eax
f0103e6e:	74 15                	je     f0103e85 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e70:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103e73:	83 fa 10             	cmp    $0x10,%edx
f0103e76:	b9 15 77 10 f0       	mov    $0xf0107715,%ecx
f0103e7b:	ba 02 77 10 f0       	mov    $0xf0107702,%edx
f0103e80:	0f 43 d1             	cmovae %ecx,%edx
f0103e83:	eb 05                	jmp    f0103e8a <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103e85:	ba f6 76 10 f0       	mov    $0xf01076f6,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e8a:	83 ec 04             	sub    $0x4,%esp
f0103e8d:	52                   	push   %edx
f0103e8e:	50                   	push   %eax
f0103e8f:	68 8f 77 10 f0       	push   $0xf010778f
f0103e94:	e8 ca f9 ff ff       	call   f0103863 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e99:	83 c4 10             	add    $0x10,%esp
f0103e9c:	3b 1d 60 fa 22 f0    	cmp    0xf022fa60,%ebx
f0103ea2:	75 1a                	jne    f0103ebe <print_trapframe+0xaf>
f0103ea4:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ea8:	75 14                	jne    f0103ebe <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103eaa:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ead:	83 ec 08             	sub    $0x8,%esp
f0103eb0:	50                   	push   %eax
f0103eb1:	68 a1 77 10 f0       	push   $0xf01077a1
f0103eb6:	e8 a8 f9 ff ff       	call   f0103863 <cprintf>
f0103ebb:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ebe:	83 ec 08             	sub    $0x8,%esp
f0103ec1:	ff 73 2c             	pushl  0x2c(%ebx)
f0103ec4:	68 b0 77 10 f0       	push   $0xf01077b0
f0103ec9:	e8 95 f9 ff ff       	call   f0103863 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103ece:	83 c4 10             	add    $0x10,%esp
f0103ed1:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ed5:	75 49                	jne    f0103f20 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ed7:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103eda:	89 c2                	mov    %eax,%edx
f0103edc:	83 e2 01             	and    $0x1,%edx
f0103edf:	ba 2f 77 10 f0       	mov    $0xf010772f,%edx
f0103ee4:	b9 24 77 10 f0       	mov    $0xf0107724,%ecx
f0103ee9:	0f 44 ca             	cmove  %edx,%ecx
f0103eec:	89 c2                	mov    %eax,%edx
f0103eee:	83 e2 02             	and    $0x2,%edx
f0103ef1:	ba 41 77 10 f0       	mov    $0xf0107741,%edx
f0103ef6:	be 3b 77 10 f0       	mov    $0xf010773b,%esi
f0103efb:	0f 45 d6             	cmovne %esi,%edx
f0103efe:	83 e0 04             	and    $0x4,%eax
f0103f01:	be 95 78 10 f0       	mov    $0xf0107895,%esi
f0103f06:	b8 46 77 10 f0       	mov    $0xf0107746,%eax
f0103f0b:	0f 44 c6             	cmove  %esi,%eax
f0103f0e:	51                   	push   %ecx
f0103f0f:	52                   	push   %edx
f0103f10:	50                   	push   %eax
f0103f11:	68 be 77 10 f0       	push   $0xf01077be
f0103f16:	e8 48 f9 ff ff       	call   f0103863 <cprintf>
f0103f1b:	83 c4 10             	add    $0x10,%esp
f0103f1e:	eb 10                	jmp    f0103f30 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103f20:	83 ec 0c             	sub    $0xc,%esp
f0103f23:	68 72 75 10 f0       	push   $0xf0107572
f0103f28:	e8 36 f9 ff ff       	call   f0103863 <cprintf>
f0103f2d:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103f30:	83 ec 08             	sub    $0x8,%esp
f0103f33:	ff 73 30             	pushl  0x30(%ebx)
f0103f36:	68 cd 77 10 f0       	push   $0xf01077cd
f0103f3b:	e8 23 f9 ff ff       	call   f0103863 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f40:	83 c4 08             	add    $0x8,%esp
f0103f43:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f47:	50                   	push   %eax
f0103f48:	68 dc 77 10 f0       	push   $0xf01077dc
f0103f4d:	e8 11 f9 ff ff       	call   f0103863 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f52:	83 c4 08             	add    $0x8,%esp
f0103f55:	ff 73 38             	pushl  0x38(%ebx)
f0103f58:	68 ef 77 10 f0       	push   $0xf01077ef
f0103f5d:	e8 01 f9 ff ff       	call   f0103863 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f62:	83 c4 10             	add    $0x10,%esp
f0103f65:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f69:	74 25                	je     f0103f90 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f6b:	83 ec 08             	sub    $0x8,%esp
f0103f6e:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f71:	68 fe 77 10 f0       	push   $0xf01077fe
f0103f76:	e8 e8 f8 ff ff       	call   f0103863 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f7b:	83 c4 08             	add    $0x8,%esp
f0103f7e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f82:	50                   	push   %eax
f0103f83:	68 0d 78 10 f0       	push   $0xf010780d
f0103f88:	e8 d6 f8 ff ff       	call   f0103863 <cprintf>
f0103f8d:	83 c4 10             	add    $0x10,%esp
	}
}
f0103f90:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f93:	5b                   	pop    %ebx
f0103f94:	5e                   	pop    %esi
f0103f95:	5d                   	pop    %ebp
f0103f96:	c3                   	ret    

f0103f97 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f97:	55                   	push   %ebp
f0103f98:	89 e5                	mov    %esp,%ebp
f0103f9a:	57                   	push   %edi
f0103f9b:	56                   	push   %esi
f0103f9c:	53                   	push   %ebx
f0103f9d:	83 ec 0c             	sub    $0xc,%esp
f0103fa0:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fa3:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) panic("Page fault in kernel-mode");
f0103fa6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103faa:	75 17                	jne    f0103fc3 <page_fault_handler+0x2c>
f0103fac:	83 ec 04             	sub    $0x4,%esp
f0103faf:	68 20 78 10 f0       	push   $0xf0107820
f0103fb4:	68 65 01 00 00       	push   $0x165
f0103fb9:	68 3a 78 10 f0       	push   $0xf010783a
f0103fbe:	e8 7d c0 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103fc3:	e8 b2 1b 00 00       	call   f0105b7a <cpunum>
f0103fc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fcb:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0103fd1:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fd5:	0f 84 8b 00 00 00    	je     f0104066 <page_fault_handler+0xcf>
		struct UTrapframe *utf;
		if (tf->tf_esp >= UXSTACKTOP-PGSIZE && tf->tf_esp < UXSTACKTOP) {
f0103fdb:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103fde:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			// from exception stack
			utf = (struct UTrapframe *)(tf->tf_esp - 4 - sizeof(struct UTrapframe));
f0103fe4:	83 e8 38             	sub    $0x38,%eax
f0103fe7:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103fed:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103ff2:	0f 46 d0             	cmovbe %eax,%edx
f0103ff5:	89 d7                	mov    %edx,%edi
		} else {
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W | PTE_P);
f0103ff7:	e8 7e 1b 00 00       	call   f0105b7a <cpunum>
f0103ffc:	6a 07                	push   $0x7
f0103ffe:	6a 34                	push   $0x34
f0104000:	57                   	push   %edi
f0104001:	6b c0 74             	imul   $0x74,%eax,%eax
f0104004:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010400a:	e8 13 ef ff ff       	call   f0102f22 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f010400f:	89 fa                	mov    %edi,%edx
f0104011:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_trapno;
f0104013:	8b 43 28             	mov    0x28(%ebx),%eax
f0104016:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f0104019:	8d 7f 08             	lea    0x8(%edi),%edi
f010401c:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104021:	89 de                	mov    %ebx,%esi
f0104023:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104025:	8b 43 30             	mov    0x30(%ebx),%eax
f0104028:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010402b:	8b 43 38             	mov    0x38(%ebx),%eax
f010402e:	89 d7                	mov    %edx,%edi
f0104030:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104033:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104036:	89 42 30             	mov    %eax,0x30(%edx)

		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104039:	e8 3c 1b 00 00       	call   f0105b7a <cpunum>
f010403e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104041:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104047:	8b 40 64             	mov    0x64(%eax),%eax
f010404a:	89 43 30             	mov    %eax,0x30(%ebx)
		// tf->esp = (uintptr_t)utf - 1;
		tf->tf_esp = (uintptr_t)utf;
f010404d:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		env_run(curenv);
f0104050:	e8 25 1b 00 00       	call   f0105b7a <cpunum>
f0104055:	83 c4 04             	add    $0x4,%esp
f0104058:	6b c0 74             	imul   $0x74,%eax,%eax
f010405b:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104061:	e8 e3 f5 ff ff       	call   f0103649 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104066:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104069:	e8 0c 1b 00 00       	call   f0105b7a <cpunum>
		tf->tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010406e:	57                   	push   %edi
f010406f:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0104070:	6b c0 74             	imul   $0x74,%eax,%eax
		tf->tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104073:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104079:	ff 70 48             	pushl  0x48(%eax)
f010407c:	68 e0 79 10 f0       	push   $0xf01079e0
f0104081:	e8 dd f7 ff ff       	call   f0103863 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104086:	89 1c 24             	mov    %ebx,(%esp)
f0104089:	e8 81 fd ff ff       	call   f0103e0f <print_trapframe>
	env_destroy(curenv);
f010408e:	e8 e7 1a 00 00       	call   f0105b7a <cpunum>
f0104093:	83 c4 04             	add    $0x4,%esp
f0104096:	6b c0 74             	imul   $0x74,%eax,%eax
f0104099:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010409f:	e8 06 f5 ff ff       	call   f01035aa <env_destroy>
}
f01040a4:	83 c4 10             	add    $0x10,%esp
f01040a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01040aa:	5b                   	pop    %ebx
f01040ab:	5e                   	pop    %esi
f01040ac:	5f                   	pop    %edi
f01040ad:	5d                   	pop    %ebp
f01040ae:	c3                   	ret    

f01040af <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01040af:	55                   	push   %ebp
f01040b0:	89 e5                	mov    %esp,%ebp
f01040b2:	57                   	push   %edi
f01040b3:	56                   	push   %esi
f01040b4:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01040b7:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01040b8:	83 3d 80 fe 22 f0 00 	cmpl   $0x0,0xf022fe80
f01040bf:	74 01                	je     f01040c2 <trap+0x13>
		asm volatile("hlt");
f01040c1:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040c2:	e8 b3 1a 00 00       	call   f0105b7a <cpunum>
f01040c7:	6b d0 74             	imul   $0x74,%eax,%edx
f01040ca:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01040d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01040d5:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01040d9:	83 f8 02             	cmp    $0x2,%eax
f01040dc:	75 10                	jne    f01040ee <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01040de:	83 ec 0c             	sub    $0xc,%esp
f01040e1:	68 c0 03 12 f0       	push   $0xf01203c0
f01040e6:	e8 fd 1c 00 00       	call   f0105de8 <spin_lock>
f01040eb:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01040ee:	9c                   	pushf  
f01040ef:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	// cprintf("Trap type = %s, env_id = %08x, eflags = %08x\n", trapname(tf->tf_trapno), curenv->env_id, read_eflags());
	assert(!(read_eflags() & FL_IF));
f01040f0:	f6 c4 02             	test   $0x2,%ah
f01040f3:	74 19                	je     f010410e <trap+0x5f>
f01040f5:	68 46 78 10 f0       	push   $0xf0107846
f01040fa:	68 a7 72 10 f0       	push   $0xf01072a7
f01040ff:	68 32 01 00 00       	push   $0x132
f0104104:	68 3a 78 10 f0       	push   $0xf010783a
f0104109:	e8 32 bf ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010410e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104112:	83 e0 03             	and    $0x3,%eax
f0104115:	66 83 f8 03          	cmp    $0x3,%ax
f0104119:	0f 85 a0 00 00 00    	jne    f01041bf <trap+0x110>
f010411f:	83 ec 0c             	sub    $0xc,%esp
f0104122:	68 c0 03 12 f0       	push   $0xf01203c0
f0104127:	e8 bc 1c 00 00       	call   f0105de8 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f010412c:	e8 49 1a 00 00       	call   f0105b7a <cpunum>
f0104131:	6b c0 74             	imul   $0x74,%eax,%eax
f0104134:	83 c4 10             	add    $0x10,%esp
f0104137:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010413e:	75 19                	jne    f0104159 <trap+0xaa>
f0104140:	68 5f 78 10 f0       	push   $0xf010785f
f0104145:	68 a7 72 10 f0       	push   $0xf01072a7
f010414a:	68 3a 01 00 00       	push   $0x13a
f010414f:	68 3a 78 10 f0       	push   $0xf010783a
f0104154:	e8 e7 be ff ff       	call   f0100040 <_panic>
		
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104159:	e8 1c 1a 00 00       	call   f0105b7a <cpunum>
f010415e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104161:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104167:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010416b:	75 2d                	jne    f010419a <trap+0xeb>
			env_free(curenv);
f010416d:	e8 08 1a 00 00       	call   f0105b7a <cpunum>
f0104172:	83 ec 0c             	sub    $0xc,%esp
f0104175:	6b c0 74             	imul   $0x74,%eax,%eax
f0104178:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f010417e:	e8 4c f2 ff ff       	call   f01033cf <env_free>
			curenv = NULL;
f0104183:	e8 f2 19 00 00       	call   f0105b7a <cpunum>
f0104188:	6b c0 74             	imul   $0x74,%eax,%eax
f010418b:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f0104192:	00 00 00 
			sched_yield();
f0104195:	e8 a5 02 00 00       	call   f010443f <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010419a:	e8 db 19 00 00       	call   f0105b7a <cpunum>
f010419f:	6b c0 74             	imul   $0x74,%eax,%eax
f01041a2:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01041a8:	b9 11 00 00 00       	mov    $0x11,%ecx
f01041ad:	89 c7                	mov    %eax,%edi
f01041af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01041b1:	e8 c4 19 00 00       	call   f0105b7a <cpunum>
f01041b6:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b9:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01041bf:	89 35 60 fa 22 f0    	mov    %esi,0xf022fa60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
f01041c5:	8b 46 28             	mov    0x28(%esi),%eax
f01041c8:	83 f8 0e             	cmp    $0xe,%eax
f01041cb:	74 0c                	je     f01041d9 <trap+0x12a>
f01041cd:	83 f8 30             	cmp    $0x30,%eax
f01041d0:	74 29                	je     f01041fb <trap+0x14c>
f01041d2:	83 f8 03             	cmp    $0x3,%eax
f01041d5:	75 45                	jne    f010421c <trap+0x16d>
f01041d7:	eb 11                	jmp    f01041ea <trap+0x13b>
		case T_PGFLT:
			page_fault_handler(tf);
f01041d9:	83 ec 0c             	sub    $0xc,%esp
f01041dc:	56                   	push   %esi
f01041dd:	e8 b5 fd ff ff       	call   f0103f97 <page_fault_handler>
f01041e2:	83 c4 10             	add    $0x10,%esp
f01041e5:	e9 a3 00 00 00       	jmp    f010428d <trap+0x1de>
			return;
		case T_BRKPT:
			monitor(tf);
f01041ea:	83 ec 0c             	sub    $0xc,%esp
f01041ed:	56                   	push   %esi
f01041ee:	e8 bd c8 ff ff       	call   f0100ab0 <monitor>
f01041f3:	83 c4 10             	add    $0x10,%esp
f01041f6:	e9 92 00 00 00       	jmp    f010428d <trap+0x1de>
			return;
		case T_SYSCALL:
			tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, 
f01041fb:	83 ec 08             	sub    $0x8,%esp
f01041fe:	ff 76 04             	pushl  0x4(%esi)
f0104201:	ff 36                	pushl  (%esi)
f0104203:	ff 76 10             	pushl  0x10(%esi)
f0104206:	ff 76 18             	pushl  0x18(%esi)
f0104209:	ff 76 14             	pushl  0x14(%esi)
f010420c:	ff 76 1c             	pushl  0x1c(%esi)
f010420f:	e8 a8 03 00 00       	call   f01045bc <syscall>
f0104214:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104217:	83 c4 20             	add    $0x20,%esp
f010421a:	eb 71                	jmp    f010428d <trap+0x1de>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010421c:	83 f8 27             	cmp    $0x27,%eax
f010421f:	75 1a                	jne    f010423b <trap+0x18c>
		cprintf("Spurious interrupt on irq 7\n");
f0104221:	83 ec 0c             	sub    $0xc,%esp
f0104224:	68 66 78 10 f0       	push   $0xf0107866
f0104229:	e8 35 f6 ff ff       	call   f0103863 <cprintf>
		print_trapframe(tf);
f010422e:	89 34 24             	mov    %esi,(%esp)
f0104231:	e8 d9 fb ff ff       	call   f0103e0f <print_trapframe>
f0104236:	83 c4 10             	add    $0x10,%esp
f0104239:	eb 52                	jmp    f010428d <trap+0x1de>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010423b:	83 f8 20             	cmp    $0x20,%eax
f010423e:	75 0a                	jne    f010424a <trap+0x19b>
		lapic_eoi();
f0104240:	e8 80 1a 00 00       	call   f0105cc5 <lapic_eoi>
		sched_yield();
f0104245:	e8 f5 01 00 00       	call   f010443f <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010424a:	83 ec 0c             	sub    $0xc,%esp
f010424d:	56                   	push   %esi
f010424e:	e8 bc fb ff ff       	call   f0103e0f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104253:	83 c4 10             	add    $0x10,%esp
f0104256:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010425b:	75 17                	jne    f0104274 <trap+0x1c5>
		panic("unhandled trap in kernel");
f010425d:	83 ec 04             	sub    $0x4,%esp
f0104260:	68 83 78 10 f0       	push   $0xf0107883
f0104265:	68 17 01 00 00       	push   $0x117
f010426a:	68 3a 78 10 f0       	push   $0xf010783a
f010426f:	e8 cc bd ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104274:	e8 01 19 00 00       	call   f0105b7a <cpunum>
f0104279:	83 ec 0c             	sub    $0xc,%esp
f010427c:	6b c0 74             	imul   $0x74,%eax,%eax
f010427f:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104285:	e8 20 f3 ff ff       	call   f01035aa <env_destroy>
f010428a:	83 c4 10             	add    $0x10,%esp
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010428d:	e8 e8 18 00 00       	call   f0105b7a <cpunum>
f0104292:	6b c0 74             	imul   $0x74,%eax,%eax
f0104295:	83 b8 28 00 23 f0 00 	cmpl   $0x0,-0xfdcffd8(%eax)
f010429c:	74 2a                	je     f01042c8 <trap+0x219>
f010429e:	e8 d7 18 00 00       	call   f0105b7a <cpunum>
f01042a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01042a6:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01042ac:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01042b0:	75 16                	jne    f01042c8 <trap+0x219>
		env_run(curenv);
f01042b2:	e8 c3 18 00 00       	call   f0105b7a <cpunum>
f01042b7:	83 ec 0c             	sub    $0xc,%esp
f01042ba:	6b c0 74             	imul   $0x74,%eax,%eax
f01042bd:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01042c3:	e8 81 f3 ff ff       	call   f0103649 <env_run>
	else
		sched_yield();
f01042c8:	e8 72 01 00 00       	call   f010443f <sched_yield>
f01042cd:	90                   	nop

f01042ce <handler0>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(handler0, T_DIVIDE)
f01042ce:	6a 00                	push   $0x0
f01042d0:	6a 00                	push   $0x0
f01042d2:	e9 83 00 00 00       	jmp    f010435a <_alltraps>
f01042d7:	90                   	nop

f01042d8 <handler1>:
TRAPHANDLER_NOEC(handler1, T_DEBUG)
f01042d8:	6a 00                	push   $0x0
f01042da:	6a 01                	push   $0x1
f01042dc:	eb 7c                	jmp    f010435a <_alltraps>

f01042de <handler2>:
TRAPHANDLER_NOEC(handler2, T_NMI)
f01042de:	6a 00                	push   $0x0
f01042e0:	6a 02                	push   $0x2
f01042e2:	eb 76                	jmp    f010435a <_alltraps>

f01042e4 <handler3>:
TRAPHANDLER_NOEC(handler3, T_BRKPT)
f01042e4:	6a 00                	push   $0x0
f01042e6:	6a 03                	push   $0x3
f01042e8:	eb 70                	jmp    f010435a <_alltraps>

f01042ea <handler4>:
TRAPHANDLER_NOEC(handler4, T_OFLOW)
f01042ea:	6a 00                	push   $0x0
f01042ec:	6a 04                	push   $0x4
f01042ee:	eb 6a                	jmp    f010435a <_alltraps>

f01042f0 <handler5>:
TRAPHANDLER_NOEC(handler5, T_BOUND)
f01042f0:	6a 00                	push   $0x0
f01042f2:	6a 05                	push   $0x5
f01042f4:	eb 64                	jmp    f010435a <_alltraps>

f01042f6 <handler6>:
TRAPHANDLER_NOEC(handler6, T_ILLOP)
f01042f6:	6a 00                	push   $0x0
f01042f8:	6a 06                	push   $0x6
f01042fa:	eb 5e                	jmp    f010435a <_alltraps>

f01042fc <handler7>:
TRAPHANDLER_NOEC(handler7, T_DEVICE)
f01042fc:	6a 00                	push   $0x0
f01042fe:	6a 07                	push   $0x7
f0104300:	eb 58                	jmp    f010435a <_alltraps>

f0104302 <handler8>:
TRAPHANDLER(handler8, T_DBLFLT)
f0104302:	6a 08                	push   $0x8
f0104304:	eb 54                	jmp    f010435a <_alltraps>

f0104306 <handler10>:
// 9 deprecated since 386
TRAPHANDLER(handler10, T_TSS)
f0104306:	6a 0a                	push   $0xa
f0104308:	eb 50                	jmp    f010435a <_alltraps>

f010430a <handler11>:
TRAPHANDLER(handler11, T_SEGNP)
f010430a:	6a 0b                	push   $0xb
f010430c:	eb 4c                	jmp    f010435a <_alltraps>

f010430e <handler12>:
TRAPHANDLER(handler12, T_STACK)
f010430e:	6a 0c                	push   $0xc
f0104310:	eb 48                	jmp    f010435a <_alltraps>

f0104312 <handler13>:
TRAPHANDLER(handler13, T_GPFLT)
f0104312:	6a 0d                	push   $0xd
f0104314:	eb 44                	jmp    f010435a <_alltraps>

f0104316 <handler14>:
TRAPHANDLER(handler14, T_PGFLT)
f0104316:	6a 0e                	push   $0xe
f0104318:	eb 40                	jmp    f010435a <_alltraps>

f010431a <handler16>:
// 15 reserved by intel
TRAPHANDLER_NOEC(handler16, T_FPERR)
f010431a:	6a 00                	push   $0x0
f010431c:	6a 10                	push   $0x10
f010431e:	eb 3a                	jmp    f010435a <_alltraps>

f0104320 <handler17>:
TRAPHANDLER(handler17, T_ALIGN)
f0104320:	6a 11                	push   $0x11
f0104322:	eb 36                	jmp    f010435a <_alltraps>

f0104324 <handler18>:
TRAPHANDLER_NOEC(handler18, T_MCHK)
f0104324:	6a 00                	push   $0x0
f0104326:	6a 12                	push   $0x12
f0104328:	eb 30                	jmp    f010435a <_alltraps>

f010432a <handler19>:
TRAPHANDLER_NOEC(handler19, T_SIMDERR)
f010432a:	6a 00                	push   $0x0
f010432c:	6a 13                	push   $0x13
f010432e:	eb 2a                	jmp    f010435a <_alltraps>

f0104330 <handler48>:


// system call (interrupt)
TRAPHANDLER_NOEC(handler48, T_SYSCALL)
f0104330:	6a 00                	push   $0x0
f0104332:	6a 30                	push   $0x30
f0104334:	eb 24                	jmp    f010435a <_alltraps>

f0104336 <handler32>:

// IRQs
TRAPHANDLER_NOEC(handler32, IRQ_OFFSET + IRQ_TIMER)
f0104336:	6a 00                	push   $0x0
f0104338:	6a 20                	push   $0x20
f010433a:	eb 1e                	jmp    f010435a <_alltraps>

f010433c <handler33>:
TRAPHANDLER_NOEC(handler33, IRQ_OFFSET + IRQ_KBD)
f010433c:	6a 00                	push   $0x0
f010433e:	6a 21                	push   $0x21
f0104340:	eb 18                	jmp    f010435a <_alltraps>

f0104342 <handler36>:
TRAPHANDLER_NOEC(handler36, IRQ_OFFSET + IRQ_SERIAL)
f0104342:	6a 00                	push   $0x0
f0104344:	6a 24                	push   $0x24
f0104346:	eb 12                	jmp    f010435a <_alltraps>

f0104348 <handler39>:
TRAPHANDLER_NOEC(handler39, IRQ_OFFSET + IRQ_SPURIOUS)
f0104348:	6a 00                	push   $0x0
f010434a:	6a 27                	push   $0x27
f010434c:	eb 0c                	jmp    f010435a <_alltraps>

f010434e <handler46>:
TRAPHANDLER_NOEC(handler46, IRQ_OFFSET + IRQ_IDE)
f010434e:	6a 00                	push   $0x0
f0104350:	6a 2e                	push   $0x2e
f0104352:	eb 06                	jmp    f010435a <_alltraps>

f0104354 <handler51>:
TRAPHANDLER_NOEC(handler51, IRQ_OFFSET + IRQ_ERROR)
f0104354:	6a 00                	push   $0x0
f0104356:	6a 33                	push   $0x33
f0104358:	eb 00                	jmp    f010435a <_alltraps>

f010435a <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
pushl %ds
f010435a:	1e                   	push   %ds
pushl %es
f010435b:	06                   	push   %es
pushal
f010435c:	60                   	pusha  

movw $GD_KD, %ax
f010435d:	66 b8 10 00          	mov    $0x10,%ax
movw %ax, %ds
f0104361:	8e d8                	mov    %eax,%ds
movw %ax, %es
f0104363:	8e c0                	mov    %eax,%es
pushl %esp
f0104365:	54                   	push   %esp
call trap
f0104366:	e8 44 fd ff ff       	call   f01040af <trap>

f010436b <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010436b:	55                   	push   %ebp
f010436c:	89 e5                	mov    %esp,%ebp
f010436e:	83 ec 08             	sub    $0x8,%esp
f0104371:	a1 48 f2 22 f0       	mov    0xf022f248,%eax
f0104376:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104379:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010437e:	8b 02                	mov    (%edx),%eax
f0104380:	83 e8 01             	sub    $0x1,%eax
f0104383:	83 f8 02             	cmp    $0x2,%eax
f0104386:	76 10                	jbe    f0104398 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104388:	83 c1 01             	add    $0x1,%ecx
f010438b:	83 c2 7c             	add    $0x7c,%edx
f010438e:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104394:	75 e8                	jne    f010437e <sched_halt+0x13>
f0104396:	eb 08                	jmp    f01043a0 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104398:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f010439e:	75 1f                	jne    f01043bf <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01043a0:	83 ec 0c             	sub    $0xc,%esp
f01043a3:	68 70 7a 10 f0       	push   $0xf0107a70
f01043a8:	e8 b6 f4 ff ff       	call   f0103863 <cprintf>
f01043ad:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01043b0:	83 ec 0c             	sub    $0xc,%esp
f01043b3:	6a 00                	push   $0x0
f01043b5:	e8 f6 c6 ff ff       	call   f0100ab0 <monitor>
f01043ba:	83 c4 10             	add    $0x10,%esp
f01043bd:	eb f1                	jmp    f01043b0 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01043bf:	e8 b6 17 00 00       	call   f0105b7a <cpunum>
f01043c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01043c7:	c7 80 28 00 23 f0 00 	movl   $0x0,-0xfdcffd8(%eax)
f01043ce:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01043d1:	a1 8c fe 22 f0       	mov    0xf022fe8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01043d6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01043db:	77 12                	ja     f01043ef <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01043dd:	50                   	push   %eax
f01043de:	68 68 62 10 f0       	push   $0xf0106268
f01043e3:	6a 49                	push   $0x49
f01043e5:	68 99 7a 10 f0       	push   $0xf0107a99
f01043ea:	e8 51 bc ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01043ef:	05 00 00 00 10       	add    $0x10000000,%eax
f01043f4:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01043f7:	e8 7e 17 00 00       	call   f0105b7a <cpunum>
f01043fc:	6b d0 74             	imul   $0x74,%eax,%edx
f01043ff:	81 c2 20 00 23 f0    	add    $0xf0230020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104405:	b8 02 00 00 00       	mov    $0x2,%eax
f010440a:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010440e:	83 ec 0c             	sub    $0xc,%esp
f0104411:	68 c0 03 12 f0       	push   $0xf01203c0
f0104416:	e8 6a 1a 00 00       	call   f0105e85 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010441b:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010441d:	e8 58 17 00 00       	call   f0105b7a <cpunum>
f0104422:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104425:	8b 80 30 00 23 f0    	mov    -0xfdcffd0(%eax),%eax
f010442b:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104430:	89 c4                	mov    %eax,%esp
f0104432:	6a 00                	push   $0x0
f0104434:	6a 00                	push   $0x0
f0104436:	fb                   	sti    
f0104437:	f4                   	hlt    
f0104438:	eb fd                	jmp    f0104437 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010443a:	83 c4 10             	add    $0x10,%esp
f010443d:	c9                   	leave  
f010443e:	c3                   	ret    

f010443f <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010443f:	55                   	push   %ebp
f0104440:	89 e5                	mov    %esp,%ebp
f0104442:	57                   	push   %edi
f0104443:	56                   	push   %esi
f0104444:	53                   	push   %ebx
f0104445:	83 ec 0c             	sub    $0xc,%esp
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = curenv;
f0104448:	e8 2d 17 00 00       	call   f0105b7a <cpunum>
f010444d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104450:	8b b8 28 00 23 f0    	mov    -0xfdcffd8(%eax),%edi
	size_t idx = idle!=NULL ? ENVX(idle->env_id):-1;
f0104456:	85 ff                	test   %edi,%edi
f0104458:	74 0a                	je     f0104464 <sched_yield+0x25>
f010445a:	8b 47 48             	mov    0x48(%edi),%eax
f010445d:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104462:	eb 05                	jmp    f0104469 <sched_yield+0x2a>
f0104464:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	for (size_t i=0; i<NENV; i++) {
		idx = (idx+1 == NENV) ? 0:idx+1;
		if (envs[idx].env_status == ENV_RUNNABLE) {
f0104469:	8b 35 48 f2 22 f0    	mov    0xf022f248,%esi
f010446f:	b9 00 04 00 00       	mov    $0x400,%ecx

	// LAB 4: Your code here.
	idle = curenv;
	size_t idx = idle!=NULL ? ENVX(idle->env_id):-1;
	for (size_t i=0; i<NENV; i++) {
		idx = (idx+1 == NENV) ? 0:idx+1;
f0104474:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104479:	8d 50 01             	lea    0x1(%eax),%edx
f010447c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0104481:	89 d0                	mov    %edx,%eax
f0104483:	0f 44 c3             	cmove  %ebx,%eax
		if (envs[idx].env_status == ENV_RUNNABLE) {
f0104486:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104489:	01 f2                	add    %esi,%edx
f010448b:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f010448f:	75 09                	jne    f010449a <sched_yield+0x5b>
			env_run(&envs[idx]);
f0104491:	83 ec 0c             	sub    $0xc,%esp
f0104494:	52                   	push   %edx
f0104495:	e8 af f1 ff ff       	call   f0103649 <env_run>
	// below to halt the cpu.

	// LAB 4: Your code here.
	idle = curenv;
	size_t idx = idle!=NULL ? ENVX(idle->env_id):-1;
	for (size_t i=0; i<NENV; i++) {
f010449a:	83 e9 01             	sub    $0x1,%ecx
f010449d:	75 da                	jne    f0104479 <sched_yield+0x3a>
		if (envs[idx].env_status == ENV_RUNNABLE) {
			env_run(&envs[idx]);
			return;
		}
	}
	if (idle && idle->env_status == ENV_RUNNING) {
f010449f:	85 ff                	test   %edi,%edi
f01044a1:	74 0f                	je     f01044b2 <sched_yield+0x73>
f01044a3:	83 7f 54 03          	cmpl   $0x3,0x54(%edi)
f01044a7:	75 09                	jne    f01044b2 <sched_yield+0x73>
		env_run(idle);
f01044a9:	83 ec 0c             	sub    $0xc,%esp
f01044ac:	57                   	push   %edi
f01044ad:	e8 97 f1 ff ff       	call   f0103649 <env_run>
		return;
	}
	// sched_halt never returns
	sched_halt();
f01044b2:	e8 b4 fe ff ff       	call   f010436b <sched_halt>
}
f01044b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044ba:	5b                   	pop    %ebx
f01044bb:	5e                   	pop    %esi
f01044bc:	5f                   	pop    %edi
f01044bd:	5d                   	pop    %ebp
f01044be:	c3                   	ret    

f01044bf <sys_page_map>:
//		address space.
//	-E_NO_MEM if there's no memory to allocate any necessary page tables.
static int
sys_page_map(envid_t srcenvid, void *srcva,
	     envid_t dstenvid, void *dstva, int perm)
{
f01044bf:	55                   	push   %ebp
f01044c0:	89 e5                	mov    %esp,%ebp
f01044c2:	57                   	push   %edi
f01044c3:	56                   	push   %esi
f01044c4:	53                   	push   %ebx
f01044c5:	83 ec 2c             	sub    $0x2c,%esp
f01044c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01044cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f01044ce:	81 fa ff ff bf ee    	cmp    $0xeebfffff,%edx
f01044d4:	0f 87 ab 00 00 00    	ja     f0104585 <sys_page_map+0xc6>
f01044da:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01044e0:	0f 85 a6 00 00 00    	jne    f010458c <sys_page_map+0xcd>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f01044e6:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01044ec:	0f 87 a1 00 00 00    	ja     f0104593 <sys_page_map+0xd4>
f01044f2:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01044f8:	0f 85 9c 00 00 00    	jne    f010459a <sys_page_map+0xdb>
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0) return -E_INVAL;
f01044fe:	89 f7                	mov    %esi,%edi
f0104500:	81 e7 fd f1 ff ff    	and    $0xfffff1fd,%edi
f0104506:	83 ff 05             	cmp    $0x5,%edi
f0104509:	0f 85 92 00 00 00    	jne    f01045a1 <sys_page_map+0xe2>
f010450f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0104512:	89 55 d0             	mov    %edx,-0x30(%ebp)
	struct Env *src_e, *dst_e;
	// add for lab4 exercise 15 for ipc.
	// customerize 0x200 as PTE_NO_CHECK
	// and we assume 0x200 is not used elsewhere
	bool check_perm = (perm & 0x200);
	perm &= (~0x200);
f0104515:	89 f7                	mov    %esi,%edi
f0104517:	81 e7 ff fd ff ff    	and    $0xfffffdff,%edi
	if (envid2env(srcenvid, &src_e, !check_perm)<0 || envid2env(dstenvid, &dst_e, !check_perm)<0) return -E_BAD_ENV;
f010451d:	f7 c6 00 02 00 00    	test   $0x200,%esi
f0104523:	0f 94 c1             	sete   %cl
f0104526:	0f b6 c9             	movzbl %cl,%ecx
f0104529:	89 ce                	mov    %ecx,%esi
f010452b:	83 ec 04             	sub    $0x4,%esp
f010452e:	51                   	push   %ecx
f010452f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104532:	52                   	push   %edx
f0104533:	50                   	push   %eax
f0104534:	e8 b0 ea ff ff       	call   f0102fe9 <envid2env>
f0104539:	83 c4 10             	add    $0x10,%esp
f010453c:	85 c0                	test   %eax,%eax
f010453e:	78 68                	js     f01045a8 <sys_page_map+0xe9>
f0104540:	83 ec 04             	sub    $0x4,%esp
f0104543:	56                   	push   %esi
f0104544:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104547:	50                   	push   %eax
f0104548:	ff 75 d4             	pushl  -0x2c(%ebp)
f010454b:	e8 99 ea ff ff       	call   f0102fe9 <envid2env>
f0104550:	83 c4 10             	add    $0x10,%esp
f0104553:	85 c0                	test   %eax,%eax
f0104555:	78 58                	js     f01045af <sys_page_map+0xf0>
	pte_t *src_ptab;	
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_ptab);
f0104557:	83 ec 04             	sub    $0x4,%esp
f010455a:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010455d:	50                   	push   %eax
f010455e:	ff 75 d0             	pushl  -0x30(%ebp)
f0104561:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104564:	ff 70 60             	pushl  0x60(%eax)
f0104567:	e8 a8 cd ff ff       	call   f0101314 <page_lookup>
	if ((*src_ptab & PTE_W) == 0 && (perm & PTE_W) == 1) return -E_INVAL;
	if (page_insert(dst_e->env_pgdir, pp, dstva, perm) < 0) return -E_NO_MEM;
f010456c:	57                   	push   %edi
f010456d:	53                   	push   %ebx
f010456e:	50                   	push   %eax
f010456f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104572:	ff 70 60             	pushl  0x60(%eax)
f0104575:	e8 6f ce ff ff       	call   f01013e9 <page_insert>
f010457a:	83 c4 20             	add    $0x20,%esp
	return 0;
f010457d:	c1 f8 1f             	sar    $0x1f,%eax
f0104580:	83 e0 fc             	and    $0xfffffffc,%eax
f0104583:	eb 2f                	jmp    f01045b4 <sys_page_map+0xf5>
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	// panic("sys_page_map not implemented");

	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f0104585:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010458a:	eb 28                	jmp    f01045b4 <sys_page_map+0xf5>
f010458c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104591:	eb 21                	jmp    f01045b4 <sys_page_map+0xf5>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104593:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104598:	eb 1a                	jmp    f01045b4 <sys_page_map+0xf5>
f010459a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010459f:	eb 13                	jmp    f01045b4 <sys_page_map+0xf5>
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0) return -E_INVAL;
f01045a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01045a6:	eb 0c                	jmp    f01045b4 <sys_page_map+0xf5>
	// add for lab4 exercise 15 for ipc.
	// customerize 0x200 as PTE_NO_CHECK
	// and we assume 0x200 is not used elsewhere
	bool check_perm = (perm & 0x200);
	perm &= (~0x200);
	if (envid2env(srcenvid, &src_e, !check_perm)<0 || envid2env(dstenvid, &dst_e, !check_perm)<0) return -E_BAD_ENV;
f01045a8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01045ad:	eb 05                	jmp    f01045b4 <sys_page_map+0xf5>
f01045af:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	pte_t *src_ptab;	
	struct PageInfo *pp = page_lookup(src_e->env_pgdir, srcva, &src_ptab);
	if ((*src_ptab & PTE_W) == 0 && (perm & PTE_W) == 1) return -E_INVAL;
	if (page_insert(dst_e->env_pgdir, pp, dstva, perm) < 0) return -E_NO_MEM;
	return 0;
}
f01045b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01045b7:	5b                   	pop    %ebx
f01045b8:	5e                   	pop    %esi
f01045b9:	5f                   	pop    %edi
f01045ba:	5d                   	pop    %ebp
f01045bb:	c3                   	ret    

f01045bc <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01045bc:	55                   	push   %ebp
f01045bd:	89 e5                	mov    %esp,%ebp
f01045bf:	57                   	push   %edi
f01045c0:	56                   	push   %esi
f01045c1:	53                   	push   %ebx
f01045c2:	83 ec 1c             	sub    $0x1c,%esp
f01045c5:	8b 45 08             	mov    0x8(%ebp),%eax
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	
	int32_t retVal = 0;
	switch (syscallno) {
f01045c8:	83 f8 0c             	cmp    $0xc,%eax
f01045cb:	0f 87 13 04 00 00    	ja     f01049e4 <syscall+0x428>
f01045d1:	ff 24 85 e0 7a 10 f0 	jmp    *-0xfef8520(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f01045d8:	e8 9d 15 00 00       	call   f0105b7a <cpunum>
f01045dd:	6a 04                	push   $0x4
f01045df:	ff 75 10             	pushl  0x10(%ebp)
f01045e2:	ff 75 0c             	pushl  0xc(%ebp)
f01045e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e8:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f01045ee:	e8 2f e9 ff ff       	call   f0102f22 <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01045f3:	83 c4 0c             	add    $0xc,%esp
f01045f6:	ff 75 0c             	pushl  0xc(%ebp)
f01045f9:	ff 75 10             	pushl  0x10(%ebp)
f01045fc:	68 a6 7a 10 f0       	push   $0xf0107aa6
f0104601:	e8 5d f2 ff ff       	call   f0103863 <cprintf>
f0104606:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	
	int32_t retVal = 0;
f0104609:	b8 00 00 00 00       	mov    $0x0,%eax
f010460e:	e9 d6 03 00 00       	jmp    f01049e9 <syscall+0x42d>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104613:	e8 dd bf ff ff       	call   f01005f5 <cons_getc>
	case SYS_cputs:
		sys_cputs((const char *)a1, a2);
		break;
	case SYS_cgetc:
		retVal = sys_cgetc();
		break;
f0104618:	e9 cc 03 00 00       	jmp    f01049e9 <syscall+0x42d>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010461d:	83 ec 04             	sub    $0x4,%esp
f0104620:	6a 01                	push   $0x1
f0104622:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104625:	50                   	push   %eax
f0104626:	ff 75 0c             	pushl  0xc(%ebp)
f0104629:	e8 bb e9 ff ff       	call   f0102fe9 <envid2env>
f010462e:	83 c4 10             	add    $0x10,%esp
f0104631:	85 c0                	test   %eax,%eax
f0104633:	0f 88 b0 03 00 00    	js     f01049e9 <syscall+0x42d>
		return r;
	if (e == curenv)
f0104639:	e8 3c 15 00 00       	call   f0105b7a <cpunum>
f010463e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104641:	6b c0 74             	imul   $0x74,%eax,%eax
f0104644:	39 90 28 00 23 f0    	cmp    %edx,-0xfdcffd8(%eax)
f010464a:	75 23                	jne    f010466f <syscall+0xb3>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f010464c:	e8 29 15 00 00       	call   f0105b7a <cpunum>
f0104651:	83 ec 08             	sub    $0x8,%esp
f0104654:	6b c0 74             	imul   $0x74,%eax,%eax
f0104657:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f010465d:	ff 70 48             	pushl  0x48(%eax)
f0104660:	68 ab 7a 10 f0       	push   $0xf0107aab
f0104665:	e8 f9 f1 ff ff       	call   f0103863 <cprintf>
f010466a:	83 c4 10             	add    $0x10,%esp
f010466d:	eb 25                	jmp    f0104694 <syscall+0xd8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010466f:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104672:	e8 03 15 00 00       	call   f0105b7a <cpunum>
f0104677:	83 ec 04             	sub    $0x4,%esp
f010467a:	53                   	push   %ebx
f010467b:	6b c0 74             	imul   $0x74,%eax,%eax
f010467e:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f0104684:	ff 70 48             	pushl  0x48(%eax)
f0104687:	68 c6 7a 10 f0       	push   $0xf0107ac6
f010468c:	e8 d2 f1 ff ff       	call   f0103863 <cprintf>
f0104691:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104694:	83 ec 0c             	sub    $0xc,%esp
f0104697:	ff 75 e4             	pushl  -0x1c(%ebp)
f010469a:	e8 0b ef ff ff       	call   f01035aa <env_destroy>
f010469f:	83 c4 10             	add    $0x10,%esp
	return 0;
f01046a2:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_cgetc:
		retVal = sys_cgetc();
		break;
	case SYS_env_destroy:
		retVal = sys_env_destroy(a1);
		break;
f01046a7:	e9 3d 03 00 00       	jmp    f01049e9 <syscall+0x42d>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01046ac:	e8 c9 14 00 00       	call   f0105b7a <cpunum>
f01046b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b4:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01046ba:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_env_destroy:
		retVal = sys_env_destroy(a1);
		break;
	case SYS_getenvid:
		retVal = sys_getenvid();
		break;
f01046bd:	e9 27 03 00 00       	jmp    f01049e9 <syscall+0x42d>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01046c2:	e8 78 fd ff ff       	call   f010443f <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	// panic("sys_exofork not implemented");
	struct Env *e;
	int r = env_alloc(&e, curenv->env_id);
f01046c7:	e8 ae 14 00 00       	call   f0105b7a <cpunum>
f01046cc:	83 ec 08             	sub    $0x8,%esp
f01046cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d2:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01046d8:	ff 70 48             	pushl  0x48(%eax)
f01046db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046de:	50                   	push   %eax
f01046df:	e8 10 ea ff ff       	call   f01030f4 <env_alloc>
	if (r < 0) return r;
f01046e4:	83 c4 10             	add    $0x10,%esp
f01046e7:	85 c0                	test   %eax,%eax
f01046e9:	0f 88 fa 02 00 00    	js     f01049e9 <syscall+0x42d>
	e->env_status = ENV_NOT_RUNNABLE;
f01046ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01046f2:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f01046f9:	e8 7c 14 00 00       	call   f0105b7a <cpunum>
f01046fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104701:	8b b0 28 00 23 f0    	mov    -0xfdcffd8(%eax),%esi
f0104707:	b9 11 00 00 00       	mov    $0x11,%ecx
f010470c:	89 df                	mov    %ebx,%edi
f010470e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0104710:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104713:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f010471a:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_yield:
		sys_yield();
		break;
	case SYS_exofork:
		retVal = (int32_t)sys_exofork();
		break;
f010471d:	e9 c7 02 00 00       	jmp    f01049e9 <syscall+0x42d>
	// envid's status.

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");
	
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;	
f0104722:	8b 45 10             	mov    0x10(%ebp),%eax
f0104725:	83 e8 02             	sub    $0x2,%eax
f0104728:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f010472d:	75 2b                	jne    f010475a <syscall+0x19e>
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f010472f:	83 ec 04             	sub    $0x4,%esp
f0104732:	6a 01                	push   $0x1
f0104734:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104737:	50                   	push   %eax
f0104738:	ff 75 0c             	pushl  0xc(%ebp)
f010473b:	e8 a9 e8 ff ff       	call   f0102fe9 <envid2env>
f0104740:	83 c4 10             	add    $0x10,%esp
f0104743:	85 c0                	test   %eax,%eax
f0104745:	78 1d                	js     f0104764 <syscall+0x1a8>
	e->env_status = status;
f0104747:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010474a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010474d:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104750:	b8 00 00 00 00       	mov    $0x0,%eax
f0104755:	e9 8f 02 00 00       	jmp    f01049e9 <syscall+0x42d>
	// envid's status.

	// LAB 4: Your code here.
	// panic("sys_env_set_status not implemented");
	
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;	
f010475a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010475f:	e9 85 02 00 00       	jmp    f01049e9 <syscall+0x42d>
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f0104764:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	case SYS_exofork:
		retVal = (int32_t)sys_exofork();
		break;
	case SYS_env_set_status:
		retVal = sys_env_set_status(a1, a2);
		break;
f0104769:	e9 7b 02 00 00       	jmp    f01049e9 <syscall+0x42d>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f010476e:	83 ec 04             	sub    $0x4,%esp
f0104771:	6a 01                	push   $0x1
f0104773:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104776:	50                   	push   %eax
f0104777:	ff 75 0c             	pushl  0xc(%ebp)
f010477a:	e8 6a e8 ff ff       	call   f0102fe9 <envid2env>
f010477f:	83 c4 10             	add    $0x10,%esp
f0104782:	85 c0                	test   %eax,%eax
f0104784:	78 13                	js     f0104799 <syscall+0x1dd>
	e->env_pgfault_upcall = func;
f0104786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104789:	8b 7d 10             	mov    0x10(%ebp),%edi
f010478c:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f010478f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104794:	e9 50 02 00 00       	jmp    f01049e9 <syscall+0x42d>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	// panic("sys_env_set_pgfault_upcall not implemented");
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f0104799:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	case SYS_env_set_status:
		retVal = sys_env_set_status(a1, a2);
		break;
	case SYS_env_set_pgfault_upcall:
		retVal = sys_env_set_pgfault_upcall(a1, (void *)a2);
		break;
f010479e:	e9 46 02 00 00       	jmp    f01049e9 <syscall+0x42d>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");
	if ((~perm & (PTE_U|PTE_P)) != 0) return -E_INVAL;
f01047a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01047a6:	f7 d0                	not    %eax
f01047a8:	a8 05                	test   $0x5,%al
f01047aa:	75 75                	jne    f0104821 <syscall+0x265>
	if ((perm & (~(PTE_U|PTE_P|PTE_AVAIL|PTE_W))) != 0) return -E_INVAL;
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f01047ac:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f01047b3:	75 76                	jne    f010482b <syscall+0x26f>
f01047b5:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047bc:	77 6d                	ja     f010482b <syscall+0x26f>
f01047be:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047c5:	75 6e                	jne    f0104835 <syscall+0x279>
	
	struct PageInfo *pginfo = page_alloc(ALLOC_ZERO);
f01047c7:	83 ec 0c             	sub    $0xc,%esp
f01047ca:	6a 01                	push   $0x1
f01047cc:	e8 23 c9 ff ff       	call   f01010f4 <page_alloc>
f01047d1:	89 c3                	mov    %eax,%ebx
	if (!pginfo) return -E_NO_MEM;
f01047d3:	83 c4 10             	add    $0x10,%esp
f01047d6:	85 c0                	test   %eax,%eax
f01047d8:	74 65                	je     f010483f <syscall+0x283>
	struct Env *e;
	int r = envid2env(envid, &e, 1);
f01047da:	83 ec 04             	sub    $0x4,%esp
f01047dd:	6a 01                	push   $0x1
f01047df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01047e2:	50                   	push   %eax
f01047e3:	ff 75 0c             	pushl  0xc(%ebp)
f01047e6:	e8 fe e7 ff ff       	call   f0102fe9 <envid2env>
	if (r < 0) return -E_BAD_ENV;
f01047eb:	83 c4 10             	add    $0x10,%esp
f01047ee:	85 c0                	test   %eax,%eax
f01047f0:	78 57                	js     f0104849 <syscall+0x28d>
	r = page_insert(e->env_pgdir, pginfo, va, perm);
f01047f2:	ff 75 14             	pushl  0x14(%ebp)
f01047f5:	ff 75 10             	pushl  0x10(%ebp)
f01047f8:	53                   	push   %ebx
f01047f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047fc:	ff 70 60             	pushl  0x60(%eax)
f01047ff:	e8 e5 cb ff ff       	call   f01013e9 <page_insert>
	if (r < 0) {
f0104804:	83 c4 10             	add    $0x10,%esp
f0104807:	85 c0                	test   %eax,%eax
f0104809:	79 48                	jns    f0104853 <syscall+0x297>
		page_free(pginfo);
f010480b:	83 ec 0c             	sub    $0xc,%esp
f010480e:	53                   	push   %ebx
f010480f:	e8 50 c9 ff ff       	call   f0101164 <page_free>
f0104814:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104817:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010481c:	e9 c8 01 00 00       	jmp    f01049e9 <syscall+0x42d>
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	// panic("sys_page_alloc not implemented");
	if ((~perm & (PTE_U|PTE_P)) != 0) return -E_INVAL;
f0104821:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104826:	e9 be 01 00 00       	jmp    f01049e9 <syscall+0x42d>
	if ((perm & (~(PTE_U|PTE_P|PTE_AVAIL|PTE_W))) != 0) return -E_INVAL;
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL; 
f010482b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104830:	e9 b4 01 00 00       	jmp    f01049e9 <syscall+0x42d>
f0104835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010483a:	e9 aa 01 00 00       	jmp    f01049e9 <syscall+0x42d>
	
	struct PageInfo *pginfo = page_alloc(ALLOC_ZERO);
	if (!pginfo) return -E_NO_MEM;
f010483f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104844:	e9 a0 01 00 00       	jmp    f01049e9 <syscall+0x42d>
	struct Env *e;
	int r = envid2env(envid, &e, 1);
	if (r < 0) return -E_BAD_ENV;
f0104849:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010484e:	e9 96 01 00 00       	jmp    f01049e9 <syscall+0x42d>
	r = page_insert(e->env_pgdir, pginfo, va, perm);
	if (r < 0) {
		page_free(pginfo);
		return -E_NO_MEM;
	}
	return 0;
f0104853:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_env_set_pgfault_upcall:
		retVal = sys_env_set_pgfault_upcall(a1, (void *)a2);
		break;
	case SYS_page_alloc:
		retVal = sys_page_alloc(a1,(void *)a2, (int)a3);
		break;
f0104858:	e9 8c 01 00 00       	jmp    f01049e9 <syscall+0x42d>
	case SYS_page_map:
		retVal = sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
f010485d:	83 ec 08             	sub    $0x8,%esp
f0104860:	ff 75 1c             	pushl  0x1c(%ebp)
f0104863:	ff 75 18             	pushl  0x18(%ebp)
f0104866:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0104869:	8b 55 10             	mov    0x10(%ebp),%edx
f010486c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010486f:	e8 4b fc ff ff       	call   f01044bf <sys_page_map>
		break;
f0104874:	83 c4 10             	add    $0x10,%esp
f0104877:	e9 6d 01 00 00       	jmp    f01049e9 <syscall+0x42d>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL;
f010487c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104883:	77 3f                	ja     f01048c4 <syscall+0x308>
f0104885:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010488c:	75 40                	jne    f01048ce <syscall+0x312>
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f010488e:	83 ec 04             	sub    $0x4,%esp
f0104891:	6a 01                	push   $0x1
f0104893:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104896:	50                   	push   %eax
f0104897:	ff 75 0c             	pushl  0xc(%ebp)
f010489a:	e8 4a e7 ff ff       	call   f0102fe9 <envid2env>
f010489f:	83 c4 10             	add    $0x10,%esp
f01048a2:	85 c0                	test   %eax,%eax
f01048a4:	78 32                	js     f01048d8 <syscall+0x31c>
	page_remove(e->env_pgdir, va);
f01048a6:	83 ec 08             	sub    $0x8,%esp
f01048a9:	ff 75 10             	pushl  0x10(%ebp)
f01048ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048af:	ff 70 60             	pushl  0x60(%eax)
f01048b2:	e8 ec ca ff ff       	call   f01013a3 <page_remove>
f01048b7:	83 c4 10             	add    $0x10,%esp
	return 0;
f01048ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01048bf:	e9 25 01 00 00       	jmp    f01049e9 <syscall+0x42d>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	// panic("sys_page_unmap not implemented");
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL;
f01048c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048c9:	e9 1b 01 00 00       	jmp    f01049e9 <syscall+0x42d>
f01048ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01048d3:	e9 11 01 00 00       	jmp    f01049e9 <syscall+0x42d>
	struct Env *e;
	if (envid2env(envid, &e, 1) < 0) return -E_BAD_ENV;
f01048d8:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	case SYS_page_map:
		retVal = sys_page_map(a1, (void *)a2, a3, (void*)a4, (int)a5);
		break;
	case SYS_page_unmap:
		retVal = sys_page_unmap(a1, (void *)a2);
		break;
f01048dd:	e9 07 01 00 00       	jmp    f01049e9 <syscall+0x42d>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01048e2:	e8 93 12 00 00       	call   f0105b7a <cpunum>
f01048e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01048ea:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
f01048f0:	8b 58 48             	mov    0x48(%eax),%ebx
	// LAB 4: Your code here.
	// panic("sys_ipc_try_send not implemented");

	envid_t src_envid = sys_getenvid(); 
	struct Env *dst_e;
	if (envid2env(envid, &dst_e, 0) < 0) {
f01048f3:	83 ec 04             	sub    $0x4,%esp
f01048f6:	6a 00                	push   $0x0
f01048f8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048fb:	50                   	push   %eax
f01048fc:	ff 75 0c             	pushl  0xc(%ebp)
f01048ff:	e8 e5 e6 ff ff       	call   f0102fe9 <envid2env>
f0104904:	83 c4 10             	add    $0x10,%esp
f0104907:	85 c0                	test   %eax,%eax
f0104909:	78 6c                	js     f0104977 <syscall+0x3bb>
		return -E_BAD_ENV;
	}

	if (dst_e->env_ipc_recving == false) // || dst_e->env_ipc_from != 0) 
f010490b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010490e:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104912:	74 6a                	je     f010497e <syscall+0x3c2>
		return -E_IPC_NOT_RECV;
	
	// pass the value
	dst_e->env_ipc_value = value;
f0104914:	8b 75 10             	mov    0x10(%ebp),%esi
f0104917:	89 70 70             	mov    %esi,0x70(%eax)
	dst_e->env_ipc_perm = 0;
f010491a:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)

	// pass the page
	if ((uintptr_t)srcva < UTOP) {
f0104921:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104928:	77 2e                	ja     f0104958 <syscall+0x39c>
		// customerize 0x200 as PTE_NO_CHECK
		unsigned tmp_perm = perm | 0x200;
		int r = sys_page_map(src_envid, srcva, envid, (void *)dst_e->env_ipc_dstva, tmp_perm);
f010492a:	83 ec 08             	sub    $0x8,%esp
f010492d:	8b 55 18             	mov    0x18(%ebp),%edx
f0104930:	80 ce 02             	or     $0x2,%dh
f0104933:	52                   	push   %edx
f0104934:	ff 70 6c             	pushl  0x6c(%eax)
f0104937:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010493a:	8b 55 14             	mov    0x14(%ebp),%edx
f010493d:	89 d8                	mov    %ebx,%eax
f010493f:	e8 7b fb ff ff       	call   f01044bf <sys_page_map>
		if (r < 0) return r;
f0104944:	83 c4 10             	add    $0x10,%esp
f0104947:	85 c0                	test   %eax,%eax
f0104949:	0f 88 9a 00 00 00    	js     f01049e9 <syscall+0x42d>
		dst_e->env_ipc_perm = perm;
f010494f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104952:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104955:	89 78 78             	mov    %edi,0x78(%eax)
	}

	dst_e->env_ipc_from = src_envid;
f0104958:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010495b:	89 58 74             	mov    %ebx,0x74(%eax)
	dst_e->env_status = ENV_RUNNABLE;
f010495e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	// return from the syscall, set %eax
	dst_e->env_tf.tf_regs.reg_eax = 0;
f0104965:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	dst_e->env_ipc_recving = false;
f010496c:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	return 0;
f0104970:	b8 00 00 00 00       	mov    $0x0,%eax
f0104975:	eb 72                	jmp    f01049e9 <syscall+0x42d>
	// panic("sys_ipc_try_send not implemented");

	envid_t src_envid = sys_getenvid(); 
	struct Env *dst_e;
	if (envid2env(envid, &dst_e, 0) < 0) {
		return -E_BAD_ENV;
f0104977:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010497c:	eb 6b                	jmp    f01049e9 <syscall+0x42d>
	}

	if (dst_e->env_ipc_recving == false) // || dst_e->env_ipc_from != 0) 
		return -E_IPC_NOT_RECV;
f010497e:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	case SYS_page_unmap:
		retVal = sys_page_unmap(a1, (void *)a2);
		break;
	case SYS_ipc_try_send:
		retVal = sys_ipc_try_send(a1, a2, (void *)a3, a4);
		break;
f0104983:	eb 64                	jmp    f01049e9 <syscall+0x42d>
	// panic("sys_ipc_recv not implemented");
	
	// wrong, because when we don't want to share page, we set dstva=UTOP
	// but we can still pass value
	// if ( (uintptr_t) dstva >= UTOP) return -E_INVAL;
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;
f0104985:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010498c:	77 09                	ja     f0104997 <syscall+0x3db>
f010498e:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104995:	75 3f                	jne    f01049d6 <syscall+0x41a>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104997:	e8 de 11 00 00       	call   f0105b7a <cpunum>
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;

	envid_t envid = sys_getenvid();
	struct Env *e;
	// do not check permission
	if (envid2env(envid, &e, 0) < 0) return -E_BAD_ENV;
f010499c:	83 ec 04             	sub    $0x4,%esp
f010499f:	6a 00                	push   $0x0
f01049a1:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049a4:	52                   	push   %edx

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01049a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a8:	8b 80 28 00 23 f0    	mov    -0xfdcffd8(%eax),%eax
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;

	envid_t envid = sys_getenvid();
	struct Env *e;
	// do not check permission
	if (envid2env(envid, &e, 0) < 0) return -E_BAD_ENV;
f01049ae:	ff 70 48             	pushl  0x48(%eax)
f01049b1:	e8 33 e6 ff ff       	call   f0102fe9 <envid2env>
f01049b6:	83 c4 10             	add    $0x10,%esp
f01049b9:	85 c0                	test   %eax,%eax
f01049bb:	78 20                	js     f01049dd <syscall+0x421>
	
	e->env_ipc_recving = true;
f01049bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049c0:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	e->env_ipc_dstva = dstva;
f01049c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01049c7:	89 78 6c             	mov    %edi,0x6c(%eax)
	e->env_status = ENV_NOT_RUNNABLE;
f01049ca:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01049d1:	e8 69 fa ff ff       	call   f010443f <sched_yield>
	// panic("sys_ipc_recv not implemented");
	
	// wrong, because when we don't want to share page, we set dstva=UTOP
	// but we can still pass value
	// if ( (uintptr_t) dstva >= UTOP) return -E_INVAL;
	if ((uintptr_t) dstva < UTOP && PGOFF(dstva) != 0) return -E_INVAL;
f01049d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01049db:	eb 0c                	jmp    f01049e9 <syscall+0x42d>

	envid_t envid = sys_getenvid();
	struct Env *e;
	// do not check permission
	if (envid2env(envid, &e, 0) < 0) return -E_BAD_ENV;
f01049dd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	case SYS_ipc_try_send:
		retVal = sys_ipc_try_send(a1, a2, (void *)a3, a4);
		break;
	case SYS_ipc_recv:
		retVal = sys_ipc_recv((void *)a1);
		break;
f01049e2:	eb 05                	jmp    f01049e9 <syscall+0x42d>

	default:
		retVal = -E_INVAL;
f01049e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	return retVal;
}
f01049e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049ec:	5b                   	pop    %ebx
f01049ed:	5e                   	pop    %esi
f01049ee:	5f                   	pop    %edi
f01049ef:	5d                   	pop    %ebp
f01049f0:	c3                   	ret    

f01049f1 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01049f1:	55                   	push   %ebp
f01049f2:	89 e5                	mov    %esp,%ebp
f01049f4:	57                   	push   %edi
f01049f5:	56                   	push   %esi
f01049f6:	53                   	push   %ebx
f01049f7:	83 ec 14             	sub    $0x14,%esp
f01049fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01049fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104a00:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104a03:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104a06:	8b 1a                	mov    (%edx),%ebx
f0104a08:	8b 01                	mov    (%ecx),%eax
f0104a0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104a14:	eb 7f                	jmp    f0104a95 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104a19:	01 d8                	add    %ebx,%eax
f0104a1b:	89 c6                	mov    %eax,%esi
f0104a1d:	c1 ee 1f             	shr    $0x1f,%esi
f0104a20:	01 c6                	add    %eax,%esi
f0104a22:	d1 fe                	sar    %esi
f0104a24:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104a27:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a2a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104a2d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a2f:	eb 03                	jmp    f0104a34 <stab_binsearch+0x43>
			m--;
f0104a31:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104a34:	39 c3                	cmp    %eax,%ebx
f0104a36:	7f 0d                	jg     f0104a45 <stab_binsearch+0x54>
f0104a38:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104a3c:	83 ea 0c             	sub    $0xc,%edx
f0104a3f:	39 f9                	cmp    %edi,%ecx
f0104a41:	75 ee                	jne    f0104a31 <stab_binsearch+0x40>
f0104a43:	eb 05                	jmp    f0104a4a <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104a45:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104a48:	eb 4b                	jmp    f0104a95 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104a4a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a4d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104a50:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104a54:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104a57:	76 11                	jbe    f0104a6a <stab_binsearch+0x79>
			*region_left = m;
f0104a59:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104a5c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104a5e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a61:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a68:	eb 2b                	jmp    f0104a95 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104a6a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104a6d:	73 14                	jae    f0104a83 <stab_binsearch+0x92>
			*region_right = m - 1;
f0104a6f:	83 e8 01             	sub    $0x1,%eax
f0104a72:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104a75:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104a78:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a7a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104a81:	eb 12                	jmp    f0104a95 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104a83:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104a86:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104a88:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104a8c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104a8e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104a95:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104a98:	0f 8e 78 ff ff ff    	jle    f0104a16 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104a9e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104aa2:	75 0f                	jne    f0104ab3 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104aa4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104aa7:	8b 00                	mov    (%eax),%eax
f0104aa9:	83 e8 01             	sub    $0x1,%eax
f0104aac:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104aaf:	89 06                	mov    %eax,(%esi)
f0104ab1:	eb 2c                	jmp    f0104adf <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ab3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ab6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104ab8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104abb:	8b 0e                	mov    (%esi),%ecx
f0104abd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ac0:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104ac3:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ac6:	eb 03                	jmp    f0104acb <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104ac8:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104acb:	39 c8                	cmp    %ecx,%eax
f0104acd:	7e 0b                	jle    f0104ada <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104acf:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104ad3:	83 ea 0c             	sub    $0xc,%edx
f0104ad6:	39 df                	cmp    %ebx,%edi
f0104ad8:	75 ee                	jne    f0104ac8 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104ada:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104add:	89 06                	mov    %eax,(%esi)
	}
}
f0104adf:	83 c4 14             	add    $0x14,%esp
f0104ae2:	5b                   	pop    %ebx
f0104ae3:	5e                   	pop    %esi
f0104ae4:	5f                   	pop    %edi
f0104ae5:	5d                   	pop    %ebp
f0104ae6:	c3                   	ret    

f0104ae7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104ae7:	55                   	push   %ebp
f0104ae8:	89 e5                	mov    %esp,%ebp
f0104aea:	57                   	push   %edi
f0104aeb:	56                   	push   %esi
f0104aec:	53                   	push   %ebx
f0104aed:	83 ec 3c             	sub    $0x3c,%esp
f0104af0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104af3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104af6:	c7 03 14 7b 10 f0    	movl   $0xf0107b14,(%ebx)
	info->eip_line = 0;
f0104afc:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104b03:	c7 43 08 14 7b 10 f0 	movl   $0xf0107b14,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104b0a:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104b11:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104b14:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104b1b:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104b21:	0f 87 a3 00 00 00    	ja     f0104bca <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
f0104b27:	e8 4e 10 00 00       	call   f0105b7a <cpunum>
f0104b2c:	6a 04                	push   $0x4
f0104b2e:	6a 10                	push   $0x10
f0104b30:	68 00 00 20 00       	push   $0x200000
f0104b35:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b38:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104b3e:	e8 4b e3 ff ff       	call   f0102e8e <user_mem_check>
f0104b43:	83 c4 10             	add    $0x10,%esp
f0104b46:	85 c0                	test   %eax,%eax
f0104b48:	0f 88 3e 02 00 00    	js     f0104d8c <debuginfo_eip+0x2a5>
			return -1;
		}

		stabs = usd->stabs;
f0104b4e:	a1 00 00 20 00       	mov    0x200000,%eax
f0104b53:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104b56:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104b5c:	8b 15 08 00 20 00    	mov    0x200008,%edx
f0104b62:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0104b65:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0104b6a:	89 45 bc             	mov    %eax,-0x44(%ebp)
		// LAB 3: Your code here.
		/*
		cprintf("usd = %p, stab_start = %p, stab_end= %p, str_start = %p, str_end= %p\n",
			usd, stabs, stab_end, stabstr, stabstr_end);
		*/
		if (user_mem_check(curenv, (void *)stabs, stab_end-stabs, PTE_U) < 0) {
f0104b6d:	e8 08 10 00 00       	call   f0105b7a <cpunum>
f0104b72:	6a 04                	push   $0x4
f0104b74:	89 f2                	mov    %esi,%edx
f0104b76:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104b79:	29 ca                	sub    %ecx,%edx
f0104b7b:	c1 fa 02             	sar    $0x2,%edx
f0104b7e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0104b84:	52                   	push   %edx
f0104b85:	51                   	push   %ecx
f0104b86:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b89:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104b8f:	e8 fa e2 ff ff       	call   f0102e8e <user_mem_check>
f0104b94:	83 c4 10             	add    $0x10,%esp
f0104b97:	85 c0                	test   %eax,%eax
f0104b99:	0f 88 f4 01 00 00    	js     f0104d93 <debuginfo_eip+0x2ac>
			return -1;
		}
		if (user_mem_check(curenv, (void *)stabstr, stabstr_end-stabstr, PTE_U) < 0) {
f0104b9f:	e8 d6 0f 00 00       	call   f0105b7a <cpunum>
f0104ba4:	6a 04                	push   $0x4
f0104ba6:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104ba9:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104bac:	29 ca                	sub    %ecx,%edx
f0104bae:	52                   	push   %edx
f0104baf:	51                   	push   %ecx
f0104bb0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb3:	ff b0 28 00 23 f0    	pushl  -0xfdcffd8(%eax)
f0104bb9:	e8 d0 e2 ff ff       	call   f0102e8e <user_mem_check>
f0104bbe:	83 c4 10             	add    $0x10,%esp
f0104bc1:	85 c0                	test   %eax,%eax
f0104bc3:	79 1f                	jns    f0104be4 <debuginfo_eip+0xfd>
f0104bc5:	e9 d0 01 00 00       	jmp    f0104d9a <debuginfo_eip+0x2b3>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104bca:	c7 45 bc 52 5c 11 f0 	movl   $0xf0115c52,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104bd1:	c7 45 b8 59 24 11 f0 	movl   $0xf0112459,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104bd8:	be 58 24 11 f0       	mov    $0xf0112458,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104bdd:	c7 45 c0 f4 7f 10 f0 	movl   $0xf0107ff4,-0x40(%ebp)
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104be4:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104be7:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104bea:	0f 83 b1 01 00 00    	jae    f0104da1 <debuginfo_eip+0x2ba>
f0104bf0:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0104bf4:	0f 85 ae 01 00 00    	jne    f0104da8 <debuginfo_eip+0x2c1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104bfa:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c01:	2b 75 c0             	sub    -0x40(%ebp),%esi
f0104c04:	c1 fe 02             	sar    $0x2,%esi
f0104c07:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104c0d:	83 e8 01             	sub    $0x1,%eax
f0104c10:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c13:	83 ec 08             	sub    $0x8,%esp
f0104c16:	57                   	push   %edi
f0104c17:	6a 64                	push   $0x64
f0104c19:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104c1c:	89 d1                	mov    %edx,%ecx
f0104c1e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c21:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104c24:	89 f0                	mov    %esi,%eax
f0104c26:	e8 c6 fd ff ff       	call   f01049f1 <stab_binsearch>
	if (lfile == 0)
f0104c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c2e:	83 c4 10             	add    $0x10,%esp
f0104c31:	85 c0                	test   %eax,%eax
f0104c33:	0f 84 76 01 00 00    	je     f0104daf <debuginfo_eip+0x2c8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c39:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c3f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c42:	83 ec 08             	sub    $0x8,%esp
f0104c45:	57                   	push   %edi
f0104c46:	6a 24                	push   $0x24
f0104c48:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0104c4b:	89 d1                	mov    %edx,%ecx
f0104c4d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c50:	89 f0                	mov    %esi,%eax
f0104c52:	e8 9a fd ff ff       	call   f01049f1 <stab_binsearch>

	if (lfun <= rfun) {
f0104c57:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c5a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104c5d:	83 c4 10             	add    $0x10,%esp
f0104c60:	39 d0                	cmp    %edx,%eax
f0104c62:	7f 2e                	jg     f0104c92 <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104c64:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0104c67:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0104c6a:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0104c6d:	8b 36                	mov    (%esi),%esi
f0104c6f:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0104c72:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f0104c75:	39 ce                	cmp    %ecx,%esi
f0104c77:	73 06                	jae    f0104c7f <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104c79:	03 75 b8             	add    -0x48(%ebp),%esi
f0104c7c:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104c7f:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104c82:	8b 4e 08             	mov    0x8(%esi),%ecx
f0104c85:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104c88:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104c8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104c8d:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0104c90:	eb 0f                	jmp    f0104ca1 <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104c92:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104c95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c98:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104c9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c9e:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104ca1:	83 ec 08             	sub    $0x8,%esp
f0104ca4:	6a 3a                	push   $0x3a
f0104ca6:	ff 73 08             	pushl  0x8(%ebx)
f0104ca9:	e8 8f 08 00 00       	call   f010553d <strfind>
f0104cae:	2b 43 08             	sub    0x8(%ebx),%eax
f0104cb1:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104cb4:	83 c4 08             	add    $0x8,%esp
f0104cb7:	57                   	push   %edi
f0104cb8:	6a 44                	push   $0x44
f0104cba:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104cbd:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104cc0:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104cc3:	89 f8                	mov    %edi,%eax
f0104cc5:	e8 27 fd ff ff       	call   f01049f1 <stab_binsearch>
	if (lline <= rline) {
f0104cca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104ccd:	83 c4 10             	add    $0x10,%esp
f0104cd0:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104cd3:	0f 8f dd 00 00 00    	jg     f0104db6 <debuginfo_eip+0x2cf>
		info->eip_line = stabs[lline].n_desc;
f0104cd9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cdc:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104cdf:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0104ce3:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104ce6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ce9:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104ced:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104cf0:	eb 0a                	jmp    f0104cfc <debuginfo_eip+0x215>
f0104cf2:	83 e8 01             	sub    $0x1,%eax
f0104cf5:	83 ea 0c             	sub    $0xc,%edx
f0104cf8:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0104cfc:	39 c7                	cmp    %eax,%edi
f0104cfe:	7e 05                	jle    f0104d05 <debuginfo_eip+0x21e>
f0104d00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d03:	eb 47                	jmp    f0104d4c <debuginfo_eip+0x265>
	       && stabs[lline].n_type != N_SOL
f0104d05:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d09:	80 f9 84             	cmp    $0x84,%cl
f0104d0c:	75 0e                	jne    f0104d1c <debuginfo_eip+0x235>
f0104d0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d11:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d15:	74 1c                	je     f0104d33 <debuginfo_eip+0x24c>
f0104d17:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104d1a:	eb 17                	jmp    f0104d33 <debuginfo_eip+0x24c>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d1c:	80 f9 64             	cmp    $0x64,%cl
f0104d1f:	75 d1                	jne    f0104cf2 <debuginfo_eip+0x20b>
f0104d21:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104d25:	74 cb                	je     f0104cf2 <debuginfo_eip+0x20b>
f0104d27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d2a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d2e:	74 03                	je     f0104d33 <debuginfo_eip+0x24c>
f0104d30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d33:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104d36:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d39:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104d3c:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104d3f:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104d42:	29 f8                	sub    %edi,%eax
f0104d44:	39 c2                	cmp    %eax,%edx
f0104d46:	73 04                	jae    f0104d4c <debuginfo_eip+0x265>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104d48:	01 fa                	add    %edi,%edx
f0104d4a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d4f:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d52:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d57:	39 f2                	cmp    %esi,%edx
f0104d59:	7d 67                	jge    f0104dc2 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
f0104d5b:	83 c2 01             	add    $0x1,%edx
f0104d5e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104d61:	89 d0                	mov    %edx,%eax
f0104d63:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104d66:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104d69:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104d6c:	eb 04                	jmp    f0104d72 <debuginfo_eip+0x28b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104d6e:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104d72:	39 c6                	cmp    %eax,%esi
f0104d74:	7e 47                	jle    f0104dbd <debuginfo_eip+0x2d6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104d76:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104d7a:	83 c0 01             	add    $0x1,%eax
f0104d7d:	83 c2 0c             	add    $0xc,%edx
f0104d80:	80 f9 a0             	cmp    $0xa0,%cl
f0104d83:	74 e9                	je     f0104d6e <debuginfo_eip+0x287>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d85:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d8a:	eb 36                	jmp    f0104dc2 <debuginfo_eip+0x2db>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) {
			return -1;
f0104d8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d91:	eb 2f                	jmp    f0104dc2 <debuginfo_eip+0x2db>
		/*
		cprintf("usd = %p, stab_start = %p, stab_end= %p, str_start = %p, str_end= %p\n",
			usd, stabs, stab_end, stabstr, stabstr_end);
		*/
		if (user_mem_check(curenv, (void *)stabs, stab_end-stabs, PTE_U) < 0) {
			return -1;
f0104d93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d98:	eb 28                	jmp    f0104dc2 <debuginfo_eip+0x2db>
		}
		if (user_mem_check(curenv, (void *)stabstr, stabstr_end-stabstr, PTE_U) < 0) {
			return -1;
f0104d9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104d9f:	eb 21                	jmp    f0104dc2 <debuginfo_eip+0x2db>
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104da1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104da6:	eb 1a                	jmp    f0104dc2 <debuginfo_eip+0x2db>
f0104da8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dad:	eb 13                	jmp    f0104dc2 <debuginfo_eip+0x2db>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104daf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104db4:	eb 0c                	jmp    f0104dc2 <debuginfo_eip+0x2db>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
f0104db6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dbb:	eb 05                	jmp    f0104dc2 <debuginfo_eip+0x2db>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dc5:	5b                   	pop    %ebx
f0104dc6:	5e                   	pop    %esi
f0104dc7:	5f                   	pop    %edi
f0104dc8:	5d                   	pop    %ebp
f0104dc9:	c3                   	ret    

f0104dca <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104dca:	55                   	push   %ebp
f0104dcb:	89 e5                	mov    %esp,%ebp
f0104dcd:	57                   	push   %edi
f0104dce:	56                   	push   %esi
f0104dcf:	53                   	push   %ebx
f0104dd0:	83 ec 1c             	sub    $0x1c,%esp
f0104dd3:	89 c7                	mov    %eax,%edi
f0104dd5:	89 d6                	mov    %edx,%esi
f0104dd7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104dda:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ddd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104de0:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104de3:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104de6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104deb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104dee:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104df1:	39 d3                	cmp    %edx,%ebx
f0104df3:	72 05                	jb     f0104dfa <printnum+0x30>
f0104df5:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104df8:	77 45                	ja     f0104e3f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104dfa:	83 ec 0c             	sub    $0xc,%esp
f0104dfd:	ff 75 18             	pushl  0x18(%ebp)
f0104e00:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e03:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e06:	53                   	push   %ebx
f0104e07:	ff 75 10             	pushl  0x10(%ebp)
f0104e0a:	83 ec 08             	sub    $0x8,%esp
f0104e0d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e10:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e13:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e16:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e19:	e8 62 11 00 00       	call   f0105f80 <__udivdi3>
f0104e1e:	83 c4 18             	add    $0x18,%esp
f0104e21:	52                   	push   %edx
f0104e22:	50                   	push   %eax
f0104e23:	89 f2                	mov    %esi,%edx
f0104e25:	89 f8                	mov    %edi,%eax
f0104e27:	e8 9e ff ff ff       	call   f0104dca <printnum>
f0104e2c:	83 c4 20             	add    $0x20,%esp
f0104e2f:	eb 18                	jmp    f0104e49 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e31:	83 ec 08             	sub    $0x8,%esp
f0104e34:	56                   	push   %esi
f0104e35:	ff 75 18             	pushl  0x18(%ebp)
f0104e38:	ff d7                	call   *%edi
f0104e3a:	83 c4 10             	add    $0x10,%esp
f0104e3d:	eb 03                	jmp    f0104e42 <printnum+0x78>
f0104e3f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104e42:	83 eb 01             	sub    $0x1,%ebx
f0104e45:	85 db                	test   %ebx,%ebx
f0104e47:	7f e8                	jg     f0104e31 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e49:	83 ec 08             	sub    $0x8,%esp
f0104e4c:	56                   	push   %esi
f0104e4d:	83 ec 04             	sub    $0x4,%esp
f0104e50:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e53:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e56:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e59:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e5c:	e8 4f 12 00 00       	call   f01060b0 <__umoddi3>
f0104e61:	83 c4 14             	add    $0x14,%esp
f0104e64:	0f be 80 1e 7b 10 f0 	movsbl -0xfef84e2(%eax),%eax
f0104e6b:	50                   	push   %eax
f0104e6c:	ff d7                	call   *%edi
}
f0104e6e:	83 c4 10             	add    $0x10,%esp
f0104e71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e74:	5b                   	pop    %ebx
f0104e75:	5e                   	pop    %esi
f0104e76:	5f                   	pop    %edi
f0104e77:	5d                   	pop    %ebp
f0104e78:	c3                   	ret    

f0104e79 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104e79:	55                   	push   %ebp
f0104e7a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104e7c:	83 fa 01             	cmp    $0x1,%edx
f0104e7f:	7e 0e                	jle    f0104e8f <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104e81:	8b 10                	mov    (%eax),%edx
f0104e83:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104e86:	89 08                	mov    %ecx,(%eax)
f0104e88:	8b 02                	mov    (%edx),%eax
f0104e8a:	8b 52 04             	mov    0x4(%edx),%edx
f0104e8d:	eb 22                	jmp    f0104eb1 <getuint+0x38>
	else if (lflag)
f0104e8f:	85 d2                	test   %edx,%edx
f0104e91:	74 10                	je     f0104ea3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104e93:	8b 10                	mov    (%eax),%edx
f0104e95:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104e98:	89 08                	mov    %ecx,(%eax)
f0104e9a:	8b 02                	mov    (%edx),%eax
f0104e9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ea1:	eb 0e                	jmp    f0104eb1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104ea3:	8b 10                	mov    (%eax),%edx
f0104ea5:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ea8:	89 08                	mov    %ecx,(%eax)
f0104eaa:	8b 02                	mov    (%edx),%eax
f0104eac:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104eb1:	5d                   	pop    %ebp
f0104eb2:	c3                   	ret    

f0104eb3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104eb3:	55                   	push   %ebp
f0104eb4:	89 e5                	mov    %esp,%ebp
f0104eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104eb9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104ebd:	8b 10                	mov    (%eax),%edx
f0104ebf:	3b 50 04             	cmp    0x4(%eax),%edx
f0104ec2:	73 0a                	jae    f0104ece <sprintputch+0x1b>
		*b->buf++ = ch;
f0104ec4:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104ec7:	89 08                	mov    %ecx,(%eax)
f0104ec9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ecc:	88 02                	mov    %al,(%edx)
}
f0104ece:	5d                   	pop    %ebp
f0104ecf:	c3                   	ret    

f0104ed0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104ed0:	55                   	push   %ebp
f0104ed1:	89 e5                	mov    %esp,%ebp
f0104ed3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104ed6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104ed9:	50                   	push   %eax
f0104eda:	ff 75 10             	pushl  0x10(%ebp)
f0104edd:	ff 75 0c             	pushl  0xc(%ebp)
f0104ee0:	ff 75 08             	pushl  0x8(%ebp)
f0104ee3:	e8 05 00 00 00       	call   f0104eed <vprintfmt>
	va_end(ap);
}
f0104ee8:	83 c4 10             	add    $0x10,%esp
f0104eeb:	c9                   	leave  
f0104eec:	c3                   	ret    

f0104eed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104eed:	55                   	push   %ebp
f0104eee:	89 e5                	mov    %esp,%ebp
f0104ef0:	57                   	push   %edi
f0104ef1:	56                   	push   %esi
f0104ef2:	53                   	push   %ebx
f0104ef3:	83 ec 2c             	sub    $0x2c,%esp
f0104ef6:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ef9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104efc:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104eff:	eb 12                	jmp    f0104f13 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104f01:	85 c0                	test   %eax,%eax
f0104f03:	0f 84 89 03 00 00    	je     f0105292 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0104f09:	83 ec 08             	sub    $0x8,%esp
f0104f0c:	53                   	push   %ebx
f0104f0d:	50                   	push   %eax
f0104f0e:	ff d6                	call   *%esi
f0104f10:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104f13:	83 c7 01             	add    $0x1,%edi
f0104f16:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f1a:	83 f8 25             	cmp    $0x25,%eax
f0104f1d:	75 e2                	jne    f0104f01 <vprintfmt+0x14>
f0104f1f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104f23:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104f2a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f31:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104f38:	ba 00 00 00 00       	mov    $0x0,%edx
f0104f3d:	eb 07                	jmp    f0104f46 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104f42:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f46:	8d 47 01             	lea    0x1(%edi),%eax
f0104f49:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f4c:	0f b6 07             	movzbl (%edi),%eax
f0104f4f:	0f b6 c8             	movzbl %al,%ecx
f0104f52:	83 e8 23             	sub    $0x23,%eax
f0104f55:	3c 55                	cmp    $0x55,%al
f0104f57:	0f 87 1a 03 00 00    	ja     f0105277 <vprintfmt+0x38a>
f0104f5d:	0f b6 c0             	movzbl %al,%eax
f0104f60:	ff 24 85 e0 7b 10 f0 	jmp    *-0xfef8420(,%eax,4)
f0104f67:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104f6a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f6e:	eb d6                	jmp    f0104f46 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f73:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104f7b:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104f7e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104f82:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104f85:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104f88:	83 fa 09             	cmp    $0x9,%edx
f0104f8b:	77 39                	ja     f0104fc6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104f8d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104f90:	eb e9                	jmp    f0104f7b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104f92:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f95:	8d 48 04             	lea    0x4(%eax),%ecx
f0104f98:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104f9b:	8b 00                	mov    (%eax),%eax
f0104f9d:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fa0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104fa3:	eb 27                	jmp    f0104fcc <vprintfmt+0xdf>
f0104fa5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fa8:	85 c0                	test   %eax,%eax
f0104faa:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104faf:	0f 49 c8             	cmovns %eax,%ecx
f0104fb2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104fb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fb8:	eb 8c                	jmp    f0104f46 <vprintfmt+0x59>
f0104fba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104fbd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104fc4:	eb 80                	jmp    f0104f46 <vprintfmt+0x59>
f0104fc6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104fc9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104fcc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104fd0:	0f 89 70 ff ff ff    	jns    f0104f46 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104fd6:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104fd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104fdc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104fe3:	e9 5e ff ff ff       	jmp    f0104f46 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104fe8:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104feb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104fee:	e9 53 ff ff ff       	jmp    f0104f46 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104ff3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ff6:	8d 50 04             	lea    0x4(%eax),%edx
f0104ff9:	89 55 14             	mov    %edx,0x14(%ebp)
f0104ffc:	83 ec 08             	sub    $0x8,%esp
f0104fff:	53                   	push   %ebx
f0105000:	ff 30                	pushl  (%eax)
f0105002:	ff d6                	call   *%esi
			break;
f0105004:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105007:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010500a:	e9 04 ff ff ff       	jmp    f0104f13 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010500f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105012:	8d 50 04             	lea    0x4(%eax),%edx
f0105015:	89 55 14             	mov    %edx,0x14(%ebp)
f0105018:	8b 00                	mov    (%eax),%eax
f010501a:	99                   	cltd   
f010501b:	31 d0                	xor    %edx,%eax
f010501d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010501f:	83 f8 08             	cmp    $0x8,%eax
f0105022:	7f 0b                	jg     f010502f <vprintfmt+0x142>
f0105024:	8b 14 85 40 7d 10 f0 	mov    -0xfef82c0(,%eax,4),%edx
f010502b:	85 d2                	test   %edx,%edx
f010502d:	75 18                	jne    f0105047 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f010502f:	50                   	push   %eax
f0105030:	68 36 7b 10 f0       	push   $0xf0107b36
f0105035:	53                   	push   %ebx
f0105036:	56                   	push   %esi
f0105037:	e8 94 fe ff ff       	call   f0104ed0 <printfmt>
f010503c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010503f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105042:	e9 cc fe ff ff       	jmp    f0104f13 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0105047:	52                   	push   %edx
f0105048:	68 b9 72 10 f0       	push   $0xf01072b9
f010504d:	53                   	push   %ebx
f010504e:	56                   	push   %esi
f010504f:	e8 7c fe ff ff       	call   f0104ed0 <printfmt>
f0105054:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105057:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010505a:	e9 b4 fe ff ff       	jmp    f0104f13 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010505f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105062:	8d 50 04             	lea    0x4(%eax),%edx
f0105065:	89 55 14             	mov    %edx,0x14(%ebp)
f0105068:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010506a:	85 ff                	test   %edi,%edi
f010506c:	b8 2f 7b 10 f0       	mov    $0xf0107b2f,%eax
f0105071:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105074:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105078:	0f 8e 94 00 00 00    	jle    f0105112 <vprintfmt+0x225>
f010507e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105082:	0f 84 98 00 00 00    	je     f0105120 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105088:	83 ec 08             	sub    $0x8,%esp
f010508b:	ff 75 d0             	pushl  -0x30(%ebp)
f010508e:	57                   	push   %edi
f010508f:	e8 5f 03 00 00       	call   f01053f3 <strnlen>
f0105094:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105097:	29 c1                	sub    %eax,%ecx
f0105099:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f010509c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010509f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01050a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01050a6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01050a9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01050ab:	eb 0f                	jmp    f01050bc <vprintfmt+0x1cf>
					putch(padc, putdat);
f01050ad:	83 ec 08             	sub    $0x8,%esp
f01050b0:	53                   	push   %ebx
f01050b1:	ff 75 e0             	pushl  -0x20(%ebp)
f01050b4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01050b6:	83 ef 01             	sub    $0x1,%edi
f01050b9:	83 c4 10             	add    $0x10,%esp
f01050bc:	85 ff                	test   %edi,%edi
f01050be:	7f ed                	jg     f01050ad <vprintfmt+0x1c0>
f01050c0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01050c3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01050c6:	85 c9                	test   %ecx,%ecx
f01050c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01050cd:	0f 49 c1             	cmovns %ecx,%eax
f01050d0:	29 c1                	sub    %eax,%ecx
f01050d2:	89 75 08             	mov    %esi,0x8(%ebp)
f01050d5:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050d8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050db:	89 cb                	mov    %ecx,%ebx
f01050dd:	eb 4d                	jmp    f010512c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01050df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01050e3:	74 1b                	je     f0105100 <vprintfmt+0x213>
f01050e5:	0f be c0             	movsbl %al,%eax
f01050e8:	83 e8 20             	sub    $0x20,%eax
f01050eb:	83 f8 5e             	cmp    $0x5e,%eax
f01050ee:	76 10                	jbe    f0105100 <vprintfmt+0x213>
					putch('?', putdat);
f01050f0:	83 ec 08             	sub    $0x8,%esp
f01050f3:	ff 75 0c             	pushl  0xc(%ebp)
f01050f6:	6a 3f                	push   $0x3f
f01050f8:	ff 55 08             	call   *0x8(%ebp)
f01050fb:	83 c4 10             	add    $0x10,%esp
f01050fe:	eb 0d                	jmp    f010510d <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0105100:	83 ec 08             	sub    $0x8,%esp
f0105103:	ff 75 0c             	pushl  0xc(%ebp)
f0105106:	52                   	push   %edx
f0105107:	ff 55 08             	call   *0x8(%ebp)
f010510a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010510d:	83 eb 01             	sub    $0x1,%ebx
f0105110:	eb 1a                	jmp    f010512c <vprintfmt+0x23f>
f0105112:	89 75 08             	mov    %esi,0x8(%ebp)
f0105115:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105118:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010511b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010511e:	eb 0c                	jmp    f010512c <vprintfmt+0x23f>
f0105120:	89 75 08             	mov    %esi,0x8(%ebp)
f0105123:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105126:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105129:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010512c:	83 c7 01             	add    $0x1,%edi
f010512f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0105133:	0f be d0             	movsbl %al,%edx
f0105136:	85 d2                	test   %edx,%edx
f0105138:	74 23                	je     f010515d <vprintfmt+0x270>
f010513a:	85 f6                	test   %esi,%esi
f010513c:	78 a1                	js     f01050df <vprintfmt+0x1f2>
f010513e:	83 ee 01             	sub    $0x1,%esi
f0105141:	79 9c                	jns    f01050df <vprintfmt+0x1f2>
f0105143:	89 df                	mov    %ebx,%edi
f0105145:	8b 75 08             	mov    0x8(%ebp),%esi
f0105148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010514b:	eb 18                	jmp    f0105165 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010514d:	83 ec 08             	sub    $0x8,%esp
f0105150:	53                   	push   %ebx
f0105151:	6a 20                	push   $0x20
f0105153:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105155:	83 ef 01             	sub    $0x1,%edi
f0105158:	83 c4 10             	add    $0x10,%esp
f010515b:	eb 08                	jmp    f0105165 <vprintfmt+0x278>
f010515d:	89 df                	mov    %ebx,%edi
f010515f:	8b 75 08             	mov    0x8(%ebp),%esi
f0105162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105165:	85 ff                	test   %edi,%edi
f0105167:	7f e4                	jg     f010514d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105169:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010516c:	e9 a2 fd ff ff       	jmp    f0104f13 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105171:	83 fa 01             	cmp    $0x1,%edx
f0105174:	7e 16                	jle    f010518c <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0105176:	8b 45 14             	mov    0x14(%ebp),%eax
f0105179:	8d 50 08             	lea    0x8(%eax),%edx
f010517c:	89 55 14             	mov    %edx,0x14(%ebp)
f010517f:	8b 50 04             	mov    0x4(%eax),%edx
f0105182:	8b 00                	mov    (%eax),%eax
f0105184:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105187:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010518a:	eb 32                	jmp    f01051be <vprintfmt+0x2d1>
	else if (lflag)
f010518c:	85 d2                	test   %edx,%edx
f010518e:	74 18                	je     f01051a8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0105190:	8b 45 14             	mov    0x14(%ebp),%eax
f0105193:	8d 50 04             	lea    0x4(%eax),%edx
f0105196:	89 55 14             	mov    %edx,0x14(%ebp)
f0105199:	8b 00                	mov    (%eax),%eax
f010519b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010519e:	89 c1                	mov    %eax,%ecx
f01051a0:	c1 f9 1f             	sar    $0x1f,%ecx
f01051a3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051a6:	eb 16                	jmp    f01051be <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01051a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ab:	8d 50 04             	lea    0x4(%eax),%edx
f01051ae:	89 55 14             	mov    %edx,0x14(%ebp)
f01051b1:	8b 00                	mov    (%eax),%eax
f01051b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051b6:	89 c1                	mov    %eax,%ecx
f01051b8:	c1 f9 1f             	sar    $0x1f,%ecx
f01051bb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01051be:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01051c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01051c4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01051c9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01051cd:	79 74                	jns    f0105243 <vprintfmt+0x356>
				putch('-', putdat);
f01051cf:	83 ec 08             	sub    $0x8,%esp
f01051d2:	53                   	push   %ebx
f01051d3:	6a 2d                	push   $0x2d
f01051d5:	ff d6                	call   *%esi
				num = -(long long) num;
f01051d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01051da:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01051dd:	f7 d8                	neg    %eax
f01051df:	83 d2 00             	adc    $0x0,%edx
f01051e2:	f7 da                	neg    %edx
f01051e4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01051e7:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01051ec:	eb 55                	jmp    f0105243 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01051ee:	8d 45 14             	lea    0x14(%ebp),%eax
f01051f1:	e8 83 fc ff ff       	call   f0104e79 <getuint>
			base = 10;
f01051f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01051fb:	eb 46                	jmp    f0105243 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f01051fd:	8d 45 14             	lea    0x14(%ebp),%eax
f0105200:	e8 74 fc ff ff       	call   f0104e79 <getuint>
			base = 8;
f0105205:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f010520a:	eb 37                	jmp    f0105243 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010520c:	83 ec 08             	sub    $0x8,%esp
f010520f:	53                   	push   %ebx
f0105210:	6a 30                	push   $0x30
f0105212:	ff d6                	call   *%esi
			putch('x', putdat);
f0105214:	83 c4 08             	add    $0x8,%esp
f0105217:	53                   	push   %ebx
f0105218:	6a 78                	push   $0x78
f010521a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010521c:	8b 45 14             	mov    0x14(%ebp),%eax
f010521f:	8d 50 04             	lea    0x4(%eax),%edx
f0105222:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105225:	8b 00                	mov    (%eax),%eax
f0105227:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010522c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010522f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105234:	eb 0d                	jmp    f0105243 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105236:	8d 45 14             	lea    0x14(%ebp),%eax
f0105239:	e8 3b fc ff ff       	call   f0104e79 <getuint>
			base = 16;
f010523e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105243:	83 ec 0c             	sub    $0xc,%esp
f0105246:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010524a:	57                   	push   %edi
f010524b:	ff 75 e0             	pushl  -0x20(%ebp)
f010524e:	51                   	push   %ecx
f010524f:	52                   	push   %edx
f0105250:	50                   	push   %eax
f0105251:	89 da                	mov    %ebx,%edx
f0105253:	89 f0                	mov    %esi,%eax
f0105255:	e8 70 fb ff ff       	call   f0104dca <printnum>
			break;
f010525a:	83 c4 20             	add    $0x20,%esp
f010525d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105260:	e9 ae fc ff ff       	jmp    f0104f13 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105265:	83 ec 08             	sub    $0x8,%esp
f0105268:	53                   	push   %ebx
f0105269:	51                   	push   %ecx
f010526a:	ff d6                	call   *%esi
			break;
f010526c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010526f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105272:	e9 9c fc ff ff       	jmp    f0104f13 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105277:	83 ec 08             	sub    $0x8,%esp
f010527a:	53                   	push   %ebx
f010527b:	6a 25                	push   $0x25
f010527d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010527f:	83 c4 10             	add    $0x10,%esp
f0105282:	eb 03                	jmp    f0105287 <vprintfmt+0x39a>
f0105284:	83 ef 01             	sub    $0x1,%edi
f0105287:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010528b:	75 f7                	jne    f0105284 <vprintfmt+0x397>
f010528d:	e9 81 fc ff ff       	jmp    f0104f13 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0105292:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105295:	5b                   	pop    %ebx
f0105296:	5e                   	pop    %esi
f0105297:	5f                   	pop    %edi
f0105298:	5d                   	pop    %ebp
f0105299:	c3                   	ret    

f010529a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010529a:	55                   	push   %ebp
f010529b:	89 e5                	mov    %esp,%ebp
f010529d:	83 ec 18             	sub    $0x18,%esp
f01052a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01052a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01052a6:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01052a9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01052ad:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01052b0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01052b7:	85 c0                	test   %eax,%eax
f01052b9:	74 26                	je     f01052e1 <vsnprintf+0x47>
f01052bb:	85 d2                	test   %edx,%edx
f01052bd:	7e 22                	jle    f01052e1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01052bf:	ff 75 14             	pushl  0x14(%ebp)
f01052c2:	ff 75 10             	pushl  0x10(%ebp)
f01052c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01052c8:	50                   	push   %eax
f01052c9:	68 b3 4e 10 f0       	push   $0xf0104eb3
f01052ce:	e8 1a fc ff ff       	call   f0104eed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01052d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01052d6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01052d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01052dc:	83 c4 10             	add    $0x10,%esp
f01052df:	eb 05                	jmp    f01052e6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01052e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01052e6:	c9                   	leave  
f01052e7:	c3                   	ret    

f01052e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01052e8:	55                   	push   %ebp
f01052e9:	89 e5                	mov    %esp,%ebp
f01052eb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01052ee:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01052f1:	50                   	push   %eax
f01052f2:	ff 75 10             	pushl  0x10(%ebp)
f01052f5:	ff 75 0c             	pushl  0xc(%ebp)
f01052f8:	ff 75 08             	pushl  0x8(%ebp)
f01052fb:	e8 9a ff ff ff       	call   f010529a <vsnprintf>
	va_end(ap);

	return rc;
}
f0105300:	c9                   	leave  
f0105301:	c3                   	ret    

f0105302 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105302:	55                   	push   %ebp
f0105303:	89 e5                	mov    %esp,%ebp
f0105305:	57                   	push   %edi
f0105306:	56                   	push   %esi
f0105307:	53                   	push   %ebx
f0105308:	83 ec 0c             	sub    $0xc,%esp
f010530b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010530e:	85 c0                	test   %eax,%eax
f0105310:	74 11                	je     f0105323 <readline+0x21>
		cprintf("%s", prompt);
f0105312:	83 ec 08             	sub    $0x8,%esp
f0105315:	50                   	push   %eax
f0105316:	68 b9 72 10 f0       	push   $0xf01072b9
f010531b:	e8 43 e5 ff ff       	call   f0103863 <cprintf>
f0105320:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0105323:	83 ec 0c             	sub    $0xc,%esp
f0105326:	6a 00                	push   $0x0
f0105328:	e8 58 b4 ff ff       	call   f0100785 <iscons>
f010532d:	89 c7                	mov    %eax,%edi
f010532f:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105332:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105337:	e8 38 b4 ff ff       	call   f0100774 <getchar>
f010533c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010533e:	85 c0                	test   %eax,%eax
f0105340:	79 18                	jns    f010535a <readline+0x58>
			cprintf("read error: %e\n", c);
f0105342:	83 ec 08             	sub    $0x8,%esp
f0105345:	50                   	push   %eax
f0105346:	68 64 7d 10 f0       	push   $0xf0107d64
f010534b:	e8 13 e5 ff ff       	call   f0103863 <cprintf>
			return NULL;
f0105350:	83 c4 10             	add    $0x10,%esp
f0105353:	b8 00 00 00 00       	mov    $0x0,%eax
f0105358:	eb 79                	jmp    f01053d3 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010535a:	83 f8 08             	cmp    $0x8,%eax
f010535d:	0f 94 c2             	sete   %dl
f0105360:	83 f8 7f             	cmp    $0x7f,%eax
f0105363:	0f 94 c0             	sete   %al
f0105366:	08 c2                	or     %al,%dl
f0105368:	74 1a                	je     f0105384 <readline+0x82>
f010536a:	85 f6                	test   %esi,%esi
f010536c:	7e 16                	jle    f0105384 <readline+0x82>
			if (echoing)
f010536e:	85 ff                	test   %edi,%edi
f0105370:	74 0d                	je     f010537f <readline+0x7d>
				cputchar('\b');
f0105372:	83 ec 0c             	sub    $0xc,%esp
f0105375:	6a 08                	push   $0x8
f0105377:	e8 e8 b3 ff ff       	call   f0100764 <cputchar>
f010537c:	83 c4 10             	add    $0x10,%esp
			i--;
f010537f:	83 ee 01             	sub    $0x1,%esi
f0105382:	eb b3                	jmp    f0105337 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105384:	83 fb 1f             	cmp    $0x1f,%ebx
f0105387:	7e 23                	jle    f01053ac <readline+0xaa>
f0105389:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010538f:	7f 1b                	jg     f01053ac <readline+0xaa>
			if (echoing)
f0105391:	85 ff                	test   %edi,%edi
f0105393:	74 0c                	je     f01053a1 <readline+0x9f>
				cputchar(c);
f0105395:	83 ec 0c             	sub    $0xc,%esp
f0105398:	53                   	push   %ebx
f0105399:	e8 c6 b3 ff ff       	call   f0100764 <cputchar>
f010539e:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01053a1:	88 9e 80 fa 22 f0    	mov    %bl,-0xfdd0580(%esi)
f01053a7:	8d 76 01             	lea    0x1(%esi),%esi
f01053aa:	eb 8b                	jmp    f0105337 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01053ac:	83 fb 0a             	cmp    $0xa,%ebx
f01053af:	74 05                	je     f01053b6 <readline+0xb4>
f01053b1:	83 fb 0d             	cmp    $0xd,%ebx
f01053b4:	75 81                	jne    f0105337 <readline+0x35>
			if (echoing)
f01053b6:	85 ff                	test   %edi,%edi
f01053b8:	74 0d                	je     f01053c7 <readline+0xc5>
				cputchar('\n');
f01053ba:	83 ec 0c             	sub    $0xc,%esp
f01053bd:	6a 0a                	push   $0xa
f01053bf:	e8 a0 b3 ff ff       	call   f0100764 <cputchar>
f01053c4:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01053c7:	c6 86 80 fa 22 f0 00 	movb   $0x0,-0xfdd0580(%esi)
			return buf;
f01053ce:	b8 80 fa 22 f0       	mov    $0xf022fa80,%eax
		}
	}
}
f01053d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053d6:	5b                   	pop    %ebx
f01053d7:	5e                   	pop    %esi
f01053d8:	5f                   	pop    %edi
f01053d9:	5d                   	pop    %ebp
f01053da:	c3                   	ret    

f01053db <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01053db:	55                   	push   %ebp
f01053dc:	89 e5                	mov    %esp,%ebp
f01053de:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01053e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01053e6:	eb 03                	jmp    f01053eb <strlen+0x10>
		n++;
f01053e8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01053eb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01053ef:	75 f7                	jne    f01053e8 <strlen+0xd>
		n++;
	return n;
}
f01053f1:	5d                   	pop    %ebp
f01053f2:	c3                   	ret    

f01053f3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01053f3:	55                   	push   %ebp
f01053f4:	89 e5                	mov    %esp,%ebp
f01053f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01053f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01053fc:	ba 00 00 00 00       	mov    $0x0,%edx
f0105401:	eb 03                	jmp    f0105406 <strnlen+0x13>
		n++;
f0105403:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105406:	39 c2                	cmp    %eax,%edx
f0105408:	74 08                	je     f0105412 <strnlen+0x1f>
f010540a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010540e:	75 f3                	jne    f0105403 <strnlen+0x10>
f0105410:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105412:	5d                   	pop    %ebp
f0105413:	c3                   	ret    

f0105414 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105414:	55                   	push   %ebp
f0105415:	89 e5                	mov    %esp,%ebp
f0105417:	53                   	push   %ebx
f0105418:	8b 45 08             	mov    0x8(%ebp),%eax
f010541b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010541e:	89 c2                	mov    %eax,%edx
f0105420:	83 c2 01             	add    $0x1,%edx
f0105423:	83 c1 01             	add    $0x1,%ecx
f0105426:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010542a:	88 5a ff             	mov    %bl,-0x1(%edx)
f010542d:	84 db                	test   %bl,%bl
f010542f:	75 ef                	jne    f0105420 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105431:	5b                   	pop    %ebx
f0105432:	5d                   	pop    %ebp
f0105433:	c3                   	ret    

f0105434 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105434:	55                   	push   %ebp
f0105435:	89 e5                	mov    %esp,%ebp
f0105437:	53                   	push   %ebx
f0105438:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010543b:	53                   	push   %ebx
f010543c:	e8 9a ff ff ff       	call   f01053db <strlen>
f0105441:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105444:	ff 75 0c             	pushl  0xc(%ebp)
f0105447:	01 d8                	add    %ebx,%eax
f0105449:	50                   	push   %eax
f010544a:	e8 c5 ff ff ff       	call   f0105414 <strcpy>
	return dst;
}
f010544f:	89 d8                	mov    %ebx,%eax
f0105451:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105454:	c9                   	leave  
f0105455:	c3                   	ret    

f0105456 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105456:	55                   	push   %ebp
f0105457:	89 e5                	mov    %esp,%ebp
f0105459:	56                   	push   %esi
f010545a:	53                   	push   %ebx
f010545b:	8b 75 08             	mov    0x8(%ebp),%esi
f010545e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105461:	89 f3                	mov    %esi,%ebx
f0105463:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105466:	89 f2                	mov    %esi,%edx
f0105468:	eb 0f                	jmp    f0105479 <strncpy+0x23>
		*dst++ = *src;
f010546a:	83 c2 01             	add    $0x1,%edx
f010546d:	0f b6 01             	movzbl (%ecx),%eax
f0105470:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105473:	80 39 01             	cmpb   $0x1,(%ecx)
f0105476:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105479:	39 da                	cmp    %ebx,%edx
f010547b:	75 ed                	jne    f010546a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010547d:	89 f0                	mov    %esi,%eax
f010547f:	5b                   	pop    %ebx
f0105480:	5e                   	pop    %esi
f0105481:	5d                   	pop    %ebp
f0105482:	c3                   	ret    

f0105483 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105483:	55                   	push   %ebp
f0105484:	89 e5                	mov    %esp,%ebp
f0105486:	56                   	push   %esi
f0105487:	53                   	push   %ebx
f0105488:	8b 75 08             	mov    0x8(%ebp),%esi
f010548b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010548e:	8b 55 10             	mov    0x10(%ebp),%edx
f0105491:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105493:	85 d2                	test   %edx,%edx
f0105495:	74 21                	je     f01054b8 <strlcpy+0x35>
f0105497:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010549b:	89 f2                	mov    %esi,%edx
f010549d:	eb 09                	jmp    f01054a8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010549f:	83 c2 01             	add    $0x1,%edx
f01054a2:	83 c1 01             	add    $0x1,%ecx
f01054a5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01054a8:	39 c2                	cmp    %eax,%edx
f01054aa:	74 09                	je     f01054b5 <strlcpy+0x32>
f01054ac:	0f b6 19             	movzbl (%ecx),%ebx
f01054af:	84 db                	test   %bl,%bl
f01054b1:	75 ec                	jne    f010549f <strlcpy+0x1c>
f01054b3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01054b5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01054b8:	29 f0                	sub    %esi,%eax
}
f01054ba:	5b                   	pop    %ebx
f01054bb:	5e                   	pop    %esi
f01054bc:	5d                   	pop    %ebp
f01054bd:	c3                   	ret    

f01054be <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01054be:	55                   	push   %ebp
f01054bf:	89 e5                	mov    %esp,%ebp
f01054c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01054c7:	eb 06                	jmp    f01054cf <strcmp+0x11>
		p++, q++;
f01054c9:	83 c1 01             	add    $0x1,%ecx
f01054cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01054cf:	0f b6 01             	movzbl (%ecx),%eax
f01054d2:	84 c0                	test   %al,%al
f01054d4:	74 04                	je     f01054da <strcmp+0x1c>
f01054d6:	3a 02                	cmp    (%edx),%al
f01054d8:	74 ef                	je     f01054c9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01054da:	0f b6 c0             	movzbl %al,%eax
f01054dd:	0f b6 12             	movzbl (%edx),%edx
f01054e0:	29 d0                	sub    %edx,%eax
}
f01054e2:	5d                   	pop    %ebp
f01054e3:	c3                   	ret    

f01054e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01054e4:	55                   	push   %ebp
f01054e5:	89 e5                	mov    %esp,%ebp
f01054e7:	53                   	push   %ebx
f01054e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01054eb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01054ee:	89 c3                	mov    %eax,%ebx
f01054f0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01054f3:	eb 06                	jmp    f01054fb <strncmp+0x17>
		n--, p++, q++;
f01054f5:	83 c0 01             	add    $0x1,%eax
f01054f8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01054fb:	39 d8                	cmp    %ebx,%eax
f01054fd:	74 15                	je     f0105514 <strncmp+0x30>
f01054ff:	0f b6 08             	movzbl (%eax),%ecx
f0105502:	84 c9                	test   %cl,%cl
f0105504:	74 04                	je     f010550a <strncmp+0x26>
f0105506:	3a 0a                	cmp    (%edx),%cl
f0105508:	74 eb                	je     f01054f5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010550a:	0f b6 00             	movzbl (%eax),%eax
f010550d:	0f b6 12             	movzbl (%edx),%edx
f0105510:	29 d0                	sub    %edx,%eax
f0105512:	eb 05                	jmp    f0105519 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105514:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105519:	5b                   	pop    %ebx
f010551a:	5d                   	pop    %ebp
f010551b:	c3                   	ret    

f010551c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010551c:	55                   	push   %ebp
f010551d:	89 e5                	mov    %esp,%ebp
f010551f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105522:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105526:	eb 07                	jmp    f010552f <strchr+0x13>
		if (*s == c)
f0105528:	38 ca                	cmp    %cl,%dl
f010552a:	74 0f                	je     f010553b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010552c:	83 c0 01             	add    $0x1,%eax
f010552f:	0f b6 10             	movzbl (%eax),%edx
f0105532:	84 d2                	test   %dl,%dl
f0105534:	75 f2                	jne    f0105528 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105536:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010553b:	5d                   	pop    %ebp
f010553c:	c3                   	ret    

f010553d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010553d:	55                   	push   %ebp
f010553e:	89 e5                	mov    %esp,%ebp
f0105540:	8b 45 08             	mov    0x8(%ebp),%eax
f0105543:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105547:	eb 03                	jmp    f010554c <strfind+0xf>
f0105549:	83 c0 01             	add    $0x1,%eax
f010554c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010554f:	38 ca                	cmp    %cl,%dl
f0105551:	74 04                	je     f0105557 <strfind+0x1a>
f0105553:	84 d2                	test   %dl,%dl
f0105555:	75 f2                	jne    f0105549 <strfind+0xc>
			break;
	return (char *) s;
}
f0105557:	5d                   	pop    %ebp
f0105558:	c3                   	ret    

f0105559 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105559:	55                   	push   %ebp
f010555a:	89 e5                	mov    %esp,%ebp
f010555c:	57                   	push   %edi
f010555d:	56                   	push   %esi
f010555e:	53                   	push   %ebx
f010555f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105562:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105565:	85 c9                	test   %ecx,%ecx
f0105567:	74 36                	je     f010559f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105569:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010556f:	75 28                	jne    f0105599 <memset+0x40>
f0105571:	f6 c1 03             	test   $0x3,%cl
f0105574:	75 23                	jne    f0105599 <memset+0x40>
		c &= 0xFF;
f0105576:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010557a:	89 d3                	mov    %edx,%ebx
f010557c:	c1 e3 08             	shl    $0x8,%ebx
f010557f:	89 d6                	mov    %edx,%esi
f0105581:	c1 e6 18             	shl    $0x18,%esi
f0105584:	89 d0                	mov    %edx,%eax
f0105586:	c1 e0 10             	shl    $0x10,%eax
f0105589:	09 f0                	or     %esi,%eax
f010558b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010558d:	89 d8                	mov    %ebx,%eax
f010558f:	09 d0                	or     %edx,%eax
f0105591:	c1 e9 02             	shr    $0x2,%ecx
f0105594:	fc                   	cld    
f0105595:	f3 ab                	rep stos %eax,%es:(%edi)
f0105597:	eb 06                	jmp    f010559f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105599:	8b 45 0c             	mov    0xc(%ebp),%eax
f010559c:	fc                   	cld    
f010559d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010559f:	89 f8                	mov    %edi,%eax
f01055a1:	5b                   	pop    %ebx
f01055a2:	5e                   	pop    %esi
f01055a3:	5f                   	pop    %edi
f01055a4:	5d                   	pop    %ebp
f01055a5:	c3                   	ret    

f01055a6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01055a6:	55                   	push   %ebp
f01055a7:	89 e5                	mov    %esp,%ebp
f01055a9:	57                   	push   %edi
f01055aa:	56                   	push   %esi
f01055ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01055ae:	8b 75 0c             	mov    0xc(%ebp),%esi
f01055b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01055b4:	39 c6                	cmp    %eax,%esi
f01055b6:	73 35                	jae    f01055ed <memmove+0x47>
f01055b8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01055bb:	39 d0                	cmp    %edx,%eax
f01055bd:	73 2e                	jae    f01055ed <memmove+0x47>
		s += n;
		d += n;
f01055bf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055c2:	89 d6                	mov    %edx,%esi
f01055c4:	09 fe                	or     %edi,%esi
f01055c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01055cc:	75 13                	jne    f01055e1 <memmove+0x3b>
f01055ce:	f6 c1 03             	test   $0x3,%cl
f01055d1:	75 0e                	jne    f01055e1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01055d3:	83 ef 04             	sub    $0x4,%edi
f01055d6:	8d 72 fc             	lea    -0x4(%edx),%esi
f01055d9:	c1 e9 02             	shr    $0x2,%ecx
f01055dc:	fd                   	std    
f01055dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01055df:	eb 09                	jmp    f01055ea <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01055e1:	83 ef 01             	sub    $0x1,%edi
f01055e4:	8d 72 ff             	lea    -0x1(%edx),%esi
f01055e7:	fd                   	std    
f01055e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01055ea:	fc                   	cld    
f01055eb:	eb 1d                	jmp    f010560a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01055ed:	89 f2                	mov    %esi,%edx
f01055ef:	09 c2                	or     %eax,%edx
f01055f1:	f6 c2 03             	test   $0x3,%dl
f01055f4:	75 0f                	jne    f0105605 <memmove+0x5f>
f01055f6:	f6 c1 03             	test   $0x3,%cl
f01055f9:	75 0a                	jne    f0105605 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01055fb:	c1 e9 02             	shr    $0x2,%ecx
f01055fe:	89 c7                	mov    %eax,%edi
f0105600:	fc                   	cld    
f0105601:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105603:	eb 05                	jmp    f010560a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105605:	89 c7                	mov    %eax,%edi
f0105607:	fc                   	cld    
f0105608:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010560a:	5e                   	pop    %esi
f010560b:	5f                   	pop    %edi
f010560c:	5d                   	pop    %ebp
f010560d:	c3                   	ret    

f010560e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010560e:	55                   	push   %ebp
f010560f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105611:	ff 75 10             	pushl  0x10(%ebp)
f0105614:	ff 75 0c             	pushl  0xc(%ebp)
f0105617:	ff 75 08             	pushl  0x8(%ebp)
f010561a:	e8 87 ff ff ff       	call   f01055a6 <memmove>
}
f010561f:	c9                   	leave  
f0105620:	c3                   	ret    

f0105621 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105621:	55                   	push   %ebp
f0105622:	89 e5                	mov    %esp,%ebp
f0105624:	56                   	push   %esi
f0105625:	53                   	push   %ebx
f0105626:	8b 45 08             	mov    0x8(%ebp),%eax
f0105629:	8b 55 0c             	mov    0xc(%ebp),%edx
f010562c:	89 c6                	mov    %eax,%esi
f010562e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105631:	eb 1a                	jmp    f010564d <memcmp+0x2c>
		if (*s1 != *s2)
f0105633:	0f b6 08             	movzbl (%eax),%ecx
f0105636:	0f b6 1a             	movzbl (%edx),%ebx
f0105639:	38 d9                	cmp    %bl,%cl
f010563b:	74 0a                	je     f0105647 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010563d:	0f b6 c1             	movzbl %cl,%eax
f0105640:	0f b6 db             	movzbl %bl,%ebx
f0105643:	29 d8                	sub    %ebx,%eax
f0105645:	eb 0f                	jmp    f0105656 <memcmp+0x35>
		s1++, s2++;
f0105647:	83 c0 01             	add    $0x1,%eax
f010564a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010564d:	39 f0                	cmp    %esi,%eax
f010564f:	75 e2                	jne    f0105633 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105651:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105656:	5b                   	pop    %ebx
f0105657:	5e                   	pop    %esi
f0105658:	5d                   	pop    %ebp
f0105659:	c3                   	ret    

f010565a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010565a:	55                   	push   %ebp
f010565b:	89 e5                	mov    %esp,%ebp
f010565d:	53                   	push   %ebx
f010565e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105661:	89 c1                	mov    %eax,%ecx
f0105663:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105666:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010566a:	eb 0a                	jmp    f0105676 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010566c:	0f b6 10             	movzbl (%eax),%edx
f010566f:	39 da                	cmp    %ebx,%edx
f0105671:	74 07                	je     f010567a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105673:	83 c0 01             	add    $0x1,%eax
f0105676:	39 c8                	cmp    %ecx,%eax
f0105678:	72 f2                	jb     f010566c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010567a:	5b                   	pop    %ebx
f010567b:	5d                   	pop    %ebp
f010567c:	c3                   	ret    

f010567d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010567d:	55                   	push   %ebp
f010567e:	89 e5                	mov    %esp,%ebp
f0105680:	57                   	push   %edi
f0105681:	56                   	push   %esi
f0105682:	53                   	push   %ebx
f0105683:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105686:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105689:	eb 03                	jmp    f010568e <strtol+0x11>
		s++;
f010568b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010568e:	0f b6 01             	movzbl (%ecx),%eax
f0105691:	3c 20                	cmp    $0x20,%al
f0105693:	74 f6                	je     f010568b <strtol+0xe>
f0105695:	3c 09                	cmp    $0x9,%al
f0105697:	74 f2                	je     f010568b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105699:	3c 2b                	cmp    $0x2b,%al
f010569b:	75 0a                	jne    f01056a7 <strtol+0x2a>
		s++;
f010569d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01056a0:	bf 00 00 00 00       	mov    $0x0,%edi
f01056a5:	eb 11                	jmp    f01056b8 <strtol+0x3b>
f01056a7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01056ac:	3c 2d                	cmp    $0x2d,%al
f01056ae:	75 08                	jne    f01056b8 <strtol+0x3b>
		s++, neg = 1;
f01056b0:	83 c1 01             	add    $0x1,%ecx
f01056b3:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01056b8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01056be:	75 15                	jne    f01056d5 <strtol+0x58>
f01056c0:	80 39 30             	cmpb   $0x30,(%ecx)
f01056c3:	75 10                	jne    f01056d5 <strtol+0x58>
f01056c5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01056c9:	75 7c                	jne    f0105747 <strtol+0xca>
		s += 2, base = 16;
f01056cb:	83 c1 02             	add    $0x2,%ecx
f01056ce:	bb 10 00 00 00       	mov    $0x10,%ebx
f01056d3:	eb 16                	jmp    f01056eb <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01056d5:	85 db                	test   %ebx,%ebx
f01056d7:	75 12                	jne    f01056eb <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01056d9:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01056de:	80 39 30             	cmpb   $0x30,(%ecx)
f01056e1:	75 08                	jne    f01056eb <strtol+0x6e>
		s++, base = 8;
f01056e3:	83 c1 01             	add    $0x1,%ecx
f01056e6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01056eb:	b8 00 00 00 00       	mov    $0x0,%eax
f01056f0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01056f3:	0f b6 11             	movzbl (%ecx),%edx
f01056f6:	8d 72 d0             	lea    -0x30(%edx),%esi
f01056f9:	89 f3                	mov    %esi,%ebx
f01056fb:	80 fb 09             	cmp    $0x9,%bl
f01056fe:	77 08                	ja     f0105708 <strtol+0x8b>
			dig = *s - '0';
f0105700:	0f be d2             	movsbl %dl,%edx
f0105703:	83 ea 30             	sub    $0x30,%edx
f0105706:	eb 22                	jmp    f010572a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105708:	8d 72 9f             	lea    -0x61(%edx),%esi
f010570b:	89 f3                	mov    %esi,%ebx
f010570d:	80 fb 19             	cmp    $0x19,%bl
f0105710:	77 08                	ja     f010571a <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105712:	0f be d2             	movsbl %dl,%edx
f0105715:	83 ea 57             	sub    $0x57,%edx
f0105718:	eb 10                	jmp    f010572a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010571a:	8d 72 bf             	lea    -0x41(%edx),%esi
f010571d:	89 f3                	mov    %esi,%ebx
f010571f:	80 fb 19             	cmp    $0x19,%bl
f0105722:	77 16                	ja     f010573a <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105724:	0f be d2             	movsbl %dl,%edx
f0105727:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010572a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010572d:	7d 0b                	jge    f010573a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010572f:	83 c1 01             	add    $0x1,%ecx
f0105732:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105736:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105738:	eb b9                	jmp    f01056f3 <strtol+0x76>

	if (endptr)
f010573a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010573e:	74 0d                	je     f010574d <strtol+0xd0>
		*endptr = (char *) s;
f0105740:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105743:	89 0e                	mov    %ecx,(%esi)
f0105745:	eb 06                	jmp    f010574d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105747:	85 db                	test   %ebx,%ebx
f0105749:	74 98                	je     f01056e3 <strtol+0x66>
f010574b:	eb 9e                	jmp    f01056eb <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010574d:	89 c2                	mov    %eax,%edx
f010574f:	f7 da                	neg    %edx
f0105751:	85 ff                	test   %edi,%edi
f0105753:	0f 45 c2             	cmovne %edx,%eax
}
f0105756:	5b                   	pop    %ebx
f0105757:	5e                   	pop    %esi
f0105758:	5f                   	pop    %edi
f0105759:	5d                   	pop    %ebp
f010575a:	c3                   	ret    
f010575b:	90                   	nop

f010575c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010575c:	fa                   	cli    

	xorw    %ax, %ax
f010575d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010575f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105761:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105763:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105765:	0f 01 16             	lgdtl  (%esi)
f0105768:	74 70                	je     f01057da <mpsearch1+0x3>
	movl    %cr0, %eax
f010576a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010576d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105771:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105774:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010577a:	08 00                	or     %al,(%eax)

f010577c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010577c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105780:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105782:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105784:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105786:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010578a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010578c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010578e:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105793:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105796:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105799:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010579e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01057a1:	8b 25 84 fe 22 f0    	mov    0xf022fe84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01057a7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01057ac:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f01057b1:	ff d0                	call   *%eax

f01057b3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01057b3:	eb fe                	jmp    f01057b3 <spin>
f01057b5:	8d 76 00             	lea    0x0(%esi),%esi

f01057b8 <gdt>:
	...
f01057c0:	ff                   	(bad)  
f01057c1:	ff 00                	incl   (%eax)
f01057c3:	00 00                	add    %al,(%eax)
f01057c5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01057cc:	00                   	.byte 0x0
f01057cd:	92                   	xchg   %eax,%edx
f01057ce:	cf                   	iret   
	...

f01057d0 <gdtdesc>:
f01057d0:	17                   	pop    %ss
f01057d1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01057d6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01057d6:	90                   	nop

f01057d7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01057d7:	55                   	push   %ebp
f01057d8:	89 e5                	mov    %esp,%ebp
f01057da:	57                   	push   %edi
f01057db:	56                   	push   %esi
f01057dc:	53                   	push   %ebx
f01057dd:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01057e0:	8b 0d 88 fe 22 f0    	mov    0xf022fe88,%ecx
f01057e6:	89 c3                	mov    %eax,%ebx
f01057e8:	c1 eb 0c             	shr    $0xc,%ebx
f01057eb:	39 cb                	cmp    %ecx,%ebx
f01057ed:	72 12                	jb     f0105801 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01057ef:	50                   	push   %eax
f01057f0:	68 44 62 10 f0       	push   $0xf0106244
f01057f5:	6a 57                	push   $0x57
f01057f7:	68 01 7f 10 f0       	push   $0xf0107f01
f01057fc:	e8 3f a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105801:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105807:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105809:	89 c2                	mov    %eax,%edx
f010580b:	c1 ea 0c             	shr    $0xc,%edx
f010580e:	39 ca                	cmp    %ecx,%edx
f0105810:	72 12                	jb     f0105824 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105812:	50                   	push   %eax
f0105813:	68 44 62 10 f0       	push   $0xf0106244
f0105818:	6a 57                	push   $0x57
f010581a:	68 01 7f 10 f0       	push   $0xf0107f01
f010581f:	e8 1c a8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105824:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f010582a:	eb 2f                	jmp    f010585b <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010582c:	83 ec 04             	sub    $0x4,%esp
f010582f:	6a 04                	push   $0x4
f0105831:	68 11 7f 10 f0       	push   $0xf0107f11
f0105836:	53                   	push   %ebx
f0105837:	e8 e5 fd ff ff       	call   f0105621 <memcmp>
f010583c:	83 c4 10             	add    $0x10,%esp
f010583f:	85 c0                	test   %eax,%eax
f0105841:	75 15                	jne    f0105858 <mpsearch1+0x81>
f0105843:	89 da                	mov    %ebx,%edx
f0105845:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105848:	0f b6 0a             	movzbl (%edx),%ecx
f010584b:	01 c8                	add    %ecx,%eax
f010584d:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105850:	39 d7                	cmp    %edx,%edi
f0105852:	75 f4                	jne    f0105848 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105854:	84 c0                	test   %al,%al
f0105856:	74 0e                	je     f0105866 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105858:	83 c3 10             	add    $0x10,%ebx
f010585b:	39 f3                	cmp    %esi,%ebx
f010585d:	72 cd                	jb     f010582c <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010585f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105864:	eb 02                	jmp    f0105868 <mpsearch1+0x91>
f0105866:	89 d8                	mov    %ebx,%eax
}
f0105868:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010586b:	5b                   	pop    %ebx
f010586c:	5e                   	pop    %esi
f010586d:	5f                   	pop    %edi
f010586e:	5d                   	pop    %ebp
f010586f:	c3                   	ret    

f0105870 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105870:	55                   	push   %ebp
f0105871:	89 e5                	mov    %esp,%ebp
f0105873:	57                   	push   %edi
f0105874:	56                   	push   %esi
f0105875:	53                   	push   %ebx
f0105876:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105879:	c7 05 c0 03 23 f0 20 	movl   $0xf0230020,0xf02303c0
f0105880:	00 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105883:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f010588a:	75 16                	jne    f01058a2 <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010588c:	68 00 04 00 00       	push   $0x400
f0105891:	68 44 62 10 f0       	push   $0xf0106244
f0105896:	6a 6f                	push   $0x6f
f0105898:	68 01 7f 10 f0       	push   $0xf0107f01
f010589d:	e8 9e a7 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01058a2:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01058a9:	85 c0                	test   %eax,%eax
f01058ab:	74 16                	je     f01058c3 <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01058ad:	c1 e0 04             	shl    $0x4,%eax
f01058b0:	ba 00 04 00 00       	mov    $0x400,%edx
f01058b5:	e8 1d ff ff ff       	call   f01057d7 <mpsearch1>
f01058ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058bd:	85 c0                	test   %eax,%eax
f01058bf:	75 3c                	jne    f01058fd <mp_init+0x8d>
f01058c1:	eb 20                	jmp    f01058e3 <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01058c3:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01058ca:	c1 e0 0a             	shl    $0xa,%eax
f01058cd:	2d 00 04 00 00       	sub    $0x400,%eax
f01058d2:	ba 00 04 00 00       	mov    $0x400,%edx
f01058d7:	e8 fb fe ff ff       	call   f01057d7 <mpsearch1>
f01058dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01058df:	85 c0                	test   %eax,%eax
f01058e1:	75 1a                	jne    f01058fd <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01058e3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01058e8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01058ed:	e8 e5 fe ff ff       	call   f01057d7 <mpsearch1>
f01058f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01058f5:	85 c0                	test   %eax,%eax
f01058f7:	0f 84 5d 02 00 00    	je     f0105b5a <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01058fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105900:	8b 70 04             	mov    0x4(%eax),%esi
f0105903:	85 f6                	test   %esi,%esi
f0105905:	74 06                	je     f010590d <mp_init+0x9d>
f0105907:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010590b:	74 15                	je     f0105922 <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f010590d:	83 ec 0c             	sub    $0xc,%esp
f0105910:	68 74 7d 10 f0       	push   $0xf0107d74
f0105915:	e8 49 df ff ff       	call   f0103863 <cprintf>
f010591a:	83 c4 10             	add    $0x10,%esp
f010591d:	e9 38 02 00 00       	jmp    f0105b5a <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105922:	89 f0                	mov    %esi,%eax
f0105924:	c1 e8 0c             	shr    $0xc,%eax
f0105927:	3b 05 88 fe 22 f0    	cmp    0xf022fe88,%eax
f010592d:	72 15                	jb     f0105944 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010592f:	56                   	push   %esi
f0105930:	68 44 62 10 f0       	push   $0xf0106244
f0105935:	68 90 00 00 00       	push   $0x90
f010593a:	68 01 7f 10 f0       	push   $0xf0107f01
f010593f:	e8 fc a6 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105944:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010594a:	83 ec 04             	sub    $0x4,%esp
f010594d:	6a 04                	push   $0x4
f010594f:	68 16 7f 10 f0       	push   $0xf0107f16
f0105954:	53                   	push   %ebx
f0105955:	e8 c7 fc ff ff       	call   f0105621 <memcmp>
f010595a:	83 c4 10             	add    $0x10,%esp
f010595d:	85 c0                	test   %eax,%eax
f010595f:	74 15                	je     f0105976 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105961:	83 ec 0c             	sub    $0xc,%esp
f0105964:	68 a4 7d 10 f0       	push   $0xf0107da4
f0105969:	e8 f5 de ff ff       	call   f0103863 <cprintf>
f010596e:	83 c4 10             	add    $0x10,%esp
f0105971:	e9 e4 01 00 00       	jmp    f0105b5a <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105976:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f010597a:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010597e:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105981:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105986:	b8 00 00 00 00       	mov    $0x0,%eax
f010598b:	eb 0d                	jmp    f010599a <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f010598d:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105994:	f0 
f0105995:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105997:	83 c0 01             	add    $0x1,%eax
f010599a:	39 c7                	cmp    %eax,%edi
f010599c:	75 ef                	jne    f010598d <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010599e:	84 d2                	test   %dl,%dl
f01059a0:	74 15                	je     f01059b7 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01059a2:	83 ec 0c             	sub    $0xc,%esp
f01059a5:	68 d8 7d 10 f0       	push   $0xf0107dd8
f01059aa:	e8 b4 de ff ff       	call   f0103863 <cprintf>
f01059af:	83 c4 10             	add    $0x10,%esp
f01059b2:	e9 a3 01 00 00       	jmp    f0105b5a <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01059b7:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01059bb:	3c 01                	cmp    $0x1,%al
f01059bd:	74 1d                	je     f01059dc <mp_init+0x16c>
f01059bf:	3c 04                	cmp    $0x4,%al
f01059c1:	74 19                	je     f01059dc <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01059c3:	83 ec 08             	sub    $0x8,%esp
f01059c6:	0f b6 c0             	movzbl %al,%eax
f01059c9:	50                   	push   %eax
f01059ca:	68 fc 7d 10 f0       	push   $0xf0107dfc
f01059cf:	e8 8f de ff ff       	call   f0103863 <cprintf>
f01059d4:	83 c4 10             	add    $0x10,%esp
f01059d7:	e9 7e 01 00 00       	jmp    f0105b5a <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01059dc:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01059e0:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01059e4:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01059e9:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01059ee:	01 ce                	add    %ecx,%esi
f01059f0:	eb 0d                	jmp    f01059ff <mp_init+0x18f>
f01059f2:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01059f9:	f0 
f01059fa:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01059fc:	83 c0 01             	add    $0x1,%eax
f01059ff:	39 c7                	cmp    %eax,%edi
f0105a01:	75 ef                	jne    f01059f2 <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105a03:	89 d0                	mov    %edx,%eax
f0105a05:	02 43 2a             	add    0x2a(%ebx),%al
f0105a08:	74 15                	je     f0105a1f <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105a0a:	83 ec 0c             	sub    $0xc,%esp
f0105a0d:	68 1c 7e 10 f0       	push   $0xf0107e1c
f0105a12:	e8 4c de ff ff       	call   f0103863 <cprintf>
f0105a17:	83 c4 10             	add    $0x10,%esp
f0105a1a:	e9 3b 01 00 00       	jmp    f0105b5a <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105a1f:	85 db                	test   %ebx,%ebx
f0105a21:	0f 84 33 01 00 00    	je     f0105b5a <mp_init+0x2ea>
		return;
	ismp = 1;
f0105a27:	c7 05 00 00 23 f0 01 	movl   $0x1,0xf0230000
f0105a2e:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105a31:	8b 43 24             	mov    0x24(%ebx),%eax
f0105a34:	a3 00 10 27 f0       	mov    %eax,0xf0271000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105a39:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105a3c:	be 00 00 00 00       	mov    $0x0,%esi
f0105a41:	e9 85 00 00 00       	jmp    f0105acb <mp_init+0x25b>
		switch (*p) {
f0105a46:	0f b6 07             	movzbl (%edi),%eax
f0105a49:	84 c0                	test   %al,%al
f0105a4b:	74 06                	je     f0105a53 <mp_init+0x1e3>
f0105a4d:	3c 04                	cmp    $0x4,%al
f0105a4f:	77 55                	ja     f0105aa6 <mp_init+0x236>
f0105a51:	eb 4e                	jmp    f0105aa1 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105a53:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105a57:	74 11                	je     f0105a6a <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105a59:	6b 05 c4 03 23 f0 74 	imul   $0x74,0xf02303c4,%eax
f0105a60:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105a65:	a3 c0 03 23 f0       	mov    %eax,0xf02303c0
			if (ncpu < NCPU) {
f0105a6a:	a1 c4 03 23 f0       	mov    0xf02303c4,%eax
f0105a6f:	83 f8 07             	cmp    $0x7,%eax
f0105a72:	7f 13                	jg     f0105a87 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105a74:	6b d0 74             	imul   $0x74,%eax,%edx
f0105a77:	88 82 20 00 23 f0    	mov    %al,-0xfdcffe0(%edx)
				ncpu++;
f0105a7d:	83 c0 01             	add    $0x1,%eax
f0105a80:	a3 c4 03 23 f0       	mov    %eax,0xf02303c4
f0105a85:	eb 15                	jmp    f0105a9c <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105a87:	83 ec 08             	sub    $0x8,%esp
f0105a8a:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105a8e:	50                   	push   %eax
f0105a8f:	68 4c 7e 10 f0       	push   $0xf0107e4c
f0105a94:	e8 ca dd ff ff       	call   f0103863 <cprintf>
f0105a99:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105a9c:	83 c7 14             	add    $0x14,%edi
			continue;
f0105a9f:	eb 27                	jmp    f0105ac8 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105aa1:	83 c7 08             	add    $0x8,%edi
			continue;
f0105aa4:	eb 22                	jmp    f0105ac8 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105aa6:	83 ec 08             	sub    $0x8,%esp
f0105aa9:	0f b6 c0             	movzbl %al,%eax
f0105aac:	50                   	push   %eax
f0105aad:	68 74 7e 10 f0       	push   $0xf0107e74
f0105ab2:	e8 ac dd ff ff       	call   f0103863 <cprintf>
			ismp = 0;
f0105ab7:	c7 05 00 00 23 f0 00 	movl   $0x0,0xf0230000
f0105abe:	00 00 00 
			i = conf->entry;
f0105ac1:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f0105ac5:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105ac8:	83 c6 01             	add    $0x1,%esi
f0105acb:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0105acf:	39 c6                	cmp    %eax,%esi
f0105ad1:	0f 82 6f ff ff ff    	jb     f0105a46 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105ad7:	a1 c0 03 23 f0       	mov    0xf02303c0,%eax
f0105adc:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105ae3:	83 3d 00 00 23 f0 00 	cmpl   $0x0,0xf0230000
f0105aea:	75 26                	jne    f0105b12 <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105aec:	c7 05 c4 03 23 f0 01 	movl   $0x1,0xf02303c4
f0105af3:	00 00 00 
		lapicaddr = 0;
f0105af6:	c7 05 00 10 27 f0 00 	movl   $0x0,0xf0271000
f0105afd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105b00:	83 ec 0c             	sub    $0xc,%esp
f0105b03:	68 94 7e 10 f0       	push   $0xf0107e94
f0105b08:	e8 56 dd ff ff       	call   f0103863 <cprintf>
		return;
f0105b0d:	83 c4 10             	add    $0x10,%esp
f0105b10:	eb 48                	jmp    f0105b5a <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105b12:	83 ec 04             	sub    $0x4,%esp
f0105b15:	ff 35 c4 03 23 f0    	pushl  0xf02303c4
f0105b1b:	0f b6 00             	movzbl (%eax),%eax
f0105b1e:	50                   	push   %eax
f0105b1f:	68 1b 7f 10 f0       	push   $0xf0107f1b
f0105b24:	e8 3a dd ff ff       	call   f0103863 <cprintf>

	if (mp->imcrp) {
f0105b29:	83 c4 10             	add    $0x10,%esp
f0105b2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105b2f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105b33:	74 25                	je     f0105b5a <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105b35:	83 ec 0c             	sub    $0xc,%esp
f0105b38:	68 c0 7e 10 f0       	push   $0xf0107ec0
f0105b3d:	e8 21 dd ff ff       	call   f0103863 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b42:	ba 22 00 00 00       	mov    $0x22,%edx
f0105b47:	b8 70 00 00 00       	mov    $0x70,%eax
f0105b4c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105b4d:	ba 23 00 00 00       	mov    $0x23,%edx
f0105b52:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105b53:	83 c8 01             	or     $0x1,%eax
f0105b56:	ee                   	out    %al,(%dx)
f0105b57:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b5d:	5b                   	pop    %ebx
f0105b5e:	5e                   	pop    %esi
f0105b5f:	5f                   	pop    %edi
f0105b60:	5d                   	pop    %ebp
f0105b61:	c3                   	ret    

f0105b62 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105b62:	55                   	push   %ebp
f0105b63:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105b65:	8b 0d 04 10 27 f0    	mov    0xf0271004,%ecx
f0105b6b:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105b6e:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105b70:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105b75:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105b78:	5d                   	pop    %ebp
f0105b79:	c3                   	ret    

f0105b7a <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105b7a:	55                   	push   %ebp
f0105b7b:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105b7d:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105b82:	85 c0                	test   %eax,%eax
f0105b84:	74 08                	je     f0105b8e <cpunum+0x14>
		return lapic[ID] >> 24;
f0105b86:	8b 40 20             	mov    0x20(%eax),%eax
f0105b89:	c1 e8 18             	shr    $0x18,%eax
f0105b8c:	eb 05                	jmp    f0105b93 <cpunum+0x19>
	return 0;
f0105b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b93:	5d                   	pop    %ebp
f0105b94:	c3                   	ret    

f0105b95 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105b95:	a1 00 10 27 f0       	mov    0xf0271000,%eax
f0105b9a:	85 c0                	test   %eax,%eax
f0105b9c:	0f 84 21 01 00 00    	je     f0105cc3 <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105ba2:	55                   	push   %ebp
f0105ba3:	89 e5                	mov    %esp,%ebp
f0105ba5:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105ba8:	68 00 10 00 00       	push   $0x1000
f0105bad:	50                   	push   %eax
f0105bae:	e8 9c b8 ff ff       	call   f010144f <mmio_map_region>
f0105bb3:	a3 04 10 27 f0       	mov    %eax,0xf0271004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105bb8:	ba 27 01 00 00       	mov    $0x127,%edx
f0105bbd:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105bc2:	e8 9b ff ff ff       	call   f0105b62 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105bc7:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105bcc:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105bd1:	e8 8c ff ff ff       	call   f0105b62 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105bd6:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105bdb:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105be0:	e8 7d ff ff ff       	call   f0105b62 <lapicw>
	lapicw(TICR, 10000000); 
f0105be5:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105bea:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105bef:	e8 6e ff ff ff       	call   f0105b62 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105bf4:	e8 81 ff ff ff       	call   f0105b7a <cpunum>
f0105bf9:	6b c0 74             	imul   $0x74,%eax,%eax
f0105bfc:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105c01:	83 c4 10             	add    $0x10,%esp
f0105c04:	39 05 c0 03 23 f0    	cmp    %eax,0xf02303c0
f0105c0a:	74 0f                	je     f0105c1b <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105c0c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c11:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105c16:	e8 47 ff ff ff       	call   f0105b62 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105c1b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c20:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105c25:	e8 38 ff ff ff       	call   f0105b62 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105c2a:	a1 04 10 27 f0       	mov    0xf0271004,%eax
f0105c2f:	8b 40 30             	mov    0x30(%eax),%eax
f0105c32:	c1 e8 10             	shr    $0x10,%eax
f0105c35:	3c 03                	cmp    $0x3,%al
f0105c37:	76 0f                	jbe    f0105c48 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105c39:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105c3e:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105c43:	e8 1a ff ff ff       	call   f0105b62 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105c48:	ba 33 00 00 00       	mov    $0x33,%edx
f0105c4d:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105c52:	e8 0b ff ff ff       	call   f0105b62 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105c57:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c5c:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c61:	e8 fc fe ff ff       	call   f0105b62 <lapicw>
	lapicw(ESR, 0);
f0105c66:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c6b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105c70:	e8 ed fe ff ff       	call   f0105b62 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105c75:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c7a:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105c7f:	e8 de fe ff ff       	call   f0105b62 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105c84:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c89:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105c8e:	e8 cf fe ff ff       	call   f0105b62 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105c93:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105c98:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105c9d:	e8 c0 fe ff ff       	call   f0105b62 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105ca2:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105ca8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105cae:	f6 c4 10             	test   $0x10,%ah
f0105cb1:	75 f5                	jne    f0105ca8 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0105cb3:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cb8:	b8 20 00 00 00       	mov    $0x20,%eax
f0105cbd:	e8 a0 fe ff ff       	call   f0105b62 <lapicw>
}
f0105cc2:	c9                   	leave  
f0105cc3:	f3 c3                	repz ret 

f0105cc5 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105cc5:	83 3d 04 10 27 f0 00 	cmpl   $0x0,0xf0271004
f0105ccc:	74 13                	je     f0105ce1 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105cce:	55                   	push   %ebp
f0105ccf:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0105cd1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cd6:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105cdb:	e8 82 fe ff ff       	call   f0105b62 <lapicw>
}
f0105ce0:	5d                   	pop    %ebp
f0105ce1:	f3 c3                	repz ret 

f0105ce3 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105ce3:	55                   	push   %ebp
f0105ce4:	89 e5                	mov    %esp,%ebp
f0105ce6:	56                   	push   %esi
f0105ce7:	53                   	push   %ebx
f0105ce8:	8b 75 08             	mov    0x8(%ebp),%esi
f0105ceb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105cee:	ba 70 00 00 00       	mov    $0x70,%edx
f0105cf3:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105cf8:	ee                   	out    %al,(%dx)
f0105cf9:	ba 71 00 00 00       	mov    $0x71,%edx
f0105cfe:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d03:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d04:	83 3d 88 fe 22 f0 00 	cmpl   $0x0,0xf022fe88
f0105d0b:	75 19                	jne    f0105d26 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d0d:	68 67 04 00 00       	push   $0x467
f0105d12:	68 44 62 10 f0       	push   $0xf0106244
f0105d17:	68 98 00 00 00       	push   $0x98
f0105d1c:	68 38 7f 10 f0       	push   $0xf0107f38
f0105d21:	e8 1a a3 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105d26:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105d2d:	00 00 
	wrv[1] = addr >> 4;
f0105d2f:	89 d8                	mov    %ebx,%eax
f0105d31:	c1 e8 04             	shr    $0x4,%eax
f0105d34:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105d3a:	c1 e6 18             	shl    $0x18,%esi
f0105d3d:	89 f2                	mov    %esi,%edx
f0105d3f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d44:	e8 19 fe ff ff       	call   f0105b62 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105d49:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105d4e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d53:	e8 0a fe ff ff       	call   f0105b62 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105d58:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105d5d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d62:	e8 fb fd ff ff       	call   f0105b62 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d67:	c1 eb 0c             	shr    $0xc,%ebx
f0105d6a:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d6d:	89 f2                	mov    %esi,%edx
f0105d6f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d74:	e8 e9 fd ff ff       	call   f0105b62 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d79:	89 da                	mov    %ebx,%edx
f0105d7b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d80:	e8 dd fd ff ff       	call   f0105b62 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105d85:	89 f2                	mov    %esi,%edx
f0105d87:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d8c:	e8 d1 fd ff ff       	call   f0105b62 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105d91:	89 da                	mov    %ebx,%edx
f0105d93:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d98:	e8 c5 fd ff ff       	call   f0105b62 <lapicw>
		microdelay(200);
	}
}
f0105d9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105da0:	5b                   	pop    %ebx
f0105da1:	5e                   	pop    %esi
f0105da2:	5d                   	pop    %ebp
f0105da3:	c3                   	ret    

f0105da4 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105da4:	55                   	push   %ebp
f0105da5:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105da7:	8b 55 08             	mov    0x8(%ebp),%edx
f0105daa:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105db0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105db5:	e8 a8 fd ff ff       	call   f0105b62 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105dba:	8b 15 04 10 27 f0    	mov    0xf0271004,%edx
f0105dc0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105dc6:	f6 c4 10             	test   $0x10,%ah
f0105dc9:	75 f5                	jne    f0105dc0 <lapic_ipi+0x1c>
		;
}
f0105dcb:	5d                   	pop    %ebp
f0105dcc:	c3                   	ret    

f0105dcd <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105dcd:	55                   	push   %ebp
f0105dce:	89 e5                	mov    %esp,%ebp
f0105dd0:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105dd3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105dd9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ddc:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105ddf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105de6:	5d                   	pop    %ebp
f0105de7:	c3                   	ret    

f0105de8 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105de8:	55                   	push   %ebp
f0105de9:	89 e5                	mov    %esp,%ebp
f0105deb:	56                   	push   %esi
f0105dec:	53                   	push   %ebx
f0105ded:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105df0:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105df3:	74 14                	je     f0105e09 <spin_lock+0x21>
f0105df5:	8b 73 08             	mov    0x8(%ebx),%esi
f0105df8:	e8 7d fd ff ff       	call   f0105b7a <cpunum>
f0105dfd:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e00:	05 20 00 23 f0       	add    $0xf0230020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105e05:	39 c6                	cmp    %eax,%esi
f0105e07:	74 07                	je     f0105e10 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105e09:	ba 01 00 00 00       	mov    $0x1,%edx
f0105e0e:	eb 20                	jmp    f0105e30 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105e10:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105e13:	e8 62 fd ff ff       	call   f0105b7a <cpunum>
f0105e18:	83 ec 0c             	sub    $0xc,%esp
f0105e1b:	53                   	push   %ebx
f0105e1c:	50                   	push   %eax
f0105e1d:	68 48 7f 10 f0       	push   $0xf0107f48
f0105e22:	6a 41                	push   $0x41
f0105e24:	68 ac 7f 10 f0       	push   $0xf0107fac
f0105e29:	e8 12 a2 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105e2e:	f3 90                	pause  
f0105e30:	89 d0                	mov    %edx,%eax
f0105e32:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105e35:	85 c0                	test   %eax,%eax
f0105e37:	75 f5                	jne    f0105e2e <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105e39:	e8 3c fd ff ff       	call   f0105b7a <cpunum>
f0105e3e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e41:	05 20 00 23 f0       	add    $0xf0230020,%eax
f0105e46:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105e49:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105e4c:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e53:	eb 0b                	jmp    f0105e60 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105e55:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105e58:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105e5b:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105e5d:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105e60:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105e66:	76 11                	jbe    f0105e79 <spin_lock+0x91>
f0105e68:	83 f8 09             	cmp    $0x9,%eax
f0105e6b:	7e e8                	jle    f0105e55 <spin_lock+0x6d>
f0105e6d:	eb 0a                	jmp    f0105e79 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105e6f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105e76:	83 c0 01             	add    $0x1,%eax
f0105e79:	83 f8 09             	cmp    $0x9,%eax
f0105e7c:	7e f1                	jle    f0105e6f <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105e7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e81:	5b                   	pop    %ebx
f0105e82:	5e                   	pop    %esi
f0105e83:	5d                   	pop    %ebp
f0105e84:	c3                   	ret    

f0105e85 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105e85:	55                   	push   %ebp
f0105e86:	89 e5                	mov    %esp,%ebp
f0105e88:	57                   	push   %edi
f0105e89:	56                   	push   %esi
f0105e8a:	53                   	push   %ebx
f0105e8b:	83 ec 4c             	sub    $0x4c,%esp
f0105e8e:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105e91:	83 3e 00             	cmpl   $0x0,(%esi)
f0105e94:	74 18                	je     f0105eae <spin_unlock+0x29>
f0105e96:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105e99:	e8 dc fc ff ff       	call   f0105b7a <cpunum>
f0105e9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ea1:	05 20 00 23 f0       	add    $0xf0230020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105ea6:	39 c3                	cmp    %eax,%ebx
f0105ea8:	0f 84 a5 00 00 00    	je     f0105f53 <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105eae:	83 ec 04             	sub    $0x4,%esp
f0105eb1:	6a 28                	push   $0x28
f0105eb3:	8d 46 0c             	lea    0xc(%esi),%eax
f0105eb6:	50                   	push   %eax
f0105eb7:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105eba:	53                   	push   %ebx
f0105ebb:	e8 e6 f6 ff ff       	call   f01055a6 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105ec0:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105ec3:	0f b6 38             	movzbl (%eax),%edi
f0105ec6:	8b 76 04             	mov    0x4(%esi),%esi
f0105ec9:	e8 ac fc ff ff       	call   f0105b7a <cpunum>
f0105ece:	57                   	push   %edi
f0105ecf:	56                   	push   %esi
f0105ed0:	50                   	push   %eax
f0105ed1:	68 74 7f 10 f0       	push   $0xf0107f74
f0105ed6:	e8 88 d9 ff ff       	call   f0103863 <cprintf>
f0105edb:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105ede:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105ee1:	eb 54                	jmp    f0105f37 <spin_unlock+0xb2>
f0105ee3:	83 ec 08             	sub    $0x8,%esp
f0105ee6:	57                   	push   %edi
f0105ee7:	50                   	push   %eax
f0105ee8:	e8 fa eb ff ff       	call   f0104ae7 <debuginfo_eip>
f0105eed:	83 c4 10             	add    $0x10,%esp
f0105ef0:	85 c0                	test   %eax,%eax
f0105ef2:	78 27                	js     f0105f1b <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105ef4:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105ef6:	83 ec 04             	sub    $0x4,%esp
f0105ef9:	89 c2                	mov    %eax,%edx
f0105efb:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105efe:	52                   	push   %edx
f0105eff:	ff 75 b0             	pushl  -0x50(%ebp)
f0105f02:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105f05:	ff 75 ac             	pushl  -0x54(%ebp)
f0105f08:	ff 75 a8             	pushl  -0x58(%ebp)
f0105f0b:	50                   	push   %eax
f0105f0c:	68 bc 7f 10 f0       	push   $0xf0107fbc
f0105f11:	e8 4d d9 ff ff       	call   f0103863 <cprintf>
f0105f16:	83 c4 20             	add    $0x20,%esp
f0105f19:	eb 12                	jmp    f0105f2d <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105f1b:	83 ec 08             	sub    $0x8,%esp
f0105f1e:	ff 36                	pushl  (%esi)
f0105f20:	68 d3 7f 10 f0       	push   $0xf0107fd3
f0105f25:	e8 39 d9 ff ff       	call   f0103863 <cprintf>
f0105f2a:	83 c4 10             	add    $0x10,%esp
f0105f2d:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105f30:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105f33:	39 c3                	cmp    %eax,%ebx
f0105f35:	74 08                	je     f0105f3f <spin_unlock+0xba>
f0105f37:	89 de                	mov    %ebx,%esi
f0105f39:	8b 03                	mov    (%ebx),%eax
f0105f3b:	85 c0                	test   %eax,%eax
f0105f3d:	75 a4                	jne    f0105ee3 <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105f3f:	83 ec 04             	sub    $0x4,%esp
f0105f42:	68 db 7f 10 f0       	push   $0xf0107fdb
f0105f47:	6a 67                	push   $0x67
f0105f49:	68 ac 7f 10 f0       	push   $0xf0107fac
f0105f4e:	e8 ed a0 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105f53:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105f5a:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105f61:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f66:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105f69:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f6c:	5b                   	pop    %ebx
f0105f6d:	5e                   	pop    %esi
f0105f6e:	5f                   	pop    %edi
f0105f6f:	5d                   	pop    %ebp
f0105f70:	c3                   	ret    
f0105f71:	66 90                	xchg   %ax,%ax
f0105f73:	66 90                	xchg   %ax,%ax
f0105f75:	66 90                	xchg   %ax,%ax
f0105f77:	66 90                	xchg   %ax,%ax
f0105f79:	66 90                	xchg   %ax,%ax
f0105f7b:	66 90                	xchg   %ax,%ax
f0105f7d:	66 90                	xchg   %ax,%ax
f0105f7f:	90                   	nop

f0105f80 <__udivdi3>:
f0105f80:	55                   	push   %ebp
f0105f81:	57                   	push   %edi
f0105f82:	56                   	push   %esi
f0105f83:	53                   	push   %ebx
f0105f84:	83 ec 1c             	sub    $0x1c,%esp
f0105f87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105f8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105f8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105f97:	85 f6                	test   %esi,%esi
f0105f99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105f9d:	89 ca                	mov    %ecx,%edx
f0105f9f:	89 f8                	mov    %edi,%eax
f0105fa1:	75 3d                	jne    f0105fe0 <__udivdi3+0x60>
f0105fa3:	39 cf                	cmp    %ecx,%edi
f0105fa5:	0f 87 c5 00 00 00    	ja     f0106070 <__udivdi3+0xf0>
f0105fab:	85 ff                	test   %edi,%edi
f0105fad:	89 fd                	mov    %edi,%ebp
f0105faf:	75 0b                	jne    f0105fbc <__udivdi3+0x3c>
f0105fb1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105fb6:	31 d2                	xor    %edx,%edx
f0105fb8:	f7 f7                	div    %edi
f0105fba:	89 c5                	mov    %eax,%ebp
f0105fbc:	89 c8                	mov    %ecx,%eax
f0105fbe:	31 d2                	xor    %edx,%edx
f0105fc0:	f7 f5                	div    %ebp
f0105fc2:	89 c1                	mov    %eax,%ecx
f0105fc4:	89 d8                	mov    %ebx,%eax
f0105fc6:	89 cf                	mov    %ecx,%edi
f0105fc8:	f7 f5                	div    %ebp
f0105fca:	89 c3                	mov    %eax,%ebx
f0105fcc:	89 d8                	mov    %ebx,%eax
f0105fce:	89 fa                	mov    %edi,%edx
f0105fd0:	83 c4 1c             	add    $0x1c,%esp
f0105fd3:	5b                   	pop    %ebx
f0105fd4:	5e                   	pop    %esi
f0105fd5:	5f                   	pop    %edi
f0105fd6:	5d                   	pop    %ebp
f0105fd7:	c3                   	ret    
f0105fd8:	90                   	nop
f0105fd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105fe0:	39 ce                	cmp    %ecx,%esi
f0105fe2:	77 74                	ja     f0106058 <__udivdi3+0xd8>
f0105fe4:	0f bd fe             	bsr    %esi,%edi
f0105fe7:	83 f7 1f             	xor    $0x1f,%edi
f0105fea:	0f 84 98 00 00 00    	je     f0106088 <__udivdi3+0x108>
f0105ff0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105ff5:	89 f9                	mov    %edi,%ecx
f0105ff7:	89 c5                	mov    %eax,%ebp
f0105ff9:	29 fb                	sub    %edi,%ebx
f0105ffb:	d3 e6                	shl    %cl,%esi
f0105ffd:	89 d9                	mov    %ebx,%ecx
f0105fff:	d3 ed                	shr    %cl,%ebp
f0106001:	89 f9                	mov    %edi,%ecx
f0106003:	d3 e0                	shl    %cl,%eax
f0106005:	09 ee                	or     %ebp,%esi
f0106007:	89 d9                	mov    %ebx,%ecx
f0106009:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010600d:	89 d5                	mov    %edx,%ebp
f010600f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106013:	d3 ed                	shr    %cl,%ebp
f0106015:	89 f9                	mov    %edi,%ecx
f0106017:	d3 e2                	shl    %cl,%edx
f0106019:	89 d9                	mov    %ebx,%ecx
f010601b:	d3 e8                	shr    %cl,%eax
f010601d:	09 c2                	or     %eax,%edx
f010601f:	89 d0                	mov    %edx,%eax
f0106021:	89 ea                	mov    %ebp,%edx
f0106023:	f7 f6                	div    %esi
f0106025:	89 d5                	mov    %edx,%ebp
f0106027:	89 c3                	mov    %eax,%ebx
f0106029:	f7 64 24 0c          	mull   0xc(%esp)
f010602d:	39 d5                	cmp    %edx,%ebp
f010602f:	72 10                	jb     f0106041 <__udivdi3+0xc1>
f0106031:	8b 74 24 08          	mov    0x8(%esp),%esi
f0106035:	89 f9                	mov    %edi,%ecx
f0106037:	d3 e6                	shl    %cl,%esi
f0106039:	39 c6                	cmp    %eax,%esi
f010603b:	73 07                	jae    f0106044 <__udivdi3+0xc4>
f010603d:	39 d5                	cmp    %edx,%ebp
f010603f:	75 03                	jne    f0106044 <__udivdi3+0xc4>
f0106041:	83 eb 01             	sub    $0x1,%ebx
f0106044:	31 ff                	xor    %edi,%edi
f0106046:	89 d8                	mov    %ebx,%eax
f0106048:	89 fa                	mov    %edi,%edx
f010604a:	83 c4 1c             	add    $0x1c,%esp
f010604d:	5b                   	pop    %ebx
f010604e:	5e                   	pop    %esi
f010604f:	5f                   	pop    %edi
f0106050:	5d                   	pop    %ebp
f0106051:	c3                   	ret    
f0106052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106058:	31 ff                	xor    %edi,%edi
f010605a:	31 db                	xor    %ebx,%ebx
f010605c:	89 d8                	mov    %ebx,%eax
f010605e:	89 fa                	mov    %edi,%edx
f0106060:	83 c4 1c             	add    $0x1c,%esp
f0106063:	5b                   	pop    %ebx
f0106064:	5e                   	pop    %esi
f0106065:	5f                   	pop    %edi
f0106066:	5d                   	pop    %ebp
f0106067:	c3                   	ret    
f0106068:	90                   	nop
f0106069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106070:	89 d8                	mov    %ebx,%eax
f0106072:	f7 f7                	div    %edi
f0106074:	31 ff                	xor    %edi,%edi
f0106076:	89 c3                	mov    %eax,%ebx
f0106078:	89 d8                	mov    %ebx,%eax
f010607a:	89 fa                	mov    %edi,%edx
f010607c:	83 c4 1c             	add    $0x1c,%esp
f010607f:	5b                   	pop    %ebx
f0106080:	5e                   	pop    %esi
f0106081:	5f                   	pop    %edi
f0106082:	5d                   	pop    %ebp
f0106083:	c3                   	ret    
f0106084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106088:	39 ce                	cmp    %ecx,%esi
f010608a:	72 0c                	jb     f0106098 <__udivdi3+0x118>
f010608c:	31 db                	xor    %ebx,%ebx
f010608e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106092:	0f 87 34 ff ff ff    	ja     f0105fcc <__udivdi3+0x4c>
f0106098:	bb 01 00 00 00       	mov    $0x1,%ebx
f010609d:	e9 2a ff ff ff       	jmp    f0105fcc <__udivdi3+0x4c>
f01060a2:	66 90                	xchg   %ax,%ax
f01060a4:	66 90                	xchg   %ax,%ax
f01060a6:	66 90                	xchg   %ax,%ax
f01060a8:	66 90                	xchg   %ax,%ax
f01060aa:	66 90                	xchg   %ax,%ax
f01060ac:	66 90                	xchg   %ax,%ax
f01060ae:	66 90                	xchg   %ax,%ax

f01060b0 <__umoddi3>:
f01060b0:	55                   	push   %ebp
f01060b1:	57                   	push   %edi
f01060b2:	56                   	push   %esi
f01060b3:	53                   	push   %ebx
f01060b4:	83 ec 1c             	sub    $0x1c,%esp
f01060b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01060bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01060bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01060c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01060c7:	85 d2                	test   %edx,%edx
f01060c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01060cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01060d1:	89 f3                	mov    %esi,%ebx
f01060d3:	89 3c 24             	mov    %edi,(%esp)
f01060d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01060da:	75 1c                	jne    f01060f8 <__umoddi3+0x48>
f01060dc:	39 f7                	cmp    %esi,%edi
f01060de:	76 50                	jbe    f0106130 <__umoddi3+0x80>
f01060e0:	89 c8                	mov    %ecx,%eax
f01060e2:	89 f2                	mov    %esi,%edx
f01060e4:	f7 f7                	div    %edi
f01060e6:	89 d0                	mov    %edx,%eax
f01060e8:	31 d2                	xor    %edx,%edx
f01060ea:	83 c4 1c             	add    $0x1c,%esp
f01060ed:	5b                   	pop    %ebx
f01060ee:	5e                   	pop    %esi
f01060ef:	5f                   	pop    %edi
f01060f0:	5d                   	pop    %ebp
f01060f1:	c3                   	ret    
f01060f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01060f8:	39 f2                	cmp    %esi,%edx
f01060fa:	89 d0                	mov    %edx,%eax
f01060fc:	77 52                	ja     f0106150 <__umoddi3+0xa0>
f01060fe:	0f bd ea             	bsr    %edx,%ebp
f0106101:	83 f5 1f             	xor    $0x1f,%ebp
f0106104:	75 5a                	jne    f0106160 <__umoddi3+0xb0>
f0106106:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010610a:	0f 82 e0 00 00 00    	jb     f01061f0 <__umoddi3+0x140>
f0106110:	39 0c 24             	cmp    %ecx,(%esp)
f0106113:	0f 86 d7 00 00 00    	jbe    f01061f0 <__umoddi3+0x140>
f0106119:	8b 44 24 08          	mov    0x8(%esp),%eax
f010611d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106121:	83 c4 1c             	add    $0x1c,%esp
f0106124:	5b                   	pop    %ebx
f0106125:	5e                   	pop    %esi
f0106126:	5f                   	pop    %edi
f0106127:	5d                   	pop    %ebp
f0106128:	c3                   	ret    
f0106129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106130:	85 ff                	test   %edi,%edi
f0106132:	89 fd                	mov    %edi,%ebp
f0106134:	75 0b                	jne    f0106141 <__umoddi3+0x91>
f0106136:	b8 01 00 00 00       	mov    $0x1,%eax
f010613b:	31 d2                	xor    %edx,%edx
f010613d:	f7 f7                	div    %edi
f010613f:	89 c5                	mov    %eax,%ebp
f0106141:	89 f0                	mov    %esi,%eax
f0106143:	31 d2                	xor    %edx,%edx
f0106145:	f7 f5                	div    %ebp
f0106147:	89 c8                	mov    %ecx,%eax
f0106149:	f7 f5                	div    %ebp
f010614b:	89 d0                	mov    %edx,%eax
f010614d:	eb 99                	jmp    f01060e8 <__umoddi3+0x38>
f010614f:	90                   	nop
f0106150:	89 c8                	mov    %ecx,%eax
f0106152:	89 f2                	mov    %esi,%edx
f0106154:	83 c4 1c             	add    $0x1c,%esp
f0106157:	5b                   	pop    %ebx
f0106158:	5e                   	pop    %esi
f0106159:	5f                   	pop    %edi
f010615a:	5d                   	pop    %ebp
f010615b:	c3                   	ret    
f010615c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106160:	8b 34 24             	mov    (%esp),%esi
f0106163:	bf 20 00 00 00       	mov    $0x20,%edi
f0106168:	89 e9                	mov    %ebp,%ecx
f010616a:	29 ef                	sub    %ebp,%edi
f010616c:	d3 e0                	shl    %cl,%eax
f010616e:	89 f9                	mov    %edi,%ecx
f0106170:	89 f2                	mov    %esi,%edx
f0106172:	d3 ea                	shr    %cl,%edx
f0106174:	89 e9                	mov    %ebp,%ecx
f0106176:	09 c2                	or     %eax,%edx
f0106178:	89 d8                	mov    %ebx,%eax
f010617a:	89 14 24             	mov    %edx,(%esp)
f010617d:	89 f2                	mov    %esi,%edx
f010617f:	d3 e2                	shl    %cl,%edx
f0106181:	89 f9                	mov    %edi,%ecx
f0106183:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106187:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010618b:	d3 e8                	shr    %cl,%eax
f010618d:	89 e9                	mov    %ebp,%ecx
f010618f:	89 c6                	mov    %eax,%esi
f0106191:	d3 e3                	shl    %cl,%ebx
f0106193:	89 f9                	mov    %edi,%ecx
f0106195:	89 d0                	mov    %edx,%eax
f0106197:	d3 e8                	shr    %cl,%eax
f0106199:	89 e9                	mov    %ebp,%ecx
f010619b:	09 d8                	or     %ebx,%eax
f010619d:	89 d3                	mov    %edx,%ebx
f010619f:	89 f2                	mov    %esi,%edx
f01061a1:	f7 34 24             	divl   (%esp)
f01061a4:	89 d6                	mov    %edx,%esi
f01061a6:	d3 e3                	shl    %cl,%ebx
f01061a8:	f7 64 24 04          	mull   0x4(%esp)
f01061ac:	39 d6                	cmp    %edx,%esi
f01061ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01061b2:	89 d1                	mov    %edx,%ecx
f01061b4:	89 c3                	mov    %eax,%ebx
f01061b6:	72 08                	jb     f01061c0 <__umoddi3+0x110>
f01061b8:	75 11                	jne    f01061cb <__umoddi3+0x11b>
f01061ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01061be:	73 0b                	jae    f01061cb <__umoddi3+0x11b>
f01061c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01061c4:	1b 14 24             	sbb    (%esp),%edx
f01061c7:	89 d1                	mov    %edx,%ecx
f01061c9:	89 c3                	mov    %eax,%ebx
f01061cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01061cf:	29 da                	sub    %ebx,%edx
f01061d1:	19 ce                	sbb    %ecx,%esi
f01061d3:	89 f9                	mov    %edi,%ecx
f01061d5:	89 f0                	mov    %esi,%eax
f01061d7:	d3 e0                	shl    %cl,%eax
f01061d9:	89 e9                	mov    %ebp,%ecx
f01061db:	d3 ea                	shr    %cl,%edx
f01061dd:	89 e9                	mov    %ebp,%ecx
f01061df:	d3 ee                	shr    %cl,%esi
f01061e1:	09 d0                	or     %edx,%eax
f01061e3:	89 f2                	mov    %esi,%edx
f01061e5:	83 c4 1c             	add    $0x1c,%esp
f01061e8:	5b                   	pop    %ebx
f01061e9:	5e                   	pop    %esi
f01061ea:	5f                   	pop    %edi
f01061eb:	5d                   	pop    %ebp
f01061ec:	c3                   	ret    
f01061ed:	8d 76 00             	lea    0x0(%esi),%esi
f01061f0:	29 f9                	sub    %edi,%ecx
f01061f2:	19 d6                	sbb    %edx,%esi
f01061f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01061f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01061fc:	e9 18 ff ff ff       	jmp    f0106119 <__umoddi3+0x69>
