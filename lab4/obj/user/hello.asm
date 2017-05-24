
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 60 0f 80 00       	push   $0x800f60
  80003e:	e8 06 01 00 00       	call   800149 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 0f 80 00       	push   $0x800f6e
  800054:	e8 f0 00 00 00       	call   800149 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 25 0a 00 00       	call   800a93 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 a1 09 00 00       	call   800a52 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	75 1a                	jne    8000ef <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 ff 00 00 00       	push   $0xff
  8000dd:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 2f 09 00 00       	call   800a15 <sys_cputs>
		b->idx = 0;
  8000e6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ec:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	ff 75 0c             	pushl  0xc(%ebp)
  800118:	ff 75 08             	pushl  0x8(%ebp)
  80011b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800121:	50                   	push   %eax
  800122:	68 b6 00 80 00       	push   $0x8000b6
  800127:	e8 54 01 00 00       	call   800280 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012c:	83 c4 08             	add    $0x8,%esp
  80012f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800135:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	e8 d4 08 00 00       	call   800a15 <sys_cputs>

	return b.cnt;
}
  800141:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80014f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800152:	50                   	push   %eax
  800153:	ff 75 08             	pushl  0x8(%ebp)
  800156:	e8 9d ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80015b:	c9                   	leave  
  80015c:	c3                   	ret    

