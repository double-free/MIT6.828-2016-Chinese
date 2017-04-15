### 题目介绍
---
https://pdos.csail.mit.edu/6.828/2016/homework/lock.html
比较有价值的一个作业。重点考察了两个知识：
- 哈希表的实现
- 多线程与互斥锁

题目已给出基本的框架，大意是多核处理器下，使用多线程对共享数据（哈希表）进行操作，会带来效率的提升，然而如果不加锁就会出现不正确的结果。所以需要你在适当地方使用互斥锁。

直接上代码吧。为了方便理解做了一些变量名的更改与注释。
```
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <pthread.h>
#include <sys/time.h>

#define NBUCKET 5
#define NKEYS 100000

/*
 * 实现了一个哈希表，对 NBUCKET 取余进行散列
 *
 */

struct entry {
	int key;
	int value;
	struct entry *next;
};

// table 中存放的是 5 个地址，链表头
struct entry *table[NBUCKET];
int keys[NKEYS];
// 线程数量默认为1
int nthread = 1;
// done 用于统计有多少个线程已经完成
volatile int done;

double now() {
	struct timeval tv;
	gettimeofday(&tv, 0);
	return tv.tv_sec + tv.tv_usec / 1000000.0;
}

static void print(void) {
	int i;
	struct entry *e;
	for (i=0; i<NBUCKET; i++) {
		printf("%d: ", i);
		for (e = table[i]; e != 0; e = e->next) {
			printf("%d ", e->key);
		}
		printf("\n");
	}
}

static void insert(int key, int val, struct entry **p, struct entry *n) {
	// 在链表头插入
	struct entry *e = (struct entry *)malloc(sizeof(struct entry));
	e->key = key;
	e->value = val;
	e->next = n;
	*p = e;
}

static void put(int key, int val) {
	int i = key % NBUCKET;
	insert(key, val, &table[i], table[i]);
}

static struct entry* get(int key) {
	struct entry *e = 0;
	for (e = table[key % NBUCKET]; e != 0; e = e->next) {
		if (e->key == key) break;
	}
	return e;
}

static void *task(void *xa){

	long n = (long) xa;
	int b = NKEYS / nthread;
	int no_found_count = 0;
	double t0, t1;
	t0 = now();
	// 第 n 个线程put [n*b, (n+1)*b) 范围内的 entry
	for (int i = 0; i < b; i++) {
		put(keys[b*n + i], n);
	}
	t1 = now();
	printf("thread %ld: put time = %f\n", n, t1-t0);
	
	// 等待所有线程完成 put 操作
	__sync_fetch_and_add(&done, 1);
	while (done < nthread);

	t0 = now();
	for (int i=0; i<NKEYS; i ++) {
		struct entry *e = get(keys[i]);
		if (e==0) no_found_count++;
	}
	t1 = now();
	printf("thread %ld: get time = %f\n", n, t1-t0);
  printf("thread %ld: %d keys missing\n", n, no_found_count);
	return NULL;
}

int main(int argc, char const *argv[]) {
	if (argc < 2) {
		printf("%s: %s nthread\n", argv[0], argv[0]);
		return -1;
	}
	nthread = atoi(argv[1]);
	// 分配好 threads 的空间，此后由 pthread_create 修改其内容为线程id
	pthread_t *threads = (pthread_t *)malloc(sizeof(pthread_t) * nthread);
	srandom(0);
	assert(NKEYS % nthread == 0);

	for (int i=0; i<NKEYS; i++) {
		keys[i] = random();
	}
	double t0 = now();
	for (int i=0; i<nthread; i++) {
		// arg0 线程id，
		// arg1 线程属性
		// arg2 需要执行的函数 void * (*task) (void  *)
		// arg3 函数的参数
		// 将 i 转为 void* 类型，内容还是 i，表明是第几个线程
		assert(pthread_create(&threads[i], NULL, task, (void *)i) == 0);
	}
	void *value;
	for (int i=0; i<nthread; i++) {
		// arg0 要回收的线程id
		// arg1 该线程的返回值
		// 会阻塞直到线程运行结束
		assert(pthread_join(threads[i], &value) == 0);
	}
	double t1 = now();
	printf("completion time = %.4f\n", t1-t0);
	return 0;
}
```
这个程序运行会出现问题，症状如下：
- 单线程
```
$ ./a.out 1
thread 0: put time = 0.004676
thread 0: get time = 11.021167
thread 0: 0 keys missing
completion time = 11.0260
```
- 多线程
```
$ ./a.out 2
thread 0: put time = 0.025475
thread 1: put time = 0.028295
thread 1: get time = 12.859959
thread 1: 15880 keys missing
thread 0: get time = 12.930442
thread 0: 15880 keys missing
completion time = 12.9592
```

显然，在几乎同样的时间里，多线程获得了效率提升（因为是多核cpu）。对整个哈希表查询了2轮，符合预期。然而，却出现了条目为空的情况。

### 分析
---

1. 哪些是共享数据？

个人认为，本题中的共享数据，包括全局变量，以及在堆上的数据。

2. 仅有写数据需要加锁，读数据并不需要。

在整个过程中，仅有 put 函数对全局变量做了更改。所以要加锁肯定加在 put 函数前。

3. 为什么会丢失 key？

关键的 insert 函数中，如果线程 A 执行到`e->next = n;`切换到线程B，线程B执行完成 insert 函数，返回线程 A 执行，则会出现连续改动两次链表头，相当于线程 B 的链表头直接被覆盖，造成丢失。
```
static void insert(int key, int val, struct entry **p, struct entry *n) {
	// 在链表头插入
	struct entry *e = (struct entry *)malloc(sizeof(struct entry));
	e->key = key;
	e->value = val;
	e->next = n;
	*p = e;
}
```

修改代码，加入全局变量：
```
pthread_mutex_t lock;
```
在 main 函数中初始化：
```
pthread_mutex_init(&lock, NULL);
```
将 task 函数修改为：
```
static void *task(void *xa){
	long n = (long) xa;
	int b = NKEYS / nthread;
	int no_found_count = 0;
	double t0, t1;
	t0 = now();
	// put 时加锁
	pthread_mutex_lock(&lock);
	for (int i = 0; i < b; i++) {
		put(keys[b*n + i], n);
	}
	// put 结束时解锁
	pthread_mutex_unlock(&lock);

	t1 = now();
	printf("thread %ld: put time = %f\n", n, t1-t0);

	__sync_fetch_and_add(&done, 1);
	while (done < nthread);

	t0 = now();
	for (int i=0; i<NKEYS; i ++) {
		struct entry *e = get(keys[i]);
		if (e==0) no_found_count++;
	}
	t1 = now();
	printf("thread %ld: get time = %f\n", n, t1-t0);
  printf("thread %ld: %d keys missing\n", n, no_found_count);
	return NULL;
}
```
现在单线程执行结果为：
```
$ ./a.out 1
thread 0: put time = 0.004574
thread 0: get time = 10.766191
thread 0: 0 keys missing
completion time = 10.7710
```
多线程执行结果为：
```
./a.out 2
thread 0: put time = 0.002329
thread 1: put time = 0.004662
thread 1: get time = 10.282535
thread 1: 0 keys missing
thread 0: get time = 10.282641
thread 0: 0 keys missing
completion time = 10.2877
```