
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 c6 00 00 00       	call   800110 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7e 17                	jle    800108 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	50                   	push   %eax
  8000f5:	6a 03                	push   $0x3
  8000f7:	68 4a 0f 80 00       	push   $0x800f4a
  8000fc:	6a 23                	push   $0x23
  8000fe:	68 67 0f 80 00       	push   $0x800f67
  800103:	e8 f5 01 00 00       	call   8002fd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	b8 04 00 00 00       	mov    $0x4,%eax
  800161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7e 17                	jle    800189 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800172:	83 ec 0c             	sub    $0xc,%esp
  800175:	50                   	push   %eax
  800176:	6a 04                	push   $0x4
  800178:	68 4a 0f 80 00       	push   $0x800f4a
  80017d:	6a 23                	push   $0x23
  80017f:	68 67 0f 80 00       	push   $0x800f67
  800184:	e8 74 01 00 00       	call   8002fd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800189:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	b8 05 00 00 00       	mov    $0x5,%eax
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7e 17                	jle    8001cb <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	50                   	push   %eax
  8001b8:	6a 05                	push   $0x5
  8001ba:	68 4a 0f 80 00       	push   $0x800f4a
  8001bf:	6a 23                	push   $0x23
  8001c1:	68 67 0f 80 00       	push   $0x800f67
  8001c6:	e8 32 01 00 00       	call   8002fd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ce:	5b                   	pop    %ebx
  8001cf:	5e                   	pop    %esi
  8001d0:	5f                   	pop    %edi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7e 17                	jle    80020d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f6:	83 ec 0c             	sub    $0xc,%esp
  8001f9:	50                   	push   %eax
  8001fa:	6a 06                	push   $0x6
  8001fc:	68 4a 0f 80 00       	push   $0x800f4a
  800201:	6a 23                	push   $0x23
  800203:	68 67 0f 80 00       	push   $0x800f67
  800208:	e8 f0 00 00 00       	call   8002fd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800210:	5b                   	pop    %ebx
  800211:	5e                   	pop    %esi
  800212:	5f                   	pop    %edi
  800213:	5d                   	pop    %ebp
  800214:	c3                   	ret    

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	b8 08 00 00 00       	mov    $0x8,%eax
  800228:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022b:	8b 55 08             	mov    0x8(%ebp),%edx
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7e 17                	jle    80024f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	50                   	push   %eax
  80023c:	6a 08                	push   $0x8
  80023e:	68 4a 0f 80 00       	push   $0x800f4a
  800243:	6a 23                	push   $0x23
  800245:	68 67 0f 80 00       	push   $0x800f67
  80024a:	e8 ae 00 00 00       	call   8002fd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	b8 09 00 00 00       	mov    $0x9,%eax
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	8b 55 08             	mov    0x8(%ebp),%edx
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7e 17                	jle    800291 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027a:	83 ec 0c             	sub    $0xc,%esp
  80027d:	50                   	push   %eax
  80027e:	6a 09                	push   $0x9
  800280:	68 4a 0f 80 00       	push   $0x800f4a
  800285:	6a 23                	push   $0x23
  800287:	68 67 0f 80 00       	push   $0x800f67
  80028c:	e8 6c 00 00 00       	call   8002fd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800294:	5b                   	pop    %ebx
  800295:	5e                   	pop    %esi
  800296:	5f                   	pop    %edi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029f:	be 00 00 00 00       	mov    $0x0,%esi
  8002a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0c                	push   $0xc
  8002e4:	68 4a 0f 80 00       	push   $0x800f4a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 67 0f 80 00       	push   $0x800f67
  8002f0:	e8 08 00 00 00       	call   8002fd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800305:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030b:	e8 00 fe ff ff       	call   800110 <sys_getenvid>
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	56                   	push   %esi
  80031a:	50                   	push   %eax
  80031b:	68 78 0f 80 00       	push   $0x800f78
  800320:	e8 b1 00 00 00       	call   8003d6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	53                   	push   %ebx
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	e8 54 00 00 00       	call   800385 <vcprintf>
	cprintf("\n");
  800331:	c7 04 24 9c 0f 80 00 	movl   $0x800f9c,(%esp)
  800338:	e8 99 00 00 00       	call   8003d6 <cprintf>
  80033d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800340:	cc                   	int3   
  800341:	eb fd                	jmp    800340 <_panic+0x43>

