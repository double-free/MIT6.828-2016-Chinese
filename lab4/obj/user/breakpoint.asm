
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 c6 00 00 00       	call   80010f <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800085:	6a 00                	push   $0x0
  800087:	e8 42 00 00 00       	call   8000ce <sys_env_destroy>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5f                   	pop    %edi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <sys_cgetc>:

int
sys_cgetc(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	89 d6                	mov    %edx,%esi
  8000c7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	89 cb                	mov    %ecx,%ebx
  8000e6:	89 cf                	mov    %ecx,%edi
  8000e8:	89 ce                	mov    %ecx,%esi
  8000ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7e 17                	jle    800107 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	50                   	push   %eax
  8000f4:	6a 03                	push   $0x3
  8000f6:	68 4a 0f 80 00       	push   $0x800f4a
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 67 0f 80 00       	push   $0x800f67
  800102:	e8 f5 01 00 00       	call   8002fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800107:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5e                   	pop    %esi
  80010c:	5f                   	pop    %edi
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	b8 04 00 00 00       	mov    $0x4,%eax
  800160:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800163:	8b 55 08             	mov    0x8(%ebp),%edx
  800166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800169:	89 f7                	mov    %esi,%edi
  80016b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 17                	jle    800188 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800171:	83 ec 0c             	sub    $0xc,%esp
  800174:	50                   	push   %eax
  800175:	6a 04                	push   $0x4
  800177:	68 4a 0f 80 00       	push   $0x800f4a
  80017c:	6a 23                	push   $0x23
  80017e:	68 67 0f 80 00       	push   $0x800f67
  800183:	e8 74 01 00 00       	call   8002fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018b:	5b                   	pop    %ebx
  80018c:	5e                   	pop    %esi
  80018d:	5f                   	pop    %edi
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800199:	b8 05 00 00 00       	mov    $0x5,%eax
  80019e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7e 17                	jle    8001ca <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b3:	83 ec 0c             	sub    $0xc,%esp
  8001b6:	50                   	push   %eax
  8001b7:	6a 05                	push   $0x5
  8001b9:	68 4a 0f 80 00       	push   $0x800f4a
  8001be:	6a 23                	push   $0x23
  8001c0:	68 67 0f 80 00       	push   $0x800f67
  8001c5:	e8 32 01 00 00       	call   8002fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	89 de                	mov    %ebx,%esi
  8001ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7e 17                	jle    80020c <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	50                   	push   %eax
  8001f9:	6a 06                	push   $0x6
  8001fb:	68 4a 0f 80 00       	push   $0x800f4a
  800200:	6a 23                	push   $0x23
  800202:	68 67 0f 80 00       	push   $0x800f67
  800207:	e8 f0 00 00 00       	call   8002fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	b8 08 00 00 00       	mov    $0x8,%eax
  800227:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7e 17                	jle    80024e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800237:	83 ec 0c             	sub    $0xc,%esp
  80023a:	50                   	push   %eax
  80023b:	6a 08                	push   $0x8
  80023d:	68 4a 0f 80 00       	push   $0x800f4a
  800242:	6a 23                	push   $0x23
  800244:	68 67 0f 80 00       	push   $0x800f67
  800249:	e8 ae 00 00 00       	call   8002fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	b8 09 00 00 00       	mov    $0x9,%eax
  800269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026c:	8b 55 08             	mov    0x8(%ebp),%edx
  80026f:	89 df                	mov    %ebx,%edi
  800271:	89 de                	mov    %ebx,%esi
  800273:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800275:	85 c0                	test   %eax,%eax
  800277:	7e 17                	jle    800290 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800279:	83 ec 0c             	sub    $0xc,%esp
  80027c:	50                   	push   %eax
  80027d:	6a 09                	push   $0x9
  80027f:	68 4a 0f 80 00       	push   $0x800f4a
  800284:	6a 23                	push   $0x23
  800286:	68 67 0f 80 00       	push   $0x800f67
  80028b:	e8 6c 00 00 00       	call   8002fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029e:	be 00 00 00 00       	mov    $0x0,%esi
  8002a3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	89 cb                	mov    %ecx,%ebx
  8002d3:	89 cf                	mov    %ecx,%edi
  8002d5:	89 ce                	mov    %ecx,%esi
  8002d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 17                	jle    8002f4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	83 ec 0c             	sub    $0xc,%esp
  8002e0:	50                   	push   %eax
  8002e1:	6a 0c                	push   $0xc
  8002e3:	68 4a 0f 80 00       	push   $0x800f4a
  8002e8:	6a 23                	push   $0x23
  8002ea:	68 67 0f 80 00       	push   $0x800f67
  8002ef:	e8 08 00 00 00       	call   8002fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f7:	5b                   	pop    %ebx
  8002f8:	5e                   	pop    %esi
  8002f9:	5f                   	pop    %edi
  8002fa:	5d                   	pop    %ebp
  8002fb:	c3                   	ret    

008002fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800301:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800304:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030a:	e8 00 fe ff ff       	call   80010f <sys_getenvid>
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	56                   	push   %esi
  800319:	50                   	push   %eax
  80031a:	68 78 0f 80 00       	push   $0x800f78
  80031f:	e8 b1 00 00 00       	call   8003d5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800324:	83 c4 18             	add    $0x18,%esp
  800327:	53                   	push   %ebx
  800328:	ff 75 10             	pushl  0x10(%ebp)
  80032b:	e8 54 00 00 00       	call   800384 <vcprintf>
	cprintf("\n");
  800330:	c7 04 24 9c 0f 80 00 	movl   $0x800f9c,(%esp)
  800337:	e8 99 00 00 00       	call   8003d5 <cprintf>
  80033c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033f:	cc                   	int3   
  800340:	eb fd                	jmp    80033f <_panic+0x43>

00800342 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	53                   	push   %ebx
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034c:	8b 13                	mov    (%ebx),%edx
  80034e:	8d 42 01             	lea    0x1(%edx),%eax
  800351:	89 03                	mov    %eax,(%ebx)
  800353:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800356:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035f:	75 1a                	jne    80037b <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800361:	83 ec 08             	sub    $0x8,%esp
  800364:	68 ff 00 00 00       	push   $0xff
  800369:	8d 43 08             	lea    0x8(%ebx),%eax
  80036c:	50                   	push   %eax
  80036d:	e8 1f fd ff ff       	call   800091 <sys_cputs>
		b->idx = 0;
  800372:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800378:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80037b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800394:	00 00 00 
	b.cnt = 0;
  800397:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a1:	ff 75 0c             	pushl  0xc(%ebp)
  8003a4:	ff 75 08             	pushl  0x8(%ebp)
  8003a7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ad:	50                   	push   %eax
  8003ae:	68 42 03 80 00       	push   $0x800342
  8003b3:	e8 54 01 00 00       	call   80050c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b8:	83 c4 08             	add    $0x8,%esp
  8003bb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c7:	50                   	push   %eax
  8003c8:	e8 c4 fc ff ff       	call   800091 <sys_cputs>

	return b.cnt;
}
  8003cd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    

