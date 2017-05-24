
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 5d 00 00 00       	call   8000a2 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 6a 0f 80 00       	push   $0x800f6a
  80010c:	6a 23                	push   $0x23
  80010e:	68 87 0f 80 00       	push   $0x800f87
  800113:	e8 f5 01 00 00       	call   80030d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 6a 0f 80 00       	push   $0x800f6a
  80018d:	6a 23                	push   $0x23
  80018f:	68 87 0f 80 00       	push   $0x800f87
  800194:	e8 74 01 00 00       	call   80030d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 6a 0f 80 00       	push   $0x800f6a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 87 0f 80 00       	push   $0x800f87
  8001d6:	e8 32 01 00 00       	call   80030d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 6a 0f 80 00       	push   $0x800f6a
  800211:	6a 23                	push   $0x23
  800213:	68 87 0f 80 00       	push   $0x800f87
  800218:	e8 f0 00 00 00       	call   80030d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 6a 0f 80 00       	push   $0x800f6a
  800253:	6a 23                	push   $0x23
  800255:	68 87 0f 80 00       	push   $0x800f87
  80025a:	e8 ae 00 00 00       	call   80030d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 6a 0f 80 00       	push   $0x800f6a
  800295:	6a 23                	push   $0x23
  800297:	68 87 0f 80 00       	push   $0x800f87
  80029c:	e8 6c 00 00 00       	call   80030d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002af:	be 00 00 00 00       	mov    $0x0,%esi
  8002b4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7e 17                	jle    800305 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ee:	83 ec 0c             	sub    $0xc,%esp
  8002f1:	50                   	push   %eax
  8002f2:	6a 0c                	push   $0xc
  8002f4:	68 6a 0f 80 00       	push   $0x800f6a
  8002f9:	6a 23                	push   $0x23
  8002fb:	68 87 0f 80 00       	push   $0x800f87
  800300:	e8 08 00 00 00       	call   80030d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800305:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800308:	5b                   	pop    %ebx
  800309:	5e                   	pop    %esi
  80030a:	5f                   	pop    %edi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800315:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031b:	e8 00 fe ff ff       	call   800120 <sys_getenvid>
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	56                   	push   %esi
  80032a:	50                   	push   %eax
  80032b:	68 98 0f 80 00       	push   $0x800f98
  800330:	e8 b1 00 00 00       	call   8003e6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	53                   	push   %ebx
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	e8 54 00 00 00       	call   800395 <vcprintf>
	cprintf("\n");
  800341:	c7 04 24 bc 0f 80 00 	movl   $0x800fbc,(%esp)
  800348:	e8 99 00 00 00       	call   8003e6 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800350:	cc                   	int3   
  800351:	eb fd                	jmp    800350 <_panic+0x43>

00800353 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	53                   	push   %ebx
  800357:	83 ec 04             	sub    $0x4,%esp
  80035a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035d:	8b 13                	mov    (%ebx),%edx
  80035f:	8d 42 01             	lea    0x1(%edx),%eax
  800362:	89 03                	mov    %eax,(%ebx)
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800370:	75 1a                	jne    80038c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	68 ff 00 00 00       	push   $0xff
  80037a:	8d 43 08             	lea    0x8(%ebx),%eax
  80037d:	50                   	push   %eax
  80037e:	e8 1f fd ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  800383:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800389:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80038c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800390:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800393:	c9                   	leave  
  800394:	c3                   	ret    

00800395 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a5:	00 00 00 
	b.cnt = 0;
  8003a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b2:	ff 75 0c             	pushl  0xc(%ebp)
  8003b5:	ff 75 08             	pushl  0x8(%ebp)
  8003b8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003be:	50                   	push   %eax
  8003bf:	68 53 03 80 00       	push   $0x800353
  8003c4:	e8 54 01 00 00       	call   80051d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c9:	83 c4 08             	add    $0x8,%esp
  8003cc:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d8:	50                   	push   %eax
  8003d9:	e8 c4 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8003de:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e4:	c9                   	leave  
  8003e5:	c3                   	ret    

008003e6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ec:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ef:	50                   	push   %eax
  8003f0:	ff 75 08             	pushl  0x8(%ebp)
  8003f3:	e8 9d ff ff ff       	call   800395 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f8:	c9                   	leave  
  8003f9:	c3                   	ret    

