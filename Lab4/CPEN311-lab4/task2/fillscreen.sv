module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y, 
                  output logic [2:0] vga_colour, output logic vga_plot);
     
     reg [1:0] state;
     reg [7:0] VGA_X; 
     reg [6:0] VGA_Y;

     localparam IDLE = 0;
	localparam FILL = 1;
	localparam DONE = 2; 

     localparam RESOLUTION_WIDTH = 160;
	localparam RESOLUTION_HEIGHT = 120;

     assign vga_colour = VGA_X % 8;

     assign vga_x = VGA_X;
     assign vga_y = VGA_Y;
     assign done = state == DONE;
     assign vga_plot = state == FILL;

     always_ff @(posedge clk, negedge rst_n) begin
          if (!rst_n) begin
			state <= IDLE;
               {VGA_X, VGA_Y} <= 0;
		end else begin
			case(state)
                    IDLE: begin 
                         state <= start ? FILL : IDLE;
                    end
                    FILL: begin
                         if (VGA_X < RESOLUTION_WIDTH-1) begin
                              VGA_X <= VGA_X + 1;
                         end  else if (VGA_Y < RESOLUTION_HEIGHT-1) begin
                                   VGA_X <= 0;
                                   VGA_Y <= VGA_Y + 1;
                         end  else begin
                                   state <= DONE;
                         end
                    end
                    DONE: begin
                         state <= IDLE;
                    end
                    default: state <= IDLE;
               endcase
          end
     end
    
endmodule: fillscreen