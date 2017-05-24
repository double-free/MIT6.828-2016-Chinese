
obj/user/faultallocbad:     file format elf32-i386


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

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 10 80 00       	push   $0x801060
  800045:	e8 9c 01 00 00       	call   8001e6 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 10 0b 00 00       	call   800b6e <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 10 80 00       	push   $0x801080
  80006f:	6a 0f                	push   $0xf
  800071:	68 6a 10 80 00       	push   $0x80106a
  800076:	e8 92 00 00 00       	call   80010d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 10 80 00       	push   $0x8010ac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 8f 06 00 00       	call   800718 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 7c 0c 00 00       	call   800d1d <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 02 0a 00 00       	call   800ab2 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000c0:	e8 6b 0a 00 00       	call   800b30 <sys_getenvid>
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
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

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
  800103:	e8 e7 09 00 00       	call   800aef <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 10 0a 00 00       	call   800b30 <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 d8 10 80 00       	push   $0x8010d8
  800130:	e8 b1 00 00 00       	call   8001e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	pushl  0x10(%ebp)
  80013c:	e8 54 00 00 00       	call   800195 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 68 10 80 00 	movl   $0x801068,(%esp)
  800148:	e8 99 00 00 00       	call   8001e6 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	75 1a                	jne    80018c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800172:	83 ec 08             	sub    $0x8,%esp
  800175:	68 ff 00 00 00       	push   $0xff
  80017a:	8d 43 08             	lea    0x8(%ebx),%eax
  80017d:	50                   	push   %eax
  80017e:	e8 2f 09 00 00       	call   800ab2 <sys_cputs>
		b->idx = 0;
  800183:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800189:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80018c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800190:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80019e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a5:	00 00 00 
	b.cnt = 0;
  8001a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b2:	ff 75 0c             	pushl  0xc(%ebp)
  8001b5:	ff 75 08             	pushl  0x8(%ebp)
  8001b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001be:	50                   	push   %eax
  8001bf:	68 53 01 80 00       	push   $0x800153
  8001c4:	e8 54 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001c9:	83 c4 08             	add    $0x8,%esp
  8001cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001d8:	50                   	push   %eax
  8001d9:	e8 d4 08 00 00       	call   800ab2 <sys_cputs>

	return b.cnt;
}
  8001de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ef:	50                   	push   %eax
  8001f0:	ff 75 08             	pushl  0x8(%ebp)
  8001f3:	e8 9d ff ff ff       	call   800195 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fa:	55                   	push   %ebp
  8001fb:	89 e5                	mov    %esp,%ebp
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	53                   	push   %ebx
  800200:	83 ec 1c             	sub    $0x1c,%esp
  800203:	89 c7                	mov    %eax,%edi
  800205:	89 d6                	mov    %edx,%esi
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800210:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80021e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800221:	39 d3                	cmp    %edx,%ebx
  800223:	72 05                	jb     80022a <printnum+0x30>
  800225:	39 45 10             	cmp    %eax,0x10(%ebp)
  800228:	77 45                	ja     80026f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022a:	83 ec 0c             	sub    $0xc,%esp
  80022d:	ff 75 18             	pushl  0x18(%ebp)
  800230:	8b 45 14             	mov    0x14(%ebp),%eax
  800233:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800236:	53                   	push   %ebx
  800237:	ff 75 10             	pushl  0x10(%ebp)
  80023a:	83 ec 08             	sub    $0x8,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 72 0b 00 00       	call   800dc0 <__udivdi3>
  80024e:	83 c4 18             	add    $0x18,%esp
  800251:	52                   	push   %edx
  800252:	50                   	push   %eax
  800253:	89 f2                	mov    %esi,%edx
  800255:	89 f8                	mov    %edi,%eax
  800257:	e8 9e ff ff ff       	call   8001fa <printnum>
  80025c:	83 c4 20             	add    $0x20,%esp
  80025f:	eb 18                	jmp    800279 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	ff 75 18             	pushl  0x18(%ebp)
  800268:	ff d7                	call   *%edi
  80026a:	83 c4 10             	add    $0x10,%esp
  80026d:	eb 03                	jmp    800272 <printnum+0x78>
  80026f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800272:	83 eb 01             	sub    $0x1,%ebx
  800275:	85 db                	test   %ebx,%ebx
  800277:	7f e8                	jg     800261 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	56                   	push   %esi
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	ff 75 e4             	pushl  -0x1c(%ebp)
  800283:	ff 75 e0             	pushl  -0x20(%ebp)
  800286:	ff 75 dc             	pushl  -0x24(%ebp)
  800289:	ff 75 d8             	pushl  -0x28(%ebp)
  80028c:	e8 5f 0c 00 00       	call   800ef0 <__umoddi3>
  800291:	83 c4 14             	add    $0x14,%esp
  800294:	0f be 80 fc 10 80 00 	movsbl 0x8010fc(%eax),%eax
  80029b:	50                   	push   %eax
  80029c:	ff d7                	call   *%edi
}
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ac:	83 fa 01             	cmp    $0x1,%edx
  8002af:	7e 0e                	jle    8002bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b1:	8b 10                	mov    (%eax),%edx
  8002b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b6:	89 08                	mov    %ecx,(%eax)
  8002b8:	8b 02                	mov    (%edx),%eax
  8002ba:	8b 52 04             	mov    0x4(%edx),%edx
  8002bd:	eb 22                	jmp    8002e1 <getuint+0x38>
	else if (lflag)
  8002bf:	85 d2                	test   %edx,%edx
  8002c1:	74 10                	je     8002d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c3:	8b 10                	mov    (%eax),%edx
  8002c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 02                	mov    (%edx),%eax
  8002cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d1:	eb 0e                	jmp    8002e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d3:	8b 10                	mov    (%eax),%edx
  8002d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d8:	89 08                	mov    %ecx,(%eax)
  8002da:	8b 02                	mov    (%edx),%eax
  8002dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f2:	73 0a                	jae    8002fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fc:	88 02                	mov    %al,(%edx)
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800309:	50                   	push   %eax
  80030a:	ff 75 10             	pushl  0x10(%ebp)
  80030d:	ff 75 0c             	pushl  0xc(%ebp)
  800310:	ff 75 08             	pushl  0x8(%ebp)
  800313:	e8 05 00 00 00       	call   80031d <vprintfmt>
	va_end(ap);
}
  800318:	83 c4 10             	add    $0x10,%esp
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
  800326:	8b 75 08             	mov    0x8(%ebp),%esi
  800329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80032c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032f:	eb 12                	jmp    800343 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800331:	85 c0                	test   %eax,%eax
  800333:	0f 84 89 03 00 00    	je     8006c2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800339:	83 ec 08             	sub    $0x8,%esp
  80033c:	53                   	push   %ebx
  80033d:	50                   	push   %eax
  80033e:	ff d6                	call   *%esi
  800340:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800343:	83 c7 01             	add    $0x1,%edi
  800346:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80034a:	83 f8 25             	cmp    $0x25,%eax
  80034d:	75 e2                	jne    800331 <vprintfmt+0x14>
  80034f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800353:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800361:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800368:	ba 00 00 00 00       	mov    $0x0,%edx
  80036d:	eb 07                	jmp    800376 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800372:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8d 47 01             	lea    0x1(%edi),%eax
  800379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80037c:	0f b6 07             	movzbl (%edi),%eax
  80037f:	0f b6 c8             	movzbl %al,%ecx
  800382:	83 e8 23             	sub    $0x23,%eax
  800385:	3c 55                	cmp    $0x55,%al
  800387:	0f 87 1a 03 00 00    	ja     8006a7 <vprintfmt+0x38a>
  80038d:	0f b6 c0             	movzbl %al,%eax
  800390:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80039a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80039e:	eb d6                	jmp    800376 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ae:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003b2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003b5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003b8:	83 fa 09             	cmp    $0x9,%edx
  8003bb:	77 39                	ja     8003f6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c0:	eb e9                	jmp    8003ab <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8003c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003d3:	eb 27                	jmp    8003fc <vprintfmt+0xdf>
  8003d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003df:	0f 49 c8             	cmovns %eax,%ecx
  8003e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e8:	eb 8c                	jmp    800376 <vprintfmt+0x59>
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003f4:	eb 80                	jmp    800376 <vprintfmt+0x59>
  8003f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003f9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800400:	0f 89 70 ff ff ff    	jns    800376 <vprintfmt+0x59>
				width = precision, precision = -1;
  800406:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800409:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800413:	e9 5e ff ff ff       	jmp    800376 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800418:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041e:	e9 53 ff ff ff       	jmp    800376 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 50 04             	lea    0x4(%eax),%edx
  800429:	89 55 14             	mov    %edx,0x14(%ebp)
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	53                   	push   %ebx
  800430:	ff 30                	pushl  (%eax)
  800432:	ff d6                	call   *%esi
			break;
  800434:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80043a:	e9 04 ff ff ff       	jmp    800343 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	99                   	cltd   
  80044b:	31 d0                	xor    %edx,%eax
  80044d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044f:	83 f8 08             	cmp    $0x8,%eax
  800452:	7f 0b                	jg     80045f <vprintfmt+0x142>
  800454:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  80045b:	85 d2                	test   %edx,%edx
  80045d:	75 18                	jne    800477 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80045f:	50                   	push   %eax
  800460:	68 14 11 80 00       	push   $0x801114
  800465:	53                   	push   %ebx
  800466:	56                   	push   %esi
  800467:	e8 94 fe ff ff       	call   800300 <printfmt>
  80046c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800472:	e9 cc fe ff ff       	jmp    800343 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800477:	52                   	push   %edx
  800478:	68 1d 11 80 00       	push   $0x80111d
  80047d:	53                   	push   %ebx
  80047e:	56                   	push   %esi
  80047f:	e8 7c fe ff ff       	call   800300 <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048a:	e9 b4 fe ff ff       	jmp    800343 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 50 04             	lea    0x4(%eax),%edx
  800495:	89 55 14             	mov    %edx,0x14(%ebp)
  800498:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049a:	85 ff                	test   %edi,%edi
  80049c:	b8 0d 11 80 00       	mov    $0x80110d,%eax
  8004a1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a8:	0f 8e 94 00 00 00    	jle    800542 <vprintfmt+0x225>
  8004ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b2:	0f 84 98 00 00 00    	je     800550 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8004be:	57                   	push   %edi
  8004bf:	e8 86 02 00 00       	call   80074a <strnlen>
  8004c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004c7:	29 c1                	sub    %eax,%ecx
  8004c9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004d9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	eb 0f                	jmp    8004ec <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	53                   	push   %ebx
  8004e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	83 ef 01             	sub    $0x1,%edi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	7f ed                	jg     8004dd <vprintfmt+0x1c0>
  8004f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004f6:	85 c9                	test   %ecx,%ecx
  8004f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fd:	0f 49 c1             	cmovns %ecx,%eax
  800500:	29 c1                	sub    %eax,%ecx
  800502:	89 75 08             	mov    %esi,0x8(%ebp)
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800508:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050b:	89 cb                	mov    %ecx,%ebx
  80050d:	eb 4d                	jmp    80055c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800513:	74 1b                	je     800530 <vprintfmt+0x213>
  800515:	0f be c0             	movsbl %al,%eax
  800518:	83 e8 20             	sub    $0x20,%eax
  80051b:	83 f8 5e             	cmp    $0x5e,%eax
  80051e:	76 10                	jbe    800530 <vprintfmt+0x213>
					putch('?', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	ff 75 0c             	pushl  0xc(%ebp)
  800526:	6a 3f                	push   $0x3f
  800528:	ff 55 08             	call   *0x8(%ebp)
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	eb 0d                	jmp    80053d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 0c             	pushl  0xc(%ebp)
  800536:	52                   	push   %edx
  800537:	ff 55 08             	call   *0x8(%ebp)
  80053a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053d:	83 eb 01             	sub    $0x1,%ebx
  800540:	eb 1a                	jmp    80055c <vprintfmt+0x23f>
  800542:	89 75 08             	mov    %esi,0x8(%ebp)
  800545:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800548:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054e:	eb 0c                	jmp    80055c <vprintfmt+0x23f>
  800550:	89 75 08             	mov    %esi,0x8(%ebp)
  800553:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800556:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800559:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055c:	83 c7 01             	add    $0x1,%edi
  80055f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800563:	0f be d0             	movsbl %al,%edx
  800566:	85 d2                	test   %edx,%edx
  800568:	74 23                	je     80058d <vprintfmt+0x270>
  80056a:	85 f6                	test   %esi,%esi
  80056c:	78 a1                	js     80050f <vprintfmt+0x1f2>
  80056e:	83 ee 01             	sub    $0x1,%esi
  800571:	79 9c                	jns    80050f <vprintfmt+0x1f2>
  800573:	89 df                	mov    %ebx,%edi
  800575:	8b 75 08             	mov    0x8(%ebp),%esi
  800578:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057b:	eb 18                	jmp    800595 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	53                   	push   %ebx
  800581:	6a 20                	push   $0x20
  800583:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800585:	83 ef 01             	sub    $0x1,%edi
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	eb 08                	jmp    800595 <vprintfmt+0x278>
  80058d:	89 df                	mov    %ebx,%edi
  80058f:	8b 75 08             	mov    0x8(%ebp),%esi
  800592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800595:	85 ff                	test   %edi,%edi
  800597:	7f e4                	jg     80057d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059c:	e9 a2 fd ff ff       	jmp    800343 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005a1:	83 fa 01             	cmp    $0x1,%edx
  8005a4:	7e 16                	jle    8005bc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 50 08             	lea    0x8(%eax),%edx
  8005ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8005af:	8b 50 04             	mov    0x4(%eax),%edx
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ba:	eb 32                	jmp    8005ee <vprintfmt+0x2d1>
	else if (lflag)
  8005bc:	85 d2                	test   %edx,%edx
  8005be:	74 18                	je     8005d8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 00                	mov    (%eax),%eax
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	89 c1                	mov    %eax,%ecx
  8005d0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d6:	eb 16                	jmp    8005ee <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 50 04             	lea    0x4(%eax),%edx
  8005de:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	89 c1                	mov    %eax,%ecx
  8005e8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fd:	79 74                	jns    800673 <vprintfmt+0x356>
				putch('-', putdat);
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	53                   	push   %ebx
  800603:	6a 2d                	push   $0x2d
  800605:	ff d6                	call   *%esi
				num = -(long long) num;
  800607:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80060d:	f7 d8                	neg    %eax
  80060f:	83 d2 00             	adc    $0x0,%edx
  800612:	f7 da                	neg    %edx
  800614:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800617:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80061c:	eb 55                	jmp    800673 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061e:	8d 45 14             	lea    0x14(%ebp),%eax
  800621:	e8 83 fc ff ff       	call   8002a9 <getuint>
			base = 10;
  800626:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80062b:	eb 46                	jmp    800673 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80062d:	8d 45 14             	lea    0x14(%ebp),%eax
  800630:	e8 74 fc ff ff       	call   8002a9 <getuint>
			base = 8;
  800635:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80063a:	eb 37                	jmp    800673 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 30                	push   $0x30
  800642:	ff d6                	call   *%esi
			putch('x', putdat);
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 78                	push   $0x78
  80064a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80065f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800664:	eb 0d                	jmp    800673 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 3b fc ff ff       	call   8002a9 <getuint>
			base = 16;
  80066e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800673:	83 ec 0c             	sub    $0xc,%esp
  800676:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067a:	57                   	push   %edi
  80067b:	ff 75 e0             	pushl  -0x20(%ebp)
  80067e:	51                   	push   %ecx
  80067f:	52                   	push   %edx
  800680:	50                   	push   %eax
  800681:	89 da                	mov    %ebx,%edx
  800683:	89 f0                	mov    %esi,%eax
  800685:	e8 70 fb ff ff       	call   8001fa <printnum>
			break;
  80068a:	83 c4 20             	add    $0x20,%esp
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800690:	e9 ae fc ff ff       	jmp    800343 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	51                   	push   %ecx
  80069a:	ff d6                	call   *%esi
			break;
  80069c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a2:	e9 9c fc ff ff       	jmp    800343 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 25                	push   $0x25
  8006ad:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 03                	jmp    8006b7 <vprintfmt+0x39a>
  8006b4:	83 ef 01             	sub    $0x1,%edi
  8006b7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006bb:	75 f7                	jne    8006b4 <vprintfmt+0x397>
  8006bd:	e9 81 fc ff ff       	jmp    800343 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c5:	5b                   	pop    %ebx
  8006c6:	5e                   	pop    %esi
  8006c7:	5f                   	pop    %edi
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 18             	sub    $0x18,%esp
  8006d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	74 26                	je     800711 <vsnprintf+0x47>
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	7e 22                	jle    800711 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ef:	ff 75 14             	pushl  0x14(%ebp)
  8006f2:	ff 75 10             	pushl  0x10(%ebp)
  8006f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f8:	50                   	push   %eax
  8006f9:	68 e3 02 80 00       	push   $0x8002e3
  8006fe:	e8 1a fc ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800703:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800706:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070c:	83 c4 10             	add    $0x10,%esp
  80070f:	eb 05                	jmp    800716 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800721:	50                   	push   %eax
  800722:	ff 75 10             	pushl  0x10(%ebp)
  800725:	ff 75 0c             	pushl  0xc(%ebp)
  800728:	ff 75 08             	pushl  0x8(%ebp)
  80072b:	e8 9a ff ff ff       	call   8006ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800738:	b8 00 00 00 00       	mov    $0x0,%eax
  80073d:	eb 03                	jmp    800742 <strlen+0x10>
		n++;
  80073f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800742:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800746:	75 f7                	jne    80073f <strlen+0xd>
		n++;
	return n;
}
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800750:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800753:	ba 00 00 00 00       	mov    $0x0,%edx
  800758:	eb 03                	jmp    80075d <strnlen+0x13>
		n++;
  80075a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075d:	39 c2                	cmp    %eax,%edx
  80075f:	74 08                	je     800769 <strnlen+0x1f>
  800761:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800765:	75 f3                	jne    80075a <strnlen+0x10>
  800767:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	53                   	push   %ebx
  80076f:	8b 45 08             	mov    0x8(%ebp),%eax
  800772:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800775:	89 c2                	mov    %eax,%edx
  800777:	83 c2 01             	add    $0x1,%edx
  80077a:	83 c1 01             	add    $0x1,%ecx
  80077d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800781:	88 5a ff             	mov    %bl,-0x1(%edx)
  800784:	84 db                	test   %bl,%bl
  800786:	75 ef                	jne    800777 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800788:	5b                   	pop    %ebx
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	53                   	push   %ebx
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800792:	53                   	push   %ebx
  800793:	e8 9a ff ff ff       	call   800732 <strlen>
  800798:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079b:	ff 75 0c             	pushl  0xc(%ebp)
  80079e:	01 d8                	add    %ebx,%eax
  8007a0:	50                   	push   %eax
  8007a1:	e8 c5 ff ff ff       	call   80076b <strcpy>
	return dst;
}
  8007a6:	89 d8                	mov    %ebx,%eax
  8007a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    

