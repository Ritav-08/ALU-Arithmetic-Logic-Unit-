# 📘 32-bit ALU (Arithmetic Logic Unit) – Verilog

## 🔹 Overview

This project implements a **32-bit Arithmetic Logic Unit (ALU)** in Verilog along with a **self-checking testbench**.
The ALU performs four operations based on a 2-bit select line:

* Addition
* Subtraction
* Bitwise AND
* Bitwise OR

It also generates four important status flags:

* Zero
* Carry
* Overflow
* Negative

---

## 🔹 Features

* 32-bit input operands (`a_i`, `b_i`)
* 4 ALU operations using 2-bit select line
* Parallel computation of all operations
* Status flags for result analysis
* Self-checking testbench with automated validation
* Random test case generation for robustness

---

## 🔹 Module Description

### 📌 Inputs

* `a_i [31:0]` → First operand
* `b_i [31:0]` → Second operand
* `sel_i [1:0]` → Operation select

### 📌 Outputs

* `dout_o [31:0]` → ALU result
* `fZero_o` → High when result is zero
* `fCarry_o` → Carry/No Borrow flag
* `fOverflow_o` → Overflow flag
* `fNegative_o` → Sign of result (MSB)

---

## 🔹 Operation Selection

| Select (`sel_i`) | Operation   | Description                  |
| ---------------- | ----------- | ---------------------------- |
| 00               | Addition    | `a_i + b_i`                  |
| 01               | Subtraction | `a_i - b_i` (2’s complement) |
| 10               | AND         | Bitwise AND                  |
| 11               | OR          | Bitwise OR                   |

---

## 🔹 Working Principle

### 🔸 Arithmetic Operations

* **Addition:**

  ```
  sum = a_i + b_i
  ```
* **Subtraction (2’s Complement):**

  ```
  diff = a_i + (~b_i) + 1
  ```

### 🔸 Logical Operations

* AND:

  ```
  a_i & b_i
  ```
* OR:

  ```
  a_i | b_i
  ```

---

## 🔹 Flag Description

* **Zero Flag (`fZero_o`)**
  High when output is `0`

* **Carry Flag (`fCarry_o`)**

  * Addition → Carry out
  * Subtraction → High = No Borrow

* **Overflow Flag (`fOverflow_o`)**

  * Detects signed overflow:

    * Addition: (+ + → -) or (- - → +)
    * Subtraction: (+ - → -) or (- + → +)

* **Negative Flag (`fNegative_o`)**

  * Indicates sign (MSB of result)

---

## 🔹 Testbench Details

The testbench (`tb_ALU4ops`) is **fully self-checking**:

### 🔸 Features

* Validates all operations
* Compares DUT output with expected results
* Tracks:

  * Total checks
  * Pass/Fail count
  * Overflow occurrences
  * Zero occurrences

### 🔸 Test Coverage

* Directed test cases:

  * Normal operations
  * Edge cases (overflow, carry, zero)
  * Alternating bit patterns
* Random testing:

  ```
  repeat(100) with $urandom
  ```

---

## 🔹 Simulation

### ▶️ Tools

* ModelSim / QuestaSim
* Xilinx Vivado
* Icarus Verilog + GTKWave

### ▶️ Run (Icarus Verilog Example)

```bash id="alu_run"
iverilog -o ALU4ops.vvp ALU4ops.v tb_ALU4ops.v
vvp ALU4ops.vvp
gtkwave ALU.vcd
```

---

## 🔹 Output

* Console output using `$monitor` and `$display`
* Error messages for mismatches
* Final summary:

  ```
  Total Checks: X | Pass: Y, Fail: Z
  Overflow Count: A, Zero Count: B
  ```
* Waveform dump file:

  ```
  ALU.vcd
  ```

---

## 🔹 Sample Output Format

```id="alu_sample"
Time: 20 | A: 00000005, B: 00000003, Sel: 00 | Out: 00000008 | Flags- Zero: 0, Carry: 0, Overflow: 0, Negative: 0
```

---

## 🔹 Applications

* Processor ALUs
* Embedded systems
* FPGA/ASIC arithmetic units
* Digital signal processing (basic operations)

---

## 🔹 Design Insights

* All operations are computed in parallel → faster selection
* Separate adders used for addition and subtraction → improves speed
* Trade-off: Higher hardware usage vs lower latency

---

## 🔹 File Structure

```id="alu_struct"
├── ALU4ops.v        # ALU Design
├── tb_ALU4ops.v     # Self-checking Testbench
├── ALU.vcd          # Waveform output (generated)
└── README.txt       # Documentation
```
