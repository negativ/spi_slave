module spi_master(input logic clk,
						input logic reset,
						input logic starttx,
						input logic [7:0] d,
						input logic miso,
						output logic ss,
						output logic sck,
						output logic mosi,
						output logic [7:0] q,
						output logic finished);

parameter CLOCK_DIV = 4;

typedef enum logic [2:0] {
	IDLE    = 3'b000,
	SS_DOWN = 3'b001,
	PAYLOAD = 3'b010,
	SS_UP   = 3'b011
} state_t;

state_t state, next_state;
logic [CLOCK_DIV - 1:0] sck_clk_counter = '0;
logic [1:0] sck_buffer = '0;
logic sck_en  = '0;
logic sck_rise = '0;
logic sck_fall = '0;
logic [7:0] mosi_data = '0;
logic [3:0] mosi_counter = '0;

always_comb begin
	sck = sck_en & sck_clk_counter[CLOCK_DIV-1];
	state = next_state;
    mosi = sck_en? mosi_data[7] : 1'bz;
    sck_rise = (sck_buffer == 2'b01);
    sck_fall = (sck_buffer == 2'b10);
end


always_ff @(posedge clk, posedge reset) begin
	if (reset) begin
		sck_clk_counter <= '0;
        mosi_data <= '0;
        sck_en <= '0;
        ss <= '1;
        finished <= '0;
        q <= '0;
        sck_buffer <= '0;
        mosi_counter <= '0;
	end
    else begin
        sck_buffer <= {sck_buffer[0], sck};
        
        case (state)
        IDLE: begin
            if (starttx) begin
                mosi_counter <= '0;
                mosi_data <= d;
                next_state <= SS_DOWN;
                finished <= '0;
            end
        end
        SS_DOWN: begin
            ss <= '0;
            sck_en <= '1;
            next_state <= PAYLOAD;
            mosi_counter <= '0;
        end
        PAYLOAD: begin
            sck_clk_counter <= sck_clk_counter + 1'b1;
            
            if (mosi_counter == 4'b1000) begin
                sck_en <= '0;
                next_state <= SS_UP;
            end
            else if (sck_rise)
                q <= {q[6:0], miso};
            else if (sck_fall) begin
                mosi_counter <= mosi_counter + 1'b1;
                mosi_data <= {mosi_data[6:0], 1'b0};
            end
            ss <= '0;
        end
        SS_UP: begin
            ss <= '1;
            finished <= '1;
            next_state <= IDLE;
        end
        endcase
    end
end
						
endmodule