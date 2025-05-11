`timescale 1ns / 1ps
module mux_jump_sel (
    input  [31:0] br_final,
    input  [27:0] jump_shifted,
    input  [31:0] pc_next,
    input         jump,
    output reg [31:0] pc_in
);
    always @(*) begin
        case (jump)
            1'b1: pc_in = {pc_next[31:28], jump_shifted}; // jump target
            1'b0: pc_in = br_final;                       // pc_next / branch
            default: pc_in = pc_next;
        endcase
    end
endmodule
