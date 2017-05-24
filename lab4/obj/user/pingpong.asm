
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 99 0d 00 00       	call   800dda <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 a4 0a 00 00       	call   800af3 <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 20 14 80 00       	push   $0x801420
  800059:	e8 4b 01 00 00       	call   8001a9 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 b0 0f 00 00       	call   80101c <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 28 0f 00 00       	call   800fa7 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 6a 0a 00 00       	call   800af3 <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 36 14 80 00       	push   $0x801436
  800091:	e8 13 01 00 00       	call   8001a9 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 6e 0f 00 00       	call   80101c <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 25 0a 00 00       	call   800af3 <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010a:	6a 00                	push   $0x0
  80010c:	e8 a1 09 00 00       	call   800ab2 <sys_env_destroy>
}
  800111:	83 c4 10             	add    $0x10,%esp
  800114:	c9                   	leave  
  800115:	c3                   	ret    

00800116 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	53                   	push   %ebx
  80011a:	83 ec 04             	sub    $0x4,%esp
  80011d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800120:	8b 13                	mov    (%ebx),%edx
  800122:	8d 42 01             	lea    0x1(%edx),%eax
  800125:	89 03                	mov    %eax,(%ebx)
  800127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800133:	75 1a                	jne    80014f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 2f 09 00 00       	call   800a75 <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800161:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800168:	00 00 00 
	b.cnt = 0;
  80016b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800172:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800175:	ff 75 0c             	pushl  0xc(%ebp)
  800178:	ff 75 08             	pushl  0x8(%ebp)
  80017b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800181:	50                   	push   %eax
  800182:	68 16 01 80 00       	push   $0x800116
  800187:	e8 54 01 00 00       	call   8002e0 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018c:	83 c4 08             	add    $0x8,%esp
  80018f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800195:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 d4 08 00 00       	call   800a75 <sys_cputs>

	return b.cnt;
}
  8001a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 9d ff ff ff       	call   800158 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001de:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e4:	39 d3                	cmp    %edx,%ebx
  8001e6:	72 05                	jb     8001ed <printnum+0x30>
  8001e8:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001eb:	77 45                	ja     800232 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ed:	83 ec 0c             	sub    $0xc,%esp
  8001f0:	ff 75 18             	pushl  0x18(%ebp)
  8001f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f6:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f9:	53                   	push   %ebx
  8001fa:	ff 75 10             	pushl  0x10(%ebp)
  8001fd:	83 ec 08             	sub    $0x8,%esp
  800200:	ff 75 e4             	pushl  -0x1c(%ebp)
  800203:	ff 75 e0             	pushl  -0x20(%ebp)
  800206:	ff 75 dc             	pushl  -0x24(%ebp)
  800209:	ff 75 d8             	pushl  -0x28(%ebp)
  80020c:	e8 7f 0f 00 00       	call   801190 <__udivdi3>
  800211:	83 c4 18             	add    $0x18,%esp
  800214:	52                   	push   %edx
  800215:	50                   	push   %eax
  800216:	89 f2                	mov    %esi,%edx
  800218:	89 f8                	mov    %edi,%eax
  80021a:	e8 9e ff ff ff       	call   8001bd <printnum>
  80021f:	83 c4 20             	add    $0x20,%esp
  800222:	eb 18                	jmp    80023c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	ff 75 18             	pushl  0x18(%ebp)
  80022b:	ff d7                	call   *%edi
  80022d:	83 c4 10             	add    $0x10,%esp
  800230:	eb 03                	jmp    800235 <printnum+0x78>
  800232:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800235:	83 eb 01             	sub    $0x1,%ebx
  800238:	85 db                	test   %ebx,%ebx
  80023a:	7f e8                	jg     800224 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	56                   	push   %esi
  800240:	83 ec 04             	sub    $0x4,%esp
  800243:	ff 75 e4             	pushl  -0x1c(%ebp)
  800246:	ff 75 e0             	pushl  -0x20(%ebp)
  800249:	ff 75 dc             	pushl  -0x24(%ebp)
  80024c:	ff 75 d8             	pushl  -0x28(%ebp)
  80024f:	e8 6c 10 00 00       	call   8012c0 <__umoddi3>
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	0f be 80 53 14 80 00 	movsbl 0x801453(%eax),%eax
  80025e:	50                   	push   %eax
  80025f:	ff d7                	call   *%edi
}
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026f:	83 fa 01             	cmp    $0x1,%edx
  800272:	7e 0e                	jle    800282 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 08             	lea    0x8(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	8b 52 04             	mov    0x4(%edx),%edx
  800280:	eb 22                	jmp    8002a4 <getuint+0x38>
	else if (lflag)
  800282:	85 d2                	test   %edx,%edx
  800284:	74 10                	je     800296 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800286:	8b 10                	mov    (%eax),%edx
  800288:	8d 4a 04             	lea    0x4(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 02                	mov    (%edx),%eax
  80028f:	ba 00 00 00 00       	mov    $0x0,%edx
  800294:	eb 0e                	jmp    8002a4 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800296:	8b 10                	mov    (%eax),%edx
  800298:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029b:	89 08                	mov    %ecx,(%eax)
  80029d:	8b 02                	mov    (%edx),%eax
  80029f:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ac:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b5:	73 0a                	jae    8002c1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ba:	89 08                	mov    %ecx,(%eax)
  8002bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bf:	88 02                	mov    %al,(%edx)
}
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002cc:	50                   	push   %eax
  8002cd:	ff 75 10             	pushl  0x10(%ebp)
  8002d0:	ff 75 0c             	pushl  0xc(%ebp)
  8002d3:	ff 75 08             	pushl  0x8(%ebp)
  8002d6:	e8 05 00 00 00       	call   8002e0 <vprintfmt>
	va_end(ap);
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 2c             	sub    $0x2c,%esp
  8002e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002ef:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f2:	eb 12                	jmp    800306 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	0f 84 89 03 00 00    	je     800685 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002fc:	83 ec 08             	sub    $0x8,%esp
  8002ff:	53                   	push   %ebx
  800300:	50                   	push   %eax
  800301:	ff d6                	call   *%esi
  800303:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800306:	83 c7 01             	add    $0x1,%edi
  800309:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80030d:	83 f8 25             	cmp    $0x25,%eax
  800310:	75 e2                	jne    8002f4 <vprintfmt+0x14>
  800312:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800316:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800324:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80032b:	ba 00 00 00 00       	mov    $0x0,%edx
  800330:	eb 07                	jmp    800339 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800332:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800335:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8d 47 01             	lea    0x1(%edi),%eax
  80033c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80033f:	0f b6 07             	movzbl (%edi),%eax
  800342:	0f b6 c8             	movzbl %al,%ecx
  800345:	83 e8 23             	sub    $0x23,%eax
  800348:	3c 55                	cmp    $0x55,%al
  80034a:	0f 87 1a 03 00 00    	ja     80066a <vprintfmt+0x38a>
  800350:	0f b6 c0             	movzbl %al,%eax
  800353:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80035d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800361:	eb d6                	jmp    800339 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800366:	b8 00 00 00 00       	mov    $0x0,%eax
  80036b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80036e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800371:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800375:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800378:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80037b:	83 fa 09             	cmp    $0x9,%edx
  80037e:	77 39                	ja     8003b9 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800380:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800383:	eb e9                	jmp    80036e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 48 04             	lea    0x4(%eax),%ecx
  80038b:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80038e:	8b 00                	mov    (%eax),%eax
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800393:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800396:	eb 27                	jmp    8003bf <vprintfmt+0xdf>
  800398:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039b:	85 c0                	test   %eax,%eax
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	0f 49 c8             	cmovns %eax,%ecx
  8003a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	eb 8c                	jmp    800339 <vprintfmt+0x59>
  8003ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003b0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003b7:	eb 80                	jmp    800339 <vprintfmt+0x59>
  8003b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003bc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c3:	0f 89 70 ff ff ff    	jns    800339 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003d6:	e9 5e ff ff ff       	jmp    800339 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003db:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003e1:	e9 53 ff ff ff       	jmp    800339 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e9:	8d 50 04             	lea    0x4(%eax),%edx
  8003ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ef:	83 ec 08             	sub    $0x8,%esp
  8003f2:	53                   	push   %ebx
  8003f3:	ff 30                	pushl  (%eax)
  8003f5:	ff d6                	call   *%esi
			break;
  8003f7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003fd:	e9 04 ff ff ff       	jmp    800306 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 50 04             	lea    0x4(%eax),%edx
  800408:	89 55 14             	mov    %edx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	99                   	cltd   
  80040e:	31 d0                	xor    %edx,%eax
  800410:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800412:	83 f8 08             	cmp    $0x8,%eax
  800415:	7f 0b                	jg     800422 <vprintfmt+0x142>
  800417:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  80041e:	85 d2                	test   %edx,%edx
  800420:	75 18                	jne    80043a <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800422:	50                   	push   %eax
  800423:	68 6b 14 80 00       	push   $0x80146b
  800428:	53                   	push   %ebx
  800429:	56                   	push   %esi
  80042a:	e8 94 fe ff ff       	call   8002c3 <printfmt>
  80042f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800435:	e9 cc fe ff ff       	jmp    800306 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80043a:	52                   	push   %edx
  80043b:	68 74 14 80 00       	push   $0x801474
  800440:	53                   	push   %ebx
  800441:	56                   	push   %esi
  800442:	e8 7c fe ff ff       	call   8002c3 <printfmt>
  800447:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044d:	e9 b4 fe ff ff       	jmp    800306 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045d:	85 ff                	test   %edi,%edi
  80045f:	b8 64 14 80 00       	mov    $0x801464,%eax
  800464:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800467:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046b:	0f 8e 94 00 00 00    	jle    800505 <vprintfmt+0x225>
  800471:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800475:	0f 84 98 00 00 00    	je     800513 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 d0             	pushl  -0x30(%ebp)
  800481:	57                   	push   %edi
  800482:	e8 86 02 00 00       	call   80070d <strnlen>
  800487:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048a:	29 c1                	sub    %eax,%ecx
  80048c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80048f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800492:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800496:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800499:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80049c:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	eb 0f                	jmp    8004af <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	53                   	push   %ebx
  8004a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a9:	83 ef 01             	sub    $0x1,%edi
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	7f ed                	jg     8004a0 <vprintfmt+0x1c0>
  8004b3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b9:	85 c9                	test   %ecx,%ecx
  8004bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c0:	0f 49 c1             	cmovns %ecx,%eax
  8004c3:	29 c1                	sub    %eax,%ecx
  8004c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ce:	89 cb                	mov    %ecx,%ebx
  8004d0:	eb 4d                	jmp    80051f <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d6:	74 1b                	je     8004f3 <vprintfmt+0x213>
  8004d8:	0f be c0             	movsbl %al,%eax
  8004db:	83 e8 20             	sub    $0x20,%eax
  8004de:	83 f8 5e             	cmp    $0x5e,%eax
  8004e1:	76 10                	jbe    8004f3 <vprintfmt+0x213>
					putch('?', putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	ff 75 0c             	pushl  0xc(%ebp)
  8004e9:	6a 3f                	push   $0x3f
  8004eb:	ff 55 08             	call   *0x8(%ebp)
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	eb 0d                	jmp    800500 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	ff 75 0c             	pushl  0xc(%ebp)
  8004f9:	52                   	push   %edx
  8004fa:	ff 55 08             	call   *0x8(%ebp)
  8004fd:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800500:	83 eb 01             	sub    $0x1,%ebx
  800503:	eb 1a                	jmp    80051f <vprintfmt+0x23f>
  800505:	89 75 08             	mov    %esi,0x8(%ebp)
  800508:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800511:	eb 0c                	jmp    80051f <vprintfmt+0x23f>
  800513:	89 75 08             	mov    %esi,0x8(%ebp)
  800516:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800519:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051f:	83 c7 01             	add    $0x1,%edi
  800522:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800526:	0f be d0             	movsbl %al,%edx
  800529:	85 d2                	test   %edx,%edx
  80052b:	74 23                	je     800550 <vprintfmt+0x270>
  80052d:	85 f6                	test   %esi,%esi
  80052f:	78 a1                	js     8004d2 <vprintfmt+0x1f2>
  800531:	83 ee 01             	sub    $0x1,%esi
  800534:	79 9c                	jns    8004d2 <vprintfmt+0x1f2>
  800536:	89 df                	mov    %ebx,%edi
  800538:	8b 75 08             	mov    0x8(%ebp),%esi
  80053b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053e:	eb 18                	jmp    800558 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	53                   	push   %ebx
  800544:	6a 20                	push   $0x20
  800546:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800548:	83 ef 01             	sub    $0x1,%edi
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	eb 08                	jmp    800558 <vprintfmt+0x278>
  800550:	89 df                	mov    %ebx,%edi
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800558:	85 ff                	test   %edi,%edi
  80055a:	7f e4                	jg     800540 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055f:	e9 a2 fd ff ff       	jmp    800306 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800564:	83 fa 01             	cmp    $0x1,%edx
  800567:	7e 16                	jle    80057f <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8d 50 08             	lea    0x8(%eax),%edx
  80056f:	89 55 14             	mov    %edx,0x14(%ebp)
  800572:	8b 50 04             	mov    0x4(%eax),%edx
  800575:	8b 00                	mov    (%eax),%eax
  800577:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057d:	eb 32                	jmp    8005b1 <vprintfmt+0x2d1>
	else if (lflag)
  80057f:	85 d2                	test   %edx,%edx
  800581:	74 18                	je     80059b <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 50 04             	lea    0x4(%eax),%edx
  800589:	89 55 14             	mov    %edx,0x14(%ebp)
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 c1                	mov    %eax,%ecx
  800593:	c1 f9 1f             	sar    $0x1f,%ecx
  800596:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800599:	eb 16                	jmp    8005b1 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8d 50 04             	lea    0x4(%eax),%edx
  8005a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	89 c1                	mov    %eax,%ecx
  8005ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005b1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005b7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005bc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c0:	79 74                	jns    800636 <vprintfmt+0x356>
				putch('-', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 2d                	push   $0x2d
  8005c8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005d0:	f7 d8                	neg    %eax
  8005d2:	83 d2 00             	adc    $0x0,%edx
  8005d5:	f7 da                	neg    %edx
  8005d7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005da:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005df:	eb 55                	jmp    800636 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005e1:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e4:	e8 83 fc ff ff       	call   80026c <getuint>
			base = 10;
  8005e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005ee:	eb 46                	jmp    800636 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005f0:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f3:	e8 74 fc ff ff       	call   80026c <getuint>
			base = 8;
  8005f8:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005fd:	eb 37                	jmp    800636 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 30                	push   $0x30
  800605:	ff d6                	call   *%esi
			putch('x', putdat);
  800607:	83 c4 08             	add    $0x8,%esp
  80060a:	53                   	push   %ebx
  80060b:	6a 78                	push   $0x78
  80060d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8d 50 04             	lea    0x4(%eax),%edx
  800615:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800622:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800627:	eb 0d                	jmp    800636 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800629:	8d 45 14             	lea    0x14(%ebp),%eax
  80062c:	e8 3b fc ff ff       	call   80026c <getuint>
			base = 16;
  800631:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800636:	83 ec 0c             	sub    $0xc,%esp
  800639:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80063d:	57                   	push   %edi
  80063e:	ff 75 e0             	pushl  -0x20(%ebp)
  800641:	51                   	push   %ecx
  800642:	52                   	push   %edx
  800643:	50                   	push   %eax
  800644:	89 da                	mov    %ebx,%edx
  800646:	89 f0                	mov    %esi,%eax
  800648:	e8 70 fb ff ff       	call   8001bd <printnum>
			break;
  80064d:	83 c4 20             	add    $0x20,%esp
  800650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800653:	e9 ae fc ff ff       	jmp    800306 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	51                   	push   %ecx
  80065d:	ff d6                	call   *%esi
			break;
  80065f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800665:	e9 9c fc ff ff       	jmp    800306 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	53                   	push   %ebx
  80066e:	6a 25                	push   $0x25
  800670:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	eb 03                	jmp    80067a <vprintfmt+0x39a>
  800677:	83 ef 01             	sub    $0x1,%edi
  80067a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80067e:	75 f7                	jne    800677 <vprintfmt+0x397>
  800680:	e9 81 fc ff ff       	jmp    800306 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800688:	5b                   	pop    %ebx
  800689:	5e                   	pop    %esi
  80068a:	5f                   	pop    %edi
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	83 ec 18             	sub    $0x18,%esp
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800699:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80069c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006a0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	74 26                	je     8006d4 <vsnprintf+0x47>
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	7e 22                	jle    8006d4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006b2:	ff 75 14             	pushl  0x14(%ebp)
  8006b5:	ff 75 10             	pushl  0x10(%ebp)
  8006b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	68 a6 02 80 00       	push   $0x8002a6
  8006c1:	e8 1a fc ff ff       	call   8002e0 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	eb 05                	jmp    8006d9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e4:	50                   	push   %eax
  8006e5:	ff 75 10             	pushl  0x10(%ebp)
  8006e8:	ff 75 0c             	pushl  0xc(%ebp)
  8006eb:	ff 75 08             	pushl  0x8(%ebp)
  8006ee:	e8 9a ff ff ff       	call   80068d <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800700:	eb 03                	jmp    800705 <strlen+0x10>
		n++;
  800702:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800705:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800709:	75 f7                	jne    800702 <strlen+0xd>
		n++;
	return n;
}
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800713:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800716:	ba 00 00 00 00       	mov    $0x0,%edx
  80071b:	eb 03                	jmp    800720 <strnlen+0x13>
		n++;
  80071d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800720:	39 c2                	cmp    %eax,%edx
  800722:	74 08                	je     80072c <strnlen+0x1f>
  800724:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800728:	75 f3                	jne    80071d <strnlen+0x10>
  80072a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80072c:	5d                   	pop    %ebp
  80072d:	c3                   	ret    

0080072e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80072e:	55                   	push   %ebp
  80072f:	89 e5                	mov    %esp,%ebp
  800731:	53                   	push   %ebx
  800732:	8b 45 08             	mov    0x8(%ebp),%eax
  800735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800738:	89 c2                	mov    %eax,%edx
  80073a:	83 c2 01             	add    $0x1,%edx
  80073d:	83 c1 01             	add    $0x1,%ecx
  800740:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800744:	88 5a ff             	mov    %bl,-0x1(%edx)
  800747:	84 db                	test   %bl,%bl
  800749:	75 ef                	jne    80073a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80074b:	5b                   	pop    %ebx
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	53                   	push   %ebx
  800752:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800755:	53                   	push   %ebx
  800756:	e8 9a ff ff ff       	call   8006f5 <strlen>
  80075b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80075e:	ff 75 0c             	pushl  0xc(%ebp)
  800761:	01 d8                	add    %ebx,%eax
  800763:	50                   	push   %eax
  800764:	e8 c5 ff ff ff       	call   80072e <strcpy>
	return dst;
}
  800769:	89 d8                	mov    %ebx,%eax
  80076b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80076e:	c9                   	leave  
  80076f:	c3                   	ret    

00800770 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	8b 75 08             	mov    0x8(%ebp),%esi
  800778:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80077b:	89 f3                	mov    %esi,%ebx
  80077d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800780:	89 f2                	mov    %esi,%edx
  800782:	eb 0f                	jmp    800793 <strncpy+0x23>
		*dst++ = *src;
  800784:	83 c2 01             	add    $0x1,%edx
  800787:	0f b6 01             	movzbl (%ecx),%eax
  80078a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80078d:	80 39 01             	cmpb   $0x1,(%ecx)
  800790:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800793:	39 da                	cmp    %ebx,%edx
  800795:	75 ed                	jne    800784 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800797:	89 f0                	mov    %esi,%eax
  800799:	5b                   	pop    %ebx
  80079a:	5e                   	pop    %esi
  80079b:	5d                   	pop    %ebp
  80079c:	c3                   	ret    

0080079d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	56                   	push   %esi
  8007a1:	53                   	push   %ebx
  8007a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a8:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ab:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ad:	85 d2                	test   %edx,%edx
  8007af:	74 21                	je     8007d2 <strlcpy+0x35>
  8007b1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007b5:	89 f2                	mov    %esi,%edx
  8007b7:	eb 09                	jmp    8007c2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b9:	83 c2 01             	add    $0x1,%edx
  8007bc:	83 c1 01             	add    $0x1,%ecx
  8007bf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007c2:	39 c2                	cmp    %eax,%edx
  8007c4:	74 09                	je     8007cf <strlcpy+0x32>
  8007c6:	0f b6 19             	movzbl (%ecx),%ebx
  8007c9:	84 db                	test   %bl,%bl
  8007cb:	75 ec                	jne    8007b9 <strlcpy+0x1c>
  8007cd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007cf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007d2:	29 f0                	sub    %esi,%eax
}
  8007d4:	5b                   	pop    %ebx
  8007d5:	5e                   	pop    %esi
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007e1:	eb 06                	jmp    8007e9 <strcmp+0x11>
		p++, q++;
  8007e3:	83 c1 01             	add    $0x1,%ecx
  8007e6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e9:	0f b6 01             	movzbl (%ecx),%eax
  8007ec:	84 c0                	test   %al,%al
  8007ee:	74 04                	je     8007f4 <strcmp+0x1c>
  8007f0:	3a 02                	cmp    (%edx),%al
  8007f2:	74 ef                	je     8007e3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007f4:	0f b6 c0             	movzbl %al,%eax
  8007f7:	0f b6 12             	movzbl (%edx),%edx
  8007fa:	29 d0                	sub    %edx,%eax
}
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	8b 45 08             	mov    0x8(%ebp),%eax
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
  800808:	89 c3                	mov    %eax,%ebx
  80080a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80080d:	eb 06                	jmp    800815 <strncmp+0x17>
		n--, p++, q++;
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800815:	39 d8                	cmp    %ebx,%eax
  800817:	74 15                	je     80082e <strncmp+0x30>
  800819:	0f b6 08             	movzbl (%eax),%ecx
  80081c:	84 c9                	test   %cl,%cl
  80081e:	74 04                	je     800824 <strncmp+0x26>
  800820:	3a 0a                	cmp    (%edx),%cl
  800822:	74 eb                	je     80080f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800824:	0f b6 00             	movzbl (%eax),%eax
  800827:	0f b6 12             	movzbl (%edx),%edx
  80082a:	29 d0                	sub    %edx,%eax
  80082c:	eb 05                	jmp    800833 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800833:	5b                   	pop    %ebx
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800840:	eb 07                	jmp    800849 <strchr+0x13>
		if (*s == c)
  800842:	38 ca                	cmp    %cl,%dl
  800844:	74 0f                	je     800855 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800846:	83 c0 01             	add    $0x1,%eax
  800849:	0f b6 10             	movzbl (%eax),%edx
  80084c:	84 d2                	test   %dl,%dl
  80084e:	75 f2                	jne    800842 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800861:	eb 03                	jmp    800866 <strfind+0xf>
  800863:	83 c0 01             	add    $0x1,%eax
  800866:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800869:	38 ca                	cmp    %cl,%dl
  80086b:	74 04                	je     800871 <strfind+0x1a>
  80086d:	84 d2                	test   %dl,%dl
  80086f:	75 f2                	jne    800863 <strfind+0xc>
			break;
	return (char *) s;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	57                   	push   %edi
  800877:	56                   	push   %esi
  800878:	53                   	push   %ebx
  800879:	8b 7d 08             	mov    0x8(%ebp),%edi
  80087c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80087f:	85 c9                	test   %ecx,%ecx
  800881:	74 36                	je     8008b9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800883:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800889:	75 28                	jne    8008b3 <memset+0x40>
  80088b:	f6 c1 03             	test   $0x3,%cl
  80088e:	75 23                	jne    8008b3 <memset+0x40>
		c &= 0xFF;
  800890:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800894:	89 d3                	mov    %edx,%ebx
  800896:	c1 e3 08             	shl    $0x8,%ebx
  800899:	89 d6                	mov    %edx,%esi
  80089b:	c1 e6 18             	shl    $0x18,%esi
  80089e:	89 d0                	mov    %edx,%eax
  8008a0:	c1 e0 10             	shl    $0x10,%eax
  8008a3:	09 f0                	or     %esi,%eax
  8008a5:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008a7:	89 d8                	mov    %ebx,%eax
  8008a9:	09 d0                	or     %edx,%eax
  8008ab:	c1 e9 02             	shr    $0x2,%ecx
  8008ae:	fc                   	cld    
  8008af:	f3 ab                	rep stos %eax,%es:(%edi)
  8008b1:	eb 06                	jmp    8008b9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b6:	fc                   	cld    
  8008b7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b9:	89 f8                	mov    %edi,%eax
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	57                   	push   %edi
  8008c4:	56                   	push   %esi
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008cb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008ce:	39 c6                	cmp    %eax,%esi
  8008d0:	73 35                	jae    800907 <memmove+0x47>
  8008d2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008d5:	39 d0                	cmp    %edx,%eax
  8008d7:	73 2e                	jae    800907 <memmove+0x47>
		s += n;
		d += n;
  8008d9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008dc:	89 d6                	mov    %edx,%esi
  8008de:	09 fe                	or     %edi,%esi
  8008e0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008e6:	75 13                	jne    8008fb <memmove+0x3b>
  8008e8:	f6 c1 03             	test   $0x3,%cl
  8008eb:	75 0e                	jne    8008fb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008ed:	83 ef 04             	sub    $0x4,%edi
  8008f0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008f3:	c1 e9 02             	shr    $0x2,%ecx
  8008f6:	fd                   	std    
  8008f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f9:	eb 09                	jmp    800904 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008fb:	83 ef 01             	sub    $0x1,%edi
  8008fe:	8d 72 ff             	lea    -0x1(%edx),%esi
  800901:	fd                   	std    
  800902:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800904:	fc                   	cld    
  800905:	eb 1d                	jmp    800924 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800907:	89 f2                	mov    %esi,%edx
  800909:	09 c2                	or     %eax,%edx
  80090b:	f6 c2 03             	test   $0x3,%dl
  80090e:	75 0f                	jne    80091f <memmove+0x5f>
  800910:	f6 c1 03             	test   $0x3,%cl
  800913:	75 0a                	jne    80091f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800915:	c1 e9 02             	shr    $0x2,%ecx
  800918:	89 c7                	mov    %eax,%edi
  80091a:	fc                   	cld    
  80091b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80091d:	eb 05                	jmp    800924 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80091f:	89 c7                	mov    %eax,%edi
  800921:	fc                   	cld    
  800922:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800924:	5e                   	pop    %esi
  800925:	5f                   	pop    %edi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80092b:	ff 75 10             	pushl  0x10(%ebp)
  80092e:	ff 75 0c             	pushl  0xc(%ebp)
  800931:	ff 75 08             	pushl  0x8(%ebp)
  800934:	e8 87 ff ff ff       	call   8008c0 <memmove>
}
  800939:	c9                   	leave  
  80093a:	c3                   	ret    

