
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 4a 0f 80 00       	push   $0x800f4a
  800100:	6a 23                	push   $0x23
  800102:	68 67 0f 80 00       	push   $0x800f67
  800107:	e8 f5 01 00 00       	call   800301 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	b8 04 00 00 00       	mov    $0x4,%eax
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7e 17                	jle    80018d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 4a 0f 80 00       	push   $0x800f4a
  800181:	6a 23                	push   $0x23
  800183:	68 67 0f 80 00       	push   $0x800f67
  800188:	e8 74 01 00 00       	call   800301 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 4a 0f 80 00       	push   $0x800f4a
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 67 0f 80 00       	push   $0x800f67
  8001ca:	e8 32 01 00 00       	call   800301 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 4a 0f 80 00       	push   $0x800f4a
  800205:	6a 23                	push   $0x23
  800207:	68 67 0f 80 00       	push   $0x800f67
  80020c:	e8 f0 00 00 00       	call   800301 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	b8 08 00 00 00       	mov    $0x8,%eax
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 4a 0f 80 00       	push   $0x800f4a
  800247:	6a 23                	push   $0x23
  800249:	68 67 0f 80 00       	push   $0x800f67
  80024e:	e8 ae 00 00 00       	call   800301 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 09 00 00 00       	mov    $0x9,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 4a 0f 80 00       	push   $0x800f4a
  800289:	6a 23                	push   $0x23
  80028b:	68 67 0f 80 00       	push   $0x800f67
  800290:	e8 6c 00 00 00       	call   800301 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a3:	be 00 00 00 00       	mov    $0x0,%esi
  8002a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 4a 0f 80 00       	push   $0x800f4a
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 67 0f 80 00       	push   $0x800f67
  8002f4:	e8 08 00 00 00       	call   800301 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030f:	e8 00 fe ff ff       	call   800114 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 78 0f 80 00       	push   $0x800f78
  800324:	e8 b1 00 00 00       	call   8003da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	pushl  0x10(%ebp)
  800330:	e8 54 00 00 00       	call   800389 <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 9c 0f 80 00 	movl   $0x800f9c,(%esp)
  80033c:	e8 99 00 00 00       	call   8003da <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	75 1a                	jne    800380 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	68 ff 00 00 00       	push   $0xff
  80036e:	8d 43 08             	lea    0x8(%ebx),%eax
  800371:	50                   	push   %eax
  800372:	e8 1f fd ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800377:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800380:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800392:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800399:	00 00 00 
	b.cnt = 0;
  80039c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a6:	ff 75 0c             	pushl  0xc(%ebp)
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	68 47 03 80 00       	push   $0x800347
  8003b8:	e8 54 01 00 00       	call   800511 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bd:	83 c4 08             	add    $0x8,%esp
  8003c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	e8 c4 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e3:	50                   	push   %eax
  8003e4:	ff 75 08             	pushl  0x8(%ebp)
  8003e7:	e8 9d ff ff ff       	call   800389 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 1c             	sub    $0x1c,%esp
  8003f7:	89 c7                	mov    %eax,%edi
  8003f9:	89 d6                	mov    %edx,%esi
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800407:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800412:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800415:	39 d3                	cmp    %edx,%ebx
  800417:	72 05                	jb     80041e <printnum+0x30>
  800419:	39 45 10             	cmp    %eax,0x10(%ebp)
  80041c:	77 45                	ja     800463 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041e:	83 ec 0c             	sub    $0xc,%esp
  800421:	ff 75 18             	pushl  0x18(%ebp)
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	ff 75 e4             	pushl  -0x1c(%ebp)
  800434:	ff 75 e0             	pushl  -0x20(%ebp)
  800437:	ff 75 dc             	pushl  -0x24(%ebp)
  80043a:	ff 75 d8             	pushl  -0x28(%ebp)
  80043d:	e8 6e 08 00 00       	call   800cb0 <__udivdi3>
  800442:	83 c4 18             	add    $0x18,%esp
  800445:	52                   	push   %edx
  800446:	50                   	push   %eax
  800447:	89 f2                	mov    %esi,%edx
  800449:	89 f8                	mov    %edi,%eax
  80044b:	e8 9e ff ff ff       	call   8003ee <printnum>
  800450:	83 c4 20             	add    $0x20,%esp
  800453:	eb 18                	jmp    80046d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	56                   	push   %esi
  800459:	ff 75 18             	pushl  0x18(%ebp)
  80045c:	ff d7                	call   *%edi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	eb 03                	jmp    800466 <printnum+0x78>
  800463:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800466:	83 eb 01             	sub    $0x1,%ebx
  800469:	85 db                	test   %ebx,%ebx
  80046b:	7f e8                	jg     800455 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	56                   	push   %esi
  800471:	83 ec 04             	sub    $0x4,%esp
  800474:	ff 75 e4             	pushl  -0x1c(%ebp)
  800477:	ff 75 e0             	pushl  -0x20(%ebp)
  80047a:	ff 75 dc             	pushl  -0x24(%ebp)
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	e8 5b 09 00 00       	call   800de0 <__umoddi3>
  800485:	83 c4 14             	add    $0x14,%esp
  800488:	0f be 80 9e 0f 80 00 	movsbl 0x800f9e(%eax),%eax
  80048f:	50                   	push   %eax
  800490:	ff d7                	call   *%edi
}
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800498:	5b                   	pop    %ebx
  800499:	5e                   	pop    %esi
  80049a:	5f                   	pop    %edi
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    

