## 3.10 – Diagnostics and analysis

## Table of Contents

- [3.10.1 Observability and signals](#3101-observability-and-signals)
- [3.10.2 Symptom vs cause](#3102-symptom-vs-cause)
- [3.10.3 Correlation and causality](#3103-correlation-and-causality)
- [3.10.4 Building a hypothesis](#3104-building-a-hypothesis)
- [3.10.5 Narrowing down the bottleneck](#3105-narrowing-down-the-bottleneck)
- [3.10.6 Iterative analysis and validation](#3106-iterative-analysis-and-validation)

---

## 3.10.1 Observability and signals

### Definition

Diagnostics starts from observable signals.

These signals provide indirect visibility into the internal behavior of the system under load.  
They do not expose mechanisms directly, but they reflect their effects.

---

### Core signals

The primary signals are:

- latency (p50, p95, p99)  
- throughput  
- error rate  
- resource utilization (CPU, memory, I/O, network)  
- queue lengths  

(→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md))  
(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))

Each signal captures a different dimension of system behavior.  
Only their combination provides a meaningful view.

---

### Signal characteristics

Signals must be:

- **accurate** → reflect real behavior  
- **granular** → expose distribution (e.g. percentiles, not only averages)  
- **correlated in time** → aligned across components  

Without these properties, interpretation becomes unreliable or misleading.

---

### Practical implications

Effective diagnostics requires:

- observing multiple signals together  
- correlating them over time  
- avoiding single-metric reasoning  

Looking at one metric in isolation often hides the underlying mechanism.

---

### Key idea

Diagnostics depends on both the availability and the correct interpretation of observable signals.

---

## 3.10.2 Symptom vs cause

### Definition

A symptom is an observable effect.

A cause is the underlying mechanism that produces that effect.

---

### Distinction

Typical symptoms:

- high latency  
- high CPU usage  
- increased error rate  
- frequent garbage collection  

These describe *what is happening*, not *why it is happening*.

---

### Example

- high CPU usage may result from:
  - inefficient computation  
  - excessive retries  
  - memory pressure  
  - contention  

- high latency may result from:
  - queue buildup  
  - I/O delays  
  - synchronization  

(→ [3.9 Common performance problems](./03-09-common-performance-problems.md))

---

### Diagnostic implication

The same symptom can be produced by different causes.

Without identifying the underlying mechanism, corrective actions may target the wrong part of the system.

For example:

- reducing CPU usage may not reduce latency if the root cause is I/O queueing  
- tuning GC may not help if allocation rate remains unchanged  

---

### Key idea

Observed behavior is not the cause.

Diagnosis requires mapping symptoms to the mechanisms that generate them.

---

## 3.10.3 Correlation and causality

### Definition

Correlation is the simultaneous variation of two signals.

Causality is a direct relationship where one factor produces another.

---

### Common mistake

Two metrics change together:

- CPU increases  
- latency increases  

This does not imply that CPU is the cause of latency.

---

### Example

Possible interpretations:

- CPU saturation → scheduling delays → latency  
- I/O delays → more concurrent threads → higher CPU usage  
- contention → retries → both CPU and latency increase  

(→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))  
(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))

---

### Diagnostic implication

Correlation is a starting point, not a conclusion.

Multiple mechanisms can produce the same correlated signals.  
Only a causal model explains how one leads to the other.

---

### Practical approach

To establish causality:

- identify the sequence of events  
- verify consistency with known system behavior  
- validate through observation or controlled change  

---

### Key idea

Do not infer causation from correlation.

Diagnosis requires identifying the mechanism that links signals.

---

## 3.10.4 Building a hypothesis

### Definition

A hypothesis is a proposed explanation linking observed signals to a system mechanism.

It provides a structured way to move from observation to explanation.

---

### Process

A hypothesis is built by:

1. observing signals  
2. identifying consistent patterns  
3. mapping them to known mechanisms  

(→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md))  
(→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))

---

### Example

Observed:

- latency increases  
- queue length increases  
- CPU approaches saturation  

Hypothesis:

- increased arrival rate → queue buildup → longer waiting time → CPU saturation  

This connects observable signals to a queueing mechanism.

---

### Requirements

A valid hypothesis must be:

- consistent with observed data  
- grounded in system behavior  
- testable through measurement or change  

---

### Diagnostic implication

A hypothesis guides investigation.

Without it, analysis becomes reactive and unstructured.

---

### Key idea

Diagnosis proceeds through explicit, testable hypotheses, not assumptions.

---

## 3.10.5 Narrowing down the bottleneck

### Definition

Diagnostics aims to identify the resource or mechanism that limits system performance.

This limiting factor determines the overall system behavior under load.

---

### Approach

The analysis focuses on:

- CPU behavior  
- I/O latency  
- network delays  
- memory pressure  

(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))  
(→ [3.7 Runtime and memory model](./03-07-runtime-and-memory-model.md))

---

### Method

- isolate one dimension at a time  
- compare signals across resources  
- identify the dominant constraint  

This reduces complexity by focusing on the most impactful factor.

---

### Example

If:

- CPU is low  
- I/O latency is high  
- queues are growing  

Then:

- I/O is likely the limiting factor  

The system is not CPU-bound, even if CPU is active.

---

### Diagnostic implication

Performance is typically limited by a single dominant bottleneck at a given time.

Optimizing non-limiting resources produces little or no improvement.

---

### Key idea

Effective diagnosis reduces the system to its limiting factor.

---

## 3.10.6 Iterative analysis and validation

### Definition

Diagnosis is an iterative process of testing and refining hypotheses.

It evolves through successive observations and validations.

---

### Process

1. observe signals  
2. build hypothesis  
3. test through changes or measurements  
4. validate or reject  

Each step refines the understanding of the system.

---

### Example

```java
ExecutorService pool = Executors.newFixedThreadPool(10);

for (int i = 0; i < 1000; i++) {
    pool.submit(() -> {
        Thread.sleep(100);
        return null;
    });
}
```

Interpretation:

- fixed thread pool limits parallel execution  
- tasks accumulate  
- queueing increases latency  

This hypothesis can be tested by:

- increasing pool size  
- reducing blocking time  

---

### Validation

A hypothesis is validated if:

- changes produce expected effects  
- signals evolve consistently with the proposed mechanism  

If not, the hypothesis must be revised.

---

### Practical implications

- avoid one-step conclusions  
- iterate systematically  
- validate assumptions with observable data  

---

### Key idea

Diagnosis is a loop.

Understanding emerges through iteration, verification, and refinement.

