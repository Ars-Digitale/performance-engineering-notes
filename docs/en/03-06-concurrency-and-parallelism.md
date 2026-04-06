# 3.6 – Concurrency and parallelism

## Table of Contents

- [3.6.1 Concurrency vs parallelism](#361-concurrency-vs-parallelism)
- [3.6.2 Threads and execution model](#362-threads-and-execution-model)
- [3.6.3 Contention and synchronization](#363-contention-and-synchronization)
- [3.6.4 Common concurrency issues](#364-common-concurrency-issues)

---

## 3.6.1 Concurrency vs parallelism

### Definition

**Concurrency** and **parallelism** are related but distinct concepts.

They are often confused, but they describe different aspects of system behavior.

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

---

### Key difference

- **Concurrency** = dealing with many tasks  
- **Parallelism** = executing many tasks simultaneously  

A system can be:

- concurrent but not parallel (single core, interleaving tasks)
- parallel but not highly concurrent (few long-running tasks)

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

---

### Practical intuition

A concurrent system:

- can accept many requests
- may still process them sequentially or with limited parallelism

A parallel system:

- can process multiple requests at the same time
- but may still suffer from contention or coordination overhead

---

### Link with previous concepts

Concurrency increases:

- the number of in-flight requests (→ [3.2.1 Little’s Law](03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency))

This leads to:

- resource sharing
- potential queueing (→ [3.5.2 Saturation and queueing](03-05-system-behavior-under-load.md#352-saturation-and-queueing))

---

### Key idea

Concurrency determines how many tasks are active.

Parallelism determines how many tasks are executed at the same time.

Performance depends on both, and on how they interact with system resources.

---

## 3.6.2 Threads and execution model

### Definition

The **execution model** defines how work is executed within a system.

In most systems, work is performed by **threads**, which run within a **process**.

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

---

### Thread lifecycle

A thread typically goes through several states:

- **running** (actively executing)
- **runnable** (ready to run, waiting for CPU)
- **waiting** / blocked (waiting for a resource or event)

Performance is affected by how threads move between these states.

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

---

### Execution models

Different systems use different **execution models**.

Common models include:


#### One thread per request

Each request is handled by a dedicated thread.

Characteristics:

- simple model
- easy to reason about
- blocking operations are straightforward

Limitations:

- high memory usage with many threads
- limited scalability under high concurrency


#### Thread pool

A fixed number of threads handle incoming requests.

Requests are queued and assigned to available threads.

Characteristics:

- controlled concurrency
- reduced overhead compared to unbounded threads

Limitations:

- queueing when all threads are busy
- potential saturation of the pool


#### Event-driven / asynchronous model

Work is handled using **non-blocking** operations and **event loops**.

Characteristics:

- few threads can handle many concurrent requests
- efficient for I/O-bound workloads

Limitations:

- more complex programming model
- requires careful handling of asynchronous flows

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

---

### Link with previous concepts

Thread behavior directly impacts:

- queueing (→ [3.5.2 Saturation and queueing](03-05-system-behavior-under-load.md#352-saturation-and-queueing))
- latency under load
- effective capacity of the system

---

### Key idea

The execution model defines how work is scheduled and processed.

Threads are not free.

How they are used determines:

- how much work can be handled
- how efficiently resources are utilized
- how the system behaves under load