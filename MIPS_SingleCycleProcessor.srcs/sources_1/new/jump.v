`timescale 1ns / 1ps
module shift_left_2_jump (
    input  [25:0] instr_address,
    output [27:0] jump_shifted
);
    assign jump_shifted = instr_address << 2;
endmodule
