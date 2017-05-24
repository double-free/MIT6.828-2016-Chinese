
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 96 0a 00 00       	call   800ad6 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 65 0c 00 00       	call   800cc3 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 c0 10 80 00       	push   $0x8010c0
  80006a:	e8 1d 01 00 00       	call   80018c <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 d1 10 80 00       	push   $0x8010d1
  800083:	e8 04 01 00 00       	call   80018c <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 9c 0c 00 00       	call   800d38 <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 25 0a 00 00       	call   800ad6 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 a1 09 00 00       	call   800a95 <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	75 1a                	jne    800132 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	68 ff 00 00 00       	push   $0xff
  800120:	8d 43 08             	lea    0x8(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	e8 2f 09 00 00       	call   800a58 <sys_cputs>
		b->idx = 0;
  800129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800144:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014b:	00 00 00 
	b.cnt = 0;
  80014e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800155:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800164:	50                   	push   %eax
  800165:	68 f9 00 80 00       	push   $0x8000f9
  80016a:	e8 54 01 00 00       	call   8002c3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016f:	83 c4 08             	add    $0x8,%esp
  800172:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800178:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017e:	50                   	push   %eax
  80017f:	e8 d4 08 00 00       	call   800a58 <sys_cputs>

	return b.cnt;
}
  800184:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 9d ff ff ff       	call   80013b <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c7:	39 d3                	cmp    %edx,%ebx
  8001c9:	72 05                	jb     8001d0 <printnum+0x30>
  8001cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ce:	77 45                	ja     800215 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	ff 75 18             	pushl  0x18(%ebp)
  8001d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001dc:	53                   	push   %ebx
  8001dd:	ff 75 10             	pushl  0x10(%ebp)
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ef:	e8 2c 0c 00 00       	call   800e20 <__udivdi3>
  8001f4:	83 c4 18             	add    $0x18,%esp
  8001f7:	52                   	push   %edx
  8001f8:	50                   	push   %eax
  8001f9:	89 f2                	mov    %esi,%edx
  8001fb:	89 f8                	mov    %edi,%eax
  8001fd:	e8 9e ff ff ff       	call   8001a0 <printnum>
  800202:	83 c4 20             	add    $0x20,%esp
  800205:	eb 18                	jmp    80021f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800207:	83 ec 08             	sub    $0x8,%esp
  80020a:	56                   	push   %esi
  80020b:	ff 75 18             	pushl  0x18(%ebp)
  80020e:	ff d7                	call   *%edi
  800210:	83 c4 10             	add    $0x10,%esp
  800213:	eb 03                	jmp    800218 <printnum+0x78>
  800215:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f e8                	jg     800207 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 19 0d 00 00       	call   800f50 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 f2 10 80 00 	movsbl 0x8010f2(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800252:	83 fa 01             	cmp    $0x1,%edx
  800255:	7e 0e                	jle    800265 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800257:	8b 10                	mov    (%eax),%edx
  800259:	8d 4a 08             	lea    0x8(%edx),%ecx
  80025c:	89 08                	mov    %ecx,(%eax)
  80025e:	8b 02                	mov    (%edx),%eax
  800260:	8b 52 04             	mov    0x4(%edx),%edx
  800263:	eb 22                	jmp    800287 <getuint+0x38>
	else if (lflag)
  800265:	85 d2                	test   %edx,%edx
  800267:	74 10                	je     800279 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800269:	8b 10                	mov    (%eax),%edx
  80026b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80026e:	89 08                	mov    %ecx,(%eax)
  800270:	8b 02                	mov    (%edx),%eax
  800272:	ba 00 00 00 00       	mov    $0x0,%edx
  800277:	eb 0e                	jmp    800287 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800279:	8b 10                	mov    (%eax),%edx
  80027b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 02                	mov    (%edx),%eax
  800282:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800287:	5d                   	pop    %ebp
  800288:	c3                   	ret    

00800289 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 0a                	jae    8002a4 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	88 02                	mov    %al,(%edx)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002af:	50                   	push   %eax
  8002b0:	ff 75 10             	pushl  0x10(%ebp)
  8002b3:	ff 75 0c             	pushl  0xc(%ebp)
  8002b6:	ff 75 08             	pushl  0x8(%ebp)
  8002b9:	e8 05 00 00 00       	call   8002c3 <vprintfmt>
	va_end(ap);
}
  8002be:	83 c4 10             	add    $0x10,%esp
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	57                   	push   %edi
  8002c7:	56                   	push   %esi
  8002c8:	53                   	push   %ebx
  8002c9:	83 ec 2c             	sub    $0x2c,%esp
  8002cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d5:	eb 12                	jmp    8002e9 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002d7:	85 c0                	test   %eax,%eax
  8002d9:	0f 84 89 03 00 00    	je     800668 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	53                   	push   %ebx
  8002e3:	50                   	push   %eax
  8002e4:	ff d6                	call   *%esi
  8002e6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002e9:	83 c7 01             	add    $0x1,%edi
  8002ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f0:	83 f8 25             	cmp    $0x25,%eax
  8002f3:	75 e2                	jne    8002d7 <vprintfmt+0x14>
  8002f5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002f9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800300:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800307:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
  800313:	eb 07                	jmp    80031c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800318:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031c:	8d 47 01             	lea    0x1(%edi),%eax
  80031f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800322:	0f b6 07             	movzbl (%edi),%eax
  800325:	0f b6 c8             	movzbl %al,%ecx
  800328:	83 e8 23             	sub    $0x23,%eax
  80032b:	3c 55                	cmp    $0x55,%al
  80032d:	0f 87 1a 03 00 00    	ja     80064d <vprintfmt+0x38a>
  800333:	0f b6 c0             	movzbl %al,%eax
  800336:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800340:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800344:	eb d6                	jmp    80031c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	b8 00 00 00 00       	mov    $0x0,%eax
  80034e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800351:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800354:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800358:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80035b:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80035e:	83 fa 09             	cmp    $0x9,%edx
  800361:	77 39                	ja     80039c <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800363:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800366:	eb e9                	jmp    800351 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800368:	8b 45 14             	mov    0x14(%ebp),%eax
  80036b:	8d 48 04             	lea    0x4(%eax),%ecx
  80036e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800371:	8b 00                	mov    (%eax),%eax
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800379:	eb 27                	jmp    8003a2 <vprintfmt+0xdf>
  80037b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80037e:	85 c0                	test   %eax,%eax
  800380:	b9 00 00 00 00       	mov    $0x0,%ecx
  800385:	0f 49 c8             	cmovns %eax,%ecx
  800388:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80038e:	eb 8c                	jmp    80031c <vprintfmt+0x59>
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800393:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80039a:	eb 80                	jmp    80031c <vprintfmt+0x59>
  80039c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80039f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a6:	0f 89 70 ff ff ff    	jns    80031c <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b9:	e9 5e ff ff ff       	jmp    80031c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003be:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003c4:	e9 53 ff ff ff       	jmp    80031c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	8d 50 04             	lea    0x4(%eax),%edx
  8003cf:	89 55 14             	mov    %edx,0x14(%ebp)
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	53                   	push   %ebx
  8003d6:	ff 30                	pushl  (%eax)
  8003d8:	ff d6                	call   *%esi
			break;
  8003da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003e0:	e9 04 ff ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 50 04             	lea    0x4(%eax),%edx
  8003eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8003ee:	8b 00                	mov    (%eax),%eax
  8003f0:	99                   	cltd   
  8003f1:	31 d0                	xor    %edx,%eax
  8003f3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f5:	83 f8 08             	cmp    $0x8,%eax
  8003f8:	7f 0b                	jg     800405 <vprintfmt+0x142>
  8003fa:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800401:	85 d2                	test   %edx,%edx
  800403:	75 18                	jne    80041d <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800405:	50                   	push   %eax
  800406:	68 0a 11 80 00       	push   $0x80110a
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 94 fe ff ff       	call   8002a6 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800418:	e9 cc fe ff ff       	jmp    8002e9 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80041d:	52                   	push   %edx
  80041e:	68 13 11 80 00       	push   $0x801113
  800423:	53                   	push   %ebx
  800424:	56                   	push   %esi
  800425:	e8 7c fe ff ff       	call   8002a6 <printfmt>
  80042a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800430:	e9 b4 fe ff ff       	jmp    8002e9 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 50 04             	lea    0x4(%eax),%edx
  80043b:	89 55 14             	mov    %edx,0x14(%ebp)
  80043e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800440:	85 ff                	test   %edi,%edi
  800442:	b8 03 11 80 00       	mov    $0x801103,%eax
  800447:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80044a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044e:	0f 8e 94 00 00 00    	jle    8004e8 <vprintfmt+0x225>
  800454:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800458:	0f 84 98 00 00 00    	je     8004f6 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	ff 75 d0             	pushl  -0x30(%ebp)
  800464:	57                   	push   %edi
  800465:	e8 86 02 00 00       	call   8006f0 <strnlen>
  80046a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800472:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800475:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80047f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800481:	eb 0f                	jmp    800492 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	53                   	push   %ebx
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048c:	83 ef 01             	sub    $0x1,%edi
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	85 ff                	test   %edi,%edi
  800494:	7f ed                	jg     800483 <vprintfmt+0x1c0>
  800496:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800499:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80049c:	85 c9                	test   %ecx,%ecx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	0f 49 c1             	cmovns %ecx,%eax
  8004a6:	29 c1                	sub    %eax,%ecx
  8004a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b1:	89 cb                	mov    %ecx,%ebx
  8004b3:	eb 4d                	jmp    800502 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b9:	74 1b                	je     8004d6 <vprintfmt+0x213>
  8004bb:	0f be c0             	movsbl %al,%eax
  8004be:	83 e8 20             	sub    $0x20,%eax
  8004c1:	83 f8 5e             	cmp    $0x5e,%eax
  8004c4:	76 10                	jbe    8004d6 <vprintfmt+0x213>
					putch('?', putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	6a 3f                	push   $0x3f
  8004ce:	ff 55 08             	call   *0x8(%ebp)
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	eb 0d                	jmp    8004e3 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	52                   	push   %edx
  8004dd:	ff 55 08             	call   *0x8(%ebp)
  8004e0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e3:	83 eb 01             	sub    $0x1,%ebx
  8004e6:	eb 1a                	jmp    800502 <vprintfmt+0x23f>
  8004e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f4:	eb 0c                	jmp    800502 <vprintfmt+0x23f>
  8004f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ff:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 23                	je     800533 <vprintfmt+0x270>
  800510:	85 f6                	test   %esi,%esi
  800512:	78 a1                	js     8004b5 <vprintfmt+0x1f2>
  800514:	83 ee 01             	sub    $0x1,%esi
  800517:	79 9c                	jns    8004b5 <vprintfmt+0x1f2>
  800519:	89 df                	mov    %ebx,%edi
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800521:	eb 18                	jmp    80053b <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	6a 20                	push   $0x20
  800529:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	eb 08                	jmp    80053b <vprintfmt+0x278>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	85 ff                	test   %edi,%edi
  80053d:	7f e4                	jg     800523 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	e9 a2 fd ff ff       	jmp    8002e9 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 fa 01             	cmp    $0x1,%edx
  80054a:	7e 16                	jle    800562 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 08             	lea    0x8(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 50 04             	mov    0x4(%eax),%edx
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800560:	eb 32                	jmp    800594 <vprintfmt+0x2d1>
	else if (lflag)
  800562:	85 d2                	test   %edx,%edx
  800564:	74 18                	je     80057e <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 50 04             	lea    0x4(%eax),%edx
  80056c:	89 55 14             	mov    %edx,0x14(%ebp)
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	89 c1                	mov    %eax,%ecx
  800576:	c1 f9 1f             	sar    $0x1f,%ecx
  800579:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057c:	eb 16                	jmp    800594 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800594:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800597:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80059a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a3:	79 74                	jns    800619 <vprintfmt+0x356>
				putch('-', putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	53                   	push   %ebx
  8005a9:	6a 2d                	push   $0x2d
  8005ab:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005b3:	f7 d8                	neg    %eax
  8005b5:	83 d2 00             	adc    $0x0,%edx
  8005b8:	f7 da                	neg    %edx
  8005ba:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005bd:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005c2:	eb 55                	jmp    800619 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c4:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c7:	e8 83 fc ff ff       	call   80024f <getuint>
			base = 10;
  8005cc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005d1:	eb 46                	jmp    800619 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d6:	e8 74 fc ff ff       	call   80024f <getuint>
			base = 8;
  8005db:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005e0:	eb 37                	jmp    800619 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	53                   	push   %ebx
  8005e6:	6a 30                	push   $0x30
  8005e8:	ff d6                	call   *%esi
			putch('x', putdat);
  8005ea:	83 c4 08             	add    $0x8,%esp
  8005ed:	53                   	push   %ebx
  8005ee:	6a 78                	push   $0x78
  8005f0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 50 04             	lea    0x4(%eax),%edx
  8005f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800602:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800605:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80060a:	eb 0d                	jmp    800619 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80060c:	8d 45 14             	lea    0x14(%ebp),%eax
  80060f:	e8 3b fc ff ff       	call   80024f <getuint>
			base = 16;
  800614:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800619:	83 ec 0c             	sub    $0xc,%esp
  80061c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800620:	57                   	push   %edi
  800621:	ff 75 e0             	pushl  -0x20(%ebp)
  800624:	51                   	push   %ecx
  800625:	52                   	push   %edx
  800626:	50                   	push   %eax
  800627:	89 da                	mov    %ebx,%edx
  800629:	89 f0                	mov    %esi,%eax
  80062b:	e8 70 fb ff ff       	call   8001a0 <printnum>
			break;
  800630:	83 c4 20             	add    $0x20,%esp
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800636:	e9 ae fc ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	51                   	push   %ecx
  800640:	ff d6                	call   *%esi
			break;
  800642:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800648:	e9 9c fc ff ff       	jmp    8002e9 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 25                	push   $0x25
  800653:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	eb 03                	jmp    80065d <vprintfmt+0x39a>
  80065a:	83 ef 01             	sub    $0x1,%edi
  80065d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800661:	75 f7                	jne    80065a <vprintfmt+0x397>
  800663:	e9 81 fc ff ff       	jmp    8002e9 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	83 ec 18             	sub    $0x18,%esp
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80067c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80067f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800683:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800686:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 26                	je     8006b7 <vsnprintf+0x47>
  800691:	85 d2                	test   %edx,%edx
  800693:	7e 22                	jle    8006b7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800695:	ff 75 14             	pushl  0x14(%ebp)
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	68 89 02 80 00       	push   $0x800289
  8006a4:	e8 1a fc ff ff       	call   8002c3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	eb 05                	jmp    8006bc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006bc:	c9                   	leave  
  8006bd:	c3                   	ret    

008006be <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006be:	55                   	push   %ebp
  8006bf:	89 e5                	mov    %esp,%ebp
  8006c1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006c4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006c7:	50                   	push   %eax
  8006c8:	ff 75 10             	pushl  0x10(%ebp)
  8006cb:	ff 75 0c             	pushl  0xc(%ebp)
  8006ce:	ff 75 08             	pushl  0x8(%ebp)
  8006d1:	e8 9a ff ff ff       	call   800670 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006d6:	c9                   	leave  
  8006d7:	c3                   	ret    

008006d8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006d8:	55                   	push   %ebp
  8006d9:	89 e5                	mov    %esp,%ebp
  8006db:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	eb 03                	jmp    8006e8 <strlen+0x10>
		n++;
  8006e5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006ec:	75 f7                	jne    8006e5 <strlen+0xd>
		n++;
	return n;
}
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006f6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fe:	eb 03                	jmp    800703 <strnlen+0x13>
		n++;
  800700:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800703:	39 c2                	cmp    %eax,%edx
  800705:	74 08                	je     80070f <strnlen+0x1f>
  800707:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80070b:	75 f3                	jne    800700 <strnlen+0x10>
  80070d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80071b:	89 c2                	mov    %eax,%edx
  80071d:	83 c2 01             	add    $0x1,%edx
  800720:	83 c1 01             	add    $0x1,%ecx
  800723:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800727:	88 5a ff             	mov    %bl,-0x1(%edx)
  80072a:	84 db                	test   %bl,%bl
  80072c:	75 ef                	jne    80071d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80072e:	5b                   	pop    %ebx
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	53                   	push   %ebx
  800735:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800738:	53                   	push   %ebx
  800739:	e8 9a ff ff ff       	call   8006d8 <strlen>
  80073e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	01 d8                	add    %ebx,%eax
  800746:	50                   	push   %eax
  800747:	e8 c5 ff ff ff       	call   800711 <strcpy>
	return dst;
}
  80074c:	89 d8                	mov    %ebx,%eax
  80074e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800751:	c9                   	leave  
  800752:	c3                   	ret    

00800753 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	8b 75 08             	mov    0x8(%ebp),%esi
  80075b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80075e:	89 f3                	mov    %esi,%ebx
  800760:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800763:	89 f2                	mov    %esi,%edx
  800765:	eb 0f                	jmp    800776 <strncpy+0x23>
		*dst++ = *src;
  800767:	83 c2 01             	add    $0x1,%edx
  80076a:	0f b6 01             	movzbl (%ecx),%eax
  80076d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800770:	80 39 01             	cmpb   $0x1,(%ecx)
  800773:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800776:	39 da                	cmp    %ebx,%edx
  800778:	75 ed                	jne    800767 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80077a:	89 f0                	mov    %esi,%eax
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	56                   	push   %esi
  800784:	53                   	push   %ebx
  800785:	8b 75 08             	mov    0x8(%ebp),%esi
  800788:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80078b:	8b 55 10             	mov    0x10(%ebp),%edx
  80078e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800790:	85 d2                	test   %edx,%edx
  800792:	74 21                	je     8007b5 <strlcpy+0x35>
  800794:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800798:	89 f2                	mov    %esi,%edx
  80079a:	eb 09                	jmp    8007a5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80079c:	83 c2 01             	add    $0x1,%edx
  80079f:	83 c1 01             	add    $0x1,%ecx
  8007a2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007a5:	39 c2                	cmp    %eax,%edx
  8007a7:	74 09                	je     8007b2 <strlcpy+0x32>
  8007a9:	0f b6 19             	movzbl (%ecx),%ebx
  8007ac:	84 db                	test   %bl,%bl
  8007ae:	75 ec                	jne    80079c <strlcpy+0x1c>
  8007b0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b5:	29 f0                	sub    %esi,%eax
}
  8007b7:	5b                   	pop    %ebx
  8007b8:	5e                   	pop    %esi
  8007b9:	5d                   	pop    %ebp
  8007ba:	c3                   	ret    

