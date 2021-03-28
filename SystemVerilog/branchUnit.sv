/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ////////////////////////////////////////////////// BRANCH UNIT //////////////////////////////////////////////////////////////////////////////////////
 //////////////////////////////////////// Developed By: Willian Analdo Nunes /////////////////////////////////////////////////////////////////////////
 //////////////////////////////////////////// PUCRS, Porto Alegre, 2020      /////////////////////////////////////////////////////////////////////////
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

//BUG FIXED --> JALR was adding the A operand(target address) to C operand(in J_type instructions OPC is 0), when it should add the OPA to the B operand(the offset imediate).

`include "pkg.sv"
import my_pkg::*;

module branchUnit
    (input logic clk,
    input logic [31:0]  opA, // 1st Operand from register bank
    input logic [31:0]  opB, // 2nd Operand from register bank
    input logic [31:0]  offset, // Imediate
    input logic [31:0]  NPC, // PC
    input instruction_type i,
    output logic [31:0] result_out,
    output logic [31:0] result_jal, // Jal return address
    output logic        jump_out,
    output logic        we_out);

    logic [31:0]        result, result_int;
    logic [31:0]        result_jal_int;
    logic               jump;
    logic               we_int;

    assign result_int = opA + opB;                       // Generates the JALR target
  ////////////////////////////////////////////////////////////// Result assign ////////////////////////////////////////////////////////////////////////
    always_comb begin
      if(i==OP6) begin
          result <= opA + opB;                            // OPA==PC e OPB==OFFSET
          result_jal_int <= NPC+4;                                // The return address is the instruction following the JAL
      end else if(i==OP7) begin
          result[31:1] <= result_int[31:1];                // JALR result recieves the target calculated and assigned to result_int
          result[0]<=0;                                   // The less significant digit is 0
          result_jal_int <= NPC+4;                                // The return address is the instruction following the JAL
      end else begin
          result <= NPC + offset;                         // The new PC address is PC + imediate
          result_jal_int <= 32'h00000000;                         // Return address is not used
      end
    end


    ////////////////////////////////////////////////////////////// Genarates the branch signal //////////////////////////////////////////////////////////
    always_comb begin
        if(i==OP0)                                              // Branch if equal
          jump <= (opA == opB);
        else if(i==OP1)                                         // Branch if not equal
          jump <= (opA != opB);
        else if(i==OP2)                                         // Branch if less than
          jump <= ($signed(opA) < $signed(opB));
        else if(i==OP3)                                        // Branch if less than unsigned
          jump <= ($unsigned(opA) < $unsigned(opB));
        else if(i==OP4)                                         // Branch if greather than
          jump <= ($signed(opA) >= $signed(opB));
        else if(i==OP5)                                        // Branch if greather than
          jump <= ($unsigned(opA) >= $unsigned(opB));
        else if(i==OP6 || i==OP7)                               // Unconditional Branches
          jump <= 1;
        else
          jump <= 0;
    end

    always_comb 
      if(i==OP6 || i==OP7)
        we_int <= '1;
      else 
        we_int <= '0;


    always @(posedge clk) begin
          result_out <= result;
          result_jal <= result_jal_int;
          jump_out <= jump;
          we_out <= we_int;
      end

endmodule