008007ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	56                   	push   %esi
  8007b1:	53                   	push   %ebx
  8007b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b8:	89 f3                	mov    %esi,%ebx
  8007ba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	eb 0f                	jmp    8007d0 <strncpy+0x23>
		*dst++ = *src;
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	0f b6 01             	movzbl (%ecx),%eax
  8007c7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ca:	80 39 01             	cmpb   $0x1,(%ecx)
  8007cd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d0:	39 da                	cmp    %ebx,%edx
  8007d2:	75 ed                	jne    8007c1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d4:	89 f0                	mov    %esi,%eax
  8007d6:	5b                   	pop    %ebx
  8007d7:	5e                   	pop    %esi
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	74 21                	je     80080f <strlcpy+0x35>
  8007ee:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f2:	89 f2                	mov    %esi,%edx
  8007f4:	eb 09                	jmp    8007ff <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ff:	39 c2                	cmp    %eax,%edx
  800801:	74 09                	je     80080c <strlcpy+0x32>
  800803:	0f b6 19             	movzbl (%ecx),%ebx
  800806:	84 db                	test   %bl,%bl
  800808:	75 ec                	jne    8007f6 <strlcpy+0x1c>
  80080a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80080c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80080f:	29 f0                	sub    %esi,%eax
}
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081e:	eb 06                	jmp    800826 <strcmp+0x11>
		p++, q++;
  800820:	83 c1 01             	add    $0x1,%ecx
  800823:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800826:	0f b6 01             	movzbl (%ecx),%eax
  800829:	84 c0                	test   %al,%al
  80082b:	74 04                	je     800831 <strcmp+0x1c>
  80082d:	3a 02                	cmp    (%edx),%al
  80082f:	74 ef                	je     800820 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800831:	0f b6 c0             	movzbl %al,%eax
  800834:	0f b6 12             	movzbl (%edx),%edx
  800837:	29 d0                	sub    %edx,%eax
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	8b 55 0c             	mov    0xc(%ebp),%edx
  800845:	89 c3                	mov    %eax,%ebx
  800847:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strncmp+0x17>
		n--, p++, q++;
  80084c:	83 c0 01             	add    $0x1,%eax
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800852:	39 d8                	cmp    %ebx,%eax
  800854:	74 15                	je     80086b <strncmp+0x30>
  800856:	0f b6 08             	movzbl (%eax),%ecx
  800859:	84 c9                	test   %cl,%cl
  80085b:	74 04                	je     800861 <strncmp+0x26>
  80085d:	3a 0a                	cmp    (%edx),%cl
  80085f:	74 eb                	je     80084c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800861:	0f b6 00             	movzbl (%eax),%eax
  800864:	0f b6 12             	movzbl (%edx),%edx
  800867:	29 d0                	sub    %edx,%eax
  800869:	eb 05                	jmp    800870 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800870:	5b                   	pop    %ebx
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087d:	eb 07                	jmp    800886 <strchr+0x13>
		if (*s == c)
  80087f:	38 ca                	cmp    %cl,%dl
  800881:	74 0f                	je     800892 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	0f b6 10             	movzbl (%eax),%edx
  800889:	84 d2                	test   %dl,%dl
  80088b:	75 f2                	jne    80087f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80088d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 45 08             	mov    0x8(%ebp),%eax
  80089a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089e:	eb 03                	jmp    8008a3 <strfind+0xf>
  8008a0:	83 c0 01             	add    $0x1,%eax
  8008a3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 04                	je     8008ae <strfind+0x1a>
  8008aa:	84 d2                	test   %dl,%dl
  8008ac:	75 f2                	jne    8008a0 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	57                   	push   %edi
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008bc:	85 c9                	test   %ecx,%ecx
  8008be:	74 36                	je     8008f6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c6:	75 28                	jne    8008f0 <memset+0x40>
  8008c8:	f6 c1 03             	test   $0x3,%cl
  8008cb:	75 23                	jne    8008f0 <memset+0x40>
		c &= 0xFF;
  8008cd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d1:	89 d3                	mov    %edx,%ebx
  8008d3:	c1 e3 08             	shl    $0x8,%ebx
  8008d6:	89 d6                	mov    %edx,%esi
  8008d8:	c1 e6 18             	shl    $0x18,%esi
  8008db:	89 d0                	mov    %edx,%eax
  8008dd:	c1 e0 10             	shl    $0x10,%eax
  8008e0:	09 f0                	or     %esi,%eax
  8008e2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e4:	89 d8                	mov    %ebx,%eax
  8008e6:	09 d0                	or     %edx,%eax
  8008e8:	c1 e9 02             	shr    $0x2,%ecx
  8008eb:	fc                   	cld    
  8008ec:	f3 ab                	rep stos %eax,%es:(%edi)
  8008ee:	eb 06                	jmp    8008f6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f3:	fc                   	cld    
  8008f4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f6:	89 f8                	mov    %edi,%eax
  8008f8:	5b                   	pop    %ebx
  8008f9:	5e                   	pop    %esi
  8008fa:	5f                   	pop    %edi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 75 0c             	mov    0xc(%ebp),%esi
  800908:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090b:	39 c6                	cmp    %eax,%esi
  80090d:	73 35                	jae    800944 <memmove+0x47>
  80090f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800912:	39 d0                	cmp    %edx,%eax
  800914:	73 2e                	jae    800944 <memmove+0x47>
		s += n;
		d += n;
  800916:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800919:	89 d6                	mov    %edx,%esi
  80091b:	09 fe                	or     %edi,%esi
  80091d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800923:	75 13                	jne    800938 <memmove+0x3b>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 0e                	jne    800938 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80092a:	83 ef 04             	sub    $0x4,%edi
  80092d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800930:	c1 e9 02             	shr    $0x2,%ecx
  800933:	fd                   	std    
  800934:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800936:	eb 09                	jmp    800941 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800938:	83 ef 01             	sub    $0x1,%edi
  80093b:	8d 72 ff             	lea    -0x1(%edx),%esi
  80093e:	fd                   	std    
  80093f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800941:	fc                   	cld    
  800942:	eb 1d                	jmp    800961 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	89 f2                	mov    %esi,%edx
  800946:	09 c2                	or     %eax,%edx
  800948:	f6 c2 03             	test   $0x3,%dl
  80094b:	75 0f                	jne    80095c <memmove+0x5f>
  80094d:	f6 c1 03             	test   $0x3,%cl
  800950:	75 0a                	jne    80095c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800952:	c1 e9 02             	shr    $0x2,%ecx
  800955:	89 c7                	mov    %eax,%edi
  800957:	fc                   	cld    
  800958:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095a:	eb 05                	jmp    800961 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80095c:	89 c7                	mov    %eax,%edi
  80095e:	fc                   	cld    
  80095f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800968:	ff 75 10             	pushl  0x10(%ebp)
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	ff 75 08             	pushl  0x8(%ebp)
  800971:	e8 87 ff ff ff       	call   8008fd <memmove>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	56                   	push   %esi
  80097c:	53                   	push   %ebx
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
  800983:	89 c6                	mov    %eax,%esi
  800985:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800988:	eb 1a                	jmp    8009a4 <memcmp+0x2c>
		if (*s1 != *s2)
  80098a:	0f b6 08             	movzbl (%eax),%ecx
  80098d:	0f b6 1a             	movzbl (%edx),%ebx
  800990:	38 d9                	cmp    %bl,%cl
  800992:	74 0a                	je     80099e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800994:	0f b6 c1             	movzbl %cl,%eax
  800997:	0f b6 db             	movzbl %bl,%ebx
  80099a:	29 d8                	sub    %ebx,%eax
  80099c:	eb 0f                	jmp    8009ad <memcmp+0x35>
		s1++, s2++;
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a4:	39 f0                	cmp    %esi,%eax
  8009a6:	75 e2                	jne    80098a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ad:	5b                   	pop    %ebx
  8009ae:	5e                   	pop    %esi
  8009af:	5d                   	pop    %ebp
  8009b0:	c3                   	ret    

