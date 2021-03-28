/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 ///////////////////////////////////////////////// EXECUTE UNIT //////////////////////////////////////////////////////////////////////////////////////
 //////////////////////////////////////// Developed By: Willian Analdo Nunes /////////////////////////////////////////////////////////////////////////
 //////////////////////////////////////////// PUCRS, Porto Alegre, 2020      /////////////////////////////////////////////////////////////////////////
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/


`include "adder.sv"
`include "logicUnit.sv"
`include "shiftUnit.sv"
`include "branchUnit.sv"
`include "bypassUnit.sv"
`include "memoryUnit.sv"

//`include "pkg.sv"
import my_pkg::*;

module execute2(
               input logic         clk,
               input logic         reset,
               input logic [31:0]  NPC, // Operands from Operand Fetch stage
               input logic [31:0]  opA, //              ||
               input logic [31:0]  opB, //              ||
               input logic [31:0]  opC, //              ||
               input               instruction_type i,
               input logic [3:0] stream_tag_in,            // Instruction type
               output logic [31:0] result_out [1:0], // Results vector(one from each unit)
               output logic        jump_out,                       // Signal that indicates a branch taken
               output logic [3:0] stream_tag_out,
               output instruction_type i_out,
   output logic [31:0] read_address,
   output logic read,                            // Ce to memory read
   input logic [31:0] DATA_in,                 // Data coming from memory
   output logic write,                            // Signal that indicates the write memory operation
   output logic [1:0] size);                           // Signal that indicates the size of Read or Write in memory(byte(1),half(2),word(4))


   logic                           jump_int, write_int;
   logic [1:0] size_int;
   instruction_type i_execute_2;
   logic [31:0]                    adderA, adderB, logicA, logicB, shiftA, shiftB, branchA, branchB, branchC, memoryA, memoryB, memoryC, bypassB, NPCbranch;
   logic [31:0] result [7:0];
   instruction_type adder_i, logic_i, shift_i, branch_i, memory_i, queue_i;
   logic [3:0] stream_tag_stage2;
   xu xu_sel, xu_stage2;
   
   logic sel_adder, sel_logic, sel_shift, sel_branch, sel_bypass, sel_memory;
   
   assign xu_sel = xu'(i[5:3]);
   assign xu_stage2 = xu'(i_out[5:3]);

   
   ////////////////////////////////////////////////////// Instantiation of execution units  /////////////////////////////////////////////////////////////
   adder adder1 (.clk(clk), .opA(adderA), .opB(adderB), .i(adder_i), .result_out(result[0]));
   logicUnit logical1 (.clk(clk), .opA(logicA), .opB(logicB), .i(logic_i), .result_out(result[1]));
   shiftUnit shift1 (.clk(clk), .opA(shiftA), .opB(shiftB), .i(shift_i), .result_out(result[2]));
   branchUnit branch1 (.clk(clk), .opA(branchA), .opB(branchB), .offset(branchC), .NPC(NPCbranch), .i(branch_i), .result_out(result[4]), .result_jal(result[3]), .jump_out(jump_int));
   bypassUnit bypassUnit1 (.clk(clk), .reset(reset), .opA(bypassB), .result_out(result[5]));
   memoryUnit memory1 (.clk(clk), .opA(memoryA), .opB(memoryB), .data(memoryC), .i(memory_i), .read_address(read_address), .read(read), .DATA_in(DATA_in), .write_address(result[7]), .DATA_wb(result[6]),  .write(write_int), .size(size_int));
   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   //orderQueue iexecuteQueue (.clk(clk), .reset(reset), .stream_tag_in(stream_tag_in), .i(i), .stream_tag_out(stream_tag_out), .i_out(i_out));

   always@(posedge clk or negedge reset) begin
      if(!reset) begin
         i_execute_2 <= NOP;
         i_out <= NOP;
         stream_tag_stage2 <= '0;
         stream_tag_out <= '0;
      end else begin
         i_execute_2 <= i;
         i_out <= i_execute_2;
         stream_tag_stage2 <= stream_tag_in;
         stream_tag_out <= stream_tag_stage2;
      end
   end

   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   //always@(posedge clk) begin
   always_comb begin
      ////////////////////////////////////// adder /////////////////////////////////////////////////////////
      if(xu_sel==adder) begin
         adder_i <= i;
         adderA <= opA;
         adderB <= opB;
      end else begin
         adder_i <= NOTOKEN;
         adderA <= 'Z;
         adderB <= 'Z;
      end
      ////////////////////////////////////// logic /////////////////////////////////////////////////////////
      if (xu_sel==logical) begin
         logic_i <= i;
         logicA <= opA;
         logicB <= opB;
      end else begin
         logic_i <= NOTOKEN;
         logicA <= 'Z;
         logicB <= 'Z;
      end
      ////////////////////////////////////// shift /////////////////////////////////////////////////////////
      if (xu_sel==shifter) begin
         shift_i <= i;
         shiftA <= opA;
         shiftB <= opB;
      end else begin
         shift_i <= NOTOKEN;
         shiftA <= 'Z;
         shiftB <= 'Z;
      end
      ////////////////////////////////////// branch /////////////////////////////////////////////////////////
      if (xu_sel==branch) begin
         branch_i <= i;
         branchA <= opA;
         branchB <= opB;
         branchC <= opC;
         NPCbranch <= NPC;
      end else begin
         branch_i <= NOTOKEN;
         branchA <= 'Z;
         branchB <= 'Z;
         branchC <= 'Z;
         NPCbranch <= 'Z;
      end
      ////////////////////////////////////// memory /////////////////////////////////////////////////////////
      if (xu_sel==memory) begin
         memory_i <= i;
         memoryA <= opA;
         memoryB <= opB;
         memoryC <= opC;
      end else begin
         memory_i <= NOTOKEN;
         memoryA <= 'Z;
         memoryB <= 'Z;
         memoryC <= 'Z;
      end
      ////////////////////////////////////// bypass /////////////////////////////////////////////////////////
      if(xu_sel==bypass) begin
         bypassB <= opB;
      end else begin
         bypassB <= 'Z;
      end
   end


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////// DEMUX ////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   assign sel_adder =   (xu_stage2==adder) ? '1 : '0;
   assign sel_logic = (xu_stage2==logical) ? '1 : '0;
   assign sel_shift = (xu_stage2==shifter) ? '1 : '0;
   assign sel_branch = (xu_stage2==branch) ? '1 : '0;
   assign sel_bypass = (xu_stage2==bypass) ? '1 : '0;
   assign sel_memory = (xu_stage2==memory) ? '1 : '0;


   for (genvar i = 0; i < 32 ; i++) begin
      hold adder_h (.a(result[0][i]), .en(sel_adder), .q(result_out[0][i]), .*);
      hold logic_h (.a(result[1][i]), .en(sel_logic), .q(result_out[0][i]), .*);
      hold shift_h (.a(result[2][i]), .en(sel_shift), .q(result_out[0][i]), .*);
      hold branch_h (.a(result[3][i]), .en(sel_branch), .q(result_out[0][i]), .*);
      hold bypass_h (.a(result[5][i]), .en(sel_bypass), .q(result_out[0][i]), .*);
      hold dataWB_h (.a(result[6][i]), .en(sel_memory), .q(result_out[0][i]), .*);
   end

   for (genvar i = 0; i < 32 ; i++) begin
      hold branchjal_h (.a(result[4][i]), .en(sel_branch), .q(result_out[1][i]), .*);
      hold WriteADD_h (.a(result[7][i]), .en(sel_memory), .q(result_out[1][i]), .*);
      discard zero1_d (.a(0), .en((!sel_branch) && (!sel_memory)), .q(result_out[1][i]), .*);
   end

      hold jump_h (.a(jump_int), .en(sel_branch), .q(jump_out), .*);
      discard zeroJ_d (.a(0), .en(!sel_branch), .q(jump_out), .*);

      for (genvar i = 0; i < 2 ; i++) begin
         hold size_h (.a(size_int[i]), .en(sel_memory), .q(size[i]), .*);
         discard zeroS_d (.a(0), .en(!sel_memory), .q(size[i]), .*);
      end
      
      hold write_h (.a(write_int), .en(sel_memory), .q(write), .*);
      discard zeroW_d (.a(0), .en(!sel_memory), .q(write), .*);

endmodule
