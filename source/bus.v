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
           output wire        sram_lb,
           output wire [7:0]  led,
           output reg [7:0]   seg_sel,
           output reg [7:0]   seg_code
           );
   wire                      cs_dram_n; //data
   wire                      cs_iram_n; //instruction
   wire                      cs_vga_n;
   wire                      cs_led_n;
   wire                      cs_seg_n;
   wire [35:0]               mo_dram;
   wire [15:0]               mi_dram;
   wire [15:0]               hwdata;
   wire [15:0]               lwdata;
   wire [15:0]               hrdata;
   wire [15:0]               lrdata;
   wire [15:0]               mi;
   reg                       state;
   reg [15:0]                last_mi;
   wire [7:0]                mo_led;
   wire [7:0]                mi_led;
   wire [31:0]               mo_seg;
   wire [31:0]               mi_seg;

   assign cs_iram_n = ((addr[31:20] == 12'h000) ? 0:1) || (!en);
   assign cs_dram_n = ((addr[31:20] == 12'h001) ? 0:1) || (!en);
   assign cs_led_n = ((addr[31:20] == 12'h010) ? 0:1) || (!en);

   assign rdata[31:16] = (!cs_dram_n) ? hrdata:(
                         (!cs_led_n) ? {mi_led,mi_led}:
                         (!cs_seg_n) ? mi_seg[31:16] : 16'b0);
   assign rdata[15:0] = (!cs_dram_n) ? lrdata:(
                        (!cs_led_n) ? {mi_led,mi_led}:
                        (!cs_seg_n) ? mi_seg[15:0] : 16'b0);

   assign hwdata = wdata[31:16];
   assign lwdata = wdata[15:0];
   assign mo_dram = state ? {rw,hwdata,{addr[19:2],1'b1}}:{rw,lwdata,{addr[19:2],1'b0}};
   assign mi = cs_dram_n ? 16'b0 : mi_dram;
   assign lrdata = cs_dram_n ? 16'b0 : last_mi;
   assign hrdata = mi;

   assign mo_led = sel[0] ? wdata[0:7]:(
                   sel[1] ? wdata[8:15]:(
                   sel[2] ? wdata[16:23]:(
                   sel[3] ? wdata[24:31]:7'b0)));

   assign mo_seg = wdata;


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

   driver_led led0(
                   .sck(sck),
                   .rst(rst),
                   .cs_n(cs_led_n),
                   .rw(rw),
                   .mosi(mo_led),
                   .miso(mi_led),
                   .led(led));

   seg seg0(
            .sck(sck),
            .rst(rst),
            .cs_n(cs_seg_n),
            .rw(rw),
            .mosi(mo_seg),
            .miso(mi_seg),
            .seg_sel(seg_sel),
            .seg_code(seg_code));


endmodule // bus
