
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 17                	jle    800122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	50                   	push   %eax
  80010f:	6a 03                	push   $0x3
  800111:	68 0a 10 80 00       	push   $0x80100a
  800116:	6a 23                	push   $0x23
  800118:	68 27 10 80 00       	push   $0x801027
  80011d:	e8 1c 02 00 00       	call   80033e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7e 17                	jle    8001a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	50                   	push   %eax
  800190:	6a 04                	push   $0x4
  800192:	68 0a 10 80 00       	push   $0x80100a
  800197:	6a 23                	push   $0x23
  800199:	68 27 10 80 00       	push   $0x801027
  80019e:	e8 9b 01 00 00       	call   80033e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a6:	5b                   	pop    %ebx
  8001a7:	5e                   	pop    %esi
  8001a8:	5f                   	pop    %edi
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 05                	push   $0x5
  8001d4:	68 0a 10 80 00       	push   $0x80100a
  8001d9:	6a 23                	push   $0x23
  8001db:	68 27 10 80 00       	push   $0x801027
  8001e0:	e8 59 01 00 00       	call   80033e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 06                	push   $0x6
  800216:	68 0a 10 80 00       	push   $0x80100a
  80021b:	6a 23                	push   $0x23
  80021d:	68 27 10 80 00       	push   $0x801027
  800222:	e8 17 01 00 00       	call   80033e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 08                	push   $0x8
  800258:	68 0a 10 80 00       	push   $0x80100a
  80025d:	6a 23                	push   $0x23
  80025f:	68 27 10 80 00       	push   $0x801027
  800264:	e8 d5 00 00 00       	call   80033e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 09                	push   $0x9
  80029a:	68 0a 10 80 00       	push   $0x80100a
  80029f:	6a 23                	push   $0x23
  8002a1:	68 27 10 80 00       	push   $0x801027
  8002a6:	e8 93 00 00 00       	call   80033e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b9:	be 00 00 00 00       	mov    $0x0,%esi
  8002be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7e 17                	jle    80030f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	50                   	push   %eax
  8002fc:	6a 0c                	push   $0xc
  8002fe:	68 0a 10 80 00       	push   $0x80100a
  800303:	6a 23                	push   $0x23
  800305:	68 27 10 80 00       	push   $0x801027
  80030a:	e8 2f 00 00 00       	call   80033e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80030f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800312:	5b                   	pop    %ebx
  800313:	5e                   	pop    %esi
  800314:	5f                   	pop    %edi
  800315:	5d                   	pop    %ebp
  800316:	c3                   	ret    

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %ebp
  800322:	8b 6c 24 30          	mov    0x30(%esp),%ebp
	subl $4, %ebp
  800326:	83 ed 04             	sub    $0x4,%ebp
	movl %ebp, 48(%esp)
  800329:	89 6c 24 30          	mov    %ebp,0x30(%esp)
	movl 40(%esp), %eax
  80032d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl %eax, (%ebp)
  800331:	89 45 00             	mov    %eax,0x0(%ebp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800334:	83 c4 08             	add    $0x8,%esp
	popal
  800337:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800338:	83 c4 04             	add    $0x4,%esp
	popfl
  80033b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80033c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80033d:	c3                   	ret    

0080033e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800343:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800346:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034c:	e8 d9 fd ff ff       	call   80012a <sys_getenvid>
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	ff 75 0c             	pushl  0xc(%ebp)
  800357:	ff 75 08             	pushl  0x8(%ebp)
  80035a:	56                   	push   %esi
  80035b:	50                   	push   %eax
  80035c:	68 38 10 80 00       	push   $0x801038
  800361:	e8 b1 00 00 00       	call   800417 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800366:	83 c4 18             	add    $0x18,%esp
  800369:	53                   	push   %ebx
  80036a:	ff 75 10             	pushl  0x10(%ebp)
  80036d:	e8 54 00 00 00       	call   8003c6 <vcprintf>
	cprintf("\n");
  800372:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  800379:	e8 99 00 00 00       	call   800417 <cprintf>
  80037e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800381:	cc                   	int3   
  800382:	eb fd                	jmp    800381 <_panic+0x43>

00800384 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 13                	mov    (%ebx),%edx
  800390:	8d 42 01             	lea    0x1(%edx),%eax
  800393:	89 03                	mov    %eax,(%ebx)
  800395:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800398:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a1:	75 1a                	jne    8003bd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	68 ff 00 00 00       	push   $0xff
  8003ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ae:	50                   	push   %eax
  8003af:	e8 f8 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ba:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d6:	00 00 00 
	b.cnt = 0;
  8003d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e3:	ff 75 0c             	pushl  0xc(%ebp)
  8003e6:	ff 75 08             	pushl  0x8(%ebp)
  8003e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ef:	50                   	push   %eax
  8003f0:	68 84 03 80 00       	push   $0x800384
  8003f5:	e8 54 01 00 00       	call   80054e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fa:	83 c4 08             	add    $0x8,%esp
  8003fd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800403:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800409:	50                   	push   %eax
  80040a:	e8 9d fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  80040f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800420:	50                   	push   %eax
  800421:	ff 75 08             	pushl  0x8(%ebp)
  800424:	e8 9d ff ff ff       	call   8003c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	57                   	push   %edi
  80042f:	56                   	push   %esi
  800430:	53                   	push   %ebx
  800431:	83 ec 1c             	sub    $0x1c,%esp
  800434:	89 c7                	mov    %eax,%edi
  800436:	89 d6                	mov    %edx,%esi
  800438:	8b 45 08             	mov    0x8(%ebp),%eax
  80043b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800441:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800444:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800447:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80044f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800452:	39 d3                	cmp    %edx,%ebx
  800454:	72 05                	jb     80045b <printnum+0x30>
  800456:	39 45 10             	cmp    %eax,0x10(%ebp)
  800459:	77 45                	ja     8004a0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045b:	83 ec 0c             	sub    $0xc,%esp
  80045e:	ff 75 18             	pushl  0x18(%ebp)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800467:	53                   	push   %ebx
  800468:	ff 75 10             	pushl  0x10(%ebp)
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800471:	ff 75 e0             	pushl  -0x20(%ebp)
  800474:	ff 75 dc             	pushl  -0x24(%ebp)
  800477:	ff 75 d8             	pushl  -0x28(%ebp)
  80047a:	e8 e1 08 00 00       	call   800d60 <__udivdi3>
  80047f:	83 c4 18             	add    $0x18,%esp
  800482:	52                   	push   %edx
  800483:	50                   	push   %eax
  800484:	89 f2                	mov    %esi,%edx
  800486:	89 f8                	mov    %edi,%eax
  800488:	e8 9e ff ff ff       	call   80042b <printnum>
  80048d:	83 c4 20             	add    $0x20,%esp
  800490:	eb 18                	jmp    8004aa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	56                   	push   %esi
  800496:	ff 75 18             	pushl  0x18(%ebp)
  800499:	ff d7                	call   *%edi
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	eb 03                	jmp    8004a3 <printnum+0x78>
  8004a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a3:	83 eb 01             	sub    $0x1,%ebx
  8004a6:	85 db                	test   %ebx,%ebx
  8004a8:	7f e8                	jg     800492 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	56                   	push   %esi
  8004ae:	83 ec 04             	sub    $0x4,%esp
  8004b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bd:	e8 ce 09 00 00       	call   800e90 <__umoddi3>
  8004c2:	83 c4 14             	add    $0x14,%esp
  8004c5:	0f be 80 5e 10 80 00 	movsbl 0x80105e(%eax),%eax
  8004cc:	50                   	push   %eax
  8004cd:	ff d7                	call   *%edi
}
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d5:	5b                   	pop    %ebx
  8004d6:	5e                   	pop    %esi
  8004d7:	5f                   	pop    %edi
  8004d8:	5d                   	pop    %ebp
  8004d9:	c3                   	ret    

