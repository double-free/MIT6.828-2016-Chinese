
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 2b 0b 00 00       	call   800b68 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 06 0e 00 00       	call   800e4f <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 26 0b 00 00       	call   800b87 <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 fd 0a 00 00       	call   800b87 <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 20 80 00       	mov    0x802004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 20 80 00       	mov    %eax,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 20 80 00       	mov    0x802004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 60 13 80 00       	push   $0x801360
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 88 13 80 00       	push   $0x801388
  8000c4:	e8 7c 00 00 00       	call   800145 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 20 80 00       	mov    0x802008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 9b 13 80 00       	push   $0x80139b
  8000de:	e8 3b 01 00 00       	call   80021e <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 6b 0a 00 00       	call   800b68 <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800139:	6a 00                	push   $0x0
  80013b:	e8 e7 09 00 00       	call   800b27 <sys_env_destroy>
}
  800140:	83 c4 10             	add    $0x10,%esp
  800143:	c9                   	leave  
  800144:	c3                   	ret    

00800145 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800153:	e8 10 0a 00 00       	call   800b68 <sys_getenvid>
  800158:	83 ec 0c             	sub    $0xc,%esp
  80015b:	ff 75 0c             	pushl  0xc(%ebp)
  80015e:	ff 75 08             	pushl  0x8(%ebp)
  800161:	56                   	push   %esi
  800162:	50                   	push   %eax
  800163:	68 c4 13 80 00       	push   $0x8013c4
  800168:	e8 b1 00 00 00       	call   80021e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016d:	83 c4 18             	add    $0x18,%esp
  800170:	53                   	push   %ebx
  800171:	ff 75 10             	pushl  0x10(%ebp)
  800174:	e8 54 00 00 00       	call   8001cd <vcprintf>
	cprintf("\n");
  800179:	c7 04 24 b7 13 80 00 	movl   $0x8013b7,(%esp)
  800180:	e8 99 00 00 00       	call   80021e <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800188:	cc                   	int3   
  800189:	eb fd                	jmp    800188 <_panic+0x43>

0080018b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	53                   	push   %ebx
  80018f:	83 ec 04             	sub    $0x4,%esp
  800192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800195:	8b 13                	mov    (%ebx),%edx
  800197:	8d 42 01             	lea    0x1(%edx),%eax
  80019a:	89 03                	mov    %eax,(%ebx)
  80019c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a8:	75 1a                	jne    8001c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001aa:	83 ec 08             	sub    $0x8,%esp
  8001ad:	68 ff 00 00 00       	push   $0xff
  8001b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b5:	50                   	push   %eax
  8001b6:	e8 2f 09 00 00       	call   800aea <sys_cputs>
		b->idx = 0;
  8001bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001dd:	00 00 00 
	b.cnt = 0;
  8001e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ea:	ff 75 0c             	pushl  0xc(%ebp)
  8001ed:	ff 75 08             	pushl  0x8(%ebp)
  8001f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f6:	50                   	push   %eax
  8001f7:	68 8b 01 80 00       	push   $0x80018b
  8001fc:	e8 54 01 00 00       	call   800355 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800201:	83 c4 08             	add    $0x8,%esp
  800204:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800210:	50                   	push   %eax
  800211:	e8 d4 08 00 00       	call   800aea <sys_cputs>

	return b.cnt;
}
  800216:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800224:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800227:	50                   	push   %eax
  800228:	ff 75 08             	pushl  0x8(%ebp)
  80022b:	e8 9d ff ff ff       	call   8001cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	57                   	push   %edi
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 1c             	sub    $0x1c,%esp
  80023b:	89 c7                	mov    %eax,%edi
  80023d:	89 d6                	mov    %edx,%esi
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
  800245:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800248:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800253:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800256:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800259:	39 d3                	cmp    %edx,%ebx
  80025b:	72 05                	jb     800262 <printnum+0x30>
  80025d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800260:	77 45                	ja     8002a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	8b 45 14             	mov    0x14(%ebp),%eax
  80026b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026e:	53                   	push   %ebx
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	ff 75 e4             	pushl  -0x1c(%ebp)
  800278:	ff 75 e0             	pushl  -0x20(%ebp)
  80027b:	ff 75 dc             	pushl  -0x24(%ebp)
  80027e:	ff 75 d8             	pushl  -0x28(%ebp)
  800281:	e8 3a 0e 00 00       	call   8010c0 <__udivdi3>
  800286:	83 c4 18             	add    $0x18,%esp
  800289:	52                   	push   %edx
  80028a:	50                   	push   %eax
  80028b:	89 f2                	mov    %esi,%edx
  80028d:	89 f8                	mov    %edi,%eax
  80028f:	e8 9e ff ff ff       	call   800232 <printnum>
  800294:	83 c4 20             	add    $0x20,%esp
  800297:	eb 18                	jmp    8002b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	56                   	push   %esi
  80029d:	ff 75 18             	pushl  0x18(%ebp)
  8002a0:	ff d7                	call   *%edi
  8002a2:	83 c4 10             	add    $0x10,%esp
  8002a5:	eb 03                	jmp    8002aa <printnum+0x78>
  8002a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	85 db                	test   %ebx,%ebx
  8002af:	7f e8                	jg     800299 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	83 ec 04             	sub    $0x4,%esp
  8002b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8002be:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	e8 27 0f 00 00       	call   8011f0 <__umoddi3>
  8002c9:	83 c4 14             	add    $0x14,%esp
  8002cc:	0f be 80 e7 13 80 00 	movsbl 0x8013e7(%eax),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff d7                	call   *%edi
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e4:	83 fa 01             	cmp    $0x1,%edx
  8002e7:	7e 0e                	jle    8002f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	8b 52 04             	mov    0x4(%edx),%edx
  8002f5:	eb 22                	jmp    800319 <getuint+0x38>
	else if (lflag)
  8002f7:	85 d2                	test   %edx,%edx
  8002f9:	74 10                	je     80030b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	ba 00 00 00 00       	mov    $0x0,%edx
  800309:	eb 0e                	jmp    800319 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800321:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800325:	8b 10                	mov    (%eax),%edx
  800327:	3b 50 04             	cmp    0x4(%eax),%edx
  80032a:	73 0a                	jae    800336 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032f:	89 08                	mov    %ecx,(%eax)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	88 02                	mov    %al,(%edx)
}
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800341:	50                   	push   %eax
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	ff 75 0c             	pushl  0xc(%ebp)
  800348:	ff 75 08             	pushl  0x8(%ebp)
  80034b:	e8 05 00 00 00       	call   800355 <vprintfmt>
	va_end(ap);
}
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	c9                   	leave  
  800354:	c3                   	ret    

