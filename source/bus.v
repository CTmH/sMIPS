`timescale 1ns / 1ps
module bus(
           input wire         sck,
           input wire         rst,
           input wire         en,
           input wire         rw,
           input wire [3:0]   sel,
           input wire [31:0]  addr,
           input wire [31:0]  wdata,
           output wire [31:0] rdata,
           output wire [18:0] sram_addr,
           inout wire [15:0]  sram_data,
           output wire        sram_oe_n,
           output wire        sram_ce_n,
           output wire        sram_we_n,
           output wire        sram_ub,
           output wire        sram_lb
           );
   wire                      cs_dram_n; //data
   wire                      cs_iram_n; //instruction
   wire                      cs_vga_n;
   wire [35:0]               mo_dram;
   wire [15:0]               mi_dram;
   wire [15:0]               hwdata;
   wire [15:0]               lwdata;
   wire [15:0]               hrdata;
   wire [15:0]               lrdata;
   wire [15:0]               mi;
   reg                       state;
   reg [15:0]                last_mi;

   assign cs_iram_n = ((addr[31:20] == 12'h000) ? 0:1) || (!en);
   assign cs_dram_n = ((addr[31:20] == 12'h001) ? 0:1) || (!en);
   assign hwdata = wdata[31:16];
   assign lwdata = wdata[15:0];
   assign rdata[31:16] = hrdata;
   assign rdata[15:0] = lrdata;
   assign mo_dram = state ? {rw,hwdata,{addr[19:2],1'b1}}:{rw,lwdata,{addr[19:2],1'b0}};
   assign mi = cs_dram_n ? 16'b0 : mi_dram;
   assign lrdata = cs_dram_n ? 16'b0 : last_mi;
   assign hrdata = mi;

   //TODO cs_vga_n

   sram sram0(
                      .sck(sck),
                      .rst(rst),
                      .cs_n(cs_dram_n),
                      .mosi(mo_dram),
                      .miso(mi_dram),
                      .sram_addr(sram_addr),
                      .sram_data(sram_data),
                      .sram_oe_n(sram_oe_n),
                      .sram_ce_n(sram_ce_n),
                      .sram_we_n(sram_we_n),
                      .sram_ub(sram_ub),
                      .sram_lb(sram_lb));

   always @ (posedge sck) begin
      if(rst) begin
         state <= 1'b0;
      end
      else begin
         state <= ~state;
         last_mi <= mi;
      end
   end

endmodule // bus
