
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 c6 00 00 00       	call   800118 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 4a 0f 80 00       	push   $0x800f4a
  800104:	6a 23                	push   $0x23
  800106:	68 67 0f 80 00       	push   $0x800f67
  80010b:	e8 f5 01 00 00       	call   800305 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0a 00 00 00       	mov    $0xa,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 4a 0f 80 00       	push   $0x800f4a
  800185:	6a 23                	push   $0x23
  800187:	68 67 0f 80 00       	push   $0x800f67
  80018c:	e8 74 01 00 00       	call   800305 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 4a 0f 80 00       	push   $0x800f4a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 67 0f 80 00       	push   $0x800f67
  8001ce:	e8 32 01 00 00       	call   800305 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 4a 0f 80 00       	push   $0x800f4a
  800209:	6a 23                	push   $0x23
  80020b:	68 67 0f 80 00       	push   $0x800f67
  800210:	e8 f0 00 00 00       	call   800305 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 4a 0f 80 00       	push   $0x800f4a
  80024b:	6a 23                	push   $0x23
  80024d:	68 67 0f 80 00       	push   $0x800f67
  800252:	e8 ae 00 00 00       	call   800305 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 4a 0f 80 00       	push   $0x800f4a
  80028d:	6a 23                	push   $0x23
  80028f:	68 67 0f 80 00       	push   $0x800f67
  800294:	e8 6c 00 00 00       	call   800305 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a7:	be 00 00 00 00       	mov    $0x0,%esi
  8002ac:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002bd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
  8002ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	89 cb                	mov    %ecx,%ebx
  8002dc:	89 cf                	mov    %ecx,%edi
  8002de:	89 ce                	mov    %ecx,%esi
  8002e0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	7e 17                	jle    8002fd <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0c                	push   $0xc
  8002ec:	68 4a 0f 80 00       	push   $0x800f4a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 67 0f 80 00       	push   $0x800f67
  8002f8:	e8 08 00 00 00       	call   800305 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800313:	e8 00 fe ff ff       	call   800118 <sys_getenvid>
  800318:	83 ec 0c             	sub    $0xc,%esp
  80031b:	ff 75 0c             	pushl  0xc(%ebp)
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	56                   	push   %esi
  800322:	50                   	push   %eax
  800323:	68 78 0f 80 00       	push   $0x800f78
  800328:	e8 b1 00 00 00       	call   8003de <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80032d:	83 c4 18             	add    $0x18,%esp
  800330:	53                   	push   %ebx
  800331:	ff 75 10             	pushl  0x10(%ebp)
  800334:	e8 54 00 00 00       	call   80038d <vcprintf>
	cprintf("\n");
  800339:	c7 04 24 9c 0f 80 00 	movl   $0x800f9c,(%esp)
  800340:	e8 99 00 00 00       	call   8003de <cprintf>
  800345:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800348:	cc                   	int3   
  800349:	eb fd                	jmp    800348 <_panic+0x43>

0080034b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	53                   	push   %ebx
  80034f:	83 ec 04             	sub    $0x4,%esp
  800352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800355:	8b 13                	mov    (%ebx),%edx
  800357:	8d 42 01             	lea    0x1(%edx),%eax
  80035a:	89 03                	mov    %eax,(%ebx)
  80035c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800363:	3d ff 00 00 00       	cmp    $0xff,%eax
  800368:	75 1a                	jne    800384 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	68 ff 00 00 00       	push   $0xff
  800372:	8d 43 08             	lea    0x8(%ebx),%eax
  800375:	50                   	push   %eax
  800376:	e8 1f fd ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80037b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800381:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800384:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800388:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800396:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039d:	00 00 00 
	b.cnt = 0;
  8003a0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003aa:	ff 75 0c             	pushl  0xc(%ebp)
  8003ad:	ff 75 08             	pushl  0x8(%ebp)
  8003b0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b6:	50                   	push   %eax
  8003b7:	68 4b 03 80 00       	push   $0x80034b
  8003bc:	e8 54 01 00 00       	call   800515 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c1:	83 c4 08             	add    $0x8,%esp
  8003c4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d0:	50                   	push   %eax
  8003d1:	e8 c4 fc ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8003d6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003dc:	c9                   	leave  
  8003dd:	c3                   	ret    

008003de <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e7:	50                   	push   %eax
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	e8 9d ff ff ff       	call   80038d <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f0:	c9                   	leave  
  8003f1:	c3                   	ret    

