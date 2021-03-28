`include "execute.sv"
`include "retire.sv"

import my_pkg::*;


module ER(     // Execute & Retire
        input logic         clk,
        input logic         reset,
        input logic [31:0]  NPC, // Operands from Operand Fetch stage
        input logic [31:0]  opA, //              ||
        input logic [31:0]  opB, //              ||
        input logic [31:0]  opC, //              ||
        input instruction_type i,
        input logic [3:0] stream_tag_in,
   output logic [31:0] read_address,
   output logic read,
   input logic [31:0] DATA_in,
        output logic reg_we,
        output logic [31:0] WrData,
        output logic [31:0] New_pc,
    output logic [31:0] write_address,  
    output logic [31:0] DATA_out,
    output logic write,
    output logic [1:0] size,
    output instruction_type i_ret
   );
    
    logic [31:0] result_ret [1:0];
    logic jump_ret, write_ret;
    logic [3:0] stream_tag_ret;
    instruction_type i_ret1;
    logic [1:0] size_ret;

     assign i_ret = i_ret1;

   execute Exec (.result_out(result_ret), .jump_out(jump_ret), .stream_tag_out(stream_tag_ret), .i_out(i_ret1), .write(write_ret), .size(size_ret), .*);

   retire Retire (.result(result_ret), .jump(jump_ret), .i(i_ret1), .instruction_tag(stream_tag_ret), .write_in(write_ret), .size_in(size_ret), .*);

endmodule