00800355 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 2c             	sub    $0x2c,%esp
  80035e:	8b 75 08             	mov    0x8(%ebp),%esi
  800361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800364:	8b 7d 10             	mov    0x10(%ebp),%edi
  800367:	eb 12                	jmp    80037b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800369:	85 c0                	test   %eax,%eax
  80036b:	0f 84 89 03 00 00    	je     8006fa <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	53                   	push   %ebx
  800375:	50                   	push   %eax
  800376:	ff d6                	call   *%esi
  800378:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80037b:	83 c7 01             	add    $0x1,%edi
  80037e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800382:	83 f8 25             	cmp    $0x25,%eax
  800385:	75 e2                	jne    800369 <vprintfmt+0x14>
  800387:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80038b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800392:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800399:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a5:	eb 07                	jmp    8003ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8d 47 01             	lea    0x1(%edi),%eax
  8003b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b4:	0f b6 07             	movzbl (%edi),%eax
  8003b7:	0f b6 c8             	movzbl %al,%ecx
  8003ba:	83 e8 23             	sub    $0x23,%eax
  8003bd:	3c 55                	cmp    $0x55,%al
  8003bf:	0f 87 1a 03 00 00    	ja     8006df <vprintfmt+0x38a>
  8003c5:	0f b6 c0             	movzbl %al,%eax
  8003c8:	ff 24 85 a0 14 80 00 	jmp    *0x8014a0(,%eax,4)
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d6:	eb d6                	jmp    8003ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ea:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ed:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003f0:	83 fa 09             	cmp    $0x9,%edx
  8003f3:	77 39                	ja     80042e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f8:	eb e9                	jmp    8003e3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 48 04             	lea    0x4(%eax),%ecx
  800400:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800403:	8b 00                	mov    (%eax),%eax
  800405:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040b:	eb 27                	jmp    800434 <vprintfmt+0xdf>
  80040d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800410:	85 c0                	test   %eax,%eax
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	0f 49 c8             	cmovns %eax,%ecx
  80041a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800420:	eb 8c                	jmp    8003ae <vprintfmt+0x59>
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800425:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042c:	eb 80                	jmp    8003ae <vprintfmt+0x59>
  80042e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800431:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800434:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800438:	0f 89 70 ff ff ff    	jns    8003ae <vprintfmt+0x59>
				width = precision, precision = -1;
  80043e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800441:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800444:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044b:	e9 5e ff ff ff       	jmp    8003ae <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800450:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800456:	e9 53 ff ff ff       	jmp    8003ae <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 50 04             	lea    0x4(%eax),%edx
  800461:	89 55 14             	mov    %edx,0x14(%ebp)
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	53                   	push   %ebx
  800468:	ff 30                	pushl  (%eax)
  80046a:	ff d6                	call   *%esi
			break;
  80046c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800472:	e9 04 ff ff ff       	jmp    80037b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	8b 00                	mov    (%eax),%eax
  800482:	99                   	cltd   
  800483:	31 d0                	xor    %edx,%eax
  800485:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800487:	83 f8 08             	cmp    $0x8,%eax
  80048a:	7f 0b                	jg     800497 <vprintfmt+0x142>
  80048c:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	75 18                	jne    8004af <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800497:	50                   	push   %eax
  800498:	68 ff 13 80 00       	push   $0x8013ff
  80049d:	53                   	push   %ebx
  80049e:	56                   	push   %esi
  80049f:	e8 94 fe ff ff       	call   800338 <printfmt>
  8004a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004aa:	e9 cc fe ff ff       	jmp    80037b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004af:	52                   	push   %edx
  8004b0:	68 08 14 80 00       	push   $0x801408
  8004b5:	53                   	push   %ebx
  8004b6:	56                   	push   %esi
  8004b7:	e8 7c fe ff ff       	call   800338 <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c2:	e9 b4 fe ff ff       	jmp    80037b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 50 04             	lea    0x4(%eax),%edx
  8004cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	b8 f8 13 80 00       	mov    $0x8013f8,%eax
  8004d9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004dc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e0:	0f 8e 94 00 00 00    	jle    80057a <vprintfmt+0x225>
  8004e6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ea:	0f 84 98 00 00 00    	je     800588 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f6:	57                   	push   %edi
  8004f7:	e8 86 02 00 00       	call   800782 <strnlen>
  8004fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ff:	29 c1                	sub    %eax,%ecx
  800501:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800504:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800507:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80050b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800511:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	eb 0f                	jmp    800524 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	ff 75 e0             	pushl  -0x20(%ebp)
  80051c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051e:	83 ef 01             	sub    $0x1,%edi
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	85 ff                	test   %edi,%edi
  800526:	7f ed                	jg     800515 <vprintfmt+0x1c0>
  800528:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80052b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052e:	85 c9                	test   %ecx,%ecx
  800530:	b8 00 00 00 00       	mov    $0x0,%eax
  800535:	0f 49 c1             	cmovns %ecx,%eax
  800538:	29 c1                	sub    %eax,%ecx
  80053a:	89 75 08             	mov    %esi,0x8(%ebp)
  80053d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800540:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800543:	89 cb                	mov    %ecx,%ebx
  800545:	eb 4d                	jmp    800594 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800547:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80054b:	74 1b                	je     800568 <vprintfmt+0x213>
  80054d:	0f be c0             	movsbl %al,%eax
  800550:	83 e8 20             	sub    $0x20,%eax
  800553:	83 f8 5e             	cmp    $0x5e,%eax
  800556:	76 10                	jbe    800568 <vprintfmt+0x213>
					putch('?', putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	ff 75 0c             	pushl  0xc(%ebp)
  80055e:	6a 3f                	push   $0x3f
  800560:	ff 55 08             	call   *0x8(%ebp)
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	eb 0d                	jmp    800575 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800568:	83 ec 08             	sub    $0x8,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	52                   	push   %edx
  80056f:	ff 55 08             	call   *0x8(%ebp)
  800572:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800575:	83 eb 01             	sub    $0x1,%ebx
  800578:	eb 1a                	jmp    800594 <vprintfmt+0x23f>
  80057a:	89 75 08             	mov    %esi,0x8(%ebp)
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800580:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800583:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800586:	eb 0c                	jmp    800594 <vprintfmt+0x23f>
  800588:	89 75 08             	mov    %esi,0x8(%ebp)
  80058b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800591:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800594:	83 c7 01             	add    $0x1,%edi
  800597:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80059b:	0f be d0             	movsbl %al,%edx
  80059e:	85 d2                	test   %edx,%edx
  8005a0:	74 23                	je     8005c5 <vprintfmt+0x270>
  8005a2:	85 f6                	test   %esi,%esi
  8005a4:	78 a1                	js     800547 <vprintfmt+0x1f2>
  8005a6:	83 ee 01             	sub    $0x1,%esi
  8005a9:	79 9c                	jns    800547 <vprintfmt+0x1f2>
  8005ab:	89 df                	mov    %ebx,%edi
  8005ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b3:	eb 18                	jmp    8005cd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b5:	83 ec 08             	sub    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	6a 20                	push   $0x20
  8005bb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bd:	83 ef 01             	sub    $0x1,%edi
  8005c0:	83 c4 10             	add    $0x10,%esp
  8005c3:	eb 08                	jmp    8005cd <vprintfmt+0x278>
  8005c5:	89 df                	mov    %ebx,%edi
  8005c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cd:	85 ff                	test   %edi,%edi
  8005cf:	7f e4                	jg     8005b5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d4:	e9 a2 fd ff ff       	jmp    80037b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d9:	83 fa 01             	cmp    $0x1,%edx
  8005dc:	7e 16                	jle    8005f4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 08             	lea    0x8(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	8b 50 04             	mov    0x4(%eax),%edx
  8005ea:	8b 00                	mov    (%eax),%eax
  8005ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f2:	eb 32                	jmp    800626 <vprintfmt+0x2d1>
	else if (lflag)
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	74 18                	je     800610 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 04             	lea    0x4(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 00                	mov    (%eax),%eax
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	89 c1                	mov    %eax,%ecx
  800608:	c1 f9 1f             	sar    $0x1f,%ecx
  80060b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060e:	eb 16                	jmp    800626 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061e:	89 c1                	mov    %eax,%ecx
  800620:	c1 f9 1f             	sar    $0x1f,%ecx
  800623:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800626:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800629:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800631:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800635:	79 74                	jns    8006ab <vprintfmt+0x356>
				putch('-', putdat);
  800637:	83 ec 08             	sub    $0x8,%esp
  80063a:	53                   	push   %ebx
  80063b:	6a 2d                	push   $0x2d
  80063d:	ff d6                	call   *%esi
				num = -(long long) num;
  80063f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800642:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800645:	f7 d8                	neg    %eax
  800647:	83 d2 00             	adc    $0x0,%edx
  80064a:	f7 da                	neg    %edx
  80064c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800654:	eb 55                	jmp    8006ab <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 83 fc ff ff       	call   8002e1 <getuint>
			base = 10;
  80065e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800663:	eb 46                	jmp    8006ab <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 74 fc ff ff       	call   8002e1 <getuint>
			base = 8;
  80066d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800672:	eb 37                	jmp    8006ab <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 30                	push   $0x30
  80067a:	ff d6                	call   *%esi
			putch('x', putdat);
  80067c:	83 c4 08             	add    $0x8,%esp
  80067f:	53                   	push   %ebx
  800680:	6a 78                	push   $0x78
  800682:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800694:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800697:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80069c:	eb 0d                	jmp    8006ab <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069e:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a1:	e8 3b fc ff ff       	call   8002e1 <getuint>
			base = 16;
  8006a6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006ab:	83 ec 0c             	sub    $0xc,%esp
  8006ae:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006b2:	57                   	push   %edi
  8006b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b6:	51                   	push   %ecx
  8006b7:	52                   	push   %edx
  8006b8:	50                   	push   %eax
  8006b9:	89 da                	mov    %ebx,%edx
  8006bb:	89 f0                	mov    %esi,%eax
  8006bd:	e8 70 fb ff ff       	call   800232 <printnum>
			break;
  8006c2:	83 c4 20             	add    $0x20,%esp
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c8:	e9 ae fc ff ff       	jmp    80037b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	51                   	push   %ecx
  8006d2:	ff d6                	call   *%esi
			break;
  8006d4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006da:	e9 9c fc ff ff       	jmp    80037b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 25                	push   $0x25
  8006e5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	eb 03                	jmp    8006ef <vprintfmt+0x39a>
  8006ec:	83 ef 01             	sub    $0x1,%edi
  8006ef:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006f3:	75 f7                	jne    8006ec <vprintfmt+0x397>
  8006f5:	e9 81 fc ff ff       	jmp    80037b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fd:	5b                   	pop    %ebx
  8006fe:	5e                   	pop    %esi
  8006ff:	5f                   	pop    %edi
  800700:	5d                   	pop    %ebp
  800701:	c3                   	ret    

00800702 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 18             	sub    $0x18,%esp
  800708:	8b 45 08             	mov    0x8(%ebp),%eax
  80070b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800711:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800715:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800718:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071f:	85 c0                	test   %eax,%eax
  800721:	74 26                	je     800749 <vsnprintf+0x47>
  800723:	85 d2                	test   %edx,%edx
  800725:	7e 22                	jle    800749 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800727:	ff 75 14             	pushl  0x14(%ebp)
  80072a:	ff 75 10             	pushl  0x10(%ebp)
  80072d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	68 1b 03 80 00       	push   $0x80031b
  800736:	e8 1a fc ff ff       	call   800355 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80073b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800741:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb 05                	jmp    80074e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800749:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80074e:	c9                   	leave  
  80074f:	c3                   	ret    

00800750 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800759:	50                   	push   %eax
  80075a:	ff 75 10             	pushl  0x10(%ebp)
  80075d:	ff 75 0c             	pushl  0xc(%ebp)
  800760:	ff 75 08             	pushl  0x8(%ebp)
  800763:	e8 9a ff ff ff       	call   800702 <vsnprintf>
	va_end(ap);

	return rc;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	b8 00 00 00 00       	mov    $0x0,%eax
  800775:	eb 03                	jmp    80077a <strlen+0x10>
		n++;
  800777:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80077a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077e:	75 f7                	jne    800777 <strlen+0xd>
		n++;
	return n;
}
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	ba 00 00 00 00       	mov    $0x0,%edx
  800790:	eb 03                	jmp    800795 <strnlen+0x13>
		n++;
  800792:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800795:	39 c2                	cmp    %eax,%edx
  800797:	74 08                	je     8007a1 <strnlen+0x1f>
  800799:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80079d:	75 f3                	jne    800792 <strnlen+0x10>
  80079f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	53                   	push   %ebx
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ad:	89 c2                	mov    %eax,%edx
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	83 c1 01             	add    $0x1,%ecx
  8007b5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007b9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007bc:	84 db                	test   %bl,%bl
  8007be:	75 ef                	jne    8007af <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c0:	5b                   	pop    %ebx
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ca:	53                   	push   %ebx
  8007cb:	e8 9a ff ff ff       	call   80076a <strlen>
  8007d0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d3:	ff 75 0c             	pushl  0xc(%ebp)
  8007d6:	01 d8                	add    %ebx,%eax
  8007d8:	50                   	push   %eax
  8007d9:	e8 c5 ff ff ff       	call   8007a3 <strcpy>
	return dst;
}
  8007de:	89 d8                	mov    %ebx,%eax
  8007e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	89 f3                	mov    %esi,%ebx
  8007f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f5:	89 f2                	mov    %esi,%edx
  8007f7:	eb 0f                	jmp    800808 <strncpy+0x23>
		*dst++ = *src;
  8007f9:	83 c2 01             	add    $0x1,%edx
  8007fc:	0f b6 01             	movzbl (%ecx),%eax
  8007ff:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800802:	80 39 01             	cmpb   $0x1,(%ecx)
  800805:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800808:	39 da                	cmp    %ebx,%edx
  80080a:	75 ed                	jne    8007f9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080c:	89 f0                	mov    %esi,%eax
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	8b 75 08             	mov    0x8(%ebp),%esi
  80081a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081d:	8b 55 10             	mov    0x10(%ebp),%edx
  800820:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800822:	85 d2                	test   %edx,%edx
  800824:	74 21                	je     800847 <strlcpy+0x35>
  800826:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082a:	89 f2                	mov    %esi,%edx
  80082c:	eb 09                	jmp    800837 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	83 c1 01             	add    $0x1,%ecx
  800834:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800837:	39 c2                	cmp    %eax,%edx
  800839:	74 09                	je     800844 <strlcpy+0x32>
  80083b:	0f b6 19             	movzbl (%ecx),%ebx
  80083e:	84 db                	test   %bl,%bl
  800840:	75 ec                	jne    80082e <strlcpy+0x1c>
  800842:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800844:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800847:	29 f0                	sub    %esi,%eax
}
  800849:	5b                   	pop    %ebx
  80084a:	5e                   	pop    %esi
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800853:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800856:	eb 06                	jmp    80085e <strcmp+0x11>
		p++, q++;
  800858:	83 c1 01             	add    $0x1,%ecx
  80085b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80085e:	0f b6 01             	movzbl (%ecx),%eax
  800861:	84 c0                	test   %al,%al
  800863:	74 04                	je     800869 <strcmp+0x1c>
  800865:	3a 02                	cmp    (%edx),%al
  800867:	74 ef                	je     800858 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800869:	0f b6 c0             	movzbl %al,%eax
  80086c:	0f b6 12             	movzbl (%edx),%edx
  80086f:	29 d0                	sub    %edx,%eax
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	53                   	push   %ebx
  800877:	8b 45 08             	mov    0x8(%ebp),%eax
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087d:	89 c3                	mov    %eax,%ebx
  80087f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800882:	eb 06                	jmp    80088a <strncmp+0x17>
		n--, p++, q++;
  800884:	83 c0 01             	add    $0x1,%eax
  800887:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80088a:	39 d8                	cmp    %ebx,%eax
  80088c:	74 15                	je     8008a3 <strncmp+0x30>
  80088e:	0f b6 08             	movzbl (%eax),%ecx
  800891:	84 c9                	test   %cl,%cl
  800893:	74 04                	je     800899 <strncmp+0x26>
  800895:	3a 0a                	cmp    (%edx),%cl
  800897:	74 eb                	je     800884 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800899:	0f b6 00             	movzbl (%eax),%eax
  80089c:	0f b6 12             	movzbl (%edx),%edx
  80089f:	29 d0                	sub    %edx,%eax
  8008a1:	eb 05                	jmp    8008a8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a8:	5b                   	pop    %ebx
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b5:	eb 07                	jmp    8008be <strchr+0x13>
		if (*s == c)
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	74 0f                	je     8008ca <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	0f b6 10             	movzbl (%eax),%edx
  8008c1:	84 d2                	test   %dl,%dl
  8008c3:	75 f2                	jne    8008b7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ca:	5d                   	pop    %ebp
  8008cb:	c3                   	ret    

