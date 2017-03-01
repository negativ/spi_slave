`timescale 1 ns/ 10 ps

module spi_master_tb();

logic clk = '0;
logic reset = '0;
logic sck = '0;
logic ss = '1;
logic mosi = '0;
logic miso = '1;
logic ready = '0;
logic [7:0] q = '0;
logic [7:0] d = 8'h41;
logic starttx = '0;

spi_master spi(.clk(clk),
               .reset(reset),
               .starttx(starttx),
               .d(d),
               .miso(miso),
               .ss(ss),
               .sck(sck),
               .mosi(mosi),
               .q(q),
               .finished(ready)
               );

always
    #10 clk = ~clk;
    
initial begin
    #100 reset = '0;
    #100 reset = '1;
    #100 reset = '0;
    
    starttx = '1;
    
    #1200 $quit;
end

endmodule