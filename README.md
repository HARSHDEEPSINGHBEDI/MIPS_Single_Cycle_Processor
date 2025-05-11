# MIPS Single-Cycle Processor – Harshdeep Singh

This repository implements a 32-bit MIPS **single-cycle** CPU in Verilog. It supports exactly **14 instructions** (no others):  
1. **add**, **sub** (two’s-complement)  
2. **and**, **or** (via direct ops)  
3. **lw**, **sw**  
4. **slt**  
5. **beq**, **bne**  
6. **j**, **jal**  
7. **srl**  
8. **sltiu**  
9. **lhu**  

Everything runs in a single clock tick per instruction. A self-checking testbench exercises all 14 and prints results.

---

## 📁 Repository Layout


---

## 🖼️ Datapath Diagram

The full single-cycle datapath (all connections in one clock):

![Single-cycle datapath](img/Screenshot%202025-05-12%20003011.png)

---

## 🎛️ Control-Signal Cheat Sheet

### 1-bit control signals

| Instr.  | RegDst | Jump | ExtSel | Branch | Bne | MemRead | MemWrite | MemtoReg | ALUSrc | RegWrite | Jal |
|---------|:------:|:----:|:------:|:------:|:---:|:-------:|:--------:|:--------:|:------:|:--------:|:---:|
| R-type  |   1    |  0   |   1    |   0    |  0  |    0    |     0    |     0    |   0    |     1    |  0  |
| **srl** |   1    |  0   |   1    |   0    |  0  |    0    |     0    |     0    |   0    |     1    |  0  |
| lw      |   0    |  0   |   1    |   0    |  0  |    1    |     0    |     1    |   1    |     1    |  0  |
| sw      |   x    |  0   |   1    |   0    |  0  |    0    |     1    |     x    |   1    |     0    |  0  |
| beq     |   x    |  0   |   1    |   1    |  0  |    0    |     0    |     x    |   0    |     0    |  0  |
| bne     |   x    |  0   |   1    |   1    |  1  |    0    |     0    |     x    |   0    |     0    |  0  |
| j       |   x    |  1   |   x    |   0    |  0  |    0    |     0    |     x    |   x    |     0    |  0  |
| jal     |   x    |  1   |   x    |   0    |  0  |    0    |     0    |     x    |   x    |     1    |  1  |
| sltiu   |   0    |  0   | **0**  |   0    |  0  |    0    |     0    |     0    |   1    |     1    |  0  |
| lhu     |   0    |  0   |   1    |   0    |  0  |    1    |     0    |     1    |   1    |     1    |  0  |

### ALU control decoding

| ALUOp | funct (R-type) | Instruction | ALU action | alu_control bits |
|:-----:|:--------------:|:-----------:|:----------:|:----------------:|
|  00   | —              | `lw`, `sw`, `lhu` | ADD     | `0010`           |
|  01   | —              | `beq`,`bne`      | SUB     | `0110`           |
|  11   | —              | `sltiu`          | SLTU    | `1010`           |
|  10   | `100000`       | `add`            | ADD     | `0010`           |
|  10   | `100010`       | `sub`            | SUB     | `0110`           |
|  10   | `100100`       | `and`            | AND     | `0000`           |
|  10   | `100101`       | `or`             | OR      | `0001`           |
|  10   | `101010`       | `slt`            | SLT     | `0111`           |
|  10   | `000010`       | `srl`            | SRL     | `1001`           |

---

## 🔍 Module Descriptions

Each file in **src/** implements one block of the datapath:

- **pc.v**  
  Holds the 32-bit Program Counter; updates on every clock (`pc_out <= pc_in`), resets to 0.

- **adder.v**  
  Computes `pc_next = pc_out + 4` for instruction fetch.

- **instr_mem.v**  
  1 KB instruction memory (`[0:255]`), word-aligned.  
  - On read: `instruction = memory[pc_out >> 2]`  
  - Decodes fields (`opcode`, `rs`, `rt`, `rd`, `shamt`, `funct`, `imm`, `instr_address`).  
  - Initialized via `$readmemh("program1.mem", memory)`.

- **control_unit.v**  
  Generates all control signals from `opcode` and `funct`.  
  Handles R-type, lw/sw, beq/bne, j/jal, sltiu, lhu, and SRL.

- **reg_file.v**  
  32×32 register file with two async-read ports and one pos-edge write port.  
  Prevents writes to `$zero` (reg 0).

- **sign_ext.v**  
  Extends 16-bit immediate to 32 bits:  
  - `ExtSel=1` → sign-extend  
  - `ExtSel=0` → zero-extend (for sltiu)

- **mux_reg_dst.v**  
  Chooses write destination: `rt`, `rd`, or `$ra` (`jal`).

- **shift_left_2_branch.v**  
  Shifts sign-extended immediate left by 2 for branch offset.

- **mux_alu_src.v**  
  Selects ALU second input: register data vs. immediate.

- **alu_control.v**  
  Maps `(ALUOp, funct)` to the 4-bit `alu_control` code.

- **alu.v**  
  Core ALU: ADD, SUB, AND, OR, SLT, SLTU, SRL.  
  Produces `zero` flag and handles overflow for ADD/SUB.

- **data_mem.v**  
  256×32 data memory.  
  - Asynchronous read (`MemRead`), supports word & half-word unsigned.  
  - Synchronous write (`MemWrite`, word only).

- **mux_memtoreg.v**  
  Chooses write-back data: ALU result, memory data, or `pc_next` (`jal`).

- **shift_left_2_jump.v**  
  Shifts 26-bit address from instruction left by 2 for jump.

- **alu_branch.v**  
  Computes branch target: `pc_next + shifted_imm`.

- **mux_br_sel.v**  
  Chooses between branch target and `pc_next` based on `Branch`/`Bne` and `zero`.

- **mux_jump_sel.v**  
  Chooses final `pc_in`: branch vs. jump (`{pc_next[31:28], instr_address<<2}`).

---

## 📝 Sample Program & Testbench

- **`tb/program1.mem`**  
  One 32-bit hex word per line (big-endian), 14 entries:
  ```text
  01095020  # add  $t2,$t0,$t1
  01095822  # sub  $t3,$t0,$t1
  01096024  # and  $t4,$t0,$t1
  01096825  # or   $t5,$t0,$t1
  ad0b0004  # sw   $t3,4($t0)
  8d0c0004  # lw   $t4,4($t0)
  0109702a  # slt  $t6,$t0,$t1
  00128082  # srl  $s0,$t1,2
  11090002  # beq  $t0,$t1,offset
  15090000  # bne  $t0,$t1,offset
  0800000c  # j    0x30
  00000000  # nop
  0c00000d  # jal  0x34
  2d0a0001  # sltiu $t2,$t0,1
  950c0002  # lhu  $t4,2($t0)
