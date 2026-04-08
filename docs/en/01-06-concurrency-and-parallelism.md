# 1.6 – Concurrency and parallelism

<a id="16-concurrency-and-parallelism"></a>

This chapter introduces concurrency and parallelism as core concepts in system performance engineering.

It explains how work is scheduled, how multiple tasks interact, and why coordination overhead, contention, and synchronization often become limiting factors under load.

Concurrency and parallelism are essential to scalability, but they also introduce complexity, overhead, and failure modes that directly affect latency, throughput, and system stability.

## Table of Contents

- [1.6.1 Concurrency vs parallelism](#161-concurrency-vs-parallelism)
- [1.6.2 Threads and execution model](#162-threads-and-execution-model)
- [1.6.3 Contention and synchronization](#163-contention-and-synchronization)
- [1.6.4 Common concurrency issues](#164-common-concurrency-issues)
	- [1.6.4.1 Race conditions](#1641-race-conditions)
	- [1.6.4.2 Deadlocks](#1642-deadlocks)
	- [1.6.4.3 Livelocks](#1643-livelocks)
	- [1.6.4.4 Starvation](#1644-starvation)
	- [1.6.4.5 Thread pool exhaustion](#1645-thread-pool-exhaustion)

---

<a id="161-concurrency-vs-parallelism"></a>
## 1.6.1 Concurrency vs parallelism

### Definition

**Concurrency** and **parallelism** are related but distinct concepts.

They are often confused, but they describe different aspects of system behavior.

Understanding the distinction is essential because a system may handle many tasks at once from a structural point of view without actually executing many tasks simultaneously at the hardware level.

---

### Concurrency

**Concurrency** refers to the ability of a system to handle multiple tasks during the same time interval.

These tasks:

- may not run at the exact same time
- can be interleaved
- share system resources

Concurrency is about:

- structure
- coordination
- managing multiple in-flight operations

It is therefore primarily concerned with how work is organized and scheduled.

---

### Parallelism

**Parallelism** refers to the execution of multiple tasks at the same time.

This requires:

- multiple processing units (e.g. CPU cores)
- true simultaneous execution

Parallelism is about:

- execution
- hardware utilization
- doing more work at the same instant

It is therefore primarily concerned with actual simultaneous progress.

---

### Key difference

- **Concurrency** = dealing with many tasks  
- **Parallelism** = executing many tasks simultaneously  

A system can be:

- concurrent but not parallel (single core, interleaving tasks)
- parallel but not highly concurrent (few long-running tasks)

This distinction matters because the scalability properties of a system depend not only on how much work exists, but also on how that work is coordinated and scheduled.

---

### Relationship with performance

Concurrency affects:

- how many requests can be in progress
- how resources are shared
- how contention arises

Parallelism affects:

- how fast work can be executed
- how well hardware is utilized

Both influence:

- throughput
- latency
- scalability

In practice, adding concurrency without sufficient parallelism may increase waiting and contention, while adding parallelism without good concurrency control may waste resources or expose coordination problems.

---

### Practical intuition

A concurrent system:

- can accept many requests
- may still process them sequentially or with limited parallelism

A parallel system:

- can process multiple requests at the same time
- but may still suffer from contention or coordination overhead

For this reason, concurrency and parallelism should not be treated as automatically beneficial.

Their value depends on how they interact with workload, shared resources, and execution constraints.

---

### Link with previous concepts

Concurrency increases:

- the number of in-flight requests (→ [1.2.1 Little’s Law](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency))

This leads to:

- resource sharing
- potential queueing (→ [1.5.2 Saturation and queueing](01-05-system-behavior-under-load.md#152-saturation-and-queueing))

This is one of the main reasons concurrency becomes a central topic in performance engineering rather than only a programming concern.

---

### Practical interpretation

Concurrency is often required to support many simultaneous operations, especially in networked and I/O-driven systems.

However, concurrency also increases the probability of:

- shared state interactions
- queue buildup
- lock contention
- coordination overhead

Parallelism may increase throughput, but only if useful work is actually being performed rather than blocked or serialized.

---

### Key idea

Concurrency determines how many tasks are active.

Parallelism determines how many tasks are executed at the same time.

Performance depends on both, and on how they interact with system resources.

---

<a id="162-threads-and-execution-model"></a>
## 1.6.2 Threads and execution model

### Definition

The **execution model** defines how work is executed within a system.

In most systems, work is performed by **threads**, which run within a **process**.

The execution model determines how requests are mapped to execution units, how waiting is handled, and how system resources are consumed under load.

---

### Processes and threads

A **process** is an isolated execution environment:

- it has its own memory space
- it contains resources (files, sockets, memory)

A **thread** is a unit of execution within a process:

- multiple threads share the same process memory
- threads execute tasks concurrently

In most applications:

- one process hosts multiple threads
- threads handle incoming requests

This shared-memory model makes threads efficient for communication, but also introduces shared-state complexity.

---

### Threads

A thread:

- executes instructions
- consumes CPU time
- may block while waiting (e.g. I/O, locks)

Multiple threads allow a system to:

- handle multiple requests
- overlap computation and waiting
- increase concurrency

However, threads are not free.

Each additional thread adds memory overhead, scheduling overhead, and coordination complexity.

---

### Thread lifecycle

A thread typically goes through several states:

- **running** (actively executing)
- **runnable** (ready to run, waiting for CPU)
- **waiting** / blocked (waiting for a resource or event)

Performance is affected by how threads move between these states.

A system with many runnable or blocked threads may appear active, but still make limited useful progress.

Understanding thread states is therefore essential when diagnosing concurrency issues.

---

### Stack and memory

Each thread has its own **stack**:

- stores method calls and local variables
- grows and shrinks during execution

Implications:

- more threads → more memory usage (one stack per thread)
- deep call chains → larger stack usage
- stack exhaustion can lead to failures

This is particularly relevant in high-concurrency systems.

Thread count therefore affects not only scheduling, but also memory footprint and stability.

---

### Execution models

Different systems use different **execution models**.

Common models include:

---

#### One thread per request

Each request is handled by a dedicated thread.

Characteristics:

- simple model
- easy to reason about
- blocking operations are straightforward

Limitations:

- high memory usage with many threads
- limited scalability under high concurrency

This model is conceptually simple, but it often performs poorly when concurrency becomes very large or when blocking is frequent.

---

#### Thread pool

A fixed number of threads handle incoming requests.

Requests are queued and assigned to available threads.

Characteristics:

- controlled concurrency
- reduced overhead compared to unbounded threads

Limitations:

- queueing when all threads are busy
- potential saturation of the pool

This model is widely used because it provides controlled resource usage, but it introduces an explicit queue and therefore a visible capacity limit.

---

#### Event-driven / asynchronous model

Work is handled using **non-blocking** operations and **event loops**.

Characteristics:

- few threads can handle many concurrent requests
- efficient for I/O-bound workloads

Limitations:

- more complex programming model
- requires careful handling of asynchronous flows

This model reduces the number of blocked threads, but it shifts complexity into coordination, callbacks, state handling, and non-blocking design.

---

### Java perspective (example)

In Java, a common execution model uses thread pools.

For example:

```java
ExecutorService executor = Executors.newFixedThreadPool(10);

executor.submit(() -> {
    // task logic
});
```

Requests are:

- submitted to a queue
- executed by a limited number of threads

If all threads are busy:

- tasks wait in the queue
- latency increases

For a detailed explanation of threads in Java, see:

→ https://ars-digitale.github.io/java-21-study-guide/en/module-07/threads/

This example is simple, but it highlights a key idea: bounded execution resources naturally introduce queueing when demand exceeds immediate processing capacity.

---

### Blocking vs non-blocking

Threads may:

- **block** (wait for I/O, locks, external resources)
- **remain active** (CPU-bound work)

Blocking reduces effective concurrency:

- threads are occupied but not progressing
- fewer threads are available for new work

Non-blocking approaches aim to:

- reduce idle waiting
- improve resource utilization

The distinction is important because high thread count does not necessarily mean high throughput.

If threads spend most of their time waiting, concurrency is present, but productive execution is limited.

---

### Practical implications

The execution model determines:

- how concurrency is handled
- how resources are used
- how queueing appears

Typical effects include:

- thread pool saturation → request queueing
- blocking operations → reduced throughput
- too many threads → context switching overhead

The execution model also determines where bottlenecks become visible: in queues, in pools, in blocked threads, or in event loops.

---

### Link with previous concepts

Thread behavior directly impacts:

- queueing (→ [1.5.2 Saturation and queueing](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- latency under load
- effective capacity of the system

It also influences how quickly a system moves from stable behavior to saturation when concurrency increases.

---

### Practical interpretation

Choosing an execution model is not only a programming decision.

It is a performance decision.

The model affects:

- memory consumption
- scheduling overhead
- latency under waiting conditions
- scalability under real workload

A design that is easy to implement may not be the design that behaves best under sustained load.

---

### Key idea

The execution model defines how work is scheduled and processed.

Threads are not free.

How they are used determines:

- how much work can be handled
- how efficiently resources are utilized
- how the system behaves under load

---

<a id="163-contention-and-synchronization"></a>
## 1.6.3 Contention and synchronization

### Definition

**Contention** occurs when multiple threads compete for the same resource.

**Synchronization** is the mechanism used to coordinate access to shared resources.

These concepts are central to understanding performance degradation in concurrent systems.

They connect correctness and performance: the same mechanisms that protect shared state can also become the source of waiting and reduced scalability.

---

### Shared resources

In concurrent systems, threads often share resources such as:

- memory structures (objects, caches)
- locks and monitors
- thread pools and queues
- database connections
- I/O channels

When access is not coordinated, data **corruption** may occur.

When access is coordinated, **contention** may appear.

This makes synchronization necessary, but not free.

---

### Synchronization

Synchronization ensures that shared resources are accessed safely.

Common mechanisms include:

- locks (mutexes, monitors)
- synchronized sections
- semaphores
- atomic operations

Synchronization guarantees correctness, but introduces overhead.

That overhead may come from:

- waiting
- serialization of execution
- additional memory barriers
- coordination costs between threads

---

### Contention

**Contention** arises when multiple threads attempt to access the same resource simultaneously.

When contention occurs:

- threads may block or wait
- execution is delayed
- throughput is reduced

The more threads compete:

- the higher the waiting time
- the lower the effective parallelism

A highly concurrent system can therefore behave like a partially serialized system if too much of its work depends on the same shared resources.

---

### Lock contention

A common form of contention involves locks.

When a thread holds a lock:

- other threads must wait
- a queue of waiting threads may form

Effects include:

- increased latency
- reduced throughput
- potential bottlenecks

Lock contention is especially problematic when critical sections are long, frequently accessed, or placed on hot execution paths.

---

### Contention vs utilization

High contention can occur even when CPU utilization is moderate.

For example:

- many threads are waiting on a lock
- CPU is partially idle
- system appears underutilized but is actually constrained

This is a common source of misleading diagnostics.

It explains why low or moderate CPU usage does not necessarily mean that the system has available capacity.

---

### Fine-grained vs coarse-grained synchronization

Synchronization can be:

- **coarse-grained** (few locks, large critical sections)
- **fine-grained** (many locks, smaller critical sections)

Trade-offs:

- **coarse-grained** → simpler but higher contention
- **fine-grained** → more scalable but more complex

Choosing between them depends on workload characteristics, access patterns, and the cost of added design complexity.

---

### Java perspective (example)

In Java, synchronization may be implemented using `synchronized` blocks:

```java
synchronized (lock) {
    // critical section
}
```

Or explicit locks:

```java
Lock lock = new ReentrantLock();

lock.lock();
try {
    // critical section
} finally {
    lock.unlock();
}
```

If many threads attempt to enter the same critical section:

- contention increases
- threads block
- performance degrades

This example highlights how a correctness mechanism can become a scalability constraint under load.

---

### Symptoms of contention

Typical indicators include:

- increasing response time under load
- low CPU utilization with high latency
- threads in blocked or waiting states
- long queues on shared resources

These symptoms often appear before total saturation and may be mistaken for other resource problems if not analyzed carefully.

---

### Practical implications

Contention limits scalability.

Even with:

- sufficient CPU
- adequate memory

A system may not scale if:

- threads spend time waiting instead of executing

Reducing contention often has a larger impact than optimizing individual operations.

This is especially true for systems where performance is constrained by shared access rather than by raw computation.

---

### Link with previous concepts

Contention contributes to:

- queueing (→ [1.5.2 Saturation and queueing](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- non-linear degradation (→ [1.5.3 Non-linear degradation](01-05-system-behavior-under-load.md#153-non-linear-degradation))
- throughput collapse (→ [1.5.4 Throughput collapse](01-05-system-behavior-under-load.md#154-throughput-collapse))

Contention is therefore both a local synchronization phenomenon and a system-level performance mechanism.

---

### Practical interpretation

Concurrency increases opportunities for useful overlap, but it also increases competition for shared resources.

The practical challenge is not simply to add more threads, but to ensure that additional concurrency results in useful work rather than additional waiting.

---

### Key idea

Concurrency introduces the need for synchronization.

Synchronization introduces contention.

Contention limits performance.

Understanding and controlling contention is essential for scalable systems.

---

<a id="164-common-concurrency-issues"></a>
## 1.6.4 Common concurrency issues

Concurrency introduces complexity.

When multiple threads interact, incorrect assumptions or poor coordination can lead to specific classes of problems.

These issues often appear under load and can severely impact performance and correctness.

Many of them are difficult to reproduce in light testing because they depend on timing, scheduling, or resource pressure.

---

<a id="1641-race-conditions"></a>
### 1.6.4.1 Race conditions

### Definition

A **race condition** occurs when multiple threads access shared data without proper synchronization, and the result depends on timing.

The outcome is therefore not deterministic and may vary from one execution to another.

---

### Example

Two threads update a shared counter:

- Thread A reads value = 10
- Thread B reads value = 10
- Thread A writes 11
- Thread B writes 11

Expected result: 12  
Actual result: 11

The final value depends on the order in which unsynchronized operations happen to execute.

---

### Impact

- incorrect results
- inconsistent system state
- difficult-to-reproduce bugs

Race conditions may also corrupt internal assumptions in ways that only appear later under load.

---

### Performance relevance

Race conditions may not always cause visible failures, but:

- they often require additional synchronization
- improper fixes can introduce contention

This is one reason correctness and performance cannot be treated as completely separate concerns in concurrent systems.

---

<a id="1642-deadlocks"></a>
### 1.6.4.2 Deadlocks

### Definition

A **deadlock** occurs when two or more threads wait indefinitely for each other.

Each thread holds a resource and waits for another resource held by another thread.

As a result, progress stops completely.

---

### Example

- Thread A holds lock L1 and waits for L2
- Thread B holds lock L2 and waits for L1

Neither can proceed.

This circular waiting pattern is the defining characteristic of deadlock.

---

### Impact

- system stalls
- requests never complete
- resources remain locked

Deadlocks are especially severe because they convert active resources into permanently blocked ones.

---

### Detection

- threads remain blocked
- thread dumps show circular waiting

Deadlocks are often detected through thread analysis rather than through general performance metrics alone.

---

<a id="1643-livelocks"></a>
## 1.6.4.3 Livelocks

### Definition

A **livelock** occurs when threads are not blocked but continuously change state in response to each other without making progress.

Unlike deadlock, activity continues, but useful work does not.

---

### Example

Two threads repeatedly retry an operation:

- both detect conflict
- both retry at the same time
- conflict persists

The system remains active, but the conflicting behavior continues indefinitely.

---

### Impact

- CPU is used
- no useful work is completed

Livelocks may therefore look like active processing even though progress is effectively zero.

---

<a id="1644-starvation"></a>
## 1.6.4.4 Starvation

### Definition

**Starvation** occurs when some threads are unable to obtain resources for a prolonged period.

Other threads continue to execute while some are effectively ignored.

This means the system is making progress, but not fairly or predictably for all work.

---

### Causes

- unfair scheduling
- high-priority threads dominating execution
- resource monopolization

Starvation is especially problematic when a subset of requests experiences extreme latency while the rest of the system appears functional.

---

### Impact

- some requests experience very high latency
- system appears partially functional
- tail latency increases

This makes starvation particularly relevant from both a performance and user-experience perspective.

---

<a id="1645-thread-pool-exhaustion"></a>
## 1.6.4.5 Thread pool exhaustion

### Definition

**Thread pool exhaustion** occurs when all threads in a pool are busy and incoming tasks must wait.

This is one of the most common concurrency-related bottlenecks in real systems.

---

### Causes

- blocking operations within threads
- insufficient pool size
- long-running tasks

These causes may exist independently or reinforce each other under increasing load.

---

### Effects

- request queue grows
- latency increases
- throughput may degrade

If saturation continues, thread pool exhaustion may also contribute to timeouts, retries, and instability in upstream components.

---

### Link with previous concepts

Thread pool exhaustion is a direct example of:

- saturation (→ [1.5.2 Saturation and queueing](01-05-system-behavior-under-load.md#152-saturation-and-queueing))
- non-linear degradation (→ [1.5.3 Non-linear degradation](01-05-system-behavior-under-load.md#153-non-linear-degradation))

It is therefore one of the clearest practical expressions of the system behaviors introduced in the previous chapter.

---

### Key idea

Concurrency issues are not only correctness problems.

They are also performance problems.

Many performance degradations are caused by:

- contention
- blocking
- coordination failures

Understanding these issues is essential for diagnosing real-world systems.