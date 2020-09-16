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
         input wire[`InstAddrBus]   addr,
         output reg[`InstBus]   inst
       );

reg[`InstBus]  inst_mem[0:`InstMemNum-1];

always @ (*)
  //   begin
  //     if (ce == `ChipDisable)
  //       begin
  //         inst <= `ZeroWord;
  //       end
  //     else
  begin
    inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
  end
//   end
endmodule
