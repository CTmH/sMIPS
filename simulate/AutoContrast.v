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
    #3;
    rst = 0;
end
always #1 clk=~clk; 

spoc spoc0(
  .clk(clk),
  .rst(rst)
);

// open the trace file;
integer trace_ref;
initial begin
    trace_ref = $fopen("C:/Users/like/vivado/data/trace.txt","r");
end

wire [31:0] debug_inst;
wire [7 :0] debug_aluop_i;
wire [31:0] debug_regs_wdata;
assign debug_inst        = spoc0.cpu0.id_inst_i;
assign debug_aluop_i     = spoc0.cpu0.ex_aluop_i;
assign debug_regs_wdata  = spoc0.cpu0.wb_wreg_data_i;

//get reference result in falling edge
reg        debug_end;
reg [31:0] ref_inst;
reg [7 :0] ref_aluop_i;
reg [31:0] ref_regs_wdata;
always @(posedge clk)
begin 
    #1;
    if(!debug_end)
    begin
        if (!($feof(trace_ref)))
        begin
            $fscanf(trace_ref, "%b %h %h %h", debug_end,
                    ref_inst, ref_aluop_i, ref_regs_wdata);
        end
    end
end

//compare result in rsing edge 
reg [7:0] err_count;
always @(posedge clk)
begin
    #2;
    if(!debug_end)
    begin
        if ((debug_inst!==ref_inst) || (debug_aluop_i!==ref_aluop_i)||(debug_regs_wdata!==ref_regs_wdata))
        begin
            $display("--------------------------------------------------------------");
            $display("[%t] Error!!!",$time);
            $display("    reference: inst = 0x%8h, aluop = 0x%2h, regs_wdata = 0x%8h",
                      ref_inst, ref_aluop_i, ref_regs_wdata);
            $display("    mycpu    : inst = 0x%8h, aluop = 0x%2h, regs_wdata = 0x%8h",
                      debug_inst, debug_aluop_i, debug_regs_wdata);
            $display("--------------------------------------------------------------");
            err_count <= err_count + 1'b1;
        end
    end
end

//monitor test
initial
begin
    $timeformat(-9,0," ns",10);
    $display("==============================================================");
    $display("Test begin!");
    err_count = 0;
end

//test end
wire global_err = ( err_count!=8'd0) ? 1 : 0;
always @(posedge clk)
begin
    if (rst)
    begin
        debug_end <= 1'b0;
    end
    else if(debug_end)
    begin
        $display("==============================================================");
        $display("Test end!");
        $fclose(trace_ref);
        if (global_err)
        begin
            $display("Fail!!!Total %d errors!",err_count);
        end
        else
        begin
            $display("----PASS!!!");
        end
	    $finish;
	end
end

endmodule