008008cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d6:	eb 03                	jmp    8008db <strfind+0xf>
  8008d8:	83 c0 01             	add    $0x1,%eax
  8008db:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 04                	je     8008e6 <strfind+0x1a>
  8008e2:	84 d2                	test   %dl,%dl
  8008e4:	75 f2                	jne    8008d8 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 36                	je     80092e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fe:	75 28                	jne    800928 <memset+0x40>
  800900:	f6 c1 03             	test   $0x3,%cl
  800903:	75 23                	jne    800928 <memset+0x40>
		c &= 0xFF;
  800905:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800909:	89 d3                	mov    %edx,%ebx
  80090b:	c1 e3 08             	shl    $0x8,%ebx
  80090e:	89 d6                	mov    %edx,%esi
  800910:	c1 e6 18             	shl    $0x18,%esi
  800913:	89 d0                	mov    %edx,%eax
  800915:	c1 e0 10             	shl    $0x10,%eax
  800918:	09 f0                	or     %esi,%eax
  80091a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80091c:	89 d8                	mov    %ebx,%eax
  80091e:	09 d0                	or     %edx,%eax
  800920:	c1 e9 02             	shr    $0x2,%ecx
  800923:	fc                   	cld    
  800924:	f3 ab                	rep stos %eax,%es:(%edi)
  800926:	eb 06                	jmp    80092e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092b:	fc                   	cld    
  80092c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092e:	89 f8                	mov    %edi,%eax
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5f                   	pop    %edi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	57                   	push   %edi
  800939:	56                   	push   %esi
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
  80093d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800943:	39 c6                	cmp    %eax,%esi
  800945:	73 35                	jae    80097c <memmove+0x47>
  800947:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094a:	39 d0                	cmp    %edx,%eax
  80094c:	73 2e                	jae    80097c <memmove+0x47>
		s += n;
		d += n;
  80094e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800951:	89 d6                	mov    %edx,%esi
  800953:	09 fe                	or     %edi,%esi
  800955:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095b:	75 13                	jne    800970 <memmove+0x3b>
  80095d:	f6 c1 03             	test   $0x3,%cl
  800960:	75 0e                	jne    800970 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800962:	83 ef 04             	sub    $0x4,%edi
  800965:	8d 72 fc             	lea    -0x4(%edx),%esi
  800968:	c1 e9 02             	shr    $0x2,%ecx
  80096b:	fd                   	std    
  80096c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096e:	eb 09                	jmp    800979 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800970:	83 ef 01             	sub    $0x1,%edi
  800973:	8d 72 ff             	lea    -0x1(%edx),%esi
  800976:	fd                   	std    
  800977:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800979:	fc                   	cld    
  80097a:	eb 1d                	jmp    800999 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 f2                	mov    %esi,%edx
  80097e:	09 c2                	or     %eax,%edx
  800980:	f6 c2 03             	test   $0x3,%dl
  800983:	75 0f                	jne    800994 <memmove+0x5f>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 0a                	jne    800994 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80098a:	c1 e9 02             	shr    $0x2,%ecx
  80098d:	89 c7                	mov    %eax,%edi
  80098f:	fc                   	cld    
  800990:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800992:	eb 05                	jmp    800999 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800994:	89 c7                	mov    %eax,%edi
  800996:	fc                   	cld    
  800997:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800999:	5e                   	pop    %esi
  80099a:	5f                   	pop    %edi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a0:	ff 75 10             	pushl  0x10(%ebp)
  8009a3:	ff 75 0c             	pushl  0xc(%ebp)
  8009a6:	ff 75 08             	pushl  0x8(%ebp)
  8009a9:	e8 87 ff ff ff       	call   800935 <memmove>
}
  8009ae:	c9                   	leave  
  8009af:	c3                   	ret    