008009b1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	53                   	push   %ebx
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b8:	89 c1                	mov    %eax,%ecx
  8009ba:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c1:	eb 0a                	jmp    8009cd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c3:	0f b6 10             	movzbl (%eax),%edx
  8009c6:	39 da                	cmp    %ebx,%edx
  8009c8:	74 07                	je     8009d1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	39 c8                	cmp    %ecx,%eax
  8009cf:	72 f2                	jb     8009c3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d1:	5b                   	pop    %ebx
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	57                   	push   %edi
  8009d8:	56                   	push   %esi
  8009d9:	53                   	push   %ebx
  8009da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e0:	eb 03                	jmp    8009e5 <strtol+0x11>
		s++;
  8009e2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e5:	0f b6 01             	movzbl (%ecx),%eax
  8009e8:	3c 20                	cmp    $0x20,%al
  8009ea:	74 f6                	je     8009e2 <strtol+0xe>
  8009ec:	3c 09                	cmp    $0x9,%al
  8009ee:	74 f2                	je     8009e2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f0:	3c 2b                	cmp    $0x2b,%al
  8009f2:	75 0a                	jne    8009fe <strtol+0x2a>
		s++;
  8009f4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8009fc:	eb 11                	jmp    800a0f <strtol+0x3b>
  8009fe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a03:	3c 2d                	cmp    $0x2d,%al
  800a05:	75 08                	jne    800a0f <strtol+0x3b>
		s++, neg = 1;
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a0f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a15:	75 15                	jne    800a2c <strtol+0x58>
  800a17:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1a:	75 10                	jne    800a2c <strtol+0x58>
  800a1c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a20:	75 7c                	jne    800a9e <strtol+0xca>
		s += 2, base = 16;
  800a22:	83 c1 02             	add    $0x2,%ecx
  800a25:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2a:	eb 16                	jmp    800a42 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a2c:	85 db                	test   %ebx,%ebx
  800a2e:	75 12                	jne    800a42 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a30:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a35:	80 39 30             	cmpb   $0x30,(%ecx)
  800a38:	75 08                	jne    800a42 <strtol+0x6e>
		s++, base = 8;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a42:	b8 00 00 00 00       	mov    $0x0,%eax
  800a47:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4a:	0f b6 11             	movzbl (%ecx),%edx
  800a4d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a50:	89 f3                	mov    %esi,%ebx
  800a52:	80 fb 09             	cmp    $0x9,%bl
  800a55:	77 08                	ja     800a5f <strtol+0x8b>
			dig = *s - '0';
  800a57:	0f be d2             	movsbl %dl,%edx
  800a5a:	83 ea 30             	sub    $0x30,%edx
  800a5d:	eb 22                	jmp    800a81 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a5f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a62:	89 f3                	mov    %esi,%ebx
  800a64:	80 fb 19             	cmp    $0x19,%bl
  800a67:	77 08                	ja     800a71 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a69:	0f be d2             	movsbl %dl,%edx
  800a6c:	83 ea 57             	sub    $0x57,%edx
  800a6f:	eb 10                	jmp    800a81 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a71:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a74:	89 f3                	mov    %esi,%ebx
  800a76:	80 fb 19             	cmp    $0x19,%bl
  800a79:	77 16                	ja     800a91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a7b:	0f be d2             	movsbl %dl,%edx
  800a7e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a81:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a84:	7d 0b                	jge    800a91 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a8d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a8f:	eb b9                	jmp    800a4a <strtol+0x76>

	if (endptr)
  800a91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a95:	74 0d                	je     800aa4 <strtol+0xd0>
		*endptr = (char *) s;
  800a97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9a:	89 0e                	mov    %ecx,(%esi)
  800a9c:	eb 06                	jmp    800aa4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9e:	85 db                	test   %ebx,%ebx
  800aa0:	74 98                	je     800a3a <strtol+0x66>
  800aa2:	eb 9e                	jmp    800a42 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aa4:	89 c2                	mov    %eax,%edx
  800aa6:	f7 da                	neg    %edx
  800aa8:	85 ff                	test   %edi,%edi
  800aaa:	0f 45 c2             	cmovne %edx,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  800abd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac3:	89 c3                	mov    %eax,%ebx
  800ac5:	89 c7                	mov    %eax,%edi
  800ac7:	89 c6                	mov    %eax,%esi
  800ac9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	57                   	push   %edi
  800ad4:	56                   	push   %esi
  800ad5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad6:	ba 00 00 00 00       	mov    $0x0,%edx
  800adb:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae0:	89 d1                	mov    %edx,%ecx
  800ae2:	89 d3                	mov    %edx,%ebx
  800ae4:	89 d7                	mov    %edx,%edi
  800ae6:	89 d6                	mov    %edx,%esi
  800ae8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	53                   	push   %ebx
  800af5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800afd:	b8 03 00 00 00       	mov    $0x3,%eax
  800b02:	8b 55 08             	mov    0x8(%ebp),%edx
  800b05:	89 cb                	mov    %ecx,%ebx
  800b07:	89 cf                	mov    %ecx,%edi
  800b09:	89 ce                	mov    %ecx,%esi
  800b0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	7e 17                	jle    800b28 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b11:	83 ec 0c             	sub    $0xc,%esp
  800b14:	50                   	push   %eax
  800b15:	6a 03                	push   $0x3
  800b17:	68 44 13 80 00       	push   $0x801344
  800b1c:	6a 23                	push   $0x23
  800b1e:	68 61 13 80 00       	push   $0x801361
  800b23:	e8 e5 f5 ff ff       	call   80010d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_yield>:

