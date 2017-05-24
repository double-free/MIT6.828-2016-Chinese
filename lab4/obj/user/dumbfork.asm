
obj/user/dumbfork:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 4a 0c 00 00       	call   800c94 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 e0 10 80 00       	push   $0x8010e0
  800057:	6a 20                	push   $0x20
  800059:	68 f3 10 80 00       	push   $0x8010f3
  80005e:	e8 d0 01 00 00       	call   800233 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 61 0c 00 00       	call   800cd7 <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 03 11 80 00       	push   $0x801103
  800083:	6a 22                	push   $0x22
  800085:	68 f3 10 80 00       	push   $0x8010f3
  80008a:	e8 a4 01 00 00       	call   800233 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 81 09 00 00       	call   800a23 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 68 0c 00 00       	call   800d19 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 14 11 80 00       	push   $0x801114
  8000be:	6a 25                	push   $0x25
  8000c0:	68 f3 10 80 00       	push   $0x8010f3
  8000c5:	e8 69 01 00 00       	call   800233 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 27 11 80 00       	push   $0x801127
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 f3 10 80 00       	push   $0x8010f3
  8000f3:	e8 3b 01 00 00       	call   800233 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 53 0b 00 00       	call   800c56 <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 fa 0b 00 00       	call   800d5b <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 37 11 80 00       	push   $0x801137
  80016e:	6a 4c                	push   $0x4c
  800170:	68 f3 10 80 00       	push   $0x8010f3
  800175:	e8 b9 00 00 00       	call   800233 <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 55 11 80 00       	mov    $0x801155,%esi
  80019a:	b8 4e 11 80 00       	mov    $0x80114e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 5b 11 80 00       	push   $0x80115b
  8001b3:	e8 54 01 00 00       	call   80030c <cprintf>
		sys_yield();
  8001b8:	e8 b8 0a 00 00       	call   800c75 <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e6:	e8 6b 0a 00 00       	call   800c56 <sys_getenvid>
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800227:	6a 00                	push   $0x0
  800229:	e8 e7 09 00 00       	call   800c15 <sys_env_destroy>
}
  80022e:	83 c4 10             	add    $0x10,%esp
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800241:	e8 10 0a 00 00       	call   800c56 <sys_getenvid>
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	ff 75 0c             	pushl  0xc(%ebp)
  80024c:	ff 75 08             	pushl  0x8(%ebp)
  80024f:	56                   	push   %esi
  800250:	50                   	push   %eax
  800251:	68 78 11 80 00       	push   $0x801178
  800256:	e8 b1 00 00 00       	call   80030c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025b:	83 c4 18             	add    $0x18,%esp
  80025e:	53                   	push   %ebx
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	e8 54 00 00 00       	call   8002bb <vcprintf>
	cprintf("\n");
  800267:	c7 04 24 6b 11 80 00 	movl   $0x80116b,(%esp)
  80026e:	e8 99 00 00 00       	call   80030c <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800276:	cc                   	int3   
  800277:	eb fd                	jmp    800276 <_panic+0x43>

00800279 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	53                   	push   %ebx
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800283:	8b 13                	mov    (%ebx),%edx
  800285:	8d 42 01             	lea    0x1(%edx),%eax
  800288:	89 03                	mov    %eax,(%ebx)
  80028a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800291:	3d ff 00 00 00       	cmp    $0xff,%eax
  800296:	75 1a                	jne    8002b2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	68 ff 00 00 00       	push   $0xff
  8002a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 2f 09 00 00       	call   800bd8 <sys_cputs>
		b->idx = 0;
  8002a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002af:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cb:	00 00 00 
	b.cnt = 0;
  8002ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e4:	50                   	push   %eax
  8002e5:	68 79 02 80 00       	push   $0x800279
  8002ea:	e8 54 01 00 00       	call   800443 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ef:	83 c4 08             	add    $0x8,%esp
  8002f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fe:	50                   	push   %eax
  8002ff:	e8 d4 08 00 00       	call   800bd8 <sys_cputs>

	return b.cnt;
}
  800304:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800312:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 9d ff ff ff       	call   8002bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 1c             	sub    $0x1c,%esp
  800329:	89 c7                	mov    %eax,%edi
  80032b:	89 d6                	mov    %edx,%esi
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	8b 55 0c             	mov    0xc(%ebp),%edx
  800333:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800336:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800339:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800341:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800344:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800347:	39 d3                	cmp    %edx,%ebx
  800349:	72 05                	jb     800350 <printnum+0x30>
  80034b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80034e:	77 45                	ja     800395 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 18             	pushl  0x18(%ebp)
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035c:	53                   	push   %ebx
  80035d:	ff 75 10             	pushl  0x10(%ebp)
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	ff 75 e4             	pushl  -0x1c(%ebp)
  800366:	ff 75 e0             	pushl  -0x20(%ebp)
  800369:	ff 75 dc             	pushl  -0x24(%ebp)
  80036c:	ff 75 d8             	pushl  -0x28(%ebp)
  80036f:	e8 dc 0a 00 00       	call   800e50 <__udivdi3>
  800374:	83 c4 18             	add    $0x18,%esp
  800377:	52                   	push   %edx
  800378:	50                   	push   %eax
  800379:	89 f2                	mov    %esi,%edx
  80037b:	89 f8                	mov    %edi,%eax
  80037d:	e8 9e ff ff ff       	call   800320 <printnum>
  800382:	83 c4 20             	add    $0x20,%esp
  800385:	eb 18                	jmp    80039f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	56                   	push   %esi
  80038b:	ff 75 18             	pushl  0x18(%ebp)
  80038e:	ff d7                	call   *%edi
  800390:	83 c4 10             	add    $0x10,%esp
  800393:	eb 03                	jmp    800398 <printnum+0x78>
  800395:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800398:	83 eb 01             	sub    $0x1,%ebx
  80039b:	85 db                	test   %ebx,%ebx
  80039d:	7f e8                	jg     800387 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	56                   	push   %esi
  8003a3:	83 ec 04             	sub    $0x4,%esp
  8003a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8003af:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b2:	e8 c9 0b 00 00       	call   800f80 <__umoddi3>
  8003b7:	83 c4 14             	add    $0x14,%esp
  8003ba:	0f be 80 9c 11 80 00 	movsbl 0x80119c(%eax),%eax
  8003c1:	50                   	push   %eax
  8003c2:	ff d7                	call   *%edi
}
  8003c4:	83 c4 10             	add    $0x10,%esp
  8003c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d2:	83 fa 01             	cmp    $0x1,%edx
  8003d5:	7e 0e                	jle    8003e5 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d7:	8b 10                	mov    (%eax),%edx
  8003d9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003dc:	89 08                	mov    %ecx,(%eax)
  8003de:	8b 02                	mov    (%edx),%eax
  8003e0:	8b 52 04             	mov    0x4(%edx),%edx
  8003e3:	eb 22                	jmp    800407 <getuint+0x38>
	else if (lflag)
  8003e5:	85 d2                	test   %edx,%edx
  8003e7:	74 10                	je     8003f9 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e9:	8b 10                	mov    (%eax),%edx
  8003eb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ee:	89 08                	mov    %ecx,(%eax)
  8003f0:	8b 02                	mov    (%edx),%eax
  8003f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f7:	eb 0e                	jmp    800407 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fe:	89 08                	mov    %ecx,(%eax)
  800400:	8b 02                	mov    (%edx),%eax
  800402:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800413:	8b 10                	mov    (%eax),%edx
  800415:	3b 50 04             	cmp    0x4(%eax),%edx
  800418:	73 0a                	jae    800424 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80041d:	89 08                	mov    %ecx,(%eax)
  80041f:	8b 45 08             	mov    0x8(%ebp),%eax
  800422:	88 02                	mov    %al,(%edx)
}
  800424:	5d                   	pop    %ebp
  800425:	c3                   	ret    

