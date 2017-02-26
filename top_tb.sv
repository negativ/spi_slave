`timescale 1 ns/ 10 ps
module top_tb();

logic clk = '0;
logic reset = '0;
logic sck = '0;
logic ss = '1;
logic mosi = '0;
logic miso = '0;
logic sck_en = '0;
logic ready = '0;
logic [7:0] q = 8'h41;
logic [7:0] d = '0;
logic [7:0] mosi_data = 8'hF2;

initial begin
	#20 reset = '1;
	#100 reset = '0;
	#60 ss = '0;
	#810 ss = '1;
	#60 ss = '0;
	#810 ss = '1;
end

spi_slave spi(.clk(clk), 
				  .reset(reset), 
				  .d(d), 
			     .sck(sck), 
				  .ss(ss), 
				  .mosi(mosi), 
				  .miso(miso), 
				  .q(q), 
				  .finished(ready));

always_comb
	mosi = mosi_data[7];
	
always_ff @(negedge sck)
	mosi_data <= {mosi_data[6:0], 1'b0};

always begin
	#5 clk = ~clk;
	sck_en = ~ss;
end

always begin
	#50 sck = sck_en? ~sck : '0;
end

endmodule