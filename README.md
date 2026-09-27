# Cache Memory using SystemVerilog

## My Fifth VLSI RTL Design Project

A 4-line direct-mapped cache memory designed and verified using SystemVerilog.

---

## 📌 Project Description

This project implements a **4-line direct-mapped cache memory** using SystemVerilog.

The design demonstrates fundamental cache-memory concepts including:

- Cache read and write operations
- Direct-mapped cache organization
- Tag and index mapping
- Valid-bit management
- Cache hit detection
- Cache miss detection
- Cache line replacement
- Write-through memory operation
- Hit/miss statistics
- RTL verification using a self-checking testbench

---

## 🎯 Objective

The main objective of this project is to understand how cache memory works at the RTL level and implement a simple cache controller using SystemVerilog.

---

## 🏗️ Cache Architecture

| Parameter | Value |
|---|---|
| Address Width | 4 bits |
| Data Width | 8 bits |
| Cache Lines | 4 |
| Mapping | Direct-Mapped |
| Tag Bits | 2 bits |
| Index Bits | 2 bits |
| Write Policy | Write-Through |
| Main Memory | 16 × 8 bits |

### Address Format

```text
4-bit Address

+-------------+-------------+
|   TAG [3:2] | INDEX [1:0] |
+-------------+-------------+