008003fa <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	57                   	push   %edi
  8003fe:	56                   	push   %esi
  8003ff:	53                   	push   %ebx
  800400:	83 ec 1c             	sub    $0x1c,%esp
  800403:	89 c7                	mov    %eax,%edi
  800405:	89 d6                	mov    %edx,%esi
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
  80040a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800410:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800416:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800421:	39 d3                	cmp    %edx,%ebx
  800423:	72 05                	jb     80042a <printnum+0x30>
  800425:	39 45 10             	cmp    %eax,0x10(%ebp)
  800428:	77 45                	ja     80046f <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042a:	83 ec 0c             	sub    $0xc,%esp
  80042d:	ff 75 18             	pushl  0x18(%ebp)
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800436:	53                   	push   %ebx
  800437:	ff 75 10             	pushl  0x10(%ebp)
  80043a:	83 ec 08             	sub    $0x8,%esp
  80043d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff 75 dc             	pushl  -0x24(%ebp)
  800446:	ff 75 d8             	pushl  -0x28(%ebp)
  800449:	e8 72 08 00 00       	call   800cc0 <__udivdi3>
  80044e:	83 c4 18             	add    $0x18,%esp
  800451:	52                   	push   %edx
  800452:	50                   	push   %eax
  800453:	89 f2                	mov    %esi,%edx
  800455:	89 f8                	mov    %edi,%eax
  800457:	e8 9e ff ff ff       	call   8003fa <printnum>
  80045c:	83 c4 20             	add    $0x20,%esp
  80045f:	eb 18                	jmp    800479 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	56                   	push   %esi
  800465:	ff 75 18             	pushl  0x18(%ebp)
  800468:	ff d7                	call   *%edi
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	eb 03                	jmp    800472 <printnum+0x78>
  80046f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800472:	83 eb 01             	sub    $0x1,%ebx
  800475:	85 db                	test   %ebx,%ebx
  800477:	7f e8                	jg     800461 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	56                   	push   %esi
  80047d:	83 ec 04             	sub    $0x4,%esp
  800480:	ff 75 e4             	pushl  -0x1c(%ebp)
  800483:	ff 75 e0             	pushl  -0x20(%ebp)
  800486:	ff 75 dc             	pushl  -0x24(%ebp)
  800489:	ff 75 d8             	pushl  -0x28(%ebp)
  80048c:	e8 5f 09 00 00       	call   800df0 <__umoddi3>
  800491:	83 c4 14             	add    $0x14,%esp
  800494:	0f be 80 be 0f 80 00 	movsbl 0x800fbe(%eax),%eax
  80049b:	50                   	push   %eax
  80049c:	ff d7                	call   *%edi
}
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ac:	83 fa 01             	cmp    $0x1,%edx
  8004af:	7e 0e                	jle    8004bf <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b1:	8b 10                	mov    (%eax),%edx
  8004b3:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 02                	mov    (%edx),%eax
  8004ba:	8b 52 04             	mov    0x4(%edx),%edx
  8004bd:	eb 22                	jmp    8004e1 <getuint+0x38>
	else if (lflag)
  8004bf:	85 d2                	test   %edx,%edx
  8004c1:	74 10                	je     8004d3 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c8:	89 08                	mov    %ecx,(%eax)
  8004ca:	8b 02                	mov    (%edx),%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	eb 0e                	jmp    8004e1 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d3:	8b 10                	mov    (%eax),%edx
  8004d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d8:	89 08                	mov    %ecx,(%eax)
  8004da:	8b 02                	mov    (%edx),%eax
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ed:	8b 10                	mov    (%eax),%edx
  8004ef:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f2:	73 0a                	jae    8004fe <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f7:	89 08                	mov    %ecx,(%eax)
  8004f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fc:	88 02                	mov    %al,(%edx)
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800506:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800509:	50                   	push   %eax
  80050a:	ff 75 10             	pushl  0x10(%ebp)
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	ff 75 08             	pushl  0x8(%ebp)
  800513:	e8 05 00 00 00       	call   80051d <vprintfmt>
	va_end(ap);
}
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 2c             	sub    $0x2c,%esp
  800526:	8b 75 08             	mov    0x8(%ebp),%esi
  800529:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052f:	eb 12                	jmp    800543 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800531:	85 c0                	test   %eax,%eax
  800533:	0f 84 89 03 00 00    	je     8008c2 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	50                   	push   %eax
  80053e:	ff d6                	call   *%esi
  800540:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800543:	83 c7 01             	add    $0x1,%edi
  800546:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054a:	83 f8 25             	cmp    $0x25,%eax
  80054d:	75 e2                	jne    800531 <vprintfmt+0x14>
  80054f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800553:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800561:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800568:	ba 00 00 00 00       	mov    $0x0,%edx
  80056d:	eb 07                	jmp    800576 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800572:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800576:	8d 47 01             	lea    0x1(%edi),%eax
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	0f b6 07             	movzbl (%edi),%eax
  80057f:	0f b6 c8             	movzbl %al,%ecx
  800582:	83 e8 23             	sub    $0x23,%eax
  800585:	3c 55                	cmp    $0x55,%al
  800587:	0f 87 1a 03 00 00    	ja     8008a7 <vprintfmt+0x38a>
  80058d:	0f b6 c0             	movzbl %al,%eax
  800590:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059e:	eb d6                	jmp    800576 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ae:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b2:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b5:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b8:	83 fa 09             	cmp    $0x9,%edx
  8005bb:	77 39                	ja     8005f6 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c0:	eb e9                	jmp    8005ab <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c8:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d3:	eb 27                	jmp    8005fc <vprintfmt+0xdf>
  8005d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	0f 49 c8             	cmovns %eax,%ecx
  8005e2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e8:	eb 8c                	jmp    800576 <vprintfmt+0x59>
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f4:	eb 80                	jmp    800576 <vprintfmt+0x59>
  8005f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800600:	0f 89 70 ff ff ff    	jns    800576 <vprintfmt+0x59>
				width = precision, precision = -1;
  800606:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800609:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800613:	e9 5e ff ff ff       	jmp    800576 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800618:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061e:	e9 53 ff ff ff       	jmp    800576 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	ff 30                	pushl  (%eax)
  800632:	ff d6                	call   *%esi
			break;
  800634:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063a:	e9 04 ff ff ff       	jmp    800543 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 50 04             	lea    0x4(%eax),%edx
  800645:	89 55 14             	mov    %edx,0x14(%ebp)
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	99                   	cltd   
  80064b:	31 d0                	xor    %edx,%eax
  80064d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064f:	83 f8 08             	cmp    $0x8,%eax
  800652:	7f 0b                	jg     80065f <vprintfmt+0x142>
  800654:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  80065b:	85 d2                	test   %edx,%edx
  80065d:	75 18                	jne    800677 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 d6 0f 80 00       	push   $0x800fd6
  800665:	53                   	push   %ebx
  800666:	56                   	push   %esi
  800667:	e8 94 fe ff ff       	call   800500 <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800672:	e9 cc fe ff ff       	jmp    800543 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800677:	52                   	push   %edx
  800678:	68 df 0f 80 00       	push   $0x800fdf
  80067d:	53                   	push   %ebx
  80067e:	56                   	push   %esi
  80067f:	e8 7c fe ff ff       	call   800500 <printfmt>
  800684:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068a:	e9 b4 fe ff ff       	jmp    800543 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068f:	8b 45 14             	mov    0x14(%ebp),%eax
  800692:	8d 50 04             	lea    0x4(%eax),%edx
  800695:	89 55 14             	mov    %edx,0x14(%ebp)
  800698:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069a:	85 ff                	test   %edi,%edi
  80069c:	b8 cf 0f 80 00       	mov    $0x800fcf,%eax
  8006a1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a8:	0f 8e 94 00 00 00    	jle    800742 <vprintfmt+0x225>
  8006ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b2:	0f 84 98 00 00 00    	je     800750 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b8:	83 ec 08             	sub    $0x8,%esp
  8006bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8006be:	57                   	push   %edi
  8006bf:	e8 86 02 00 00       	call   80094a <strnlen>
  8006c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c7:	29 c1                	sub    %eax,%ecx
  8006c9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006db:	eb 0f                	jmp    8006ec <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	53                   	push   %ebx
  8006e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e6:	83 ef 01             	sub    $0x1,%edi
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	85 ff                	test   %edi,%edi
  8006ee:	7f ed                	jg     8006dd <vprintfmt+0x1c0>
  8006f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f6:	85 c9                	test   %ecx,%ecx
  8006f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fd:	0f 49 c1             	cmovns %ecx,%eax
  800700:	29 c1                	sub    %eax,%ecx
  800702:	89 75 08             	mov    %esi,0x8(%ebp)
  800705:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800708:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070b:	89 cb                	mov    %ecx,%ebx
  80070d:	eb 4d                	jmp    80075c <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80070f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800713:	74 1b                	je     800730 <vprintfmt+0x213>
  800715:	0f be c0             	movsbl %al,%eax
  800718:	83 e8 20             	sub    $0x20,%eax
  80071b:	83 f8 5e             	cmp    $0x5e,%eax
  80071e:	76 10                	jbe    800730 <vprintfmt+0x213>
					putch('?', putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	ff 75 0c             	pushl  0xc(%ebp)
  800726:	6a 3f                	push   $0x3f
  800728:	ff 55 08             	call   *0x8(%ebp)
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	eb 0d                	jmp    80073d <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	ff 75 0c             	pushl  0xc(%ebp)
  800736:	52                   	push   %edx
  800737:	ff 55 08             	call   *0x8(%ebp)
  80073a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073d:	83 eb 01             	sub    $0x1,%ebx
  800740:	eb 1a                	jmp    80075c <vprintfmt+0x23f>
  800742:	89 75 08             	mov    %esi,0x8(%ebp)
  800745:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800748:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074e:	eb 0c                	jmp    80075c <vprintfmt+0x23f>
  800750:	89 75 08             	mov    %esi,0x8(%ebp)
  800753:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800756:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800759:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80075c:	83 c7 01             	add    $0x1,%edi
  80075f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800763:	0f be d0             	movsbl %al,%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 23                	je     80078d <vprintfmt+0x270>
  80076a:	85 f6                	test   %esi,%esi
  80076c:	78 a1                	js     80070f <vprintfmt+0x1f2>
  80076e:	83 ee 01             	sub    $0x1,%esi
  800771:	79 9c                	jns    80070f <vprintfmt+0x1f2>
  800773:	89 df                	mov    %ebx,%edi
  800775:	8b 75 08             	mov    0x8(%ebp),%esi
  800778:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077b:	eb 18                	jmp    800795 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 20                	push   $0x20
  800783:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800785:	83 ef 01             	sub    $0x1,%edi
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 08                	jmp    800795 <vprintfmt+0x278>
  80078d:	89 df                	mov    %ebx,%edi
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800795:	85 ff                	test   %edi,%edi
  800797:	7f e4                	jg     80077d <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800799:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80079c:	e9 a2 fd ff ff       	jmp    800543 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a1:	83 fa 01             	cmp    $0x1,%edx
  8007a4:	7e 16                	jle    8007bc <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 08             	lea    0x8(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8007af:	8b 50 04             	mov    0x4(%eax),%edx
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ba:	eb 32                	jmp    8007ee <vprintfmt+0x2d1>
	else if (lflag)
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	74 18                	je     8007d8 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8d 50 04             	lea    0x4(%eax),%edx
  8007c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	89 c1                	mov    %eax,%ecx
  8007d0:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d6:	eb 16                	jmp    8007ee <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8d 50 04             	lea    0x4(%eax),%edx
  8007de:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e6:	89 c1                	mov    %eax,%ecx
  8007e8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f1:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f9:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007fd:	79 74                	jns    800873 <vprintfmt+0x356>
				putch('-', putdat);
  8007ff:	83 ec 08             	sub    $0x8,%esp
  800802:	53                   	push   %ebx
  800803:	6a 2d                	push   $0x2d
  800805:	ff d6                	call   *%esi
				num = -(long long) num;
  800807:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80080d:	f7 d8                	neg    %eax
  80080f:	83 d2 00             	adc    $0x0,%edx
  800812:	f7 da                	neg    %edx
  800814:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800817:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80081c:	eb 55                	jmp    800873 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081e:	8d 45 14             	lea    0x14(%ebp),%eax
  800821:	e8 83 fc ff ff       	call   8004a9 <getuint>
			base = 10;
  800826:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082b:	eb 46                	jmp    800873 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80082d:	8d 45 14             	lea    0x14(%ebp),%eax
  800830:	e8 74 fc ff ff       	call   8004a9 <getuint>
			base = 8;
  800835:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083a:	eb 37                	jmp    800873 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	53                   	push   %ebx
  800840:	6a 30                	push   $0x30
  800842:	ff d6                	call   *%esi
			putch('x', putdat);
  800844:	83 c4 08             	add    $0x8,%esp
  800847:	53                   	push   %ebx
  800848:	6a 78                	push   $0x78
  80084a:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 04             	lea    0x4(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800855:	8b 00                	mov    (%eax),%eax
  800857:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085c:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80085f:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800864:	eb 0d                	jmp    800873 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
  800869:	e8 3b fc ff ff       	call   8004a9 <getuint>
			base = 16;
  80086e:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800873:	83 ec 0c             	sub    $0xc,%esp
  800876:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087a:	57                   	push   %edi
  80087b:	ff 75 e0             	pushl  -0x20(%ebp)
  80087e:	51                   	push   %ecx
  80087f:	52                   	push   %edx
  800880:	50                   	push   %eax
  800881:	89 da                	mov    %ebx,%edx
  800883:	89 f0                	mov    %esi,%eax
  800885:	e8 70 fb ff ff       	call   8003fa <printnum>
			break;
  80088a:	83 c4 20             	add    $0x20,%esp
  80088d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800890:	e9 ae fc ff ff       	jmp    800543 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800895:	83 ec 08             	sub    $0x8,%esp
  800898:	53                   	push   %ebx
  800899:	51                   	push   %ecx
  80089a:	ff d6                	call   *%esi
			break;
  80089c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a2:	e9 9c fc ff ff       	jmp    800543 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	53                   	push   %ebx
  8008ab:	6a 25                	push   $0x25
  8008ad:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008af:	83 c4 10             	add    $0x10,%esp
  8008b2:	eb 03                	jmp    8008b7 <vprintfmt+0x39a>
  8008b4:	83 ef 01             	sub    $0x1,%edi
  8008b7:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008bb:	75 f7                	jne    8008b4 <vprintfmt+0x397>
  8008bd:	e9 81 fc ff ff       	jmp    800543 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5f                   	pop    %edi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 18             	sub    $0x18,%esp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008dd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e7:	85 c0                	test   %eax,%eax
  8008e9:	74 26                	je     800911 <vsnprintf+0x47>
  8008eb:	85 d2                	test   %edx,%edx
  8008ed:	7e 22                	jle    800911 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ef:	ff 75 14             	pushl  0x14(%ebp)
  8008f2:	ff 75 10             	pushl  0x10(%ebp)
  8008f5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f8:	50                   	push   %eax
  8008f9:	68 e3 04 80 00       	push   $0x8004e3
  8008fe:	e8 1a fc ff ff       	call   80051d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800903:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800906:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800909:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	eb 05                	jmp    800916 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800911:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800921:	50                   	push   %eax
  800922:	ff 75 10             	pushl  0x10(%ebp)
  800925:	ff 75 0c             	pushl  0xc(%ebp)
  800928:	ff 75 08             	pushl  0x8(%ebp)
  80092b:	e8 9a ff ff ff       	call   8008ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
  80093d:	eb 03                	jmp    800942 <strlen+0x10>
		n++;
  80093f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800942:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800946:	75 f7                	jne    80093f <strlen+0xd>
		n++;
	return n;
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800950:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800953:	ba 00 00 00 00       	mov    $0x0,%edx
  800958:	eb 03                	jmp    80095d <strnlen+0x13>
		n++;
  80095a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095d:	39 c2                	cmp    %eax,%edx
  80095f:	74 08                	je     800969 <strnlen+0x1f>
  800961:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800965:	75 f3                	jne    80095a <strnlen+0x10>
  800967:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800975:	89 c2                	mov    %eax,%edx
  800977:	83 c2 01             	add    $0x1,%edx
  80097a:	83 c1 01             	add    $0x1,%ecx
  80097d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800981:	88 5a ff             	mov    %bl,-0x1(%edx)
  800984:	84 db                	test   %bl,%bl
  800986:	75 ef                	jne    800977 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800992:	53                   	push   %ebx
  800993:	e8 9a ff ff ff       	call   800932 <strlen>
  800998:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80099b:	ff 75 0c             	pushl  0xc(%ebp)
  80099e:	01 d8                	add    %ebx,%eax
  8009a0:	50                   	push   %eax
  8009a1:	e8 c5 ff ff ff       	call   80096b <strcpy>
	return dst;
}
  8009a6:	89 d8                	mov    %ebx,%eax
  8009a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b8:	89 f3                	mov    %esi,%ebx
  8009ba:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bd:	89 f2                	mov    %esi,%edx
  8009bf:	eb 0f                	jmp    8009d0 <strncpy+0x23>
		*dst++ = *src;
  8009c1:	83 c2 01             	add    $0x1,%edx
  8009c4:	0f b6 01             	movzbl (%ecx),%eax
  8009c7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ca:	80 39 01             	cmpb   $0x1,(%ecx)
  8009cd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d0:	39 da                	cmp    %ebx,%edx
  8009d2:	75 ed                	jne    8009c1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d4:	89 f0                	mov    %esi,%eax
  8009d6:	5b                   	pop    %ebx
  8009d7:	5e                   	pop    %esi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e5:	8b 55 10             	mov    0x10(%ebp),%edx
  8009e8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ea:	85 d2                	test   %edx,%edx
  8009ec:	74 21                	je     800a0f <strlcpy+0x35>
  8009ee:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f2:	89 f2                	mov    %esi,%edx
  8009f4:	eb 09                	jmp    8009ff <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f6:	83 c2 01             	add    $0x1,%edx
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ff:	39 c2                	cmp    %eax,%edx
  800a01:	74 09                	je     800a0c <strlcpy+0x32>
  800a03:	0f b6 19             	movzbl (%ecx),%ebx
  800a06:	84 db                	test   %bl,%bl
  800a08:	75 ec                	jne    8009f6 <strlcpy+0x1c>
  800a0a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a0c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a0f:	29 f0                	sub    %esi,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1e:	eb 06                	jmp    800a26 <strcmp+0x11>
		p++, q++;
  800a20:	83 c1 01             	add    $0x1,%ecx
  800a23:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a26:	0f b6 01             	movzbl (%ecx),%eax
  800a29:	84 c0                	test   %al,%al
  800a2b:	74 04                	je     800a31 <strcmp+0x1c>
  800a2d:	3a 02                	cmp    (%edx),%al
  800a2f:	74 ef                	je     800a20 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a31:	0f b6 c0             	movzbl %al,%eax
  800a34:	0f b6 12             	movzbl (%edx),%edx
  800a37:	29 d0                	sub    %edx,%eax
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4a:	eb 06                	jmp    800a52 <strncmp+0x17>
		n--, p++, q++;
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a52:	39 d8                	cmp    %ebx,%eax
  800a54:	74 15                	je     800a6b <strncmp+0x30>
  800a56:	0f b6 08             	movzbl (%eax),%ecx
  800a59:	84 c9                	test   %cl,%cl
  800a5b:	74 04                	je     800a61 <strncmp+0x26>
  800a5d:	3a 0a                	cmp    (%edx),%cl
  800a5f:	74 eb                	je     800a4c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a61:	0f b6 00             	movzbl (%eax),%eax
  800a64:	0f b6 12             	movzbl (%edx),%edx
  800a67:	29 d0                	sub    %edx,%eax
  800a69:	eb 05                	jmp    800a70 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a70:	5b                   	pop    %ebx
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7d:	eb 07                	jmp    800a86 <strchr+0x13>
		if (*s == c)
  800a7f:	38 ca                	cmp    %cl,%dl
  800a81:	74 0f                	je     800a92 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	0f b6 10             	movzbl (%eax),%edx
  800a89:	84 d2                	test   %dl,%dl
  800a8b:	75 f2                	jne    800a7f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9e:	eb 03                	jmp    800aa3 <strfind+0xf>
  800aa0:	83 c0 01             	add    $0x1,%eax
  800aa3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aa6:	38 ca                	cmp    %cl,%dl
  800aa8:	74 04                	je     800aae <strfind+0x1a>
  800aaa:	84 d2                	test   %dl,%dl
  800aac:	75 f2                	jne    800aa0 <strfind+0xc>
			break;
	return (char *) s;
}
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	57                   	push   %edi
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800abc:	85 c9                	test   %ecx,%ecx
  800abe:	74 36                	je     800af6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac0:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac6:	75 28                	jne    800af0 <memset+0x40>
  800ac8:	f6 c1 03             	test   $0x3,%cl
  800acb:	75 23                	jne    800af0 <memset+0x40>
		c &= 0xFF;
  800acd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad1:	89 d3                	mov    %edx,%ebx
  800ad3:	c1 e3 08             	shl    $0x8,%ebx
  800ad6:	89 d6                	mov    %edx,%esi
  800ad8:	c1 e6 18             	shl    $0x18,%esi
  800adb:	89 d0                	mov    %edx,%eax
  800add:	c1 e0 10             	shl    $0x10,%eax
  800ae0:	09 f0                	or     %esi,%eax
  800ae2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae4:	89 d8                	mov    %ebx,%eax
  800ae6:	09 d0                	or     %edx,%eax
  800ae8:	c1 e9 02             	shr    $0x2,%ecx
  800aeb:	fc                   	cld    
  800aec:	f3 ab                	rep stos %eax,%es:(%edi)
  800aee:	eb 06                	jmp    800af6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af3:	fc                   	cld    
  800af4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af6:	89 f8                	mov    %edi,%eax
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b0b:	39 c6                	cmp    %eax,%esi
  800b0d:	73 35                	jae    800b44 <memmove+0x47>
  800b0f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b12:	39 d0                	cmp    %edx,%eax
  800b14:	73 2e                	jae    800b44 <memmove+0x47>
		s += n;
		d += n;
  800b16:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	09 fe                	or     %edi,%esi
  800b1d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b23:	75 13                	jne    800b38 <memmove+0x3b>
  800b25:	f6 c1 03             	test   $0x3,%cl
  800b28:	75 0e                	jne    800b38 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b2a:	83 ef 04             	sub    $0x4,%edi
  800b2d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b30:	c1 e9 02             	shr    $0x2,%ecx
  800b33:	fd                   	std    
  800b34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b36:	eb 09                	jmp    800b41 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b38:	83 ef 01             	sub    $0x1,%edi
  800b3b:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b3e:	fd                   	std    
  800b3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b41:	fc                   	cld    
  800b42:	eb 1d                	jmp    800b61 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b44:	89 f2                	mov    %esi,%edx
  800b46:	09 c2                	or     %eax,%edx
  800b48:	f6 c2 03             	test   $0x3,%dl
  800b4b:	75 0f                	jne    800b5c <memmove+0x5f>
  800b4d:	f6 c1 03             	test   $0x3,%cl
  800b50:	75 0a                	jne    800b5c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b52:	c1 e9 02             	shr    $0x2,%ecx
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	fc                   	cld    
  800b58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5a:	eb 05                	jmp    800b61 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b5c:	89 c7                	mov    %eax,%edi
  800b5e:	fc                   	cld    
  800b5f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b68:	ff 75 10             	pushl  0x10(%ebp)
  800b6b:	ff 75 0c             	pushl  0xc(%ebp)
  800b6e:	ff 75 08             	pushl  0x8(%ebp)
  800b71:	e8 87 ff ff ff       	call   800afd <memmove>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b83:	89 c6                	mov    %eax,%esi
  800b85:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b88:	eb 1a                	jmp    800ba4 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8a:	0f b6 08             	movzbl (%eax),%ecx
  800b8d:	0f b6 1a             	movzbl (%edx),%ebx
  800b90:	38 d9                	cmp    %bl,%cl
  800b92:	74 0a                	je     800b9e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b94:	0f b6 c1             	movzbl %cl,%eax
  800b97:	0f b6 db             	movzbl %bl,%ebx
  800b9a:	29 d8                	sub    %ebx,%eax
  800b9c:	eb 0f                	jmp    800bad <memcmp+0x35>
		s1++, s2++;
  800b9e:	83 c0 01             	add    $0x1,%eax
  800ba1:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba4:	39 f0                	cmp    %esi,%eax
  800ba6:	75 e2                	jne    800b8a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	53                   	push   %ebx
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bb8:	89 c1                	mov    %eax,%ecx
  800bba:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bbd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc1:	eb 0a                	jmp    800bcd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc3:	0f b6 10             	movzbl (%eax),%edx
  800bc6:	39 da                	cmp    %ebx,%edx
  800bc8:	74 07                	je     800bd1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bca:	83 c0 01             	add    $0x1,%eax
  800bcd:	39 c8                	cmp    %ecx,%eax
  800bcf:	72 f2                	jb     800bc3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be0:	eb 03                	jmp    800be5 <strtol+0x11>
		s++;
  800be2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be5:	0f b6 01             	movzbl (%ecx),%eax
  800be8:	3c 20                	cmp    $0x20,%al
  800bea:	74 f6                	je     800be2 <strtol+0xe>
  800bec:	3c 09                	cmp    $0x9,%al
  800bee:	74 f2                	je     800be2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf0:	3c 2b                	cmp    $0x2b,%al
  800bf2:	75 0a                	jne    800bfe <strtol+0x2a>
		s++;
  800bf4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bfc:	eb 11                	jmp    800c0f <strtol+0x3b>
  800bfe:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c03:	3c 2d                	cmp    $0x2d,%al
  800c05:	75 08                	jne    800c0f <strtol+0x3b>
		s++, neg = 1;
  800c07:	83 c1 01             	add    $0x1,%ecx
  800c0a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c15:	75 15                	jne    800c2c <strtol+0x58>
  800c17:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1a:	75 10                	jne    800c2c <strtol+0x58>
  800c1c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c20:	75 7c                	jne    800c9e <strtol+0xca>
		s += 2, base = 16;
  800c22:	83 c1 02             	add    $0x2,%ecx
  800c25:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2a:	eb 16                	jmp    800c42 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c2c:	85 db                	test   %ebx,%ebx
  800c2e:	75 12                	jne    800c42 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c30:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c35:	80 39 30             	cmpb   $0x30,(%ecx)
  800c38:	75 08                	jne    800c42 <strtol+0x6e>
		s++, base = 8;
  800c3a:	83 c1 01             	add    $0x1,%ecx
  800c3d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
  800c47:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4a:	0f b6 11             	movzbl (%ecx),%edx
  800c4d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c50:	89 f3                	mov    %esi,%ebx
  800c52:	80 fb 09             	cmp    $0x9,%bl
  800c55:	77 08                	ja     800c5f <strtol+0x8b>
			dig = *s - '0';
  800c57:	0f be d2             	movsbl %dl,%edx
  800c5a:	83 ea 30             	sub    $0x30,%edx
  800c5d:	eb 22                	jmp    800c81 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c5f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c62:	89 f3                	mov    %esi,%ebx
  800c64:	80 fb 19             	cmp    $0x19,%bl
  800c67:	77 08                	ja     800c71 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c69:	0f be d2             	movsbl %dl,%edx
  800c6c:	83 ea 57             	sub    $0x57,%edx
  800c6f:	eb 10                	jmp    800c81 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c71:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c74:	89 f3                	mov    %esi,%ebx
  800c76:	80 fb 19             	cmp    $0x19,%bl
  800c79:	77 16                	ja     800c91 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c7b:	0f be d2             	movsbl %dl,%edx
  800c7e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c81:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c84:	7d 0b                	jge    800c91 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c86:	83 c1 01             	add    $0x1,%ecx
  800c89:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c8d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c8f:	eb b9                	jmp    800c4a <strtol+0x76>

	if (endptr)
  800c91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c95:	74 0d                	je     800ca4 <strtol+0xd0>
		*endptr = (char *) s;
  800c97:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9a:	89 0e                	mov    %ecx,(%esi)
  800c9c:	eb 06                	jmp    800ca4 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9e:	85 db                	test   %ebx,%ebx
  800ca0:	74 98                	je     800c3a <strtol+0x66>
  800ca2:	eb 9e                	jmp    800c42 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca4:	89 c2                	mov    %eax,%edx
  800ca6:	f7 da                	neg    %edx
  800ca8:	85 ff                	test   %edi,%edi
  800caa:	0f 45 c2             	cmovne %edx,%eax
}
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
  800cb2:	66 90                	xchg   %ax,%ax
  800cb4:	66 90                	xchg   %ax,%ax
  800cb6:	66 90                	xchg   %ax,%ax
  800cb8:	66 90                	xchg   %ax,%ax
  800cba:	66 90                	xchg   %ax,%ax
  800cbc:	66 90                	xchg   %ax,%ax
  800cbe:	66 90                	xchg   %ax,%ax

