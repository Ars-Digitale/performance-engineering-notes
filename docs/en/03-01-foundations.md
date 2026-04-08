# 3.1 – Foundations

<a id="31-foundations"></a>

This section introduces the fundamental concepts required to reason about system performance.

It provides a conceptual model used throughout the guide.

It defines the core principles used in performance engineering to analyze system behavior under load.

## Table of Contents

- [3.1.1 Throughput, latency, concurrency](#311-throughput-latency-concurrency)
- [3.1.2 Service time vs response time](#312-service-time-vs-response-time)
- [3.1.3 Systems under load](#313-systems-under-load)
- [3.1.4 Saturation and bottlenecks](#314-saturation-and-bottlenecks)
- [3.1.5 Why systems slow down](#315-why-systems-slow-down)

---

<a id="311-throughput-latency-concurrency"></a>
## 3.1.1 Throughput, latency, concurrency

### Definition

These are the three primary dimensions used to describe system performance.

- **Throughput**: number of requests processed per unit of time (e.g. requests per second)  
- **Latency**: time required to complete a request (response time)  
- **Concurrency**: number of requests being processed at the same time  

These concepts are fundamental to performance engineering and are used throughout the guide to describe system behavior.

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

- requests enter  
- they are processed  
- they exit  

At any moment:

- some requests are being processed (concurrency)  
- new requests arrive (throughput)  
- each request takes time to complete (latency)  

This mental model helps reason about flow, accumulation, and delays in real systems.

---

### Example

If a system processes:

- 100 requests per second  
- each request takes 200 ms (0.2 s)  

then, on average:

- about 20 requests are in flight at any given time  

This relationship is formalized by **Little’s Law**:

→ [3.2.1 Little’s Law](03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency)

---

### Practical interpretation

Throughput, latency, and concurrency form a closed system.

Changing one of them necessarily impacts the others.

For example:

- reducing latency reduces concurrency for the same throughput  
- increasing throughput increases concurrency if latency remains constant  
- high concurrency increases the probability of queueing and contention  

Understanding this relationship is essential for diagnosing performance issues.

---

<a id="312-service-time-vs-response-time"></a>
## 3.1.2 Service time vs response time

### Definition

At a resource level, response time is composed of two parts:

- **service time (S)**: time spent doing actual work  
- **waiting time (Wq)**: time spent waiting before being processed  

This distinction is fundamental in performance analysis.

---

### Relationship

Response time:

- includes both execution and waiting  
- increases when queues form  

Even if service time remains constant:

- response time can increase significantly due to waiting  

This is one of the main reasons systems degrade under load.

---

### Practical meaning

A slow system is often not slow because work is expensive, but because work is waiting.

As load increases:

- queues grow  
- waiting dominates  
- response time degrades  

This decomposition is formalized as:

→ [3.2.3 Service time vs response time](03-02-core-metrics-and-formulas.md#323-service-time-vs-response-time-queueing)

---

### Practical interpretation

Separating service time from response time allows:

- identifying whether the system is CPU-bound or queue-bound  
- distinguishing between processing cost and contention  
- understanding whether optimization should target execution or waiting  

In many real systems, latency issues are caused primarily by queueing rather than computation.

---

<a id="313-systems-under-load"></a>
## 3.1.3 Systems under load

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
- queues start to form  
- latency increases  
- throughput eventually stabilizes or degrades  

These effects are not linear and depend on system design and resource constraints.

---

### Key observation

Systems do not degrade linearly.

At low load:

- performance is stable  

Near saturation:

- small increases in load can cause large increases in latency  

This non-linear behavior is a key characteristic of real-world systems.

---

### Practical interpretation

Understanding system behavior under load is essential for:

- capacity planning  
- performance testing  
- diagnosing latency issues  

It explains why systems may appear stable in testing but fail under slightly higher production load.

---

<a id="314-saturation-and-bottlenecks"></a>
## 3.1.4 Saturation and bottlenecks

### Saturation

A resource is saturated when it is busy most or all of the time.

Typical examples:

- CPU at or near 100%  
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

Improving non-bottleneck resources has little or no effect.

Performance improvements require:

- identifying the bottleneck  
- reducing its demand or increasing its capacity  

This is a key principle in performance engineering.

---

### Practical interpretation

In complex systems:

- multiple resources may appear busy  
- but only one typically limits throughput at a given time  

Correctly identifying the bottleneck is essential to avoid ineffective optimizations.

---

<a id="315-why-systems-slow-down"></a>
## 3.1.5 Why systems slow down

### Common mechanisms

Performance degradation is usually driven by a small number of mechanisms:

- queueing due to saturation  
- contention on shared resources  
- inefficient use of resources  
- external dependencies becoming slow  

These mechanisms often interact and amplify each other.

---

### Queueing effect

As utilization approaches its limit:

- waiting time increases rapidly  
- response time becomes dominated by queueing  

This behavior is closely related to utilization and queueing effects:

→ [3.2.2 Utilization Law](03-02-core-metrics-and-formulas.md#322-utilization-law-resource-level-busy-time)

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

Understanding these interactions is essential for effective diagnosis.

---

### Practical conclusion

Most performance problems are not caused by a single slow operation, but by:

- interactions between components  
- accumulation of waiting time  
- overload conditions  

Understanding these mechanisms is essential before applying formulas or running tests.

---

### Key idea

System performance is determined by interactions between workload, resources, and concurrency.

Understanding these interactions is the foundation of performance engineering.