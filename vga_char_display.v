`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/19 19:56:10
// Design Name: 
// Module Name: vga_char_display
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


module vga_char_display(
    input clk,
    input rst,
    //input [35:0] in_data,
    output reg [3:0] r,
    output reg [3:0] g,
    output reg [3:0] b,
    output hs,
    output vs
    );

	// 显示器可显示区域
	parameter UP_BOUND = 31;
	parameter DOWN_BOUND = 510;
	parameter LEFT_BOUND = 144;
	parameter RIGHT_BOUND = 783;

	// 屏幕中央两个字符的显示区域
	parameter up_pos = 100;
	parameter down_pos = 356;
	parameter left_pos = 200;
	parameter right_pos = 712;
	
	wire  [35:0] in_data = 36'b010001100000000000000000001;
	wire pclk;
	reg [9:0] hcount, vcount;
	wire [7:0] p[7:0];
	reg [255:0] screen_reg[511:0];//长511宽256像素
    reg rst_n;
    wire [4:0]v_word = in_data[4:0];//字符行地址
    wire [4:0]h_word = in_data[9:5];//字符列地址
    wire [7:0] word_ascii = in_data[26:19];//要输入字符的ascii
    reg [3:0] v_pixel ;
    reg [3:0] h_pixel;
    wire [7:0] v_mem0;
    assign v_mem0= {v_word[4:0],3'd0};
    wire [7:0] v_mem1;
    assign v_mem1= {v_word[4:0],3'd1};
    wire [7:0] v_mem2;
    assign v_mem2= {v_word[4:0],3'd2};
    wire [7:0] v_mem3;
    assign v_mem3= {v_word[4:0],3'd3};
    wire [7:0] v_mem4;
    assign v_mem4= {v_word[4:0],3'd4};
    wire [7:0] v_mem5;
    assign v_mem5= {v_word[4:0],3'd5};
    wire [7:0] v_mem6;
    assign v_mem6= {v_word[4:0],3'd6};
    wire [7:0] v_mem7;
    assign v_mem7= {v_word[4:0],3'd7};
    wire [7:0] h_mem0;
    assign h_mem0 = {h_word[4:0],3'd0};
    wire [7:0] h_mem1;
    assign h_mem1 = {h_word[4:0],3'd1};
    wire [7:0] h_mem2;
    assign h_mem2 = {h_word[4:0],3'd2};
    wire [7:0] h_mem3;
    assign h_mem3 = {h_word[4:0],3'd3};
    wire [7:0] h_mem4;
    assign h_mem4 = {h_word[4:0],3'd4};
    wire [7:0] h_mem5;
    assign h_mem5 = {h_word[4:0],3'd5};
    wire [7:0] h_mem6;
    assign h_mem6 = {h_word[4:0],3'd6};
    wire [7:0] h_mem7;
    assign h_mem7 = {h_word[4:0],3'd7};
    

 always @(posedge clk)//处理screen_reg寄存器中的数据
    begin
screen_reg[v_mem0][h_mem1] <= p[0][1];
         screen_reg[v_mem0][h_mem2] <= p[2][0];
         screen_reg[v_mem0][h_mem3] <= p[3][0];
         screen_reg[v_mem0][h_mem4] <= p[4][0];
         screen_reg[v_mem0][h_mem5] <= p[5][0];
         screen_reg[v_mem0][h_mem6] <= p[6][0];
         screen_reg[v_mem0][h_mem7] <= p[7][0];
         screen_reg[v_mem0][h_mem0] <= p[0][0];
         
         screen_reg[v_mem1][h_mem0] <= p[0][1];
         screen_reg[v_mem1][h_mem1] <= p[1][1];
         screen_reg[v_mem1][h_mem2] <= p[2][1];
         screen_reg[v_mem1][h_mem3] <= p[3][1];
         screen_reg[v_mem1][h_mem4] <= p[4][1];
         screen_reg[v_mem1][h_mem5] <= p[5][1];
         screen_reg[v_mem1][h_mem6] <= p[6][1];
         screen_reg[v_mem1][h_mem7] <= p[7][1];

         screen_reg[v_mem2][h_mem0] <= p[0][2];   
         screen_reg[v_mem2][h_mem1] <= p[1][2]; 
         screen_reg[v_mem2][h_mem2] <= p[2][2]; 
         screen_reg[v_mem2][h_mem3] <= p[3][2]; 
         screen_reg[v_mem2][h_mem4] <= p[4][2]; 
         screen_reg[v_mem2][h_mem5] <= p[5][2]; 
         screen_reg[v_mem2][h_mem6] <= p[6][2]; 
         screen_reg[v_mem2][h_mem7] <= p[7][2]; 
         
         screen_reg[v_mem3][h_mem0] <= p[0][3]; 
         screen_reg[v_mem3][h_mem1] <= p[1][3]; 
         screen_reg[v_mem3][h_mem2] <= p[2][3]; 
         screen_reg[v_mem3][h_mem3] <= p[3][3]; 
         screen_reg[v_mem3][h_mem4] <= p[4][3]; 
         screen_reg[v_mem3][h_mem5] <= p[5][3]; 
         screen_reg[v_mem3][h_mem6] <= p[6][3]; 
         screen_reg[v_mem3][h_mem7] <= p[7][3]; 
         
         screen_reg[v_mem4][h_mem0] <= p[0][4]; 
         screen_reg[v_mem4][h_mem1] <= p[1][4]; 
         screen_reg[v_mem4][h_mem2] <= p[2][4]; 
         screen_reg[v_mem4][h_mem3] <= p[3][4]; 
         screen_reg[v_mem4][h_mem4] <= p[4][4]; 
         screen_reg[v_mem4][h_mem5] <= p[5][4]; 
         screen_reg[v_mem4][h_mem6] <= p[6][4]; 
         screen_reg[v_mem4][h_mem7] <= p[7][4]; 
         
         screen_reg[v_mem5][h_mem0] <= p[0][5]; 
         screen_reg[v_mem5][h_mem1] <= p[1][5]; 
         screen_reg[v_mem5][h_mem2] <= p[2][5]; 
         screen_reg[v_mem5][h_mem3] <= p[3][5]; 
         screen_reg[v_mem5][h_mem4] <= p[4][5]; 
         screen_reg[v_mem5][h_mem5] <= p[5][5]; 
         screen_reg[v_mem5][h_mem6] <= p[6][5]; 
         screen_reg[v_mem5][h_mem7] <= p[7][5]; 
         
         screen_reg[v_mem6][h_mem0] <= p[0][6]; 
         screen_reg[v_mem6][h_mem1] <= p[1][6]; 
         screen_reg[v_mem6][h_mem2] <= p[2][6]; 
         screen_reg[v_mem6][h_mem3] <= p[3][6]; 
         screen_reg[v_mem6][h_mem4] <= p[4][6]; 
         screen_reg[v_mem6][h_mem5] <= p[5][6]; 
         screen_reg[v_mem6][h_mem6] <= p[6][6]; 
         screen_reg[v_mem6][h_mem7] <= p[7][6]; 
         
         screen_reg[v_mem7][h_mem0] <= p[0][7]; 
         screen_reg[v_mem7][h_mem1] <= p[1][7]; 
         screen_reg[v_mem7][h_mem2] <= p[2][7]; 
         screen_reg[v_mem7][h_mem3] <= p[3][7]; 
         screen_reg[v_mem7][h_mem4] <= p[4][7]; 
         screen_reg[v_mem7][h_mem5] <= p[5][7]; 
         screen_reg[v_mem7][h_mem6] <= p[6][7]; 
         screen_reg[v_mem7][h_mem7] <= p[7][7];



    end

    
 always @(posedge clk)
   begin
        rst_n <= ~rst;
   end 
	
	//获得25MHz时钟
	dcm_25m u0
         (
         // Clock in ports
          .clk_in1(clk),      // input clk_in1
          // Clock out ports
          .clk_out1(pclk),     // output clk_out1
          // Status and control signals
          .reset(rst_n));   

	RAM_set u_ram_1 (//p[A][B]:A为列，B为行
		.clk(clk),
		.rst_n(rst_n),
		.data(word_ascii),
		.col0(p[0]),
		.col1(p[1]),
		.col2(p[2]),
		.col3(p[3]),
		.col4(p[4]),
		.col5(p[5]),
		.col6(p[6]),
		.col7(p[7])
	);


	
	
	// 列计数与行同步
	assign hs = (hcount < 96) ? 0 : 1;
	always @ (posedge pclk or posedge rst_n)
	begin
		if (rst_n)
			hcount <= 0;
		else if (hcount == 799)
			hcount <= 0;
		else
			hcount <= hcount+1;
	end
	
	// 行计数与场同步
	assign vs = (vcount < 2) ? 0 : 1;
	always @ (posedge pclk or posedge rst_n)
	begin
		if (rst_n)
			vcount <= 0;
		else if (hcount == 799) begin
			if (vcount == 520)
				vcount <= 0;
			else
				vcount <= vcount+1;
		end
		else
			vcount <= vcount;
	end
	
	// 设置显示信号值
	always @ (posedge pclk or posedge rst_n)
	begin
		if (rst_n) begin
			r <= 0;
			g <= 0;
			b <= 0;
		end
		else if (vcount>=UP_BOUND && vcount<=DOWN_BOUND
				&& hcount>=LEFT_BOUND && hcount<=RIGHT_BOUND) begin
			if (vcount>=up_pos && vcount<=down_pos
					&& hcount>=left_pos && hcount<=right_pos) begin
				if (screen_reg[vcount-up_pos ][ hcount-left_pos]) begin
					r <= 4'b1111;
					g <= 4'b1111;
					b <= 4'b1111;
				end
				else begin
					r <= 4'b0000;
					g <= 4'b0000;
					b <= 4'b0000;
				end
			end
			else begin
				r <= 4'b0000;
				g <= 4'b0000;
				b <= 4'b0000;
			end
		end
		else begin
			r <= 4'b0000;
			g <= 4'b0000;
			b <= 4'b0000;
		end
	end

endmodule
