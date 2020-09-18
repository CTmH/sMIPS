`timescale 1ns / 1ps
module driver_sram(
            input wire         sck, //clock
            input wire         rst,
            input wire         cs_n, //chip select
            input wire [35:0]  mosi, //slave input
            output wire [15:0] miso, //slave output
            );
   wire [18:0]                addr;
   wire [15:0]                data;
   wire                       rw; //r=0,w=1
   wire                       oe;
   wire                       ce;
   wire                       we;
   wire                       ub;
   wire                       lb;

   sram sram0 (
             .addr(addr),
             .oe_n(oe),
             .ce_n(ce),
             .we_n(we),
             .ub(ub),
             .lb(lb),
             .data(data)
             );

   assign rw = mosi[35];
   assign miso = rw ? 16'b0:data;
   assign data = rw ? mosi[34:19]:{16{1'bz}};
   assign addr = mosi[18:0];
   assign oe = cs_n | rw;
   assign ce = cs_n;
   assign we = cs_n | (~rw);
   assign ub = cs_n;
   assign lb = cs_n;

endmodule // driver_sram

