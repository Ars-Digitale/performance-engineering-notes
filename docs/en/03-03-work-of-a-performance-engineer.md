# 3.3 – Work of a performance engineer

<a id="33-work-of-a-performance-engineer"></a>

This section describes what performance engineering is in practice and how it is applied to real systems.

## Table of Contents

- [3.3.1 What performance engineering is (in practice)](#331-what-performance-engineering-is-in-practice)
- [3.3.2 Typical workflow](#332-typical-workflow)
- [3.3.3 Black-box vs white-box](#333-black-box-vs-white-box)
- [3.3.4 Load testing vs diagnostics](#334-load-testing-vs-diagnostics)
- [3.3.5 What actually matters (and what doesn’t)](#335-what-actually-matters-and-what-doesnt)

---

<a id="331-what-performance-engineering-is-in-practice"></a>
## 3.3.1 What performance engineering is (in practice)

### Definition

Performance engineering is the discipline of understanding, measuring, and controlling how a system behaves under load.

It is not limited to performance testing, nor to a specific tool or technology.

It is a way of reasoning about systems under load or when they are stressed.

It focuses on behavior as a whole, not on isolated metrics or individual components.

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

A system that appears correct under low load may exhibit completely different behavior when stressed.

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

The objective is not only to observe behavior, but also to explain it.

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

Testing without analysis produces data without understanding.

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

<a id="332-typical-workflow"></a>
## 3.3.2 Typical workflow

Performance engineering is an iterative process where the system is progressively exercised, analyzed, stabilized, and understood under increasing levels of load.

The objective is not only to detect problems, but to build a reliable model of how the system behaves under realistic conditions.

---

<a id="3321-environment-preparation-and-calibration"></a>
### 3.3.2.1 Environment preparation and calibration

- verify and align test environment with production characteristics (as much as possible)
- verify configurations (CPU, memory, pools, connections)
- ensure observability (metrics, logs, traces)

Goal:

- establish a reliable baseline
- ensure repeatability of results

Without calibration, measurements are difficult to interpret and comparisons become unreliable.

---

<a id="3322-use-case-definition-and-workload-modeling"></a>
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

Workload definition is one of the most critical steps.

Incorrect workload leads to misleading conclusions.

---

<a id="3322-non-functional-requirements"></a>
### Non-functional requirements (NFRs)

In parallel with workload definition, **non-functional requirements** must be clarified.

These define what is considered an **acceptable system behavior**.

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

---

<a id="3323-initial-load-stress-testing"></a>
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

<a id="3324-analysis-and-bottleneck-identification"></a>
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

→ [3.1 Foundations](03-01-foundations.md)  
→ [3.2 Core metrics and formulas](03-02-core-metrics-and-formulas.md)

---

<a id="3325-fixes-and-iterative-validation"></a>
### 3.3.2.5 Fixes and iterative validation

After identifying bottlenecks, fixes are applied.

These may include:

- code changes
- configuration updates
- resource adjustments

Each fix must be validated by re-running tests.

This creates an iterative loop:

- **Test** → **Analyze** → **Fix** → **Test** again

The goal is to progressively stabilize the system.

---

<a id="3326-intermediate-validation"></a>
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

<a id="3327-long-duration-validation"></a>
### 3.3.2.7 Long-duration validation (soak / endurance)

Once the system is stable, it must be observed over time.

This phase evaluates behavior under sustained load.

Typical goals:

- detect slow memory leaks
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

<a id="3328-dimensioning-and-capacity-definition"></a>
### 3.3.2.8 Dimensioning and capacity definition

Based on previous observations and also from unitary testing after the phase of baseline stabilization, system components are dimensioned.

This includes:

- heap and memory configuration
- thread pools and connection pools
- concurrency limits
- infrastructure sizing
- clustering

The goal is to define:

- how much load the system can handle
- under which conditions it remains stable
- what margins are required

Dimensioning must be based on observed behavior, not assumptions.

---

<a id="3329-tuning"></a>
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

<a id="33210-verification-and-regression"></a>
### 3.3.2.10 Verification and regression

After tuning, the system must be re-validated.

This includes:

- re-running key scenarios
- verifying that improvements are effective
- ensuring no regressions are introduced

This phase ensures consistency and reliability.

---

<a id="33211-benchmarking"></a>
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

- **define workload** → **test** → **analyze** → **fix** → **validate** → **optimize**

The objective is not only to improve performance, but to understand system limits and ensure predictable behavior under load.

---

<a id="333-black-box-vs-white-box"></a>
## 3.3.3 Black-box vs white-box

Performance engineering can be approached from two complementary perspectives:

- black-box (external observation)
- white-box (internal observation)

Both are required to understand system behavior under load.

---

<a id="3331-black-box"></a>
### 3.3.3.1 Black-box approach

In a black-box approach, the system is observed from the outside.

Only externally visible behavior is measured:

- response time
- throughput
- error rate

The internal implementation is not considered.

---

### What it provides

Black-box observation allows:

- validating system behavior from a user perspective
- measuring end-to-end performance
- detecting visible failures under load

It answers questions such as:

- Is the system fast enough?
- Does it handle the expected load?
- Does it fail under stress?

---

### Limitations

Black-box alone cannot explain:

- where time is spent
- which resource is saturated
- why performance degrades

It shows symptoms, not causes.

---

<a id="3332-white-box"></a>
### 3.3.3.2 White-box approach

In a white-box approach, internal system behavior is observed.

This includes:

- resource utilization (CPU, memory, disk, network)
- thread and connection pools
- internal queues
- component-level timings

White-box observation provides a level of **introspection into the system execution**.

In many cases, this includes visibility close to the code level:

- method-level timings
- call paths and execution flows
- hotspots (slow or frequently executed methods)
- allocation patterns and memory behavior
- lock contention and synchronization points

---

### What it provides

White-box observation allows:

- identifying bottlenecks
- understanding where time is spent
- detecting contention and queueing
- analyzing resource saturation

It answers questions such as:

- Which component is slow?
- Where is latency accumulated?
- What limits throughput?
- Which part of the execution is responsible for the slowdown?

---

### Limitations

White-box alone does not guarantee:

- correct end-to-end behavior
- acceptable user experience

A system can appear efficient internally but still fail under real workload conditions.

---

<a id="3333-observability-and-tooling"></a>
### 3.3.3.3 Observability and tooling

Observability provides the data required for white-box analysis.

It typically includes:

- system and application metrics (e.g. CPU usage, latency, throughput)
- logs (events, errors, state changes)
- traces (request flow across components)
- application performance monitoring (APM)

These sources provide continuous visibility into system behavior.

---

### Diagnostic artifacts

In addition to continuous observability, deeper analysis often relies on diagnostic artifacts.

These are typically collected on demand and provide a snapshot of the system state.

Common examples include:

- thread dumps (thread states, locks, contention)
- heap dumps (memory usage, object retention, leaks)
- profiling snapshots (CPU and allocation profiling)
- core dumps (process-level failure analysis)

These artifacts allow:

- inspection of internal execution state
- identification of blocking threads and deadlocks
- analysis of memory leaks and retention paths
- detailed investigation of performance anomalies

They are usually heavier and more intrusive than observability tools, and are used selectively during diagnostics.

---

<a id="3334-combining-both"></a>
### 3.3.3.4 Combining both approaches

Effective performance engineering requires combining both perspectives.

Typical workflow:

- use black-box to detect issues
- use white-box to explain them
- validate improvements again with black-box

This creates a feedback loop:

- **observe** → **analyze** → **fix** → **validate**

---

### Key idea

**Black-box** observation reveals that a problem exists.

**White-box** observation explains why it exists.

Both are necessary to understand and control system behavior under load.

---

<a id="334-load-testing-vs-diagnostics"></a>
## 3.3.4 Load testing vs diagnostics

Load testing and diagnostics are often confused.

They serve different purposes and operate at different levels.

Both are required to understand system behavior under load.

---

<a id="3341-load-testing"></a>
### 3.3.4.1 Load testing

Load testing applies controlled workload to the system.

It is used to:

- observe behavior under specific conditions
- measure latency, throughput, and error rates
- validate assumptions about capacity and scalability

Load testing operates primarily at the **black-box level**:

- requests are generated externally
- responses are measured externally

---

### What it provides

Load testing answers questions such as:

- Can the system handle the expected load?
- What happens when load increases?
- When does performance degrade?
- What is the maximum sustainable throughput?

---

### Limitations

Load testing alone does not explain:

- why the system slows down
- which component is responsible
- how resources are used internally

It reveals behavior, but not causes.

---

<a id="3342-diagnostics"></a>
### 3.3.4.2 Diagnostics

Diagnostics investigates the internal behavior of the system.

It is used to:

- identify bottlenecks
- understand execution paths
- analyze resource usage
- explain observed performance issues

Diagnostics operates at the **white-box level**:

- internal metrics are analyzed
- traces and execution paths are inspected
- diagnostic artifacts may be collected

---

### What it provides

Diagnostics answers questions such as:

- Where is time spent?
- Which resource is saturated?
- Which component is responsible for latency?
- What causes performance degradation?

---

### Tools and techniques

Diagnostics typically relies on:

- metrics, logs, and traces
- application performance monitoring (APM)
- thread dumps and heap dumps
- profiling and execution analysis

---

### Limitations

Diagnostics without load testing may miss:

- real workload conditions
- interactions between components
- behavior under stress

It can explain a problem, but not necessarily reproduce it.

---

<a id="3343-relationship-between-load-testing-and-diagnostics"></a>
### 3.3.4.3 Relationship between load testing and diagnostics

Load testing and diagnostics must be combined.

Typical workflow:

- apply load to expose behavior
- use diagnostics to analyze internal state
- apply fixes
- validate again with load testing

This creates a loop:

- observe → explain → fix → validate

---

### Key idea

Load testing reveals that a problem exists.

Diagnostics explains why it exists.

Neither is sufficient on its own.

Understanding system behavior requires both.

---

<a id="335-what-actually-matters-and-what-doesnt"></a>
## 3.3.5 What actually matters (and what doesn’t)

Performance engineering involves many tools, metrics, and techniques.

However, not all of them are equally important.

Understanding what matters is essential to avoid wasting effort and drawing incorrect conclusions.

---

### What matters

The most important aspects are:

- **understanding system behavior under load**
- **identifying bottlenecks and limiting factors**
- **using realistic workloads and validated NFRs**
- **reasoning about interactions between components**
- **measuring and interpreting results correctly**

Performance engineering is primarily about:

- building a mental model of the system
- validating that model with observations
- refining it through iteration

---

### What does not matter (as much as it seems)

Some aspects are often overemphasized:

- tools and frameworks
- isolated metrics without context
- synthetic or unrealistic test scenarios
- micro-optimizations without system-level impact
- single test results taken in isolation

These elements can be useful, but they are not sufficient.

---

### Common misconceptions

Several misconceptions frequently appear:

- “If I run a load test, I understand the system”
- “If CPU is low, the system is healthy”
- “If average latency is acceptable, the system is fine”
- “More hardware will solve the problem”

These assumptions often lead to incorrect conclusions.

---

### System-level thinking

Performance emerges from interactions:

- between components
- between workload and resources
- between concurrency and queueing

Focusing on a single part of the system is rarely enough.

Understanding requires a global view.

---

### Practical implication

Effective performance engineering requires:

- asking the right questions
- validating assumptions
- correlating multiple signals
- iterating based on evidence

Tools, tests, and metrics support this process, but do not replace it.

---

### Key idea

Performance engineering is not about collecting data.

It is about understanding what the data means.

The goal is not to produce numbers, but to explain system behavior and make informed decisions.