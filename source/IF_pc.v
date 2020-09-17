`timescale 1ns / 1ps
`include "consts.vh"

module pc(
input wire clk,
input wire rst,
input wire[`InstAddrBus] npc,
output reg[`InstAddrBus] pc
);
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			pc <= 32'h00000000;
		end else begin
	 		pc <= npc;
		end
	end
endmodule