# 3.5 – System behavior under load

## Table of Contents

- [3.5.1 Load vs capacity](#351-load-vs-capacity)
- [3.5.2 Saturation and queueing](#352-saturation-and-queueing)
- [3.5.3 Non-linear degradation](#353-non-linear-degradation)
- [3.5.4 Throughput collapse](#354-throughput-collapse)
- [3.5.5 Tail latency amplification](#355-tail-latency-amplification)

---

## 3.5.1 Load vs capacity

### Definition

A system operates under load, but it has a finite capacity.

- **Load**: the amount of work applied to the system (e.g. requests per second, concurrent users)
- **Capacity**: the maximum amount of work the system can handle while remaining stable

Understanding the relationship between load and capacity is fundamental to performance engineering.

---

### System behavior

At low load:

- resources are underutilized
- response time is stable
- throughput increases linearly with load

As load increases:

- resource utilization grows
- contention begins to appear
- response time increases

When load approaches capacity:

- queues form
- latency increases rapidly
- system behavior becomes less predictable

---

### Capacity is not a fixed number

Capacity is often misunderstood as a single value.

In reality, it depends on:

- workload composition (use cases and distribution)
- resource configuration (CPU, memory, pools)
- system state (cold vs warm, cache effects)
- external dependencies (databases, services)

A system may handle:

- 100 req/s for simple requests
- but only 20 req/s for complex ones

---

### Effective capacity

Capacity must be defined under constraints.

Typical criteria:

- latency within acceptable limits (e.g. p95)
- error rate below threshold
- stable resource usage

The maximum load that satisfies these conditions is the **effective capacity**.

---

### Practical implication

Capacity cannot be assumed.

It must be:

- measured under realistic workload
- validated through testing
- monitored over time

Increasing load beyond effective capacity leads to:

- rapid degradation
- unstable behavior
- potential system failure

---

### Link with previous concepts

The relationship between load, latency, and concurrency is formalized by:

→ [3.2.1 Little’s Law](03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency)

As load increases:

- concurrency increases
- waiting time grows
- response time degrades

---

### Key idea

A system does not fail when it reaches capacity.

It starts to degrade before that point.

The goal of performance engineering is to identify:

- where capacity lies
- how the system behaves near it
- how much margin is required

--- 

## 3.5.2 Saturation and queueing

### Definition

**Saturation** occurs when a resource is busy most or all of the time.

**Queueing** occurs when incoming work cannot be processed immediately and must wait.

These two phenomena are tightly connected.

---

### Resource saturation

A resource becomes saturated when:

- its utilization approaches its limit
- it has little or no idle time

Typical examples:

- CPU close to 100%
- thread pool fully occupied
- connection pool exhausted

At this point:

- new requests cannot be processed immediately
- they must wait

---

### Queue formation

When requests arrive faster than they can be processed:

- a queue forms
- waiting time increases

This affects response time:

- service time remains the same
- waiting time grows

→ [3.2.3 Service time vs response time](03-02-core-metrics-and-formulas.md#323-service-time-vs-response-time-queueing)

---

### Non-linear effect

Queueing does not grow linearly.

As utilization increases:

- waiting time grows slowly at first
- then increases rapidly
- eventually dominates response time

Small increases in load can cause large increases in latency.

---

### Link with utilization

Utilization plays a central role:

→ [3.2.2 Utilization Law](03-02-core-metrics-and-formulas.md#322-utilization-law-resource-level-busy-time)

As utilization approaches its limit:

- the probability of waiting increases
- queues grow
- latency becomes unstable

---

### Practical implications

Queueing is often the main cause of performance degradation.

Symptoms include:

- sudden increase in response time
- long-tail latency (p95, p99)
- growing queues (threads, connections, requests)

Even if:

- CPU is not fully saturated
- average latency seems acceptable

---

### Example

A system handles requests with:

- service time = 10 ms

At low load:

- requests are processed immediately
- response time ≈ 10 ms

As load increases:

- requests start waiting
- response time becomes:

  10 ms (service) + waiting time

At high load:

- waiting time dominates
- response time increases rapidly

---

### Key idea

Saturation does not immediately break the system.

It introduces queueing.

Queueing increases waiting time.

Waiting time dominates response time.

This is the primary mechanism behind performance degradation under load.