`timescale 1ns / 1ps
`include "consts.vh"

module id(

         input wire                 rst,
         input wire[`InstAddrBus]   pc_i,
         input wire[`InstBus]       inst_i,

         //??????锟斤拷?锟斤拷?????锟斤拷?????????????
         input wire                 ex_wreg_i,
         input wire[`RegDataBus]        ex_wdata_i,
         input wire[`RegAddrBus]    ex_wd_i,

         //???????锟斤拷?????锟斤拷?????????????
         input wire                    mem_wreg_i,
         input wire[`RegDataBus]           mem_wdata_i,
         input wire[`RegAddrBus]       mem_wd_i,

         input wire[`RegDataBus]           reg1_data_i,
         input wire[`RegDataBus]           reg2_data_i,

         //????????????????????????????????????????is_in_delayslot?true
         input wire                    is_in_delayslot_i,
         
         input wire[`AluOpBus]         ex_aluop_i,

         //???regfile?????
         output reg                    reg1_read_o,
         output reg                    reg2_read_o,
         output reg[`RegAddrBus]       reg1_addr_o,
         output reg[`RegAddrBus]       reg2_addr_o,

         //?????锟斤拷?锟斤拷????
         output reg[`AluOpBus]         aluop_o,
         output reg[`AluSelBus]        alusel_o,
         output reg[`RegDataBus]       reg1_data_o,
         output reg[`RegDataBus]       reg2_data_o,
         output reg[`RegAddrBus]       wreg_addr_o,
         output reg                    wreg_enable_o,

         output reg                    next_inst_in_delayslot_o,	
         output reg[`NPC_OP_LENGTH  - 1:0]    cu_npc_op_o,     
         output reg[`RegDataBus]       link_addr_o,
          output reg                    is_in_delayslot_o,
          output wire                   stallreq,
          output wire[`InstBus]      fore_inst
       );

wire[5:0] op = inst_i[31:26];
wire[4:0] seg_sa = inst_i[10:6];
wire[5:0] seg_func = inst_i[5:0];
wire[4:0] seg_rt = inst_i[20:16];

wire[`EXT_OP_LENGTH  - 1:0] ext_op;
wire[`RegDataBus] imm_extended;
assign ext_op = (op==`EXE_ORI||op==`EXE_ANDI||op==`EXE_XORI)?`EXT_OP_UNSIGNED:
       (op==`EXE_ADDI||op==`EXE_ADDIU)?`EXT_OP_SIGNED:
       (op==`EXE_LUI)?`EXT_OP_SFT16:`EXT_OP_DEFAULT;
extend ext0(
         .imm_i(inst_i[15:0]),
         .ext_op_i(ext_op),
         .imm_o(imm_extended)
       );

reg[`RegDataBus] imm;
reg instvalid;

wire[`RegDataBus] pc_plus_8;
assign pc_plus_8 = pc_i + 8;   //???锟斤拷????????????2????????
assign fore_inst = inst_i;

reg stallreq_for_reg1_loadrelate;  //读取的寄存器1是否与上条指令存在load相关
reg stallreq_for_reg2_loadrelate;  //读取的寄存器2是否与上条指令存在load相关
wire pre_inst_is_load;  //上一条指令是否为加载指令
assign stallreq = stallreq_for_reg1_loadrelate | stallreq_for_reg2_loadrelate;
 assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB_OP) || 
  							(ex_aluop_i == `EXE_LBU_OP)||
  							(ex_aluop_i == `EXE_LH_OP) ||
  							(ex_aluop_i == `EXE_LHU_OP)||
  							(ex_aluop_i == `EXE_LW_OP)) ? 1'b1 : 1'b0;

always @ (*)
  begin
    if (rst == `RstEnable)
      begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wreg_addr_o <= `NOPRegAddr;
        wreg_enable_o <= `WriteDisable;
        instvalid <= `InstValid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        imm <= 32'h0;
        link_addr_o <= `ZeroWord;
        cu_npc_op_o <= `NPC_OP_NEXT;
        next_inst_in_delayslot_o <= `NotInDelaySlot;
      end
    else
      begin
        aluop_o <= `EXE_NOP_OP;
        alusel_o <= `EXE_RES_NOP;
        wreg_addr_o <= inst_i[15:11];
        wreg_enable_o <= `WriteDisable;
        instvalid <= `InstInvalid;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        reg1_addr_o <= inst_i[25:21];
        reg2_addr_o <= inst_i[20:16];
        imm <= `ZeroWord;
        link_addr_o <= `ZeroWord;
        cu_npc_op_o <= `NPC_OP_NEXT;	
        next_inst_in_delayslot_o <= `NotInDelaySlot;
        case (op)
          `EXE_SPECIAL_INST:
            begin
              case (seg_sa)
                5'b00000:
                  begin
                    case (seg_func)
                      `EXE_AND:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_AND_OP;
                          alusel_o <= `EXE_RES_LOGIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_OR:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_OR_OP;
                          alusel_o <= `EXE_RES_LOGIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_XOR:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_XOR_OP;
                          alusel_o <= `EXE_RES_LOGIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_NOR:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_NOR_OP;
                          alusel_o <= `EXE_RES_LOGIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SLLV:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_SLL_OP;
                          alusel_o <= `EXE_RES_SHIFT;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SRLV:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_SRL_OP;
                          alusel_o <= `EXE_RES_SHIFT;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SRAV:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_SRA_OP;
                          alusel_o <= `EXE_RES_SHIFT;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SYNC:
                        begin
                          wreg_enable_o <= `WriteDisable;
                          aluop_o <= `EXE_NOP_OP;
                          alusel_o <= `EXE_RES_NOP;
                          reg1_read_o <= 1'b0;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                     `EXE_JR: 
                        begin
	                      wreg_enable_o <= `WriteDisable;		
	                      aluop_o <= `EXE_JR_OP;
	                      alusel_o <= `EXE_RES_JUMP_BRANCH;   
		  				  reg1_read_o <= 1'b1;	
		  				  reg2_read_o <= 1'b0;
		  				  link_addr_o <= `ZeroWord;		  						
			              cu_npc_op_o <= `NPC_OP_RS;		           
			              next_inst_in_delayslot_o <= `InDelaySlot;
			              instvalid <= `InstValid;	
						end
	                  `EXE_JALR: 
					    begin
						  wreg_enable_o <= `WriteEnable;		
						  aluop_o <= `EXE_JALR_OP;
		  				  alusel_o <= `EXE_RES_JUMP_BRANCH;   
		  				  reg1_read_o <= 1'b1;	
		  				  reg2_read_o <= 1'b0;
		  				  wreg_addr_o <= inst_i[15:11];
		  				  link_addr_o <= pc_plus_8;		  						
			              cu_npc_op_o <= `NPC_OP_RS;			           
			              next_inst_in_delayslot_o <= `InDelaySlot;
			              instvalid <= `InstValid;	
					    end
                      `EXE_MOVN:
                        begin
                          if(reg2_data_o != `ZeroWord)
                            begin
                              wreg_enable_o <= `WriteEnable;
                            end
                          else
                            begin
                              wreg_enable_o <= `WriteDisable;
                            end
                          aluop_o<=`EXE_MOVN_OP;
                          alusel_o <= `EXE_RES_MOVE;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b0;
                        end
                      `EXE_MOVZ:
                        begin
                          if(reg2_data_o != `ZeroWord)
                            begin
                              wreg_enable_o <= `WriteDisable;
                            end
                          else
                            begin
                              wreg_enable_o <= `WriteEnable;
                            end
                          aluop_o<=`EXE_MOVN_OP;
                          alusel_o <= `EXE_RES_MOVE;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b0;
                        end
                      `EXE_ADD:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_ADD_OP;
                          alusel_o <= `EXE_RES_ARITHMETIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_ADDU:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_ADDU_OP;
                          alusel_o <= `EXE_RES_ARITHMETIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SUB:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_SUB_OP;
                          alusel_o <= `EXE_RES_ARITHMETIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SUBU:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_SUBU_OP;
                          alusel_o <= `EXE_RES_ARITHMETIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SLT:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_SLT_OP;
                          alusel_o <= `EXE_RES_ARITHMETIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      `EXE_SLTU:
                        begin
                          wreg_enable_o <= `WriteEnable;
                          aluop_o <= `EXE_SLTU_OP;
                          alusel_o <= `EXE_RES_ARITHMETIC;
                          reg1_read_o <= 1'b1;
                          reg2_read_o <= 1'b1;
                          instvalid <= `InstValid;
                        end
                      default:
                        begin
                        end
                    endcase
                  end
                default:
                  begin
                  end
              endcase
            end
          `EXE_ORI:
            begin                        //ORI???
              wreg_enable_o <= `WriteEnable;
              aluop_o <= `EXE_OR_OP;
              alusel_o <= `EXE_RES_LOGIC;
              reg1_read_o <= 1'b1;
              reg2_read_o <= 1'b0;
              imm <= imm_extended;
              wreg_addr_o <= inst_i[20:16];
              instvalid <= `InstValid;
            end
          `EXE_ANDI:
            begin
              wreg_enable_o <= `WriteEnable;
              aluop_o <= `EXE_AND_OP;
              alusel_o <= `EXE_RES_LOGIC;
              reg1_read_o <= 1'b1;
              reg2_read_o <= 1'b0;
              imm <= imm_extended;
              wreg_addr_o <= inst_i[20:16];
              instvalid <= `InstValid;
            end
          `EXE_XORI:
            begin
              wreg_enable_o <= `WriteEnable;
              aluop_o <= `EXE_XOR_OP;
              alusel_o <= `EXE_RES_LOGIC;
              reg1_read_o <= 1'b1;
              reg2_read_o <= 1'b0;
              imm <= imm_extended;
              wreg_addr_o <= inst_i[20:16];
              instvalid <= `InstValid;
            end
          `EXE_LUI:
            begin
              wreg_enable_o <= `WriteEnable;
              aluop_o <= `EXE_OR_OP;
              alusel_o <= `EXE_RES_LOGIC;
              reg1_read_o <= 1'b1;
              reg2_read_o <= 1'b0;
              imm <= imm_extended;
              wreg_addr_o <= inst_i[20:16];
              instvalid <= `InstValid;
            end
          `EXE_PREF:
            begin
              wreg_enable_o <= `WriteDisable;
              aluop_o <= `EXE_NOP_OP;
              alusel_o <= `EXE_RES_NOP;
              reg1_read_o <= 1'b0;
              reg2_read_o <= 1'b0;
              instvalid <= `InstValid;
            end
          `EXE_J:			
            begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_J_OP;
		  	  alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  	  reg1_read_o <= 1'b0;	
		  	  reg2_read_o <= 1'b0;
		  	  link_addr_o <= `ZeroWord;
			  cu_npc_op_o <= `NPC_OP_JUMP;
			  next_inst_in_delayslot_o <= `InDelaySlot;		  	
			  instvalid <= `InstValid;	
			end
		  `EXE_JAL:			
		    begin
		  	  wreg_enable_o <= `WriteEnable;		
		  	  aluop_o <= `EXE_JAL_OP;
		  	  alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  	  reg1_read_o <= 1'b0;	
		  	  reg2_read_o <= 1'b0;
		  	  wreg_addr_o <= 5'b11111;	
		  	  link_addr_o <= pc_plus_8 ;
			  cu_npc_op_o <= `NPC_OP_JUMP;
			  next_inst_in_delayslot_o <= `InDelaySlot;		  	
			  instvalid <= `InstValid;	
		    end
		  `EXE_BEQ:			
		    begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_BEQ_OP;
		  	  alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b1;
		  	  instvalid <= `InstValid;	
		  	  if(reg1_data_o == reg2_data_o) 
		  	  begin
			    cu_npc_op_o <= `NPC_OP_OFFSET;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			  end
			end
		  `EXE_BGTZ:			
		    begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_BGTZ_OP;
		  	  alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b0;
		  	  instvalid <= `InstValid;	
		  	  if((reg1_data_o[31] == 1'b0) && (reg1_data_o != `ZeroWord)) 
		  	  begin
			    cu_npc_op_o <= `NPC_OP_OFFSET;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			  end
			end
		  `EXE_BLEZ:			
		    begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_BLEZ_OP;
		  	  alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b0;
		  	  instvalid <= `InstValid;	
		  	  if((reg1_data_o[31] == 1'b1) || (reg1_data_o == `ZeroWord)) 
		  	  begin
			    cu_npc_op_o <= `NPC_OP_OFFSET;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			  end
			end
		  `EXE_BNE:			
		    begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_BLEZ_OP;
		  	  alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b1;
		  	  instvalid <= `InstValid;	
		  	  if(reg1_data_o != reg2_data_o) 
		  	  begin
			    cu_npc_op_o <= `NPC_OP_OFFSET;
			    next_inst_in_delayslot_o <= `InDelaySlot;		  	
			  end
			end
		  `EXE_LB:			
		    begin
		  	  wreg_enable_o <= `WriteEnable;		
		  	  aluop_o <= `EXE_LB_OP;
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b0;	  	
			  wreg_addr_o <= inst_i[20:16]; 
			  instvalid <= `InstValid;	
			end
		  `EXE_LBU:			
		    begin
		  	  wreg_enable_o <= `WriteEnable;		
		  	  aluop_o <= `EXE_LBU_OP;
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b0;	  	
			  wreg_addr_o <= inst_i[20:16]; 
			  instvalid <= `InstValid;	
			end
		  `EXE_LH:			
		    begin
		  	  wreg_enable_o <= `WriteEnable;		
		  	  aluop_o <= `EXE_LH_OP;
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b0;	  	
			  wreg_addr_o <= inst_i[20:16]; 
			  instvalid <= `InstValid;	
			end
		  `EXE_LHU:			
		    begin
		  	  wreg_enable_o <= `WriteEnable;		
		  	  aluop_o <= `EXE_LHU_OP;
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b0;	  	
			  wreg_addr_o <= inst_i[20:16]; 
			  instvalid <= `InstValid;	
			end
		  `EXE_LW:			
		    begin
		  	  wreg_enable_o <= `WriteEnable;		
		  	  aluop_o <= `EXE_LW_OP;
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b0;	  	
			  wreg_addr_o <= inst_i[20:16]; 
			  instvalid <= `InstValid;	
			end
		  `EXE_SB:			
		    begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_SB_OP;
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b1; 
		  	  instvalid <= `InstValid;	
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
			end
		  `EXE_SH:			
		    begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_SH_OP;
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b1; 
		  	  instvalid <= `InstValid;	
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
			end
		  `EXE_SW:			
		    begin
		  	  wreg_enable_o <= `WriteDisable;		
		  	  aluop_o <= `EXE_SW_OP;
		  	  reg1_read_o <= 1'b1;	
		  	  reg2_read_o <= 1'b1; 
		  	  instvalid <= `InstValid;	
		  	  alusel_o <= `EXE_RES_LOAD_STORE; 
			end
		  `EXE_REGIMM_INST:		
		    begin
			  case (seg_rt)
			    `EXE_BGEZ:	
			      begin
				    wreg_enable_o <= `WriteDisable;		
				    aluop_o <= `EXE_BGEZ_OP;
		  			alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  			reg1_read_o <= 1'b1;	
		  			reg2_read_o <= 1'b0;
		  			instvalid <= `InstValid;	
		  			if(reg1_data_o[31] == 1'b0) 
		  			begin
			    		cu_npc_op_o <= `NPC_OP_OFFSET;
			    		next_inst_in_delayslot_o <= `InDelaySlot;		  	
			   		end
				  end
				`EXE_BGEZAL:		
				  begin
					wreg_enable_o <= `WriteEnable;		
					aluop_o <= `EXE_BGEZAL_OP;
		  			alusel_o <= `EXE_RES_JUMP_BRANCH;
		  			reg1_read_o <= 1'b1;
		  			reg2_read_o <= 1'b0;
		  			link_addr_o <= pc_plus_8; 
		  			wreg_addr_o <= 5'b11111;  	
		  			instvalid <= `InstValid;
		  			if(reg1_data_o[31] == 1'b0) 
		  			begin
			    	  cu_npc_op_o <= `NPC_OP_OFFSET;
			    	  next_inst_in_delayslot_o <= `InDelaySlot;
			   		end
				  end
				`EXE_BLTZ:		
				  begin
				    wreg_enable_o <= `WriteDisable;		
				    aluop_o <= `EXE_BGEZAL_OP;
		  			alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  			reg1_read_o <= 1'b1;	
		  			reg2_read_o <= 1'b0;
		  			instvalid <= `InstValid;	
		  			if(reg1_data_o[31] == 1'b1) 
		  			begin
			    	  cu_npc_op_o <= `NPC_OP_OFFSET;
			    	  next_inst_in_delayslot_o <= `InDelaySlot;		  	
			   		end
				  end 
				`EXE_BLTZAL:		
				  begin
				    wreg_enable_o <= `WriteEnable;		
				    aluop_o <= `EXE_BGEZAL_OP;
		  			alusel_o <= `EXE_RES_JUMP_BRANCH; 
		  			reg1_read_o <= 1'b1;	
		  			reg2_read_o <= 1'b0;
		  			link_addr_o <= pc_plus_8;	
		  			wreg_addr_o <= 5'b11111; 
		  			instvalid <= `InstValid;
		  			if(reg1_data_o[31] == 1'b1) 
		  			begin
			    	  cu_npc_op_o <= `NPC_OP_OFFSET;
			    	  next_inst_in_delayslot_o <= `InDelaySlot;
			   		end
				  end
				default:
				  begin
				  end
			  endcase
			end
          `EXE_ADDI:
            begin                        //ADDI???
              wreg_enable_o <= `WriteEnable;
              aluop_o <= `EXE_ADDI_OP;
              alusel_o <= `EXE_RES_ARITHMETIC;
              reg1_read_o <= 1'b1;
              reg2_read_o <= 1'b0;
              imm <= imm_extended;
              wreg_addr_o <= inst_i[20:16];
              instvalid <= `InstValid;
            end
          `EXE_ADDIU:
            begin                        //ADDIU???
              wreg_enable_o <= `WriteEnable;
              aluop_o <= `EXE_ADDIU_OP;
              alusel_o <= `EXE_RES_ARITHMETIC;
              reg1_read_o <= 1'b1;
              reg2_read_o <= 1'b0;
              imm <= imm_extended;
              wreg_addr_o <= inst_i[20:16];
              instvalid <= `InstValid;
            end
          `EXE_SPECIAL2_INST:
            begin
              case(seg_func)
                `EXE_CLZ:
                  begin
                    wreg_enable_o <= `WriteEnable;
                    aluop_o <= `EXE_CLZ_OP;
                    alusel_o<= `EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    instvalid <= `InstValid;
                  end
                `EXE_CLO:
                  begin
                    wreg_enable_o <= `WriteEnable;
                    aluop_o <= `EXE_CLO_OP;
                    alusel_o<= `EXE_RES_ARITHMETIC;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    instvalid <= `InstValid;
                  end
                default:
                  begin
                  end
              endcase
            end
        endcase    //case op

        if (inst_i[31:21] == 11'b00000000000)
          begin
            if (seg_func == `EXE_SLL)
              begin
                wreg_enable_o <= `WriteEnable;
                aluop_o <= `EXE_SLL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <= inst_i[10:6];
                wreg_addr_o <= inst_i[15:11];
                instvalid <= `InstValid;
              end
            else if ( seg_func == `EXE_SRL )
              begin
                wreg_enable_o <= `WriteEnable;
                aluop_o <= `EXE_SRL_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <= inst_i[10:6];
                wreg_addr_o <= inst_i[15:11];
                instvalid <= `InstValid;
              end
            else if ( seg_func == `EXE_SRA )
              begin
                wreg_enable_o <= `WriteEnable;
                aluop_o <= `EXE_SRA_OP;
                alusel_o <= `EXE_RES_SHIFT;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b1;
                imm[4:0] <= inst_i[10:6];
                wreg_addr_o <= inst_i[15:11];
                instvalid <= `InstValid;
              end
          end
      end       //if
  end         //always


always @ (*)
  begin
    stallreq_for_reg1_loadrelate <= `NoStop;
    if(rst == `RstEnable)
      begin
        reg1_data_o <= `ZeroWord;
      end
    else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1)
      begin
        stallreq_for_reg1_loadrelate <= `Stop;	
      end
    else if((reg1_read_o == 1'b1) && (ex_wreg_i == 1'b1)
            && (ex_wd_i == reg1_addr_o))
      begin
        reg1_data_o <= ex_wdata_i;
      end
    else if((reg1_read_o == 1'b1) && (mem_wreg_i == 1'b1)
            && (mem_wd_i == reg1_addr_o))
      begin
        reg1_data_o <= mem_wdata_i;
      end
    else if(reg1_read_o == 1'b1)
      begin
        reg1_data_o <= reg1_data_i;
      end
    else if(reg1_read_o == 1'b0)
      begin
        reg1_data_o <= imm;
      end
    else
      begin
        reg1_data_o <= `ZeroWord;
      end
  end

always @ (*)
  begin
    stallreq_for_reg2_loadrelate <= `NoStop;
    if(rst == `RstEnable)
      begin
        reg2_data_o <= `ZeroWord;
      end
    else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1)
      begin
        stallreq_for_reg2_loadrelate <= `Stop;	
      end
    else if((reg2_read_o == 1'b1) && (ex_wreg_i == 1'b1)
            && (ex_wd_i == reg2_addr_o))
      begin
        reg2_data_o <= ex_wdata_i;
      end
    else if((reg2_read_o == 1'b1) && (mem_wreg_i == 1'b1)
            && (mem_wd_i == reg2_addr_o))
      begin
        reg2_data_o <= mem_wdata_i;
      end
    else if(reg2_read_o == 1'b1)
      begin
        reg2_data_o <= reg2_data_i;
      end
    else if(reg2_read_o == 1'b0)
      begin
        reg2_data_o <= imm;
      end
    else
      begin
        reg2_data_o <= `ZeroWord;
      end
  end
  
always @ (*) 
  begin
	if(rst == `RstEnable) 
	  begin
		is_in_delayslot_o <= `NotInDelaySlot;
	  end 
	else 
	  begin
		  is_in_delayslot_o <= is_in_delayslot_i;		
	  end
  end
endmodule
