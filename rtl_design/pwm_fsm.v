// 1 ms	  >> duty= 20'd50000
// 1.5 ms  >> duty= 20'd75000
// 2 ms	  >> duty= 20'd100000
// 50 HZ  >> period=1000000
module pwm_generator
	#(
		parameter period = 20'd1000000,		// period of pwm signal =  servo period * system frequancy
					 pbit = 20,			// bits to store period
					 dbit = 20			// bits to store duty cycle
	  )
  (
	input wire clk, reset,
	input wire en,	big_tick,					// start preduce the signal
	input wire [dbit-1:0] duty,   // duty cycle from previous stage 8-bit
	output wire pwm_out           // output signal mapped to servo
   );

	//symbolic state decleration
	localparam [1:0]
		start = 2'b00,
		idle = 2'b01,
		one  = 2'b10,
		zero = 2'b11;
		
	//signal decleration
	reg pwm_next, pwm_reg;
	reg [1:0] state_next, state_reg;
	reg [dbit-1:0] dut_next, dut_reg;
	reg [pbit-1:0] per_next, per_reg;
	
	//body
	//FSMD state & data regesters
	always @(posedge clk, posedge reset)
		if (reset)
			begin
				state_reg <= start;
				dut_reg <= 0;
				per_reg <= 0;
				pwm_reg <= 0;
			end
		else
			begin
				state_reg <= state_next;
				dut_reg <= dut_next;
				per_reg <= per_next;
				pwm_reg <= pwm_next;
			end
	
	//FSMD next-state logic
	always @*
	begin
		state_next = state_reg;
		dut_next = dut_reg;
		per_next = per_reg;
		pwm_next = pwm_reg;
		case (state_reg)
		
			start:
				if (big_tick)
					state_next = idle;
			idle:
			
				if (en)
					begin
						state_next = one;
						dut_next = duty;
						per_next = period;
					end
			one:
				begin
					pwm_next = 1'b1;
					if (dut_reg == 0)
						state_next = zero;
					else
						begin
							dut_next = dut_reg - 1;
							per_next = per_reg - 1;
						end
				end
			zero:
				begin
					pwm_next = 1'b0;
					if (per_reg == 0)
						state_next = idle;
					else
						per_next = per_reg - 1;
				end
			default: state_next = idle;
		endcase
	end
	
	//output logic
	assign pwm_out = pwm_reg;

endmodule
