module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
				input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
				input logic start, output logic done,
				output logic [7:0] vga_x, output logic [6:0] vga_y,
				output logic [2:0] vga_colour, output logic vga_plot);

	reg unsigned [7:0] c1x, c1y, c2x, c2y, c3x, c3y, CENTRE_X, CENTRE_Y;
	reg [2:0] state;
	reg circle_start;
	wire circle_done, plot_en;

	assign c1x = centre_x;
	assign c1y = centre_y - (diameter*37>>6);
	assign c2x = centre_x - (diameter>>1);
	assign c2y = centre_y + (diameter*37>>7);
	assign c3x = centre_x + (diameter>>1);
	assign c3y = centre_y + (diameter*37>>7);
	
	localparam IDLE = 0;
	localparam DRC1 = 1;
	localparam DRC2 = 2;
	localparam DRC3 = 3;
	localparam DONE = 4;

	circle cir(.clk, .rst_n, .colour, .centre_x(CENTRE_X), .centre_y(CENTRE_Y), .radius(diameter),
				.start(circle_start), .done(circle_done), .vga_x, .vga_y, .vga_colour, .vga_plot(plot_en));
	
	always_comb begin
		case(state)
			IDLE: vga_plot = 0;
			DRC1: vga_plot = (vga_y >  c2y) && plot_en;
			DRC2: vga_plot = (vga_x >= c1x && vga_y <= c3y) && plot_en;
			DRC3: vga_plot = (vga_x <  c1x && vga_y <= c2y) && plot_en;
			DONE: vga_plot = 0;
		endcase
	end

	always_comb begin
		done = 0;
		case(state)
			IDLE: circle_start = 0;
			DRC1: begin
				CENTRE_X = c1x;
				CENTRE_Y = c1y;
				circle_start = 1;
			end
			DRC2: begin
				CENTRE_X = c2x;
				CENTRE_Y = c2y;
				circle_start = 1;
			end
			DRC3: begin
				CENTRE_X = c3x;
				CENTRE_Y = c3y;
				circle_start = 1;
			end
			DONE: done = 1;
		endcase
	end

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end else begin
			case (state)
				IDLE: state <= start ? DRC1 : IDLE;
				DRC1: state <= circle_done ? DRC2 : DRC1;
				DRC2: state <= !start ? IDLE :
							   circle_done ? DRC3 : DRC2;
				DRC3: state <= !start ? IDLE :
							   circle_done ? DONE : DRC3;
				DONE: state <= start ? IDLE : DONE;
				default: state <= IDLE;
			endcase
		end
	end

endmodule