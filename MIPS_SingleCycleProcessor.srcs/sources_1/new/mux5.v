`timescale 1ns / 1ps
module mux_br_sel (
    input  [31:0] pc_next,
    input  [31:0] branch_target,
    input         Branch,
    input         Bne,
    input         zero_flag,
    output [31:0] br_final
);
    assign br_final = ( (Branch &&  zero_flag) ||
                        (Bne    && ~zero_flag) ) ? branch_target
                                                : pc_next;
endmodule
