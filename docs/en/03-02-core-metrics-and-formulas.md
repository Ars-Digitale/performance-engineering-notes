# 3.2 – Core metrics and formulas


A compact reference of the main formulas used in **application + system performance engineering**.

These formulas formalize the concepts introduced in:

→ [3.1 Foundations](03-01-foundations.md)

They should be read as a complement to the conceptual model, not in isolation.

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

## **Notation** (typical)

| Symbol | Definition |
| ------ | ------ |
| `X` or `λ` | **throughput** / arrival rate (requests per second)	|
| `R` or `W` | **response time** / time in system (seconds)			|
| `S`        | **service time** at a resource (seconds per request)	|
| `U`        | **utilization** of a resource (0–1)					|
| `L`        | **average concurrency** / in-flight requests (count)	|
| `V`        | **average number of visits** to a resource per request	|
| `D`        | **service demand** on a resource (seconds per request)	|

---

## 3.2.1 Little’s Law (system-level concurrency)

### Definition
Relates average **concurrency** to **throughput** and **time in system**.

### Formula
$$
{\Large L = \lambda \cdot W}
$$

### Where
- `L` = average number of requests in the system (in-flight / concurrency)
- `λ` = arrival rate / throughput (requests/s)
- `W` = average time in system (s) (often the average end-to-end response time)

### Practical meaning
If you know throughput and average response time, you can estimate how many requests are concurrently “in flight”.

### Example
If `λ = 200 req/s` and `W = 0.15 s`:

$$
L = 200 \cdot 0.15 = 30
$$

About **30** requests are in flight on average.

---

## 3.2.2 Utilization Law (resource-level busy time)

### Definition
Utilization is the **fraction of time** a *single resource* is busy during a fixed interval (typically 1 second).  
It is “busy time percentage”.

### Formula
$$
{\Large U = X \cdot S}
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

## 3.2.3 Service time vs response time (queueing)

### Definition
Response time at a resource includes:
- service time (actual work)
- queue time (waiting)

### Formula
$$
{\Large R = S + W_q}
$$

### Where
- `R`  = response time at the resource
- `S`  = service time
- `W_q` = waiting time in queue

### Practical meaning
As utilization approaches saturation, queueing grows non-linearly and **dominates** response time, causing **long-tail latency**.

---

## 3.2.4 Service Demand (visits × service time)

### Definition
Total service required on a resource per request, accounting for multiple visits.

### Formula
$$
{\Large D = V \cdot S}
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

## 3.2.5 Throughput

### Definition
Requests completed per unit of time.

### Formula
$$
{\Large X = \frac{N}{T}}
$$

### Where
- `N` = number of completed requests
- `T` = observation window (seconds)

---

## 3.2.6 Error rate

### Definition
Fraction of requests that fail (timeouts, 5xx, etc.).

### Formula
<div style="font-size:1.9rem">

$$
\mathrm{ErrorRate} = \dfrac{N_{\mathrm{err}}}{N_{\mathrm{total}}}\times 100\%
$$

</div>

---

## 3.2.7 Percentiles (p50, p95, p99)

### Definition
The `p`-th percentile is the value below which **p% of observations** fall.

- `p50` ≈ median (“typical request”)
- `p95` = threshold for the slowest 5%
- `p99` = threshold for the slowest 1%

Percentiles capture **distribution** and **tail behavior** better than averages.

---

### 3.2.7.1 How to compute a percentile (ordered sample)

Given `N` values sorted ascending:

$$
{\Large v_1 \le v_2 \le \dots \le v_N}
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

### 3.2.7.2 Interpretation vs average (why tails matter)

- If `p50` is much lower than the mean, the distribution is **right-skewed** (few slow requests inflate the mean).
- If `p95` or `p99` is far above the mean, you have **long-tail latency**.

A typical pattern:
- mean looks “acceptable”
- `p95/p99` are bad  
→ user experience is degraded for a non-negligible fraction of users and SLOs are at risk.

---

## 3.2.8 Empirical CDF (threshold → percentage)

### Definition
Given a threshold `t`, the empirical cumulative distribution function (CDF) tells the fraction of samples at or below `t`.

### Formula
$$
{\Large F(t) = \frac{\left|\{x_i \le t\}\right|}{N}}
$$

### Practical meaning
CDF answers: “If my SLO is 200 ms, what % of requests meet it?”

Percentiles answer the inverse: “What threshold corresponds to 95% of requests?”

---

## 3.2.9 Long-tail latency (what it is)

### Definition
A small fraction of requests (e.g. 5% or 1%) is **much slower** than the majority.

### Why the tail “dominates”
- SLOs are typically defined on `p95/p99`, so tails drive pass/fail.
- In distributed systems, the slowest dependency often determines end-to-end latency.
- Tail events are frequently driven by **contention/queueing**.

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

## 3.2.10 Quick checklist (what to measure in tests)

- Latency: `p50/p90/p95/p99`
- Throughput: `RPS/TPS`
- Error rate: `timeouts/5xx`
- Utilization: CPU, memory, DB, pools
- Queue lengths: thread pools, connection pools, message backlogs
- Dependency timings: DB/Redis/external APIs