`timescale 1ns / 1ps
module processor_tb;

    reg clk   = 0;
    reg reset = 1;
    integer i;

    processor uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;   // 10-ns clock

    initial begin
        $display("\n==== Single-Cycle MIPS Test ====\n");

        #10 reset = 0;       // release reset

        uut.REG_FILE.registers[8]  = 32'd5;
        uut.REG_FILE.registers[9]  = 32'd3;
        uut.REG_FILE.registers[11] = 32'd99;
        uut.REG_FILE.registers[18] = 32'd7;    // $s2  

        uut.DATA_MEMORY.memory[0] = 32'h0000ABCD;
        uut.DATA_MEMORY.memory[1] = 32'hDEADBEEF;
        uut.DATA_MEMORY.memory[9] = 32'h12345678;

        $readmemh("program1.mem", uut.INSTR_MEM.memory);

        @(posedge clk);

        for (i = 0; i < 14; i = i + 1) begin
            @(posedge clk);
            $display("\nT=%0t | PC=%0d | instr=0x%h",
                     $time, uut.pc_out, uut.instruction);
        end

        $finish;
    end
endmodule
