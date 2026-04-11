# 1.5 – System behavior under load

<a id="15-system-behavior-under-load"></a>

This chapter analyzes system behavior as workload increases and as systems approach their capacity limits.

It focuses on the main mechanisms that can cause degradation under load, including **saturation**, **queueing**, **throughput loss**, and **tail latency amplification**.

These concepts are central in performance engineering because they analyze why systems may appear stable under low load and become unstable near their capacity limits.

## Table of Contents

- [1.5.1 Load vs capacity](#151-load-vs-capacity)
- [1.5.2 Saturation and queueing](#152-saturation-and-queueing)
- [1.5.3 Non-linear degradation](#153-non-linear-degradation)
- [1.5.4 Throughput collapse](#154-throughput-collapse)
- [1.5.5 Tail latency amplification](#155-tail-latency-amplification)

---

<a id="151-load-vs-capacity"></a>
## 1.5.1 Load vs capacity

### Definition

A system operates under a workload, but it has a well-defined capacity.

- **Load**: the amount of work applied to the system (e.g. requests per second, concurrent users)
- **Capacity**: the maximum amount of work the system can handle while remaining stable

Understanding the relationship between load and capacity is fundamental in performance engineering.

It defines the operating envelope of the system and determines when behavior is predictable and when degradation begins.

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

This transition is one of the most important aspects of performance analysis.

A system rarely moves directly from “stable” to “problematic”.
  
It usually passes through a region of increasing instability and reduced efficiency.

---

### Capacity is not a fixed value

Capacity is often misunderstood as a restricted set of values.

In reality, it depends on:

- workload composition (use cases and distribution)
- resource configuration (CPU, memory, pools)
- system state (cold vs warm, cache effects)
- external dependencies (databases, services)

A system may handle:

- 100 req/s for simple requests
- but only 20 req/s for complex requests

Capacity is therefore always contextual.

It must be understood in relation to a specific workload, environment, and acceptance criteria.

---

### Effective capacity

Capacity must be defined under well-defined constraints.

Typical criteria:

- latency within acceptable limits (e.g. p95)
- error rate below threshold
- stable resource usage

The maximum load that satisfies these conditions is the **effective capacity**.

This is the capacity that matters operationally.

A theoretical maximum that produces unacceptable latency or instability is not useful in practice.

---

### Practical implication

Capacity cannot be assumed a priori.

It must be:

- measured under realistic workload
- validated through testing
- monitored over time

Increasing load beyond effective capacity leads to:

- rapid degradation
- unstable behavior
- potential system failure

It may also reduce the system’s ability to recover quickly after overload.

---

### Link with previous concepts

The relationship between load, latency, and concurrency is formalized by:

→ [1.2.1 Little’s Law](01-02-core-metrics-and-formulas.md#121-littles-law-system-level-concurrency)

As load increases:

- concurrency increases
- waiting time grows
- response time degrades

This relationship constitutes one of the foundations for understanding behavior under load.

---

### Practical interpretation

Load and capacity should never be treated as abstract labels.

They determine:

- whether the system operates with headroom
- whether queueing is likely to appear
- how much margin exists before instability appears

In performance engineering, knowing that a system “works” is not sufficient.

What matters is knowing under which load conditions it remains stable and how close it is to its effective capacity.

---

### Key idea

A system does not break when it reaches capacity.

It begins to degrade before that point.

The goal of performance engineering is to identify:

- where the capacity limits lie
- how the system behaves near them
- how much margin is required

--- 

<a id="152-saturation-and-queueing"></a>
## 1.5.2 Saturation and queueing

### Definition

**Saturation** occurs when a resource is busy most or all of the time.

**Queueing** occurs when incoming work cannot be processed immediately and must be placed on hold: in a queue.

These two phenomena are closely related.

They are among the most important mechanisms underlying performance degradation in real systems.

---

### Resource saturation

A resource becomes saturated when:

- its utilization approaches the limit
- it has little or no idle time

Typical examples:

- CPU close to 100%
- thread pool fully occupied
- connection pool exhausted

At this point:

- new requests cannot be processed immediately
- they must wait

Saturation does not necessarily mean there is a problem.

It means the system has lost processing headroom and is no longer able to absorb additional work without delay.

---

### Queue formation

When work requests arrive faster than they can be processed:

- a queue forms
- waiting time increases

This affects response time:

- service time remains the same
- waiting time grows

→ [1.2.3 Service time vs response time](01-02-core-metrics-and-formulas.md#123-service-time-vs-response-time-queueing)

Queueing is therefore the visible consequence of insufficient processing capacity at a given resource.

---

### Non-linear effect

Queueing does not grow linearly.

As utilization increases:

- waiting time grows slowly at first
- then increases rapidly
- eventually dominates response time

Small increases in load can cause large increases in latency.

This explains why systems often appear stable for a long time and then degrade suddenly near the saturation threshold.

---

### Link with utilization

Utilization plays a central role:

→ [1.2.2 Utilization Law](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time)

As utilization approaches its limit:

- the probability of waiting increases
- queues grow
- latency becomes unstable

The important point is not that a resource is “busy,” but that when it is persistently busy, incoming work begins to accumulate.

---

### Practical implications

Queueing is often the main cause of performance degradation.

Symptoms include:

- sudden increase in response time
- high tail latency (p95, p99)
- growing queues (threads, connections, requests)

Even if:

- CPU is not fully saturated
- average latency seems acceptable

queueing may still be the dominant source of delay.

This is particularly common in systems with shared pools, blocking operations, or dependency bottlenecks.

---

### Example

A system handles requests with:

- service time = 10 ms

At low load:

- requests are processed immediately
- response time ≈ 10 ms

As load increases:

- requests begin to wait
- response time becomes:

  10 ms (service) + waiting time

At high load:

- waiting time dominates
- response time increases rapidly

This example aims to illustrate why latency growth under load is often caused more by waiting than by the work itself.

---

### Practical interpretation

Saturation is the condition.

Queueing is the consequence.

The system does not slow down because each request requires more computation, but because more requests are competing for the same limited resources.

This distinction is essential:

- optimizing service time may help
- but reducing queueing is often even more important

---

### Key idea

Saturation does not immediately break the system.

It introduces queueing.

Queueing increases waiting time.

Waiting time dominates response time.

This is the main mechanism underlying performance degradation under load.

---

<a id="153-non-linear-degradation"></a>
## 1.5.3 Non-linear degradation

### Definition

System performance does not degrade linearly as load increases.

Rather, degradation follows a non-linear pattern, especially near capacity limits.

This means that the relationship between load and response time is often initially regular and then strongly unstable near saturation.

---

### Linear vs non-linear behavior

At low or moderate load:

- throughput increases proportionally with load
- latency remains relatively stable

In this region, the system appears predictable.

---

When load approaches capacity:

- small increases in load produce large increases in latency
- variability increases
- behavior becomes unstable

This marks the transition to non-linear degradation.

The system no longer behaves proportionally to demand.

It begins to react disproportionately to additional work.

---

### Root cause

Non-linear degradation is mainly caused by:

- queueing effects (→ [1.5.2 Saturation and queueing](#152-saturation-and-queueing))
- high resource utilization
- contention between requests

As utilization increases:

- waiting time grows disproportionately
- response time becomes dominated by delays rather than service

This explains why degradation often accelerates suddenly rather than growing gradually.

---

### Observable effects

Typical symptoms include:

- rapid increase in p95 and p99 latency
- widening gap between average latency and tail latency
- increase in response-time variance
- intermittent errors or timeouts

These effects often appear suddenly.

The system may seem healthy just before entering a region of severe instability.

---

### Misleading intuition

It is common to assume:

- “If the system handles 80 req/s, it should handle 100 req/s with slightly higher latency”

In reality:

- performance may remain stable up to a certain point
- then degrade sharply beyond that point

There is often no gradual transition.

This constitutes one of the most common mistakes in capacity planning and performance expectations.

---

### Example

A system behaves as follows:

- up to 70 req/s → stable latency (~100 ms)
- at 80 req/s → latency increases to 150 ms
- at 90 req/s → latency jumps to 400 ms
- at 100 req/s → system becomes unstable

The degradation is not proportional to load.

The last increments in load have a much greater effect than the previous ones.

---

### Practical implication

Capacity planning must take non-linear behavior into account.

Operating a system near its limits leads to:

- unpredictable latency
- unstable performance
- poor user experience

Systems should operate with a reasonable safety margin below capacity.

That margin is not optional.

It is what allows the system to absorb normal variability without entering unstable behavior.

---

### Link with previous concepts

Non-linear degradation is the visible effect of:

- increasing utilization (→ [1.2.2 Utilization Law](01-02-core-metrics-and-formulas.md#122-utilization-law-resource-level-busy-time))
- growing queueing (→ [1.5.2 Saturation and queueing](#152-saturation-and-queueing))

It is therefore a system-level consequence of mechanisms already introduced in previous sections.

---

### Practical interpretation

Non-linear degradation explains why systems should not be operated too close to their theoretical maximum.

An adequate operational margin can make the difference between:

- stable performance
- unpredictable degradation

This also explains why average resource usage alone is often misleading when assessing production safety.

---

### Key idea

Performance degradation is not gradual.

It accelerates as the system approaches its own limits.

Understanding this non-linearity is essential to avoid operating systems too close to their capacity limits.

---

<a id="154-throughput-collapse"></a>
## 1.5.4 Throughput collapse

### Definition

**Throughput collapse** occurs when increasing load no longer increases throughput and may even reduce it.

Instead of scaling with demand, the system becomes less efficient as load increases.

This is one of the clearest signals that the system is operating beyond its effective capacity.

---

### Expected behavior vs collapse

Under normal conditions:

- increasing load increases throughput
- until the system approaches its capacity limits

However, beyond a certain point:

- throughput stops increasing
- may plateau or decrease
- latency increases significantly

This is the so-called throughput collapse.

More incoming work does not translate into an equal amount of completed work.

---

### Root causes

Throughput collapse is typically caused by:

- excessive queueing
- contention on shared resources
- resource thrashing (CPU, memory, I/O)
- retry amplification
- inefficient scheduling or locking

When the system becomes overloaded:

- more time is spent managing contention than doing useful work
- effective processing capacity decreases

This is the key reason why greater demand can produce less output.

---

### Queueing contribution

When queues grow:

- requests wait longer
- system resources remain occupied
- new requests add pressure without increasing completed work

Queueing can therefore:

- increase latency
- reduce effective throughput

This is particularly visible when the system spends more and more time managing backlog instead of making real progress.

---

### Contention and thrashing

At high load:

- threads compete for shared resources
- locks become hotspots
- context switching increases
- cache locality degrades

In extreme cases:

- the system spends more time coordinating than processing

This leads to a reduction in throughput.

The system remains active, but its activity becomes increasingly unproductive.

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

Retry behavior is therefore not only a response to symptoms, but also a frequent cause of worsening overload.

---

### Observable effects

Typical symptoms include:

- throughput that plateaus or decreases despite increasing load
- sharp increase in latency
- increasing error rates (timeouts, 5xx)
- unstable or oscillating behavior

At this stage, the system may appear busy but is no longer scaling in a useful way.

---

### Example

A system behaves as follows:

- 50 req/s → 50 req/s throughput
- 80 req/s → 80 req/s throughput
- 100 req/s → 90 req/s throughput
- 120 req/s → 70 req/s throughput

Increasing load reduces effective throughput.

This is a direct indicator that overload is “damaging” useful work.

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

In many cases, the first corrective action is not optimization but protection: rate limiting, admission control, or retry control.

---

### Link with previous concepts

Throughput collapse is the result of:

- non-linear degradation (→ [3.5.3 Non-linear degradation](#353-non-linear-degradation))
- saturation and queueing (→ [3.5.2 Saturation and queueing](#352-saturation-and-queueing))

It can therefore be understood as an advanced stage of overload behavior.

---

### Practical interpretation

A system does not always process more work when additional work is applied to it.

At a certain point, additional work becomes destructive rather than productive.

Recognizing this transition is essential in performance engineering, because it marks the difference between high load and overload.

---

### Key idea

Beyond a certain point, additional load reduces the system’s ability to process requests.

Understanding throughput collapse is essential to avoid overload conditions.

---

<a id="155-tail-latency-amplification"></a>
## 1.5.5 Tail latency amplification

### Definition

**Tail latency amplification** refers to the disproportionate increase of high-percentile response times (e.g. p95, p99) under load.

While average latency may appear acceptable, a subset of requests becomes significantly slower.

This effect constitutes one of the most important indicators of degraded user experience and hidden instability.

---

### Percentiles vs average

Average latency hides variability.

Percentiles reveal distribution:

- p50 represents the typical request
- p95 and p99 represent the slowest requests

Under load:

- average latency may increase moderately
- tail latency may increase drastically

→ [1.2.7 Percentiles](01-02-core-metrics-and-formulas.md#127-percentiles-p50-p95-p99)

For this reason, averages alone are not sufficient to assess real performance quality.

---

### Root causes

Tail latency amplification is mainly driven by:

- queueing delays
- contention on shared resources
- uneven workload distribution
- dependency variability (e.g. database, external services)

Even small delays in some components can:

- propagate through the system
- amplify end-to-end latency

Tail latency is therefore often an emergent effect, not only a local one.

---

### Effect in distributed systems

In systems with multiple components:

- a request often depends on several services
- overall latency depends on the slowest component

As the number of dependencies increases:

- the probability of a slow request increases
- tail latency becomes more pronounced

This is one of the reasons why tail latency is particularly important in distributed architectures.

---

### Under load

As load increases:

- queues grow
- contention increases
- variability expands

This leads to:

- a widening gap between average and p95/p99
- unpredictable response times for a subset of users

The system may therefore appear mostly stable while still producing an unacceptable experience for a significant fraction of requests.

---

### Observable effects

Typical symptoms include:

- stable average latency with degraded p95/p99
- intermittent slow responses
- timeouts affecting only a fraction of requests

This can be misleading:

- the system appears “mostly fine”
- but user experience is degraded

This explains why queue metrics are essential in performance testing and production monitoring.

---

### Example

A system shows:

- average latency = 120 ms
- p95 latency = 180 ms (acceptable)
- p99 latency = 1200 ms (problematic)

Most requests are fast, but a small percentage is very slow.

In many user-facing systems, this small percentage is enough to create visible dissatisfaction or SLO violations.

---

### Practical implication

Performance evaluation must take **tail latency** into account.

Relying on averages can:

- hide critical issues
- underestimate user impact

Systems should be designed and tested to:

- control queue behavior
- limit variability under load

This is particularly important for distributed systems, APIs, and interactive applications.

---

### Link with previous concepts

Tail latency amplification is a consequence of:

- queueing (→ [1.5.2 Saturation and queueing](#152-saturation-and-queueing))
- non-linear degradation (→ [1.5.3 Non-linear degradation](#153-non-linear-degradation))
- system interactions and dependencies

It is therefore one of the most visible manifestations of system stress under load.

---

### Practical interpretation

Performance is not defined by the average request.

It is defined by the predictability of response times, especially for the slowest requests.

A system with acceptable average latency but poor p95/p99 behavior is not truly stable from a user or operational perspective.

---

### Key idea

Performance is not defined by the average request.

It is defined by how the system behaves for the slowest requests.

Controlling tail latency is essential for predictable and reliable systems.