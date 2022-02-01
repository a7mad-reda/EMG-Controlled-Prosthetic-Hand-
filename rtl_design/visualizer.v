module visualizer
  (input wire clk,reset,
   input wire [7:0] d,
   output wire [7:0] leds
  );

reg [7:0] s_reg;

always@(posedge clk, posedge reset)
  if (reset)
    s_reg <= 0;
  else
    s_reg <= d;
    

assign leds[0] = (s_reg >= 8'h1f ) ? 1'b1 : 1'b0;
assign leds[1] = (s_reg >= 8'h3f ) ? 1'b1 : 1'b0;
assign leds[2] = (s_reg >= 8'h5f ) ? 1'b1 : 1'b0;
assign leds[3] = (s_reg >= 8'h7f ) ? 1'b1 : 1'b0;
assign leds[4] = (s_reg >= 8'h9f ) ? 1'b1 : 1'b0;
assign leds[5] = (s_reg >= 8'hbf ) ? 1'b1 : 1'b0;
assign leds[6] = (s_reg >= 8'hdf ) ? 1'b1 : 1'b0;
assign leds[7] = (s_reg >= 8'hff ) ? 1'b1 : 1'b0;
     
endmodule
