module top_level
  #(
    parameter DVSR = 50,   //sampe every 1ms
              DVSR_BIT = 8,
              DBIT = 1,
              FIFO_W = 2         
  )
  (input wire clk,reset,
   input wire [7:0] d,
   output wire servo, pwm,
	output wire [7:0] leds

  );

//signal declaration
reg [19:0] duty;
reg en;
wire tick, big_tick, ctrl, wr, empty ;
wire r_data;
reg led_reg, led_next, rd;



mod_m_counter #(.M(24'd10000000), .N(24)) sample_tick_gen1
  (.clk(clk), .reset(reset), .q(), .max_tick(big_tick));
  
mod_m_counter #(.M(DVSR), .N(DVSR_BIT)) sample_tick_gen
  (.clk(clk), .reset(reset), .q(), .max_tick(tick));
  
visualizer visual_unit
  (.clk(clk), .reset(reset), .d(d), .leds(leds));
  
processing_unit proc_unit 
  (.clk(clk), .reset(reset), .d(d), .sample_tick(tick),
   .wr(wr), .ctrl(ctrl));
   
fifo #(.B(DBIT), .W(FIFO_W)) fifo_unit
  (.clk(clk), .reset(reset), .w_data(ctrl), .wr(wr), .full(), .rd(rd),
   .empty(empty) , .r_data(r_data));
   
pwm_generator pwm_gen_unit  
	(.clk(clk), .reset(reset), .en(en), .duty(duty), .pwm_out(pwm), .big_tick(big_tick));

always@(posedge clk, posedge reset)
  if(reset)
    led_reg <= 0;
  else
    led_reg <= led_next;
  
always@*
  begin
	 duty = 0;
	 en = 0;
    rd = 0;
    led_next = led_reg;
    if(~empty)
      begin
       rd = 1;
		 en = 1;
       led_next = r_data;		 
		 if (led_reg)
			duty = 20'd88000;               // +180 degree // 2ms duty cycle
		 else
			duty = 20'd60000;						// 0 degree    // 1ms duty cycle
		
     end
  end
  

assign servo = led_reg;


endmodule
