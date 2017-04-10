Homework: Shell
===
### 题目介绍
---

通过此次作业，将会了解到 Shell 的工作原理，以及类 Linux 系统的新进程到底是如何产生的。
首先自然是看懂 main 函数。
```
int
main(void)
{
    static char buf[100];
    int fd, r;
    
    // Read and run input commands.
    while(getcmd(buf, sizeof(buf)) >= 0){
        if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
            // 如果只是 cd 命令，则切换文件夹后继续等待命令
            // Clumsy but will have to do for now.
            // Chdir has no effect on the parent if run in the child.
            // 一般写完命令敲回车，这里就是把回车改为'\0'
            buf[strlen(buf)-1] = 0;  // chop \n
            if(chdir(buf+3) < 0)
            fprintf(stderr, "cannot cd %s\n", buf+3);
            continue;
        }
        // 若不是 cd 命令，则fork出子程序尝试运行命令
        if(fork1() == 0)
        runcmd(parsecmd(buf));
        // 等待子进程完成
        wait(&r);
    }
    exit(0);
}
```
循环调用 getcmd 函数读入命令：
```
int
getcmd(char *buf, int nbuf)
{
    
    if (isatty(fileno(stdin)))  // 判断标准输入是否为终端
    fprintf(stdout, "6.828$ ");  // 是终端则显示提示符
    memset(buf, 0, nbuf);
    fgets(buf, nbuf, stdin);  // 从标准输入读入nbuf个字符到 buf 中
    if(buf[0] == 0) // EOF
    return -1;
    return 0;
}
```
读入命令并确定不是 cd 命令后，执行关键语句
`runcmd(parsecmd(buf))`，显然是将 buf 用 parsecmd 解析后，送入 runcmd 运行。我们暂时并不关心如何解析，无非是一些字符串处理，提取关键符号确定类型。先看 runcmd 函数。
```
// Execute cmd.  Never returns.
void
runcmd(struct cmd *cmd)
{
    int p[2], r;
    struct execcmd *ecmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;
    
    if(cmd == 0)
    exit(0);
    
    switch(cmd->type){
        default:
        fprintf(stderr, "unknown runcmd\n");
        exit(-1);
        
        case ' ':
        ecmd = (struct execcmd*)cmd;
        if(ecmd->argv[0] == 0)
        exit(0);
        fprintf(stderr, "exec not implemented\n");
        // Your code here ...
        break;
        
        case '>':
        case '<':
        rcmd = (struct redircmd*)cmd;
        fprintf(stderr, "redir not implemented\n");
        // Your code here ...
        runcmd(rcmd->cmd);
        break;
        
        case '|':
        pcmd = (struct pipecmd*)cmd;
        fprintf(stderr, "pipe not implemented\n");
        // Your code here ...
        break;
    }    
    exit(0);
}
```
由此可看出，parsecmd 把命令分成了3个类型，分别是可执行命令，重定向命令，以及管道命令。

实现
---
#### 可执行命令

在文中找到关键提示：
>You may want to change the 6.828 shell to always try /bin, if the program doesn't exist in the current working directory, so that below you don't have to type "/bin" for each program. If you are ambitious you can implement support for a PATH variable.

也就是说对于 ls 这个存在的命令，我们只需要想办法将命令引导到 /bin/目录下寻找即可。这里涉及到 linux 系统调用的一个关键函数
```
int access(const char * pathname, int mode) 
```
它的作用是检查能否对某个文件(pathname)执行某个操作(mode)，操作的主要模式有：
```
R_OK      // 测试读许可权
W_OK      // 测试写许可权
X_OK      // 测试执行许可权
F_OK      // 测试文件是否存在
```
需要注意的是，测试成功返回值为0。失败为-1。有了这个函数，可以把之前的类型为`' '`的部分改为：
```
case ' ':
ecmd = (struct execcmd*)cmd;
if (ecmd->argv[0] == 0)
exit(0);
// fprintf(stderr, "exec not implemented\n");
if (access(ecmd->argv[0], F_OK) == 0) {
    execv(ecmd->argv[0], ecmd->argv);
} else {
    const char *binPath = "/bin/";
    int pathLen = strlen(binPath) + strlen(ecmd->argv[0]);
    char *abs_path = (char *)malloc((pathLen+1)*sizeof(char));
    strcpy(abs_path, binPath);
    strcat(abs_path, ecmd->argv[0]);
    if (access(abs_path, F_OK) == 0) {
        execv(abs_path, ecmd->argv);
    } else {
        fprintf(stderr, "%s: Command not found\n", ecmd->argv[0]);
    }
}
break;
```
需要补充说明的可能就是 execv 函数，它是 exec 函数族的一个，exec 函数族的作用就是根据 pathname 找到可执行文件，并用它取代调用进程的内容。虽然 pid 未改变，但是实际运行的内容已经不同。结合之前 main 函数中的内容，可以看出 Shell 执行某个命令实际上就是 fork 出一个子进程，然后把子进程替换为想要执行的程序。
测试结果为：
```
yy@yy-virtual-machine:~/OS/myShell$ ./myShell
6.828$ ls
myShell  sh.c  t.sh
6.828$ ls ../
lab  multi-thread  myLogs  MyMemo.txt  myShell	qemu  qemu_mit_2.3  xv6-public
6.828$ abc
abc: Command not found
6.828$
```
可以看出，满足了要求的所有功能。
#### 输入输出重定向
首先可能需要看一下配套的 xv6 教材第 10 页的文件系统，至少需要了解文件描述符 (file descriptor) 是什么。
刚开始写的时候还以为需要自己处理 '<' 和 '>' 情况，后来发现结构体 rcmd 中已经设置好，不需要分开处理。注意一下这个函数：
```
struct cmd*
redircmd(struct cmd *subcmd, char *file, int type)
{
    struct redircmd *cmd;
    
    cmd = malloc(sizeof(*cmd));
    memset(cmd, 0, sizeof(*cmd));
    cmd->type = type;
    cmd->cmd = subcmd;
    cmd->file = file;
    cmd->mode = (type == '<') ?  O_RDONLY : O_WRONLY|O_CREAT|O_TRUNC;
    cmd->fd = (type == '<') ? 0 : 1;
    return (struct cmd*)cmd;
}
```
看懂之后的工作就很简单了，结果代码为：
```
case '>':
case '<':
rcmd = (struct redircmd*)cmd;
// fprintf(stderr, "redir not implemented\n");
// Your code here ...
close(rcmd->fd);
if (open(rcmd->file, rcmd->mode, 0644) < 0) {
    fprintf(stderr, "Unable to open file: %s\n", rcmd->file);
    exit(0);
}
runcmd(rcmd->cmd);
break;
```
思路就是先关闭程序原先的标准输入/输出，打开指定文件作为新的标准输入/输出。
非常容易漏掉权限位，即open的第三个参数。注意这里用的是8进制数，所以一定不能直接写`644`而要写`0644`。
我还遇到了一个问题，在此记录一下，第一次权限设置不对，导致无法打开生成的文件，更改后运行，还是不行。后来发现其实由于只是 Truncate，没有把之前生成的文件删除新建，所以权限还是第一次有问题的版本。删掉之前的文件，重新运行，结果正常。
#### 管道

