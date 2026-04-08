## 1.11 – Practical checklists

<a id="111-practical-checklists"></a>

This chapter provides practical checklists for preparing, running, and analyzing performance tests.

Unlike the previous chapters, which explain concepts and mechanisms, this chapter focuses on operational discipline.

The goal is to reduce avoidable mistakes and ensure that performance tests produce results that are interpretable, reliable, and useful.

## Table of Contents

- [1.11.1 Before running a test](#1111-before-running-a-test)
- [1.11.2 During test execution](#1112-during-test-execution)
- [1.11.3 After test analysis](#1113-after-test-analysis)
- [1.11.4 Common pitfalls](#1114-common-pitfalls)

---

<a id="1111-before-running-a-test"></a>
## 1.11.1 Before running a test

### Objectives

Clearly define what the test is intended to validate.

Typical objectives include:

- latency targets  
- throughput goals  
- capacity limits  

A test without a clear objective may still generate data, but that data will be difficult to evaluate.

The first question should always be:

- what is this test supposed to prove, validate, or reveal?

---

### Workload definition

Define the workload precisely:

- request rate or concurrency  
- request mix  
- duration  

(→ [1.4 Types of performance tests](./01-04-types-of-performance-tests.md))

The workload must be specific enough to be reproducible and realistic enough to be meaningful.

A vague or artificial workload can produce technically correct results that are operationally irrelevant.

---

### Environment consistency

Ensure that:

- test environment is stable  
- configuration matches production assumptions  
- external dependencies are controlled  

If the environment changes during testing, interpretation becomes uncertain.

Performance results are only comparable if the execution conditions remain sufficiently consistent.

This is especially important when evaluating:

- configuration changes
- code changes
- infrastructure changes

---

### Metrics setup

Verify that all required metrics are available:

- latency percentiles  
- throughput  
- resource utilization  
- error rate  

(→ [1.2 Core metrics and formulas](./01-02-core-metrics-and-formulas.md))

It is also useful to ensure that supporting signals are available when relevant, such as:

- queue lengths
- dependency timings
- GC activity
- thread or pool states

The test should not begin before visibility is in place.

---

### Readiness checks

Before running the test, confirm that:

- the target system is in the expected state
- monitoring is active
- the workload generator is configured correctly
- the test duration is appropriate for the chosen objective
- success and failure criteria are known in advance

This avoids a common problem in performance testing: running a technically valid test that cannot later be interpreted with confidence.

---

### Practical interpretation

Preparation is part of the test.

Most unreliable results are not caused by complex system behavior, but by poor test preparation:

- unclear objectives
- unrealistic workload
- inconsistent environment
- incomplete metrics

A well-prepared test makes later diagnostics far easier.

---

### Key idea

A test is only meaningful if objectives, workload, and measurements are clearly defined.

---

<a id="1112-during-test-execution"></a>
## 1.11.2 During test execution

### Monitoring

Observe system behavior in real time:

- latency evolution  
- throughput stability  
- resource usage  

Monitoring during execution is important because some issues are visible only while the test is running, especially:

- sudden saturation
- unexpected queueing
- unstable recovery
- dependency failures

Waiting until the end of the test may hide important time-dependent behavior.

---

### Consistency checks

Ensure that:

- workload is applied as expected  
- no external disturbances affect the test  

This includes verifying that:

- the intended request rate is actually being generated
- the mix of operations remains consistent
- no unrelated activity is distorting results
- failures are caused by the test conditions rather than by external noise

A mismatch between intended workload and actual workload can invalidate the entire interpretation.

---

### Early signals

Watch for:

- rapid latency increase  
- unexpected errors  
- resource saturation  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

These are often the first signs that the system is approaching a limit or that the workload is exposing an unanticipated bottleneck.

Early detection matters because it allows the test operator to:

- capture relevant evidence
- preserve useful context
- avoid losing the most informative part of the run

---

### Runtime observations

During execution, it is useful to observe not only absolute values, but also change over time.

Examples:

- latency rising while throughput remains flat
- queue lengths growing before CPU saturation
- errors appearing only after a specific threshold
- p95/p99 degrading before the average changes significantly

These patterns often reveal more than isolated snapshots.

They help distinguish:

- transient instability
- steady overload
- slow degradation
- sudden collapse

---

### Intervention discipline

During a test, avoid changing parameters unless the change is part of the test plan.

Unplanned intervention makes results harder to interpret because it mixes multiple causes into the same observation window.

If intervention becomes necessary, it should be:

- documented
- timestamped
- explicitly linked to the observed behavior

This preserves the diagnostic value of the run.

---

### Practical interpretation

Execution is the phase where theoretical preparation meets real system behavior.

A well-designed test can still become misleading if the operator does not confirm that:

- the workload is correct
- the environment remains stable
- the system is behaving as expected or, importantly, as unexpectedly as the test was intended to reveal

---

### Key idea

Execution is not passive.

Continuous observation is required to detect anomalies early.

---

<a id="1113-after-test-analysis"></a>
## 1.11.3 After test analysis

### Data review

Analyze collected data:

- latency distribution  
- throughput trends  
- resource utilization  

Data review should focus not only on average values, but also on the shape of behavior over time.

For example:

- when degradation began
- whether throughput scaled as expected
- whether tail latency widened before failures appeared

This makes the analysis more diagnostic and less descriptive.

---

### Correlation

Relate signals:

- latency vs CPU  
- latency vs I/O  
- errors vs load  

(→ [1.10 Diagnostics and analysis](./01-10-diagnostics-and-analysis.md))

Correlation helps identify which resource or mechanism is most likely associated with the observed degradation.

However, correlation should be treated as an analytical starting point, not a final conclusion.

---

### Interpretation

Identify:

- bottlenecks  
- scaling limits  
- abnormal patterns  

Interpretation should answer questions such as:

- what changed first?
- what degraded next?
- which constraint became dominant?
- was the degradation gradual, abrupt, or time-dependent?

This is the point where raw measurements become system understanding.

---

### Reporting

Summarize:

- observed behavior  
- identified issues  
- recommendations  

A useful report does more than list numbers.

It should explain:

- what the system was expected to do
- what it actually did
- where it diverged from expectations
- what evidence supports the conclusion

This makes the results actionable for engineering, operations, and future testing.

---

### Next-step orientation

After analysis, define what should happen next.

This may include:

- re-running the same test after changes
- refining workload realism
- collecting deeper diagnostics
- isolating a suspected bottleneck
- expanding to stress, soak, or capacity testing

Without a next-step decision, analysis remains informative but not operationally useful.

---

### Practical interpretation

Post-test analysis is where performance engineering becomes decision-making.

The purpose is not only to state that a metric changed, but to explain:

- why the change matters
- what it implies about the system
- what should be done next

---

### Key idea

Analysis transforms raw data into actionable understanding.

---

<a id="1114-common-pitfalls"></a>
## 1.11.4 Common pitfalls

### Misinterpreting averages

- averages hide tail latency  
- percentiles provide a clearer view  

(→ [1.2.7 Percentiles](./01-02-core-metrics-and-formulas.md#127-percentiles-p50-p95-p99))

A system can appear healthy on average while still producing unacceptable performance for a meaningful fraction of requests.

This is one of the most common mistakes in test interpretation.

---

### Ignoring workload realism

- unrealistic workloads produce misleading results  
- production patterns must be approximated  

A synthetic workload may be easier to generate, but if it does not reflect real request mix, concurrency, and dependency behavior, conclusions may not transfer to production conditions.

Realism does not require perfect reproduction, but it does require credible approximation.

---

### Confusing symptom and cause

- high CPU is not always the root problem  
- latency must be analyzed in context  

(→ [1.10 Diagnostics and analysis](./01-10-diagnostics-and-analysis.md))

This pitfall often leads to ineffective optimization.

The visible symptom may be only the consequence of a deeper mechanism such as queueing, blocking, or dependency slowdown.

---

### Overlooking bottlenecks

- optimizing non-limiting resources has little effect  
- focus must remain on the dominant constraint  

(→ [1.8 Resource-level performance](./01-08-resource-level-performance.md))

This is a frequent source of wasted effort.

A system may contain many imperfections, but only some of them matter at the current operating point.

---

### Running tests without acceptance criteria

A test is difficult to interpret if there is no prior definition of acceptable behavior.

Without explicit thresholds, it becomes unclear whether the result means:

- success
- failure
- degradation
- acceptable risk

Performance numbers are useful only when compared to defined expectations.

---

### Treating one test as definitive

A single test run rarely captures the full behavior of a system.

Different runs may expose:

- warm-up effects
- dependency variability
- long-term drift
- threshold behavior under different load profiles

Reliable performance analysis usually requires comparison, repetition, and validation.

---

### Ignoring time dimension

Some problems do not appear immediately.

A short test may miss:

- slow memory growth
- delayed queue buildup
- gradual dependency degradation
- runtime instability over time

This is why test duration must match the type of behavior being evaluated.

---

### Practical interpretation

Most mistakes in performance testing are not caused by bad tools.

They are caused by:

- weak assumptions
- incomplete visibility
- poor interpretation
- lack of methodological discipline

Avoiding these pitfalls is often more valuable than adding more measurement detail.

---

### Key idea

Incorrect assumptions lead to incorrect conclusions.

Avoiding common pitfalls is essential for reliable performance analysis.