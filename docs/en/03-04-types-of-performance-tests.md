## 3.4 – Types of performance tests

## Table of Contents

- [3.4.1 Purpose of performance testing](#341-purpose-of-performance-testing)
- [3.4.2 Load testing](#342-load-testing)
- [3.4.3 Stress testing](#343-stress-testing)
- [3.4.4 Spike testing](#344-spike-testing)
- [3.4.5 Soak testing](#345-soak-testing)
- [3.4.6 Capacity testing](#346-capacity-testing)

---

## 3.4.1 Purpose of performance testing

### Definition

Performance testing evaluates how a system behaves under controlled workload conditions.

It provides measurable data about:

- latency  
- throughput  
- error rate  
- resource usage  

(→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md))

---

### Role in performance engineering

Performance testing is not only about measuring results.

It is used to:

- validate system behavior under expected conditions  
- reveal bottlenecks and limitations  
- support capacity planning  
- validate architectural decisions  

---

### Workload as a model

A test workload represents a simplified model of real usage.

It defines:

- arrival rate (requests per second)  
- concurrency (number of active users or requests)  
- request patterns (distribution, mix of operations)  

(→ [3.2.1 Little’s Law (system-level concurrency)](./03-02-core-metrics-and-formulas.md#321-littles-law-system-level-concurrency))

---

### Key idea

Performance tests are controlled experiments.

They are designed to observe system behavior under specific workload conditions.

---

## 3.4.2 Load testing

### Definition

**Load testing** evaluates system behavior under expected or typical workload.

---

### Objective

- verify that the system meets performance requirements  
- validate latency and throughput targets  
- observe resource usage under normal conditions  

---

### Characteristics

- workload is stable and controlled  
- system operates within its expected range  
- focus is on steady-state behavior  

---

### Example

A system designed for:

- 200 requests per second  
- p95 latency < 300 ms  

A load test verifies that these targets are met.

---

### Diagnostic value

Load testing provides a baseline:

- normal latency distribution  
- typical resource utilization  
- expected throughput  

This baseline is essential for comparison with other tests.

---

### Key idea

Load testing answers: *“Does the system behave correctly under expected load?”*

---

## 3.4.3 Stress testing

### Definition

**Stress testing** evaluates system behavior beyond its expected capacity.

---

### Objective

- identify system limits  
- observe behavior under overload  
- detect failure modes  

---

### Characteristics

- workload increases beyond normal levels  
- system approaches or reaches saturation  

(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))

---

### Observable effects

- latency increases rapidly  
- throughput plateaus or decreases  
- error rate increases  

(→ [3.5.3 Non-linear degradation](./03-05-system-behavior-under-load.md#353-non-linear-degradation))  
(→ [3.5.4 Throughput collapse](./03-05-system-behavior-under-load.md#354-throughput-collapse))

---

### Diagnostic value

Stress testing reveals:

- bottlenecks  
- saturation points  
- system stability under pressure  

---

### Key idea

Stress testing answers: *“What happens when the system is pushed beyond its limits?”*

---

## 3.4.4 Spike testing

### Definition

**Spike testing** evaluates system behavior under sudden increases in load.

---

### Objective

- observe reaction to abrupt workload changes  
- evaluate elasticity and recovery  
- detect transient instability  

---

### Characteristics

- workload increases rapidly in a short time  
- system must adapt quickly  

---

### Observable effects

- temporary latency spikes  
- queue buildup  
- potential errors during transition  

(→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))

---

### Diagnostic value

Spike testing reveals:

- sensitivity to burst traffic  
- queueing behavior under sudden load  
- recovery capability after the spike  

---

### Key idea

Spike testing answers: *“How does the system react to sudden load changes?”*

---

## 3.4.5 Soak testing

### Definition

**Soak testing** evaluates system behavior over an extended period under sustained load.

---

### Objective

- detect long-term issues  
- observe stability over time  
- identify gradual degradation  

---

### Characteristics

- workload is constant or slowly varying  
- test duration is long (hours or days)  

---

### Observable effects

- memory growth  
- resource leaks  
- performance degradation over time  

(→ [3.7 Runtime and memory model](./03-07-runtime-and-memory-model.md))

---

### Diagnostic value

Soak testing reveals:

- memory leaks  
- resource exhaustion  
- long-term instability  

---

### Key idea

Soak testing answers: *“Does the system remain stable over time?”*

---

## 3.4.6 Capacity testing

### Definition

**Capacity testing** determines the maximum workload a system can handle while meeting performance requirements.

---

### Objective

- identify maximum sustainable throughput  
- determine safe operating limits  
- support capacity planning  

---

### Method

- gradually increase workload  
- monitor latency, throughput, and errors  
- identify the point where performance degrades  

---

### Interpretation

The capacity limit is reached when:

- latency exceeds acceptable thresholds  
- error rate increases  
- throughput no longer scales  

(→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md))  
(→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))

---

### Key idea

Capacity testing answers: *“How far can the system scale before it degrades?”*



