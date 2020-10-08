`timescale 1ns / 1ps
module sram(
            input wire         sck, //clock
            input wire         rst,
            input wire         cs_n, //chip select
            input wire [35:0]  mosi, //slave input
            output wire [15:0] miso, //slave output
            output wire [18:0] sram_addr,
            inout wire [15:0] sram_data,
            output wire        sram_oe_n,
            output wire        sram_ce_n,
            output wire        sram_we_n,
            output wire        sram_ub,
            output wire        sram_lb
            );

   wire                       rw; //r=0,w=1
   
   assign rw = mosi[35];
   assign miso = rw ? 16'b0:sram_data;
   assign sram_data = rw ? mosi[34:19]:{16{1'bz}};
   assign sram_addr = mosi[18:0];
   assign sram_oe_n = cs_n | rw;
   assign sram_ce_n = cs_n;
   assign sram_we_n = cs_n | (~rw);
   assign sram_ub = cs_n;
   assign sram_lb = cs_n;

endmodule // sram