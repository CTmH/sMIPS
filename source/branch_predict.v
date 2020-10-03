`timescale 1ns / 1ps
`include "consts.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2020/09/22 20:34:43
// Design Name:
// Module Name: branch_predict
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


module branch_predict(
         input wire clk,
         input wire rst,
         input wire[31:0] pc,
         input wire flush,
         input wire[`InstBus] inst,
         output wire branch_predict,
         output wire[31:0] branch_predict_addr
       );
reg      pred;
reg[1:0] history;
parameter STRONG_YES=2'b11;
parameter WEAK_YES=2'b10;
parameter WEAK_NO=2'b01;
parameter STRONG_NO=2'b00;

wire[5:0] opcode=inst[31:26];
wire[4:0] seg_rt=inst[20:16];

wire inst_beq, inst_bne, inst_bgtz, inst_blez, inst_bgez, inst_bgezal, inst_bltz, inst_bltzal;
assign inst_beq       = (opcode == `EXE_BEQ   ) ? 1 : 0;
assign inst_bne       = (opcode == `EXE_BNE   ) ? 1 : 0;
assign inst_bgtz      = (opcode == `EXE_BGTZ  ) ? 1 : 0;
assign inst_blez      = (opcode == `EXE_BLEZ  ) ? 1 : 0;
assign inst_bgez      = (opcode == `EXE_REGIMM_INST && seg_rt==`EXE_BGEZ ) ? 1 : 0;
assign inst_bgezal    = (opcode == `EXE_REGIMM_INST && seg_rt==`EXE_BGEZAL ) ? 1 : 0;
assign inst_bltz      = (opcode == `EXE_REGIMM_INST && seg_rt==`EXE_BLTZ ) ? 1 : 0;
assign inst_bltzal    = (opcode == `EXE_REGIMM_INST && seg_rt==`EXE_BLTZAL ) ? 1 : 0;

wire[15:0] imm16=inst[15:0];
// 默认不跳�???
assign branch_predict = (inst_beq||inst_bne||inst_bgtz||inst_blez||inst_bgez||inst_bgezal||inst_bltz||inst_bltzal)?history[1]:`BP_NO;
assign branch_predict_addr = {pc + 4 + {{14{imm16[15]}}, {imm16, 2'b00}}};

always @(posedge clk)
  begin
    if(rst==`RstEnable)
    begin
      pred<=1'b0;
    end else begin
      if(inst_beq||inst_bne||inst_bgtz||inst_blez||inst_bgez||inst_bgezal||inst_bltz||inst_bltzal)
        begin
          pred<=1'b1;
        end
      else
        begin
          pred<=1'b0;
        end
    end
  end

always @(clk)
  begin
    if(rst==`RstEnable)
      begin
        history<=2'b00;
      end
    else
      begin
        if(clk)
          begin  // 人工pose_edge
            if(pred)
              begin
                if(flush)
                  begin  // 预测失败，反转预�???
                    case (history)
                      STRONG_YES:
                        history<=WEAK_YES;
                      WEAK_YES:
                        history<=WEAK_NO;
                      WEAK_NO:
                        history<=WEAK_YES;
                      STRONG_NO:
                        history<=WEAK_NO;
                      default:
                        history<=STRONG_NO;
                    endcase
                  end
                else
                  begin
                    case (history)
                      STRONG_YES:
                        history<=STRONG_YES;
                      WEAK_YES:
                        history<=STRONG_YES;
                      WEAK_NO:
                        history<=STRONG_NO;
                      STRONG_NO:
                        history<=STRONG_NO;
                      default:
                        history<=STRONG_NO;
                    endcase
                  end
              end
          end
      end
  end
endmodule
