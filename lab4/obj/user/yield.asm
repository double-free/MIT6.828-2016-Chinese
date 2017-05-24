
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 a0 0f 80 00       	push   $0x800fa0
  800048:	e8 38 01 00 00       	call   800185 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 94 0a 00 00       	call   800aee <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 c0 0f 80 00       	push   $0x800fc0
  80006c:	e8 14 01 00 00       	call   800185 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 ec 0f 80 00       	push   $0x800fec
  80008d:	e8 f3 00 00 00       	call   800185 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 25 0a 00 00       	call   800acf <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 a1 09 00 00       	call   800a8e <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	75 1a                	jne    80012b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800111:	83 ec 08             	sub    $0x8,%esp
  800114:	68 ff 00 00 00       	push   $0xff
  800119:	8d 43 08             	lea    0x8(%ebx),%eax
  80011c:	50                   	push   %eax
  80011d:	e8 2f 09 00 00       	call   800a51 <sys_cputs>
		b->idx = 0;
  800122:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800128:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	ff 75 0c             	pushl  0xc(%ebp)
  800154:	ff 75 08             	pushl  0x8(%ebp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	68 f2 00 80 00       	push   $0x8000f2
  800163:	e8 54 01 00 00       	call   8002bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800168:	83 c4 08             	add    $0x8,%esp
  80016b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800171:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800177:	50                   	push   %eax
  800178:	e8 d4 08 00 00       	call   800a51 <sys_cputs>

	return b.cnt;
}
  80017d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800183:	c9                   	leave  
  800184:	c3                   	ret    

