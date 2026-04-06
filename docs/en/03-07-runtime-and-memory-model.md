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

### Key idea

Heap and stack are not just memory areas.

They reflect how a system:

- allocates data
- executes code
- manages lifecycle

Understanding this model is essential before analyzing allocation, garbage collection, and memory-related performance issues.

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

### Interaction with threads

Each thread:

- has its own stack
- shares the heap

This creates a model where:

- execution is isolated per thread (stack)
- data is shared across threads (heap)

This interaction is a source of:

- contention (shared objects)
- memory pressure (allocation rate)
- coordination overhead

---

### Practical intuition

A system under load:

- creates and processes many objects (heap)
- uses many threads (multiple stacks)

Performance depends on:

- how efficiently memory is allocated
- how quickly it is reclaimed
- how threads interact with shared data

---

### Link with previous concepts

Memory behavior directly impacts:

- thread execution (→ [3.6.2 Threads and execution model](03-06-concurrency-and-parallelism.md#362-threads-and-execution-model))
- contention (→ [3.6.3 Contention and synchronization](03-06-concurrency-and-parallelism.md#363-contention-and-synchronization))
- latency under load (→ [3.5 System behavior under load](03-05-system-behavior-under-load.md))

---

### Key idea

The heap stores shared data.

The stack supports execution.

Performance depends on how these two interact under load.