## 3.9 – Common performance problems

## Table of Contents

- [3.9.1 CPU-bound inefficiency](#391-cpu-bound-inefficiency)
- [3.9.2 Excessive allocation and memory churn](#392-excessive-allocation-and-memory-churn)
- [3.9.3 Contention and synchronization hot spots](#393-contention-and-synchronization-hot-spots)
- [3.9.4 Blocking and waiting bottlenecks](#394-blocking-and-waiting-bottlenecks)
- [3.9.5 Queue buildup and saturation effects](#395-queue-buildup-and-saturation-effects)
- [3.9.6 Dependency amplification and cascading latency](#396-dependency-amplification-and-cascading-latency)

---

## 3.9.1 CPU-bound inefficiency

### Definition

A CPU-bound inefficiency occurs when the system spends excessive CPU time performing work that could be reduced, optimized, or avoided.

---

### Typical causes

- inefficient algorithms (e.g. unnecessary complexity)
- repeated computations
- lack of caching for expensive operations
- excessive data transformations

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

---

### Impact under load

- increased CPU utilization
- reduced throughput
- earlier CPU saturation

This leads to scheduling delays (→ [3.8.1 CPU behavior](./03-08-resource-level-performance.md#381-cpu-behavior)) and non-linear latency growth (→ [3.5.3 Non-linear degradation](./03-05-system-behavior-under-load.md#353-non-linear-degradation)).

---

### Practical implications

- optimize hot paths
- avoid repeated work
- reduce algorithmic complexity

---

### Key idea

CPU inefficiency reduces the amount of useful work the system can perform before reaching saturation.

---

## 3.9.2 Excessive allocation and memory churn

### Definition

Excessive allocation occurs when the system creates a large number of short-lived objects, increasing memory churn and pressure on the runtime.

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

---

### Mechanism

- high allocation rate increases memory churn
- garbage collection runs more frequently

(→ [3.7.2 Allocation and object lifecycle](./03-07-runtime-and-memory-model.md#372-allocation-and-object-lifecycle))  
(→ [3.7.3 Garbage collection](./03-07-runtime-and-memory-model.md#373-garbage-collection-conceptual))

---

### Impact under load

- increased GC activity
- CPU overhead for memory management
- latency variability

This contributes to memory pressure (→ [3.7.4 Memory pressure and performance](./03-07-runtime-and-memory-model.md#374-memory-pressure-and-performance)).

---

### Practical implications

- reduce unnecessary object creation
- reuse objects when appropriate
- analyze allocation patterns

---

### Key idea

Memory churn increases runtime overhead and introduces latency variability.

---

## 3.9.3 Contention and synchronization hot spots

### Definition

Contention occurs when multiple threads compete for the same resource, forcing serialized access.

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

---

### Mechanism

- threads block while waiting for the lock
- contention increases with concurrency

(→ [3.6 Concurrency and parallelism](./03-06-concurrency-and-parallelism.md))

---

### Impact under load

- increased waiting time
- reduced throughput
- latency increases

This leads to queueing effects (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md)).

---

### Practical implications

- minimize shared mutable state
- reduce critical section size
- use more scalable concurrency patterns

---

### Key idea

**Contention converts parallel work into serialized execution**.

---

## 3.9.4 Blocking and waiting bottlenecks

### Definition

Blocking occurs when a thread waits for an external operation to complete, preventing it from doing useful work.

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

---

### Mechanism

- threads spend time waiting instead of executing
- thread pools may become saturated

(→ [3.6 Concurrency and parallelism](./03-06-concurrency-and-parallelism.md))

---

### Impact under load

- increased latency
- reduced throughput
- thread exhaustion

This amplifies queueing and saturation (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md)).

---

### Practical implications

- reduce blocking operations
- use asynchronous or non-blocking patterns when appropriate
- size thread pools carefully

---

### Key idea

Blocking reduces effective concurrency and limits system throughput.

---

## 3.9.5 Queue buildup and saturation effects

### Definition

Queue buildup occurs when incoming work exceeds processing capacity, causing requests to wait before being processed.

---

### Mechanism

- arrival rate exceeds service capacity
- queues grow over time

This can be described using Little’s Law (→ [3.2.1 Little’s Law (system-level concurrency)](./03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency)).

---

### Impact under load

- waiting time increases
- response time increases
- latency becomes unstable

This leads to non-linear degradation (→ [3.5.3 Non-linear degradation](./03-05-system-behavior-under-load.md#353-non-linear-degradation)) and throughput limits.

---

### Observable symptoms

- growing queue lengths
- increasing response times
- stable or decreasing throughput

---

### Practical implications

- control concurrency
- increase capacity of the bottleneck resource
- reduce arrival rate if necessary

---

### Key idea

**Queues grow when demand exceeds capacity, driving latency**.

---

## 3.9.6 Dependency amplification and cascading latency

### Definition

Dependency amplification occurs when latency in one component propagates and increases latency across the system.

---

### Mechanism

- requests depend on multiple downstream services
- delays accumulate across calls
- slow components affect the entire system

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

---

### Impact under load

- latency amplification across services
- increased variability
- tail latency degradation

(→ [3.5.5 Tail latency amplification](./03-05-system-behavior-under-load.md#355-tail-latency-amplification))

---

### Practical implications

- minimize number of synchronous dependencies
- use timeouts and fallback strategies
- isolate slow components

---

### Key idea

**System latency is often determined by the slowest dependency**.

