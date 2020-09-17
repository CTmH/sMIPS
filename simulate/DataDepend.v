`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/16 14:48:10
// Design Name: 
// Module Name: testbench
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


module testbench(

    );
    
reg clk;
reg rst;

initial begin
    clk = 0;
    rst = 1;
    #3
    rst = 0;
end
always #1 clk=~clk; 

spoc spoc0(
  .clk(clk),
  .rst(rst)
);

endmodule