00800185 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80018e:	50                   	push   %eax
  80018f:	ff 75 08             	pushl  0x8(%ebp)
  800192:	e8 9d ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 1c             	sub    $0x1c,%esp
  8001a2:	89 c7                	mov    %eax,%edi
  8001a4:	89 d6                	mov    %edx,%esi
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001af:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001bd:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c0:	39 d3                	cmp    %edx,%ebx
  8001c2:	72 05                	jb     8001c9 <printnum+0x30>
  8001c4:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c7:	77 45                	ja     80020e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	ff 75 18             	pushl  0x18(%ebp)
  8001cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d5:	53                   	push   %ebx
  8001d6:	ff 75 10             	pushl  0x10(%ebp)
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001df:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e8:	e8 23 0b 00 00       	call   800d10 <__udivdi3>
  8001ed:	83 c4 18             	add    $0x18,%esp
  8001f0:	52                   	push   %edx
  8001f1:	50                   	push   %eax
  8001f2:	89 f2                	mov    %esi,%edx
  8001f4:	89 f8                	mov    %edi,%eax
  8001f6:	e8 9e ff ff ff       	call   800199 <printnum>
  8001fb:	83 c4 20             	add    $0x20,%esp
  8001fe:	eb 18                	jmp    800218 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	56                   	push   %esi
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	ff d7                	call   *%edi
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb 03                	jmp    800211 <printnum+0x78>
  80020e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800211:	83 eb 01             	sub    $0x1,%ebx
  800214:	85 db                	test   %ebx,%ebx
  800216:	7f e8                	jg     800200 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	56                   	push   %esi
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800222:	ff 75 e0             	pushl  -0x20(%ebp)
  800225:	ff 75 dc             	pushl  -0x24(%ebp)
  800228:	ff 75 d8             	pushl  -0x28(%ebp)
  80022b:	e8 10 0c 00 00       	call   800e40 <__umoddi3>
  800230:	83 c4 14             	add    $0x14,%esp
  800233:	0f be 80 15 10 80 00 	movsbl 0x801015(%eax),%eax
  80023a:	50                   	push   %eax
  80023b:	ff d7                	call   *%edi
}
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80024b:	83 fa 01             	cmp    $0x1,%edx
  80024e:	7e 0e                	jle    80025e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800250:	8b 10                	mov    (%eax),%edx
  800252:	8d 4a 08             	lea    0x8(%edx),%ecx
  800255:	89 08                	mov    %ecx,(%eax)
  800257:	8b 02                	mov    (%edx),%eax
  800259:	8b 52 04             	mov    0x4(%edx),%edx
  80025c:	eb 22                	jmp    800280 <getuint+0x38>
	else if (lflag)
  80025e:	85 d2                	test   %edx,%edx
  800260:	74 10                	je     800272 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800262:	8b 10                	mov    (%eax),%edx
  800264:	8d 4a 04             	lea    0x4(%edx),%ecx
  800267:	89 08                	mov    %ecx,(%eax)
  800269:	8b 02                	mov    (%edx),%eax
  80026b:	ba 00 00 00 00       	mov    $0x0,%edx
  800270:	eb 0e                	jmp    800280 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800272:	8b 10                	mov    (%eax),%edx
  800274:	8d 4a 04             	lea    0x4(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 02                	mov    (%edx),%eax
  80027b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    

00800282 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800288:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	3b 50 04             	cmp    0x4(%eax),%edx
  800291:	73 0a                	jae    80029d <sprintputch+0x1b>
		*b->buf++ = ch;
  800293:	8d 4a 01             	lea    0x1(%edx),%ecx
  800296:	89 08                	mov    %ecx,(%eax)
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	88 02                	mov    %al,(%edx)
}
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a8:	50                   	push   %eax
  8002a9:	ff 75 10             	pushl  0x10(%ebp)
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	ff 75 08             	pushl  0x8(%ebp)
  8002b2:	e8 05 00 00 00       	call   8002bc <vprintfmt>
	va_end(ap);
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 2c             	sub    $0x2c,%esp
  8002c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002cb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ce:	eb 12                	jmp    8002e2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	0f 84 89 03 00 00    	je     800661 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002d8:	83 ec 08             	sub    $0x8,%esp
  8002db:	53                   	push   %ebx
  8002dc:	50                   	push   %eax
  8002dd:	ff d6                	call   *%esi
  8002df:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e2:	83 c7 01             	add    $0x1,%edi
  8002e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002e9:	83 f8 25             	cmp    $0x25,%eax
  8002ec:	75 e2                	jne    8002d0 <vprintfmt+0x14>
  8002ee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800300:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800307:	ba 00 00 00 00       	mov    $0x0,%edx
  80030c:	eb 07                	jmp    800315 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800311:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8d 47 01             	lea    0x1(%edi),%eax
  800318:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031b:	0f b6 07             	movzbl (%edi),%eax
  80031e:	0f b6 c8             	movzbl %al,%ecx
  800321:	83 e8 23             	sub    $0x23,%eax
  800324:	3c 55                	cmp    $0x55,%al
  800326:	0f 87 1a 03 00 00    	ja     800646 <vprintfmt+0x38a>
  80032c:	0f b6 c0             	movzbl %al,%eax
  80032f:	ff 24 85 e0 10 80 00 	jmp    *0x8010e0(,%eax,4)
  800336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800339:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80033d:	eb d6                	jmp    800315 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800342:	b8 00 00 00 00       	mov    $0x0,%eax
  800347:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80034a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800351:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800354:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800357:	83 fa 09             	cmp    $0x9,%edx
  80035a:	77 39                	ja     800395 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80035c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80035f:	eb e9                	jmp    80034a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800361:	8b 45 14             	mov    0x14(%ebp),%eax
  800364:	8d 48 04             	lea    0x4(%eax),%ecx
  800367:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80036a:	8b 00                	mov    (%eax),%eax
  80036c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800372:	eb 27                	jmp    80039b <vprintfmt+0xdf>
  800374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800377:	85 c0                	test   %eax,%eax
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	0f 49 c8             	cmovns %eax,%ecx
  800381:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800387:	eb 8c                	jmp    800315 <vprintfmt+0x59>
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80038c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800393:	eb 80                	jmp    800315 <vprintfmt+0x59>
  800395:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80039b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039f:	0f 89 70 ff ff ff    	jns    800315 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b2:	e9 5e ff ff ff       	jmp    800315 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b7:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003bd:	e9 53 ff ff ff       	jmp    800315 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 50 04             	lea    0x4(%eax),%edx
  8003c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	53                   	push   %ebx
  8003cf:	ff 30                	pushl  (%eax)
  8003d1:	ff d6                	call   *%esi
			break;
  8003d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d9:	e9 04 ff ff ff       	jmp    8002e2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8d 50 04             	lea    0x4(%eax),%edx
  8003e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e7:	8b 00                	mov    (%eax),%eax
  8003e9:	99                   	cltd   
  8003ea:	31 d0                	xor    %edx,%eax
  8003ec:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ee:	83 f8 08             	cmp    $0x8,%eax
  8003f1:	7f 0b                	jg     8003fe <vprintfmt+0x142>
  8003f3:	8b 14 85 40 12 80 00 	mov    0x801240(,%eax,4),%edx
  8003fa:	85 d2                	test   %edx,%edx
  8003fc:	75 18                	jne    800416 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003fe:	50                   	push   %eax
  8003ff:	68 2d 10 80 00       	push   $0x80102d
  800404:	53                   	push   %ebx
  800405:	56                   	push   %esi
  800406:	e8 94 fe ff ff       	call   80029f <printfmt>
  80040b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800411:	e9 cc fe ff ff       	jmp    8002e2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800416:	52                   	push   %edx
  800417:	68 36 10 80 00       	push   $0x801036
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 7c fe ff ff       	call   80029f <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800429:	e9 b4 fe ff ff       	jmp    8002e2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800439:	85 ff                	test   %edi,%edi
  80043b:	b8 26 10 80 00       	mov    $0x801026,%eax
  800440:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800443:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800447:	0f 8e 94 00 00 00    	jle    8004e1 <vprintfmt+0x225>
  80044d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800451:	0f 84 98 00 00 00    	je     8004ef <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	ff 75 d0             	pushl  -0x30(%ebp)
  80045d:	57                   	push   %edi
  80045e:	e8 86 02 00 00       	call   8006e9 <strnlen>
  800463:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800466:	29 c1                	sub    %eax,%ecx
  800468:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80046b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800478:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	eb 0f                	jmp    80048b <vprintfmt+0x1cf>
					putch(padc, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	53                   	push   %ebx
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800485:	83 ef 01             	sub    $0x1,%edi
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 ff                	test   %edi,%edi
  80048d:	7f ed                	jg     80047c <vprintfmt+0x1c0>
  80048f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800492:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800495:	85 c9                	test   %ecx,%ecx
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	0f 49 c1             	cmovns %ecx,%eax
  80049f:	29 c1                	sub    %eax,%ecx
  8004a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004aa:	89 cb                	mov    %ecx,%ebx
  8004ac:	eb 4d                	jmp    8004fb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b2:	74 1b                	je     8004cf <vprintfmt+0x213>
  8004b4:	0f be c0             	movsbl %al,%eax
  8004b7:	83 e8 20             	sub    $0x20,%eax
  8004ba:	83 f8 5e             	cmp    $0x5e,%eax
  8004bd:	76 10                	jbe    8004cf <vprintfmt+0x213>
					putch('?', putdat);
  8004bf:	83 ec 08             	sub    $0x8,%esp
  8004c2:	ff 75 0c             	pushl  0xc(%ebp)
  8004c5:	6a 3f                	push   $0x3f
  8004c7:	ff 55 08             	call   *0x8(%ebp)
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	eb 0d                	jmp    8004dc <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004cf:	83 ec 08             	sub    $0x8,%esp
  8004d2:	ff 75 0c             	pushl  0xc(%ebp)
  8004d5:	52                   	push   %edx
  8004d6:	ff 55 08             	call   *0x8(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dc:	83 eb 01             	sub    $0x1,%ebx
  8004df:	eb 1a                	jmp    8004fb <vprintfmt+0x23f>
  8004e1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ed:	eb 0c                	jmp    8004fb <vprintfmt+0x23f>
  8004ef:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fb:	83 c7 01             	add    $0x1,%edi
  8004fe:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800502:	0f be d0             	movsbl %al,%edx
  800505:	85 d2                	test   %edx,%edx
  800507:	74 23                	je     80052c <vprintfmt+0x270>
  800509:	85 f6                	test   %esi,%esi
  80050b:	78 a1                	js     8004ae <vprintfmt+0x1f2>
  80050d:	83 ee 01             	sub    $0x1,%esi
  800510:	79 9c                	jns    8004ae <vprintfmt+0x1f2>
  800512:	89 df                	mov    %ebx,%edi
  800514:	8b 75 08             	mov    0x8(%ebp),%esi
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051a:	eb 18                	jmp    800534 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 20                	push   $0x20
  800522:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800524:	83 ef 01             	sub    $0x1,%edi
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb 08                	jmp    800534 <vprintfmt+0x278>
  80052c:	89 df                	mov    %ebx,%edi
  80052e:	8b 75 08             	mov    0x8(%ebp),%esi
  800531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800534:	85 ff                	test   %edi,%edi
  800536:	7f e4                	jg     80051c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053b:	e9 a2 fd ff ff       	jmp    8002e2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800540:	83 fa 01             	cmp    $0x1,%edx
  800543:	7e 16                	jle    80055b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800545:	8b 45 14             	mov    0x14(%ebp),%eax
  800548:	8d 50 08             	lea    0x8(%eax),%edx
  80054b:	89 55 14             	mov    %edx,0x14(%ebp)
  80054e:	8b 50 04             	mov    0x4(%eax),%edx
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800559:	eb 32                	jmp    80058d <vprintfmt+0x2d1>
	else if (lflag)
  80055b:	85 d2                	test   %edx,%edx
  80055d:	74 18                	je     800577 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056d:	89 c1                	mov    %eax,%ecx
  80056f:	c1 f9 1f             	sar    $0x1f,%ecx
  800572:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800575:	eb 16                	jmp    80058d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 50 04             	lea    0x4(%eax),%edx
  80057d:	89 55 14             	mov    %edx,0x14(%ebp)
  800580:	8b 00                	mov    (%eax),%eax
  800582:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800585:	89 c1                	mov    %eax,%ecx
  800587:	c1 f9 1f             	sar    $0x1f,%ecx
  80058a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800590:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800593:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800598:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059c:	79 74                	jns    800612 <vprintfmt+0x356>
				putch('-', putdat);
  80059e:	83 ec 08             	sub    $0x8,%esp
  8005a1:	53                   	push   %ebx
  8005a2:	6a 2d                	push   $0x2d
  8005a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ac:	f7 d8                	neg    %eax
  8005ae:	83 d2 00             	adc    $0x0,%edx
  8005b1:	f7 da                	neg    %edx
  8005b3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005b6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005bb:	eb 55                	jmp    800612 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c0:	e8 83 fc ff ff       	call   800248 <getuint>
			base = 10;
  8005c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ca:	eb 46                	jmp    800612 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005cc:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cf:	e8 74 fc ff ff       	call   800248 <getuint>
			base = 8;
  8005d4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005d9:	eb 37                	jmp    800612 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 30                	push   $0x30
  8005e1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e3:	83 c4 08             	add    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 78                	push   $0x78
  8005e9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 04             	lea    0x4(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005f4:	8b 00                	mov    (%eax),%eax
  8005f6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005fb:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005fe:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800603:	eb 0d                	jmp    800612 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800605:	8d 45 14             	lea    0x14(%ebp),%eax
  800608:	e8 3b fc ff ff       	call   800248 <getuint>
			base = 16;
  80060d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800612:	83 ec 0c             	sub    $0xc,%esp
  800615:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800619:	57                   	push   %edi
  80061a:	ff 75 e0             	pushl  -0x20(%ebp)
  80061d:	51                   	push   %ecx
  80061e:	52                   	push   %edx
  80061f:	50                   	push   %eax
  800620:	89 da                	mov    %ebx,%edx
  800622:	89 f0                	mov    %esi,%eax
  800624:	e8 70 fb ff ff       	call   800199 <printnum>
			break;
  800629:	83 c4 20             	add    $0x20,%esp
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80062f:	e9 ae fc ff ff       	jmp    8002e2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	51                   	push   %ecx
  800639:	ff d6                	call   *%esi
			break;
  80063b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800641:	e9 9c fc ff ff       	jmp    8002e2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800646:	83 ec 08             	sub    $0x8,%esp
  800649:	53                   	push   %ebx
  80064a:	6a 25                	push   $0x25
  80064c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064e:	83 c4 10             	add    $0x10,%esp
  800651:	eb 03                	jmp    800656 <vprintfmt+0x39a>
  800653:	83 ef 01             	sub    $0x1,%edi
  800656:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80065a:	75 f7                	jne    800653 <vprintfmt+0x397>
  80065c:	e9 81 fc ff ff       	jmp    8002e2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800661:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800664:	5b                   	pop    %ebx
  800665:	5e                   	pop    %esi
  800666:	5f                   	pop    %edi
  800667:	5d                   	pop    %ebp
  800668:	c3                   	ret    

00800669 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800669:	55                   	push   %ebp
  80066a:	89 e5                	mov    %esp,%ebp
  80066c:	83 ec 18             	sub    $0x18,%esp
  80066f:	8b 45 08             	mov    0x8(%ebp),%eax
  800672:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800675:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800678:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80067c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800686:	85 c0                	test   %eax,%eax
  800688:	74 26                	je     8006b0 <vsnprintf+0x47>
  80068a:	85 d2                	test   %edx,%edx
  80068c:	7e 22                	jle    8006b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068e:	ff 75 14             	pushl  0x14(%ebp)
  800691:	ff 75 10             	pushl  0x10(%ebp)
  800694:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800697:	50                   	push   %eax
  800698:	68 82 02 80 00       	push   $0x800282
  80069d:	e8 1a fc ff ff       	call   8002bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	eb 05                	jmp    8006b5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b5:	c9                   	leave  
  8006b6:	c3                   	ret    

008006b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b7:	55                   	push   %ebp
  8006b8:	89 e5                	mov    %esp,%ebp
  8006ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c0:	50                   	push   %eax
  8006c1:	ff 75 10             	pushl  0x10(%ebp)
  8006c4:	ff 75 0c             	pushl  0xc(%ebp)
  8006c7:	ff 75 08             	pushl  0x8(%ebp)
  8006ca:	e8 9a ff ff ff       	call   800669 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cf:	c9                   	leave  
  8006d0:	c3                   	ret    

008006d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
  8006d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006dc:	eb 03                	jmp    8006e1 <strlen+0x10>
		n++;
  8006de:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e5:	75 f7                	jne    8006de <strlen+0xd>
		n++;
	return n;
}
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f7:	eb 03                	jmp    8006fc <strnlen+0x13>
		n++;
  8006f9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006fc:	39 c2                	cmp    %eax,%edx
  8006fe:	74 08                	je     800708 <strnlen+0x1f>
  800700:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800704:	75 f3                	jne    8006f9 <strnlen+0x10>
  800706:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	8b 45 08             	mov    0x8(%ebp),%eax
  800711:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800714:	89 c2                	mov    %eax,%edx
  800716:	83 c2 01             	add    $0x1,%edx
  800719:	83 c1 01             	add    $0x1,%ecx
  80071c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800720:	88 5a ff             	mov    %bl,-0x1(%edx)
  800723:	84 db                	test   %bl,%bl
  800725:	75 ef                	jne    800716 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800727:	5b                   	pop    %ebx
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	53                   	push   %ebx
  80072e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800731:	53                   	push   %ebx
  800732:	e8 9a ff ff ff       	call   8006d1 <strlen>
  800737:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	01 d8                	add    %ebx,%eax
  80073f:	50                   	push   %eax
  800740:	e8 c5 ff ff ff       	call   80070a <strcpy>
	return dst;
}
  800745:	89 d8                	mov    %ebx,%eax
  800747:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	56                   	push   %esi
  800750:	53                   	push   %ebx
  800751:	8b 75 08             	mov    0x8(%ebp),%esi
  800754:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800757:	89 f3                	mov    %esi,%ebx
  800759:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075c:	89 f2                	mov    %esi,%edx
  80075e:	eb 0f                	jmp    80076f <strncpy+0x23>
		*dst++ = *src;
  800760:	83 c2 01             	add    $0x1,%edx
  800763:	0f b6 01             	movzbl (%ecx),%eax
  800766:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800769:	80 39 01             	cmpb   $0x1,(%ecx)
  80076c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076f:	39 da                	cmp    %ebx,%edx
  800771:	75 ed                	jne    800760 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800773:	89 f0                	mov    %esi,%eax
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5d                   	pop    %ebp
  800778:	c3                   	ret    

00800779 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800779:	55                   	push   %ebp
  80077a:	89 e5                	mov    %esp,%ebp
  80077c:	56                   	push   %esi
  80077d:	53                   	push   %ebx
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800784:	8b 55 10             	mov    0x10(%ebp),%edx
  800787:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800789:	85 d2                	test   %edx,%edx
  80078b:	74 21                	je     8007ae <strlcpy+0x35>
  80078d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800791:	89 f2                	mov    %esi,%edx
  800793:	eb 09                	jmp    80079e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800795:	83 c2 01             	add    $0x1,%edx
  800798:	83 c1 01             	add    $0x1,%ecx
  80079b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079e:	39 c2                	cmp    %eax,%edx
  8007a0:	74 09                	je     8007ab <strlcpy+0x32>
  8007a2:	0f b6 19             	movzbl (%ecx),%ebx
  8007a5:	84 db                	test   %bl,%bl
  8007a7:	75 ec                	jne    800795 <strlcpy+0x1c>
  8007a9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ae:	29 f0                	sub    %esi,%eax
}
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ba:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007bd:	eb 06                	jmp    8007c5 <strcmp+0x11>
		p++, q++;
  8007bf:	83 c1 01             	add    $0x1,%ecx
  8007c2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c5:	0f b6 01             	movzbl (%ecx),%eax
  8007c8:	84 c0                	test   %al,%al
  8007ca:	74 04                	je     8007d0 <strcmp+0x1c>
  8007cc:	3a 02                	cmp    (%edx),%al
  8007ce:	74 ef                	je     8007bf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d0:	0f b6 c0             	movzbl %al,%eax
  8007d3:	0f b6 12             	movzbl (%edx),%edx
  8007d6:	29 d0                	sub    %edx,%eax
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	53                   	push   %ebx
  8007de:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e4:	89 c3                	mov    %eax,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e9:	eb 06                	jmp    8007f1 <strncmp+0x17>
		n--, p++, q++;
  8007eb:	83 c0 01             	add    $0x1,%eax
  8007ee:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f1:	39 d8                	cmp    %ebx,%eax
  8007f3:	74 15                	je     80080a <strncmp+0x30>
  8007f5:	0f b6 08             	movzbl (%eax),%ecx
  8007f8:	84 c9                	test   %cl,%cl
  8007fa:	74 04                	je     800800 <strncmp+0x26>
  8007fc:	3a 0a                	cmp    (%edx),%cl
  8007fe:	74 eb                	je     8007eb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800800:	0f b6 00             	movzbl (%eax),%eax
  800803:	0f b6 12             	movzbl (%edx),%edx
  800806:	29 d0                	sub    %edx,%eax
  800808:	eb 05                	jmp    80080f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80080a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80081c:	eb 07                	jmp    800825 <strchr+0x13>
		if (*s == c)
  80081e:	38 ca                	cmp    %cl,%dl
  800820:	74 0f                	je     800831 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800822:	83 c0 01             	add    $0x1,%eax
  800825:	0f b6 10             	movzbl (%eax),%edx
  800828:	84 d2                	test   %dl,%dl
  80082a:	75 f2                	jne    80081e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80082c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800831:	5d                   	pop    %ebp
  800832:	c3                   	ret    