00800426 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042f:	50                   	push   %eax
  800430:	ff 75 10             	pushl  0x10(%ebp)
  800433:	ff 75 0c             	pushl  0xc(%ebp)
  800436:	ff 75 08             	pushl  0x8(%ebp)
  800439:	e8 05 00 00 00       	call   800443 <vprintfmt>
	va_end(ap);
}
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	c9                   	leave  
  800442:	c3                   	ret    

00800443 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	57                   	push   %edi
  800447:	56                   	push   %esi
  800448:	53                   	push   %ebx
  800449:	83 ec 2c             	sub    $0x2c,%esp
  80044c:	8b 75 08             	mov    0x8(%ebp),%esi
  80044f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800452:	8b 7d 10             	mov    0x10(%ebp),%edi
  800455:	eb 12                	jmp    800469 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800457:	85 c0                	test   %eax,%eax
  800459:	0f 84 89 03 00 00    	je     8007e8 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	53                   	push   %ebx
  800463:	50                   	push   %eax
  800464:	ff d6                	call   *%esi
  800466:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800469:	83 c7 01             	add    $0x1,%edi
  80046c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800470:	83 f8 25             	cmp    $0x25,%eax
  800473:	75 e2                	jne    800457 <vprintfmt+0x14>
  800475:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800479:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800480:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800487:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80048e:	ba 00 00 00 00       	mov    $0x0,%edx
  800493:	eb 07                	jmp    80049c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800498:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8d 47 01             	lea    0x1(%edi),%eax
  80049f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a2:	0f b6 07             	movzbl (%edi),%eax
  8004a5:	0f b6 c8             	movzbl %al,%ecx
  8004a8:	83 e8 23             	sub    $0x23,%eax
  8004ab:	3c 55                	cmp    $0x55,%al
  8004ad:	0f 87 1a 03 00 00    	ja     8007cd <vprintfmt+0x38a>
  8004b3:	0f b6 c0             	movzbl %al,%eax
  8004b6:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c4:	eb d6                	jmp    80049c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004db:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004de:	83 fa 09             	cmp    $0x9,%edx
  8004e1:	77 39                	ja     80051c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e6:	eb e9                	jmp    8004d1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ee:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f9:	eb 27                	jmp    800522 <vprintfmt+0xdf>
  8004fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fe:	85 c0                	test   %eax,%eax
  800500:	b9 00 00 00 00       	mov    $0x0,%ecx
  800505:	0f 49 c8             	cmovns %eax,%ecx
  800508:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050e:	eb 8c                	jmp    80049c <vprintfmt+0x59>
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800513:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051a:	eb 80                	jmp    80049c <vprintfmt+0x59>
  80051c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800522:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800526:	0f 89 70 ff ff ff    	jns    80049c <vprintfmt+0x59>
				width = precision, precision = -1;
  80052c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80052f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800532:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800539:	e9 5e ff ff ff       	jmp    80049c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80053e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800544:	e9 53 ff ff ff       	jmp    80049c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8d 50 04             	lea    0x4(%eax),%edx
  80054f:	89 55 14             	mov    %edx,0x14(%ebp)
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	53                   	push   %ebx
  800556:	ff 30                	pushl  (%eax)
  800558:	ff d6                	call   *%esi
			break;
  80055a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800560:	e9 04 ff ff ff       	jmp    800469 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 50 04             	lea    0x4(%eax),%edx
  80056b:	89 55 14             	mov    %edx,0x14(%ebp)
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	99                   	cltd   
  800571:	31 d0                	xor    %edx,%eax
  800573:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800575:	83 f8 08             	cmp    $0x8,%eax
  800578:	7f 0b                	jg     800585 <vprintfmt+0x142>
  80057a:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  800581:	85 d2                	test   %edx,%edx
  800583:	75 18                	jne    80059d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800585:	50                   	push   %eax
  800586:	68 b4 11 80 00       	push   $0x8011b4
  80058b:	53                   	push   %ebx
  80058c:	56                   	push   %esi
  80058d:	e8 94 fe ff ff       	call   800426 <printfmt>
  800592:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800598:	e9 cc fe ff ff       	jmp    800469 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80059d:	52                   	push   %edx
  80059e:	68 bd 11 80 00       	push   $0x8011bd
  8005a3:	53                   	push   %ebx
  8005a4:	56                   	push   %esi
  8005a5:	e8 7c fe ff ff       	call   800426 <printfmt>
  8005aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b0:	e9 b4 fe ff ff       	jmp    800469 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 50 04             	lea    0x4(%eax),%edx
  8005bb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005be:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c0:	85 ff                	test   %edi,%edi
  8005c2:	b8 ad 11 80 00       	mov    $0x8011ad,%eax
  8005c7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005ca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ce:	0f 8e 94 00 00 00    	jle    800668 <vprintfmt+0x225>
  8005d4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d8:	0f 84 98 00 00 00    	je     800676 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e4:	57                   	push   %edi
  8005e5:	e8 86 02 00 00       	call   800870 <strnlen>
  8005ea:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ed:	29 c1                	sub    %eax,%ecx
  8005ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	eb 0f                	jmp    800612 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	ff 75 e0             	pushl  -0x20(%ebp)
  80060a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	85 ff                	test   %edi,%edi
  800614:	7f ed                	jg     800603 <vprintfmt+0x1c0>
  800616:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800619:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061c:	85 c9                	test   %ecx,%ecx
  80061e:	b8 00 00 00 00       	mov    $0x0,%eax
  800623:	0f 49 c1             	cmovns %ecx,%eax
  800626:	29 c1                	sub    %eax,%ecx
  800628:	89 75 08             	mov    %esi,0x8(%ebp)
  80062b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800631:	89 cb                	mov    %ecx,%ebx
  800633:	eb 4d                	jmp    800682 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800635:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800639:	74 1b                	je     800656 <vprintfmt+0x213>
  80063b:	0f be c0             	movsbl %al,%eax
  80063e:	83 e8 20             	sub    $0x20,%eax
  800641:	83 f8 5e             	cmp    $0x5e,%eax
  800644:	76 10                	jbe    800656 <vprintfmt+0x213>
					putch('?', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	ff 75 0c             	pushl  0xc(%ebp)
  80064c:	6a 3f                	push   $0x3f
  80064e:	ff 55 08             	call   *0x8(%ebp)
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	eb 0d                	jmp    800663 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	ff 75 0c             	pushl  0xc(%ebp)
  80065c:	52                   	push   %edx
  80065d:	ff 55 08             	call   *0x8(%ebp)
  800660:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800663:	83 eb 01             	sub    $0x1,%ebx
  800666:	eb 1a                	jmp    800682 <vprintfmt+0x23f>
  800668:	89 75 08             	mov    %esi,0x8(%ebp)
  80066b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800671:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800674:	eb 0c                	jmp    800682 <vprintfmt+0x23f>
  800676:	89 75 08             	mov    %esi,0x8(%ebp)
  800679:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800682:	83 c7 01             	add    $0x1,%edi
  800685:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800689:	0f be d0             	movsbl %al,%edx
  80068c:	85 d2                	test   %edx,%edx
  80068e:	74 23                	je     8006b3 <vprintfmt+0x270>
  800690:	85 f6                	test   %esi,%esi
  800692:	78 a1                	js     800635 <vprintfmt+0x1f2>
  800694:	83 ee 01             	sub    $0x1,%esi
  800697:	79 9c                	jns    800635 <vprintfmt+0x1f2>
  800699:	89 df                	mov    %ebx,%edi
  80069b:	8b 75 08             	mov    0x8(%ebp),%esi
  80069e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a1:	eb 18                	jmp    8006bb <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 20                	push   $0x20
  8006a9:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ab:	83 ef 01             	sub    $0x1,%edi
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb 08                	jmp    8006bb <vprintfmt+0x278>
  8006b3:	89 df                	mov    %ebx,%edi
  8006b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006bb:	85 ff                	test   %edi,%edi
  8006bd:	7f e4                	jg     8006a3 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c2:	e9 a2 fd ff ff       	jmp    800469 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c7:	83 fa 01             	cmp    $0x1,%edx
  8006ca:	7e 16                	jle    8006e2 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 08             	lea    0x8(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 50 04             	mov    0x4(%eax),%edx
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e0:	eb 32                	jmp    800714 <vprintfmt+0x2d1>
	else if (lflag)
  8006e2:	85 d2                	test   %edx,%edx
  8006e4:	74 18                	je     8006fe <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f4:	89 c1                	mov    %eax,%ecx
  8006f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fc:	eb 16                	jmp    800714 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 50 04             	lea    0x4(%eax),%edx
  800704:	89 55 14             	mov    %edx,0x14(%ebp)
  800707:	8b 00                	mov    (%eax),%eax
  800709:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070c:	89 c1                	mov    %eax,%ecx
  80070e:	c1 f9 1f             	sar    $0x1f,%ecx
  800711:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800714:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800717:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800723:	79 74                	jns    800799 <vprintfmt+0x356>
				putch('-', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	6a 2d                	push   $0x2d
  80072b:	ff d6                	call   *%esi
				num = -(long long) num;
  80072d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800730:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800733:	f7 d8                	neg    %eax
  800735:	83 d2 00             	adc    $0x0,%edx
  800738:	f7 da                	neg    %edx
  80073a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80073d:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800742:	eb 55                	jmp    800799 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800744:	8d 45 14             	lea    0x14(%ebp),%eax
  800747:	e8 83 fc ff ff       	call   8003cf <getuint>
			base = 10;
  80074c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800751:	eb 46                	jmp    800799 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 74 fc ff ff       	call   8003cf <getuint>
			base = 8;
  80075b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800760:	eb 37                	jmp    800799 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 30                	push   $0x30
  800768:	ff d6                	call   *%esi
			putch('x', putdat);
  80076a:	83 c4 08             	add    $0x8,%esp
  80076d:	53                   	push   %ebx
  80076e:	6a 78                	push   $0x78
  800770:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077b:	8b 00                	mov    (%eax),%eax
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800782:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800785:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078a:	eb 0d                	jmp    800799 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
  80078f:	e8 3b fc ff ff       	call   8003cf <getuint>
			base = 16;
  800794:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800799:	83 ec 0c             	sub    $0xc,%esp
  80079c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a0:	57                   	push   %edi
  8007a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a4:	51                   	push   %ecx
  8007a5:	52                   	push   %edx
  8007a6:	50                   	push   %eax
  8007a7:	89 da                	mov    %ebx,%edx
  8007a9:	89 f0                	mov    %esi,%eax
  8007ab:	e8 70 fb ff ff       	call   800320 <printnum>
			break;
  8007b0:	83 c4 20             	add    $0x20,%esp
  8007b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b6:	e9 ae fc ff ff       	jmp    800469 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	53                   	push   %ebx
  8007bf:	51                   	push   %ecx
  8007c0:	ff d6                	call   *%esi
			break;
  8007c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c8:	e9 9c fc ff ff       	jmp    800469 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cd:	83 ec 08             	sub    $0x8,%esp
  8007d0:	53                   	push   %ebx
  8007d1:	6a 25                	push   $0x25
  8007d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d5:	83 c4 10             	add    $0x10,%esp
  8007d8:	eb 03                	jmp    8007dd <vprintfmt+0x39a>
  8007da:	83 ef 01             	sub    $0x1,%edi
  8007dd:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e1:	75 f7                	jne    8007da <vprintfmt+0x397>
  8007e3:	e9 81 fc ff ff       	jmp    800469 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5f                   	pop    %edi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 18             	sub    $0x18,%esp
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ff:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800803:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800806:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080d:	85 c0                	test   %eax,%eax
  80080f:	74 26                	je     800837 <vsnprintf+0x47>
  800811:	85 d2                	test   %edx,%edx
  800813:	7e 22                	jle    800837 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800815:	ff 75 14             	pushl  0x14(%ebp)
  800818:	ff 75 10             	pushl  0x10(%ebp)
  80081b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081e:	50                   	push   %eax
  80081f:	68 09 04 80 00       	push   $0x800409
  800824:	e8 1a fc ff ff       	call   800443 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800829:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	eb 05                	jmp    80083c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800847:	50                   	push   %eax
  800848:	ff 75 10             	pushl  0x10(%ebp)
  80084b:	ff 75 0c             	pushl  0xc(%ebp)
  80084e:	ff 75 08             	pushl  0x8(%ebp)
  800851:	e8 9a ff ff ff       	call   8007f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
  800863:	eb 03                	jmp    800868 <strlen+0x10>
		n++;
  800865:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800868:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086c:	75 f7                	jne    800865 <strlen+0xd>
		n++;
	return n;
}
  80086e:	5d                   	pop    %ebp
  80086f:	c3                   	ret    

00800870 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800876:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
  80087e:	eb 03                	jmp    800883 <strnlen+0x13>
		n++;
  800880:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800883:	39 c2                	cmp    %eax,%edx
  800885:	74 08                	je     80088f <strnlen+0x1f>
  800887:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088b:	75 f3                	jne    800880 <strnlen+0x10>
  80088d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	83 c2 01             	add    $0x1,%edx
  8008a0:	83 c1 01             	add    $0x1,%ecx
  8008a3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008aa:	84 db                	test   %bl,%bl
  8008ac:	75 ef                	jne    80089d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	53                   	push   %ebx
  8008b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b8:	53                   	push   %ebx
  8008b9:	e8 9a ff ff ff       	call   800858 <strlen>
  8008be:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c1:	ff 75 0c             	pushl  0xc(%ebp)
  8008c4:	01 d8                	add    %ebx,%eax
  8008c6:	50                   	push   %eax
  8008c7:	e8 c5 ff ff ff       	call   800891 <strcpy>
	return dst;
}
  8008cc:	89 d8                	mov    %ebx,%eax
  8008ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    

008008d3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	56                   	push   %esi
  8008d7:	53                   	push   %ebx
  8008d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008de:	89 f3                	mov    %esi,%ebx
  8008e0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e3:	89 f2                	mov    %esi,%edx
  8008e5:	eb 0f                	jmp    8008f6 <strncpy+0x23>
		*dst++ = *src;
  8008e7:	83 c2 01             	add    $0x1,%edx
  8008ea:	0f b6 01             	movzbl (%ecx),%eax
  8008ed:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f6:	39 da                	cmp    %ebx,%edx
  8008f8:	75 ed                	jne    8008e7 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fa:	89 f0                	mov    %esi,%eax
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
  800905:	8b 75 08             	mov    0x8(%ebp),%esi
  800908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090b:	8b 55 10             	mov    0x10(%ebp),%edx
  80090e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800910:	85 d2                	test   %edx,%edx
  800912:	74 21                	je     800935 <strlcpy+0x35>
  800914:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800918:	89 f2                	mov    %esi,%edx
  80091a:	eb 09                	jmp    800925 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091c:	83 c2 01             	add    $0x1,%edx
  80091f:	83 c1 01             	add    $0x1,%ecx
  800922:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800925:	39 c2                	cmp    %eax,%edx
  800927:	74 09                	je     800932 <strlcpy+0x32>
  800929:	0f b6 19             	movzbl (%ecx),%ebx
  80092c:	84 db                	test   %bl,%bl
  80092e:	75 ec                	jne    80091c <strlcpy+0x1c>
  800930:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800932:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800935:	29 f0                	sub    %esi,%eax
}
  800937:	5b                   	pop    %ebx
  800938:	5e                   	pop    %esi
  800939:	5d                   	pop    %ebp
  80093a:	c3                   	ret    

