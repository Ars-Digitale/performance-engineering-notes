## 3.7 – Runtime and memory model

## Table of Contents

- [3.7.1 Memory structure (heap, stack)](#371-memory-structure-heap-stack)
- [3.7.2 Allocation and object lifecycle](#372-allocation-and-object-lifecycle)
- [3.7.3 Garbage collection (conceptual)](#373-garbage-collection-conceptual)
- [3.7.4 Memory pressure and performance](#374-memory-pressure-and-performance)

---

## 3.7.1 Memory structure (heap, stack)

### Memory management models

Different systems use different memory management strategies.

Two common approaches are:

- **manual memory management**  
  Memory is explicitly allocated and freed by the programmer (e.g. C, C++)

- **managed memory**  
  Memory is allocated automatically and reclaimed by the runtime (e.g. Java, .NET)

This guide focuses on **managed memory systems**, where:

- objects are allocated dynamically
- memory is reclaimed automatically (garbage collection)

---

### Definition

Memory is organized into different regions with distinct roles.

The two most important areas for performance reasoning are:

- **heap**
- **stack**

---

### Heap

The heap is a shared memory area used for dynamic allocation.

In managed runtimes (such as Java):

- objects are allocated on the heap
- memory is managed by the runtime
- garbage collection reclaims unused objects

Implications:

- memory usage grows with allocation rate
- garbage collection impacts performance
- shared access may introduce contention

---

### Stack

Each thread has its own stack.

The stack stores:

- method calls (call frames)
- local variables
- intermediate values

Characteristics:

- private to each thread
- grows and shrinks during execution
- typically much smaller than the heap

---

### Heap vs stack

| Aspect            | Heap                         | Stack                        |
|------------------|------------------------------|------------------------------|
| Scope            | Shared across threads        | Private per thread           |
| Allocation       | Dynamic (objects)            | Automatic (method calls)     |
| Lifetime         | Managed by runtime           | Tied to method execution     |
| Performance      | More complex                 | Very fast                    |
| Memory impact    | Global                       | Per-thread                   |

---

### Interaction with threads

Each thread:

- has its own stack
- shares the heap

This creates a model where:

- execution is isolated per thread (stack)
- data is shared across threads (heap)

This interaction is a source of:

- contention (shared objects)
- coordination overhead

---

### Performance implications

Heap:

- excessive allocation → increased GC activity
- large heap → longer garbage collection cycles
- shared access → potential contention

Stack:

- many threads → higher total memory usage (one stack per thread)
- deep call chains → increased stack usage
- stack overflow → failure in extreme cases

---

### Key idea

The heap stores shared data.

The stack supports execution.

Performance depends on how these two interact under load.

---

### Link with previous concepts

Memory behavior directly impacts:

- thread execution (→ [3.6.2 Threads and execution model](03-06-concurrency-and-parallelism.md#362-threads-and-execution-model))
- contention (→ [3.6.3 Contention and synchronization](03-06-concurrency-and-parallelism.md#363-contention-and-synchronization))
- latency under load (→ [3.5 System behavior under load](03-05-system-behavior-under-load.md))

---

## 3.7.2 Allocation and object lifecycle

### Definition

In managed memory systems, objects are created dynamically and live for a certain period of time before being reclaimed.

The way objects are allocated and how long they live has a direct impact on performance.

---

### Allocation

Allocation is the process of creating new objects in memory.

In most managed runtimes:

- allocation happens on the heap
- it is designed to be fast and efficient
- it occurs very frequently in typical applications

Examples of allocation:

- creating request objects
- building data structures
- processing intermediate results

---

### Allocation rate

The **allocation rate** is the amount of memory allocated per unit of time.

It is a key performance factor.

High allocation rate means:

- more objects created
- increased memory churn
- increased pressure on the runtime

Even if individual allocations are fast, large volumes impact the system.

---

### Object lifecycle

Objects do not all live for the same duration.

Typical categories include:

- **short-lived objects**  
  created and discarded quickly (e.g. temporary request data)

- **medium-lived objects**  
  survive for some time during processing

- **long-lived objects**  
  remain in memory for extended periods (e.g. caches, shared state)

Understanding object lifetime is essential for reasoning about memory behavior.

---

### Allocation patterns

Real systems tend to exhibit patterns such as:

- many short-lived objects per request
- occasional long-lived objects
- bursts of allocation under load

These patterns determine:

- memory usage
- garbage collection behavior
- performance stability

---

### Impact on performance

Allocation itself is usually fast.

The main impact comes from:

- increased memory usage
- pressure on garbage collection

High allocation rate can lead to:

- more frequent garbage collection cycles
- increased latency
- unpredictable pauses

---

### Under load

As load increases:

- more requests are processed
- more objects are created
- allocation rate increases

This amplifies:

- memory pressure
- garbage collection activity
- latency variability

---

### Interaction with concurrency

Allocation is often performed by multiple threads.

This can lead to:

- contention on memory structures
- increased coordination overhead
- uneven memory usage patterns

In high-concurrency systems:

- allocation rate grows with concurrency
- memory becomes a shared bottleneck

---

### Practical implications

To reason about performance, it is important to consider:

- how many objects are created per request
- how long they live
- how allocation rate changes under load

Understanding allocation is essential to:

- explain latency behavior
- identify bottlenecks
- predict system limits

---

### Link with next concepts

Allocation and object lifetime directly influence:

- garbage collection behavior (→ next section)
- memory pressure
- latency under load

---

### Key idea

Performance depends on how much memory is allocated and how long it is retained.

Allocation patterns shape system behavior under load.

---

## 3.7.3 Garbage collection (conceptual)

### Definition

Garbage collection (GC) is the process by which a managed runtime reclaims memory that is no longer in use.

Instead of requiring explicit deallocation, the runtime:

- identifies unused objects
- frees their memory
- makes space available for new allocations

---

### Basic principle

An object is eligible for collection when it is no longer reachable.

This means:

- no active reference points to it
- it cannot be accessed by the program

The runtime periodically:

- scans object references
- identifies unreachable objects
- reclaims their memory

---

### Allocation and reclamation cycle

Memory usage follows a cycle:

1. objects are allocated
2. objects become unused
3. garbage collection reclaims memory

This cycle repeats continuously during execution.

---

### Java perspective (example)

In Java, object allocation is frequent and inexpensive.

For example:

```java
for (int i = 0; i < 1_000_000; i++) {
    String s = new String("test");
}
```

This code creates a large number of short-lived objects.

In a managed runtime:

- these objects are allocated quickly on the heap
- they become unreachable shortly after creation
- garbage collection reclaims them

If such allocation patterns occur under load:

- GC activity increases
- memory pressure grows
- latency may become unstable

The impact depends not on a single allocation, but on the **allocation rate over time**.

### Example: object retention

Objects that remain referenced are not collected.

```java
List<String> cache = new ArrayList<>();

while (true) {
    cache.add(new String("data"));
}
```

In this case:

- objects are continuously allocated
- they are never released
- memory usage grows over time

This leads to:

- increased memory pressure
- more expensive garbage collection
- potential system instability

### Cost of garbage collection

Garbage collection is not free.

It introduces overhead:

- CPU time to analyze memory
- pauses during collection (depending on strategy)

The cost depends on:

- allocation rate
- number of live objects
- memory size

---

### Stop-the-world effect

Some garbage collection phases may pause application execution.

During these pauses:

- threads are temporarily stopped
- no application work is performed

Even short pauses can:

- increase latency
- affect tail response times (p95, p99)

---

### Generational behavior (conceptual)

Most modern runtimes use a generational approach.

Based on observation:

- most objects are short-lived
- few objects live for a long time

Memory is organized so that:

- short-lived objects are collected frequently
- long-lived objects are collected less often

---

### Under load

As load increases:

- allocation rate increases
- garbage collection runs more frequently

This can lead to:

- higher CPU usage
- more frequent pauses
- increased latency variability

---

### Interaction with object lifecycle

Garbage collection behavior depends on:

- how many objects are created
- how long they live

Typical patterns:

- many short-lived objects → frequent collections
- many long-lived objects → heavier collections

---

### Observable effects

Garbage collection issues often appear as:

- latency spikes
- long-tail latency (p95/p99 degradation)
- periodic pauses
- increased CPU usage without clear cause

---

### Practical implications

Performance analysis must consider:

- allocation rate
- object lifetime distribution
- frequency and cost of GC cycles

Optimization typically focuses on:

- understanding allocation patterns
- reducing unnecessary object creation
- controlling memory pressure

---

### Link with previous concepts

Garbage collection is directly linked to:

- allocation (→ [3.7.2 Allocation and object lifecycle](#372-allocation-and-object-lifecycle))
- memory structure (→ [3.7.1 Memory structure](#371-memory-structure-heap-stack))
- tail latency (→ [3.5.5 Tail latency amplification](03-05-system-behavior-under-load.md#355-tail-latency-amplification))

---

### Key idea

Garbage collection enables automatic memory management but introduces variability.

Performance depends on how efficiently memory is reclaimed.

---

## 3.7.4 Memory pressure and performance

### Definition

Memory pressure refers to the stress placed on the memory system when allocation, retention, and reclamation interact under load.

It is not only about how much memory is used, but how memory behaves over time.

---

### What creates memory pressure

Memory pressure is driven by a combination of factors:

- high allocation rate
- large number of live objects
- long object lifetimes
- inefficient memory reclamation

---

### Allocation vs retention

Two different patterns can create pressure:

- **high allocation rate**  
  many objects are created and quickly discarded

- **high retention**  
  objects remain in memory for long periods

---

### Example: high allocation rate

```java
for (int i = 0; i < 1_000_000; i++) {
    String s = new String("test");
}
```

Characteristics:

- many short-lived objects
- frequent allocation
- frequent garbage collection

Effects:

- increased GC activity
- CPU overhead
- potential latency spikes

---

### Example: memory retention

```java
List<String> cache = new ArrayList<>();

while (true) {
    cache.add(new String("data"));
}
```

Characteristics:

- objects are retained
- memory usage continuously grows

Effects:

- increasing heap usage
- heavier garbage collection cycles
- eventual instability or failure

---

### Under load

As system load increases:

- more requests are processed
- more objects are created
- more objects are retained

This leads to:

- increased allocation rate
- increased memory usage
- increased GC activity

Memory pressure amplifies:

- latency variability
- tail latency

---

### Interaction with garbage collection

Garbage collection responds to memory pressure.

Under pressure:

- collections become more frequent
- pauses may increase
- CPU usage grows

In extreme cases:

- GC dominates execution
- useful work decreases

---

### Observable symptoms

Memory pressure often appears as:

- latency spikes without clear CPU bottleneck
- long-tail latency degradation (p95, p99)
- periodic pauses
- increased GC frequency
- growing memory usage over time

---

### Practical intuition

A system may appear:

- lightly loaded (moderate CPU)
- but still slow

This often indicates:

- memory pressure
- GC-related overhead

---

### Simplified model

System behavior can be approximated as:

- allocation rate ↑ → GC activity ↑  
- retention ↑ → memory usage ↑  
- GC activity ↑ → latency variability ↑  

These relationships are not linear.

---

### Practical implications

To manage memory pressure:

- understand allocation patterns
- identify long-lived objects
- monitor GC behavior
- correlate memory metrics with latency

Optimization should focus on:

- reducing unnecessary allocation
- controlling object lifetime
- avoiding unbounded retention

---

### Link with previous concepts

Memory pressure contributes to:

- non-linear degradation (→ [3.5.3 Non-linear degradation](03-05-system-behavior-under-load.md#353-non-linear-degradation))
- throughput collapse (→ [3.5.4 Throughput collapse](03-05-system-behavior-under-load.md#354-throughput-collapse))
- tail latency amplification (→ [3.5.5 Tail latency amplification](03-05-system-behavior-under-load.md#355-tail-latency-amplification))

---

### Key idea

Memory pressure results from the interaction between allocation, retention, and garbage collection under load.

Understanding this interaction is essential to explain latency and stability issues in real systems.
