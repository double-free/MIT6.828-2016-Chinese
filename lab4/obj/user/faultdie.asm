
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 10 80 00       	push   $0x801020
  80004a:	e8 1c 01 00 00       	call   80016b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 61 0a 00 00       	call   800ab5 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 18 0a 00 00       	call   800a74 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 31 0c 00 00       	call   800ca2 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 25 0a 00 00       	call   800ab5 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 a1 09 00 00       	call   800a74 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 1a                	jne    800111 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 2f 09 00 00       	call   800a37 <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	68 d8 00 80 00       	push   $0x8000d8
  800149:	e8 54 01 00 00       	call   8002a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	83 c4 08             	add    $0x8,%esp
  800151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 d4 08 00 00       	call   800a37 <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	50                   	push   %eax
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	e8 9d ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 1c             	sub    $0x1c,%esp
  800188:	89 c7                	mov    %eax,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800195:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800198:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80019b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a6:	39 d3                	cmp    %edx,%ebx
  8001a8:	72 05                	jb     8001af <printnum+0x30>
  8001aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ad:	77 45                	ja     8001f4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	ff 75 18             	pushl  0x18(%ebp)
  8001b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001bb:	53                   	push   %ebx
  8001bc:	ff 75 10             	pushl  0x10(%ebp)
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ce:	e8 bd 0b 00 00       	call   800d90 <__udivdi3>
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	52                   	push   %edx
  8001d7:	50                   	push   %eax
  8001d8:	89 f2                	mov    %esi,%edx
  8001da:	89 f8                	mov    %edi,%eax
  8001dc:	e8 9e ff ff ff       	call   80017f <printnum>
  8001e1:	83 c4 20             	add    $0x20,%esp
  8001e4:	eb 18                	jmp    8001fe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff d7                	call   *%edi
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	eb 03                	jmp    8001f7 <printnum+0x78>
  8001f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	85 db                	test   %ebx,%ebx
  8001fc:	7f e8                	jg     8001e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	56                   	push   %esi
  800202:	83 ec 04             	sub    $0x4,%esp
  800205:	ff 75 e4             	pushl  -0x1c(%ebp)
  800208:	ff 75 e0             	pushl  -0x20(%ebp)
  80020b:	ff 75 dc             	pushl  -0x24(%ebp)
  80020e:	ff 75 d8             	pushl  -0x28(%ebp)
  800211:	e8 aa 0c 00 00       	call   800ec0 <__umoddi3>
  800216:	83 c4 14             	add    $0x14,%esp
  800219:	0f be 80 46 10 80 00 	movsbl 0x801046(%eax),%eax
  800220:	50                   	push   %eax
  800221:	ff d7                	call   *%edi
}
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800231:	83 fa 01             	cmp    $0x1,%edx
  800234:	7e 0e                	jle    800244 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 08             	lea    0x8(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	8b 52 04             	mov    0x4(%edx),%edx
  800242:	eb 22                	jmp    800266 <getuint+0x38>
	else if (lflag)
  800244:	85 d2                	test   %edx,%edx
  800246:	74 10                	je     800258 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800248:	8b 10                	mov    (%eax),%edx
  80024a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 02                	mov    (%edx),%eax
  800251:	ba 00 00 00 00       	mov    $0x0,%edx
  800256:	eb 0e                	jmp    800266 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80026e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800272:	8b 10                	mov    (%eax),%edx
  800274:	3b 50 04             	cmp    0x4(%eax),%edx
  800277:	73 0a                	jae    800283 <sprintputch+0x1b>
		*b->buf++ = ch;
  800279:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027c:	89 08                	mov    %ecx,(%eax)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	88 02                	mov    %al,(%edx)
}
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028e:	50                   	push   %eax
  80028f:	ff 75 10             	pushl  0x10(%ebp)
  800292:	ff 75 0c             	pushl  0xc(%ebp)
  800295:	ff 75 08             	pushl  0x8(%ebp)
  800298:	e8 05 00 00 00       	call   8002a2 <vprintfmt>
	va_end(ap);
}
  80029d:	83 c4 10             	add    $0x10,%esp
  8002a0:	c9                   	leave  
  8002a1:	c3                   	ret    

