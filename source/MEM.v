`timescale 1ns / 1ps
`include "consts.vh"

module mem(

	input wire										rst,
	
	//����ִ�н׶ε���Ϣ	
	input wire[`RegAddrBus]       wreg_addr_i,
	input wire                    wreg_enable_i,
	input wire[`RegDataBus]					  wdata_i,
	
	//�͵���д�׶ε���Ϣ
	output reg[`RegAddrBus]      wreg_addr_o,
	output reg                   wreg_enable_o,
	output reg[`RegDataBus]					 wdata_o
	
);

	
	always @ (*) begin
		if(rst == `RstEnable) begin
			wreg_addr_o <= `NOPRegAddr;
			wreg_enable_o <= `WriteDisable;
		  wdata_o <= `ZeroWord;
		end else begin
		  wreg_addr_o <= wreg_addr_i;
			wreg_enable_o <= wreg_enable_i;
			wdata_o <= wdata_i;
		end    //if
	end      //always
			

endmodule