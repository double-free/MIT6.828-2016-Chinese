
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 60 0f 80 00       	push   $0x800f60
  800056:	e8 f0 00 00 00       	call   80014b <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 25 0a 00 00       	call   800a95 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 a1 09 00 00       	call   800a54 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	75 1a                	jne    8000f1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d7:	83 ec 08             	sub    $0x8,%esp
  8000da:	68 ff 00 00 00       	push   $0xff
  8000df:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e2:	50                   	push   %eax
  8000e3:	e8 2f 09 00 00       	call   800a17 <sys_cputs>
		b->idx = 0;
  8000e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ee:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f8:	c9                   	leave  
  8000f9:	c3                   	ret    

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b8 00 80 00       	push   $0x8000b8
  800129:	e8 54 01 00 00       	call   800282 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 d4 08 00 00       	call   800a17 <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800175:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800178:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800180:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800183:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800186:	39 d3                	cmp    %edx,%ebx
  800188:	72 05                	jb     80018f <printnum+0x30>
  80018a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018d:	77 45                	ja     8001d4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 18             	pushl  0x18(%ebp)
  800195:	8b 45 14             	mov    0x14(%ebp),%eax
  800198:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019b:	53                   	push   %ebx
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ae:	e8 1d 0b 00 00       	call   800cd0 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9e ff ff ff       	call   80015f <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 18                	jmp    8001de <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	eb 03                	jmp    8001d7 <printnum+0x78>
  8001d4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d7:	83 eb 01             	sub    $0x1,%ebx
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7f e8                	jg     8001c6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001de:	83 ec 08             	sub    $0x8,%esp
  8001e1:	56                   	push   %esi
  8001e2:	83 ec 04             	sub    $0x4,%esp
  8001e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8001eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f1:	e8 0a 0c 00 00       	call   800e00 <__umoddi3>
  8001f6:	83 c4 14             	add    $0x14,%esp
  8001f9:	0f be 80 78 0f 80 00 	movsbl 0x800f78(%eax),%eax
  800200:	50                   	push   %eax
  800201:	ff d7                	call   *%edi
}
  800203:	83 c4 10             	add    $0x10,%esp
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800211:	83 fa 01             	cmp    $0x1,%edx
  800214:	7e 0e                	jle    800224 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800216:	8b 10                	mov    (%eax),%edx
  800218:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021b:	89 08                	mov    %ecx,(%eax)
  80021d:	8b 02                	mov    (%edx),%eax
  80021f:	8b 52 04             	mov    0x4(%edx),%edx
  800222:	eb 22                	jmp    800246 <getuint+0x38>
	else if (lflag)
  800224:	85 d2                	test   %edx,%edx
  800226:	74 10                	je     800238 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800228:	8b 10                	mov    (%eax),%edx
  80022a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022d:	89 08                	mov    %ecx,(%eax)
  80022f:	8b 02                	mov    (%edx),%eax
  800231:	ba 00 00 00 00       	mov    $0x0,%edx
  800236:	eb 0e                	jmp    800246 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 02                	mov    (%edx),%eax
  800241:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800252:	8b 10                	mov    (%eax),%edx
  800254:	3b 50 04             	cmp    0x4(%eax),%edx
  800257:	73 0a                	jae    800263 <sprintputch+0x1b>
		*b->buf++ = ch;
  800259:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	88 02                	mov    %al,(%edx)
}
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 10             	pushl  0x10(%ebp)
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	ff 75 08             	pushl  0x8(%ebp)
  800278:	e8 05 00 00 00       	call   800282 <vprintfmt>
	va_end(ap);
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	c9                   	leave  
  800281:	c3                   	ret    