008009b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bb:	89 c6                	mov    %eax,%esi
  8009bd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c0:	eb 1a                	jmp    8009dc <memcmp+0x2c>
		if (*s1 != *s2)
  8009c2:	0f b6 08             	movzbl (%eax),%ecx
  8009c5:	0f b6 1a             	movzbl (%edx),%ebx
  8009c8:	38 d9                	cmp    %bl,%cl
  8009ca:	74 0a                	je     8009d6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009cc:	0f b6 c1             	movzbl %cl,%eax
  8009cf:	0f b6 db             	movzbl %bl,%ebx
  8009d2:	29 d8                	sub    %ebx,%eax
  8009d4:	eb 0f                	jmp    8009e5 <memcmp+0x35>
		s1++, s2++;
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dc:	39 f0                	cmp    %esi,%eax
  8009de:	75 e2                	jne    8009c2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f0:	89 c1                	mov    %eax,%ecx
  8009f2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f9:	eb 0a                	jmp    800a05 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fb:	0f b6 10             	movzbl (%eax),%edx
  8009fe:	39 da                	cmp    %ebx,%edx
  800a00:	74 07                	je     800a09 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a02:	83 c0 01             	add    $0x1,%eax
  800a05:	39 c8                	cmp    %ecx,%eax
  800a07:	72 f2                	jb     8009fb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	57                   	push   %edi
  800a10:	56                   	push   %esi
  800a11:	53                   	push   %ebx
  800a12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a18:	eb 03                	jmp    800a1d <strtol+0x11>
		s++;
  800a1a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a1d:	0f b6 01             	movzbl (%ecx),%eax
  800a20:	3c 20                	cmp    $0x20,%al
  800a22:	74 f6                	je     800a1a <strtol+0xe>
  800a24:	3c 09                	cmp    $0x9,%al
  800a26:	74 f2                	je     800a1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a28:	3c 2b                	cmp    $0x2b,%al
  800a2a:	75 0a                	jne    800a36 <strtol+0x2a>
		s++;
  800a2c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a34:	eb 11                	jmp    800a47 <strtol+0x3b>
  800a36:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a3b:	3c 2d                	cmp    $0x2d,%al
  800a3d:	75 08                	jne    800a47 <strtol+0x3b>
		s++, neg = 1;
  800a3f:	83 c1 01             	add    $0x1,%ecx
  800a42:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a47:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a4d:	75 15                	jne    800a64 <strtol+0x58>
  800a4f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a52:	75 10                	jne    800a64 <strtol+0x58>
  800a54:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a58:	75 7c                	jne    800ad6 <strtol+0xca>
		s += 2, base = 16;
  800a5a:	83 c1 02             	add    $0x2,%ecx
  800a5d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a62:	eb 16                	jmp    800a7a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a64:	85 db                	test   %ebx,%ebx
  800a66:	75 12                	jne    800a7a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a68:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a6d:	80 39 30             	cmpb   $0x30,(%ecx)
  800a70:	75 08                	jne    800a7a <strtol+0x6e>
		s++, base = 8;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a82:	0f b6 11             	movzbl (%ecx),%edx
  800a85:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 09             	cmp    $0x9,%bl
  800a8d:	77 08                	ja     800a97 <strtol+0x8b>
			dig = *s - '0';
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 30             	sub    $0x30,%edx
  800a95:	eb 22                	jmp    800ab9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 19             	cmp    $0x19,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 57             	sub    $0x57,%edx
  800aa7:	eb 10                	jmp    800ab9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800aa9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 16                	ja     800ac9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ab9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800abc:	7d 0b                	jge    800ac9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ac5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ac7:	eb b9                	jmp    800a82 <strtol+0x76>

	if (endptr)
  800ac9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acd:	74 0d                	je     800adc <strtol+0xd0>
		*endptr = (char *) s;
  800acf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad2:	89 0e                	mov    %ecx,(%esi)
  800ad4:	eb 06                	jmp    800adc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad6:	85 db                	test   %ebx,%ebx
  800ad8:	74 98                	je     800a72 <strtol+0x66>
  800ada:	eb 9e                	jmp    800a7a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800adc:	89 c2                	mov    %eax,%edx
  800ade:	f7 da                	neg    %edx
  800ae0:	85 ff                	test   %edi,%edi
  800ae2:	0f 45 c2             	cmovne %edx,%eax
}
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	57                   	push   %edi
  800aee:	56                   	push   %esi
  800aef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af0:	b8 00 00 00 00       	mov    $0x0,%eax
  800af5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af8:	8b 55 08             	mov    0x8(%ebp),%edx
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	89 c6                	mov    %eax,%esi
  800b01:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5f                   	pop    %edi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b13:	b8 01 00 00 00       	mov    $0x1,%eax
  800b18:	89 d1                	mov    %edx,%ecx
  800b1a:	89 d3                	mov    %edx,%ebx
  800b1c:	89 d7                	mov    %edx,%edi
  800b1e:	89 d6                	mov    %edx,%esi
  800b20:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b22:	5b                   	pop    %ebx
  800b23:	5e                   	pop    %esi
  800b24:	5f                   	pop    %edi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3d:	89 cb                	mov    %ecx,%ebx
  800b3f:	89 cf                	mov    %ecx,%edi
  800b41:	89 ce                	mov    %ecx,%esi
  800b43:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7e 17                	jle    800b60 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	6a 03                	push   $0x3
  800b4f:	68 24 16 80 00       	push   $0x801624
  800b54:	6a 23                	push   $0x23
  800b56:	68 41 16 80 00       	push   $0x801641
  800b5b:	e8 e5 f5 ff ff       	call   800145 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b63:	5b                   	pop    %ebx
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	57                   	push   %edi
  800b6c:	56                   	push   %esi
  800b6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 02 00 00 00       	mov    $0x2,%eax
  800b78:	89 d1                	mov    %edx,%ecx
  800b7a:	89 d3                	mov    %edx,%ebx
  800b7c:	89 d7                	mov    %edx,%edi
  800b7e:	89 d6                	mov    %edx,%esi
  800b80:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <sys_yield>:

