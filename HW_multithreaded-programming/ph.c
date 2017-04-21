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
int nthread = 1;
volatile int done;

// 加入互斥锁
pthread_mutex_t lock;

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
	printf("arg = %ld\n", n);
	int b = NKEYS / nthread;
	int no_found_count = 0;
	double t0, t1;
	t0 = now();
	pthread_mutex_lock(&lock);
	for (int i = 0; i < b; i++) {
		put(keys[b*n + i], n);
	}
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

int main(int argc, char const *argv[]) {
	if (argc < 2) {
		printf("%s: %s nthread\n", argv[0], argv[0]);
		return -1;
	}
	nthread = atoi(argv[1]);
	// 分配好 threads 的空间，此后由 pthread_create 修改其内容为线程id
	pthread_t *threads = (pthread_t *)malloc(sizeof(pthread_t) * nthread);
	pthread_mutex_init(&lock, NULL);

	srandom(0);
	assert(NKEYS % nthread == 0);

	for (int i=0; i<NKEYS; i++) {
		keys[i] = random();
	}
	double t0 = now();

	// 用 long 是方便转为 void*， 都是 8 byte
	for (long i=0; i<nthread; i++) {
		// arg1 线程id，
		// arg2 线程属性
		// arg3 需要执行的函数 void * (*task) (void  *)
		// arg3 函数的参数
		// 将 i 转为 void* 类型，内容还是 i，表明是第几个线程
		assert(pthread_create(&threads[i], NULL, task, (void *)i) == 0);
	}
	void *value;
	for (int i=0; i<nthread; i++) {
		assert(pthread_join(threads[i], &value) == 0);
	}
	pthread_mutex_destroy(&lock);
	double t1 = now();
	printf("completion time = %.4f\n", t1-t0);
	return 0;
}
