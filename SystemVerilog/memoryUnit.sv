/*/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// MEMORY UNIT ////////////////////////////////////////////////////////////////
//////////////////////////////////////// Developed By: Willian Analdo Nunes ///////////////////////////////////////////////////
//////////////////////////////////////////// PUCRS, Porto Alegre, 2020      ///////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////*/

`include "pkg.sv"
import my_pkg::*;

module memoryUnit
    (input logic clk,
    input logic [31:0] opA,                          // Base Address
    input logic [31:0] opB,                          // Offset
    input logic [31:0] data,                         // Data to be Written in memory
    input instruction_type i, 
    output logic [31:0] read_address,                // Memory Address for read or write_2
    output logic read,                               // Signal that allows the operations with memory
    input logic [31:0] DATA_in,                      // Data received from memory
    output logic [31:0] write_address,               // Adrress to Write in memory
    output logic [31:0] DATA_wb,                     // Data to be Written in Register Bank or in memory
    output logic write,                              // Signal that indicates the memory operation
    output logic [1:0] size,
    output logic       we_out);                        // Signal that indicates the size of Write in memory(byte(1),half(2),word(4))


    instruction_type i_stage2;
    logic write_2;
    logic [31:0] DATA_wb_int, DATA_write, write_address_2, write_address_int;
    logic [1:0] size_int;
    logic we_int;

///////////////////////////////////// generate all signal and datas read or to be written ///////////////////////////////////////////////////////////
    always@(posedge clk) begin
        if(i==OP0 | i==OP1) begin                        // Load Byte signed and unsigned          
            write_2 <= 0;
            read <= 1;
            DATA_write <= '0;
            size_int <= 2'b00;

        end else if(i==OP2 | i==OP3) begin               // Load Half(16b) signed and unsigned
            write_2 <= 0;
            read <= 1;
            DATA_write <= '0;
            size_int <= 2'b00;

        end else if(i==OP4) begin                        // Load Word(32b)
            write_2 <= 0;
            read <= 1;
            DATA_write <= '0;
            size_int <= 2'b00;
                                                                    // The following instructions check if the write_2 in memory is enable
        end else if(i==OP7) begin            // Store Byte
            write_2 <= 1;
            read <= 0;
            DATA_write[31:8] <= 24'h000000;
            DATA_write[7:0] <= data[7:0];                 // Only the less significant byte is fullfilled with data, the rest is fullfilled with zeros
            size_int <= 2'b01;

        end else if(i==OP6) begin           // Store Half(16b)
            write_2 <= 1;
            read <= 0;
            DATA_write[31:16] <= 16'h0000;    
            DATA_write[15:0] <= data[15:0];               // Only the less significant half is fullfilled with data, the rest is fullfilled with zeros
            size_int <= 2'b10;

        end else if(i==OP5) begin            // Store Word
            write_2 <= 1;
            read <= 0;
            DATA_write[31:0] <= data[31:0];  
            size_int <= 2'b11;

        end else begin                                  // Case it's not a memory instruction it denies the memory access with ce in '0'.
            write_2 <= 'Z;
            read <= 'Z;
            DATA_write <= 'Z;
            size_int <= 'Z;
        end
/////////////////////////////////////////////////////////////////
        if(i==OP0 | i==OP1 | i==OP2 | i==OP3 | i==OP4)
            read_address = opA + opB;
        else 
            read_address = '0;
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always @(posedge clk) begin
        if(i_stage2==OP0 | i_stage2==OP1) begin
            if(DATA_in[7]==1 & i_stage2==OP0)                   // Signal extension
                DATA_wb_int[31:8] <= 24'hFFFFFF;
            else                                               // 0's extension
                DATA_wb_int[31:8] <= 24'h000000;            
            DATA_wb_int[7:0] <= DATA_in[7:0];

        end else if(i_stage2==OP2 | i_stage2==OP3) begin
            if(DATA_in[15]==1 & i_stage2==OP2)                  // Signal extension
                DATA_wb_int[31:16] <= 16'hFFFF;
            else                                               // 0's extension
                DATA_wb_int[31:16] <= 16'h0000; 
            DATA_wb_int[15:0] <= DATA_in[15:0];

        end else if(i_stage2==OP4)
            DATA_wb_int <= DATA_in;

        else                                                   // write_2
            DATA_wb_int <= DATA_write;
    end

    assign write_address_int = opA + opB;

    assign DATA_wb = DATA_wb_int;


    always_comb
        if(i_stage2==OP5 || i_stage2==OP6 || i_stage2==OP7)
            we_int<='0;
        else 
            we_int<='1;


    always@(posedge clk) begin
        write_address_2 <= write_address_int;
        write_address <= write_address_2;
        
        write <= write_2;
        i_stage2 <= i;
        size <= size_int;
        we_out <= we_int;
    end
endmodule