void
sys_yield(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b97:	89 d1                	mov    %edx,%ecx
  800b99:	89 d3                	mov    %edx,%ebx
  800b9b:	89 d7                	mov    %edx,%edi
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800baf:	be 00 00 00 00       	mov    $0x0,%esi
  800bb4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc2:	89 f7                	mov    %esi,%edi
  800bc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7e 17                	jle    800be1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 04                	push   $0x4
  800bd0:	68 24 16 80 00       	push   $0x801624
  800bd5:	6a 23                	push   $0x23
  800bd7:	68 41 16 80 00       	push   $0x801641
  800bdc:	e8 64 f5 ff ff       	call   800145 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800be1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7e 17                	jle    800c23 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0c:	83 ec 0c             	sub    $0xc,%esp
  800c0f:	50                   	push   %eax
  800c10:	6a 05                	push   $0x5
  800c12:	68 24 16 80 00       	push   $0x801624
  800c17:	6a 23                	push   $0x23
  800c19:	68 41 16 80 00       	push   $0x801641
  800c1e:	e8 22 f5 ff ff       	call   800145 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c34:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c39:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	89 df                	mov    %ebx,%edi
  800c46:	89 de                	mov    %ebx,%esi
  800c48:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	7e 17                	jle    800c65 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4e:	83 ec 0c             	sub    $0xc,%esp
  800c51:	50                   	push   %eax
  800c52:	6a 06                	push   $0x6
  800c54:	68 24 16 80 00       	push   $0x801624
  800c59:	6a 23                	push   $0x23
  800c5b:	68 41 16 80 00       	push   $0x801641
  800c60:	e8 e0 f4 ff ff       	call   800145 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c68:	5b                   	pop    %ebx
  800c69:	5e                   	pop    %esi
  800c6a:	5f                   	pop    %edi
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	57                   	push   %edi
  800c71:	56                   	push   %esi
  800c72:	53                   	push   %ebx
  800c73:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c76:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	89 df                	mov    %ebx,%edi
  800c88:	89 de                	mov    %ebx,%esi
  800c8a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7e 17                	jle    800ca7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 08                	push   $0x8
  800c96:	68 24 16 80 00       	push   $0x801624
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 41 16 80 00       	push   $0x801641
  800ca2:	e8 9e f4 ff ff       	call   800145 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    

00800caf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	57                   	push   %edi
  800cb3:	56                   	push   %esi
  800cb4:	53                   	push   %ebx
  800cb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cbd:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	89 df                	mov    %ebx,%edi
  800cca:	89 de                	mov    %ebx,%esi
  800ccc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cce:	85 c0                	test   %eax,%eax
  800cd0:	7e 17                	jle    800ce9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd2:	83 ec 0c             	sub    $0xc,%esp
  800cd5:	50                   	push   %eax
  800cd6:	6a 09                	push   $0x9
  800cd8:	68 24 16 80 00       	push   $0x801624
  800cdd:	6a 23                	push   $0x23
  800cdf:	68 41 16 80 00       	push   $0x801641
  800ce4:	e8 5c f4 ff ff       	call   800145 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ce9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	be 00 00 00 00       	mov    $0x0,%esi
  800cfc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d0f:	5b                   	pop    %ebx
  800d10:	5e                   	pop    %esi
  800d11:	5f                   	pop    %edi
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	57                   	push   %edi
  800d18:	56                   	push   %esi
  800d19:	53                   	push   %ebx
  800d1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d22:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 cb                	mov    %ecx,%ebx
  800d2c:	89 cf                	mov    %ecx,%edi
  800d2e:	89 ce                	mov    %ecx,%esi
  800d30:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 0c                	push   $0xc
  800d3c:	68 24 16 80 00       	push   $0x801624
  800d41:	6a 23                	push   $0x23
  800d43:	68 41 16 80 00       	push   $0x801641
  800d48:	e8 f8 f3 ff ff       	call   800145 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800d5d:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0) {
  800d5f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800d63:	74 11                	je     800d76 <pgfault+0x21>
  800d65:	89 d8                	mov    %ebx,%eax
  800d67:	c1 e8 0c             	shr    $0xc,%eax
  800d6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800d71:	f6 c4 08             	test   $0x8,%ah
  800d74:	75 14                	jne    800d8a <pgfault+0x35>
		panic("pgfault: invalid user trap frame");
  800d76:	83 ec 04             	sub    $0x4,%esp
  800d79:	68 50 16 80 00       	push   $0x801650
  800d7e:	6a 1d                	push   $0x1d
  800d80:	68 bc 16 80 00       	push   $0x8016bc
  800d85:	e8 bb f3 ff ff       	call   800145 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// panic("pgfault not implemented");
        envid_t envid = sys_getenvid();
  800d8a:	e8 d9 fd ff ff       	call   800b68 <sys_getenvid>
  800d8f:	89 c6                	mov    %eax,%esi
        if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	6a 07                	push   $0x7
  800d96:	68 00 f0 7f 00       	push   $0x7ff000
  800d9b:	50                   	push   %eax
  800d9c:	e8 05 fe ff ff       	call   800ba6 <sys_page_alloc>
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	79 12                	jns    800dba <pgfault+0x65>
                panic("pgfault: page allocation failed %e", r);
  800da8:	50                   	push   %eax
  800da9:	68 74 16 80 00       	push   $0x801674
  800dae:	6a 29                	push   $0x29
  800db0:	68 bc 16 80 00       	push   $0x8016bc
  800db5:	e8 8b f3 ff ff       	call   800145 <_panic>

        addr = ROUNDDOWN(addr, PGSIZE);
  800dba:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        memmove(PFTEMP, addr, PGSIZE);
  800dc0:	83 ec 04             	sub    $0x4,%esp
  800dc3:	68 00 10 00 00       	push   $0x1000
  800dc8:	53                   	push   %ebx
  800dc9:	68 00 f0 7f 00       	push   $0x7ff000
  800dce:	e8 62 fb ff ff       	call   800935 <memmove>
        if ((r = sys_page_unmap(envid, addr)) < 0)
  800dd3:	83 c4 08             	add    $0x8,%esp
  800dd6:	53                   	push   %ebx
  800dd7:	56                   	push   %esi
  800dd8:	e8 4e fe ff ff       	call   800c2b <sys_page_unmap>
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	85 c0                	test   %eax,%eax
  800de2:	79 12                	jns    800df6 <pgfault+0xa1>
                panic("pgfault: page unmap failed %e", r);
  800de4:	50                   	push   %eax
  800de5:	68 c7 16 80 00       	push   $0x8016c7
  800dea:	6a 2e                	push   $0x2e
  800dec:	68 bc 16 80 00       	push   $0x8016bc
  800df1:	e8 4f f3 ff ff       	call   800145 <_panic>
        if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	6a 07                	push   $0x7
  800dfb:	53                   	push   %ebx
  800dfc:	56                   	push   %esi
  800dfd:	68 00 f0 7f 00       	push   $0x7ff000
  800e02:	56                   	push   %esi
  800e03:	e8 e1 fd ff ff       	call   800be9 <sys_page_map>
  800e08:	83 c4 20             	add    $0x20,%esp
  800e0b:	85 c0                	test   %eax,%eax
  800e0d:	79 12                	jns    800e21 <pgfault+0xcc>
                panic("pgfault: page map failed %e", r);
  800e0f:	50                   	push   %eax
  800e10:	68 e5 16 80 00       	push   $0x8016e5
  800e15:	6a 30                	push   $0x30
  800e17:	68 bc 16 80 00       	push   $0x8016bc
  800e1c:	e8 24 f3 ff ff       	call   800145 <_panic>
        if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e21:	83 ec 08             	sub    $0x8,%esp
  800e24:	68 00 f0 7f 00       	push   $0x7ff000
  800e29:	56                   	push   %esi
  800e2a:	e8 fc fd ff ff       	call   800c2b <sys_page_unmap>
  800e2f:	83 c4 10             	add    $0x10,%esp
  800e32:	85 c0                	test   %eax,%eax
  800e34:	79 12                	jns    800e48 <pgfault+0xf3>
                panic("pgfault: page unmap failed %e", r);
  800e36:	50                   	push   %eax
  800e37:	68 c7 16 80 00       	push   $0x8016c7
  800e3c:	6a 32                	push   $0x32
  800e3e:	68 bc 16 80 00       	push   $0x8016bc
  800e43:	e8 fd f2 ff ff       	call   800145 <_panic>
}
  800e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5d                   	pop    %ebp
  800e4e:	c3                   	ret    

