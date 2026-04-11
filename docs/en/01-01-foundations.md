# 1.1 – Foundations

<a id="11-foundations"></a>

This section introduces the fundamental concepts required to reason about application and system performance.

It provides a conceptual model used throughout the guide.

It defines the core principles used in performance engineering for analyzing system behavior under load.

## Table of Contents

- [1.1.1 Throughput, latency, concurrency](#111-throughput-latency-concurrency)
- [1.1.2 Service time vs response time](#112-service-time-vs-response-time)
- [1.1.3 Systems under load](#113-systems-under-load)
- [1.1.4 Saturation and bottlenecks](#114-saturation-and-bottlenecks)
- [1.1.5 Why systems slow down](#115-why-systems-slow-down)

---

<a id="111-throughput-latency-concurrency"></a>
## 1.1.1 Throughput, latency, concurrency

### Definition

These are the three primary dimensions used to describe system performance.

- **Throughput**: Quantity of work performed per unit of time; number of requests processed per unit of time (e.g. requests per second)  
- **Latency**: time required to complete a request (response time)  
- **Concurrency**: number of requests being processed at the same time  

These concepts are fundamental in performance engineering and are used throughout the guide to describe system behavior.

---

### Relationship

These quantities are not independent.

For a stable system:

- increasing throughput typically increases concurrency  
- increasing concurrency tends to increase latency  
- latency directly affects how many requests remain “in flight”  

This relationship is central to understanding how systems behave under load.

---

### Practical intuition

A system can be viewed as a processing pipeline:

- **Input**: requests enter  
- **Execution**: they are processed  
- **Output**: they exit  

At any moment:

- some requests are being processed (concurrency)  
- new requests arrive (throughput)  
- each request takes time to complete (latency)  

This mental model helps reason about flow, accumulation, and delays in real systems.

---

### Example

If a system processes:

- `100` requests per second (100 Req./sec.)  
- each request takes `200 ms` (0.2 s)  

then, on average:

- about `20` requests are `in flight` at any given time  

This relationship is formalized by **Little’s Law**:

→ [1.2.1 Little’s Law](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)

---

### Practical interpretation

Throughput, latency, and concurrency form a closed system.

Changing one of them necessarily impacts the others.

For example:

- reducing latency reduces concurrency for the same throughput  
- increasing throughput increases concurrency if latency remains constant  
- high concurrency increases the probability of queueing and contention  

This is a key element in diagnosing performance issues.

---

<a id="112-service-time-vs-response-time"></a>
## 1.1.2 Service time vs response time

### Definition

At a resource level, response time is composed of two parts:

- **service time (S)**: time spent performing actual work  
- **waiting time (Wq)**: time spent waiting before being processed  

This distinction is fundamental in performance analysis.

---

### Relationship

Response time:

- includes both `execution` and `waiting`  
- it increases when queues form  

Even if service time remains constant:

- response time can increase significantly due to waiting  

This is one of the main reasons systems degrade under load.

---

### Practical meaning

A slow system is often not slow because the work itself is expensive, but because the work is waiting for available resources.

As load increases:

- queues grow  
- waiting dominates  
- response time degrades  

This decomposition is formalized as:

→ [1.2.3 Service time vs response time](01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)

---

### Practical interpretation

Separating `service time` from `response time` allows:

- identifying whether the system is CPU-bound or queue-bound  
- distinguishing processing cost from resource contention  
- understanding whether optimization should target execution or waiting  

In many real systems, latency issues are primarily caused by queueing rather than computation.

---

<a id="113-systems-under-load"></a>
## 1.1.3 Systems under load

### Definition

A system under load processes a continuous stream of incoming requests.

Load is typically expressed as:

- requests per second  
- concurrent users  
- transactions per second  

Load defines the operating conditions under which performance must be evaluated.

---

### Behavior

As load increases:

- resource utilization increases  
- queues begin to form  
- latency increases  
- throughput eventually stabilizes or degrades  

These effects are not linear and depend on system design and resource constraints.

---

### Key observation

Systems do not degrade linearly.

At low load:

- performance is stable  

Near saturation:

- small increases in load can cause significant increases in latency  

This non-linear behavior is a key characteristic of real-world systems.

---

### Practical interpretation

Understanding system behavior under load is essential for:

- capacity planning  
- performance testing  
- diagnosing latency issues  

It helps explain why systems may appear stable in testing but fail under slightly higher production load.

---

<a id="114-saturation-and-bottlenecks"></a>
## 1.1.4 Saturation and bottlenecks

### Saturation

A resource is saturated when it is busy most or all of the time.

Typical examples:

- CPU at 100% (or close to it...)  
- thread pool fully utilized  
- connection pool exhausted  

Saturation indicates that a resource cannot handle additional demand without degradation.

---

### Bottleneck

A bottleneck is the resource that limits system throughput.

Characteristics:

- highest utilization  
- longest queues  
- dominant contribution to response time  

The bottleneck determines the overall system capacity.

---

### Practical meaning

Improving resources that are not actual bottlenecks has little or no effect.

Performance improvements require:

- identifying the bottleneck  
- reducing its demand or increasing its capacity  

This is a key principle in performance engineering.

---

### Practical interpretation

In complex systems:

- multiple resources may appear limiting  
- but typically only one limits throughput at a given time  

Correctly identifying the bottleneck is essential to avoid ineffective optimizations.

---

<a id="115-why-systems-slow-down"></a>
## 1.1.5 Why systems slow down

### Common mechanisms

Performance degradation is usually driven by a limited number of factors:

- queueing due to saturation  
- contention on shared resources  
- inefficient use of resources  
- external dependencies becoming slow  

These mechanisms often interact and amplify each other.

---

### Queueing effect

As resource utilization approaches its limits:

- waiting time increases rapidly  
- response time becomes dominated by queueing  

This behavior is closely related to utilization and queueing effects:

→ [1.2.2 Utilization Law](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time)

---

### Amplification effects

Certain patterns amplify performance problems:

- retries increase load on already saturated systems  
- timeouts lead to duplicated work  
- cascading dependencies propagate delays  

These effects can transform moderate load into severe degradation.

---

### Practical interpretation

Performance degradation is rarely caused by a single factor.

Instead, it emerges from:

- interactions between components  
- accumulation of waiting time  
- feedback loops under load  

From this emerges the possibility of an effective diagnosis.

---

### Practical conclusion

Most performance problems are not caused by a single slow or problematic operation, but by:

- interactions between components  
- accumulation of waiting time  
- overload conditions  

Understanding these mechanisms is required before applying formulas or running tests.

---

### Key idea

System performance is determined by interactions between workload, resources, and concurrency.

Understanding these interactions constitutes the foundation of performance engineering.