00800343 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	53                   	push   %ebx
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034d:	8b 13                	mov    (%ebx),%edx
  80034f:	8d 42 01             	lea    0x1(%edx),%eax
  800352:	89 03                	mov    %eax,(%ebx)
  800354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800357:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800360:	75 1a                	jne    80037c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	68 ff 00 00 00       	push   $0xff
  80036a:	8d 43 08             	lea    0x8(%ebx),%eax
  80036d:	50                   	push   %eax
  80036e:	e8 1f fd ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  800373:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800379:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800395:	00 00 00 
	b.cnt = 0;
  800398:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a2:	ff 75 0c             	pushl  0xc(%ebp)
  8003a5:	ff 75 08             	pushl  0x8(%ebp)
  8003a8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ae:	50                   	push   %eax
  8003af:	68 43 03 80 00       	push   $0x800343
  8003b4:	e8 54 01 00 00       	call   80050d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b9:	83 c4 08             	add    $0x8,%esp
  8003bc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c8:	50                   	push   %eax
  8003c9:	e8 c4 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8003ce:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d4:	c9                   	leave  
  8003d5:	c3                   	ret    

008003d6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
  8003d9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003dc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003df:	50                   	push   %eax
  8003e0:	ff 75 08             	pushl  0x8(%ebp)
  8003e3:	e8 9d ff ff ff       	call   800385 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	57                   	push   %edi
  8003ee:	56                   	push   %esi
  8003ef:	53                   	push   %ebx
  8003f0:	83 ec 1c             	sub    $0x1c,%esp
  8003f3:	89 c7                	mov    %eax,%edi
  8003f5:	89 d6                	mov    %edx,%esi
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800400:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800403:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800411:	39 d3                	cmp    %edx,%ebx
  800413:	72 05                	jb     80041a <printnum+0x30>
  800415:	39 45 10             	cmp    %eax,0x10(%ebp)
  800418:	77 45                	ja     80045f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041a:	83 ec 0c             	sub    $0xc,%esp
  80041d:	ff 75 18             	pushl  0x18(%ebp)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800426:	53                   	push   %ebx
  800427:	ff 75 10             	pushl  0x10(%ebp)
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800430:	ff 75 e0             	pushl  -0x20(%ebp)
  800433:	ff 75 dc             	pushl  -0x24(%ebp)
  800436:	ff 75 d8             	pushl  -0x28(%ebp)
  800439:	e8 72 08 00 00       	call   800cb0 <__udivdi3>
  80043e:	83 c4 18             	add    $0x18,%esp
  800441:	52                   	push   %edx
  800442:	50                   	push   %eax
  800443:	89 f2                	mov    %esi,%edx
  800445:	89 f8                	mov    %edi,%eax
  800447:	e8 9e ff ff ff       	call   8003ea <printnum>
  80044c:	83 c4 20             	add    $0x20,%esp
  80044f:	eb 18                	jmp    800469 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800451:	83 ec 08             	sub    $0x8,%esp
  800454:	56                   	push   %esi
  800455:	ff 75 18             	pushl  0x18(%ebp)
  800458:	ff d7                	call   *%edi
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	eb 03                	jmp    800462 <printnum+0x78>
  80045f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800462:	83 eb 01             	sub    $0x1,%ebx
  800465:	85 db                	test   %ebx,%ebx
  800467:	7f e8                	jg     800451 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	ff 75 e4             	pushl  -0x1c(%ebp)
  800473:	ff 75 e0             	pushl  -0x20(%ebp)
  800476:	ff 75 dc             	pushl  -0x24(%ebp)
  800479:	ff 75 d8             	pushl  -0x28(%ebp)
  80047c:	e8 5f 09 00 00       	call   800de0 <__umoddi3>
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	0f be 80 9e 0f 80 00 	movsbl 0x800f9e(%eax),%eax
  80048b:	50                   	push   %eax
  80048c:	ff d7                	call   *%edi
}
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800494:	5b                   	pop    %ebx
  800495:	5e                   	pop    %esi
  800496:	5f                   	pop    %edi
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049c:	83 fa 01             	cmp    $0x1,%edx
  80049f:	7e 0e                	jle    8004af <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a1:	8b 10                	mov    (%eax),%edx
  8004a3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a6:	89 08                	mov    %ecx,(%eax)
  8004a8:	8b 02                	mov    (%edx),%eax
  8004aa:	8b 52 04             	mov    0x4(%edx),%edx
  8004ad:	eb 22                	jmp    8004d1 <getuint+0x38>
	else if (lflag)
  8004af:	85 d2                	test   %edx,%edx
  8004b1:	74 10                	je     8004c3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b3:	8b 10                	mov    (%eax),%edx
  8004b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b8:	89 08                	mov    %ecx,(%eax)
  8004ba:	8b 02                	mov    (%edx),%eax
  8004bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c1:	eb 0e                	jmp    8004d1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d1:	5d                   	pop    %ebp
  8004d2:	c3                   	ret    