0080015d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 1c             	sub    $0x1c,%esp
  800166:	89 c7                	mov    %eax,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	8b 45 08             	mov    0x8(%ebp),%eax
  80016d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800170:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800173:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800176:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800179:	bb 00 00 00 00       	mov    $0x0,%ebx
  80017e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800181:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800184:	39 d3                	cmp    %edx,%ebx
  800186:	72 05                	jb     80018d <printnum+0x30>
  800188:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018b:	77 45                	ja     8001d2 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	ff 75 18             	pushl  0x18(%ebp)
  800193:	8b 45 14             	mov    0x14(%ebp),%eax
  800196:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800199:	53                   	push   %ebx
  80019a:	ff 75 10             	pushl  0x10(%ebp)
  80019d:	83 ec 08             	sub    $0x8,%esp
  8001a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ac:	e8 1f 0b 00 00       	call   800cd0 <__udivdi3>
  8001b1:	83 c4 18             	add    $0x18,%esp
  8001b4:	52                   	push   %edx
  8001b5:	50                   	push   %eax
  8001b6:	89 f2                	mov    %esi,%edx
  8001b8:	89 f8                	mov    %edi,%eax
  8001ba:	e8 9e ff ff ff       	call   80015d <printnum>
  8001bf:	83 c4 20             	add    $0x20,%esp
  8001c2:	eb 18                	jmp    8001dc <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c4:	83 ec 08             	sub    $0x8,%esp
  8001c7:	56                   	push   %esi
  8001c8:	ff 75 18             	pushl  0x18(%ebp)
  8001cb:	ff d7                	call   *%edi
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	eb 03                	jmp    8001d5 <printnum+0x78>
  8001d2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d5:	83 eb 01             	sub    $0x1,%ebx
  8001d8:	85 db                	test   %ebx,%ebx
  8001da:	7f e8                	jg     8001c4 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001dc:	83 ec 08             	sub    $0x8,%esp
  8001df:	56                   	push   %esi
  8001e0:	83 ec 04             	sub    $0x4,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 0c 0c 00 00       	call   800e00 <__umoddi3>
  8001f4:	83 c4 14             	add    $0x14,%esp
  8001f7:	0f be 80 8f 0f 80 00 	movsbl 0x800f8f(%eax),%eax
  8001fe:	50                   	push   %eax
  8001ff:	ff d7                	call   *%edi
}
  800201:	83 c4 10             	add    $0x10,%esp
  800204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800207:	5b                   	pop    %ebx
  800208:	5e                   	pop    %esi
  800209:	5f                   	pop    %edi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80020f:	83 fa 01             	cmp    $0x1,%edx
  800212:	7e 0e                	jle    800222 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800214:	8b 10                	mov    (%eax),%edx
  800216:	8d 4a 08             	lea    0x8(%edx),%ecx
  800219:	89 08                	mov    %ecx,(%eax)
  80021b:	8b 02                	mov    (%edx),%eax
  80021d:	8b 52 04             	mov    0x4(%edx),%edx
  800220:	eb 22                	jmp    800244 <getuint+0x38>
	else if (lflag)
  800222:	85 d2                	test   %edx,%edx
  800224:	74 10                	je     800236 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800226:	8b 10                	mov    (%eax),%edx
  800228:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 02                	mov    (%edx),%eax
  80022f:	ba 00 00 00 00       	mov    $0x0,%edx
  800234:	eb 0e                	jmp    800244 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800236:	8b 10                	mov    (%eax),%edx
  800238:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 02                	mov    (%edx),%eax
  80023f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800250:	8b 10                	mov    (%eax),%edx
  800252:	3b 50 04             	cmp    0x4(%eax),%edx
  800255:	73 0a                	jae    800261 <sprintputch+0x1b>
		*b->buf++ = ch;
  800257:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	88 02                	mov    %al,(%edx)
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800269:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 08             	pushl  0x8(%ebp)
  800276:	e8 05 00 00 00       	call   800280 <vprintfmt>
	va_end(ap);
}
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 2c             	sub    $0x2c,%esp
  800289:	8b 75 08             	mov    0x8(%ebp),%esi
  80028c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80028f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800292:	eb 12                	jmp    8002a6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800294:	85 c0                	test   %eax,%eax
  800296:	0f 84 89 03 00 00    	je     800625 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80029c:	83 ec 08             	sub    $0x8,%esp
  80029f:	53                   	push   %ebx
  8002a0:	50                   	push   %eax
  8002a1:	ff d6                	call   *%esi
  8002a3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a6:	83 c7 01             	add    $0x1,%edi
  8002a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ad:	83 f8 25             	cmp    $0x25,%eax
  8002b0:	75 e2                	jne    800294 <vprintfmt+0x14>
  8002b2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	eb 07                	jmp    8002d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d9:	8d 47 01             	lea    0x1(%edi),%eax
  8002dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002df:	0f b6 07             	movzbl (%edi),%eax
  8002e2:	0f b6 c8             	movzbl %al,%ecx
  8002e5:	83 e8 23             	sub    $0x23,%eax
  8002e8:	3c 55                	cmp    $0x55,%al
  8002ea:	0f 87 1a 03 00 00    	ja     80060a <vprintfmt+0x38a>
  8002f0:	0f b6 c0             	movzbl %al,%eax
  8002f3:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  8002fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800301:	eb d6                	jmp    8002d9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800306:	b8 00 00 00 00       	mov    $0x0,%eax
  80030b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800311:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800315:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800318:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80031b:	83 fa 09             	cmp    $0x9,%edx
  80031e:	77 39                	ja     800359 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800320:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800323:	eb e9                	jmp    80030e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800325:	8b 45 14             	mov    0x14(%ebp),%eax
  800328:	8d 48 04             	lea    0x4(%eax),%ecx
  80032b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032e:	8b 00                	mov    (%eax),%eax
  800330:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800336:	eb 27                	jmp    80035f <vprintfmt+0xdf>
  800338:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033b:	85 c0                	test   %eax,%eax
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	0f 49 c8             	cmovns %eax,%ecx
  800345:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034b:	eb 8c                	jmp    8002d9 <vprintfmt+0x59>
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800350:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800357:	eb 80                	jmp    8002d9 <vprintfmt+0x59>
  800359:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800363:	0f 89 70 ff ff ff    	jns    8002d9 <vprintfmt+0x59>
				width = precision, precision = -1;
  800369:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800376:	e9 5e ff ff ff       	jmp    8002d9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80037b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800381:	e9 53 ff ff ff       	jmp    8002d9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 50 04             	lea    0x4(%eax),%edx
  80038c:	89 55 14             	mov    %edx,0x14(%ebp)
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	53                   	push   %ebx
  800393:	ff 30                	pushl  (%eax)
  800395:	ff d6                	call   *%esi
			break;
  800397:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039d:	e9 04 ff ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 50 04             	lea    0x4(%eax),%edx
  8003a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	99                   	cltd   
  8003ae:	31 d0                	xor    %edx,%eax
  8003b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 08             	cmp    $0x8,%eax
  8003b5:	7f 0b                	jg     8003c2 <vprintfmt+0x142>
  8003b7:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	75 18                	jne    8003da <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8003c2:	50                   	push   %eax
  8003c3:	68 a7 0f 80 00       	push   $0x800fa7
  8003c8:	53                   	push   %ebx
  8003c9:	56                   	push   %esi
  8003ca:	e8 94 fe ff ff       	call   800263 <printfmt>
  8003cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d5:	e9 cc fe ff ff       	jmp    8002a6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003da:	52                   	push   %edx
  8003db:	68 b0 0f 80 00       	push   $0x800fb0
  8003e0:	53                   	push   %ebx
  8003e1:	56                   	push   %esi
  8003e2:	e8 7c fe ff ff       	call   800263 <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ed:	e9 b4 fe ff ff       	jmp    8002a6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	8d 50 04             	lea    0x4(%eax),%edx
  8003f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fb:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003fd:	85 ff                	test   %edi,%edi
  8003ff:	b8 a0 0f 80 00       	mov    $0x800fa0,%eax
  800404:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800407:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040b:	0f 8e 94 00 00 00    	jle    8004a5 <vprintfmt+0x225>
  800411:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800415:	0f 84 98 00 00 00    	je     8004b3 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041b:	83 ec 08             	sub    $0x8,%esp
  80041e:	ff 75 d0             	pushl  -0x30(%ebp)
  800421:	57                   	push   %edi
  800422:	e8 86 02 00 00       	call   8006ad <strnlen>
  800427:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80042a:	29 c1                	sub    %eax,%ecx
  80042c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80042f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800432:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800439:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043e:	eb 0f                	jmp    80044f <vprintfmt+0x1cf>
					putch(padc, putdat);
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800449:	83 ef 01             	sub    $0x1,%edi
  80044c:	83 c4 10             	add    $0x10,%esp
  80044f:	85 ff                	test   %edi,%edi
  800451:	7f ed                	jg     800440 <vprintfmt+0x1c0>
  800453:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800456:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800459:	85 c9                	test   %ecx,%ecx
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	0f 49 c1             	cmovns %ecx,%eax
  800463:	29 c1                	sub    %eax,%ecx
  800465:	89 75 08             	mov    %esi,0x8(%ebp)
  800468:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80046b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046e:	89 cb                	mov    %ecx,%ebx
  800470:	eb 4d                	jmp    8004bf <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800472:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800476:	74 1b                	je     800493 <vprintfmt+0x213>
  800478:	0f be c0             	movsbl %al,%eax
  80047b:	83 e8 20             	sub    $0x20,%eax
  80047e:	83 f8 5e             	cmp    $0x5e,%eax
  800481:	76 10                	jbe    800493 <vprintfmt+0x213>
					putch('?', putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 0c             	pushl  0xc(%ebp)
  800489:	6a 3f                	push   $0x3f
  80048b:	ff 55 08             	call   *0x8(%ebp)
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	eb 0d                	jmp    8004a0 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	ff 75 0c             	pushl  0xc(%ebp)
  800499:	52                   	push   %edx
  80049a:	ff 55 08             	call   *0x8(%ebp)
  80049d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a0:	83 eb 01             	sub    $0x1,%ebx
  8004a3:	eb 1a                	jmp    8004bf <vprintfmt+0x23f>
  8004a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b1:	eb 0c                	jmp    8004bf <vprintfmt+0x23f>
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bf:	83 c7 01             	add    $0x1,%edi
  8004c2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c6:	0f be d0             	movsbl %al,%edx
  8004c9:	85 d2                	test   %edx,%edx
  8004cb:	74 23                	je     8004f0 <vprintfmt+0x270>
  8004cd:	85 f6                	test   %esi,%esi
  8004cf:	78 a1                	js     800472 <vprintfmt+0x1f2>
  8004d1:	83 ee 01             	sub    $0x1,%esi
  8004d4:	79 9c                	jns    800472 <vprintfmt+0x1f2>
  8004d6:	89 df                	mov    %ebx,%edi
  8004d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004de:	eb 18                	jmp    8004f8 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	53                   	push   %ebx
  8004e4:	6a 20                	push   $0x20
  8004e6:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e8:	83 ef 01             	sub    $0x1,%edi
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb 08                	jmp    8004f8 <vprintfmt+0x278>
  8004f0:	89 df                	mov    %ebx,%edi
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	85 ff                	test   %edi,%edi
  8004fa:	7f e4                	jg     8004e0 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	e9 a2 fd ff ff       	jmp    8002a6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800504:	83 fa 01             	cmp    $0x1,%edx
  800507:	7e 16                	jle    80051f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 50 08             	lea    0x8(%eax),%edx
  80050f:	89 55 14             	mov    %edx,0x14(%ebp)
  800512:	8b 50 04             	mov    0x4(%eax),%edx
  800515:	8b 00                	mov    (%eax),%eax
  800517:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051d:	eb 32                	jmp    800551 <vprintfmt+0x2d1>
	else if (lflag)
  80051f:	85 d2                	test   %edx,%edx
  800521:	74 18                	je     80053b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8d 50 04             	lea    0x4(%eax),%edx
  800529:	89 55 14             	mov    %edx,0x14(%ebp)
  80052c:	8b 00                	mov    (%eax),%eax
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800531:	89 c1                	mov    %eax,%ecx
  800533:	c1 f9 1f             	sar    $0x1f,%ecx
  800536:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800539:	eb 16                	jmp    800551 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8d 50 04             	lea    0x4(%eax),%edx
  800541:	89 55 14             	mov    %edx,0x14(%ebp)
  800544:	8b 00                	mov    (%eax),%eax
  800546:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800549:	89 c1                	mov    %eax,%ecx
  80054b:	c1 f9 1f             	sar    $0x1f,%ecx
  80054e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800551:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800554:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800557:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800560:	79 74                	jns    8005d6 <vprintfmt+0x356>
				putch('-', putdat);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	53                   	push   %ebx
  800566:	6a 2d                	push   $0x2d
  800568:	ff d6                	call   *%esi
				num = -(long long) num;
  80056a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800570:	f7 d8                	neg    %eax
  800572:	83 d2 00             	adc    $0x0,%edx
  800575:	f7 da                	neg    %edx
  800577:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80057a:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80057f:	eb 55                	jmp    8005d6 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800581:	8d 45 14             	lea    0x14(%ebp),%eax
  800584:	e8 83 fc ff ff       	call   80020c <getuint>
			base = 10;
  800589:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80058e:	eb 46                	jmp    8005d6 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800590:	8d 45 14             	lea    0x14(%ebp),%eax
  800593:	e8 74 fc ff ff       	call   80020c <getuint>
			base = 8;
  800598:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80059d:	eb 37                	jmp    8005d6 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	53                   	push   %ebx
  8005a3:	6a 30                	push   $0x30
  8005a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005a7:	83 c4 08             	add    $0x8,%esp
  8005aa:	53                   	push   %ebx
  8005ab:	6a 78                	push   $0x78
  8005ad:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8d 50 04             	lea    0x4(%eax),%edx
  8005b5:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005bf:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c2:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c7:	eb 0d                	jmp    8005d6 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005cc:	e8 3b fc ff ff       	call   80020c <getuint>
			base = 16;
  8005d1:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d6:	83 ec 0c             	sub    $0xc,%esp
  8005d9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005dd:	57                   	push   %edi
  8005de:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e1:	51                   	push   %ecx
  8005e2:	52                   	push   %edx
  8005e3:	50                   	push   %eax
  8005e4:	89 da                	mov    %ebx,%edx
  8005e6:	89 f0                	mov    %esi,%eax
  8005e8:	e8 70 fb ff ff       	call   80015d <printnum>
			break;
  8005ed:	83 c4 20             	add    $0x20,%esp
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f3:	e9 ae fc ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	51                   	push   %ecx
  8005fd:	ff d6                	call   *%esi
			break;
  8005ff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800605:	e9 9c fc ff ff       	jmp    8002a6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	53                   	push   %ebx
  80060e:	6a 25                	push   $0x25
  800610:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	eb 03                	jmp    80061a <vprintfmt+0x39a>
  800617:	83 ef 01             	sub    $0x1,%edi
  80061a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80061e:	75 f7                	jne    800617 <vprintfmt+0x397>
  800620:	e9 81 fc ff ff       	jmp    8002a6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800625:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800628:	5b                   	pop    %ebx
  800629:	5e                   	pop    %esi
  80062a:	5f                   	pop    %edi
  80062b:	5d                   	pop    %ebp
  80062c:	c3                   	ret    

0080062d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	83 ec 18             	sub    $0x18,%esp
  800633:	8b 45 08             	mov    0x8(%ebp),%eax
  800636:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800639:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80063c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800640:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800643:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80064a:	85 c0                	test   %eax,%eax
  80064c:	74 26                	je     800674 <vsnprintf+0x47>
  80064e:	85 d2                	test   %edx,%edx
  800650:	7e 22                	jle    800674 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800652:	ff 75 14             	pushl  0x14(%ebp)
  800655:	ff 75 10             	pushl  0x10(%ebp)
  800658:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	68 46 02 80 00       	push   $0x800246
  800661:	e8 1a fc ff ff       	call   800280 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800666:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800669:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80066f:	83 c4 10             	add    $0x10,%esp
  800672:	eb 05                	jmp    800679 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800674:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800679:	c9                   	leave  
  80067a:	c3                   	ret    

0080067b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80067b:	55                   	push   %ebp
  80067c:	89 e5                	mov    %esp,%ebp
  80067e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800681:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800684:	50                   	push   %eax
  800685:	ff 75 10             	pushl  0x10(%ebp)
  800688:	ff 75 0c             	pushl  0xc(%ebp)
  80068b:	ff 75 08             	pushl  0x8(%ebp)
  80068e:	e8 9a ff ff ff       	call   80062d <vsnprintf>
	va_end(ap);

	return rc;
}
  800693:	c9                   	leave  
  800694:	c3                   	ret    

