`timescale 1ns / 1ps
module control_unit (
    input  [5:0] opcode,
    input  [5:0] funct,
    output reg RegDst,
    output reg Jump,
    output reg ExtSel,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg Jal,
    output reg [1:0] mem_mode,
    output reg Bne
);
    always @(*) begin
        RegDst   = 0;
        Jump     = 0;
        Branch   = 0;
        MemRead  = 0;
        MemtoReg = 0;
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 0;
        RegWrite = 0;
        Jal      = 0;
        mem_mode = 2'b00;
        Bne      = 0;
        ExtSel   = 1;

        case (opcode)
            6'b000000: begin
                case (funct)
                    6'b000010: begin      // SRL
                        RegDst   = 1;
                        RegWrite = 1;
                        ALUOp    = 2'b10;
                    end
                    default: begin        // other R-type
                        RegDst   = 1;
                        RegWrite = 1;
                        ALUOp    = 2'b10;
                    end
                endcase
            end
            6'b100011: begin              // lw
                ALUSrc   = 1;
                MemRead  = 1;
                MemtoReg = 1;
                RegWrite = 1;
            end
            6'b101011: begin              // sw
                ALUSrc   = 1;
                MemWrite = 1;
            end
            6'b000100: begin              // beq
                Branch = 1;
                ALUOp  = 2'b01;
            end
            6'b000101: begin              // bne
                Branch = 1;
                ALUOp  = 2'b01;
                Bne    = 1;
            end
            6'b000010: Jump = 1;          // j
            6'b000011: begin              // jal
                Jump     = 1;
                RegWrite = 1;
                Jal      = 1;
            end
            6'b001011: begin              // sltiu
                ALUSrc   = 1;
                RegWrite = 1;
                ALUOp    = 2'b11;
                ExtSel   = 0;
            end
            6'b100101: begin              // lhu
                ALUSrc   = 1;
                MemRead  = 1;
                MemtoReg = 1;
                RegWrite = 1;
                mem_mode = 2'b01;
            end
        endcase
    end
endmodule
