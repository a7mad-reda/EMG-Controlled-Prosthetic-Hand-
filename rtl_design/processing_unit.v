module processing_unit
  #(
    parameter k=50,     //no. samples needed
              k_th=3,   //no. samples 'threshold'
              th_val=8'd75 //signal amplitude 'threshold'
  )
  (
  input wire clk, reset,
  input wire sample_tick, //samples rate
  input wire [7:0] d,     //input signal
  output wire ctrl, wr
  );
  
  //symbolic state declaration
  localparam [1:0]
    idle = 2'b00,
    read = 2'b01,
    compare = 2'b10;
    
  //signal declaration
  reg [1:0] state_reg, state_next;
  reg [5:0] cmp_succ_reg, cmp_succ_next;
  reg [5:0] n_reg, n_next;
  reg [7:0] s_reg;
  reg ctrl_reg, ctrl_next;
  reg wr_reg, wr_next;
  
  //body
  
  //FSMD state & data registers
  always@(posedge clk, posedge reset)
    if (reset)
      begin
        state_reg <= idle;
        cmp_succ_reg <= 0;
        n_reg <= 0;
        s_reg <= 8'b0;
        ctrl_reg <= 0;
        wr_reg <= 0;
      end
    else
      begin
        state_reg <= state_next;
        ctrl_reg <= ctrl_next;
		  s_reg <= d;
        wr_reg <= wr_next;
        cmp_succ_reg <= cmp_succ_next;
        n_reg <= n_next;
      end
        
  //next state logic
  always@*
    begin
      state_next = state_reg;
      cmp_succ_next = cmp_succ_reg;
      n_next = n_reg;
      ctrl_next = ctrl_reg;
      wr_next = 0;
      
      case(state_reg)
        idle:
          begin
            cmp_succ_next = 0;
            n_next = 0;
            if(sample_tick)
              begin
                wr_next = 0;
                state_next = read;
              end
          end
          
        read:
          if(sample_tick)
            if(n_reg==k)
              state_next = compare;
            else 
              begin
                n_next = n_reg + 1;
                if(s_reg > th_val)
                  cmp_succ_next = cmp_succ_reg + 1;
              end
              
        compare:
          if(sample_tick)
            if(cmp_succ_reg >= k_th)
            begin
              ctrl_next = 1;
              wr_next = 1;
              state_next =idle;
            end
            else
            begin
              ctrl_next = 0;
              wr_next = 1;
              state_next =idle;
            end
            
      endcase
    end
    
  //output
  assign ctrl = ctrl_reg;
  assign wr = wr_reg;
  
endmodule 