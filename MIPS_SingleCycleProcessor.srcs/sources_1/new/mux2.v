`timescale 1ns / 1ps
module shift_left_2_branch (
    input  [31:0] imm_ext,
    output [31:0] shift_left
);
    assign shift_left = imm_ext << 2;
endmodule