008007bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c4:	eb 06                	jmp    8007cc <strcmp+0x11>
		p++, q++;
  8007c6:	83 c1 01             	add    $0x1,%ecx
  8007c9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007cc:	0f b6 01             	movzbl (%ecx),%eax
  8007cf:	84 c0                	test   %al,%al
  8007d1:	74 04                	je     8007d7 <strcmp+0x1c>
  8007d3:	3a 02                	cmp    (%edx),%al
  8007d5:	74 ef                	je     8007c6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d7:	0f b6 c0             	movzbl %al,%eax
  8007da:	0f b6 12             	movzbl (%edx),%edx
  8007dd:	29 d0                	sub    %edx,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	53                   	push   %ebx
  8007e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007eb:	89 c3                	mov    %eax,%ebx
  8007ed:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f0:	eb 06                	jmp    8007f8 <strncmp+0x17>
		n--, p++, q++;
  8007f2:	83 c0 01             	add    $0x1,%eax
  8007f5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007f8:	39 d8                	cmp    %ebx,%eax
  8007fa:	74 15                	je     800811 <strncmp+0x30>
  8007fc:	0f b6 08             	movzbl (%eax),%ecx
  8007ff:	84 c9                	test   %cl,%cl
  800801:	74 04                	je     800807 <strncmp+0x26>
  800803:	3a 0a                	cmp    (%edx),%cl
  800805:	74 eb                	je     8007f2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800807:	0f b6 00             	movzbl (%eax),%eax
  80080a:	0f b6 12             	movzbl (%edx),%edx
  80080d:	29 d0                	sub    %edx,%eax
  80080f:	eb 05                	jmp    800816 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800811:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 45 08             	mov    0x8(%ebp),%eax
  80081f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800823:	eb 07                	jmp    80082c <strchr+0x13>
		if (*s == c)
  800825:	38 ca                	cmp    %cl,%dl
  800827:	74 0f                	je     800838 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	0f b6 10             	movzbl (%eax),%edx
  80082f:	84 d2                	test   %dl,%dl
  800831:	75 f2                	jne    800825 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	8b 45 08             	mov    0x8(%ebp),%eax
  800840:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800844:	eb 03                	jmp    800849 <strfind+0xf>
  800846:	83 c0 01             	add    $0x1,%eax
  800849:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80084c:	38 ca                	cmp    %cl,%dl
  80084e:	74 04                	je     800854 <strfind+0x1a>
  800850:	84 d2                	test   %dl,%dl
  800852:	75 f2                	jne    800846 <strfind+0xc>
			break;
	return (char *) s;
}
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	57                   	push   %edi
  80085a:	56                   	push   %esi
  80085b:	53                   	push   %ebx
  80085c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800862:	85 c9                	test   %ecx,%ecx
  800864:	74 36                	je     80089c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800866:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80086c:	75 28                	jne    800896 <memset+0x40>
  80086e:	f6 c1 03             	test   $0x3,%cl
  800871:	75 23                	jne    800896 <memset+0x40>
		c &= 0xFF;
  800873:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800877:	89 d3                	mov    %edx,%ebx
  800879:	c1 e3 08             	shl    $0x8,%ebx
  80087c:	89 d6                	mov    %edx,%esi
  80087e:	c1 e6 18             	shl    $0x18,%esi
  800881:	89 d0                	mov    %edx,%eax
  800883:	c1 e0 10             	shl    $0x10,%eax
  800886:	09 f0                	or     %esi,%eax
  800888:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80088a:	89 d8                	mov    %ebx,%eax
  80088c:	09 d0                	or     %edx,%eax
  80088e:	c1 e9 02             	shr    $0x2,%ecx
  800891:	fc                   	cld    
  800892:	f3 ab                	rep stos %eax,%es:(%edi)
  800894:	eb 06                	jmp    80089c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	fc                   	cld    
  80089a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80089c:	89 f8                	mov    %edi,%eax
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5f                   	pop    %edi
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	57                   	push   %edi
  8008a7:	56                   	push   %esi
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b1:	39 c6                	cmp    %eax,%esi
  8008b3:	73 35                	jae    8008ea <memmove+0x47>
  8008b5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008b8:	39 d0                	cmp    %edx,%eax
  8008ba:	73 2e                	jae    8008ea <memmove+0x47>
		s += n;
		d += n;
  8008bc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008bf:	89 d6                	mov    %edx,%esi
  8008c1:	09 fe                	or     %edi,%esi
  8008c3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008c9:	75 13                	jne    8008de <memmove+0x3b>
  8008cb:	f6 c1 03             	test   $0x3,%cl
  8008ce:	75 0e                	jne    8008de <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d0:	83 ef 04             	sub    $0x4,%edi
  8008d3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008d6:	c1 e9 02             	shr    $0x2,%ecx
  8008d9:	fd                   	std    
  8008da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008dc:	eb 09                	jmp    8008e7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008de:	83 ef 01             	sub    $0x1,%edi
  8008e1:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008e4:	fd                   	std    
  8008e5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008e7:	fc                   	cld    
  8008e8:	eb 1d                	jmp    800907 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008ea:	89 f2                	mov    %esi,%edx
  8008ec:	09 c2                	or     %eax,%edx
  8008ee:	f6 c2 03             	test   $0x3,%dl
  8008f1:	75 0f                	jne    800902 <memmove+0x5f>
  8008f3:	f6 c1 03             	test   $0x3,%cl
  8008f6:	75 0a                	jne    800902 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008f8:	c1 e9 02             	shr    $0x2,%ecx
  8008fb:	89 c7                	mov    %eax,%edi
  8008fd:	fc                   	cld    
  8008fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800900:	eb 05                	jmp    800907 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800902:	89 c7                	mov    %eax,%edi
  800904:	fc                   	cld    
  800905:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800907:	5e                   	pop    %esi
  800908:	5f                   	pop    %edi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80090e:	ff 75 10             	pushl  0x10(%ebp)
  800911:	ff 75 0c             	pushl  0xc(%ebp)
  800914:	ff 75 08             	pushl  0x8(%ebp)
  800917:	e8 87 ff ff ff       	call   8008a3 <memmove>
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	8b 55 0c             	mov    0xc(%ebp),%edx
  800929:	89 c6                	mov    %eax,%esi
  80092b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80092e:	eb 1a                	jmp    80094a <memcmp+0x2c>
		if (*s1 != *s2)
  800930:	0f b6 08             	movzbl (%eax),%ecx
  800933:	0f b6 1a             	movzbl (%edx),%ebx
  800936:	38 d9                	cmp    %bl,%cl
  800938:	74 0a                	je     800944 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80093a:	0f b6 c1             	movzbl %cl,%eax
  80093d:	0f b6 db             	movzbl %bl,%ebx
  800940:	29 d8                	sub    %ebx,%eax
  800942:	eb 0f                	jmp    800953 <memcmp+0x35>
		s1++, s2++;
  800944:	83 c0 01             	add    $0x1,%eax
  800947:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80094a:	39 f0                	cmp    %esi,%eax
  80094c:	75 e2                	jne    800930 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	53                   	push   %ebx
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80095e:	89 c1                	mov    %eax,%ecx
  800960:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800963:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800967:	eb 0a                	jmp    800973 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	0f b6 10             	movzbl (%eax),%edx
  80096c:	39 da                	cmp    %ebx,%edx
  80096e:	74 07                	je     800977 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800970:	83 c0 01             	add    $0x1,%eax
  800973:	39 c8                	cmp    %ecx,%eax
  800975:	72 f2                	jb     800969 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800986:	eb 03                	jmp    80098b <strtol+0x11>
		s++;
  800988:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098b:	0f b6 01             	movzbl (%ecx),%eax
  80098e:	3c 20                	cmp    $0x20,%al
  800990:	74 f6                	je     800988 <strtol+0xe>
  800992:	3c 09                	cmp    $0x9,%al
  800994:	74 f2                	je     800988 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800996:	3c 2b                	cmp    $0x2b,%al
  800998:	75 0a                	jne    8009a4 <strtol+0x2a>
		s++;
  80099a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80099d:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a2:	eb 11                	jmp    8009b5 <strtol+0x3b>
  8009a4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009a9:	3c 2d                	cmp    $0x2d,%al
  8009ab:	75 08                	jne    8009b5 <strtol+0x3b>
		s++, neg = 1;
  8009ad:	83 c1 01             	add    $0x1,%ecx
  8009b0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009b5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009bb:	75 15                	jne    8009d2 <strtol+0x58>
  8009bd:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c0:	75 10                	jne    8009d2 <strtol+0x58>
  8009c2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009c6:	75 7c                	jne    800a44 <strtol+0xca>
		s += 2, base = 16;
  8009c8:	83 c1 02             	add    $0x2,%ecx
  8009cb:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d0:	eb 16                	jmp    8009e8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d2:	85 db                	test   %ebx,%ebx
  8009d4:	75 12                	jne    8009e8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009d6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009db:	80 39 30             	cmpb   $0x30,(%ecx)
  8009de:	75 08                	jne    8009e8 <strtol+0x6e>
		s++, base = 8;
  8009e0:	83 c1 01             	add    $0x1,%ecx
  8009e3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ed:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f0:	0f b6 11             	movzbl (%ecx),%edx
  8009f3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009f6:	89 f3                	mov    %esi,%ebx
  8009f8:	80 fb 09             	cmp    $0x9,%bl
  8009fb:	77 08                	ja     800a05 <strtol+0x8b>
			dig = *s - '0';
  8009fd:	0f be d2             	movsbl %dl,%edx
  800a00:	83 ea 30             	sub    $0x30,%edx
  800a03:	eb 22                	jmp    800a27 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a05:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a08:	89 f3                	mov    %esi,%ebx
  800a0a:	80 fb 19             	cmp    $0x19,%bl
  800a0d:	77 08                	ja     800a17 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a0f:	0f be d2             	movsbl %dl,%edx
  800a12:	83 ea 57             	sub    $0x57,%edx
  800a15:	eb 10                	jmp    800a27 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a17:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a1a:	89 f3                	mov    %esi,%ebx
  800a1c:	80 fb 19             	cmp    $0x19,%bl
  800a1f:	77 16                	ja     800a37 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a21:	0f be d2             	movsbl %dl,%edx
  800a24:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a27:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a2a:	7d 0b                	jge    800a37 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a2c:	83 c1 01             	add    $0x1,%ecx
  800a2f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a33:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a35:	eb b9                	jmp    8009f0 <strtol+0x76>

	if (endptr)
  800a37:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a3b:	74 0d                	je     800a4a <strtol+0xd0>
		*endptr = (char *) s;
  800a3d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a40:	89 0e                	mov    %ecx,(%esi)
  800a42:	eb 06                	jmp    800a4a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a44:	85 db                	test   %ebx,%ebx
  800a46:	74 98                	je     8009e0 <strtol+0x66>
  800a48:	eb 9e                	jmp    8009e8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a4a:	89 c2                	mov    %eax,%edx
  800a4c:	f7 da                	neg    %edx
  800a4e:	85 ff                	test   %edi,%edi
  800a50:	0f 45 c2             	cmovne %edx,%eax
}
  800a53:	5b                   	pop    %ebx
  800a54:	5e                   	pop    %esi
  800a55:	5f                   	pop    %edi
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	89 c3                	mov    %eax,%ebx
  800a6b:	89 c7                	mov    %eax,%edi
  800a6d:	89 c6                	mov    %eax,%esi
  800a6f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a81:	b8 01 00 00 00       	mov    $0x1,%eax
  800a86:	89 d1                	mov    %edx,%ecx
  800a88:	89 d3                	mov    %edx,%ebx
  800a8a:	89 d7                	mov    %edx,%edi
  800a8c:	89 d6                	mov    %edx,%esi
  800a8e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	57                   	push   %edi
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa3:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	89 cb                	mov    %ecx,%ebx
  800aad:	89 cf                	mov    %ecx,%edi
  800aaf:	89 ce                	mov    %ecx,%esi
  800ab1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	7e 17                	jle    800ace <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	50                   	push   %eax
  800abb:	6a 03                	push   $0x3
  800abd:	68 44 13 80 00       	push   $0x801344
  800ac2:	6a 23                	push   $0x23
  800ac4:	68 61 13 80 00       	push   $0x801361
  800ac9:	e8 fd 02 00 00       	call   800dcb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5f                   	pop    %edi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ae6:	89 d1                	mov    %edx,%ecx
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	89 d7                	mov    %edx,%edi
  800aec:	89 d6                	mov    %edx,%esi
  800aee:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_yield>:

void
sys_yield(void)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b05:	89 d1                	mov    %edx,%ecx
  800b07:	89 d3                	mov    %edx,%ebx
  800b09:	89 d7                	mov    %edx,%edi
  800b0b:	89 d6                	mov    %edx,%esi
  800b0d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800b1d:	be 00 00 00 00       	mov    $0x0,%esi
  800b22:	b8 04 00 00 00       	mov    $0x4,%eax
  800b27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b30:	89 f7                	mov    %esi,%edi
  800b32:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b34:	85 c0                	test   %eax,%eax
  800b36:	7e 17                	jle    800b4f <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b38:	83 ec 0c             	sub    $0xc,%esp
  800b3b:	50                   	push   %eax
  800b3c:	6a 04                	push   $0x4
  800b3e:	68 44 13 80 00       	push   $0x801344
  800b43:	6a 23                	push   $0x23
  800b45:	68 61 13 80 00       	push   $0x801361
  800b4a:	e8 7c 02 00 00       	call   800dcb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	b8 05 00 00 00       	mov    $0x5,%eax
  800b65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b68:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b71:	8b 75 18             	mov    0x18(%ebp),%esi
  800b74:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b76:	85 c0                	test   %eax,%eax
  800b78:	7e 17                	jle    800b91 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7a:	83 ec 0c             	sub    $0xc,%esp
  800b7d:	50                   	push   %eax
  800b7e:	6a 05                	push   $0x5
  800b80:	68 44 13 80 00       	push   $0x801344
  800b85:	6a 23                	push   $0x23
  800b87:	68 61 13 80 00       	push   $0x801361
  800b8c:	e8 3a 02 00 00       	call   800dcb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800b91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba7:	b8 06 00 00 00       	mov    $0x6,%eax
  800bac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	89 df                	mov    %ebx,%edi
  800bb4:	89 de                	mov    %ebx,%esi
  800bb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb8:	85 c0                	test   %eax,%eax
  800bba:	7e 17                	jle    800bd3 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	50                   	push   %eax
  800bc0:	6a 06                	push   $0x6
  800bc2:	68 44 13 80 00       	push   $0x801344
  800bc7:	6a 23                	push   $0x23
  800bc9:	68 61 13 80 00       	push   $0x801361
  800bce:	e8 f8 01 00 00       	call   800dcb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be9:	b8 08 00 00 00       	mov    $0x8,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	89 df                	mov    %ebx,%edi
  800bf6:	89 de                	mov    %ebx,%esi
  800bf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	7e 17                	jle    800c15 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 08                	push   $0x8
  800c04:	68 44 13 80 00       	push   $0x801344
  800c09:	6a 23                	push   $0x23
  800c0b:	68 61 13 80 00       	push   $0x801361
  800c10:	e8 b6 01 00 00       	call   800dcb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	89 df                	mov    %ebx,%edi
  800c38:	89 de                	mov    %ebx,%esi
  800c3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 09                	push   $0x9
  800c46:	68 44 13 80 00       	push   $0x801344
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 61 13 80 00       	push   $0x801361
  800c52:	e8 74 01 00 00       	call   800dcb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	be 00 00 00 00       	mov    $0x0,%esi
  800c6a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 cb                	mov    %ecx,%ebx
  800c9a:	89 cf                	mov    %ecx,%edi
  800c9c:	89 ce                	mov    %ecx,%esi
  800c9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	7e 17                	jle    800cbb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	6a 0c                	push   $0xc
  800caa:	68 44 13 80 00       	push   $0x801344
  800caf:	6a 23                	push   $0x23
  800cb1:	68 61 13 80 00       	push   $0x801361
  800cb6:	e8 10 01 00 00       	call   800dcb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;
	if (pg != NULL) {
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	74 0e                	je     800ce3 <ipc_recv+0x20>
		r = sys_ipc_recv(pg);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	e8 a4 ff ff ff       	call   800c82 <sys_ipc_recv>
  800cde:	83 c4 10             	add    $0x10,%esp
  800ce1:	eb 10                	jmp    800cf3 <ipc_recv+0x30>
	} else {
		r = sys_ipc_recv((void *) UTOP);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	68 00 00 c0 ee       	push   $0xeec00000
  800ceb:	e8 92 ff ff ff       	call   800c82 <sys_ipc_recv>
  800cf0:	83 c4 10             	add    $0x10,%esp
	}
	if (r < 0) {
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	79 16                	jns    800d0d <ipc_recv+0x4a>
		// failed
		if (from_env_store != NULL) *from_env_store = 0;
  800cf7:	85 f6                	test   %esi,%esi
  800cf9:	74 06                	je     800d01 <ipc_recv+0x3e>
  800cfb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL) *perm_store = 0;
  800d01:	85 db                	test   %ebx,%ebx
  800d03:	74 2c                	je     800d31 <ipc_recv+0x6e>
  800d05:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800d0b:	eb 24                	jmp    800d31 <ipc_recv+0x6e>
		return r;
	} else {
		if (from_env_store != NULL) *from_env_store = thisenv->env_ipc_from;
  800d0d:	85 f6                	test   %esi,%esi
  800d0f:	74 0a                	je     800d1b <ipc_recv+0x58>
  800d11:	a1 04 20 80 00       	mov    0x802004,%eax
  800d16:	8b 40 74             	mov    0x74(%eax),%eax
  800d19:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL) *perm_store = thisenv->env_ipc_perm;
  800d1b:	85 db                	test   %ebx,%ebx
  800d1d:	74 0a                	je     800d29 <ipc_recv+0x66>
  800d1f:	a1 04 20 80 00       	mov    0x802004,%eax
  800d24:	8b 40 78             	mov    0x78(%eax),%eax
  800d27:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  800d29:	a1 04 20 80 00       	mov    0x802004,%eax
  800d2e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  800d31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d44:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	int r;
	if (pg == NULL) pg = (void *)UTOP;
  800d47:	85 f6                	test   %esi,%esi
  800d49:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800d4e:	0f 44 f0             	cmove  %eax,%esi
	do {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800d51:	ff 75 14             	pushl  0x14(%ebp)
  800d54:	56                   	push   %esi
  800d55:	ff 75 0c             	pushl  0xc(%ebp)
  800d58:	57                   	push   %edi
  800d59:	e8 01 ff ff ff       	call   800c5f <sys_ipc_try_send>
  800d5e:	89 c3                	mov    %eax,%ebx
		if (r < 0 && r != -E_IPC_NOT_RECV) panic("ipc send failed: %e", r);
  800d60:	c1 e8 1f             	shr    $0x1f,%eax
  800d63:	83 c4 10             	add    $0x10,%esp
  800d66:	84 c0                	test   %al,%al
  800d68:	74 17                	je     800d81 <ipc_send+0x49>
  800d6a:	83 fb f9             	cmp    $0xfffffff9,%ebx
  800d6d:	74 12                	je     800d81 <ipc_send+0x49>
  800d6f:	53                   	push   %ebx
  800d70:	68 6f 13 80 00       	push   $0x80136f
  800d75:	6a 40                	push   $0x40
  800d77:	68 83 13 80 00       	push   $0x801383
  800d7c:	e8 4a 00 00 00       	call   800dcb <_panic>
		sys_yield();
  800d81:	e8 6f fd ff ff       	call   800af5 <sys_yield>
	} while (r != 0);
  800d86:	85 db                	test   %ebx,%ebx
  800d88:	75 c7                	jne    800d51 <ipc_send+0x19>
}
  800d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800d98:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800d9d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800da0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800da6:	8b 52 50             	mov    0x50(%edx),%edx
  800da9:	39 ca                	cmp    %ecx,%edx
  800dab:	75 0d                	jne    800dba <ipc_find_env+0x28>
			return envs[i].env_id;
  800dad:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800db0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800db5:	8b 40 48             	mov    0x48(%eax),%eax
  800db8:	eb 0f                	jmp    800dc9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800dba:	83 c0 01             	add    $0x1,%eax
  800dbd:	3d 00 04 00 00       	cmp    $0x400,%eax
  800dc2:	75 d9                	jne    800d9d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800dc4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dd0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dd3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dd9:	e8 f8 fc ff ff       	call   800ad6 <sys_getenvid>
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	ff 75 0c             	pushl  0xc(%ebp)
  800de4:	ff 75 08             	pushl  0x8(%ebp)
  800de7:	56                   	push   %esi
  800de8:	50                   	push   %eax
  800de9:	68 90 13 80 00       	push   $0x801390
  800dee:	e8 99 f3 ff ff       	call   80018c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800df3:	83 c4 18             	add    $0x18,%esp
  800df6:	53                   	push   %ebx
  800df7:	ff 75 10             	pushl  0x10(%ebp)
  800dfa:	e8 3c f3 ff ff       	call   80013b <vcprintf>
	cprintf("\n");
  800dff:	c7 04 24 cf 10 80 00 	movl   $0x8010cf,(%esp)
  800e06:	e8 81 f3 ff ff       	call   80018c <cprintf>
  800e0b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e0e:	cc                   	int3   
  800e0f:	eb fd                	jmp    800e0e <_panic+0x43>
  800e11:	66 90                	xchg   %ax,%ax
  800e13:	66 90                	xchg   %ax,%ax
  800e15:	66 90                	xchg   %ax,%ax
  800e17:	66 90                	xchg   %ax,%ax
  800e19:	66 90                	xchg   %ax,%ax
  800e1b:	66 90                	xchg   %ax,%ax
  800e1d:	66 90                	xchg   %ax,%ax
  800e1f:	90                   	nop