008004d3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004dd:	8b 10                	mov    (%eax),%edx
  8004df:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e2:	73 0a                	jae    8004ee <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e7:	89 08                	mov    %ecx,(%eax)
  8004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ec:	88 02                	mov    %al,(%edx)
}
  8004ee:	5d                   	pop    %ebp
  8004ef:	c3                   	ret    

008004f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f9:	50                   	push   %eax
  8004fa:	ff 75 10             	pushl  0x10(%ebp)
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	ff 75 08             	pushl  0x8(%ebp)
  800503:	e8 05 00 00 00       	call   80050d <vprintfmt>
	va_end(ap);
}
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	53                   	push   %ebx
  800513:	83 ec 2c             	sub    $0x2c,%esp
  800516:	8b 75 08             	mov    0x8(%ebp),%esi
  800519:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051f:	eb 12                	jmp    800533 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800521:	85 c0                	test   %eax,%eax
  800523:	0f 84 89 03 00 00    	je     8008b2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800529:	83 ec 08             	sub    $0x8,%esp
  80052c:	53                   	push   %ebx
  80052d:	50                   	push   %eax
  80052e:	ff d6                	call   *%esi
  800530:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800533:	83 c7 01             	add    $0x1,%edi
  800536:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053a:	83 f8 25             	cmp    $0x25,%eax
  80053d:	75 e2                	jne    800521 <vprintfmt+0x14>
  80053f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800543:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80054a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800551:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800558:	ba 00 00 00 00       	mov    $0x0,%edx
  80055d:	eb 07                	jmp    800566 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800562:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800566:	8d 47 01             	lea    0x1(%edi),%eax
  800569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056c:	0f b6 07             	movzbl (%edi),%eax
  80056f:	0f b6 c8             	movzbl %al,%ecx
  800572:	83 e8 23             	sub    $0x23,%eax
  800575:	3c 55                	cmp    $0x55,%al
  800577:	0f 87 1a 03 00 00    	ja     800897 <vprintfmt+0x38a>
  80057d:	0f b6 c0             	movzbl %al,%eax
  800580:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80058a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80058e:	eb d6                	jmp    800566 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800593:	b8 00 00 00 00       	mov    $0x0,%eax
  800598:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059e:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005a2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005a8:	83 fa 09             	cmp    $0x9,%edx
  8005ab:	77 39                	ja     8005e6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ad:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b0:	eb e9                	jmp    80059b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c3:	eb 27                	jmp    8005ec <vprintfmt+0xdf>
  8005c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c8:	85 c0                	test   %eax,%eax
  8005ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cf:	0f 49 c8             	cmovns %eax,%ecx
  8005d2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d8:	eb 8c                	jmp    800566 <vprintfmt+0x59>
  8005da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005dd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e4:	eb 80                	jmp    800566 <vprintfmt+0x59>
  8005e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f0:	0f 89 70 ff ff ff    	jns    800566 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800603:	e9 5e ff ff ff       	jmp    800566 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800608:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80060e:	e9 53 ff ff ff       	jmp    800566 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 50 04             	lea    0x4(%eax),%edx
  800619:	89 55 14             	mov    %edx,0x14(%ebp)
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	ff 30                	pushl  (%eax)
  800622:	ff d6                	call   *%esi
			break;
  800624:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80062a:	e9 04 ff ff ff       	jmp    800533 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 50 04             	lea    0x4(%eax),%edx
  800635:	89 55 14             	mov    %edx,0x14(%ebp)
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	99                   	cltd   
  80063b:	31 d0                	xor    %edx,%eax
  80063d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063f:	83 f8 08             	cmp    $0x8,%eax
  800642:	7f 0b                	jg     80064f <vprintfmt+0x142>
  800644:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80064b:	85 d2                	test   %edx,%edx
  80064d:	75 18                	jne    800667 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80064f:	50                   	push   %eax
  800650:	68 b6 0f 80 00       	push   $0x800fb6
  800655:	53                   	push   %ebx
  800656:	56                   	push   %esi
  800657:	e8 94 fe ff ff       	call   8004f0 <printfmt>
  80065c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800662:	e9 cc fe ff ff       	jmp    800533 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800667:	52                   	push   %edx
  800668:	68 bf 0f 80 00       	push   $0x800fbf
  80066d:	53                   	push   %ebx
  80066e:	56                   	push   %esi
  80066f:	e8 7c fe ff ff       	call   8004f0 <printfmt>
  800674:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067a:	e9 b4 fe ff ff       	jmp    800533 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80068a:	85 ff                	test   %edi,%edi
  80068c:	b8 af 0f 80 00       	mov    $0x800faf,%eax
  800691:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800694:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800698:	0f 8e 94 00 00 00    	jle    800732 <vprintfmt+0x225>
  80069e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a2:	0f 84 98 00 00 00    	je     800740 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ae:	57                   	push   %edi
  8006af:	e8 86 02 00 00       	call   80093a <strnlen>
  8006b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b7:	29 c1                	sub    %eax,%ecx
  8006b9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006bc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006bf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cb:	eb 0f                	jmp    8006dc <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d6:	83 ef 01             	sub    $0x1,%edi
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	85 ff                	test   %edi,%edi
  8006de:	7f ed                	jg     8006cd <vprintfmt+0x1c0>
  8006e0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006e3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e6:	85 c9                	test   %ecx,%ecx
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	0f 49 c1             	cmovns %ecx,%eax
  8006f0:	29 c1                	sub    %eax,%ecx
  8006f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fb:	89 cb                	mov    %ecx,%ebx
  8006fd:	eb 4d                	jmp    80074c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800703:	74 1b                	je     800720 <vprintfmt+0x213>
  800705:	0f be c0             	movsbl %al,%eax
  800708:	83 e8 20             	sub    $0x20,%eax
  80070b:	83 f8 5e             	cmp    $0x5e,%eax
  80070e:	76 10                	jbe    800720 <vprintfmt+0x213>
					putch('?', putdat);
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	ff 75 0c             	pushl  0xc(%ebp)
  800716:	6a 3f                	push   $0x3f
  800718:	ff 55 08             	call   *0x8(%ebp)
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	eb 0d                	jmp    80072d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	ff 75 0c             	pushl  0xc(%ebp)
  800726:	52                   	push   %edx
  800727:	ff 55 08             	call   *0x8(%ebp)
  80072a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072d:	83 eb 01             	sub    $0x1,%ebx
  800730:	eb 1a                	jmp    80074c <vprintfmt+0x23f>
  800732:	89 75 08             	mov    %esi,0x8(%ebp)
  800735:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800738:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073e:	eb 0c                	jmp    80074c <vprintfmt+0x23f>
  800740:	89 75 08             	mov    %esi,0x8(%ebp)
  800743:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800746:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800749:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074c:	83 c7 01             	add    $0x1,%edi
  80074f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800753:	0f be d0             	movsbl %al,%edx
  800756:	85 d2                	test   %edx,%edx
  800758:	74 23                	je     80077d <vprintfmt+0x270>
  80075a:	85 f6                	test   %esi,%esi
  80075c:	78 a1                	js     8006ff <vprintfmt+0x1f2>
  80075e:	83 ee 01             	sub    $0x1,%esi
  800761:	79 9c                	jns    8006ff <vprintfmt+0x1f2>
  800763:	89 df                	mov    %ebx,%edi
  800765:	8b 75 08             	mov    0x8(%ebp),%esi
  800768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076b:	eb 18                	jmp    800785 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 20                	push   $0x20
  800773:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800775:	83 ef 01             	sub    $0x1,%edi
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 08                	jmp    800785 <vprintfmt+0x278>
  80077d:	89 df                	mov    %ebx,%edi
  80077f:	8b 75 08             	mov    0x8(%ebp),%esi
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800785:	85 ff                	test   %edi,%edi
  800787:	7f e4                	jg     80076d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800789:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078c:	e9 a2 fd ff ff       	jmp    800533 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800791:	83 fa 01             	cmp    $0x1,%edx
  800794:	7e 16                	jle    8007ac <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8d 50 08             	lea    0x8(%eax),%edx
  80079c:	89 55 14             	mov    %edx,0x14(%ebp)
  80079f:	8b 50 04             	mov    0x4(%eax),%edx
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007aa:	eb 32                	jmp    8007de <vprintfmt+0x2d1>
	else if (lflag)
  8007ac:	85 d2                	test   %edx,%edx
  8007ae:	74 18                	je     8007c8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 50 04             	lea    0x4(%eax),%edx
  8007b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b9:	8b 00                	mov    (%eax),%eax
  8007bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007be:	89 c1                	mov    %eax,%ecx
  8007c0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c6:	eb 16                	jmp    8007de <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d1:	8b 00                	mov    (%eax),%eax
  8007d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d6:	89 c1                	mov    %eax,%ecx
  8007d8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007de:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ed:	79 74                	jns    800863 <vprintfmt+0x356>
				putch('-', putdat);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	6a 2d                	push   $0x2d
  8007f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007fd:	f7 d8                	neg    %eax
  8007ff:	83 d2 00             	adc    $0x0,%edx
  800802:	f7 da                	neg    %edx
  800804:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800807:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80080c:	eb 55                	jmp    800863 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
  800811:	e8 83 fc ff ff       	call   800499 <getuint>
			base = 10;
  800816:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80081b:	eb 46                	jmp    800863 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80081d:	8d 45 14             	lea    0x14(%ebp),%eax
  800820:	e8 74 fc ff ff       	call   800499 <getuint>
			base = 8;
  800825:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80082a:	eb 37                	jmp    800863 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	53                   	push   %ebx
  800830:	6a 30                	push   $0x30
  800832:	ff d6                	call   *%esi
			putch('x', putdat);
  800834:	83 c4 08             	add    $0x8,%esp
  800837:	53                   	push   %ebx
  800838:	6a 78                	push   $0x78
  80083a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8d 50 04             	lea    0x4(%eax),%edx
  800842:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800845:	8b 00                	mov    (%eax),%eax
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80084f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800854:	eb 0d                	jmp    800863 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
  800859:	e8 3b fc ff ff       	call   800499 <getuint>
			base = 16;
  80085e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800863:	83 ec 0c             	sub    $0xc,%esp
  800866:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80086a:	57                   	push   %edi
  80086b:	ff 75 e0             	pushl  -0x20(%ebp)
  80086e:	51                   	push   %ecx
  80086f:	52                   	push   %edx
  800870:	50                   	push   %eax
  800871:	89 da                	mov    %ebx,%edx
  800873:	89 f0                	mov    %esi,%eax
  800875:	e8 70 fb ff ff       	call   8003ea <printnum>
			break;
  80087a:	83 c4 20             	add    $0x20,%esp
  80087d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800880:	e9 ae fc ff ff       	jmp    800533 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	53                   	push   %ebx
  800889:	51                   	push   %ecx
  80088a:	ff d6                	call   *%esi
			break;
  80088c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800892:	e9 9c fc ff ff       	jmp    800533 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	6a 25                	push   $0x25
  80089d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	eb 03                	jmp    8008a7 <vprintfmt+0x39a>
  8008a4:	83 ef 01             	sub    $0x1,%edi
  8008a7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008ab:	75 f7                	jne    8008a4 <vprintfmt+0x397>
  8008ad:	e9 81 fc ff ff       	jmp    800533 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b5:	5b                   	pop    %ebx
  8008b6:	5e                   	pop    %esi
  8008b7:	5f                   	pop    %edi
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	83 ec 18             	sub    $0x18,%esp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008cd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d7:	85 c0                	test   %eax,%eax
  8008d9:	74 26                	je     800901 <vsnprintf+0x47>
  8008db:	85 d2                	test   %edx,%edx
  8008dd:	7e 22                	jle    800901 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008df:	ff 75 14             	pushl  0x14(%ebp)
  8008e2:	ff 75 10             	pushl  0x10(%ebp)
  8008e5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e8:	50                   	push   %eax
  8008e9:	68 d3 04 80 00       	push   $0x8004d3
  8008ee:	e8 1a fc ff ff       	call   80050d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fc:	83 c4 10             	add    $0x10,%esp
  8008ff:	eb 05                	jmp    800906 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800901:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800911:	50                   	push   %eax
  800912:	ff 75 10             	pushl  0x10(%ebp)
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	ff 75 08             	pushl  0x8(%ebp)
  80091b:	e8 9a ff ff ff       	call   8008ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
  80092d:	eb 03                	jmp    800932 <strlen+0x10>
		n++;
  80092f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800932:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800936:	75 f7                	jne    80092f <strlen+0xd>
		n++;
	return n;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800943:	ba 00 00 00 00       	mov    $0x0,%edx
  800948:	eb 03                	jmp    80094d <strnlen+0x13>
		n++;
  80094a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094d:	39 c2                	cmp    %eax,%edx
  80094f:	74 08                	je     800959 <strnlen+0x1f>
  800951:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800955:	75 f3                	jne    80094a <strnlen+0x10>
  800957:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800965:	89 c2                	mov    %eax,%edx
  800967:	83 c2 01             	add    $0x1,%edx
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800971:	88 5a ff             	mov    %bl,-0x1(%edx)
  800974:	84 db                	test   %bl,%bl
  800976:	75 ef                	jne    800967 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800978:	5b                   	pop    %ebx
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800982:	53                   	push   %ebx
  800983:	e8 9a ff ff ff       	call   800922 <strlen>
  800988:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098b:	ff 75 0c             	pushl  0xc(%ebp)
  80098e:	01 d8                	add    %ebx,%eax
  800990:	50                   	push   %eax
  800991:	e8 c5 ff ff ff       	call   80095b <strcpy>
	return dst;
}
  800996:	89 d8                	mov    %ebx,%eax
  800998:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a8:	89 f3                	mov    %esi,%ebx
  8009aa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ad:	89 f2                	mov    %esi,%edx
  8009af:	eb 0f                	jmp    8009c0 <strncpy+0x23>
		*dst++ = *src;
  8009b1:	83 c2 01             	add    $0x1,%edx
  8009b4:	0f b6 01             	movzbl (%ecx),%eax
  8009b7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ba:	80 39 01             	cmpb   $0x1,(%ecx)
  8009bd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c0:	39 da                	cmp    %ebx,%edx
  8009c2:	75 ed                	jne    8009b1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c4:	89 f0                	mov    %esi,%eax
  8009c6:	5b                   	pop    %ebx
  8009c7:	5e                   	pop    %esi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d5:	8b 55 10             	mov    0x10(%ebp),%edx
  8009d8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009da:	85 d2                	test   %edx,%edx
  8009dc:	74 21                	je     8009ff <strlcpy+0x35>
  8009de:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009e2:	89 f2                	mov    %esi,%edx
  8009e4:	eb 09                	jmp    8009ef <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ef:	39 c2                	cmp    %eax,%edx
  8009f1:	74 09                	je     8009fc <strlcpy+0x32>
  8009f3:	0f b6 19             	movzbl (%ecx),%ebx
  8009f6:	84 db                	test   %bl,%bl
  8009f8:	75 ec                	jne    8009e6 <strlcpy+0x1c>
  8009fa:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009fc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ff:	29 f0                	sub    %esi,%eax
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0e:	eb 06                	jmp    800a16 <strcmp+0x11>
		p++, q++;
  800a10:	83 c1 01             	add    $0x1,%ecx
  800a13:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a16:	0f b6 01             	movzbl (%ecx),%eax
  800a19:	84 c0                	test   %al,%al
  800a1b:	74 04                	je     800a21 <strcmp+0x1c>
  800a1d:	3a 02                	cmp    (%edx),%al
  800a1f:	74 ef                	je     800a10 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a21:	0f b6 c0             	movzbl %al,%eax
  800a24:	0f b6 12             	movzbl (%edx),%edx
  800a27:	29 d0                	sub    %edx,%eax
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a35:	89 c3                	mov    %eax,%ebx
  800a37:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a3a:	eb 06                	jmp    800a42 <strncmp+0x17>
		n--, p++, q++;
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a42:	39 d8                	cmp    %ebx,%eax
  800a44:	74 15                	je     800a5b <strncmp+0x30>
  800a46:	0f b6 08             	movzbl (%eax),%ecx
  800a49:	84 c9                	test   %cl,%cl
  800a4b:	74 04                	je     800a51 <strncmp+0x26>
  800a4d:	3a 0a                	cmp    (%edx),%cl
  800a4f:	74 eb                	je     800a3c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 00             	movzbl (%eax),%eax
  800a54:	0f b6 12             	movzbl (%edx),%edx
  800a57:	29 d0                	sub    %edx,%eax
  800a59:	eb 05                	jmp    800a60 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a60:	5b                   	pop    %ebx
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6d:	eb 07                	jmp    800a76 <strchr+0x13>
		if (*s == c)
  800a6f:	38 ca                	cmp    %cl,%dl
  800a71:	74 0f                	je     800a82 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	0f b6 10             	movzbl (%eax),%edx
  800a79:	84 d2                	test   %dl,%dl
  800a7b:	75 f2                	jne    800a6f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8e:	eb 03                	jmp    800a93 <strfind+0xf>
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a96:	38 ca                	cmp    %cl,%dl
  800a98:	74 04                	je     800a9e <strfind+0x1a>
  800a9a:	84 d2                	test   %dl,%dl
  800a9c:	75 f2                	jne    800a90 <strfind+0xc>
			break;
	return (char *) s;
}
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	57                   	push   %edi
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aac:	85 c9                	test   %ecx,%ecx
  800aae:	74 36                	je     800ae6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab6:	75 28                	jne    800ae0 <memset+0x40>
  800ab8:	f6 c1 03             	test   $0x3,%cl
  800abb:	75 23                	jne    800ae0 <memset+0x40>
		c &= 0xFF;
  800abd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac1:	89 d3                	mov    %edx,%ebx
  800ac3:	c1 e3 08             	shl    $0x8,%ebx
  800ac6:	89 d6                	mov    %edx,%esi
  800ac8:	c1 e6 18             	shl    $0x18,%esi
  800acb:	89 d0                	mov    %edx,%eax
  800acd:	c1 e0 10             	shl    $0x10,%eax
  800ad0:	09 f0                	or     %esi,%eax
  800ad2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ad4:	89 d8                	mov    %ebx,%eax
  800ad6:	09 d0                	or     %edx,%eax
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
  800adb:	fc                   	cld    
  800adc:	f3 ab                	rep stos %eax,%es:(%edi)
  800ade:	eb 06                	jmp    800ae6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae3:	fc                   	cld    
  800ae4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae6:	89 f8                	mov    %edi,%eax
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	8b 45 08             	mov    0x8(%ebp),%eax
  800af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afb:	39 c6                	cmp    %eax,%esi
  800afd:	73 35                	jae    800b34 <memmove+0x47>
  800aff:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b02:	39 d0                	cmp    %edx,%eax
  800b04:	73 2e                	jae    800b34 <memmove+0x47>
		s += n;
		d += n;
  800b06:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	09 fe                	or     %edi,%esi
  800b0d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b13:	75 13                	jne    800b28 <memmove+0x3b>
  800b15:	f6 c1 03             	test   $0x3,%cl
  800b18:	75 0e                	jne    800b28 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b1a:	83 ef 04             	sub    $0x4,%edi
  800b1d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b20:	c1 e9 02             	shr    $0x2,%ecx
  800b23:	fd                   	std    
  800b24:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b26:	eb 09                	jmp    800b31 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b28:	83 ef 01             	sub    $0x1,%edi
  800b2b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b2e:	fd                   	std    
  800b2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b31:	fc                   	cld    
  800b32:	eb 1d                	jmp    800b51 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b34:	89 f2                	mov    %esi,%edx
  800b36:	09 c2                	or     %eax,%edx
  800b38:	f6 c2 03             	test   $0x3,%dl
  800b3b:	75 0f                	jne    800b4c <memmove+0x5f>
  800b3d:	f6 c1 03             	test   $0x3,%cl
  800b40:	75 0a                	jne    800b4c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b42:	c1 e9 02             	shr    $0x2,%ecx
  800b45:	89 c7                	mov    %eax,%edi
  800b47:	fc                   	cld    
  800b48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4a:	eb 05                	jmp    800b51 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	fc                   	cld    
  800b4f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b58:	ff 75 10             	pushl  0x10(%ebp)
  800b5b:	ff 75 0c             	pushl  0xc(%ebp)
  800b5e:	ff 75 08             	pushl  0x8(%ebp)
  800b61:	e8 87 ff ff ff       	call   800aed <memmove>
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    