0080093b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
  800946:	89 c6                	mov    %eax,%esi
  800948:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094b:	eb 1a                	jmp    800967 <memcmp+0x2c>
		if (*s1 != *s2)
  80094d:	0f b6 08             	movzbl (%eax),%ecx
  800950:	0f b6 1a             	movzbl (%edx),%ebx
  800953:	38 d9                	cmp    %bl,%cl
  800955:	74 0a                	je     800961 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800957:	0f b6 c1             	movzbl %cl,%eax
  80095a:	0f b6 db             	movzbl %bl,%ebx
  80095d:	29 d8                	sub    %ebx,%eax
  80095f:	eb 0f                	jmp    800970 <memcmp+0x35>
		s1++, s2++;
  800961:	83 c0 01             	add    $0x1,%eax
  800964:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800967:	39 f0                	cmp    %esi,%eax
  800969:	75 e2                	jne    80094d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80096b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	53                   	push   %ebx
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80097b:	89 c1                	mov    %eax,%ecx
  80097d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800980:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800984:	eb 0a                	jmp    800990 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800986:	0f b6 10             	movzbl (%eax),%edx
  800989:	39 da                	cmp    %ebx,%edx
  80098b:	74 07                	je     800994 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80098d:	83 c0 01             	add    $0x1,%eax
  800990:	39 c8                	cmp    %ecx,%eax
  800992:	72 f2                	jb     800986 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800994:	5b                   	pop    %ebx
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	57                   	push   %edi
  80099b:	56                   	push   %esi
  80099c:	53                   	push   %ebx
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a3:	eb 03                	jmp    8009a8 <strtol+0x11>
		s++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009a8:	0f b6 01             	movzbl (%ecx),%eax
  8009ab:	3c 20                	cmp    $0x20,%al
  8009ad:	74 f6                	je     8009a5 <strtol+0xe>
  8009af:	3c 09                	cmp    $0x9,%al
  8009b1:	74 f2                	je     8009a5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009b3:	3c 2b                	cmp    $0x2b,%al
  8009b5:	75 0a                	jne    8009c1 <strtol+0x2a>
		s++;
  8009b7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009ba:	bf 00 00 00 00       	mov    $0x0,%edi
  8009bf:	eb 11                	jmp    8009d2 <strtol+0x3b>
  8009c1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009c6:	3c 2d                	cmp    $0x2d,%al
  8009c8:	75 08                	jne    8009d2 <strtol+0x3b>
		s++, neg = 1;
  8009ca:	83 c1 01             	add    $0x1,%ecx
  8009cd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009d2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009d8:	75 15                	jne    8009ef <strtol+0x58>
  8009da:	80 39 30             	cmpb   $0x30,(%ecx)
  8009dd:	75 10                	jne    8009ef <strtol+0x58>
  8009df:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009e3:	75 7c                	jne    800a61 <strtol+0xca>
		s += 2, base = 16;
  8009e5:	83 c1 02             	add    $0x2,%ecx
  8009e8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009ed:	eb 16                	jmp    800a05 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009ef:	85 db                	test   %ebx,%ebx
  8009f1:	75 12                	jne    800a05 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009f8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fb:	75 08                	jne    800a05 <strtol+0x6e>
		s++, base = 8;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a0d:	0f b6 11             	movzbl (%ecx),%edx
  800a10:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	80 fb 09             	cmp    $0x9,%bl
  800a18:	77 08                	ja     800a22 <strtol+0x8b>
			dig = *s - '0';
  800a1a:	0f be d2             	movsbl %dl,%edx
  800a1d:	83 ea 30             	sub    $0x30,%edx
  800a20:	eb 22                	jmp    800a44 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a22:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a25:	89 f3                	mov    %esi,%ebx
  800a27:	80 fb 19             	cmp    $0x19,%bl
  800a2a:	77 08                	ja     800a34 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a2c:	0f be d2             	movsbl %dl,%edx
  800a2f:	83 ea 57             	sub    $0x57,%edx
  800a32:	eb 10                	jmp    800a44 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a34:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a37:	89 f3                	mov    %esi,%ebx
  800a39:	80 fb 19             	cmp    $0x19,%bl
  800a3c:	77 16                	ja     800a54 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a3e:	0f be d2             	movsbl %dl,%edx
  800a41:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a44:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a47:	7d 0b                	jge    800a54 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a50:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a52:	eb b9                	jmp    800a0d <strtol+0x76>

	if (endptr)
  800a54:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a58:	74 0d                	je     800a67 <strtol+0xd0>
		*endptr = (char *) s;
  800a5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5d:	89 0e                	mov    %ecx,(%esi)
  800a5f:	eb 06                	jmp    800a67 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a61:	85 db                	test   %ebx,%ebx
  800a63:	74 98                	je     8009fd <strtol+0x66>
  800a65:	eb 9e                	jmp    800a05 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	f7 da                	neg    %edx
  800a6b:	85 ff                	test   %edi,%edi
  800a6d:	0f 45 c2             	cmovne %edx,%eax
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5f                   	pop    %edi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	57                   	push   %edi
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
  800a86:	89 c3                	mov    %eax,%ebx
  800a88:	89 c7                	mov    %eax,%edi
  800a8a:	89 c6                	mov    %eax,%esi
  800a8c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a8e:	5b                   	pop    %ebx
  800a8f:	5e                   	pop    %esi
  800a90:	5f                   	pop    %edi
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <sys_cgetc>:

