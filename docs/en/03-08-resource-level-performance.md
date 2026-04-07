## 3.8 – Resource-level performance

## Table of Contents

- [3.8.1 CPU behavior](#381-cpu-behavior)
- [3.8.2 I/O and disk](#382-io-and-disk)
- [3.8.3 Network behavior](#383-network-behavior)
- [3.8.4 Resource saturation and bottlenecks](#384-resource-saturation-and-bottlenecks)

---

## 3.8.1 CPU behavior

### Definition

The **CPU** is responsible for executing instructions.

CPU performance is determined not only by how fast instructions are executed, but by how execution is scheduled across competing workloads.

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

This directly impacts latency (→ [3.5 System behavior under load](docs/en/03-05-system-behavior-under-load.md)) and can be reasoned using concurrency relationships (→ [3.2.1 Little’s Law (system-level concurrency)](docs/en/03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency)).

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

This indicates that threads are ready to execute but cannot be scheduled immediately (→ [3.6 Concurrency and parallelism](docs/en/03-06-concurrency-and-parallelism.md)).

---

### Impact on performance

When CPU becomes saturated:

- scheduling delays increase
- response time increases
- throughput may plateau or decrease

This effect is non-linear (→ [3.5.3 Non-linear degradation](docs/en/03-05-system-behavior-under-load.md#353-non-linear-degradation)).

---

### Interaction with concurrency

Concurrency increases the number of active threads.

As concurrency grows:

- more threads compete for CPU
- run queue length increases
- scheduling overhead increases

Beyond a certain point:

- adding threads reduces performance instead of improving it (→ [3.6 Concurrency and parallelism](docs/en/03-06-concurrency-and-parallelism.md)).

---

### Practical implications

To reason about CPU behavior:

- distinguish utilization from saturation
- observe runnable threads, not just %CPU
- correlate CPU metrics with latency (→ [3.2 Core metrics and formulas](docs/en/03-02-core-metrics-and-formulas.md))

CPU issues are often not about raw usage, but about **contention for execution**.

---

### Key idea

**CPU performance is limited by scheduling**.

When threads cannot be scheduled immediately, latency increases even if the system appears fully utilized.

---

## 3.8.2 I/O and disk

### Definition

**I/O operations** involve reading from or writing to storage devices.

Unlike CPU operations, I/O is typically slower and often blocking.

---

### Latency vs throughput

I/O performance has two key dimensions:

- **latency** → time to complete a single operation  
- **throughput** → number of operations per unit of time  

High throughput does not guarantee low latency.

---

### Blocking behavior

Many I/O operations are blocking:

- a thread initiates an operation
- it waits until completion

During this time:

- the thread is not executing useful work
- it may hold resources (locks, connections)

---

### Queueing effects

When multiple requests perform I/O:

- operations queue at the device level
- waiting time increases

As queue length grows:

- latency increases
- variability increases (→ [3.5 System behavior under load](docs/en/03-05-system-behavior-under-load.md))

This can be expressed as queueing delay (→ [3.2.3 Service time vs response time (queueing)](docs/en/03-02-core-metrics-and-formulas.md#323-service-time-vs-response-time-queueing)).

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

This reflects queueing effects (→ [3.2 Core metrics and formulas](docs/en/03-02-core-metrics-and-formulas.md)).

---

### Impact on performance

When I/O becomes a bottleneck:

- request latency increases
- throughput may degrade
- threads spend more time waiting than executing

---

### Interaction with concurrency

More concurrent requests lead to:

- more I/O operations
- longer device queues
- increased latency

Increasing concurrency does not improve performance if the device is saturated (→ [3.6 Concurrency and parallelism](docs/en/03-06-concurrency-and-parallelism.md)).

---

### Practical implications

To reason about I/O behavior:

- focus on latency (`await`), not only throughput  
- identify queue buildup  
- correlate I/O wait with application latency (→ [3.5 System behavior under load](docs/en/03-05-system-behavior-under-load.md))  

---

### Key idea

**I/O performance is dominated by waiting time**.

As queues grow, latency increases and system responsiveness degrades.

---

## 3.8.3 Network behavior

### Definition

**Network** performance is determined by the transfer of data between systems.

It depends on both latency and bandwidth.

---

### Latency and round trips

Network communication often requires multiple exchanges.

Each exchange introduces:

- transmission delay
- propagation delay
- processing delay

Multiple round trips amplify total latency (→ [3.5 System behavior under load](docs/en/03-05-system-behavior-under-load.md)).

---

### Bandwidth limitations

Bandwidth defines how much data can be transferred per unit of time.

When bandwidth is limited:

- large payloads take longer to transfer
- throughput becomes constrained

---

### Amplification under load

As load increases:

- more requests are sent over the network
- contention increases
- queues may form in buffers

This leads to:

- increased latency
- packet delays or retransmissions (→ [3.5.5 Tail latency amplification](docs/en/03-05-system-behavior-under-load.md#355-tail-latency-amplification))

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

---

### Impact on performance

Network constraints lead to:

- increased response time
- higher variability
- cascading delays across services

---

### Interaction with system design

Distributed systems amplify network effects:

- multiple services introduce multiple network hops
- latency accumulates across calls (→ [3.5 System behavior under load](docs/en/03-05-system-behavior-under-load.md))

---

### Practical implications

To reason about network behavior:

- consider number of round trips  
- observe connection patterns  
- correlate network activity with latency  

---

### Key idea

**Network performance is driven by latency and communication patterns**.

Under load, small delays accumulate and significantly impact response time.

---

## 3.8.4 Resource saturation and bottlenecks

### Definition

A **bottleneck** is the resource that limits system performance.

Saturation occurs when that resource operates at or near its capacity.

---

### Identifying the limiting resource

At any moment, system performance is constrained by one dominant resource:

- CPU
- I/O
- network
- memory (indirectly through GC → [3.7 Runtime and memory model](docs/en/03-07-runtime-and-memory-model.md))

Identifying this resource is essential.

---

### Single bottleneck principle

Even in complex systems:

- performance is typically limited by one primary constraint

Improving non-limiting resources has little effect.

---

### Cascading effects

When a resource becomes saturated:

- queues build up
- latency increases
- upstream components slow down

This can propagate through the system (→ [3.5 System behavior under load](docs/en/03-05-system-behavior-under-load.md)).

---

### Interaction between resources

Resources are not independent:

- slow I/O increases thread wait time → affects CPU scheduling (→ [3.8.1 CPU behavior](#381-cpu-behavior))  
- network delays increase request lifetime → increases memory usage (→ [3.7 Runtime and memory model](docs/en/03-07-runtime-and-memory-model.md))  
- CPU saturation delays processing → increases queue sizes (→ [3.2.1 Little’s Law (system-level concurrency)](docs/en/03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency))  

---

### Observable patterns

Common signs of bottlenecks:

- CPU near saturation with high run queue  
- I/O latency increasing with high device utilization  
- network delays with growing connection counts  

---

### Impact on system behavior

When a bottleneck is reached:

- throughput stops increasing
- latency grows rapidly
- system becomes unstable under further load

This corresponds to:

- non-linear degradation (→ [3.5.3 Non-linear degradation](docs/en/03-05-system-behavior-under-load.md#353-non-linear-degradation))  
- throughput collapse (→ [3.5.4 Throughput collapse](docs/en/03-05-system-behavior-under-load.md#354-throughput-collapse))  

---

### Practical implications

To analyze performance:

- identify the saturated resource  
- correlate resource metrics with latency  
- focus optimization on the limiting factor  

---

### Key idea

**System performance is limited by its bottleneck**.

Understanding which resource is saturated is essential to explain and improve behavior under load.