0080093b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800944:	eb 06                	jmp    80094c <strcmp+0x11>
		p++, q++;
  800946:	83 c1 01             	add    $0x1,%ecx
  800949:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094c:	0f b6 01             	movzbl (%ecx),%eax
  80094f:	84 c0                	test   %al,%al
  800951:	74 04                	je     800957 <strcmp+0x1c>
  800953:	3a 02                	cmp    (%edx),%al
  800955:	74 ef                	je     800946 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800957:	0f b6 c0             	movzbl %al,%eax
  80095a:	0f b6 12             	movzbl (%edx),%edx
  80095d:	29 d0                	sub    %edx,%eax
}
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096b:	89 c3                	mov    %eax,%ebx
  80096d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800970:	eb 06                	jmp    800978 <strncmp+0x17>
		n--, p++, q++;
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800978:	39 d8                	cmp    %ebx,%eax
  80097a:	74 15                	je     800991 <strncmp+0x30>
  80097c:	0f b6 08             	movzbl (%eax),%ecx
  80097f:	84 c9                	test   %cl,%cl
  800981:	74 04                	je     800987 <strncmp+0x26>
  800983:	3a 0a                	cmp    (%edx),%cl
  800985:	74 eb                	je     800972 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800987:	0f b6 00             	movzbl (%eax),%eax
  80098a:	0f b6 12             	movzbl (%edx),%edx
  80098d:	29 d0                	sub    %edx,%eax
  80098f:	eb 05                	jmp    800996 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800991:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800996:	5b                   	pop    %ebx
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a3:	eb 07                	jmp    8009ac <strchr+0x13>
		if (*s == c)
  8009a5:	38 ca                	cmp    %cl,%dl
  8009a7:	74 0f                	je     8009b8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	0f b6 10             	movzbl (%eax),%edx
  8009af:	84 d2                	test   %dl,%dl
  8009b1:	75 f2                	jne    8009a5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c4:	eb 03                	jmp    8009c9 <strfind+0xf>
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	74 04                	je     8009d4 <strfind+0x1a>
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 f2                	jne    8009c6 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	57                   	push   %edi
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e2:	85 c9                	test   %ecx,%ecx
  8009e4:	74 36                	je     800a1c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e6:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ec:	75 28                	jne    800a16 <memset+0x40>
  8009ee:	f6 c1 03             	test   $0x3,%cl
  8009f1:	75 23                	jne    800a16 <memset+0x40>
		c &= 0xFF;
  8009f3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f7:	89 d3                	mov    %edx,%ebx
  8009f9:	c1 e3 08             	shl    $0x8,%ebx
  8009fc:	89 d6                	mov    %edx,%esi
  8009fe:	c1 e6 18             	shl    $0x18,%esi
  800a01:	89 d0                	mov    %edx,%eax
  800a03:	c1 e0 10             	shl    $0x10,%eax
  800a06:	09 f0                	or     %esi,%eax
  800a08:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0a:	89 d8                	mov    %ebx,%eax
  800a0c:	09 d0                	or     %edx,%eax
  800a0e:	c1 e9 02             	shr    $0x2,%ecx
  800a11:	fc                   	cld    
  800a12:	f3 ab                	rep stos %eax,%es:(%edi)
  800a14:	eb 06                	jmp    800a1c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a19:	fc                   	cld    
  800a1a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1c:	89 f8                	mov    %edi,%eax
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5f                   	pop    %edi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	57                   	push   %edi
  800a27:	56                   	push   %esi
  800a28:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a31:	39 c6                	cmp    %eax,%esi
  800a33:	73 35                	jae    800a6a <memmove+0x47>
  800a35:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a38:	39 d0                	cmp    %edx,%eax
  800a3a:	73 2e                	jae    800a6a <memmove+0x47>
		s += n;
		d += n;
  800a3c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3f:	89 d6                	mov    %edx,%esi
  800a41:	09 fe                	or     %edi,%esi
  800a43:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a49:	75 13                	jne    800a5e <memmove+0x3b>
  800a4b:	f6 c1 03             	test   $0x3,%cl
  800a4e:	75 0e                	jne    800a5e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a50:	83 ef 04             	sub    $0x4,%edi
  800a53:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a56:	c1 e9 02             	shr    $0x2,%ecx
  800a59:	fd                   	std    
  800a5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5c:	eb 09                	jmp    800a67 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a5e:	83 ef 01             	sub    $0x1,%edi
  800a61:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a64:	fd                   	std    
  800a65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a67:	fc                   	cld    
  800a68:	eb 1d                	jmp    800a87 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6a:	89 f2                	mov    %esi,%edx
  800a6c:	09 c2                	or     %eax,%edx
  800a6e:	f6 c2 03             	test   $0x3,%dl
  800a71:	75 0f                	jne    800a82 <memmove+0x5f>
  800a73:	f6 c1 03             	test   $0x3,%cl
  800a76:	75 0a                	jne    800a82 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a78:	c1 e9 02             	shr    $0x2,%ecx
  800a7b:	89 c7                	mov    %eax,%edi
  800a7d:	fc                   	cld    
  800a7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a80:	eb 05                	jmp    800a87 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a82:	89 c7                	mov    %eax,%edi
  800a84:	fc                   	cld    
  800a85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a8e:	ff 75 10             	pushl  0x10(%ebp)
  800a91:	ff 75 0c             	pushl  0xc(%ebp)
  800a94:	ff 75 08             	pushl  0x8(%ebp)
  800a97:	e8 87 ff ff ff       	call   800a23 <memmove>
}
  800a9c:	c9                   	leave  
  800a9d:	c3                   	ret    