008003f2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 1c             	sub    $0x1c,%esp
  8003fb:	89 c7                	mov    %eax,%edi
  8003fd:	89 d6                	mov    %edx,%esi
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800408:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800413:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800416:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800419:	39 d3                	cmp    %edx,%ebx
  80041b:	72 05                	jb     800422 <printnum+0x30>
  80041d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800420:	77 45                	ja     800467 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800422:	83 ec 0c             	sub    $0xc,%esp
  800425:	ff 75 18             	pushl  0x18(%ebp)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042e:	53                   	push   %ebx
  80042f:	ff 75 10             	pushl  0x10(%ebp)
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	ff 75 e4             	pushl  -0x1c(%ebp)
  800438:	ff 75 e0             	pushl  -0x20(%ebp)
  80043b:	ff 75 dc             	pushl  -0x24(%ebp)
  80043e:	ff 75 d8             	pushl  -0x28(%ebp)
  800441:	e8 6a 08 00 00       	call   800cb0 <__udivdi3>
  800446:	83 c4 18             	add    $0x18,%esp
  800449:	52                   	push   %edx
  80044a:	50                   	push   %eax
  80044b:	89 f2                	mov    %esi,%edx
  80044d:	89 f8                	mov    %edi,%eax
  80044f:	e8 9e ff ff ff       	call   8003f2 <printnum>
  800454:	83 c4 20             	add    $0x20,%esp
  800457:	eb 18                	jmp    800471 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800459:	83 ec 08             	sub    $0x8,%esp
  80045c:	56                   	push   %esi
  80045d:	ff 75 18             	pushl  0x18(%ebp)
  800460:	ff d7                	call   *%edi
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	eb 03                	jmp    80046a <printnum+0x78>
  800467:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	85 db                	test   %ebx,%ebx
  80046f:	7f e8                	jg     800459 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	56                   	push   %esi
  800475:	83 ec 04             	sub    $0x4,%esp
  800478:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047b:	ff 75 e0             	pushl  -0x20(%ebp)
  80047e:	ff 75 dc             	pushl  -0x24(%ebp)
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	e8 57 09 00 00       	call   800de0 <__umoddi3>
  800489:	83 c4 14             	add    $0x14,%esp
  80048c:	0f be 80 9e 0f 80 00 	movsbl 0x800f9e(%eax),%eax
  800493:	50                   	push   %eax
  800494:	ff d7                	call   *%edi
}
  800496:	83 c4 10             	add    $0x10,%esp
  800499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049c:	5b                   	pop    %ebx
  80049d:	5e                   	pop    %esi
  80049e:	5f                   	pop    %edi
  80049f:	5d                   	pop    %ebp
  8004a0:	c3                   	ret    

008004a1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a4:	83 fa 01             	cmp    $0x1,%edx
  8004a7:	7e 0e                	jle    8004b7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 02                	mov    (%edx),%eax
  8004b2:	8b 52 04             	mov    0x4(%edx),%edx
  8004b5:	eb 22                	jmp    8004d9 <getuint+0x38>
	else if (lflag)
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	74 10                	je     8004cb <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c0:	89 08                	mov    %ecx,(%eax)
  8004c2:	8b 02                	mov    (%edx),%eax
  8004c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c9:	eb 0e                	jmp    8004d9 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d0:	89 08                	mov    %ecx,(%eax)
  8004d2:	8b 02                	mov    (%edx),%eax
  8004d4:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ea:	73 0a                	jae    8004f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	88 02                	mov    %al,(%edx)
}
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800501:	50                   	push   %eax
  800502:	ff 75 10             	pushl  0x10(%ebp)
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	ff 75 08             	pushl  0x8(%ebp)
  80050b:	e8 05 00 00 00       	call   800515 <vprintfmt>
	va_end(ap);
}
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	c9                   	leave  
  800514:	c3                   	ret    

