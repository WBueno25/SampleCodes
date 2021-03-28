`include "OPF.sv"
`include "regbank.sv"

`include "pkg.sv"
import my_pkg::*;

module RLL #(WIDTH=32) // REGISTER LOCKING LOOP
  (input logic clk, reset,
    input logic we,
    input logic [4:0] regA,
    input logic [4:0] regB,
    input logic [4:0] regD,
    input logic [31:0] NPC_in,
    input logic [31:0] instruction,
    input instruction_type i,
    input fmts fmt,
    input logic [3:0] tag_in,
    input logic [31:0] in,
    output instruction_type i_out,
    output logic [3:0] tag_out,
    output logic [31:0] opA,
    output logic [31:0] opB,
    output logic [31:0] opC,
    output logic [31:0] NPC,
    );

    logic [31:0] target_int, locked_int;
    logic [4:0] addra, addrb;
    logic [31:1] addrw;
    logic [31:0] dataA, dataB;

    OPF OPF1 (.addrA(addra), .addrB(addrb), .addrW(addrw), .*);

    regbank RB1 (.addra(addra), .addrb(addrb), .addrw(addrw), .outa(dataA), .outb(dataB), .*);

endmodule