int
sys_cgetc(void)
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
  800a9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800aa3:	89 d1                	mov    %edx,%ecx
  800aa5:	89 d3                	mov    %edx,%ebx
  800aa7:	89 d7                	mov    %edx,%edi
  800aa9:	89 d6                	mov    %edx,%esi
  800aab:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ac0:	b8 03 00 00 00       	mov    $0x3,%eax
  800ac5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac8:	89 cb                	mov    %ecx,%ebx
  800aca:	89 cf                	mov    %ecx,%edi
  800acc:	89 ce                	mov    %ecx,%esi
  800ace:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	7e 17                	jle    800aeb <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ad4:	83 ec 0c             	sub    $0xc,%esp
  800ad7:	50                   	push   %eax
  800ad8:	6a 03                	push   $0x3
  800ada:	68 a4 16 80 00       	push   $0x8016a4
  800adf:	6a 23                	push   $0x23
  800ae1:	68 c1 16 80 00       	push   $0x8016c1
  800ae6:	e8 c4 05 00 00       	call   8010af <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
  800afe:	b8 02 00 00 00       	mov    $0x2,%eax
  800b03:	89 d1                	mov    %edx,%ecx
  800b05:	89 d3                	mov    %edx,%ebx
  800b07:	89 d7                	mov    %edx,%edi
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_yield>:

