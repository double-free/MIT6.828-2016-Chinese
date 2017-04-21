// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/trap.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display backtrace info", mon_backtrace },
	{ "showmappings", "Display memory mappings", mon_showmappings },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	int x = 1, y = 3, z = 4;
	cprintf("x %d, y %x, z %d\n", x, y, z);
	unsigned int i = 0x00646c72;
	cprintf("H%x Wo%s\n", 57616, &i);
	uint32_t ebp, *ptr_ebp;
	struct Eipdebuginfo info;
	ebp = read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp != 0) {
		ptr_ebp = (uint32_t *)ebp;
		
		cprintf("\tebp %x  eip %x  args %08x %08x %08x %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3], ptr_ebp[4], ptr_ebp[5], ptr_ebp[6]);
		/* for the question of lab3 exercise 9
		cprintf("\tebp %x  eip %x  args %08x %08x\n", ebp, ptr_ebp[1], ptr_ebp[2], ptr_ebp[3]);
		*/
		if (debuginfo_eip(ptr_ebp[1], &info) == 0) {
			uint32_t fn_offset = ptr_ebp[1] - info.eip_fn_addr;
			cprintf("\t\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line,info.eip_fn_namelen,  info.eip_fn_name, fn_offset);
		}
		ebp = *ptr_ebp;
	}
	return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	// check args
	if (argc != 3) {
		cprintf("Requir 2 virtual address as arguments.\n");
		return -1;
	}
	char *errChar;
	uintptr_t start_addr = strtol(argv[1], &errChar, 16);
	if (*errChar) {
		cprintf("Invalid virtual address: %s.\n", argv[1]);
		return -1;
	}
	uintptr_t end_addr = strtol(argv[2], &errChar, 16);
	if (*errChar) {
		cprintf("Invalid virtual address: %s.\n", argv[2]);
		return -1;
	}
	if (start_addr > end_addr) {
		cprintf("Address 1 must be lower than address 2\n");
		return -1;
	}
	
	// 
	start_addr = ROUNDDOWN(start_addr, PGSIZE);
	end_addr = ROUNDUP(end_addr, PGSIZE);
	uintptr_t cur_addr = start_addr;
	while (cur_addr <= end_addr) {
		pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
		if ( !cur_pte || !(*cur_pte & PTE_P)) {
			cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
		} else {
			cprintf( "Virtual address [%08x] - physical address [%08x], permission: ", cur_addr, PTE_ADDR(*cur_pte));
			char perm_PS = (*cur_pte & PTE_PS) ? 'S':'-';
			char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
			char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
			cprintf( "-%c----%c%cP\n", perm_PS, perm_U, perm_W);
		}
		cur_addr += PGSIZE;
	}
	return 0;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
