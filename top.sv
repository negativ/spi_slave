module top(input clk,
			input reset,
			input sck,
			input ss,
			input mosi,
			output miso,
			output led,
            input logic m_miso,
            output logic m_ss,
            output logic m_sck,
			output logic m_mosi,
			output logic [7:0] m_q,
			output logic m_finished);

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
						
spi_master s_master(.clk(clk),
                    .reset(reset),
                    .starttx(1'b1),
                    .d(d),
                    .miso(m_miso),
                    .ss(m_ss),
                    .sck(s_sck),
                    .mosi(m_mosi),
                    .q(m_q),
                    .finished(m_finished));

always_ff @(posedge clk, posedge reset) begin
	if (reset)
		d <= '0;
	else if (led)
		d <= q + 1'b1;
end
			  
endmodule