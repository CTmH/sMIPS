`timescale 1ns / 1ps
module vsram (
              input wire         sck,
              input wire         rst,
              input wire         cs_n,
              input wire [35:0]  mosi,
              output wire [15:0] miso,
              );
   reg [15:0]                   dmem[63:0];
   wire [5:0]                   addr;
   wire                         we;

   //load data

   assign addr = mosi[5:0];
   assign we = mosi[35];
   assign miso = we ? 16'b0 : dmem[addr];

   always @ (posedge clk) begin
      if(we) begin
         dmem[addr] <= mosi[34:19];
      end
   end

endmodule // vsram

