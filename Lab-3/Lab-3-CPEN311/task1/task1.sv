module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
			output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
			output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
			output logic [9:0] LEDR);

	logic en;
	logic rdy;
	reg [7:0] addr;
	reg [7:0] wrdata;
	reg wren;
	wire rst_n = KEY[3];
			
	reg [1:0] state;
	localparam idle = 0;
	localparam writeS = 1;
	localparam finished = 2;

	s_mem s(.address(addr), .clock(CLOCK_50), .data(wrdata), .wren, .q());
	init init(.clk(CLOCK_50), .rst_n, .en, .rdy, .addr, .wrdata, .wren);

	always_comb begin
		case (state)
			idle: en = rdy;
			default en = 0;
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		if (!rst_n) state = idle;
		else begin
			case (state)
				idle: state <= rdy ? writeS : idle;
				writeS: state <= rdy ? finished : writeS;
				finished: state <= finished;
				default: state <= idle;
			endcase
		end
	end

endmodule: task1
