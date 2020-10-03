module driver_led(
                  input wire        sck,
                  input wire        rst,
                  input wire        cs_n,
                  input wire        rw,
                  input wire [7:0]  mosi,
                  output wire [7:0] miso,
                  output wire [7:0] led
                  );
   reg [7:0]                         rled;
   assign led = rled;
   assign miso = rled;

   always @ (posedge sck) begin
      if(rst) begin
         rled <= 8'b0;
      end
      else if(cs_n==0 && rw == 1) begin
         rled <= mosi;
      end
   end

endmodule // driver_led
