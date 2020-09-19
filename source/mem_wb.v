`timescale 1ns / 1ps
`include "consts.vh"

module mem_wb(

         input wire    clk,
         input wire          rst,
         //���Կ���ģ�����Ϣ
         input wire[5:0]               stall,


         //���Էô�׶ε���Ϣ
         input wire[`RegAddrBus]       mem_wreg_addr,
         input wire                    mem_wreg_enable,
         input wire[`RegDataBus]      mem_wdata,

         //�͵���д�׶ε���Ϣ
         output reg[`RegAddrBus]      wb_wreg_addr,
         output reg                   wb_wreg_enable,
         output reg[`RegDataBus]      wb_wdata

       );


always @ (posedge clk)
  begin
    if(rst == `RstEnable)
      begin
        wb_wreg_addr <= `NOPRegAddr;
        wb_wreg_enable <= `WriteDisable;
        wb_wdata <= `ZeroWord;
      end
    else if(stall[4] == `Stop && stall[5] == `NoStop)
      begin
        wb_wreg_addr <= `NOPRegAddr;
        wb_wreg_enable <= `WriteDisable;
        wb_wdata <= `ZeroWord;
      end
    else if(stall[4] == `NoStop)
      begin
        wb_wreg_addr <= mem_wreg_addr;
        wb_wreg_enable <= mem_wreg_enable;
        wb_wdata <= mem_wdata;
      end    //if
  end      //always


endmodule
