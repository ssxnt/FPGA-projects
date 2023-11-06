module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

	logic r_start, r_done, rst_n, strt, fsb_start, fsb_done;
    reg [2:0] r_colour, fsb_colour;
	reg [7:0] centre_x, diameter;
	reg [6:0] centre_y;
	reg [2:0] state;

	wire [2:0] fsb_colour_out, r_colour_out;

    logic [9:0] VGA_R_10;
	logic [9:0] VGA_G_10;
	logic [9:0] VGA_B_10;
	logic VGA_BLANK, VGA_SYNC;

	localparam IDLE = 0;
	localparam FILL = 1;
	localparam DRAW = 2;
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

	assign r_colour = RED;
	assign fsb_colour = BLACK;
	assign centre_x = 80;
	assign centre_y = 60;
	assign diameter = 80;
	assign VGA_COLOUR = fsb_colour_out | r_colour_out;

	fillscreenb fsb(.clk(CLOCK_50), .rst_n, .colour(fsb_colour), .start(fsb_start), .done(fsb_done), .vga_x(VGA_X), .vga_y(VGA_Y), 
                   .vga_colour(fsb_colour_out), .vga_plot(VGA_PLOT));

	reuleaux joe(.clk(CLOCK_50), .rst_n, .colour(r_colour), .centre_x, .centre_y, .diameter,
			  .start(r_start), .done(r_done), .vga_x(VGA_X), .vga_y(VGA_Y), .vga_colour(r_colour_out), .vga_plot(VGA_PLOT));

	vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(rst_n), .clock(CLOCK_50), .colour(VGA_COLOUR),
											.x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
											.VGA_R(VGA_R_10), .VGA_G(VGA_G_10), .VGA_B(VGA_B_10),
											.*);
	
	always_comb begin
		case(state)
			IDLE: {fsb_start, r_start} = {2'b00};
			FILL: {fsb_start, r_start} = {2'b10};
			DRAW: {fsb_start, r_start} = {2'b01};
			DONE: {fsb_start, r_start} = {2'b00};
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end else begin
			case(state)
				IDLE: state <= strt ? FILL : IDLE;
				FILL: state <= fsb_done ? DRAW : FILL;
				DRAW: state <= r_done ? DONE :
							   strt ? DRAW : IDLE;
				DONE: state <= DONE;
				default: state <= IDLE;
			endcase
		end
	end
	
endmodule: task4