
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 71 15 80 00       	push   $0x801571
  800049:	68 40 15 80 00       	push   $0x801540
  80004e:	e8 75 06 00 00       	call   8006c8 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 15 80 00       	push   $0x801550
  80005c:	68 54 15 80 00       	push   $0x801554
  800061:	e8 62 06 00 00       	call   8006c8 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 64 15 80 00       	push   $0x801564
  800077:	e8 4c 06 00 00       	call   8006c8 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 68 15 80 00       	push   $0x801568
  80008e:	e8 35 06 00 00       	call   8006c8 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 72 15 80 00       	push   $0x801572
  8000a6:	68 54 15 80 00       	push   $0x801554
  8000ab:	e8 18 06 00 00       	call   8006c8 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 64 15 80 00       	push   $0x801564
  8000c3:	e8 00 06 00 00       	call   8006c8 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 68 15 80 00       	push   $0x801568
  8000d5:	e8 ee 05 00 00       	call   8006c8 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 76 15 80 00       	push   $0x801576
  8000ed:	68 54 15 80 00       	push   $0x801554
  8000f2:	e8 d1 05 00 00       	call   8006c8 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 64 15 80 00       	push   $0x801564
  80010a:	e8 b9 05 00 00       	call   8006c8 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 68 15 80 00       	push   $0x801568
  80011c:	e8 a7 05 00 00       	call   8006c8 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 7a 15 80 00       	push   $0x80157a
  800134:	68 54 15 80 00       	push   $0x801554
  800139:	e8 8a 05 00 00       	call   8006c8 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 64 15 80 00       	push   $0x801564
  800151:	e8 72 05 00 00       	call   8006c8 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 68 15 80 00       	push   $0x801568
  800163:	e8 60 05 00 00       	call   8006c8 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 7e 15 80 00       	push   $0x80157e
  80017b:	68 54 15 80 00       	push   $0x801554
  800180:	e8 43 05 00 00       	call   8006c8 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 64 15 80 00       	push   $0x801564
  800198:	e8 2b 05 00 00       	call   8006c8 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 68 15 80 00       	push   $0x801568
  8001aa:	e8 19 05 00 00       	call   8006c8 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 82 15 80 00       	push   $0x801582
  8001c2:	68 54 15 80 00       	push   $0x801554
  8001c7:	e8 fc 04 00 00       	call   8006c8 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 64 15 80 00       	push   $0x801564
  8001df:	e8 e4 04 00 00       	call   8006c8 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 68 15 80 00       	push   $0x801568
  8001f1:	e8 d2 04 00 00       	call   8006c8 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 86 15 80 00       	push   $0x801586
  800209:	68 54 15 80 00       	push   $0x801554
  80020e:	e8 b5 04 00 00       	call   8006c8 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 64 15 80 00       	push   $0x801564
  800226:	e8 9d 04 00 00       	call   8006c8 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 68 15 80 00       	push   $0x801568
  800238:	e8 8b 04 00 00       	call   8006c8 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 8a 15 80 00       	push   $0x80158a
  800250:	68 54 15 80 00       	push   $0x801554
  800255:	e8 6e 04 00 00       	call   8006c8 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 64 15 80 00       	push   $0x801564
  80026d:	e8 56 04 00 00       	call   8006c8 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 68 15 80 00       	push   $0x801568
  80027f:	e8 44 04 00 00       	call   8006c8 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 8e 15 80 00       	push   $0x80158e
  800297:	68 54 15 80 00       	push   $0x801554
  80029c:	e8 27 04 00 00       	call   8006c8 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 64 15 80 00       	push   $0x801564
  8002b4:	e8 0f 04 00 00       	call   8006c8 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 95 15 80 00       	push   $0x801595
  8002c4:	68 54 15 80 00       	push   $0x801554
  8002c9:	e8 fa 03 00 00       	call   8006c8 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 68 15 80 00       	push   $0x801568
  8002e3:	e8 e0 03 00 00       	call   8006c8 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 95 15 80 00       	push   $0x801595
  8002f3:	68 54 15 80 00       	push   $0x801554
  8002f8:	e8 cb 03 00 00       	call   8006c8 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 64 15 80 00       	push   $0x801564
  800312:	e8 b1 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 99 15 80 00       	push   $0x801599
  800322:	e8 a1 03 00 00       	call   8006c8 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 68 15 80 00       	push   $0x801568
  800338:	e8 8b 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 99 15 80 00       	push   $0x801599
  800348:	e8 7b 03 00 00       	call   8006c8 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 64 15 80 00       	push   $0x801564
  80035a:	e8 69 03 00 00       	call   8006c8 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 68 15 80 00       	push   $0x801568
  80036c:	e8 57 03 00 00       	call   8006c8 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 64 15 80 00       	push   $0x801564
  80037e:	e8 45 03 00 00       	call   8006c8 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 99 15 80 00       	push   $0x801599
  80038e:	e8 35 03 00 00       	call   8006c8 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 00 16 80 00       	push   $0x801600
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 a7 15 80 00       	push   $0x8015a7
  8003c6:	e8 24 02 00 00       	call   8005ef <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 60 20 80 00    	mov    %edx,0x802060
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 70 20 80 00    	mov    %edx,0x802070
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 74 20 80 00    	mov    %edx,0x802074
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 78 20 80 00    	mov    %edx,0x802078
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 bf 15 80 00       	push   $0x8015bf
  80043b:	68 cd 15 80 00       	push   $0x8015cd
  800440:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800445:	ba b8 15 80 00       	mov    $0x8015b8,%edx
  80044a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 eb 0b 00 00       	call   801050 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 d4 15 80 00       	push   $0x8015d4
  800472:	6a 5c                	push   $0x5c
  800474:	68 a7 15 80 00       	push   $0x8015a7
  800479:	e8 71 01 00 00       	call   8005ef <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 6f 0d 00 00       	call   8011ff <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004b1:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004b7:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  8004bd:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  8004c3:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  8004c9:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  8004cf:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  8004d4:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8004ea:	89 35 24 20 80 00    	mov    %esi,0x802024
  8004f0:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8004f6:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8004fc:	89 15 34 20 80 00    	mov    %edx,0x802034
  800502:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800508:	a3 3c 20 80 00       	mov    %eax,0x80203c
  80050d:	89 25 48 20 80 00    	mov    %esp,0x802048
  800513:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800519:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  80051f:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  800525:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  80052b:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800531:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800537:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  80053c:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 44 20 80 00       	mov    %eax,0x802044
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 34 16 80 00       	push   $0x801634
  80055f:	e8 64 01 00 00       	call   8006c8 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  80056c:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 e7 15 80 00       	push   $0x8015e7
  800579:	68 f8 15 80 00       	push   $0x8015f8
  80057e:	b9 20 20 80 00       	mov    $0x802020,%ecx
  800583:	ba b8 15 80 00       	mov    $0x8015b8,%edx
  800588:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 6b 0a 00 00       	call   801012 <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
		binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

	// exit gracefully
	exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8005e3:	6a 00                	push   $0x0
  8005e5:	e8 e7 09 00 00       	call   800fd1 <sys_env_destroy>
}
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	c9                   	leave  
  8005ee:	c3                   	ret    

008005ef <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005ef:	55                   	push   %ebp
  8005f0:	89 e5                	mov    %esp,%ebp
  8005f2:	56                   	push   %esi
  8005f3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f7:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8005fd:	e8 10 0a 00 00       	call   801012 <sys_getenvid>
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	ff 75 0c             	pushl  0xc(%ebp)
  800608:	ff 75 08             	pushl  0x8(%ebp)
  80060b:	56                   	push   %esi
  80060c:	50                   	push   %eax
  80060d:	68 60 16 80 00       	push   $0x801660
  800612:	e8 b1 00 00 00       	call   8006c8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800617:	83 c4 18             	add    $0x18,%esp
  80061a:	53                   	push   %ebx
  80061b:	ff 75 10             	pushl  0x10(%ebp)
  80061e:	e8 54 00 00 00       	call   800677 <vcprintf>
	cprintf("\n");
  800623:	c7 04 24 70 15 80 00 	movl   $0x801570,(%esp)
  80062a:	e8 99 00 00 00       	call   8006c8 <cprintf>
  80062f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800632:	cc                   	int3   
  800633:	eb fd                	jmp    800632 <_panic+0x43>

