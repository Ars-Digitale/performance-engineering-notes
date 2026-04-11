# 1.3 – Work of a performance engineer

<a id="13-work-of-a-performance-engineer"></a>

This section describes what performance engineering is, in practice, and how it is applied to real systems.

## Table of Contents

- [1.3.1 What performance engineering is (in practice)](#131-what-performance-engineering-is-in-practice)
- [1.3.2 Typical workflow](#132-typical-workflow)
- [1.3.3 Black-box vs white-box](#133-black-box-vs-white-box)
- [1.3.4 Load testing vs diagnostics](#134-load-testing-vs-diagnostics)
- [1.3.5 What actually matters (and what does not)](#135-what-actually-matters-and-what-doesnt)

---

<a id="131-what-performance-engineering-is-in-practice"></a>
## 1.3.1 What performance engineering is (in practice)

### Definition

Performance engineering is the discipline that consists in understanding, measuring, and controlling the way a system behaves under load.

It is limited neither to performance testing, nor to specific tools or technologies.

It refers rather to an overall methodology for reasoning about systems under load or, possibly, under stress.

It focuses on the overall behavior of the system and not on isolated metrics or on individual components.

---

### Performance and non-functional requirements

Performance engineering does not focus on a single property.

When a system is exercised under load, a subset of **non-functional requirements (NFRs)** becomes visible:

- latency and throughput (performance)
- scalability (vertical and horizontal)
- stability and resilience under stress
- resource usage and efficiency
- capacity limits

These properties are not independent of one another.

They all emerge together as the system is brought to its limits.

Load acts as a **forcing function** that reveals the way the system behaves.

A system that appears perfectly balanced under low load may show completely different behavior when it is stressed.

---

### What performance engineering actually observes

Under load, a system reveals:

- how work passes through its components
- how resources are consumed
- where contentions appear
- where queues form
- which limits are reached first

This requires:

- understanding the system model (→ [1.1 Foundations](01-01-foundations.md))
- measuring key metrics (→ [1.2 Core metrics and formulas](01-02-core-metrics-and-formulas.md))
- identifying limiting factors

The objective, evidently, is not only to observe system behavior, but also to explain it.

---

### Not just testing

Performance engineering is often reduced to **load testing** alone.

In practice, the testing phase is only one part of the work.

Tests are used to:

- expose system behavior
- validate assumptions
- reproduce problems

But performance engineering also includes:

- analyzing system design
- investigating production issues
- sizing resources (heap, pools, threads, connections)
- explaining observed behavior

Testing without analysis produces data without understanding.

---

### Practical perspective

In real scenarios, the work typically involves:

- preparing and calibrating test environments
- interpreting non-functional requirements (NFRs)
- identifying and defining (meaningful) test scenarios with respect to NFRs
- validating behavior with controlled use cases
- applying load or stress to make problems emerge (often in white-box)
- identifying and correcting bottlenecks
- sizing system components (CPU, memory, pools, concurrency limits)
- refining configurations and parameters (Tuning)
- running benchmarks to establish reference points
- running long-duration tests (soak / endurance) to validate stability over time

These activities are not isolated.

They are part of a continuous process aimed at understanding the system’s possibilities and limits.

---

### Key idea

Performance engineering does not consist (only) in making a system faster and more performant.

It instead comprises a set of activities and tasks aimed at understanding how a system behaves under workload, and at ensuring that it remains:

- predictable
- stable
- scalable

Most problems are not caused by a single “slow” operation, but by:

- interactions between components
- accumulation of waiting times
- saturation of shared resources

Taken together, these mechanisms form the core of performance engineering.

---

<a id="132-typical-workflow"></a>
## 1.3.2 Typical workflow

Performance engineering is an iterative process in which the system is progressively exercised, analyzed, stabilized, and understood under increasing levels of load.

The objective is not only to detect problems, but to build a reliable model of how the system behaves under realistic (and limit) production conditions.

---

<a id="1321-environment-preparation-and-calibration"></a>
### 1.3.2.1 Environment preparation and calibration

- verify and align the test environment with production characteristics (as much as possible)
- verify configurations (CPU, memory, pools, connections)
- ensure observability (metrics, logs, traces)

Goal:

- establish a reliable baseline
- ensure repeatability of results

Without calibration, measurements are difficult (or impossible) to interpret, and comparisons become at the very least unreliable.

---

<a id="1322-use-case-definition-and-workload-modeling"></a>
### 1.3.2.2 Use case definition and workload modeling

Before applying load to the system, the workload must be defined.

A system is not tested in isolation, but through the requests it processes.

This requires the precise identification of:

- critical user and system paths
- typical operations (read, write, batch, background job)
- the relative frequency of each operation
- concurrency patterns

A realistic workload includes:

- a mix of use cases
- a weighted distribution (e.g. traffic percentages)
- different request types and different costs

Workload definition is one of the most critical steps and must be carried out in close collaboration with those who define the non-functional requirements (NFRs).

An incorrect workload leads to misleading conclusions, or even to conclusions that are entirely useless.

---

<a id="1322-non-functional-requirements"></a>
### Non-functional requirements (NFR)

In parallel with workload definition, **non-functional requirements** must be clarified.

They define what is considered **acceptable system behavior**.

Typical examples:

- throughput targets (e.g. 30 req/s)
- concurrency levels (e.g. 500 concurrent users)
- latency objectives (e.g. p95 < 200 ms)
- error rate thresholds
- resource usage constraints

NFRs may be:

- explicitly defined by stakeholders
- only partially defined
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
- tests cannot be considered either successful or failed

An incorrect workload definition or the absence of NFRs leads to results that are technically correct, but not actionable.

---

<a id="1323-initial-load-stress-testing"></a>
### 1.3.2.3 Initial load / stress testing (problem discovery)

The first “load test” phase aims to establish a reference baseline and possible major problems.

Typical goals:

- identify obvious bottlenecks
- detect functional errors under load
- make instability emerge (timeouts, crashes, saturation)

This phase is often:

- exploratory
- iterative
- partially white-box (using internal visibility)

The objective is discovery, not precision.

---

<a id="1324-analysis-and-bottleneck-identification"></a>
### 1.3.2.4 Analysis and bottleneck identification

Once problems have emerged, the system must be analyzed in detail.

This involves:

- correlating metrics (latency, throughput, utilization)
- identifying where time is spent
- locating saturation points and queues

Typical questions:

- which resource is saturated?
- where does latency accumulate?
- what limits throughput?

This step is based on:

→ [1.1 Foundations](01-01-foundations.md)  
→ [1.2 Core metrics and formulas](01-02-core-metrics-and-formulas.md)

---

<a id="1325-fixes-and-iterative-validation"></a>
### 1.3.2.5 Fixes and iterative validation

After bottlenecks have been identified, corrective actions must be applied.

These may include:

- code changes
- configuration updates
- resource adjustments (vertical/horizontal scalability)

Each fix must be validated by re-running the tests.

This creates an iterative loop:

- **Test** → **Analyze** → **Fix** → **Test** again

The goal is to progressively stabilize the system.

---

<a id="1326-intermediate-validation"></a>
### 1.3.2.6 Intermediate validation (stable baseline)

Before moving on to further and long-duration tests, the system must reach a stable baseline.

This means:

- no critical errors under expected load
- predictable behavior
- latency and error rates under control

This phase ensures that:

- major issues are resolved
- results are reproducible

---

<a id="1327-long-duration-validation"></a>
### 1.3.2.7 Long-duration validation (soak / endurance)

Once it has been ensured that the system is stable, it must be investigated over time.

This phase evaluates the system’s behavior under sustained workload over time.

Typical goals:

- detect slow memory leaks
- observe resource accumulation (threads, connections, buffers)
- identify performance degradations over time
- validate long-term stability

This phase is essential because some issues:

- do not appear immediately
- emerge only after prolonged exercise

The results of this phase have a direct impact on:

- system sizing
- capacity planning
- runtime configuration

---

<a id="1328-dimensioning-and-capacity-definition"></a>
### 1.3.2.8 Dimensioning and capacity definition

Based on previous observations, and also starting from possible unit tests subsequent to the baseline stabilization phase, system components are sized.

This phase includes:

- heap and memory configuration
- thread pools and connection pools
- concurrency limits
- infrastructure sizing
- clustering

The goal is to define:

- how much load the system can handle
- under which conditions it remains stable
- which possible margins are required

Sizing must be based on observed behavior, not on assumptions.

---

<a id="1329-tuning"></a>
### 1.3.2.9 Tuning

Once sizing has been defined, tuning refines system behavior.

Typical areas:

- garbage collector parameters
- thread scheduling and pool sizing
- database and connection settings
- caching strategies

Tuning aims to:

- reduce latency
- improve stability
- optimize resource usage

It is often iterative and dependent on the specific context.

---

<a id="13210-verification-and-regression"></a>
### 1.3.2.10 Verification and regression

After the tuning phase, the system must be validated again.

This includes:

- re-running key scenarios
- verifying that improvements are effective
- ensuring that regressions are not introduced

This phase ensures consistency and reliability.

---

<a id="13211-benchmarking"></a>
### 1.3.2.11 Benchmarking and reference points

Finally, benchmarks are established.

They provide:

- reference performance metrics
- comparison points between versions
- validation against expectations

Benchmarks are not goals in themselves.

They are used to:

- understand system behavior
- track its evolution over time

---

### Key idea

Performance engineering develops according to an iterative loop:

- **define the workload** → **test** → **analyze** → **fix** → **validate** → **optimize**

The objective is not only to improve performance, but to understand system limits and ensure predictable behavior under load.

---

<a id="133-black-box-vs-white-box"></a>
## 1.3.3 Black-box vs white-box

Performance engineering can be approached from two complementary perspectives:

- **black-box** (external observation)
- **white-box** (internal observation)

Both are necessary to understand system behavior under workload.

---

<a id="1331-black-box"></a>
### 1.3.3.1 Black-box approach

In a black-box approach, the system is observed from the outside.

Only externally visible behavior is measured:

- response time
- throughput
- error rate

Internal implementation is not taken into consideration.

---

### What it provides

Black-box observation allows:

- validating system behavior from the user’s point of view
- measuring end-to-end performance
- detecting visible errors under load

It answers questions such as:

- Is the system fast enough?
- Does it handle the expected load?
- Does it fail under stress?

---

### Limitations

Black-box alone cannot explain:

- where time is most often spent
- which resource is saturated
- why performance degrades

It shows symptoms, not causes.

---

<a id="1332-white-box"></a>
### 1.3.3.2 White-box approach

In a white-box approach, the internal behavior of the system is observed.

This includes:

- resource utilization (CPU, memory, disk, network)
- thread pools and connection pools
- internal queues
- component-level timings

White-box observation provides a level of **introspection into system execution**.

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
- Where does latency accumulate?
- What limits throughput?
- Which part of the execution is responsible for the slowdown?

---

### Limitations

White-box alone does not guarantee:

- correct end-to-end behavior
- acceptable user experience

A system may appear internally efficient, while still failing under real workload conditions.

---

<a id="1333-observability-and-tooling"></a>
### 1.3.3.3 Observability and instrumentation

Observability provides the data required for white-box analysis.

It typically includes:

- system and application metrics (e.g. CPU usage, latency, throughput)
- logs (events, errors, state changes)
- traces (request flow between components)
- application performance monitoring (APM)

These sources provide continuous visibility into system behavior.

---

### Diagnostic artifacts

In addition to continuous observability, deeper analysis is often based on diagnostic artifacts.

These are typically collected on demand and provide a snapshot of the system state.

Common examples include:

- thread dumps (thread states, locks, contention)
- heap dumps (memory usage, object retention, leaks)
- profiling snapshots (CPU profiling and allocations)
- core dumps (process-level failure analysis)

These artifacts allow:

- inspecting the internal state of execution
- identifying blocked threads and deadlocks
- analyzing memory leaks and retention paths
- investigating performance anomalies in detail

They are generally heavier and more intrusive than observability tools, and are used selectively during diagnostics.

---

<a id="1334-combining-both"></a>
### 1.3.3.4 Combining both approaches

Effective performance engineering requires combining both perspectives.

Typical workflow:

- use black-box to detect problems
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

<a id="134-load-testing-vs-diagnostics"></a>
## 1.3.4 Load testing vs diagnostics

Load testing and diagnostics are often confused.

They serve different purposes and operate at different levels.

Both are necessary to understand system behavior under workload.

---

<a id="1341-load-testing"></a>
### 1.3.4.1 Load testing

Load testing applies a controlled workload to the system.

It is used to:

- observe behavior under specific conditions
- measure latency, throughput, and error rates
- validate assumptions about capacity and scalability

Load testing operates primarily at the **black-box** level:

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

<a id="1342-diagnostics"></a>
### 1.3.4.2 Diagnostics

Diagnostics investigates the internal behavior of the system.

It is used to:

- identify bottlenecks
- understand execution paths
- analyze resource usage
- explain observed performance issues

Diagnostics operates at the **white-box** level:

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

Diagnostics without load testing may fail to capture:

- real workload conditions
- interactions between components
- behavior under stress

It can explain a problem, but not necessarily reproduce it.

---

<a id="1343-relationship-between-load-testing-and-diagnostics"></a>
### 1.3.4.3 Relationship between load testing and diagnostics

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

Neither of the two is sufficient on its own.

Understanding system behavior requires both.

---

<a id="135-what-actually-matters-and-what-doesnt"></a>
## 1.3.5 What actually matters (and what does not)

Performance engineering involves an extensive set of tools, metrics, and techniques.

However, not all of them can have the same level of importance in heterogeneous contexts.

Understanding what matters is essential to avoid wasting effort and drawing incorrect conclusions.

---

### What matters

The most important aspects are:

- **understanding system behavior under load**
- **identifying bottlenecks and limiting factors**
- **using realistic workloads and validated NFRs**
- **reasoning about interactions between components**
- **measuring and interpreting results correctly**

Performance engineering mainly concerns:

- building a mental model of the system
- validating that model through observations
- refining it through iteration

---

### What does not matter (as much as it seems)

Some aspects are often excessively emphasized:

- tools and frameworks
- isolated metrics without context
- synthetic or unrealistic test scenarios
- micro-optimizations without system-level impact
- results of a single test taken in isolation

These elements may be useful, but they are not sufficient.

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

Focusing on a single part of the system is rarely sufficient.

What is required is a global view.

---

### Practical implication

Effective performance engineering requires:

- asking the right questions
- validating assumptions
- correlating multiple signals
- iterating on the basis of evidence

Tools, tests, and metrics support this process, but do not replace it.

---

### Key idea

Performance engineering does not consist in collecting data.

It concerns understanding what the data means.

The goal is not to produce numbers, but to explain system behavior and make informed decisions.