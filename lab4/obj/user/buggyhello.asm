
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 c6 00 00 00       	call   80011d <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7e 17                	jle    800115 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fe:	83 ec 0c             	sub    $0xc,%esp
  800101:	50                   	push   %eax
  800102:	6a 03                	push   $0x3
  800104:	68 4a 0f 80 00       	push   $0x800f4a
  800109:	6a 23                	push   $0x23
  80010b:	68 67 0f 80 00       	push   $0x800f67
  800110:	e8 f5 01 00 00       	call   80030a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800115:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_yield>:

void
sys_yield(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	be 00 00 00 00       	mov    $0x0,%esi
  800169:	b8 04 00 00 00       	mov    $0x4,%eax
  80016e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800177:	89 f7                	mov    %esi,%edi
  800179:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017b:	85 c0                	test   %eax,%eax
  80017d:	7e 17                	jle    800196 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	50                   	push   %eax
  800183:	6a 04                	push   $0x4
  800185:	68 4a 0f 80 00       	push   $0x800f4a
  80018a:	6a 23                	push   $0x23
  80018c:	68 67 0f 80 00       	push   $0x800f67
  800191:	e8 74 01 00 00       	call   80030a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001af:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7e 17                	jle    8001d8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c1:	83 ec 0c             	sub    $0xc,%esp
  8001c4:	50                   	push   %eax
  8001c5:	6a 05                	push   $0x5
  8001c7:	68 4a 0f 80 00       	push   $0x800f4a
  8001cc:	6a 23                	push   $0x23
  8001ce:	68 67 0f 80 00       	push   $0x800f67
  8001d3:	e8 32 01 00 00       	call   80030a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7e 17                	jle    80021a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	50                   	push   %eax
  800207:	6a 06                	push   $0x6
  800209:	68 4a 0f 80 00       	push   $0x800f4a
  80020e:	6a 23                	push   $0x23
  800210:	68 67 0f 80 00       	push   $0x800f67
  800215:	e8 f0 00 00 00       	call   80030a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    

00800222 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	b8 08 00 00 00       	mov    $0x8,%eax
  800235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800238:	8b 55 08             	mov    0x8(%ebp),%edx
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7e 17                	jle    80025c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	50                   	push   %eax
  800249:	6a 08                	push   $0x8
  80024b:	68 4a 0f 80 00       	push   $0x800f4a
  800250:	6a 23                	push   $0x23
  800252:	68 67 0f 80 00       	push   $0x800f67
  800257:	e8 ae 00 00 00       	call   80030a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025f:	5b                   	pop    %ebx
  800260:	5e                   	pop    %esi
  800261:	5f                   	pop    %edi
  800262:	5d                   	pop    %ebp
  800263:	c3                   	ret    

00800264 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	b8 09 00 00 00       	mov    $0x9,%eax
  800277:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027a:	8b 55 08             	mov    0x8(%ebp),%edx
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7e 17                	jle    80029e <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	50                   	push   %eax
  80028b:	6a 09                	push   $0x9
  80028d:	68 4a 0f 80 00       	push   $0x800f4a
  800292:	6a 23                	push   $0x23
  800294:	68 67 0f 80 00       	push   $0x800f67
  800299:	e8 6c 00 00 00       	call   80030a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ac:	be 00 00 00 00       	mov    $0x0,%esi
  8002b1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 cb                	mov    %ecx,%ebx
  8002e1:	89 cf                	mov    %ecx,%edi
  8002e3:	89 ce                	mov    %ecx,%esi
  8002e5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7e 17                	jle    800302 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002eb:	83 ec 0c             	sub    $0xc,%esp
  8002ee:	50                   	push   %eax
  8002ef:	6a 0c                	push   $0xc
  8002f1:	68 4a 0f 80 00       	push   $0x800f4a
  8002f6:	6a 23                	push   $0x23
  8002f8:	68 67 0f 80 00       	push   $0x800f67
  8002fd:	e8 08 00 00 00       	call   80030a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800312:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800318:	e8 00 fe ff ff       	call   80011d <sys_getenvid>
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	56                   	push   %esi
  800327:	50                   	push   %eax
  800328:	68 78 0f 80 00       	push   $0x800f78
  80032d:	e8 b1 00 00 00       	call   8003e3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800332:	83 c4 18             	add    $0x18,%esp
  800335:	53                   	push   %ebx
  800336:	ff 75 10             	pushl  0x10(%ebp)
  800339:	e8 54 00 00 00       	call   800392 <vcprintf>
	cprintf("\n");
  80033e:	c7 04 24 9c 0f 80 00 	movl   $0x800f9c,(%esp)
  800345:	e8 99 00 00 00       	call   8003e3 <cprintf>
  80034a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034d:	cc                   	int3   
  80034e:	eb fd                	jmp    80034d <_panic+0x43>

00800350 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035a:	8b 13                	mov    (%ebx),%edx
  80035c:	8d 42 01             	lea    0x1(%edx),%eax
  80035f:	89 03                	mov    %eax,(%ebx)
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800368:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036d:	75 1a                	jne    800389 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	68 ff 00 00 00       	push   $0xff
  800377:	8d 43 08             	lea    0x8(%ebx),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 1f fd ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  800380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800386:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800389:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80038d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a2:	00 00 00 
	b.cnt = 0;
  8003a5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ac:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003af:	ff 75 0c             	pushl  0xc(%ebp)
  8003b2:	ff 75 08             	pushl  0x8(%ebp)
  8003b5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003bb:	50                   	push   %eax
  8003bc:	68 50 03 80 00       	push   $0x800350
  8003c1:	e8 54 01 00 00       	call   80051a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c6:	83 c4 08             	add    $0x8,%esp
  8003c9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003cf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d5:	50                   	push   %eax
  8003d6:	e8 c4 fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  8003db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ec:	50                   	push   %eax
  8003ed:	ff 75 08             	pushl  0x8(%ebp)
  8003f0:	e8 9d ff ff ff       	call   800392 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f5:	c9                   	leave  
  8003f6:	c3                   	ret    

008003f7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	57                   	push   %edi
  8003fb:	56                   	push   %esi
  8003fc:	53                   	push   %ebx
  8003fd:	83 ec 1c             	sub    $0x1c,%esp
  800400:	89 c7                	mov    %eax,%edi
  800402:	89 d6                	mov    %edx,%esi
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800410:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800413:	bb 00 00 00 00       	mov    $0x0,%ebx
  800418:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80041b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80041e:	39 d3                	cmp    %edx,%ebx
  800420:	72 05                	jb     800427 <printnum+0x30>
  800422:	39 45 10             	cmp    %eax,0x10(%ebp)
  800425:	77 45                	ja     80046c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800427:	83 ec 0c             	sub    $0xc,%esp
  80042a:	ff 75 18             	pushl  0x18(%ebp)
  80042d:	8b 45 14             	mov    0x14(%ebp),%eax
  800430:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800433:	53                   	push   %ebx
  800434:	ff 75 10             	pushl  0x10(%ebp)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043d:	ff 75 e0             	pushl  -0x20(%ebp)
  800440:	ff 75 dc             	pushl  -0x24(%ebp)
  800443:	ff 75 d8             	pushl  -0x28(%ebp)
  800446:	e8 65 08 00 00       	call   800cb0 <__udivdi3>
  80044b:	83 c4 18             	add    $0x18,%esp
  80044e:	52                   	push   %edx
  80044f:	50                   	push   %eax
  800450:	89 f2                	mov    %esi,%edx
  800452:	89 f8                	mov    %edi,%eax
  800454:	e8 9e ff ff ff       	call   8003f7 <printnum>
  800459:	83 c4 20             	add    $0x20,%esp
  80045c:	eb 18                	jmp    800476 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045e:	83 ec 08             	sub    $0x8,%esp
  800461:	56                   	push   %esi
  800462:	ff 75 18             	pushl  0x18(%ebp)
  800465:	ff d7                	call   *%edi
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	eb 03                	jmp    80046f <printnum+0x78>
  80046c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80046f:	83 eb 01             	sub    $0x1,%ebx
  800472:	85 db                	test   %ebx,%ebx
  800474:	7f e8                	jg     80045e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	56                   	push   %esi
  80047a:	83 ec 04             	sub    $0x4,%esp
  80047d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 75 dc             	pushl  -0x24(%ebp)
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	e8 52 09 00 00       	call   800de0 <__umoddi3>
  80048e:	83 c4 14             	add    $0x14,%esp
  800491:	0f be 80 9e 0f 80 00 	movsbl 0x800f9e(%eax),%eax
  800498:	50                   	push   %eax
  800499:	ff d7                	call   *%edi
}
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a1:	5b                   	pop    %ebx
  8004a2:	5e                   	pop    %esi
  8004a3:	5f                   	pop    %edi
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    

