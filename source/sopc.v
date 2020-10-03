`timescale 1ns / 1ps
`include "consts.vh"

module spoc(
         input wire clk,
         input wire rst_n,
           //SRAM IO
         output wire [18:0] sram_addr,
         inout wire [15:0]  sram_data,
         output wire        sram_oe_n,
         output wire        sram_ce_n,
         output wire        sram_we_n,
         output wire        sram_ub,
         output wire        sram_lb,
         output wire [7:0]  led,
         output wire [7:0]   seg_sel,
         output wire [7:0]   seg_code
       );
reg clk_cpu = 0;
reg state = 0;
wire rst;
assign rst  = !rst_n;

always @ (posedge clk) begin
    //if(rst) begin
   //     clk_cpu <= 0;
    //    state <= 0;
    //end
    //else 
    if(state)
        clk_cpu <= !clk_cpu;
     else state<=!state;
    end

cpu cpu0(
      .clk(clk_cpu),
      .clk_bus(clk),
      .rst(rst),
      .sram_addr(sram_addr),
      .sram_data(sram_data),
      .sram_oe_n(sram_oe_n),
      .sram_ce_n(sram_ce_n),
      .sram_we_n(sram_we_n),
      .sram_ub(sram_ub),
      .sram_lb(sram_lb),
      .led(led),
      .seg_sel(seg_sel),
      .seg_code(seg_code)
    );
endmodule