void
sys_yield(void)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b18:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b22:	89 d1                	mov    %edx,%ecx
  800b24:	89 d3                	mov    %edx,%ebx
  800b26:	89 d7                	mov    %edx,%edi
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	be 00 00 00 00       	mov    $0x0,%esi
  800b3f:	b8 04 00 00 00       	mov    $0x4,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b4d:	89 f7                	mov    %esi,%edi
  800b4f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	7e 17                	jle    800b6c <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	50                   	push   %eax
  800b59:	6a 04                	push   $0x4
  800b5b:	68 a4 16 80 00       	push   $0x8016a4
  800b60:	6a 23                	push   $0x23
  800b62:	68 c1 16 80 00       	push   $0x8016c1
  800b67:	e8 43 05 00 00       	call   8010af <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7d:	b8 05 00 00 00       	mov    $0x5,%eax
  800b82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b85:	8b 55 08             	mov    0x8(%ebp),%edx
  800b88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b8e:	8b 75 18             	mov    0x18(%ebp),%esi
  800b91:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b93:	85 c0                	test   %eax,%eax
  800b95:	7e 17                	jle    800bae <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	6a 05                	push   $0x5
  800b9d:	68 a4 16 80 00       	push   $0x8016a4
  800ba2:	6a 23                	push   $0x23
  800ba4:	68 c1 16 80 00       	push   $0x8016c1
  800ba9:	e8 01 05 00 00       	call   8010af <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5f                   	pop    %edi
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bc4:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	89 df                	mov    %ebx,%edi
  800bd1:	89 de                	mov    %ebx,%esi
  800bd3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd5:	85 c0                	test   %eax,%eax
  800bd7:	7e 17                	jle    800bf0 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd9:	83 ec 0c             	sub    $0xc,%esp
  800bdc:	50                   	push   %eax
  800bdd:	6a 06                	push   $0x6
  800bdf:	68 a4 16 80 00       	push   $0x8016a4
  800be4:	6a 23                	push   $0x23
  800be6:	68 c1 16 80 00       	push   $0x8016c1
  800beb:	e8 bf 04 00 00       	call   8010af <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c06:	b8 08 00 00 00       	mov    $0x8,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	89 df                	mov    %ebx,%edi
  800c13:	89 de                	mov    %ebx,%esi
  800c15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c17:	85 c0                	test   %eax,%eax
  800c19:	7e 17                	jle    800c32 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1b:	83 ec 0c             	sub    $0xc,%esp
  800c1e:	50                   	push   %eax
  800c1f:	6a 08                	push   $0x8
  800c21:	68 a4 16 80 00       	push   $0x8016a4
  800c26:	6a 23                	push   $0x23
  800c28:	68 c1 16 80 00       	push   $0x8016c1
  800c2d:	e8 7d 04 00 00       	call   8010af <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c48:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c50:	8b 55 08             	mov    0x8(%ebp),%edx
  800c53:	89 df                	mov    %ebx,%edi
  800c55:	89 de                	mov    %ebx,%esi
  800c57:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c59:	85 c0                	test   %eax,%eax
  800c5b:	7e 17                	jle    800c74 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5d:	83 ec 0c             	sub    $0xc,%esp
  800c60:	50                   	push   %eax
  800c61:	6a 09                	push   $0x9
  800c63:	68 a4 16 80 00       	push   $0x8016a4
  800c68:	6a 23                	push   $0x23
  800c6a:	68 c1 16 80 00       	push   $0x8016c1
  800c6f:	e8 3b 04 00 00       	call   8010af <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5f                   	pop    %edi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	57                   	push   %edi
  800c80:	56                   	push   %esi
  800c81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	be 00 00 00 00       	mov    $0x0,%esi
  800c87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c95:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c98:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cad:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb5:	89 cb                	mov    %ecx,%ebx
  800cb7:	89 cf                	mov    %ecx,%edi
  800cb9:	89 ce                	mov    %ecx,%esi
  800cbb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 17                	jle    800cd8 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 0c                	push   $0xc
  800cc7:	68 a4 16 80 00       	push   $0x8016a4
  800ccc:	6a 23                	push   $0x23
  800cce:	68 c1 16 80 00       	push   $0x8016c1
  800cd3:	e8 d7 03 00 00       	call   8010af <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ce8:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0) {
  800cea:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800cee:	74 11                	je     800d01 <pgfault+0x21>
  800cf0:	89 d8                	mov    %ebx,%eax
  800cf2:	c1 e8 0c             	shr    $0xc,%eax
  800cf5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800cfc:	f6 c4 08             	test   $0x8,%ah
  800cff:	75 14                	jne    800d15 <pgfault+0x35>
		panic("pgfault: invalid user trap frame");
  800d01:	83 ec 04             	sub    $0x4,%esp
  800d04:	68 d0 16 80 00       	push   $0x8016d0
  800d09:	6a 1d                	push   $0x1d
  800d0b:	68 3c 17 80 00       	push   $0x80173c
  800d10:	e8 9a 03 00 00       	call   8010af <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// panic("pgfault not implemented");
        envid_t envid = sys_getenvid();
  800d15:	e8 d9 fd ff ff       	call   800af3 <sys_getenvid>
  800d1a:	89 c6                	mov    %eax,%esi
        if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800d1c:	83 ec 04             	sub    $0x4,%esp
  800d1f:	6a 07                	push   $0x7
  800d21:	68 00 f0 7f 00       	push   $0x7ff000
  800d26:	50                   	push   %eax
  800d27:	e8 05 fe ff ff       	call   800b31 <sys_page_alloc>
  800d2c:	83 c4 10             	add    $0x10,%esp
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	79 12                	jns    800d45 <pgfault+0x65>
                panic("pgfault: page allocation failed %e", r);
  800d33:	50                   	push   %eax
  800d34:	68 f4 16 80 00       	push   $0x8016f4
  800d39:	6a 29                	push   $0x29
  800d3b:	68 3c 17 80 00       	push   $0x80173c
  800d40:	e8 6a 03 00 00       	call   8010af <_panic>

        addr = ROUNDDOWN(addr, PGSIZE);
  800d45:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        memmove(PFTEMP, addr, PGSIZE);
  800d4b:	83 ec 04             	sub    $0x4,%esp
  800d4e:	68 00 10 00 00       	push   $0x1000
  800d53:	53                   	push   %ebx
  800d54:	68 00 f0 7f 00       	push   $0x7ff000
  800d59:	e8 62 fb ff ff       	call   8008c0 <memmove>
        if ((r = sys_page_unmap(envid, addr)) < 0)
  800d5e:	83 c4 08             	add    $0x8,%esp
  800d61:	53                   	push   %ebx
  800d62:	56                   	push   %esi
  800d63:	e8 4e fe ff ff       	call   800bb6 <sys_page_unmap>
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	79 12                	jns    800d81 <pgfault+0xa1>
                panic("pgfault: page unmap failed %e", r);
  800d6f:	50                   	push   %eax
  800d70:	68 47 17 80 00       	push   $0x801747
  800d75:	6a 2e                	push   $0x2e
  800d77:	68 3c 17 80 00       	push   $0x80173c
  800d7c:	e8 2e 03 00 00       	call   8010af <_panic>
        if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	6a 07                	push   $0x7
  800d86:	53                   	push   %ebx
  800d87:	56                   	push   %esi
  800d88:	68 00 f0 7f 00       	push   $0x7ff000
  800d8d:	56                   	push   %esi
  800d8e:	e8 e1 fd ff ff       	call   800b74 <sys_page_map>
  800d93:	83 c4 20             	add    $0x20,%esp
  800d96:	85 c0                	test   %eax,%eax
  800d98:	79 12                	jns    800dac <pgfault+0xcc>
                panic("pgfault: page map failed %e", r);
  800d9a:	50                   	push   %eax
  800d9b:	68 65 17 80 00       	push   $0x801765
  800da0:	6a 30                	push   $0x30
  800da2:	68 3c 17 80 00       	push   $0x80173c
  800da7:	e8 03 03 00 00       	call   8010af <_panic>
        if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800dac:	83 ec 08             	sub    $0x8,%esp
  800daf:	68 00 f0 7f 00       	push   $0x7ff000
  800db4:	56                   	push   %esi
  800db5:	e8 fc fd ff ff       	call   800bb6 <sys_page_unmap>
  800dba:	83 c4 10             	add    $0x10,%esp
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	79 12                	jns    800dd3 <pgfault+0xf3>
                panic("pgfault: page unmap failed %e", r);
  800dc1:	50                   	push   %eax
  800dc2:	68 47 17 80 00       	push   $0x801747
  800dc7:	6a 32                	push   $0x32
  800dc9:	68 3c 17 80 00       	push   $0x80173c
  800dce:	e8 dc 02 00 00       	call   8010af <_panic>
}
  800dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dd6:	5b                   	pop    %ebx
  800dd7:	5e                   	pop    %esi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// panic("fork not implemented");

	set_pgfault_handler(pgfault);
  800de3:	68 e0 0c 80 00       	push   $0x800ce0
  800de8:	e8 08 03 00 00       	call   8010f5 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ded:	b8 07 00 00 00       	mov    $0x7,%eax
  800df2:	cd 30                	int    $0x30
  800df4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800df7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t e_id = sys_exofork();
	if (e_id < 0) panic("fork: %e", e_id);
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	79 12                	jns    800e13 <fork+0x39>
  800e01:	50                   	push   %eax
  800e02:	68 81 17 80 00       	push   $0x801781
  800e07:	6a 73                	push   $0x73
  800e09:	68 3c 17 80 00       	push   $0x80173c
  800e0e:	e8 9c 02 00 00       	call   8010af <_panic>
  800e13:	bf 00 00 80 00       	mov    $0x800000,%edi
	if (e_id == 0) {
  800e18:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e1c:	75 21                	jne    800e3f <fork+0x65>
		// child
		thisenv = &envs[ENVX(sys_getenvid())];
  800e1e:	e8 d0 fc ff ff       	call   800af3 <sys_getenvid>
  800e23:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e28:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e2b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e30:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e35:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3a:	e9 46 01 00 00       	jmp    800f85 <fork+0x1ab>

	// parent
	// extern unsigned char end[];
	// for ((uint8_t *) addr = UTEXT; addr < end; addr += PGSIZE)
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800e3f:	89 f8                	mov    %edi,%eax
  800e41:	c1 e8 16             	shr    $0x16,%eax
  800e44:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e4b:	a8 01                	test   $0x1,%al
  800e4d:	0f 84 9a 00 00 00    	je     800eed <fork+0x113>
  800e53:	89 fb                	mov    %edi,%ebx
  800e55:	c1 eb 0c             	shr    $0xc,%ebx
  800e58:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e5f:	a8 01                	test   $0x1,%al
  800e61:	0f 84 86 00 00 00    	je     800eed <fork+0x113>
	int r;

	// LAB 4: Your code here.
	// panic("duppage not implemented");

	envid_t this_env_id = sys_getenvid();
  800e67:	e8 87 fc ff ff       	call   800af3 <sys_getenvid>
  800e6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800e6f:	89 de                	mov    %ebx,%esi
  800e71:	c1 e6 0c             	shl    $0xc,%esi

	int perm = uvpt[pn] & 0xFFF;
  800e74:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e7b:	89 c3                	mov    %eax,%ebx
  800e7d:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
	if ( (perm & PTE_W) || (perm & PTE_COW) ) {
  800e83:	a9 02 08 00 00       	test   $0x802,%eax
  800e88:	74 0a                	je     800e94 <fork+0xba>
		// marked as COW and read-only
		perm |= PTE_COW;
		perm &= ~PTE_W;
  800e8a:	25 fd 0f 00 00       	and    $0xffd,%eax
  800e8f:	80 cc 08             	or     $0x8,%ah
  800e92:	89 c3                	mov    %eax,%ebx
	}
	// IMPORTANT: adjust permission to the syscall
	perm &= PTE_SYSCALL;
  800e94:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
	// cprintf("fromenvid = %x, toenvid = %x, dup page %d, addr = %08p, perm = %03x\n",this_env_id, envid, pn, va, perm);
	if((r = sys_page_map(this_env_id, va, envid, va, perm)) < 0) 
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	53                   	push   %ebx
  800e9e:	56                   	push   %esi
  800e9f:	ff 75 e0             	pushl  -0x20(%ebp)
  800ea2:	56                   	push   %esi
  800ea3:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ea6:	e8 c9 fc ff ff       	call   800b74 <sys_page_map>
  800eab:	83 c4 20             	add    $0x20,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	79 12                	jns    800ec4 <fork+0xea>
		panic("duppage: %e",r);
  800eb2:	50                   	push   %eax
  800eb3:	68 8a 17 80 00       	push   $0x80178a
  800eb8:	6a 55                	push   $0x55
  800eba:	68 3c 17 80 00       	push   $0x80173c
  800ebf:	e8 eb 01 00 00       	call   8010af <_panic>
	if((r = sys_page_map(this_env_id, va, this_env_id, va, perm)) < 0) 
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	53                   	push   %ebx
  800ec8:	56                   	push   %esi
  800ec9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ecc:	50                   	push   %eax
  800ecd:	56                   	push   %esi
  800ece:	50                   	push   %eax
  800ecf:	e8 a0 fc ff ff       	call   800b74 <sys_page_map>
  800ed4:	83 c4 20             	add    $0x20,%esp
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	79 12                	jns    800eed <fork+0x113>
		panic("duppage: %e",r);
  800edb:	50                   	push   %eax
  800edc:	68 8a 17 80 00       	push   $0x80178a
  800ee1:	6a 57                	push   $0x57
  800ee3:	68 3c 17 80 00       	push   $0x80173c
  800ee8:	e8 c2 01 00 00       	call   8010af <_panic>
	}

	// parent
	// extern unsigned char end[];
	// for ((uint8_t *) addr = UTEXT; addr < end; addr += PGSIZE)
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800eed:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800ef3:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  800ef9:	0f 85 40 ff ff ff    	jne    800e3f <fork+0x65>
			// dup page to child
			duppage(e_id, PGNUM(addr));
		}
	}
	// alloc page for exception stack
	int r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800eff:	83 ec 04             	sub    $0x4,%esp
  800f02:	6a 07                	push   $0x7
  800f04:	68 00 f0 bf ee       	push   $0xeebff000
  800f09:	ff 75 dc             	pushl  -0x24(%ebp)
  800f0c:	e8 20 fc ff ff       	call   800b31 <sys_page_alloc>
	if (r < 0) panic("fork: %e",r);
  800f11:	83 c4 10             	add    $0x10,%esp
  800f14:	85 c0                	test   %eax,%eax
  800f16:	79 15                	jns    800f2d <fork+0x153>
  800f18:	50                   	push   %eax
  800f19:	68 81 17 80 00       	push   $0x801781
  800f1e:	68 85 00 00 00       	push   $0x85
  800f23:	68 3c 17 80 00       	push   $0x80173c
  800f28:	e8 82 01 00 00       	call   8010af <_panic>

	// DO NOT FORGET
	extern void _pgfault_upcall();
	r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	68 69 11 80 00       	push   $0x801169
  800f35:	ff 75 dc             	pushl  -0x24(%ebp)
  800f38:	e8 fd fc ff ff       	call   800c3a <sys_env_set_pgfault_upcall>
	if (r < 0) panic("fork: set upcall for child fail, %e", r);
  800f3d:	83 c4 10             	add    $0x10,%esp
  800f40:	85 c0                	test   %eax,%eax
  800f42:	79 15                	jns    800f59 <fork+0x17f>
  800f44:	50                   	push   %eax
  800f45:	68 18 17 80 00       	push   $0x801718
  800f4a:	68 8a 00 00 00       	push   $0x8a
  800f4f:	68 3c 17 80 00       	push   $0x80173c
  800f54:	e8 56 01 00 00       	call   8010af <_panic>

	// mark the child environment runnable
	if ((r = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  800f59:	83 ec 08             	sub    $0x8,%esp
  800f5c:	6a 02                	push   $0x2
  800f5e:	ff 75 dc             	pushl  -0x24(%ebp)
  800f61:	e8 92 fc ff ff       	call   800bf8 <sys_env_set_status>
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	79 15                	jns    800f82 <fork+0x1a8>
		panic("sys_env_set_status: %e", r);
  800f6d:	50                   	push   %eax
  800f6e:	68 96 17 80 00       	push   $0x801796
  800f73:	68 8e 00 00 00       	push   $0x8e
  800f78:	68 3c 17 80 00       	push   $0x80173c
  800f7d:	e8 2d 01 00 00       	call   8010af <_panic>

	return e_id;
  800f82:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
  800f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f88:	5b                   	pop    %ebx
  800f89:	5e                   	pop    %esi
  800f8a:	5f                   	pop    %edi
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <sfork>:

// Challenge!
int
sfork(void)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f93:	68 ad 17 80 00       	push   $0x8017ad
  800f98:	68 97 00 00 00       	push   $0x97
  800f9d:	68 3c 17 80 00       	push   $0x80173c
  800fa2:	e8 08 01 00 00       	call   8010af <_panic>

00800fa7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
  800fac:	8b 75 08             	mov    0x8(%ebp),%esi
  800faf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;
	if (pg != NULL) {
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	74 0e                	je     800fc7 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  800fb9:	83 ec 0c             	sub    $0xc,%esp
  800fbc:	50                   	push   %eax
  800fbd:	e8 dd fc ff ff       	call   800c9f <sys_ipc_recv>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	eb 10                	jmp    800fd7 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *) UTOP);
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	68 00 00 c0 ee       	push   $0xeec00000
  800fcf:	e8 cb fc ff ff       	call   800c9f <sys_ipc_recv>
  800fd4:	83 c4 10             	add    $0x10,%esp
	}
	if (r < 0) {
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	79 16                	jns    800ff1 <ipc_recv+0x4a>
		// failed
		if (from_env_store != NULL) *from_env_store = 0;
  800fdb:	85 f6                	test   %esi,%esi
  800fdd:	74 06                	je     800fe5 <ipc_recv+0x3e>
  800fdf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  800fe5:	85 db                	test   %ebx,%ebx
  800fe7:	74 2c                	je     801015 <ipc_recv+0x6e>
  800fe9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800fef:	eb 24                	jmp    801015 <ipc_recv+0x6e>
		return r;
	} else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800ff1:	85 f6                	test   %esi,%esi
  800ff3:	74 0a                	je     800fff <ipc_recv+0x58>
  800ff5:	a1 04 20 80 00       	mov    0x802004,%eax
  800ffa:	8b 40 74             	mov    0x74(%eax),%eax
  800ffd:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800fff:	85 db                	test   %ebx,%ebx
  801001:	74 0a                	je     80100d <ipc_recv+0x66>
  801003:	a1 04 20 80 00       	mov    0x802004,%eax
  801008:	8b 40 78             	mov    0x78(%eax),%eax
  80100b:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  80100d:	a1 04 20 80 00       	mov    0x802004,%eax
  801012:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801015:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	57                   	push   %edi
  801020:	56                   	push   %esi
  801021:	53                   	push   %ebx
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	8b 7d 08             	mov    0x8(%ebp),%edi
  801028:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	int r;
	if (pg == NULL) pg = (void *)UTOP;
  80102b:	85 f6                	test   %esi,%esi
  80102d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801032:	0f 44 f0             	cmove  %eax,%esi
	do {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801035:	ff 75 14             	pushl  0x14(%ebp)
  801038:	56                   	push   %esi
  801039:	ff 75 0c             	pushl  0xc(%ebp)
  80103c:	57                   	push   %edi
  80103d:	e8 3a fc ff ff       	call   800c7c <sys_ipc_try_send>
  801042:	89 c3                	mov    %eax,%ebx
		if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  801044:	c1 e8 1f             	shr    $0x1f,%eax
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	84 c0                	test   %al,%al
  80104c:	74 17                	je     801065 <ipc_send+0x49>
  80104e:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801051:	74 12                	je     801065 <ipc_send+0x49>
  801053:	53                   	push   %ebx
  801054:	68 c3 17 80 00       	push   $0x8017c3
  801059:	6a 40                	push   $0x40
  80105b:	68 d7 17 80 00       	push   $0x8017d7
  801060:	e8 4a 00 00 00       	call   8010af <_panic>
		sys_yield();
  801065:	e8 a8 fa ff ff       	call   800b12 <sys_yield>
	} while (r != 0);
  80106a:	85 db                	test   %ebx,%ebx
  80106c:	75 c7                	jne    801035 <ipc_send+0x19>
}
  80106e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801071:	5b                   	pop    %ebx
  801072:	5e                   	pop    %esi
  801073:	5f                   	pop    %edi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80107c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801081:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801084:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80108a:	8b 52 50             	mov    0x50(%edx),%edx
  80108d:	39 ca                	cmp    %ecx,%edx
  80108f:	75 0d                	jne    80109e <ipc_find_env+0x28>
			return envs[i].env_id;
  801091:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801094:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801099:	8b 40 48             	mov    0x48(%eax),%eax
  80109c:	eb 0f                	jmp    8010ad <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80109e:	83 c0 01             	add    $0x1,%eax
  8010a1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010a6:	75 d9                	jne    801081 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010b4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010b7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010bd:	e8 31 fa ff ff       	call   800af3 <sys_getenvid>
  8010c2:	83 ec 0c             	sub    $0xc,%esp
  8010c5:	ff 75 0c             	pushl  0xc(%ebp)
  8010c8:	ff 75 08             	pushl  0x8(%ebp)
  8010cb:	56                   	push   %esi
  8010cc:	50                   	push   %eax
  8010cd:	68 e4 17 80 00       	push   $0x8017e4
  8010d2:	e8 d2 f0 ff ff       	call   8001a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010d7:	83 c4 18             	add    $0x18,%esp
  8010da:	53                   	push   %ebx
  8010db:	ff 75 10             	pushl  0x10(%ebp)
  8010de:	e8 75 f0 ff ff       	call   800158 <vcprintf>
	cprintf("\n");
  8010e3:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8010ea:	e8 ba f0 ff ff       	call   8001a9 <cprintf>
  8010ef:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010f2:	cc                   	int3   
  8010f3:	eb fd                	jmp    8010f2 <_panic+0x43>

