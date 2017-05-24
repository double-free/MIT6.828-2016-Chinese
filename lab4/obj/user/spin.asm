
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 20 13 80 00       	push   $0x801320
  80003f:	e8 5c 01 00 00       	call   8001a0 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 88 0d 00 00       	call   800dd1 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 98 13 80 00       	push   $0x801398
  800058:	e8 43 01 00 00       	call   8001a0 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 48 13 80 00       	push   $0x801348
  80006c:	e8 2f 01 00 00       	call   8001a0 <cprintf>
	sys_yield();
  800071:	e8 93 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800076:	e8 8e 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  80007b:	e8 89 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800080:	e8 84 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800085:	e8 7f 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  80008a:	e8 7a 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  80008f:	e8 75 0a 00 00       	call   800b09 <sys_yield>
	sys_yield();
  800094:	e8 70 0a 00 00       	call   800b09 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 70 13 80 00 	movl   $0x801370,(%esp)
  8000a0:	e8 fb 00 00 00       	call   8001a0 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 fc 09 00 00       	call   800aa9 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 25 0a 00 00       	call   800aea <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 a1 09 00 00       	call   800aa9 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	75 1a                	jne    800146 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80012c:	83 ec 08             	sub    $0x8,%esp
  80012f:	68 ff 00 00 00       	push   $0xff
  800134:	8d 43 08             	lea    0x8(%ebx),%eax
  800137:	50                   	push   %eax
  800138:	e8 2f 09 00 00       	call   800a6c <sys_cputs>
		b->idx = 0;
  80013d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800143:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800146:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800158:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015f:	00 00 00 
	b.cnt = 0;
  800162:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800169:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016c:	ff 75 0c             	pushl  0xc(%ebp)
  80016f:	ff 75 08             	pushl  0x8(%ebp)
  800172:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800178:	50                   	push   %eax
  800179:	68 0d 01 80 00       	push   $0x80010d
  80017e:	e8 54 01 00 00       	call   8002d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800183:	83 c4 08             	add    $0x8,%esp
  800186:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	e8 d4 08 00 00       	call   800a6c <sys_cputs>

	return b.cnt;
}
  800198:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001a9:	50                   	push   %eax
  8001aa:	ff 75 08             	pushl  0x8(%ebp)
  8001ad:	e8 9d ff ff ff       	call   80014f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	57                   	push   %edi
  8001b8:	56                   	push   %esi
  8001b9:	53                   	push   %ebx
  8001ba:	83 ec 1c             	sub    $0x1c,%esp
  8001bd:	89 c7                	mov    %eax,%edi
  8001bf:	89 d6                	mov    %edx,%esi
  8001c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001d8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001db:	39 d3                	cmp    %edx,%ebx
  8001dd:	72 05                	jb     8001e4 <printnum+0x30>
  8001df:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001e2:	77 45                	ja     800229 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 18             	pushl  0x18(%ebp)
  8001ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ed:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f0:	53                   	push   %ebx
  8001f1:	ff 75 10             	pushl  0x10(%ebp)
  8001f4:	83 ec 08             	sub    $0x8,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	ff 75 dc             	pushl  -0x24(%ebp)
  800200:	ff 75 d8             	pushl  -0x28(%ebp)
  800203:	e8 78 0e 00 00       	call   801080 <__udivdi3>
  800208:	83 c4 18             	add    $0x18,%esp
  80020b:	52                   	push   %edx
  80020c:	50                   	push   %eax
  80020d:	89 f2                	mov    %esi,%edx
  80020f:	89 f8                	mov    %edi,%eax
  800211:	e8 9e ff ff ff       	call   8001b4 <printnum>
  800216:	83 c4 20             	add    $0x20,%esp
  800219:	eb 18                	jmp    800233 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	56                   	push   %esi
  80021f:	ff 75 18             	pushl  0x18(%ebp)
  800222:	ff d7                	call   *%edi
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	eb 03                	jmp    80022c <printnum+0x78>
  800229:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022c:	83 eb 01             	sub    $0x1,%ebx
  80022f:	85 db                	test   %ebx,%ebx
  800231:	7f e8                	jg     80021b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	56                   	push   %esi
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	ff 75 dc             	pushl  -0x24(%ebp)
  800243:	ff 75 d8             	pushl  -0x28(%ebp)
  800246:	e8 65 0f 00 00       	call   8011b0 <__umoddi3>
  80024b:	83 c4 14             	add    $0x14,%esp
  80024e:	0f be 80 c0 13 80 00 	movsbl 0x8013c0(%eax),%eax
  800255:	50                   	push   %eax
  800256:	ff d7                	call   *%edi
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800266:	83 fa 01             	cmp    $0x1,%edx
  800269:	7e 0e                	jle    800279 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80026b:	8b 10                	mov    (%eax),%edx
  80026d:	8d 4a 08             	lea    0x8(%edx),%ecx
  800270:	89 08                	mov    %ecx,(%eax)
  800272:	8b 02                	mov    (%edx),%eax
  800274:	8b 52 04             	mov    0x4(%edx),%edx
  800277:	eb 22                	jmp    80029b <getuint+0x38>
	else if (lflag)
  800279:	85 d2                	test   %edx,%edx
  80027b:	74 10                	je     80028d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80027d:	8b 10                	mov    (%eax),%edx
  80027f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800282:	89 08                	mov    %ecx,(%eax)
  800284:	8b 02                	mov    (%edx),%eax
  800286:	ba 00 00 00 00       	mov    $0x0,%edx
  80028b:	eb 0e                	jmp    80029b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80028d:	8b 10                	mov    (%eax),%edx
  80028f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 02                	mov    (%edx),%eax
  800296:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a7:	8b 10                	mov    (%eax),%edx
  8002a9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ac:	73 0a                	jae    8002b8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ae:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b1:	89 08                	mov    %ecx,(%eax)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	88 02                	mov    %al,(%edx)
}
  8002b8:	5d                   	pop    %ebp
  8002b9:	c3                   	ret    

