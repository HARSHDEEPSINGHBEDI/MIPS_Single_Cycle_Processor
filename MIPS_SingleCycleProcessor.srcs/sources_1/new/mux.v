`timescale 1ns / 1ps
module mux_reg_dst (
    input  [4:0] rt,
    input  [4:0] rd,
    input        RegDst,
    input        Jal,
    output reg [4:0] reg_dst_out
);
    always @(*) begin
        if (Jal)
            reg_dst_out = 5'd31; // $ra
        else if (RegDst)
            reg_dst_out = rd;    // R-type
        else
            reg_dst_out = rt;    // I-type
    end
endmodule
