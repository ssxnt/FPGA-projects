module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     
     reg [1:0] state;

     localparam IDLE = 0;
	localparam FILL = 1;
	localparam DONE = 2; 

     localparam RESOLUTION_WIDTH = 160;
	localparam RESOLUTION_HEIGHT = 120;

     always_ff @(posedge clk, negedge rst_n) begin
          if (!rst_n) begin
			state <= IDLE;
               {vga_x, vga_y} <= 0;
               vga_plot <= 0;
               done <= 0;
		end else begin
			case(state)
                    IDLE: begin 
                         state <= start ? FILL : IDLE;
                    end
                    FILL: begin
                         if (vga_x < RESOLUTION_WIDTH - 1) begin
                              vga_x <= vga_x + 1;
                         end  else if (vga_y < RESOLUTION_HEIGHT - 1) begin
                                   vga_x <= 0;
                                   vga_y <= vga_y + 1;
                         end  else begin
                                   state <= DONE;
                                   done <= 1;
                         end
                         vga_colour <= vga_x % 8;
                         vga_plot <= 1;
                    end
                    DONE: begin
                         state <= IDLE;
                    end
                    default: state <= IDLE;
               endcase
          end
     end
    
endmodule: fillscreen