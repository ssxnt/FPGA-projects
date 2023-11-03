module task3(input logic CLOCK_50, input logic [3:0] KEY,
			 input logic [9:0] SW, output logic [9:0] LEDR,
			 output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
			 output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
			 output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
			 output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
			 output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
			 output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

	// instantiate and connect the VGA adapter and your module
	logic fsb_start, c_start, fsb_done, c_done, rst_n, strt;
    reg [2:0] colour;
	reg [7:0] centre_x, radius;
	reg [6:0] centre_y;
	reg [2:0] state;
	reg [3:0] i = 0;
	
	//wire [7:0] VGA_X, VGA_Y;
	//wire [2:0] VGA_COLOUR;

    logic [9:0] VGA_R_10;
	logic [9:0] VGA_G_10;
	logic [9:0] VGA_B_10;
	logic VGA_BLANK, VGA_SYNC;

	localparam IDLE = 0;
	localparam FILL = 1;
	localparam DRAW = 2;
	localparam NEXT = 3;
	localparam DONE = 4;

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

	fillscreenb fsb(.clk(CLOCK_50), .rst_n, .colour, .start(fsb_start), .done(fsb_done), .vga_x(VGA_X), .vga_y(VGA_Y), 
                   .vga_colour(VGA_COLOUR), .vga_plot(VGA_PLOT));

	circle cir(.clk(CLOCK_50), .rst_n, .colour, .centre_x, .centre_y, .radius,
			  .start(c_start), .done(c_done), .vga_x(VGA_X), .vga_y(VGA_Y), .vga_colour(VGA_COLOUR), .vga_plot(VGA_PLOT));

	vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(rst_n), .clock(CLOCK_50), .colour(VGA_COLOUR),
											.x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
											.VGA_R(VGA_R_10), .VGA_G(VGA_G_10), .VGA_B(VGA_B_10),
											.*);
	
	always_comb begin
		case(state)
			IDLE: {fsb_start, c_start} = {2'b00};
			FILL: {fsb_start, c_start} = {2'b10};
			DRAW: {fsb_start, c_start} = {2'b01};
			NEXT: {fsb_start, c_start} = {2'b00};
			DONE: {fsb_start, c_start} = {2'b00};
		endcase
	end

	always_comb begin
		case(i)
			 0: {colour, centre_x, centre_y, radius} = {RED,	8'd27, 	7'd37,	8'd52};
			 1: {colour, centre_x, centre_y, radius} = {GREEN,	8'd27, 	7'd12,	8'd21};
			 2: {colour, centre_x, centre_y, radius} = {BLUE,	8'd27, 	7'd123,	8'd14};
			 3: {colour, centre_x, centre_y, radius} = {WHITE,  8'd82, 	7'd1,	8'd34};
			 4: {colour, centre_x, centre_y, radius} = {BLACK, 	8'd99, 	7'd21,	8'd100};
			 5: {colour, centre_x, centre_y, radius} = {YELLOW, 8'd10, 	7'd34,	8'd123};
			 6: {colour, centre_x, centre_y, radius} = {AQUA, 	8'd120, 7'd55,	8'd12};
			 7: {colour, centre_x, centre_y, radius} = {RED, 	8'd33, 	7'd110,	8'd145};
			 8: {colour, centre_x, centre_y, radius} = {GREEN, 	8'd5, 	7'd32,	8'd67};
			 9: {colour, centre_x, centre_y, radius} = {BLUE,   8'd165,	7'd35,	8'd0};
			10: {colour, centre_x, centre_y, radius} = {WHITE, 	8'd198,	7'd18,	8'd42};
			11: {colour, centre_x, centre_y, radius} = {BLACK, 	8'd32, 	7'd35,	8'd13};
			12: {colour, centre_x, centre_y, radius} = {YELLOW, 8'd145,	7'd45,	8'd77};
			13: {colour, centre_x, centre_y, radius} = {AQUA, 	8'd23,	7'd39,	8'd90};
			14: {colour, centre_x, centre_y, radius} = {PURPLE, 8'd23,	7'd22,	8'd64};
			15: {colour, centre_x, centre_y, radius} = {PURPLE, 8'd87,	7'd56,	8'd32};
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end else begin
			case(state)
				IDLE: state <= strt ? FILL : IDLE;
				FILL: state <= fsb_done ? DRAW : FILL;
				DRAW: state <= c_done ? NEXT :
							   strt ? DRAW : IDLE;
				NEXT: begin
					  state <= c_done ? i==15 : 
							   strt ? DRAW : IDLE;
					i <= i + 1;
				end
				DONE: state <= DONE;
			endcase
		end
	end
	
endmodule: task3