00800a9e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa9:	89 c6                	mov    %eax,%esi
  800aab:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aae:	eb 1a                	jmp    800aca <memcmp+0x2c>
		if (*s1 != *s2)
  800ab0:	0f b6 08             	movzbl (%eax),%ecx
  800ab3:	0f b6 1a             	movzbl (%edx),%ebx
  800ab6:	38 d9                	cmp    %bl,%cl
  800ab8:	74 0a                	je     800ac4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aba:	0f b6 c1             	movzbl %cl,%eax
  800abd:	0f b6 db             	movzbl %bl,%ebx
  800ac0:	29 d8                	sub    %ebx,%eax
  800ac2:	eb 0f                	jmp    800ad3 <memcmp+0x35>
		s1++, s2++;
  800ac4:	83 c0 01             	add    $0x1,%eax
  800ac7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aca:	39 f0                	cmp    %esi,%eax
  800acc:	75 e2                	jne    800ab0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ace:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad3:	5b                   	pop    %ebx
  800ad4:	5e                   	pop    %esi
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	53                   	push   %ebx
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ade:	89 c1                	mov    %eax,%ecx
  800ae0:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae3:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae7:	eb 0a                	jmp    800af3 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae9:	0f b6 10             	movzbl (%eax),%edx
  800aec:	39 da                	cmp    %ebx,%edx
  800aee:	74 07                	je     800af7 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af0:	83 c0 01             	add    $0x1,%eax
  800af3:	39 c8                	cmp    %ecx,%eax
  800af5:	72 f2                	jb     800ae9 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af7:	5b                   	pop    %ebx
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b06:	eb 03                	jmp    800b0b <strtol+0x11>
		s++;
  800b08:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0b:	0f b6 01             	movzbl (%ecx),%eax
  800b0e:	3c 20                	cmp    $0x20,%al
  800b10:	74 f6                	je     800b08 <strtol+0xe>
  800b12:	3c 09                	cmp    $0x9,%al
  800b14:	74 f2                	je     800b08 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b16:	3c 2b                	cmp    $0x2b,%al
  800b18:	75 0a                	jne    800b24 <strtol+0x2a>
		s++;
  800b1a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
  800b22:	eb 11                	jmp    800b35 <strtol+0x3b>
  800b24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b29:	3c 2d                	cmp    $0x2d,%al
  800b2b:	75 08                	jne    800b35 <strtol+0x3b>
		s++, neg = 1;
  800b2d:	83 c1 01             	add    $0x1,%ecx
  800b30:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b35:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3b:	75 15                	jne    800b52 <strtol+0x58>
  800b3d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b40:	75 10                	jne    800b52 <strtol+0x58>
  800b42:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b46:	75 7c                	jne    800bc4 <strtol+0xca>
		s += 2, base = 16;
  800b48:	83 c1 02             	add    $0x2,%ecx
  800b4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b50:	eb 16                	jmp    800b68 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b52:	85 db                	test   %ebx,%ebx
  800b54:	75 12                	jne    800b68 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b56:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5e:	75 08                	jne    800b68 <strtol+0x6e>
		s++, base = 8;
  800b60:	83 c1 01             	add    $0x1,%ecx
  800b63:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b70:	0f b6 11             	movzbl (%ecx),%edx
  800b73:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b76:	89 f3                	mov    %esi,%ebx
  800b78:	80 fb 09             	cmp    $0x9,%bl
  800b7b:	77 08                	ja     800b85 <strtol+0x8b>
			dig = *s - '0';
  800b7d:	0f be d2             	movsbl %dl,%edx
  800b80:	83 ea 30             	sub    $0x30,%edx
  800b83:	eb 22                	jmp    800ba7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b85:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b88:	89 f3                	mov    %esi,%ebx
  800b8a:	80 fb 19             	cmp    $0x19,%bl
  800b8d:	77 08                	ja     800b97 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	83 ea 57             	sub    $0x57,%edx
  800b95:	eb 10                	jmp    800ba7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b97:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 19             	cmp    $0x19,%bl
  800b9f:	77 16                	ja     800bb7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800baa:	7d 0b                	jge    800bb7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bac:	83 c1 01             	add    $0x1,%ecx
  800baf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb5:	eb b9                	jmp    800b70 <strtol+0x76>

	if (endptr)
  800bb7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbb:	74 0d                	je     800bca <strtol+0xd0>
		*endptr = (char *) s;
  800bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc0:	89 0e                	mov    %ecx,(%esi)
  800bc2:	eb 06                	jmp    800bca <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc4:	85 db                	test   %ebx,%ebx
  800bc6:	74 98                	je     800b60 <strtol+0x66>
  800bc8:	eb 9e                	jmp    800b68 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bca:	89 c2                	mov    %eax,%edx
  800bcc:	f7 da                	neg    %edx
  800bce:	85 ff                	test   %edi,%edi
  800bd0:	0f 45 c2             	cmovne %edx,%eax
}
  800bd3:	5b                   	pop    %ebx
  800bd4:	5e                   	pop    %esi
  800bd5:	5f                   	pop    %edi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	89 c3                	mov    %eax,%ebx
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	89 c6                	mov    %eax,%esi
  800bef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c23:	b8 03 00 00 00       	mov    $0x3,%eax
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	89 cb                	mov    %ecx,%ebx
  800c2d:	89 cf                	mov    %ecx,%edi
  800c2f:	89 ce                	mov    %ecx,%esi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 17                	jle    800c4e <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	83 ec 0c             	sub    $0xc,%esp
  800c3a:	50                   	push   %eax
  800c3b:	6a 03                	push   $0x3
  800c3d:	68 e4 13 80 00       	push   $0x8013e4
  800c42:	6a 23                	push   $0x23
  800c44:	68 01 14 80 00       	push   $0x801401
  800c49:	e8 e5 f5 ff ff       	call   800233 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c61:	b8 02 00 00 00       	mov    $0x2,%eax
  800c66:	89 d1                	mov    %edx,%ecx
  800c68:	89 d3                	mov    %edx,%ebx
  800c6a:	89 d7                	mov    %edx,%edi
  800c6c:	89 d6                	mov    %edx,%esi
  800c6e:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <sys_yield>:

void
sys_yield(void)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8f:	5b                   	pop    %ebx
  800c90:	5e                   	pop    %esi
  800c91:	5f                   	pop    %edi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9d:	be 00 00 00 00       	mov    $0x0,%esi
  800ca2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb0:	89 f7                	mov    %esi,%edi
  800cb2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7e 17                	jle    800ccf <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 04                	push   $0x4
  800cbe:	68 e4 13 80 00       	push   $0x8013e4
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 01 14 80 00       	push   $0x801401
  800cca:	e8 64 f5 ff ff       	call   800233 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7e 17                	jle    800d11 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	50                   	push   %eax
  800cfe:	6a 05                	push   $0x5
  800d00:	68 e4 13 80 00       	push   $0x8013e4
  800d05:	6a 23                	push   $0x23
  800d07:	68 01 14 80 00       	push   $0x801401
  800d0c:	e8 22 f5 ff ff       	call   800233 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7e 17                	jle    800d53 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 06                	push   $0x6
  800d42:	68 e4 13 80 00       	push   $0x8013e4
  800d47:	6a 23                	push   $0x23
  800d49:	68 01 14 80 00       	push   $0x801401
  800d4e:	e8 e0 f4 ff ff       	call   800233 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d69:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d71:	8b 55 08             	mov    0x8(%ebp),%edx
  800d74:	89 df                	mov    %ebx,%edi
  800d76:	89 de                	mov    %ebx,%esi
  800d78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	7e 17                	jle    800d95 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7e:	83 ec 0c             	sub    $0xc,%esp
  800d81:	50                   	push   %eax
  800d82:	6a 08                	push   $0x8
  800d84:	68 e4 13 80 00       	push   $0x8013e4
  800d89:	6a 23                	push   $0x23
  800d8b:	68 01 14 80 00       	push   $0x801401
  800d90:	e8 9e f4 ff ff       	call   800233 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	b8 09 00 00 00       	mov    $0x9,%eax
  800db0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7e 17                	jle    800dd7 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc0:	83 ec 0c             	sub    $0xc,%esp
  800dc3:	50                   	push   %eax
  800dc4:	6a 09                	push   $0x9
  800dc6:	68 e4 13 80 00       	push   $0x8013e4
  800dcb:	6a 23                	push   $0x23
  800dcd:	68 01 14 80 00       	push   $0x801401
  800dd2:	e8 5c f4 ff ff       	call   800233 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	be 00 00 00 00       	mov    $0x0,%esi
  800dea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfb:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e10:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e15:	8b 55 08             	mov    0x8(%ebp),%edx
  800e18:	89 cb                	mov    %ecx,%ebx
  800e1a:	89 cf                	mov    %ecx,%edi
  800e1c:	89 ce                	mov    %ecx,%esi
  800e1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 17                	jle    800e3b <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	6a 0c                	push   $0xc
  800e2a:	68 e4 13 80 00       	push   $0x8013e4
  800e2f:	6a 23                	push   $0x23
  800e31:	68 01 14 80 00       	push   $0x801401
  800e36:	e8 f8 f3 ff ff       	call   800233 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    
  800e43:	66 90                	xchg   %ax,%ax
  800e45:	66 90                	xchg   %ax,%ax
  800e47:	66 90                	xchg   %ax,%ax
  800e49:	66 90                	xchg   %ax,%ax
  800e4b:	66 90                	xchg   %ax,%ax
  800e4d:	66 90                	xchg   %ax,%ax
  800e4f:	90                   	nop

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e67:	85 f6                	test   %esi,%esi
  800e69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e6d:	89 ca                	mov    %ecx,%edx
  800e6f:	89 f8                	mov    %edi,%eax
  800e71:	75 3d                	jne    800eb0 <__udivdi3+0x60>
  800e73:	39 cf                	cmp    %ecx,%edi
  800e75:	0f 87 c5 00 00 00    	ja     800f40 <__udivdi3+0xf0>
  800e7b:	85 ff                	test   %edi,%edi
  800e7d:	89 fd                	mov    %edi,%ebp
  800e7f:	75 0b                	jne    800e8c <__udivdi3+0x3c>
  800e81:	b8 01 00 00 00       	mov    $0x1,%eax
  800e86:	31 d2                	xor    %edx,%edx
  800e88:	f7 f7                	div    %edi
  800e8a:	89 c5                	mov    %eax,%ebp
  800e8c:	89 c8                	mov    %ecx,%eax
  800e8e:	31 d2                	xor    %edx,%edx
  800e90:	f7 f5                	div    %ebp
  800e92:	89 c1                	mov    %eax,%ecx
  800e94:	89 d8                	mov    %ebx,%eax
  800e96:	89 cf                	mov    %ecx,%edi
  800e98:	f7 f5                	div    %ebp
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 d8                	mov    %ebx,%eax
  800e9e:	89 fa                	mov    %edi,%edx
  800ea0:	83 c4 1c             	add    $0x1c,%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    
  800ea8:	90                   	nop
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	39 ce                	cmp    %ecx,%esi
  800eb2:	77 74                	ja     800f28 <__udivdi3+0xd8>
  800eb4:	0f bd fe             	bsr    %esi,%edi
  800eb7:	83 f7 1f             	xor    $0x1f,%edi
  800eba:	0f 84 98 00 00 00    	je     800f58 <__udivdi3+0x108>
  800ec0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	89 c5                	mov    %eax,%ebp
  800ec9:	29 fb                	sub    %edi,%ebx
  800ecb:	d3 e6                	shl    %cl,%esi
  800ecd:	89 d9                	mov    %ebx,%ecx
  800ecf:	d3 ed                	shr    %cl,%ebp
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e0                	shl    %cl,%eax
  800ed5:	09 ee                	or     %ebp,%esi
  800ed7:	89 d9                	mov    %ebx,%ecx
  800ed9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800edd:	89 d5                	mov    %edx,%ebp
  800edf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ee3:	d3 ed                	shr    %cl,%ebp
  800ee5:	89 f9                	mov    %edi,%ecx
  800ee7:	d3 e2                	shl    %cl,%edx
  800ee9:	89 d9                	mov    %ebx,%ecx
  800eeb:	d3 e8                	shr    %cl,%eax
  800eed:	09 c2                	or     %eax,%edx
  800eef:	89 d0                	mov    %edx,%eax
  800ef1:	89 ea                	mov    %ebp,%edx
  800ef3:	f7 f6                	div    %esi
  800ef5:	89 d5                	mov    %edx,%ebp
  800ef7:	89 c3                	mov    %eax,%ebx
  800ef9:	f7 64 24 0c          	mull   0xc(%esp)
  800efd:	39 d5                	cmp    %edx,%ebp
  800eff:	72 10                	jb     800f11 <__udivdi3+0xc1>
  800f01:	8b 74 24 08          	mov    0x8(%esp),%esi
  800f05:	89 f9                	mov    %edi,%ecx
  800f07:	d3 e6                	shl    %cl,%esi
  800f09:	39 c6                	cmp    %eax,%esi
  800f0b:	73 07                	jae    800f14 <__udivdi3+0xc4>
  800f0d:	39 d5                	cmp    %edx,%ebp
  800f0f:	75 03                	jne    800f14 <__udivdi3+0xc4>
  800f11:	83 eb 01             	sub    $0x1,%ebx
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 d8                	mov    %ebx,%eax
  800f18:	89 fa                	mov    %edi,%edx
  800f1a:	83 c4 1c             	add    $0x1c,%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
  800f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f28:	31 ff                	xor    %edi,%edi
  800f2a:	31 db                	xor    %ebx,%ebx
  800f2c:	89 d8                	mov    %ebx,%eax
  800f2e:	89 fa                	mov    %edi,%edx
  800f30:	83 c4 1c             	add    $0x1c,%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
  800f38:	90                   	nop
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	89 d8                	mov    %ebx,%eax
  800f42:	f7 f7                	div    %edi
  800f44:	31 ff                	xor    %edi,%edi
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	89 d8                	mov    %ebx,%eax
  800f4a:	89 fa                	mov    %edi,%edx
  800f4c:	83 c4 1c             	add    $0x1c,%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5e                   	pop    %esi
  800f51:	5f                   	pop    %edi
  800f52:	5d                   	pop    %ebp
  800f53:	c3                   	ret    
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	39 ce                	cmp    %ecx,%esi
  800f5a:	72 0c                	jb     800f68 <__udivdi3+0x118>
  800f5c:	31 db                	xor    %ebx,%ebx
  800f5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f62:	0f 87 34 ff ff ff    	ja     800e9c <__udivdi3+0x4c>
  800f68:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f6d:	e9 2a ff ff ff       	jmp    800e9c <__udivdi3+0x4c>
  800f72:	66 90                	xchg   %ax,%ax
  800f74:	66 90                	xchg   %ax,%ax
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 1c             	sub    $0x1c,%esp
  800f87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f97:	85 d2                	test   %edx,%edx
  800f99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 f3                	mov    %esi,%ebx
  800fa3:	89 3c 24             	mov    %edi,(%esp)
  800fa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800faa:	75 1c                	jne    800fc8 <__umoddi3+0x48>
  800fac:	39 f7                	cmp    %esi,%edi
  800fae:	76 50                	jbe    801000 <__umoddi3+0x80>
  800fb0:	89 c8                	mov    %ecx,%eax
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	f7 f7                	div    %edi
  800fb6:	89 d0                	mov    %edx,%eax
  800fb8:	31 d2                	xor    %edx,%edx
  800fba:	83 c4 1c             	add    $0x1c,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5f                   	pop    %edi
  800fc0:	5d                   	pop    %ebp
  800fc1:	c3                   	ret    
  800fc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc8:	39 f2                	cmp    %esi,%edx
  800fca:	89 d0                	mov    %edx,%eax
  800fcc:	77 52                	ja     801020 <__umoddi3+0xa0>
  800fce:	0f bd ea             	bsr    %edx,%ebp
  800fd1:	83 f5 1f             	xor    $0x1f,%ebp
  800fd4:	75 5a                	jne    801030 <__umoddi3+0xb0>
  800fd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800fda:	0f 82 e0 00 00 00    	jb     8010c0 <__umoddi3+0x140>
  800fe0:	39 0c 24             	cmp    %ecx,(%esp)
  800fe3:	0f 86 d7 00 00 00    	jbe    8010c0 <__umoddi3+0x140>
  800fe9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fed:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ff1:	83 c4 1c             	add    $0x1c,%esp
  800ff4:	5b                   	pop    %ebx
  800ff5:	5e                   	pop    %esi
  800ff6:	5f                   	pop    %edi
  800ff7:	5d                   	pop    %ebp
  800ff8:	c3                   	ret    
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	85 ff                	test   %edi,%edi
  801002:	89 fd                	mov    %edi,%ebp
  801004:	75 0b                	jne    801011 <__umoddi3+0x91>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f7                	div    %edi
  80100f:	89 c5                	mov    %eax,%ebp
  801011:	89 f0                	mov    %esi,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f5                	div    %ebp
  801017:	89 c8                	mov    %ecx,%eax
  801019:	f7 f5                	div    %ebp
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	eb 99                	jmp    800fb8 <__umoddi3+0x38>
  80101f:	90                   	nop
  801020:	89 c8                	mov    %ecx,%eax
  801022:	89 f2                	mov    %esi,%edx
  801024:	83 c4 1c             	add    $0x1c,%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5f                   	pop    %edi
  80102a:	5d                   	pop    %ebp
  80102b:	c3                   	ret    
  80102c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801030:	8b 34 24             	mov    (%esp),%esi
  801033:	bf 20 00 00 00       	mov    $0x20,%edi
  801038:	89 e9                	mov    %ebp,%ecx
  80103a:	29 ef                	sub    %ebp,%edi
  80103c:	d3 e0                	shl    %cl,%eax
  80103e:	89 f9                	mov    %edi,%ecx
  801040:	89 f2                	mov    %esi,%edx
  801042:	d3 ea                	shr    %cl,%edx
  801044:	89 e9                	mov    %ebp,%ecx
  801046:	09 c2                	or     %eax,%edx
  801048:	89 d8                	mov    %ebx,%eax
  80104a:	89 14 24             	mov    %edx,(%esp)
  80104d:	89 f2                	mov    %esi,%edx
  80104f:	d3 e2                	shl    %cl,%edx
  801051:	89 f9                	mov    %edi,%ecx
  801053:	89 54 24 04          	mov    %edx,0x4(%esp)
  801057:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80105b:	d3 e8                	shr    %cl,%eax
  80105d:	89 e9                	mov    %ebp,%ecx
  80105f:	89 c6                	mov    %eax,%esi
  801061:	d3 e3                	shl    %cl,%ebx
  801063:	89 f9                	mov    %edi,%ecx
  801065:	89 d0                	mov    %edx,%eax
  801067:	d3 e8                	shr    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	09 d8                	or     %ebx,%eax
  80106d:	89 d3                	mov    %edx,%ebx
  80106f:	89 f2                	mov    %esi,%edx
  801071:	f7 34 24             	divl   (%esp)
  801074:	89 d6                	mov    %edx,%esi
  801076:	d3 e3                	shl    %cl,%ebx
  801078:	f7 64 24 04          	mull   0x4(%esp)
  80107c:	39 d6                	cmp    %edx,%esi
  80107e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801082:	89 d1                	mov    %edx,%ecx
  801084:	89 c3                	mov    %eax,%ebx
  801086:	72 08                	jb     801090 <__umoddi3+0x110>
  801088:	75 11                	jne    80109b <__umoddi3+0x11b>
  80108a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80108e:	73 0b                	jae    80109b <__umoddi3+0x11b>
  801090:	2b 44 24 04          	sub    0x4(%esp),%eax
  801094:	1b 14 24             	sbb    (%esp),%edx
  801097:	89 d1                	mov    %edx,%ecx
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80109f:	29 da                	sub    %ebx,%edx
  8010a1:	19 ce                	sbb    %ecx,%esi
  8010a3:	89 f9                	mov    %edi,%ecx
  8010a5:	89 f0                	mov    %esi,%eax
  8010a7:	d3 e0                	shl    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	d3 ea                	shr    %cl,%edx
  8010ad:	89 e9                	mov    %ebp,%ecx
  8010af:	d3 ee                	shr    %cl,%esi
  8010b1:	09 d0                	or     %edx,%eax
  8010b3:	89 f2                	mov    %esi,%edx
  8010b5:	83 c4 1c             	add    $0x1c,%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    
  8010bd:	8d 76 00             	lea    0x0(%esi),%esi
  8010c0:	29 f9                	sub    %edi,%ecx
  8010c2:	19 d6                	sbb    %edx,%esi
  8010c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010cc:	e9 18 ff ff ff       	jmp    800fe9 <__umoddi3+0x69>
