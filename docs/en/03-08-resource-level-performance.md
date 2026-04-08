## 3.8 – Resource-level performance

<a id="38-resource-level-performance"></a>

This chapter explains how core system resources behave under load and how they constrain performance.

It focuses on CPU, I/O, network behavior, and the way bottlenecks emerge when one resource becomes saturated before the others.

Understanding resource-level performance is essential because system degradation is often the visible result of resource limits rather than application logic alone.

## Table of Contents

- [3.8.1 CPU behavior](#381-cpu-behavior)
- [3.8.2 I/O and disk](#382-io-and-disk)
- [3.8.3 Network behavior](#383-network-behavior)
- [3.8.4 Resource saturation and bottlenecks](#384-resource-saturation-and-bottlenecks)

---

<a id="381-cpu-behavior"></a>
## 3.8.1 CPU behavior

### Definition

The **CPU** is responsible for executing instructions.

CPU performance is determined not only by how fast instructions are executed, but by how execution is scheduled across competing workloads.

This distinction is important because CPU-related degradation is often caused by scheduling pressure, queueing, and contention, not only by raw computational cost.

---

### CPU utilization vs saturation

**CPU utilization** represents how much of the CPU capacity is being used.

High utilization does not necessarily mean a problem.

**CPU saturation** occurs when:

- there is more work than the CPU can execute
- threads are ready to run but cannot be scheduled immediately

Key distinction:

- **high utilization** → CPU is busy  
- **saturation** → CPU is overloaded  

A system may therefore show high CPU usage and still behave acceptably, as long as runnable work does not accumulate faster than the CPU can process it.

---

### Scheduling and run queue

Threads do not execute continuously.

They are scheduled by the operating system.

At any moment:

- some threads are **running**
- some are **waiting** to run (run queue)

When the number of runnable threads exceeds available CPU cores:

- threads accumulate in the run queue
- scheduling delays increase

This directly impacts latency (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md)) and can be reasoned using concurrency relationships (→ [3.2.1 Little’s Law (system-level concurrency)](./03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency)).

The run queue is therefore a critical signal of CPU pressure, because it shows not just that the CPU is busy, but that work is waiting to be executed.

---

### Observable behavior (example)

A system under CPU pressure shows an increasing number of runnable threads.

```bash
$ vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 7  0      0  12000  45000 300000    0    0     2     1 1200 3000 90  8  2  0  0
 8  0      0  11000  45000 300000    0    0     1     2 1300 3200 92  6  2  0  0
```

Interpretation:

- run queue (`r`) is high → threads waiting for CPU  
- CPU idle (`id`) is close to zero → no available capacity  
- CPU usage (`us + sy`) is near saturation  

This indicates that threads are ready to execute but cannot be scheduled immediately (→ [3.6 Concurrency and parallelism](./03-06-concurrency-and-parallelism.md)).

The important point is that CPU saturation is not defined only by percentage values, but by the presence of runnable work that cannot make progress immediately.

---

### Impact on performance

When CPU becomes saturated:

- scheduling delays increase
- response time increases
- throughput may plateau or decrease

This effect is non-linear (→ [3.5.3 Non-linear degradation](./03-05-system-behavior-under-load.md#353-non-linear-degradation)).

As CPU saturation increases, the system may spend progressively more time waiting to be scheduled rather than performing useful work.

---

### Interaction with concurrency

Concurrency increases the number of active threads.

As concurrency grows:

- more threads compete for CPU
- run queue length increases
- scheduling overhead increases

Beyond a certain point:

- adding threads reduces performance instead of improving it (→ [3.6 Concurrency and parallelism](./03-06-concurrency-and-parallelism.md)).

This is why adding more concurrent work does not always produce better throughput.

If CPU time becomes the limiting resource, concurrency turns into scheduling pressure.

---

### Practical implications

To reason about CPU behavior:

- distinguish utilization from saturation
- observe runnable threads, not just %CPU
- correlate CPU metrics with latency (→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md))

CPU issues are often not about raw usage, but about **contention for execution**.

It is therefore possible for a system to appear “fully busy” without being unstable, or to appear only moderately busy while already showing scheduling delays.

---

### Practical interpretation

CPU analysis should focus on the ability of the system to keep up with runnable work.

A busy CPU is not automatically a problem.

A saturated CPU becomes a problem when runnable tasks accumulate, latency rises, and throughput no longer scales with incoming demand.

---

### Key idea

**CPU performance is limited by scheduling**.

When threads cannot be scheduled immediately, latency increases even if the system appears fully utilized.

---

<a id="382-io-and-disk"></a>
## 3.8.2 I/O and disk

### Definition

**I/O operations** involve reading from or writing to storage devices.

Unlike CPU operations, I/O is typically slower and often blocking.

This means that many performance problems involving I/O are dominated by waiting time rather than by active computation.

---

### Latency vs throughput

I/O performance has two key dimensions:

- **latency** → time to complete a single operation  
- **throughput** → number of operations per unit of time  

High throughput does not guarantee low latency.

A system may move a large amount of data overall while individual requests still experience significant wait times.

---

### Blocking behavior

Many I/O operations are blocking:

- a thread initiates an operation
- it waits until completion

During this time:

- the thread is not executing useful work
- it may hold resources (locks, connections)

This is one of the main reasons why I/O bottlenecks often propagate into thread pool pressure, queueing, and reduced effective concurrency.

---

### Queueing effects

When multiple requests perform I/O:

- operations queue at the device level
- waiting time increases

As queue length grows:

- latency increases
- variability increases (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))

This can be expressed as queueing delay (→ [3.2.3 Service time vs response time (queueing)](./03-02-core-metrics-and-formulas.md#323-service-time-vs-response-time-queueing)).

The important point is that the cost of I/O is not limited to the duration of the operation itself.

It also includes the time spent waiting for previous operations to complete.

---

### Observable behavior (example)

A system under I/O pressure shows increasing wait times.

```bash
$ iostat -x 1
Device            r/s     w/s   await   %util
sda              120     80     35.0    95.0
sda              130     90     42.0    98.0
```

Interpretation:

- high `await` → requests spend significant time waiting  
- `%util` near 100% → device is saturated  
- increasing latency indicates queue buildup  

This reflects queueing effects (→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md)).

The increasing `await` value is especially important, because it often reveals that the device is not merely busy, but increasingly unable to absorb incoming work without additional delay.

---

### Impact on performance

When I/O becomes a bottleneck:

- request latency increases
- throughput may degrade
- threads spend more time waiting than executing

This can reduce effective system capacity even when CPU usage remains moderate.

A system can therefore be I/O-bound without appearing CPU-bound.

---

### Interaction with concurrency

More concurrent requests lead to:

- more I/O operations
- longer device queues
- increased latency

Increasing concurrency does not improve performance if the device is saturated (→ [3.6 Concurrency and parallelism](./03-06-concurrency-and-parallelism.md)).

Beyond a certain point, additional concurrency only increases waiting and worsens response time.

---

### Practical implications

To reason about I/O behavior:

- focus on latency (`await`), not only throughput  
- identify queue buildup  
- correlate I/O wait with application latency (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))  

I/O problems are often misunderstood because throughput may remain acceptable while latency degrades significantly.

---

### Practical interpretation

I/O performance should be evaluated as a waiting system.

The core question is not only how many operations per second the device can support, but how long operations wait when the workload intensifies.

A storage subsystem that performs well at low concurrency may degrade sharply when requests begin to accumulate.

---

### Key idea

**I/O performance is dominated by waiting time**.

As queues grow, latency increases and system responsiveness degrades.

---

<a id="383-network-behavior"></a>
## 3.8.3 Network behavior

### Definition

**Network** performance is determined by the transfer of data between systems.

It depends on both latency and bandwidth.

In distributed systems, network behavior is often a major contributor to end-to-end response time, especially when requests traverse multiple services.

---

### Latency and round trips

Network communication often requires multiple exchanges.

Each exchange introduces:

- transmission delay
- propagation delay
- processing delay

Multiple round trips amplify total latency (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md)).

This is especially important in request chains where each service call depends on the response of the previous one.

Even small delays can accumulate significantly across multiple network hops.

---

### Bandwidth limitations

Bandwidth defines how much data can be transferred per unit of time.

When bandwidth is limited:

- large payloads take longer to transfer
- throughput becomes constrained

Bandwidth therefore matters most when the amount of transferred data becomes large enough to dominate communication time.

Latency, by contrast, matters even for small payloads when many round trips are required.

---

### Amplification under load

As load increases:

- more requests are sent over the network
- contention increases
- queues may form in buffers

This leads to:

- increased latency
- packet delays or retransmissions (→ [3.5.5 Tail latency amplification](./03-05-system-behavior-under-load.md#355-tail-latency-amplification))

Under load, network variability becomes especially important because occasional delays can affect only part of the traffic while still degrading overall user experience.

---

### Observable behavior (example)

A system under network pressure shows connection and queue buildup.

```bash
$ ss -s
Total: 1200
TCP:   900 (estab 850, timewait 30)

Transport Total     IP        IPv6
*         1200      -         -
RAW       0         0         0
UDP       50        40        10
TCP       870       800       70
```

Interpretation:

- large number of established connections → high concurrency  
- accumulation of connections may indicate slow processing or network delays  

A growing number of open connections may indicate that requests are not completing quickly enough, either because downstream services are slow or because the system is unable to process network work efficiently.

---

### Impact on performance

Network constraints lead to:

- increased response time
- higher variability
- cascading delays across services

In distributed architectures, these delays often propagate and amplify because one slow network interaction can delay many dependent operations.

---

### Interaction with system design

Distributed systems amplify network effects:

- multiple services introduce multiple network hops
- latency accumulates across calls (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))

A system with many service boundaries may therefore suffer from network-induced latency even when each individual call appears relatively inexpensive.

---

### Practical implications

To reason about network behavior:

- consider number of round trips  
- observe connection patterns  
- correlate network activity with latency  

It is also important to distinguish between:

- bandwidth-limited behavior
- latency-limited behavior
- dependency-induced delay

These are related but not identical problems.

---

### Practical interpretation

Network performance is not only about how fast bytes move.

It is also about how often systems communicate, how many dependencies are involved, and how delays in one component affect others.

In many service architectures, reducing unnecessary round trips can improve latency more effectively than simply increasing bandwidth.

---

### Key idea

**Network performance is driven by latency and communication patterns**.

Under load, small delays accumulate and significantly impact response time.

---

<a id="384-resource-saturation-and-bottlenecks"></a>
## 3.8.4 Resource saturation and bottlenecks

### Definition

A **bottleneck** is the resource that limits system performance.

Saturation occurs when that resource operates at or near its capacity.

This is the point where additional workload no longer translates into proportional useful throughput.

---

### Identifying the limiting resource

At any moment, system performance is constrained by one dominant resource:

- CPU
- I/O
- network
- memory (indirectly through GC → [3.7 Runtime and memory model](./03-07-runtime-and-memory-model.md))

Identifying this resource is essential.

Without identifying the actual limiting resource, optimization efforts often target symptoms rather than causes.

---

### Single bottleneck principle

Even in complex systems:

- performance is typically limited by one primary constraint

Improving non-limiting resources has little effect.

This principle is one of the reasons why performance engineering must remain system-oriented.

Many resources may appear active, but only one usually determines the current capacity limit.

---

### Cascading effects

When a resource becomes saturated:

- queues build up
- latency increases
- upstream components slow down

This can propagate through the system (→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md)).

A local bottleneck can therefore become a system-wide problem as delays spread to callers, workers, pools, and dependent services.

---

### Interaction between resources

Resources are not independent:

- slow I/O increases thread wait time → affects CPU scheduling (→ [3.8.1 CPU behavior](#381-cpu-behavior))  
- network delays increase request lifetime → increases memory usage (→ [3.7 Runtime and memory model](./03-07-runtime-and-memory-model.md))  
- CPU saturation delays processing → increases queue sizes (→ [3.2.1 Little’s Law (system-level concurrency)](./03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency))  

This interaction explains why bottlenecks often move or appear coupled under changing workload conditions.

The limiting factor may shift as one part of the system is improved or as workload composition changes.

---

### Observable patterns

Common signs of bottlenecks:

- CPU near saturation with high run queue  
- I/O latency increasing with high device utilization  
- network delays with growing connection counts  

These patterns are useful because they connect system-level symptoms with specific resource behaviors.

They help reduce diagnostic ambiguity.

---

### Impact on system behavior

When a bottleneck is reached:

- throughput stops increasing
- latency grows rapidly
- system becomes unstable under further load

This corresponds to:

- non-linear degradation (→ [3.5.3 Non-linear degradation](./03-05-system-behavior-under-load.md#353-non-linear-degradation))  
- throughput collapse (→ [3.5.4 Throughput collapse](./03-05-system-behavior-under-load.md#354-throughput-collapse))  

At this stage, additional demand often worsens the situation rather than increasing useful output.

---

### Practical implications

To analyze performance:

- identify the saturated resource  
- correlate resource metrics with latency  
- focus optimization on the limiting factor  

A correct diagnosis therefore depends on understanding not just which resources are busy, but which one is currently controlling system behavior.

---

### Practical interpretation

Bottleneck analysis is the bridge between observation and action.

The purpose is not merely to collect CPU, I/O, or network metrics, but to determine which resource is constraining useful work at the current operating point.

Once that resource is identified, optimization becomes meaningful.

---

### Key idea

**System performance is limited by its bottleneck**.

Understanding which resource is saturated is essential to explain and improve behavior under load.