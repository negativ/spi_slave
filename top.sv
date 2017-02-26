module top(input clk,
			  input reset,
			  input sck,
			  input ss,
			  input mosi,
			  output miso,
			  output led);

logic [7:0] q = '0;
logic [7:0] d = '0;

spi_slave s_slave(.clk(clk), 
						.reset(reset), 
						.d(d), 
						.sck(sck), 
						.ss(ss), 
						.mosi(mosi), 
						.miso(miso), 
						.q(q), 
						.finished(led));

always_ff @(posedge clk, posedge reset) begin
	if (reset)
		d <= '0;
	else if (led)
		d <= q + 1'b1;
end
			  
endmodule