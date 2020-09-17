`timescale 1ns / 1ps
`include "consts.vh"

module extend(
           input  wire[15:0]                  imm_i,
           input  wire[`EXT_OP_LENGTH  - 1:0] ext_op_i,

           output wire[`RegDataBus]                  imm_o
       );


// 不能用case而要用这种选择逻辑似乎
assign imm_o =
       (ext_op_i == `EXT_OP_SFT16) ? {imm_i, 16'b0} :            // LUI等指令
       (ext_op_i == `EXT_OP_SIGNED) ? {{16{imm_i[15]}}, imm_i} : // ADDIU等的符号扩展
       {16'b0, imm_i};                                            // LW, SW等的无符号扩展
endmodule