00800833 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083d:	eb 03                	jmp    800842 <strfind+0xf>
  80083f:	83 c0 01             	add    $0x1,%eax
  800842:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800845:	38 ca                	cmp    %cl,%dl
  800847:	74 04                	je     80084d <strfind+0x1a>
  800849:	84 d2                	test   %dl,%dl
  80084b:	75 f2                	jne    80083f <strfind+0xc>
			break;
	return (char *) s;
}
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	57                   	push   %edi
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
  800855:	8b 7d 08             	mov    0x8(%ebp),%edi
  800858:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	74 36                	je     800895 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800865:	75 28                	jne    80088f <memset+0x40>
  800867:	f6 c1 03             	test   $0x3,%cl
  80086a:	75 23                	jne    80088f <memset+0x40>
		c &= 0xFF;
  80086c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800870:	89 d3                	mov    %edx,%ebx
  800872:	c1 e3 08             	shl    $0x8,%ebx
  800875:	89 d6                	mov    %edx,%esi
  800877:	c1 e6 18             	shl    $0x18,%esi
  80087a:	89 d0                	mov    %edx,%eax
  80087c:	c1 e0 10             	shl    $0x10,%eax
  80087f:	09 f0                	or     %esi,%eax
  800881:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800883:	89 d8                	mov    %ebx,%eax
  800885:	09 d0                	or     %edx,%eax
  800887:	c1 e9 02             	shr    $0x2,%ecx
  80088a:	fc                   	cld    
  80088b:	f3 ab                	rep stos %eax,%es:(%edi)
  80088d:	eb 06                	jmp    800895 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800892:	fc                   	cld    
  800893:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800895:	89 f8                	mov    %edi,%eax
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5f                   	pop    %edi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	57                   	push   %edi
  8008a0:	56                   	push   %esi
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008aa:	39 c6                	cmp    %eax,%esi
  8008ac:	73 35                	jae    8008e3 <memmove+0x47>
  8008ae:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b1:	39 d0                	cmp    %edx,%eax
  8008b3:	73 2e                	jae    8008e3 <memmove+0x47>
		s += n;
		d += n;
  8008b5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b8:	89 d6                	mov    %edx,%esi
  8008ba:	09 fe                	or     %edi,%esi
  8008bc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c2:	75 13                	jne    8008d7 <memmove+0x3b>
  8008c4:	f6 c1 03             	test   $0x3,%cl
  8008c7:	75 0e                	jne    8008d7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c9:	83 ef 04             	sub    $0x4,%edi
  8008cc:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cf:	c1 e9 02             	shr    $0x2,%ecx
  8008d2:	fd                   	std    
  8008d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d5:	eb 09                	jmp    8008e0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d7:	83 ef 01             	sub    $0x1,%edi
  8008da:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008dd:	fd                   	std    
  8008de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e0:	fc                   	cld    
  8008e1:	eb 1d                	jmp    800900 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e3:	89 f2                	mov    %esi,%edx
  8008e5:	09 c2                	or     %eax,%edx
  8008e7:	f6 c2 03             	test   $0x3,%dl
  8008ea:	75 0f                	jne    8008fb <memmove+0x5f>
  8008ec:	f6 c1 03             	test   $0x3,%cl
  8008ef:	75 0a                	jne    8008fb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f1:	c1 e9 02             	shr    $0x2,%ecx
  8008f4:	89 c7                	mov    %eax,%edi
  8008f6:	fc                   	cld    
  8008f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f9:	eb 05                	jmp    800900 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008fb:	89 c7                	mov    %eax,%edi
  8008fd:	fc                   	cld    
  8008fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800907:	ff 75 10             	pushl  0x10(%ebp)
  80090a:	ff 75 0c             	pushl  0xc(%ebp)
  80090d:	ff 75 08             	pushl  0x8(%ebp)
  800910:	e8 87 ff ff ff       	call   80089c <memmove>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800922:	89 c6                	mov    %eax,%esi
  800924:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800927:	eb 1a                	jmp    800943 <memcmp+0x2c>
		if (*s1 != *s2)
  800929:	0f b6 08             	movzbl (%eax),%ecx
  80092c:	0f b6 1a             	movzbl (%edx),%ebx
  80092f:	38 d9                	cmp    %bl,%cl
  800931:	74 0a                	je     80093d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800933:	0f b6 c1             	movzbl %cl,%eax
  800936:	0f b6 db             	movzbl %bl,%ebx
  800939:	29 d8                	sub    %ebx,%eax
  80093b:	eb 0f                	jmp    80094c <memcmp+0x35>
		s1++, s2++;
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800943:	39 f0                	cmp    %esi,%eax
  800945:	75 e2                	jne    800929 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80094c:	5b                   	pop    %ebx
  80094d:	5e                   	pop    %esi
  80094e:	5d                   	pop    %ebp
  80094f:	c3                   	ret    

