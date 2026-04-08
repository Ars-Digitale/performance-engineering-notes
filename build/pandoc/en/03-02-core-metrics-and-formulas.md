# 3.2 – Core metrics and formulas

<a id="32-core-metrics-and-formulas"></a>

A compact reference of the main formulas used in **application + system performance engineering**.

These formulas formalize the concepts introduced in:

→ [3.1 Foundations](#chap-03-01-foundations)

They should be read as a complement to the conceptual model, not in isolation.

They provide the quantitative basis used to reason about system behavior, validate assumptions, and interpret performance test results.


## Table of Contents

- [3.2.1 Little’s Law (system-level concurrency)](#321-littles-law-system-level-concurrency)
- [3.2.2 Utilization Law (resource-level busy time)](#322-utilization-law-resource-level-busy-time)
- [3.2.3 Service time vs response time (queueing)](#323-service-time-vs-response-time-queueing)
- [3.2.4 Service Demand (visits × service time)](#324-service-demand-visits--service-time)
- [3.2.5 Throughput](#325-throughput)
- [3.2.6 Error rate](#326-error-rate)
- [3.2.7 Percentiles (p50, p95, p99)](#327-percentiles-p50-p95-p99)
	- [3.2.7.1 How to compute a percentile (ordered sample)](#3271-how-to-compute-a-percentile-ordered-sample)
	- [3.2.7.2 Interpretation vs average (why tails matter)](#3272-interpretation-vs-average-why-tails-matter)
- [3.2.8 Empirical CDF (threshold → percentage)](#328-empirical-cdf-threshold--percentage)
- [3.2.9 Long-tail latency (what it is)](#329-long-tail-latency-what-it-is)
- [3.2.10 Quick checklist (what to measure in tests)](#3210-quick-checklist-what-to-measure-in-tests)

---

## **Notation** (typical) {#notation-typical}

| Symbol | Definition |
| ------ | ------ |
| `X` or `λ` | **throughput** / arrival rate (requests per second)	|
| `R` or `W` | **response time** / time in system (seconds)			|
| `S`        | **service time** at a resource (seconds per request)	|
| `U`        | **utilization** of a resource (0–1)					|
| `L`        | **average concurrency** / in-flight requests (count)	|
| `V`        | **average number of visits** to a resource per request	|
| `D`        | **service demand** on a resource (seconds per request)	|

This notation is used consistently across the guide and allows formulas to be applied in a uniform way across different contexts.

---

## 3.2.1 Little’s Law (system-level concurrency) {#321-littles-law-system-level-concurrency}

### Definition
Relates average **concurrency** to **throughput** and **time in system**.

### Formula
$$
L = \lambda \cdot W
$$

### Where
- `L` = average number of requests in the system (in-flight / concurrency)
- `λ` = arrival rate / throughput (requests/s)
- `W` = average time in system (s) (often the average end-to-end response time)

### Practical meaning
If you know throughput and average response time, you can estimate how many requests are concurrently “in flight”.

This makes Little’s Law one of the most useful tools for reasoning about system load and concurrency.

### Example
If `λ = 200 req/s` and `W = 0.15 s`:

$$
L = 200 \cdot 0.15 = 30
$$

About **30** requests are in flight on average.

---

### Practical interpretation

Little’s Law connects three observable quantities:

- throughput  
- latency  
- concurrency  

This allows:

- estimating concurrency from measurements  
- validating system behavior  
- detecting inconsistencies in metrics  

It is widely used in performance engineering, capacity planning, and system diagnostics.

---

## 3.2.2 Utilization Law (resource-level busy time) {#322-utilization-law-resource-level-busy-time}

### Definition
Utilization is the **fraction of time** a *single resource* is busy during a fixed interval (typically 1 second).  
It is “busy time percentage”.

### Formula
$$
U = X \cdot S
$$

### Where
- `U` = utilization (0–1)
- `X` = throughput observed by that resource (req/s)
- `S` = mean service time at that resource (s/req)

### Resource
A **single service unit**, e.g. CPU core, thread/worker, DB connection, etc.

### Example
A DB worker handles `50 req/s`, each query takes `10 ms = 0.01 s`:

$$
U = 50 \cdot 0.01 = 0.5 \Rightarrow 50\%
$$

Interpretation: the resource is busy **0.5 seconds per second**.

---

### Practical interpretation

Utilization is a key indicator of resource saturation.

As utilization approaches 1:

- queueing increases  
- latency grows non-linearly  
- system stability decreases  

This makes utilization one of the most important signals when diagnosing bottlenecks.

---

## 3.2.3 Service time vs response time (queueing) {#323-service-time-vs-response-time-queueing}

### Definition
Response time at a resource includes:
- service time (actual work)
- queue time (waiting)

### Formula
$$
R = S + W_q
$$

### Where
- `R`  = response time at the resource
- `S`  = service time
- `W_q` = waiting time in queue

### Practical meaning
As utilization approaches saturation, queueing grows non-linearly and **dominates** response time, causing **long-tail latency**.

---

### Practical interpretation

This formula explains why systems slow down under load even when computation cost does not change.

In many real systems:

- service time remains relatively stable  
- waiting time increases rapidly  

As a result:

- response time is dominated by queueing  
- latency becomes unpredictable  

Understanding this distinction is essential for diagnosing performance issues.

---

## 3.2.4 Service Demand (visits × service time) {#324-service-demand-visits--service-time}

### Definition
Total service required on a resource per request, accounting for multiple visits.

### Formula
$$
D = V \cdot S
$$

### Where
- `D` = service demand on the resource (s)
- `V` = average visits to the resource per request
- `S` = service time per visit (s)

### Example
A request performs `V = 3` DB queries, each takes `S = 5 ms = 0.005 s`:

$$
D = 3 \cdot 0.005 = 0.015 \text{ s} = 15 \text{ ms}
$$

---

### Practical interpretation

Service demand represents the total work required from a resource per request.

It is particularly useful for:

- identifying heavily used resources  
- estimating capacity limits  
- understanding scaling behavior  

Reducing service demand is often more effective than increasing raw capacity.

---

## 3.2.5 Throughput {#325-throughput}

### Definition
Requests completed per unit of time.

### Formula
$$
X = \frac{N}{T}
$$

### Where
- `N` = number of completed requests
- `T` = observation window (seconds)

---

### Practical interpretation

Throughput is one of the primary indicators of system performance.

It reflects the system’s ability to process work.

However, throughput must always be interpreted together with:

- latency  
- error rate  
- resource utilization  

High throughput alone does not guarantee acceptable system behavior.

---

## 3.2.6 Error rate {#326-error-rate}

### Definition
Fraction of requests that fail (timeouts, 5xx, etc.).

### Formula

$$
\mathrm{ErrorRate} = \frac{N_{\mathrm{err}}}{N_{\mathrm{total}}} \times 100\%
$$

---

### Practical interpretation

Error rate reflects system reliability under load.

An increase in error rate often indicates:

- overload conditions  
- resource exhaustion  
- instability  

Error rate should always be monitored together with latency and throughput.

---

## 3.2.7 Percentiles (p50, p95, p99) {#327-percentiles-p50-p95-p99}

### Definition
The `p`-th percentile is the value below which **p% of observations** fall.

- `p50` ≈ median (“typical request”)
- `p95` = threshold for the slowest 5%
- `p99` = threshold for the slowest 1%

Percentiles capture **distribution** and **tail behavior** better than averages.

---

### Practical interpretation

Percentiles are essential for understanding real user experience.

In many systems:

- average latency appears acceptable  
- tail latency (p95/p99) is significantly worse  

This difference is critical for system evaluation and SLO definition.

---

### 3.2.7.1 How to compute a percentile (ordered sample) {#3271-how-to-compute-a-percentile-ordered-sample}

Given `N` values sorted ascending:

$$
v_1 \le v_2 \le \dots \le v_N
$$

Compute the theoretical position:

$$
P = \frac{p}{100}(N + 1)
$$

- If `P` is an integer → percentile = `v_P`
- If not, let `k = floor(P)` and `δ = P - k` (fractional part), then interpolate:

$$
\text{Percentile}(p) \approx v_k + \delta \cdot (v_{k+1} - v_k)
$$

> Note: percentile definitions vary slightly across tools. This method is a clear and commonly used approach and is excellent for reasoning in interviews/assessments.

---

### 3.2.7.2 Interpretation vs average (why tails matter) {#3272-interpretation-vs-average-why-tails-matter}

- If `p50` is much lower than the mean, the distribution is **right-skewed** (few slow requests inflate the mean).
- If `p95` or `p99` is far above the mean, you have **long-tail latency**.

A typical pattern:
- mean looks “acceptable”
- `p95/p99` are bad  
→ user experience is degraded for a non-negligible fraction of users and SLOs are at risk.

---

### Practical interpretation

Percentiles highlight behavior that averages hide.

They are essential for:

- defining service level objectives (SLOs)  
- detecting tail latency issues  
- understanding worst-case behavior  

Ignoring percentiles often leads to incorrect conclusions about system performance.

---

## 3.2.8 Empirical CDF (threshold → percentage) {#328-empirical-cdf-threshold--percentage}

### Definition
Given a threshold `t`, the empirical cumulative distribution function (CDF) tells the fraction of samples at or below `t`.

### Formula
$$
F(t) = \frac{\left|\{x_i \le t\}\right|}{N}
$$

### Practical meaning
CDF answers: “If my SLO is 200 ms, what % of requests meet it?”

Percentiles answer the inverse: “What threshold corresponds to 95% of requests?”

---

### Practical interpretation

CDF and percentiles are complementary views of the same data.

- CDF: given a threshold → what fraction meets it  
- Percentile: given a fraction → what threshold corresponds  

Both are useful for performance analysis and SLO validation.

---

## 3.2.9 Long-tail latency (what it is) {#329-long-tail-latency-what-it-is}

### Definition
A small fraction of requests (e.g. 5% or 1%) is **much slower** than the majority.

---

### Why the tail “dominates”

- SLOs are typically defined on `p95/p99`, so tails drive pass/fail.
- In distributed systems, the slowest dependency often determines end-to-end latency.
- Tail events are frequently driven by **contention/queueing**.

---

### Common causes (high-level)

- thread pool / connection pool saturation (queueing)
- lock contention / synchronization hot spots
- slow DB queries, missing indexes, lock waits
- retries + timeouts amplifying tail latency
- hot keys in caches / uneven shard load
- GC pauses / memory pressure (stop-the-world)
- network jitter / packet loss / retransmissions
- disk I/O spikes, compactions, fsync/wal flush

---

### Practical interpretation

Long-tail latency is one of the most critical aspects of system performance.

It explains why:

- average metrics can appear acceptable  
- user experience is still degraded  

Managing tail latency is often more important than improving average performance.

---

## 3.2.10 Quick checklist (what to measure in tests) {#3210-quick-checklist-what-to-measure-in-tests}

- Latency: `p50/p90/p95/p99`
- Throughput: `RPS/TPS`
- Error rate: `timeouts/5xx`
- Utilization: CPU, memory, DB, pools
- Queue lengths: thread pools, connection pools, message backlogs
- Dependency timings: DB/Redis/external APIs

---

### Practical interpretation

These metrics form the minimal set required to understand system behavior during performance tests.

They allow:

- identifying bottlenecks  
- detecting instability  
- correlating workload with system behavior  

Measuring only a subset of these metrics often leads to incomplete or misleading analysis.

---

### Key idea

Formulas are not isolated abstractions.

They are tools used to explain observed behavior and validate system models.

Understanding how to apply them is essential for performance engineering.