00800b68 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b73:	89 c6                	mov    %eax,%esi
  800b75:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b78:	eb 1a                	jmp    800b94 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7a:	0f b6 08             	movzbl (%eax),%ecx
  800b7d:	0f b6 1a             	movzbl (%edx),%ebx
  800b80:	38 d9                	cmp    %bl,%cl
  800b82:	74 0a                	je     800b8e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b84:	0f b6 c1             	movzbl %cl,%eax
  800b87:	0f b6 db             	movzbl %bl,%ebx
  800b8a:	29 d8                	sub    %ebx,%eax
  800b8c:	eb 0f                	jmp    800b9d <memcmp+0x35>
		s1++, s2++;
  800b8e:	83 c0 01             	add    $0x1,%eax
  800b91:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b94:	39 f0                	cmp    %esi,%eax
  800b96:	75 e2                	jne    800b7a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	53                   	push   %ebx
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ba8:	89 c1                	mov    %eax,%ecx
  800baa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bad:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb1:	eb 0a                	jmp    800bbd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb3:	0f b6 10             	movzbl (%eax),%edx
  800bb6:	39 da                	cmp    %ebx,%edx
  800bb8:	74 07                	je     800bc1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bba:	83 c0 01             	add    $0x1,%eax
  800bbd:	39 c8                	cmp    %ecx,%eax
  800bbf:	72 f2                	jb     800bb3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd0:	eb 03                	jmp    800bd5 <strtol+0x11>
		s++;
  800bd2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd5:	0f b6 01             	movzbl (%ecx),%eax
  800bd8:	3c 20                	cmp    $0x20,%al
  800bda:	74 f6                	je     800bd2 <strtol+0xe>
  800bdc:	3c 09                	cmp    $0x9,%al
  800bde:	74 f2                	je     800bd2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be0:	3c 2b                	cmp    $0x2b,%al
  800be2:	75 0a                	jne    800bee <strtol+0x2a>
		s++;
  800be4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bec:	eb 11                	jmp    800bff <strtol+0x3b>
  800bee:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf3:	3c 2d                	cmp    $0x2d,%al
  800bf5:	75 08                	jne    800bff <strtol+0x3b>
		s++, neg = 1;
  800bf7:	83 c1 01             	add    $0x1,%ecx
  800bfa:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c05:	75 15                	jne    800c1c <strtol+0x58>
  800c07:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0a:	75 10                	jne    800c1c <strtol+0x58>
  800c0c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c10:	75 7c                	jne    800c8e <strtol+0xca>
		s += 2, base = 16;
  800c12:	83 c1 02             	add    $0x2,%ecx
  800c15:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1a:	eb 16                	jmp    800c32 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c1c:	85 db                	test   %ebx,%ebx
  800c1e:	75 12                	jne    800c32 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c20:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c25:	80 39 30             	cmpb   $0x30,(%ecx)
  800c28:	75 08                	jne    800c32 <strtol+0x6e>
		s++, base = 8;
  800c2a:	83 c1 01             	add    $0x1,%ecx
  800c2d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c32:	b8 00 00 00 00       	mov    $0x0,%eax
  800c37:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c3a:	0f b6 11             	movzbl (%ecx),%edx
  800c3d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c40:	89 f3                	mov    %esi,%ebx
  800c42:	80 fb 09             	cmp    $0x9,%bl
  800c45:	77 08                	ja     800c4f <strtol+0x8b>
			dig = *s - '0';
  800c47:	0f be d2             	movsbl %dl,%edx
  800c4a:	83 ea 30             	sub    $0x30,%edx
  800c4d:	eb 22                	jmp    800c71 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c4f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c52:	89 f3                	mov    %esi,%ebx
  800c54:	80 fb 19             	cmp    $0x19,%bl
  800c57:	77 08                	ja     800c61 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c59:	0f be d2             	movsbl %dl,%edx
  800c5c:	83 ea 57             	sub    $0x57,%edx
  800c5f:	eb 10                	jmp    800c71 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c61:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c64:	89 f3                	mov    %esi,%ebx
  800c66:	80 fb 19             	cmp    $0x19,%bl
  800c69:	77 16                	ja     800c81 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c6b:	0f be d2             	movsbl %dl,%edx
  800c6e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c71:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c74:	7d 0b                	jge    800c81 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c76:	83 c1 01             	add    $0x1,%ecx
  800c79:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c7d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c7f:	eb b9                	jmp    800c3a <strtol+0x76>

	if (endptr)
  800c81:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c85:	74 0d                	je     800c94 <strtol+0xd0>
		*endptr = (char *) s;
  800c87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8a:	89 0e                	mov    %ecx,(%esi)
  800c8c:	eb 06                	jmp    800c94 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8e:	85 db                	test   %ebx,%ebx
  800c90:	74 98                	je     800c2a <strtol+0x66>
  800c92:	eb 9e                	jmp    800c32 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c94:	89 c2                	mov    %eax,%edx
  800c96:	f7 da                	neg    %edx
  800c98:	85 ff                	test   %edi,%edi
  800c9a:	0f 45 c2             	cmovne %edx,%eax
}
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    
  800ca2:	66 90                	xchg   %ax,%ax
  800ca4:	66 90                	xchg   %ax,%ax
  800ca6:	66 90                	xchg   %ax,%ax
  800ca8:	66 90                	xchg   %ax,%ax
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
