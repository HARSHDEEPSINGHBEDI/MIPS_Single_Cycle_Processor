`timescale 1ns / 1ps
module alu (
    input  [31:0] read_data1,
    input  [31:0] alu_src_out,
    input  [3:0]  alu_control,
    input  [4:0]  shamt,
    output reg [31:0] alu_out,
    output reg zero,
    output reg overflow
);
    always @(*) begin
        overflow = 0;
        case (alu_control)
            4'b0010: begin                        // ADD
                alu_out = read_data1 + alu_src_out;
                if ((read_data1[31]==alu_src_out[31]) && (alu_out[31]!=read_data1[31]))
                    overflow = 1;
            end
            4'b0110: begin                        // SUB
                alu_out = read_data1 - alu_src_out;
                if ((read_data1[31]!=alu_src_out[31]) && (alu_out[31]==alu_src_out[31]))
                    overflow = 1;
            end
            4'b0000: alu_out = read_data1 & alu_src_out;                    // AND
            4'b0001: alu_out = read_data1 | alu_src_out;                    // OR
            4'b0111: alu_out = (read_data1 < alu_src_out) ? 32'd1 : 32'd0;  // SLT
            4'b1001: alu_out = read_data1 >> shamt;                         // SRL
            4'b1010: alu_out = ($unsigned(read_data1) < $unsigned(alu_src_out)) ? 32'd1 : 32'd0; // SLTIU
            default: alu_out = 32'd0;
        endcase
        zero = (alu_out == 0);
    end
endmodule