008004a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a6:	55                   	push   %ebp
  8004a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a9:	83 fa 01             	cmp    $0x1,%edx
  8004ac:	7e 0e                	jle    8004bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ae:	8b 10                	mov    (%eax),%edx
  8004b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 02                	mov    (%edx),%eax
  8004b7:	8b 52 04             	mov    0x4(%edx),%edx
  8004ba:	eb 22                	jmp    8004de <getuint+0x38>
	else if (lflag)
  8004bc:	85 d2                	test   %edx,%edx
  8004be:	74 10                	je     8004d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ce:	eb 0e                	jmp    8004de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d0:	8b 10                	mov    (%eax),%edx
  8004d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 02                	mov    (%edx),%eax
  8004d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ef:	73 0a                	jae    8004fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	88 02                	mov    %al,(%edx)
}
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800503:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800506:	50                   	push   %eax
  800507:	ff 75 10             	pushl  0x10(%ebp)
  80050a:	ff 75 0c             	pushl  0xc(%ebp)
  80050d:	ff 75 08             	pushl  0x8(%ebp)
  800510:	e8 05 00 00 00       	call   80051a <vprintfmt>
	va_end(ap);
}
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	57                   	push   %edi
  80051e:	56                   	push   %esi
  80051f:	53                   	push   %ebx
  800520:	83 ec 2c             	sub    $0x2c,%esp
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052c:	eb 12                	jmp    800540 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052e:	85 c0                	test   %eax,%eax
  800530:	0f 84 89 03 00 00    	je     8008bf <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	53                   	push   %ebx
  80053a:	50                   	push   %eax
  80053b:	ff d6                	call   *%esi
  80053d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800540:	83 c7 01             	add    $0x1,%edi
  800543:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800547:	83 f8 25             	cmp    $0x25,%eax
  80054a:	75 e2                	jne    80052e <vprintfmt+0x14>
  80054c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800550:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800557:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80055e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800565:	ba 00 00 00 00       	mov    $0x0,%edx
  80056a:	eb 07                	jmp    800573 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8d 47 01             	lea    0x1(%edi),%eax
  800576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800579:	0f b6 07             	movzbl (%edi),%eax
  80057c:	0f b6 c8             	movzbl %al,%ecx
  80057f:	83 e8 23             	sub    $0x23,%eax
  800582:	3c 55                	cmp    $0x55,%al
  800584:	0f 87 1a 03 00 00    	ja     8008a4 <vprintfmt+0x38a>
  80058a:	0f b6 c0             	movzbl %al,%eax
  80058d:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800597:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059b:	eb d6                	jmp    800573 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ab:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005af:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005b5:	83 fa 09             	cmp    $0x9,%edx
  8005b8:	77 39                	ja     8005f3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005bd:	eb e9                	jmp    8005a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 48 04             	lea    0x4(%eax),%ecx
  8005c5:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005c8:	8b 00                	mov    (%eax),%eax
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d0:	eb 27                	jmp    8005f9 <vprintfmt+0xdf>
  8005d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dc:	0f 49 c8             	cmovns %eax,%ecx
  8005df:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e5:	eb 8c                	jmp    800573 <vprintfmt+0x59>
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f1:	eb 80                	jmp    800573 <vprintfmt+0x59>
  8005f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fd:	0f 89 70 ff ff ff    	jns    800573 <vprintfmt+0x59>
				width = precision, precision = -1;
  800603:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800606:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800609:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800610:	e9 5e ff ff ff       	jmp    800573 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800615:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800618:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80061b:	e9 53 ff ff ff       	jmp    800573 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 50 04             	lea    0x4(%eax),%edx
  800626:	89 55 14             	mov    %edx,0x14(%ebp)
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	ff 30                	pushl  (%eax)
  80062f:	ff d6                	call   *%esi
			break;
  800631:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800637:	e9 04 ff ff ff       	jmp    800540 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	99                   	cltd   
  800648:	31 d0                	xor    %edx,%eax
  80064a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064c:	83 f8 08             	cmp    $0x8,%eax
  80064f:	7f 0b                	jg     80065c <vprintfmt+0x142>
  800651:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  800658:	85 d2                	test   %edx,%edx
  80065a:	75 18                	jne    800674 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  80065c:	50                   	push   %eax
  80065d:	68 b6 0f 80 00       	push   $0x800fb6
  800662:	53                   	push   %ebx
  800663:	56                   	push   %esi
  800664:	e8 94 fe ff ff       	call   8004fd <printfmt>
  800669:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80066f:	e9 cc fe ff ff       	jmp    800540 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800674:	52                   	push   %edx
  800675:	68 bf 0f 80 00       	push   $0x800fbf
  80067a:	53                   	push   %ebx
  80067b:	56                   	push   %esi
  80067c:	e8 7c fe ff ff       	call   8004fd <printfmt>
  800681:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800684:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800687:	e9 b4 fe ff ff       	jmp    800540 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800697:	85 ff                	test   %edi,%edi
  800699:	b8 af 0f 80 00       	mov    $0x800faf,%eax
  80069e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a5:	0f 8e 94 00 00 00    	jle    80073f <vprintfmt+0x225>
  8006ab:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006af:	0f 84 98 00 00 00    	je     80074d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	ff 75 d0             	pushl  -0x30(%ebp)
  8006bb:	57                   	push   %edi
  8006bc:	e8 86 02 00 00       	call   800947 <strnlen>
  8006c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c4:	29 c1                	sub    %eax,%ecx
  8006c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006cc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006d3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d8:	eb 0f                	jmp    8006e9 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	83 ef 01             	sub    $0x1,%edi
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 ff                	test   %edi,%edi
  8006eb:	7f ed                	jg     8006da <vprintfmt+0x1c0>
  8006ed:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006f3:	85 c9                	test   %ecx,%ecx
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	0f 49 c1             	cmovns %ecx,%eax
  8006fd:	29 c1                	sub    %eax,%ecx
  8006ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800702:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800705:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800708:	89 cb                	mov    %ecx,%ebx
  80070a:	eb 4d                	jmp    800759 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80070c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800710:	74 1b                	je     80072d <vprintfmt+0x213>
  800712:	0f be c0             	movsbl %al,%eax
  800715:	83 e8 20             	sub    $0x20,%eax
  800718:	83 f8 5e             	cmp    $0x5e,%eax
  80071b:	76 10                	jbe    80072d <vprintfmt+0x213>
					putch('?', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	ff 75 0c             	pushl  0xc(%ebp)
  800723:	6a 3f                	push   $0x3f
  800725:	ff 55 08             	call   *0x8(%ebp)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	eb 0d                	jmp    80073a <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	52                   	push   %edx
  800734:	ff 55 08             	call   *0x8(%ebp)
  800737:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80073a:	83 eb 01             	sub    $0x1,%ebx
  80073d:	eb 1a                	jmp    800759 <vprintfmt+0x23f>
  80073f:	89 75 08             	mov    %esi,0x8(%ebp)
  800742:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800745:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800748:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80074b:	eb 0c                	jmp    800759 <vprintfmt+0x23f>
  80074d:	89 75 08             	mov    %esi,0x8(%ebp)
  800750:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800753:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800756:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800759:	83 c7 01             	add    $0x1,%edi
  80075c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800760:	0f be d0             	movsbl %al,%edx
  800763:	85 d2                	test   %edx,%edx
  800765:	74 23                	je     80078a <vprintfmt+0x270>
  800767:	85 f6                	test   %esi,%esi
  800769:	78 a1                	js     80070c <vprintfmt+0x1f2>
  80076b:	83 ee 01             	sub    $0x1,%esi
  80076e:	79 9c                	jns    80070c <vprintfmt+0x1f2>
  800770:	89 df                	mov    %ebx,%edi
  800772:	8b 75 08             	mov    0x8(%ebp),%esi
  800775:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800778:	eb 18                	jmp    800792 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	53                   	push   %ebx
  80077e:	6a 20                	push   $0x20
  800780:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800782:	83 ef 01             	sub    $0x1,%edi
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	eb 08                	jmp    800792 <vprintfmt+0x278>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	85 ff                	test   %edi,%edi
  800794:	7f e4                	jg     80077a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800796:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800799:	e9 a2 fd ff ff       	jmp    800540 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80079e:	83 fa 01             	cmp    $0x1,%edx
  8007a1:	7e 16                	jle    8007b9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 08             	lea    0x8(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ac:	8b 50 04             	mov    0x4(%eax),%edx
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b7:	eb 32                	jmp    8007eb <vprintfmt+0x2d1>
	else if (lflag)
  8007b9:	85 d2                	test   %edx,%edx
  8007bb:	74 18                	je     8007d5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 50 04             	lea    0x4(%eax),%edx
  8007c3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c6:	8b 00                	mov    (%eax),%eax
  8007c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cb:	89 c1                	mov    %eax,%ecx
  8007cd:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d3:	eb 16                	jmp    8007eb <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 04             	lea    0x4(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e3:	89 c1                	mov    %eax,%ecx
  8007e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007fa:	79 74                	jns    800870 <vprintfmt+0x356>
				putch('-', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	53                   	push   %ebx
  800800:	6a 2d                	push   $0x2d
  800802:	ff d6                	call   *%esi
				num = -(long long) num;
  800804:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800807:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80080a:	f7 d8                	neg    %eax
  80080c:	83 d2 00             	adc    $0x0,%edx
  80080f:	f7 da                	neg    %edx
  800811:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800814:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800819:	eb 55                	jmp    800870 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
  80081e:	e8 83 fc ff ff       	call   8004a6 <getuint>
			base = 10;
  800823:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800828:	eb 46                	jmp    800870 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  80082a:	8d 45 14             	lea    0x14(%ebp),%eax
  80082d:	e8 74 fc ff ff       	call   8004a6 <getuint>
			base = 8;
  800832:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800837:	eb 37                	jmp    800870 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	53                   	push   %ebx
  80083d:	6a 30                	push   $0x30
  80083f:	ff d6                	call   *%esi
			putch('x', putdat);
  800841:	83 c4 08             	add    $0x8,%esp
  800844:	53                   	push   %ebx
  800845:	6a 78                	push   $0x78
  800847:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8d 50 04             	lea    0x4(%eax),%edx
  80084f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800852:	8b 00                	mov    (%eax),%eax
  800854:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800859:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80085c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800861:	eb 0d                	jmp    800870 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
  800866:	e8 3b fc ff ff       	call   8004a6 <getuint>
			base = 16;
  80086b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800870:	83 ec 0c             	sub    $0xc,%esp
  800873:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800877:	57                   	push   %edi
  800878:	ff 75 e0             	pushl  -0x20(%ebp)
  80087b:	51                   	push   %ecx
  80087c:	52                   	push   %edx
  80087d:	50                   	push   %eax
  80087e:	89 da                	mov    %ebx,%edx
  800880:	89 f0                	mov    %esi,%eax
  800882:	e8 70 fb ff ff       	call   8003f7 <printnum>
			break;
  800887:	83 c4 20             	add    $0x20,%esp
  80088a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088d:	e9 ae fc ff ff       	jmp    800540 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800892:	83 ec 08             	sub    $0x8,%esp
  800895:	53                   	push   %ebx
  800896:	51                   	push   %ecx
  800897:	ff d6                	call   *%esi
			break;
  800899:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80089c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80089f:	e9 9c fc ff ff       	jmp    800540 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	53                   	push   %ebx
  8008a8:	6a 25                	push   $0x25
  8008aa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 03                	jmp    8008b4 <vprintfmt+0x39a>
  8008b1:	83 ef 01             	sub    $0x1,%edi
  8008b4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008b8:	75 f7                	jne    8008b1 <vprintfmt+0x397>
  8008ba:	e9 81 fc ff ff       	jmp    800540 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5f                   	pop    %edi
  8008c5:	5d                   	pop    %ebp
  8008c6:	c3                   	ret    

008008c7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c7:	55                   	push   %ebp
  8008c8:	89 e5                	mov    %esp,%ebp
  8008ca:	83 ec 18             	sub    $0x18,%esp
  8008cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	74 26                	je     80090e <vsnprintf+0x47>
  8008e8:	85 d2                	test   %edx,%edx
  8008ea:	7e 22                	jle    80090e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ec:	ff 75 14             	pushl  0x14(%ebp)
  8008ef:	ff 75 10             	pushl  0x10(%ebp)
  8008f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f5:	50                   	push   %eax
  8008f6:	68 e0 04 80 00       	push   $0x8004e0
  8008fb:	e8 1a fc ff ff       	call   80051a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800900:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800903:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800906:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800909:	83 c4 10             	add    $0x10,%esp
  80090c:	eb 05                	jmp    800913 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80090e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800913:	c9                   	leave  
  800914:	c3                   	ret    

00800915 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80091b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80091e:	50                   	push   %eax
  80091f:	ff 75 10             	pushl  0x10(%ebp)
  800922:	ff 75 0c             	pushl  0xc(%ebp)
  800925:	ff 75 08             	pushl  0x8(%ebp)
  800928:	e8 9a ff ff ff       	call   8008c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
  80093a:	eb 03                	jmp    80093f <strlen+0x10>
		n++;
  80093c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80093f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800943:	75 f7                	jne    80093c <strlen+0xd>
		n++;
	return n;
}
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800950:	ba 00 00 00 00       	mov    $0x0,%edx
  800955:	eb 03                	jmp    80095a <strnlen+0x13>
		n++;
  800957:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095a:	39 c2                	cmp    %eax,%edx
  80095c:	74 08                	je     800966 <strnlen+0x1f>
  80095e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800962:	75 f3                	jne    800957 <strnlen+0x10>
  800964:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	53                   	push   %ebx
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800972:	89 c2                	mov    %eax,%edx
  800974:	83 c2 01             	add    $0x1,%edx
  800977:	83 c1 01             	add    $0x1,%ecx
  80097a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80097e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800981:	84 db                	test   %bl,%bl
  800983:	75 ef                	jne    800974 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800985:	5b                   	pop    %ebx
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	53                   	push   %ebx
  80098c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80098f:	53                   	push   %ebx
  800990:	e8 9a ff ff ff       	call   80092f <strlen>
  800995:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	01 d8                	add    %ebx,%eax
  80099d:	50                   	push   %eax
  80099e:	e8 c5 ff ff ff       	call   800968 <strcpy>
	return dst;
}
  8009a3:	89 d8                	mov    %ebx,%eax
  8009a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	56                   	push   %esi
  8009ae:	53                   	push   %ebx
  8009af:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b5:	89 f3                	mov    %esi,%ebx
  8009b7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009ba:	89 f2                	mov    %esi,%edx
  8009bc:	eb 0f                	jmp    8009cd <strncpy+0x23>
		*dst++ = *src;
  8009be:	83 c2 01             	add    $0x1,%edx
  8009c1:	0f b6 01             	movzbl (%ecx),%eax
  8009c4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c7:	80 39 01             	cmpb   $0x1,(%ecx)
  8009ca:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009cd:	39 da                	cmp    %ebx,%edx
  8009cf:	75 ed                	jne    8009be <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d1:	89 f0                	mov    %esi,%eax
  8009d3:	5b                   	pop    %ebx
  8009d4:	5e                   	pop    %esi
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	56                   	push   %esi
  8009db:	53                   	push   %ebx
  8009dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e2:	8b 55 10             	mov    0x10(%ebp),%edx
  8009e5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e7:	85 d2                	test   %edx,%edx
  8009e9:	74 21                	je     800a0c <strlcpy+0x35>
  8009eb:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ef:	89 f2                	mov    %esi,%edx
  8009f1:	eb 09                	jmp    8009fc <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009f3:	83 c2 01             	add    $0x1,%edx
  8009f6:	83 c1 01             	add    $0x1,%ecx
  8009f9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009fc:	39 c2                	cmp    %eax,%edx
  8009fe:	74 09                	je     800a09 <strlcpy+0x32>
  800a00:	0f b6 19             	movzbl (%ecx),%ebx
  800a03:	84 db                	test   %bl,%bl
  800a05:	75 ec                	jne    8009f3 <strlcpy+0x1c>
  800a07:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a09:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a0c:	29 f0                	sub    %esi,%eax
}
  800a0e:	5b                   	pop    %ebx
  800a0f:	5e                   	pop    %esi
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1b:	eb 06                	jmp    800a23 <strcmp+0x11>
		p++, q++;
  800a1d:	83 c1 01             	add    $0x1,%ecx
  800a20:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a23:	0f b6 01             	movzbl (%ecx),%eax
  800a26:	84 c0                	test   %al,%al
  800a28:	74 04                	je     800a2e <strcmp+0x1c>
  800a2a:	3a 02                	cmp    (%edx),%al
  800a2c:	74 ef                	je     800a1d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2e:	0f b6 c0             	movzbl %al,%eax
  800a31:	0f b6 12             	movzbl (%edx),%edx
  800a34:	29 d0                	sub    %edx,%eax
}
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a42:	89 c3                	mov    %eax,%ebx
  800a44:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a47:	eb 06                	jmp    800a4f <strncmp+0x17>
		n--, p++, q++;
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4f:	39 d8                	cmp    %ebx,%eax
  800a51:	74 15                	je     800a68 <strncmp+0x30>
  800a53:	0f b6 08             	movzbl (%eax),%ecx
  800a56:	84 c9                	test   %cl,%cl
  800a58:	74 04                	je     800a5e <strncmp+0x26>
  800a5a:	3a 0a                	cmp    (%edx),%cl
  800a5c:	74 eb                	je     800a49 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5e:	0f b6 00             	movzbl (%eax),%eax
  800a61:	0f b6 12             	movzbl (%edx),%edx
  800a64:	29 d0                	sub    %edx,%eax
  800a66:	eb 05                	jmp    800a6d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a7a:	eb 07                	jmp    800a83 <strchr+0x13>
		if (*s == c)
  800a7c:	38 ca                	cmp    %cl,%dl
  800a7e:	74 0f                	je     800a8f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a80:	83 c0 01             	add    $0x1,%eax
  800a83:	0f b6 10             	movzbl (%eax),%edx
  800a86:	84 d2                	test   %dl,%dl
  800a88:	75 f2                	jne    800a7c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9b:	eb 03                	jmp    800aa0 <strfind+0xf>
  800a9d:	83 c0 01             	add    $0x1,%eax
  800aa0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aa3:	38 ca                	cmp    %cl,%dl
  800aa5:	74 04                	je     800aab <strfind+0x1a>
  800aa7:	84 d2                	test   %dl,%dl
  800aa9:	75 f2                	jne    800a9d <strfind+0xc>
			break;
	return (char *) s;
}
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab9:	85 c9                	test   %ecx,%ecx
  800abb:	74 36                	je     800af3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac3:	75 28                	jne    800aed <memset+0x40>
  800ac5:	f6 c1 03             	test   $0x3,%cl
  800ac8:	75 23                	jne    800aed <memset+0x40>
		c &= 0xFF;
  800aca:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ace:	89 d3                	mov    %edx,%ebx
  800ad0:	c1 e3 08             	shl    $0x8,%ebx
  800ad3:	89 d6                	mov    %edx,%esi
  800ad5:	c1 e6 18             	shl    $0x18,%esi
  800ad8:	89 d0                	mov    %edx,%eax
  800ada:	c1 e0 10             	shl    $0x10,%eax
  800add:	09 f0                	or     %esi,%eax
  800adf:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae1:	89 d8                	mov    %ebx,%eax
  800ae3:	09 d0                	or     %edx,%eax
  800ae5:	c1 e9 02             	shr    $0x2,%ecx
  800ae8:	fc                   	cld    
  800ae9:	f3 ab                	rep stos %eax,%es:(%edi)
  800aeb:	eb 06                	jmp    800af3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aed:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af0:	fc                   	cld    
  800af1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800af3:	89 f8                	mov    %edi,%eax
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
  800b02:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b08:	39 c6                	cmp    %eax,%esi
  800b0a:	73 35                	jae    800b41 <memmove+0x47>
  800b0c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b0f:	39 d0                	cmp    %edx,%eax
  800b11:	73 2e                	jae    800b41 <memmove+0x47>
		s += n;
		d += n;
  800b13:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	89 d6                	mov    %edx,%esi
  800b18:	09 fe                	or     %edi,%esi
  800b1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b20:	75 13                	jne    800b35 <memmove+0x3b>
  800b22:	f6 c1 03             	test   $0x3,%cl
  800b25:	75 0e                	jne    800b35 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b27:	83 ef 04             	sub    $0x4,%edi
  800b2a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b2d:	c1 e9 02             	shr    $0x2,%ecx
  800b30:	fd                   	std    
  800b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b33:	eb 09                	jmp    800b3e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b35:	83 ef 01             	sub    $0x1,%edi
  800b38:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b3b:	fd                   	std    
  800b3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b3e:	fc                   	cld    
  800b3f:	eb 1d                	jmp    800b5e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	89 f2                	mov    %esi,%edx
  800b43:	09 c2                	or     %eax,%edx
  800b45:	f6 c2 03             	test   $0x3,%dl
  800b48:	75 0f                	jne    800b59 <memmove+0x5f>
  800b4a:	f6 c1 03             	test   $0x3,%cl
  800b4d:	75 0a                	jne    800b59 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b4f:	c1 e9 02             	shr    $0x2,%ecx
  800b52:	89 c7                	mov    %eax,%edi
  800b54:	fc                   	cld    
  800b55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b57:	eb 05                	jmp    800b5e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b59:	89 c7                	mov    %eax,%edi
  800b5b:	fc                   	cld    
  800b5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b65:	ff 75 10             	pushl  0x10(%ebp)
  800b68:	ff 75 0c             	pushl  0xc(%ebp)
  800b6b:	ff 75 08             	pushl  0x8(%ebp)
  800b6e:	e8 87 ff ff ff       	call   800afa <memmove>
}
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b80:	89 c6                	mov    %eax,%esi
  800b82:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b85:	eb 1a                	jmp    800ba1 <memcmp+0x2c>
		if (*s1 != *s2)
  800b87:	0f b6 08             	movzbl (%eax),%ecx
  800b8a:	0f b6 1a             	movzbl (%edx),%ebx
  800b8d:	38 d9                	cmp    %bl,%cl
  800b8f:	74 0a                	je     800b9b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b91:	0f b6 c1             	movzbl %cl,%eax
  800b94:	0f b6 db             	movzbl %bl,%ebx
  800b97:	29 d8                	sub    %ebx,%eax
  800b99:	eb 0f                	jmp    800baa <memcmp+0x35>
		s1++, s2++;
  800b9b:	83 c0 01             	add    $0x1,%eax
  800b9e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba1:	39 f0                	cmp    %esi,%eax
  800ba3:	75 e2                	jne    800b87 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	53                   	push   %ebx
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bb5:	89 c1                	mov    %eax,%ecx
  800bb7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bba:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bbe:	eb 0a                	jmp    800bca <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc0:	0f b6 10             	movzbl (%eax),%edx
  800bc3:	39 da                	cmp    %ebx,%edx
  800bc5:	74 07                	je     800bce <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	39 c8                	cmp    %ecx,%eax
  800bcc:	72 f2                	jb     800bc0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bda:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bdd:	eb 03                	jmp    800be2 <strtol+0x11>
		s++;
  800bdf:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be2:	0f b6 01             	movzbl (%ecx),%eax
  800be5:	3c 20                	cmp    $0x20,%al
  800be7:	74 f6                	je     800bdf <strtol+0xe>
  800be9:	3c 09                	cmp    $0x9,%al
  800beb:	74 f2                	je     800bdf <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bed:	3c 2b                	cmp    $0x2b,%al
  800bef:	75 0a                	jne    800bfb <strtol+0x2a>
		s++;
  800bf1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf4:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf9:	eb 11                	jmp    800c0c <strtol+0x3b>
  800bfb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c00:	3c 2d                	cmp    $0x2d,%al
  800c02:	75 08                	jne    800c0c <strtol+0x3b>
		s++, neg = 1;
  800c04:	83 c1 01             	add    $0x1,%ecx
  800c07:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c12:	75 15                	jne    800c29 <strtol+0x58>
  800c14:	80 39 30             	cmpb   $0x30,(%ecx)
  800c17:	75 10                	jne    800c29 <strtol+0x58>
  800c19:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c1d:	75 7c                	jne    800c9b <strtol+0xca>
		s += 2, base = 16;
  800c1f:	83 c1 02             	add    $0x2,%ecx
  800c22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c27:	eb 16                	jmp    800c3f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c29:	85 db                	test   %ebx,%ebx
  800c2b:	75 12                	jne    800c3f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c2d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c32:	80 39 30             	cmpb   $0x30,(%ecx)
  800c35:	75 08                	jne    800c3f <strtol+0x6e>
		s++, base = 8;
  800c37:	83 c1 01             	add    $0x1,%ecx
  800c3a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c44:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c47:	0f b6 11             	movzbl (%ecx),%edx
  800c4a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 09             	cmp    $0x9,%bl
  800c52:	77 08                	ja     800c5c <strtol+0x8b>
			dig = *s - '0';
  800c54:	0f be d2             	movsbl %dl,%edx
  800c57:	83 ea 30             	sub    $0x30,%edx
  800c5a:	eb 22                	jmp    800c7e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c5c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 19             	cmp    $0x19,%bl
  800c64:	77 08                	ja     800c6e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c66:	0f be d2             	movsbl %dl,%edx
  800c69:	83 ea 57             	sub    $0x57,%edx
  800c6c:	eb 10                	jmp    800c7e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c6e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c71:	89 f3                	mov    %esi,%ebx
  800c73:	80 fb 19             	cmp    $0x19,%bl
  800c76:	77 16                	ja     800c8e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c78:	0f be d2             	movsbl %dl,%edx
  800c7b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c7e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c81:	7d 0b                	jge    800c8e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c83:	83 c1 01             	add    $0x1,%ecx
  800c86:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c8a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c8c:	eb b9                	jmp    800c47 <strtol+0x76>

	if (endptr)
  800c8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c92:	74 0d                	je     800ca1 <strtol+0xd0>
		*endptr = (char *) s;
  800c94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c97:	89 0e                	mov    %ecx,(%esi)
  800c99:	eb 06                	jmp    800ca1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9b:	85 db                	test   %ebx,%ebx
  800c9d:	74 98                	je     800c37 <strtol+0x66>
  800c9f:	eb 9e                	jmp    800c3f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca1:	89 c2                	mov    %eax,%edx
  800ca3:	f7 da                	neg    %edx
  800ca5:	85 ff                	test   %edi,%edi
  800ca7:	0f 45 c2             	cmovne %edx,%eax
}
  800caa:	5b                   	pop    %ebx
  800cab:	5e                   	pop    %esi
  800cac:	5f                   	pop    %edi
  800cad:	5d                   	pop    %ebp
  800cae:	c3                   	ret    
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
