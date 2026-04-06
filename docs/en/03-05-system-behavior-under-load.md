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

---

## 3.5.3 Non-linear degradation

### Definition

System performance does not degrade linearly as load increases.

Instead, degradation follows a non-linear pattern, especially near capacity limits.

---

### Linear vs non-linear behavior

At low to moderate load:

- throughput increases proportionally with load
- latency remains relatively stable

In this region, the system appears predictable.

---

As load approaches capacity:

- small increases in load produce large increases in latency
- variability increases
- behavior becomes unstable

This marks the transition to non-linear degradation.

---

### Root cause

Non-linear degradation is primarily caused by:

- queueing effects (→ [3.5.2 Saturation and queueing](#352-saturation-and-queueing))
- high resource utilization
- contention between requests

As utilization increases:

- waiting time grows disproportionately
- response time becomes dominated by delays rather than service

---

### Observable effects

Typical symptoms include:

- rapid increase in p95 and p99 latency
- widening gap between average and tail latency
- increased variance in response times
- intermittent errors or timeouts

These effects often appear suddenly.

---

### Misleading intuition

It is common to assume:

- “If the system handles 80 req/s, it should handle 100 req/s with slightly higher latency”

In reality:

- performance may remain stable up to a point
- then degrade sharply beyond that point

There is often no gradual transition.

---

### Example

A system behaves as follows:

- up to 70 req/s → stable latency (~100 ms)
- at 80 req/s → latency increases to 150 ms
- at 90 req/s → latency jumps to 400 ms
- at 100 req/s → system becomes unstable

The degradation is not proportional to load.

---

### Practical implication

Capacity planning must consider non-linear behavior.

Operating a system near its limits leads to:

- unpredictable latency
- unstable performance
- poor user experience

Systems should operate with a margin below capacity.

---

### Link with previous concepts

Non-linear degradation is the visible effect of:

- increasing utilization (→ [3.2.2 Utilization Law](03-02-core-metrics-and-formulas.md#322-utilization-law-resource-level-busy-time))
- growing queueing (→ [3.5.2 Saturation and queueing](#352-saturation-and-queueing))

---

### Key idea

Performance degradation is not gradual.

It accelerates as the system approaches its limits.

Understanding this non-linearity is essential to avoid operating systems too close to capacity.

---

## 3.5.4 Throughput collapse

### Definition

**Throughput collapse** occurs when increasing load no longer increases throughput, and may even reduce it.

Instead of scaling with demand, the system becomes less efficient as load grows.

---

### Expected behavior vs collapse

Under normal conditions:

- increasing load increases throughput
- until the system approaches capacity

However, beyond a certain point:

- throughput stops increasing
- may plateau or decrease
- latency increases significantly

This is throughput collapse.

---

### Root causes

Throughput collapse is typically caused by:

- excessive queueing
- contention on shared resources
- resource thrashing (CPU, memory, I/O)
- retry amplification
- inefficient scheduling or locking

As the system becomes overloaded:

- more time is spent managing contention than doing useful work
- effective processing capacity decreases

---

### Queueing contribution

When queues grow:

- requests wait longer
- system resources remain occupied
- new requests add pressure without increasing completed work

Queueing can therefore:

- increase latency
- reduce effective throughput

---

### Contention and thrashing

At high load:

- threads compete for shared resources
- locks become hotspots
- context switching increases
- cache locality degrades

In extreme cases:

- the system spends more time coordinating than processing

This leads to reduced throughput.

---

### Retry amplification

Failures under load often trigger retries.

This creates additional load:

- failed requests are retried
- more work is generated
- pressure increases further

This feedback loop can:

- accelerate collapse
- make recovery difficult

---

### Observable effects

Typical symptoms include:

- throughput plateau or decrease despite increased load
- sharp increase in latency
- rising error rates (timeouts, 5xx)
- unstable or oscillating behavior

---

### Example

A system behaves as follows:

- 50 req/s → 50 req/s throughput
- 80 req/s → 80 req/s throughput
- 100 req/s → 90 req/s throughput
- 120 req/s → 70 req/s throughput

Increasing load reduces effective throughput.

---

### Practical implication

Throughput collapse indicates that the system is operating beyond its effective capacity.

At this point:

- adding more load worsens performance
- the system may become unstable

Mitigation requires:

- reducing load
- removing bottlenecks
- improving resource efficiency

---

### Link with previous concepts

Throughput collapse is the result of:

- non-linear degradation (→ [3.5.3 Non-linear degradation](#353-non-linear-degradation))
- saturation and queueing (→ [3.5.2 Saturation and queueing](#352-saturation-and-queueing))

---

### Key idea

A system does not always process more work when more work is applied.

Beyond a certain point, additional load reduces the system’s ability to process requests.

Understanding throughput collapse is essential to avoid overload conditions.

---

## 3.5.5 Tail latency amplification

### Definition

**Tail latency amplification** refers to the disproportionate increase of high-percentile response times (e.g. p95, p99) under load.

While average latency may appear acceptable, a subset of requests becomes significantly slower.

---

### Percentiles vs average

Average latency hides variability.

Percentiles reveal distribution:

- p50 represents the typical request
- p95 and p99 represent the slowest requests

Under load:

- average latency may increase moderately
- tail latency can increase dramatically

→ [3.2.7 Percentiles](03-02-core-metrics-and-formulas.md#327-percentiles-p50-p95-p99)

---

### Root causes

Tail latency amplification is primarily driven by:

- queueing delays
- contention on shared resources
- uneven workload distribution
- dependency variability (e.g. database, external services)

Even small delays in some components can:

- propagate through the system
- amplify end-to-end latency

---

### Distributed systems effect

In systems with multiple components:

- a request often depends on several services
- overall latency depends on the slowest component

As the number of dependencies increases:

- the probability of a slow request increases
- tail latency becomes more pronounced

---

### Under load

As load increases:

- queues grow
- contention increases
- variability expands

This leads to:

- a widening gap between average and p95/p99
- unpredictable response times for a subset of users

---

### Observable effects

Typical symptoms include:

- stable average latency with degraded p95/p99
- intermittent slow responses
- timeouts affecting only a fraction of requests

This can be misleading:

- the system appears “mostly fine”
- but user experience is degraded

---

### Example

A system shows:

- average latency = 120 ms
- p95 latency = 180 ms (acceptable)
- p99 latency = 1200 ms (problematic)

Most requests are fast, but a small percentage is very slow.

---

### Practical implication

Performance evaluation must consider **tail latency**.

Relying on averages can:

- hide critical issues
- underestimate user impact

Systems should be designed and tested to:

- control tail behavior
- limit variability under load

---

### Link with previous concepts

Tail latency amplification is a consequence of:

- queueing (→ [3.5.2 Saturation and queueing](#352-saturation-and-queueing))
- non-linear degradation (→ [3.5.3 Non-linear degradation](#353-non-linear-degradation))
- system interactions and dependencies

---

### Key idea

Performance is not defined by the average request.

It is defined by how the system behaves for the slowest requests.

Controlling tail latency is essential for predictable and reliable systems.