008002ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ba:	55                   	push   %ebp
  8002bb:	89 e5                	mov    %esp,%ebp
  8002bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c3:	50                   	push   %eax
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ca:	ff 75 08             	pushl  0x8(%ebp)
  8002cd:	e8 05 00 00 00       	call   8002d7 <vprintfmt>
	va_end(ap);
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	83 ec 2c             	sub    $0x2c,%esp
  8002e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8002e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e9:	eb 12                	jmp    8002fd <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	0f 84 89 03 00 00    	je     80067c <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	53                   	push   %ebx
  8002f7:	50                   	push   %eax
  8002f8:	ff d6                	call   *%esi
  8002fa:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fd:	83 c7 01             	add    $0x1,%edi
  800300:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800304:	83 f8 25             	cmp    $0x25,%eax
  800307:	75 e2                	jne    8002eb <vprintfmt+0x14>
  800309:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80030d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800314:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	eb 07                	jmp    800330 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80032c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8d 47 01             	lea    0x1(%edi),%eax
  800333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800336:	0f b6 07             	movzbl (%edi),%eax
  800339:	0f b6 c8             	movzbl %al,%ecx
  80033c:	83 e8 23             	sub    $0x23,%eax
  80033f:	3c 55                	cmp    $0x55,%al
  800341:	0f 87 1a 03 00 00    	ja     800661 <vprintfmt+0x38a>
  800347:	0f b6 c0             	movzbl %al,%eax
  80034a:	ff 24 85 80 14 80 00 	jmp    *0x801480(,%eax,4)
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800354:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800358:	eb d6                	jmp    800330 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035d:	b8 00 00 00 00       	mov    $0x0,%eax
  800362:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800365:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800368:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80036c:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80036f:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800372:	83 fa 09             	cmp    $0x9,%edx
  800375:	77 39                	ja     8003b0 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800377:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80037a:	eb e9                	jmp    800365 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 48 04             	lea    0x4(%eax),%ecx
  800382:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800385:	8b 00                	mov    (%eax),%eax
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038d:	eb 27                	jmp    8003b6 <vprintfmt+0xdf>
  80038f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800392:	85 c0                	test   %eax,%eax
  800394:	b9 00 00 00 00       	mov    $0x0,%ecx
  800399:	0f 49 c8             	cmovns %eax,%ecx
  80039c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a2:	eb 8c                	jmp    800330 <vprintfmt+0x59>
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ae:	eb 80                	jmp    800330 <vprintfmt+0x59>
  8003b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	0f 89 70 ff ff ff    	jns    800330 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	e9 5e ff ff ff       	jmp    800330 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d8:	e9 53 ff ff ff       	jmp    800330 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 50 04             	lea    0x4(%eax),%edx
  8003e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	53                   	push   %ebx
  8003ea:	ff 30                	pushl  (%eax)
  8003ec:	ff d6                	call   *%esi
			break;
  8003ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 04 ff ff ff       	jmp    8002fd <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 50 04             	lea    0x4(%eax),%edx
  8003ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	99                   	cltd   
  800405:	31 d0                	xor    %edx,%eax
  800407:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800409:	83 f8 08             	cmp    $0x8,%eax
  80040c:	7f 0b                	jg     800419 <vprintfmt+0x142>
  80040e:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  800415:	85 d2                	test   %edx,%edx
  800417:	75 18                	jne    800431 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800419:	50                   	push   %eax
  80041a:	68 d8 13 80 00       	push   $0x8013d8
  80041f:	53                   	push   %ebx
  800420:	56                   	push   %esi
  800421:	e8 94 fe ff ff       	call   8002ba <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 cc fe ff ff       	jmp    8002fd <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	68 e1 13 80 00       	push   $0x8013e1
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 7c fe ff ff       	call   8002ba <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800441:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800444:	e9 b4 fe ff ff       	jmp    8002fd <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 50 04             	lea    0x4(%eax),%edx
  80044f:	89 55 14             	mov    %edx,0x14(%ebp)
  800452:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800454:	85 ff                	test   %edi,%edi
  800456:	b8 d1 13 80 00       	mov    $0x8013d1,%eax
  80045b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	0f 8e 94 00 00 00    	jle    8004fc <vprintfmt+0x225>
  800468:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80046c:	0f 84 98 00 00 00    	je     80050a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 d0             	pushl  -0x30(%ebp)
  800478:	57                   	push   %edi
  800479:	e8 86 02 00 00       	call   800704 <strnlen>
  80047e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800481:	29 c1                	sub    %eax,%ecx
  800483:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800489:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800490:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800493:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	eb 0f                	jmp    8004a6 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	53                   	push   %ebx
  80049b:	ff 75 e0             	pushl  -0x20(%ebp)
  80049e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	83 ef 01             	sub    $0x1,%edi
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	85 ff                	test   %edi,%edi
  8004a8:	7f ed                	jg     800497 <vprintfmt+0x1c0>
  8004aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004ad:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004b0:	85 c9                	test   %ecx,%ecx
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	0f 49 c1             	cmovns %ecx,%eax
  8004ba:	29 c1                	sub    %eax,%ecx
  8004bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c5:	89 cb                	mov    %ecx,%ebx
  8004c7:	eb 4d                	jmp    800516 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004cd:	74 1b                	je     8004ea <vprintfmt+0x213>
  8004cf:	0f be c0             	movsbl %al,%eax
  8004d2:	83 e8 20             	sub    $0x20,%eax
  8004d5:	83 f8 5e             	cmp    $0x5e,%eax
  8004d8:	76 10                	jbe    8004ea <vprintfmt+0x213>
					putch('?', putdat);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	ff 75 0c             	pushl  0xc(%ebp)
  8004e0:	6a 3f                	push   $0x3f
  8004e2:	ff 55 08             	call   *0x8(%ebp)
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb 0d                	jmp    8004f7 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	ff 75 0c             	pushl  0xc(%ebp)
  8004f0:	52                   	push   %edx
  8004f1:	ff 55 08             	call   *0x8(%ebp)
  8004f4:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f7:	83 eb 01             	sub    $0x1,%ebx
  8004fa:	eb 1a                	jmp    800516 <vprintfmt+0x23f>
  8004fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800502:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800505:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800508:	eb 0c                	jmp    800516 <vprintfmt+0x23f>
  80050a:	89 75 08             	mov    %esi,0x8(%ebp)
  80050d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800510:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800513:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800516:	83 c7 01             	add    $0x1,%edi
  800519:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051d:	0f be d0             	movsbl %al,%edx
  800520:	85 d2                	test   %edx,%edx
  800522:	74 23                	je     800547 <vprintfmt+0x270>
  800524:	85 f6                	test   %esi,%esi
  800526:	78 a1                	js     8004c9 <vprintfmt+0x1f2>
  800528:	83 ee 01             	sub    $0x1,%esi
  80052b:	79 9c                	jns    8004c9 <vprintfmt+0x1f2>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	eb 18                	jmp    80054f <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	6a 20                	push   $0x20
  80053d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053f:	83 ef 01             	sub    $0x1,%edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb 08                	jmp    80054f <vprintfmt+0x278>
  800547:	89 df                	mov    %ebx,%edi
  800549:	8b 75 08             	mov    0x8(%ebp),%esi
  80054c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054f:	85 ff                	test   %edi,%edi
  800551:	7f e4                	jg     800537 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800556:	e9 a2 fd ff ff       	jmp    8002fd <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80055b:	83 fa 01             	cmp    $0x1,%edx
  80055e:	7e 16                	jle    800576 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8d 50 08             	lea    0x8(%eax),%edx
  800566:	89 55 14             	mov    %edx,0x14(%ebp)
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	eb 32                	jmp    8005a8 <vprintfmt+0x2d1>
	else if (lflag)
  800576:	85 d2                	test   %edx,%edx
  800578:	74 18                	je     800592 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 50 04             	lea    0x4(%eax),%edx
  800580:	89 55 14             	mov    %edx,0x14(%ebp)
  800583:	8b 00                	mov    (%eax),%eax
  800585:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800588:	89 c1                	mov    %eax,%ecx
  80058a:	c1 f9 1f             	sar    $0x1f,%ecx
  80058d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800590:	eb 16                	jmp    8005a8 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a0:	89 c1                	mov    %eax,%ecx
  8005a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005ae:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005b7:	79 74                	jns    80062d <vprintfmt+0x356>
				putch('-', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 2d                	push   $0x2d
  8005bf:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005c7:	f7 d8                	neg    %eax
  8005c9:	83 d2 00             	adc    $0x0,%edx
  8005cc:	f7 da                	neg    %edx
  8005ce:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005d1:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8005d6:	eb 55                	jmp    80062d <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005db:	e8 83 fc ff ff       	call   800263 <getuint>
			base = 10;
  8005e0:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8005e5:	eb 46                	jmp    80062d <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  8005e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ea:	e8 74 fc ff ff       	call   800263 <getuint>
			base = 8;
  8005ef:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8005f4:	eb 37                	jmp    80062d <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	6a 30                	push   $0x30
  8005fc:	ff d6                	call   *%esi
			putch('x', putdat);
  8005fe:	83 c4 08             	add    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 78                	push   $0x78
  800604:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800616:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800619:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80061e:	eb 0d                	jmp    80062d <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800620:	8d 45 14             	lea    0x14(%ebp),%eax
  800623:	e8 3b fc ff ff       	call   800263 <getuint>
			base = 16;
  800628:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800634:	57                   	push   %edi
  800635:	ff 75 e0             	pushl  -0x20(%ebp)
  800638:	51                   	push   %ecx
  800639:	52                   	push   %edx
  80063a:	50                   	push   %eax
  80063b:	89 da                	mov    %ebx,%edx
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	e8 70 fb ff ff       	call   8001b4 <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80064a:	e9 ae fc ff ff       	jmp    8002fd <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	51                   	push   %ecx
  800654:	ff d6                	call   *%esi
			break;
  800656:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80065c:	e9 9c fc ff ff       	jmp    8002fd <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	53                   	push   %ebx
  800665:	6a 25                	push   $0x25
  800667:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	eb 03                	jmp    800671 <vprintfmt+0x39a>
  80066e:	83 ef 01             	sub    $0x1,%edi
  800671:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800675:	75 f7                	jne    80066e <vprintfmt+0x397>
  800677:	e9 81 fc ff ff       	jmp    8002fd <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80067c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067f:	5b                   	pop    %ebx
  800680:	5e                   	pop    %esi
  800681:	5f                   	pop    %edi
  800682:	5d                   	pop    %ebp
  800683:	c3                   	ret    

00800684 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	83 ec 18             	sub    $0x18,%esp
  80068a:	8b 45 08             	mov    0x8(%ebp),%eax
  80068d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800690:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800693:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800697:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 26                	je     8006cb <vsnprintf+0x47>
  8006a5:	85 d2                	test   %edx,%edx
  8006a7:	7e 22                	jle    8006cb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006a9:	ff 75 14             	pushl  0x14(%ebp)
  8006ac:	ff 75 10             	pushl  0x10(%ebp)
  8006af:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b2:	50                   	push   %eax
  8006b3:	68 9d 02 80 00       	push   $0x80029d
  8006b8:	e8 1a fc ff ff       	call   8002d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb 05                	jmp    8006d0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006d0:	c9                   	leave  
  8006d1:	c3                   	ret    

008006d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006d8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006db:	50                   	push   %eax
  8006dc:	ff 75 10             	pushl  0x10(%ebp)
  8006df:	ff 75 0c             	pushl  0xc(%ebp)
  8006e2:	ff 75 08             	pushl  0x8(%ebp)
  8006e5:	e8 9a ff ff ff       	call   800684 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006ea:	c9                   	leave  
  8006eb:	c3                   	ret    

008006ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f7:	eb 03                	jmp    8006fc <strlen+0x10>
		n++;
  8006f9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800700:	75 f7                	jne    8006f9 <strlen+0xd>
		n++;
	return n;
}
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80070a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80070d:	ba 00 00 00 00       	mov    $0x0,%edx
  800712:	eb 03                	jmp    800717 <strnlen+0x13>
		n++;
  800714:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800717:	39 c2                	cmp    %eax,%edx
  800719:	74 08                	je     800723 <strnlen+0x1f>
  80071b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80071f:	75 f3                	jne    800714 <strnlen+0x10>
  800721:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    