00800635 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800635:	55                   	push   %ebp
  800636:	89 e5                	mov    %esp,%ebp
  800638:	53                   	push   %ebx
  800639:	83 ec 04             	sub    $0x4,%esp
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063f:	8b 13                	mov    (%ebx),%edx
  800641:	8d 42 01             	lea    0x1(%edx),%eax
  800644:	89 03                	mov    %eax,(%ebx)
  800646:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800649:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800652:	75 1a                	jne    80066e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	68 ff 00 00 00       	push   $0xff
  80065c:	8d 43 08             	lea    0x8(%ebx),%eax
  80065f:	50                   	push   %eax
  800660:	e8 2f 09 00 00       	call   800f94 <sys_cputs>
		b->idx = 0;
  800665:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80066e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800675:	c9                   	leave  
  800676:	c3                   	ret    

00800677 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800677:	55                   	push   %ebp
  800678:	89 e5                	mov    %esp,%ebp
  80067a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800680:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800687:	00 00 00 
	b.cnt = 0;
  80068a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800691:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800694:	ff 75 0c             	pushl  0xc(%ebp)
  800697:	ff 75 08             	pushl  0x8(%ebp)
  80069a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a0:	50                   	push   %eax
  8006a1:	68 35 06 80 00       	push   $0x800635
  8006a6:	e8 54 01 00 00       	call   8007ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006ba:	50                   	push   %eax
  8006bb:	e8 d4 08 00 00       	call   800f94 <sys_cputs>

	return b.cnt;
}
  8006c0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d1:	50                   	push   %eax
  8006d2:	ff 75 08             	pushl  0x8(%ebp)
  8006d5:	e8 9d ff ff ff       	call   800677 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006da:	c9                   	leave  
  8006db:	c3                   	ret    

008006dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	57                   	push   %edi
  8006e0:	56                   	push   %esi
  8006e1:	53                   	push   %ebx
  8006e2:	83 ec 1c             	sub    $0x1c,%esp
  8006e5:	89 c7                	mov    %eax,%edi
  8006e7:	89 d6                	mov    %edx,%esi
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8006f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800700:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800703:	39 d3                	cmp    %edx,%ebx
  800705:	72 05                	jb     80070c <printnum+0x30>
  800707:	39 45 10             	cmp    %eax,0x10(%ebp)
  80070a:	77 45                	ja     800751 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	ff 75 18             	pushl  0x18(%ebp)
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800718:	53                   	push   %ebx
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800722:	ff 75 e0             	pushl  -0x20(%ebp)
  800725:	ff 75 dc             	pushl  -0x24(%ebp)
  800728:	ff 75 d8             	pushl  -0x28(%ebp)
  80072b:	e8 70 0b 00 00       	call   8012a0 <__udivdi3>
  800730:	83 c4 18             	add    $0x18,%esp
  800733:	52                   	push   %edx
  800734:	50                   	push   %eax
  800735:	89 f2                	mov    %esi,%edx
  800737:	89 f8                	mov    %edi,%eax
  800739:	e8 9e ff ff ff       	call   8006dc <printnum>
  80073e:	83 c4 20             	add    $0x20,%esp
  800741:	eb 18                	jmp    80075b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	56                   	push   %esi
  800747:	ff 75 18             	pushl  0x18(%ebp)
  80074a:	ff d7                	call   *%edi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb 03                	jmp    800754 <printnum+0x78>
  800751:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	85 db                	test   %ebx,%ebx
  800759:	7f e8                	jg     800743 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	56                   	push   %esi
  80075f:	83 ec 04             	sub    $0x4,%esp
  800762:	ff 75 e4             	pushl  -0x1c(%ebp)
  800765:	ff 75 e0             	pushl  -0x20(%ebp)
  800768:	ff 75 dc             	pushl  -0x24(%ebp)
  80076b:	ff 75 d8             	pushl  -0x28(%ebp)
  80076e:	e8 5d 0c 00 00       	call   8013d0 <__umoddi3>
  800773:	83 c4 14             	add    $0x14,%esp
  800776:	0f be 80 84 16 80 00 	movsbl 0x801684(%eax),%eax
  80077d:	50                   	push   %eax
  80077e:	ff d7                	call   *%edi
}
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5f                   	pop    %edi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078e:	83 fa 01             	cmp    $0x1,%edx
  800791:	7e 0e                	jle    8007a1 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800793:	8b 10                	mov    (%eax),%edx
  800795:	8d 4a 08             	lea    0x8(%edx),%ecx
  800798:	89 08                	mov    %ecx,(%eax)
  80079a:	8b 02                	mov    (%edx),%eax
  80079c:	8b 52 04             	mov    0x4(%edx),%edx
  80079f:	eb 22                	jmp    8007c3 <getuint+0x38>
	else if (lflag)
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 10                	je     8007b5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a5:	8b 10                	mov    (%eax),%edx
  8007a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007aa:	89 08                	mov    %ecx,(%eax)
  8007ac:	8b 02                	mov    (%edx),%eax
  8007ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b3:	eb 0e                	jmp    8007c3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007ba:	89 08                	mov    %ecx,(%eax)
  8007bc:	8b 02                	mov    (%edx),%eax
  8007be:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c3:	5d                   	pop    %ebp
  8007c4:	c3                   	ret    

