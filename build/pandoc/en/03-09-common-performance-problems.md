## 3.9 – Common performance problems

<a id="39-common-performance-problems"></a>

This chapter describes common performance problems that appear in real systems under load.

These problems are not isolated categories. They often interact, reinforce each other, and become visible as latency growth, throughput loss, instability, or tail degradation.

The purpose of this chapter is to connect recurring symptoms to the underlying mechanisms already introduced in the previous chapters.

## Table of Contents

- [3.9.1 CPU-bound inefficiency](#391-cpu-bound-inefficiency)
- [3.9.2 Excessive allocation and memory churn](#392-excessive-allocation-and-memory-churn)
- [3.9.3 Contention and synchronization hot spots](#393-contention-and-synchronization-hot-spots)
- [3.9.4 Blocking and waiting bottlenecks](#394-blocking-and-waiting-bottlenecks)
- [3.9.5 Queue buildup and saturation effects](#395-queue-buildup-and-saturation-effects)
- [3.9.6 Dependency amplification and cascading latency](#396-dependency-amplification-and-cascading-latency)

---

## 3.9.1 CPU-bound inefficiency {#391-cpu-bound-inefficiency}

### Definition

A CPU-bound inefficiency occurs when the system spends excessive CPU time performing work that could be reduced, optimized, or avoided.

This does not necessarily mean that the system is CPU-saturated at all times.

It means that available CPU time is being consumed inefficiently, reducing the amount of useful work the system can perform before reaching saturation.

---

### Typical causes

- inefficient algorithms (e.g. unnecessary complexity)
- repeated computations
- lack of caching for expensive operations
- excessive data transformations

These causes are common because CPU inefficiency often emerges from code that is functionally correct but structurally wasteful.

In performance engineering, inefficiency matters most when it occurs in hot paths or highly repeated operations.

---

### Example

```java
public int countMatches(List<String> items, String target) {
    int count = 0;
    for (String s : items) {
        if (s.toLowerCase().equals(target.toLowerCase())) {
            count++;
        }
    }
    return count;
}
```

Interpretation:

- repeated `toLowerCase()` calls create unnecessary work
- CPU time increases with input size
- avoidable computation in hot paths

The problem is not only the cost of the loop itself, but the repeated transformation of values that could be normalized once instead of at every comparison.

---

### Mechanism

CPU-bound inefficiency wastes execution capacity.

More CPU time is consumed than necessary to produce the same result.

As the workload grows:

- CPU utilization rises earlier
- runnable work accumulates sooner
- useful throughput reaches its limit earlier

This transforms inefficient code into a system-level bottleneck when request volume increases.

---

### Impact under load

- increased CPU utilization
- reduced throughput
- earlier CPU saturation

This leads to scheduling delays (→ [3.8.1 CPU behavior](#chap-03-08-resource-level-performance)) and non-linear latency growth (→ [3.5.3 Non-linear degradation](#chap-03-05-system-behavior-under-load)).

In practical terms, the system reaches its CPU limit sooner than expected, leaving less headroom for bursts or concurrent traffic growth.

---

### Observable symptoms

Typical symptoms include:

- high CPU usage under moderate load
- rising latency with increasing request volume
- throughput flattening earlier than expected
- significant CPU time spent in repeated or avoidable operations

These symptoms often appear before total CPU saturation and may initially look like a generic scaling problem.

---

### Practical implications

- optimize hot paths
- avoid repeated work
- reduce algorithmic complexity

It is also important to identify which inefficiencies actually matter at system level.

An inefficient operation executed once may be irrelevant.

The same inefficiency executed millions of times becomes a bottleneck.

---

### Practical interpretation

CPU inefficiency is one of the most common reasons a system fails to scale despite apparently sufficient hardware.

The issue is not lack of CPU in absolute terms, but poor use of the CPU that is available.

Optimization is therefore most valuable when it increases the amount of useful work performed per unit of CPU time.

---

### Key idea

CPU inefficiency reduces the amount of useful work the system can perform before reaching saturation.

---

## 3.9.2 Excessive allocation and memory churn {#392-excessive-allocation-and-memory-churn}

### Definition

Excessive allocation occurs when the system creates a large number of short-lived objects, increasing memory churn and pressure on the runtime.

This is a common problem in managed runtimes, where allocation is easy and often inexpensive per operation, but expensive in aggregate when performed continuously under load.

---

### Example

```java
for (Order o : orders) {
    result.add(new ReportRow(o.getId(), o.getAmount(), o.getStatus()));
}
```

Interpretation:

- many objects are created per iteration
- objects are short-lived
- allocation rate increases

If this pattern appears in frequently executed code, total allocation volume can become significant even when each individual object is small.

---

### Mechanism

- high allocation rate increases memory churn
- garbage collection runs more frequently

(→ [3.7.2 Allocation and object lifecycle](#chap-03-07-runtime-and-memory-model))  
(→ [3.7.3 Garbage collection](#chap-03-07-runtime-and-memory-model))

The system therefore pays not only for creating objects, but for reclaiming them, tracking them, and managing the runtime effects of frequent memory turnover.

---

### Impact under load

- increased GC activity
- CPU overhead for memory management
- latency variability

This contributes to memory pressure (→ [3.7.4 Memory pressure and performance](#chap-03-07-runtime-and-memory-model)).

As load increases, allocation-related overhead often becomes more visible through pauses, jitter, and widening latency percentiles.

---

### Observable symptoms

Typical symptoms include:

- increased garbage collection frequency
- periodic latency spikes
- growing gap between average and tail latency
- moderate CPU usage with unstable response times
- memory behavior that degrades as throughput increases

These symptoms are especially common in systems that allocate heavily in request-processing paths.

---

### Practical implications

- reduce unnecessary object creation
- reuse objects when appropriate
- analyze allocation patterns

It is also important to distinguish between:

- necessary allocation
- avoidable allocation
- retained allocation that should have remained temporary

This distinction helps determine whether the issue is churn, retention, or both.

---

### Practical interpretation

Excessive allocation is often invisible in code review because the code remains simple and correct.

Its effect becomes visible only at runtime, when repeated object creation changes GC behavior and memory pressure.

A system may therefore appear logically efficient while still behaving poorly because it creates too much transient memory traffic.

---

### Key idea

Memory churn increases runtime overhead and introduces latency variability.

---

## 3.9.3 Contention and synchronization hot spots {#393-contention-and-synchronization-hot-spots}

### Definition

Contention occurs when multiple threads compete for the same resource, forcing serialized access.

A synchronization hot spot is a part of the system where this competition becomes concentrated and repeatedly delays execution.

These hot spots are especially damaging because they reduce effective parallelism exactly where concurrency is expected to help.

---

### Example

```java
public class Counter {
    private int value = 0;

    public synchronized void increment() {
        value++;
    }
}
```

Interpretation:

- access is serialized through synchronization
- only one thread progresses at a time
- throughput is limited by the critical section

The issue is not that synchronization exists, but that a frequently accessed shared path can become the limiting point for the whole system.

---

### Mechanism

- threads block while waiting for the lock
- contention increases with concurrency

(→ [3.6 Concurrency and parallelism](#chap-03-06-concurrency-and-parallelism))

As more threads compete for the same synchronized section:

- waiting time grows
- effective parallelism decreases
- more time is spent coordinating than progressing

This causes the system to behave as if its concurrency were lower than its thread count suggests.

---

### Impact under load

- increased waiting time
- reduced throughput
- latency increases

This leads to queueing effects (→ [3.5 System behavior under load](#chap-03-05-system-behavior-under-load)).

Under higher load, synchronization hot spots often become visible as latency growth without proportional CPU growth, because threads are waiting rather than computing.

---

### Observable symptoms

Typical symptoms include:

- rising latency with moderate CPU usage
- many threads blocked or waiting
- reduced scalability as concurrency increases
- throughput limited by a small critical section
- lock-heavy code paths appearing on hot execution paths

These symptoms are often misleading because the system may appear only partially utilized while already constrained.

---

### Practical implications

- minimize shared mutable state
- reduce critical section size
- use more scalable concurrency patterns

It is also important to identify whether the bottleneck is caused by:

- lock scope
- frequency of access
- long critical sections
- unnecessary synchronization

Different causes require different fixes.

---

### Practical interpretation

Contention problems are often misunderstood as generic slowness.

In reality, the core issue is serialization: many threads are present, but only a few are making useful progress.

Performance engineering therefore focuses not only on adding concurrency, but on making sure concurrency does not collapse into waiting.

---

### Key idea

**Contention converts parallel work into serialized execution**.

---

## 3.9.4 Blocking and waiting bottlenecks {#394-blocking-and-waiting-bottlenecks}

### Definition

Blocking occurs when a thread waits for an external operation to complete, preventing it from doing useful work.

This includes waiting for:

- I/O
- network responses
- locks
- external services
- other coordinated events

Blocking is often necessary, but it becomes a bottleneck when too many execution resources are occupied by waiting rather than progressing.

---

### Example

```java
public String fetchData() throws Exception {
    Thread.sleep(50); // simulate blocking call
    return "data";
}
```

Interpretation:

- thread is idle during wait
- resources remain allocated
- concurrency does not translate to throughput

The thread exists, but it is not advancing useful work during the blocked period.

---

### Mechanism

- threads spend time waiting instead of executing
- thread pools may become saturated

(→ [3.6 Concurrency and parallelism](#chap-03-06-concurrency-and-parallelism))

As more threads become blocked:

- fewer threads remain available for new work
- queueing appears at the execution model level
- latency grows even if the CPU is not fully used

This is why blocking bottlenecks often coexist with moderate CPU usage.

---

### Impact under load

- increased latency
- reduced throughput
- thread exhaustion

This amplifies queueing and saturation (→ [3.5 System behavior under load](#chap-03-05-system-behavior-under-load)).

Under sustained load, blocking behavior often creates a feedback loop where queued requests wait for threads that are themselves waiting on slow operations.

---

### Observable symptoms

Typical symptoms include:

- many threads in waiting or blocked states
- growing request queues
- moderate CPU with poor throughput
- rising latency during I/O-heavy or dependency-heavy operations
- thread pools that appear full without corresponding productive work

These symptoms are especially common in services that mix request concurrency with synchronous downstream calls.

---

### Practical implications

- reduce blocking operations
- use asynchronous or non-blocking patterns when appropriate
- size thread pools carefully

It is also useful to distinguish between:

- unavoidable blocking
- avoidable blocking
- blocking placed in high-frequency execution paths

That distinction helps identify where redesign is necessary.

---

### Practical interpretation

Blocking reduces effective concurrency.

A system may have many threads, but if a large share of them is waiting, the system behaves as if it had much less execution capacity than expected.

This is why blocking issues are often execution-model problems before they become raw resource problems.

---

### Key idea

Blocking reduces effective concurrency and limits system throughput.

---

## 3.9.5 Queue buildup and saturation effects {#395-queue-buildup-and-saturation-effects}

### Definition

Queue buildup occurs when incoming work exceeds processing capacity, causing requests to wait before being processed.

This is one of the most common and most important performance problems because queueing transforms moderate overload into rapidly increasing latency.

---

### Mechanism

- arrival rate exceeds service capacity
- queues grow over time

This can be described using Little’s Law (→ [3.2.1 Little’s Law (system-level concurrency)](#chap-03-02-core-metrics-and-formulas)).

As incoming demand continues while processing remains limited, waiting accumulates and response time begins to include increasingly large queue delay.

---

### Impact under load

- waiting time increases
- response time increases
- latency becomes unstable

This leads to non-linear degradation (→ [3.5.3 Non-linear degradation](#chap-03-05-system-behavior-under-load)) and throughput limits.

Once queueing becomes dominant, the system can deteriorate very quickly even if the original increase in load was relatively small.

---

### Observable symptoms

- growing queue lengths
- increasing response times
- stable or decreasing throughput

Other symptoms may include:

- bursts of timeout errors
- widening p95/p99 latency
- delayed recovery after temporary overload

These effects often indicate that the system is operating near or beyond effective capacity.

---

### Practical implications

- control concurrency
- increase capacity of the bottleneck resource
- reduce arrival rate if necessary

It is also important to determine where the queue is forming:

- thread pool
- connection pool
- device
- network buffer
- downstream service

The location of the queue often reveals the actual bottleneck.

---

### Practical interpretation

Queue buildup is not just an operational detail.

It is often the direct mechanism through which overload becomes visible to users.

A system may still be functioning, but once work begins to wait systematically, latency growth becomes inevitable.

---

### Key idea

**Queues grow when demand exceeds capacity, driving latency**.

---

## 3.9.6 Dependency amplification and cascading latency {#396-dependency-amplification-and-cascading-latency}

### Definition

Dependency amplification occurs when latency in one component propagates and increases latency across the system.

This problem is especially important in distributed systems, where a request often depends on multiple downstream calls before it can complete.

---

### Mechanism

- requests depend on multiple downstream services
- delays accumulate across calls
- slow components affect the entire system

Even when each individual delay is small, the total effect can become significant once multiple dependencies, retries, or serial call chains are involved.

---

### Example

```java
public Response process() {
    Data a = serviceA.call();
    Data b = serviceB.call();
    return combine(a, b);
}
```

Interpretation:

- total latency depends on multiple dependencies
- slowest dependency dominates response time

In real systems, this effect becomes stronger when requests depend on many services, remote databases, or chained synchronous operations.

---

### Impact under load

- latency amplification across services
- increased variability
- tail latency degradation

(→ [3.5.5 Tail latency amplification](#chap-03-05-system-behavior-under-load))

Under load, dependency amplification often becomes more severe because slow downstream systems retain upstream threads, requests, and queues for longer periods.

---

### Observable symptoms

Typical symptoms include:

- sudden latency increases without local CPU saturation
- degraded p95/p99 behavior caused by downstream variability
- request chains that become slower as one dependency slows down
- instability spreading from one service to another
- retries and timeouts increasing pressure across the system

These symptoms are often difficult to interpret without correlating behavior across multiple components.

---

### Practical implications

- minimize number of synchronous dependencies
- use timeouts and fallback strategies
- isolate slow components

It is also useful to identify:

- which dependency contributes most to end-to-end delay
- whether calls are serial or parallel
- whether retries worsen the problem
- whether slow components trigger upstream queueing

This turns a vague “distributed slowness” problem into a diagnosable system behavior.

---

### Practical interpretation

A system’s latency is not determined only by its own code.

It is often determined by the slowest dependency in the request path.

The more dependencies a system has, the more likely it is that variability in one place will become visible everywhere else.

---

### Key idea

**System latency is often determined by the slowest dependency**.