void
sys_yield(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5f:	89 d1                	mov    %edx,%ecx
  800b61:	89 d3                	mov    %edx,%ebx
  800b63:	89 d7                	mov    %edx,%edi
  800b65:	89 d6                	mov    %edx,%esi
  800b67:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b69:	5b                   	pop    %ebx
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	be 00 00 00 00       	mov    $0x0,%esi
  800b7c:	b8 04 00 00 00       	mov    $0x4,%eax
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8a:	89 f7                	mov    %esi,%edi
  800b8c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7e 17                	jle    800ba9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b92:	83 ec 0c             	sub    $0xc,%esp
  800b95:	50                   	push   %eax
  800b96:	6a 04                	push   $0x4
  800b98:	68 44 13 80 00       	push   $0x801344
  800b9d:	6a 23                	push   $0x23
  800b9f:	68 61 13 80 00       	push   $0x801361
  800ba4:	e8 64 f5 ff ff       	call   80010d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bba:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	7e 17                	jle    800beb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd4:	83 ec 0c             	sub    $0xc,%esp
  800bd7:	50                   	push   %eax
  800bd8:	6a 05                	push   $0x5
  800bda:	68 44 13 80 00       	push   $0x801344
  800bdf:	6a 23                	push   $0x23
  800be1:	68 61 13 80 00       	push   $0x801361
  800be6:	e8 22 f5 ff ff       	call   80010d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	57                   	push   %edi
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c01:	b8 06 00 00 00       	mov    $0x6,%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	89 de                	mov    %ebx,%esi
  800c10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c12:	85 c0                	test   %eax,%eax
  800c14:	7e 17                	jle    800c2d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c16:	83 ec 0c             	sub    $0xc,%esp
  800c19:	50                   	push   %eax
  800c1a:	6a 06                	push   $0x6
  800c1c:	68 44 13 80 00       	push   $0x801344
  800c21:	6a 23                	push   $0x23
  800c23:	68 61 13 80 00       	push   $0x801361
  800c28:	e8 e0 f4 ff ff       	call   80010d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c43:	b8 08 00 00 00       	mov    $0x8,%eax
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4e:	89 df                	mov    %ebx,%edi
  800c50:	89 de                	mov    %ebx,%esi
  800c52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7e 17                	jle    800c6f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c58:	83 ec 0c             	sub    $0xc,%esp
  800c5b:	50                   	push   %eax
  800c5c:	6a 08                	push   $0x8
  800c5e:	68 44 13 80 00       	push   $0x801344
  800c63:	6a 23                	push   $0x23
  800c65:	68 61 13 80 00       	push   $0x801361
  800c6a:	e8 9e f4 ff ff       	call   80010d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    

00800c77 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	57                   	push   %edi
  800c7b:	56                   	push   %esi
  800c7c:	53                   	push   %ebx
  800c7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c85:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c90:	89 df                	mov    %ebx,%edi
  800c92:	89 de                	mov    %ebx,%esi
  800c94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c96:	85 c0                	test   %eax,%eax
  800c98:	7e 17                	jle    800cb1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9a:	83 ec 0c             	sub    $0xc,%esp
  800c9d:	50                   	push   %eax
  800c9e:	6a 09                	push   $0x9
  800ca0:	68 44 13 80 00       	push   $0x801344
  800ca5:	6a 23                	push   $0x23
  800ca7:	68 61 13 80 00       	push   $0x801361
  800cac:	e8 5c f4 ff ff       	call   80010d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    

00800cb9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	57                   	push   %edi
  800cbd:	56                   	push   %esi
  800cbe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbf:	be 00 00 00 00       	mov    $0x0,%esi
  800cc4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cea:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	89 cb                	mov    %ecx,%ebx
  800cf4:	89 cf                	mov    %ecx,%edi
  800cf6:	89 ce                	mov    %ecx,%esi
  800cf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfa:	85 c0                	test   %eax,%eax
  800cfc:	7e 17                	jle    800d15 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfe:	83 ec 0c             	sub    $0xc,%esp
  800d01:	50                   	push   %eax
  800d02:	6a 0c                	push   $0xc
  800d04:	68 44 13 80 00       	push   $0x801344
  800d09:	6a 23                	push   $0x23
  800d0b:	68 61 13 80 00       	push   $0x801361
  800d10:	e8 f8 f3 ff ff       	call   80010d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	53                   	push   %ebx
  800d21:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d24:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d2b:	75 57                	jne    800d84 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  800d2d:	e8 fe fd ff ff       	call   800b30 <sys_getenvid>
  800d32:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800d34:	83 ec 04             	sub    $0x4,%esp
  800d37:	6a 07                	push   $0x7
  800d39:	68 00 f0 bf ee       	push   $0xeebff000
  800d3e:	50                   	push   %eax
  800d3f:	e8 2a fe ff ff       	call   800b6e <sys_page_alloc>
		if (r < 0) {
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	85 c0                	test   %eax,%eax
  800d49:	79 12                	jns    800d5d <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  800d4b:	50                   	push   %eax
  800d4c:	68 6f 13 80 00       	push   $0x80136f
  800d51:	6a 24                	push   $0x24
  800d53:	68 83 13 80 00       	push   $0x801383
  800d58:	e8 b0 f3 ff ff       	call   80010d <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  800d5d:	83 ec 08             	sub    $0x8,%esp
  800d60:	68 91 0d 80 00       	push   $0x800d91
  800d65:	53                   	push   %ebx
  800d66:	e8 0c ff ff ff       	call   800c77 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d6b:	83 c4 10             	add    $0x10,%esp
  800d6e:	85 c0                	test   %eax,%eax
  800d70:	79 12                	jns    800d84 <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  800d72:	50                   	push   %eax
  800d73:	68 6f 13 80 00       	push   $0x80136f
  800d78:	6a 29                	push   $0x29
  800d7a:	68 83 13 80 00       	push   $0x801383
  800d7f:	e8 89 f3 ff ff       	call   80010d <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d84:	8b 45 08             	mov    0x8(%ebp),%eax
  800d87:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d8c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d91:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d92:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d97:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d99:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  800d9c:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  800da0:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  800da3:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  800da7:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  800dab:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800dae:	83 c4 08             	add    $0x8,%esp
	popal
  800db1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800db2:	83 c4 04             	add    $0x4,%esp
	popfl
  800db5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800db6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800db7:	c3                   	ret    
  800db8:	66 90                	xchg   %ax,%ax
  800dba:	66 90                	xchg   %ax,%ax
  800dbc:	66 90                	xchg   %ax,%ax
  800dbe:	66 90                	xchg   %ax,%ax

00800dc0 <__udivdi3>:
  800dc0:	55                   	push   %ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 1c             	sub    $0x1c,%esp
  800dc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800dcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800dcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800dd7:	85 f6                	test   %esi,%esi
  800dd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ddd:	89 ca                	mov    %ecx,%edx
  800ddf:	89 f8                	mov    %edi,%eax
  800de1:	75 3d                	jne    800e20 <__udivdi3+0x60>
  800de3:	39 cf                	cmp    %ecx,%edi
  800de5:	0f 87 c5 00 00 00    	ja     800eb0 <__udivdi3+0xf0>
  800deb:	85 ff                	test   %edi,%edi
  800ded:	89 fd                	mov    %edi,%ebp
  800def:	75 0b                	jne    800dfc <__udivdi3+0x3c>
  800df1:	b8 01 00 00 00       	mov    $0x1,%eax
  800df6:	31 d2                	xor    %edx,%edx
  800df8:	f7 f7                	div    %edi
  800dfa:	89 c5                	mov    %eax,%ebp
  800dfc:	89 c8                	mov    %ecx,%eax
  800dfe:	31 d2                	xor    %edx,%edx
  800e00:	f7 f5                	div    %ebp
  800e02:	89 c1                	mov    %eax,%ecx
  800e04:	89 d8                	mov    %ebx,%eax
  800e06:	89 cf                	mov    %ecx,%edi
  800e08:	f7 f5                	div    %ebp
  800e0a:	89 c3                	mov    %eax,%ebx
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	89 fa                	mov    %edi,%edx
  800e10:	83 c4 1c             	add    $0x1c,%esp
  800e13:	5b                   	pop    %ebx
  800e14:	5e                   	pop    %esi
  800e15:	5f                   	pop    %edi
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    
  800e18:	90                   	nop
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	39 ce                	cmp    %ecx,%esi
  800e22:	77 74                	ja     800e98 <__udivdi3+0xd8>
  800e24:	0f bd fe             	bsr    %esi,%edi
  800e27:	83 f7 1f             	xor    $0x1f,%edi
  800e2a:	0f 84 98 00 00 00    	je     800ec8 <__udivdi3+0x108>
  800e30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	89 c5                	mov    %eax,%ebp
  800e39:	29 fb                	sub    %edi,%ebx
  800e3b:	d3 e6                	shl    %cl,%esi
  800e3d:	89 d9                	mov    %ebx,%ecx
  800e3f:	d3 ed                	shr    %cl,%ebp
  800e41:	89 f9                	mov    %edi,%ecx
  800e43:	d3 e0                	shl    %cl,%eax
  800e45:	09 ee                	or     %ebp,%esi
  800e47:	89 d9                	mov    %ebx,%ecx
  800e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4d:	89 d5                	mov    %edx,%ebp
  800e4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e53:	d3 ed                	shr    %cl,%ebp
  800e55:	89 f9                	mov    %edi,%ecx
  800e57:	d3 e2                	shl    %cl,%edx
  800e59:	89 d9                	mov    %ebx,%ecx
  800e5b:	d3 e8                	shr    %cl,%eax
  800e5d:	09 c2                	or     %eax,%edx
  800e5f:	89 d0                	mov    %edx,%eax
  800e61:	89 ea                	mov    %ebp,%edx
  800e63:	f7 f6                	div    %esi
  800e65:	89 d5                	mov    %edx,%ebp
  800e67:	89 c3                	mov    %eax,%ebx
  800e69:	f7 64 24 0c          	mull   0xc(%esp)
  800e6d:	39 d5                	cmp    %edx,%ebp
  800e6f:	72 10                	jb     800e81 <__udivdi3+0xc1>
  800e71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e75:	89 f9                	mov    %edi,%ecx
  800e77:	d3 e6                	shl    %cl,%esi
  800e79:	39 c6                	cmp    %eax,%esi
  800e7b:	73 07                	jae    800e84 <__udivdi3+0xc4>
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	75 03                	jne    800e84 <__udivdi3+0xc4>
  800e81:	83 eb 01             	sub    $0x1,%ebx
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 d8                	mov    %ebx,%eax
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	31 ff                	xor    %edi,%edi
  800e9a:	31 db                	xor    %ebx,%ebx
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
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	f7 f7                	div    %edi
  800eb4:	31 ff                	xor    %edi,%edi
  800eb6:	89 c3                	mov    %eax,%ebx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 fa                	mov    %edi,%edx
  800ebc:	83 c4 1c             	add    $0x1c,%esp
  800ebf:	5b                   	pop    %ebx
  800ec0:	5e                   	pop    %esi
  800ec1:	5f                   	pop    %edi
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    
  800ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	39 ce                	cmp    %ecx,%esi
  800eca:	72 0c                	jb     800ed8 <__udivdi3+0x118>
  800ecc:	31 db                	xor    %ebx,%ebx
  800ece:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ed2:	0f 87 34 ff ff ff    	ja     800e0c <__udivdi3+0x4c>
  800ed8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800edd:	e9 2a ff ff ff       	jmp    800e0c <__udivdi3+0x4c>
  800ee2:	66 90                	xchg   %ax,%ax
  800ee4:	66 90                	xchg   %ax,%ax
  800ee6:	66 90                	xchg   %ax,%ax
  800ee8:	66 90                	xchg   %ax,%ax
  800eea:	66 90                	xchg   %ax,%ax
  800eec:	66 90                	xchg   %ax,%ax
  800eee:	66 90                	xchg   %ax,%ax

00800ef0 <__umoddi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	85 d2                	test   %edx,%edx
  800f09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f3                	mov    %esi,%ebx
  800f13:	89 3c 24             	mov    %edi,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	75 1c                	jne    800f38 <__umoddi3+0x48>
  800f1c:	39 f7                	cmp    %esi,%edi
  800f1e:	76 50                	jbe    800f70 <__umoddi3+0x80>
  800f20:	89 c8                	mov    %ecx,%eax
  800f22:	89 f2                	mov    %esi,%edx
  800f24:	f7 f7                	div    %edi
  800f26:	89 d0                	mov    %edx,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	83 c4 1c             	add    $0x1c,%esp
  800f2d:	5b                   	pop    %ebx
  800f2e:	5e                   	pop    %esi
  800f2f:	5f                   	pop    %edi
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    
  800f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f38:	39 f2                	cmp    %esi,%edx
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	77 52                	ja     800f90 <__umoddi3+0xa0>
  800f3e:	0f bd ea             	bsr    %edx,%ebp
  800f41:	83 f5 1f             	xor    $0x1f,%ebp
  800f44:	75 5a                	jne    800fa0 <__umoddi3+0xb0>
  800f46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f4a:	0f 82 e0 00 00 00    	jb     801030 <__umoddi3+0x140>
  800f50:	39 0c 24             	cmp    %ecx,(%esp)
  800f53:	0f 86 d7 00 00 00    	jbe    801030 <__umoddi3+0x140>
  800f59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f61:	83 c4 1c             	add    $0x1c,%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	85 ff                	test   %edi,%edi
  800f72:	89 fd                	mov    %edi,%ebp
  800f74:	75 0b                	jne    800f81 <__umoddi3+0x91>
  800f76:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	f7 f7                	div    %edi
  800f7f:	89 c5                	mov    %eax,%ebp
  800f81:	89 f0                	mov    %esi,%eax
  800f83:	31 d2                	xor    %edx,%edx
  800f85:	f7 f5                	div    %ebp
  800f87:	89 c8                	mov    %ecx,%eax
  800f89:	f7 f5                	div    %ebp
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	eb 99                	jmp    800f28 <__umoddi3+0x38>
  800f8f:	90                   	nop
  800f90:	89 c8                	mov    %ecx,%eax
  800f92:	89 f2                	mov    %esi,%edx
  800f94:	83 c4 1c             	add    $0x1c,%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    
  800f9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fa0:	8b 34 24             	mov    (%esp),%esi
  800fa3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fa8:	89 e9                	mov    %ebp,%ecx
  800faa:	29 ef                	sub    %ebp,%edi
  800fac:	d3 e0                	shl    %cl,%eax
  800fae:	89 f9                	mov    %edi,%ecx
  800fb0:	89 f2                	mov    %esi,%edx
  800fb2:	d3 ea                	shr    %cl,%edx
  800fb4:	89 e9                	mov    %ebp,%ecx
  800fb6:	09 c2                	or     %eax,%edx
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	89 14 24             	mov    %edx,(%esp)
  800fbd:	89 f2                	mov    %esi,%edx
  800fbf:	d3 e2                	shl    %cl,%edx
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	89 c6                	mov    %eax,%esi
  800fd1:	d3 e3                	shl    %cl,%ebx
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	d3 e8                	shr    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	09 d8                	or     %ebx,%eax
  800fdd:	89 d3                	mov    %edx,%ebx
  800fdf:	89 f2                	mov    %esi,%edx
  800fe1:	f7 34 24             	divl   (%esp)
  800fe4:	89 d6                	mov    %edx,%esi
  800fe6:	d3 e3                	shl    %cl,%ebx
  800fe8:	f7 64 24 04          	mull   0x4(%esp)
  800fec:	39 d6                	cmp    %edx,%esi
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	89 d1                	mov    %edx,%ecx
  800ff4:	89 c3                	mov    %eax,%ebx
  800ff6:	72 08                	jb     801000 <__umoddi3+0x110>
  800ff8:	75 11                	jne    80100b <__umoddi3+0x11b>
  800ffa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800ffe:	73 0b                	jae    80100b <__umoddi3+0x11b>
  801000:	2b 44 24 04          	sub    0x4(%esp),%eax
  801004:	1b 14 24             	sbb    (%esp),%edx
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 c3                	mov    %eax,%ebx
  80100b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80100f:	29 da                	sub    %ebx,%edx
  801011:	19 ce                	sbb    %ecx,%esi
  801013:	89 f9                	mov    %edi,%ecx
  801015:	89 f0                	mov    %esi,%eax
  801017:	d3 e0                	shl    %cl,%eax
  801019:	89 e9                	mov    %ebp,%ecx
  80101b:	d3 ea                	shr    %cl,%edx
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	d3 ee                	shr    %cl,%esi
  801021:	09 d0                	or     %edx,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	83 c4 1c             	add    $0x1c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	29 f9                	sub    %edi,%ecx
  801032:	19 d6                	sbb    %edx,%esi
  801034:	89 74 24 04          	mov    %esi,0x4(%esp)
  801038:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103c:	e9 18 ff ff ff       	jmp    800f59 <__umoddi3+0x69>
