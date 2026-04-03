# Performance Engineering Guide

A practical guide to **application + system performance engineering**.

This index provides a stable entry point for the repository and organizes the guide by topic.

## Table of Contents

- [1. Scope](#1-scope)
- [2. How to use this guide](#2-how-to-use-this-guide)
- [3. Repository map](#3-repository-map)
- [4. Guide structure](#4-guide-structure)
	- [4.1 Foundations](#41-foundations)
	- [4.2 Core metrics and formulas](#42-core-metrics-and-formulas)
	- [4.3 Work of a performance engineer](#43-work-of-a-performance-engineer)
	- [4.4 Types of performance tests](#44-types-of-performance-tests)
	- [4.5 System behavior under load](#45-system-behavior-under-load)
	- [4.6 Concurrency and parallelism](#46-concurrency-and-parallelism)
	- [4.7 Resource-level performance](#47-resource-level-performance)
	- [4.8 Common performance problems](#48-common-performance-problems)
	- [4.9 Diagnostics and analysis](#49-diagnostics-and-analysis)
	- [4.10 Practical checklists](#410-practical-checklists)
- [5. Current contents](#5-current-contents)
- [6. Planned contents](#6-planned-contents)
- [7. Notes](#7-notes)

---

## 1. Scope

This guide focuses on practical performance engineering for software systems.

It covers:

- core concepts and terminology
- metrics and formulas
- workload and test design
- queueing and saturation behavior
- concurrency and threading issues
- CPU, memory, disk, and network performance
- diagnostics and bottleneck analysis
- common failure modes under load

The perspective is intentionally practical: how systems behave, how performance problems emerge, and how to reason about them.

---

## 2. How to use this guide

This guide can be read in two ways:

- **Sequentially**, starting from foundations and continuing toward diagnostics
- **As a reference**, by jumping directly to a specific topic

Recommended order for first reading:

1. Foundations
2. Core metrics and formulas
3. Types of performance tests
4. System behavior under load
5. Diagnostics and analysis

---

## 3. Repository map

- `README.md` — repository overview
- `docs/index.md` — guide index
- `docs/01-perf-formulas.md` — core formulas

Additional documents will be added progressively under `docs/`.

---

## 4. Guide structure

### 4.1 Foundations

This section introduces the mental model of performance engineering.

Topics include:

- throughput
- latency
- response time
- service time
- concurrency
- saturation
- bottlenecks
- queueing basics

---

### 4.2 Core metrics and formulas

This section groups the main formulas and measurement concepts used in performance work.

Topics include:

- Little’s Law
- Utilization Law
- service demand
- throughput
- error rate
- percentiles
- CDF

---

### 4.3 Work of a performance engineer

This section describes what a performance engineer actually does.

Topics include:

- baseline definition
- workload characterization
- black-box vs white-box analysis
- test execution
- bottleneck identification
- interpretation of metrics
- communication of findings

---

### 4.4 Types of performance tests

This section presents the main test categories and their purpose.

Topics include:

- load testing
- stress testing
- spike testing
- soak testing
- capacity testing

---

### 4.5 System behavior under load

This section explains how systems evolve as load increases.

Topics include:

- saturation
- queue growth
- backpressure
- throughput limits
- latency degradation
- cascading failures
- retry amplification

---

### 4.6 Concurrency and parallelism

This section introduces concurrency-related concepts and typical issues.

Topics include:

- concurrency vs parallelism
- threads and processes
- thread pools
- synchronization
- race conditions
- deadlocks
- livelocks
- starvation

---

### 4.7 Resource-level performance

This section looks at performance from the resource perspective.

Topics include:

- CPU
- memory
- disk I/O
- network
- connection pools
- worker pools

---

### 4.8 Common performance problems

This section groups recurring performance issues by symptom or mechanism.

Topics include:

- high latency
- long-tail latency
- throughput collapse
- timeouts
- slow queries
- lock contention
- GC pauses
- connection pool exhaustion

---

### 4.9 Diagnostics and analysis

This section focuses on investigation and reasoning.

Topics include:

- reading metrics correctly
- correlating signals
- identifying bottlenecks
- distinguishing cause from effect
- tracing, logs, and metrics
- practical analysis flow

---

### 4.10 Practical checklists

This section provides concise operational checklists.

Topics include:

- what to measure during tests
- what to observe in production
- red flags
- sanity checks
- common interpretation mistakes

---

## 5. Current contents

- [01 – Core formulas](01-perf-formulas.md)

---

## 6. Planned contents

- 02 – Foundations
- 03 – Work of a performance engineer
- 04 – Types of performance tests
- 05 – System behavior under load
- 06 – Concurrency and parallelism
- 07 – Resource-level performance
- 08 – Common performance problems
- 09 – Diagnostics and analysis
- 10 – Practical checklists

---

## 7. Notes

This index is intended to remain stable even as the guide grows.

New sections can be added progressively without changing the overall structure of the guide.
