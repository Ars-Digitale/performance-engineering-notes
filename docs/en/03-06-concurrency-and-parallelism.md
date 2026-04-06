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

- Concurrency = dealing with many tasks  
- Parallelism = executing many tasks simultaneously  

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