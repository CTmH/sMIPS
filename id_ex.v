`timescale 1ns / 1ps
`include "consts.vh"

module id_ex(

	input	wire										clk,
	input wire										rst,

	
	//从译码阶段传递的信息
	input wire[`AluOpBus]         id_aluop,
	input wire[`AluSelBus]        id_alusel,
	input wire[`RegDataBus]           id_reg1,
	input wire[`RegDataBus]           id_reg2,
	input wire[`RegAddrBus]       id_wreg_addr,
	input wire                    id_wreg_enable,	
	
	//传递到执行阶段的信息
	output reg[`AluOpBus]         ex_aluop,
	output reg[`AluSelBus]        ex_alusel,
	output reg[`RegDataBus]           ex_reg1,
	output reg[`RegDataBus]           ex_reg2,
	output reg[`RegAddrBus]       ex_wreg_addr,
	output reg                    ex_wreg_enable
	
);

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			ex_aluop <= `EXE_NOP_OP;
			ex_alusel <= `EXE_RES_NOP;
			ex_reg1 <= `ZeroWord;
			ex_reg2 <= `ZeroWord;
			ex_wreg_addr <= `NOPRegAddr;
			ex_wreg_enable <= `WriteDisable;
		end else begin		
			ex_aluop <= id_aluop;
			ex_alusel <= id_alusel;
			ex_reg1 <= id_reg1;
			ex_reg2 <= id_reg2;
			ex_wreg_addr <= id_wreg_addr;
			ex_wreg_enable <= id_wreg_enable;		
		end
	end
	
endmodule