008003d5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003de:	50                   	push   %eax
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 9d ff ff ff       	call   800384 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 1c             	sub    $0x1c,%esp
  8003f2:	89 c7                	mov    %eax,%edi
  8003f4:	89 d6                	mov    %edx,%esi
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800402:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800410:	39 d3                	cmp    %edx,%ebx
  800412:	72 05                	jb     800419 <printnum+0x30>
  800414:	39 45 10             	cmp    %eax,0x10(%ebp)
  800417:	77 45                	ja     80045e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800419:	83 ec 0c             	sub    $0xc,%esp
  80041c:	ff 75 18             	pushl  0x18(%ebp)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800425:	53                   	push   %ebx
  800426:	ff 75 10             	pushl  0x10(%ebp)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042f:	ff 75 e0             	pushl  -0x20(%ebp)
  800432:	ff 75 dc             	pushl  -0x24(%ebp)
  800435:	ff 75 d8             	pushl  -0x28(%ebp)
  800438:	e8 73 08 00 00       	call   800cb0 <__udivdi3>
  80043d:	83 c4 18             	add    $0x18,%esp
  800440:	52                   	push   %edx
  800441:	50                   	push   %eax
  800442:	89 f2                	mov    %esi,%edx
  800444:	89 f8                	mov    %edi,%eax
  800446:	e8 9e ff ff ff       	call   8003e9 <printnum>
  80044b:	83 c4 20             	add    $0x20,%esp
  80044e:	eb 18                	jmp    800468 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	56                   	push   %esi
  800454:	ff 75 18             	pushl  0x18(%ebp)
  800457:	ff d7                	call   *%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	eb 03                	jmp    800461 <printnum+0x78>
  80045e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800461:	83 eb 01             	sub    $0x1,%ebx
  800464:	85 db                	test   %ebx,%ebx
  800466:	7f e8                	jg     800450 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	56                   	push   %esi
  80046c:	83 ec 04             	sub    $0x4,%esp
  80046f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff 75 dc             	pushl  -0x24(%ebp)
  800478:	ff 75 d8             	pushl  -0x28(%ebp)
  80047b:	e8 60 09 00 00       	call   800de0 <__umoddi3>
  800480:	83 c4 14             	add    $0x14,%esp
  800483:	0f be 80 9e 0f 80 00 	movsbl 0x800f9e(%eax),%eax
  80048a:	50                   	push   %eax
  80048b:	ff d7                	call   *%edi
}
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800493:	5b                   	pop    %ebx
  800494:	5e                   	pop    %esi
  800495:	5f                   	pop    %edi
  800496:	5d                   	pop    %ebp
  800497:	c3                   	ret    

