## 3.4 – Types of performance tests

<a id="34-types-of-performance-tests"></a>

This chapter introduces the main categories of performance tests used in performance engineering.

Each type of performance test answers a different question about system behavior under load.

Together, they help evaluate performance, stability, scalability, recovery, and capacity in a controlled and measurable way.

## Table of Contents

- [3.4.1 Purpose of performance testing](#341-purpose-of-performance-testing)
- [3.4.2 Load testing](#342-load-testing)
- [3.4.3 Stress testing](#343-stress-testing)
- [3.4.4 Spike testing](#344-spike-testing)
- [3.4.5 Soak testing](#345-soak-testing)
- [3.4.6 Capacity testing](#346-capacity-testing)

---

## 3.4.1 Purpose of performance testing {#341-purpose-of-performance-testing}

### Definition

Performance testing evaluates how a system behaves under controlled workload conditions.

It provides measurable data about:

- latency  
- throughput  
- error rate  
- resource usage  

(→ [3.2 Core metrics and formulas](#chap-03-02-core-metrics-and-formulas))

Performance testing is therefore not only a measurement activity, but also a validation activity.

It is used to compare expected behavior with observed behavior under defined workload conditions.

---

### Role in performance engineering

Performance testing is not only about measuring results.

It is used to:

- validate system behavior under expected conditions  
- reveal bottlenecks and limitations  
- support capacity planning  
- validate architectural decisions  

It also provides a controlled framework for comparing:

- versions of the same system
- different configurations
- infrastructure changes
- tuning choices

Without controlled testing, performance discussions often remain based on assumptions rather than evidence.

---

### Workload as a model

A test workload represents a simplified model of real usage.

It defines:

- arrival rate (requests per second)  
- concurrency (number of active users or requests)  
- request patterns (distribution, mix of operations)  

(→ [3.2.1 Little’s Law (system-level concurrency)](#chap-03-02-core-metrics-and-formulas))

A workload is not the real production environment itself.

It is a practical approximation of the most relevant usage patterns.

For this reason, the value of a performance test depends strongly on how realistic the workload model is.

---

### Controlled conditions

A performance test is meaningful only if the execution conditions are understood.

This includes:

- the shape of the workload
- the duration of the test
- the environment in which it runs
- the metrics collected during execution

If these conditions are unclear, results may still produce numbers, but those numbers are difficult to interpret and compare.

Controlled conditions are what transform a test from a simple exercise into a useful engineering activity.

---

### Relationship with the rest of the guide

Performance testing is the practical entry point for many of the concepts developed in the rest of the guide.

It exposes:

- queueing and saturation effects (→ [3.5 System behavior under load](#chap-03-05-system-behavior-under-load))
- concurrency limits (→ [3.6 Concurrency and parallelism](#chap-03-06-concurrency-and-parallelism))
- runtime and memory effects (→ [3.7 Runtime and memory model](#chap-03-07-runtime-and-memory-model))
- resource saturation (→ [3.8 Resource-level performance](#chap-03-08-resource-level-performance))

For that reason, test design should always be connected to system reasoning.

---

### Practical meaning

A good performance test does not only answer:

- “How fast is the system?”

It also helps answer:

- “Under which conditions does the system remain stable?”
- “What changes as load increases?”
- “Which limit is reached first?”
- “What kind of degradation appears?”

These questions are essential in performance engineering because they connect measurement to interpretation.

---

### Key idea

Performance tests are controlled experiments.

They are designed to observe system behavior under specific workload conditions.

Their value lies not only in the measurements they produce, but also in the understanding they provide.

---

## 3.4.2 Load testing {#342-load-testing}

### Definition

**Load testing** evaluates system behavior under expected or typical workload.

It is the most common and most direct way to validate that a system behaves acceptably under normal operating conditions.

---

### Objective

- verify that the system meets performance requirements  
- validate latency and throughput targets  
- observe resource usage under normal conditions  

Load testing answers the question of whether the system behaves correctly in the operating range it is expected to support.

---

### Characteristics

- workload is stable and controlled  
- system operates within its expected range  
- focus is on steady-state behavior  

The purpose is not to break the system, but to establish whether the system performs correctly under the load it was designed for.

---

### Example

A system designed for:

- 200 requests per second  
- p95 latency < 300 ms  

A load test verifies that these targets are met.

It may also verify that:

- error rate remains low
- throughput remains stable
- resource utilization remains within acceptable bounds

---

### Diagnostic value

Load testing provides a baseline:

- normal latency distribution  
- typical resource utilization  
- expected throughput  

This baseline is essential for comparison with other tests.

Without a reliable baseline, it is difficult to determine whether behavior observed in stress, spike, soak, or capacity tests is abnormal or simply normal for the system.

---

### Limits of load testing

Load testing alone does not determine:

- the maximum system capacity
- the failure point of the system
- the long-term stability of the runtime
- the recovery behavior after abrupt changes in load

A system may pass a load test and still fail under overload, sustained execution, or rapid bursts of traffic.

For this reason, load testing is necessary but not sufficient.

---

### Practical interpretation

Load testing is the reference point for the rest of performance analysis.

It defines the system’s normal operating behavior and allows later tests to be interpreted in context.

If the system already behaves poorly under expected load, there is little value in moving immediately to more advanced test types.

---

### Key idea

Load testing answers: *“Does the system behave correctly under expected load?”*

It establishes the baseline against which all other performance tests can be interpreted.

---

## 3.4.3 Stress testing {#343-stress-testing}

### Definition

**Stress testing** evaluates system behavior beyond its expected capacity.

It is used to observe what happens when the system is pushed outside its intended operating range.

---

### Objective

- identify system limits  
- observe behavior under overload  
- detect failure modes  

Stress testing is primarily concerned with limit behavior and degradation under excessive demand.

---

### Characteristics

- workload increases beyond normal levels  
- system approaches or reaches saturation  

(→ [3.8 Resource-level performance](#chap-03-08-resource-level-performance))

The overload may be applied progressively or maintained at a clearly excessive level.

In both cases, the goal is to expose how the system behaves when demand exceeds capacity.

---

### Observable effects

- latency increases rapidly  
- throughput plateaus or decreases  
- error rate increases  

(→ [3.5.3 Non-linear degradation](#chap-03-05-system-behavior-under-load))  
(→ [3.5.4 Throughput collapse](#chap-03-05-system-behavior-under-load))

Additional effects may include:

- queue buildup
- timeout amplification
- pool exhaustion
- unstable resource usage
- retry-driven overload

---

### Diagnostic value

Stress testing reveals:

- bottlenecks  
- saturation points  
- system stability under pressure  

It is particularly useful for understanding whether degradation is gradual, abrupt, recoverable, or unstable.

Two systems with similar load-test results may behave very differently under stress.

---

### Failure behavior

An important aspect of stress testing is not only whether the system fails, but how it fails.

Relevant questions include:

- Does latency increase before errors appear?
- Do errors appear gradually or suddenly?
- Does throughput flatten before it collapses?
- Does the system recover when load is reduced?

These questions matter operationally because overload is a realistic scenario in production systems.

---

### Distinction from capacity testing

Stress testing and capacity testing are related, but they are not identical.

- **stress testing** focuses on overload behavior and failure modes
- **capacity testing** focuses on the maximum sustainable load that still meets requirements

Stress testing therefore continues beyond the acceptable operating range in order to examine degradation and failure.

---

### Practical interpretation

Stress testing is useful when the engineering question is not only:

- “How much load can the system support?”

but also:

- “What happens after it can no longer support the load?”
- “Does it degrade gracefully?”
- “Can it recover cleanly?”

These are essential questions for resilience and operational robustness.

---

### Key idea

Stress testing answers: *“What happens when the system is pushed beyond its limits?”*

It reveals how the system degrades, how it fails, and how much overload it can tolerate before becoming unstable.

---

## 3.4.4 Spike testing {#344-spike-testing}

### Definition

**Spike testing** evaluates system behavior under sudden increases in load.

Unlike load testing or gradual stress testing, spike testing focuses on rapid transitions rather than stable operating conditions.

---

### Objective

- observe reaction to abrupt workload changes  
- evaluate elasticity and recovery  
- detect transient instability  

Spike testing is especially relevant for systems exposed to burst traffic, campaign peaks, event-driven demand, or short-lived surges in activity.

---

### Characteristics

- workload increases rapidly in a short time  
- system must adapt quickly  

The defining characteristic is not only the volume of load, but the speed at which the load changes.

A system may handle a high load when it is reached gradually, but behave poorly when the same load arrives suddenly.

---

### Observable effects

- temporary latency spikes  
- queue buildup  
- potential errors during transition  

(→ [3.5 System behavior under load](#chap-03-05-system-behavior-under-load))

Additional effects may include:

- delayed scaling response
- transient connection exhaustion
- temporary timeout cascades
- slow recovery after the burst

---

### Diagnostic value

Spike testing reveals:

- sensitivity to burst traffic  
- queueing behavior under sudden load  
- recovery capability after the spike  

It is valuable because many systems are optimized for steady-state conditions but remain fragile during abrupt transitions.

---

### Recovery behavior

The most important part of spike testing is often what happens after the spike.

Relevant questions include:

- Does the system return quickly to normal latency?
- Do queues drain in a controlled way?
- Are resources released correctly?
- Does the system remain degraded after the spike has passed?

A system that survives the spike but recovers slowly may still be operationally weak.

---

### Practical interpretation

Spike testing is especially useful for systems that are:

- externally exposed to bursty traffic
- dependent on auto-scaling or elastic behavior
- sensitive to queue buildup
- subject to event-driven demand changes

In these cases, average load is often less important than short-term peaks and the system’s reaction to them.

---

### Key idea

Spike testing answers: *“How does the system react to sudden load changes?”*

It evaluates not only resistance to bursts, but also the ability to recover cleanly after them.

---

## 3.4.5 Soak testing {#345-soak-testing}

### Definition

**Soak testing** evaluates system behavior over an extended period under sustained load.

It is sometimes also called endurance testing.

Its purpose is to expose problems that do not appear in short-duration tests.

---

### Objective

- detect long-term issues  
- observe stability over time  
- identify gradual degradation  

Soak testing is less concerned with peak performance and more concerned with consistency, accumulation, and drift.

---

### Characteristics

- workload is constant or slowly varying  
- test duration is long (hours or days)  

The key dimension is time.

Some systems behave correctly for minutes but degrade after hours because of accumulation effects.

---

### Observable effects

- memory growth  
- resource leaks  
- performance degradation over time  

(→ [3.7 Runtime and memory model](#chap-03-07-runtime-and-memory-model))

Additional long-duration symptoms may include:

- thread accumulation
- connection leakage
- slowly increasing queues
- GC overhead growth
- cache imbalance or uncontrolled retention

---

### Diagnostic value

Soak testing reveals:

- memory leaks  
- resource exhaustion  
- long-term instability  

It is often the only reliable way to validate whether the system remains healthy during prolonged activity.

This is essential for production systems expected to run continuously.

---

### Time-dependent degradation

Soak testing is important because some failures are not threshold-based, but time-based.

Examples include:

- memory retained slowly over time
- pools not fully released
- background tasks accumulating drift
- retry patterns slowly increasing pressure
- caches growing without effective eviction

These issues may not appear in load or stress tests of short duration.

---

### Operational value

A system that performs well for ten minutes but degrades after six hours is not stable.

Soak testing therefore contributes directly to:

- production readiness
- runtime confidence
- long-term reliability assessment
- infrastructure and runtime dimensioning

It also helps validate that monitoring remains meaningful over long periods of operation.

---

### Practical interpretation

Soak testing is particularly important for systems with:

- long uptimes
- background processing
- memory-managed runtimes
- connection-heavy architectures
- resource pools that change slowly over time

In such systems, short-duration performance results are not sufficient to guarantee real stability.

---

### Key idea

Soak testing answers: *“Does the system remain stable over time?”*

It validates long-duration behavior and reveals issues caused by accumulation, drift, and slow degradation.

---

## 3.4.6 Capacity testing {#346-capacity-testing}

### Definition

**Capacity testing** determines the maximum workload a system can handle while meeting performance requirements.

It is used to identify the practical operating limit of the system under acceptable conditions.

---

### Objective

- identify maximum sustainable throughput  
- determine safe operating limits  
- support capacity planning  

Capacity testing is therefore directly related to planning, sizing, forecasting, and operational decision-making.

---

### Method

- gradually increase workload  
- monitor latency, throughput, and errors  
- identify the point where performance degrades  

The increase in load should be controlled and measurable.

This allows the system limit to be located more precisely than in a purely exploratory stress test.

---

### Interpretation

The capacity limit is reached when:

- latency exceeds acceptable thresholds  
- error rate increases  
- throughput no longer scales  

(→ [3.2 Core metrics and formulas](#chap-03-02-core-metrics-and-formulas))  
(→ [3.5 System behavior under load](#chap-03-05-system-behavior-under-load))

In practice, the limit is not always a single exact value.

It may be better understood as a range in which acceptable behavior begins to deteriorate.

---

### What capacity testing reveals

Capacity testing reveals:

- the highest sustainable load under defined acceptance criteria
- the margin between expected load and maximum acceptable load
- the relationship between increasing demand and degrading behavior
- the point at which additional load no longer produces useful throughput

This information is essential for engineering and planning decisions.

---

### Relationship with capacity planning

Capacity testing is one of the main inputs to capacity planning.

It helps answer questions such as:

- How much traffic can the current system support?
- How much headroom is available?
- When will scaling be required?
- Which component constrains capacity first?

This makes capacity testing especially useful for forecasting and operational preparation.

---

### Distinction from stress testing

Capacity testing is not about forcing failure for its own sake.

It is about identifying the highest load that still satisfies defined requirements.

- **capacity testing** stops at or near the acceptable limit
- **stress testing** continues beyond that limit to examine overload behavior

The distinction matters because many business and engineering decisions depend on safe operation, not on total failure.

---

### Practical meaning

Capacity is not only a number.

It depends on:

- workload mix
- concurrency level
- latency objectives
- acceptable error rate
- resource constraints

For this reason, any capacity number must always be interpreted in the context of the workload and acceptance criteria used during the test.

---

### Practical interpretation

Capacity testing is most useful when the engineering objective is to answer:

- “What is the safe operating range?”
- “How much headroom do we have?”
- “When do we need to scale?”
- “What constrains future growth?”

It is therefore one of the most decision-oriented forms of performance testing.

---

### Key idea

Capacity testing answers: *“How far can the system scale before it degrades?”*

It identifies the maximum sustainable operating range, not just the point of failure.
