`timescale 1ns / 1ps
module data_mem (
    input        clk,
    input        MemWrite,
    input        MemRead,
    input  [1:0] mem_mode,      // 00-word, 01-halfword (lhu)
    input  [31:0] alu_out,
    input  [31:0] read_data2,
    output reg [31:0] read_data_mem
);
    reg [31:0] memory [0:255];

    
    always @(*) begin
        read_data_mem = 32'd0;
        if (MemRead) begin
            case (mem_mode)
                2'b00: read_data_mem = memory[alu_out >> 2];                       // lw
                2'b01: read_data_mem = (alu_out[1] ? {16'd0, memory[alu_out>>2][31:16]}
                                                  : {16'd0, memory[alu_out>>2][15:0]}); // lhu
            endcase
        end
    end

    
    always @(posedge clk) begin
        if (MemWrite && mem_mode == 2'b00)
            memory[alu_out >> 2] <= read_data2;   // sw (word only)
    end
endmodule
