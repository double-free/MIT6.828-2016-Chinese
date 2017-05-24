
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 78 0f 80 00       	push   $0x800f78
  800110:	6a 23                	push   $0x23
  800112:	68 95 0f 80 00       	push   $0x800f95
  800117:	e8 f5 01 00 00       	call   800311 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 78 0f 80 00       	push   $0x800f78
  800191:	6a 23                	push   $0x23
  800193:	68 95 0f 80 00       	push   $0x800f95
  800198:	e8 74 01 00 00       	call   800311 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 78 0f 80 00       	push   $0x800f78
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 95 0f 80 00       	push   $0x800f95
  8001da:	e8 32 01 00 00       	call   800311 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 78 0f 80 00       	push   $0x800f78
  800215:	6a 23                	push   $0x23
  800217:	68 95 0f 80 00       	push   $0x800f95
  80021c:	e8 f0 00 00 00       	call   800311 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 78 0f 80 00       	push   $0x800f78
  800257:	6a 23                	push   $0x23
  800259:	68 95 0f 80 00       	push   $0x800f95
  80025e:	e8 ae 00 00 00       	call   800311 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 78 0f 80 00       	push   $0x800f78
  800299:	6a 23                	push   $0x23
  80029b:	68 95 0f 80 00       	push   $0x800f95
  8002a0:	e8 6c 00 00 00       	call   800311 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b3:	be 00 00 00 00       	mov    $0x0,%esi
  8002b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 17                	jle    800309 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	50                   	push   %eax
  8002f6:	6a 0c                	push   $0xc
  8002f8:	68 78 0f 80 00       	push   $0x800f78
  8002fd:	6a 23                	push   $0x23
  8002ff:	68 95 0f 80 00       	push   $0x800f95
  800304:	e8 08 00 00 00       	call   800311 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800319:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80031f:	e8 00 fe ff ff       	call   800124 <sys_getenvid>
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	56                   	push   %esi
  80032e:	50                   	push   %eax
  80032f:	68 a4 0f 80 00       	push   $0x800fa4
  800334:	e8 b1 00 00 00       	call   8003ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	e8 54 00 00 00       	call   800399 <vcprintf>
	cprintf("\n");
  800345:	c7 04 24 6c 0f 80 00 	movl   $0x800f6c,(%esp)
  80034c:	e8 99 00 00 00       	call   8003ea <cprintf>
  800351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800354:	cc                   	int3   
  800355:	eb fd                	jmp    800354 <_panic+0x43>

