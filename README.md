# MIPS Single-Cycle Processor – Harshdeep Singh

A Verilog implementation of a 32-bit MIPS **single-cycle** CPU supporting exactly **14 instructions**:

1. `add`  
2. `sub`  
3. `and`  
4. `or`  
5. `lw`  
6. `sw`  
7. `slt`  
8. `beq`  
9. `bne`  
10. `j`  
11. `jal`  
12. `srl`  
13. `sltiu`  
14. `lhu`  

---

## 📁 Repository Layout


---

## 🖼️ Datapath Diagram

![Single-cycle datapath](img/Screenshot%202025-05-12%20003011.png)

---

## 🎛️ Control-Signal Cheat Sheet

### 1-bit control signals

| Instr.  | RegDst | Jump | ExtSel | Branch | Bne | MemRead | MemWrite | MemtoReg | ALUSrc | RegWrite | Jal |
|:-------:|:------:|:----:|:------:|:------:|:---:|:-------:|:--------:|:--------:|:------:|:--------:|:---:|
| R-type  |   1    |  0   |   1    |   0    |  0  |    0    |     0    |     0    |   0    |     1    |  0  |
| **srl** |   1    |  0   |   1    |   0    |  0  |    0    |     0    |     0    |   0    |     1    |  0  |
| `lw`    |   0    |  0   |   1    |   0    |  0  |    1    |     0    |     1    |   1    |     1    |  0  |
| `sw`    |   x    |  0   |   1    |   0    |  0  |    0    |     1    |     x    |   1    |     0    |  0  |
| `beq`   |   x    |  0   |   1    |   1    |  0  |    0    |     0    |     x    |   0    |     0    |  0  |
| `bne`   |   x    |  0   |   1    |   1    |  1  |    0    |     0    |     x    |   0    |     0    |  0  |
| `j`     |   x    |  1   |   x    |   0    |  0  |    0    |     0    |     x    |   x    |     0    |  0  |
| `jal`   |   x    |  1   |   x    |   0    |  0  |    0    |     0    |     x    |   x    |     1    |  1  |
| `sltiu` |   0    |  0   | **0**  |   0    |  0  |    0    |     0    |     0    |   1    |     1    |  0  |
| `lhu`   |   0    |  0   |   1    |   0    |  0  |    1    |     0    |     1    |   1    |     1    |  0  |

### ALU-control decoding

| ALUOp | funct (R-type) | Instruction | Action | `alu_control` |
|:-----:|:--------------:|:-----------:|:------:|:-------------:|
|  00   | —              | `lw`/`sw`/`lhu` | ADD  | `0010` |
|  01   | —              | `beq`/`bne`     | SUB  | `0110` |
|  11   | —              | `sltiu`         | SLTU | `1010` |
|  10   | `100000`       | `add`           | ADD  | `0010` |
|  10   | `100010`       | `sub`           | SUB  | `0110` |
|  10   | `100100`       | `and`           | AND  | `0000` |
|  10   | `100101`       | `or`            | OR   | `0001` |
|  10   | `101010`       | `slt`           | SLT  | `0111` |
|  10   | `000010`       | `srl`           | SRL  | `1001` |

---

## 💾 Memory Organization

- **Instruction memory**: 1 KB (256 × 32 bits), word-aligned  
- **Data memory**:        1 KB (256 × 32 bits), word-aligned; `lhu` reads half-word zero-extended

---

## 🔧 Testbench & `program1.mem`

- **`tb/program1.mem`** holds the 14 instructions in hex (one per line).  
- To **modify the program**, open `tb/program1.mem`, edit or reorder the 14 hex words, save, and rerun the testbench.  
- **Initialization in `processor_tb.v`** before simulation:
  1. **Registers**  
     ```verilog
     uut.REG_FILE.registers[8]  = 32'd5;   // $t0
     uut.REG_FILE.registers[9]  = 32'd3;   // $t1
     uut.REG_FILE.registers[11] = 32'd99;  // $t3
     uut.REG_FILE.registers[18] = 32'd7;   // $s2 (for SRL)
     ```
  2. **Data memory**  
     ```verilog
     uut.DATA_MEMORY.memory[0] = 32'h0000ABCD;
     uut.DATA_MEMORY.memory[1] = 32'hDEADBEEF;
     uut.DATA_MEMORY.memory[9] = 32'h12345678;
     ```
  3. **Instruction memory**  
     ```verilog
     $readmemh("program1.mem", uut.INSTR_MEM.memory);
     ```

---

## 🚀 Quick Run

```bash
cd src
iverilog -g2012 -o ../build/run.vvp *.v ../tb/processor_tb.v
cd ..
vvp build/run.vvp
