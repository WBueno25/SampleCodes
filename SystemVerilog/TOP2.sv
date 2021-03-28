`include "fetch.sv"
`include "decoder.sv"
`include "RLL.sv"
`include "execute.sv"
`include "retire.sv"

//`define debug 1
//`include "pkg.sv"
import my_pkg::*;

module TOP2(
    input logic clk,
    input logic reset,
    input logic [31:0] instruction,
    output logic [31:0] i_address,
    /////////////////////////////////
    output logic [31:0] read_address,
    output logic read,
    input logic [31:0] DATA_in,
    /////////////////////////////////
    output logic [31:0] write_address, 
    output logic [31:0] DATA_out,
    output logic write,
    output logic [1:0] size,
    /////////////////////////////////
    output logic reg_we,
    output logic [31:0] WrData,
    output logic [31:0] New_pc,
    `ifdef debug

    /////////////////////////////////
    output logic [31:0] NPC_decoder,
    output logic [3:0] tag_decoder,
    /////////////////////////////////
    output logic [4:0] regA,
    output logic [4:0] regB,
    output logic [4:0] regD,
    output logic [31:0] NPC_RLL,
    output fmts fmt_RLL,
    output logic [31:0] instruction_RLL,
    output instruction_type i_RLL,
    output xu xu_RLL,
    output logic [3:0] tag_RLL,
    ///////////////////////////
    output logic [31:1] addrW,
    output logic [31:0] locked,
    ///////////////////////////////
    output instruction_type i_exec,
    output xu xu_exec,
    output logic [3:0] tag_exec,
    output logic [31:0] opA,
    output logic [31:0] opB,
    output logic [31:0] opC,
    output logic [31:0] NPC,
    /////////////////////////////////////
    output logic [31:0] result_ret [1:0],
    output logic we_ret,
    output logic jump_ret,
    output logic [3:0] tag_ret,
    output logic write_ret,
    output logic [1:0] size_ret
    `endif
    );

    logic [4:0] regA, regB, regD;
    logic [31:0] NPC_decoder, NPC_RLL, instruction_RLL; 
    fmts fmt_RLL;
    instruction_type i_RLL, i_exec, i_ret;
    logic [3:0] tag_decoder, tag_RLL, tag_exec, tag_ret;
    
    logic [31:0] opA, opB, opC, NPC;

    logic [31:0] result_ret [1:0];
    logic jump_ret, write_ret;
    logic [1:0] size_ret;
    logic we_ret;

    logic we_int, we_int2, reg_we;
    logic [31:0] WrData_int, WrData_int2, WrData, New_pc;
    logic [31:0] New_pc_int, New_pc_int2;
    logic [31:0] NPC_decoder_int, tag_decoder_int;
    xu xu_RLL, xu_exec;

    logic [31:1] addrW;
    logic [31:0] locked;

    always@(posedge clk) begin
        New_pc_int2 <= New_pc_int;
        New_pc <= New_pc_int2;
        NPC_decoder <= NPC_decoder_int;
        tag_decoder <= tag_decoder_int;
    end

    fetch Ifetch (  .NewPC(New_pc),
                    .NPC(NPC_decoder_int), .tag_out(tag_decoder_int), .*);

    decoder decode ( .NPC_IN(NPC_decoder), .tag_in(tag_decoder),
                    .i_out(i_RLL), .tag_out(tag_RLL), .NPC_out(NPC_RLL), .instruction_out(instruction_RLL), .fmt_out(fmt_RLL), .xu_sel(xu_RLL), .*);

    RLL RLL1 ( .NPC_in(NPC_RLL), .instruction(instruction_RLL), .i(i_RLL), .fmt(fmt_RLL), .tag_in(tag_RLL), .we(reg_we), .in(WrData),
                .i_out(i_exec), .tag_out(tag_exec), .xu_sel_in(xu_RLL), .xu_sel(xu_exec), .*);

    execute Exec ( .i(i_exec), .tag_in(tag_exec), .xu_sel(xu_exec), 
                   .result_out(result_ret), .jump_out(jump_ret), .stream_tag_out(tag_ret), .write(write_ret), .size(size_ret), .we_out(we_ret), .*);

    retire Retire (.result(result_ret), .jump(jump_ret), .instruction_tag(tag_ret), .write_in(write_ret), .size_in(size_ret), .we(we_ret), 
                    .reg_we(reg_we), .WrData(WrData), .New_pc(New_pc_int), .*);

endmodule
