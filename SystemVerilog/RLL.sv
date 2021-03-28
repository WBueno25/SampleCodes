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
    input xu xu_sel_in,
    input fmts fmt,
    input logic [3:0] tag_in,
    input logic [31:0] in,
    output instruction_type i_out,
    output xu xu_sel,
    output logic [3:0] tag_out,
    output logic [31:0] opA,
    output logic [31:0] opB,
    output logic [31:0] opC,
    output logic [31:0] NPC,
    ///////////////////////////
    output logic [31:1] addrW,
    output logic [31:0] locked
    );

    logic [4:0] addra, addrb;
    logic [31:1] addrW;
    logic [31:0] dataA, dataB;
    logic [31:0] locked;

    OPF OPF1 (.addrA(addra), .addrB(addrb), .addrW(addrW), .*);

    regbank RB1 (.addra(addra), .addrb(addrb), .addrw(addrW), .outa(dataA), .outb(dataB), .*);

endmodule
