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
           output wire [7:0]   seg_sel,
           output wire [7:0]   seg_code,
           output wire [3:0] r,
           output wire [3:0] g,
           output wire [3:0] b,
           output wire hs,
           output wire vs
           );
   wire                      cs_dram_n; //data
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
   wire [35:0]               mo_vga;

   //12'h000 for instruction
   assign cs_dram_n = ((addr[31:20] == 12'h001) ? 0:1) || (!en);
   assign cs_led_n = ((addr[31:20] == 12'h002) ? 0:1) || (!en);
   assign cs_seg_n = ((addr[31:20] == 12'h003) ? 0:1) || (!en);
   assign cs_vga_n = ((addr[31:20] == 12'h004) ? 0:1) || (!en);

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

   assign mo_led = sel[0] ? wdata[7:0]:(
                   sel[1] ? wdata[15:8]:(
                   sel[2] ? wdata[23:16]:(
                   sel[3] ? wdata[31:24]:7'b0)));

   assign mo_seg = wdata;
   
   assign mo_vga = {1'b1,lwdata,{addr[19:2]},1'b0};

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
        // state <= 1'b1;
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
            
   vga_char_display vga0 (
            .clk(clk),
            .rst(rst),
            .in_w_data(mo_vga),
            .hs(hs),
            .vs(vs),
            .r(r),
            .g(g),
            .b(b));


endmodule // bus
