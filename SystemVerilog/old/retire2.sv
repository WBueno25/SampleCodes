/*///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// RETIRE UNIT //////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////// Developed By: Willian Analdo Nunes /////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////// PUCRS, Porto Alegre, 2020      /////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

`include "pkg.sv"
import my_pkg::*;

module retire(
    input logic clk,
    input logic reset,
    input logic [31:0] result [1:0],        // Results vector(one from each unit)
    input logic jump,                       // Jump signal from branch unit
    input instruction_type i,               // Instruction type to genarate the wb_we signal
    input logic [3:0] instruction_tag,      // Instruction tag to be compared with retire tag
    input logic write_in,
    input logic [1:0] size_in,
    output logic reg_we,              // Write Enable to Register Bank
    output logic [31:0] WrData,
    output logic [31:0] New_pc,
    output logic [31:0] write_address,  
    output logic [31:0] DATA_out,
    output logic write,
    output logic [1:0] size,
    //output logic freeMem
    );        

    logic [31:0] data;
    logic [3:0] next_tag;
    logic [3:0] curr_tag;
    logic killed, jump_int;
    xu xu_sel;

    assign xu_sel = xu'(i[5:3]);

    assign jump_int = (xu_sel==branch && jump==1) ? 1 : 0;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always@(posedge clk)
        WrData <= result[0];

////////////////////////////////////////////////////// Killed signal generation /////////////////////////////////////////////////////////////////////
    always_comb
        if (curr_tag != instruction_tag)
            killed <= 1;
        else
            killed <= 0;

//////////////////////////////////////////////////// TAG control based on signals Jump and Killed ///////////////////////////////////////////////////
    always @(posedge clk or negedge reset) begin
        if(!reset)
            curr_tag <= 0;
        else if (jump_int & killed==0)      // If a jump was taken and the tag is correct
            curr_tag <= curr_tag + 1;
        else  
            curr_tag <= curr_tag;
    end

//assign curr_tag = '0;
//assign killed='0;


/////////////////////////////////////////////////// Flow Control ////////////////////////////////////////////////////////////////////////////////////
    always@(posedge clk)
        if(killed)
          reg_we <= 0;
        else if(xu_sel==adder | xu_sel==logical | xu_sel==shifter | i==LB | i==LW | i==LH  | i==LBU | i==LHU | i==LUI)
          reg_we <= 1;
        else if((i==JAL | i==JALR) && jump_int==1) 
          reg_we <= 1;
        else 
          reg_we <= '0;

//////////////////////////////////// PC Flow control signal generation //////////////////////////////////////////////////////////////////////////////
    always@(posedge clk)
        if (jump_int=='1 && killed=='0)
            New_pc <= result[1];
        else
            New_pc <= 'Z;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always@(posedge clk) begin
        if((i==SB | i==SH | i==SW) && killed==0) begin
            write <= write_in;
            size <= size_in;
            write_address <= result[1];
            DATA_out <= result[0];
        end else begin
            write <= 'Z;
            size <= 'Z;
            write_address <= 'Z;
            DATA_out <= 'Z;
        end
    end

/*
    always_comb
        if(!reset)
            freeMem <= 1;
        else if(i==SB | i==SH | i==SW)
            freeMem <= 1;
        else 
            freeMem <= 'Z;
*/

//always@(posedge clk)
//    if(i==INVALID & killed==0) $display("%t INVALID INSTRUCTION!!!",$time);
endmodule