00800282 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 2c             	sub    $0x2c,%esp
  80028b:	8b 75 08             	mov    0x8(%ebp),%esi
  80028e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800291:	8b 7d 10             	mov    0x10(%ebp),%edi
  800294:	eb 12                	jmp    8002a8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800296:	85 c0                	test   %eax,%eax
  800298:	0f 84 89 03 00 00    	je     800627 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80029e:	83 ec 08             	sub    $0x8,%esp
  8002a1:	53                   	push   %ebx
  8002a2:	50                   	push   %eax
  8002a3:	ff d6                	call   *%esi
  8002a5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a8:	83 c7 01             	add    $0x1,%edi
  8002ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002af:	83 f8 25             	cmp    $0x25,%eax
  8002b2:	75 e2                	jne    800296 <vprintfmt+0x14>
  8002b4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	eb 07                	jmp    8002db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	8d 47 01             	lea    0x1(%edi),%eax
  8002de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e1:	0f b6 07             	movzbl (%edi),%eax
  8002e4:	0f b6 c8             	movzbl %al,%ecx
  8002e7:	83 e8 23             	sub    $0x23,%eax
  8002ea:	3c 55                	cmp    $0x55,%al
  8002ec:	0f 87 1a 03 00 00    	ja     80060c <vprintfmt+0x38a>
  8002f2:	0f b6 c0             	movzbl %al,%eax
  8002f5:	ff 24 85 40 10 80 00 	jmp    *0x801040(,%eax,4)
  8002fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ff:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800303:	eb d6                	jmp    8002db <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800308:	b8 00 00 00 00       	mov    $0x0,%eax
  80030d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800310:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800313:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800317:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80031a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031d:	83 fa 09             	cmp    $0x9,%edx
  800320:	77 39                	ja     80035b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800322:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800325:	eb e9                	jmp    800310 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800327:	8b 45 14             	mov    0x14(%ebp),%eax
  80032a:	8d 48 04             	lea    0x4(%eax),%ecx
  80032d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800330:	8b 00                	mov    (%eax),%eax
  800332:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800338:	eb 27                	jmp    800361 <vprintfmt+0xdf>
  80033a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033d:	85 c0                	test   %eax,%eax
  80033f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800344:	0f 49 c8             	cmovns %eax,%ecx
  800347:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034d:	eb 8c                	jmp    8002db <vprintfmt+0x59>
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800352:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800359:	eb 80                	jmp    8002db <vprintfmt+0x59>
  80035b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800361:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800365:	0f 89 70 ff ff ff    	jns    8002db <vprintfmt+0x59>
				width = precision, precision = -1;
  80036b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800371:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800378:	e9 5e ff ff ff       	jmp    8002db <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800383:	e9 53 ff ff ff       	jmp    8002db <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800388:	8b 45 14             	mov    0x14(%ebp),%eax
  80038b:	8d 50 04             	lea    0x4(%eax),%edx
  80038e:	89 55 14             	mov    %edx,0x14(%ebp)
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	53                   	push   %ebx
  800395:	ff 30                	pushl  (%eax)
  800397:	ff d6                	call   *%esi
			break;
  800399:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039f:	e9 04 ff ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8d 50 04             	lea    0x4(%eax),%edx
  8003aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ad:	8b 00                	mov    (%eax),%eax
  8003af:	99                   	cltd   
  8003b0:	31 d0                	xor    %edx,%eax
  8003b2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b4:	83 f8 08             	cmp    $0x8,%eax
  8003b7:	7f 0b                	jg     8003c4 <vprintfmt+0x142>
  8003b9:	8b 14 85 a0 11 80 00 	mov    0x8011a0(,%eax,4),%edx
  8003c0:	85 d2                	test   %edx,%edx
  8003c2:	75 18                	jne    8003dc <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c4:	50                   	push   %eax
  8003c5:	68 90 0f 80 00       	push   $0x800f90
  8003ca:	53                   	push   %ebx
  8003cb:	56                   	push   %esi
  8003cc:	e8 94 fe ff ff       	call   800265 <printfmt>
  8003d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d7:	e9 cc fe ff ff       	jmp    8002a8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003dc:	52                   	push   %edx
  8003dd:	68 99 0f 80 00       	push   $0x800f99
  8003e2:	53                   	push   %ebx
  8003e3:	56                   	push   %esi
  8003e4:	e8 7c fe ff ff       	call   800265 <printfmt>
  8003e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ef:	e9 b4 fe ff ff       	jmp    8002a8 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 50 04             	lea    0x4(%eax),%edx
  8003fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ff:	85 ff                	test   %edi,%edi
  800401:	b8 89 0f 80 00       	mov    $0x800f89,%eax
  800406:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800409:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040d:	0f 8e 94 00 00 00    	jle    8004a7 <vprintfmt+0x225>
  800413:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800417:	0f 84 98 00 00 00    	je     8004b5 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	ff 75 d0             	pushl  -0x30(%ebp)
  800423:	57                   	push   %edi
  800424:	e8 86 02 00 00       	call   8006af <strnlen>
  800429:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042c:	29 c1                	sub    %eax,%ecx
  80042e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800431:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800434:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800438:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	eb 0f                	jmp    800451 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	53                   	push   %ebx
  800446:	ff 75 e0             	pushl  -0x20(%ebp)
  800449:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ef 01             	sub    $0x1,%edi
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	85 ff                	test   %edi,%edi
  800453:	7f ed                	jg     800442 <vprintfmt+0x1c0>
  800455:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800458:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80045b:	85 c9                	test   %ecx,%ecx
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	0f 49 c1             	cmovns %ecx,%eax
  800465:	29 c1                	sub    %eax,%ecx
  800467:	89 75 08             	mov    %esi,0x8(%ebp)
  80046a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800470:	89 cb                	mov    %ecx,%ebx
  800472:	eb 4d                	jmp    8004c1 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	74 1b                	je     800495 <vprintfmt+0x213>
  80047a:	0f be c0             	movsbl %al,%eax
  80047d:	83 e8 20             	sub    $0x20,%eax
  800480:	83 f8 5e             	cmp    $0x5e,%eax
  800483:	76 10                	jbe    800495 <vprintfmt+0x213>
					putch('?', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	ff 75 0c             	pushl  0xc(%ebp)
  80048b:	6a 3f                	push   $0x3f
  80048d:	ff 55 08             	call   *0x8(%ebp)
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb 0d                	jmp    8004a2 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 0c             	pushl  0xc(%ebp)
  80049b:	52                   	push   %edx
  80049c:	ff 55 08             	call   *0x8(%ebp)
  80049f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	eb 1a                	jmp    8004c1 <vprintfmt+0x23f>
  8004a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b3:	eb 0c                	jmp    8004c1 <vprintfmt+0x23f>
  8004b5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004be:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c1:	83 c7 01             	add    $0x1,%edi
  8004c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c8:	0f be d0             	movsbl %al,%edx
  8004cb:	85 d2                	test   %edx,%edx
  8004cd:	74 23                	je     8004f2 <vprintfmt+0x270>
  8004cf:	85 f6                	test   %esi,%esi
  8004d1:	78 a1                	js     800474 <vprintfmt+0x1f2>
  8004d3:	83 ee 01             	sub    $0x1,%esi
  8004d6:	79 9c                	jns    800474 <vprintfmt+0x1f2>
  8004d8:	89 df                	mov    %ebx,%edi
  8004da:	8b 75 08             	mov    0x8(%ebp),%esi
  8004dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e0:	eb 18                	jmp    8004fa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 20                	push   $0x20
  8004e8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb 08                	jmp    8004fa <vprintfmt+0x278>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	85 ff                	test   %edi,%edi
  8004fc:	7f e4                	jg     8004e2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 a2 fd ff ff       	jmp    8002a8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 fa 01             	cmp    $0x1,%edx
  800509:	7e 16                	jle    800521 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 08             	lea    0x8(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 50 04             	mov    0x4(%eax),%edx
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051f:	eb 32                	jmp    800553 <vprintfmt+0x2d1>
	else if (lflag)
  800521:	85 d2                	test   %edx,%edx
  800523:	74 18                	je     80053d <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 50 04             	lea    0x4(%eax),%edx
  80052b:	89 55 14             	mov    %edx,0x14(%ebp)
  80052e:	8b 00                	mov    (%eax),%eax
  800530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800533:	89 c1                	mov    %eax,%ecx
  800535:	c1 f9 1f             	sar    $0x1f,%ecx
  800538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053b:	eb 16                	jmp    800553 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800553:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800556:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800559:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800562:	79 74                	jns    8005d8 <vprintfmt+0x356>
				putch('-', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	53                   	push   %ebx
  800568:	6a 2d                	push   $0x2d
  80056a:	ff d6                	call   *%esi
				num = -(long long) num;
  80056c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800572:	f7 d8                	neg    %eax
  800574:	83 d2 00             	adc    $0x0,%edx
  800577:	f7 da                	neg    %edx
  800579:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800581:	eb 55                	jmp    8005d8 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800583:	8d 45 14             	lea    0x14(%ebp),%eax
  800586:	e8 83 fc ff ff       	call   80020e <getuint>
			base = 10;
  80058b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800590:	eb 46                	jmp    8005d8 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800592:	8d 45 14             	lea    0x14(%ebp),%eax
  800595:	e8 74 fc ff ff       	call   80020e <getuint>
			base = 8;
  80059a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80059f:	eb 37                	jmp    8005d8 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 30                	push   $0x30
  8005a7:	ff d6                	call   *%esi
			putch('x', putdat);
  8005a9:	83 c4 08             	add    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 78                	push   $0x78
  8005af:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c9:	eb 0d                	jmp    8005d8 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 3b fc ff ff       	call   80020e <getuint>
			base = 16;
  8005d3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d8:	83 ec 0c             	sub    $0xc,%esp
  8005db:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005df:	57                   	push   %edi
  8005e0:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e3:	51                   	push   %ecx
  8005e4:	52                   	push   %edx
  8005e5:	50                   	push   %eax
  8005e6:	89 da                	mov    %ebx,%edx
  8005e8:	89 f0                	mov    %esi,%eax
  8005ea:	e8 70 fb ff ff       	call   80015f <printnum>
			break;
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f5:	e9 ae fc ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	51                   	push   %ecx
  8005ff:	ff d6                	call   *%esi
			break;
  800601:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800607:	e9 9c fc ff ff       	jmp    8002a8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 25                	push   $0x25
  800612:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	eb 03                	jmp    80061c <vprintfmt+0x39a>
  800619:	83 ef 01             	sub    $0x1,%edi
  80061c:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800620:	75 f7                	jne    800619 <vprintfmt+0x397>
  800622:	e9 81 fc ff ff       	jmp    8002a8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800627:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062a:	5b                   	pop    %ebx
  80062b:	5e                   	pop    %esi
  80062c:	5f                   	pop    %edi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	83 ec 18             	sub    $0x18,%esp
  800635:	8b 45 08             	mov    0x8(%ebp),%eax
  800638:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80063b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800642:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800645:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064c:	85 c0                	test   %eax,%eax
  80064e:	74 26                	je     800676 <vsnprintf+0x47>
  800650:	85 d2                	test   %edx,%edx
  800652:	7e 22                	jle    800676 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800654:	ff 75 14             	pushl  0x14(%ebp)
  800657:	ff 75 10             	pushl  0x10(%ebp)
  80065a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065d:	50                   	push   %eax
  80065e:	68 48 02 80 00       	push   $0x800248
  800663:	e8 1a fc ff ff       	call   800282 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800668:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80066b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80066e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	eb 05                	jmp    80067b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800676:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80067b:	c9                   	leave  
  80067c:	c3                   	ret    

0080067d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800686:	50                   	push   %eax
  800687:	ff 75 10             	pushl  0x10(%ebp)
  80068a:	ff 75 0c             	pushl  0xc(%ebp)
  80068d:	ff 75 08             	pushl  0x8(%ebp)
  800690:	e8 9a ff ff ff       	call   80062f <vsnprintf>
	va_end(ap);

	return rc;
}
  800695:	c9                   	leave  
  800696:	c3                   	ret    

00800697 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800697:	55                   	push   %ebp
  800698:	89 e5                	mov    %esp,%ebp
  80069a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069d:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a2:	eb 03                	jmp    8006a7 <strlen+0x10>
		n++;
  8006a4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ab:	75 f7                	jne    8006a4 <strlen+0xd>
		n++;
	return n;
}
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bd:	eb 03                	jmp    8006c2 <strnlen+0x13>
		n++;
  8006bf:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c2:	39 c2                	cmp    %eax,%edx
  8006c4:	74 08                	je     8006ce <strnlen+0x1f>
  8006c6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006ca:	75 f3                	jne    8006bf <strnlen+0x10>
  8006cc:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006ce:	5d                   	pop    %ebp
  8006cf:	c3                   	ret    

008006d0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	53                   	push   %ebx
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006da:	89 c2                	mov    %eax,%edx
  8006dc:	83 c2 01             	add    $0x1,%edx
  8006df:	83 c1 01             	add    $0x1,%ecx
  8006e2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006e9:	84 db                	test   %bl,%bl
  8006eb:	75 ef                	jne    8006dc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006ed:	5b                   	pop    %ebx
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	53                   	push   %ebx
  8006f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f7:	53                   	push   %ebx
  8006f8:	e8 9a ff ff ff       	call   800697 <strlen>
  8006fd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800700:	ff 75 0c             	pushl  0xc(%ebp)
  800703:	01 d8                	add    %ebx,%eax
  800705:	50                   	push   %eax
  800706:	e8 c5 ff ff ff       	call   8006d0 <strcpy>
	return dst;
}
  80070b:	89 d8                	mov    %ebx,%eax
  80070d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	56                   	push   %esi
  800716:	53                   	push   %ebx
  800717:	8b 75 08             	mov    0x8(%ebp),%esi
  80071a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071d:	89 f3                	mov    %esi,%ebx
  80071f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800722:	89 f2                	mov    %esi,%edx
  800724:	eb 0f                	jmp    800735 <strncpy+0x23>
		*dst++ = *src;
  800726:	83 c2 01             	add    $0x1,%edx
  800729:	0f b6 01             	movzbl (%ecx),%eax
  80072c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80072f:	80 39 01             	cmpb   $0x1,(%ecx)
  800732:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800735:	39 da                	cmp    %ebx,%edx
  800737:	75 ed                	jne    800726 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800739:	89 f0                	mov    %esi,%eax
  80073b:	5b                   	pop    %ebx
  80073c:	5e                   	pop    %esi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80073f:	55                   	push   %ebp
  800740:	89 e5                	mov    %esp,%ebp
  800742:	56                   	push   %esi
  800743:	53                   	push   %ebx
  800744:	8b 75 08             	mov    0x8(%ebp),%esi
  800747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80074a:	8b 55 10             	mov    0x10(%ebp),%edx
  80074d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80074f:	85 d2                	test   %edx,%edx
  800751:	74 21                	je     800774 <strlcpy+0x35>
  800753:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800757:	89 f2                	mov    %esi,%edx
  800759:	eb 09                	jmp    800764 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80075b:	83 c2 01             	add    $0x1,%edx
  80075e:	83 c1 01             	add    $0x1,%ecx
  800761:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800764:	39 c2                	cmp    %eax,%edx
  800766:	74 09                	je     800771 <strlcpy+0x32>
  800768:	0f b6 19             	movzbl (%ecx),%ebx
  80076b:	84 db                	test   %bl,%bl
  80076d:	75 ec                	jne    80075b <strlcpy+0x1c>
  80076f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800771:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800774:	29 f0                	sub    %esi,%eax
}
  800776:	5b                   	pop    %ebx
  800777:	5e                   	pop    %esi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800783:	eb 06                	jmp    80078b <strcmp+0x11>
		p++, q++;
  800785:	83 c1 01             	add    $0x1,%ecx
  800788:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80078b:	0f b6 01             	movzbl (%ecx),%eax
  80078e:	84 c0                	test   %al,%al
  800790:	74 04                	je     800796 <strcmp+0x1c>
  800792:	3a 02                	cmp    (%edx),%al
  800794:	74 ef                	je     800785 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800796:	0f b6 c0             	movzbl %al,%eax
  800799:	0f b6 12             	movzbl (%edx),%edx
  80079c:	29 d0                	sub    %edx,%eax
}
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007aa:	89 c3                	mov    %eax,%ebx
  8007ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007af:	eb 06                	jmp    8007b7 <strncmp+0x17>
		n--, p++, q++;
  8007b1:	83 c0 01             	add    $0x1,%eax
  8007b4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007b7:	39 d8                	cmp    %ebx,%eax
  8007b9:	74 15                	je     8007d0 <strncmp+0x30>
  8007bb:	0f b6 08             	movzbl (%eax),%ecx
  8007be:	84 c9                	test   %cl,%cl
  8007c0:	74 04                	je     8007c6 <strncmp+0x26>
  8007c2:	3a 0a                	cmp    (%edx),%cl
  8007c4:	74 eb                	je     8007b1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c6:	0f b6 00             	movzbl (%eax),%eax
  8007c9:	0f b6 12             	movzbl (%edx),%edx
  8007cc:	29 d0                	sub    %edx,%eax
  8007ce:	eb 05                	jmp    8007d5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007d0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e2:	eb 07                	jmp    8007eb <strchr+0x13>
		if (*s == c)
  8007e4:	38 ca                	cmp    %cl,%dl
  8007e6:	74 0f                	je     8007f7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	0f b6 10             	movzbl (%eax),%edx
  8007ee:	84 d2                	test   %dl,%dl
  8007f0:	75 f2                	jne    8007e4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800803:	eb 03                	jmp    800808 <strfind+0xf>
  800805:	83 c0 01             	add    $0x1,%eax
  800808:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80080b:	38 ca                	cmp    %cl,%dl
  80080d:	74 04                	je     800813 <strfind+0x1a>
  80080f:	84 d2                	test   %dl,%dl
  800811:	75 f2                	jne    800805 <strfind+0xc>
			break;
	return (char *) s;
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	57                   	push   %edi
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800821:	85 c9                	test   %ecx,%ecx
  800823:	74 36                	je     80085b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800825:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80082b:	75 28                	jne    800855 <memset+0x40>
  80082d:	f6 c1 03             	test   $0x3,%cl
  800830:	75 23                	jne    800855 <memset+0x40>
		c &= 0xFF;
  800832:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800836:	89 d3                	mov    %edx,%ebx
  800838:	c1 e3 08             	shl    $0x8,%ebx
  80083b:	89 d6                	mov    %edx,%esi
  80083d:	c1 e6 18             	shl    $0x18,%esi
  800840:	89 d0                	mov    %edx,%eax
  800842:	c1 e0 10             	shl    $0x10,%eax
  800845:	09 f0                	or     %esi,%eax
  800847:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800849:	89 d8                	mov    %ebx,%eax
  80084b:	09 d0                	or     %edx,%eax
  80084d:	c1 e9 02             	shr    $0x2,%ecx
  800850:	fc                   	cld    
  800851:	f3 ab                	rep stos %eax,%es:(%edi)
  800853:	eb 06                	jmp    80085b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800855:	8b 45 0c             	mov    0xc(%ebp),%eax
  800858:	fc                   	cld    
  800859:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80085b:	89 f8                	mov    %edi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5f                   	pop    %edi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	57                   	push   %edi
  800866:	56                   	push   %esi
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800870:	39 c6                	cmp    %eax,%esi
  800872:	73 35                	jae    8008a9 <memmove+0x47>
  800874:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800877:	39 d0                	cmp    %edx,%eax
  800879:	73 2e                	jae    8008a9 <memmove+0x47>
		s += n;
		d += n;
  80087b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087e:	89 d6                	mov    %edx,%esi
  800880:	09 fe                	or     %edi,%esi
  800882:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800888:	75 13                	jne    80089d <memmove+0x3b>
  80088a:	f6 c1 03             	test   $0x3,%cl
  80088d:	75 0e                	jne    80089d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80088f:	83 ef 04             	sub    $0x4,%edi
  800892:	8d 72 fc             	lea    -0x4(%edx),%esi
  800895:	c1 e9 02             	shr    $0x2,%ecx
  800898:	fd                   	std    
  800899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80089b:	eb 09                	jmp    8008a6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80089d:	83 ef 01             	sub    $0x1,%edi
  8008a0:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a3:	fd                   	std    
  8008a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a6:	fc                   	cld    
  8008a7:	eb 1d                	jmp    8008c6 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a9:	89 f2                	mov    %esi,%edx
  8008ab:	09 c2                	or     %eax,%edx
  8008ad:	f6 c2 03             	test   $0x3,%dl
  8008b0:	75 0f                	jne    8008c1 <memmove+0x5f>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 0a                	jne    8008c1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008b7:	c1 e9 02             	shr    $0x2,%ecx
  8008ba:	89 c7                	mov    %eax,%edi
  8008bc:	fc                   	cld    
  8008bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bf:	eb 05                	jmp    8008c6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008c1:	89 c7                	mov    %eax,%edi
  8008c3:	fc                   	cld    
  8008c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008cd:	ff 75 10             	pushl  0x10(%ebp)
  8008d0:	ff 75 0c             	pushl  0xc(%ebp)
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 87 ff ff ff       	call   800862 <memmove>
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	89 c6                	mov    %eax,%esi
  8008ea:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008ed:	eb 1a                	jmp    800909 <memcmp+0x2c>
		if (*s1 != *s2)
  8008ef:	0f b6 08             	movzbl (%eax),%ecx
  8008f2:	0f b6 1a             	movzbl (%edx),%ebx
  8008f5:	38 d9                	cmp    %bl,%cl
  8008f7:	74 0a                	je     800903 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008f9:	0f b6 c1             	movzbl %cl,%eax
  8008fc:	0f b6 db             	movzbl %bl,%ebx
  8008ff:	29 d8                	sub    %ebx,%eax
  800901:	eb 0f                	jmp    800912 <memcmp+0x35>
		s1++, s2++;
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800909:	39 f0                	cmp    %esi,%eax
  80090b:	75 e2                	jne    8008ef <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5b                   	pop    %ebx
  800913:	5e                   	pop    %esi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	53                   	push   %ebx
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80091d:	89 c1                	mov    %eax,%ecx
  80091f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800922:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800926:	eb 0a                	jmp    800932 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	39 da                	cmp    %ebx,%edx
  80092d:	74 07                	je     800936 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092f:	83 c0 01             	add    $0x1,%eax
  800932:	39 c8                	cmp    %ecx,%eax
  800934:	72 f2                	jb     800928 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	57                   	push   %edi
  80093d:	56                   	push   %esi
  80093e:	53                   	push   %ebx
  80093f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800942:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800945:	eb 03                	jmp    80094a <strtol+0x11>
		s++;
  800947:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80094a:	0f b6 01             	movzbl (%ecx),%eax
  80094d:	3c 20                	cmp    $0x20,%al
  80094f:	74 f6                	je     800947 <strtol+0xe>
  800951:	3c 09                	cmp    $0x9,%al
  800953:	74 f2                	je     800947 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800955:	3c 2b                	cmp    $0x2b,%al
  800957:	75 0a                	jne    800963 <strtol+0x2a>
		s++;
  800959:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095c:	bf 00 00 00 00       	mov    $0x0,%edi
  800961:	eb 11                	jmp    800974 <strtol+0x3b>
  800963:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800968:	3c 2d                	cmp    $0x2d,%al
  80096a:	75 08                	jne    800974 <strtol+0x3b>
		s++, neg = 1;
  80096c:	83 c1 01             	add    $0x1,%ecx
  80096f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800974:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80097a:	75 15                	jne    800991 <strtol+0x58>
  80097c:	80 39 30             	cmpb   $0x30,(%ecx)
  80097f:	75 10                	jne    800991 <strtol+0x58>
  800981:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800985:	75 7c                	jne    800a03 <strtol+0xca>
		s += 2, base = 16;
  800987:	83 c1 02             	add    $0x2,%ecx
  80098a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80098f:	eb 16                	jmp    8009a7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800991:	85 db                	test   %ebx,%ebx
  800993:	75 12                	jne    8009a7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800995:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80099a:	80 39 30             	cmpb   $0x30,(%ecx)
  80099d:	75 08                	jne    8009a7 <strtol+0x6e>
		s++, base = 8;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ac:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009af:	0f b6 11             	movzbl (%ecx),%edx
  8009b2:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b5:	89 f3                	mov    %esi,%ebx
  8009b7:	80 fb 09             	cmp    $0x9,%bl
  8009ba:	77 08                	ja     8009c4 <strtol+0x8b>
			dig = *s - '0';
  8009bc:	0f be d2             	movsbl %dl,%edx
  8009bf:	83 ea 30             	sub    $0x30,%edx
  8009c2:	eb 22                	jmp    8009e6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009c4:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009c7:	89 f3                	mov    %esi,%ebx
  8009c9:	80 fb 19             	cmp    $0x19,%bl
  8009cc:	77 08                	ja     8009d6 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009ce:	0f be d2             	movsbl %dl,%edx
  8009d1:	83 ea 57             	sub    $0x57,%edx
  8009d4:	eb 10                	jmp    8009e6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009d6:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009d9:	89 f3                	mov    %esi,%ebx
  8009db:	80 fb 19             	cmp    $0x19,%bl
  8009de:	77 16                	ja     8009f6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009e0:	0f be d2             	movsbl %dl,%edx
  8009e3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009e6:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009e9:	7d 0b                	jge    8009f6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009eb:	83 c1 01             	add    $0x1,%ecx
  8009ee:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f4:	eb b9                	jmp    8009af <strtol+0x76>

	if (endptr)
  8009f6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009fa:	74 0d                	je     800a09 <strtol+0xd0>
		*endptr = (char *) s;
  8009fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ff:	89 0e                	mov    %ecx,(%esi)
  800a01:	eb 06                	jmp    800a09 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a03:	85 db                	test   %ebx,%ebx
  800a05:	74 98                	je     80099f <strtol+0x66>
  800a07:	eb 9e                	jmp    8009a7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a09:	89 c2                	mov    %eax,%edx
  800a0b:	f7 da                	neg    %edx
  800a0d:	85 ff                	test   %edi,%edi
  800a0f:	0f 45 c2             	cmovne %edx,%eax
}
  800a12:	5b                   	pop    %ebx
  800a13:	5e                   	pop    %esi
  800a14:	5f                   	pop    %edi
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a25:	8b 55 08             	mov    0x8(%ebp),%edx
  800a28:	89 c3                	mov    %eax,%ebx
  800a2a:	89 c7                	mov    %eax,%edi
  800a2c:	89 c6                	mov    %eax,%esi
  800a2e:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	57                   	push   %edi
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a40:	b8 01 00 00 00       	mov    $0x1,%eax
  800a45:	89 d1                	mov    %edx,%ecx
  800a47:	89 d3                	mov    %edx,%ebx
  800a49:	89 d7                	mov    %edx,%edi
  800a4b:	89 d6                	mov    %edx,%esi
  800a4d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5f                   	pop    %edi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a62:	b8 03 00 00 00       	mov    $0x3,%eax
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	89 cb                	mov    %ecx,%ebx
  800a6c:	89 cf                	mov    %ecx,%edi
  800a6e:	89 ce                	mov    %ecx,%esi
  800a70:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a72:	85 c0                	test   %eax,%eax
  800a74:	7e 17                	jle    800a8d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a76:	83 ec 0c             	sub    $0xc,%esp
  800a79:	50                   	push   %eax
  800a7a:	6a 03                	push   $0x3
  800a7c:	68 c4 11 80 00       	push   $0x8011c4
  800a81:	6a 23                	push   $0x23
  800a83:	68 e1 11 80 00       	push   $0x8011e1
  800a88:	e8 f5 01 00 00       	call   800c82 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa5:	89 d1                	mov    %edx,%ecx
  800aa7:	89 d3                	mov    %edx,%ebx
  800aa9:	89 d7                	mov    %edx,%edi
  800aab:	89 d6                	mov    %edx,%esi
  800aad:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aaf:	5b                   	pop    %ebx
  800ab0:	5e                   	pop    %esi
  800ab1:	5f                   	pop    %edi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <sys_yield>:

