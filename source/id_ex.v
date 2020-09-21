`timescale 1ns / 1ps
`include "consts.vh"

module id_ex(

         input wire										clk,
         input wire										rst,
         input wire[5:0]               stall,

         //从译码阶段传递的信息
         input wire[`AluOpBus]         id_aluop,
         input wire[`AluSelBus]        id_alusel,
         input wire[`RegDataBus]       id_reg1,
         input wire[`RegDataBus]       id_reg2,
         input wire[`RegAddrBus]       id_wreg_addr,
         input wire                    id_wreg_enable,
         input wire[`InstBus]          id_inst,

         input wire[`RegDataBus]       id_link_address,
         input wire                    id_is_in_delayslot,
         input wire                    next_inst_in_delayslot_i,

         //传???到执???阶段的信???
         output reg[`AluOpBus]         ex_aluop,
         output reg[`AluSelBus]        ex_alusel,
         output reg[`RegDataBus]       ex_reg1,
         output reg[`RegDataBus]       ex_reg2,
         output reg[`RegAddrBus]       ex_wreg_addr,
         output reg                    ex_wreg_enable,

         output reg[`RegDataBus]       ex_link_address,
         output reg                    ex_is_in_delayslot,
         output reg                    is_in_delayslot_o,
         output reg[`InstBus]          ex_inst
       );

always @ (posedge clk)
  begin
    if (rst == `RstEnable)
      begin
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wreg_addr <= `NOPRegAddr;
        ex_wreg_enable <= `WriteDisable;
        ex_link_address <= `ZeroWord;
        ex_is_in_delayslot <= `NotInDelaySlot;
        is_in_delayslot_o <= `NotInDelaySlot;
      end
    else if(stall[2] == `Stop && stall[3] == `NoStop)
      begin
        ex_aluop <= `EXE_NOP_OP;
        ex_alusel <= `EXE_RES_NOP;
        ex_reg1 <= `ZeroWord;
        ex_reg2 <= `ZeroWord;
        ex_wreg_addr <= `NOPRegAddr;
        ex_wreg_enable <= `WriteDisable;
        ex_link_address <= `ZeroWord;
        ex_is_in_delayslot <= `NotInDelaySlot;
      end
    else if(stall[2] == `NoStop)
      begin
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wreg_addr <= id_wreg_addr;
        ex_wreg_enable <= id_wreg_enable;
        ex_link_address <= id_link_address;
        ex_is_in_delayslot <= id_is_in_delayslot;
        is_in_delayslot_o <= next_inst_in_delayslot_i;
        ex_inst <= id_inst;
      end
  end

endmodule
