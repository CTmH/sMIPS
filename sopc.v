`timescale 1ns / 1ps
`include "consts.vh"

module spoc(
         input wire clk,
         input wire rst
       );
cpu cpu0(
      .clk(clk),
      .rst(rst)
    );
endmodule
