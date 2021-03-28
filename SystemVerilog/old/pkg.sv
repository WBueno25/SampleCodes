package my_pkg;

   typedef enum  logic[2:0] {R_type, I_type, S_type, B_type, U_type, J_type} fmts;

   typedef enum  logic[5:0] {
                              ADD,SUB,SLTU,SLT,
                              XOR,OR,AND,
                              SLL,SRL,SRA,
                              BEQ,BNE,BLT,BLTU,BGE,BGEU,JAL,JALR,
                              LB,LBU,LH,LHU,LW,SB,SH,SW,
                              LUI,FENCE,ECALL,CSRR,NOP,INVALID, NOTOKEN='Z
                              } instruction_type;

   typedef enum  logic[2:0] {adder, logical, shifter, branch, memory, bypass} xu;

   typedef logic [31:0] wires32;
   typedef logic [15:0] wires16;
   typedef logic [7:0]  wires8;
   typedef logic [3:0]  wires4;

   const int            MEMORY_SIZE = 131072;

   typedef wires8 [0:131072] ram_memory;

endpackage