00800695 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
  800698:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80069b:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a0:	eb 03                	jmp    8006a5 <strlen+0x10>
		n++;
  8006a2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006a9:	75 f7                	jne    8006a2 <strlen+0xd>
		n++;
	return n;
}
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bb:	eb 03                	jmp    8006c0 <strnlen+0x13>
		n++;
  8006bd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006c0:	39 c2                	cmp    %eax,%edx
  8006c2:	74 08                	je     8006cc <strnlen+0x1f>
  8006c4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8006c8:	75 f3                	jne    8006bd <strnlen+0x10>
  8006ca:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8006d8:	89 c2                	mov    %eax,%edx
  8006da:	83 c2 01             	add    $0x1,%edx
  8006dd:	83 c1 01             	add    $0x1,%ecx
  8006e0:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8006e4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8006e7:	84 db                	test   %bl,%bl
  8006e9:	75 ef                	jne    8006da <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8006eb:	5b                   	pop    %ebx
  8006ec:	5d                   	pop    %ebp
  8006ed:	c3                   	ret    

008006ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	53                   	push   %ebx
  8006f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8006f5:	53                   	push   %ebx
  8006f6:	e8 9a ff ff ff       	call   800695 <strlen>
  8006fb:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	01 d8                	add    %ebx,%eax
  800703:	50                   	push   %eax
  800704:	e8 c5 ff ff ff       	call   8006ce <strcpy>
	return dst;
}
  800709:	89 d8                	mov    %ebx,%eax
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	56                   	push   %esi
  800714:	53                   	push   %ebx
  800715:	8b 75 08             	mov    0x8(%ebp),%esi
  800718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80071b:	89 f3                	mov    %esi,%ebx
  80071d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800720:	89 f2                	mov    %esi,%edx
  800722:	eb 0f                	jmp    800733 <strncpy+0x23>
		*dst++ = *src;
  800724:	83 c2 01             	add    $0x1,%edx
  800727:	0f b6 01             	movzbl (%ecx),%eax
  80072a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80072d:	80 39 01             	cmpb   $0x1,(%ecx)
  800730:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800733:	39 da                	cmp    %ebx,%edx
  800735:	75 ed                	jne    800724 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800737:	89 f0                	mov    %esi,%eax
  800739:	5b                   	pop    %ebx
  80073a:	5e                   	pop    %esi
  80073b:	5d                   	pop    %ebp
  80073c:	c3                   	ret    

