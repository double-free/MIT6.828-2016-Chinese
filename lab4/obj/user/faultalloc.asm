
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
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
  800045:	e8 b1 01 00 00       	call   8001fb <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 25 0b 00 00       	call   800b83 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 80 10 80 00       	push   $0x801080
  80006f:	6a 0e                	push   $0xe
  800071:	68 6a 10 80 00       	push   $0x80106a
  800076:	e8 a7 00 00 00       	call   800122 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 ac 10 80 00       	push   $0x8010ac
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 a4 06 00 00       	call   80072d <snprintf>
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
  80009c:	e8 91 0c 00 00       	call   800d32 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 10 80 00       	push   $0x80107c
  8000ae:	e8 48 01 00 00       	call   8001fb <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 10 80 00       	push   $0x80107c
  8000c0:	e8 36 01 00 00       	call   8001fb <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 6b 0a 00 00       	call   800b45 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 e7 09 00 00       	call   800b04 <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 10 0a 00 00       	call   800b45 <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 d8 10 80 00       	push   $0x8010d8
  800145:	e8 b1 00 00 00       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	pushl  0x10(%ebp)
  800151:	e8 54 00 00 00       	call   8001aa <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 7e 10 80 00 	movl   $0x80107e,(%esp)
  80015d:	e8 99 00 00 00       	call   8001fb <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	75 1a                	jne    8001a1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800187:	83 ec 08             	sub    $0x8,%esp
  80018a:	68 ff 00 00 00       	push   $0xff
  80018f:	8d 43 08             	lea    0x8(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 2f 09 00 00       	call   800ac7 <sys_cputs>
		b->idx = 0;
  800198:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a8:	c9                   	leave  
  8001a9:	c3                   	ret    

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ca:	ff 75 08             	pushl  0x8(%ebp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	50                   	push   %eax
  8001d4:	68 68 01 80 00       	push   $0x800168
  8001d9:	e8 54 01 00 00       	call   800332 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	83 c4 08             	add    $0x8,%esp
  8001e1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 d4 08 00 00       	call   800ac7 <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	50                   	push   %eax
  800205:	ff 75 08             	pushl  0x8(%ebp)
  800208:	e8 9d ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 1c             	sub    $0x1c,%esp
  800218:	89 c7                	mov    %eax,%edi
  80021a:	89 d6                	mov    %edx,%esi
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800222:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800225:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800228:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800233:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800236:	39 d3                	cmp    %edx,%ebx
  800238:	72 05                	jb     80023f <printnum+0x30>
  80023a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023d:	77 45                	ja     800284 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	ff 75 18             	pushl  0x18(%ebp)
  800245:	8b 45 14             	mov    0x14(%ebp),%eax
  800248:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024b:	53                   	push   %ebx
  80024c:	ff 75 10             	pushl  0x10(%ebp)
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	ff 75 e4             	pushl  -0x1c(%ebp)
  800255:	ff 75 e0             	pushl  -0x20(%ebp)
  800258:	ff 75 dc             	pushl  -0x24(%ebp)
  80025b:	ff 75 d8             	pushl  -0x28(%ebp)
  80025e:	e8 6d 0b 00 00       	call   800dd0 <__udivdi3>
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	52                   	push   %edx
  800267:	50                   	push   %eax
  800268:	89 f2                	mov    %esi,%edx
  80026a:	89 f8                	mov    %edi,%eax
  80026c:	e8 9e ff ff ff       	call   80020f <printnum>
  800271:	83 c4 20             	add    $0x20,%esp
  800274:	eb 18                	jmp    80028e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	ff 75 18             	pushl  0x18(%ebp)
  80027d:	ff d7                	call   *%edi
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	eb 03                	jmp    800287 <printnum+0x78>
  800284:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800287:	83 eb 01             	sub    $0x1,%ebx
  80028a:	85 db                	test   %ebx,%ebx
  80028c:	7f e8                	jg     800276 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	83 ec 04             	sub    $0x4,%esp
  800295:	ff 75 e4             	pushl  -0x1c(%ebp)
  800298:	ff 75 e0             	pushl  -0x20(%ebp)
  80029b:	ff 75 dc             	pushl  -0x24(%ebp)
  80029e:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a1:	e8 5a 0c 00 00       	call   800f00 <__umoddi3>
  8002a6:	83 c4 14             	add    $0x14,%esp
  8002a9:	0f be 80 fc 10 80 00 	movsbl 0x8010fc(%eax),%eax
  8002b0:	50                   	push   %eax
  8002b1:	ff d7                	call   *%edi
}
  8002b3:	83 c4 10             	add    $0x10,%esp
  8002b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b9:	5b                   	pop    %ebx
  8002ba:	5e                   	pop    %esi
  8002bb:	5f                   	pop    %edi
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c1:	83 fa 01             	cmp    $0x1,%edx
  8002c4:	7e 0e                	jle    8002d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002cb:	89 08                	mov    %ecx,(%eax)
  8002cd:	8b 02                	mov    (%edx),%eax
  8002cf:	8b 52 04             	mov    0x4(%edx),%edx
  8002d2:	eb 22                	jmp    8002f6 <getuint+0x38>
	else if (lflag)
  8002d4:	85 d2                	test   %edx,%edx
  8002d6:	74 10                	je     8002e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d8:	8b 10                	mov    (%eax),%edx
  8002da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002dd:	89 08                	mov    %ecx,(%eax)
  8002df:	8b 02                	mov    (%edx),%eax
  8002e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e6:	eb 0e                	jmp    8002f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002ed:	89 08                	mov    %ecx,(%eax)
  8002ef:	8b 02                	mov    (%edx),%eax
  8002f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800302:	8b 10                	mov    (%eax),%edx
  800304:	3b 50 04             	cmp    0x4(%eax),%edx
  800307:	73 0a                	jae    800313 <sprintputch+0x1b>
		*b->buf++ = ch;
  800309:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030c:	89 08                	mov    %ecx,(%eax)
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	88 02                	mov    %al,(%edx)
}
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    