void
sys_yield(void)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aba:	ba 00 00 00 00       	mov    $0x0,%edx
  800abf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac4:	89 d1                	mov    %edx,%ecx
  800ac6:	89 d3                	mov    %edx,%ebx
  800ac8:	89 d7                	mov    %edx,%edi
  800aca:	89 d6                	mov    %edx,%esi
  800acc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	be 00 00 00 00       	mov    $0x0,%esi
  800ae1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae9:	8b 55 08             	mov    0x8(%ebp),%edx
  800aec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aef:	89 f7                	mov    %esi,%edi
  800af1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af3:	85 c0                	test   %eax,%eax
  800af5:	7e 17                	jle    800b0e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	50                   	push   %eax
  800afb:	6a 04                	push   $0x4
  800afd:	68 c4 11 80 00       	push   $0x8011c4
  800b02:	6a 23                	push   $0x23
  800b04:	68 e1 11 80 00       	push   $0x8011e1
  800b09:	e8 74 01 00 00       	call   800c82 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800b24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b27:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b30:	8b 75 18             	mov    0x18(%ebp),%esi
  800b33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7e 17                	jle    800b50 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	50                   	push   %eax
  800b3d:	6a 05                	push   $0x5
  800b3f:	68 c4 11 80 00       	push   $0x8011c4
  800b44:	6a 23                	push   $0x23
  800b46:	68 e1 11 80 00       	push   $0x8011e1
  800b4b:	e8 32 01 00 00       	call   800c82 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b66:	b8 06 00 00 00       	mov    $0x6,%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	89 df                	mov    %ebx,%edi
  800b73:	89 de                	mov    %ebx,%esi
  800b75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b77:	85 c0                	test   %eax,%eax
  800b79:	7e 17                	jle    800b92 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	50                   	push   %eax
  800b7f:	6a 06                	push   $0x6
  800b81:	68 c4 11 80 00       	push   $0x8011c4
  800b86:	6a 23                	push   $0x23
  800b88:	68 e1 11 80 00       	push   $0x8011e1
  800b8d:	e8 f0 00 00 00       	call   800c82 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba8:	b8 08 00 00 00       	mov    $0x8,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	89 df                	mov    %ebx,%edi
  800bb5:	89 de                	mov    %ebx,%esi
  800bb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb9:	85 c0                	test   %eax,%eax
  800bbb:	7e 17                	jle    800bd4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbd:	83 ec 0c             	sub    $0xc,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 08                	push   $0x8
  800bc3:	68 c4 11 80 00       	push   $0x8011c4
  800bc8:	6a 23                	push   $0x23
  800bca:	68 e1 11 80 00       	push   $0x8011e1
  800bcf:	e8 ae 00 00 00       	call   800c82 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bea:	b8 09 00 00 00       	mov    $0x9,%eax
  800bef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	89 df                	mov    %ebx,%edi
  800bf7:	89 de                	mov    %ebx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 09                	push   $0x9
  800c05:	68 c4 11 80 00       	push   $0x8011c4
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 e1 11 80 00       	push   $0x8011e1
  800c11:	e8 6c 00 00 00       	call   800c82 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	be 00 00 00 00       	mov    $0x0,%esi
  800c29:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	89 cb                	mov    %ecx,%ebx
  800c59:	89 cf                	mov    %ecx,%edi
  800c5b:	89 ce                	mov    %ecx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 0c                	push   $0xc
  800c69:	68 c4 11 80 00       	push   $0x8011c4
  800c6e:	6a 23                	push   $0x23
  800c70:	68 e1 11 80 00       	push   $0x8011e1
  800c75:	e8 08 00 00 00       	call   800c82 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c87:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c8a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c90:	e8 00 fe ff ff       	call   800a95 <sys_getenvid>
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	ff 75 0c             	pushl  0xc(%ebp)
  800c9b:	ff 75 08             	pushl  0x8(%ebp)
  800c9e:	56                   	push   %esi
  800c9f:	50                   	push   %eax
  800ca0:	68 f0 11 80 00       	push   $0x8011f0
  800ca5:	e8 a1 f4 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800caa:	83 c4 18             	add    $0x18,%esp
  800cad:	53                   	push   %ebx
  800cae:	ff 75 10             	pushl  0x10(%ebp)
  800cb1:	e8 44 f4 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800cb6:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  800cbd:	e8 89 f4 ff ff       	call   80014b <cprintf>
  800cc2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cc5:	cc                   	int3   
  800cc6:	eb fd                	jmp    800cc5 <_panic+0x43>
  800cc8:	66 90                	xchg   %ax,%ax
  800cca:	66 90                	xchg   %ax,%ax
  800ccc:	66 90                	xchg   %ax,%ax
  800cce:	66 90                	xchg   %ax,%ax