008010f5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	53                   	push   %ebx
  8010f9:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010fc:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801103:	75 57                	jne    80115c <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  801105:	e8 e9 f9 ff ff       	call   800af3 <sys_getenvid>
  80110a:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	6a 07                	push   $0x7
  801111:	68 00 f0 bf ee       	push   $0xeebff000
  801116:	50                   	push   %eax
  801117:	e8 15 fa ff ff       	call   800b31 <sys_page_alloc>
		if (r < 0) {
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	85 c0                	test   %eax,%eax
  801121:	79 12                	jns    801135 <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  801123:	50                   	push   %eax
  801124:	68 08 18 80 00       	push   $0x801808
  801129:	6a 24                	push   $0x24
  80112b:	68 1c 18 80 00       	push   $0x80181c
  801130:	e8 7a ff ff ff       	call   8010af <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  801135:	83 ec 08             	sub    $0x8,%esp
  801138:	68 69 11 80 00       	push   $0x801169
  80113d:	53                   	push   %ebx
  80113e:	e8 f7 fa ff ff       	call   800c3a <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	79 12                	jns    80115c <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  80114a:	50                   	push   %eax
  80114b:	68 08 18 80 00       	push   $0x801808
  801150:	6a 29                	push   $0x29
  801152:	68 1c 18 80 00       	push   $0x80181c
  801157:	e8 53 ff ff ff       	call   8010af <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801164:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801167:	c9                   	leave  
  801168:	c3                   	ret    

00801169 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801169:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80116a:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80116f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801171:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  801174:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  801178:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  80117b:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  80117f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  801183:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801186:	83 c4 08             	add    $0x8,%esp
	popal
  801189:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80118a:	83 c4 04             	add    $0x4,%esp
	popfl
  80118d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80118e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80118f:	c3                   	ret    

00801190 <__udivdi3>:
  801190:	55                   	push   %ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 1c             	sub    $0x1c,%esp
  801197:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80119b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80119f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8011a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011a7:	85 f6                	test   %esi,%esi
  8011a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ad:	89 ca                	mov    %ecx,%edx
  8011af:	89 f8                	mov    %edi,%eax
  8011b1:	75 3d                	jne    8011f0 <__udivdi3+0x60>
  8011b3:	39 cf                	cmp    %ecx,%edi
  8011b5:	0f 87 c5 00 00 00    	ja     801280 <__udivdi3+0xf0>
  8011bb:	85 ff                	test   %edi,%edi
  8011bd:	89 fd                	mov    %edi,%ebp
  8011bf:	75 0b                	jne    8011cc <__udivdi3+0x3c>
  8011c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c6:	31 d2                	xor    %edx,%edx
  8011c8:	f7 f7                	div    %edi
  8011ca:	89 c5                	mov    %eax,%ebp
  8011cc:	89 c8                	mov    %ecx,%eax
  8011ce:	31 d2                	xor    %edx,%edx
  8011d0:	f7 f5                	div    %ebp
  8011d2:	89 c1                	mov    %eax,%ecx
  8011d4:	89 d8                	mov    %ebx,%eax
  8011d6:	89 cf                	mov    %ecx,%edi
  8011d8:	f7 f5                	div    %ebp
  8011da:	89 c3                	mov    %eax,%ebx
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	89 fa                	mov    %edi,%edx
  8011e0:	83 c4 1c             	add    $0x1c,%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
  8011e8:	90                   	nop
  8011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	39 ce                	cmp    %ecx,%esi
  8011f2:	77 74                	ja     801268 <__udivdi3+0xd8>
  8011f4:	0f bd fe             	bsr    %esi,%edi
  8011f7:	83 f7 1f             	xor    $0x1f,%edi
  8011fa:	0f 84 98 00 00 00    	je     801298 <__udivdi3+0x108>
  801200:	bb 20 00 00 00       	mov    $0x20,%ebx
  801205:	89 f9                	mov    %edi,%ecx
  801207:	89 c5                	mov    %eax,%ebp
  801209:	29 fb                	sub    %edi,%ebx
  80120b:	d3 e6                	shl    %cl,%esi
  80120d:	89 d9                	mov    %ebx,%ecx
  80120f:	d3 ed                	shr    %cl,%ebp
  801211:	89 f9                	mov    %edi,%ecx
  801213:	d3 e0                	shl    %cl,%eax
  801215:	09 ee                	or     %ebp,%esi
  801217:	89 d9                	mov    %ebx,%ecx
  801219:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80121d:	89 d5                	mov    %edx,%ebp
  80121f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801223:	d3 ed                	shr    %cl,%ebp
  801225:	89 f9                	mov    %edi,%ecx
  801227:	d3 e2                	shl    %cl,%edx
  801229:	89 d9                	mov    %ebx,%ecx
  80122b:	d3 e8                	shr    %cl,%eax
  80122d:	09 c2                	or     %eax,%edx
  80122f:	89 d0                	mov    %edx,%eax
  801231:	89 ea                	mov    %ebp,%edx
  801233:	f7 f6                	div    %esi
  801235:	89 d5                	mov    %edx,%ebp
  801237:	89 c3                	mov    %eax,%ebx
  801239:	f7 64 24 0c          	mull   0xc(%esp)
  80123d:	39 d5                	cmp    %edx,%ebp
  80123f:	72 10                	jb     801251 <__udivdi3+0xc1>
  801241:	8b 74 24 08          	mov    0x8(%esp),%esi
  801245:	89 f9                	mov    %edi,%ecx
  801247:	d3 e6                	shl    %cl,%esi
  801249:	39 c6                	cmp    %eax,%esi
  80124b:	73 07                	jae    801254 <__udivdi3+0xc4>
  80124d:	39 d5                	cmp    %edx,%ebp
  80124f:	75 03                	jne    801254 <__udivdi3+0xc4>
  801251:	83 eb 01             	sub    $0x1,%ebx
  801254:	31 ff                	xor    %edi,%edi
  801256:	89 d8                	mov    %ebx,%eax
  801258:	89 fa                	mov    %edi,%edx
  80125a:	83 c4 1c             	add    $0x1c,%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5e                   	pop    %esi
  80125f:	5f                   	pop    %edi
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    
  801262:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801268:	31 ff                	xor    %edi,%edi
  80126a:	31 db                	xor    %ebx,%ebx
  80126c:	89 d8                	mov    %ebx,%eax
  80126e:	89 fa                	mov    %edi,%edx
  801270:	83 c4 1c             	add    $0x1c,%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
  801278:	90                   	nop
  801279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 d8                	mov    %ebx,%eax
  801282:	f7 f7                	div    %edi
  801284:	31 ff                	xor    %edi,%edi
  801286:	89 c3                	mov    %eax,%ebx
  801288:	89 d8                	mov    %ebx,%eax
  80128a:	89 fa                	mov    %edi,%edx
  80128c:	83 c4 1c             	add    $0x1c,%esp
  80128f:	5b                   	pop    %ebx
  801290:	5e                   	pop    %esi
  801291:	5f                   	pop    %edi
  801292:	5d                   	pop    %ebp
  801293:	c3                   	ret    
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	39 ce                	cmp    %ecx,%esi
  80129a:	72 0c                	jb     8012a8 <__udivdi3+0x118>
  80129c:	31 db                	xor    %ebx,%ebx
  80129e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8012a2:	0f 87 34 ff ff ff    	ja     8011dc <__udivdi3+0x4c>
  8012a8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012ad:	e9 2a ff ff ff       	jmp    8011dc <__udivdi3+0x4c>
  8012b2:	66 90                	xchg   %ax,%ax
  8012b4:	66 90                	xchg   %ax,%ax
  8012b6:	66 90                	xchg   %ax,%ax
  8012b8:	66 90                	xchg   %ax,%ax
  8012ba:	66 90                	xchg   %ax,%ax
  8012bc:	66 90                	xchg   %ax,%ax
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__umoddi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	53                   	push   %ebx
  8012c4:	83 ec 1c             	sub    $0x1c,%esp
  8012c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8012cf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012d7:	85 d2                	test   %edx,%edx
  8012d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8012dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e1:	89 f3                	mov    %esi,%ebx
  8012e3:	89 3c 24             	mov    %edi,(%esp)
  8012e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012ea:	75 1c                	jne    801308 <__umoddi3+0x48>
  8012ec:	39 f7                	cmp    %esi,%edi
  8012ee:	76 50                	jbe    801340 <__umoddi3+0x80>
  8012f0:	89 c8                	mov    %ecx,%eax
  8012f2:	89 f2                	mov    %esi,%edx
  8012f4:	f7 f7                	div    %edi
  8012f6:	89 d0                	mov    %edx,%eax
  8012f8:	31 d2                	xor    %edx,%edx
  8012fa:	83 c4 1c             	add    $0x1c,%esp
  8012fd:	5b                   	pop    %ebx
  8012fe:	5e                   	pop    %esi
  8012ff:	5f                   	pop    %edi
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    
  801302:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801308:	39 f2                	cmp    %esi,%edx
  80130a:	89 d0                	mov    %edx,%eax
  80130c:	77 52                	ja     801360 <__umoddi3+0xa0>
  80130e:	0f bd ea             	bsr    %edx,%ebp
  801311:	83 f5 1f             	xor    $0x1f,%ebp
  801314:	75 5a                	jne    801370 <__umoddi3+0xb0>
  801316:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80131a:	0f 82 e0 00 00 00    	jb     801400 <__umoddi3+0x140>
  801320:	39 0c 24             	cmp    %ecx,(%esp)
  801323:	0f 86 d7 00 00 00    	jbe    801400 <__umoddi3+0x140>
  801329:	8b 44 24 08          	mov    0x8(%esp),%eax
  80132d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801331:	83 c4 1c             	add    $0x1c,%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	85 ff                	test   %edi,%edi
  801342:	89 fd                	mov    %edi,%ebp
  801344:	75 0b                	jne    801351 <__umoddi3+0x91>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f7                	div    %edi
  80134f:	89 c5                	mov    %eax,%ebp
  801351:	89 f0                	mov    %esi,%eax
  801353:	31 d2                	xor    %edx,%edx
  801355:	f7 f5                	div    %ebp
  801357:	89 c8                	mov    %ecx,%eax
  801359:	f7 f5                	div    %ebp
  80135b:	89 d0                	mov    %edx,%eax
  80135d:	eb 99                	jmp    8012f8 <__umoddi3+0x38>
  80135f:	90                   	nop
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 f2                	mov    %esi,%edx
  801364:	83 c4 1c             	add    $0x1c,%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	8b 34 24             	mov    (%esp),%esi
  801373:	bf 20 00 00 00       	mov    $0x20,%edi
  801378:	89 e9                	mov    %ebp,%ecx
  80137a:	29 ef                	sub    %ebp,%edi
  80137c:	d3 e0                	shl    %cl,%eax
  80137e:	89 f9                	mov    %edi,%ecx
  801380:	89 f2                	mov    %esi,%edx
  801382:	d3 ea                	shr    %cl,%edx
  801384:	89 e9                	mov    %ebp,%ecx
  801386:	09 c2                	or     %eax,%edx
  801388:	89 d8                	mov    %ebx,%eax
  80138a:	89 14 24             	mov    %edx,(%esp)
  80138d:	89 f2                	mov    %esi,%edx
  80138f:	d3 e2                	shl    %cl,%edx
  801391:	89 f9                	mov    %edi,%ecx
  801393:	89 54 24 04          	mov    %edx,0x4(%esp)
  801397:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80139b:	d3 e8                	shr    %cl,%eax
  80139d:	89 e9                	mov    %ebp,%ecx
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	d3 e3                	shl    %cl,%ebx
  8013a3:	89 f9                	mov    %edi,%ecx
  8013a5:	89 d0                	mov    %edx,%eax
  8013a7:	d3 e8                	shr    %cl,%eax
  8013a9:	89 e9                	mov    %ebp,%ecx
  8013ab:	09 d8                	or     %ebx,%eax
  8013ad:	89 d3                	mov    %edx,%ebx
  8013af:	89 f2                	mov    %esi,%edx
  8013b1:	f7 34 24             	divl   (%esp)
  8013b4:	89 d6                	mov    %edx,%esi
  8013b6:	d3 e3                	shl    %cl,%ebx
  8013b8:	f7 64 24 04          	mull   0x4(%esp)
  8013bc:	39 d6                	cmp    %edx,%esi
  8013be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c2:	89 d1                	mov    %edx,%ecx
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	72 08                	jb     8013d0 <__umoddi3+0x110>
  8013c8:	75 11                	jne    8013db <__umoddi3+0x11b>
  8013ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8013ce:	73 0b                	jae    8013db <__umoddi3+0x11b>
  8013d0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8013d4:	1b 14 24             	sbb    (%esp),%edx
  8013d7:	89 d1                	mov    %edx,%ecx
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	8b 54 24 08          	mov    0x8(%esp),%edx
  8013df:	29 da                	sub    %ebx,%edx
  8013e1:	19 ce                	sbb    %ecx,%esi
  8013e3:	89 f9                	mov    %edi,%ecx
  8013e5:	89 f0                	mov    %esi,%eax
  8013e7:	d3 e0                	shl    %cl,%eax
  8013e9:	89 e9                	mov    %ebp,%ecx
  8013eb:	d3 ea                	shr    %cl,%edx
  8013ed:	89 e9                	mov    %ebp,%ecx
  8013ef:	d3 ee                	shr    %cl,%esi
  8013f1:	09 d0                	or     %edx,%eax
  8013f3:	89 f2                	mov    %esi,%edx
  8013f5:	83 c4 1c             	add    $0x1c,%esp
  8013f8:	5b                   	pop    %ebx
  8013f9:	5e                   	pop    %esi
  8013fa:	5f                   	pop    %edi
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	29 f9                	sub    %edi,%ecx
  801402:	19 d6                	sbb    %edx,%esi
  801404:	89 74 24 04          	mov    %esi,0x4(%esp)
  801408:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80140c:	e9 18 ff ff ff       	jmp    801329 <__umoddi3+0x69>
