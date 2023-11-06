module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
			  input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
			  input logic start, output logic done,
			  output logic [7:0] vga_x, output logic [6:0] vga_y,
			  output logic [2:0] vga_colour, output logic vga_plot);
	
	reg unsigned [7:0] offset_x, offset_y, pixel_x, pixel_y;
	reg signed [8:0] crit;
	reg [3:0] state;
	reg is_valid, is_on_screen;

	localparam IDLE = 0;
	localparam OCT1 = 1;
	localparam OCT2 = 2;
	localparam OCT3 = 3;
	localparam OCT4 = 4;
	localparam OCT5 = 5;
	localparam OCT6 = 6;
	localparam OCT7 = 7;
	localparam OCT8 = 8;
	localparam DONE = 9;

	localparam RESOLUTION_WIDTH = 160;
	localparam RESOLUTION_HIGHT = 120;

	assign vga_colour = start ? colour : 0;
	assign is_on_screen = pixel_x < RESOLUTION_WIDTH && pixel_y < RESOLUTION_HIGHT;
	assign is_valid = is_on_screen && offset_y <= offset_x;

	assign vga_x = is_on_screen ? pixel_x : 8'h55;
	assign vga_y = is_on_screen ? pixel_y[6:0] : 7'h55;

	always_comb begin
		done = 0;
		vga_plot = is_valid;
		case (state)
			IDLE: begin
				vga_plot = 0;
			end
			OCT1: begin
				pixel_x = centre_x + offset_x;
				pixel_y = centre_y + offset_y;
			end
			OCT2: begin
				pixel_x = centre_x + offset_y;
				pixel_y = centre_y + offset_x;
			end
			OCT3: begin
				pixel_x = centre_x - offset_y;
				pixel_y = centre_y + offset_x;
			end
			OCT4: begin
				pixel_x = centre_x - offset_x;
				pixel_y = centre_y + offset_y;
			end
			OCT5: begin
				pixel_x = centre_x - offset_x;
				pixel_y = centre_y - offset_y;
			end
			OCT6: begin
				pixel_x = centre_x - offset_y;
				pixel_y = centre_y - offset_x;
			end
			OCT7: begin
				pixel_x = centre_x + offset_y;
				pixel_y = centre_y - offset_x;
			end
			OCT8: begin
				pixel_x = centre_x + offset_x;
				pixel_y = centre_y - offset_y;
			end
			DONE: begin
				vga_plot = 0;
				done = 1;
			end 
			default: begin
				vga_plot = 0;
				done = 0;
			end
		endcase
	end

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
		end else begin
			case(state)
				IDLE: begin
					state <= start ? OCT1 : IDLE;
					offset_y <= 0;
					offset_x <= radius;
					crit <= 1 - radius;
				end
				OCT1: begin
					if (!start) state <= IDLE; 
					else if (offset_y <= offset_x) state <= OCT2;
					else state <= DONE;
				end
				OCT2: state <= start ? OCT3 : IDLE;
				OCT3: state <= start ? OCT4 : IDLE;
				OCT4: state <= start ? OCT5 : IDLE;
				OCT5: state <= start ? OCT6 : IDLE;
				OCT6: state <= start ? OCT7 : IDLE;
				OCT7: state <= start ? OCT8 : IDLE;
				OCT8: begin
					state <= start ? OCT1 : IDLE;
					offset_y <= offset_y + 1;
					if (crit < 1) begin
						crit <= crit + (offset_y<<1) + 1;
					end else begin
						offset_x <= offset_x - 1;
						crit <= crit + ((offset_y - offset_x)<<1) + 1;
					end
				end
				DONE: state <= start ? IDLE : DONE;
				default: state <= IDLE;
			endcase
		end
	end

endmodule