0080073d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	56                   	push   %esi
  800741:	53                   	push   %ebx
  800742:	8b 75 08             	mov    0x8(%ebp),%esi
  800745:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800748:	8b 55 10             	mov    0x10(%ebp),%edx
  80074b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80074d:	85 d2                	test   %edx,%edx
  80074f:	74 21                	je     800772 <strlcpy+0x35>
  800751:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800755:	89 f2                	mov    %esi,%edx
  800757:	eb 09                	jmp    800762 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800759:	83 c2 01             	add    $0x1,%edx
  80075c:	83 c1 01             	add    $0x1,%ecx
  80075f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800762:	39 c2                	cmp    %eax,%edx
  800764:	74 09                	je     80076f <strlcpy+0x32>
  800766:	0f b6 19             	movzbl (%ecx),%ebx
  800769:	84 db                	test   %bl,%bl
  80076b:	75 ec                	jne    800759 <strlcpy+0x1c>
  80076d:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80076f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800772:	29 f0                	sub    %esi,%eax
}
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800781:	eb 06                	jmp    800789 <strcmp+0x11>
		p++, q++;
  800783:	83 c1 01             	add    $0x1,%ecx
  800786:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800789:	0f b6 01             	movzbl (%ecx),%eax
  80078c:	84 c0                	test   %al,%al
  80078e:	74 04                	je     800794 <strcmp+0x1c>
  800790:	3a 02                	cmp    (%edx),%al
  800792:	74 ef                	je     800783 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800794:	0f b6 c0             	movzbl %al,%eax
  800797:	0f b6 12             	movzbl (%edx),%edx
  80079a:	29 d0                	sub    %edx,%eax
}
  80079c:	5d                   	pop    %ebp
  80079d:	c3                   	ret    

