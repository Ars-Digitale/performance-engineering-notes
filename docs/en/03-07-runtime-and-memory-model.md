## 3.7 – Runtime and memory model

<a id="37-runtime-and-memory-model"></a>

This chapter explains how managed runtimes organize memory, allocate objects, reclaim unused memory, and behave under memory pressure.

It focuses on the runtime and memory mechanisms that directly affect latency, stability, and throughput under load.

Understanding these mechanisms is essential because many performance problems are not caused only by CPU or I/O limits, but by the way memory is allocated, retained, and reclaimed over time.

## Table of Contents

- [3.7.1 Memory structure (heap, stack)](#371-memory-structure-heap-stack)
- [3.7.2 Allocation and object lifecycle](#372-allocation-and-object-lifecycle)
- [3.7.3 Garbage collection (conceptual)](#373-garbage-collection-conceptual)
- [3.7.4 Memory pressure and performance](#374-memory-pressure-and-performance)

---

<a id="371-memory-structure-heap-stack"></a>
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

This distinction matters because performance behavior changes significantly depending on whether memory lifecycle is controlled directly by the programmer or indirectly by the runtime.

---

### Definition

Memory is organized into different regions with distinct roles.

The two most important areas for performance reasoning are:

- **heap**
- **stack**

These two regions support different aspects of program execution and have very different performance implications.

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

The heap is therefore not only a storage area, but a central part of runtime behavior under load.

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

Because the stack is private to the thread, access is simple and efficient, but the number of threads directly affects total stack memory usage.

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

It also explains why concurrency and memory behavior are tightly linked in managed systems.

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

These implications become especially important when the system is under sustained or high-concurrency load.

---

### Practical interpretation

Heap and stack are not just implementation details.

They affect:

- how data is shared
- how work is executed
- how memory grows under concurrency
- where runtime overhead appears

A system with many threads and frequent allocation will stress both regions differently: the stack through thread count and call depth, the heap through object creation and retention.

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

This is why runtime and memory model cannot be analyzed separately from concurrency and system behavior.

---

<a id="372-allocation-and-object-lifecycle"></a>
## 3.7.2 Allocation and object lifecycle

### Definition

In managed memory systems, objects are created dynamically and live for a certain period of time before being reclaimed.

The way objects are allocated and how long they live has a direct impact on performance.

Allocation behavior is therefore not only a memory concern, but also a latency and stability concern.

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

In high-throughput systems, allocation is often continuous and closely tied to workload intensity.

---

### Allocation rate

The **allocation rate** is the amount of memory allocated per unit of time.

It is a key performance factor.

High allocation rate means:

- more objects created
- increased memory churn
- increased pressure on the runtime

Even if individual allocations are fast, large volumes impact the system.

This is one of the reasons why “fast allocation” does not automatically mean “low memory overhead.”

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

It determines how much memory remains live over time and how the runtime must organize reclamation work.

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

Allocation patterns are often more informative than isolated allocation events, because the runtime reacts to aggregate behavior over time.

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

The important point is that memory cost is often indirect: the system pays not only for creating objects, but for managing the consequences of creating many of them.

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

A system that is stable at low load may therefore become memory-sensitive as request volume rises, even if the logic of each request remains unchanged.

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

This is one of the ways in which concurrency and memory behavior reinforce each other under load.

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

It also helps distinguish between problems caused by computation and problems caused by memory churn.

---

### Practical interpretation

Allocation is often invisible at the code level because it is easy to write and usually inexpensive per operation.

However, at the system level, repeated allocation changes the runtime’s workload.

A design that creates large numbers of temporary objects may work correctly, but still impose significant pressure on the memory subsystem.

---

### Link with next concepts

Allocation and object lifetime directly influence:

- garbage collection behavior (→ next section)
- memory pressure
- latency under load

They therefore form the causal basis for the runtime effects described in the rest of this chapter.

---

### Key idea

Performance depends on how much memory is allocated and how long it is retained.

Allocation patterns shape system behavior under load.

---

<a id="373-garbage-collection-conceptual"></a>
## 3.7.3 Garbage collection (conceptual)

### Definition

Garbage collection (GC) is the process by which a managed runtime reclaims memory that is no longer in use.

Instead of requiring explicit deallocation, the runtime:

- identifies unused objects
- frees their memory
- makes space available for new allocations

Garbage collection is one of the defining mechanisms of managed runtimes and one of the main ways memory behavior becomes visible in performance analysis.

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

This model allows memory to be managed automatically, but it also means that reclamation work must be performed during program execution.

---

### Allocation and reclamation cycle

Memory usage follows a cycle:

1. objects are allocated
2. objects become unused
3. garbage collection reclaims memory

This cycle repeats continuously during execution.

The runtime therefore alternates between allocating new memory and reclaiming old memory, with overall behavior driven by allocation rate and retention patterns.

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

This is why memory behavior should be analyzed as a pattern, not as an isolated operation.

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

This example illustrates the difference between temporary allocation churn and persistent retention.

### Cost of garbage collection

Garbage collection is not free.

It introduces overhead:

- CPU time to analyze memory
- pauses during collection (depending on strategy)

The cost depends on:

- allocation rate
- number of live objects
- memory size

In other words, GC cost depends not only on how much memory exists, but on how much memory is active, changing, and still reachable.

---

### Stop-the-world effect

Some garbage collection phases may pause application execution.

During these pauses:

- threads are temporarily stopped
- no application work is performed

Even short pauses can:

- increase latency
- affect tail response times (p95, p99)

This is one of the reasons GC issues often appear first in percentile-based latency analysis rather than in averages alone.

---

### Generational behavior (conceptual)

Most modern runtimes use a generational approach.

Based on observation:

- most objects are short-lived
- few objects live for a long time

Memory is organized so that:

- short-lived objects are collected frequently
- long-lived objects are collected less often

This improves efficiency because reclaiming many short-lived objects is usually cheaper than repeatedly scanning long-lived memory.

---

### Under load

As load increases:

- allocation rate increases
- garbage collection runs more frequently

This can lead to:

- higher CPU usage
- more frequent pauses
- increased latency variability

Under heavy load, GC may therefore shift from being a background maintenance mechanism to being a visible part of the system’s performance behavior.

---

### Interaction with object lifecycle

Garbage collection behavior depends on:

- how many objects are created
- how long they live

Typical patterns:

- many short-lived objects → frequent collections
- many long-lived objects → heavier collections

This is why allocation and retention must be analyzed together: object count alone is not enough.

---

### Observable effects

Garbage collection issues often appear as:

- latency spikes
- long-tail latency (p95/p99 degradation)
- periodic pauses
- increased CPU usage without clear cause

These symptoms are often intermittent, which makes GC-related problems difficult to diagnose without correlating memory and latency signals.

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

Tuning the collector may help, but it is usually more effective to first understand why the runtime is under pressure.

---

### Practical interpretation

Garbage collection is not a bug or an anomaly.

It is a necessary runtime mechanism.

The performance question is not whether GC exists, but whether its cost remains compatible with the workload and latency objectives of the system.

---

### Link with previous concepts

Garbage collection is directly linked to:

- allocation (→ [3.7.2 Allocation and object lifecycle](#372-allocation-and-object-lifecycle))
- memory structure (→ [3.7.1 Memory structure](#371-memory-structure-heap-stack))
- tail latency (→ [3.5.5 Tail latency amplification](03-05-system-behavior-under-load.md#355-tail-latency-amplification))

It is therefore both a runtime mechanism and a system-level contributor to performance variability.

---

### Key idea

Garbage collection enables automatic memory management but introduces variability.

Performance depends on how efficiently memory is reclaimed.

---

<a id="374-memory-pressure-and-performance"></a>
## 3.7.4 Memory pressure and performance

### Definition

Memory pressure refers to the stress placed on the memory system when allocation, retention, and reclamation interact under load.

It is not only about how much memory is used, but how memory behaves over time.

Memory pressure is therefore a dynamic condition, not simply a static measure of heap occupancy.

---

### What creates memory pressure

Memory pressure is driven by a combination of factors:

- high allocation rate
- large number of live objects
- long object lifetimes
- inefficient memory reclamation

These factors reinforce each other and determine how much work the runtime must perform to keep memory usable.

---

### Allocation vs retention

Two different patterns can create pressure:

- **high allocation rate**  
  many objects are created and quickly discarded

- **high retention**  
  objects remain in memory for long periods

These patterns create pressure in different ways.

High allocation increases churn and collection frequency.

High retention increases the amount of memory that remains live and must be scanned or preserved.

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

This example highlights pressure driven by churn rather than by long-term retention.

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

This example highlights pressure driven by retained memory rather than temporary allocation frequency alone.

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

This is why memory-related degradation often becomes more visible as the system moves from moderate load to sustained high load.

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

When this happens, the runtime is spending a significant share of its effort managing memory instead of processing application work.

---

### Observable symptoms

Memory pressure often appears as:

- latency spikes without clear CPU bottleneck
- long-tail latency degradation (p95, p99)
- periodic pauses
- increased GC frequency
- growing memory usage over time

These symptoms are especially important because they can be mistaken for generic slowness unless memory behavior is examined directly.

---

### Practical intuition

A system may appear:

- lightly loaded (moderate CPU)
- but still slow

This often indicates:

- memory pressure
- GC-related overhead

This is one of the main reasons why CPU alone is not sufficient to assess system health.

---

### Simplified model

System behavior can be approximated as:

- allocation rate ↑ → GC activity ↑  
- retention ↑ → memory usage ↑  
- GC activity ↑ → latency variability ↑  

These relationships are not linear.

They depend on runtime strategy, workload shape, object lifetimes, and the amount of live data.

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

In many cases, the most effective fix is not collector tuning, but reducing the memory work the runtime is forced to perform.

---

### Link with previous concepts

Memory pressure contributes to:

- non-linear degradation (→ [3.5.3 Non-linear degradation](03-05-system-behavior-under-load.md#353-non-linear-degradation))
- throughput collapse (→ [3.5.4 Throughput collapse](03-05-system-behavior-under-load.md#354-throughput-collapse))
- tail latency amplification (→ [3.5.5 Tail latency amplification](03-05-system-behavior-under-load.md#355-tail-latency-amplification))

It is therefore a direct bridge between runtime internals and visible system behavior under load.

---

### Practical interpretation

Memory pressure explains why a system may degrade even when it is not obviously CPU-bound or externally blocked.

A runtime under memory stress can still appear active, but produce increasing latency, reduced throughput, and unstable behavior.

This makes memory pressure one of the most important hidden causes of performance degradation in managed runtimes.

---

### Key idea

Memory pressure results from the interaction between allocation, retention, and garbage collection under load.

Understanding this interaction is essential to explain latency and stability issues in real systems.