00800cd0 <__udivdi3>:
  800cd0:	55                   	push   %ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
  800cd4:	83 ec 1c             	sub    $0x1c,%esp
  800cd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ce7:	85 f6                	test   %esi,%esi
  800ce9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ced:	89 ca                	mov    %ecx,%edx
  800cef:	89 f8                	mov    %edi,%eax
  800cf1:	75 3d                	jne    800d30 <__udivdi3+0x60>
  800cf3:	39 cf                	cmp    %ecx,%edi
  800cf5:	0f 87 c5 00 00 00    	ja     800dc0 <__udivdi3+0xf0>
  800cfb:	85 ff                	test   %edi,%edi
  800cfd:	89 fd                	mov    %edi,%ebp
  800cff:	75 0b                	jne    800d0c <__udivdi3+0x3c>
  800d01:	b8 01 00 00 00       	mov    $0x1,%eax
  800d06:	31 d2                	xor    %edx,%edx
  800d08:	f7 f7                	div    %edi
  800d0a:	89 c5                	mov    %eax,%ebp
  800d0c:	89 c8                	mov    %ecx,%eax
  800d0e:	31 d2                	xor    %edx,%edx
  800d10:	f7 f5                	div    %ebp
  800d12:	89 c1                	mov    %eax,%ecx
  800d14:	89 d8                	mov    %ebx,%eax
  800d16:	89 cf                	mov    %ecx,%edi
  800d18:	f7 f5                	div    %ebp
  800d1a:	89 c3                	mov    %eax,%ebx
  800d1c:	89 d8                	mov    %ebx,%eax
  800d1e:	89 fa                	mov    %edi,%edx
  800d20:	83 c4 1c             	add    $0x1c,%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    
  800d28:	90                   	nop
  800d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d30:	39 ce                	cmp    %ecx,%esi
  800d32:	77 74                	ja     800da8 <__udivdi3+0xd8>
  800d34:	0f bd fe             	bsr    %esi,%edi
  800d37:	83 f7 1f             	xor    $0x1f,%edi
  800d3a:	0f 84 98 00 00 00    	je     800dd8 <__udivdi3+0x108>
  800d40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d45:	89 f9                	mov    %edi,%ecx
  800d47:	89 c5                	mov    %eax,%ebp
  800d49:	29 fb                	sub    %edi,%ebx
  800d4b:	d3 e6                	shl    %cl,%esi
  800d4d:	89 d9                	mov    %ebx,%ecx
  800d4f:	d3 ed                	shr    %cl,%ebp
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	d3 e0                	shl    %cl,%eax
  800d55:	09 ee                	or     %ebp,%esi
  800d57:	89 d9                	mov    %ebx,%ecx
  800d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d5d:	89 d5                	mov    %edx,%ebp
  800d5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d63:	d3 ed                	shr    %cl,%ebp
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	d3 e2                	shl    %cl,%edx
  800d69:	89 d9                	mov    %ebx,%ecx
  800d6b:	d3 e8                	shr    %cl,%eax
  800d6d:	09 c2                	or     %eax,%edx
  800d6f:	89 d0                	mov    %edx,%eax
  800d71:	89 ea                	mov    %ebp,%edx
  800d73:	f7 f6                	div    %esi
  800d75:	89 d5                	mov    %edx,%ebp
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	f7 64 24 0c          	mull   0xc(%esp)
  800d7d:	39 d5                	cmp    %edx,%ebp
  800d7f:	72 10                	jb     800d91 <__udivdi3+0xc1>
  800d81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e6                	shl    %cl,%esi
  800d89:	39 c6                	cmp    %eax,%esi
  800d8b:	73 07                	jae    800d94 <__udivdi3+0xc4>
  800d8d:	39 d5                	cmp    %edx,%ebp
  800d8f:	75 03                	jne    800d94 <__udivdi3+0xc4>
  800d91:	83 eb 01             	sub    $0x1,%ebx
  800d94:	31 ff                	xor    %edi,%edi
  800d96:	89 d8                	mov    %ebx,%eax
  800d98:	89 fa                	mov    %edi,%edx
  800d9a:	83 c4 1c             	add    $0x1c,%esp
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5f                   	pop    %edi
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    
  800da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da8:	31 ff                	xor    %edi,%edi
  800daa:	31 db                	xor    %ebx,%ebx
  800dac:	89 d8                	mov    %ebx,%eax
  800dae:	89 fa                	mov    %edi,%edx
  800db0:	83 c4 1c             	add    $0x1c,%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
  800db8:	90                   	nop
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	f7 f7                	div    %edi
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	89 fa                	mov    %edi,%edx
  800dcc:	83 c4 1c             	add    $0x1c,%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
  800dd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	39 ce                	cmp    %ecx,%esi
  800dda:	72 0c                	jb     800de8 <__udivdi3+0x118>
  800ddc:	31 db                	xor    %ebx,%ebx
  800dde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800de2:	0f 87 34 ff ff ff    	ja     800d1c <__udivdi3+0x4c>
  800de8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ded:	e9 2a ff ff ff       	jmp    800d1c <__udivdi3+0x4c>
  800df2:	66 90                	xchg   %ax,%ax
  800df4:	66 90                	xchg   %ax,%ax
  800df6:	66 90                	xchg   %ax,%ax
  800df8:	66 90                	xchg   %ax,%ax
  800dfa:	66 90                	xchg   %ax,%ax
  800dfc:	66 90                	xchg   %ax,%ax
  800dfe:	66 90                	xchg   %ax,%ax