008004da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004dd:	83 fa 01             	cmp    $0x1,%edx
  8004e0:	7e 0e                	jle    8004f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004e2:	8b 10                	mov    (%eax),%edx
  8004e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 02                	mov    (%edx),%eax
  8004eb:	8b 52 04             	mov    0x4(%edx),%edx
  8004ee:	eb 22                	jmp    800512 <getuint+0x38>
	else if (lflag)
  8004f0:	85 d2                	test   %edx,%edx
  8004f2:	74 10                	je     800504 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004f4:	8b 10                	mov    (%eax),%edx
  8004f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f9:	89 08                	mov    %ecx,(%eax)
  8004fb:	8b 02                	mov    (%edx),%eax
  8004fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800502:	eb 0e                	jmp    800512 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800504:	8b 10                	mov    (%eax),%edx
  800506:	8d 4a 04             	lea    0x4(%edx),%ecx
  800509:	89 08                	mov    %ecx,(%eax)
  80050b:	8b 02                	mov    (%edx),%eax
  80050d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800512:	5d                   	pop    %ebp
  800513:	c3                   	ret    

00800514 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800514:	55                   	push   %ebp
  800515:	89 e5                	mov    %esp,%ebp
  800517:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80051a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80051e:	8b 10                	mov    (%eax),%edx
  800520:	3b 50 04             	cmp    0x4(%eax),%edx
  800523:	73 0a                	jae    80052f <sprintputch+0x1b>
		*b->buf++ = ch;
  800525:	8d 4a 01             	lea    0x1(%edx),%ecx
  800528:	89 08                	mov    %ecx,(%eax)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	88 02                	mov    %al,(%edx)
}
  80052f:	5d                   	pop    %ebp
  800530:	c3                   	ret    

00800531 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800537:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80053a:	50                   	push   %eax
  80053b:	ff 75 10             	pushl  0x10(%ebp)
  80053e:	ff 75 0c             	pushl  0xc(%ebp)
  800541:	ff 75 08             	pushl  0x8(%ebp)
  800544:	e8 05 00 00 00       	call   80054e <vprintfmt>
	va_end(ap);
}
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	c9                   	leave  
  80054d:	c3                   	ret    