0080049d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a0:	83 fa 01             	cmp    $0x1,%edx
  8004a3:	7e 0e                	jle    8004b3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	8b 52 04             	mov    0x4(%edx),%edx
  8004b1:	eb 22                	jmp    8004d5 <getuint+0x38>
	else if (lflag)
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	74 10                	je     8004c7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bc:	89 08                	mov    %ecx,(%eax)
  8004be:	8b 02                	mov    (%edx),%eax
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	eb 0e                	jmp    8004d5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e6:	73 0a                	jae    8004f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004eb:	89 08                	mov    %ecx,(%eax)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	88 02                	mov    %al,(%edx)
}
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 10             	pushl  0x10(%ebp)
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	e8 05 00 00 00       	call   800511 <vprintfmt>
	va_end(ap);
}
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	57                   	push   %edi
  800515:	56                   	push   %esi
  800516:	53                   	push   %ebx
  800517:	83 ec 2c             	sub    $0x2c,%esp
  80051a:	8b 75 08             	mov    0x8(%ebp),%esi
  80051d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800520:	8b 7d 10             	mov    0x10(%ebp),%edi
  800523:	eb 12                	jmp    800537 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800525:	85 c0                	test   %eax,%eax
  800527:	0f 84 89 03 00 00    	je     8008b6 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	50                   	push   %eax
  800532:	ff d6                	call   *%esi
  800534:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800537:	83 c7 01             	add    $0x1,%edi
  80053a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053e:	83 f8 25             	cmp    $0x25,%eax
  800541:	75 e2                	jne    800525 <vprintfmt+0x14>
  800543:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800547:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80054e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800555:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80055c:	ba 00 00 00 00       	mov    $0x0,%edx
  800561:	eb 07                	jmp    80056a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800566:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8d 47 01             	lea    0x1(%edi),%eax
  80056d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800570:	0f b6 07             	movzbl (%edi),%eax
  800573:	0f b6 c8             	movzbl %al,%ecx
  800576:	83 e8 23             	sub    $0x23,%eax
  800579:	3c 55                	cmp    $0x55,%al
  80057b:	0f 87 1a 03 00 00    	ja     80089b <vprintfmt+0x38a>
  800581:	0f b6 c0             	movzbl %al,%eax
  800584:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80058e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800592:	eb d6                	jmp    80056a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005a6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ac:	83 fa 09             	cmp    $0x9,%edx
  8005af:	77 39                	ja     8005ea <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b4:	eb e9                	jmp    80059f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8005bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c7:	eb 27                	jmp    8005f0 <vprintfmt+0xdf>
  8005c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	0f 49 c8             	cmovns %eax,%ecx
  8005d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	eb 8c                	jmp    80056a <vprintfmt+0x59>
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e8:	eb 80                	jmp    80056a <vprintfmt+0x59>
  8005ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f4:	0f 89 70 ff ff ff    	jns    80056a <vprintfmt+0x59>
				width = precision, precision = -1;
  8005fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800600:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800607:	e9 5e ff ff ff       	jmp    80056a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80060c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800612:	e9 53 ff ff ff       	jmp    80056a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	ff 30                	pushl  (%eax)
  800626:	ff d6                	call   *%esi
			break;
  800628:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80062e:	e9 04 ff ff ff       	jmp    800537 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 04             	lea    0x4(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	99                   	cltd   
  80063f:	31 d0                	xor    %edx,%eax
  800641:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800643:	83 f8 08             	cmp    $0x8,%eax
  800646:	7f 0b                	jg     800653 <vprintfmt+0x142>
  800648:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80064f:	85 d2                	test   %edx,%edx
  800651:	75 18                	jne    80066b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800653:	50                   	push   %eax
  800654:	68 b6 0f 80 00       	push   $0x800fb6
  800659:	53                   	push   %ebx
  80065a:	56                   	push   %esi
  80065b:	e8 94 fe ff ff       	call   8004f4 <printfmt>
  800660:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800666:	e9 cc fe ff ff       	jmp    800537 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80066b:	52                   	push   %edx
  80066c:	68 bf 0f 80 00       	push   $0x800fbf
  800671:	53                   	push   %ebx
  800672:	56                   	push   %esi
  800673:	e8 7c fe ff ff       	call   8004f4 <printfmt>
  800678:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	e9 b4 fe ff ff       	jmp    800537 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80068e:	85 ff                	test   %edi,%edi
  800690:	b8 af 0f 80 00       	mov    $0x800faf,%eax
  800695:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800698:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069c:	0f 8e 94 00 00 00    	jle    800736 <vprintfmt+0x225>
  8006a2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a6:	0f 84 98 00 00 00    	je     800744 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	ff 75 d0             	pushl  -0x30(%ebp)
  8006b2:	57                   	push   %edi
  8006b3:	e8 86 02 00 00       	call   80093e <strnlen>
  8006b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006bb:	29 c1                	sub    %eax,%ecx
  8006bd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ca:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006cd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	eb 0f                	jmp    8006e0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 ff                	test   %edi,%edi
  8006e2:	7f ed                	jg     8006d1 <vprintfmt+0x1c0>
  8006e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006e7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f1:	0f 49 c1             	cmovns %ecx,%eax
  8006f4:	29 c1                	sub    %eax,%ecx
  8006f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ff:	89 cb                	mov    %ecx,%ebx
  800701:	eb 4d                	jmp    800750 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800703:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800707:	74 1b                	je     800724 <vprintfmt+0x213>
  800709:	0f be c0             	movsbl %al,%eax
  80070c:	83 e8 20             	sub    $0x20,%eax
  80070f:	83 f8 5e             	cmp    $0x5e,%eax
  800712:	76 10                	jbe    800724 <vprintfmt+0x213>
					putch('?', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	ff 75 0c             	pushl  0xc(%ebp)
  80071a:	6a 3f                	push   $0x3f
  80071c:	ff 55 08             	call   *0x8(%ebp)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 0d                	jmp    800731 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	52                   	push   %edx
  80072b:	ff 55 08             	call   *0x8(%ebp)
  80072e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800731:	83 eb 01             	sub    $0x1,%ebx
  800734:	eb 1a                	jmp    800750 <vprintfmt+0x23f>
  800736:	89 75 08             	mov    %esi,0x8(%ebp)
  800739:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80073c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800742:	eb 0c                	jmp    800750 <vprintfmt+0x23f>
  800744:	89 75 08             	mov    %esi,0x8(%ebp)
  800747:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800750:	83 c7 01             	add    $0x1,%edi
  800753:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800757:	0f be d0             	movsbl %al,%edx
  80075a:	85 d2                	test   %edx,%edx
  80075c:	74 23                	je     800781 <vprintfmt+0x270>
  80075e:	85 f6                	test   %esi,%esi
  800760:	78 a1                	js     800703 <vprintfmt+0x1f2>
  800762:	83 ee 01             	sub    $0x1,%esi
  800765:	79 9c                	jns    800703 <vprintfmt+0x1f2>
  800767:	89 df                	mov    %ebx,%edi
  800769:	8b 75 08             	mov    0x8(%ebp),%esi
  80076c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076f:	eb 18                	jmp    800789 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 20                	push   $0x20
  800777:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800779:	83 ef 01             	sub    $0x1,%edi
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 08                	jmp    800789 <vprintfmt+0x278>
  800781:	89 df                	mov    %ebx,%edi
  800783:	8b 75 08             	mov    0x8(%ebp),%esi
  800786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800789:	85 ff                	test   %edi,%edi
  80078b:	7f e4                	jg     800771 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800790:	e9 a2 fd ff ff       	jmp    800537 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800795:	83 fa 01             	cmp    $0x1,%edx
  800798:	7e 16                	jle    8007b0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 08             	lea    0x8(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a3:	8b 50 04             	mov    0x4(%eax),%edx
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ab:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007ae:	eb 32                	jmp    8007e2 <vprintfmt+0x2d1>
	else if (lflag)
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	74 18                	je     8007cc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bd:	8b 00                	mov    (%eax),%eax
  8007bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c2:	89 c1                	mov    %eax,%ecx
  8007c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ca:	eb 16                	jmp    8007e2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8d 50 04             	lea    0x4(%eax),%edx
  8007d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d5:	8b 00                	mov    (%eax),%eax
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	89 c1                	mov    %eax,%ecx
  8007dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8007df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e5:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007e8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007f1:	79 74                	jns    800867 <vprintfmt+0x356>
				putch('-', putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	53                   	push   %ebx
  8007f7:	6a 2d                	push   $0x2d
  8007f9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800801:	f7 d8                	neg    %eax
  800803:	83 d2 00             	adc    $0x0,%edx
  800806:	f7 da                	neg    %edx
  800808:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80080b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800810:	eb 55                	jmp    800867 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800812:	8d 45 14             	lea    0x14(%ebp),%eax
  800815:	e8 83 fc ff ff       	call   80049d <getuint>
			base = 10;
  80081a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80081f:	eb 46                	jmp    800867 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
  800821:	8d 45 14             	lea    0x14(%ebp),%eax
  800824:	e8 74 fc ff ff       	call   80049d <getuint>
			base = 8;
  800829:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80082e:	eb 37                	jmp    800867 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	53                   	push   %ebx
  800834:	6a 30                	push   $0x30
  800836:	ff d6                	call   *%esi
			putch('x', putdat);
  800838:	83 c4 08             	add    $0x8,%esp
  80083b:	53                   	push   %ebx
  80083c:	6a 78                	push   $0x78
  80083e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	8d 50 04             	lea    0x4(%eax),%edx
  800846:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800849:	8b 00                	mov    (%eax),%eax
  80084b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800850:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800853:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800858:	eb 0d                	jmp    800867 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80085a:	8d 45 14             	lea    0x14(%ebp),%eax
  80085d:	e8 3b fc ff ff       	call   80049d <getuint>
			base = 16;
  800862:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800867:	83 ec 0c             	sub    $0xc,%esp
  80086a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80086e:	57                   	push   %edi
  80086f:	ff 75 e0             	pushl  -0x20(%ebp)
  800872:	51                   	push   %ecx
  800873:	52                   	push   %edx
  800874:	50                   	push   %eax
  800875:	89 da                	mov    %ebx,%edx
  800877:	89 f0                	mov    %esi,%eax
  800879:	e8 70 fb ff ff       	call   8003ee <printnum>
			break;
  80087e:	83 c4 20             	add    $0x20,%esp
  800881:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800884:	e9 ae fc ff ff       	jmp    800537 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	51                   	push   %ecx
  80088e:	ff d6                	call   *%esi
			break;
  800890:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800893:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800896:	e9 9c fc ff ff       	jmp    800537 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	6a 25                	push   $0x25
  8008a1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 03                	jmp    8008ab <vprintfmt+0x39a>
  8008a8:	83 ef 01             	sub    $0x1,%edi
  8008ab:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008af:	75 f7                	jne    8008a8 <vprintfmt+0x397>
  8008b1:	e9 81 fc ff ff       	jmp    800537 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5f                   	pop    %edi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 18             	sub    $0x18,%esp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	74 26                	je     800905 <vsnprintf+0x47>
  8008df:	85 d2                	test   %edx,%edx
  8008e1:	7e 22                	jle    800905 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e3:	ff 75 14             	pushl  0x14(%ebp)
  8008e6:	ff 75 10             	pushl  0x10(%ebp)
  8008e9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ec:	50                   	push   %eax
  8008ed:	68 d7 04 80 00       	push   $0x8004d7
  8008f2:	e8 1a fc ff ff       	call   800511 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	eb 05                	jmp    80090a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800905:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800912:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800915:	50                   	push   %eax
  800916:	ff 75 10             	pushl  0x10(%ebp)
  800919:	ff 75 0c             	pushl  0xc(%ebp)
  80091c:	ff 75 08             	pushl  0x8(%ebp)
  80091f:	e8 9a ff ff ff       	call   8008be <vsnprintf>
	va_end(ap);

	return rc;
}
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092c:	b8 00 00 00 00       	mov    $0x0,%eax
  800931:	eb 03                	jmp    800936 <strlen+0x10>
		n++;
  800933:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093a:	75 f7                	jne    800933 <strlen+0xd>
		n++;
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800947:	ba 00 00 00 00       	mov    $0x0,%edx
  80094c:	eb 03                	jmp    800951 <strnlen+0x13>
		n++;
  80094e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800951:	39 c2                	cmp    %eax,%edx
  800953:	74 08                	je     80095d <strnlen+0x1f>
  800955:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800959:	75 f3                	jne    80094e <strnlen+0x10>
  80095b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	8b 45 08             	mov    0x8(%ebp),%eax
  800966:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800969:	89 c2                	mov    %eax,%edx
  80096b:	83 c2 01             	add    $0x1,%edx
  80096e:	83 c1 01             	add    $0x1,%ecx
  800971:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800975:	88 5a ff             	mov    %bl,-0x1(%edx)
  800978:	84 db                	test   %bl,%bl
  80097a:	75 ef                	jne    80096b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80097c:	5b                   	pop    %ebx
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	53                   	push   %ebx
  800983:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800986:	53                   	push   %ebx
  800987:	e8 9a ff ff ff       	call   800926 <strlen>
  80098c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80098f:	ff 75 0c             	pushl  0xc(%ebp)
  800992:	01 d8                	add    %ebx,%eax
  800994:	50                   	push   %eax
  800995:	e8 c5 ff ff ff       	call   80095f <strcpy>
	return dst;
}
  80099a:	89 d8                	mov    %ebx,%eax
  80099c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ac:	89 f3                	mov    %esi,%ebx
  8009ae:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	eb 0f                	jmp    8009c4 <strncpy+0x23>
		*dst++ = *src;
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	0f b6 01             	movzbl (%ecx),%eax
  8009bb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009be:	80 39 01             	cmpb   $0x1,(%ecx)
  8009c1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c4:	39 da                	cmp    %ebx,%edx
  8009c6:	75 ed                	jne    8009b5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c8:	89 f0                	mov    %esi,%eax
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009dc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	74 21                	je     800a03 <strlcpy+0x35>
  8009e2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009e6:	89 f2                	mov    %esi,%edx
  8009e8:	eb 09                	jmp    8009f3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009ea:	83 c2 01             	add    $0x1,%edx
  8009ed:	83 c1 01             	add    $0x1,%ecx
  8009f0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f3:	39 c2                	cmp    %eax,%edx
  8009f5:	74 09                	je     800a00 <strlcpy+0x32>
  8009f7:	0f b6 19             	movzbl (%ecx),%ebx
  8009fa:	84 db                	test   %bl,%bl
  8009fc:	75 ec                	jne    8009ea <strlcpy+0x1c>
  8009fe:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a00:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a03:	29 f0                	sub    %esi,%eax
}
  800a05:	5b                   	pop    %ebx
  800a06:	5e                   	pop    %esi
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a12:	eb 06                	jmp    800a1a <strcmp+0x11>
		p++, q++;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1a:	0f b6 01             	movzbl (%ecx),%eax
  800a1d:	84 c0                	test   %al,%al
  800a1f:	74 04                	je     800a25 <strcmp+0x1c>
  800a21:	3a 02                	cmp    (%edx),%al
  800a23:	74 ef                	je     800a14 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a25:	0f b6 c0             	movzbl %al,%eax
  800a28:	0f b6 12             	movzbl (%edx),%edx
  800a2b:	29 d0                	sub    %edx,%eax
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a39:	89 c3                	mov    %eax,%ebx
  800a3b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a3e:	eb 06                	jmp    800a46 <strncmp+0x17>
		n--, p++, q++;
  800a40:	83 c0 01             	add    $0x1,%eax
  800a43:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a46:	39 d8                	cmp    %ebx,%eax
  800a48:	74 15                	je     800a5f <strncmp+0x30>
  800a4a:	0f b6 08             	movzbl (%eax),%ecx
  800a4d:	84 c9                	test   %cl,%cl
  800a4f:	74 04                	je     800a55 <strncmp+0x26>
  800a51:	3a 0a                	cmp    (%edx),%cl
  800a53:	74 eb                	je     800a40 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a55:	0f b6 00             	movzbl (%eax),%eax
  800a58:	0f b6 12             	movzbl (%edx),%edx
  800a5b:	29 d0                	sub    %edx,%eax
  800a5d:	eb 05                	jmp    800a64 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a64:	5b                   	pop    %ebx
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a71:	eb 07                	jmp    800a7a <strchr+0x13>
		if (*s == c)
  800a73:	38 ca                	cmp    %cl,%dl
  800a75:	74 0f                	je     800a86 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a77:	83 c0 01             	add    $0x1,%eax
  800a7a:	0f b6 10             	movzbl (%eax),%edx
  800a7d:	84 d2                	test   %dl,%dl
  800a7f:	75 f2                	jne    800a73 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a81:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a92:	eb 03                	jmp    800a97 <strfind+0xf>
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a9a:	38 ca                	cmp    %cl,%dl
  800a9c:	74 04                	je     800aa2 <strfind+0x1a>
  800a9e:	84 d2                	test   %dl,%dl
  800aa0:	75 f2                	jne    800a94 <strfind+0xc>
			break;
	return (char *) s;
}
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	57                   	push   %edi
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab0:	85 c9                	test   %ecx,%ecx
  800ab2:	74 36                	je     800aea <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aba:	75 28                	jne    800ae4 <memset+0x40>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	75 23                	jne    800ae4 <memset+0x40>
		c &= 0xFF;
  800ac1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac5:	89 d3                	mov    %edx,%ebx
  800ac7:	c1 e3 08             	shl    $0x8,%ebx
  800aca:	89 d6                	mov    %edx,%esi
  800acc:	c1 e6 18             	shl    $0x18,%esi
  800acf:	89 d0                	mov    %edx,%eax
  800ad1:	c1 e0 10             	shl    $0x10,%eax
  800ad4:	09 f0                	or     %esi,%eax
  800ad6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ad8:	89 d8                	mov    %ebx,%eax
  800ada:	09 d0                	or     %edx,%eax
  800adc:	c1 e9 02             	shr    $0x2,%ecx
  800adf:	fc                   	cld    
  800ae0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae2:	eb 06                	jmp    800aea <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae7:	fc                   	cld    
  800ae8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aea:	89 f8                	mov    %edi,%eax
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	57                   	push   %edi
  800af5:	56                   	push   %esi
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aff:	39 c6                	cmp    %eax,%esi
  800b01:	73 35                	jae    800b38 <memmove+0x47>
  800b03:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b06:	39 d0                	cmp    %edx,%eax
  800b08:	73 2e                	jae    800b38 <memmove+0x47>
		s += n;
		d += n;
  800b0a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0d:	89 d6                	mov    %edx,%esi
  800b0f:	09 fe                	or     %edi,%esi
  800b11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b17:	75 13                	jne    800b2c <memmove+0x3b>
  800b19:	f6 c1 03             	test   $0x3,%cl
  800b1c:	75 0e                	jne    800b2c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b1e:	83 ef 04             	sub    $0x4,%edi
  800b21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b24:	c1 e9 02             	shr    $0x2,%ecx
  800b27:	fd                   	std    
  800b28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2a:	eb 09                	jmp    800b35 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b2c:	83 ef 01             	sub    $0x1,%edi
  800b2f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b32:	fd                   	std    
  800b33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b35:	fc                   	cld    
  800b36:	eb 1d                	jmp    800b55 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b38:	89 f2                	mov    %esi,%edx
  800b3a:	09 c2                	or     %eax,%edx
  800b3c:	f6 c2 03             	test   $0x3,%dl
  800b3f:	75 0f                	jne    800b50 <memmove+0x5f>
  800b41:	f6 c1 03             	test   $0x3,%cl
  800b44:	75 0a                	jne    800b50 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b46:	c1 e9 02             	shr    $0x2,%ecx
  800b49:	89 c7                	mov    %eax,%edi
  800b4b:	fc                   	cld    
  800b4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4e:	eb 05                	jmp    800b55 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b50:	89 c7                	mov    %eax,%edi
  800b52:	fc                   	cld    
  800b53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b5c:	ff 75 10             	pushl  0x10(%ebp)
  800b5f:	ff 75 0c             	pushl  0xc(%ebp)
  800b62:	ff 75 08             	pushl  0x8(%ebp)
  800b65:	e8 87 ff ff ff       	call   800af1 <memmove>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b77:	89 c6                	mov    %eax,%esi
  800b79:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7c:	eb 1a                	jmp    800b98 <memcmp+0x2c>
		if (*s1 != *s2)
  800b7e:	0f b6 08             	movzbl (%eax),%ecx
  800b81:	0f b6 1a             	movzbl (%edx),%ebx
  800b84:	38 d9                	cmp    %bl,%cl
  800b86:	74 0a                	je     800b92 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b88:	0f b6 c1             	movzbl %cl,%eax
  800b8b:	0f b6 db             	movzbl %bl,%ebx
  800b8e:	29 d8                	sub    %ebx,%eax
  800b90:	eb 0f                	jmp    800ba1 <memcmp+0x35>
		s1++, s2++;
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b98:	39 f0                	cmp    %esi,%eax
  800b9a:	75 e2                	jne    800b7e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	53                   	push   %ebx
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bac:	89 c1                	mov    %eax,%ecx
  800bae:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb5:	eb 0a                	jmp    800bc1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb7:	0f b6 10             	movzbl (%eax),%edx
  800bba:	39 da                	cmp    %ebx,%edx
  800bbc:	74 07                	je     800bc5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bbe:	83 c0 01             	add    $0x1,%eax
  800bc1:	39 c8                	cmp    %ecx,%eax
  800bc3:	72 f2                	jb     800bb7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd4:	eb 03                	jmp    800bd9 <strtol+0x11>
		s++;
  800bd6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd9:	0f b6 01             	movzbl (%ecx),%eax
  800bdc:	3c 20                	cmp    $0x20,%al
  800bde:	74 f6                	je     800bd6 <strtol+0xe>
  800be0:	3c 09                	cmp    $0x9,%al
  800be2:	74 f2                	je     800bd6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be4:	3c 2b                	cmp    $0x2b,%al
  800be6:	75 0a                	jne    800bf2 <strtol+0x2a>
		s++;
  800be8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800beb:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf0:	eb 11                	jmp    800c03 <strtol+0x3b>
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf7:	3c 2d                	cmp    $0x2d,%al
  800bf9:	75 08                	jne    800c03 <strtol+0x3b>
		s++, neg = 1;
  800bfb:	83 c1 01             	add    $0x1,%ecx
  800bfe:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c09:	75 15                	jne    800c20 <strtol+0x58>
  800c0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0e:	75 10                	jne    800c20 <strtol+0x58>
  800c10:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c14:	75 7c                	jne    800c92 <strtol+0xca>
		s += 2, base = 16;
  800c16:	83 c1 02             	add    $0x2,%ecx
  800c19:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c1e:	eb 16                	jmp    800c36 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c20:	85 db                	test   %ebx,%ebx
  800c22:	75 12                	jne    800c36 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c24:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c29:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2c:	75 08                	jne    800c36 <strtol+0x6e>
		s++, base = 8;
  800c2e:	83 c1 01             	add    $0x1,%ecx
  800c31:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c3e:	0f b6 11             	movzbl (%ecx),%edx
  800c41:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c44:	89 f3                	mov    %esi,%ebx
  800c46:	80 fb 09             	cmp    $0x9,%bl
  800c49:	77 08                	ja     800c53 <strtol+0x8b>
			dig = *s - '0';
  800c4b:	0f be d2             	movsbl %dl,%edx
  800c4e:	83 ea 30             	sub    $0x30,%edx
  800c51:	eb 22                	jmp    800c75 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c53:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c56:	89 f3                	mov    %esi,%ebx
  800c58:	80 fb 19             	cmp    $0x19,%bl
  800c5b:	77 08                	ja     800c65 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c5d:	0f be d2             	movsbl %dl,%edx
  800c60:	83 ea 57             	sub    $0x57,%edx
  800c63:	eb 10                	jmp    800c75 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c68:	89 f3                	mov    %esi,%ebx
  800c6a:	80 fb 19             	cmp    $0x19,%bl
  800c6d:	77 16                	ja     800c85 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c6f:	0f be d2             	movsbl %dl,%edx
  800c72:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c75:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c78:	7d 0b                	jge    800c85 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c7a:	83 c1 01             	add    $0x1,%ecx
  800c7d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c81:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c83:	eb b9                	jmp    800c3e <strtol+0x76>

	if (endptr)
  800c85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c89:	74 0d                	je     800c98 <strtol+0xd0>
		*endptr = (char *) s;
  800c8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8e:	89 0e                	mov    %ecx,(%esi)
  800c90:	eb 06                	jmp    800c98 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c92:	85 db                	test   %ebx,%ebx
  800c94:	74 98                	je     800c2e <strtol+0x66>
  800c96:	eb 9e                	jmp    800c36 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c98:	89 c2                	mov    %eax,%edx
  800c9a:	f7 da                	neg    %edx
  800c9c:	85 ff                	test   %edi,%edi
  800c9e:	0f 45 c2             	cmovne %edx,%eax
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    
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