本次作业的最难的就是管道。重点还是参考 xv6 教材 13 页管道部分，在 xv6 源码的 Sheet 86 还能找到管道的实现。重点是搞明白 `pipe`，`dup` 两个函数。
- `int pipe(int p[])`
作用是建立一个缓冲区，并把缓冲区通过 fd 形式给程序调用。它将 p[0] 修改为缓冲区的读取端， p[1] 修改为缓冲区的写入端。
- `int dup(int old_fd)`
作用是产生一个fd，指向 old_fd 指向的文件，并返回这个fd。产生的 fd 总是空闲的最小 fd。

```
case '|':
pcmd = (struct pipecmd*)cmd;
// fprintf(stderr, "pipe not implemented\n");
// Your code here ...
if (pipe(p) < 0) fprintf(stderr,"pipe failed\n");
if (fork1() == 0) {
    // 先关闭标准输出再 dup
    // dup 会把标准输出定向到 p[1] 所指文件，即管道写入端
    close(1);
    dup(p[1]);
    // 去掉管道对端口的引用
    close(p[0]);
    close(p[1]);
    // 此时 left 的标准输入不变，标准输出流入管道
    runcmd(pcmd->left);
}
if (fork1() == 0) {
    // 先关闭标准输入再 dup
    // dup 会把标准输入定向到 p[0] 所指文件，即管道读取端
    close(0);
    dup(p[0]);
    // 去掉管道对端口的引用
    close(p[0]);
    close(p[1]);
    // 此时 right 的标准输入从管道读取，标准输出不变
    runcmd(pcmd->right);
}
close(p[0]);
close(p[1]);
wait(&r);
wait(&r);
break;
```
比较费解的就是 fork 了两次，也 wait 了两次。我自己写了一个实现，似乎也能正常运行，并且只 fork 了一次。
```
case '|':
pcmd = (struct pipecmd*)cmd;
// fprintf(stderr, "pipe not implemented\n");
// Your code here ...
if (pipe(p) < 0) fprintf(stderr,"pipe failed\n");
if (fork1() == 0) {
    close(1);
    dup(p[1]);
    close(p[0]);
    close(p[1]);
    runcmd(pcmd->left);
} else {
    close(0);
    dup(p[0]);
    close(p[0]);
    close(p[1]);
    runcmd(pcmd->right);
}
break;
```
最后，执行脚本判断：
```
yy@yy-virtual-machine:~/OS/myShell$ ./myShell < t.sh
sort: Command not found
wc: Command not found
uniq: Command not found
```
好的 ，又出现了问题。这几个命令都位于 `/usr/bin/`下，而我们在执行中只加入了 `/bin/` 目录，于是我又为`case ' '`添加了一个一劳永逸的实现，方便以后添加新的路径。
```

case ' ':
ecmd = (struct execcmd*)cmd;
if(ecmd->argv[0] == 0)
exit(0);
// fprintf(stderr, "exec not implemented\n");
if(access(ecmd->argv[0], F_OK) == 0) {
    execv(ecmd->argv[0], ecmd->argv);
} else {
    // 将路径改为数组实现
    const char *binPath[] = {"/bin/", "/usr/bin/"};
    char *abs_path;
    int bin_count = sizeof(binPath)/sizeof(binPath[0]);
    int found = 0;
    for (int i=0; i<bin_count && found==0; i++) {
        int pathLen = strlen(binPath[i]) + strlen(ecmd->argv[0]);
        abs_path = (char *)malloc((pathLen+1)*sizeof(char));
        strcpy(abs_path, binPath[i]);
        strcat(abs_path, ecmd->argv[0]);
        if(access(abs_path, F_OK) == 0) {
            execv(abs_path, ecmd->argv);
            found = 1;
        }
        free(abs_path);
    }
    if (found == 0) {
        fprintf(stderr, "%s: Command not found\n", ecmd->argv[0]);
    }
}

break;
```
运行成功，结果如下：
```
yy@yy-virtual-machine:~/OS/myShell$ ./myShell <t.sh 
4       4      20
4       4      20
```