00800515 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	57                   	push   %edi
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 2c             	sub    $0x2c,%esp
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	8b 7d 10             	mov    0x10(%ebp),%edi
  800527:	eb 12                	jmp    80053b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800529:	85 c0                	test   %eax,%eax
  80052b:	0f 84 89 03 00 00    	je     8008ba <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	53                   	push   %ebx
  800535:	50                   	push   %eax
  800536:	ff d6                	call   *%esi
  800538:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80053b:	83 c7 01             	add    $0x1,%edi
  80053e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800542:	83 f8 25             	cmp    $0x25,%eax
  800545:	75 e2                	jne    800529 <vprintfmt+0x14>
  800547:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80054b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800552:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800559:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800560:	ba 00 00 00 00       	mov    $0x0,%edx
  800565:	eb 07                	jmp    80056e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800567:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8d 47 01             	lea    0x1(%edi),%eax
  800571:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800574:	0f b6 07             	movzbl (%edi),%eax
  800577:	0f b6 c8             	movzbl %al,%ecx
  80057a:	83 e8 23             	sub    $0x23,%eax
  80057d:	3c 55                	cmp    $0x55,%al
  80057f:	0f 87 1a 03 00 00    	ja     80089f <vprintfmt+0x38a>
  800585:	0f b6 c0             	movzbl %al,%eax
  800588:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800592:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800596:	eb d6                	jmp    80056e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059b:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005aa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005ad:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b0:	83 fa 09             	cmp    $0x9,%edx
  8005b3:	77 39                	ja     8005ee <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b8:	eb e9                	jmp    8005a3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c0:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005cb:	eb 27                	jmp    8005f4 <vprintfmt+0xdf>
  8005cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d7:	0f 49 c8             	cmovns %eax,%ecx
  8005da:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e0:	eb 8c                	jmp    80056e <vprintfmt+0x59>
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e5:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ec:	eb 80                	jmp    80056e <vprintfmt+0x59>
  8005ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f8:	0f 89 70 ff ff ff    	jns    80056e <vprintfmt+0x59>
				width = precision, precision = -1;
  8005fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800601:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800604:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80060b:	e9 5e ff ff ff       	jmp    80056e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800610:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800616:	e9 53 ff ff ff       	jmp    80056e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	ff 30                	pushl  (%eax)
  80062a:	ff d6                	call   *%esi
			break;
  80062c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800632:	e9 04 ff ff ff       	jmp    80053b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 50 04             	lea    0x4(%eax),%edx
  80063d:	89 55 14             	mov    %edx,0x14(%ebp)
  800640:	8b 00                	mov    (%eax),%eax
  800642:	99                   	cltd   
  800643:	31 d0                	xor    %edx,%eax
  800645:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800647:	83 f8 08             	cmp    $0x8,%eax
  80064a:	7f 0b                	jg     800657 <vprintfmt+0x142>
  80064c:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  800653:	85 d2                	test   %edx,%edx
  800655:	75 18                	jne    80066f <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800657:	50                   	push   %eax
  800658:	68 b6 0f 80 00       	push   $0x800fb6
  80065d:	53                   	push   %ebx
  80065e:	56                   	push   %esi
  80065f:	e8 94 fe ff ff       	call   8004f8 <printfmt>
  800664:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066a:	e9 cc fe ff ff       	jmp    80053b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80066f:	52                   	push   %edx
  800670:	68 bf 0f 80 00       	push   $0x800fbf
  800675:	53                   	push   %ebx
  800676:	56                   	push   %esi
  800677:	e8 7c fe ff ff       	call   8004f8 <printfmt>
  80067c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800682:	e9 b4 fe ff ff       	jmp    80053b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
  800690:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800692:	85 ff                	test   %edi,%edi
  800694:	b8 af 0f 80 00       	mov    $0x800faf,%eax
  800699:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80069c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a0:	0f 8e 94 00 00 00    	jle    80073a <vprintfmt+0x225>
  8006a6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006aa:	0f 84 98 00 00 00    	je     800748 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b0:	83 ec 08             	sub    $0x8,%esp
  8006b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b6:	57                   	push   %edi
  8006b7:	e8 86 02 00 00       	call   800942 <strnlen>
  8006bc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006bf:	29 c1                	sub    %eax,%ecx
  8006c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c4:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c7:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d1:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d3:	eb 0f                	jmp    8006e4 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dc:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006de:	83 ef 01             	sub    $0x1,%edi
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	85 ff                	test   %edi,%edi
  8006e6:	7f ed                	jg     8006d5 <vprintfmt+0x1c0>
  8006e8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006eb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006ee:	85 c9                	test   %ecx,%ecx
  8006f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f5:	0f 49 c1             	cmovns %ecx,%eax
  8006f8:	29 c1                	sub    %eax,%ecx
  8006fa:	89 75 08             	mov    %esi,0x8(%ebp)
  8006fd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800700:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800703:	89 cb                	mov    %ecx,%ebx
  800705:	eb 4d                	jmp    800754 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800707:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070b:	74 1b                	je     800728 <vprintfmt+0x213>
  80070d:	0f be c0             	movsbl %al,%eax
  800710:	83 e8 20             	sub    $0x20,%eax
  800713:	83 f8 5e             	cmp    $0x5e,%eax
  800716:	76 10                	jbe    800728 <vprintfmt+0x213>
					putch('?', putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	ff 75 0c             	pushl  0xc(%ebp)
  80071e:	6a 3f                	push   $0x3f
  800720:	ff 55 08             	call   *0x8(%ebp)
  800723:	83 c4 10             	add    $0x10,%esp
  800726:	eb 0d                	jmp    800735 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	ff 75 0c             	pushl  0xc(%ebp)
  80072e:	52                   	push   %edx
  80072f:	ff 55 08             	call   *0x8(%ebp)
  800732:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800735:	83 eb 01             	sub    $0x1,%ebx
  800738:	eb 1a                	jmp    800754 <vprintfmt+0x23f>
  80073a:	89 75 08             	mov    %esi,0x8(%ebp)
  80073d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800740:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800743:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800746:	eb 0c                	jmp    800754 <vprintfmt+0x23f>
  800748:	89 75 08             	mov    %esi,0x8(%ebp)
  80074b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800751:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800754:	83 c7 01             	add    $0x1,%edi
  800757:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80075b:	0f be d0             	movsbl %al,%edx
  80075e:	85 d2                	test   %edx,%edx
  800760:	74 23                	je     800785 <vprintfmt+0x270>
  800762:	85 f6                	test   %esi,%esi
  800764:	78 a1                	js     800707 <vprintfmt+0x1f2>
  800766:	83 ee 01             	sub    $0x1,%esi
  800769:	79 9c                	jns    800707 <vprintfmt+0x1f2>
  80076b:	89 df                	mov    %ebx,%edi
  80076d:	8b 75 08             	mov    0x8(%ebp),%esi
  800770:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800773:	eb 18                	jmp    80078d <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 20                	push   $0x20
  80077b:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80077d:	83 ef 01             	sub    $0x1,%edi
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	eb 08                	jmp    80078d <vprintfmt+0x278>
  800785:	89 df                	mov    %ebx,%edi
  800787:	8b 75 08             	mov    0x8(%ebp),%esi
  80078a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078d:	85 ff                	test   %edi,%edi
  80078f:	7f e4                	jg     800775 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800791:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800794:	e9 a2 fd ff ff       	jmp    80053b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800799:	83 fa 01             	cmp    $0x1,%edx
  80079c:	7e 16                	jle    8007b4 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8d 50 08             	lea    0x8(%eax),%edx
  8007a4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a7:	8b 50 04             	mov    0x4(%eax),%edx
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b2:	eb 32                	jmp    8007e6 <vprintfmt+0x2d1>
	else if (lflag)
  8007b4:	85 d2                	test   %edx,%edx
  8007b6:	74 18                	je     8007d0 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8d 50 04             	lea    0x4(%eax),%edx
  8007be:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c1:	8b 00                	mov    (%eax),%eax
  8007c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c6:	89 c1                	mov    %eax,%ecx
  8007c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ce:	eb 16                	jmp    8007e6 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8d 50 04             	lea    0x4(%eax),%edx
  8007d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d9:	8b 00                	mov    (%eax),%eax
  8007db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007de:	89 c1                	mov    %eax,%ecx
  8007e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e9:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ec:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f5:	79 74                	jns    80086b <vprintfmt+0x356>
				putch('-', putdat);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	6a 2d                	push   $0x2d
  8007fd:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ff:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800802:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800805:	f7 d8                	neg    %eax
  800807:	83 d2 00             	adc    $0x0,%edx
  80080a:	f7 da                	neg    %edx
  80080c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80080f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800814:	eb 55                	jmp    80086b <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
  800819:	e8 83 fc ff ff       	call   8004a1 <getuint>
			base = 10;
  80081e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800823:	eb 46                	jmp    80086b <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 74 fc ff ff       	call   8004a1 <getuint>
			base = 8;
  80082d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800832:	eb 37                	jmp    80086b <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	53                   	push   %ebx
  800838:	6a 30                	push   $0x30
  80083a:	ff d6                	call   *%esi
			putch('x', putdat);
  80083c:	83 c4 08             	add    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 78                	push   $0x78
  800842:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 50 04             	lea    0x4(%eax),%edx
  80084a:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80084d:	8b 00                	mov    (%eax),%eax
  80084f:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800854:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800857:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80085c:	eb 0d                	jmp    80086b <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80085e:	8d 45 14             	lea    0x14(%ebp),%eax
  800861:	e8 3b fc ff ff       	call   8004a1 <getuint>
			base = 16;
  800866:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80086b:	83 ec 0c             	sub    $0xc,%esp
  80086e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800872:	57                   	push   %edi
  800873:	ff 75 e0             	pushl  -0x20(%ebp)
  800876:	51                   	push   %ecx
  800877:	52                   	push   %edx
  800878:	50                   	push   %eax
  800879:	89 da                	mov    %ebx,%edx
  80087b:	89 f0                	mov    %esi,%eax
  80087d:	e8 70 fb ff ff       	call   8003f2 <printnum>
			break;
  800882:	83 c4 20             	add    $0x20,%esp
  800885:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800888:	e9 ae fc ff ff       	jmp    80053b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	53                   	push   %ebx
  800891:	51                   	push   %ecx
  800892:	ff d6                	call   *%esi
			break;
  800894:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80089a:	e9 9c fc ff ff       	jmp    80053b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	53                   	push   %ebx
  8008a3:	6a 25                	push   $0x25
  8008a5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	eb 03                	jmp    8008af <vprintfmt+0x39a>
  8008ac:	83 ef 01             	sub    $0x1,%edi
  8008af:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008b3:	75 f7                	jne    8008ac <vprintfmt+0x397>
  8008b5:	e9 81 fc ff ff       	jmp    80053b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008bd:	5b                   	pop    %ebx
  8008be:	5e                   	pop    %esi
  8008bf:	5f                   	pop    %edi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	83 ec 18             	sub    $0x18,%esp
  8008c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	74 26                	je     800909 <vsnprintf+0x47>
  8008e3:	85 d2                	test   %edx,%edx
  8008e5:	7e 22                	jle    800909 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e7:	ff 75 14             	pushl  0x14(%ebp)
  8008ea:	ff 75 10             	pushl  0x10(%ebp)
  8008ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f0:	50                   	push   %eax
  8008f1:	68 db 04 80 00       	push   $0x8004db
  8008f6:	e8 1a fc ff ff       	call   800515 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008fe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800901:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb 05                	jmp    80090e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800909:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800916:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800919:	50                   	push   %eax
  80091a:	ff 75 10             	pushl  0x10(%ebp)
  80091d:	ff 75 0c             	pushl  0xc(%ebp)
  800920:	ff 75 08             	pushl  0x8(%ebp)
  800923:	e8 9a ff ff ff       	call   8008c2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800928:	c9                   	leave  
  800929:	c3                   	ret    

0080092a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800930:	b8 00 00 00 00       	mov    $0x0,%eax
  800935:	eb 03                	jmp    80093a <strlen+0x10>
		n++;
  800937:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80093a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093e:	75 f7                	jne    800937 <strlen+0xd>
		n++;
	return n;
}
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094b:	ba 00 00 00 00       	mov    $0x0,%edx
  800950:	eb 03                	jmp    800955 <strnlen+0x13>
		n++;
  800952:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800955:	39 c2                	cmp    %eax,%edx
  800957:	74 08                	je     800961 <strnlen+0x1f>
  800959:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80095d:	75 f3                	jne    800952 <strnlen+0x10>
  80095f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80096d:	89 c2                	mov    %eax,%edx
  80096f:	83 c2 01             	add    $0x1,%edx
  800972:	83 c1 01             	add    $0x1,%ecx
  800975:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800979:	88 5a ff             	mov    %bl,-0x1(%edx)
  80097c:	84 db                	test   %bl,%bl
  80097e:	75 ef                	jne    80096f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800980:	5b                   	pop    %ebx
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80098a:	53                   	push   %ebx
  80098b:	e8 9a ff ff ff       	call   80092a <strlen>
  800990:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	01 d8                	add    %ebx,%eax
  800998:	50                   	push   %eax
  800999:	e8 c5 ff ff ff       	call   800963 <strcpy>
	return dst;
}
  80099e:	89 d8                	mov    %ebx,%eax
  8009a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b0:	89 f3                	mov    %esi,%ebx
  8009b2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b5:	89 f2                	mov    %esi,%edx
  8009b7:	eb 0f                	jmp    8009c8 <strncpy+0x23>
		*dst++ = *src;
  8009b9:	83 c2 01             	add    $0x1,%edx
  8009bc:	0f b6 01             	movzbl (%ecx),%eax
  8009bf:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c2:	80 39 01             	cmpb   $0x1,(%ecx)
  8009c5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c8:	39 da                	cmp    %ebx,%edx
  8009ca:	75 ed                	jne    8009b9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009cc:	89 f0                	mov    %esi,%eax
  8009ce:	5b                   	pop    %ebx
  8009cf:	5e                   	pop    %esi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8009e0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e2:	85 d2                	test   %edx,%edx
  8009e4:	74 21                	je     800a07 <strlcpy+0x35>
  8009e6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ea:	89 f2                	mov    %esi,%edx
  8009ec:	eb 09                	jmp    8009f7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ee:	83 c2 01             	add    $0x1,%edx
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f7:	39 c2                	cmp    %eax,%edx
  8009f9:	74 09                	je     800a04 <strlcpy+0x32>
  8009fb:	0f b6 19             	movzbl (%ecx),%ebx
  8009fe:	84 db                	test   %bl,%bl
  800a00:	75 ec                	jne    8009ee <strlcpy+0x1c>
  800a02:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a04:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a07:	29 f0                	sub    %esi,%eax
}
  800a09:	5b                   	pop    %ebx
  800a0a:	5e                   	pop    %esi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a13:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a16:	eb 06                	jmp    800a1e <strcmp+0x11>
		p++, q++;
  800a18:	83 c1 01             	add    $0x1,%ecx
  800a1b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1e:	0f b6 01             	movzbl (%ecx),%eax
  800a21:	84 c0                	test   %al,%al
  800a23:	74 04                	je     800a29 <strcmp+0x1c>
  800a25:	3a 02                	cmp    (%edx),%al
  800a27:	74 ef                	je     800a18 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a29:	0f b6 c0             	movzbl %al,%eax
  800a2c:	0f b6 12             	movzbl (%edx),%edx
  800a2f:	29 d0                	sub    %edx,%eax
}
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    