008007c5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c5:	55                   	push   %ebp
  8007c6:	89 e5                	mov    %esp,%ebp
  8007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007cb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d4:	73 0a                	jae    8007e0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d9:	89 08                	mov    %ecx,(%eax)
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	88 02                	mov    %al,(%edx)
}
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007eb:	50                   	push   %eax
  8007ec:	ff 75 10             	pushl  0x10(%ebp)
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	ff 75 08             	pushl  0x8(%ebp)
  8007f5:	e8 05 00 00 00       	call   8007ff <vprintfmt>
	va_end(ap);
}
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	57                   	push   %edi
  800803:	56                   	push   %esi
  800804:	53                   	push   %ebx
  800805:	83 ec 2c             	sub    $0x2c,%esp
  800808:	8b 75 08             	mov    0x8(%ebp),%esi
  80080b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800811:	eb 12                	jmp    800825 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800813:	85 c0                	test   %eax,%eax
  800815:	0f 84 89 03 00 00    	je     800ba4 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	50                   	push   %eax
  800820:	ff d6                	call   *%esi
  800822:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800825:	83 c7 01             	add    $0x1,%edi
  800828:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80082c:	83 f8 25             	cmp    $0x25,%eax
  80082f:	75 e2                	jne    800813 <vprintfmt+0x14>
  800831:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800835:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80083c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800843:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80084a:	ba 00 00 00 00       	mov    $0x0,%edx
  80084f:	eb 07                	jmp    800858 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800854:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800858:	8d 47 01             	lea    0x1(%edi),%eax
  80085b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085e:	0f b6 07             	movzbl (%edi),%eax
  800861:	0f b6 c8             	movzbl %al,%ecx
  800864:	83 e8 23             	sub    $0x23,%eax
  800867:	3c 55                	cmp    $0x55,%al
  800869:	0f 87 1a 03 00 00    	ja     800b89 <vprintfmt+0x38a>
  80086f:	0f b6 c0             	movzbl %al,%eax
  800872:	ff 24 85 40 17 80 00 	jmp    *0x801740(,%eax,4)
  800879:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80087c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800880:	eb d6                	jmp    800858 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800882:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800885:	b8 00 00 00 00       	mov    $0x0,%eax
  80088a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800890:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800894:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800897:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80089a:	83 fa 09             	cmp    $0x9,%edx
  80089d:	77 39                	ja     8008d8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80089f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008a2:	eb e9                	jmp    80088d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8d 48 04             	lea    0x4(%eax),%ecx
  8008aa:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008ad:	8b 00                	mov    (%eax),%eax
  8008af:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b5:	eb 27                	jmp    8008de <vprintfmt+0xdf>
  8008b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c1:	0f 49 c8             	cmovns %eax,%ecx
  8008c4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ca:	eb 8c                	jmp    800858 <vprintfmt+0x59>
  8008cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008cf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d6:	eb 80                	jmp    800858 <vprintfmt+0x59>
  8008d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008db:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008de:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008e2:	0f 89 70 ff ff ff    	jns    800858 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f5:	e9 5e ff ff ff       	jmp    800858 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008fa:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800900:	e9 53 ff ff ff       	jmp    800858 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8d 50 04             	lea    0x4(%eax),%edx
  80090b:	89 55 14             	mov    %edx,0x14(%ebp)
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	53                   	push   %ebx
  800912:	ff 30                	pushl  (%eax)
  800914:	ff d6                	call   *%esi
			break;
  800916:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800919:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80091c:	e9 04 ff ff ff       	jmp    800825 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800921:	8b 45 14             	mov    0x14(%ebp),%eax
  800924:	8d 50 04             	lea    0x4(%eax),%edx
  800927:	89 55 14             	mov    %edx,0x14(%ebp)
  80092a:	8b 00                	mov    (%eax),%eax
  80092c:	99                   	cltd   
  80092d:	31 d0                	xor    %edx,%eax
  80092f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800931:	83 f8 08             	cmp    $0x8,%eax
  800934:	7f 0b                	jg     800941 <vprintfmt+0x142>
  800936:	8b 14 85 a0 18 80 00 	mov    0x8018a0(,%eax,4),%edx
  80093d:	85 d2                	test   %edx,%edx
  80093f:	75 18                	jne    800959 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800941:	50                   	push   %eax
  800942:	68 9c 16 80 00       	push   $0x80169c
  800947:	53                   	push   %ebx
  800948:	56                   	push   %esi
  800949:	e8 94 fe ff ff       	call   8007e2 <printfmt>
  80094e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800951:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800954:	e9 cc fe ff ff       	jmp    800825 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800959:	52                   	push   %edx
  80095a:	68 a5 16 80 00       	push   $0x8016a5
  80095f:	53                   	push   %ebx
  800960:	56                   	push   %esi
  800961:	e8 7c fe ff ff       	call   8007e2 <printfmt>
  800966:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800969:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80096c:	e9 b4 fe ff ff       	jmp    800825 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 50 04             	lea    0x4(%eax),%edx
  800977:	89 55 14             	mov    %edx,0x14(%ebp)
  80097a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80097c:	85 ff                	test   %edi,%edi
  80097e:	b8 95 16 80 00       	mov    $0x801695,%eax
  800983:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800986:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80098a:	0f 8e 94 00 00 00    	jle    800a24 <vprintfmt+0x225>
  800990:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800994:	0f 84 98 00 00 00    	je     800a32 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099a:	83 ec 08             	sub    $0x8,%esp
  80099d:	ff 75 d0             	pushl  -0x30(%ebp)
  8009a0:	57                   	push   %edi
  8009a1:	e8 86 02 00 00       	call   800c2c <strnlen>
  8009a6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009a9:	29 c1                	sub    %eax,%ecx
  8009ab:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009ae:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bd:	eb 0f                	jmp    8009ce <vprintfmt+0x1cf>
					putch(padc, putdat);
  8009bf:	83 ec 08             	sub    $0x8,%esp
  8009c2:	53                   	push   %ebx
  8009c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c8:	83 ef 01             	sub    $0x1,%edi
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	85 ff                	test   %edi,%edi
  8009d0:	7f ed                	jg     8009bf <vprintfmt+0x1c0>
  8009d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009d8:	85 c9                	test   %ecx,%ecx
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
  8009df:	0f 49 c1             	cmovns %ecx,%eax
  8009e2:	29 c1                	sub    %eax,%ecx
  8009e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ed:	89 cb                	mov    %ecx,%ebx
  8009ef:	eb 4d                	jmp    800a3e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f5:	74 1b                	je     800a12 <vprintfmt+0x213>
  8009f7:	0f be c0             	movsbl %al,%eax
  8009fa:	83 e8 20             	sub    $0x20,%eax
  8009fd:	83 f8 5e             	cmp    $0x5e,%eax
  800a00:	76 10                	jbe    800a12 <vprintfmt+0x213>
					putch('?', putdat);
  800a02:	83 ec 08             	sub    $0x8,%esp
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	6a 3f                	push   $0x3f
  800a0a:	ff 55 08             	call   *0x8(%ebp)
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	eb 0d                	jmp    800a1f <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800a12:	83 ec 08             	sub    $0x8,%esp
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	52                   	push   %edx
  800a19:	ff 55 08             	call   *0x8(%ebp)
  800a1c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1f:	83 eb 01             	sub    $0x1,%ebx
  800a22:	eb 1a                	jmp    800a3e <vprintfmt+0x23f>
  800a24:	89 75 08             	mov    %esi,0x8(%ebp)
  800a27:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a2a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a30:	eb 0c                	jmp    800a3e <vprintfmt+0x23f>
  800a32:	89 75 08             	mov    %esi,0x8(%ebp)
  800a35:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a38:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3e:	83 c7 01             	add    $0x1,%edi
  800a41:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a45:	0f be d0             	movsbl %al,%edx
  800a48:	85 d2                	test   %edx,%edx
  800a4a:	74 23                	je     800a6f <vprintfmt+0x270>
  800a4c:	85 f6                	test   %esi,%esi
  800a4e:	78 a1                	js     8009f1 <vprintfmt+0x1f2>
  800a50:	83 ee 01             	sub    $0x1,%esi
  800a53:	79 9c                	jns    8009f1 <vprintfmt+0x1f2>
  800a55:	89 df                	mov    %ebx,%edi
  800a57:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5d:	eb 18                	jmp    800a77 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5f:	83 ec 08             	sub    $0x8,%esp
  800a62:	53                   	push   %ebx
  800a63:	6a 20                	push   $0x20
  800a65:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a67:	83 ef 01             	sub    $0x1,%edi
  800a6a:	83 c4 10             	add    $0x10,%esp
  800a6d:	eb 08                	jmp    800a77 <vprintfmt+0x278>
  800a6f:	89 df                	mov    %ebx,%edi
  800a71:	8b 75 08             	mov    0x8(%ebp),%esi
  800a74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a77:	85 ff                	test   %edi,%edi
  800a79:	7f e4                	jg     800a5f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7e:	e9 a2 fd ff ff       	jmp    800825 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a83:	83 fa 01             	cmp    $0x1,%edx
  800a86:	7e 16                	jle    800a9e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800a88:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8b:	8d 50 08             	lea    0x8(%eax),%edx
  800a8e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a91:	8b 50 04             	mov    0x4(%eax),%edx
  800a94:	8b 00                	mov    (%eax),%eax
  800a96:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a99:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a9c:	eb 32                	jmp    800ad0 <vprintfmt+0x2d1>
	else if (lflag)
  800a9e:	85 d2                	test   %edx,%edx
  800aa0:	74 18                	je     800aba <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  800aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa5:	8d 50 04             	lea    0x4(%eax),%edx
  800aa8:	89 55 14             	mov    %edx,0x14(%ebp)
  800aab:	8b 00                	mov    (%eax),%eax
  800aad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab0:	89 c1                	mov    %eax,%ecx
  800ab2:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab8:	eb 16                	jmp    800ad0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800aba:	8b 45 14             	mov    0x14(%ebp),%eax
  800abd:	8d 50 04             	lea    0x4(%eax),%edx
  800ac0:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac3:	8b 00                	mov    (%eax),%eax
  800ac5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac8:	89 c1                	mov    %eax,%ecx
  800aca:	c1 f9 1f             	sar    $0x1f,%ecx
  800acd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800adb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800adf:	79 74                	jns    800b55 <vprintfmt+0x356>
				putch('-', putdat);
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	53                   	push   %ebx
  800ae5:	6a 2d                	push   $0x2d
  800ae7:	ff d6                	call   *%esi
				num = -(long long) num;
  800ae9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800aef:	f7 d8                	neg    %eax
  800af1:	83 d2 00             	adc    $0x0,%edx
  800af4:	f7 da                	neg    %edx
  800af6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800af9:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800afe:	eb 55                	jmp    800b55 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b00:	8d 45 14             	lea    0x14(%ebp),%eax
  800b03:	e8 83 fc ff ff       	call   80078b <getuint>
			base = 10;
  800b08:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b0d:	eb 46                	jmp    800b55 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800b0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800b12:	e8 74 fc ff ff       	call   80078b <getuint>
			base = 8;
  800b17:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b1c:	eb 37                	jmp    800b55 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800b1e:	83 ec 08             	sub    $0x8,%esp
  800b21:	53                   	push   %ebx
  800b22:	6a 30                	push   $0x30
  800b24:	ff d6                	call   *%esi
			putch('x', putdat);
  800b26:	83 c4 08             	add    $0x8,%esp
  800b29:	53                   	push   %ebx
  800b2a:	6a 78                	push   $0x78
  800b2c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b31:	8d 50 04             	lea    0x4(%eax),%edx
  800b34:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b37:	8b 00                	mov    (%eax),%eax
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b3e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b41:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b46:	eb 0d                	jmp    800b55 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b48:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4b:	e8 3b fc ff ff       	call   80078b <getuint>
			base = 16;
  800b50:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b55:	83 ec 0c             	sub    $0xc,%esp
  800b58:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b5c:	57                   	push   %edi
  800b5d:	ff 75 e0             	pushl  -0x20(%ebp)
  800b60:	51                   	push   %ecx
  800b61:	52                   	push   %edx
  800b62:	50                   	push   %eax
  800b63:	89 da                	mov    %ebx,%edx
  800b65:	89 f0                	mov    %esi,%eax
  800b67:	e8 70 fb ff ff       	call   8006dc <printnum>
			break;
  800b6c:	83 c4 20             	add    $0x20,%esp
  800b6f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b72:	e9 ae fc ff ff       	jmp    800825 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b77:	83 ec 08             	sub    $0x8,%esp
  800b7a:	53                   	push   %ebx
  800b7b:	51                   	push   %ecx
  800b7c:	ff d6                	call   *%esi
			break;
  800b7e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b81:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b84:	e9 9c fc ff ff       	jmp    800825 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b89:	83 ec 08             	sub    $0x8,%esp
  800b8c:	53                   	push   %ebx
  800b8d:	6a 25                	push   $0x25
  800b8f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b91:	83 c4 10             	add    $0x10,%esp
  800b94:	eb 03                	jmp    800b99 <vprintfmt+0x39a>
  800b96:	83 ef 01             	sub    $0x1,%edi
  800b99:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b9d:	75 f7                	jne    800b96 <vprintfmt+0x397>
  800b9f:	e9 81 fc ff ff       	jmp    800825 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba7:	5b                   	pop    %ebx
  800ba8:	5e                   	pop    %esi
  800ba9:	5f                   	pop    %edi
  800baa:	5d                   	pop    %ebp
  800bab:	c3                   	ret    

