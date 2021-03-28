/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////// DECODER UNIT //////////////////////////////////////////////////////////////////
//////////////////////////////////////// Developed By: Willian Analdo Nunes ///////////////////////////////////////////////////
//////////////////////////////////////////// PUCRS, Porto Alegre, 2020      ///////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

`include "pkg.sv"
import my_pkg::*;

module decoder
    (input logic clk,
    input logic reset,
    input logic [31:0] NPC_IN,            // It's bypassed to npc_out
    input logic [31:0] instruction,       // Object code fetched in memory by fetch unit
    input logic [3:0] tag_in,      // The instruction tag
    output logic [4:0] regA,              // Address of the first register(rs1)
    output logic [4:0] regB,              // Address of the second register(rs2)
    output logic [4:0] regD,              // Address of the destination register(rd)
    output logic [31:0] NPC_out,          
    output fmts fmt_out,                  // Exit of signal "fmt" that indicates the instruction format
    output logic [31:0] instruction_out,  // Object code to Operand Fetch
    output instruction_type i_out,        // Decoded instruction 
    output xu xu_sel,
    output logic [3:0] tag_out);


    fmts fmt;                               // The fmt type is defined in the package
    i_type i;                     // as the instruction_type                           
    xu xu_int;
    instruction_type op;


/////////////////////////////// Decodes the opcodes to find out the type of the instruction and then assign it to signal "i" ////////////////////////////
    always_comb begin
            if (instruction[6:0]==7'b0110111) i<=LUI;
        else if (instruction[6:0]==7'b0010111) i<=ADD;    //AUIPC
        else if (instruction[6:0]==7'b1101111) i<=JAL;

        else if (instruction[14:12]==3'b000 & instruction[6:0]==7'b1100111) i<=JALR;

        else if (instruction[14:12]==3'b000 & instruction[6:0]==7'b1100011) i<=BEQ;
        else if (instruction[14:12]==3'b001 & instruction[6:0]==7'b1100011) i<=BNE;
        else if (instruction[14:12]==3'b100 & instruction[6:0]==7'b1100011) i<=BLT;
        else if (instruction[14:12]==3'b101 & instruction[6:0]==7'b1100011) i<=BGE;
        else if (instruction[14:12]==3'b110 & instruction[6:0]==7'b1100011) i<=BLTU;
        else if (instruction[14:12]==3'b111 & instruction[6:0]==7'b1100011) i<=BGEU;

        else if (instruction[14:12]==3'b000 & instruction[6:0]==7'b0000011) i<=LB;
        else if (instruction[14:12]==3'b001 & instruction[6:0]==7'b0000011) i<=LH;
        else if (instruction[14:12]==3'b010 & instruction[6:0]==7'b0000011) i<=LW;
        else if (instruction[14:12]==3'b100 & instruction[6:0]==7'b0000011) i<=LBU;
        else if (instruction[14:12]==3'b101 & instruction[6:0]==7'b0000011) i<=LHU;

        else if (instruction[14:12]==3'b000 & instruction[6:0]==7'b0100011) i<=SB;
        else if (instruction[14:12]==3'b001 & instruction[6:0]==7'b0100011) i<=SH;
        else if (instruction[14:12]==3'b010 & instruction[6:0]==7'b0100011) i<=SW;
        
        else if (instruction[14:12]==3'b000 & instruction[6:0]==7'b0010011) i<=ADD;         // ADDI
        else if (instruction[14:12]==3'b010 & instruction[6:0]==7'b0010011) i<=SLT;         // SLTI
        else if (instruction[14:12]==3'b011 & instruction[6:0]==7'b0010011) i<=SLTU;        // SLTIU
        else if (instruction[14:12]==3'b100 & instruction[6:0]==7'b0010011) i<=XOR;         // XORI
        else if (instruction[14:12]==3'b110 & instruction[6:0]==7'b0010011) i<=OR;          // ORI
        else if (instruction[14:12]==3'b111 & instruction[6:0]==7'b0010011) i<=AND;         // ANDI

        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b001 & instruction[6:0]==7'b0010011) i<=SLL;        // SLLI
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b101 & instruction[6:0]==7'b0010011) i<=SRL;        // SRLI
        else if (instruction[31:25]==7'b0100000 & instruction[14:12]==3'b101 & instruction[6:0]==7'b0010011) i<=SRA;        // SRAI

        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b000 & instruction[6:0]==7'b0110011) i<=ADD;
        else if (instruction[31:25]==7'b0100000 & instruction[14:12]==3'b000 & instruction[6:0]==7'b0110011) i<=SUB;
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b001 & instruction[6:0]==7'b0110011) i<=SLL;
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b010 & instruction[6:0]==7'b0110011) i<=SLT;
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b011 & instruction[6:0]==7'b0110011) i<=SLTU;
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b100 & instruction[6:0]==7'b0110011) i<=XOR;
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b101 & instruction[6:0]==7'b0110011) i<=SRL;
        else if (instruction[31:25]==7'b0100000 & instruction[14:12]==3'b101 & instruction[6:0]==7'b0110011) i<=SRA;
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b110 & instruction[6:0]==7'b0110011) i<=OR;
        else if (instruction[31:25]==7'b0000000 & instruction[14:12]==3'b111 & instruction[6:0]==7'b0110011) i<=AND;
/*
        else if (instruction[6:0]==7'b0001111) i<=FENCE;  // Opcodes of fence and ecall instructions that wasnt implemented at the first version
        else if (instruction[31:22]==  '0 & instruction[6:0]==7'b1110011) i<=ECALL;
        else if (instruction[6:0]==7'b1110011) i<=CSRR;
*/
        else if (instruction[31:0]==32'h00000000) i<=NOP; // Standard NOP instruction
        else if (instruction[31:0]==32'h00000013) i<=NOP;

        else begin 
            i<=INVALID;
        end
    end


    always_comb 
        case (i)
            ADD, SUB, SLTU, SLT:                        xu_int <= adder;
            XOR, OR, AND:                               xu_int <= logical;
            SLL, SRL, SRA:                              xu_int <= shifter;
            BEQ, BNE, BLT, BLTU, BGE, BGEU, JAL, JALR:  xu_int <= branch;
            LB, LBU, LH, LHU, LW, SB, SH, SW:           xu_int <= memory;
            default:                                    xu_int <= bypass;
        endcase


    always_comb 
        case (i)
            ADD, XOR, SLL, BEQ, LB:         op<=OP0;
            SUB, OR, SRL, BNE, LBU, LUI:    op<=OP1;
            SLTU, AND, SRA, BLT, LH:        op<=OP2;
            SLT, BLTU, LHU:                 op<=OP3;
            BGE, LW:                        op<=OP4;
            BGEU, SW:                       op<=OP5;
            JAL, SH:                        op<=OP6;
            JALR, SB:                       op<=OP7;
            default:                        op<=OP0;
        endcase




/////////////////////////////////////////////////  Decodes the instruction format ////////////////////////////////////////////////////////////////////////
    always_comb begin    
        if(instruction[6:0]==7'b0010011 | instruction[6:0]==7'b1100111 | instruction[6:0]==7'b0000011) // Register-Imediate(ADDI,ORI,ANDI,JALR,LOADS)
            fmt <= I_type;                  
        else if(instruction[6:0]==7'b0100011) // Store_type(SW,SB,SH)
            fmt <= S_type;
        else if(instruction[6:0]==7'b1100011) // Conditional branches(BEQ,BNE,BLT)
            fmt <= B_type;
        else if (instruction[6:0]==7'b0110111 | instruction[6:0]==7'b0010111) // U_type(LUI,AUIPC)
            fmt <= U_type;
        else if (instruction[6:0]==7'b1101111) // J_type(JAL)
            fmt <= J_type;
        else                                   // Register-Register instructions (ADD,SUB,AND...)
            fmt <= R_type;                      
    end

////////////////////////////////////////////////// Instantiation of output registers ///////////////////////////////////////////////////////////////////
    always @(posedge clk or negedge reset)
        if(!reset) begin
            regA <= '0;
            regB <= '0;
            regD <= '0;
            NPC_out <= '0;
            instruction_out <= '0;
            fmt_out <= '0;
            i_out <= '0;
            xu_sel <= '0;
            tag_out <= '0; 
        end else begin
            regA <= instruction[19:15];
            regB <= instruction[24:20];
            regD <= instruction[11:7];
            NPC_out <= NPC_IN;
            instruction_out <= instruction;
            fmt_out <= fmt;
            i_out <= op;
            xu_sel <= xu_int;
            tag_out <= tag_in;
        end

endmodule