`include "pkg.sv"
import my_pkg::*;

module OPF #(WIDTH=32)
  (input logic clk, reset,
    //input logic [31:0] locked,
    input logic we,
    input logic [4:0] regA,
    input logic [4:0] regB,
    input logic [4:0] regD,
    input logic [31:0] NPC_in,
    input logic [31:0] instruction,
    input instruction_type i,
    input fmts fmt,
    input logic [3:0] tag_in,
    output logic [4:0] addrA,
    output logic [4:0] addrB,
    output logic [31:1] addrW,
    //output logic [31:0] target,
    output instruction_type i_out,
    output logic [3:0] tag_out,
    input logic [31:0] dataA,
    input logic [31:0] dataB,
    output logic [31:0] opA,
    output logic [31:0] opB,
    output logic [31:0] opC,
    output logic [31:0] NPC
    );

    typedef enum bit {LOCK, UNLOCK} state_t;
    logic [4:0] a_r, b_r, d_r, a_next, b_next, d_next;
    logic [31:0] NPC_r, instruction_r, NPC_next, NPC_int, instruction_next;
    logic [3:0] tag_r, tag_next, tag_int;
    logic [2:0] fmt_r, fmt_next;
    state_t             ps, ns;
    logic               accept_input, accept_output, accept_locked;
    instruction_type i_r, i_next;
    logic bubble_int;
    logic [31:0] locked_r, target_int;
    logic [31:0] dataA_int, dataB_int, opA_int, opB_int, opC_int, imed;

    parameter DEPTH = 4;
    wor [31:0] locked;
    logic [31:0] lock_queue[DEPTH];

    // Control FSM
   always_ff @(posedge clk or negedge reset)
     if (!reset)
       ps <= UNLOCK;
     else
       ps <= ns;

    always_comb
     if((locked_r[a_r]==1 || locked_r[b_r]==1) || (locked_r[0]==1 &&  (i_r==LB | i_r==LBU | i_r==LH | i_r==LHU | i_r==LW))) 
          ns <= LOCK;
        else 
          ns <= UNLOCK;
 
    always_comb
        accept_input <= ps == UNLOCK ? 1'b1 : 1'b0;

    // Input conditional handshake
    for (genvar i = 0 ; i < 5 ; i++) begin
        discard discard_a (.a(a_next[i]), .en(!accept_input), .q(a_r[i]), .*);
        hold hold_a (.a(regA[i]), .en(accept_input), .q(a_r[i]), .*);

        discard discard_b (.a(b_next[i]), .en(!accept_input), .q(b_r[i]), .*);
        hold hold_b (.a(regB[i]), .en(accept_input), .q(b_r[i]), .*);

        discard discard_d (.a(d_next[i]), .en(!accept_input), .q(d_r[i]), .*);
        hold hold_d (.a(regD[i]), .en(accept_input), .q(d_r[i]), .*);
   end

   for (genvar i = 0 ; i < 32 ; i++) begin
        discard discard_NPC (.a(NPC_next[i]), .en(!accept_input), .q(NPC_r[i]), .*);
        hold hold_NPC (.a(NPC_in[i]), .en(accept_input), .q(NPC_r[i]), .*);

        discard discard_inst (.a(instruction_next[i]), .en(!accept_input), .q(instruction_r[i]), .*);
        hold hold_inst (.a(instruction[i]), .en(accept_input), .q(instruction_r[i]), .*);
  end

   for (genvar j = 0 ; j < 6 ; j++) begin
        discard discard_i (.a(i_next[j]), .en(!accept_input), .q(i_r[j]), .*);
        hold hold_i (.a(i[j]), .en(accept_input), .q(i_r[j]), .*);
   end

   for (genvar j = 0 ; j < 3 ; j++) begin
        discard discard_fmt (.a(fmt_next[j]), .en(!accept_input), .q(fmt_r[j]), .*);
        hold hold_fmt (.a(fmt[j]), .en(accept_input), .q(fmt_r[j]), .*);
   end

   for (genvar j = 0 ; j < 4 ; j++) begin
        discard discard_tag (.a(tag_next[j]), .en(!accept_input), .q(tag_r[j]), .*);
        hold hold_tag (.a(tag_in[j]), .en(accept_input), .q(tag_r[j]), .*);
   end


   always_ff @(posedge clk or negedge reset)
        if (!reset) begin
            a_next <= '0;
            b_next <= '0;
            d_next <= '0;
            NPC_next <= '0;
            instruction_next <= '0;
            i_next <= NOP;
            fmt_next <= '0;
            tag_next <= '0;
        end else begin
            a_next <= a_r;
            b_next <= b_r;
            d_next <= d_r;
            NPC_next <= NPC_r;
            instruction_next <= instruction_r;
            i_next <= i_r;
            fmt_next <= fmt_r;
            tag_next <= tag_r;
        end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////// Conversion to one-hot codification ///////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always_comb begin
        target_int <= 1 << d_r;

        if(i_r==SB | i_r==SH | i_r==SW)
            target_int[0] <= 1;
        else
            target_int[0] <= 0;
    end

///////////////////////////////////////////////////// Implement the queue //////////////////////////////////////////////////////////////////////////
    always @(posedge clk or negedge reset)  
        if(!reset)                                      // At reset clear the queue
            for (int i = 0; i < DEPTH; i++)
                lock_queue[i] <= '0;
        else begin
            for (int j = 0; j < DEPTH-1; j++)
                lock_queue[j+1] <= lock_queue[j];       // Move the queue forward
            
            if(ns==LOCK)
                lock_queue[0] <= '0;
            else
                lock_queue[0] <= target_int;
        end

    generate
    for(genvar w = 0; w < DEPTH-1; w++) 
        assign locked = lock_queue[w];
    endgenerate

    always@(posedge clk) begin
        locked_r <= locked;
        addrW <= lock_queue[DEPTH-2][31:1] & {32{&we}};
    end



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////// Extracts the immediate based on instruction type. //////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if(fmt_r==I_type) begin
            imed[10:0] <= instruction_r[30:20];
            if(instruction_r[31]==0)
                imed[31:11] <= 21'b000000000000000000000;
            else
                imed[31:11] <= 21'b111111111111111111111;    
        
        end else if(fmt_r==S_type) begin
            imed[10:5] <= instruction_r[30:25];
            imed[4:0]  <= instruction_r[11:7];
            if(instruction_r[31]==0)
                imed[31:11] <= 21'b000000000000000000000;
            else
                imed[31:11] <= 21'b111111111111111111111;    

        end else if(fmt_r==B_type) begin
            imed[11] <= instruction_r[7];
            imed[10:5] <= instruction_r[30:25];
            imed[4:1] <= instruction_r[11:8];
            imed[0] <= 0;
            if(instruction_r[31]==0)
                imed[31:12] <= 20'b00000000000000000000;
            else
                imed[31:12]<=20'b11111111111111111111;

        end else if(fmt_r==U_type) begin
            imed[31:12] <= instruction_r[31:12];
            imed[11:0] <= 12'b000000000000;

        end else if(fmt_r==J_type) begin
            imed[19:12] <= instruction_r[19:12];
            imed[11] <= instruction_r[20];
            imed[10:5] <= instruction_r[30:25];
            imed[4:1] <= instruction_r[24:21];
            imed[0] <= 0;
            if(instruction_r[31]==0)
                imed[31:20] <= 12'b000000000000;
            else
                imed[31:20] <= 12'b111111111111;

        end else
            imed[31:0] <= 32'h00000000;  
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // regbank input
    always@(posedge clk) begin
      dataA_int <= dataA;
      dataB_int <= dataB;
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    always_comb begin
      //opA
      if(fmt_r==U_type | fmt_r==J_type)
        opA_int <= NPC_r;
      else
        opA_int <= dataA_int;
      //opB
      if(fmt_r==R_type | fmt_r==B_type)
        opB_int <= dataB_int;
      else
        opB_int <= imed;
      //OPC
      if(fmt_r==S_type)
        opC_int <= dataB_int;
      else 
        opC_int <= imed;
    end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Output
    always@(posedge clk or negedge reset) begin
      if(!reset) begin
        i_out <= NOP;
        opA <= '0;
        opB <= '0;
        opC <= '0;
      end else if(ns==LOCK) begin
        i_out <= NOP;
        opA <= '0;
        opB <= '0;
        opC <= '0;
      end else begin
        i_out <= i_r;
        opA <= opA_int;
        opB <= opB_int;
        opC <= opC_int;
      end
    end
/*
    always_ff @(posedge clk or negedge reset)
      if (!reset) begin
        //addrA <= '0;
        //addrB <= '0;
        //tag_out <= '0;
        //NPC <= '0;
      end else begin
        //addrA <= a_r;
        //addrB <= b_r;
        //tag_out <= tag_int;
        //NPC <= NPC_r;
      end
*/    
    always@(posedge clk) begin
      NPC <= NPC_r;
      tag_out <= tag_r;
      addrA <= a_r;
      addrB <= b_r;
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////







endmodule