0080054e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	57                   	push   %edi
  800552:	56                   	push   %esi
  800553:	53                   	push   %ebx
  800554:	83 ec 2c             	sub    $0x2c,%esp
  800557:	8b 75 08             	mov    0x8(%ebp),%esi
  80055a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800560:	eb 12                	jmp    800574 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 84 89 03 00 00    	je     8008f3 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	53                   	push   %ebx
  80056e:	50                   	push   %eax
  80056f:	ff d6                	call   *%esi
  800571:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800574:	83 c7 01             	add    $0x1,%edi
  800577:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80057b:	83 f8 25             	cmp    $0x25,%eax
  80057e:	75 e2                	jne    800562 <vprintfmt+0x14>
  800580:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800584:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80058b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800592:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
  80059e:	eb 07                	jmp    8005a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8d 47 01             	lea    0x1(%edi),%eax
  8005aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ad:	0f b6 07             	movzbl (%edi),%eax
  8005b0:	0f b6 c8             	movzbl %al,%ecx
  8005b3:	83 e8 23             	sub    $0x23,%eax
  8005b6:	3c 55                	cmp    $0x55,%al
  8005b8:	0f 87 1a 03 00 00    	ja     8008d8 <vprintfmt+0x38a>
  8005be:	0f b6 c0             	movzbl %al,%eax
  8005c1:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005cf:	eb d6                	jmp    8005a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005df:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005e3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005e6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005e9:	83 fa 09             	cmp    $0x9,%edx
  8005ec:	77 39                	ja     800627 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005f1:	eb e9                	jmp    8005dc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8005f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800604:	eb 27                	jmp    80062d <vprintfmt+0xdf>
  800606:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800609:	85 c0                	test   %eax,%eax
  80060b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800610:	0f 49 c8             	cmovns %eax,%ecx
  800613:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800619:	eb 8c                	jmp    8005a7 <vprintfmt+0x59>
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80061e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800625:	eb 80                	jmp    8005a7 <vprintfmt+0x59>
  800627:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80062d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800631:	0f 89 70 ff ff ff    	jns    8005a7 <vprintfmt+0x59>
				width = precision, precision = -1;
  800637:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80063a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80063d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800644:	e9 5e ff ff ff       	jmp    8005a7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800649:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80064f:	e9 53 ff ff ff       	jmp    8005a7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	53                   	push   %ebx
  800661:	ff 30                	pushl  (%eax)
  800663:	ff d6                	call   *%esi
			break;
  800665:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800668:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80066b:	e9 04 ff ff ff       	jmp    800574 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8d 50 04             	lea    0x4(%eax),%edx
  800676:	89 55 14             	mov    %edx,0x14(%ebp)
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	99                   	cltd   
  80067c:	31 d0                	xor    %edx,%eax
  80067e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800680:	83 f8 08             	cmp    $0x8,%eax
  800683:	7f 0b                	jg     800690 <vprintfmt+0x142>
  800685:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  80068c:	85 d2                	test   %edx,%edx
  80068e:	75 18                	jne    8006a8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800690:	50                   	push   %eax
  800691:	68 76 10 80 00       	push   $0x801076
  800696:	53                   	push   %ebx
  800697:	56                   	push   %esi
  800698:	e8 94 fe ff ff       	call   800531 <printfmt>
  80069d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006a3:	e9 cc fe ff ff       	jmp    800574 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8006a8:	52                   	push   %edx
  8006a9:	68 7f 10 80 00       	push   $0x80107f
  8006ae:	53                   	push   %ebx
  8006af:	56                   	push   %esi
  8006b0:	e8 7c fe ff ff       	call   800531 <printfmt>
  8006b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bb:	e9 b4 fe ff ff       	jmp    800574 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 50 04             	lea    0x4(%eax),%edx
  8006c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006cb:	85 ff                	test   %edi,%edi
  8006cd:	b8 6f 10 80 00       	mov    $0x80106f,%eax
  8006d2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006d9:	0f 8e 94 00 00 00    	jle    800773 <vprintfmt+0x225>
  8006df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006e3:	0f 84 98 00 00 00    	je     800781 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e9:	83 ec 08             	sub    $0x8,%esp
  8006ec:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ef:	57                   	push   %edi
  8006f0:	e8 86 02 00 00       	call   80097b <strnlen>
  8006f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006f8:	29 c1                	sub    %eax,%ecx
  8006fa:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006fd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800700:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800704:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800707:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80070a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80070c:	eb 0f                	jmp    80071d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	ff 75 e0             	pushl  -0x20(%ebp)
  800715:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800717:	83 ef 01             	sub    $0x1,%edi
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	85 ff                	test   %edi,%edi
  80071f:	7f ed                	jg     80070e <vprintfmt+0x1c0>
  800721:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800724:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800727:	85 c9                	test   %ecx,%ecx
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	0f 49 c1             	cmovns %ecx,%eax
  800731:	29 c1                	sub    %eax,%ecx
  800733:	89 75 08             	mov    %esi,0x8(%ebp)
  800736:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800739:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073c:	89 cb                	mov    %ecx,%ebx
  80073e:	eb 4d                	jmp    80078d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800740:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800744:	74 1b                	je     800761 <vprintfmt+0x213>
  800746:	0f be c0             	movsbl %al,%eax
  800749:	83 e8 20             	sub    $0x20,%eax
  80074c:	83 f8 5e             	cmp    $0x5e,%eax
  80074f:	76 10                	jbe    800761 <vprintfmt+0x213>
					putch('?', putdat);
  800751:	83 ec 08             	sub    $0x8,%esp
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	6a 3f                	push   $0x3f
  800759:	ff 55 08             	call   *0x8(%ebp)
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	eb 0d                	jmp    80076e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	ff 75 0c             	pushl  0xc(%ebp)
  800767:	52                   	push   %edx
  800768:	ff 55 08             	call   *0x8(%ebp)
  80076b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076e:	83 eb 01             	sub    $0x1,%ebx
  800771:	eb 1a                	jmp    80078d <vprintfmt+0x23f>
  800773:	89 75 08             	mov    %esi,0x8(%ebp)
  800776:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800779:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80077c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077f:	eb 0c                	jmp    80078d <vprintfmt+0x23f>
  800781:	89 75 08             	mov    %esi,0x8(%ebp)
  800784:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800787:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80078a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078d:	83 c7 01             	add    $0x1,%edi
  800790:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800794:	0f be d0             	movsbl %al,%edx
  800797:	85 d2                	test   %edx,%edx
  800799:	74 23                	je     8007be <vprintfmt+0x270>
  80079b:	85 f6                	test   %esi,%esi
  80079d:	78 a1                	js     800740 <vprintfmt+0x1f2>
  80079f:	83 ee 01             	sub    $0x1,%esi
  8007a2:	79 9c                	jns    800740 <vprintfmt+0x1f2>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	eb 18                	jmp    8007c6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007ae:	83 ec 08             	sub    $0x8,%esp
  8007b1:	53                   	push   %ebx
  8007b2:	6a 20                	push   $0x20
  8007b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007b6:	83 ef 01             	sub    $0x1,%edi
  8007b9:	83 c4 10             	add    $0x10,%esp
  8007bc:	eb 08                	jmp    8007c6 <vprintfmt+0x278>
  8007be:	89 df                	mov    %ebx,%edi
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007c6:	85 ff                	test   %edi,%edi
  8007c8:	7f e4                	jg     8007ae <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007cd:	e9 a2 fd ff ff       	jmp    800574 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d2:	83 fa 01             	cmp    $0x1,%edx
  8007d5:	7e 16                	jle    8007ed <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007da:	8d 50 08             	lea    0x8(%eax),%edx
  8007dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e0:	8b 50 04             	mov    0x4(%eax),%edx
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007eb:	eb 32                	jmp    80081f <vprintfmt+0x2d1>
	else if (lflag)
  8007ed:	85 d2                	test   %edx,%edx
  8007ef:	74 18                	je     800809 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 04             	lea    0x4(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fa:	8b 00                	mov    (%eax),%eax
  8007fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ff:	89 c1                	mov    %eax,%ecx
  800801:	c1 f9 1f             	sar    $0x1f,%ecx
  800804:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800807:	eb 16                	jmp    80081f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8d 50 04             	lea    0x4(%eax),%edx
  80080f:	89 55 14             	mov    %edx,0x14(%ebp)
  800812:	8b 00                	mov    (%eax),%eax
  800814:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800817:	89 c1                	mov    %eax,%ecx
  800819:	c1 f9 1f             	sar    $0x1f,%ecx
  80081c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800822:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800825:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80082a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80082e:	79 74                	jns    8008a4 <vprintfmt+0x356>
				putch('-', putdat);
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	53                   	push   %ebx
  800834:	6a 2d                	push   $0x2d
  800836:	ff d6                	call   *%esi
				num = -(long long) num;
  800838:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80083b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80083e:	f7 d8                	neg    %eax
  800840:	83 d2 00             	adc    $0x0,%edx
  800843:	f7 da                	neg    %edx
  800845:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800848:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80084d:	eb 55                	jmp    8008a4 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80084f:	8d 45 14             	lea    0x14(%ebp),%eax
  800852:	e8 83 fc ff ff       	call   8004da <getuint>
			base = 10;
  800857:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80085c:	eb 46                	jmp    8008a4 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
  800861:	e8 74 fc ff ff       	call   8004da <getuint>
			base = 8;
  800866:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80086b:	eb 37                	jmp    8008a4 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	53                   	push   %ebx
  800871:	6a 30                	push   $0x30
  800873:	ff d6                	call   *%esi
			putch('x', putdat);
  800875:	83 c4 08             	add    $0x8,%esp
  800878:	53                   	push   %ebx
  800879:	6a 78                	push   $0x78
  80087b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087d:	8b 45 14             	mov    0x14(%ebp),%eax
  800880:	8d 50 04             	lea    0x4(%eax),%edx
  800883:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800886:	8b 00                	mov    (%eax),%eax
  800888:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80088d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800890:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800895:	eb 0d                	jmp    8008a4 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
  80089a:	e8 3b fc ff ff       	call   8004da <getuint>
			base = 16;
  80089f:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008a4:	83 ec 0c             	sub    $0xc,%esp
  8008a7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008ab:	57                   	push   %edi
  8008ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8008af:	51                   	push   %ecx
  8008b0:	52                   	push   %edx
  8008b1:	50                   	push   %eax
  8008b2:	89 da                	mov    %ebx,%edx
  8008b4:	89 f0                	mov    %esi,%eax
  8008b6:	e8 70 fb ff ff       	call   80042b <printnum>
			break;
  8008bb:	83 c4 20             	add    $0x20,%esp
  8008be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c1:	e9 ae fc ff ff       	jmp    800574 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	51                   	push   %ecx
  8008cb:	ff d6                	call   *%esi
			break;
  8008cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008d3:	e9 9c fc ff ff       	jmp    800574 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	6a 25                	push   $0x25
  8008de:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	eb 03                	jmp    8008e8 <vprintfmt+0x39a>
  8008e5:	83 ef 01             	sub    $0x1,%edi
  8008e8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ec:	75 f7                	jne    8008e5 <vprintfmt+0x397>
  8008ee:	e9 81 fc ff ff       	jmp    800574 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5f                   	pop    %edi
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	83 ec 18             	sub    $0x18,%esp
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800907:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80090a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80090e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800911:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800918:	85 c0                	test   %eax,%eax
  80091a:	74 26                	je     800942 <vsnprintf+0x47>
  80091c:	85 d2                	test   %edx,%edx
  80091e:	7e 22                	jle    800942 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800920:	ff 75 14             	pushl  0x14(%ebp)
  800923:	ff 75 10             	pushl  0x10(%ebp)
  800926:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800929:	50                   	push   %eax
  80092a:	68 14 05 80 00       	push   $0x800514
  80092f:	e8 1a fc ff ff       	call   80054e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800934:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800937:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80093a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80093d:	83 c4 10             	add    $0x10,%esp
  800940:	eb 05                	jmp    800947 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800942:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80094f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800952:	50                   	push   %eax
  800953:	ff 75 10             	pushl  0x10(%ebp)
  800956:	ff 75 0c             	pushl  0xc(%ebp)
  800959:	ff 75 08             	pushl  0x8(%ebp)
  80095c:	e8 9a ff ff ff       	call   8008fb <vsnprintf>
	va_end(ap);

	return rc;
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800969:	b8 00 00 00 00       	mov    $0x0,%eax
  80096e:	eb 03                	jmp    800973 <strlen+0x10>
		n++;
  800970:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800973:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800977:	75 f7                	jne    800970 <strlen+0xd>
		n++;
	return n;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800981:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	eb 03                	jmp    80098e <strnlen+0x13>
		n++;
  80098b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098e:	39 c2                	cmp    %eax,%edx
  800990:	74 08                	je     80099a <strnlen+0x1f>
  800992:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800996:	75 f3                	jne    80098b <strnlen+0x10>
  800998:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	53                   	push   %ebx
  8009a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a6:	89 c2                	mov    %eax,%edx
  8009a8:	83 c2 01             	add    $0x1,%edx
  8009ab:	83 c1 01             	add    $0x1,%ecx
  8009ae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009b2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009b5:	84 db                	test   %bl,%bl
  8009b7:	75 ef                	jne    8009a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	53                   	push   %ebx
  8009c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c3:	53                   	push   %ebx
  8009c4:	e8 9a ff ff ff       	call   800963 <strlen>
  8009c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009cc:	ff 75 0c             	pushl  0xc(%ebp)
  8009cf:	01 d8                	add    %ebx,%eax
  8009d1:	50                   	push   %eax
  8009d2:	e8 c5 ff ff ff       	call   80099c <strcpy>
	return dst;
}
  8009d7:	89 d8                	mov    %ebx,%eax
  8009d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e9:	89 f3                	mov    %esi,%ebx
  8009eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ee:	89 f2                	mov    %esi,%edx
  8009f0:	eb 0f                	jmp    800a01 <strncpy+0x23>
		*dst++ = *src;
  8009f2:	83 c2 01             	add    $0x1,%edx
  8009f5:	0f b6 01             	movzbl (%ecx),%eax
  8009f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009fb:	80 39 01             	cmpb   $0x1,(%ecx)
  8009fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a01:	39 da                	cmp    %ebx,%edx
  800a03:	75 ed                	jne    8009f2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a05:	89 f0                	mov    %esi,%eax
  800a07:	5b                   	pop    %ebx
  800a08:	5e                   	pop    %esi
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 75 08             	mov    0x8(%ebp),%esi
  800a13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a16:	8b 55 10             	mov    0x10(%ebp),%edx
  800a19:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a1b:	85 d2                	test   %edx,%edx
  800a1d:	74 21                	je     800a40 <strlcpy+0x35>
  800a1f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a23:	89 f2                	mov    %esi,%edx
  800a25:	eb 09                	jmp    800a30 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a27:	83 c2 01             	add    $0x1,%edx
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a30:	39 c2                	cmp    %eax,%edx
  800a32:	74 09                	je     800a3d <strlcpy+0x32>
  800a34:	0f b6 19             	movzbl (%ecx),%ebx
  800a37:	84 db                	test   %bl,%bl
  800a39:	75 ec                	jne    800a27 <strlcpy+0x1c>
  800a3b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a3d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a40:	29 f0                	sub    %esi,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a4f:	eb 06                	jmp    800a57 <strcmp+0x11>
		p++, q++;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a57:	0f b6 01             	movzbl (%ecx),%eax
  800a5a:	84 c0                	test   %al,%al
  800a5c:	74 04                	je     800a62 <strcmp+0x1c>
  800a5e:	3a 02                	cmp    (%edx),%al
  800a60:	74 ef                	je     800a51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a62:	0f b6 c0             	movzbl %al,%eax
  800a65:	0f b6 12             	movzbl (%edx),%edx
  800a68:	29 d0                	sub    %edx,%eax
}
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	53                   	push   %ebx
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a7b:	eb 06                	jmp    800a83 <strncmp+0x17>
		n--, p++, q++;
  800a7d:	83 c0 01             	add    $0x1,%eax
  800a80:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a83:	39 d8                	cmp    %ebx,%eax
  800a85:	74 15                	je     800a9c <strncmp+0x30>
  800a87:	0f b6 08             	movzbl (%eax),%ecx
  800a8a:	84 c9                	test   %cl,%cl
  800a8c:	74 04                	je     800a92 <strncmp+0x26>
  800a8e:	3a 0a                	cmp    (%edx),%cl
  800a90:	74 eb                	je     800a7d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a92:	0f b6 00             	movzbl (%eax),%eax
  800a95:	0f b6 12             	movzbl (%edx),%edx
  800a98:	29 d0                	sub    %edx,%eax
  800a9a:	eb 05                	jmp    800aa1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a9c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa1:	5b                   	pop    %ebx
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aae:	eb 07                	jmp    800ab7 <strchr+0x13>
		if (*s == c)
  800ab0:	38 ca                	cmp    %cl,%dl
  800ab2:	74 0f                	je     800ac3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ab4:	83 c0 01             	add    $0x1,%eax
  800ab7:	0f b6 10             	movzbl (%eax),%edx
  800aba:	84 d2                	test   %dl,%dl
  800abc:	75 f2                	jne    800ab0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800abe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acf:	eb 03                	jmp    800ad4 <strfind+0xf>
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ad7:	38 ca                	cmp    %cl,%dl
  800ad9:	74 04                	je     800adf <strfind+0x1a>
  800adb:	84 d2                	test   %dl,%dl
  800add:	75 f2                	jne    800ad1 <strfind+0xc>
			break;
	return (char *) s;
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	57                   	push   %edi
  800ae5:	56                   	push   %esi
  800ae6:	53                   	push   %ebx
  800ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aed:	85 c9                	test   %ecx,%ecx
  800aef:	74 36                	je     800b27 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af7:	75 28                	jne    800b21 <memset+0x40>
  800af9:	f6 c1 03             	test   $0x3,%cl
  800afc:	75 23                	jne    800b21 <memset+0x40>
		c &= 0xFF;
  800afe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b02:	89 d3                	mov    %edx,%ebx
  800b04:	c1 e3 08             	shl    $0x8,%ebx
  800b07:	89 d6                	mov    %edx,%esi
  800b09:	c1 e6 18             	shl    $0x18,%esi
  800b0c:	89 d0                	mov    %edx,%eax
  800b0e:	c1 e0 10             	shl    $0x10,%eax
  800b11:	09 f0                	or     %esi,%eax
  800b13:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b15:	89 d8                	mov    %ebx,%eax
  800b17:	09 d0                	or     %edx,%eax
  800b19:	c1 e9 02             	shr    $0x2,%ecx
  800b1c:	fc                   	cld    
  800b1d:	f3 ab                	rep stos %eax,%es:(%edi)
  800b1f:	eb 06                	jmp    800b27 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	fc                   	cld    
  800b25:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b27:	89 f8                	mov    %edi,%eax
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	57                   	push   %edi
  800b32:	56                   	push   %esi
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b3c:	39 c6                	cmp    %eax,%esi
  800b3e:	73 35                	jae    800b75 <memmove+0x47>
  800b40:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b43:	39 d0                	cmp    %edx,%eax
  800b45:	73 2e                	jae    800b75 <memmove+0x47>
		s += n;
		d += n;
  800b47:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	09 fe                	or     %edi,%esi
  800b4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b54:	75 13                	jne    800b69 <memmove+0x3b>
  800b56:	f6 c1 03             	test   $0x3,%cl
  800b59:	75 0e                	jne    800b69 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b5b:	83 ef 04             	sub    $0x4,%edi
  800b5e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b61:	c1 e9 02             	shr    $0x2,%ecx
  800b64:	fd                   	std    
  800b65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b67:	eb 09                	jmp    800b72 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b69:	83 ef 01             	sub    $0x1,%edi
  800b6c:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b6f:	fd                   	std    
  800b70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b72:	fc                   	cld    
  800b73:	eb 1d                	jmp    800b92 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b75:	89 f2                	mov    %esi,%edx
  800b77:	09 c2                	or     %eax,%edx
  800b79:	f6 c2 03             	test   $0x3,%dl
  800b7c:	75 0f                	jne    800b8d <memmove+0x5f>
  800b7e:	f6 c1 03             	test   $0x3,%cl
  800b81:	75 0a                	jne    800b8d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b83:	c1 e9 02             	shr    $0x2,%ecx
  800b86:	89 c7                	mov    %eax,%edi
  800b88:	fc                   	cld    
  800b89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8b:	eb 05                	jmp    800b92 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b8d:	89 c7                	mov    %eax,%edi
  800b8f:	fc                   	cld    
  800b90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b99:	ff 75 10             	pushl  0x10(%ebp)
  800b9c:	ff 75 0c             	pushl  0xc(%ebp)
  800b9f:	ff 75 08             	pushl  0x8(%ebp)
  800ba2:	e8 87 ff ff ff       	call   800b2e <memmove>
}
  800ba7:	c9                   	leave  
  800ba8:	c3                   	ret    

