module task2(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    logic start, done, rst_n;
    reg [2:0] colour;

    logic [9:0] VGA_R_10;
	logic [9:0] VGA_G_10;
	logic [9:0] VGA_B_10;
	logic VGA_BLANK, VGA_SYNC;

	assign VGA_R = VGA_R_10[9:2];
	assign VGA_G = VGA_G_10[9:2];
	assign VGA_B = VGA_B_10[9:2];

    assign rst_n = KEY[3];
    assign colour = VGA_COLOUR;

    fillscreen fs(.clk(CLOCK_50), .rst_n(rst_n), .colour(colour), .start(start), .done(done), .vga_x(VGA_X), .vga_y(VGA_Y), .vga_colour(VGA_COLOUR), .vga_plot(VGA_PLOT));
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(rst_n), .clock(CLOCK_50), .colour(colour),
												.x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
												.VGA_R(VGA_R_10), .VGA_G(VGA_G_10), .VGA_B(VGA_B_10),
												.*);

    always_ff @(posedge CLOCK_50, negedge rst_n) begin
        start <= !rst_n && !done;
    end
    
endmodule: task2