00800bac <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 18             	sub    $0x18,%esp
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bbb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bbf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	74 26                	je     800bf3 <vsnprintf+0x47>
  800bcd:	85 d2                	test   %edx,%edx
  800bcf:	7e 22                	jle    800bf3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd1:	ff 75 14             	pushl  0x14(%ebp)
  800bd4:	ff 75 10             	pushl  0x10(%ebp)
  800bd7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bda:	50                   	push   %eax
  800bdb:	68 c5 07 80 00       	push   $0x8007c5
  800be0:	e8 1a fc ff ff       	call   8007ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bee:	83 c4 10             	add    $0x10,%esp
  800bf1:	eb 05                	jmp    800bf8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c00:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c03:	50                   	push   %eax
  800c04:	ff 75 10             	pushl  0x10(%ebp)
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	ff 75 08             	pushl  0x8(%ebp)
  800c0d:	e8 9a ff ff ff       	call   800bac <vsnprintf>
	va_end(ap);

	return rc;
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	eb 03                	jmp    800c24 <strlen+0x10>
		n++;
  800c21:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c24:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c28:	75 f7                	jne    800c21 <strlen+0xd>
		n++;
	return n;
}
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c32:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c35:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3a:	eb 03                	jmp    800c3f <strnlen+0x13>
		n++;
  800c3c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c3f:	39 c2                	cmp    %eax,%edx
  800c41:	74 08                	je     800c4b <strnlen+0x1f>
  800c43:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c47:	75 f3                	jne    800c3c <strnlen+0x10>
  800c49:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	53                   	push   %ebx
  800c51:	8b 45 08             	mov    0x8(%ebp),%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c57:	89 c2                	mov    %eax,%edx
  800c59:	83 c2 01             	add    $0x1,%edx
  800c5c:	83 c1 01             	add    $0x1,%ecx
  800c5f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c63:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c66:	84 db                	test   %bl,%bl
  800c68:	75 ef                	jne    800c59 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c6a:	5b                   	pop    %ebx
  800c6b:	5d                   	pop    %ebp
  800c6c:	c3                   	ret    

00800c6d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	53                   	push   %ebx
  800c71:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c74:	53                   	push   %ebx
  800c75:	e8 9a ff ff ff       	call   800c14 <strlen>
  800c7a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c7d:	ff 75 0c             	pushl  0xc(%ebp)
  800c80:	01 d8                	add    %ebx,%eax
  800c82:	50                   	push   %eax
  800c83:	e8 c5 ff ff ff       	call   800c4d <strcpy>
	return dst;
}
  800c88:	89 d8                	mov    %ebx,%eax
  800c8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c8d:	c9                   	leave  
  800c8e:	c3                   	ret    