008002a2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	57                   	push   %edi
  8002a6:	56                   	push   %esi
  8002a7:	53                   	push   %ebx
  8002a8:	83 ec 2c             	sub    $0x2c,%esp
  8002ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b4:	eb 12                	jmp    8002c8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b6:	85 c0                	test   %eax,%eax
  8002b8:	0f 84 89 03 00 00    	je     800647 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002be:	83 ec 08             	sub    $0x8,%esp
  8002c1:	53                   	push   %ebx
  8002c2:	50                   	push   %eax
  8002c3:	ff d6                	call   *%esi
  8002c5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002c8:	83 c7 01             	add    $0x1,%edi
  8002cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002cf:	83 f8 25             	cmp    $0x25,%eax
  8002d2:	75 e2                	jne    8002b6 <vprintfmt+0x14>
  8002d4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002d8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002df:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f2:	eb 07                	jmp    8002fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002f7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8d 47 01             	lea    0x1(%edi),%eax
  8002fe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800301:	0f b6 07             	movzbl (%edi),%eax
  800304:	0f b6 c8             	movzbl %al,%ecx
  800307:	83 e8 23             	sub    $0x23,%eax
  80030a:	3c 55                	cmp    $0x55,%al
  80030c:	0f 87 1a 03 00 00    	ja     80062c <vprintfmt+0x38a>
  800312:	0f b6 c0             	movzbl %al,%eax
  800315:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  80031c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80031f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800323:	eb d6                	jmp    8002fb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800328:	b8 00 00 00 00       	mov    $0x0,%eax
  80032d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800330:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800333:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800337:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80033a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80033d:	83 fa 09             	cmp    $0x9,%edx
  800340:	77 39                	ja     80037b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800342:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800345:	eb e9                	jmp    800330 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800347:	8b 45 14             	mov    0x14(%ebp),%eax
  80034a:	8d 48 04             	lea    0x4(%eax),%ecx
  80034d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800350:	8b 00                	mov    (%eax),%eax
  800352:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800355:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800358:	eb 27                	jmp    800381 <vprintfmt+0xdf>
  80035a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035d:	85 c0                	test   %eax,%eax
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800364:	0f 49 c8             	cmovns %eax,%ecx
  800367:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	eb 8c                	jmp    8002fb <vprintfmt+0x59>
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800372:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800379:	eb 80                	jmp    8002fb <vprintfmt+0x59>
  80037b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80037e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800381:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800385:	0f 89 70 ff ff ff    	jns    8002fb <vprintfmt+0x59>
				width = precision, precision = -1;
  80038b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80038e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800391:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800398:	e9 5e ff ff ff       	jmp    8002fb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80039d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003a3:	e9 53 ff ff ff       	jmp    8002fb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ab:	8d 50 04             	lea    0x4(%eax),%edx
  8003ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b1:	83 ec 08             	sub    $0x8,%esp
  8003b4:	53                   	push   %ebx
  8003b5:	ff 30                	pushl  (%eax)
  8003b7:	ff d6                	call   *%esi
			break;
  8003b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003bf:	e9 04 ff ff ff       	jmp    8002c8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 50 04             	lea    0x4(%eax),%edx
  8003ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	99                   	cltd   
  8003d0:	31 d0                	xor    %edx,%eax
  8003d2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d4:	83 f8 08             	cmp    $0x8,%eax
  8003d7:	7f 0b                	jg     8003e4 <vprintfmt+0x142>
  8003d9:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	75 18                	jne    8003fc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003e4:	50                   	push   %eax
  8003e5:	68 5e 10 80 00       	push   $0x80105e
  8003ea:	53                   	push   %ebx
  8003eb:	56                   	push   %esi
  8003ec:	e8 94 fe ff ff       	call   800285 <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003f7:	e9 cc fe ff ff       	jmp    8002c8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003fc:	52                   	push   %edx
  8003fd:	68 67 10 80 00       	push   $0x801067
  800402:	53                   	push   %ebx
  800403:	56                   	push   %esi
  800404:	e8 7c fe ff ff       	call   800285 <printfmt>
  800409:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	e9 b4 fe ff ff       	jmp    8002c8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 50 04             	lea    0x4(%eax),%edx
  80041a:	89 55 14             	mov    %edx,0x14(%ebp)
  80041d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041f:	85 ff                	test   %edi,%edi
  800421:	b8 57 10 80 00       	mov    $0x801057,%eax
  800426:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800429:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042d:	0f 8e 94 00 00 00    	jle    8004c7 <vprintfmt+0x225>
  800433:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800437:	0f 84 98 00 00 00    	je     8004d5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	ff 75 d0             	pushl  -0x30(%ebp)
  800443:	57                   	push   %edi
  800444:	e8 86 02 00 00       	call   8006cf <strnlen>
  800449:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044c:	29 c1                	sub    %eax,%ecx
  80044e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800451:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800454:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800458:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80045e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800460:	eb 0f                	jmp    800471 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046b:	83 ef 01             	sub    $0x1,%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	85 ff                	test   %edi,%edi
  800473:	7f ed                	jg     800462 <vprintfmt+0x1c0>
  800475:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800478:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047b:	85 c9                	test   %ecx,%ecx
  80047d:	b8 00 00 00 00       	mov    $0x0,%eax
  800482:	0f 49 c1             	cmovns %ecx,%eax
  800485:	29 c1                	sub    %eax,%ecx
  800487:	89 75 08             	mov    %esi,0x8(%ebp)
  80048a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800490:	89 cb                	mov    %ecx,%ebx
  800492:	eb 4d                	jmp    8004e1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800494:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800498:	74 1b                	je     8004b5 <vprintfmt+0x213>
  80049a:	0f be c0             	movsbl %al,%eax
  80049d:	83 e8 20             	sub    $0x20,%eax
  8004a0:	83 f8 5e             	cmp    $0x5e,%eax
  8004a3:	76 10                	jbe    8004b5 <vprintfmt+0x213>
					putch('?', putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	6a 3f                	push   $0x3f
  8004ad:	ff 55 08             	call   *0x8(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	eb 0d                	jmp    8004c2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	ff 75 0c             	pushl  0xc(%ebp)
  8004bb:	52                   	push   %edx
  8004bc:	ff 55 08             	call   *0x8(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c2:	83 eb 01             	sub    $0x1,%ebx
  8004c5:	eb 1a                	jmp    8004e1 <vprintfmt+0x23f>
  8004c7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ca:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d3:	eb 0c                	jmp    8004e1 <vprintfmt+0x23f>
  8004d5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004db:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004de:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e1:	83 c7 01             	add    $0x1,%edi
  8004e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e8:	0f be d0             	movsbl %al,%edx
  8004eb:	85 d2                	test   %edx,%edx
  8004ed:	74 23                	je     800512 <vprintfmt+0x270>
  8004ef:	85 f6                	test   %esi,%esi
  8004f1:	78 a1                	js     800494 <vprintfmt+0x1f2>
  8004f3:	83 ee 01             	sub    $0x1,%esi
  8004f6:	79 9c                	jns    800494 <vprintfmt+0x1f2>
  8004f8:	89 df                	mov    %ebx,%edi
  8004fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800500:	eb 18                	jmp    80051a <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	53                   	push   %ebx
  800506:	6a 20                	push   $0x20
  800508:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050a:	83 ef 01             	sub    $0x1,%edi
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	eb 08                	jmp    80051a <vprintfmt+0x278>
  800512:	89 df                	mov    %ebx,%edi
  800514:	8b 75 08             	mov    0x8(%ebp),%esi
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f e4                	jg     800502 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800521:	e9 a2 fd ff ff       	jmp    8002c8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800526:	83 fa 01             	cmp    $0x1,%edx
  800529:	7e 16                	jle    800541 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8d 50 08             	lea    0x8(%eax),%edx
  800531:	89 55 14             	mov    %edx,0x14(%ebp)
  800534:	8b 50 04             	mov    0x4(%eax),%edx
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053f:	eb 32                	jmp    800573 <vprintfmt+0x2d1>
	else if (lflag)
  800541:	85 d2                	test   %edx,%edx
  800543:	74 18                	je     80055d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 04             	lea    0x4(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 00                	mov    (%eax),%eax
  800550:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800553:	89 c1                	mov    %eax,%ecx
  800555:	c1 f9 1f             	sar    $0x1f,%ecx
  800558:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80055b:	eb 16                	jmp    800573 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8d 50 04             	lea    0x4(%eax),%edx
  800563:	89 55 14             	mov    %edx,0x14(%ebp)
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 c1                	mov    %eax,%ecx
  80056d:	c1 f9 1f             	sar    $0x1f,%ecx
  800570:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800573:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800576:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800579:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80057e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800582:	79 74                	jns    8005f8 <vprintfmt+0x356>
				putch('-', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	53                   	push   %ebx
  800588:	6a 2d                	push   $0x2d
  80058a:	ff d6                	call   *%esi
				num = -(long long) num;
  80058c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80058f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800592:	f7 d8                	neg    %eax
  800594:	83 d2 00             	adc    $0x0,%edx
  800597:	f7 da                	neg    %edx
  800599:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80059c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005a1:	eb 55                	jmp    8005f8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 83 fc ff ff       	call   80022e <getuint>
			base = 10;
  8005ab:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005b0:	eb 46                	jmp    8005f8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b5:	e8 74 fc ff ff       	call   80022e <getuint>
			base = 8;
  8005ba:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005bf:	eb 37                	jmp    8005f8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 30                	push   $0x30
  8005c7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c9:	83 c4 08             	add    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 78                	push   $0x78
  8005cf:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005e1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005e4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005e9:	eb 0d                	jmp    8005f8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ee:	e8 3b fc ff ff       	call   80022e <getuint>
			base = 16;
  8005f3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005f8:	83 ec 0c             	sub    $0xc,%esp
  8005fb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005ff:	57                   	push   %edi
  800600:	ff 75 e0             	pushl  -0x20(%ebp)
  800603:	51                   	push   %ecx
  800604:	52                   	push   %edx
  800605:	50                   	push   %eax
  800606:	89 da                	mov    %ebx,%edx
  800608:	89 f0                	mov    %esi,%eax
  80060a:	e8 70 fb ff ff       	call   80017f <printnum>
			break;
  80060f:	83 c4 20             	add    $0x20,%esp
  800612:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800615:	e9 ae fc ff ff       	jmp    8002c8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	51                   	push   %ecx
  80061f:	ff d6                	call   *%esi
			break;
  800621:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800627:	e9 9c fc ff ff       	jmp    8002c8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 25                	push   $0x25
  800632:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	eb 03                	jmp    80063c <vprintfmt+0x39a>
  800639:	83 ef 01             	sub    $0x1,%edi
  80063c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800640:	75 f7                	jne    800639 <vprintfmt+0x397>
  800642:	e9 81 fc ff ff       	jmp    8002c8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800647:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5e                   	pop    %esi
  80064c:	5f                   	pop    %edi
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	83 ec 18             	sub    $0x18,%esp
  800655:	8b 45 08             	mov    0x8(%ebp),%eax
  800658:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80065b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80065e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800662:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800665:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80066c:	85 c0                	test   %eax,%eax
  80066e:	74 26                	je     800696 <vsnprintf+0x47>
  800670:	85 d2                	test   %edx,%edx
  800672:	7e 22                	jle    800696 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800674:	ff 75 14             	pushl  0x14(%ebp)
  800677:	ff 75 10             	pushl  0x10(%ebp)
  80067a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	68 68 02 80 00       	push   $0x800268
  800683:	e8 1a fc ff ff       	call   8002a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800688:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80068b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	eb 05                	jmp    80069b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80069b:	c9                   	leave  
  80069c:	c3                   	ret    

0080069d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a6:	50                   	push   %eax
  8006a7:	ff 75 10             	pushl  0x10(%ebp)
  8006aa:	ff 75 0c             	pushl  0xc(%ebp)
  8006ad:	ff 75 08             	pushl  0x8(%ebp)
  8006b0:	e8 9a ff ff ff       	call   80064f <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c2:	eb 03                	jmp    8006c7 <strlen+0x10>
		n++;
  8006c4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006cb:	75 f7                	jne    8006c4 <strlen+0xd>
		n++;
	return n;
}
  8006cd:	5d                   	pop    %ebp
  8006ce:	c3                   	ret    

008006cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006cf:	55                   	push   %ebp
  8006d0:	89 e5                	mov    %esp,%ebp
  8006d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006dd:	eb 03                	jmp    8006e2 <strnlen+0x13>
		n++;
  8006df:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006e2:	39 c2                	cmp    %eax,%edx
  8006e4:	74 08                	je     8006ee <strnlen+0x1f>
  8006e6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ea:	75 f3                	jne    8006df <strnlen+0x10>
  8006ec:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006fa:	89 c2                	mov    %eax,%edx
  8006fc:	83 c2 01             	add    $0x1,%edx
  8006ff:	83 c1 01             	add    $0x1,%ecx
  800702:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800706:	88 5a ff             	mov    %bl,-0x1(%edx)
  800709:	84 db                	test   %bl,%bl
  80070b:	75 ef                	jne    8006fc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80070d:	5b                   	pop    %ebx
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	53                   	push   %ebx
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800717:	53                   	push   %ebx
  800718:	e8 9a ff ff ff       	call   8006b7 <strlen>
  80071d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800720:	ff 75 0c             	pushl  0xc(%ebp)
  800723:	01 d8                	add    %ebx,%eax
  800725:	50                   	push   %eax
  800726:	e8 c5 ff ff ff       	call   8006f0 <strcpy>
	return dst;
}
  80072b:	89 d8                	mov    %ebx,%eax
  80072d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	8b 75 08             	mov    0x8(%ebp),%esi
  80073a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80073d:	89 f3                	mov    %esi,%ebx
  80073f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800742:	89 f2                	mov    %esi,%edx
  800744:	eb 0f                	jmp    800755 <strncpy+0x23>
		*dst++ = *src;
  800746:	83 c2 01             	add    $0x1,%edx
  800749:	0f b6 01             	movzbl (%ecx),%eax
  80074c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80074f:	80 39 01             	cmpb   $0x1,(%ecx)
  800752:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800755:	39 da                	cmp    %ebx,%edx
  800757:	75 ed                	jne    800746 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800759:	89 f0                	mov    %esi,%eax
  80075b:	5b                   	pop    %ebx
  80075c:	5e                   	pop    %esi
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	56                   	push   %esi
  800763:	53                   	push   %ebx
  800764:	8b 75 08             	mov    0x8(%ebp),%esi
  800767:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80076a:	8b 55 10             	mov    0x10(%ebp),%edx
  80076d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 21                	je     800794 <strlcpy+0x35>
  800773:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800777:	89 f2                	mov    %esi,%edx
  800779:	eb 09                	jmp    800784 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80077b:	83 c2 01             	add    $0x1,%edx
  80077e:	83 c1 01             	add    $0x1,%ecx
  800781:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800784:	39 c2                	cmp    %eax,%edx
  800786:	74 09                	je     800791 <strlcpy+0x32>
  800788:	0f b6 19             	movzbl (%ecx),%ebx
  80078b:	84 db                	test   %bl,%bl
  80078d:	75 ec                	jne    80077b <strlcpy+0x1c>
  80078f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800791:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800794:	29 f0                	sub    %esi,%eax
}
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007a3:	eb 06                	jmp    8007ab <strcmp+0x11>
		p++, q++;
  8007a5:	83 c1 01             	add    $0x1,%ecx
  8007a8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007ab:	0f b6 01             	movzbl (%ecx),%eax
  8007ae:	84 c0                	test   %al,%al
  8007b0:	74 04                	je     8007b6 <strcmp+0x1c>
  8007b2:	3a 02                	cmp    (%edx),%al
  8007b4:	74 ef                	je     8007a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007b6:	0f b6 c0             	movzbl %al,%eax
  8007b9:	0f b6 12             	movzbl (%edx),%edx
  8007bc:	29 d0                	sub    %edx,%eax
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	53                   	push   %ebx
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	89 c3                	mov    %eax,%ebx
  8007cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007cf:	eb 06                	jmp    8007d7 <strncmp+0x17>
		n--, p++, q++;
  8007d1:	83 c0 01             	add    $0x1,%eax
  8007d4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007d7:	39 d8                	cmp    %ebx,%eax
  8007d9:	74 15                	je     8007f0 <strncmp+0x30>
  8007db:	0f b6 08             	movzbl (%eax),%ecx
  8007de:	84 c9                	test   %cl,%cl
  8007e0:	74 04                	je     8007e6 <strncmp+0x26>
  8007e2:	3a 0a                	cmp    (%edx),%cl
  8007e4:	74 eb                	je     8007d1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007e6:	0f b6 00             	movzbl (%eax),%eax
  8007e9:	0f b6 12             	movzbl (%edx),%edx
  8007ec:	29 d0                	sub    %edx,%eax
  8007ee:	eb 05                	jmp    8007f5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800802:	eb 07                	jmp    80080b <strchr+0x13>
		if (*s == c)
  800804:	38 ca                	cmp    %cl,%dl
  800806:	74 0f                	je     800817 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800808:	83 c0 01             	add    $0x1,%eax
  80080b:	0f b6 10             	movzbl (%eax),%edx
  80080e:	84 d2                	test   %dl,%dl
  800810:	75 f2                	jne    800804 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800823:	eb 03                	jmp    800828 <strfind+0xf>
  800825:	83 c0 01             	add    $0x1,%eax
  800828:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80082b:	38 ca                	cmp    %cl,%dl
  80082d:	74 04                	je     800833 <strfind+0x1a>
  80082f:	84 d2                	test   %dl,%dl
  800831:	75 f2                	jne    800825 <strfind+0xc>
			break;
	return (char *) s;
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	57                   	push   %edi
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
  80083b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800841:	85 c9                	test   %ecx,%ecx
  800843:	74 36                	je     80087b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800845:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80084b:	75 28                	jne    800875 <memset+0x40>
  80084d:	f6 c1 03             	test   $0x3,%cl
  800850:	75 23                	jne    800875 <memset+0x40>
		c &= 0xFF;
  800852:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800856:	89 d3                	mov    %edx,%ebx
  800858:	c1 e3 08             	shl    $0x8,%ebx
  80085b:	89 d6                	mov    %edx,%esi
  80085d:	c1 e6 18             	shl    $0x18,%esi
  800860:	89 d0                	mov    %edx,%eax
  800862:	c1 e0 10             	shl    $0x10,%eax
  800865:	09 f0                	or     %esi,%eax
  800867:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800869:	89 d8                	mov    %ebx,%eax
  80086b:	09 d0                	or     %edx,%eax
  80086d:	c1 e9 02             	shr    $0x2,%ecx
  800870:	fc                   	cld    
  800871:	f3 ab                	rep stos %eax,%es:(%edi)
  800873:	eb 06                	jmp    80087b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
  800878:	fc                   	cld    
  800879:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80087b:	89 f8                	mov    %edi,%eax
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5f                   	pop    %edi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	57                   	push   %edi
  800886:	56                   	push   %esi
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800890:	39 c6                	cmp    %eax,%esi
  800892:	73 35                	jae    8008c9 <memmove+0x47>
  800894:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800897:	39 d0                	cmp    %edx,%eax
  800899:	73 2e                	jae    8008c9 <memmove+0x47>
		s += n;
		d += n;
  80089b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80089e:	89 d6                	mov    %edx,%esi
  8008a0:	09 fe                	or     %edi,%esi
  8008a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008a8:	75 13                	jne    8008bd <memmove+0x3b>
  8008aa:	f6 c1 03             	test   $0x3,%cl
  8008ad:	75 0e                	jne    8008bd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008af:	83 ef 04             	sub    $0x4,%edi
  8008b2:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
  8008b8:	fd                   	std    
  8008b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bb:	eb 09                	jmp    8008c6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008bd:	83 ef 01             	sub    $0x1,%edi
  8008c0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008c3:	fd                   	std    
  8008c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008c6:	fc                   	cld    
  8008c7:	eb 1d                	jmp    8008e6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c9:	89 f2                	mov    %esi,%edx
  8008cb:	09 c2                	or     %eax,%edx
  8008cd:	f6 c2 03             	test   $0x3,%dl
  8008d0:	75 0f                	jne    8008e1 <memmove+0x5f>
  8008d2:	f6 c1 03             	test   $0x3,%cl
  8008d5:	75 0a                	jne    8008e1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008d7:	c1 e9 02             	shr    $0x2,%ecx
  8008da:	89 c7                	mov    %eax,%edi
  8008dc:	fc                   	cld    
  8008dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008df:	eb 05                	jmp    8008e6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008e1:	89 c7                	mov    %eax,%edi
  8008e3:	fc                   	cld    
  8008e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008e6:	5e                   	pop    %esi
  8008e7:	5f                   	pop    %edi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	ff 75 0c             	pushl  0xc(%ebp)
  8008f3:	ff 75 08             	pushl  0x8(%ebp)
  8008f6:	e8 87 ff ff ff       	call   800882 <memmove>
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80090d:	eb 1a                	jmp    800929 <memcmp+0x2c>
		if (*s1 != *s2)
  80090f:	0f b6 08             	movzbl (%eax),%ecx
  800912:	0f b6 1a             	movzbl (%edx),%ebx
  800915:	38 d9                	cmp    %bl,%cl
  800917:	74 0a                	je     800923 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800919:	0f b6 c1             	movzbl %cl,%eax
  80091c:	0f b6 db             	movzbl %bl,%ebx
  80091f:	29 d8                	sub    %ebx,%eax
  800921:	eb 0f                	jmp    800932 <memcmp+0x35>
		s1++, s2++;
  800923:	83 c0 01             	add    $0x1,%eax
  800926:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800929:	39 f0                	cmp    %esi,%eax
  80092b:	75 e2                	jne    80090f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80092d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	53                   	push   %ebx
  80093a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80093d:	89 c1                	mov    %eax,%ecx
  80093f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800942:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800946:	eb 0a                	jmp    800952 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800948:	0f b6 10             	movzbl (%eax),%edx
  80094b:	39 da                	cmp    %ebx,%edx
  80094d:	74 07                	je     800956 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	39 c8                	cmp    %ecx,%eax
  800954:	72 f2                	jb     800948 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800956:	5b                   	pop    %ebx
  800957:	5d                   	pop    %ebp
  800958:	c3                   	ret    

00800959 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	57                   	push   %edi
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800962:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800965:	eb 03                	jmp    80096a <strtol+0x11>
		s++;
  800967:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80096a:	0f b6 01             	movzbl (%ecx),%eax
  80096d:	3c 20                	cmp    $0x20,%al
  80096f:	74 f6                	je     800967 <strtol+0xe>
  800971:	3c 09                	cmp    $0x9,%al
  800973:	74 f2                	je     800967 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800975:	3c 2b                	cmp    $0x2b,%al
  800977:	75 0a                	jne    800983 <strtol+0x2a>
		s++;
  800979:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80097c:	bf 00 00 00 00       	mov    $0x0,%edi
  800981:	eb 11                	jmp    800994 <strtol+0x3b>
  800983:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800988:	3c 2d                	cmp    $0x2d,%al
  80098a:	75 08                	jne    800994 <strtol+0x3b>
		s++, neg = 1;
  80098c:	83 c1 01             	add    $0x1,%ecx
  80098f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800994:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80099a:	75 15                	jne    8009b1 <strtol+0x58>
  80099c:	80 39 30             	cmpb   $0x30,(%ecx)
  80099f:	75 10                	jne    8009b1 <strtol+0x58>
  8009a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009a5:	75 7c                	jne    800a23 <strtol+0xca>
		s += 2, base = 16;
  8009a7:	83 c1 02             	add    $0x2,%ecx
  8009aa:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009af:	eb 16                	jmp    8009c7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009b1:	85 db                	test   %ebx,%ebx
  8009b3:	75 12                	jne    8009c7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009b5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8009bd:	75 08                	jne    8009c7 <strtol+0x6e>
		s++, base = 8;
  8009bf:	83 c1 01             	add    $0x1,%ecx
  8009c2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cc:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009cf:	0f b6 11             	movzbl (%ecx),%edx
  8009d2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009d5:	89 f3                	mov    %esi,%ebx
  8009d7:	80 fb 09             	cmp    $0x9,%bl
  8009da:	77 08                	ja     8009e4 <strtol+0x8b>
			dig = *s - '0';
  8009dc:	0f be d2             	movsbl %dl,%edx
  8009df:	83 ea 30             	sub    $0x30,%edx
  8009e2:	eb 22                	jmp    800a06 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009e4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009e7:	89 f3                	mov    %esi,%ebx
  8009e9:	80 fb 19             	cmp    $0x19,%bl
  8009ec:	77 08                	ja     8009f6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009ee:	0f be d2             	movsbl %dl,%edx
  8009f1:	83 ea 57             	sub    $0x57,%edx
  8009f4:	eb 10                	jmp    800a06 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009f6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009f9:	89 f3                	mov    %esi,%ebx
  8009fb:	80 fb 19             	cmp    $0x19,%bl
  8009fe:	77 16                	ja     800a16 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a00:	0f be d2             	movsbl %dl,%edx
  800a03:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a06:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a09:	7d 0b                	jge    800a16 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a12:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a14:	eb b9                	jmp    8009cf <strtol+0x76>

	if (endptr)
  800a16:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a1a:	74 0d                	je     800a29 <strtol+0xd0>
		*endptr = (char *) s;
  800a1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a1f:	89 0e                	mov    %ecx,(%esi)
  800a21:	eb 06                	jmp    800a29 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a23:	85 db                	test   %ebx,%ebx
  800a25:	74 98                	je     8009bf <strtol+0x66>
  800a27:	eb 9e                	jmp    8009c7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a29:	89 c2                	mov    %eax,%edx
  800a2b:	f7 da                	neg    %edx
  800a2d:	85 ff                	test   %edi,%edi
  800a2f:	0f 45 c2             	cmovne %edx,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5f                   	pop    %edi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	57                   	push   %edi
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a45:	8b 55 08             	mov    0x8(%ebp),%edx
  800a48:	89 c3                	mov    %eax,%ebx
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	89 c6                	mov    %eax,%esi
  800a4e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5f                   	pop    %edi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	57                   	push   %edi
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	b8 01 00 00 00       	mov    $0x1,%eax
  800a65:	89 d1                	mov    %edx,%ecx
  800a67:	89 d3                	mov    %edx,%ebx
  800a69:	89 d7                	mov    %edx,%edi
  800a6b:	89 d6                	mov    %edx,%esi
  800a6d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5f                   	pop    %edi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	57                   	push   %edi
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a82:	b8 03 00 00 00       	mov    $0x3,%eax
  800a87:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8a:	89 cb                	mov    %ecx,%ebx
  800a8c:	89 cf                	mov    %ecx,%edi
  800a8e:	89 ce                	mov    %ecx,%esi
  800a90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a92:	85 c0                	test   %eax,%eax
  800a94:	7e 17                	jle    800aad <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a96:	83 ec 0c             	sub    $0xc,%esp
  800a99:	50                   	push   %eax
  800a9a:	6a 03                	push   $0x3
  800a9c:	68 84 12 80 00       	push   $0x801284
  800aa1:	6a 23                	push   $0x23
  800aa3:	68 a1 12 80 00       	push   $0x8012a1
  800aa8:	e8 90 02 00 00       	call   800d3d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac5:	89 d1                	mov    %edx,%ecx
  800ac7:	89 d3                	mov    %edx,%ebx
  800ac9:	89 d7                	mov    %edx,%edi
  800acb:	89 d6                	mov    %edx,%esi
  800acd:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_yield>:

void
sys_yield(void)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	ba 00 00 00 00       	mov    $0x0,%edx
  800adf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae4:	89 d1                	mov    %edx,%ecx
  800ae6:	89 d3                	mov    %edx,%ebx
  800ae8:	89 d7                	mov    %edx,%edi
  800aea:	89 d6                	mov    %edx,%esi
  800aec:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	be 00 00 00 00       	mov    $0x0,%esi
  800b01:	b8 04 00 00 00       	mov    $0x4,%eax
  800b06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b09:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b0f:	89 f7                	mov    %esi,%edi
  800b11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b13:	85 c0                	test   %eax,%eax
  800b15:	7e 17                	jle    800b2e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b17:	83 ec 0c             	sub    $0xc,%esp
  800b1a:	50                   	push   %eax
  800b1b:	6a 04                	push   $0x4
  800b1d:	68 84 12 80 00       	push   $0x801284
  800b22:	6a 23                	push   $0x23
  800b24:	68 a1 12 80 00       	push   $0x8012a1
  800b29:	e8 0f 02 00 00       	call   800d3d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    

00800b36 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	57                   	push   %edi
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b50:	8b 75 18             	mov    0x18(%ebp),%esi
  800b53:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b55:	85 c0                	test   %eax,%eax
  800b57:	7e 17                	jle    800b70 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 05                	push   $0x5
  800b5f:	68 84 12 80 00       	push   $0x801284
  800b64:	6a 23                	push   $0x23
  800b66:	68 a1 12 80 00       	push   $0x8012a1
  800b6b:	e8 cd 01 00 00       	call   800d3d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b86:	b8 06 00 00 00       	mov    $0x6,%eax
  800b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b91:	89 df                	mov    %ebx,%edi
  800b93:	89 de                	mov    %ebx,%esi
  800b95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 06                	push   $0x6
  800ba1:	68 84 12 80 00       	push   $0x801284
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 a1 12 80 00       	push   $0x8012a1
  800bad:	e8 8b 01 00 00       	call   800d3d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd3:	89 df                	mov    %ebx,%edi
  800bd5:	89 de                	mov    %ebx,%esi
  800bd7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd9:	85 c0                	test   %eax,%eax
  800bdb:	7e 17                	jle    800bf4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 08                	push   $0x8
  800be3:	68 84 12 80 00       	push   $0x801284
  800be8:	6a 23                	push   $0x23
  800bea:	68 a1 12 80 00       	push   $0x8012a1
  800bef:	e8 49 01 00 00       	call   800d3d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
  800c02:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	89 df                	mov    %ebx,%edi
  800c17:	89 de                	mov    %ebx,%esi
  800c19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	7e 17                	jle    800c36 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 09                	push   $0x9
  800c25:	68 84 12 80 00       	push   $0x801284
  800c2a:	6a 23                	push   $0x23
  800c2c:	68 a1 12 80 00       	push   $0x8012a1
  800c31:	e8 07 01 00 00       	call   800d3d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	be 00 00 00 00       	mov    $0x0,%esi
  800c49:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c4e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 cb                	mov    %ecx,%ebx
  800c79:	89 cf                	mov    %ecx,%edi
  800c7b:	89 ce                	mov    %ecx,%esi
  800c7d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 0c                	push   $0xc
  800c89:	68 84 12 80 00       	push   $0x801284
  800c8e:	6a 23                	push   $0x23
  800c90:	68 a1 12 80 00       	push   $0x8012a1
  800c95:	e8 a3 00 00 00       	call   800d3d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	53                   	push   %ebx
  800ca6:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ca9:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cb0:	75 57                	jne    800d09 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  800cb2:	e8 fe fd ff ff       	call   800ab5 <sys_getenvid>
  800cb7:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800cb9:	83 ec 04             	sub    $0x4,%esp
  800cbc:	6a 07                	push   $0x7
  800cbe:	68 00 f0 bf ee       	push   $0xeebff000
  800cc3:	50                   	push   %eax
  800cc4:	e8 2a fe ff ff       	call   800af3 <sys_page_alloc>
		if (r < 0) {
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	85 c0                	test   %eax,%eax
  800cce:	79 12                	jns    800ce2 <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  800cd0:	50                   	push   %eax
  800cd1:	68 af 12 80 00       	push   $0x8012af
  800cd6:	6a 24                	push   $0x24
  800cd8:	68 c3 12 80 00       	push   $0x8012c3
  800cdd:	e8 5b 00 00 00       	call   800d3d <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  800ce2:	83 ec 08             	sub    $0x8,%esp
  800ce5:	68 16 0d 80 00       	push   $0x800d16
  800cea:	53                   	push   %ebx
  800ceb:	e8 0c ff ff ff       	call   800bfc <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800cf0:	83 c4 10             	add    $0x10,%esp
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	79 12                	jns    800d09 <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  800cf7:	50                   	push   %eax
  800cf8:	68 af 12 80 00       	push   $0x8012af
  800cfd:	6a 29                	push   $0x29
  800cff:	68 c3 12 80 00       	push   $0x8012c3
  800d04:	e8 34 00 00 00       	call   800d3d <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d09:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d16:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d17:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d1c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d1e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  800d21:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  800d25:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  800d28:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  800d2c:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  800d30:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800d33:	83 c4 08             	add    $0x8,%esp
	popal
  800d36:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800d37:	83 c4 04             	add    $0x4,%esp
	popfl
  800d3a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800d3b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800d3c:	c3                   	ret    

00800d3d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d42:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d45:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d4b:	e8 65 fd ff ff       	call   800ab5 <sys_getenvid>
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	ff 75 0c             	pushl  0xc(%ebp)
  800d56:	ff 75 08             	pushl  0x8(%ebp)
  800d59:	56                   	push   %esi
  800d5a:	50                   	push   %eax
  800d5b:	68 d4 12 80 00       	push   $0x8012d4
  800d60:	e8 06 f4 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d65:	83 c4 18             	add    $0x18,%esp
  800d68:	53                   	push   %ebx
  800d69:	ff 75 10             	pushl  0x10(%ebp)
  800d6c:	e8 a9 f3 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800d71:	c7 04 24 3a 10 80 00 	movl   $0x80103a,(%esp)
  800d78:	e8 ee f3 ff ff       	call   80016b <cprintf>
  800d7d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d80:	cc                   	int3   
  800d81:	eb fd                	jmp    800d80 <_panic+0x43>
  800d83:	66 90                	xchg   %ax,%ax
  800d85:	66 90                	xchg   %ax,%ax
  800d87:	66 90                	xchg   %ax,%ax
  800d89:	66 90                	xchg   %ax,%ax
  800d8b:	66 90                	xchg   %ax,%ax
  800d8d:	66 90                	xchg   %ax,%ax
  800d8f:	90                   	nop

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800da7:	85 f6                	test   %esi,%esi
  800da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dad:	89 ca                	mov    %ecx,%edx
  800daf:	89 f8                	mov    %edi,%eax
  800db1:	75 3d                	jne    800df0 <__udivdi3+0x60>
  800db3:	39 cf                	cmp    %ecx,%edi
  800db5:	0f 87 c5 00 00 00    	ja     800e80 <__udivdi3+0xf0>
  800dbb:	85 ff                	test   %edi,%edi
  800dbd:	89 fd                	mov    %edi,%ebp
  800dbf:	75 0b                	jne    800dcc <__udivdi3+0x3c>
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	31 d2                	xor    %edx,%edx
  800dc8:	f7 f7                	div    %edi
  800dca:	89 c5                	mov    %eax,%ebp
  800dcc:	89 c8                	mov    %ecx,%eax
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f5                	div    %ebp
  800dd2:	89 c1                	mov    %eax,%ecx
  800dd4:	89 d8                	mov    %ebx,%eax
  800dd6:	89 cf                	mov    %ecx,%edi
  800dd8:	f7 f5                	div    %ebp
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	39 ce                	cmp    %ecx,%esi
  800df2:	77 74                	ja     800e68 <__udivdi3+0xd8>
  800df4:	0f bd fe             	bsr    %esi,%edi
  800df7:	83 f7 1f             	xor    $0x1f,%edi
  800dfa:	0f 84 98 00 00 00    	je     800e98 <__udivdi3+0x108>
  800e00:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e05:	89 f9                	mov    %edi,%ecx
  800e07:	89 c5                	mov    %eax,%ebp
  800e09:	29 fb                	sub    %edi,%ebx
  800e0b:	d3 e6                	shl    %cl,%esi
  800e0d:	89 d9                	mov    %ebx,%ecx
  800e0f:	d3 ed                	shr    %cl,%ebp
  800e11:	89 f9                	mov    %edi,%ecx
  800e13:	d3 e0                	shl    %cl,%eax
  800e15:	09 ee                	or     %ebp,%esi
  800e17:	89 d9                	mov    %ebx,%ecx
  800e19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1d:	89 d5                	mov    %edx,%ebp
  800e1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e23:	d3 ed                	shr    %cl,%ebp
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	d3 e2                	shl    %cl,%edx
  800e29:	89 d9                	mov    %ebx,%ecx
  800e2b:	d3 e8                	shr    %cl,%eax
  800e2d:	09 c2                	or     %eax,%edx
  800e2f:	89 d0                	mov    %edx,%eax
  800e31:	89 ea                	mov    %ebp,%edx
  800e33:	f7 f6                	div    %esi
  800e35:	89 d5                	mov    %edx,%ebp
  800e37:	89 c3                	mov    %eax,%ebx
  800e39:	f7 64 24 0c          	mull   0xc(%esp)
  800e3d:	39 d5                	cmp    %edx,%ebp
  800e3f:	72 10                	jb     800e51 <__udivdi3+0xc1>
  800e41:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 e6                	shl    %cl,%esi
  800e49:	39 c6                	cmp    %eax,%esi
  800e4b:	73 07                	jae    800e54 <__udivdi3+0xc4>
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	75 03                	jne    800e54 <__udivdi3+0xc4>
  800e51:	83 eb 01             	sub    $0x1,%ebx
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 d8                	mov    %ebx,%eax
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	31 ff                	xor    %edi,%edi
  800e6a:	31 db                	xor    %ebx,%ebx
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	89 fa                	mov    %edi,%edx
  800e70:	83 c4 1c             	add    $0x1c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	f7 f7                	div    %edi
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	89 fa                	mov    %edi,%edx
  800e8c:	83 c4 1c             	add    $0x1c,%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	39 ce                	cmp    %ecx,%esi
  800e9a:	72 0c                	jb     800ea8 <__udivdi3+0x118>
  800e9c:	31 db                	xor    %ebx,%ebx
  800e9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ea2:	0f 87 34 ff ff ff    	ja     800ddc <__udivdi3+0x4c>
  800ea8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ead:	e9 2a ff ff ff       	jmp    800ddc <__udivdi3+0x4c>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 1c             	sub    $0x1c,%esp
  800ec7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ecb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800ecf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed7:	85 d2                	test   %edx,%edx
  800ed9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f3                	mov    %esi,%ebx
  800ee3:	89 3c 24             	mov    %edi,(%esp)
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	75 1c                	jne    800f08 <__umoddi3+0x48>
  800eec:	39 f7                	cmp    %esi,%edi
  800eee:	76 50                	jbe    800f40 <__umoddi3+0x80>
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	f7 f7                	div    %edi
  800ef6:	89 d0                	mov    %edx,%eax
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	89 d0                	mov    %edx,%eax
  800f0c:	77 52                	ja     800f60 <__umoddi3+0xa0>
  800f0e:	0f bd ea             	bsr    %edx,%ebp
  800f11:	83 f5 1f             	xor    $0x1f,%ebp
  800f14:	75 5a                	jne    800f70 <__umoddi3+0xb0>
  800f16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f1a:	0f 82 e0 00 00 00    	jb     801000 <__umoddi3+0x140>
  800f20:	39 0c 24             	cmp    %ecx,(%esp)
  800f23:	0f 86 d7 00 00 00    	jbe    801000 <__umoddi3+0x140>
  800f29:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f31:	83 c4 1c             	add    $0x1c,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	85 ff                	test   %edi,%edi
  800f42:	89 fd                	mov    %edi,%ebp
  800f44:	75 0b                	jne    800f51 <__umoddi3+0x91>
  800f46:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f7                	div    %edi
  800f4f:	89 c5                	mov    %eax,%ebp
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f5                	div    %ebp
  800f57:	89 c8                	mov    %ecx,%eax
  800f59:	f7 f5                	div    %ebp
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	eb 99                	jmp    800ef8 <__umoddi3+0x38>
  800f5f:	90                   	nop
  800f60:	89 c8                	mov    %ecx,%eax
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	83 c4 1c             	add    $0x1c,%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    
  800f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f70:	8b 34 24             	mov    (%esp),%esi
  800f73:	bf 20 00 00 00       	mov    $0x20,%edi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	29 ef                	sub    %ebp,%edi
  800f7c:	d3 e0                	shl    %cl,%eax
  800f7e:	89 f9                	mov    %edi,%ecx
  800f80:	89 f2                	mov    %esi,%edx
  800f82:	d3 ea                	shr    %cl,%edx
  800f84:	89 e9                	mov    %ebp,%ecx
  800f86:	09 c2                	or     %eax,%edx
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	89 14 24             	mov    %edx,(%esp)
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	d3 e2                	shl    %cl,%edx
  800f91:	89 f9                	mov    %edi,%ecx
  800f93:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	d3 e3                	shl    %cl,%ebx
  800fa3:	89 f9                	mov    %edi,%ecx
  800fa5:	89 d0                	mov    %edx,%eax
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	09 d8                	or     %ebx,%eax
  800fad:	89 d3                	mov    %edx,%ebx
  800faf:	89 f2                	mov    %esi,%edx
  800fb1:	f7 34 24             	divl   (%esp)
  800fb4:	89 d6                	mov    %edx,%esi
  800fb6:	d3 e3                	shl    %cl,%ebx
  800fb8:	f7 64 24 04          	mull   0x4(%esp)
  800fbc:	39 d6                	cmp    %edx,%esi
  800fbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	89 c3                	mov    %eax,%ebx
  800fc6:	72 08                	jb     800fd0 <__umoddi3+0x110>
  800fc8:	75 11                	jne    800fdb <__umoddi3+0x11b>
  800fca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fce:	73 0b                	jae    800fdb <__umoddi3+0x11b>
  800fd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fd4:	1b 14 24             	sbb    (%esp),%edx
  800fd7:	89 d1                	mov    %edx,%ecx
  800fd9:	89 c3                	mov    %eax,%ebx
  800fdb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fdf:	29 da                	sub    %ebx,%edx
  800fe1:	19 ce                	sbb    %ecx,%esi
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e0                	shl    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	d3 ea                	shr    %cl,%edx
  800fed:	89 e9                	mov    %ebp,%ecx
  800fef:	d3 ee                	shr    %cl,%esi
  800ff1:	09 d0                	or     %edx,%eax
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	83 c4 1c             	add    $0x1c,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	29 f9                	sub    %edi,%ecx
  801002:	19 d6                	sbb    %edx,%esi
  801004:	89 74 24 04          	mov    %esi,0x4(%esp)
  801008:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80100c:	e9 18 ff ff ff       	jmp    800f29 <__umoddi3+0x69>