00800950 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	53                   	push   %ebx
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800957:	89 c1                	mov    %eax,%ecx
  800959:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80095c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800960:	eb 0a                	jmp    80096c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800962:	0f b6 10             	movzbl (%eax),%edx
  800965:	39 da                	cmp    %ebx,%edx
  800967:	74 07                	je     800970 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	39 c8                	cmp    %ecx,%eax
  80096e:	72 f2                	jb     800962 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800970:	5b                   	pop    %ebx
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	57                   	push   %edi
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097f:	eb 03                	jmp    800984 <strtol+0x11>
		s++;
  800981:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800984:	0f b6 01             	movzbl (%ecx),%eax
  800987:	3c 20                	cmp    $0x20,%al
  800989:	74 f6                	je     800981 <strtol+0xe>
  80098b:	3c 09                	cmp    $0x9,%al
  80098d:	74 f2                	je     800981 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098f:	3c 2b                	cmp    $0x2b,%al
  800991:	75 0a                	jne    80099d <strtol+0x2a>
		s++;
  800993:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800996:	bf 00 00 00 00       	mov    $0x0,%edi
  80099b:	eb 11                	jmp    8009ae <strtol+0x3b>
  80099d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a2:	3c 2d                	cmp    $0x2d,%al
  8009a4:	75 08                	jne    8009ae <strtol+0x3b>
		s++, neg = 1;
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ae:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b4:	75 15                	jne    8009cb <strtol+0x58>
  8009b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b9:	75 10                	jne    8009cb <strtol+0x58>
  8009bb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bf:	75 7c                	jne    800a3d <strtol+0xca>
		s += 2, base = 16;
  8009c1:	83 c1 02             	add    $0x2,%ecx
  8009c4:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c9:	eb 16                	jmp    8009e1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009cb:	85 db                	test   %ebx,%ebx
  8009cd:	75 12                	jne    8009e1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d4:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d7:	75 08                	jne    8009e1 <strtol+0x6e>
		s++, base = 8;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e9:	0f b6 11             	movzbl (%ecx),%edx
  8009ec:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ef:	89 f3                	mov    %esi,%ebx
  8009f1:	80 fb 09             	cmp    $0x9,%bl
  8009f4:	77 08                	ja     8009fe <strtol+0x8b>
			dig = *s - '0';
  8009f6:	0f be d2             	movsbl %dl,%edx
  8009f9:	83 ea 30             	sub    $0x30,%edx
  8009fc:	eb 22                	jmp    800a20 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fe:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	80 fb 19             	cmp    $0x19,%bl
  800a06:	77 08                	ja     800a10 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a08:	0f be d2             	movsbl %dl,%edx
  800a0b:	83 ea 57             	sub    $0x57,%edx
  800a0e:	eb 10                	jmp    800a20 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a10:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 19             	cmp    $0x19,%bl
  800a18:	77 16                	ja     800a30 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a20:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a23:	7d 0b                	jge    800a30 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a2c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a2e:	eb b9                	jmp    8009e9 <strtol+0x76>

	if (endptr)
  800a30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a34:	74 0d                	je     800a43 <strtol+0xd0>
		*endptr = (char *) s;
  800a36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a39:	89 0e                	mov    %ecx,(%esi)
  800a3b:	eb 06                	jmp    800a43 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3d:	85 db                	test   %ebx,%ebx
  800a3f:	74 98                	je     8009d9 <strtol+0x66>
  800a41:	eb 9e                	jmp    8009e1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	f7 da                	neg    %edx
  800a47:	85 ff                	test   %edi,%edi
  800a49:	0f 45 c2             	cmovne %edx,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5f                   	pop    %edi
  800a4f:	5d                   	pop    %ebp
  800a50:	c3                   	ret    