00800cc0 <__udivdi3>:
  800cc0:	55                   	push   %ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 1c             	sub    $0x1c,%esp
  800cc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ccb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ccf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800cd7:	85 f6                	test   %esi,%esi
  800cd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cdd:	89 ca                	mov    %ecx,%edx
  800cdf:	89 f8                	mov    %edi,%eax
  800ce1:	75 3d                	jne    800d20 <__udivdi3+0x60>
  800ce3:	39 cf                	cmp    %ecx,%edi
  800ce5:	0f 87 c5 00 00 00    	ja     800db0 <__udivdi3+0xf0>
  800ceb:	85 ff                	test   %edi,%edi
  800ced:	89 fd                	mov    %edi,%ebp
  800cef:	75 0b                	jne    800cfc <__udivdi3+0x3c>
  800cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf6:	31 d2                	xor    %edx,%edx
  800cf8:	f7 f7                	div    %edi
  800cfa:	89 c5                	mov    %eax,%ebp
  800cfc:	89 c8                	mov    %ecx,%eax
  800cfe:	31 d2                	xor    %edx,%edx
  800d00:	f7 f5                	div    %ebp
  800d02:	89 c1                	mov    %eax,%ecx
  800d04:	89 d8                	mov    %ebx,%eax
  800d06:	89 cf                	mov    %ecx,%edi
  800d08:	f7 f5                	div    %ebp
  800d0a:	89 c3                	mov    %eax,%ebx
  800d0c:	89 d8                	mov    %ebx,%eax
  800d0e:	89 fa                	mov    %edi,%edx
  800d10:	83 c4 1c             	add    $0x1c,%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    
  800d18:	90                   	nop
  800d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d20:	39 ce                	cmp    %ecx,%esi
  800d22:	77 74                	ja     800d98 <__udivdi3+0xd8>
  800d24:	0f bd fe             	bsr    %esi,%edi
  800d27:	83 f7 1f             	xor    $0x1f,%edi
  800d2a:	0f 84 98 00 00 00    	je     800dc8 <__udivdi3+0x108>
  800d30:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d35:	89 f9                	mov    %edi,%ecx
  800d37:	89 c5                	mov    %eax,%ebp
  800d39:	29 fb                	sub    %edi,%ebx
  800d3b:	d3 e6                	shl    %cl,%esi
  800d3d:	89 d9                	mov    %ebx,%ecx
  800d3f:	d3 ed                	shr    %cl,%ebp
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	d3 e0                	shl    %cl,%eax
  800d45:	09 ee                	or     %ebp,%esi
  800d47:	89 d9                	mov    %ebx,%ecx
  800d49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d4d:	89 d5                	mov    %edx,%ebp
  800d4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d53:	d3 ed                	shr    %cl,%ebp
  800d55:	89 f9                	mov    %edi,%ecx
  800d57:	d3 e2                	shl    %cl,%edx
  800d59:	89 d9                	mov    %ebx,%ecx
  800d5b:	d3 e8                	shr    %cl,%eax
  800d5d:	09 c2                	or     %eax,%edx
  800d5f:	89 d0                	mov    %edx,%eax
  800d61:	89 ea                	mov    %ebp,%edx
  800d63:	f7 f6                	div    %esi
  800d65:	89 d5                	mov    %edx,%ebp
  800d67:	89 c3                	mov    %eax,%ebx
  800d69:	f7 64 24 0c          	mull   0xc(%esp)
  800d6d:	39 d5                	cmp    %edx,%ebp
  800d6f:	72 10                	jb     800d81 <__udivdi3+0xc1>
  800d71:	8b 74 24 08          	mov    0x8(%esp),%esi
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	d3 e6                	shl    %cl,%esi
  800d79:	39 c6                	cmp    %eax,%esi
  800d7b:	73 07                	jae    800d84 <__udivdi3+0xc4>
  800d7d:	39 d5                	cmp    %edx,%ebp
  800d7f:	75 03                	jne    800d84 <__udivdi3+0xc4>
  800d81:	83 eb 01             	sub    $0x1,%ebx
  800d84:	31 ff                	xor    %edi,%edi
  800d86:	89 d8                	mov    %ebx,%eax
  800d88:	89 fa                	mov    %edi,%edx
  800d8a:	83 c4 1c             	add    $0x1c,%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
  800d92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d98:	31 ff                	xor    %edi,%edi
  800d9a:	31 db                	xor    %ebx,%ebx
  800d9c:	89 d8                	mov    %ebx,%eax
  800d9e:	89 fa                	mov    %edi,%edx
  800da0:	83 c4 1c             	add    $0x1c,%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    
  800da8:	90                   	nop
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	f7 f7                	div    %edi
  800db4:	31 ff                	xor    %edi,%edi
  800db6:	89 c3                	mov    %eax,%ebx
  800db8:	89 d8                	mov    %ebx,%eax
  800dba:	89 fa                	mov    %edi,%edx
  800dbc:	83 c4 1c             	add    $0x1c,%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
  800dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc8:	39 ce                	cmp    %ecx,%esi
  800dca:	72 0c                	jb     800dd8 <__udivdi3+0x118>
  800dcc:	31 db                	xor    %ebx,%ebx
  800dce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800dd2:	0f 87 34 ff ff ff    	ja     800d0c <__udivdi3+0x4c>
  800dd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ddd:	e9 2a ff ff ff       	jmp    800d0c <__udivdi3+0x4c>
  800de2:	66 90                	xchg   %ax,%ax
  800de4:	66 90                	xchg   %ax,%ax
  800de6:	66 90                	xchg   %ax,%ax
  800de8:	66 90                	xchg   %ax,%ax
  800dea:	66 90                	xchg   %ax,%ax
  800dec:	66 90                	xchg   %ax,%ax
  800dee:	66 90                	xchg   %ax,%ax