00800725 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800725:	55                   	push   %ebp
  800726:	89 e5                	mov    %esp,%ebp
  800728:	53                   	push   %ebx
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80072f:	89 c2                	mov    %eax,%edx
  800731:	83 c2 01             	add    $0x1,%edx
  800734:	83 c1 01             	add    $0x1,%ecx
  800737:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80073b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80073e:	84 db                	test   %bl,%bl
  800740:	75 ef                	jne    800731 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800742:	5b                   	pop    %ebx
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80074c:	53                   	push   %ebx
  80074d:	e8 9a ff ff ff       	call   8006ec <strlen>
  800752:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800755:	ff 75 0c             	pushl  0xc(%ebp)
  800758:	01 d8                	add    %ebx,%eax
  80075a:	50                   	push   %eax
  80075b:	e8 c5 ff ff ff       	call   800725 <strcpy>
	return dst;
}
  800760:	89 d8                	mov    %ebx,%eax
  800762:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800765:	c9                   	leave  
  800766:	c3                   	ret    

00800767 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	56                   	push   %esi
  80076b:	53                   	push   %ebx
  80076c:	8b 75 08             	mov    0x8(%ebp),%esi
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	89 f3                	mov    %esi,%ebx
  800774:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800777:	89 f2                	mov    %esi,%edx
  800779:	eb 0f                	jmp    80078a <strncpy+0x23>
		*dst++ = *src;
  80077b:	83 c2 01             	add    $0x1,%edx
  80077e:	0f b6 01             	movzbl (%ecx),%eax
  800781:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800784:	80 39 01             	cmpb   $0x1,(%ecx)
  800787:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80078a:	39 da                	cmp    %ebx,%edx
  80078c:	75 ed                	jne    80077b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80078e:	89 f0                	mov    %esi,%eax
  800790:	5b                   	pop    %ebx
  800791:	5e                   	pop    %esi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	56                   	push   %esi
  800798:	53                   	push   %ebx
  800799:	8b 75 08             	mov    0x8(%ebp),%esi
  80079c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80079f:	8b 55 10             	mov    0x10(%ebp),%edx
  8007a2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007a4:	85 d2                	test   %edx,%edx
  8007a6:	74 21                	je     8007c9 <strlcpy+0x35>
  8007a8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	eb 09                	jmp    8007b9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007b0:	83 c2 01             	add    $0x1,%edx
  8007b3:	83 c1 01             	add    $0x1,%ecx
  8007b6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007b9:	39 c2                	cmp    %eax,%edx
  8007bb:	74 09                	je     8007c6 <strlcpy+0x32>
  8007bd:	0f b6 19             	movzbl (%ecx),%ebx
  8007c0:	84 db                	test   %bl,%bl
  8007c2:	75 ec                	jne    8007b0 <strlcpy+0x1c>
  8007c4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007c6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007c9:	29 f0                	sub    %esi,%eax
}
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    

008007cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007d8:	eb 06                	jmp    8007e0 <strcmp+0x11>
		p++, q++;
  8007da:	83 c1 01             	add    $0x1,%ecx
  8007dd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007e0:	0f b6 01             	movzbl (%ecx),%eax
  8007e3:	84 c0                	test   %al,%al
  8007e5:	74 04                	je     8007eb <strcmp+0x1c>
  8007e7:	3a 02                	cmp    (%edx),%al
  8007e9:	74 ef                	je     8007da <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007eb:	0f b6 c0             	movzbl %al,%eax
  8007ee:	0f b6 12             	movzbl (%edx),%edx
  8007f1:	29 d0                	sub    %edx,%eax
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ff:	89 c3                	mov    %eax,%ebx
  800801:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800804:	eb 06                	jmp    80080c <strncmp+0x17>
		n--, p++, q++;
  800806:	83 c0 01             	add    $0x1,%eax
  800809:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80080c:	39 d8                	cmp    %ebx,%eax
  80080e:	74 15                	je     800825 <strncmp+0x30>
  800810:	0f b6 08             	movzbl (%eax),%ecx
  800813:	84 c9                	test   %cl,%cl
  800815:	74 04                	je     80081b <strncmp+0x26>
  800817:	3a 0a                	cmp    (%edx),%cl
  800819:	74 eb                	je     800806 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 00             	movzbl (%eax),%eax
  80081e:	0f b6 12             	movzbl (%edx),%edx
  800821:	29 d0                	sub    %edx,%eax
  800823:	eb 05                	jmp    80082a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80082a:	5b                   	pop    %ebx
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800837:	eb 07                	jmp    800840 <strchr+0x13>
		if (*s == c)
  800839:	38 ca                	cmp    %cl,%dl
  80083b:	74 0f                	je     80084c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	0f b6 10             	movzbl (%eax),%edx
  800843:	84 d2                	test   %dl,%dl
  800845:	75 f2                	jne    800839 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800847:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800858:	eb 03                	jmp    80085d <strfind+0xf>
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800860:	38 ca                	cmp    %cl,%dl
  800862:	74 04                	je     800868 <strfind+0x1a>
  800864:	84 d2                	test   %dl,%dl
  800866:	75 f2                	jne    80085a <strfind+0xc>
			break;
	return (char *) s;
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	57                   	push   %edi
  80086e:	56                   	push   %esi
  80086f:	53                   	push   %ebx
  800870:	8b 7d 08             	mov    0x8(%ebp),%edi
  800873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800876:	85 c9                	test   %ecx,%ecx
  800878:	74 36                	je     8008b0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80087a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800880:	75 28                	jne    8008aa <memset+0x40>
  800882:	f6 c1 03             	test   $0x3,%cl
  800885:	75 23                	jne    8008aa <memset+0x40>
		c &= 0xFF;
  800887:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80088b:	89 d3                	mov    %edx,%ebx
  80088d:	c1 e3 08             	shl    $0x8,%ebx
  800890:	89 d6                	mov    %edx,%esi
  800892:	c1 e6 18             	shl    $0x18,%esi
  800895:	89 d0                	mov    %edx,%eax
  800897:	c1 e0 10             	shl    $0x10,%eax
  80089a:	09 f0                	or     %esi,%eax
  80089c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	09 d0                	or     %edx,%eax
  8008a2:	c1 e9 02             	shr    $0x2,%ecx
  8008a5:	fc                   	cld    
  8008a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008a8:	eb 06                	jmp    8008b0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ad:	fc                   	cld    
  8008ae:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008b0:	89 f8                	mov    %edi,%eax
  8008b2:	5b                   	pop    %ebx
  8008b3:	5e                   	pop    %esi
  8008b4:	5f                   	pop    %edi
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	57                   	push   %edi
  8008bb:	56                   	push   %esi
  8008bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c5:	39 c6                	cmp    %eax,%esi
  8008c7:	73 35                	jae    8008fe <memmove+0x47>
  8008c9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008cc:	39 d0                	cmp    %edx,%eax
  8008ce:	73 2e                	jae    8008fe <memmove+0x47>
		s += n;
		d += n;
  8008d0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d3:	89 d6                	mov    %edx,%esi
  8008d5:	09 fe                	or     %edi,%esi
  8008d7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008dd:	75 13                	jne    8008f2 <memmove+0x3b>
  8008df:	f6 c1 03             	test   $0x3,%cl
  8008e2:	75 0e                	jne    8008f2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008e4:	83 ef 04             	sub    $0x4,%edi
  8008e7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008ea:	c1 e9 02             	shr    $0x2,%ecx
  8008ed:	fd                   	std    
  8008ee:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f0:	eb 09                	jmp    8008fb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008f2:	83 ef 01             	sub    $0x1,%edi
  8008f5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008f8:	fd                   	std    
  8008f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008fb:	fc                   	cld    
  8008fc:	eb 1d                	jmp    80091b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008fe:	89 f2                	mov    %esi,%edx
  800900:	09 c2                	or     %eax,%edx
  800902:	f6 c2 03             	test   $0x3,%dl
  800905:	75 0f                	jne    800916 <memmove+0x5f>
  800907:	f6 c1 03             	test   $0x3,%cl
  80090a:	75 0a                	jne    800916 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80090c:	c1 e9 02             	shr    $0x2,%ecx
  80090f:	89 c7                	mov    %eax,%edi
  800911:	fc                   	cld    
  800912:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800914:	eb 05                	jmp    80091b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800916:	89 c7                	mov    %eax,%edi
  800918:	fc                   	cld    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80091b:	5e                   	pop    %esi
  80091c:	5f                   	pop    %edi
  80091d:	5d                   	pop    %ebp
  80091e:	c3                   	ret    

