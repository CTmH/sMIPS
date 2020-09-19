`timescale 1ns / 1ps
`include "consts.vh"

module ex(

	input wire										rst,
	
	//送到执行阶段的信息
	input wire[`AluOpBus]         aluop_i,
	input wire[`AluSelBus]        alusel_i,
	input wire[`RegDataBus]           reg1_i,
	input wire[`RegDataBus]           reg2_i,
	input wire[`RegAddrBus]       wreg_addr_i,
	input wire                    wreg_enable_i,
	//是否转移、以及link address
	input wire[`RegDataBus]       link_address_i,
	input wire                    is_in_delayslot_i,
	
	output reg[`RegAddrBus]       wreg_addr_o,
	output reg                    wreg_enable_o,
	output reg[`RegDataBus]		  wdata_o,

	output reg					  stallreq
	
);

	reg[`RegDataBus] logic_out;
	reg[`RegDataBus] shift_out;
	reg[`RegDataBus] move_out;
	reg[`RegDataBus] arith_out;

	// flags
	wire ov;
	wire eq;
	wire lt;

	// 中间变量
	wire[`RegDataBus] opnd1;
	wire[`RegDataBus] opnd2;
	wire[`RegDataBus] compute_res;

	assign opnd2 = (aluop_i==`EXE_SUB_OP||aluop_i==`EXE_SUBU_OP||aluop_i==`EXE_SLT_OP)?(~reg2_i+1):reg2_i;
	assign opnd1 = reg1_i;
	assign compute_res=opnd1+opnd2;
	// 溢出
	assign ov = (opnd1[31]&&opnd2[31]&&!compute_res[31])||(!opnd1[31]&&!opnd2[31]&&compute_res[31]);
	// 大小，为了防止溢出，不直接使用compute_res的高位来判断
	assign lt = (aluop_i==`EXE_SLT_OP)?((reg1_i[31]&&!reg2_i[31])?1:(reg1_i[31]&&!reg2_i[31])?0:compute_res[31]):(reg1_i<reg2_i);
	assign eq = reg1_i==reg2_i;


	always @ (*) begin
		stallreq <= `NoStop;
	end

	always @ (*) begin
		if(rst == `RstEnable) begin
			logic_out <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_OR_OP:			begin
					logic_out <= reg1_i | reg2_i;
				end
				`EXE_AND_OP:		begin
					logic_out <= reg1_i & reg2_i;
				end
				`EXE_NOR_OP:		begin
					logic_out <= ~(reg1_i |reg2_i);
				end
				`EXE_XOR_OP:		begin
					logic_out <= reg1_i ^ reg2_i;
				end
				default:				begin
					logic_out <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

	always @ (*) begin
		if(rst == `RstEnable) begin
			shift_out <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_SLL_OP:			begin
					shift_out <= reg2_i << reg1_i[4:0] ;
				end
				`EXE_SRL_OP:		begin
					shift_out <= reg2_i >> reg1_i[4:0];
				end
				`EXE_SRA_OP:		begin
					shift_out <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) 
												| reg2_i >> reg1_i[4:0];
				end
				default:				begin
					shift_out <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

	always @ (*) begin
		if(rst == `RstEnable) begin
			move_out <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_MOVN_OP:			begin
					move_out <= reg1_i ;
				end
				`EXE_MOVZ_OP:			begin
					move_out <= reg1_i ;
				end
				default:				begin
					move_out <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

	always @ (*) begin
		if(rst == `RstEnable) begin
			arith_out <= `ZeroWord;
		end else begin
			case (aluop_i)
				`EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP,`EXE_SUB_OP,`EXE_SUBU_OP:
				begin
					arith_out <= compute_res ;
				end
				`EXE_SLT_OP, `EXE_SLTU_OP:
				begin
					arith_out <= lt ;
				end
				`EXE_CLZ_OP:
				begin
					arith_out <= reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
													 reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
													 reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
													 reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
													 reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
													 reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
													 reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
													 reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
													 reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
													 reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
													 reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
				end
				`EXE_CLO_OP:
				begin
					arith_out <= (~reg1_i[31] ? 0 : ~reg1_i[30] ? 1 : ~reg1_i[29] ? 2 :
													 ~reg1_i[28] ? 3 : ~reg1_i[27] ? 4 : ~reg1_i[26] ? 5 :
													 ~reg1_i[25] ? 6 : ~reg1_i[24] ? 7 : ~reg1_i[23] ? 8 : 
													 ~reg1_i[22] ? 9 : ~reg1_i[21] ? 10 : ~reg1_i[20] ? 11 :
													 ~reg1_i[19] ? 12 : ~reg1_i[18] ? 13 : ~reg1_i[17] ? 14 : 
													 ~reg1_i[16] ? 15 : ~reg1_i[15] ? 16 : ~reg1_i[14] ? 17 : 
													 ~reg1_i[13] ? 18 : ~reg1_i[12] ? 19 : ~reg1_i[11] ? 20 :
													 ~reg1_i[10] ? 21 : ~reg1_i[9] ? 22 : ~reg1_i[8] ? 23 : 
													 ~reg1_i[7] ? 24 : ~reg1_i[6] ? 25 : ~reg1_i[5] ? 26 : 
													 ~reg1_i[4] ? 27 : ~reg1_i[3] ? 28 : ~reg1_i[2] ? 29 : 
													 ~reg1_i[1] ? 30 : ~reg1_i[0] ? 31 : 32) ;
				end
				default:
				begin
					arith_out <= `ZeroWord;
				end
			endcase
		end    //if
	end      //always

 always @ (*) begin
	 wreg_addr_o <= wreg_addr_i;
	 if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) || 
	      (aluop_i == `EXE_SUB_OP)) && (ov == 1'b1)) begin
	 	wreg_enable_o <= `WriteDisable;
	 end else begin
	  	 wreg_enable_o <= wreg_enable_i;
	 end	 	
	 case ( alusel_i ) 
	 	`EXE_RES_LOGIC:		
		begin
	 		wdata_o <= logic_out;
	 	end
	 	`EXE_RES_SHIFT:
		begin
	 		wdata_o <= shift_out;
	 	end
	 	`EXE_RES_JUMP_BRANCH:	begin
	 		wdata_o <= link_address_i;
	 	end
		`EXE_RES_MOVE:
		begin
			wdata_o <= move_out;
		end
		`EXE_RES_ARITHMETIC:
		begin
			wdata_o <= arith_out;
		end
	 	default:
		begin
	 		wdata_o <= `ZeroWord;
	 	end
	 endcase
 end	

endmodule