00800498 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800498:	55                   	push   %ebp
  800499:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80049b:	83 fa 01             	cmp    $0x1,%edx
  80049e:	7e 0e                	jle    8004ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a0:	8b 10                	mov    (%eax),%edx
  8004a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a5:	89 08                	mov    %ecx,(%eax)
  8004a7:	8b 02                	mov    (%edx),%eax
  8004a9:	8b 52 04             	mov    0x4(%edx),%edx
  8004ac:	eb 22                	jmp    8004d0 <getuint+0x38>
	else if (lflag)
  8004ae:	85 d2                	test   %edx,%edx
  8004b0:	74 10                	je     8004c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b2:	8b 10                	mov    (%eax),%edx
  8004b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b7:	89 08                	mov    %ecx,(%eax)
  8004b9:	8b 02                	mov    (%edx),%eax
  8004bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c0:	eb 0e                	jmp    8004d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004dc:	8b 10                	mov    (%eax),%edx
  8004de:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e1:	73 0a                	jae    8004ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e6:	89 08                	mov    %ecx,(%eax)
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	88 02                	mov    %al,(%edx)
}
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 10             	pushl  0x10(%ebp)
  8004fc:	ff 75 0c             	pushl  0xc(%ebp)
  8004ff:	ff 75 08             	pushl  0x8(%ebp)
  800502:	e8 05 00 00 00       	call   80050c <vprintfmt>
	va_end(ap);
}
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	c9                   	leave  
  80050b:	c3                   	ret    

