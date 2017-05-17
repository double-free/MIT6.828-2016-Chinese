介绍
===
在 lab4 中我们将实现多个同时运行的用户进程之间的抢占式多任务处理。

在 part A 中，我们需要给 JOS 增加多处理器支持。实现轮询( round-robin, RR )调度，并增加基本的用户程序管理系统调用( 创建和销毁进程，分配和映射内存 )。

在 part B 中，我们需要实现一个与 Unix 类似的 `fork()`，允许一个用户进程创建自己的拷贝。

在 part C中，我们会添加对进程间通信 ( IPC ) 的支持，允许不同的用户进程相互通信和同步。还要增加对硬件时钟中断和抢占的支持。

由于本次 lab 内容较多，报告将分为 [part A](https://github.com/double-free/MIT6.828-2016-Chinese/blob/master/lab4/part_A.md), part B, part C 三个部分。