0080079e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	53                   	push   %ebx
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 c3                	mov    %eax,%ebx
  8007aa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007ad:	eb 06                	jmp    8007b5 <strncmp+0x17>
		n--, p++, q++;
  8007af:	83 c0 01             	add    $0x1,%eax
  8007b2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007b5:	39 d8                	cmp    %ebx,%eax
  8007b7:	74 15                	je     8007ce <strncmp+0x30>
  8007b9:	0f b6 08             	movzbl (%eax),%ecx
  8007bc:	84 c9                	test   %cl,%cl
  8007be:	74 04                	je     8007c4 <strncmp+0x26>
  8007c0:	3a 0a                	cmp    (%edx),%cl
  8007c2:	74 eb                	je     8007af <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007c4:	0f b6 00             	movzbl (%eax),%eax
  8007c7:	0f b6 12             	movzbl (%edx),%edx
  8007ca:	29 d0                	sub    %edx,%eax
  8007cc:	eb 05                	jmp    8007d3 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8007ce:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8007d3:	5b                   	pop    %ebx
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8007e0:	eb 07                	jmp    8007e9 <strchr+0x13>
		if (*s == c)
  8007e2:	38 ca                	cmp    %cl,%dl
  8007e4:	74 0f                	je     8007f5 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8007e6:	83 c0 01             	add    $0x1,%eax
  8007e9:	0f b6 10             	movzbl (%eax),%edx
  8007ec:	84 d2                	test   %dl,%dl
  8007ee:	75 f2                	jne    8007e2 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8007f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800801:	eb 03                	jmp    800806 <strfind+0xf>
  800803:	83 c0 01             	add    $0x1,%eax
  800806:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800809:	38 ca                	cmp    %cl,%dl
  80080b:	74 04                	je     800811 <strfind+0x1a>
  80080d:	84 d2                	test   %dl,%dl
  80080f:	75 f2                	jne    800803 <strfind+0xc>
			break;
	return (char *) s;
}
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	57                   	push   %edi
  800817:	56                   	push   %esi
  800818:	53                   	push   %ebx
  800819:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80081f:	85 c9                	test   %ecx,%ecx
  800821:	74 36                	je     800859 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800823:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800829:	75 28                	jne    800853 <memset+0x40>
  80082b:	f6 c1 03             	test   $0x3,%cl
  80082e:	75 23                	jne    800853 <memset+0x40>
		c &= 0xFF;
  800830:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800834:	89 d3                	mov    %edx,%ebx
  800836:	c1 e3 08             	shl    $0x8,%ebx
  800839:	89 d6                	mov    %edx,%esi
  80083b:	c1 e6 18             	shl    $0x18,%esi
  80083e:	89 d0                	mov    %edx,%eax
  800840:	c1 e0 10             	shl    $0x10,%eax
  800843:	09 f0                	or     %esi,%eax
  800845:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800847:	89 d8                	mov    %ebx,%eax
  800849:	09 d0                	or     %edx,%eax
  80084b:	c1 e9 02             	shr    $0x2,%ecx
  80084e:	fc                   	cld    
  80084f:	f3 ab                	rep stos %eax,%es:(%edi)
  800851:	eb 06                	jmp    800859 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
  800856:	fc                   	cld    
  800857:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800859:	89 f8                	mov    %edi,%eax
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5f                   	pop    %edi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	57                   	push   %edi
  800864:	56                   	push   %esi
  800865:	8b 45 08             	mov    0x8(%ebp),%eax
  800868:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80086e:	39 c6                	cmp    %eax,%esi
  800870:	73 35                	jae    8008a7 <memmove+0x47>
  800872:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800875:	39 d0                	cmp    %edx,%eax
  800877:	73 2e                	jae    8008a7 <memmove+0x47>
		s += n;
		d += n;
  800879:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80087c:	89 d6                	mov    %edx,%esi
  80087e:	09 fe                	or     %edi,%esi
  800880:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800886:	75 13                	jne    80089b <memmove+0x3b>
  800888:	f6 c1 03             	test   $0x3,%cl
  80088b:	75 0e                	jne    80089b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80088d:	83 ef 04             	sub    $0x4,%edi
  800890:	8d 72 fc             	lea    -0x4(%edx),%esi
  800893:	c1 e9 02             	shr    $0x2,%ecx
  800896:	fd                   	std    
  800897:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800899:	eb 09                	jmp    8008a4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80089b:	83 ef 01             	sub    $0x1,%edi
  80089e:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008a1:	fd                   	std    
  8008a2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008a4:	fc                   	cld    
  8008a5:	eb 1d                	jmp    8008c4 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008a7:	89 f2                	mov    %esi,%edx
  8008a9:	09 c2                	or     %eax,%edx
  8008ab:	f6 c2 03             	test   $0x3,%dl
  8008ae:	75 0f                	jne    8008bf <memmove+0x5f>
  8008b0:	f6 c1 03             	test   $0x3,%cl
  8008b3:	75 0a                	jne    8008bf <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008b5:	c1 e9 02             	shr    $0x2,%ecx
  8008b8:	89 c7                	mov    %eax,%edi
  8008ba:	fc                   	cld    
  8008bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008bd:	eb 05                	jmp    8008c4 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008bf:	89 c7                	mov    %eax,%edi
  8008c1:	fc                   	cld    
  8008c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008c4:	5e                   	pop    %esi
  8008c5:	5f                   	pop    %edi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8008cb:	ff 75 10             	pushl  0x10(%ebp)
  8008ce:	ff 75 0c             	pushl  0xc(%ebp)
  8008d1:	ff 75 08             	pushl  0x8(%ebp)
  8008d4:	e8 87 ff ff ff       	call   800860 <memmove>
}
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e6:	89 c6                	mov    %eax,%esi
  8008e8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8008eb:	eb 1a                	jmp    800907 <memcmp+0x2c>
		if (*s1 != *s2)
  8008ed:	0f b6 08             	movzbl (%eax),%ecx
  8008f0:	0f b6 1a             	movzbl (%edx),%ebx
  8008f3:	38 d9                	cmp    %bl,%cl
  8008f5:	74 0a                	je     800901 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8008f7:	0f b6 c1             	movzbl %cl,%eax
  8008fa:	0f b6 db             	movzbl %bl,%ebx
  8008fd:	29 d8                	sub    %ebx,%eax
  8008ff:	eb 0f                	jmp    800910 <memcmp+0x35>
		s1++, s2++;
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800907:	39 f0                	cmp    %esi,%eax
  800909:	75 e2                	jne    8008ed <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80091b:	89 c1                	mov    %eax,%ecx
  80091d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800920:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800924:	eb 0a                	jmp    800930 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800926:	0f b6 10             	movzbl (%eax),%edx
  800929:	39 da                	cmp    %ebx,%edx
  80092b:	74 07                	je     800934 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	39 c8                	cmp    %ecx,%eax
  800932:	72 f2                	jb     800926 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800943:	eb 03                	jmp    800948 <strtol+0x11>
		s++;
  800945:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800948:	0f b6 01             	movzbl (%ecx),%eax
  80094b:	3c 20                	cmp    $0x20,%al
  80094d:	74 f6                	je     800945 <strtol+0xe>
  80094f:	3c 09                	cmp    $0x9,%al
  800951:	74 f2                	je     800945 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800953:	3c 2b                	cmp    $0x2b,%al
  800955:	75 0a                	jne    800961 <strtol+0x2a>
		s++;
  800957:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80095a:	bf 00 00 00 00       	mov    $0x0,%edi
  80095f:	eb 11                	jmp    800972 <strtol+0x3b>
  800961:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800966:	3c 2d                	cmp    $0x2d,%al
  800968:	75 08                	jne    800972 <strtol+0x3b>
		s++, neg = 1;
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800972:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800978:	75 15                	jne    80098f <strtol+0x58>
  80097a:	80 39 30             	cmpb   $0x30,(%ecx)
  80097d:	75 10                	jne    80098f <strtol+0x58>
  80097f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800983:	75 7c                	jne    800a01 <strtol+0xca>
		s += 2, base = 16;
  800985:	83 c1 02             	add    $0x2,%ecx
  800988:	bb 10 00 00 00       	mov    $0x10,%ebx
  80098d:	eb 16                	jmp    8009a5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80098f:	85 db                	test   %ebx,%ebx
  800991:	75 12                	jne    8009a5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800993:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800998:	80 39 30             	cmpb   $0x30,(%ecx)
  80099b:	75 08                	jne    8009a5 <strtol+0x6e>
		s++, base = 8;
  80099d:	83 c1 01             	add    $0x1,%ecx
  8009a0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009aa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009ad:	0f b6 11             	movzbl (%ecx),%edx
  8009b0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009b3:	89 f3                	mov    %esi,%ebx
  8009b5:	80 fb 09             	cmp    $0x9,%bl
  8009b8:	77 08                	ja     8009c2 <strtol+0x8b>
			dig = *s - '0';
  8009ba:	0f be d2             	movsbl %dl,%edx
  8009bd:	83 ea 30             	sub    $0x30,%edx
  8009c0:	eb 22                	jmp    8009e4 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009c2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009c5:	89 f3                	mov    %esi,%ebx
  8009c7:	80 fb 19             	cmp    $0x19,%bl
  8009ca:	77 08                	ja     8009d4 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8009cc:	0f be d2             	movsbl %dl,%edx
  8009cf:	83 ea 57             	sub    $0x57,%edx
  8009d2:	eb 10                	jmp    8009e4 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8009d4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8009d7:	89 f3                	mov    %esi,%ebx
  8009d9:	80 fb 19             	cmp    $0x19,%bl
  8009dc:	77 16                	ja     8009f4 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8009de:	0f be d2             	movsbl %dl,%edx
  8009e1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8009e4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8009e7:	7d 0b                	jge    8009f4 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	0f af 45 10          	imul   0x10(%ebp),%eax
  8009f0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8009f2:	eb b9                	jmp    8009ad <strtol+0x76>

	if (endptr)
  8009f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009f8:	74 0d                	je     800a07 <strtol+0xd0>
		*endptr = (char *) s;
  8009fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009fd:	89 0e                	mov    %ecx,(%esi)
  8009ff:	eb 06                	jmp    800a07 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a01:	85 db                	test   %ebx,%ebx
  800a03:	74 98                	je     80099d <strtol+0x66>
  800a05:	eb 9e                	jmp    8009a5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a07:	89 c2                	mov    %eax,%edx
  800a09:	f7 da                	neg    %edx
  800a0b:	85 ff                	test   %edi,%edi
  800a0d:	0f 45 c2             	cmovne %edx,%eax
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	89 c3                	mov    %eax,%ebx
  800a28:	89 c7                	mov    %eax,%edi
  800a2a:	89 c6                	mov    %eax,%esi
  800a2c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a2e:	5b                   	pop    %ebx
  800a2f:	5e                   	pop    %esi
  800a30:	5f                   	pop    %edi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	57                   	push   %edi
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800a43:	89 d1                	mov    %edx,%ecx
  800a45:	89 d3                	mov    %edx,%ebx
  800a47:	89 d7                	mov    %edx,%edi
  800a49:	89 d6                	mov    %edx,%esi
  800a4b:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5e                   	pop    %esi
  800a4f:	5f                   	pop    %edi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	57                   	push   %edi
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a60:	b8 03 00 00 00       	mov    $0x3,%eax
  800a65:	8b 55 08             	mov    0x8(%ebp),%edx
  800a68:	89 cb                	mov    %ecx,%ebx
  800a6a:	89 cf                	mov    %ecx,%edi
  800a6c:	89 ce                	mov    %ecx,%esi
  800a6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a70:	85 c0                	test   %eax,%eax
  800a72:	7e 17                	jle    800a8b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800a74:	83 ec 0c             	sub    $0xc,%esp
  800a77:	50                   	push   %eax
  800a78:	6a 03                	push   $0x3
  800a7a:	68 e4 11 80 00       	push   $0x8011e4
  800a7f:	6a 23                	push   $0x23
  800a81:	68 01 12 80 00       	push   $0x801201
  800a86:	e8 f5 01 00 00       	call   800c80 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800a8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a99:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800aa3:	89 d1                	mov    %edx,%ecx
  800aa5:	89 d3                	mov    %edx,%ebx
  800aa7:	89 d7                	mov    %edx,%edi
  800aa9:	89 d6                	mov    %edx,%esi
  800aab:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_yield>:

void
sys_yield(void)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab8:	ba 00 00 00 00       	mov    $0x0,%edx
  800abd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac2:	89 d1                	mov    %edx,%ecx
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	89 d7                	mov    %edx,%edi
  800ac8:	89 d6                	mov    %edx,%esi
  800aca:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	53                   	push   %ebx
  800ad7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	be 00 00 00 00       	mov    $0x0,%esi
  800adf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ae4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae7:	8b 55 08             	mov    0x8(%ebp),%edx
  800aea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800aed:	89 f7                	mov    %esi,%edi
  800aef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af1:	85 c0                	test   %eax,%eax
  800af3:	7e 17                	jle    800b0c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	50                   	push   %eax
  800af9:	6a 04                	push   $0x4
  800afb:	68 e4 11 80 00       	push   $0x8011e4
  800b00:	6a 23                	push   $0x23
  800b02:	68 01 12 80 00       	push   $0x801201
  800b07:	e8 74 01 00 00       	call   800c80 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b1d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b2e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	7e 17                	jle    800b4e <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b37:	83 ec 0c             	sub    $0xc,%esp
  800b3a:	50                   	push   %eax
  800b3b:	6a 05                	push   $0x5
  800b3d:	68 e4 11 80 00       	push   $0x8011e4
  800b42:	6a 23                	push   $0x23
  800b44:	68 01 12 80 00       	push   $0x801201
  800b49:	e8 32 01 00 00       	call   800c80 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b51:	5b                   	pop    %ebx
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	57                   	push   %edi
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b64:	b8 06 00 00 00       	mov    $0x6,%eax
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6f:	89 df                	mov    %ebx,%edi
  800b71:	89 de                	mov    %ebx,%esi
  800b73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b75:	85 c0                	test   %eax,%eax
  800b77:	7e 17                	jle    800b90 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 06                	push   $0x6
  800b7f:	68 e4 11 80 00       	push   $0x8011e4
  800b84:	6a 23                	push   $0x23
  800b86:	68 01 12 80 00       	push   $0x801201
  800b8b:	e8 f0 00 00 00       	call   800c80 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800b90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba6:	b8 08 00 00 00       	mov    $0x8,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 df                	mov    %ebx,%edi
  800bb3:	89 de                	mov    %ebx,%esi
  800bb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb7:	85 c0                	test   %eax,%eax
  800bb9:	7e 17                	jle    800bd2 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 08                	push   $0x8
  800bc1:	68 e4 11 80 00       	push   $0x8011e4
  800bc6:	6a 23                	push   $0x23
  800bc8:	68 01 12 80 00       	push   $0x801201
  800bcd:	e8 ae 00 00 00       	call   800c80 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be8:	b8 09 00 00 00       	mov    $0x9,%eax
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 df                	mov    %ebx,%edi
  800bf5:	89 de                	mov    %ebx,%esi
  800bf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	7e 17                	jle    800c14 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 09                	push   $0x9
  800c03:	68 e4 11 80 00       	push   $0x8011e4
  800c08:	6a 23                	push   $0x23
  800c0a:	68 01 12 80 00       	push   $0x801201
  800c0f:	e8 6c 00 00 00       	call   800c80 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c22:	be 00 00 00 00       	mov    $0x0,%esi
  800c27:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c38:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	89 cb                	mov    %ecx,%ebx
  800c57:	89 cf                	mov    %ecx,%edi
  800c59:	89 ce                	mov    %ecx,%esi
  800c5b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	7e 17                	jle    800c78 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 0c                	push   $0xc
  800c67:	68 e4 11 80 00       	push   $0x8011e4
  800c6c:	6a 23                	push   $0x23
  800c6e:	68 01 12 80 00       	push   $0x801201
  800c73:	e8 08 00 00 00       	call   800c80 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800c85:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800c88:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800c8e:	e8 00 fe ff ff       	call   800a93 <sys_getenvid>
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	ff 75 0c             	pushl  0xc(%ebp)
  800c99:	ff 75 08             	pushl  0x8(%ebp)
  800c9c:	56                   	push   %esi
  800c9d:	50                   	push   %eax
  800c9e:	68 10 12 80 00       	push   $0x801210
  800ca3:	e8 a1 f4 ff ff       	call   800149 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ca8:	83 c4 18             	add    $0x18,%esp
  800cab:	53                   	push   %ebx
  800cac:	ff 75 10             	pushl  0x10(%ebp)
  800caf:	e8 44 f4 ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  800cb4:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  800cbb:	e8 89 f4 ff ff       	call   800149 <cprintf>
  800cc0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800cc3:	cc                   	int3   
  800cc4:	eb fd                	jmp    800cc3 <_panic+0x43>
  800cc6:	66 90                	xchg   %ax,%ax
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