00800357 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	53                   	push   %ebx
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800361:	8b 13                	mov    (%ebx),%edx
  800363:	8d 42 01             	lea    0x1(%edx),%eax
  800366:	89 03                	mov    %eax,(%ebx)
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800374:	75 1a                	jne    800390 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	68 ff 00 00 00       	push   $0xff
  80037e:	8d 43 08             	lea    0x8(%ebx),%eax
  800381:	50                   	push   %eax
  800382:	e8 1f fd ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  800387:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800390:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800394:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a9:	00 00 00 
	b.cnt = 0;
  8003ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b6:	ff 75 0c             	pushl  0xc(%ebp)
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	68 57 03 80 00       	push   $0x800357
  8003c8:	e8 54 01 00 00       	call   800521 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cd:	83 c4 08             	add    $0x8,%esp
  8003d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 c4 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8003e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f3:	50                   	push   %eax
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 9d ff ff ff       	call   800399 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 1c             	sub    $0x1c,%esp
  800407:	89 c7                	mov    %eax,%edi
  800409:	89 d6                	mov    %edx,%esi
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800417:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800422:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800425:	39 d3                	cmp    %edx,%ebx
  800427:	72 05                	jb     80042e <printnum+0x30>
  800429:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042c:	77 45                	ja     800473 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042e:	83 ec 0c             	sub    $0xc,%esp
  800431:	ff 75 18             	pushl  0x18(%ebp)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043a:	53                   	push   %ebx
  80043b:	ff 75 10             	pushl  0x10(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 e4             	pushl  -0x1c(%ebp)
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff 75 dc             	pushl  -0x24(%ebp)
  80044a:	ff 75 d8             	pushl  -0x28(%ebp)
  80044d:	e8 6e 08 00 00       	call   800cc0 <__udivdi3>
  800452:	83 c4 18             	add    $0x18,%esp
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	89 f2                	mov    %esi,%edx
  800459:	89 f8                	mov    %edi,%eax
  80045b:	e8 9e ff ff ff       	call   8003fe <printnum>
  800460:	83 c4 20             	add    $0x20,%esp
  800463:	eb 18                	jmp    80047d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	ff 75 18             	pushl  0x18(%ebp)
  80046c:	ff d7                	call   *%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb 03                	jmp    800476 <printnum+0x78>
  800473:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800476:	83 eb 01             	sub    $0x1,%ebx
  800479:	85 db                	test   %ebx,%ebx
  80047b:	7f e8                	jg     800465 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	56                   	push   %esi
  800481:	83 ec 04             	sub    $0x4,%esp
  800484:	ff 75 e4             	pushl  -0x1c(%ebp)
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff 75 dc             	pushl  -0x24(%ebp)
  80048d:	ff 75 d8             	pushl  -0x28(%ebp)
  800490:	e8 5b 09 00 00       	call   800df0 <__umoddi3>
  800495:	83 c4 14             	add    $0x14,%esp
  800498:	0f be 80 c8 0f 80 00 	movsbl 0x800fc8(%eax),%eax
  80049f:	50                   	push   %eax
  8004a0:	ff d7                	call   *%edi
}
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a8:	5b                   	pop    %ebx
  8004a9:	5e                   	pop    %esi
  8004aa:	5f                   	pop    %edi
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b0:	83 fa 01             	cmp    $0x1,%edx
  8004b3:	7e 0e                	jle    8004c3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ba:	89 08                	mov    %ecx,(%eax)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	8b 52 04             	mov    0x4(%edx),%edx
  8004c1:	eb 22                	jmp    8004e5 <getuint+0x38>
	else if (lflag)
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	74 10                	je     8004d7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d5:	eb 0e                	jmp    8004e5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dc:	89 08                	mov    %ecx,(%eax)
  8004de:	8b 02                	mov    (%edx),%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f6:	73 0a                	jae    800502 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fb:	89 08                	mov    %ecx,(%eax)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	88 02                	mov    %al,(%edx)
}
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050d:	50                   	push   %eax
  80050e:	ff 75 10             	pushl  0x10(%ebp)
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 05 00 00 00       	call   800521 <vprintfmt>
	va_end(ap);
}
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
  80052a:	8b 75 08             	mov    0x8(%ebp),%esi
  80052d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800530:	8b 7d 10             	mov    0x10(%ebp),%edi
  800533:	eb 12                	jmp    800547 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800535:	85 c0                	test   %eax,%eax
  800537:	0f 84 89 03 00 00    	je     8008c6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	50                   	push   %eax
  800542:	ff d6                	call   *%esi
  800544:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800547:	83 c7 01             	add    $0x1,%edi
  80054a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054e:	83 f8 25             	cmp    $0x25,%eax
  800551:	75 e2                	jne    800535 <vprintfmt+0x14>
  800553:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800557:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800565:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056c:	ba 00 00 00 00       	mov    $0x0,%edx
  800571:	eb 07                	jmp    80057a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800576:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8d 47 01             	lea    0x1(%edi),%eax
  80057d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800580:	0f b6 07             	movzbl (%edi),%eax
  800583:	0f b6 c8             	movzbl %al,%ecx
  800586:	83 e8 23             	sub    $0x23,%eax
  800589:	3c 55                	cmp    $0x55,%al
  80058b:	0f 87 1a 03 00 00    	ja     8008ab <vprintfmt+0x38a>
  800591:	0f b6 c0             	movzbl %al,%eax
  800594:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a2:	eb d6                	jmp    80057a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bc:	83 fa 09             	cmp    $0x9,%edx
  8005bf:	77 39                	ja     8005fa <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c4:	eb e9                	jmp    8005af <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d7:	eb 27                	jmp    800600 <vprintfmt+0xdf>
  8005d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e3:	0f 49 c8             	cmovns %eax,%ecx
  8005e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ec:	eb 8c                	jmp    80057a <vprintfmt+0x59>
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f8:	eb 80                	jmp    80057a <vprintfmt+0x59>
  8005fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800600:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800604:	0f 89 70 ff ff ff    	jns    80057a <vprintfmt+0x59>
				width = precision, precision = -1;
  80060a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800610:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800617:	e9 5e ff ff ff       	jmp    80057a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800622:	e9 53 ff ff ff       	jmp    80057a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 50 04             	lea    0x4(%eax),%edx
  80062d:	89 55 14             	mov    %edx,0x14(%ebp)
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	ff 30                	pushl  (%eax)
  800636:	ff d6                	call   *%esi
			break;
  800638:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063e:	e9 04 ff ff ff       	jmp    800547 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 00                	mov    (%eax),%eax
  80064e:	99                   	cltd   
  80064f:	31 d0                	xor    %edx,%eax
  800651:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800653:	83 f8 08             	cmp    $0x8,%eax
  800656:	7f 0b                	jg     800663 <vprintfmt+0x142>
  800658:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  80065f:	85 d2                	test   %edx,%edx
  800661:	75 18                	jne    80067b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800663:	50                   	push   %eax
  800664:	68 e0 0f 80 00       	push   $0x800fe0
  800669:	53                   	push   %ebx
  80066a:	56                   	push   %esi
  80066b:	e8 94 fe ff ff       	call   800504 <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800676:	e9 cc fe ff ff       	jmp    800547 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067b:	52                   	push   %edx
  80067c:	68 e9 0f 80 00       	push   $0x800fe9
  800681:	53                   	push   %ebx
  800682:	56                   	push   %esi
  800683:	e8 7c fe ff ff       	call   800504 <printfmt>
  800688:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068e:	e9 b4 fe ff ff       	jmp    800547 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 04             	lea    0x4(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)
  80069c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	b8 d9 0f 80 00       	mov    $0x800fd9,%eax
  8006a5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ac:	0f 8e 94 00 00 00    	jle    800746 <vprintfmt+0x225>
  8006b2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b6:	0f 84 98 00 00 00    	je     800754 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c2:	57                   	push   %edi
  8006c3:	e8 86 02 00 00       	call   80094e <strnlen>
  8006c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cb:	29 c1                	sub    %eax,%ecx
  8006cd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006d0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006da:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006dd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006df:	eb 0f                	jmp    8006f0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ea:	83 ef 01             	sub    $0x1,%edi
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	85 ff                	test   %edi,%edi
  8006f2:	7f ed                	jg     8006e1 <vprintfmt+0x1c0>
  8006f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006fa:	85 c9                	test   %ecx,%ecx
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	0f 49 c1             	cmovns %ecx,%eax
  800704:	29 c1                	sub    %eax,%ecx
  800706:	89 75 08             	mov    %esi,0x8(%ebp)
  800709:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070f:	89 cb                	mov    %ecx,%ebx
  800711:	eb 4d                	jmp    800760 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800713:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800717:	74 1b                	je     800734 <vprintfmt+0x213>
  800719:	0f be c0             	movsbl %al,%eax
  80071c:	83 e8 20             	sub    $0x20,%eax
  80071f:	83 f8 5e             	cmp    $0x5e,%eax
  800722:	76 10                	jbe    800734 <vprintfmt+0x213>
					putch('?', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	6a 3f                	push   $0x3f
  80072c:	ff 55 08             	call   *0x8(%ebp)
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	eb 0d                	jmp    800741 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	52                   	push   %edx
  80073b:	ff 55 08             	call   *0x8(%ebp)
  80073e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800741:	83 eb 01             	sub    $0x1,%ebx
  800744:	eb 1a                	jmp    800760 <vprintfmt+0x23f>
  800746:	89 75 08             	mov    %esi,0x8(%ebp)
  800749:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800752:	eb 0c                	jmp    800760 <vprintfmt+0x23f>
  800754:	89 75 08             	mov    %esi,0x8(%ebp)
  800757:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800760:	83 c7 01             	add    $0x1,%edi
  800763:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800767:	0f be d0             	movsbl %al,%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 23                	je     800791 <vprintfmt+0x270>
  80076e:	85 f6                	test   %esi,%esi
  800770:	78 a1                	js     800713 <vprintfmt+0x1f2>
  800772:	83 ee 01             	sub    $0x1,%esi
  800775:	79 9c                	jns    800713 <vprintfmt+0x1f2>
  800777:	89 df                	mov    %ebx,%edi
  800779:	8b 75 08             	mov    0x8(%ebp),%esi
  80077c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077f:	eb 18                	jmp    800799 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 20                	push   $0x20
  800787:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800789:	83 ef 01             	sub    $0x1,%edi
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	eb 08                	jmp    800799 <vprintfmt+0x278>
  800791:	89 df                	mov    %ebx,%edi
  800793:	8b 75 08             	mov    0x8(%ebp),%esi
  800796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800799:	85 ff                	test   %edi,%edi
  80079b:	7f e4                	jg     800781 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a0:	e9 a2 fd ff ff       	jmp    800547 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a5:	83 fa 01             	cmp    $0x1,%edx
  8007a8:	7e 16                	jle    8007c0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 08             	lea    0x8(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b3:	8b 50 04             	mov    0x4(%eax),%edx
  8007b6:	8b 00                	mov    (%eax),%eax
  8007b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007be:	eb 32                	jmp    8007f2 <vprintfmt+0x2d1>
	else if (lflag)
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	74 18                	je     8007dc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d2:	89 c1                	mov    %eax,%ecx
  8007d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007da:	eb 16                	jmp    8007f2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 50 04             	lea    0x4(%eax),%edx
  8007e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e5:	8b 00                	mov    (%eax),%eax
  8007e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ea:	89 c1                	mov    %eax,%ecx
  8007ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007f5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800801:	79 74                	jns    800877 <vprintfmt+0x356>
				putch('-', putdat);
  800803:	83 ec 08             	sub    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	6a 2d                	push   $0x2d
  800809:	ff d6                	call   *%esi
				num = -(long long) num;
  80080b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80080e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800811:	f7 d8                	neg    %eax
  800813:	83 d2 00             	adc    $0x0,%edx
  800816:	f7 da                	neg    %edx
  800818:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800820:	eb 55                	jmp    800877 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800822:	8d 45 14             	lea    0x14(%ebp),%eax
  800825:	e8 83 fc ff ff       	call   8004ad <getuint>
			base = 10;
  80082a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80082f:	eb 46                	jmp    800877 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800831:	8d 45 14             	lea    0x14(%ebp),%eax
  800834:	e8 74 fc ff ff       	call   8004ad <getuint>
			base = 8;
  800839:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80083e:	eb 37                	jmp    800877 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	53                   	push   %ebx
  800844:	6a 30                	push   $0x30
  800846:	ff d6                	call   *%esi
			putch('x', putdat);
  800848:	83 c4 08             	add    $0x8,%esp
  80084b:	53                   	push   %ebx
  80084c:	6a 78                	push   $0x78
  80084e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 04             	lea    0x4(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800859:	8b 00                	mov    (%eax),%eax
  80085b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800860:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800863:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800868:	eb 0d                	jmp    800877 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80086a:	8d 45 14             	lea    0x14(%ebp),%eax
  80086d:	e8 3b fc ff ff       	call   8004ad <getuint>
			base = 16;
  800872:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800877:	83 ec 0c             	sub    $0xc,%esp
  80087a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80087e:	57                   	push   %edi
  80087f:	ff 75 e0             	pushl  -0x20(%ebp)
  800882:	51                   	push   %ecx
  800883:	52                   	push   %edx
  800884:	50                   	push   %eax
  800885:	89 da                	mov    %ebx,%edx
  800887:	89 f0                	mov    %esi,%eax
  800889:	e8 70 fb ff ff       	call   8003fe <printnum>
			break;
  80088e:	83 c4 20             	add    $0x20,%esp
  800891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800894:	e9 ae fc ff ff       	jmp    800547 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	53                   	push   %ebx
  80089d:	51                   	push   %ecx
  80089e:	ff d6                	call   *%esi
			break;
  8008a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008a6:	e9 9c fc ff ff       	jmp    800547 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ab:	83 ec 08             	sub    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	6a 25                	push   $0x25
  8008b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	eb 03                	jmp    8008bb <vprintfmt+0x39a>
  8008b8:	83 ef 01             	sub    $0x1,%edi
  8008bb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008bf:	75 f7                	jne    8008b8 <vprintfmt+0x397>
  8008c1:	e9 81 fc ff ff       	jmp    800547 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c9:	5b                   	pop    %ebx
  8008ca:	5e                   	pop    %esi
  8008cb:	5f                   	pop    %edi
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 18             	sub    $0x18,%esp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	74 26                	je     800915 <vsnprintf+0x47>
  8008ef:	85 d2                	test   %edx,%edx
  8008f1:	7e 22                	jle    800915 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f3:	ff 75 14             	pushl  0x14(%ebp)
  8008f6:	ff 75 10             	pushl  0x10(%ebp)
  8008f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fc:	50                   	push   %eax
  8008fd:	68 e7 04 80 00       	push   $0x8004e7
  800902:	e8 1a fc ff ff       	call   800521 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800907:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80090a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	eb 05                	jmp    80091a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800915:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091a:	c9                   	leave  
  80091b:	c3                   	ret    

0080091c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800922:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800925:	50                   	push   %eax
  800926:	ff 75 10             	pushl  0x10(%ebp)
  800929:	ff 75 0c             	pushl  0xc(%ebp)
  80092c:	ff 75 08             	pushl  0x8(%ebp)
  80092f:	e8 9a ff ff ff       	call   8008ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
  800941:	eb 03                	jmp    800946 <strlen+0x10>
		n++;
  800943:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800946:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80094a:	75 f7                	jne    800943 <strlen+0xd>
		n++;
	return n;
}
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800954:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800957:	ba 00 00 00 00       	mov    $0x0,%edx
  80095c:	eb 03                	jmp    800961 <strnlen+0x13>
		n++;
  80095e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800961:	39 c2                	cmp    %eax,%edx
  800963:	74 08                	je     80096d <strnlen+0x1f>
  800965:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800969:	75 f3                	jne    80095e <strnlen+0x10>
  80096b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800979:	89 c2                	mov    %eax,%edx
  80097b:	83 c2 01             	add    $0x1,%edx
  80097e:	83 c1 01             	add    $0x1,%ecx
  800981:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800985:	88 5a ff             	mov    %bl,-0x1(%edx)
  800988:	84 db                	test   %bl,%bl
  80098a:	75 ef                	jne    80097b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80098c:	5b                   	pop    %ebx
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	53                   	push   %ebx
  800993:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800996:	53                   	push   %ebx
  800997:	e8 9a ff ff ff       	call   800936 <strlen>
  80099c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80099f:	ff 75 0c             	pushl  0xc(%ebp)
  8009a2:	01 d8                	add    %ebx,%eax
  8009a4:	50                   	push   %eax
  8009a5:	e8 c5 ff ff ff       	call   80096f <strcpy>
	return dst;
}
  8009aa:	89 d8                	mov    %ebx,%eax
  8009ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009af:	c9                   	leave  
  8009b0:	c3                   	ret    

008009b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	56                   	push   %esi
  8009b5:	53                   	push   %ebx
  8009b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bc:	89 f3                	mov    %esi,%ebx
  8009be:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c1:	89 f2                	mov    %esi,%edx
  8009c3:	eb 0f                	jmp    8009d4 <strncpy+0x23>
		*dst++ = *src;
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	0f b6 01             	movzbl (%ecx),%eax
  8009cb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ce:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	39 da                	cmp    %ebx,%edx
  8009d6:	75 ed                	jne    8009c5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d8:	89 f0                	mov    %esi,%eax
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009ec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ee:	85 d2                	test   %edx,%edx
  8009f0:	74 21                	je     800a13 <strlcpy+0x35>
  8009f2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009f6:	89 f2                	mov    %esi,%edx
  8009f8:	eb 09                	jmp    800a03 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009fa:	83 c2 01             	add    $0x1,%edx
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a03:	39 c2                	cmp    %eax,%edx
  800a05:	74 09                	je     800a10 <strlcpy+0x32>
  800a07:	0f b6 19             	movzbl (%ecx),%ebx
  800a0a:	84 db                	test   %bl,%bl
  800a0c:	75 ec                	jne    8009fa <strlcpy+0x1c>
  800a0e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a10:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a13:	29 f0                	sub    %esi,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a22:	eb 06                	jmp    800a2a <strcmp+0x11>
		p++, q++;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2a:	0f b6 01             	movzbl (%ecx),%eax
  800a2d:	84 c0                	test   %al,%al
  800a2f:	74 04                	je     800a35 <strcmp+0x1c>
  800a31:	3a 02                	cmp    (%edx),%al
  800a33:	74 ef                	je     800a24 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 12             	movzbl (%edx),%edx
  800a3b:	29 d0                	sub    %edx,%eax
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a49:	89 c3                	mov    %eax,%ebx
  800a4b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a4e:	eb 06                	jmp    800a56 <strncmp+0x17>
		n--, p++, q++;
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a56:	39 d8                	cmp    %ebx,%eax
  800a58:	74 15                	je     800a6f <strncmp+0x30>
  800a5a:	0f b6 08             	movzbl (%eax),%ecx
  800a5d:	84 c9                	test   %cl,%cl
  800a5f:	74 04                	je     800a65 <strncmp+0x26>
  800a61:	3a 0a                	cmp    (%edx),%cl
  800a63:	74 eb                	je     800a50 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a65:	0f b6 00             	movzbl (%eax),%eax
  800a68:	0f b6 12             	movzbl (%edx),%edx
  800a6b:	29 d0                	sub    %edx,%eax
  800a6d:	eb 05                	jmp    800a74 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a74:	5b                   	pop    %ebx
  800a75:	5d                   	pop    %ebp
  800a76:	c3                   	ret    

00800a77 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a77:	55                   	push   %ebp
  800a78:	89 e5                	mov    %esp,%ebp
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a81:	eb 07                	jmp    800a8a <strchr+0x13>
		if (*s == c)
  800a83:	38 ca                	cmp    %cl,%dl
  800a85:	74 0f                	je     800a96 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	0f b6 10             	movzbl (%eax),%edx
  800a8d:	84 d2                	test   %dl,%dl
  800a8f:	75 f2                	jne    800a83 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a91:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa2:	eb 03                	jmp    800aa7 <strfind+0xf>
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aaa:	38 ca                	cmp    %cl,%dl
  800aac:	74 04                	je     800ab2 <strfind+0x1a>
  800aae:	84 d2                	test   %dl,%dl
  800ab0:	75 f2                	jne    800aa4 <strfind+0xc>
			break;
	return (char *) s;
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 7d 08             	mov    0x8(%ebp),%edi
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac0:	85 c9                	test   %ecx,%ecx
  800ac2:	74 36                	je     800afa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ac4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aca:	75 28                	jne    800af4 <memset+0x40>
  800acc:	f6 c1 03             	test   $0x3,%cl
  800acf:	75 23                	jne    800af4 <memset+0x40>
		c &= 0xFF;
  800ad1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ad5:	89 d3                	mov    %edx,%ebx
  800ad7:	c1 e3 08             	shl    $0x8,%ebx
  800ada:	89 d6                	mov    %edx,%esi
  800adc:	c1 e6 18             	shl    $0x18,%esi
  800adf:	89 d0                	mov    %edx,%eax
  800ae1:	c1 e0 10             	shl    $0x10,%eax
  800ae4:	09 f0                	or     %esi,%eax
  800ae6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ae8:	89 d8                	mov    %ebx,%eax
  800aea:	09 d0                	or     %edx,%eax
  800aec:	c1 e9 02             	shr    $0x2,%ecx
  800aef:	fc                   	cld    
  800af0:	f3 ab                	rep stos %eax,%es:(%edi)
  800af2:	eb 06                	jmp    800afa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	fc                   	cld    
  800af8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800afa:	89 f8                	mov    %edi,%eax
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b0f:	39 c6                	cmp    %eax,%esi
  800b11:	73 35                	jae    800b48 <memmove+0x47>
  800b13:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b16:	39 d0                	cmp    %edx,%eax
  800b18:	73 2e                	jae    800b48 <memmove+0x47>
		s += n;
		d += n;
  800b1a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1d:	89 d6                	mov    %edx,%esi
  800b1f:	09 fe                	or     %edi,%esi
  800b21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b27:	75 13                	jne    800b3c <memmove+0x3b>
  800b29:	f6 c1 03             	test   $0x3,%cl
  800b2c:	75 0e                	jne    800b3c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b2e:	83 ef 04             	sub    $0x4,%edi
  800b31:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b34:	c1 e9 02             	shr    $0x2,%ecx
  800b37:	fd                   	std    
  800b38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b3a:	eb 09                	jmp    800b45 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3c:	83 ef 01             	sub    $0x1,%edi
  800b3f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b42:	fd                   	std    
  800b43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b45:	fc                   	cld    
  800b46:	eb 1d                	jmp    800b65 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b48:	89 f2                	mov    %esi,%edx
  800b4a:	09 c2                	or     %eax,%edx
  800b4c:	f6 c2 03             	test   $0x3,%dl
  800b4f:	75 0f                	jne    800b60 <memmove+0x5f>
  800b51:	f6 c1 03             	test   $0x3,%cl
  800b54:	75 0a                	jne    800b60 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b56:	c1 e9 02             	shr    $0x2,%ecx
  800b59:	89 c7                	mov    %eax,%edi
  800b5b:	fc                   	cld    
  800b5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b5e:	eb 05                	jmp    800b65 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b60:	89 c7                	mov    %eax,%edi
  800b62:	fc                   	cld    
  800b63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b6c:	ff 75 10             	pushl  0x10(%ebp)
  800b6f:	ff 75 0c             	pushl  0xc(%ebp)
  800b72:	ff 75 08             	pushl  0x8(%ebp)
  800b75:	e8 87 ff ff ff       	call   800b01 <memmove>
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b87:	89 c6                	mov    %eax,%esi
  800b89:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8c:	eb 1a                	jmp    800ba8 <memcmp+0x2c>
		if (*s1 != *s2)
  800b8e:	0f b6 08             	movzbl (%eax),%ecx
  800b91:	0f b6 1a             	movzbl (%edx),%ebx
  800b94:	38 d9                	cmp    %bl,%cl
  800b96:	74 0a                	je     800ba2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b98:	0f b6 c1             	movzbl %cl,%eax
  800b9b:	0f b6 db             	movzbl %bl,%ebx
  800b9e:	29 d8                	sub    %ebx,%eax
  800ba0:	eb 0f                	jmp    800bb1 <memcmp+0x35>
		s1++, s2++;
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba8:	39 f0                	cmp    %esi,%eax
  800baa:	75 e2                	jne    800b8e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	53                   	push   %ebx
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbc:	89 c1                	mov    %eax,%ecx
  800bbe:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc5:	eb 0a                	jmp    800bd1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc7:	0f b6 10             	movzbl (%eax),%edx
  800bca:	39 da                	cmp    %ebx,%edx
  800bcc:	74 07                	je     800bd5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bce:	83 c0 01             	add    $0x1,%eax
  800bd1:	39 c8                	cmp    %ecx,%eax
  800bd3:	72 f2                	jb     800bc7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd5:	5b                   	pop    %ebx
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be4:	eb 03                	jmp    800be9 <strtol+0x11>
		s++;
  800be6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be9:	0f b6 01             	movzbl (%ecx),%eax
  800bec:	3c 20                	cmp    $0x20,%al
  800bee:	74 f6                	je     800be6 <strtol+0xe>
  800bf0:	3c 09                	cmp    $0x9,%al
  800bf2:	74 f2                	je     800be6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf4:	3c 2b                	cmp    $0x2b,%al
  800bf6:	75 0a                	jne    800c02 <strtol+0x2a>
		s++;
  800bf8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bfb:	bf 00 00 00 00       	mov    $0x0,%edi
  800c00:	eb 11                	jmp    800c13 <strtol+0x3b>
  800c02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c07:	3c 2d                	cmp    $0x2d,%al
  800c09:	75 08                	jne    800c13 <strtol+0x3b>
		s++, neg = 1;
  800c0b:	83 c1 01             	add    $0x1,%ecx
  800c0e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c13:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c19:	75 15                	jne    800c30 <strtol+0x58>
  800c1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c1e:	75 10                	jne    800c30 <strtol+0x58>
  800c20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c24:	75 7c                	jne    800ca2 <strtol+0xca>
		s += 2, base = 16;
  800c26:	83 c1 02             	add    $0x2,%ecx
  800c29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2e:	eb 16                	jmp    800c46 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c30:	85 db                	test   %ebx,%ebx
  800c32:	75 12                	jne    800c46 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c34:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c39:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3c:	75 08                	jne    800c46 <strtol+0x6e>
		s++, base = 8;
  800c3e:	83 c1 01             	add    $0x1,%ecx
  800c41:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c4e:	0f b6 11             	movzbl (%ecx),%edx
  800c51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c54:	89 f3                	mov    %esi,%ebx
  800c56:	80 fb 09             	cmp    $0x9,%bl
  800c59:	77 08                	ja     800c63 <strtol+0x8b>
			dig = *s - '0';
  800c5b:	0f be d2             	movsbl %dl,%edx
  800c5e:	83 ea 30             	sub    $0x30,%edx
  800c61:	eb 22                	jmp    800c85 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c66:	89 f3                	mov    %esi,%ebx
  800c68:	80 fb 19             	cmp    $0x19,%bl
  800c6b:	77 08                	ja     800c75 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c6d:	0f be d2             	movsbl %dl,%edx
  800c70:	83 ea 57             	sub    $0x57,%edx
  800c73:	eb 10                	jmp    800c85 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c78:	89 f3                	mov    %esi,%ebx
  800c7a:	80 fb 19             	cmp    $0x19,%bl
  800c7d:	77 16                	ja     800c95 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c7f:	0f be d2             	movsbl %dl,%edx
  800c82:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c88:	7d 0b                	jge    800c95 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c8a:	83 c1 01             	add    $0x1,%ecx
  800c8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c91:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c93:	eb b9                	jmp    800c4e <strtol+0x76>

	if (endptr)
  800c95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c99:	74 0d                	je     800ca8 <strtol+0xd0>
		*endptr = (char *) s;
  800c9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c9e:	89 0e                	mov    %ecx,(%esi)
  800ca0:	eb 06                	jmp    800ca8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca2:	85 db                	test   %ebx,%ebx
  800ca4:	74 98                	je     800c3e <strtol+0x66>
  800ca6:	eb 9e                	jmp    800c46 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ca8:	89 c2                	mov    %eax,%edx
  800caa:	f7 da                	neg    %edx
  800cac:	85 ff                	test   %edi,%edi
  800cae:	0f 45 c2             	cmovne %edx,%eax
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    
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
