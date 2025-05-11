`timescale 1ns / 1ps
module mux_alu_src (
    input  [31:0] read_data2,
    input  [31:0] imm_ext,
    input         ALUSrc,
    output [31:0] alu_src_out
);
    assign alu_src_out = ALUSrc ? imm_ext : read_data2;
endmodule
