# 3.3 – Work of a performance engineer

This section describes what performance engineering is in practice and how it is applied to real systems.

## Table of Contents

- [3.3.1 What performance engineering is (in practice)](#331-what-performance-engineering-is-in-practice)
- [3.3.2 Typical workflow](#332-typical-workflow)
- [3.3.3 Black-box vs white-box](#333-black-box-vs-white-box)
- [3.3.4 Load testing vs diagnostics](#334-load-testing-vs-diagnostics)
- [3.3.5 What actually matters (and what doesn’t)](#335-what-actually-matters-and-what-doesnt)

---

## 3.3.1 What performance engineering is (in practice)

### Definition

Performance engineering is the discipline of understanding, measuring, and controlling how a system behaves under load.

It is not limited to performance testing, nor to a specific tool or technology.

It is a way of reasoning about systems under load or when they are stressed.

---

### Performance and non-functional requirements

Performance engineering does not focus on a single property.

When a system is exercised under load, a subset of **non-functional requirements (NFRs)** becomes visible:

- latency and throughput (performance)
- scalability (vertical and horizontal)
- stability and resilience under stress
- resource usage and efficiency
- capacity limits

These properties are not independent.

They emerge together as the system is pushed.

Load acts as a forcing function that reveals how the system behaves.

---

### What performance engineering actually observes

Under load, a system reveals:

- how work flows through its components
- how resources are consumed
- where contention appears
- where queues form
- which limits are reached first

This requires:

- understanding the system model (→ [3.1 Foundations](03-01-foundations.md))
- measuring key metrics (→ [3.2 Core metrics and formulas](03-02-core-metrics-and-formulas.md))
- identifying limiting factors

---

### Not just testing

Performance engineering is often reduced to load testing.

In practice, testing is only one part of the work.

Tests are used to:

- expose system behavior
- validate assumptions
- reproduce problems

But performance engineering also includes:

- analyzing system design
- investigating production issues
- dimensioning resources (heaps, pools, threads, connections)
- explaining observed behavior

---

### Practical perspective

In real scenarios, the work typically involves:

- preparing and calibrating test environments
- applying load or stress to reveal problems (often white-box)
- identifying and fixing bottlenecks
- validating behavior with controlled use cases
- dimensioning system components (CPUs, memory, pools, concurrency limits)
- tuning configuration and parameters
- running benchmarks to establish reference points
- executing long-duration (soak / endurance) tests to validate stability over time

These activities are not isolated.

They are part of a continuous process aimed at understanding system limits.

---

### Key idea

Performance engineering is not about making a system faster in isolation.

It is about understanding how a system behaves when it is pushed, and ensuring that it remains:

- predictable
- stable
- scalable

Most issues are not caused by a single slow operation, but by:

- interactions between components
- accumulation of waiting time
- saturation of shared resources

Understanding these mechanisms is the core of performance engineering.

---

## 3.3.2 Typical workflow

Performance engineering is an iterative process where the system is progressively exercised, analyzed, stabilized, and understood under increasing levels of load.

The objective is not only to detect problems, but to build a reliable model of how the system behaves under realistic conditions.

---

### 3.3.2.1 Environment preparation and calibration

- align test environment with production characteristics (as much as possible)
- verify configurations (CPU, memory, pools, connections)
- ensure observability (metrics, logs, traces)

Goal:

- establish a reliable baseline
- ensure repeatability of results

Without calibration, measurements are difficult to interpret.

---

### 3.3.2.2 Use case definition and workload modeling

Before applying load, the workload must be defined.

A system is not tested in isolation, but through the requests it processes.

This requires identifying:

- critical user and system paths
- typical operations (read, write, batch, background jobs)
- relative frequency of each operation
- concurrency patterns

A realistic workload includes:

- a mix of use cases
- weighted distribution (e.g. percentages of traffic)
- different request types and costs

---

### Non-functional requirements (NFRs)

In parallel with workload definition, non-functional requirements must be clarified.

These define what is considered acceptable system behavior.

Typical examples:

- throughput targets (e.g. 30 req/s)
- concurrency levels (e.g. 500 concurrent users)
- latency objectives (e.g. p95 < 200 ms)
- error rate thresholds
- resource usage constraints

NFRs may be:

- explicitly defined by stakeholders
- partially defined
- missing or inconsistent

In all cases, they must be:

- reviewed
- validated
- made measurable

---

### Practical implication

Workload and NFRs must be aligned.

For each use case:

- the expected load must be defined
- the acceptable behavior must be known

Otherwise:

- results cannot be evaluated
- tests cannot be considered successful or failed

Incorrect workload definition or missing NFRs leads to results that are technically correct but not actionable.

### 3.3.2.3 Initial load / stress testing (problem discovery)

The first phase under load aims to expose major issues.

Typical goals:

- identify obvious bottlenecks
- detect functional failures under load
- reveal instability (timeouts, crashes, saturation)

This phase is often:

- exploratory
- iterative
- partially white-box (using internal visibility)

The objective is discovery, not precision.

---

### 3.3.2.4 Analysis and bottleneck identification

Once issues appear, the system must be analyzed.

This involves:

- correlating metrics (latency, throughput, utilization)
- identifying where time is spent
- locating saturation points and queues

Typical questions:

- which resource is saturated?
- where does latency accumulate?
- what limits throughput?

This step relies on:

→ [3.1 Foundations](03-foundations.md)  
→ [3.2 Core metrics and formulas](03-02-core-metrics-and-formulas.md)

---

### 3.3.2.5 Fixes and iterative validation

After identifying bottlenecks, fixes are applied.

These may include:

- code changes
- configuration updates
- resource adjustments

Each fix must be validated by re-running tests.

This creates an iterative loop:

- test → analyze → fix → test again

The goal is to progressively stabilize the system.

---

### 3.3.2.6 Intermediate validation (stable baseline)

Before moving to long-duration tests, the system must reach a stable baseline.

This means:

- no critical failures under expected load
- predictable behavior
- controlled latency and error rates

This phase ensures that:

- major issues are resolved
- results are reproducible

---

### 3.3.2.7 Long-duration validation (soak / endurance)

Once the system is stable, it must be observed over time.

This phase evaluates behavior under sustained load.

Typical goals:

- detect memory leaks
- observe resource accumulation (threads, connections, buffers)
- identify performance degradation over time
- validate long-term stability

This phase is essential because some issues:

- do not appear immediately
- emerge only after prolonged execution

The results of this phase directly impact:

- system dimensioning
- capacity planning
- runtime configuration

---

### 3.3.2.8 Dimensioning and capacity definition

Based on previous observations, system components are dimensioned.

This includes:

- heap and memory configuration
- thread pools and connection pools
- concurrency limits
- infrastructure sizing

The goal is to define:

- how much load the system can handle
- under which conditions it remains stable
- what margins are required

Dimensioning must be based on observed behavior, not assumptions.

---

### 3.3.2.9 Tuning

Once dimensioning is defined, tuning refines system behavior.

Typical areas:

- garbage collection parameters
- thread scheduling and pool sizing
- database and connection settings
- caching strategies

Tuning aims to:

- reduce latency
- improve stability
- optimize resource usage

It is often iterative and context-dependent.

---

### 3.3.2.10 Verification and regression

After tuning, the system must be re-validated.

This includes:

- re-running key scenarios
- verifying that improvements are effective
- ensuring no regressions are introduced

This phase ensures consistency and reliability.

---

### 3.3.2.11 Benchmarking and reference points

Finally, benchmarks are established.

These provide:

- reference performance metrics
- comparison points across versions
- validation against expectations

Benchmarks are not goals by themselves.

They are used to:

- understand system behavior
- track evolution over time

---

### Key idea

Performance engineering is an iterative loop:

- define workload → test → analyze → fix → validate → optimize

The objective is not only to improve performance, but to understand system limits and ensure predictable behavior under load.