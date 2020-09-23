`timescale 1ns / 1ps
`include "consts.vh"

module npc(
           input  wire[31:0]                  pc,
           input  wire[31:0]                  special_pc,
           input  wire[15:0]                  imm16,     // 16 bit immediate
           input  wire[25:0]                  imm26,     // 26 bit immediate
           input  wire[31:0]                  reg1_data, // rs data

           input  wire[`NPC_OP_LENGTH  - 1:0] cu_npc_op, // NPC control signal

           input  wire                        branch_predict,
           input  wire[31:0]                  branch_predict_addr,

           output wire[31:0]                  npc       // next program counter
       //     output wire[31:0]                  jmp_dst    // JAL, JAJR jump dst
       );

wire[31:0] pc_4;
assign pc_4 = pc + 32'h4;

// assign jmp_dst = pc + 32'h8;

assign npc =
       (cu_npc_op == `NPC_OP_SPEC)   ? special_pc :                                 // pc = special value
       (branch_predict ==  `BP_YES)  ? branch_predict_addr:                         // branch predict result           
       (cu_npc_op == `NPC_OP_NEXT  ) ? pc_4 :                                       // pc + 4
       (cu_npc_op == `NPC_OP_JUMP  ) ? {pc[31:28], imm26, 2'b00} :                  // pc = target
       (cu_npc_op == `NPC_OP_OFFSET) ? {pc + {{14{imm16[15]}}, {imm16, 2'b00}}} :   // pc + offset
       (cu_npc_op == `NPC_OP_RS    ) ? reg1_data :                                  // pc = rs data
       pc_4;                                                                        // fallback mode: pc + 4
endmodule