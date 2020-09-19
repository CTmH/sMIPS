`timescale 1ns / 1ps
`include "consts.vh"


module ex_mem(

         input wire          clk,
         input wire          rst,
         input wire[5:0]              stall,

         //来自执行阶段的信息
         input wire[`RegAddrBus]       ex_wreg_addr,
         input wire                    ex_wreg_enable,
         input wire[`RegDataBus]       ex_wdata,

         //送到访存阶段的信息
         output reg[`RegAddrBus]      mem_wreg_addr,
         output reg                   mem_wreg_enable,
         output reg[`RegDataBus]      mem_wdata


       );


always @ (posedge clk)
  begin
    if(rst == `RstEnable)
      begin
        mem_wreg_addr <= `NOPRegAddr;
        mem_wreg_enable <= `WriteDisable;
        mem_wdata <= `ZeroWord;
      end
    else if(stall[3] == `Stop && stall[4] == `NoStop)
      begin
        mem_wreg_addr <= `NOPRegAddr;
        mem_wreg_enable <= `WriteDisable;
        mem_wdata <= `ZeroWord;
      end
    else if(stall[3]==`NoStop)
      begin
        mem_wreg_addr <= ex_wreg_addr;
        mem_wreg_enable <= ex_wreg_enable;
        mem_wdata <= ex_wdata;
      end    //if
  end      //always


endmodule