00800a51 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	57                   	push   %edi
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a62:	89 c3                	mov    %eax,%ebx
  800a64:	89 c7                	mov    %eax,%edi
  800a66:	89 c6                	mov    %eax,%esi
  800a68:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a75:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7f:	89 d1                	mov    %edx,%ecx
  800a81:	89 d3                	mov    %edx,%ebx
  800a83:	89 d7                	mov    %edx,%edi
  800a85:	89 d6                	mov    %edx,%esi
  800a87:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a89:	5b                   	pop    %ebx
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	57                   	push   %edi
  800a92:	56                   	push   %esi
  800a93:	53                   	push   %ebx
  800a94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a97:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa4:	89 cb                	mov    %ecx,%ebx
  800aa6:	89 cf                	mov    %ecx,%edi
  800aa8:	89 ce                	mov    %ecx,%esi
  800aaa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aac:	85 c0                	test   %eax,%eax
  800aae:	7e 17                	jle    800ac7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab0:	83 ec 0c             	sub    $0xc,%esp
  800ab3:	50                   	push   %eax
  800ab4:	6a 03                	push   $0x3
  800ab6:	68 64 12 80 00       	push   $0x801264
  800abb:	6a 23                	push   $0x23
  800abd:	68 81 12 80 00       	push   $0x801281
  800ac2:	e8 f5 01 00 00       	call   800cbc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aca:	5b                   	pop    %ebx
  800acb:	5e                   	pop    %esi
  800acc:	5f                   	pop    %edi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	57                   	push   %edi
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 02 00 00 00       	mov    $0x2,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <sys_yield>:

