`timescale 1ns / 1ps
module mux_memtoreg (
    input  [31:0] alu_out,
    input  [31:0] read_data_mem,
    input  [31:0] pc_next,
    input         MemtoReg,
    input         Jal,
    output [31:0] write_data
);
    assign write_data = Jal      ? pc_next      :
                        MemtoReg ? read_data_mem:
                                    alu_out;
endmodule
