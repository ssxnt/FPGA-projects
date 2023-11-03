module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

	logic start, done, rst_n, strt;
    reg [2:0] colour;
	reg [7:0] centre_x, diameter;
	reg [6:0] centre_y;

	reg [1:0] state;

    logic [9:0] VGA_R_10;
	logic [9:0] VGA_G_10;
	logic [9:0] VGA_B_10;
	logic VGA_BLANK, VGA_SYNC;

	localparam IDLE = 0;
	localparam DRAW = 1;
	localparam DONE = 3;

	localparam RED 		= 3'b100;
	localparam GREEN 	= 3'b010;
	localparam BLUE 	= 3'b001;
	localparam WHITE	= 3'b111;
	localparam BLACK 	= 3'b000;
	localparam YELLOW	= 3'b110;
	localparam AQUA 	= 3'b011;
	localparam PURPLE 	= 3'b101;

	assign VGA_R = VGA_R_10[9:2];
	assign VGA_G = VGA_G_10[9:2];
	assign VGA_B = VGA_B_10[9:2];

    assign rst_n = KEY[3];
	assign strt = KEY[0];

	assign colour = RED;
	assign centre_x = 80;
	assign centre_y = 60;
	assign diameter = 80;

	reuleaux joe(.clk(CLOCK_50), .rst_n, .colour, .centre_x, .centre_y, .diameter,
			  .start, .done, .vga_x(VGA_X), .vga_y(VGA_Y), .vga_colour(VGA_COLOUR), .vga_plot(VGA_PLOT));

	vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(rst_n), .clock(CLOCK_50), .colour(VGA_COLOUR),
											.x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
											.VGA_R(VGA_R_10), .VGA_G(VGA_G_10), .VGA_B(VGA_B_10),
											.*);
	
	always_comb begin
		case(state)
			IDLE: start = 0;
			DRAW: start = 1;
			DONE: start = 0;
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end else begin
			case(state)
				IDLE: state <= strt ? DRAW : IDLE;
				DRAW: state <= done ? DONE :
							   strt ? DRAW : IDLE;
				DONE: state <= DONE;
				default: state <= IDLE;
			endcase
		end
	end
	
endmodule: task4
