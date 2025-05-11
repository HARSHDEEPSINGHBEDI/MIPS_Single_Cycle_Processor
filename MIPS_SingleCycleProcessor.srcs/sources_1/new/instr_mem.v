`timescale 1ns / 1ps
module instr_mem (
    input  [31:0] pc_out,
    output reg [31:0] instruction,
    output [5:0] opcode,
    output [4:0] rs,
    output [4:0] rt,
    output [4:0] rd,
    output [4:0] shamt,
    output [5:0] funct,
    output [15:0] imm,
    output [25:0] instr_address
);
    reg [31:0] memory [0:255];

    always @(*) instruction = memory[pc_out >> 2];

    assign opcode        = instruction[31:26];
    assign rs            = instruction[25:21];
    assign rt            = instruction[20:16];
    assign rd            = instruction[15:11];
    assign shamt         = instruction[10:6];
    assign funct         = instruction[5:0];
    assign imm           = instruction[15:0];
    assign instr_address = instruction[25:0];

    initial $readmemh("program1.mem", memory);
endmodule