0080091f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800922:	ff 75 10             	pushl  0x10(%ebp)
  800925:	ff 75 0c             	pushl  0xc(%ebp)
  800928:	ff 75 08             	pushl  0x8(%ebp)
  80092b:	e8 87 ff ff ff       	call   8008b7 <memmove>
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 45 08             	mov    0x8(%ebp),%eax
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 c6                	mov    %eax,%esi
  80093f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800942:	eb 1a                	jmp    80095e <memcmp+0x2c>
		if (*s1 != *s2)
  800944:	0f b6 08             	movzbl (%eax),%ecx
  800947:	0f b6 1a             	movzbl (%edx),%ebx
  80094a:	38 d9                	cmp    %bl,%cl
  80094c:	74 0a                	je     800958 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80094e:	0f b6 c1             	movzbl %cl,%eax
  800951:	0f b6 db             	movzbl %bl,%ebx
  800954:	29 d8                	sub    %ebx,%eax
  800956:	eb 0f                	jmp    800967 <memcmp+0x35>
		s1++, s2++;
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80095e:	39 f0                	cmp    %esi,%eax
  800960:	75 e2                	jne    800944 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800962:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800972:	89 c1                	mov    %eax,%ecx
  800974:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800977:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80097b:	eb 0a                	jmp    800987 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80097d:	0f b6 10             	movzbl (%eax),%edx
  800980:	39 da                	cmp    %ebx,%edx
  800982:	74 07                	je     80098b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800984:	83 c0 01             	add    $0x1,%eax
  800987:	39 c8                	cmp    %ecx,%eax
  800989:	72 f2                	jb     80097d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80098b:	5b                   	pop    %ebx
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	57                   	push   %edi
  800992:	56                   	push   %esi
  800993:	53                   	push   %ebx
  800994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800997:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099a:	eb 03                	jmp    80099f <strtol+0x11>
		s++;
  80099c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099f:	0f b6 01             	movzbl (%ecx),%eax
  8009a2:	3c 20                	cmp    $0x20,%al
  8009a4:	74 f6                	je     80099c <strtol+0xe>
  8009a6:	3c 09                	cmp    $0x9,%al
  8009a8:	74 f2                	je     80099c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009aa:	3c 2b                	cmp    $0x2b,%al
  8009ac:	75 0a                	jne    8009b8 <strtol+0x2a>
		s++;
  8009ae:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009b6:	eb 11                	jmp    8009c9 <strtol+0x3b>
  8009b8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009bd:	3c 2d                	cmp    $0x2d,%al
  8009bf:	75 08                	jne    8009c9 <strtol+0x3b>
		s++, neg = 1;
  8009c1:	83 c1 01             	add    $0x1,%ecx
  8009c4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009c9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009cf:	75 15                	jne    8009e6 <strtol+0x58>
  8009d1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d4:	75 10                	jne    8009e6 <strtol+0x58>
  8009d6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009da:	75 7c                	jne    800a58 <strtol+0xca>
		s += 2, base = 16;
  8009dc:	83 c1 02             	add    $0x2,%ecx
  8009df:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009e4:	eb 16                	jmp    8009fc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009e6:	85 db                	test   %ebx,%ebx
  8009e8:	75 12                	jne    8009fc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009ea:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ef:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f2:	75 08                	jne    8009fc <strtol+0x6e>
		s++, base = 8;
  8009f4:	83 c1 01             	add    $0x1,%ecx
  8009f7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a04:	0f b6 11             	movzbl (%ecx),%edx
  800a07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a0a:	89 f3                	mov    %esi,%ebx
  800a0c:	80 fb 09             	cmp    $0x9,%bl
  800a0f:	77 08                	ja     800a19 <strtol+0x8b>
			dig = *s - '0';
  800a11:	0f be d2             	movsbl %dl,%edx
  800a14:	83 ea 30             	sub    $0x30,%edx
  800a17:	eb 22                	jmp    800a3b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a19:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a1c:	89 f3                	mov    %esi,%ebx
  800a1e:	80 fb 19             	cmp    $0x19,%bl
  800a21:	77 08                	ja     800a2b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a23:	0f be d2             	movsbl %dl,%edx
  800a26:	83 ea 57             	sub    $0x57,%edx
  800a29:	eb 10                	jmp    800a3b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a2b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a2e:	89 f3                	mov    %esi,%ebx
  800a30:	80 fb 19             	cmp    $0x19,%bl
  800a33:	77 16                	ja     800a4b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a35:	0f be d2             	movsbl %dl,%edx
  800a38:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a3b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a3e:	7d 0b                	jge    800a4b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a40:	83 c1 01             	add    $0x1,%ecx
  800a43:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a47:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a49:	eb b9                	jmp    800a04 <strtol+0x76>

	if (endptr)
  800a4b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a4f:	74 0d                	je     800a5e <strtol+0xd0>
		*endptr = (char *) s;
  800a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a54:	89 0e                	mov    %ecx,(%esi)
  800a56:	eb 06                	jmp    800a5e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	74 98                	je     8009f4 <strtol+0x66>
  800a5c:	eb 9e                	jmp    8009fc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	f7 da                	neg    %edx
  800a62:	85 ff                	test   %edi,%edi
  800a64:	0f 45 c2             	cmovne %edx,%eax
}
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
  800a77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7d:	89 c3                	mov    %eax,%ebx
  800a7f:	89 c7                	mov    %eax,%edi
  800a81:	89 c6                	mov    %eax,%esi
  800a83:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <sys_cgetc>:

int
sys_cgetc(void)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a90:	ba 00 00 00 00       	mov    $0x0,%edx
  800a95:	b8 01 00 00 00       	mov    $0x1,%eax
  800a9a:	89 d1                	mov    %edx,%ecx
  800a9c:	89 d3                	mov    %edx,%ebx
  800a9e:	89 d7                	mov    %edx,%edi
  800aa0:	89 d6                	mov    %edx,%esi
  800aa2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ab7:	b8 03 00 00 00       	mov    $0x3,%eax
  800abc:	8b 55 08             	mov    0x8(%ebp),%edx
  800abf:	89 cb                	mov    %ecx,%ebx
  800ac1:	89 cf                	mov    %ecx,%edi
  800ac3:	89 ce                	mov    %ecx,%esi
  800ac5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ac7:	85 c0                	test   %eax,%eax
  800ac9:	7e 17                	jle    800ae2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	50                   	push   %eax
  800acf:	6a 03                	push   $0x3
  800ad1:	68 04 16 80 00       	push   $0x801604
  800ad6:	6a 23                	push   $0x23
  800ad8:	68 21 16 80 00       	push   $0x801621
  800add:	e8 bc 04 00 00       	call   800f9e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ae2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ae5:	5b                   	pop    %ebx
  800ae6:	5e                   	pop    %esi
  800ae7:	5f                   	pop    %edi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <sys_getenvid>:

envid_t
sys_getenvid(void)
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
  800af0:	ba 00 00 00 00       	mov    $0x0,%edx
  800af5:	b8 02 00 00 00       	mov    $0x2,%eax
  800afa:	89 d1                	mov    %edx,%ecx
  800afc:	89 d3                	mov    %edx,%ebx
  800afe:	89 d7                	mov    %edx,%edi
  800b00:	89 d6                	mov    %edx,%esi
  800b02:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <sys_yield>:

void
sys_yield(void)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	57                   	push   %edi
  800b0d:	56                   	push   %esi
  800b0e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b19:	89 d1                	mov    %edx,%ecx
  800b1b:	89 d3                	mov    %edx,%ebx
  800b1d:	89 d7                	mov    %edx,%edi
  800b1f:	89 d6                	mov    %edx,%esi
  800b21:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	57                   	push   %edi
  800b2c:	56                   	push   %esi
  800b2d:	53                   	push   %ebx
  800b2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	be 00 00 00 00       	mov    $0x0,%esi
  800b36:	b8 04 00 00 00       	mov    $0x4,%eax
  800b3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b41:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b44:	89 f7                	mov    %esi,%edi
  800b46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	7e 17                	jle    800b63 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	50                   	push   %eax
  800b50:	6a 04                	push   $0x4
  800b52:	68 04 16 80 00       	push   $0x801604
  800b57:	6a 23                	push   $0x23
  800b59:	68 21 16 80 00       	push   $0x801621
  800b5e:	e8 3b 04 00 00       	call   800f9e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	b8 05 00 00 00       	mov    $0x5,%eax
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800b85:	8b 75 18             	mov    0x18(%ebp),%esi
  800b88:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	7e 17                	jle    800ba5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8e:	83 ec 0c             	sub    $0xc,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 05                	push   $0x5
  800b94:	68 04 16 80 00       	push   $0x801604
  800b99:	6a 23                	push   $0x23
  800b9b:	68 21 16 80 00       	push   $0x801621
  800ba0:	e8 f9 03 00 00       	call   800f9e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbb:	b8 06 00 00 00       	mov    $0x6,%eax
  800bc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	89 df                	mov    %ebx,%edi
  800bc8:	89 de                	mov    %ebx,%esi
  800bca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 06                	push   $0x6
  800bd6:	68 04 16 80 00       	push   $0x801604
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 21 16 80 00       	push   $0x801621
  800be2:	e8 b7 03 00 00       	call   800f9e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfd:	b8 08 00 00 00       	mov    $0x8,%eax
  800c02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c05:	8b 55 08             	mov    0x8(%ebp),%edx
  800c08:	89 df                	mov    %ebx,%edi
  800c0a:	89 de                	mov    %ebx,%esi
  800c0c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7e 17                	jle    800c29 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c12:	83 ec 0c             	sub    $0xc,%esp
  800c15:	50                   	push   %eax
  800c16:	6a 08                	push   $0x8
  800c18:	68 04 16 80 00       	push   $0x801604
  800c1d:	6a 23                	push   $0x23
  800c1f:	68 21 16 80 00       	push   $0x801621
  800c24:	e8 75 03 00 00       	call   800f9e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5f                   	pop    %edi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	57                   	push   %edi
  800c35:	56                   	push   %esi
  800c36:	53                   	push   %ebx
  800c37:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	89 df                	mov    %ebx,%edi
  800c4c:	89 de                	mov    %ebx,%esi
  800c4e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	7e 17                	jle    800c6b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c54:	83 ec 0c             	sub    $0xc,%esp
  800c57:	50                   	push   %eax
  800c58:	6a 09                	push   $0x9
  800c5a:	68 04 16 80 00       	push   $0x801604
  800c5f:	6a 23                	push   $0x23
  800c61:	68 21 16 80 00       	push   $0x801621
  800c66:	e8 33 03 00 00       	call   800f9e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    

00800c73 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	57                   	push   %edi
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	be 00 00 00 00       	mov    $0x0,%esi
  800c7e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c91:	5b                   	pop    %ebx
  800c92:	5e                   	pop    %esi
  800c93:	5f                   	pop    %edi
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 cb                	mov    %ecx,%ebx
  800cae:	89 cf                	mov    %ecx,%edi
  800cb0:	89 ce                	mov    %ecx,%esi
  800cb2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7e 17                	jle    800ccf <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	6a 0c                	push   $0xc
  800cbe:	68 04 16 80 00       	push   $0x801604
  800cc3:	6a 23                	push   $0x23
  800cc5:	68 21 16 80 00       	push   $0x801621
  800cca:	e8 cf 02 00 00       	call   800f9e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    

