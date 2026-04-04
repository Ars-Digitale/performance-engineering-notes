# 03 – Foundations

This section introduces the fundamental concepts required to reason about system performance.

It provides a conceptual model used throughout the guide.

## Table of Contents

- [3.1 Throughput, latency, concurrency](#31-throughput-latency-concurrency)
- [3.2 Service time vs response time](#32-service-time-vs-response-time)
- [3.3 Systems under load](#33-systems-under-load)
- [3.4 Saturation and bottlenecks](#34-saturation-and-bottlenecks)
- [3.5 Why systems slow down](#35-why-systems-slow-down)

---

## 3.1 Throughput, latency, concurrency

### Definition

These are the three primary dimensions used to describe system performance.

- **Throughput**: number of requests processed per unit of time (e.g. requests per second)
- **Latency**: time required to complete a request (response time)
- **Concurrency**: number of requests being processed at the same time

---

### Relationship

These quantities are not independent.

For a stable system:

- increasing throughput typically increases concurrency
- increasing concurrency tends to increase latency
- latency directly affects how many requests remain “in flight”

---

### Practical intuition

A system can be seen as a pipeline:

- requests enter
- they are processed
- they exit

At any moment:

- some requests are being processed (concurrency)
- new requests arrive (throughput)
- each request takes time (latency)

---

### Example

If a system processes:

- 100 requests per second
- each request takes 200 ms (0.2 s)

then, on average:

- about 20 requests are in flight at any given time

This relationship will be formalized later.

---

## 3.2 Service time vs response time

### Definition

At a resource level, response time is composed of two parts:

- **service time (S)**: time spent doing actual work
- **waiting time (Wq)**: time spent waiting before being processed

---

### Relationship

Response time:

- includes both execution and waiting
- grows when queues form

Even if service time remains constant:

- response time can increase significantly due to waiting

---

### Practical meaning

A slow system is often not slow because work is expensive, but because work is waiting.

As load increases:

- queues grow
- waiting dominates
- response time degrades

---

## 3.3 Systems under load

### Definition

A system under load processes a continuous stream of incoming requests.

Load is typically expressed as:

- requests per second
- concurrent users
- transactions per second

---

### Behavior

As load increases:

- resource utilization increases
- queues start to form
- latency increases
- throughput eventually stabilizes or degrades

---

### Key observation

Systems do not degrade linearly.

At low load:

- performance is stable

Near saturation:

- small increases in load can cause large increases in latency

---

## 3.4 Saturation and bottlenecks

### Saturation

A resource is saturated when it is busy most or all of the time.

Typical examples:

- CPU at 100%
- thread pool fully utilized
- connection pool exhausted

---

### Bottleneck

A bottleneck is the resource that limits system throughput.

Characteristics:

- highest utilization
- longest queues
- dominant contribution to response time

---

### Practical meaning

Improving non-bottleneck resources has little or no effect.

Performance improvements require:

- identifying the bottleneck
- reducing its demand or increasing its capacity

---

## 3.5 Why systems slow down

### Common mechanisms

Performance degradation is usually driven by a small number of mechanisms:

- queueing due to saturation
- contention on shared resources
- inefficient use of resources
- external dependencies becoming slow

---

### Queueing effect

As utilization approaches its limit:

- waiting time increases rapidly
- response time becomes dominated by queueing

This is the primary reason for long-tail latency.

---

### Amplification effects

Certain patterns amplify performance problems:

- retries increase load on already saturated systems
- timeouts lead to duplicated work
- cascading dependencies propagate delays

---

### Practical conclusion

Most performance problems are not caused by a single slow operation, but by:

- interactions between components
- accumulation of waiting time
- overload conditions

Understanding these mechanisms is essential before applying formulas or running tests.