00800c8f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	8b 75 08             	mov    0x8(%ebp),%esi
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	89 f3                	mov    %esi,%ebx
  800c9c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c9f:	89 f2                	mov    %esi,%edx
  800ca1:	eb 0f                	jmp    800cb2 <strncpy+0x23>
		*dst++ = *src;
  800ca3:	83 c2 01             	add    $0x1,%edx
  800ca6:	0f b6 01             	movzbl (%ecx),%eax
  800ca9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cac:	80 39 01             	cmpb   $0x1,(%ecx)
  800caf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb2:	39 da                	cmp    %ebx,%edx
  800cb4:	75 ed                	jne    800ca3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb6:	89 f0                	mov    %esi,%eax
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc7:	8b 55 10             	mov    0x10(%ebp),%edx
  800cca:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ccc:	85 d2                	test   %edx,%edx
  800cce:	74 21                	je     800cf1 <strlcpy+0x35>
  800cd0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cd4:	89 f2                	mov    %esi,%edx
  800cd6:	eb 09                	jmp    800ce1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cd8:	83 c2 01             	add    $0x1,%edx
  800cdb:	83 c1 01             	add    $0x1,%ecx
  800cde:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce1:	39 c2                	cmp    %eax,%edx
  800ce3:	74 09                	je     800cee <strlcpy+0x32>
  800ce5:	0f b6 19             	movzbl (%ecx),%ebx
  800ce8:	84 db                	test   %bl,%bl
  800cea:	75 ec                	jne    800cd8 <strlcpy+0x1c>
  800cec:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cee:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf1:	29 f0                	sub    %esi,%eax
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d00:	eb 06                	jmp    800d08 <strcmp+0x11>
		p++, q++;
  800d02:	83 c1 01             	add    $0x1,%ecx
  800d05:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d08:	0f b6 01             	movzbl (%ecx),%eax
  800d0b:	84 c0                	test   %al,%al
  800d0d:	74 04                	je     800d13 <strcmp+0x1c>
  800d0f:	3a 02                	cmp    (%edx),%al
  800d11:	74 ef                	je     800d02 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d13:	0f b6 c0             	movzbl %al,%eax
  800d16:	0f b6 12             	movzbl (%edx),%edx
  800d19:	29 d0                	sub    %edx,%eax
}
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	53                   	push   %ebx
  800d21:	8b 45 08             	mov    0x8(%ebp),%eax
  800d24:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d27:	89 c3                	mov    %eax,%ebx
  800d29:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d2c:	eb 06                	jmp    800d34 <strncmp+0x17>
		n--, p++, q++;
  800d2e:	83 c0 01             	add    $0x1,%eax
  800d31:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d34:	39 d8                	cmp    %ebx,%eax
  800d36:	74 15                	je     800d4d <strncmp+0x30>
  800d38:	0f b6 08             	movzbl (%eax),%ecx
  800d3b:	84 c9                	test   %cl,%cl
  800d3d:	74 04                	je     800d43 <strncmp+0x26>
  800d3f:	3a 0a                	cmp    (%edx),%cl
  800d41:	74 eb                	je     800d2e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d43:	0f b6 00             	movzbl (%eax),%eax
  800d46:	0f b6 12             	movzbl (%edx),%edx
  800d49:	29 d0                	sub    %edx,%eax
  800d4b:	eb 05                	jmp    800d52 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d4d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d52:	5b                   	pop    %ebx
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d5f:	eb 07                	jmp    800d68 <strchr+0x13>
		if (*s == c)
  800d61:	38 ca                	cmp    %cl,%dl
  800d63:	74 0f                	je     800d74 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d65:	83 c0 01             	add    $0x1,%eax
  800d68:	0f b6 10             	movzbl (%eax),%edx
  800d6b:	84 d2                	test   %dl,%dl
  800d6d:	75 f2                	jne    800d61 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d80:	eb 03                	jmp    800d85 <strfind+0xf>
  800d82:	83 c0 01             	add    $0x1,%eax
  800d85:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d88:	38 ca                	cmp    %cl,%dl
  800d8a:	74 04                	je     800d90 <strfind+0x1a>
  800d8c:	84 d2                	test   %dl,%dl
  800d8e:	75 f2                	jne    800d82 <strfind+0xc>
			break;
	return (char *) s;
}
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d9e:	85 c9                	test   %ecx,%ecx
  800da0:	74 36                	je     800dd8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da8:	75 28                	jne    800dd2 <memset+0x40>
  800daa:	f6 c1 03             	test   $0x3,%cl
  800dad:	75 23                	jne    800dd2 <memset+0x40>
		c &= 0xFF;
  800daf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db3:	89 d3                	mov    %edx,%ebx
  800db5:	c1 e3 08             	shl    $0x8,%ebx
  800db8:	89 d6                	mov    %edx,%esi
  800dba:	c1 e6 18             	shl    $0x18,%esi
  800dbd:	89 d0                	mov    %edx,%eax
  800dbf:	c1 e0 10             	shl    $0x10,%eax
  800dc2:	09 f0                	or     %esi,%eax
  800dc4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800dc6:	89 d8                	mov    %ebx,%eax
  800dc8:	09 d0                	or     %edx,%eax
  800dca:	c1 e9 02             	shr    $0x2,%ecx
  800dcd:	fc                   	cld    
  800dce:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd0:	eb 06                	jmp    800dd8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd5:	fc                   	cld    
  800dd6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd8:	89 f8                	mov    %edi,%eax
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	8b 45 08             	mov    0x8(%ebp),%eax
  800de7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ded:	39 c6                	cmp    %eax,%esi
  800def:	73 35                	jae    800e26 <memmove+0x47>
  800df1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df4:	39 d0                	cmp    %edx,%eax
  800df6:	73 2e                	jae    800e26 <memmove+0x47>
		s += n;
		d += n;
  800df8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfb:	89 d6                	mov    %edx,%esi
  800dfd:	09 fe                	or     %edi,%esi
  800dff:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e05:	75 13                	jne    800e1a <memmove+0x3b>
  800e07:	f6 c1 03             	test   $0x3,%cl
  800e0a:	75 0e                	jne    800e1a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e0c:	83 ef 04             	sub    $0x4,%edi
  800e0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e12:	c1 e9 02             	shr    $0x2,%ecx
  800e15:	fd                   	std    
  800e16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e18:	eb 09                	jmp    800e23 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1a:	83 ef 01             	sub    $0x1,%edi
  800e1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e20:	fd                   	std    
  800e21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e23:	fc                   	cld    
  800e24:	eb 1d                	jmp    800e43 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e26:	89 f2                	mov    %esi,%edx
  800e28:	09 c2                	or     %eax,%edx
  800e2a:	f6 c2 03             	test   $0x3,%dl
  800e2d:	75 0f                	jne    800e3e <memmove+0x5f>
  800e2f:	f6 c1 03             	test   $0x3,%cl
  800e32:	75 0a                	jne    800e3e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800e34:	c1 e9 02             	shr    $0x2,%ecx
  800e37:	89 c7                	mov    %eax,%edi
  800e39:	fc                   	cld    
  800e3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3c:	eb 05                	jmp    800e43 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e3e:	89 c7                	mov    %eax,%edi
  800e40:	fc                   	cld    
  800e41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e4a:	ff 75 10             	pushl  0x10(%ebp)
  800e4d:	ff 75 0c             	pushl  0xc(%ebp)
  800e50:	ff 75 08             	pushl  0x8(%ebp)
  800e53:	e8 87 ff ff ff       	call   800ddf <memmove>
}
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	56                   	push   %esi
  800e5e:	53                   	push   %ebx
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e65:	89 c6                	mov    %eax,%esi
  800e67:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6a:	eb 1a                	jmp    800e86 <memcmp+0x2c>
		if (*s1 != *s2)
  800e6c:	0f b6 08             	movzbl (%eax),%ecx
  800e6f:	0f b6 1a             	movzbl (%edx),%ebx
  800e72:	38 d9                	cmp    %bl,%cl
  800e74:	74 0a                	je     800e80 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e76:	0f b6 c1             	movzbl %cl,%eax
  800e79:	0f b6 db             	movzbl %bl,%ebx
  800e7c:	29 d8                	sub    %ebx,%eax
  800e7e:	eb 0f                	jmp    800e8f <memcmp+0x35>
		s1++, s2++;
  800e80:	83 c0 01             	add    $0x1,%eax
  800e83:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e86:	39 f0                	cmp    %esi,%eax
  800e88:	75 e2                	jne    800e6c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	53                   	push   %ebx
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e9a:	89 c1                	mov    %eax,%ecx
  800e9c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800e9f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea3:	eb 0a                	jmp    800eaf <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea5:	0f b6 10             	movzbl (%eax),%edx
  800ea8:	39 da                	cmp    %ebx,%edx
  800eaa:	74 07                	je     800eb3 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eac:	83 c0 01             	add    $0x1,%eax
  800eaf:	39 c8                	cmp    %ecx,%eax
  800eb1:	72 f2                	jb     800ea5 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb3:	5b                   	pop    %ebx
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    