00800315 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80031b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031e:	50                   	push   %eax
  80031f:	ff 75 10             	pushl  0x10(%ebp)
  800322:	ff 75 0c             	pushl  0xc(%ebp)
  800325:	ff 75 08             	pushl  0x8(%ebp)
  800328:	e8 05 00 00 00       	call   800332 <vprintfmt>
	va_end(ap);
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
  800338:	83 ec 2c             	sub    $0x2c,%esp
  80033b:	8b 75 08             	mov    0x8(%ebp),%esi
  80033e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800341:	8b 7d 10             	mov    0x10(%ebp),%edi
  800344:	eb 12                	jmp    800358 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800346:	85 c0                	test   %eax,%eax
  800348:	0f 84 89 03 00 00    	je     8006d7 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	53                   	push   %ebx
  800352:	50                   	push   %eax
  800353:	ff d6                	call   *%esi
  800355:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800358:	83 c7 01             	add    $0x1,%edi
  80035b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035f:	83 f8 25             	cmp    $0x25,%eax
  800362:	75 e2                	jne    800346 <vprintfmt+0x14>
  800364:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800368:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800376:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80037d:	ba 00 00 00 00       	mov    $0x0,%edx
  800382:	eb 07                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800387:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8d 47 01             	lea    0x1(%edi),%eax
  80038e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800391:	0f b6 07             	movzbl (%edi),%eax
  800394:	0f b6 c8             	movzbl %al,%ecx
  800397:	83 e8 23             	sub    $0x23,%eax
  80039a:	3c 55                	cmp    $0x55,%al
  80039c:	0f 87 1a 03 00 00    	ja     8006bc <vprintfmt+0x38a>
  8003a2:	0f b6 c0             	movzbl %al,%eax
  8003a5:	ff 24 85 c0 11 80 00 	jmp    *0x8011c0(,%eax,4)
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003b3:	eb d6                	jmp    80038b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003c3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003c7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ca:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003cd:	83 fa 09             	cmp    $0x9,%edx
  8003d0:	77 39                	ja     80040b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e8:	eb 27                	jmp    800411 <vprintfmt+0xdf>
  8003ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ed:	85 c0                	test   %eax,%eax
  8003ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f4:	0f 49 c8             	cmovns %eax,%ecx
  8003f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fd:	eb 8c                	jmp    80038b <vprintfmt+0x59>
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800402:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800409:	eb 80                	jmp    80038b <vprintfmt+0x59>
  80040b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80040e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800411:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800415:	0f 89 70 ff ff ff    	jns    80038b <vprintfmt+0x59>
				width = precision, precision = -1;
  80041b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80041e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800421:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800428:	e9 5e ff ff ff       	jmp    80038b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800430:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800433:	e9 53 ff ff ff       	jmp    80038b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	53                   	push   %ebx
  800445:	ff 30                	pushl  (%eax)
  800447:	ff d6                	call   *%esi
			break;
  800449:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80044f:	e9 04 ff ff ff       	jmp    800358 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800454:	8b 45 14             	mov    0x14(%ebp),%eax
  800457:	8d 50 04             	lea    0x4(%eax),%edx
  80045a:	89 55 14             	mov    %edx,0x14(%ebp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	99                   	cltd   
  800460:	31 d0                	xor    %edx,%eax
  800462:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800464:	83 f8 08             	cmp    $0x8,%eax
  800467:	7f 0b                	jg     800474 <vprintfmt+0x142>
  800469:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	75 18                	jne    80048c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800474:	50                   	push   %eax
  800475:	68 14 11 80 00       	push   $0x801114
  80047a:	53                   	push   %ebx
  80047b:	56                   	push   %esi
  80047c:	e8 94 fe ff ff       	call   800315 <printfmt>
  800481:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800487:	e9 cc fe ff ff       	jmp    800358 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048c:	52                   	push   %edx
  80048d:	68 1d 11 80 00       	push   $0x80111d
  800492:	53                   	push   %ebx
  800493:	56                   	push   %esi
  800494:	e8 7c fe ff ff       	call   800315 <printfmt>
  800499:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80049f:	e9 b4 fe ff ff       	jmp    800358 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8d 50 04             	lea    0x4(%eax),%edx
  8004aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ad:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004af:	85 ff                	test   %edi,%edi
  8004b1:	b8 0d 11 80 00       	mov    $0x80110d,%eax
  8004b6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004bd:	0f 8e 94 00 00 00    	jle    800557 <vprintfmt+0x225>
  8004c3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c7:	0f 84 98 00 00 00    	je     800565 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d3:	57                   	push   %edi
  8004d4:	e8 86 02 00 00       	call   80075f <strnlen>
  8004d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004dc:	29 c1                	sub    %eax,%ecx
  8004de:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004eb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004ee:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f0:	eb 0f                	jmp    800501 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f9:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fb:	83 ef 01             	sub    $0x1,%edi
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 ff                	test   %edi,%edi
  800503:	7f ed                	jg     8004f2 <vprintfmt+0x1c0>
  800505:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800508:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80050b:	85 c9                	test   %ecx,%ecx
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	0f 49 c1             	cmovns %ecx,%eax
  800515:	29 c1                	sub    %eax,%ecx
  800517:	89 75 08             	mov    %esi,0x8(%ebp)
  80051a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800520:	89 cb                	mov    %ecx,%ebx
  800522:	eb 4d                	jmp    800571 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800524:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800528:	74 1b                	je     800545 <vprintfmt+0x213>
  80052a:	0f be c0             	movsbl %al,%eax
  80052d:	83 e8 20             	sub    $0x20,%eax
  800530:	83 f8 5e             	cmp    $0x5e,%eax
  800533:	76 10                	jbe    800545 <vprintfmt+0x213>
					putch('?', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	6a 3f                	push   $0x3f
  80053d:	ff 55 08             	call   *0x8(%ebp)
  800540:	83 c4 10             	add    $0x10,%esp
  800543:	eb 0d                	jmp    800552 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	ff 75 0c             	pushl  0xc(%ebp)
  80054b:	52                   	push   %edx
  80054c:	ff 55 08             	call   *0x8(%ebp)
  80054f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	83 eb 01             	sub    $0x1,%ebx
  800555:	eb 1a                	jmp    800571 <vprintfmt+0x23f>
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800563:	eb 0c                	jmp    800571 <vprintfmt+0x23f>
  800565:	89 75 08             	mov    %esi,0x8(%ebp)
  800568:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80056b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800571:	83 c7 01             	add    $0x1,%edi
  800574:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800578:	0f be d0             	movsbl %al,%edx
  80057b:	85 d2                	test   %edx,%edx
  80057d:	74 23                	je     8005a2 <vprintfmt+0x270>
  80057f:	85 f6                	test   %esi,%esi
  800581:	78 a1                	js     800524 <vprintfmt+0x1f2>
  800583:	83 ee 01             	sub    $0x1,%esi
  800586:	79 9c                	jns    800524 <vprintfmt+0x1f2>
  800588:	89 df                	mov    %ebx,%edi
  80058a:	8b 75 08             	mov    0x8(%ebp),%esi
  80058d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800590:	eb 18                	jmp    8005aa <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 20                	push   $0x20
  800598:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059a:	83 ef 01             	sub    $0x1,%edi
  80059d:	83 c4 10             	add    $0x10,%esp
  8005a0:	eb 08                	jmp    8005aa <vprintfmt+0x278>
  8005a2:	89 df                	mov    %ebx,%edi
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005aa:	85 ff                	test   %edi,%edi
  8005ac:	7f e4                	jg     800592 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	e9 a2 fd ff ff       	jmp    800358 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b6:	83 fa 01             	cmp    $0x1,%edx
  8005b9:	7e 16                	jle    8005d1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 08             	lea    0x8(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 50 04             	mov    0x4(%eax),%edx
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cf:	eb 32                	jmp    800603 <vprintfmt+0x2d1>
	else if (lflag)
  8005d1:	85 d2                	test   %edx,%edx
  8005d3:	74 18                	je     8005ed <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 50 04             	lea    0x4(%eax),%edx
  8005db:	89 55 14             	mov    %edx,0x14(%ebp)
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	eb 16                	jmp    800603 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8d 50 04             	lea    0x4(%eax),%edx
  8005f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fb:	89 c1                	mov    %eax,%ecx
  8005fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800600:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800603:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800606:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800609:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800612:	79 74                	jns    800688 <vprintfmt+0x356>
				putch('-', putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 2d                	push   $0x2d
  80061a:	ff d6                	call   *%esi
				num = -(long long) num;
  80061c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800622:	f7 d8                	neg    %eax
  800624:	83 d2 00             	adc    $0x0,%edx
  800627:	f7 da                	neg    %edx
  800629:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800631:	eb 55                	jmp    800688 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 83 fc ff ff       	call   8002be <getuint>
			base = 10;
  80063b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800640:	eb 46                	jmp    800688 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800642:	8d 45 14             	lea    0x14(%ebp),%eax
  800645:	e8 74 fc ff ff       	call   8002be <getuint>
			base = 8;
  80064a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80064f:	eb 37                	jmp    800688 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 30                	push   $0x30
  800657:	ff d6                	call   *%esi
			putch('x', putdat);
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 78                	push   $0x78
  80065f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 50 04             	lea    0x4(%eax),%edx
  800667:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80066a:	8b 00                	mov    (%eax),%eax
  80066c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800671:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800674:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800679:	eb 0d                	jmp    800688 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 3b fc ff ff       	call   8002be <getuint>
			base = 16;
  800683:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	83 ec 0c             	sub    $0xc,%esp
  80068b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80068f:	57                   	push   %edi
  800690:	ff 75 e0             	pushl  -0x20(%ebp)
  800693:	51                   	push   %ecx
  800694:	52                   	push   %edx
  800695:	50                   	push   %eax
  800696:	89 da                	mov    %ebx,%edx
  800698:	89 f0                	mov    %esi,%eax
  80069a:	e8 70 fb ff ff       	call   80020f <printnum>
			break;
  80069f:	83 c4 20             	add    $0x20,%esp
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a5:	e9 ae fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	53                   	push   %ebx
  8006ae:	51                   	push   %ecx
  8006af:	ff d6                	call   *%esi
			break;
  8006b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b7:	e9 9c fc ff ff       	jmp    800358 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	53                   	push   %ebx
  8006c0:	6a 25                	push   $0x25
  8006c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	eb 03                	jmp    8006cc <vprintfmt+0x39a>
  8006c9:	83 ef 01             	sub    $0x1,%edi
  8006cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006d0:	75 f7                	jne    8006c9 <vprintfmt+0x397>
  8006d2:	e9 81 fc ff ff       	jmp    800358 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006da:	5b                   	pop    %ebx
  8006db:	5e                   	pop    %esi
  8006dc:	5f                   	pop    %edi
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	83 ec 18             	sub    $0x18,%esp
  8006e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	74 26                	je     800726 <vsnprintf+0x47>
  800700:	85 d2                	test   %edx,%edx
  800702:	7e 22                	jle    800726 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800704:	ff 75 14             	pushl  0x14(%ebp)
  800707:	ff 75 10             	pushl  0x10(%ebp)
  80070a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	68 f8 02 80 00       	push   $0x8002f8
  800713:	e8 1a fc ff ff       	call   800332 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800718:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	eb 05                	jmp    80072b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800726:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80072b:	c9                   	leave  
  80072c:	c3                   	ret    

0080072d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800736:	50                   	push   %eax
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	ff 75 08             	pushl  0x8(%ebp)
  800740:	e8 9a ff ff ff       	call   8006df <vsnprintf>
	va_end(ap);

	return rc;
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	eb 03                	jmp    800757 <strlen+0x10>
		n++;
  800754:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800757:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075b:	75 f7                	jne    800754 <strlen+0xd>
		n++;
	return n;
}
  80075d:	5d                   	pop    %ebp
  80075e:	c3                   	ret    

0080075f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800765:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800768:	ba 00 00 00 00       	mov    $0x0,%edx
  80076d:	eb 03                	jmp    800772 <strnlen+0x13>
		n++;
  80076f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800772:	39 c2                	cmp    %eax,%edx
  800774:	74 08                	je     80077e <strnlen+0x1f>
  800776:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80077a:	75 f3                	jne    80076f <strnlen+0x10>
  80077c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80078a:	89 c2                	mov    %eax,%edx
  80078c:	83 c2 01             	add    $0x1,%edx
  80078f:	83 c1 01             	add    $0x1,%ecx
  800792:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800796:	88 5a ff             	mov    %bl,-0x1(%edx)
  800799:	84 db                	test   %bl,%bl
  80079b:	75 ef                	jne    80078c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	53                   	push   %ebx
  8007a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a7:	53                   	push   %ebx
  8007a8:	e8 9a ff ff ff       	call   800747 <strlen>
  8007ad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007b0:	ff 75 0c             	pushl  0xc(%ebp)
  8007b3:	01 d8                	add    %ebx,%eax
  8007b5:	50                   	push   %eax
  8007b6:	e8 c5 ff ff ff       	call   800780 <strcpy>
	return dst;
}
  8007bb:	89 d8                	mov    %ebx,%eax
  8007bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	56                   	push   %esi
  8007c6:	53                   	push   %ebx
  8007c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cd:	89 f3                	mov    %esi,%ebx
  8007cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	eb 0f                	jmp    8007e5 <strncpy+0x23>
		*dst++ = *src;
  8007d6:	83 c2 01             	add    $0x1,%edx
  8007d9:	0f b6 01             	movzbl (%ecx),%eax
  8007dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007df:	80 39 01             	cmpb   $0x1,(%ecx)
  8007e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e5:	39 da                	cmp    %ebx,%edx
  8007e7:	75 ed                	jne    8007d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ff:	85 d2                	test   %edx,%edx
  800801:	74 21                	je     800824 <strlcpy+0x35>
  800803:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 09                	jmp    800814 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800814:	39 c2                	cmp    %eax,%edx
  800816:	74 09                	je     800821 <strlcpy+0x32>
  800818:	0f b6 19             	movzbl (%ecx),%ebx
  80081b:	84 db                	test   %bl,%bl
  80081d:	75 ec                	jne    80080b <strlcpy+0x1c>
  80081f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800821:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800824:	29 f0                	sub    %esi,%eax
}
  800826:	5b                   	pop    %ebx
  800827:	5e                   	pop    %esi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800830:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800833:	eb 06                	jmp    80083b <strcmp+0x11>
		p++, q++;
  800835:	83 c1 01             	add    $0x1,%ecx
  800838:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80083b:	0f b6 01             	movzbl (%ecx),%eax
  80083e:	84 c0                	test   %al,%al
  800840:	74 04                	je     800846 <strcmp+0x1c>
  800842:	3a 02                	cmp    (%edx),%al
  800844:	74 ef                	je     800835 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800846:	0f b6 c0             	movzbl %al,%eax
  800849:	0f b6 12             	movzbl (%edx),%edx
  80084c:	29 d0                	sub    %edx,%eax
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strncmp+0x17>
		n--, p++, q++;
  800861:	83 c0 01             	add    $0x1,%eax
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800867:	39 d8                	cmp    %ebx,%eax
  800869:	74 15                	je     800880 <strncmp+0x30>
  80086b:	0f b6 08             	movzbl (%eax),%ecx
  80086e:	84 c9                	test   %cl,%cl
  800870:	74 04                	je     800876 <strncmp+0x26>
  800872:	3a 0a                	cmp    (%edx),%cl
  800874:	74 eb                	je     800861 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800876:	0f b6 00             	movzbl (%eax),%eax
  800879:	0f b6 12             	movzbl (%edx),%edx
  80087c:	29 d0                	sub    %edx,%eax
  80087e:	eb 05                	jmp    800885 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800880:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800885:	5b                   	pop    %ebx
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800892:	eb 07                	jmp    80089b <strchr+0x13>
		if (*s == c)
  800894:	38 ca                	cmp    %cl,%dl
  800896:	74 0f                	je     8008a7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800898:	83 c0 01             	add    $0x1,%eax
  80089b:	0f b6 10             	movzbl (%eax),%edx
  80089e:	84 d2                	test   %dl,%dl
  8008a0:	75 f2                	jne    800894 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b3:	eb 03                	jmp    8008b8 <strfind+0xf>
  8008b5:	83 c0 01             	add    $0x1,%eax
  8008b8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 04                	je     8008c3 <strfind+0x1a>
  8008bf:	84 d2                	test   %dl,%dl
  8008c1:	75 f2                	jne    8008b5 <strfind+0xc>
			break;
	return (char *) s;
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	57                   	push   %edi
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d1:	85 c9                	test   %ecx,%ecx
  8008d3:	74 36                	je     80090b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008db:	75 28                	jne    800905 <memset+0x40>
  8008dd:	f6 c1 03             	test   $0x3,%cl
  8008e0:	75 23                	jne    800905 <memset+0x40>
		c &= 0xFF;
  8008e2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e6:	89 d3                	mov    %edx,%ebx
  8008e8:	c1 e3 08             	shl    $0x8,%ebx
  8008eb:	89 d6                	mov    %edx,%esi
  8008ed:	c1 e6 18             	shl    $0x18,%esi
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	c1 e0 10             	shl    $0x10,%eax
  8008f5:	09 f0                	or     %esi,%eax
  8008f7:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f9:	89 d8                	mov    %ebx,%eax
  8008fb:	09 d0                	or     %edx,%eax
  8008fd:	c1 e9 02             	shr    $0x2,%ecx
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 06                	jmp    80090b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	fc                   	cld    
  800909:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800920:	39 c6                	cmp    %eax,%esi
  800922:	73 35                	jae    800959 <memmove+0x47>
  800924:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800927:	39 d0                	cmp    %edx,%eax
  800929:	73 2e                	jae    800959 <memmove+0x47>
		s += n;
		d += n;
  80092b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 d6                	mov    %edx,%esi
  800930:	09 fe                	or     %edi,%esi
  800932:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800938:	75 13                	jne    80094d <memmove+0x3b>
  80093a:	f6 c1 03             	test   $0x3,%cl
  80093d:	75 0e                	jne    80094d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80093f:	83 ef 04             	sub    $0x4,%edi
  800942:	8d 72 fc             	lea    -0x4(%edx),%esi
  800945:	c1 e9 02             	shr    $0x2,%ecx
  800948:	fd                   	std    
  800949:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094b:	eb 09                	jmp    800956 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80094d:	83 ef 01             	sub    $0x1,%edi
  800950:	8d 72 ff             	lea    -0x1(%edx),%esi
  800953:	fd                   	std    
  800954:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800956:	fc                   	cld    
  800957:	eb 1d                	jmp    800976 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800959:	89 f2                	mov    %esi,%edx
  80095b:	09 c2                	or     %eax,%edx
  80095d:	f6 c2 03             	test   $0x3,%dl
  800960:	75 0f                	jne    800971 <memmove+0x5f>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0a                	jne    800971 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800967:	c1 e9 02             	shr    $0x2,%ecx
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096f:	eb 05                	jmp    800976 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80097d:	ff 75 10             	pushl  0x10(%ebp)
  800980:	ff 75 0c             	pushl  0xc(%ebp)
  800983:	ff 75 08             	pushl  0x8(%ebp)
  800986:	e8 87 ff ff ff       	call   800912 <memmove>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
  800998:	89 c6                	mov    %eax,%esi
  80099a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099d:	eb 1a                	jmp    8009b9 <memcmp+0x2c>
		if (*s1 != *s2)
  80099f:	0f b6 08             	movzbl (%eax),%ecx
  8009a2:	0f b6 1a             	movzbl (%edx),%ebx
  8009a5:	38 d9                	cmp    %bl,%cl
  8009a7:	74 0a                	je     8009b3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a9:	0f b6 c1             	movzbl %cl,%eax
  8009ac:	0f b6 db             	movzbl %bl,%ebx
  8009af:	29 d8                	sub    %ebx,%eax
  8009b1:	eb 0f                	jmp    8009c2 <memcmp+0x35>
		s1++, s2++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b9:	39 f0                	cmp    %esi,%eax
  8009bb:	75 e2                	jne    80099f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009cd:	89 c1                	mov    %eax,%ecx
  8009cf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	eb 0a                	jmp    8009e2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009d8:	0f b6 10             	movzbl (%eax),%edx
  8009db:	39 da                	cmp    %ebx,%edx
  8009dd:	74 07                	je     8009e6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	39 c8                	cmp    %ecx,%eax
  8009e4:	72 f2                	jb     8009d8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	57                   	push   %edi
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f5:	eb 03                	jmp    8009fa <strtol+0x11>
		s++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fa:	0f b6 01             	movzbl (%ecx),%eax
  8009fd:	3c 20                	cmp    $0x20,%al
  8009ff:	74 f6                	je     8009f7 <strtol+0xe>
  800a01:	3c 09                	cmp    $0x9,%al
  800a03:	74 f2                	je     8009f7 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a05:	3c 2b                	cmp    $0x2b,%al
  800a07:	75 0a                	jne    800a13 <strtol+0x2a>
		s++;
  800a09:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a11:	eb 11                	jmp    800a24 <strtol+0x3b>
  800a13:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a18:	3c 2d                	cmp    $0x2d,%al
  800a1a:	75 08                	jne    800a24 <strtol+0x3b>
		s++, neg = 1;
  800a1c:	83 c1 01             	add    $0x1,%ecx
  800a1f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a24:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a2a:	75 15                	jne    800a41 <strtol+0x58>
  800a2c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2f:	75 10                	jne    800a41 <strtol+0x58>
  800a31:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a35:	75 7c                	jne    800ab3 <strtol+0xca>
		s += 2, base = 16;
  800a37:	83 c1 02             	add    $0x2,%ecx
  800a3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a3f:	eb 16                	jmp    800a57 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	75 12                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a45:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a4d:	75 08                	jne    800a57 <strtol+0x6e>
		s++, base = 8;
  800a4f:	83 c1 01             	add    $0x1,%ecx
  800a52:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a57:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a5f:	0f b6 11             	movzbl (%ecx),%edx
  800a62:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a65:	89 f3                	mov    %esi,%ebx
  800a67:	80 fb 09             	cmp    $0x9,%bl
  800a6a:	77 08                	ja     800a74 <strtol+0x8b>
			dig = *s - '0';
  800a6c:	0f be d2             	movsbl %dl,%edx
  800a6f:	83 ea 30             	sub    $0x30,%edx
  800a72:	eb 22                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a74:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	80 fb 19             	cmp    $0x19,%bl
  800a7c:	77 08                	ja     800a86 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a7e:	0f be d2             	movsbl %dl,%edx
  800a81:	83 ea 57             	sub    $0x57,%edx
  800a84:	eb 10                	jmp    800a96 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a86:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a89:	89 f3                	mov    %esi,%ebx
  800a8b:	80 fb 19             	cmp    $0x19,%bl
  800a8e:	77 16                	ja     800aa6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 0b                	jge    800aa6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aa4:	eb b9                	jmp    800a5f <strtol+0x76>

	if (endptr)
  800aa6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aaa:	74 0d                	je     800ab9 <strtol+0xd0>
		*endptr = (char *) s;
  800aac:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aaf:	89 0e                	mov    %ecx,(%esi)
  800ab1:	eb 06                	jmp    800ab9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	74 98                	je     800a4f <strtol+0x66>
  800ab7:	eb 9e                	jmp    800a57 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab9:	89 c2                	mov    %eax,%edx
  800abb:	f7 da                	neg    %edx
  800abd:	85 ff                	test   %edi,%edi
  800abf:	0f 45 c2             	cmovne %edx,%eax
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad8:	89 c3                	mov    %eax,%ebx
  800ada:	89 c7                	mov    %eax,%edi
  800adc:	89 c6                	mov    %eax,%esi
  800ade:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	57                   	push   %edi
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800af0:	b8 01 00 00 00       	mov    $0x1,%eax
  800af5:	89 d1                	mov    %edx,%ecx
  800af7:	89 d3                	mov    %edx,%ebx
  800af9:	89 d7                	mov    %edx,%edi
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b12:	b8 03 00 00 00       	mov    $0x3,%eax
  800b17:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1a:	89 cb                	mov    %ecx,%ebx
  800b1c:	89 cf                	mov    %ecx,%edi
  800b1e:	89 ce                	mov    %ecx,%esi
  800b20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b22:	85 c0                	test   %eax,%eax
  800b24:	7e 17                	jle    800b3d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b26:	83 ec 0c             	sub    $0xc,%esp
  800b29:	50                   	push   %eax
  800b2a:	6a 03                	push   $0x3
  800b2c:	68 44 13 80 00       	push   $0x801344
  800b31:	6a 23                	push   $0x23
  800b33:	68 61 13 80 00       	push   $0x801361
  800b38:	e8 e5 f5 ff ff       	call   800122 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	57                   	push   %edi
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b50:	b8 02 00 00 00       	mov    $0x2,%eax
  800b55:	89 d1                	mov    %edx,%ecx
  800b57:	89 d3                	mov    %edx,%ebx
  800b59:	89 d7                	mov    %edx,%edi
  800b5b:	89 d6                	mov    %edx,%esi
  800b5d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    

00800b64 <sys_yield>:

void
sys_yield(void)
{
  800b64:	55                   	push   %ebp
  800b65:	89 e5                	mov    %esp,%ebp
  800b67:	57                   	push   %edi
  800b68:	56                   	push   %esi
  800b69:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b74:	89 d1                	mov    %edx,%ecx
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	89 d7                	mov    %edx,%edi
  800b7a:	89 d6                	mov    %edx,%esi
  800b7c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	57                   	push   %edi
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b8c:	be 00 00 00 00       	mov    $0x0,%esi
  800b91:	b8 04 00 00 00       	mov    $0x4,%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	89 f7                	mov    %esi,%edi
  800ba1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba3:	85 c0                	test   %eax,%eax
  800ba5:	7e 17                	jle    800bbe <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	50                   	push   %eax
  800bab:	6a 04                	push   $0x4
  800bad:	68 44 13 80 00       	push   $0x801344
  800bb2:	6a 23                	push   $0x23
  800bb4:	68 61 13 80 00       	push   $0x801361
  800bb9:	e8 64 f5 ff ff       	call   800122 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5f                   	pop    %edi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	57                   	push   %edi
  800bca:	56                   	push   %esi
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bcf:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be0:	8b 75 18             	mov    0x18(%ebp),%esi
  800be3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800be5:	85 c0                	test   %eax,%eax
  800be7:	7e 17                	jle    800c00 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	50                   	push   %eax
  800bed:	6a 05                	push   $0x5
  800bef:	68 44 13 80 00       	push   $0x801344
  800bf4:	6a 23                	push   $0x23
  800bf6:	68 61 13 80 00       	push   $0x801361
  800bfb:	e8 22 f5 ff ff       	call   800122 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c16:	b8 06 00 00 00       	mov    $0x6,%eax
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c21:	89 df                	mov    %ebx,%edi
  800c23:	89 de                	mov    %ebx,%esi
  800c25:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 17                	jle    800c42 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	83 ec 0c             	sub    $0xc,%esp
  800c2e:	50                   	push   %eax
  800c2f:	6a 06                	push   $0x6
  800c31:	68 44 13 80 00       	push   $0x801344
  800c36:	6a 23                	push   $0x23
  800c38:	68 61 13 80 00       	push   $0x801361
  800c3d:	e8 e0 f4 ff ff       	call   800122 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c53:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c58:	b8 08 00 00 00       	mov    $0x8,%eax
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	8b 55 08             	mov    0x8(%ebp),%edx
  800c63:	89 df                	mov    %ebx,%edi
  800c65:	89 de                	mov    %ebx,%esi
  800c67:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c69:	85 c0                	test   %eax,%eax
  800c6b:	7e 17                	jle    800c84 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	50                   	push   %eax
  800c71:	6a 08                	push   $0x8
  800c73:	68 44 13 80 00       	push   $0x801344
  800c78:	6a 23                	push   $0x23
  800c7a:	68 61 13 80 00       	push   $0x801361
  800c7f:	e8 9e f4 ff ff       	call   800122 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
  800c92:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca5:	89 df                	mov    %ebx,%edi
  800ca7:	89 de                	mov    %ebx,%esi
  800ca9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 17                	jle    800cc6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	83 ec 0c             	sub    $0xc,%esp
  800cb2:	50                   	push   %eax
  800cb3:	6a 09                	push   $0x9
  800cb5:	68 44 13 80 00       	push   $0x801344
  800cba:	6a 23                	push   $0x23
  800cbc:	68 61 13 80 00       	push   $0x801361
  800cc1:	e8 5c f4 ff ff       	call   800122 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	be 00 00 00 00       	mov    $0x0,%esi
  800cd9:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cea:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7e 17                	jle    800d2a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 0c                	push   $0xc
  800d19:	68 44 13 80 00       	push   $0x801344
  800d1e:	6a 23                	push   $0x23
  800d20:	68 61 13 80 00       	push   $0x801361
  800d25:	e8 f8 f3 ff ff       	call   800122 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	53                   	push   %ebx
  800d36:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d39:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d40:	75 57                	jne    800d99 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  800d42:	e8 fe fd ff ff       	call   800b45 <sys_getenvid>
  800d47:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	6a 07                	push   $0x7
  800d4e:	68 00 f0 bf ee       	push   $0xeebff000
  800d53:	50                   	push   %eax
  800d54:	e8 2a fe ff ff       	call   800b83 <sys_page_alloc>
		if (r < 0) {
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	79 12                	jns    800d72 <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  800d60:	50                   	push   %eax
  800d61:	68 6f 13 80 00       	push   $0x80136f
  800d66:	6a 24                	push   $0x24
  800d68:	68 83 13 80 00       	push   $0x801383
  800d6d:	e8 b0 f3 ff ff       	call   800122 <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  800d72:	83 ec 08             	sub    $0x8,%esp
  800d75:	68 a6 0d 80 00       	push   $0x800da6
  800d7a:	53                   	push   %ebx
  800d7b:	e8 0c ff ff ff       	call   800c8c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	79 12                	jns    800d99 <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  800d87:	50                   	push   %eax
  800d88:	68 6f 13 80 00       	push   $0x80136f
  800d8d:	6a 29                	push   $0x29
  800d8f:	68 83 13 80 00       	push   $0x801383
  800d94:	e8 89 f3 ff ff       	call   800122 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800da1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    

00800da6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800da6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800da7:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800dac:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dae:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  800db1:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  800db5:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  800db8:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  800dbc:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  800dc0:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800dc3:	83 c4 08             	add    $0x8,%esp
	popal
  800dc6:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800dc7:	83 c4 04             	add    $0x4,%esp
	popfl
  800dca:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800dcb:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dcc:	c3                   	ret    
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	55                   	push   %ebp
  800dd1:	57                   	push   %edi
  800dd2:	56                   	push   %esi
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 1c             	sub    $0x1c,%esp
  800dd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ddb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ddf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800de3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800de7:	85 f6                	test   %esi,%esi
  800de9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ded:	89 ca                	mov    %ecx,%edx
  800def:	89 f8                	mov    %edi,%eax
  800df1:	75 3d                	jne    800e30 <__udivdi3+0x60>
  800df3:	39 cf                	cmp    %ecx,%edi
  800df5:	0f 87 c5 00 00 00    	ja     800ec0 <__udivdi3+0xf0>
  800dfb:	85 ff                	test   %edi,%edi
  800dfd:	89 fd                	mov    %edi,%ebp
  800dff:	75 0b                	jne    800e0c <__udivdi3+0x3c>
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	31 d2                	xor    %edx,%edx
  800e08:	f7 f7                	div    %edi
  800e0a:	89 c5                	mov    %eax,%ebp
  800e0c:	89 c8                	mov    %ecx,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f5                	div    %ebp
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	89 d8                	mov    %ebx,%eax
  800e16:	89 cf                	mov    %ecx,%edi
  800e18:	f7 f5                	div    %ebp
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	89 fa                	mov    %edi,%edx
  800e20:	83 c4 1c             	add    $0x1c,%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
  800e28:	90                   	nop
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 ce                	cmp    %ecx,%esi
  800e32:	77 74                	ja     800ea8 <__udivdi3+0xd8>
  800e34:	0f bd fe             	bsr    %esi,%edi
  800e37:	83 f7 1f             	xor    $0x1f,%edi
  800e3a:	0f 84 98 00 00 00    	je     800ed8 <__udivdi3+0x108>
  800e40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	89 c5                	mov    %eax,%ebp
  800e49:	29 fb                	sub    %edi,%ebx
  800e4b:	d3 e6                	shl    %cl,%esi
  800e4d:	89 d9                	mov    %ebx,%ecx
  800e4f:	d3 ed                	shr    %cl,%ebp
  800e51:	89 f9                	mov    %edi,%ecx
  800e53:	d3 e0                	shl    %cl,%eax
  800e55:	09 ee                	or     %ebp,%esi
  800e57:	89 d9                	mov    %ebx,%ecx
  800e59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e5d:	89 d5                	mov    %edx,%ebp
  800e5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e63:	d3 ed                	shr    %cl,%ebp
  800e65:	89 f9                	mov    %edi,%ecx
  800e67:	d3 e2                	shl    %cl,%edx
  800e69:	89 d9                	mov    %ebx,%ecx
  800e6b:	d3 e8                	shr    %cl,%eax
  800e6d:	09 c2                	or     %eax,%edx
  800e6f:	89 d0                	mov    %edx,%eax
  800e71:	89 ea                	mov    %ebp,%edx
  800e73:	f7 f6                	div    %esi
  800e75:	89 d5                	mov    %edx,%ebp
  800e77:	89 c3                	mov    %eax,%ebx
  800e79:	f7 64 24 0c          	mull   0xc(%esp)
  800e7d:	39 d5                	cmp    %edx,%ebp
  800e7f:	72 10                	jb     800e91 <__udivdi3+0xc1>
  800e81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	d3 e6                	shl    %cl,%esi
  800e89:	39 c6                	cmp    %eax,%esi
  800e8b:	73 07                	jae    800e94 <__udivdi3+0xc4>
  800e8d:	39 d5                	cmp    %edx,%ebp
  800e8f:	75 03                	jne    800e94 <__udivdi3+0xc4>
  800e91:	83 eb 01             	sub    $0x1,%ebx
  800e94:	31 ff                	xor    %edi,%edi
  800e96:	89 d8                	mov    %ebx,%eax
  800e98:	89 fa                	mov    %edi,%edx
  800e9a:	83 c4 1c             	add    $0x1c,%esp
  800e9d:	5b                   	pop    %ebx
  800e9e:	5e                   	pop    %esi
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
  800ea2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea8:	31 ff                	xor    %edi,%edi
  800eaa:	31 db                	xor    %ebx,%ebx
  800eac:	89 d8                	mov    %ebx,%eax
  800eae:	89 fa                	mov    %edi,%edx
  800eb0:	83 c4 1c             	add    $0x1c,%esp
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    
  800eb8:	90                   	nop
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 d8                	mov    %ebx,%eax
  800ec2:	f7 f7                	div    %edi
  800ec4:	31 ff                	xor    %edi,%edi
  800ec6:	89 c3                	mov    %eax,%ebx
  800ec8:	89 d8                	mov    %ebx,%eax
  800eca:	89 fa                	mov    %edi,%edx
  800ecc:	83 c4 1c             	add    $0x1c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    
  800ed4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed8:	39 ce                	cmp    %ecx,%esi
  800eda:	72 0c                	jb     800ee8 <__udivdi3+0x118>
  800edc:	31 db                	xor    %ebx,%ebx
  800ede:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ee2:	0f 87 34 ff ff ff    	ja     800e1c <__udivdi3+0x4c>
  800ee8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800eed:	e9 2a ff ff ff       	jmp    800e1c <__udivdi3+0x4c>
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 d2                	test   %edx,%edx
  800f19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f21:	89 f3                	mov    %esi,%ebx
  800f23:	89 3c 24             	mov    %edi,(%esp)
  800f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2a:	75 1c                	jne    800f48 <__umoddi3+0x48>
  800f2c:	39 f7                	cmp    %esi,%edi
  800f2e:	76 50                	jbe    800f80 <__umoddi3+0x80>
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	f7 f7                	div    %edi
  800f36:	89 d0                	mov    %edx,%eax
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	77 52                	ja     800fa0 <__umoddi3+0xa0>
  800f4e:	0f bd ea             	bsr    %edx,%ebp
  800f51:	83 f5 1f             	xor    $0x1f,%ebp
  800f54:	75 5a                	jne    800fb0 <__umoddi3+0xb0>
  800f56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f5a:	0f 82 e0 00 00 00    	jb     801040 <__umoddi3+0x140>
  800f60:	39 0c 24             	cmp    %ecx,(%esp)
  800f63:	0f 86 d7 00 00 00    	jbe    801040 <__umoddi3+0x140>
  800f69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f71:	83 c4 1c             	add    $0x1c,%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	85 ff                	test   %edi,%edi
  800f82:	89 fd                	mov    %edi,%ebp
  800f84:	75 0b                	jne    800f91 <__umoddi3+0x91>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f7                	div    %edi
  800f8f:	89 c5                	mov    %eax,%ebp
  800f91:	89 f0                	mov    %esi,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f5                	div    %ebp
  800f97:	89 c8                	mov    %ecx,%eax
  800f99:	f7 f5                	div    %ebp
  800f9b:	89 d0                	mov    %edx,%eax
  800f9d:	eb 99                	jmp    800f38 <__umoddi3+0x38>
  800f9f:	90                   	nop
  800fa0:	89 c8                	mov    %ecx,%eax
  800fa2:	89 f2                	mov    %esi,%edx
  800fa4:	83 c4 1c             	add    $0x1c,%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
  800fac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	8b 34 24             	mov    (%esp),%esi
  800fb3:	bf 20 00 00 00       	mov    $0x20,%edi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	29 ef                	sub    %ebp,%edi
  800fbc:	d3 e0                	shl    %cl,%eax
  800fbe:	89 f9                	mov    %edi,%ecx
  800fc0:	89 f2                	mov    %esi,%edx
  800fc2:	d3 ea                	shr    %cl,%edx
  800fc4:	89 e9                	mov    %ebp,%ecx
  800fc6:	09 c2                	or     %eax,%edx
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	89 14 24             	mov    %edx,(%esp)
  800fcd:	89 f2                	mov    %esi,%edx
  800fcf:	d3 e2                	shl    %cl,%edx
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800fdb:	d3 e8                	shr    %cl,%eax
  800fdd:	89 e9                	mov    %ebp,%ecx
  800fdf:	89 c6                	mov    %eax,%esi
  800fe1:	d3 e3                	shl    %cl,%ebx
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 d0                	mov    %edx,%eax
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	09 d8                	or     %ebx,%eax
  800fed:	89 d3                	mov    %edx,%ebx
  800fef:	89 f2                	mov    %esi,%edx
  800ff1:	f7 34 24             	divl   (%esp)
  800ff4:	89 d6                	mov    %edx,%esi
  800ff6:	d3 e3                	shl    %cl,%ebx
  800ff8:	f7 64 24 04          	mull   0x4(%esp)
  800ffc:	39 d6                	cmp    %edx,%esi
  800ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801002:	89 d1                	mov    %edx,%ecx
  801004:	89 c3                	mov    %eax,%ebx
  801006:	72 08                	jb     801010 <__umoddi3+0x110>
  801008:	75 11                	jne    80101b <__umoddi3+0x11b>
  80100a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80100e:	73 0b                	jae    80101b <__umoddi3+0x11b>
  801010:	2b 44 24 04          	sub    0x4(%esp),%eax
  801014:	1b 14 24             	sbb    (%esp),%edx
  801017:	89 d1                	mov    %edx,%ecx
  801019:	89 c3                	mov    %eax,%ebx
  80101b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80101f:	29 da                	sub    %ebx,%edx
  801021:	19 ce                	sbb    %ecx,%esi
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 f0                	mov    %esi,%eax
  801027:	d3 e0                	shl    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	d3 ea                	shr    %cl,%edx
  80102d:	89 e9                	mov    %ebp,%ecx
  80102f:	d3 ee                	shr    %cl,%esi
  801031:	09 d0                	or     %edx,%eax
  801033:	89 f2                	mov    %esi,%edx
  801035:	83 c4 1c             	add    $0x1c,%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	29 f9                	sub    %edi,%ecx
  801042:	19 d6                	sbb    %edx,%esi
  801044:	89 74 24 04          	mov    %esi,0x4(%esp)
  801048:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80104c:	e9 18 ff ff ff       	jmp    800f69 <__umoddi3+0x69>
