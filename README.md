# MIPS_Single_Cycle_Processor

# MIPS Single-Cycle Processor 

A Verilog implementation of a 32-bit MIPS **single-cycle** CPU, including
support for R-type ops, load/store, branches, jump, `jal`, `sltiu`, `lhu`1. add, sub (you can use 2’s complement approach)
2. and, or (you can use NAND and NOT)
3. lw, sw
4. slt
5. beq and bne
6. j1. 
jal
2. srl
3. sltiu
4. lhu
and **SRL**.

---

## 📐 Datapath

![Single-cycle datapath](docs/img/datapath.png)

---

## 🎛️ Control-Signal Cheat Sheet

### One-bit signals

| Instr. | RegDst | Jump | ExtSel | Branch | Bne | MemRead | MemWrite | MemtoReg | ALUSrc | RegWrite | Jal |
|--------|:------:|:----:|:------:|:------:|:---:|:-------:|:--------:|:--------:|:------:|:--------:|:---:|
| R-type |   1    |  0   |   1    |   0    |  0  |    0    |    0     |    0     |   0    |    1     |  0  |
| **srl**|   1    |  0   |   1    |   0    |  0  |    0    |    0     |    0     |   0    |    1     |  0  |
| lw     |   0    |  0   |   1    |   0    |  0  |    1    |    0     |    1     |   1    |    1     |  0  |
| sw     |   X    |  0   |   1    |   0    |  0  |    0    |    1     |    X     |   1    |    0     |  0  |
| beq    |   X    |  0   |   1    |   1    |  0  |    0    |    0     |    X     |   0    |    0     |  0  |
| bne    |   X    |  0   |   1    |   1    |  1  |    0    |    0     |    X     |   0    |    0     |  0  |
| j      |   X    |  1   |   X    |   0    |  0  |    0    |    0     |    X     |   X    |    0     |  0  |
| jal    |   X    |  1   |   X    |   0    |  0  |    0    |    0     |    X     |   X    |    1     |  1  |
| sltiu  |   0    |  0   | **0**  |   0    |  0  |    0    |    0     |    0     |   1    |    1     |  0  |
| lhu    |   0    |  0   |   1    |   0    |  0  |    1    |    0     |    1     |   1    |    1     |  0  |

### ALU control decoding

| ALUOp | funct (R-type) | Example | ALU op | **alu_control** |
|-------|----------------|---------|--------|-----------------|
| 00 | X | `lw`, `sw`, `lhu` | ADD | 0010 |
| 01 | X | `beq`, `bne` | SUB | 0110 |
| 11 | X | `sltiu` | SLTU | 1010 |
| 10 | 100000 | `add` | ADD | 0010 |
| 10 | 100010 | `sub` | SUB | 0110 |
| 10 | 100100 | `and` | AND | 0000 |
| 10 | 100101 | `or`  | OR  | 0001 |
| 10 | 101010 | `slt` | SLT | 0111 |
| 10 | 000010 | `srl` | SRL | 1001 |

`alu_control` bits feed the ALU directly (see `alu.v`).

---

## 🚀 Quick Run

```bash
# build + simulate (Icarus)
iverilog -g2012 -o build/run.vvp src/*.v tb/processor_tb.v
vvp build/run.vvp
