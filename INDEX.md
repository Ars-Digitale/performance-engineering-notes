# Performance Engineering Guide

A practical guide to **application + system performance engineering**.

This index defines the structure of the guide.

## Table of Contents

- [1. Scope](#1-scope)
- [2. How to use this guide](#2-how-to-use-this-guide)
- [3. Guide structure](#3-guide-structure)
	- [3.1 Foundations](#31-foundations)
	- [3.2 Core metrics and formulas](#32-core-metrics-and-formulas)
	- [3.3 Work of a performance engineer](#33-work-of-a-performance-engineer)
	- [3.4 Types of performance tests](#34-types-of-performance-tests)
	- [3.5 System behavior under load](#35-system-behavior-under-load)
	- [3.6 Concurrency and parallelism](#36-concurrency-and-parallelism)
	- [3.7 Runtime and memory model](#37-runtime-and-memory-model)
	- [3.8 Resource-level performance](#38-resource-level-performance)
	- [3.9 Common performance problems](#39-common-performance-problems)
	- [3.10 Diagnostics and analysis](#310-diagnostics-and-analysis)
	- [3.11 Practical checklists](#311-practical-checklists)
- [4. Documentation](#4-documentation)

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

---

## 2. How to use this guide

This guide can be read:

- sequentially (from foundations to diagnostics)
- as a reference (jumping to specific topics)

---

## 3. Guide structure

### 3.1 Foundations
Conceptual model of performance engineering.

→ [3.1 Foundations](docs/en/03-01-foundations.md)

### 3.2 Core metrics and formulas
Mathematical and measurement foundations.

→ [3.2 Core metrics and formulas](docs/en/03-02-core-metrics-and-formulas.md)

### 3.3 Work of a performance engineer
Process and methodology.

### 3.4 Types of performance tests
Load, stress, spike, soak, capacity.

### 3.5 System behavior under load
Saturation, queueing, degradation.

### 3.6 Concurrency and parallelism
Threads, synchronization, contention.

### 3.7 Runtime and memory model
Execution model and memory behavior.

Topics include:
- heap and stack
- allocation and object lifecycle
- garbage collection (conceptual)
- thread scheduling
- pauses and contention

### 3.8 Resource-level performance
CPU, memory, disk, network, and external resources.

### 3.9 Common performance problems
Latency, throughput collapse, tail issues.

### 3.10 Diagnostics and analysis
Investigation and reasoning.

### 3.11 Practical checklists
Operational guidelines.

---

## 4. Documentation

Full documentation is available here:

- [docs/index.md](docs/index.md)