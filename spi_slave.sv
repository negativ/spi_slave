module spi_slave(input logic clk,
					  input logic reset,
					  input logic [7:0] d,
					  input logic sck,
					  input logic ss,
					  input logic mosi,
					  output logic miso,
					  output logic [7:0] q,
					  output logic finished);
					  
logic ss_falling 		= '0;
logic ss_active 		= '0;
logic [2:0] ss_state = '0;
logic sck_falling 	= '0;
logic sck_rising 		= '0;
logic [2:0] sck_state 		= '0;
logic [3:0] mosi_counter	= '0;
logic mosi_data = '0;

always_ff @(posedge clk, posedge reset) begin
	if (reset) begin
		ss_state <= '1;
		sck_state <= '0;
	end
	else begin
		ss_state <= {ss_state[1:0], ss};
		sck_state <= {sck_state[1:0], sck};
	end
end

always_comb begin
	ss_falling  = (ss_state[2:1]  == 2'b10);
	ss_active   = (ss_state[2:1]  == 2'b00);
	sck_falling = (sck_state[2:1] == 2'b10);
	sck_rising  = (sck_state[2:1] == 2'b01);
	finished    = (mosi_counter[3] & (mosi_counter[2:0] == 3'b000));
	miso		   = (ss_active? (finished? 1'bz : q[7]) : (ss_falling? d[7] : 1'bz));
end

always_ff @(posedge clk, posedge reset) begin
	if (reset) begin
		mosi_counter <= '0;
		mosi_data <= '0;
		q <= '0;
	end
	else if (ss_falling) begin
		mosi_counter <= '0;
		q <= d;
	end
	else if (ss_active & sck_rising) begin
		mosi_data <= mosi;
	end
	else if (ss_active & sck_falling) begin
		q <= {q[6:0], mosi_data};
		mosi_counter <= mosi_counter + 1'b1;
	end
end
					  
endmodule