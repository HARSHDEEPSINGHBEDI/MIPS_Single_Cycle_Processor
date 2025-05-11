`timescale 1ns / 1ps

module processor (
    input  clk,
    input  reset
);

    wire [31:0] pc_in, pc_next, pc_out;

    wire [31:0] instruction;
    wire [5:0]  opcode;
    wire [4:0]  rs, rt, rd, shamt;
    wire [5:0]  funct;
    wire [15:0] imm;
    wire [25:0] instr_address;

    wire [31:0] read_data1, read_data2, write_data;
    wire [31:0] imm_ext, shift_left;
    wire [31:0] alu_src_out, alu_out, branch_target;
    wire [31:0] mem_read_data;
    wire [27:0] jump_shifted;
    wire [31:0] jump_target;
    wire [31:0] br_final;
    wire [31:0] alu_result_or_mem;
    wire [31:0] jump_or_branch_pc;
    wire [31:0] alu_input1;

    wire RegDst, Branch, Bne, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, Jump;
    wire Jal;
    wire [1:0] ALUOp;
    wire [3:0] alu_control;
    wire zero_flag;
    wire overflow_flag;
    wire [31:0] read_data_mem;
    wire [1:0] mem_mode;
    wire [4:0] reg_dst_out;
    wire ExtSel;

    pc PC (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    adder ADD (
        .pc_out(pc_out),
        .pc_next(pc_next)
    );

    instr_mem INSTR_MEM (
        .pc_out(pc_out),
        .instruction(instruction),
        .opcode(opcode),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(funct),
        .imm(imm),
        .instr_address(instr_address)
    );

    control_unit Control (
        .opcode(opcode),
        .funct(funct),
        .RegDst(RegDst),
        .Jump(Jump),
        .ExtSel(ExtSel),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .Jal(Jal),
        .mem_mode(mem_mode),
        .Bne(Bne)
    );

    reg_file REG_FILE (
        .clk(clk),
        .RegWrite(RegWrite),
        .rs(rs),
        .rt(rt),
        .reg_dst_out(reg_dst_out),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    sign_ext SIGN_EXTEND (
        .imm(imm),
        .ExtSel(ExtSel),
        .imm_ext(imm_ext)
    );

    mux_reg_dst MUX_REG_DST (
        .rt(rt),
        .rd(rd),
        .RegDst(RegDst),
        .Jal(Jal),
        .reg_dst_out(reg_dst_out)
    );

    shift_left_2_branch SHIFT_LEFT_BRANCH (
        .imm_ext(imm_ext),
        .shift_left(shift_left)
    );

    mux_alu_src MUX_ALU_SRC (
        .read_data2(read_data2),
        .imm_ext(imm_ext),
        .ALUSrc(ALUSrc),
        .alu_src_out(alu_src_out)
    );

    alu_control ALU_CONTROL (
        .ALUOp(ALUOp),
        .funct(funct),
        .alu_control(alu_control)
    );

    assign alu_input1 = (alu_control == 4'b1001) ? read_data2 : read_data1;

    alu ALU (
        .read_data1(alu_input1),
        .alu_src_out(alu_src_out),
        .alu_control(alu_control),
        .alu_out(alu_out),
        .shamt(shamt),
        .zero(zero_flag),
        .overflow(overflow_flag)
    );

    data_mem DATA_MEMORY (
        .clk(clk),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .mem_mode(mem_mode),
        .alu_out(alu_out),
        .read_data2(read_data2),
        .read_data_mem(read_data_mem)
    );

    mux_memtoreg MUX_MEMTOREG (
        .alu_out(alu_out),
        .read_data_mem(read_data_mem),
        .MemtoReg(MemtoReg),
        .write_data(write_data),
        .Jal(Jal),
        .pc_next(pc_next)
    );

    shift_left_2_jump SHIFT_LEFT_JUMP (
        .instr_address(instr_address),
        .jump_shifted(jump_shifted)
    );

    alu_branch ALU_BRANCH (
        .pc_next(pc_next),
        .shift_left(shift_left),
        .branch_target(branch_target)
    );

    mux_br_sel MUX_BR_SEL (
        .pc_next(pc_next),
        .branch_target(branch_target),
        .Branch(Branch),
        .Bne(Bne),
        .zero_flag(zero_flag),
        .br_final(br_final)
    );

    mux_jump_sel MUX_JUMP_SEL (
        .br_final(br_final),
        .jump_shifted(jump_shifted),
        .pc_next(pc_next),
        .jump(Jump),
        .pc_in(pc_in)
    );

endmodule