00800e20 <__udivdi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 f6                	test   %esi,%esi
  800e39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e3d:	89 ca                	mov    %ecx,%edx
  800e3f:	89 f8                	mov    %edi,%eax
  800e41:	75 3d                	jne    800e80 <__udivdi3+0x60>
  800e43:	39 cf                	cmp    %ecx,%edi
  800e45:	0f 87 c5 00 00 00    	ja     800f10 <__udivdi3+0xf0>
  800e4b:	85 ff                	test   %edi,%edi
  800e4d:	89 fd                	mov    %edi,%ebp
  800e4f:	75 0b                	jne    800e5c <__udivdi3+0x3c>
  800e51:	b8 01 00 00 00       	mov    $0x1,%eax
  800e56:	31 d2                	xor    %edx,%edx
  800e58:	f7 f7                	div    %edi
  800e5a:	89 c5                	mov    %eax,%ebp
  800e5c:	89 c8                	mov    %ecx,%eax
  800e5e:	31 d2                	xor    %edx,%edx
  800e60:	f7 f5                	div    %ebp
  800e62:	89 c1                	mov    %eax,%ecx
  800e64:	89 d8                	mov    %ebx,%eax
  800e66:	89 cf                	mov    %ecx,%edi
  800e68:	f7 f5                	div    %ebp
  800e6a:	89 c3                	mov    %eax,%ebx
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
  800e80:	39 ce                	cmp    %ecx,%esi
  800e82:	77 74                	ja     800ef8 <__udivdi3+0xd8>
  800e84:	0f bd fe             	bsr    %esi,%edi
  800e87:	83 f7 1f             	xor    $0x1f,%edi
  800e8a:	0f 84 98 00 00 00    	je     800f28 <__udivdi3+0x108>
  800e90:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e95:	89 f9                	mov    %edi,%ecx
  800e97:	89 c5                	mov    %eax,%ebp
  800e99:	29 fb                	sub    %edi,%ebx
  800e9b:	d3 e6                	shl    %cl,%esi
  800e9d:	89 d9                	mov    %ebx,%ecx
  800e9f:	d3 ed                	shr    %cl,%ebp
  800ea1:	89 f9                	mov    %edi,%ecx
  800ea3:	d3 e0                	shl    %cl,%eax
  800ea5:	09 ee                	or     %ebp,%esi
  800ea7:	89 d9                	mov    %ebx,%ecx
  800ea9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ead:	89 d5                	mov    %edx,%ebp
  800eaf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800eb3:	d3 ed                	shr    %cl,%ebp
  800eb5:	89 f9                	mov    %edi,%ecx
  800eb7:	d3 e2                	shl    %cl,%edx
  800eb9:	89 d9                	mov    %ebx,%ecx
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	09 c2                	or     %eax,%edx
  800ebf:	89 d0                	mov    %edx,%eax
  800ec1:	89 ea                	mov    %ebp,%edx
  800ec3:	f7 f6                	div    %esi
  800ec5:	89 d5                	mov    %edx,%ebp
  800ec7:	89 c3                	mov    %eax,%ebx
  800ec9:	f7 64 24 0c          	mull   0xc(%esp)
  800ecd:	39 d5                	cmp    %edx,%ebp
  800ecf:	72 10                	jb     800ee1 <__udivdi3+0xc1>
  800ed1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ed5:	89 f9                	mov    %edi,%ecx
  800ed7:	d3 e6                	shl    %cl,%esi
  800ed9:	39 c6                	cmp    %eax,%esi
  800edb:	73 07                	jae    800ee4 <__udivdi3+0xc4>
  800edd:	39 d5                	cmp    %edx,%ebp
  800edf:	75 03                	jne    800ee4 <__udivdi3+0xc4>
  800ee1:	83 eb 01             	sub    $0x1,%ebx
  800ee4:	31 ff                	xor    %edi,%edi
  800ee6:	89 d8                	mov    %ebx,%eax
  800ee8:	89 fa                	mov    %edi,%edx
  800eea:	83 c4 1c             	add    $0x1c,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
  800ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ef8:	31 ff                	xor    %edi,%edi
  800efa:	31 db                	xor    %ebx,%ebx
  800efc:	89 d8                	mov    %ebx,%eax
  800efe:	89 fa                	mov    %edi,%edx
  800f00:	83 c4 1c             	add    $0x1c,%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    
  800f08:	90                   	nop
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	89 d8                	mov    %ebx,%eax
  800f12:	f7 f7                	div    %edi
  800f14:	31 ff                	xor    %edi,%edi
  800f16:	89 c3                	mov    %eax,%ebx
  800f18:	89 d8                	mov    %ebx,%eax
  800f1a:	89 fa                	mov    %edi,%edx
  800f1c:	83 c4 1c             	add    $0x1c,%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    
  800f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f28:	39 ce                	cmp    %ecx,%esi
  800f2a:	72 0c                	jb     800f38 <__udivdi3+0x118>
  800f2c:	31 db                	xor    %ebx,%ebx
  800f2e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f32:	0f 87 34 ff ff ff    	ja     800e6c <__udivdi3+0x4c>
  800f38:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f3d:	e9 2a ff ff ff       	jmp    800e6c <__udivdi3+0x4c>
  800f42:	66 90                	xchg   %ax,%ax
  800f44:	66 90                	xchg   %ax,%ax
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	66 90                	xchg   %ax,%ax
  800f4a:	66 90                	xchg   %ax,%ax
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__umoddi3>:
  800f50:	55                   	push   %ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 1c             	sub    $0x1c,%esp
  800f57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f5b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f67:	85 d2                	test   %edx,%edx
  800f69:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f71:	89 f3                	mov    %esi,%ebx
  800f73:	89 3c 24             	mov    %edi,(%esp)
  800f76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f7a:	75 1c                	jne    800f98 <__umoddi3+0x48>
  800f7c:	39 f7                	cmp    %esi,%edi
  800f7e:	76 50                	jbe    800fd0 <__umoddi3+0x80>
  800f80:	89 c8                	mov    %ecx,%eax
  800f82:	89 f2                	mov    %esi,%edx
  800f84:	f7 f7                	div    %edi
  800f86:	89 d0                	mov    %edx,%eax
  800f88:	31 d2                	xor    %edx,%edx
  800f8a:	83 c4 1c             	add    $0x1c,%esp
  800f8d:	5b                   	pop    %ebx
  800f8e:	5e                   	pop    %esi
  800f8f:	5f                   	pop    %edi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    
  800f92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f98:	39 f2                	cmp    %esi,%edx
  800f9a:	89 d0                	mov    %edx,%eax
  800f9c:	77 52                	ja     800ff0 <__umoddi3+0xa0>
  800f9e:	0f bd ea             	bsr    %edx,%ebp
  800fa1:	83 f5 1f             	xor    $0x1f,%ebp
  800fa4:	75 5a                	jne    801000 <__umoddi3+0xb0>
  800fa6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800faa:	0f 82 e0 00 00 00    	jb     801090 <__umoddi3+0x140>
  800fb0:	39 0c 24             	cmp    %ecx,(%esp)
  800fb3:	0f 86 d7 00 00 00    	jbe    801090 <__umoddi3+0x140>
  800fb9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fbd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fc1:	83 c4 1c             	add    $0x1c,%esp
  800fc4:	5b                   	pop    %ebx
  800fc5:	5e                   	pop    %esi
  800fc6:	5f                   	pop    %edi
  800fc7:	5d                   	pop    %ebp
  800fc8:	c3                   	ret    
  800fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd0:	85 ff                	test   %edi,%edi
  800fd2:	89 fd                	mov    %edi,%ebp
  800fd4:	75 0b                	jne    800fe1 <__umoddi3+0x91>
  800fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	f7 f7                	div    %edi
  800fdf:	89 c5                	mov    %eax,%ebp
  800fe1:	89 f0                	mov    %esi,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f5                	div    %ebp
  800fe7:	89 c8                	mov    %ecx,%eax
  800fe9:	f7 f5                	div    %ebp
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	eb 99                	jmp    800f88 <__umoddi3+0x38>
  800fef:	90                   	nop
  800ff0:	89 c8                	mov    %ecx,%eax
  800ff2:	89 f2                	mov    %esi,%edx
  800ff4:	83 c4 1c             	add    $0x1c,%esp
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
  800ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801000:	8b 34 24             	mov    (%esp),%esi
  801003:	bf 20 00 00 00       	mov    $0x20,%edi
  801008:	89 e9                	mov    %ebp,%ecx
  80100a:	29 ef                	sub    %ebp,%edi
  80100c:	d3 e0                	shl    %cl,%eax
  80100e:	89 f9                	mov    %edi,%ecx
  801010:	89 f2                	mov    %esi,%edx
  801012:	d3 ea                	shr    %cl,%edx
  801014:	89 e9                	mov    %ebp,%ecx
  801016:	09 c2                	or     %eax,%edx
  801018:	89 d8                	mov    %ebx,%eax
  80101a:	89 14 24             	mov    %edx,(%esp)
  80101d:	89 f2                	mov    %esi,%edx
  80101f:	d3 e2                	shl    %cl,%edx
  801021:	89 f9                	mov    %edi,%ecx
  801023:	89 54 24 04          	mov    %edx,0x4(%esp)
  801027:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80102b:	d3 e8                	shr    %cl,%eax
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	89 c6                	mov    %eax,%esi
  801031:	d3 e3                	shl    %cl,%ebx
  801033:	89 f9                	mov    %edi,%ecx
  801035:	89 d0                	mov    %edx,%eax
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	09 d8                	or     %ebx,%eax
  80103d:	89 d3                	mov    %edx,%ebx
  80103f:	89 f2                	mov    %esi,%edx
  801041:	f7 34 24             	divl   (%esp)
  801044:	89 d6                	mov    %edx,%esi
  801046:	d3 e3                	shl    %cl,%ebx
  801048:	f7 64 24 04          	mull   0x4(%esp)
  80104c:	39 d6                	cmp    %edx,%esi
  80104e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801052:	89 d1                	mov    %edx,%ecx
  801054:	89 c3                	mov    %eax,%ebx
  801056:	72 08                	jb     801060 <__umoddi3+0x110>
  801058:	75 11                	jne    80106b <__umoddi3+0x11b>
  80105a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80105e:	73 0b                	jae    80106b <__umoddi3+0x11b>
  801060:	2b 44 24 04          	sub    0x4(%esp),%eax
  801064:	1b 14 24             	sbb    (%esp),%edx
  801067:	89 d1                	mov    %edx,%ecx
  801069:	89 c3                	mov    %eax,%ebx
  80106b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80106f:	29 da                	sub    %ebx,%edx
  801071:	19 ce                	sbb    %ecx,%esi
  801073:	89 f9                	mov    %edi,%ecx
  801075:	89 f0                	mov    %esi,%eax
  801077:	d3 e0                	shl    %cl,%eax
  801079:	89 e9                	mov    %ebp,%ecx
  80107b:	d3 ea                	shr    %cl,%edx
  80107d:	89 e9                	mov    %ebp,%ecx
  80107f:	d3 ee                	shr    %cl,%esi
  801081:	09 d0                	or     %edx,%eax
  801083:	89 f2                	mov    %esi,%edx
  801085:	83 c4 1c             	add    $0x1c,%esp
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	29 f9                	sub    %edi,%ecx
  801092:	19 d6                	sbb    %edx,%esi
  801094:	89 74 24 04          	mov    %esi,0x4(%esp)
  801098:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80109c:	e9 18 ff ff ff       	jmp    800fb9 <__umoddi3+0x69>