void
sys_yield(void)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af4:	ba 00 00 00 00       	mov    $0x0,%edx
  800af9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afe:	89 d1                	mov    %edx,%ecx
  800b00:	89 d3                	mov    %edx,%ebx
  800b02:	89 d7                	mov    %edx,%edi
  800b04:	89 d6                	mov    %edx,%esi
  800b06:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	57                   	push   %edi
  800b11:	56                   	push   %esi
  800b12:	53                   	push   %ebx
  800b13:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b16:	be 00 00 00 00       	mov    $0x0,%esi
  800b1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b29:	89 f7                	mov    %esi,%edi
  800b2b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b2d:	85 c0                	test   %eax,%eax
  800b2f:	7e 17                	jle    800b48 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	50                   	push   %eax
  800b35:	6a 04                	push   $0x4
  800b37:	68 64 12 80 00       	push   $0x801264
  800b3c:	6a 23                	push   $0x23
  800b3e:	68 81 12 80 00       	push   $0x801281
  800b43:	e8 74 01 00 00       	call   800cbc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4b:	5b                   	pop    %ebx
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    

00800b50 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	57                   	push   %edi
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	b8 05 00 00 00       	mov    $0x5,%eax
  800b5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b61:	8b 55 08             	mov    0x8(%ebp),%edx
  800b64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b6a:	8b 75 18             	mov    0x18(%ebp),%esi
  800b6d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	7e 17                	jle    800b8a <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b73:	83 ec 0c             	sub    $0xc,%esp
  800b76:	50                   	push   %eax
  800b77:	6a 05                	push   $0x5
  800b79:	68 64 12 80 00       	push   $0x801264
  800b7e:	6a 23                	push   $0x23
  800b80:	68 81 12 80 00       	push   $0x801281
  800b85:	e8 32 01 00 00       	call   800cbc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba0:	b8 06 00 00 00       	mov    $0x6,%eax
  800ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bab:	89 df                	mov    %ebx,%edi
  800bad:	89 de                	mov    %ebx,%esi
  800baf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb1:	85 c0                	test   %eax,%eax
  800bb3:	7e 17                	jle    800bcc <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb5:	83 ec 0c             	sub    $0xc,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 06                	push   $0x6
  800bbb:	68 64 12 80 00       	push   $0x801264
  800bc0:	6a 23                	push   $0x23
  800bc2:	68 81 12 80 00       	push   $0x801281
  800bc7:	e8 f0 00 00 00       	call   800cbc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be2:	b8 08 00 00 00       	mov    $0x8,%eax
  800be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	89 df                	mov    %ebx,%edi
  800bef:	89 de                	mov    %ebx,%esi
  800bf1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf3:	85 c0                	test   %eax,%eax
  800bf5:	7e 17                	jle    800c0e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 08                	push   $0x8
  800bfd:	68 64 12 80 00       	push   $0x801264
  800c02:	6a 23                	push   $0x23
  800c04:	68 81 12 80 00       	push   $0x801281
  800c09:	e8 ae 00 00 00       	call   800cbc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c11:	5b                   	pop    %ebx
  800c12:	5e                   	pop    %esi
  800c13:	5f                   	pop    %edi
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c24:	b8 09 00 00 00       	mov    $0x9,%eax
  800c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	89 df                	mov    %ebx,%edi
  800c31:	89 de                	mov    %ebx,%esi
  800c33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7e 17                	jle    800c50 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	50                   	push   %eax
  800c3d:	6a 09                	push   $0x9
  800c3f:	68 64 12 80 00       	push   $0x801264
  800c44:	6a 23                	push   $0x23
  800c46:	68 81 12 80 00       	push   $0x801281
  800c4b:	e8 6c 00 00 00       	call   800cbc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5e                   	pop    %esi
  800c55:	5f                   	pop    %edi
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5e:	be 00 00 00 00       	mov    $0x0,%esi
  800c63:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c71:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c74:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	89 cb                	mov    %ecx,%ebx
  800c93:	89 cf                	mov    %ecx,%edi
  800c95:	89 ce                	mov    %ecx,%esi
  800c97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 0c                	push   $0xc
  800ca3:	68 64 12 80 00       	push   $0x801264
  800ca8:	6a 23                	push   $0x23
  800caa:	68 81 12 80 00       	push   $0x801281
  800caf:	e8 08 00 00 00       	call   800cbc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800cc1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800cc4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800cca:	e8 00 fe ff ff       	call   800acf <sys_getenvid>
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	ff 75 0c             	pushl  0xc(%ebp)
  800cd5:	ff 75 08             	pushl  0x8(%ebp)
  800cd8:	56                   	push   %esi
  800cd9:	50                   	push   %eax
  800cda:	68 90 12 80 00       	push   $0x801290
  800cdf:	e8 a1 f4 ff ff       	call   800185 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ce4:	83 c4 18             	add    $0x18,%esp
  800ce7:	53                   	push   %ebx
  800ce8:	ff 75 10             	pushl  0x10(%ebp)
  800ceb:	e8 44 f4 ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  800cf0:	c7 04 24 b4 12 80 00 	movl   $0x8012b4,(%esp)
  800cf7:	e8 89 f4 ff ff       	call   800185 <cprintf>
  800cfc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cff:	cc                   	int3   
  800d00:	eb fd                	jmp    800cff <_panic+0x43>
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 f6                	test   %esi,%esi
  800d29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2d:	89 ca                	mov    %ecx,%edx
  800d2f:	89 f8                	mov    %edi,%eax
  800d31:	75 3d                	jne    800d70 <__udivdi3+0x60>
  800d33:	39 cf                	cmp    %ecx,%edi
  800d35:	0f 87 c5 00 00 00    	ja     800e00 <__udivdi3+0xf0>
  800d3b:	85 ff                	test   %edi,%edi
  800d3d:	89 fd                	mov    %edi,%ebp
  800d3f:	75 0b                	jne    800d4c <__udivdi3+0x3c>
  800d41:	b8 01 00 00 00       	mov    $0x1,%eax
  800d46:	31 d2                	xor    %edx,%edx
  800d48:	f7 f7                	div    %edi
  800d4a:	89 c5                	mov    %eax,%ebp
  800d4c:	89 c8                	mov    %ecx,%eax
  800d4e:	31 d2                	xor    %edx,%edx
  800d50:	f7 f5                	div    %ebp
  800d52:	89 c1                	mov    %eax,%ecx
  800d54:	89 d8                	mov    %ebx,%eax
  800d56:	89 cf                	mov    %ecx,%edi
  800d58:	f7 f5                	div    %ebp
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	89 d8                	mov    %ebx,%eax
  800d5e:	89 fa                	mov    %edi,%edx
  800d60:	83 c4 1c             	add    $0x1c,%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	90                   	nop
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	39 ce                	cmp    %ecx,%esi
  800d72:	77 74                	ja     800de8 <__udivdi3+0xd8>
  800d74:	0f bd fe             	bsr    %esi,%edi
  800d77:	83 f7 1f             	xor    $0x1f,%edi
  800d7a:	0f 84 98 00 00 00    	je     800e18 <__udivdi3+0x108>
  800d80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	89 c5                	mov    %eax,%ebp
  800d89:	29 fb                	sub    %edi,%ebx
  800d8b:	d3 e6                	shl    %cl,%esi
  800d8d:	89 d9                	mov    %ebx,%ecx
  800d8f:	d3 ed                	shr    %cl,%ebp
  800d91:	89 f9                	mov    %edi,%ecx
  800d93:	d3 e0                	shl    %cl,%eax
  800d95:	09 ee                	or     %ebp,%esi
  800d97:	89 d9                	mov    %ebx,%ecx
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	89 d5                	mov    %edx,%ebp
  800d9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800da3:	d3 ed                	shr    %cl,%ebp
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e2                	shl    %cl,%edx
  800da9:	89 d9                	mov    %ebx,%ecx
  800dab:	d3 e8                	shr    %cl,%eax
  800dad:	09 c2                	or     %eax,%edx
  800daf:	89 d0                	mov    %edx,%eax
  800db1:	89 ea                	mov    %ebp,%edx
  800db3:	f7 f6                	div    %esi
  800db5:	89 d5                	mov    %edx,%ebp
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	f7 64 24 0c          	mull   0xc(%esp)
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	72 10                	jb     800dd1 <__udivdi3+0xc1>
  800dc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800dc5:	89 f9                	mov    %edi,%ecx
  800dc7:	d3 e6                	shl    %cl,%esi
  800dc9:	39 c6                	cmp    %eax,%esi
  800dcb:	73 07                	jae    800dd4 <__udivdi3+0xc4>
  800dcd:	39 d5                	cmp    %edx,%ebp
  800dcf:	75 03                	jne    800dd4 <__udivdi3+0xc4>
  800dd1:	83 eb 01             	sub    $0x1,%ebx
  800dd4:	31 ff                	xor    %edi,%edi
  800dd6:	89 d8                	mov    %ebx,%eax
  800dd8:	89 fa                	mov    %edi,%edx
  800dda:	83 c4 1c             	add    $0x1c,%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    
  800de2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800de8:	31 ff                	xor    %edi,%edi
  800dea:	31 db                	xor    %ebx,%ebx
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	89 fa                	mov    %edi,%edx
  800df0:	83 c4 1c             	add    $0x1c,%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
  800df8:	90                   	nop
  800df9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e00:	89 d8                	mov    %ebx,%eax
  800e02:	f7 f7                	div    %edi
  800e04:	31 ff                	xor    %edi,%edi
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	89 d8                	mov    %ebx,%eax
  800e0a:	89 fa                	mov    %edi,%edx
  800e0c:	83 c4 1c             	add    $0x1c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	39 ce                	cmp    %ecx,%esi
  800e1a:	72 0c                	jb     800e28 <__udivdi3+0x118>
  800e1c:	31 db                	xor    %ebx,%ebx
  800e1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e22:	0f 87 34 ff ff ff    	ja     800d5c <__udivdi3+0x4c>
  800e28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e2d:	e9 2a ff ff ff       	jmp    800d5c <__udivdi3+0x4c>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	55                   	push   %ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 1c             	sub    $0x1c,%esp
  800e47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e57:	85 d2                	test   %edx,%edx
  800e59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f3                	mov    %esi,%ebx
  800e63:	89 3c 24             	mov    %edi,(%esp)
  800e66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6a:	75 1c                	jne    800e88 <__umoddi3+0x48>
  800e6c:	39 f7                	cmp    %esi,%edi
  800e6e:	76 50                	jbe    800ec0 <__umoddi3+0x80>
  800e70:	89 c8                	mov    %ecx,%eax
  800e72:	89 f2                	mov    %esi,%edx
  800e74:	f7 f7                	div    %edi
  800e76:	89 d0                	mov    %edx,%eax
  800e78:	31 d2                	xor    %edx,%edx
  800e7a:	83 c4 1c             	add    $0x1c,%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
  800e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	89 d0                	mov    %edx,%eax
  800e8c:	77 52                	ja     800ee0 <__umoddi3+0xa0>
  800e8e:	0f bd ea             	bsr    %edx,%ebp
  800e91:	83 f5 1f             	xor    $0x1f,%ebp
  800e94:	75 5a                	jne    800ef0 <__umoddi3+0xb0>
  800e96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e9a:	0f 82 e0 00 00 00    	jb     800f80 <__umoddi3+0x140>
  800ea0:	39 0c 24             	cmp    %ecx,(%esp)
  800ea3:	0f 86 d7 00 00 00    	jbe    800f80 <__umoddi3+0x140>
  800ea9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ead:	8b 54 24 04          	mov    0x4(%esp),%edx
  800eb1:	83 c4 1c             	add    $0x1c,%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	85 ff                	test   %edi,%edi
  800ec2:	89 fd                	mov    %edi,%ebp
  800ec4:	75 0b                	jne    800ed1 <__umoddi3+0x91>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f7                	div    %edi
  800ecf:	89 c5                	mov    %eax,%ebp
  800ed1:	89 f0                	mov    %esi,%eax
  800ed3:	31 d2                	xor    %edx,%edx
  800ed5:	f7 f5                	div    %ebp
  800ed7:	89 c8                	mov    %ecx,%eax
  800ed9:	f7 f5                	div    %ebp
  800edb:	89 d0                	mov    %edx,%eax
  800edd:	eb 99                	jmp    800e78 <__umoddi3+0x38>
  800edf:	90                   	nop
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	83 c4 1c             	add    $0x1c,%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    
  800eec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	8b 34 24             	mov    (%esp),%esi
  800ef3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ef8:	89 e9                	mov    %ebp,%ecx
  800efa:	29 ef                	sub    %ebp,%edi
  800efc:	d3 e0                	shl    %cl,%eax
  800efe:	89 f9                	mov    %edi,%ecx
  800f00:	89 f2                	mov    %esi,%edx
  800f02:	d3 ea                	shr    %cl,%edx
  800f04:	89 e9                	mov    %ebp,%ecx
  800f06:	09 c2                	or     %eax,%edx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 14 24             	mov    %edx,(%esp)
  800f0d:	89 f2                	mov    %esi,%edx
  800f0f:	d3 e2                	shl    %cl,%edx
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f17:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f1b:	d3 e8                	shr    %cl,%eax
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	89 c6                	mov    %eax,%esi
  800f21:	d3 e3                	shl    %cl,%ebx
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 d0                	mov    %edx,%eax
  800f27:	d3 e8                	shr    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	09 d8                	or     %ebx,%eax
  800f2d:	89 d3                	mov    %edx,%ebx
  800f2f:	89 f2                	mov    %esi,%edx
  800f31:	f7 34 24             	divl   (%esp)
  800f34:	89 d6                	mov    %edx,%esi
  800f36:	d3 e3                	shl    %cl,%ebx
  800f38:	f7 64 24 04          	mull   0x4(%esp)
  800f3c:	39 d6                	cmp    %edx,%esi
  800f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f42:	89 d1                	mov    %edx,%ecx
  800f44:	89 c3                	mov    %eax,%ebx
  800f46:	72 08                	jb     800f50 <__umoddi3+0x110>
  800f48:	75 11                	jne    800f5b <__umoddi3+0x11b>
  800f4a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f4e:	73 0b                	jae    800f5b <__umoddi3+0x11b>
  800f50:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f54:	1b 14 24             	sbb    (%esp),%edx
  800f57:	89 d1                	mov    %edx,%ecx
  800f59:	89 c3                	mov    %eax,%ebx
  800f5b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f5f:	29 da                	sub    %ebx,%edx
  800f61:	19 ce                	sbb    %ecx,%esi
  800f63:	89 f9                	mov    %edi,%ecx
  800f65:	89 f0                	mov    %esi,%eax
  800f67:	d3 e0                	shl    %cl,%eax
  800f69:	89 e9                	mov    %ebp,%ecx
  800f6b:	d3 ea                	shr    %cl,%edx
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	d3 ee                	shr    %cl,%esi
  800f71:	09 d0                	or     %edx,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	83 c4 1c             	add    $0x1c,%esp
  800f78:	5b                   	pop    %ebx
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	29 f9                	sub    %edi,%ecx
  800f82:	19 d6                	sbb    %edx,%esi
  800f84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f88:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f8c:	e9 18 ff ff ff       	jmp    800ea9 <__umoddi3+0x69>