0080050c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80050c:	55                   	push   %ebp
  80050d:	89 e5                	mov    %esp,%ebp
  80050f:	57                   	push   %edi
  800510:	56                   	push   %esi
  800511:	53                   	push   %ebx
  800512:	83 ec 2c             	sub    $0x2c,%esp
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051e:	eb 12                	jmp    800532 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800520:	85 c0                	test   %eax,%eax
  800522:	0f 84 89 03 00 00    	je     8008b1 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	53                   	push   %ebx
  80052c:	50                   	push   %eax
  80052d:	ff d6                	call   *%esi
  80052f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800532:	83 c7 01             	add    $0x1,%edi
  800535:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800539:	83 f8 25             	cmp    $0x25,%eax
  80053c:	75 e2                	jne    800520 <vprintfmt+0x14>
  80053e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800542:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800549:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800550:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800557:	ba 00 00 00 00       	mov    $0x0,%edx
  80055c:	eb 07                	jmp    800565 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800561:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8d 47 01             	lea    0x1(%edi),%eax
  800568:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056b:	0f b6 07             	movzbl (%edi),%eax
  80056e:	0f b6 c8             	movzbl %al,%ecx
  800571:	83 e8 23             	sub    $0x23,%eax
  800574:	3c 55                	cmp    $0x55,%al
  800576:	0f 87 1a 03 00 00    	ja     800896 <vprintfmt+0x38a>
  80057c:	0f b6 c0             	movzbl %al,%eax
  80057f:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  800586:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800589:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80058d:	eb d6                	jmp    800565 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800592:	b8 00 00 00 00       	mov    $0x0,%eax
  800597:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005a1:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a4:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005a7:	83 fa 09             	cmp    $0x9,%edx
  8005aa:	77 39                	ja     8005e5 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005af:	eb e9                	jmp    80059a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 48 04             	lea    0x4(%eax),%ecx
  8005b7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c2:	eb 27                	jmp    8005eb <vprintfmt+0xdf>
  8005c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c7:	85 c0                	test   %eax,%eax
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	0f 49 c8             	cmovns %eax,%ecx
  8005d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d7:	eb 8c                	jmp    800565 <vprintfmt+0x59>
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005dc:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e3:	eb 80                	jmp    800565 <vprintfmt+0x59>
  8005e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e8:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ef:	0f 89 70 ff ff ff    	jns    800565 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800602:	e9 5e ff ff ff       	jmp    800565 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800607:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80060d:	e9 53 ff ff ff       	jmp    800565 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	53                   	push   %ebx
  80061f:	ff 30                	pushl  (%eax)
  800621:	ff d6                	call   *%esi
			break;
  800623:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800629:	e9 04 ff ff ff       	jmp    800532 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	99                   	cltd   
  80063a:	31 d0                	xor    %edx,%eax
  80063c:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063e:	83 f8 08             	cmp    $0x8,%eax
  800641:	7f 0b                	jg     80064e <vprintfmt+0x142>
  800643:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80064a:	85 d2                	test   %edx,%edx
  80064c:	75 18                	jne    800666 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80064e:	50                   	push   %eax
  80064f:	68 b6 0f 80 00       	push   $0x800fb6
  800654:	53                   	push   %ebx
  800655:	56                   	push   %esi
  800656:	e8 94 fe ff ff       	call   8004ef <printfmt>
  80065b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800661:	e9 cc fe ff ff       	jmp    800532 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800666:	52                   	push   %edx
  800667:	68 bf 0f 80 00       	push   $0x800fbf
  80066c:	53                   	push   %ebx
  80066d:	56                   	push   %esi
  80066e:	e8 7c fe ff ff       	call   8004ef <printfmt>
  800673:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800679:	e9 b4 fe ff ff       	jmp    800532 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8d 50 04             	lea    0x4(%eax),%edx
  800684:	89 55 14             	mov    %edx,0x14(%ebp)
  800687:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800689:	85 ff                	test   %edi,%edi
  80068b:	b8 af 0f 80 00       	mov    $0x800faf,%eax
  800690:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800693:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800697:	0f 8e 94 00 00 00    	jle    800731 <vprintfmt+0x225>
  80069d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a1:	0f 84 98 00 00 00    	je     80073f <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8006ad:	57                   	push   %edi
  8006ae:	e8 86 02 00 00       	call   800939 <strnlen>
  8006b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b6:	29 c1                	sub    %eax,%ecx
  8006b8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ca:	eb 0f                	jmp    8006db <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006cc:	83 ec 08             	sub    $0x8,%esp
  8006cf:	53                   	push   %ebx
  8006d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d5:	83 ef 01             	sub    $0x1,%edi
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	85 ff                	test   %edi,%edi
  8006dd:	7f ed                	jg     8006cc <vprintfmt+0x1c0>
  8006df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006e2:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006e5:	85 c9                	test   %ecx,%ecx
  8006e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ec:	0f 49 c1             	cmovns %ecx,%eax
  8006ef:	29 c1                	sub    %eax,%ecx
  8006f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006fa:	89 cb                	mov    %ecx,%ebx
  8006fc:	eb 4d                	jmp    80074b <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800702:	74 1b                	je     80071f <vprintfmt+0x213>
  800704:	0f be c0             	movsbl %al,%eax
  800707:	83 e8 20             	sub    $0x20,%eax
  80070a:	83 f8 5e             	cmp    $0x5e,%eax
  80070d:	76 10                	jbe    80071f <vprintfmt+0x213>
					putch('?', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	ff 75 0c             	pushl  0xc(%ebp)
  800715:	6a 3f                	push   $0x3f
  800717:	ff 55 08             	call   *0x8(%ebp)
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	eb 0d                	jmp    80072c <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	52                   	push   %edx
  800726:	ff 55 08             	call   *0x8(%ebp)
  800729:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072c:	83 eb 01             	sub    $0x1,%ebx
  80072f:	eb 1a                	jmp    80074b <vprintfmt+0x23f>
  800731:	89 75 08             	mov    %esi,0x8(%ebp)
  800734:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800737:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80073d:	eb 0c                	jmp    80074b <vprintfmt+0x23f>
  80073f:	89 75 08             	mov    %esi,0x8(%ebp)
  800742:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800745:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800748:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074b:	83 c7 01             	add    $0x1,%edi
  80074e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800752:	0f be d0             	movsbl %al,%edx
  800755:	85 d2                	test   %edx,%edx
  800757:	74 23                	je     80077c <vprintfmt+0x270>
  800759:	85 f6                	test   %esi,%esi
  80075b:	78 a1                	js     8006fe <vprintfmt+0x1f2>
  80075d:	83 ee 01             	sub    $0x1,%esi
  800760:	79 9c                	jns    8006fe <vprintfmt+0x1f2>
  800762:	89 df                	mov    %ebx,%edi
  800764:	8b 75 08             	mov    0x8(%ebp),%esi
  800767:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076a:	eb 18                	jmp    800784 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80076c:	83 ec 08             	sub    $0x8,%esp
  80076f:	53                   	push   %ebx
  800770:	6a 20                	push   $0x20
  800772:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800774:	83 ef 01             	sub    $0x1,%edi
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	eb 08                	jmp    800784 <vprintfmt+0x278>
  80077c:	89 df                	mov    %ebx,%edi
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800784:	85 ff                	test   %edi,%edi
  800786:	7f e4                	jg     80076c <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80078b:	e9 a2 fd ff ff       	jmp    800532 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800790:	83 fa 01             	cmp    $0x1,%edx
  800793:	7e 16                	jle    8007ab <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 50 08             	lea    0x8(%eax),%edx
  80079b:	89 55 14             	mov    %edx,0x14(%ebp)
  80079e:	8b 50 04             	mov    0x4(%eax),%edx
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a9:	eb 32                	jmp    8007dd <vprintfmt+0x2d1>
	else if (lflag)
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 18                	je     8007c7 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 50 04             	lea    0x4(%eax),%edx
  8007b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b8:	8b 00                	mov    (%eax),%eax
  8007ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bd:	89 c1                	mov    %eax,%ecx
  8007bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c5:	eb 16                	jmp    8007dd <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8d 50 04             	lea    0x4(%eax),%edx
  8007cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007e8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007ec:	79 74                	jns    800862 <vprintfmt+0x356>
				putch('-', putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 2d                	push   $0x2d
  8007f4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007fc:	f7 d8                	neg    %eax
  8007fe:	83 d2 00             	adc    $0x0,%edx
  800801:	f7 da                	neg    %edx
  800803:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800806:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80080b:	eb 55                	jmp    800862 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80080d:	8d 45 14             	lea    0x14(%ebp),%eax
  800810:	e8 83 fc ff ff       	call   800498 <getuint>
			base = 10;
  800815:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80081a:	eb 46                	jmp    800862 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80081c:	8d 45 14             	lea    0x14(%ebp),%eax
  80081f:	e8 74 fc ff ff       	call   800498 <getuint>
			base = 8;
  800824:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800829:	eb 37                	jmp    800862 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	53                   	push   %ebx
  80082f:	6a 30                	push   $0x30
  800831:	ff d6                	call   *%esi
			putch('x', putdat);
  800833:	83 c4 08             	add    $0x8,%esp
  800836:	53                   	push   %ebx
  800837:	6a 78                	push   $0x78
  800839:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8d 50 04             	lea    0x4(%eax),%edx
  800841:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800844:	8b 00                	mov    (%eax),%eax
  800846:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80084b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80084e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800853:	eb 0d                	jmp    800862 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
  800858:	e8 3b fc ff ff       	call   800498 <getuint>
			base = 16;
  80085d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800862:	83 ec 0c             	sub    $0xc,%esp
  800865:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800869:	57                   	push   %edi
  80086a:	ff 75 e0             	pushl  -0x20(%ebp)
  80086d:	51                   	push   %ecx
  80086e:	52                   	push   %edx
  80086f:	50                   	push   %eax
  800870:	89 da                	mov    %ebx,%edx
  800872:	89 f0                	mov    %esi,%eax
  800874:	e8 70 fb ff ff       	call   8003e9 <printnum>
			break;
  800879:	83 c4 20             	add    $0x20,%esp
  80087c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80087f:	e9 ae fc ff ff       	jmp    800532 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	51                   	push   %ecx
  800889:	ff d6                	call   *%esi
			break;
  80088b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800891:	e9 9c fc ff ff       	jmp    800532 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800896:	83 ec 08             	sub    $0x8,%esp
  800899:	53                   	push   %ebx
  80089a:	6a 25                	push   $0x25
  80089c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	eb 03                	jmp    8008a6 <vprintfmt+0x39a>
  8008a3:	83 ef 01             	sub    $0x1,%edi
  8008a6:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008aa:	75 f7                	jne    8008a3 <vprintfmt+0x397>
  8008ac:	e9 81 fc ff ff       	jmp    800532 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5f                   	pop    %edi
  8008b7:	5d                   	pop    %ebp
  8008b8:	c3                   	ret    

008008b9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	83 ec 18             	sub    $0x18,%esp
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008c8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008cc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008d6:	85 c0                	test   %eax,%eax
  8008d8:	74 26                	je     800900 <vsnprintf+0x47>
  8008da:	85 d2                	test   %edx,%edx
  8008dc:	7e 22                	jle    800900 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008de:	ff 75 14             	pushl  0x14(%ebp)
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008e7:	50                   	push   %eax
  8008e8:	68 d2 04 80 00       	push   $0x8004d2
  8008ed:	e8 1a fc ff ff       	call   80050c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	eb 05                	jmp    800905 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800900:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800905:	c9                   	leave  
  800906:	c3                   	ret    

00800907 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80090d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800910:	50                   	push   %eax
  800911:	ff 75 10             	pushl  0x10(%ebp)
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	ff 75 08             	pushl  0x8(%ebp)
  80091a:	e8 9a ff ff ff       	call   8008b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
  80092c:	eb 03                	jmp    800931 <strlen+0x10>
		n++;
  80092e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800931:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800935:	75 f7                	jne    80092e <strlen+0xd>
		n++;
	return n;
}
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800942:	ba 00 00 00 00       	mov    $0x0,%edx
  800947:	eb 03                	jmp    80094c <strnlen+0x13>
		n++;
  800949:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094c:	39 c2                	cmp    %eax,%edx
  80094e:	74 08                	je     800958 <strnlen+0x1f>
  800950:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800954:	75 f3                	jne    800949 <strnlen+0x10>
  800956:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800964:	89 c2                	mov    %eax,%edx
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800970:	88 5a ff             	mov    %bl,-0x1(%edx)
  800973:	84 db                	test   %bl,%bl
  800975:	75 ef                	jne    800966 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800981:	53                   	push   %ebx
  800982:	e8 9a ff ff ff       	call   800921 <strlen>
  800987:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098a:	ff 75 0c             	pushl  0xc(%ebp)
  80098d:	01 d8                	add    %ebx,%eax
  80098f:	50                   	push   %eax
  800990:	e8 c5 ff ff ff       	call   80095a <strcpy>
	return dst;
}
  800995:	89 d8                	mov    %ebx,%eax
  800997:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a7:	89 f3                	mov    %esi,%ebx
  8009a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ac:	89 f2                	mov    %esi,%edx
  8009ae:	eb 0f                	jmp    8009bf <strncpy+0x23>
		*dst++ = *src;
  8009b0:	83 c2 01             	add    $0x1,%edx
  8009b3:	0f b6 01             	movzbl (%ecx),%eax
  8009b6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b9:	80 39 01             	cmpb   $0x1,(%ecx)
  8009bc:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bf:	39 da                	cmp    %ebx,%edx
  8009c1:	75 ed                	jne    8009b0 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c3:	89 f0                	mov    %esi,%eax
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
  8009ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d4:	8b 55 10             	mov    0x10(%ebp),%edx
  8009d7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d9:	85 d2                	test   %edx,%edx
  8009db:	74 21                	je     8009fe <strlcpy+0x35>
  8009dd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009e1:	89 f2                	mov    %esi,%edx
  8009e3:	eb 09                	jmp    8009ee <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e5:	83 c2 01             	add    $0x1,%edx
  8009e8:	83 c1 01             	add    $0x1,%ecx
  8009eb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ee:	39 c2                	cmp    %eax,%edx
  8009f0:	74 09                	je     8009fb <strlcpy+0x32>
  8009f2:	0f b6 19             	movzbl (%ecx),%ebx
  8009f5:	84 db                	test   %bl,%bl
  8009f7:	75 ec                	jne    8009e5 <strlcpy+0x1c>
  8009f9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009fb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009fe:	29 f0                	sub    %esi,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0d:	eb 06                	jmp    800a15 <strcmp+0x11>
		p++, q++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
  800a12:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a15:	0f b6 01             	movzbl (%ecx),%eax
  800a18:	84 c0                	test   %al,%al
  800a1a:	74 04                	je     800a20 <strcmp+0x1c>
  800a1c:	3a 02                	cmp    (%edx),%al
  800a1e:	74 ef                	je     800a0f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a20:	0f b6 c0             	movzbl %al,%eax
  800a23:	0f b6 12             	movzbl (%edx),%edx
  800a26:	29 d0                	sub    %edx,%eax
}
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	53                   	push   %ebx
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a34:	89 c3                	mov    %eax,%ebx
  800a36:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a39:	eb 06                	jmp    800a41 <strncmp+0x17>
		n--, p++, q++;
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a41:	39 d8                	cmp    %ebx,%eax
  800a43:	74 15                	je     800a5a <strncmp+0x30>
  800a45:	0f b6 08             	movzbl (%eax),%ecx
  800a48:	84 c9                	test   %cl,%cl
  800a4a:	74 04                	je     800a50 <strncmp+0x26>
  800a4c:	3a 0a                	cmp    (%edx),%cl
  800a4e:	74 eb                	je     800a3b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a50:	0f b6 00             	movzbl (%eax),%eax
  800a53:	0f b6 12             	movzbl (%edx),%edx
  800a56:	29 d0                	sub    %edx,%eax
  800a58:	eb 05                	jmp    800a5f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a5a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6c:	eb 07                	jmp    800a75 <strchr+0x13>
		if (*s == c)
  800a6e:	38 ca                	cmp    %cl,%dl
  800a70:	74 0f                	je     800a81 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	75 f2                	jne    800a6e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8d:	eb 03                	jmp    800a92 <strfind+0xf>
  800a8f:	83 c0 01             	add    $0x1,%eax
  800a92:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a95:	38 ca                	cmp    %cl,%dl
  800a97:	74 04                	je     800a9d <strfind+0x1a>
  800a99:	84 d2                	test   %dl,%dl
  800a9b:	75 f2                	jne    800a8f <strfind+0xc>
			break;
	return (char *) s;
}
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	57                   	push   %edi
  800aa3:	56                   	push   %esi
  800aa4:	53                   	push   %ebx
  800aa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aab:	85 c9                	test   %ecx,%ecx
  800aad:	74 36                	je     800ae5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aaf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab5:	75 28                	jne    800adf <memset+0x40>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 23                	jne    800adf <memset+0x40>
		c &= 0xFF;
  800abc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac0:	89 d3                	mov    %edx,%ebx
  800ac2:	c1 e3 08             	shl    $0x8,%ebx
  800ac5:	89 d6                	mov    %edx,%esi
  800ac7:	c1 e6 18             	shl    $0x18,%esi
  800aca:	89 d0                	mov    %edx,%eax
  800acc:	c1 e0 10             	shl    $0x10,%eax
  800acf:	09 f0                	or     %esi,%eax
  800ad1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ad3:	89 d8                	mov    %ebx,%eax
  800ad5:	09 d0                	or     %edx,%eax
  800ad7:	c1 e9 02             	shr    $0x2,%ecx
  800ada:	fc                   	cld    
  800adb:	f3 ab                	rep stos %eax,%es:(%edi)
  800add:	eb 06                	jmp    800ae5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800adf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae2:	fc                   	cld    
  800ae3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae5:	89 f8                	mov    %edi,%eax
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5f                   	pop    %edi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afa:	39 c6                	cmp    %eax,%esi
  800afc:	73 35                	jae    800b33 <memmove+0x47>
  800afe:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b01:	39 d0                	cmp    %edx,%eax
  800b03:	73 2e                	jae    800b33 <memmove+0x47>
		s += n;
		d += n;
  800b05:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b08:	89 d6                	mov    %edx,%esi
  800b0a:	09 fe                	or     %edi,%esi
  800b0c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b12:	75 13                	jne    800b27 <memmove+0x3b>
  800b14:	f6 c1 03             	test   $0x3,%cl
  800b17:	75 0e                	jne    800b27 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b19:	83 ef 04             	sub    $0x4,%edi
  800b1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
  800b22:	fd                   	std    
  800b23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b25:	eb 09                	jmp    800b30 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b27:	83 ef 01             	sub    $0x1,%edi
  800b2a:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b2d:	fd                   	std    
  800b2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b30:	fc                   	cld    
  800b31:	eb 1d                	jmp    800b50 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b33:	89 f2                	mov    %esi,%edx
  800b35:	09 c2                	or     %eax,%edx
  800b37:	f6 c2 03             	test   $0x3,%dl
  800b3a:	75 0f                	jne    800b4b <memmove+0x5f>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 0a                	jne    800b4b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b41:	c1 e9 02             	shr    $0x2,%ecx
  800b44:	89 c7                	mov    %eax,%edi
  800b46:	fc                   	cld    
  800b47:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b49:	eb 05                	jmp    800b50 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b4b:	89 c7                	mov    %eax,%edi
  800b4d:	fc                   	cld    
  800b4e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b57:	ff 75 10             	pushl  0x10(%ebp)
  800b5a:	ff 75 0c             	pushl  0xc(%ebp)
  800b5d:	ff 75 08             	pushl  0x8(%ebp)
  800b60:	e8 87 ff ff ff       	call   800aec <memmove>
}
  800b65:	c9                   	leave  
  800b66:	c3                   	ret    

