`timescale 1ns / 1ps
module sram (
             input wire [18:0] addr,
             input wire        oe_n,
             input wire        ce_n,
             input wire        we_n,
             input wire        ub,
             input wire        lb,
             inout wire [15:0] data
             );
   assign MEM_D0 = data[0];
   assign MEM_D1 = data[1];
   assign MEM_D2 = data[2];
   assign MEM_D3 = data[3];
   assign MEM_D4 = data[4];
   assign MEM_D5 = data[5];
   assign MEM_D6 = data[6];
   assign MEM_D7 = data[7];
   assign MEM_D8 = data[8];
   assign MEM_D9 = data[9];
   assign MEM_D10 = data[10];
   assign MEM_D11 = data[11];
   assign MEM_D12 = data[12];
   assign MEM_D13 = data[13];
   assign MEM_D14 = data[14];
   assign MEM_D15 = data[15];

   assign MEM_A0 = addr[0];
   assign MEM_A1 = addr[1];
   assign MEM_A2 = addr[2];
   assign MEM_A3 = addr[3];
   assign MEM_A4 = addr[4];
   assign MEM_A5 = addr[5];
   assign MEM_A6 = addr[6];
   assign MEM_A7 = addr[7];
   assign MEM_A8 = addr[8];
   assign MEM_A9 = addr[9];
   assign MEM_A10 = addr[10];
   assign MEM_A11 = addr[11];
   assign MEM_A12 = addr[12];
   assign MEM_A13 = addr[13];
   assign MEM_A14 = addr[14];
   assign MEM_A15 = addr[15];
   assign MEM_A16 = addr[16];
   assign MEM_A17 = addr[17];
   assign MEM_A18 = addr[18];

   assign SRAM_OE_N = oe_n;
   assign SRAM_CE_N = ce_n;
   assign SRAM_WE_N = we_n;
   assign SRAM_UB = ub;
   assign SRAM_LB = lb;

endmodule
