`timescale 1ns / 1ps
`include "consts.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/09/14 23:36:56
// Design Name:
// Module Name: if_id
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module if_id(

         input wire	clk,
         input wire	rst,
         input wire[5:0]                stall,

         input wire[`InstAddrBus]       if_pc,
         input wire[`InstBus]           if_inst,
         input wire                     branch_predict_i,
         output reg[`InstAddrBus]       id_pc,
         output reg[`InstBus]           id_inst,
         output reg                     branch_predict_o

       );

always @ (posedge clk)
  begin
    if (rst == `RstEnable)
      begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        branch_predict_o <= `BP_NO;
      end
    else if(stall == `Stop && stall[2] == `NoStop)
      begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
        branch_predict_o <= `BP_NO;
      end
    else if(stall[1] == `NoStop)
      begin
        id_pc <= if_pc;
        id_inst <= if_inst;
        branch_predict_o <= branch_predict_i;
      end
  end

endmodule
