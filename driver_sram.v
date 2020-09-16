`timescale 1ns / 1ps
module driver_sram(
            input wire        sck, //clock
            input wire        rst,
            input wire        cs_n, //chip select
            input wire [35:0] mosi, //slave input
            output reg [15:0] miso, //slave output
            );
   reg [18:0]                 addr;
   reg [15:0]                 wdata;
   wire [15:0]                rdata;
   wire [15:0]                data;
   wire                       rw; //r=0,w=1
   reg                        oe;
   reg                        ce;
   reg                        we;
   reg                        ub;
   reg                        lb;

   assign rw = mosi[35];

   sram sram0 (
             .addr(addr),
             .oe_n(oe),
             .ce_n(ce),
             .we_n(we),
             .ub(ub),
             .lb(lb),
             .data(data)
             );

   assign rdata = data;
   assign data = rw ? wdata:{16{1'bz}};

   always @ (posedge sck) begin
      if(rst) begin
         addr <= 19'b0;
         wdata <= 16'b0;
         miso <= 16'b0;
         oe <= 1;
         ce <= 1;
         we <= 1;
         ub <= 0;
         lb <= 0;
      end
      else if(cs_n == 0) begin
         if(rw == 0) begin
            addr <= mosi[18:0];
            oe <= 0;
            ce <= 0;
            we <= 1;
            lb <= 0;
            ub <= 0;
            miso <= rdata;
         end
         else begin
            wdata <= mosi[34:19];
            addr <= mosi[18:0];
            miso <= 16'b0;
            oe <= 1;
            ce <= 0;
            we <= 0;
            lb <= 0;
            ub <= 0;
         end // else: !if(rw == 0)
      end // if (cs_n == 0)
   end // always @ (posedge sck)

endmodule // driver_sram

