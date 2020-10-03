`timescale 1ns / 1ps
`include "consts.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/09/15 12:07:48
// Design Name:
// Module Name: imem
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


module imem(
         input wire rst,
         input wire[`InstAddrBus]   addr,
         output reg[`InstBus]   inst
       );

//reg[`InstBus]  inst_mem[0:`InstMemNum-1];
reg[`InstBus]  inst_mem[0:21];
always @ (*)
  if(rst)
    begin
      inst_mem[0] <= 32'h20090004;
inst_mem[1] <= 32'h3c010010;
inst_mem[2] <= 32'hac290000;
inst_mem[3] <= 32'hac290000;
inst_mem[4] <= 32'h3c010010;
inst_mem[5] <= 32'h8c2a0000;
inst_mem[6] <= 32'h012a5820;
inst_mem[7] <= 32'h3c010020;
inst_mem[8] <= 32'hac2b0000;
inst_mem[9] <= 32'h3c010030;
inst_mem[10] <= 32'hac2b0000;
inst_mem[11] <= 32'h210c0029;
inst_mem[12] <= 32'h3c010040;
inst_mem[13] <= 32'hac2c0000;
    end
  else 
    begin
      inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
    end
endmodule