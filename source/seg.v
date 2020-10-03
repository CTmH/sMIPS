module seg(
           input wire         sck,
           input wire         rst,
           input wire         cs_n,
           input wire         rw,
           input wire [31:0]  mosi,
           output wire [31:0] miso,
           output reg [7:0]   seg_sel,
           output reg [7:0]   seg_code
           );

   reg [31:0]                 cnt;
   reg clk2;
   reg [31:0]                 div_counter = 0;
   reg                        step = 0;
   reg [31:0]                 num;
   reg [3:0]   i=0;
   wire clk;
   assign clk = sck;
   assign miso = num;
   parameter _0 = 8'h3f,_1 = 8'h06,_2 = 8'h5b,_3 = 8'h4f,
     _4 = 8'h66,_5 = 8'h6d,_6 = 8'h7d,_7 = 8'h07,
     _8 = 8'h7f,_9 = 8'h6f;
   parameter STEP1 = 1'b0,  STEP2 = 1'b1;

   always @ (posedge clk) begin
      if(rst) begin
         num <= 0;
         step <= STEP1;
      end
      else if(cs_n == 0 && rw == 1) begin
         num <= mosi;
      end
   end
   
   always @ (posedge clk) begin
      if(rst) begin
         cnt <= 0;
         clk2 <= 0;
      end
      else if(cnt == 10000) begin
         cnt <= 0;
         clk2 <= !clk2;
      end
      else
        cnt <= cnt + 1;
   end

   always @ (posedge clk2)
   begin
          i = i+1'b1;
          if(i==4'b1001)
          i = 0;
          case(i)
          4'b0000:
          begin
                 
                    seg_sel = 8'b00000001;
                       case(num[3:0])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[3:0])
              end // if (sel == 8'b00000001)
             4'b0001:    
                    begin
                   seg_sel = 8'b00000010;
                       case(num[7:4])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[7:4])
                    end // if (sel == 8'b00000010)
                   4'b0010:
                    begin
                    seg_sel = 8'b00000100;
                       case(num[11:8])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[11:8])
                    end // if (sel == 8'b00000100)
                    4'b0011:
                    begin
                    seg_sel = 8'b00001000;
                       case(num[15:12])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[15:12])
                    end // if (sel == 8'b00001000)
                    4'b0100:
                    begin
                    seg_sel = 8'b00010000;
                       case(num[19:16])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[19:16])
                    end // if (sel == 8'b00010000)
                    4'b0101:
                    begin
                    seg_sel = 8'b00100000;
                       case(num[23:20])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[23:20])
                    end // if (sel == 8'b00100000)
                    4'b0110:
                    begin
                    seg_sel = 8'b01000000;
                       case(num[27:24])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[27:24])
                    end // if (sel == 8'b01000000)
                    4'b0111:
                    begin
                    seg_sel = 8'b10000000;
                       case(num[31:28])
                         4'd0:seg_code <= _0;
                         4'd1:seg_code <= _1;
                         4'd2:seg_code <= _2;
                         4'd3:seg_code <= _3;
                         4'd4:seg_code <= _4;
                         4'd5:seg_code <= _5;
                         4'd6:seg_code <= _6;
                         4'd7:seg_code <= _7;
                         4'd8:seg_code <= _8;
                         4'd9:seg_code <= _9;
                       endcase // case (num[31:28])
                    end // if (sel == 8'b10000000)
                    endcase
          end
endmodule // seg