00800eb6 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	57                   	push   %edi
  800eba:	56                   	push   %esi
  800ebb:	53                   	push   %ebx
  800ebc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec2:	eb 03                	jmp    800ec7 <strtol+0x11>
		s++;
  800ec4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec7:	0f b6 01             	movzbl (%ecx),%eax
  800eca:	3c 20                	cmp    $0x20,%al
  800ecc:	74 f6                	je     800ec4 <strtol+0xe>
  800ece:	3c 09                	cmp    $0x9,%al
  800ed0:	74 f2                	je     800ec4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ed2:	3c 2b                	cmp    $0x2b,%al
  800ed4:	75 0a                	jne    800ee0 <strtol+0x2a>
		s++;
  800ed6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ede:	eb 11                	jmp    800ef1 <strtol+0x3b>
  800ee0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee5:	3c 2d                	cmp    $0x2d,%al
  800ee7:	75 08                	jne    800ef1 <strtol+0x3b>
		s++, neg = 1;
  800ee9:	83 c1 01             	add    $0x1,%ecx
  800eec:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ef1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ef7:	75 15                	jne    800f0e <strtol+0x58>
  800ef9:	80 39 30             	cmpb   $0x30,(%ecx)
  800efc:	75 10                	jne    800f0e <strtol+0x58>
  800efe:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f02:	75 7c                	jne    800f80 <strtol+0xca>
		s += 2, base = 16;
  800f04:	83 c1 02             	add    $0x2,%ecx
  800f07:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f0c:	eb 16                	jmp    800f24 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f0e:	85 db                	test   %ebx,%ebx
  800f10:	75 12                	jne    800f24 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f12:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f17:	80 39 30             	cmpb   $0x30,(%ecx)
  800f1a:	75 08                	jne    800f24 <strtol+0x6e>
		s++, base = 8;
  800f1c:	83 c1 01             	add    $0x1,%ecx
  800f1f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f24:	b8 00 00 00 00       	mov    $0x0,%eax
  800f29:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f2c:	0f b6 11             	movzbl (%ecx),%edx
  800f2f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f32:	89 f3                	mov    %esi,%ebx
  800f34:	80 fb 09             	cmp    $0x9,%bl
  800f37:	77 08                	ja     800f41 <strtol+0x8b>
			dig = *s - '0';
  800f39:	0f be d2             	movsbl %dl,%edx
  800f3c:	83 ea 30             	sub    $0x30,%edx
  800f3f:	eb 22                	jmp    800f63 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800f41:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f44:	89 f3                	mov    %esi,%ebx
  800f46:	80 fb 19             	cmp    $0x19,%bl
  800f49:	77 08                	ja     800f53 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800f4b:	0f be d2             	movsbl %dl,%edx
  800f4e:	83 ea 57             	sub    $0x57,%edx
  800f51:	eb 10                	jmp    800f63 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800f53:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f56:	89 f3                	mov    %esi,%ebx
  800f58:	80 fb 19             	cmp    $0x19,%bl
  800f5b:	77 16                	ja     800f73 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800f5d:	0f be d2             	movsbl %dl,%edx
  800f60:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f63:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f66:	7d 0b                	jge    800f73 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800f68:	83 c1 01             	add    $0x1,%ecx
  800f6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f6f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f71:	eb b9                	jmp    800f2c <strtol+0x76>

	if (endptr)
  800f73:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f77:	74 0d                	je     800f86 <strtol+0xd0>
		*endptr = (char *) s;
  800f79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f7c:	89 0e                	mov    %ecx,(%esi)
  800f7e:	eb 06                	jmp    800f86 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f80:	85 db                	test   %ebx,%ebx
  800f82:	74 98                	je     800f1c <strtol+0x66>
  800f84:	eb 9e                	jmp    800f24 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800f86:	89 c2                	mov    %eax,%edx
  800f88:	f7 da                	neg    %edx
  800f8a:	85 ff                	test   %edi,%edi
  800f8c:	0f 45 c2             	cmovne %edx,%eax
}
  800f8f:	5b                   	pop    %ebx
  800f90:	5e                   	pop    %esi
  800f91:	5f                   	pop    %edi
  800f92:	5d                   	pop    %ebp
  800f93:	c3                   	ret    

00800f94 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa5:	89 c3                	mov    %eax,%ebx
  800fa7:	89 c7                	mov    %eax,%edi
  800fa9:	89 c6                	mov    %eax,%esi
  800fab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbd:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	89 d3                	mov    %edx,%ebx
  800fc6:	89 d7                	mov    %edx,%edi
  800fc8:	89 d6                	mov    %edx,%esi
  800fca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	57                   	push   %edi
  800fd5:	56                   	push   %esi
  800fd6:	53                   	push   %ebx
  800fd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe7:	89 cb                	mov    %ecx,%ebx
  800fe9:	89 cf                	mov    %ecx,%edi
  800feb:	89 ce                	mov    %ecx,%esi
  800fed:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	7e 17                	jle    80100a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	50                   	push   %eax
  800ff7:	6a 03                	push   $0x3
  800ff9:	68 c4 18 80 00       	push   $0x8018c4
  800ffe:	6a 23                	push   $0x23
  801000:	68 e1 18 80 00       	push   $0x8018e1
  801005:	e8 e5 f5 ff ff       	call   8005ef <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80100a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80100d:	5b                   	pop    %ebx
  80100e:	5e                   	pop    %esi
  80100f:	5f                   	pop    %edi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801018:	ba 00 00 00 00       	mov    $0x0,%edx
  80101d:	b8 02 00 00 00       	mov    $0x2,%eax
  801022:	89 d1                	mov    %edx,%ecx
  801024:	89 d3                	mov    %edx,%ebx
  801026:	89 d7                	mov    %edx,%edi
  801028:	89 d6                	mov    %edx,%esi
  80102a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_yield>:

void
sys_yield(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	57                   	push   %edi
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801037:	ba 00 00 00 00       	mov    $0x0,%edx
  80103c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801041:	89 d1                	mov    %edx,%ecx
  801043:	89 d3                	mov    %edx,%ebx
  801045:	89 d7                	mov    %edx,%edi
  801047:	89 d6                	mov    %edx,%esi
  801049:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
  801056:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801059:	be 00 00 00 00       	mov    $0x0,%esi
  80105e:	b8 04 00 00 00       	mov    $0x4,%eax
  801063:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801066:	8b 55 08             	mov    0x8(%ebp),%edx
  801069:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80106c:	89 f7                	mov    %esi,%edi
  80106e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801070:	85 c0                	test   %eax,%eax
  801072:	7e 17                	jle    80108b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	50                   	push   %eax
  801078:	6a 04                	push   $0x4
  80107a:	68 c4 18 80 00       	push   $0x8018c4
  80107f:	6a 23                	push   $0x23
  801081:	68 e1 18 80 00       	push   $0x8018e1
  801086:	e8 64 f5 ff ff       	call   8005ef <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80108b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108e:	5b                   	pop    %ebx
  80108f:	5e                   	pop    %esi
  801090:	5f                   	pop    %edi
  801091:	5d                   	pop    %ebp
  801092:	c3                   	ret    

00801093 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	57                   	push   %edi
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109c:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010aa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010ad:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	7e 17                	jle    8010cd <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	50                   	push   %eax
  8010ba:	6a 05                	push   $0x5
  8010bc:	68 c4 18 80 00       	push   $0x8018c4
  8010c1:	6a 23                	push   $0x23
  8010c3:	68 e1 18 80 00       	push   $0x8018e1
  8010c8:	e8 22 f5 ff ff       	call   8005ef <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e3:	b8 06 00 00 00       	mov    $0x6,%eax
  8010e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ee:	89 df                	mov    %ebx,%edi
  8010f0:	89 de                	mov    %ebx,%esi
  8010f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	7e 17                	jle    80110f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	50                   	push   %eax
  8010fc:	6a 06                	push   $0x6
  8010fe:	68 c4 18 80 00       	push   $0x8018c4
  801103:	6a 23                	push   $0x23
  801105:	68 e1 18 80 00       	push   $0x8018e1
  80110a:	e8 e0 f4 ff ff       	call   8005ef <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5f                   	pop    %edi
  801115:	5d                   	pop    %ebp
  801116:	c3                   	ret    

00801117 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	57                   	push   %edi
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801120:	bb 00 00 00 00       	mov    $0x0,%ebx
  801125:	b8 08 00 00 00       	mov    $0x8,%eax
  80112a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112d:	8b 55 08             	mov    0x8(%ebp),%edx
  801130:	89 df                	mov    %ebx,%edi
  801132:	89 de                	mov    %ebx,%esi
  801134:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801136:	85 c0                	test   %eax,%eax
  801138:	7e 17                	jle    801151 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113a:	83 ec 0c             	sub    $0xc,%esp
  80113d:	50                   	push   %eax
  80113e:	6a 08                	push   $0x8
  801140:	68 c4 18 80 00       	push   $0x8018c4
  801145:	6a 23                	push   $0x23
  801147:	68 e1 18 80 00       	push   $0x8018e1
  80114c:	e8 9e f4 ff ff       	call   8005ef <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801151:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801154:	5b                   	pop    %ebx
  801155:	5e                   	pop    %esi
  801156:	5f                   	pop    %edi
  801157:	5d                   	pop    %ebp
  801158:	c3                   	ret    

00801159 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	57                   	push   %edi
  80115d:	56                   	push   %esi
  80115e:	53                   	push   %ebx
  80115f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801162:	bb 00 00 00 00       	mov    $0x0,%ebx
  801167:	b8 09 00 00 00       	mov    $0x9,%eax
  80116c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116f:	8b 55 08             	mov    0x8(%ebp),%edx
  801172:	89 df                	mov    %ebx,%edi
  801174:	89 de                	mov    %ebx,%esi
  801176:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801178:	85 c0                	test   %eax,%eax
  80117a:	7e 17                	jle    801193 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117c:	83 ec 0c             	sub    $0xc,%esp
  80117f:	50                   	push   %eax
  801180:	6a 09                	push   $0x9
  801182:	68 c4 18 80 00       	push   $0x8018c4
  801187:	6a 23                	push   $0x23
  801189:	68 e1 18 80 00       	push   $0x8018e1
  80118e:	e8 5c f4 ff ff       	call   8005ef <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801193:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801196:	5b                   	pop    %ebx
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    

0080119b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a1:	be 00 00 00 00       	mov    $0x0,%esi
  8011a6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011b7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011b9:	5b                   	pop    %ebx
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    

008011be <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011cc:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d4:	89 cb                	mov    %ecx,%ebx
  8011d6:	89 cf                	mov    %ecx,%edi
  8011d8:	89 ce                	mov    %ecx,%esi
  8011da:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	7e 17                	jle    8011f7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011e0:	83 ec 0c             	sub    $0xc,%esp
  8011e3:	50                   	push   %eax
  8011e4:	6a 0c                	push   $0xc
  8011e6:	68 c4 18 80 00       	push   $0x8018c4
  8011eb:	6a 23                	push   $0x23
  8011ed:	68 e1 18 80 00       	push   $0x8018e1
  8011f2:	e8 f8 f3 ff ff       	call   8005ef <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fa:	5b                   	pop    %ebx
  8011fb:	5e                   	pop    %esi
  8011fc:	5f                   	pop    %edi
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    

008011ff <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	53                   	push   %ebx
  801203:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801206:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80120d:	75 57                	jne    801266 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  80120f:	e8 fe fd ff ff       	call   801012 <sys_getenvid>
  801214:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	6a 07                	push   $0x7
  80121b:	68 00 f0 bf ee       	push   $0xeebff000
  801220:	50                   	push   %eax
  801221:	e8 2a fe ff ff       	call   801050 <sys_page_alloc>
		if (r < 0) {
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	79 12                	jns    80123f <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  80122d:	50                   	push   %eax
  80122e:	68 ef 18 80 00       	push   $0x8018ef
  801233:	6a 24                	push   $0x24
  801235:	68 03 19 80 00       	push   $0x801903
  80123a:	e8 b0 f3 ff ff       	call   8005ef <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  80123f:	83 ec 08             	sub    $0x8,%esp
  801242:	68 73 12 80 00       	push   $0x801273
  801247:	53                   	push   %ebx
  801248:	e8 0c ff ff ff       	call   801159 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80124d:	83 c4 10             	add    $0x10,%esp
  801250:	85 c0                	test   %eax,%eax
  801252:	79 12                	jns    801266 <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  801254:	50                   	push   %eax
  801255:	68 ef 18 80 00       	push   $0x8018ef
  80125a:	6a 29                	push   $0x29
  80125c:	68 03 19 80 00       	push   $0x801903
  801261:	e8 89 f3 ff ff       	call   8005ef <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  80126e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801273:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801274:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801279:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80127b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  80127e:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  801282:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  801285:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  801289:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  80128d:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801290:	83 c4 08             	add    $0x8,%esp
	popal
  801293:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801294:	83 c4 04             	add    $0x4,%esp
	popfl
  801297:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801298:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801299:	c3                   	ret    
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__udivdi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 1c             	sub    $0x1c,%esp
  8012a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8012ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8012af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8012b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012b7:	85 f6                	test   %esi,%esi
  8012b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012bd:	89 ca                	mov    %ecx,%edx
  8012bf:	89 f8                	mov    %edi,%eax
  8012c1:	75 3d                	jne    801300 <__udivdi3+0x60>
  8012c3:	39 cf                	cmp    %ecx,%edi
  8012c5:	0f 87 c5 00 00 00    	ja     801390 <__udivdi3+0xf0>
  8012cb:	85 ff                	test   %edi,%edi
  8012cd:	89 fd                	mov    %edi,%ebp
  8012cf:	75 0b                	jne    8012dc <__udivdi3+0x3c>
  8012d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d6:	31 d2                	xor    %edx,%edx
  8012d8:	f7 f7                	div    %edi
  8012da:	89 c5                	mov    %eax,%ebp
  8012dc:	89 c8                	mov    %ecx,%eax
  8012de:	31 d2                	xor    %edx,%edx
  8012e0:	f7 f5                	div    %ebp
  8012e2:	89 c1                	mov    %eax,%ecx
  8012e4:	89 d8                	mov    %ebx,%eax
  8012e6:	89 cf                	mov    %ecx,%edi
  8012e8:	f7 f5                	div    %ebp
  8012ea:	89 c3                	mov    %eax,%ebx
  8012ec:	89 d8                	mov    %ebx,%eax
  8012ee:	89 fa                	mov    %edi,%edx
  8012f0:	83 c4 1c             	add    $0x1c,%esp
  8012f3:	5b                   	pop    %ebx
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
  8012f8:	90                   	nop
  8012f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801300:	39 ce                	cmp    %ecx,%esi
  801302:	77 74                	ja     801378 <__udivdi3+0xd8>
  801304:	0f bd fe             	bsr    %esi,%edi
  801307:	83 f7 1f             	xor    $0x1f,%edi
  80130a:	0f 84 98 00 00 00    	je     8013a8 <__udivdi3+0x108>
  801310:	bb 20 00 00 00       	mov    $0x20,%ebx
  801315:	89 f9                	mov    %edi,%ecx
  801317:	89 c5                	mov    %eax,%ebp
  801319:	29 fb                	sub    %edi,%ebx
  80131b:	d3 e6                	shl    %cl,%esi
  80131d:	89 d9                	mov    %ebx,%ecx
  80131f:	d3 ed                	shr    %cl,%ebp
  801321:	89 f9                	mov    %edi,%ecx
  801323:	d3 e0                	shl    %cl,%eax
  801325:	09 ee                	or     %ebp,%esi
  801327:	89 d9                	mov    %ebx,%ecx
  801329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132d:	89 d5                	mov    %edx,%ebp
  80132f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801333:	d3 ed                	shr    %cl,%ebp
  801335:	89 f9                	mov    %edi,%ecx
  801337:	d3 e2                	shl    %cl,%edx
  801339:	89 d9                	mov    %ebx,%ecx
  80133b:	d3 e8                	shr    %cl,%eax
  80133d:	09 c2                	or     %eax,%edx
  80133f:	89 d0                	mov    %edx,%eax
  801341:	89 ea                	mov    %ebp,%edx
  801343:	f7 f6                	div    %esi
  801345:	89 d5                	mov    %edx,%ebp
  801347:	89 c3                	mov    %eax,%ebx
  801349:	f7 64 24 0c          	mull   0xc(%esp)
  80134d:	39 d5                	cmp    %edx,%ebp
  80134f:	72 10                	jb     801361 <__udivdi3+0xc1>
  801351:	8b 74 24 08          	mov    0x8(%esp),%esi
  801355:	89 f9                	mov    %edi,%ecx
  801357:	d3 e6                	shl    %cl,%esi
  801359:	39 c6                	cmp    %eax,%esi
  80135b:	73 07                	jae    801364 <__udivdi3+0xc4>
  80135d:	39 d5                	cmp    %edx,%ebp
  80135f:	75 03                	jne    801364 <__udivdi3+0xc4>
  801361:	83 eb 01             	sub    $0x1,%ebx
  801364:	31 ff                	xor    %edi,%edi
  801366:	89 d8                	mov    %ebx,%eax
  801368:	89 fa                	mov    %edi,%edx
  80136a:	83 c4 1c             	add    $0x1c,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    
  801372:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801378:	31 ff                	xor    %edi,%edi
  80137a:	31 db                	xor    %ebx,%ebx
  80137c:	89 d8                	mov    %ebx,%eax
  80137e:	89 fa                	mov    %edi,%edx
  801380:	83 c4 1c             	add    $0x1c,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5f                   	pop    %edi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
  801388:	90                   	nop
  801389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801390:	89 d8                	mov    %ebx,%eax
  801392:	f7 f7                	div    %edi
  801394:	31 ff                	xor    %edi,%edi
  801396:	89 c3                	mov    %eax,%ebx
  801398:	89 d8                	mov    %ebx,%eax
  80139a:	89 fa                	mov    %edi,%edx
  80139c:	83 c4 1c             	add    $0x1c,%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5f                   	pop    %edi
  8013a2:	5d                   	pop    %ebp
  8013a3:	c3                   	ret    
  8013a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a8:	39 ce                	cmp    %ecx,%esi
  8013aa:	72 0c                	jb     8013b8 <__udivdi3+0x118>
  8013ac:	31 db                	xor    %ebx,%ebx
  8013ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8013b2:	0f 87 34 ff ff ff    	ja     8012ec <__udivdi3+0x4c>
  8013b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8013bd:	e9 2a ff ff ff       	jmp    8012ec <__udivdi3+0x4c>
  8013c2:	66 90                	xchg   %ax,%ax
  8013c4:	66 90                	xchg   %ax,%ax
  8013c6:	66 90                	xchg   %ax,%ax
  8013c8:	66 90                	xchg   %ax,%ax
  8013ca:	66 90                	xchg   %ax,%ax
  8013cc:	66 90                	xchg   %ax,%ax
  8013ce:	66 90                	xchg   %ax,%ax

008013d0 <__umoddi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	57                   	push   %edi
  8013d2:	56                   	push   %esi
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 1c             	sub    $0x1c,%esp
  8013d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8013df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013e7:	85 d2                	test   %edx,%edx
  8013e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f1:	89 f3                	mov    %esi,%ebx
  8013f3:	89 3c 24             	mov    %edi,(%esp)
  8013f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fa:	75 1c                	jne    801418 <__umoddi3+0x48>
  8013fc:	39 f7                	cmp    %esi,%edi
  8013fe:	76 50                	jbe    801450 <__umoddi3+0x80>
  801400:	89 c8                	mov    %ecx,%eax
  801402:	89 f2                	mov    %esi,%edx
  801404:	f7 f7                	div    %edi
  801406:	89 d0                	mov    %edx,%eax
  801408:	31 d2                	xor    %edx,%edx
  80140a:	83 c4 1c             	add    $0x1c,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5f                   	pop    %edi
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    
  801412:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801418:	39 f2                	cmp    %esi,%edx
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	77 52                	ja     801470 <__umoddi3+0xa0>
  80141e:	0f bd ea             	bsr    %edx,%ebp
  801421:	83 f5 1f             	xor    $0x1f,%ebp
  801424:	75 5a                	jne    801480 <__umoddi3+0xb0>
  801426:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80142a:	0f 82 e0 00 00 00    	jb     801510 <__umoddi3+0x140>
  801430:	39 0c 24             	cmp    %ecx,(%esp)
  801433:	0f 86 d7 00 00 00    	jbe    801510 <__umoddi3+0x140>
  801439:	8b 44 24 08          	mov    0x8(%esp),%eax
  80143d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801441:	83 c4 1c             	add    $0x1c,%esp
  801444:	5b                   	pop    %ebx
  801445:	5e                   	pop    %esi
  801446:	5f                   	pop    %edi
  801447:	5d                   	pop    %ebp
  801448:	c3                   	ret    
  801449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801450:	85 ff                	test   %edi,%edi
  801452:	89 fd                	mov    %edi,%ebp
  801454:	75 0b                	jne    801461 <__umoddi3+0x91>
  801456:	b8 01 00 00 00       	mov    $0x1,%eax
  80145b:	31 d2                	xor    %edx,%edx
  80145d:	f7 f7                	div    %edi
  80145f:	89 c5                	mov    %eax,%ebp
  801461:	89 f0                	mov    %esi,%eax
  801463:	31 d2                	xor    %edx,%edx
  801465:	f7 f5                	div    %ebp
  801467:	89 c8                	mov    %ecx,%eax
  801469:	f7 f5                	div    %ebp
  80146b:	89 d0                	mov    %edx,%eax
  80146d:	eb 99                	jmp    801408 <__umoddi3+0x38>
  80146f:	90                   	nop
  801470:	89 c8                	mov    %ecx,%eax
  801472:	89 f2                	mov    %esi,%edx
  801474:	83 c4 1c             	add    $0x1c,%esp
  801477:	5b                   	pop    %ebx
  801478:	5e                   	pop    %esi
  801479:	5f                   	pop    %edi
  80147a:	5d                   	pop    %ebp
  80147b:	c3                   	ret    
  80147c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801480:	8b 34 24             	mov    (%esp),%esi
  801483:	bf 20 00 00 00       	mov    $0x20,%edi
  801488:	89 e9                	mov    %ebp,%ecx
  80148a:	29 ef                	sub    %ebp,%edi
  80148c:	d3 e0                	shl    %cl,%eax
  80148e:	89 f9                	mov    %edi,%ecx
  801490:	89 f2                	mov    %esi,%edx
  801492:	d3 ea                	shr    %cl,%edx
  801494:	89 e9                	mov    %ebp,%ecx
  801496:	09 c2                	or     %eax,%edx
  801498:	89 d8                	mov    %ebx,%eax
  80149a:	89 14 24             	mov    %edx,(%esp)
  80149d:	89 f2                	mov    %esi,%edx
  80149f:	d3 e2                	shl    %cl,%edx
  8014a1:	89 f9                	mov    %edi,%ecx
  8014a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8014ab:	d3 e8                	shr    %cl,%eax
  8014ad:	89 e9                	mov    %ebp,%ecx
  8014af:	89 c6                	mov    %eax,%esi
  8014b1:	d3 e3                	shl    %cl,%ebx
  8014b3:	89 f9                	mov    %edi,%ecx
  8014b5:	89 d0                	mov    %edx,%eax
  8014b7:	d3 e8                	shr    %cl,%eax
  8014b9:	89 e9                	mov    %ebp,%ecx
  8014bb:	09 d8                	or     %ebx,%eax
  8014bd:	89 d3                	mov    %edx,%ebx
  8014bf:	89 f2                	mov    %esi,%edx
  8014c1:	f7 34 24             	divl   (%esp)
  8014c4:	89 d6                	mov    %edx,%esi
  8014c6:	d3 e3                	shl    %cl,%ebx
  8014c8:	f7 64 24 04          	mull   0x4(%esp)
  8014cc:	39 d6                	cmp    %edx,%esi
  8014ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d2:	89 d1                	mov    %edx,%ecx
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	72 08                	jb     8014e0 <__umoddi3+0x110>
  8014d8:	75 11                	jne    8014eb <__umoddi3+0x11b>
  8014da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8014de:	73 0b                	jae    8014eb <__umoddi3+0x11b>
  8014e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8014e4:	1b 14 24             	sbb    (%esp),%edx
  8014e7:	89 d1                	mov    %edx,%ecx
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8014ef:	29 da                	sub    %ebx,%edx
  8014f1:	19 ce                	sbb    %ecx,%esi
  8014f3:	89 f9                	mov    %edi,%ecx
  8014f5:	89 f0                	mov    %esi,%eax
  8014f7:	d3 e0                	shl    %cl,%eax
  8014f9:	89 e9                	mov    %ebp,%ecx
  8014fb:	d3 ea                	shr    %cl,%edx
  8014fd:	89 e9                	mov    %ebp,%ecx
  8014ff:	d3 ee                	shr    %cl,%esi
  801501:	09 d0                	or     %edx,%eax
  801503:	89 f2                	mov    %esi,%edx
  801505:	83 c4 1c             	add    $0x1c,%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5f                   	pop    %edi
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    
  80150d:	8d 76 00             	lea    0x0(%esi),%esi
  801510:	29 f9                	sub    %edi,%ecx
  801512:	19 d6                	sbb    %edx,%esi
  801514:	89 74 24 04          	mov    %esi,0x4(%esp)
  801518:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80151c:	e9 18 ff ff ff       	jmp    801439 <__umoddi3+0x69>