00800a33 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3d:	89 c3                	mov    %eax,%ebx
  800a3f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a42:	eb 06                	jmp    800a4a <strncmp+0x17>
		n--, p++, q++;
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4a:	39 d8                	cmp    %ebx,%eax
  800a4c:	74 15                	je     800a63 <strncmp+0x30>
  800a4e:	0f b6 08             	movzbl (%eax),%ecx
  800a51:	84 c9                	test   %cl,%cl
  800a53:	74 04                	je     800a59 <strncmp+0x26>
  800a55:	3a 0a                	cmp    (%edx),%cl
  800a57:	74 eb                	je     800a44 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a59:	0f b6 00             	movzbl (%eax),%eax
  800a5c:	0f b6 12             	movzbl (%edx),%edx
  800a5f:	29 d0                	sub    %edx,%eax
  800a61:	eb 05                	jmp    800a68 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a68:	5b                   	pop    %ebx
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	eb 07                	jmp    800a7e <strchr+0x13>
		if (*s == c)
  800a77:	38 ca                	cmp    %cl,%dl
  800a79:	74 0f                	je     800a8a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7b:	83 c0 01             	add    $0x1,%eax
  800a7e:	0f b6 10             	movzbl (%eax),%edx
  800a81:	84 d2                	test   %dl,%dl
  800a83:	75 f2                	jne    800a77 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a92:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a96:	eb 03                	jmp    800a9b <strfind+0xf>
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a9e:	38 ca                	cmp    %cl,%dl
  800aa0:	74 04                	je     800aa6 <strfind+0x1a>
  800aa2:	84 d2                	test   %dl,%dl
  800aa4:	75 f2                	jne    800a98 <strfind+0xc>
			break;
	return (char *) s;
}
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	57                   	push   %edi
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab4:	85 c9                	test   %ecx,%ecx
  800ab6:	74 36                	je     800aee <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800abe:	75 28                	jne    800ae8 <memset+0x40>
  800ac0:	f6 c1 03             	test   $0x3,%cl
  800ac3:	75 23                	jne    800ae8 <memset+0x40>
		c &= 0xFF;
  800ac5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac9:	89 d3                	mov    %edx,%ebx
  800acb:	c1 e3 08             	shl    $0x8,%ebx
  800ace:	89 d6                	mov    %edx,%esi
  800ad0:	c1 e6 18             	shl    $0x18,%esi
  800ad3:	89 d0                	mov    %edx,%eax
  800ad5:	c1 e0 10             	shl    $0x10,%eax
  800ad8:	09 f0                	or     %esi,%eax
  800ada:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800adc:	89 d8                	mov    %ebx,%eax
  800ade:	09 d0                	or     %edx,%eax
  800ae0:	c1 e9 02             	shr    $0x2,%ecx
  800ae3:	fc                   	cld    
  800ae4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae6:	eb 06                	jmp    800aee <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	fc                   	cld    
  800aec:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aee:	89 f8                	mov    %edi,%eax
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b00:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b03:	39 c6                	cmp    %eax,%esi
  800b05:	73 35                	jae    800b3c <memmove+0x47>
  800b07:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0a:	39 d0                	cmp    %edx,%eax
  800b0c:	73 2e                	jae    800b3c <memmove+0x47>
		s += n;
		d += n;
  800b0e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	09 fe                	or     %edi,%esi
  800b15:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1b:	75 13                	jne    800b30 <memmove+0x3b>
  800b1d:	f6 c1 03             	test   $0x3,%cl
  800b20:	75 0e                	jne    800b30 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b22:	83 ef 04             	sub    $0x4,%edi
  800b25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b28:	c1 e9 02             	shr    $0x2,%ecx
  800b2b:	fd                   	std    
  800b2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2e:	eb 09                	jmp    800b39 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b30:	83 ef 01             	sub    $0x1,%edi
  800b33:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b36:	fd                   	std    
  800b37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b39:	fc                   	cld    
  800b3a:	eb 1d                	jmp    800b59 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3c:	89 f2                	mov    %esi,%edx
  800b3e:	09 c2                	or     %eax,%edx
  800b40:	f6 c2 03             	test   $0x3,%dl
  800b43:	75 0f                	jne    800b54 <memmove+0x5f>
  800b45:	f6 c1 03             	test   $0x3,%cl
  800b48:	75 0a                	jne    800b54 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b4a:	c1 e9 02             	shr    $0x2,%ecx
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	fc                   	cld    
  800b50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b52:	eb 05                	jmp    800b59 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b54:	89 c7                	mov    %eax,%edi
  800b56:	fc                   	cld    
  800b57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b60:	ff 75 10             	pushl  0x10(%ebp)
  800b63:	ff 75 0c             	pushl  0xc(%ebp)
  800b66:	ff 75 08             	pushl  0x8(%ebp)
  800b69:	e8 87 ff ff ff       	call   800af5 <memmove>
}
  800b6e:	c9                   	leave  
  800b6f:	c3                   	ret    

