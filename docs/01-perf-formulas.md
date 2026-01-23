---
title: Performance Engineering – Core Formulas
slug: formulas
lang: en
description: Core performance engineering formulas (Little’s Law, Utilization Law, Service Demand, percentiles, CDF) with concise definitions and examples.
---

# Performance Engineering – Core Formulas

This page is a compact reference of the main formulas used in application + system performance work.

> Notation (typical):
- \(X\) or \(\lambda\): throughput / arrival rate (req/s)
- \(R\) or \(W\): response time / time in system (s)
- \(S\): service time at a resource (s)
- \(U\): utilization of a resource (0–1)
- \(L\): average concurrency / in-flight requests (count)

---

## 1) Little’s Law (System-level concurrency)

### Definition
Relates average **concurrency** to **throughput** and **time in system**.

### Formula
\[
L = \lambda \cdot W
\]

### Where
- \(L\): average number of requests in the system (in-flight / concurrency)
- \(\lambda\): throughput (req/s)
- \(W\): average time in system (s) (often the average response time)

### Practical meaning
If you know throughput and average response time, you can estimate how many requests are concurrently “in flight”.

### Example
If \(\lambda = 200\) req/s and \(W = 0.15\) s:
\[
L = 200 \cdot 0.15 = 30
\]
About **30** requests are in flight on average.

---

## 2) Utilization Law (Resource-level busy time)

### Definition
Utilization is the **fraction of time** a *single resource* is busy during an interval (typically 1 second).  
It is “busy time percentage”.

### Formula
\[
U = X \cdot S
\]

### Where
- \(U\): utilization (0–1)
- \(X\): throughput observed by that resource (req/s)
- \(S\): mean service time at that resource (s/req)

### Resource
A **single service unit**: CPU core, thread, worker, DB connection, etc.

### Example
A DB worker handles \(50\) req/s, each query takes \(10\) ms (\(0.01\) s):
\[
U = 50 \cdot 0.01 = 0.5 \Rightarrow 50\%
\]
Interpretation: the resource is busy **0.5 s per second**.

---

## 3) Service Time vs Response Time (Queueing)

### Definition
Response time at a resource includes:
- service time (actual work)
- queue time (waiting)

### Formula
\[
R = S + W_q
\]

### Meaning
When utilization approaches saturation, \(W_q\) grows rapidly and **dominates** \(R\), creating long-tail latency.

---

## 4) Service Demand

### Definition
Total service required on a resource per transaction, accounting for multiple visits.

### Formula
\[
D = V \cdot S
\]

### Where
- \(D\): service demand on the resource (s)
- \(V\): average number of visits to the resource per request
- \(S\): service time per visit (s)

### Example
A request performs \(V=3\) DB queries, each takes \(S=5\) ms:
\[
D = 3 \cdot 0.005 = 0.015\ \text{s} = 15\ \text{ms}
\]

---

## 5) Throughput

### Definition
Requests completed per unit of time.

### Formula
\[
X = \frac{N}{T}
\]

### Where
- \(N\): number of completed requests
- \(T\): observation window (s)

---

## 6) Error Rate

### Definition
Fraction of requests that fail (timeouts, 5xx, etc.).

### Formula
\[
\text{ErrorRate} = \frac{N_{err}}{N_{total}} \times 100\%
\]

---

## 7) Percentiles (p50, p95, p99)

### Definition
The \(p\)-th percentile is the value below which **\(p\%\)** of observations fall.

- \(p50\) ≈ median (“typical”)
- \(p95\) = worst 5% threshold
- \(p99\) = worst 1% threshold

Percentiles capture **distribution** and **tail behavior** better than averages.

### How to compute (ordered sample)
Given \(N\) values sorted ascending:
\[
v_1 \le v_2 \le \dots \le v_N
\]

Compute the (theoretical) position:
\[
P = \frac{p}{100}(N+1)
\]

- If \(P\) is integer → percentile \(= v_P\)
- If not, let \(k=\lfloor P \rfloor\) and \(\delta = P-k\), then interpolate:
\[
\text{Percentile}(p) \approx v_k + \delta (v_{k+1}-v_k)
\]

> Note: tools differ slightly in percentile definitions; this is a clear and commonly used method.

### Interpretation vs average (why tails matter)
If \(p50 \ll \text{mean}\), the distribution is **right-skewed**: few slow requests inflate the mean.  
If \(p95\) or \(p99\) is far above the mean, you likely have **long-tail latency**, commonly driven by queueing/contending resources or slow dependencies.

---

## 8) Empirical CDF (threshold → percentage)

### Definition
Given a threshold \(t\), the empirical cumulative distribution function (CDF) tells the fraction of samples at or below \(t\).

### Formula
\[
F(t) = \frac{\#\{x_i \le t\}}{N}
\]

### Practical meaning
CDF answers: “If my SLO is 200 ms, what % of requests meet it?”

Percentiles answer the inverse: “What threshold corresponds to 95% of requests?”

---

## 9) Long-tail latency (what it is)

### Definition
A small fraction of requests (e.g., 5% or 1%) is **much slower** than the majority.

### Why the tail “dominates”
- SLOs are typically defined on p95/p99, so tails drive pass/fail.
- In distributed systems, the slowest dependency often defines end-to-end latency.
- Tail events often come from **contention/queueing**: thread pools, connection pools, locks, retries, hot keys, GC pauses, I/O spikes, or network jitter.

---

## 10) Quick checklist (what to measure in tests)

- Latency: p50/p90/p95/p99
- Throughput: RPS/TPS
- Error rate: timeouts/5xx
- Utilization: CPU, DB, pools
- Queue lengths: pools, queues, message backlogs
- Dependency timings: DB/Redis/external APIs
