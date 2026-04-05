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

It is a way of reasoning about systems when they are stressed.

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
- dimensioning system components (memory, pools, concurrency limits)
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