00800df0 <__umoddi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e07:	85 d2                	test   %edx,%edx
  800e09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e11:	89 f3                	mov    %esi,%ebx
  800e13:	89 3c 24             	mov    %edi,(%esp)
  800e16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1a:	75 1c                	jne    800e38 <__umoddi3+0x48>
  800e1c:	39 f7                	cmp    %esi,%edi
  800e1e:	76 50                	jbe    800e70 <__umoddi3+0x80>
  800e20:	89 c8                	mov    %ecx,%eax
  800e22:	89 f2                	mov    %esi,%edx
  800e24:	f7 f7                	div    %edi
  800e26:	89 d0                	mov    %edx,%eax
  800e28:	31 d2                	xor    %edx,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	89 d0                	mov    %edx,%eax
  800e3c:	77 52                	ja     800e90 <__umoddi3+0xa0>
  800e3e:	0f bd ea             	bsr    %edx,%ebp
  800e41:	83 f5 1f             	xor    $0x1f,%ebp
  800e44:	75 5a                	jne    800ea0 <__umoddi3+0xb0>
  800e46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e4a:	0f 82 e0 00 00 00    	jb     800f30 <__umoddi3+0x140>
  800e50:	39 0c 24             	cmp    %ecx,(%esp)
  800e53:	0f 86 d7 00 00 00    	jbe    800f30 <__umoddi3+0x140>
  800e59:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	85 ff                	test   %edi,%edi
  800e72:	89 fd                	mov    %edi,%ebp
  800e74:	75 0b                	jne    800e81 <__umoddi3+0x91>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f7                	div    %edi
  800e7f:	89 c5                	mov    %eax,%ebp
  800e81:	89 f0                	mov    %esi,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f5                	div    %ebp
  800e87:	89 c8                	mov    %ecx,%eax
  800e89:	f7 f5                	div    %ebp
  800e8b:	89 d0                	mov    %edx,%eax
  800e8d:	eb 99                	jmp    800e28 <__umoddi3+0x38>
  800e8f:	90                   	nop
  800e90:	89 c8                	mov    %ecx,%eax
  800e92:	89 f2                	mov    %esi,%edx
  800e94:	83 c4 1c             	add    $0x1c,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	8b 34 24             	mov    (%esp),%esi
  800ea3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ea8:	89 e9                	mov    %ebp,%ecx
  800eaa:	29 ef                	sub    %ebp,%edi
  800eac:	d3 e0                	shl    %cl,%eax
  800eae:	89 f9                	mov    %edi,%ecx
  800eb0:	89 f2                	mov    %esi,%edx
  800eb2:	d3 ea                	shr    %cl,%edx
  800eb4:	89 e9                	mov    %ebp,%ecx
  800eb6:	09 c2                	or     %eax,%edx
  800eb8:	89 d8                	mov    %ebx,%eax
  800eba:	89 14 24             	mov    %edx,(%esp)
  800ebd:	89 f2                	mov    %esi,%edx
  800ebf:	d3 e2                	shl    %cl,%edx
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ecb:	d3 e8                	shr    %cl,%eax
  800ecd:	89 e9                	mov    %ebp,%ecx
  800ecf:	89 c6                	mov    %eax,%esi
  800ed1:	d3 e3                	shl    %cl,%ebx
  800ed3:	89 f9                	mov    %edi,%ecx
  800ed5:	89 d0                	mov    %edx,%eax
  800ed7:	d3 e8                	shr    %cl,%eax
  800ed9:	89 e9                	mov    %ebp,%ecx
  800edb:	09 d8                	or     %ebx,%eax
  800edd:	89 d3                	mov    %edx,%ebx
  800edf:	89 f2                	mov    %esi,%edx
  800ee1:	f7 34 24             	divl   (%esp)
  800ee4:	89 d6                	mov    %edx,%esi
  800ee6:	d3 e3                	shl    %cl,%ebx
  800ee8:	f7 64 24 04          	mull   0x4(%esp)
  800eec:	39 d6                	cmp    %edx,%esi
  800eee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ef2:	89 d1                	mov    %edx,%ecx
  800ef4:	89 c3                	mov    %eax,%ebx
  800ef6:	72 08                	jb     800f00 <__umoddi3+0x110>
  800ef8:	75 11                	jne    800f0b <__umoddi3+0x11b>
  800efa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800efe:	73 0b                	jae    800f0b <__umoddi3+0x11b>
  800f00:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f04:	1b 14 24             	sbb    (%esp),%edx
  800f07:	89 d1                	mov    %edx,%ecx
  800f09:	89 c3                	mov    %eax,%ebx
  800f0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f0f:	29 da                	sub    %ebx,%edx
  800f11:	19 ce                	sbb    %ecx,%esi
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	89 f0                	mov    %esi,%eax
  800f17:	d3 e0                	shl    %cl,%eax
  800f19:	89 e9                	mov    %ebp,%ecx
  800f1b:	d3 ea                	shr    %cl,%edx
  800f1d:	89 e9                	mov    %ebp,%ecx
  800f1f:	d3 ee                	shr    %cl,%esi
  800f21:	09 d0                	or     %edx,%eax
  800f23:	89 f2                	mov    %esi,%edx
  800f25:	83 c4 1c             	add    $0x1c,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	29 f9                	sub    %edi,%ecx
  800f32:	19 d6                	sbb    %edx,%esi
  800f34:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f3c:	e9 18 ff ff ff       	jmp    800e59 <__umoddi3+0x69>