00800cd7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800cdf:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0) {
  800ce1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ce5:	74 11                	je     800cf8 <pgfault+0x21>
  800ce7:	89 d8                	mov    %ebx,%eax
  800ce9:	c1 e8 0c             	shr    $0xc,%eax
  800cec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800cf3:	f6 c4 08             	test   $0x8,%ah
  800cf6:	75 14                	jne    800d0c <pgfault+0x35>
		panic("pgfault: invalid user trap frame");
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	68 30 16 80 00       	push   $0x801630
  800d00:	6a 1d                	push   $0x1d
  800d02:	68 9c 16 80 00       	push   $0x80169c
  800d07:	e8 92 02 00 00       	call   800f9e <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	// panic("pgfault not implemented");
        envid_t envid = sys_getenvid();
  800d0c:	e8 d9 fd ff ff       	call   800aea <sys_getenvid>
  800d11:	89 c6                	mov    %eax,%esi
        if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800d13:	83 ec 04             	sub    $0x4,%esp
  800d16:	6a 07                	push   $0x7
  800d18:	68 00 f0 7f 00       	push   $0x7ff000
  800d1d:	50                   	push   %eax
  800d1e:	e8 05 fe ff ff       	call   800b28 <sys_page_alloc>
  800d23:	83 c4 10             	add    $0x10,%esp
  800d26:	85 c0                	test   %eax,%eax
  800d28:	79 12                	jns    800d3c <pgfault+0x65>
                panic("pgfault: page allocation failed %e", r);
  800d2a:	50                   	push   %eax
  800d2b:	68 54 16 80 00       	push   $0x801654
  800d30:	6a 29                	push   $0x29
  800d32:	68 9c 16 80 00       	push   $0x80169c
  800d37:	e8 62 02 00 00       	call   800f9e <_panic>

        addr = ROUNDDOWN(addr, PGSIZE);
  800d3c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
        memmove(PFTEMP, addr, PGSIZE);
  800d42:	83 ec 04             	sub    $0x4,%esp
  800d45:	68 00 10 00 00       	push   $0x1000
  800d4a:	53                   	push   %ebx
  800d4b:	68 00 f0 7f 00       	push   $0x7ff000
  800d50:	e8 62 fb ff ff       	call   8008b7 <memmove>
        if ((r = sys_page_unmap(envid, addr)) < 0)
  800d55:	83 c4 08             	add    $0x8,%esp
  800d58:	53                   	push   %ebx
  800d59:	56                   	push   %esi
  800d5a:	e8 4e fe ff ff       	call   800bad <sys_page_unmap>
  800d5f:	83 c4 10             	add    $0x10,%esp
  800d62:	85 c0                	test   %eax,%eax
  800d64:	79 12                	jns    800d78 <pgfault+0xa1>
                panic("pgfault: page unmap failed %e", r);
  800d66:	50                   	push   %eax
  800d67:	68 a7 16 80 00       	push   $0x8016a7
  800d6c:	6a 2e                	push   $0x2e
  800d6e:	68 9c 16 80 00       	push   $0x80169c
  800d73:	e8 26 02 00 00       	call   800f9e <_panic>
        if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	6a 07                	push   $0x7
  800d7d:	53                   	push   %ebx
  800d7e:	56                   	push   %esi
  800d7f:	68 00 f0 7f 00       	push   $0x7ff000
  800d84:	56                   	push   %esi
  800d85:	e8 e1 fd ff ff       	call   800b6b <sys_page_map>
  800d8a:	83 c4 20             	add    $0x20,%esp
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	79 12                	jns    800da3 <pgfault+0xcc>
                panic("pgfault: page map failed %e", r);
  800d91:	50                   	push   %eax
  800d92:	68 c5 16 80 00       	push   $0x8016c5
  800d97:	6a 30                	push   $0x30
  800d99:	68 9c 16 80 00       	push   $0x80169c
  800d9e:	e8 fb 01 00 00       	call   800f9e <_panic>
        if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800da3:	83 ec 08             	sub    $0x8,%esp
  800da6:	68 00 f0 7f 00       	push   $0x7ff000
  800dab:	56                   	push   %esi
  800dac:	e8 fc fd ff ff       	call   800bad <sys_page_unmap>
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	79 12                	jns    800dca <pgfault+0xf3>
                panic("pgfault: page unmap failed %e", r);
  800db8:	50                   	push   %eax
  800db9:	68 a7 16 80 00       	push   $0x8016a7
  800dbe:	6a 32                	push   $0x32
  800dc0:	68 9c 16 80 00       	push   $0x80169c
  800dc5:	e8 d4 01 00 00       	call   800f9e <_panic>
}
  800dca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
  800dd7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// panic("fork not implemented");

	set_pgfault_handler(pgfault);
  800dda:	68 d7 0c 80 00       	push   $0x800cd7
  800ddf:	e8 00 02 00 00       	call   800fe4 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800de4:	b8 07 00 00 00       	mov    $0x7,%eax
  800de9:	cd 30                	int    $0x30
  800deb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800dee:	89 45 e0             	mov    %eax,-0x20(%ebp)
	envid_t e_id = sys_exofork();
	if (e_id < 0) panic("fork: %e", e_id);
  800df1:	83 c4 10             	add    $0x10,%esp
  800df4:	85 c0                	test   %eax,%eax
  800df6:	79 12                	jns    800e0a <fork+0x39>
  800df8:	50                   	push   %eax
  800df9:	68 e1 16 80 00       	push   $0x8016e1
  800dfe:	6a 73                	push   $0x73
  800e00:	68 9c 16 80 00       	push   $0x80169c
  800e05:	e8 94 01 00 00       	call   800f9e <_panic>
  800e0a:	bf 00 00 80 00       	mov    $0x800000,%edi
	if (e_id == 0) {
  800e0f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e13:	75 21                	jne    800e36 <fork+0x65>
		// child
		thisenv = &envs[ENVX(sys_getenvid())];
  800e15:	e8 d0 fc ff ff       	call   800aea <sys_getenvid>
  800e1a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e1f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e22:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e27:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e31:	e9 46 01 00 00       	jmp    800f7c <fork+0x1ab>

	// parent
	// extern unsigned char end[];
	// for ((uint8_t *) addr = UTEXT; addr < end; addr += PGSIZE)
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800e36:	89 f8                	mov    %edi,%eax
  800e38:	c1 e8 16             	shr    $0x16,%eax
  800e3b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e42:	a8 01                	test   $0x1,%al
  800e44:	0f 84 9a 00 00 00    	je     800ee4 <fork+0x113>
  800e4a:	89 fb                	mov    %edi,%ebx
  800e4c:	c1 eb 0c             	shr    $0xc,%ebx
  800e4f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e56:	a8 01                	test   $0x1,%al
  800e58:	0f 84 86 00 00 00    	je     800ee4 <fork+0x113>
	int r;

	// LAB 4: Your code here.
	// panic("duppage not implemented");

	envid_t this_env_id = sys_getenvid();
  800e5e:	e8 87 fc ff ff       	call   800aea <sys_getenvid>
  800e63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800e66:	89 de                	mov    %ebx,%esi
  800e68:	c1 e6 0c             	shl    $0xc,%esi

	int perm = uvpt[pn] & 0xFFF;
  800e6b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800e72:	89 c3                	mov    %eax,%ebx
  800e74:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
	if ( (perm & PTE_W) || (perm & PTE_COW) ) {
  800e7a:	a9 02 08 00 00       	test   $0x802,%eax
  800e7f:	74 0a                	je     800e8b <fork+0xba>
		// marked as COW and read-only
		perm |= PTE_COW;
		perm &= ~PTE_W;
  800e81:	25 fd 0f 00 00       	and    $0xffd,%eax
  800e86:	80 cc 08             	or     $0x8,%ah
  800e89:	89 c3                	mov    %eax,%ebx
	}
	// IMPORTANT: adjust permission to the syscall
	perm &= PTE_SYSCALL;
  800e8b:	81 e3 07 0e 00 00    	and    $0xe07,%ebx
	// cprintf("fromenvid = %x, toenvid = %x, dup page %d, addr = %08p, perm = %03x\n",this_env_id, envid, pn, va, perm);
	if((r = sys_page_map(this_env_id, va, envid, va, perm)) < 0) 
  800e91:	83 ec 0c             	sub    $0xc,%esp
  800e94:	53                   	push   %ebx
  800e95:	56                   	push   %esi
  800e96:	ff 75 e0             	pushl  -0x20(%ebp)
  800e99:	56                   	push   %esi
  800e9a:	ff 75 e4             	pushl  -0x1c(%ebp)
  800e9d:	e8 c9 fc ff ff       	call   800b6b <sys_page_map>
  800ea2:	83 c4 20             	add    $0x20,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	79 12                	jns    800ebb <fork+0xea>
		panic("duppage: %e",r);
  800ea9:	50                   	push   %eax
  800eaa:	68 ea 16 80 00       	push   $0x8016ea
  800eaf:	6a 55                	push   $0x55
  800eb1:	68 9c 16 80 00       	push   $0x80169c
  800eb6:	e8 e3 00 00 00       	call   800f9e <_panic>
	if((r = sys_page_map(this_env_id, va, this_env_id, va, perm)) < 0) 
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	53                   	push   %ebx
  800ebf:	56                   	push   %esi
  800ec0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ec3:	50                   	push   %eax
  800ec4:	56                   	push   %esi
  800ec5:	50                   	push   %eax
  800ec6:	e8 a0 fc ff ff       	call   800b6b <sys_page_map>
  800ecb:	83 c4 20             	add    $0x20,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	79 12                	jns    800ee4 <fork+0x113>
		panic("duppage: %e",r);
  800ed2:	50                   	push   %eax
  800ed3:	68 ea 16 80 00       	push   $0x8016ea
  800ed8:	6a 57                	push   $0x57
  800eda:	68 9c 16 80 00       	push   $0x80169c
  800edf:	e8 ba 00 00 00       	call   800f9e <_panic>
	}

	// parent
	// extern unsigned char end[];
	// for ((uint8_t *) addr = UTEXT; addr < end; addr += PGSIZE)
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800ee4:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800eea:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  800ef0:	0f 85 40 ff ff ff    	jne    800e36 <fork+0x65>
			// dup page to child
			duppage(e_id, PGNUM(addr));
		}
	}
	// alloc page for exception stack
	int r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	6a 07                	push   $0x7
  800efb:	68 00 f0 bf ee       	push   $0xeebff000
  800f00:	ff 75 dc             	pushl  -0x24(%ebp)
  800f03:	e8 20 fc ff ff       	call   800b28 <sys_page_alloc>
	if (r < 0) panic("fork: %e",r);
  800f08:	83 c4 10             	add    $0x10,%esp
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	79 15                	jns    800f24 <fork+0x153>
  800f0f:	50                   	push   %eax
  800f10:	68 e1 16 80 00       	push   $0x8016e1
  800f15:	68 85 00 00 00       	push   $0x85
  800f1a:	68 9c 16 80 00       	push   $0x80169c
  800f1f:	e8 7a 00 00 00       	call   800f9e <_panic>

	// DO NOT FORGET
	extern void _pgfault_upcall();
	r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  800f24:	83 ec 08             	sub    $0x8,%esp
  800f27:	68 58 10 80 00       	push   $0x801058
  800f2c:	ff 75 dc             	pushl  -0x24(%ebp)
  800f2f:	e8 fd fc ff ff       	call   800c31 <sys_env_set_pgfault_upcall>
	if (r < 0) panic("fork: set upcall for child fail, %e", r);
  800f34:	83 c4 10             	add    $0x10,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	79 15                	jns    800f50 <fork+0x17f>
  800f3b:	50                   	push   %eax
  800f3c:	68 78 16 80 00       	push   $0x801678
  800f41:	68 8a 00 00 00       	push   $0x8a
  800f46:	68 9c 16 80 00       	push   $0x80169c
  800f4b:	e8 4e 00 00 00       	call   800f9e <_panic>

	// mark the child environment runnable
	if ((r = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	6a 02                	push   $0x2
  800f55:	ff 75 dc             	pushl  -0x24(%ebp)
  800f58:	e8 92 fc ff ff       	call   800bef <sys_env_set_status>
  800f5d:	83 c4 10             	add    $0x10,%esp
  800f60:	85 c0                	test   %eax,%eax
  800f62:	79 15                	jns    800f79 <fork+0x1a8>
		panic("sys_env_set_status: %e", r);
  800f64:	50                   	push   %eax
  800f65:	68 f6 16 80 00       	push   $0x8016f6
  800f6a:	68 8e 00 00 00       	push   $0x8e
  800f6f:	68 9c 16 80 00       	push   $0x80169c
  800f74:	e8 25 00 00 00       	call   800f9e <_panic>

	return e_id;
  800f79:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
  800f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5e                   	pop    %esi
  800f81:	5f                   	pop    %edi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <sfork>:

// Challenge!
int
sfork(void)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f8a:	68 0d 17 80 00       	push   $0x80170d
  800f8f:	68 97 00 00 00       	push   $0x97
  800f94:	68 9c 16 80 00       	push   $0x80169c
  800f99:	e8 00 00 00 00       	call   800f9e <_panic>

00800f9e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fa3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fa6:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fac:	e8 39 fb ff ff       	call   800aea <sys_getenvid>
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	ff 75 0c             	pushl  0xc(%ebp)
  800fb7:	ff 75 08             	pushl  0x8(%ebp)
  800fba:	56                   	push   %esi
  800fbb:	50                   	push   %eax
  800fbc:	68 24 17 80 00       	push   $0x801724
  800fc1:	e8 da f1 ff ff       	call   8001a0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fc6:	83 c4 18             	add    $0x18,%esp
  800fc9:	53                   	push   %ebx
  800fca:	ff 75 10             	pushl  0x10(%ebp)
  800fcd:	e8 7d f1 ff ff       	call   80014f <vcprintf>
	cprintf("\n");
  800fd2:	c7 04 24 b4 13 80 00 	movl   $0x8013b4,(%esp)
  800fd9:	e8 c2 f1 ff ff       	call   8001a0 <cprintf>
  800fde:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fe1:	cc                   	int3   
  800fe2:	eb fd                	jmp    800fe1 <_panic+0x43>

00800fe4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800feb:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ff2:	75 57                	jne    80104b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  800ff4:	e8 f1 fa ff ff       	call   800aea <sys_getenvid>
  800ff9:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800ffb:	83 ec 04             	sub    $0x4,%esp
  800ffe:	6a 07                	push   $0x7
  801000:	68 00 f0 bf ee       	push   $0xeebff000
  801005:	50                   	push   %eax
  801006:	e8 1d fb ff ff       	call   800b28 <sys_page_alloc>
		if (r < 0) {
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	79 12                	jns    801024 <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  801012:	50                   	push   %eax
  801013:	68 48 17 80 00       	push   $0x801748
  801018:	6a 24                	push   $0x24
  80101a:	68 5c 17 80 00       	push   $0x80175c
  80101f:	e8 7a ff ff ff       	call   800f9e <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  801024:	83 ec 08             	sub    $0x8,%esp
  801027:	68 58 10 80 00       	push   $0x801058
  80102c:	53                   	push   %ebx
  80102d:	e8 ff fb ff ff       	call   800c31 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	85 c0                	test   %eax,%eax
  801037:	79 12                	jns    80104b <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  801039:	50                   	push   %eax
  80103a:	68 48 17 80 00       	push   $0x801748
  80103f:	6a 29                	push   $0x29
  801041:	68 5c 17 80 00       	push   $0x80175c
  801046:	e8 53 ff ff ff       	call   800f9e <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801053:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801058:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801059:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80105e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801060:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  801063:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  801067:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  80106a:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  80106e:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  801072:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801075:	83 c4 08             	add    $0x8,%esp
	popal
  801078:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801079:	83 c4 04             	add    $0x4,%esp
	popfl
  80107c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80107d:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80107e:	c3                   	ret    
  80107f:	90                   	nop

00801080 <__udivdi3>:
  801080:	55                   	push   %ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 1c             	sub    $0x1c,%esp
  801087:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80108b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80108f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801097:	85 f6                	test   %esi,%esi
  801099:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80109d:	89 ca                	mov    %ecx,%edx
  80109f:	89 f8                	mov    %edi,%eax
  8010a1:	75 3d                	jne    8010e0 <__udivdi3+0x60>
  8010a3:	39 cf                	cmp    %ecx,%edi
  8010a5:	0f 87 c5 00 00 00    	ja     801170 <__udivdi3+0xf0>
  8010ab:	85 ff                	test   %edi,%edi
  8010ad:	89 fd                	mov    %edi,%ebp
  8010af:	75 0b                	jne    8010bc <__udivdi3+0x3c>
  8010b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b6:	31 d2                	xor    %edx,%edx
  8010b8:	f7 f7                	div    %edi
  8010ba:	89 c5                	mov    %eax,%ebp
  8010bc:	89 c8                	mov    %ecx,%eax
  8010be:	31 d2                	xor    %edx,%edx
  8010c0:	f7 f5                	div    %ebp
  8010c2:	89 c1                	mov    %eax,%ecx
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	89 cf                	mov    %ecx,%edi
  8010c8:	f7 f5                	div    %ebp
  8010ca:	89 c3                	mov    %eax,%ebx
  8010cc:	89 d8                	mov    %ebx,%eax
  8010ce:	89 fa                	mov    %edi,%edx
  8010d0:	83 c4 1c             	add    $0x1c,%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    
  8010d8:	90                   	nop
  8010d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	39 ce                	cmp    %ecx,%esi
  8010e2:	77 74                	ja     801158 <__udivdi3+0xd8>
  8010e4:	0f bd fe             	bsr    %esi,%edi
  8010e7:	83 f7 1f             	xor    $0x1f,%edi
  8010ea:	0f 84 98 00 00 00    	je     801188 <__udivdi3+0x108>
  8010f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8010f5:	89 f9                	mov    %edi,%ecx
  8010f7:	89 c5                	mov    %eax,%ebp
  8010f9:	29 fb                	sub    %edi,%ebx
  8010fb:	d3 e6                	shl    %cl,%esi
  8010fd:	89 d9                	mov    %ebx,%ecx
  8010ff:	d3 ed                	shr    %cl,%ebp
  801101:	89 f9                	mov    %edi,%ecx
  801103:	d3 e0                	shl    %cl,%eax
  801105:	09 ee                	or     %ebp,%esi
  801107:	89 d9                	mov    %ebx,%ecx
  801109:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110d:	89 d5                	mov    %edx,%ebp
  80110f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801113:	d3 ed                	shr    %cl,%ebp
  801115:	89 f9                	mov    %edi,%ecx
  801117:	d3 e2                	shl    %cl,%edx
  801119:	89 d9                	mov    %ebx,%ecx
  80111b:	d3 e8                	shr    %cl,%eax
  80111d:	09 c2                	or     %eax,%edx
  80111f:	89 d0                	mov    %edx,%eax
  801121:	89 ea                	mov    %ebp,%edx
  801123:	f7 f6                	div    %esi
  801125:	89 d5                	mov    %edx,%ebp
  801127:	89 c3                	mov    %eax,%ebx
  801129:	f7 64 24 0c          	mull   0xc(%esp)
  80112d:	39 d5                	cmp    %edx,%ebp
  80112f:	72 10                	jb     801141 <__udivdi3+0xc1>
  801131:	8b 74 24 08          	mov    0x8(%esp),%esi
  801135:	89 f9                	mov    %edi,%ecx
  801137:	d3 e6                	shl    %cl,%esi
  801139:	39 c6                	cmp    %eax,%esi
  80113b:	73 07                	jae    801144 <__udivdi3+0xc4>
  80113d:	39 d5                	cmp    %edx,%ebp
  80113f:	75 03                	jne    801144 <__udivdi3+0xc4>
  801141:	83 eb 01             	sub    $0x1,%ebx
  801144:	31 ff                	xor    %edi,%edi
  801146:	89 d8                	mov    %ebx,%eax
  801148:	89 fa                	mov    %edi,%edx
  80114a:	83 c4 1c             	add    $0x1c,%esp
  80114d:	5b                   	pop    %ebx
  80114e:	5e                   	pop    %esi
  80114f:	5f                   	pop    %edi
  801150:	5d                   	pop    %ebp
  801151:	c3                   	ret    
  801152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801158:	31 ff                	xor    %edi,%edi
  80115a:	31 db                	xor    %ebx,%ebx
  80115c:	89 d8                	mov    %ebx,%eax
  80115e:	89 fa                	mov    %edi,%edx
  801160:	83 c4 1c             	add    $0x1c,%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    
  801168:	90                   	nop
  801169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801170:	89 d8                	mov    %ebx,%eax
  801172:	f7 f7                	div    %edi
  801174:	31 ff                	xor    %edi,%edi
  801176:	89 c3                	mov    %eax,%ebx
  801178:	89 d8                	mov    %ebx,%eax
  80117a:	89 fa                	mov    %edi,%edx
  80117c:	83 c4 1c             	add    $0x1c,%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    
  801184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801188:	39 ce                	cmp    %ecx,%esi
  80118a:	72 0c                	jb     801198 <__udivdi3+0x118>
  80118c:	31 db                	xor    %ebx,%ebx
  80118e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801192:	0f 87 34 ff ff ff    	ja     8010cc <__udivdi3+0x4c>
  801198:	bb 01 00 00 00       	mov    $0x1,%ebx
  80119d:	e9 2a ff ff ff       	jmp    8010cc <__udivdi3+0x4c>
  8011a2:	66 90                	xchg   %ax,%ax
  8011a4:	66 90                	xchg   %ax,%ax
  8011a6:	66 90                	xchg   %ax,%ax
  8011a8:	66 90                	xchg   %ax,%ax
  8011aa:	66 90                	xchg   %ax,%ax
  8011ac:	66 90                	xchg   %ax,%ax
  8011ae:	66 90                	xchg   %ax,%ax

008011b0 <__umoddi3>:
  8011b0:	55                   	push   %ebp
  8011b1:	57                   	push   %edi
  8011b2:	56                   	push   %esi
  8011b3:	53                   	push   %ebx
  8011b4:	83 ec 1c             	sub    $0x1c,%esp
  8011b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8011bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8011bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8011c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011c7:	85 d2                	test   %edx,%edx
  8011c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8011cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011d1:	89 f3                	mov    %esi,%ebx
  8011d3:	89 3c 24             	mov    %edi,(%esp)
  8011d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011da:	75 1c                	jne    8011f8 <__umoddi3+0x48>
  8011dc:	39 f7                	cmp    %esi,%edi
  8011de:	76 50                	jbe    801230 <__umoddi3+0x80>
  8011e0:	89 c8                	mov    %ecx,%eax
  8011e2:	89 f2                	mov    %esi,%edx
  8011e4:	f7 f7                	div    %edi
  8011e6:	89 d0                	mov    %edx,%eax
  8011e8:	31 d2                	xor    %edx,%edx
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    
  8011f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011f8:	39 f2                	cmp    %esi,%edx
  8011fa:	89 d0                	mov    %edx,%eax
  8011fc:	77 52                	ja     801250 <__umoddi3+0xa0>
  8011fe:	0f bd ea             	bsr    %edx,%ebp
  801201:	83 f5 1f             	xor    $0x1f,%ebp
  801204:	75 5a                	jne    801260 <__umoddi3+0xb0>
  801206:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80120a:	0f 82 e0 00 00 00    	jb     8012f0 <__umoddi3+0x140>
  801210:	39 0c 24             	cmp    %ecx,(%esp)
  801213:	0f 86 d7 00 00 00    	jbe    8012f0 <__umoddi3+0x140>
  801219:	8b 44 24 08          	mov    0x8(%esp),%eax
  80121d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801221:	83 c4 1c             	add    $0x1c,%esp
  801224:	5b                   	pop    %ebx
  801225:	5e                   	pop    %esi
  801226:	5f                   	pop    %edi
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    
  801229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801230:	85 ff                	test   %edi,%edi
  801232:	89 fd                	mov    %edi,%ebp
  801234:	75 0b                	jne    801241 <__umoddi3+0x91>
  801236:	b8 01 00 00 00       	mov    $0x1,%eax
  80123b:	31 d2                	xor    %edx,%edx
  80123d:	f7 f7                	div    %edi
  80123f:	89 c5                	mov    %eax,%ebp
  801241:	89 f0                	mov    %esi,%eax
  801243:	31 d2                	xor    %edx,%edx
  801245:	f7 f5                	div    %ebp
  801247:	89 c8                	mov    %ecx,%eax
  801249:	f7 f5                	div    %ebp
  80124b:	89 d0                	mov    %edx,%eax
  80124d:	eb 99                	jmp    8011e8 <__umoddi3+0x38>
  80124f:	90                   	nop
  801250:	89 c8                	mov    %ecx,%eax
  801252:	89 f2                	mov    %esi,%edx
  801254:	83 c4 1c             	add    $0x1c,%esp
  801257:	5b                   	pop    %ebx
  801258:	5e                   	pop    %esi
  801259:	5f                   	pop    %edi
  80125a:	5d                   	pop    %ebp
  80125b:	c3                   	ret    
  80125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801260:	8b 34 24             	mov    (%esp),%esi
  801263:	bf 20 00 00 00       	mov    $0x20,%edi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	29 ef                	sub    %ebp,%edi
  80126c:	d3 e0                	shl    %cl,%eax
  80126e:	89 f9                	mov    %edi,%ecx
  801270:	89 f2                	mov    %esi,%edx
  801272:	d3 ea                	shr    %cl,%edx
  801274:	89 e9                	mov    %ebp,%ecx
  801276:	09 c2                	or     %eax,%edx
  801278:	89 d8                	mov    %ebx,%eax
  80127a:	89 14 24             	mov    %edx,(%esp)
  80127d:	89 f2                	mov    %esi,%edx
  80127f:	d3 e2                	shl    %cl,%edx
  801281:	89 f9                	mov    %edi,%ecx
  801283:	89 54 24 04          	mov    %edx,0x4(%esp)
  801287:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80128b:	d3 e8                	shr    %cl,%eax
  80128d:	89 e9                	mov    %ebp,%ecx
  80128f:	89 c6                	mov    %eax,%esi
  801291:	d3 e3                	shl    %cl,%ebx
  801293:	89 f9                	mov    %edi,%ecx
  801295:	89 d0                	mov    %edx,%eax
  801297:	d3 e8                	shr    %cl,%eax
  801299:	89 e9                	mov    %ebp,%ecx
  80129b:	09 d8                	or     %ebx,%eax
  80129d:	89 d3                	mov    %edx,%ebx
  80129f:	89 f2                	mov    %esi,%edx
  8012a1:	f7 34 24             	divl   (%esp)
  8012a4:	89 d6                	mov    %edx,%esi
  8012a6:	d3 e3                	shl    %cl,%ebx
  8012a8:	f7 64 24 04          	mull   0x4(%esp)
  8012ac:	39 d6                	cmp    %edx,%esi
  8012ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b2:	89 d1                	mov    %edx,%ecx
  8012b4:	89 c3                	mov    %eax,%ebx
  8012b6:	72 08                	jb     8012c0 <__umoddi3+0x110>
  8012b8:	75 11                	jne    8012cb <__umoddi3+0x11b>
  8012ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8012be:	73 0b                	jae    8012cb <__umoddi3+0x11b>
  8012c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8012c4:	1b 14 24             	sbb    (%esp),%edx
  8012c7:	89 d1                	mov    %edx,%ecx
  8012c9:	89 c3                	mov    %eax,%ebx
  8012cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8012cf:	29 da                	sub    %ebx,%edx
  8012d1:	19 ce                	sbb    %ecx,%esi
  8012d3:	89 f9                	mov    %edi,%ecx
  8012d5:	89 f0                	mov    %esi,%eax
  8012d7:	d3 e0                	shl    %cl,%eax
  8012d9:	89 e9                	mov    %ebp,%ecx
  8012db:	d3 ea                	shr    %cl,%edx
  8012dd:	89 e9                	mov    %ebp,%ecx
  8012df:	d3 ee                	shr    %cl,%esi
  8012e1:	09 d0                	or     %edx,%eax
  8012e3:	89 f2                	mov    %esi,%edx
  8012e5:	83 c4 1c             	add    $0x1c,%esp
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    
  8012ed:	8d 76 00             	lea    0x0(%esi),%esi
  8012f0:	29 f9                	sub    %edi,%ecx
  8012f2:	19 d6                	sbb    %edx,%esi
  8012f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012fc:	e9 18 ff ff ff       	jmp    801219 <__umoddi3+0x69>
