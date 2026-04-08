## 3.10 – Diagnostics and analysis

<a id="310-diagnostics-and-analysis"></a>

This chapter explains how performance problems are investigated, interpreted, and validated.

It focuses on the reasoning process used to move from observed behavior to a defensible explanation of system performance under load.

Diagnostics is not only a matter of collecting data.  
It is the discipline of interpreting that data correctly and connecting symptoms to mechanisms.

## Table of Contents

- [3.10.1 Observability and signals](#3101-observability-and-signals)
- [3.10.2 Symptom vs cause](#3102-symptom-vs-cause)
- [3.10.3 Correlation and causality](#3103-correlation-and-causality)
- [3.10.4 Building a hypothesis](#3104-building-a-hypothesis)
- [3.10.5 Narrowing down the bottleneck](#3105-narrowing-down-the-bottleneck)
- [3.10.6 Iterative analysis and validation](#3106-iterative-analysis-and-validation)

---

<a id="3101-observability-and-signals"></a>
## 3.10.1 Observability and signals

### Definition

Diagnostics starts from observable signals.

These signals provide indirect visibility into the internal behavior of the system under load.  
They do not expose mechanisms directly, but they reflect their effects.

This is why observability is essential in performance engineering: internal problems are rarely visible directly, but they usually leave measurable traces in latency, throughput, resource behavior, and queueing.

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

Latency shows user-visible impact.  
Throughput shows productive work.  
Error rate shows failure behavior.  
Resource metrics show where capacity is being consumed.  
Queues show where work is accumulating.

---

### Signal characteristics

Signals must be:

- **accurate** → reflect real behavior  
- **granular** → expose distribution (e.g. percentiles, not only averages)  
- **correlated in time** → aligned across components  

Without these properties, interpretation becomes unreliable or misleading.

A metric that is delayed, aggregated too heavily, or disconnected from the relevant time window may hide the very mechanism it is supposed to reveal.

---

### Signal quality and interpretation

The presence of signals is not sufficient by itself.

Signals must also be:

- relevant to the question being asked
- observed at the correct level (system, service, resource, dependency)
- interpreted in context

For example:

- CPU usage without run queue information may hide scheduling pressure
- average latency without percentiles may hide tail instability
- memory usage without GC behavior may hide runtime pressure

The diagnostic value of a metric depends not only on its existence, but on how it is combined with other evidence.

---

### Practical implications

Effective diagnostics requires:

- observing multiple signals together  
- correlating them over time  
- avoiding single-metric reasoning  

Looking at one metric in isolation often hides the underlying mechanism.

This is one of the main reasons why simplistic explanations are dangerous in performance analysis.

A single number may describe a symptom, but it rarely explains system behavior.

---

### Practical interpretation

Observability is the raw material of diagnostics.

Without signals, there is no reliable analysis.  
With poor signals, there is unreliable analysis.  
With well-structured signals, analysis becomes testable and repeatable.

Diagnostics therefore begins not with optimization, but with visibility.

---

### Key idea

Diagnostics depends on both the availability and the correct interpretation of observable signals.

---

<a id="3102-symptom-vs-cause"></a>
## 3.10.2 Symptom vs cause

### Definition

A symptom is an observable effect.

A cause is the underlying mechanism that produces that effect.

This distinction is fundamental because most performance problems are first seen through symptoms, not through direct visibility into the root cause.

---

### Distinction

Typical symptoms:

- high latency  
- high CPU usage  
- increased error rate  
- frequent garbage collection  

These describe *what is happening*, not *why it is happening*.

A system may show the same symptom for very different reasons, and the same cause may produce different symptoms depending on load, timing, and architecture.

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

This is why symptoms must be treated as entry points for investigation, not as explanations.

---

### Diagnostic implication

The same symptom can be produced by different causes.

Without identifying the underlying mechanism, corrective actions may target the wrong part of the system.

For example:

- reducing CPU usage may not reduce latency if the root cause is I/O queueing  
- tuning GC may not help if allocation rate remains unchanged  

A technically plausible fix may therefore have little effect if it addresses only a visible consequence.

---

### Why confusion happens

Symptoms and causes are often confused because symptoms are easier to observe.

Metrics, dashboards, and monitoring systems usually show:

- what is high
- what is slow
- what is failing

They do not automatically explain:

- why it is high
- why it is slow
- why it is failing

This gap between visibility and explanation is exactly what diagnostics must bridge.

---

### Practical interpretation

A good diagnostic process treats every symptom as a clue, not as a conclusion.

The goal is to move from:

- “this metric is abnormal”

to:

- “this mechanism is producing the abnormal behavior”

That shift is what distinguishes performance reasoning from superficial monitoring.

---

### Key idea

Observed behavior is not the cause.

Diagnosis requires mapping symptoms to the mechanisms that generate them.

---

<a id="3103-correlation-and-causality"></a>
## 3.10.3 Correlation and causality

### Definition

Correlation is the simultaneous variation of two signals.

Causality is a direct relationship where one factor produces another.

This distinction is essential in diagnostics because many metrics move together under load, but not all of them are causally related in the same direction.

---

### Common mistake

Two metrics change together:

- CPU increases  
- latency increases  

This does not imply that CPU is the cause of latency.

Correlation may indicate:

- a common underlying cause
- an indirect dependency
- a causal chain in the opposite direction
- or simple coincidence in the same time window

---

### Example

Possible interpretations:

- CPU saturation → scheduling delays → latency  
- I/O delays → more concurrent threads → higher CPU usage  
- contention → retries → both CPU and latency increase  

(→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))  
(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))

In all three cases, CPU and latency move together, but the underlying mechanism is different.

---

### Diagnostic implication

Correlation is a starting point, not a conclusion.

Multiple mechanisms can produce the same correlated signals.  
Only a causal model explains how one leads to the other.

For this reason, diagnostic reasoning must go beyond “these two metrics moved at the same time.”

It must explain:

- which changed first
- which mechanism links them
- why the observed sequence is consistent with system behavior

---

### Practical approach

To establish causality:

- identify the sequence of events  
- verify consistency with known system behavior  
- validate through observation or controlled change  

This may include:

- comparing before/after states
- observing whether one metric consistently leads another
- changing one condition and verifying the expected response

Causality becomes stronger when the system behaves as the proposed mechanism predicts.

---

### Limits of superficial analysis

A dashboard can show correlation very clearly.

It cannot, by itself, prove causation.

This is why diagnostics requires reasoning, not only visualization.

A performance engineer must ask:

- Is this metric the driver, the consequence, or another consequence of the same event?
- Does the timeline support the proposed explanation?
- Does the explanation remain consistent across repeated observations?

Without these questions, correlation can easily lead to incorrect conclusions.

---

### Practical interpretation

Good diagnostics treats correlation as a hypothesis generator.

It helps identify where to look, but it does not remove the need to reason about mechanisms.

This is especially important in complex systems where multiple bottlenecks interact and symptoms propagate across components.

---

### Key idea

Do not infer causation from correlation.

Diagnosis requires identifying the mechanism that links signals.

---

<a id="3104-building-a-hypothesis"></a>
## 3.10.4 Building a hypothesis

### Definition

A hypothesis is a proposed explanation linking observed signals to a system mechanism.

It provides a structured way to move from observation to explanation.

Without a hypothesis, analysis remains descriptive rather than diagnostic.

---

### Process

A hypothesis is built by:

1. observing signals  
2. identifying consistent patterns  
3. mapping them to known mechanisms  

(→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md))  
(→ [3.5 System behavior under load](./03-05-system-behavior-under-load.md))

This process transforms raw data into a testable explanation.

It connects:

- measurements
- system behavior
- causal reasoning

---

### Example

Observed:

- latency increases  
- queue length increases  
- CPU approaches saturation  

Hypothesis:

- increased arrival rate → queue buildup → longer waiting time → CPU saturation  

This connects observable signals to a queueing mechanism.

It also gives the investigation a direction: verify whether the latency increase is caused primarily by waiting rather than by slower service time.

---

### Requirements

A valid hypothesis must be:

- consistent with observed data  
- grounded in system behavior  
- testable through measurement or change  

A hypothesis that cannot be tested may be plausible, but it is not yet useful for diagnostics.

A hypothesis that contradicts observed evidence should be rejected even if it appears intuitive.

---

### Diagnostic implication

A hypothesis guides investigation.

Without it, analysis becomes reactive and unstructured.

Instead of moving directly from symptom to fix, the diagnostic process should move from:

- symptom  
- to candidate mechanism  
- to validation  

This structure reduces guesswork and makes diagnostic conclusions more robust.

---

### Sources of hypotheses

Hypotheses usually emerge from:

- observed signal combinations
- known performance patterns
- previous system behavior
- architectural knowledge
- repeated failure scenarios

For example:

- rising latency + growing queues often suggests queueing
- moderate CPU + blocked threads may suggest contention or I/O wait
- rising GC frequency + latency spikes may suggest memory pressure

These associations do not prove the explanation, but they provide a disciplined starting point.

---

### Practical interpretation

A good hypothesis is specific enough to test and broad enough to explain the observed behavior.

It should not be:

- vague (“the system is slow”)
- circular (“latency is high because requests are slow”)
- purely descriptive

It should express a mechanism.

For example:

- “Thread pool saturation is increasing queue time, which is driving p95 latency up.”

This kind of statement can be validated.

---

### Key idea

Diagnosis proceeds through explicit, testable hypotheses, not assumptions.

---

<a id="3105-narrowing-down-the-bottleneck"></a>
## 3.10.5 Narrowing down the bottleneck

### Definition

Diagnostics aims to identify the resource or mechanism that limits system performance.

This limiting factor determines the overall system behavior under load.

Until it is identified, optimization efforts remain uncertain and often ineffective.

---

### Approach

The analysis focuses on:

- CPU behavior  
- I/O latency  
- network delays  
- memory pressure  

(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))  
(→ [3.7 Runtime and memory model](./03-07-runtime-and-memory-model.md))

These dimensions are examined because most performance limits eventually manifest through one or more of them.

However, the dominant bottleneck at a given time is usually one primary constraint rather than all constraints equally.

---

### Method

- isolate one dimension at a time  
- compare signals across resources  
- identify the dominant constraint  

This reduces complexity by focusing on the most impactful factor.

The goal is not to explain every metric at once, but to find the mechanism currently governing system behavior.

---

### Example

If:

- CPU is low  
- I/O latency is high  
- queues are growing  

Then:

- I/O is likely the limiting factor  

The system is not CPU-bound, even if CPU is active.

This kind of narrowing is essential because multiple resources are often involved, but only one is usually dominant.

---

### Diagnostic implication

Performance is typically limited by a single dominant bottleneck at a given time.

Optimizing non-limiting resources produces little or no improvement.

This is one of the most important principles in diagnostics:

- measure broadly
- conclude narrowly

A broad set of signals is required to avoid missing important evidence.  
A narrow conclusion is required to focus action on the actual constraint.

---

### Why bottlenecks are difficult to identify

Bottlenecks are often obscured by secondary effects.

For example:

- slow I/O may increase thread count
- increased thread count may increase CPU scheduling overhead
- increased waiting may inflate memory retention
- retries may amplify demand on several components at once

As a result, the visible effect may not appear at the exact location of the original problem.

This is why narrowing down the bottleneck requires correlation across layers rather than isolated interpretation of one metric.

---

### Practical interpretation

The purpose of diagnosis is not only to say that the system is under pressure.

It is to identify:

- where pressure becomes limiting
- which mechanism produces the limit
- why that constraint is currently dominant

Only then does optimization become meaningful.

---

### Key idea

Effective diagnosis reduces the system to its limiting factor.

---

<a id="3106-iterative-analysis-and-validation"></a>
## 3.10.6 Iterative analysis and validation

### Definition

Diagnosis is an iterative process of testing and refining hypotheses.

It evolves through successive observations and validations.

This is necessary because initial explanations are often incomplete, partially correct, or valid only for one layer of the system.

---

### Process

1. observe signals  
2. build hypothesis  
3. test through changes or measurements  
4. validate or reject  

Each step refines the understanding of the system.

This loop is repeated until the proposed explanation is consistent with observed behavior and supported by evidence.

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

If latency decreases and queue buildup is reduced, the hypothesis gains support.

If behavior does not change as expected, the explanation must be revised.

---

### Validation

A hypothesis is validated if:

- changes produce expected effects  
- signals evolve consistently with the proposed mechanism  

If not, the hypothesis must be revised.

Validation therefore depends on consistency between:

- observed change
- expected change
- proposed causal explanation

A fix that changes one metric without improving system behavior may indicate that the wrong mechanism was targeted.

---

### Practical implications

- avoid one-step conclusions  
- iterate systematically  
- validate assumptions with observable data  

Good diagnostics is rarely instantaneous.

It becomes reliable through repeated comparison between:

- what is observed
- what is expected
- what actually changes after intervention

This iterative discipline is what turns troubleshooting into engineering.

---

### Why iteration matters

Complex systems rarely expose a complete explanation in a single observation.

It is common to discover that:

- an initial bottleneck was only a secondary effect
- removing one constraint exposes another
- a local improvement shifts the limiting factor elsewhere
- the system behaves differently under different workloads

Iteration is therefore not a sign of uncertainty.  
It is the normal method of reaching a stable explanation.

---

### Practical interpretation

Diagnosis is a loop because system understanding is built progressively.

The objective is not to guess correctly on the first attempt.

The objective is to move from evidence to explanation through controlled reasoning and verification.

This is what makes performance analysis repeatable and defensible.

---

### Key idea

Diagnosis is a loop.

Understanding emerges through iteration, verification, and refinement.