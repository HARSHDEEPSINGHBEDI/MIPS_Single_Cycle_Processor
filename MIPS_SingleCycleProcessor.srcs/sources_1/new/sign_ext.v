`timescale 1ns / 1ps
module sign_ext (
    input  [15:0] imm,
    input         ExtSel,     // 1 = sign-extend, 0 = zero-extend
    output reg [31:0] imm_ext
);
    always @(*) begin
        if (ExtSel)
            imm_ext = {{16{imm[15]}}, imm}; // sign-extend
        else
            imm_ext = {16'b0, imm};         // zero-extend (sltiu)
    end
endmodule