00800b67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b72:	89 c6                	mov    %eax,%esi
  800b74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b77:	eb 1a                	jmp    800b93 <memcmp+0x2c>
		if (*s1 != *s2)
  800b79:	0f b6 08             	movzbl (%eax),%ecx
  800b7c:	0f b6 1a             	movzbl (%edx),%ebx
  800b7f:	38 d9                	cmp    %bl,%cl
  800b81:	74 0a                	je     800b8d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b83:	0f b6 c1             	movzbl %cl,%eax
  800b86:	0f b6 db             	movzbl %bl,%ebx
  800b89:	29 d8                	sub    %ebx,%eax
  800b8b:	eb 0f                	jmp    800b9c <memcmp+0x35>
		s1++, s2++;
  800b8d:	83 c0 01             	add    $0x1,%eax
  800b90:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b93:	39 f0                	cmp    %esi,%eax
  800b95:	75 e2                	jne    800b79 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	53                   	push   %ebx
  800ba4:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ba7:	89 c1                	mov    %eax,%ecx
  800ba9:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bac:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb0:	eb 0a                	jmp    800bbc <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb2:	0f b6 10             	movzbl (%eax),%edx
  800bb5:	39 da                	cmp    %ebx,%edx
  800bb7:	74 07                	je     800bc0 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb9:	83 c0 01             	add    $0x1,%eax
  800bbc:	39 c8                	cmp    %ecx,%eax
  800bbe:	72 f2                	jb     800bb2 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bcf:	eb 03                	jmp    800bd4 <strtol+0x11>
		s++;
  800bd1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd4:	0f b6 01             	movzbl (%ecx),%eax
  800bd7:	3c 20                	cmp    $0x20,%al
  800bd9:	74 f6                	je     800bd1 <strtol+0xe>
  800bdb:	3c 09                	cmp    $0x9,%al
  800bdd:	74 f2                	je     800bd1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bdf:	3c 2b                	cmp    $0x2b,%al
  800be1:	75 0a                	jne    800bed <strtol+0x2a>
		s++;
  800be3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be6:	bf 00 00 00 00       	mov    $0x0,%edi
  800beb:	eb 11                	jmp    800bfe <strtol+0x3b>
  800bed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf2:	3c 2d                	cmp    $0x2d,%al
  800bf4:	75 08                	jne    800bfe <strtol+0x3b>
		s++, neg = 1;
  800bf6:	83 c1 01             	add    $0x1,%ecx
  800bf9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c04:	75 15                	jne    800c1b <strtol+0x58>
  800c06:	80 39 30             	cmpb   $0x30,(%ecx)
  800c09:	75 10                	jne    800c1b <strtol+0x58>
  800c0b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c0f:	75 7c                	jne    800c8d <strtol+0xca>
		s += 2, base = 16;
  800c11:	83 c1 02             	add    $0x2,%ecx
  800c14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c19:	eb 16                	jmp    800c31 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c1b:	85 db                	test   %ebx,%ebx
  800c1d:	75 12                	jne    800c31 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c1f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c24:	80 39 30             	cmpb   $0x30,(%ecx)
  800c27:	75 08                	jne    800c31 <strtol+0x6e>
		s++, base = 8;
  800c29:	83 c1 01             	add    $0x1,%ecx
  800c2c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
  800c36:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c39:	0f b6 11             	movzbl (%ecx),%edx
  800c3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c3f:	89 f3                	mov    %esi,%ebx
  800c41:	80 fb 09             	cmp    $0x9,%bl
  800c44:	77 08                	ja     800c4e <strtol+0x8b>
			dig = *s - '0';
  800c46:	0f be d2             	movsbl %dl,%edx
  800c49:	83 ea 30             	sub    $0x30,%edx
  800c4c:	eb 22                	jmp    800c70 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c4e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 08                	ja     800c60 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c58:	0f be d2             	movsbl %dl,%edx
  800c5b:	83 ea 57             	sub    $0x57,%edx
  800c5e:	eb 10                	jmp    800c70 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c60:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c63:	89 f3                	mov    %esi,%ebx
  800c65:	80 fb 19             	cmp    $0x19,%bl
  800c68:	77 16                	ja     800c80 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c6a:	0f be d2             	movsbl %dl,%edx
  800c6d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c70:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c73:	7d 0b                	jge    800c80 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c75:	83 c1 01             	add    $0x1,%ecx
  800c78:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c7c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c7e:	eb b9                	jmp    800c39 <strtol+0x76>

	if (endptr)
  800c80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c84:	74 0d                	je     800c93 <strtol+0xd0>
		*endptr = (char *) s;
  800c86:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c89:	89 0e                	mov    %ecx,(%esi)
  800c8b:	eb 06                	jmp    800c93 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8d:	85 db                	test   %ebx,%ebx
  800c8f:	74 98                	je     800c29 <strtol+0x66>
  800c91:	eb 9e                	jmp    800c31 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c93:	89 c2                	mov    %eax,%edx
  800c95:	f7 da                	neg    %edx
  800c97:	85 ff                	test   %edi,%edi
  800c99:	0f 45 c2             	cmovne %edx,%eax
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    
  800ca1:	66 90                	xchg   %ax,%ax
  800ca3:	66 90                	xchg   %ax,%ax
  800ca5:	66 90                	xchg   %ax,%ax
  800ca7:	66 90                	xchg   %ax,%ax
  800ca9:	66 90                	xchg   %ax,%ax
  800cab:	66 90                	xchg   %ax,%ax
  800cad:	66 90                	xchg   %ax,%ax
  800caf:	90                   	nop

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