00800ba9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb4:	89 c6                	mov    %eax,%esi
  800bb6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb9:	eb 1a                	jmp    800bd5 <memcmp+0x2c>
		if (*s1 != *s2)
  800bbb:	0f b6 08             	movzbl (%eax),%ecx
  800bbe:	0f b6 1a             	movzbl (%edx),%ebx
  800bc1:	38 d9                	cmp    %bl,%cl
  800bc3:	74 0a                	je     800bcf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bc5:	0f b6 c1             	movzbl %cl,%eax
  800bc8:	0f b6 db             	movzbl %bl,%ebx
  800bcb:	29 d8                	sub    %ebx,%eax
  800bcd:	eb 0f                	jmp    800bde <memcmp+0x35>
		s1++, s2++;
  800bcf:	83 c0 01             	add    $0x1,%eax
  800bd2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd5:	39 f0                	cmp    %esi,%eax
  800bd7:	75 e2                	jne    800bbb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	53                   	push   %ebx
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800be9:	89 c1                	mov    %eax,%ecx
  800beb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bf2:	eb 0a                	jmp    800bfe <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf4:	0f b6 10             	movzbl (%eax),%edx
  800bf7:	39 da                	cmp    %ebx,%edx
  800bf9:	74 07                	je     800c02 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bfb:	83 c0 01             	add    $0x1,%eax
  800bfe:	39 c8                	cmp    %ecx,%eax
  800c00:	72 f2                	jb     800bf4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c02:	5b                   	pop    %ebx
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	57                   	push   %edi
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c11:	eb 03                	jmp    800c16 <strtol+0x11>
		s++;
  800c13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c16:	0f b6 01             	movzbl (%ecx),%eax
  800c19:	3c 20                	cmp    $0x20,%al
  800c1b:	74 f6                	je     800c13 <strtol+0xe>
  800c1d:	3c 09                	cmp    $0x9,%al
  800c1f:	74 f2                	je     800c13 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c21:	3c 2b                	cmp    $0x2b,%al
  800c23:	75 0a                	jne    800c2f <strtol+0x2a>
		s++;
  800c25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c28:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2d:	eb 11                	jmp    800c40 <strtol+0x3b>
  800c2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c34:	3c 2d                	cmp    $0x2d,%al
  800c36:	75 08                	jne    800c40 <strtol+0x3b>
		s++, neg = 1;
  800c38:	83 c1 01             	add    $0x1,%ecx
  800c3b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c46:	75 15                	jne    800c5d <strtol+0x58>
  800c48:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4b:	75 10                	jne    800c5d <strtol+0x58>
  800c4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c51:	75 7c                	jne    800ccf <strtol+0xca>
		s += 2, base = 16;
  800c53:	83 c1 02             	add    $0x2,%ecx
  800c56:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5b:	eb 16                	jmp    800c73 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c5d:	85 db                	test   %ebx,%ebx
  800c5f:	75 12                	jne    800c73 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c66:	80 39 30             	cmpb   $0x30,(%ecx)
  800c69:	75 08                	jne    800c73 <strtol+0x6e>
		s++, base = 8;
  800c6b:	83 c1 01             	add    $0x1,%ecx
  800c6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
  800c78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c7b:	0f b6 11             	movzbl (%ecx),%edx
  800c7e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c81:	89 f3                	mov    %esi,%ebx
  800c83:	80 fb 09             	cmp    $0x9,%bl
  800c86:	77 08                	ja     800c90 <strtol+0x8b>
			dig = *s - '0';
  800c88:	0f be d2             	movsbl %dl,%edx
  800c8b:	83 ea 30             	sub    $0x30,%edx
  800c8e:	eb 22                	jmp    800cb2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c90:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c93:	89 f3                	mov    %esi,%ebx
  800c95:	80 fb 19             	cmp    $0x19,%bl
  800c98:	77 08                	ja     800ca2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c9a:	0f be d2             	movsbl %dl,%edx
  800c9d:	83 ea 57             	sub    $0x57,%edx
  800ca0:	eb 10                	jmp    800cb2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ca2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca5:	89 f3                	mov    %esi,%ebx
  800ca7:	80 fb 19             	cmp    $0x19,%bl
  800caa:	77 16                	ja     800cc2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cac:	0f be d2             	movsbl %dl,%edx
  800caf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cb2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb5:	7d 0b                	jge    800cc2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cb7:	83 c1 01             	add    $0x1,%ecx
  800cba:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cc0:	eb b9                	jmp    800c7b <strtol+0x76>

	if (endptr)
  800cc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc6:	74 0d                	je     800cd5 <strtol+0xd0>
		*endptr = (char *) s;
  800cc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccb:	89 0e                	mov    %ecx,(%esi)
  800ccd:	eb 06                	jmp    800cd5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccf:	85 db                	test   %ebx,%ebx
  800cd1:	74 98                	je     800c6b <strtol+0x66>
  800cd3:	eb 9e                	jmp    800c73 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cd5:	89 c2                	mov    %eax,%edx
  800cd7:	f7 da                	neg    %edx
  800cd9:	85 ff                	test   %edi,%edi
  800cdb:	0f 45 c2             	cmovne %edx,%eax
}
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800cea:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800cf1:	75 57                	jne    800d4a <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");
		envid_t e_id = sys_getenvid();
  800cf3:	e8 32 f4 ff ff       	call   80012a <sys_getenvid>
  800cf8:	89 c3                	mov    %eax,%ebx
		r = sys_page_alloc(e_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800cfa:	83 ec 04             	sub    $0x4,%esp
  800cfd:	6a 07                	push   $0x7
  800cff:	68 00 f0 bf ee       	push   $0xeebff000
  800d04:	50                   	push   %eax
  800d05:	e8 5e f4 ff ff       	call   800168 <sys_page_alloc>
		if (r < 0) {
  800d0a:	83 c4 10             	add    $0x10,%esp
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	79 12                	jns    800d23 <set_pgfault_handler+0x40>
			panic("pgfault_handler: %e", r);
  800d11:	50                   	push   %eax
  800d12:	68 a4 12 80 00       	push   $0x8012a4
  800d17:	6a 24                	push   $0x24
  800d19:	68 b8 12 80 00       	push   $0x8012b8
  800d1e:	e8 1b f6 ff ff       	call   80033e <_panic>
		}
		// r = sys_env_set_pgfault_upcall(e_id, handler);
		r = sys_env_set_pgfault_upcall(e_id, _pgfault_upcall);
  800d23:	83 ec 08             	sub    $0x8,%esp
  800d26:	68 17 03 80 00       	push   $0x800317
  800d2b:	53                   	push   %ebx
  800d2c:	e8 40 f5 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d31:	83 c4 10             	add    $0x10,%esp
  800d34:	85 c0                	test   %eax,%eax
  800d36:	79 12                	jns    800d4a <set_pgfault_handler+0x67>
			panic("pgfault_handler: %e", r);
  800d38:	50                   	push   %eax
  800d39:	68 a4 12 80 00       	push   $0x8012a4
  800d3e:	6a 29                	push   $0x29
  800d40:	68 b8 12 80 00       	push   $0x8012b8
  800d45:	e8 f4 f5 ff ff       	call   80033e <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d52:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d55:	c9                   	leave  
  800d56:	c3                   	ret    
  800d57:	66 90                	xchg   %ax,%ax
  800d59:	66 90                	xchg   %ax,%ax
  800d5b:	66 90                	xchg   %ax,%ax
  800d5d:	66 90                	xchg   %ax,%ax
  800d5f:	90                   	nop

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d77:	85 f6                	test   %esi,%esi
  800d79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d7d:	89 ca                	mov    %ecx,%edx
  800d7f:	89 f8                	mov    %edi,%eax
  800d81:	75 3d                	jne    800dc0 <__udivdi3+0x60>
  800d83:	39 cf                	cmp    %ecx,%edi
  800d85:	0f 87 c5 00 00 00    	ja     800e50 <__udivdi3+0xf0>
  800d8b:	85 ff                	test   %edi,%edi
  800d8d:	89 fd                	mov    %edi,%ebp
  800d8f:	75 0b                	jne    800d9c <__udivdi3+0x3c>
  800d91:	b8 01 00 00 00       	mov    $0x1,%eax
  800d96:	31 d2                	xor    %edx,%edx
  800d98:	f7 f7                	div    %edi
  800d9a:	89 c5                	mov    %eax,%ebp
  800d9c:	89 c8                	mov    %ecx,%eax
  800d9e:	31 d2                	xor    %edx,%edx
  800da0:	f7 f5                	div    %ebp
  800da2:	89 c1                	mov    %eax,%ecx
  800da4:	89 d8                	mov    %ebx,%eax
  800da6:	89 cf                	mov    %ecx,%edi
  800da8:	f7 f5                	div    %ebp
  800daa:	89 c3                	mov    %eax,%ebx
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
  800dc0:	39 ce                	cmp    %ecx,%esi
  800dc2:	77 74                	ja     800e38 <__udivdi3+0xd8>
  800dc4:	0f bd fe             	bsr    %esi,%edi
  800dc7:	83 f7 1f             	xor    $0x1f,%edi
  800dca:	0f 84 98 00 00 00    	je     800e68 <__udivdi3+0x108>
  800dd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800dd5:	89 f9                	mov    %edi,%ecx
  800dd7:	89 c5                	mov    %eax,%ebp
  800dd9:	29 fb                	sub    %edi,%ebx
  800ddb:	d3 e6                	shl    %cl,%esi
  800ddd:	89 d9                	mov    %ebx,%ecx
  800ddf:	d3 ed                	shr    %cl,%ebp
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e0                	shl    %cl,%eax
  800de5:	09 ee                	or     %ebp,%esi
  800de7:	89 d9                	mov    %ebx,%ecx
  800de9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ded:	89 d5                	mov    %edx,%ebp
  800def:	8b 44 24 08          	mov    0x8(%esp),%eax
  800df3:	d3 ed                	shr    %cl,%ebp
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	d3 e2                	shl    %cl,%edx
  800df9:	89 d9                	mov    %ebx,%ecx
  800dfb:	d3 e8                	shr    %cl,%eax
  800dfd:	09 c2                	or     %eax,%edx
  800dff:	89 d0                	mov    %edx,%eax
  800e01:	89 ea                	mov    %ebp,%edx
  800e03:	f7 f6                	div    %esi
  800e05:	89 d5                	mov    %edx,%ebp
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	f7 64 24 0c          	mull   0xc(%esp)
  800e0d:	39 d5                	cmp    %edx,%ebp
  800e0f:	72 10                	jb     800e21 <__udivdi3+0xc1>
  800e11:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	d3 e6                	shl    %cl,%esi
  800e19:	39 c6                	cmp    %eax,%esi
  800e1b:	73 07                	jae    800e24 <__udivdi3+0xc4>
  800e1d:	39 d5                	cmp    %edx,%ebp
  800e1f:	75 03                	jne    800e24 <__udivdi3+0xc4>
  800e21:	83 eb 01             	sub    $0x1,%ebx
  800e24:	31 ff                	xor    %edi,%edi
  800e26:	89 d8                	mov    %ebx,%eax
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	31 ff                	xor    %edi,%edi
  800e3a:	31 db                	xor    %ebx,%ebx
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	89 fa                	mov    %edi,%edx
  800e40:	83 c4 1c             	add    $0x1c,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    
  800e48:	90                   	nop
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	f7 f7                	div    %edi
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 c3                	mov    %eax,%ebx
  800e58:	89 d8                	mov    %ebx,%eax
  800e5a:	89 fa                	mov    %edi,%edx
  800e5c:	83 c4 1c             	add    $0x1c,%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
  800e64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e68:	39 ce                	cmp    %ecx,%esi
  800e6a:	72 0c                	jb     800e78 <__udivdi3+0x118>
  800e6c:	31 db                	xor    %ebx,%ebx
  800e6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e72:	0f 87 34 ff ff ff    	ja     800dac <__udivdi3+0x4c>
  800e78:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e7d:	e9 2a ff ff ff       	jmp    800dac <__udivdi3+0x4c>
  800e82:	66 90                	xchg   %ax,%ax
  800e84:	66 90                	xchg   %ax,%ax
  800e86:	66 90                	xchg   %ax,%ax
  800e88:	66 90                	xchg   %ax,%ax
  800e8a:	66 90                	xchg   %ax,%ax
  800e8c:	66 90                	xchg   %ax,%ax
  800e8e:	66 90                	xchg   %ax,%ax

00800e90 <__umoddi3>:
  800e90:	55                   	push   %ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
  800e97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ea7:	85 d2                	test   %edx,%edx
  800ea9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ead:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eb1:	89 f3                	mov    %esi,%ebx
  800eb3:	89 3c 24             	mov    %edi,(%esp)
  800eb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eba:	75 1c                	jne    800ed8 <__umoddi3+0x48>
  800ebc:	39 f7                	cmp    %esi,%edi
  800ebe:	76 50                	jbe    800f10 <__umoddi3+0x80>
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	f7 f7                	div    %edi
  800ec6:	89 d0                	mov    %edx,%eax
  800ec8:	31 d2                	xor    %edx,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	89 d0                	mov    %edx,%eax
  800edc:	77 52                	ja     800f30 <__umoddi3+0xa0>
  800ede:	0f bd ea             	bsr    %edx,%ebp
  800ee1:	83 f5 1f             	xor    $0x1f,%ebp
  800ee4:	75 5a                	jne    800f40 <__umoddi3+0xb0>
  800ee6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800eea:	0f 82 e0 00 00 00    	jb     800fd0 <__umoddi3+0x140>
  800ef0:	39 0c 24             	cmp    %ecx,(%esp)
  800ef3:	0f 86 d7 00 00 00    	jbe    800fd0 <__umoddi3+0x140>
  800ef9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800efd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f01:	83 c4 1c             	add    $0x1c,%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	85 ff                	test   %edi,%edi
  800f12:	89 fd                	mov    %edi,%ebp
  800f14:	75 0b                	jne    800f21 <__umoddi3+0x91>
  800f16:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1b:	31 d2                	xor    %edx,%edx
  800f1d:	f7 f7                	div    %edi
  800f1f:	89 c5                	mov    %eax,%ebp
  800f21:	89 f0                	mov    %esi,%eax
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	f7 f5                	div    %ebp
  800f27:	89 c8                	mov    %ecx,%eax
  800f29:	f7 f5                	div    %ebp
  800f2b:	89 d0                	mov    %edx,%eax
  800f2d:	eb 99                	jmp    800ec8 <__umoddi3+0x38>
  800f2f:	90                   	nop
  800f30:	89 c8                	mov    %ecx,%eax
  800f32:	89 f2                	mov    %esi,%edx
  800f34:	83 c4 1c             	add    $0x1c,%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    
  800f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f40:	8b 34 24             	mov    (%esp),%esi
  800f43:	bf 20 00 00 00       	mov    $0x20,%edi
  800f48:	89 e9                	mov    %ebp,%ecx
  800f4a:	29 ef                	sub    %ebp,%edi
  800f4c:	d3 e0                	shl    %cl,%eax
  800f4e:	89 f9                	mov    %edi,%ecx
  800f50:	89 f2                	mov    %esi,%edx
  800f52:	d3 ea                	shr    %cl,%edx
  800f54:	89 e9                	mov    %ebp,%ecx
  800f56:	09 c2                	or     %eax,%edx
  800f58:	89 d8                	mov    %ebx,%eax
  800f5a:	89 14 24             	mov    %edx,(%esp)
  800f5d:	89 f2                	mov    %esi,%edx
  800f5f:	d3 e2                	shl    %cl,%edx
  800f61:	89 f9                	mov    %edi,%ecx
  800f63:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	89 e9                	mov    %ebp,%ecx
  800f6f:	89 c6                	mov    %eax,%esi
  800f71:	d3 e3                	shl    %cl,%ebx
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	89 d0                	mov    %edx,%eax
  800f77:	d3 e8                	shr    %cl,%eax
  800f79:	89 e9                	mov    %ebp,%ecx
  800f7b:	09 d8                	or     %ebx,%eax
  800f7d:	89 d3                	mov    %edx,%ebx
  800f7f:	89 f2                	mov    %esi,%edx
  800f81:	f7 34 24             	divl   (%esp)
  800f84:	89 d6                	mov    %edx,%esi
  800f86:	d3 e3                	shl    %cl,%ebx
  800f88:	f7 64 24 04          	mull   0x4(%esp)
  800f8c:	39 d6                	cmp    %edx,%esi
  800f8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	89 c3                	mov    %eax,%ebx
  800f96:	72 08                	jb     800fa0 <__umoddi3+0x110>
  800f98:	75 11                	jne    800fab <__umoddi3+0x11b>
  800f9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f9e:	73 0b                	jae    800fab <__umoddi3+0x11b>
  800fa0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fa4:	1b 14 24             	sbb    (%esp),%edx
  800fa7:	89 d1                	mov    %edx,%ecx
  800fa9:	89 c3                	mov    %eax,%ebx
  800fab:	8b 54 24 08          	mov    0x8(%esp),%edx
  800faf:	29 da                	sub    %ebx,%edx
  800fb1:	19 ce                	sbb    %ecx,%esi
  800fb3:	89 f9                	mov    %edi,%ecx
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	d3 e0                	shl    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	d3 ea                	shr    %cl,%edx
  800fbd:	89 e9                	mov    %ebp,%ecx
  800fbf:	d3 ee                	shr    %cl,%esi
  800fc1:	09 d0                	or     %edx,%eax
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	83 c4 1c             	add    $0x1c,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	29 f9                	sub    %edi,%ecx
  800fd2:	19 d6                	sbb    %edx,%esi
  800fd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdc:	e9 18 ff ff ff       	jmp    800ef9 <__umoddi3+0x69>
