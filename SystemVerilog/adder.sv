/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////// ADDER UNIT ////////////////////////////////////////////////////////////////
 //////////////////////////////////////// Developed By: Willian Analdo Nunes ///////////////////////////////////////////////////
 //////////////////////////////////////////// PUCRS, Porto Alegre, 2020      ///////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

`include "pkg.sv"
import my_pkg::*;

module adder
    (input logic clk,
    input logic [31:0]  opA,
    input logic [31:0]  opB,
    input instruction_type i,
    output logic [31:0] result_out);

    logic [31:0]        result;

    always_comb begin
        if(i==OP3)                        // Set if opA is less than opB
          if($signed(opA) < $signed(opB))
            result <= 32'b1;
          else
            result <= 32'b0;

        else if(i==OP2)                 // Set if opA is less than opB UNSIGNED
          if($unsigned(opA) < $unsigned(opB))
            result <= 32'b1;
          else
            result <= 32'b0;

        else if(i==OP1)                             // SUBTRACT
          result <= opA - opB;

        else                                         // ADD (ADD,ADDI and AUIPC)
          result <= opA + opB;
    end


    always @(posedge clk)
        result_out <= result;

  endmodule