00800e4f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// panic("fork not implemented");

	set_pgfault_handler(pgfault);
  800e58:	68 55 0d 80 00       	push   $0x800d55
  800e5d:	e8 ba 01 00 00       	call   80101c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800e62:	b8 07 00 00 00       	mov    $0x7,%eax
  800e67:	cd 30                	int    $0x30
  800e69:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t e_id = sys_exofork();
	if (e_id < 0) panic("fork: %e", e_id);
  800e6f:	83 c4 10             	add    $0x10,%esp
  800e72:	85 c0                	test   %eax,%eax
  800e74:	79 12                	jns    800e88 <fork+0x39>
  800e76:	50                   	push   %eax
  800e77:	68 01 17 80 00       	push   $0x801701
  800e7c:	6a 73                	push   $0x73
  800e7e:	68 bc 16 80 00       	push   $0x8016bc
  800e83:	e8 bd f2 ff ff       	call   800145 <_panic>
  800e88:	bf 00 00 80 00       	mov    $0x800000,%edi
	if (e_id == 0) {
  800e8d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e91:	75 21                	jne    800eb4 <fork+0x65>
		// child
		thisenv = &envs[ENVX(sys_getenvid())];
  800e93:	e8 d0 fc ff ff       	call   800b68 <sys_getenvid>
  800e98:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e9d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea5:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800eaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaf:	e9 46 01 00 00       	jmp    800ffa <fork+0x1ab>

	// parent
	// extern unsigned char end[];
	// for ((uint8_t *) addr = UTEXT; addr < end; addr += PGSIZE)
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800eb4:	89 f8                	mov    %edi,%eax
  800eb6:	c1 e8 16             	shr    $0x16,%eax
  800eb9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec0:	a8 01                	test   $0x1,%al
  800ec2:	0f 84 9a 00 00 00    	je     800f62 <fork+0x113>
  800ec8:	89 fb                	mov    %edi,%ebx
  800eca:	c1 eb 0c             	shr    $0xc,%ebx
  800ecd:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ed4:	a8 01                	test   $0x1,%al
  800ed6:	0f 84 86 00 00 00    	je     800f62 <fork+0x113>
	int r;

	// LAB 4: Your code here.
	// panic("duppage not implemented");

	envid_t this_env_id = sys_getenvid();
  800edc:	e8 87 fc ff ff       	call   800b68 <sys_getenvid>
  800ee1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800ee4:	89 de                	mov    %ebx,%esi
  800ee6:	c1 e6 0c             	shl    $0xc,%esi

	int perm = uvpt[pn] & 0xFFF;
  800ee9:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ef0:	89 c3                	mov    %eax,%ebx
  800ef2:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
	if ( (perm & PTE_W) || (perm & PTE_COW) ) {
  800ef8:	a9 02 08 00 00       	test   $0x802,%eax
  800efd:	74 0a                	je     800f09 <fork+0xba>
		// marked as COW and read-only
		perm |= PTE_COW;
		perm &= ~PTE_W;
  800eff:	25 fd 0f 00 00       	and    $0xffd,%eax
  800f04:	80 cc 08             	or     $0x8,%ah
  800f07:	89 c3                	mov    %eax,%ebx
	}
	// IMPORTANT: adjust permission to the syscall
	perm &= PTE_SYSCALL;
  800f09:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
	// cprintf("fromenvid = %x, toenvid = %x, dup page %d, addr = %08p, perm = %03x\n",this_env_id, envid, pn, va, perm);
	if((r = sys_page_map(this_env_id, va, envid, va, perm)) < 0) 
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	53                   	push   %ebx
  800f13:	56                   	push   %esi
  800f14:	ff 75 e0             	pushl  -0x20(%ebp)
  800f17:	56                   	push   %esi
  800f18:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f1b:	e8 c9 fc ff ff       	call   800be9 <sys_page_map>
  800f20:	83 c4 20             	add    $0x20,%esp
  800f23:	85 c0                	test   %eax,%eax
  800f25:	79 12                	jns    800f39 <fork+0xea>
		panic("duppage: %e",r);
  800f27:	50                   	push   %eax
  800f28:	68 0a 17 80 00       	push   $0x80170a
  800f2d:	6a 55                	push   $0x55
  800f2f:	68 bc 16 80 00       	push   $0x8016bc
  800f34:	e8 0c f2 ff ff       	call   800145 <_panic>
	if((r = sys_page_map(this_env_id, va, this_env_id, va, perm)) < 0) 
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	56                   	push   %esi
  800f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	56                   	push   %esi
  800f43:	50                   	push   %eax
  800f44:	e8 a0 fc ff ff       	call   800be9 <sys_page_map>
  800f49:	83 c4 20             	add    $0x20,%esp
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	79 12                	jns    800f62 <fork+0x113>
		panic("duppage: %e",r);
  800f50:	50                   	push   %eax
  800f51:	68 0a 17 80 00       	push   $0x80170a
  800f56:	6a 57                	push   $0x57
  800f58:	68 bc 16 80 00       	push   $0x8016bc
  800f5d:	e8 e3 f1 ff ff       	call   800145 <_panic>
	}

	// parent
	// extern unsigned char end[];
	// for ((uint8_t *) addr = UTEXT; addr < end; addr += PGSIZE)
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800f62:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800f68:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  800f6e:	0f 85 40 ff ff ff    	jne    800eb4 <fork+0x65>
			// dup page to child
			duppage(e_id, PGNUM(addr));
		}
	}
	// alloc page for exception stack
	int r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	6a 07                	push   $0x7
  800f79:	68 00 f0 bf ee       	push   $0xeebff000
  800f7e:	ff 75 dc             	pushl  -0x24(%ebp)
  800f81:	e8 20 fc ff ff       	call   800ba6 <sys_page_alloc>
	if (r < 0) panic("fork: %e",r);
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	79 15                	jns    800fa2 <fork+0x153>
  800f8d:	50                   	push   %eax
  800f8e:	68 01 17 80 00       	push   $0x801701
  800f93:	68 85 00 00 00       	push   $0x85
  800f98:	68 bc 16 80 00       	push   $0x8016bc
  800f9d:	e8 a3 f1 ff ff       	call   800145 <_panic>

	// DO NOT FORGET
	extern void _pgfault_upcall();
	r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  800fa2:	83 ec 08             	sub    $0x8,%esp
  800fa5:	68 90 10 80 00       	push   $0x801090
  800faa:	ff 75 dc             	pushl  -0x24(%ebp)
  800fad:	e8 fd fc ff ff       	call   800caf <sys_env_set_pgfault_upcall>
	if (r < 0) panic("fork: set upcall for child fail, %e", r);
  800fb2:	83 c4 10             	add    $0x10,%esp
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 15                	jns    800fce <fork+0x17f>
  800fb9:	50                   	push   %eax
  800fba:	68 98 16 80 00       	push   $0x801698
  800fbf:	68 8a 00 00 00       	push   $0x8a
  800fc4:	68 bc 16 80 00       	push   $0x8016bc
  800fc9:	e8 77 f1 ff ff       	call   800145 <_panic>

	// mark the child environment runnable
	if ((r = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  800fce:	83 ec 08             	sub    $0x8,%esp
  800fd1:	6a 02                	push   $0x2
  800fd3:	ff 75 dc             	pushl  -0x24(%ebp)
  800fd6:	e8 92 fc ff ff       	call   800c6d <sys_env_set_status>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	79 15                	jns    800ff7 <fork+0x1a8>
		panic("sys_env_set_status: %e", r);
  800fe2:	50                   	push   %eax
  800fe3:	68 16 17 80 00       	push   $0x801716
  800fe8:	68 8e 00 00 00       	push   $0x8e
  800fed:	68 bc 16 80 00       	push   $0x8016bc
  800ff2:	e8 4e f1 ff ff       	call   800145 <_panic>

	return e_id;
  800ff7:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
  800ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5f                   	pop    %edi
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <sfork>:

// Challenge!
int
sfork(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801008:	68 2d 17 80 00       	push   $0x80172d
  80100d:	68 97 00 00 00       	push   $0x97
  801012:	68 bc 16 80 00       	push   $0x8016bc
  801017:	e8 29 f1 ff ff       	call   800145 <_panic>

0080101c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801023:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80102a:	75 57                	jne    801083 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  80102c:	e8 37 fb ff ff       	call   800b68 <sys_getenvid>
  801031:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	6a 07                	push   $0x7
  801038:	68 00 f0 bf ee       	push   $0xeebff000
  80103d:	50                   	push   %eax
  80103e:	e8 63 fb ff ff       	call   800ba6 <sys_page_alloc>
		if (r < 0) {
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	79 12                	jns    80105c <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  80104a:	50                   	push   %eax
  80104b:	68 43 17 80 00       	push   $0x801743
  801050:	6a 24                	push   $0x24
  801052:	68 57 17 80 00       	push   $0x801757
  801057:	e8 e9 f0 ff ff       	call   800145 <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  80105c:	83 ec 08             	sub    $0x8,%esp
  80105f:	68 90 10 80 00       	push   $0x801090
  801064:	53                   	push   %ebx
  801065:	e8 45 fc ff ff       	call   800caf <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80106a:	83 c4 10             	add    $0x10,%esp
  80106d:	85 c0                	test   %eax,%eax
  80106f:	79 12                	jns    801083 <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  801071:	50                   	push   %eax
  801072:	68 43 17 80 00       	push   $0x801743
  801077:	6a 29                	push   $0x29
  801079:	68 57 17 80 00       	push   $0x801757
  80107e:	e8 c2 f0 ff ff       	call   800145 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	a3 0c 20 80 00       	mov    %eax,0x80200c
}
  80108b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801090:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801091:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801096:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801098:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  80109b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  80109f:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  8010a2:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  8010a6:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  8010aa:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8010ad:	83 c4 08             	add    $0x8,%esp
	popal
  8010b0:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8010b1:	83 c4 04             	add    $0x4,%esp
	popfl
  8010b4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8010b5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010b6:	c3                   	ret    
  8010b7:	66 90                	xchg   %ax,%ax
  8010b9:	66 90                	xchg   %ax,%ax
  8010bb:	66 90                	xchg   %ax,%ax
  8010bd:	66 90                	xchg   %ax,%ax
  8010bf:	90                   	nop

008010c0 <__udivdi3>:
  8010c0:	55                   	push   %ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 1c             	sub    $0x1c,%esp
  8010c7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8010cb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8010cf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8010d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010d7:	85 f6                	test   %esi,%esi
  8010d9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010dd:	89 ca                	mov    %ecx,%edx
  8010df:	89 f8                	mov    %edi,%eax
  8010e1:	75 3d                	jne    801120 <__udivdi3+0x60>
  8010e3:	39 cf                	cmp    %ecx,%edi
  8010e5:	0f 87 c5 00 00 00    	ja     8011b0 <__udivdi3+0xf0>
  8010eb:	85 ff                	test   %edi,%edi
  8010ed:	89 fd                	mov    %edi,%ebp
  8010ef:	75 0b                	jne    8010fc <__udivdi3+0x3c>
  8010f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f6:	31 d2                	xor    %edx,%edx
  8010f8:	f7 f7                	div    %edi
  8010fa:	89 c5                	mov    %eax,%ebp
  8010fc:	89 c8                	mov    %ecx,%eax
  8010fe:	31 d2                	xor    %edx,%edx
  801100:	f7 f5                	div    %ebp
  801102:	89 c1                	mov    %eax,%ecx
  801104:	89 d8                	mov    %ebx,%eax
  801106:	89 cf                	mov    %ecx,%edi
  801108:	f7 f5                	div    %ebp
  80110a:	89 c3                	mov    %eax,%ebx
  80110c:	89 d8                	mov    %ebx,%eax
  80110e:	89 fa                	mov    %edi,%edx
  801110:	83 c4 1c             	add    $0x1c,%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
  801118:	90                   	nop
  801119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801120:	39 ce                	cmp    %ecx,%esi
  801122:	77 74                	ja     801198 <__udivdi3+0xd8>
  801124:	0f bd fe             	bsr    %esi,%edi
  801127:	83 f7 1f             	xor    $0x1f,%edi
  80112a:	0f 84 98 00 00 00    	je     8011c8 <__udivdi3+0x108>
  801130:	bb 20 00 00 00       	mov    $0x20,%ebx
  801135:	89 f9                	mov    %edi,%ecx
  801137:	89 c5                	mov    %eax,%ebp
  801139:	29 fb                	sub    %edi,%ebx
  80113b:	d3 e6                	shl    %cl,%esi
  80113d:	89 d9                	mov    %ebx,%ecx
  80113f:	d3 ed                	shr    %cl,%ebp
  801141:	89 f9                	mov    %edi,%ecx
  801143:	d3 e0                	shl    %cl,%eax
  801145:	09 ee                	or     %ebp,%esi
  801147:	89 d9                	mov    %ebx,%ecx
  801149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80114d:	89 d5                	mov    %edx,%ebp
  80114f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801153:	d3 ed                	shr    %cl,%ebp
  801155:	89 f9                	mov    %edi,%ecx
  801157:	d3 e2                	shl    %cl,%edx
  801159:	89 d9                	mov    %ebx,%ecx
  80115b:	d3 e8                	shr    %cl,%eax
  80115d:	09 c2                	or     %eax,%edx
  80115f:	89 d0                	mov    %edx,%eax
  801161:	89 ea                	mov    %ebp,%edx
  801163:	f7 f6                	div    %esi
  801165:	89 d5                	mov    %edx,%ebp
  801167:	89 c3                	mov    %eax,%ebx
  801169:	f7 64 24 0c          	mull   0xc(%esp)
  80116d:	39 d5                	cmp    %edx,%ebp
  80116f:	72 10                	jb     801181 <__udivdi3+0xc1>
  801171:	8b 74 24 08          	mov    0x8(%esp),%esi
  801175:	89 f9                	mov    %edi,%ecx
  801177:	d3 e6                	shl    %cl,%esi
  801179:	39 c6                	cmp    %eax,%esi
  80117b:	73 07                	jae    801184 <__udivdi3+0xc4>
  80117d:	39 d5                	cmp    %edx,%ebp
  80117f:	75 03                	jne    801184 <__udivdi3+0xc4>
  801181:	83 eb 01             	sub    $0x1,%ebx
  801184:	31 ff                	xor    %edi,%edi
  801186:	89 d8                	mov    %ebx,%eax
  801188:	89 fa                	mov    %edi,%edx
  80118a:	83 c4 1c             	add    $0x1c,%esp
  80118d:	5b                   	pop    %ebx
  80118e:	5e                   	pop    %esi
  80118f:	5f                   	pop    %edi
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    
  801192:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801198:	31 ff                	xor    %edi,%edi
  80119a:	31 db                	xor    %ebx,%ebx
  80119c:	89 d8                	mov    %ebx,%eax
  80119e:	89 fa                	mov    %edi,%edx
  8011a0:	83 c4 1c             	add    $0x1c,%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    
  8011a8:	90                   	nop
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	89 d8                	mov    %ebx,%eax
  8011b2:	f7 f7                	div    %edi
  8011b4:	31 ff                	xor    %edi,%edi
  8011b6:	89 c3                	mov    %eax,%ebx
  8011b8:	89 d8                	mov    %ebx,%eax
  8011ba:	89 fa                	mov    %edi,%edx
  8011bc:	83 c4 1c             	add    $0x1c,%esp
  8011bf:	5b                   	pop    %ebx
  8011c0:	5e                   	pop    %esi
  8011c1:	5f                   	pop    %edi
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	39 ce                	cmp    %ecx,%esi
  8011ca:	72 0c                	jb     8011d8 <__udivdi3+0x118>
  8011cc:	31 db                	xor    %ebx,%ebx
  8011ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8011d2:	0f 87 34 ff ff ff    	ja     80110c <__udivdi3+0x4c>
  8011d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8011dd:	e9 2a ff ff ff       	jmp    80110c <__udivdi3+0x4c>
  8011e2:	66 90                	xchg   %ax,%ax
  8011e4:	66 90                	xchg   %ax,%ax
  8011e6:	66 90                	xchg   %ax,%ax
  8011e8:	66 90                	xchg   %ax,%ax
  8011ea:	66 90                	xchg   %ax,%ax
  8011ec:	66 90                	xchg   %ax,%ax
  8011ee:	66 90                	xchg   %ax,%ax

008011f0 <__umoddi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 1c             	sub    $0x1c,%esp
  8011f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8011fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801203:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801207:	85 d2                	test   %edx,%edx
  801209:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80120d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801211:	89 f3                	mov    %esi,%ebx
  801213:	89 3c 24             	mov    %edi,(%esp)
  801216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121a:	75 1c                	jne    801238 <__umoddi3+0x48>
  80121c:	39 f7                	cmp    %esi,%edi
  80121e:	76 50                	jbe    801270 <__umoddi3+0x80>
  801220:	89 c8                	mov    %ecx,%eax
  801222:	89 f2                	mov    %esi,%edx
  801224:	f7 f7                	div    %edi
  801226:	89 d0                	mov    %edx,%eax
  801228:	31 d2                	xor    %edx,%edx
  80122a:	83 c4 1c             	add    $0x1c,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    
  801232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801238:	39 f2                	cmp    %esi,%edx
  80123a:	89 d0                	mov    %edx,%eax
  80123c:	77 52                	ja     801290 <__umoddi3+0xa0>
  80123e:	0f bd ea             	bsr    %edx,%ebp
  801241:	83 f5 1f             	xor    $0x1f,%ebp
  801244:	75 5a                	jne    8012a0 <__umoddi3+0xb0>
  801246:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80124a:	0f 82 e0 00 00 00    	jb     801330 <__umoddi3+0x140>
  801250:	39 0c 24             	cmp    %ecx,(%esp)
  801253:	0f 86 d7 00 00 00    	jbe    801330 <__umoddi3+0x140>
  801259:	8b 44 24 08          	mov    0x8(%esp),%eax
  80125d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801261:	83 c4 1c             	add    $0x1c,%esp
  801264:	5b                   	pop    %ebx
  801265:	5e                   	pop    %esi
  801266:	5f                   	pop    %edi
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    
  801269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801270:	85 ff                	test   %edi,%edi
  801272:	89 fd                	mov    %edi,%ebp
  801274:	75 0b                	jne    801281 <__umoddi3+0x91>
  801276:	b8 01 00 00 00       	mov    $0x1,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	f7 f7                	div    %edi
  80127f:	89 c5                	mov    %eax,%ebp
  801281:	89 f0                	mov    %esi,%eax
  801283:	31 d2                	xor    %edx,%edx
  801285:	f7 f5                	div    %ebp
  801287:	89 c8                	mov    %ecx,%eax
  801289:	f7 f5                	div    %ebp
  80128b:	89 d0                	mov    %edx,%eax
  80128d:	eb 99                	jmp    801228 <__umoddi3+0x38>
  80128f:	90                   	nop
  801290:	89 c8                	mov    %ecx,%eax
  801292:	89 f2                	mov    %esi,%edx
  801294:	83 c4 1c             	add    $0x1c,%esp
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5f                   	pop    %edi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    
  80129c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a0:	8b 34 24             	mov    (%esp),%esi
  8012a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8012a8:	89 e9                	mov    %ebp,%ecx
  8012aa:	29 ef                	sub    %ebp,%edi
  8012ac:	d3 e0                	shl    %cl,%eax
  8012ae:	89 f9                	mov    %edi,%ecx
  8012b0:	89 f2                	mov    %esi,%edx
  8012b2:	d3 ea                	shr    %cl,%edx
  8012b4:	89 e9                	mov    %ebp,%ecx
  8012b6:	09 c2                	or     %eax,%edx
  8012b8:	89 d8                	mov    %ebx,%eax
  8012ba:	89 14 24             	mov    %edx,(%esp)
  8012bd:	89 f2                	mov    %esi,%edx
  8012bf:	d3 e2                	shl    %cl,%edx
  8012c1:	89 f9                	mov    %edi,%ecx
  8012c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8012cb:	d3 e8                	shr    %cl,%eax
  8012cd:	89 e9                	mov    %ebp,%ecx
  8012cf:	89 c6                	mov    %eax,%esi
  8012d1:	d3 e3                	shl    %cl,%ebx
  8012d3:	89 f9                	mov    %edi,%ecx
  8012d5:	89 d0                	mov    %edx,%eax
  8012d7:	d3 e8                	shr    %cl,%eax
  8012d9:	89 e9                	mov    %ebp,%ecx
  8012db:	09 d8                	or     %ebx,%eax
  8012dd:	89 d3                	mov    %edx,%ebx
  8012df:	89 f2                	mov    %esi,%edx
  8012e1:	f7 34 24             	divl   (%esp)
  8012e4:	89 d6                	mov    %edx,%esi
  8012e6:	d3 e3                	shl    %cl,%ebx
  8012e8:	f7 64 24 04          	mull   0x4(%esp)
  8012ec:	39 d6                	cmp    %edx,%esi
  8012ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f2:	89 d1                	mov    %edx,%ecx
  8012f4:	89 c3                	mov    %eax,%ebx
  8012f6:	72 08                	jb     801300 <__umoddi3+0x110>
  8012f8:	75 11                	jne    80130b <__umoddi3+0x11b>
  8012fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012fe:	73 0b                	jae    80130b <__umoddi3+0x11b>
  801300:	2b 44 24 04          	sub    0x4(%esp),%eax
  801304:	1b 14 24             	sbb    (%esp),%edx
  801307:	89 d1                	mov    %edx,%ecx
  801309:	89 c3                	mov    %eax,%ebx
  80130b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80130f:	29 da                	sub    %ebx,%edx
  801311:	19 ce                	sbb    %ecx,%esi
  801313:	89 f9                	mov    %edi,%ecx
  801315:	89 f0                	mov    %esi,%eax
  801317:	d3 e0                	shl    %cl,%eax
  801319:	89 e9                	mov    %ebp,%ecx
  80131b:	d3 ea                	shr    %cl,%edx
  80131d:	89 e9                	mov    %ebp,%ecx
  80131f:	d3 ee                	shr    %cl,%esi
  801321:	09 d0                	or     %edx,%eax
  801323:	89 f2                	mov    %esi,%edx
  801325:	83 c4 1c             	add    $0x1c,%esp
  801328:	5b                   	pop    %ebx
  801329:	5e                   	pop    %esi
  80132a:	5f                   	pop    %edi
  80132b:	5d                   	pop    %ebp
  80132c:	c3                   	ret    
  80132d:	8d 76 00             	lea    0x0(%esi),%esi
  801330:	29 f9                	sub    %edi,%ecx
  801332:	19 d6                	sbb    %edx,%esi
  801334:	89 74 24 04          	mov    %esi,0x4(%esp)
  801338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133c:	e9 18 ff ff ff       	jmp    801259 <__umoddi3+0x69>
