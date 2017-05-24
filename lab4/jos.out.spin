+ ld obj/kern/kernel
+ mk obj/kern/kernel.img
6828 decimal is 15254 octal!
Physical memory: 131072K available, base = 640K, extended = 130432K
check_page_free_list() succeeded!
check_page_alloc() succeeded!
map region size = 8192, 2 pages
map region size = 4096, 1 pages
check_page() succeeded!
map region size = 262144, 64 pages
map region size = 126976, 31 pages
map region size = 268435456, 65536 pages
map region size = 32768, 8 pages
cpu 0: map 0xefff8000 to physical address 0x231000
map region size = 32768, 8 pages
cpu 1: map 0xeffe8000 to physical address 0x239000
map region size = 32768, 8 pages
cpu 2: map 0xeffd8000 to physical address 0x241000
map region size = 32768, 8 pages
cpu 3: map 0xeffc8000 to physical address 0x249000
map region size = 32768, 8 pages
cpu 4: map 0xeffb8000 to physical address 0x251000
map region size = 32768, 8 pages
cpu 5: map 0xeffa8000 to physical address 0x259000
map region size = 32768, 8 pages
cpu 6: map 0xeff98000 to physical address 0x261000
map region size = 32768, 8 pages
cpu 7: map 0xeff88000 to physical address 0x269000
check_kern_pgdir() succeeded!
check_page_free_list() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 2 CPU(s)
map region size = 4096, 1 pages
enabled interrupts: 1 2
SMP: CPU 1 starting
map region size = 4096, 1 pages
[00000000] new env 00001000
insert page at 00200000
insert page at 00201000
insert page at 00202000
insert page at 00203000
insert page at 00204000
insert page at 00800000
insert page at 00801000
insert page at 00802000
insert page at eebfd000
I am the parent.  Forking the child...
[00001000] new env 00001001
I am the parent.  Running the child...
I am the child.  Spinning...
I am the parent.  Killing the child...
[00001000] destroying 00001001
[00001000] exiting gracefully
[00001000] free env 00001000
[00001001] free env 00001001
No runnable environments in the system!
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
qemu: terminating on signal 15 from pid 25588
