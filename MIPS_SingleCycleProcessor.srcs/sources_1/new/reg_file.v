`timescale 1ns / 1ps
module reg_file (
    input  clk,
    input  RegWrite,
    input  [4:0] rs,
    input  [4:0] rt,
    input  [4:0] reg_dst_out,
    input  [31:0] write_data,
    output reg [31:0] read_data1,
    output reg [31:0] read_data2
);
    reg [31:0] registers [0:31];

    always @(*) begin
        read_data1 = registers[rs];
        read_data2 = registers[rt];
    end

    always @(posedge clk) begin
        if (RegWrite && reg_dst_out != 5'd0)
            registers[reg_dst_out] <= write_data;
    end
endmodule