00800b70 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7b:	89 c6                	mov    %eax,%esi
  800b7d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b80:	eb 1a                	jmp    800b9c <memcmp+0x2c>
		if (*s1 != *s2)
  800b82:	0f b6 08             	movzbl (%eax),%ecx
  800b85:	0f b6 1a             	movzbl (%edx),%ebx
  800b88:	38 d9                	cmp    %bl,%cl
  800b8a:	74 0a                	je     800b96 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b8c:	0f b6 c1             	movzbl %cl,%eax
  800b8f:	0f b6 db             	movzbl %bl,%ebx
  800b92:	29 d8                	sub    %ebx,%eax
  800b94:	eb 0f                	jmp    800ba5 <memcmp+0x35>
		s1++, s2++;
  800b96:	83 c0 01             	add    $0x1,%eax
  800b99:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9c:	39 f0                	cmp    %esi,%eax
  800b9e:	75 e2                	jne    800b82 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	53                   	push   %ebx
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bb0:	89 c1                	mov    %eax,%ecx
  800bb2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb9:	eb 0a                	jmp    800bc5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bbb:	0f b6 10             	movzbl (%eax),%edx
  800bbe:	39 da                	cmp    %ebx,%edx
  800bc0:	74 07                	je     800bc9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc2:	83 c0 01             	add    $0x1,%eax
  800bc5:	39 c8                	cmp    %ecx,%eax
  800bc7:	72 f2                	jb     800bbb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd8:	eb 03                	jmp    800bdd <strtol+0x11>
		s++;
  800bda:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bdd:	0f b6 01             	movzbl (%ecx),%eax
  800be0:	3c 20                	cmp    $0x20,%al
  800be2:	74 f6                	je     800bda <strtol+0xe>
  800be4:	3c 09                	cmp    $0x9,%al
  800be6:	74 f2                	je     800bda <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be8:	3c 2b                	cmp    $0x2b,%al
  800bea:	75 0a                	jne    800bf6 <strtol+0x2a>
		s++;
  800bec:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bef:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf4:	eb 11                	jmp    800c07 <strtol+0x3b>
  800bf6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bfb:	3c 2d                	cmp    $0x2d,%al
  800bfd:	75 08                	jne    800c07 <strtol+0x3b>
		s++, neg = 1;
  800bff:	83 c1 01             	add    $0x1,%ecx
  800c02:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c07:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c0d:	75 15                	jne    800c24 <strtol+0x58>
  800c0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c12:	75 10                	jne    800c24 <strtol+0x58>
  800c14:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c18:	75 7c                	jne    800c96 <strtol+0xca>
		s += 2, base = 16;
  800c1a:	83 c1 02             	add    $0x2,%ecx
  800c1d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c22:	eb 16                	jmp    800c3a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c24:	85 db                	test   %ebx,%ebx
  800c26:	75 12                	jne    800c3a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c28:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c2d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c30:	75 08                	jne    800c3a <strtol+0x6e>
		s++, base = 8;
  800c32:	83 c1 01             	add    $0x1,%ecx
  800c35:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c42:	0f b6 11             	movzbl (%ecx),%edx
  800c45:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c48:	89 f3                	mov    %esi,%ebx
  800c4a:	80 fb 09             	cmp    $0x9,%bl
  800c4d:	77 08                	ja     800c57 <strtol+0x8b>
			dig = *s - '0';
  800c4f:	0f be d2             	movsbl %dl,%edx
  800c52:	83 ea 30             	sub    $0x30,%edx
  800c55:	eb 22                	jmp    800c79 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c57:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c5a:	89 f3                	mov    %esi,%ebx
  800c5c:	80 fb 19             	cmp    $0x19,%bl
  800c5f:	77 08                	ja     800c69 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c61:	0f be d2             	movsbl %dl,%edx
  800c64:	83 ea 57             	sub    $0x57,%edx
  800c67:	eb 10                	jmp    800c79 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c69:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c6c:	89 f3                	mov    %esi,%ebx
  800c6e:	80 fb 19             	cmp    $0x19,%bl
  800c71:	77 16                	ja     800c89 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c73:	0f be d2             	movsbl %dl,%edx
  800c76:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c79:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c7c:	7d 0b                	jge    800c89 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c7e:	83 c1 01             	add    $0x1,%ecx
  800c81:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c85:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c87:	eb b9                	jmp    800c42 <strtol+0x76>

	if (endptr)
  800c89:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c8d:	74 0d                	je     800c9c <strtol+0xd0>
		*endptr = (char *) s;
  800c8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c92:	89 0e                	mov    %ecx,(%esi)
  800c94:	eb 06                	jmp    800c9c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c96:	85 db                	test   %ebx,%ebx
  800c98:	74 98                	je     800c32 <strtol+0x66>
  800c9a:	eb 9e                	jmp    800c3a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c9c:	89 c2                	mov    %eax,%edx
  800c9e:	f7 da                	neg    %edx
  800ca0:	85 ff                	test   %edi,%edi
  800ca2:	0f 45 c2             	cmovne %edx,%eax
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    
  800caa:	66 90                	xchg   %ax,%ax
  800cac:	66 90                	xchg   %ax,%ax
  800cae:	66 90                	xchg   %ax,%ax

