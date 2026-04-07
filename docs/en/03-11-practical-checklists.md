## 3.11 – Practical checklists

## Table of Contents

- [3.11.1 Before running a test](#3111-before-running-a-test)
- [3.11.2 During test execution](#3112-during-test-execution)
- [3.11.3 After test analysis](#3113-after-test-analysis)
- [3.11.4 Common pitfalls](#3114-common-pitfalls)

---

## 3.11.1 Before running a test

### Objectives

Clearly define what the test is intended to validate.

Typical objectives include:

- latency targets  
- throughput goals  
- capacity limits  

---

### Workload definition

Define the workload precisely:

- request rate or concurrency  
- request mix  
- duration  

(→ [3.4 Types of performance tests](#34-types-of-performance-tests))

---

### Environment consistency

Ensure that:

- test environment is stable  
- configuration matches production assumptions  
- external dependencies are controlled  

---

### Metrics setup

Verify that all required metrics are available:

- latency percentiles  
- throughput  
- resource utilization  
- error rate  

(→ [3.2 Core metrics and formulas](./03-02-core-metrics-and-formulas.md))

---

### Key idea

A test is only meaningful if objectives, workload, and measurements are clearly defined.

---

## 3.11.2 During test execution

### Monitoring

Observe system behavior in real time:

- latency evolution  
- throughput stability  
- resource usage  

---

### Consistency checks

Ensure that:

- workload is applied as expected  
- no external disturbances affect the test  

---

### Early signals

Watch for:

- rapid latency increase  
- unexpected errors  
- resource saturation  

(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))

---

### Key idea

Execution is not passive.

Continuous observation is required to detect anomalies early.

---

## 3.11.3 After test analysis

### Data review

Analyze collected data:

- latency distribution  
- throughput trends  
- resource utilization  

---

### Correlation

Relate signals:

- latency vs CPU  
- latency vs I/O  
- errors vs load  

(→ [3.10 Diagnostics and analysis](./03-10-diagnostics-and-analysis.md))

---

### Interpretation

Identify:

- bottlenecks  
- scaling limits  
- abnormal patterns  

---

### Reporting

Summarize:

- observed behavior  
- identified issues  
- recommendations  

---

### Key idea

Analysis transforms raw data into actionable understanding.

---

## 3.11.4 Common pitfalls

### Misinterpreting averages

- averages hide tail latency  
- percentiles provide a clearer view  

(→ [3.2.7 Percentiles](./03-02-core-metrics-and-formulas.md#327-percentiles-p50-p95-p99))

---

### Ignoring workload realism

- unrealistic workloads produce misleading results  
- production patterns must be approximated  

---

### Confusing symptom and cause

- high CPU is not always the root problem  
- latency must be analyzed in context  

(→ [3.10 Diagnostics and analysis](./03-10-diagnostics-and-analysis.md))

---

### Overlooking bottlenecks

- optimizing non-limiting resources has little effect  
- focus must remain on the dominant constraint  

(→ [3.8 Resource-level performance](./03-08-resource-level-performance.md))

---

### Key idea

Incorrect assumptions lead to incorrect conclusions.

Avoiding common pitfalls is essential for reliable performance analysis.