00800e00 <__umoddi3>:
  800e00:	55                   	push   %ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 1c             	sub    $0x1c,%esp
  800e07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e17:	85 d2                	test   %edx,%edx
  800e19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e21:	89 f3                	mov    %esi,%ebx
  800e23:	89 3c 24             	mov    %edi,(%esp)
  800e26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e2a:	75 1c                	jne    800e48 <__umoddi3+0x48>
  800e2c:	39 f7                	cmp    %esi,%edi
  800e2e:	76 50                	jbe    800e80 <__umoddi3+0x80>
  800e30:	89 c8                	mov    %ecx,%eax
  800e32:	89 f2                	mov    %esi,%edx
  800e34:	f7 f7                	div    %edi
  800e36:	89 d0                	mov    %edx,%eax
  800e38:	31 d2                	xor    %edx,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	89 d0                	mov    %edx,%eax
  800e4c:	77 52                	ja     800ea0 <__umoddi3+0xa0>
  800e4e:	0f bd ea             	bsr    %edx,%ebp
  800e51:	83 f5 1f             	xor    $0x1f,%ebp
  800e54:	75 5a                	jne    800eb0 <__umoddi3+0xb0>
  800e56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e5a:	0f 82 e0 00 00 00    	jb     800f40 <__umoddi3+0x140>
  800e60:	39 0c 24             	cmp    %ecx,(%esp)
  800e63:	0f 86 d7 00 00 00    	jbe    800f40 <__umoddi3+0x140>
  800e69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e71:	83 c4 1c             	add    $0x1c,%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	85 ff                	test   %edi,%edi
  800e82:	89 fd                	mov    %edi,%ebp
  800e84:	75 0b                	jne    800e91 <__umoddi3+0x91>
  800e86:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f7                	div    %edi
  800e8f:	89 c5                	mov    %eax,%ebp
  800e91:	89 f0                	mov    %esi,%eax
  800e93:	31 d2                	xor    %edx,%edx
  800e95:	f7 f5                	div    %ebp
  800e97:	89 c8                	mov    %ecx,%eax
  800e99:	f7 f5                	div    %ebp
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	eb 99                	jmp    800e38 <__umoddi3+0x38>
  800e9f:	90                   	nop
  800ea0:	89 c8                	mov    %ecx,%eax
  800ea2:	89 f2                	mov    %esi,%edx
  800ea4:	83 c4 1c             	add    $0x1c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	8b 34 24             	mov    (%esp),%esi
  800eb3:	bf 20 00 00 00       	mov    $0x20,%edi
  800eb8:	89 e9                	mov    %ebp,%ecx
  800eba:	29 ef                	sub    %ebp,%edi
  800ebc:	d3 e0                	shl    %cl,%eax
  800ebe:	89 f9                	mov    %edi,%ecx
  800ec0:	89 f2                	mov    %esi,%edx
  800ec2:	d3 ea                	shr    %cl,%edx
  800ec4:	89 e9                	mov    %ebp,%ecx
  800ec6:	09 c2                	or     %eax,%edx
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	89 14 24             	mov    %edx,(%esp)
  800ecd:	89 f2                	mov    %esi,%edx
  800ecf:	d3 e2                	shl    %cl,%edx
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800edb:	d3 e8                	shr    %cl,%eax
  800edd:	89 e9                	mov    %ebp,%ecx
  800edf:	89 c6                	mov    %eax,%esi
  800ee1:	d3 e3                	shl    %cl,%ebx
  800ee3:	89 f9                	mov    %edi,%ecx
  800ee5:	89 d0                	mov    %edx,%eax
  800ee7:	d3 e8                	shr    %cl,%eax
  800ee9:	89 e9                	mov    %ebp,%ecx
  800eeb:	09 d8                	or     %ebx,%eax
  800eed:	89 d3                	mov    %edx,%ebx
  800eef:	89 f2                	mov    %esi,%edx
  800ef1:	f7 34 24             	divl   (%esp)
  800ef4:	89 d6                	mov    %edx,%esi
  800ef6:	d3 e3                	shl    %cl,%ebx
  800ef8:	f7 64 24 04          	mull   0x4(%esp)
  800efc:	39 d6                	cmp    %edx,%esi
  800efe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	89 c3                	mov    %eax,%ebx
  800f06:	72 08                	jb     800f10 <__umoddi3+0x110>
  800f08:	75 11                	jne    800f1b <__umoddi3+0x11b>
  800f0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f0e:	73 0b                	jae    800f1b <__umoddi3+0x11b>
  800f10:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f14:	1b 14 24             	sbb    (%esp),%edx
  800f17:	89 d1                	mov    %edx,%ecx
  800f19:	89 c3                	mov    %eax,%ebx
  800f1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f1f:	29 da                	sub    %ebx,%edx
  800f21:	19 ce                	sbb    %ecx,%esi
  800f23:	89 f9                	mov    %edi,%ecx
  800f25:	89 f0                	mov    %esi,%eax
  800f27:	d3 e0                	shl    %cl,%eax
  800f29:	89 e9                	mov    %ebp,%ecx
  800f2b:	d3 ea                	shr    %cl,%edx
  800f2d:	89 e9                	mov    %ebp,%ecx
  800f2f:	d3 ee                	shr    %cl,%esi
  800f31:	09 d0                	or     %edx,%eax
  800f33:	89 f2                	mov    %esi,%edx
  800f35:	83 c4 1c             	add    $0x1c,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
  800f40:	29 f9                	sub    %edi,%ecx
  800f42:	19 d6                	sbb    %edx,%esi
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f4c:	e9 18 ff ff ff       	jmp    800e69 <__umoddi3+0x69>