00800cb0 <__udivdi3>:
  800cb0:	55                   	push   %ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
  800cb4:	83 ec 1c             	sub    $0x1c,%esp
  800cb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800cc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cc7:	85 f6                	test   %esi,%esi
  800cc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ccd:	89 ca                	mov    %ecx,%edx
  800ccf:	89 f8                	mov    %edi,%eax
  800cd1:	75 3d                	jne    800d10 <__udivdi3+0x60>
  800cd3:	39 cf                	cmp    %ecx,%edi
  800cd5:	0f 87 c5 00 00 00    	ja     800da0 <__udivdi3+0xf0>
  800cdb:	85 ff                	test   %edi,%edi
  800cdd:	89 fd                	mov    %edi,%ebp
  800cdf:	75 0b                	jne    800cec <__udivdi3+0x3c>
  800ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce6:	31 d2                	xor    %edx,%edx
  800ce8:	f7 f7                	div    %edi
  800cea:	89 c5                	mov    %eax,%ebp
  800cec:	89 c8                	mov    %ecx,%eax
  800cee:	31 d2                	xor    %edx,%edx
  800cf0:	f7 f5                	div    %ebp
  800cf2:	89 c1                	mov    %eax,%ecx
  800cf4:	89 d8                	mov    %ebx,%eax
  800cf6:	89 cf                	mov    %ecx,%edi
  800cf8:	f7 f5                	div    %ebp
  800cfa:	89 c3                	mov    %eax,%ebx
  800cfc:	89 d8                	mov    %ebx,%eax
  800cfe:	89 fa                	mov    %edi,%edx
  800d00:	83 c4 1c             	add    $0x1c,%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
  800d08:	90                   	nop
  800d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d10:	39 ce                	cmp    %ecx,%esi
  800d12:	77 74                	ja     800d88 <__udivdi3+0xd8>
  800d14:	0f bd fe             	bsr    %esi,%edi
  800d17:	83 f7 1f             	xor    $0x1f,%edi
  800d1a:	0f 84 98 00 00 00    	je     800db8 <__udivdi3+0x108>
  800d20:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d25:	89 f9                	mov    %edi,%ecx
  800d27:	89 c5                	mov    %eax,%ebp
  800d29:	29 fb                	sub    %edi,%ebx
  800d2b:	d3 e6                	shl    %cl,%esi
  800d2d:	89 d9                	mov    %ebx,%ecx
  800d2f:	d3 ed                	shr    %cl,%ebp
  800d31:	89 f9                	mov    %edi,%ecx
  800d33:	d3 e0                	shl    %cl,%eax
  800d35:	09 ee                	or     %ebp,%esi
  800d37:	89 d9                	mov    %ebx,%ecx
  800d39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d3d:	89 d5                	mov    %edx,%ebp
  800d3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d43:	d3 ed                	shr    %cl,%ebp
  800d45:	89 f9                	mov    %edi,%ecx
  800d47:	d3 e2                	shl    %cl,%edx
  800d49:	89 d9                	mov    %ebx,%ecx
  800d4b:	d3 e8                	shr    %cl,%eax
  800d4d:	09 c2                	or     %eax,%edx
  800d4f:	89 d0                	mov    %edx,%eax
  800d51:	89 ea                	mov    %ebp,%edx
  800d53:	f7 f6                	div    %esi
  800d55:	89 d5                	mov    %edx,%ebp
  800d57:	89 c3                	mov    %eax,%ebx
  800d59:	f7 64 24 0c          	mull   0xc(%esp)
  800d5d:	39 d5                	cmp    %edx,%ebp
  800d5f:	72 10                	jb     800d71 <__udivdi3+0xc1>
  800d61:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	d3 e6                	shl    %cl,%esi
  800d69:	39 c6                	cmp    %eax,%esi
  800d6b:	73 07                	jae    800d74 <__udivdi3+0xc4>
  800d6d:	39 d5                	cmp    %edx,%ebp
  800d6f:	75 03                	jne    800d74 <__udivdi3+0xc4>
  800d71:	83 eb 01             	sub    $0x1,%ebx
  800d74:	31 ff                	xor    %edi,%edi
  800d76:	89 d8                	mov    %ebx,%eax
  800d78:	89 fa                	mov    %edi,%edx
  800d7a:	83 c4 1c             	add    $0x1c,%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    
  800d82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d88:	31 ff                	xor    %edi,%edi
  800d8a:	31 db                	xor    %ebx,%ebx
  800d8c:	89 d8                	mov    %ebx,%eax
  800d8e:	89 fa                	mov    %edi,%edx
  800d90:	83 c4 1c             	add    $0x1c,%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
  800d98:	90                   	nop
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	89 d8                	mov    %ebx,%eax
  800da2:	f7 f7                	div    %edi
  800da4:	31 ff                	xor    %edi,%edi
  800da6:	89 c3                	mov    %eax,%ebx
  800da8:	89 d8                	mov    %ebx,%eax
  800daa:	89 fa                	mov    %edi,%edx
  800dac:	83 c4 1c             	add    $0x1c,%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    
  800db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db8:	39 ce                	cmp    %ecx,%esi
  800dba:	72 0c                	jb     800dc8 <__udivdi3+0x118>
  800dbc:	31 db                	xor    %ebx,%ebx
  800dbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800dc2:	0f 87 34 ff ff ff    	ja     800cfc <__udivdi3+0x4c>
  800dc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800dcd:	e9 2a ff ff ff       	jmp    800cfc <__udivdi3+0x4c>
  800dd2:	66 90                	xchg   %ax,%ax
  800dd4:	66 90                	xchg   %ax,%ax
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__umoddi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800deb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800def:	8b 74 24 34          	mov    0x34(%esp),%esi
  800df3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800df7:	85 d2                	test   %edx,%edx
  800df9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800dfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e01:	89 f3                	mov    %esi,%ebx
  800e03:	89 3c 24             	mov    %edi,(%esp)
  800e06:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e0a:	75 1c                	jne    800e28 <__umoddi3+0x48>
  800e0c:	39 f7                	cmp    %esi,%edi
  800e0e:	76 50                	jbe    800e60 <__umoddi3+0x80>
  800e10:	89 c8                	mov    %ecx,%eax
  800e12:	89 f2                	mov    %esi,%edx
  800e14:	f7 f7                	div    %edi
  800e16:	89 d0                	mov    %edx,%eax
  800e18:	31 d2                	xor    %edx,%edx
  800e1a:	83 c4 1c             	add    $0x1c,%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
  800e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	89 d0                	mov    %edx,%eax
  800e2c:	77 52                	ja     800e80 <__umoddi3+0xa0>
  800e2e:	0f bd ea             	bsr    %edx,%ebp
  800e31:	83 f5 1f             	xor    $0x1f,%ebp
  800e34:	75 5a                	jne    800e90 <__umoddi3+0xb0>
  800e36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e3a:	0f 82 e0 00 00 00    	jb     800f20 <__umoddi3+0x140>
  800e40:	39 0c 24             	cmp    %ecx,(%esp)
  800e43:	0f 86 d7 00 00 00    	jbe    800f20 <__umoddi3+0x140>
  800e49:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e51:	83 c4 1c             	add    $0x1c,%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	85 ff                	test   %edi,%edi
  800e62:	89 fd                	mov    %edi,%ebp
  800e64:	75 0b                	jne    800e71 <__umoddi3+0x91>
  800e66:	b8 01 00 00 00       	mov    $0x1,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	f7 f7                	div    %edi
  800e6f:	89 c5                	mov    %eax,%ebp
  800e71:	89 f0                	mov    %esi,%eax
  800e73:	31 d2                	xor    %edx,%edx
  800e75:	f7 f5                	div    %ebp
  800e77:	89 c8                	mov    %ecx,%eax
  800e79:	f7 f5                	div    %ebp
  800e7b:	89 d0                	mov    %edx,%eax
  800e7d:	eb 99                	jmp    800e18 <__umoddi3+0x38>
  800e7f:	90                   	nop
  800e80:	89 c8                	mov    %ecx,%eax
  800e82:	89 f2                	mov    %esi,%edx
  800e84:	83 c4 1c             	add    $0x1c,%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    
  800e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e90:	8b 34 24             	mov    (%esp),%esi
  800e93:	bf 20 00 00 00       	mov    $0x20,%edi
  800e98:	89 e9                	mov    %ebp,%ecx
  800e9a:	29 ef                	sub    %ebp,%edi
  800e9c:	d3 e0                	shl    %cl,%eax
  800e9e:	89 f9                	mov    %edi,%ecx
  800ea0:	89 f2                	mov    %esi,%edx
  800ea2:	d3 ea                	shr    %cl,%edx
  800ea4:	89 e9                	mov    %ebp,%ecx
  800ea6:	09 c2                	or     %eax,%edx
  800ea8:	89 d8                	mov    %ebx,%eax
  800eaa:	89 14 24             	mov    %edx,(%esp)
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	d3 e2                	shl    %cl,%edx
  800eb1:	89 f9                	mov    %edi,%ecx
  800eb3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ebb:	d3 e8                	shr    %cl,%eax
  800ebd:	89 e9                	mov    %ebp,%ecx
  800ebf:	89 c6                	mov    %eax,%esi
  800ec1:	d3 e3                	shl    %cl,%ebx
  800ec3:	89 f9                	mov    %edi,%ecx
  800ec5:	89 d0                	mov    %edx,%eax
  800ec7:	d3 e8                	shr    %cl,%eax
  800ec9:	89 e9                	mov    %ebp,%ecx
  800ecb:	09 d8                	or     %ebx,%eax
  800ecd:	89 d3                	mov    %edx,%ebx
  800ecf:	89 f2                	mov    %esi,%edx
  800ed1:	f7 34 24             	divl   (%esp)
  800ed4:	89 d6                	mov    %edx,%esi
  800ed6:	d3 e3                	shl    %cl,%ebx
  800ed8:	f7 64 24 04          	mull   0x4(%esp)
  800edc:	39 d6                	cmp    %edx,%esi
  800ede:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ee2:	89 d1                	mov    %edx,%ecx
  800ee4:	89 c3                	mov    %eax,%ebx
  800ee6:	72 08                	jb     800ef0 <__umoddi3+0x110>
  800ee8:	75 11                	jne    800efb <__umoddi3+0x11b>
  800eea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800eee:	73 0b                	jae    800efb <__umoddi3+0x11b>
  800ef0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800ef4:	1b 14 24             	sbb    (%esp),%edx
  800ef7:	89 d1                	mov    %edx,%ecx
  800ef9:	89 c3                	mov    %eax,%ebx
  800efb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800eff:	29 da                	sub    %ebx,%edx
  800f01:	19 ce                	sbb    %ecx,%esi
  800f03:	89 f9                	mov    %edi,%ecx
  800f05:	89 f0                	mov    %esi,%eax
  800f07:	d3 e0                	shl    %cl,%eax
  800f09:	89 e9                	mov    %ebp,%ecx
  800f0b:	d3 ea                	shr    %cl,%edx
  800f0d:	89 e9                	mov    %ebp,%ecx
  800f0f:	d3 ee                	shr    %cl,%esi
  800f11:	09 d0                	or     %edx,%eax
  800f13:	89 f2                	mov    %esi,%edx
  800f15:	83 c4 1c             	add    $0x1c,%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
  800f1d:	8d 76 00             	lea    0x0(%esi),%esi
  800f20:	29 f9                	sub    %edi,%ecx
  800f22:	19 d6                	sbb    %edx,%esi
  800f24:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f2c:	e9 18 ff ff ff       	jmp    800e49 <__umoddi3+0x69>
