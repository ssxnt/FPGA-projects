module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     
     always_ff @(posedge clk, negedge rst_n) begin
          if (!rst_n) begin
               {vga_x, vga_y} <= -1;
               vga_plot = 0;
               done = 0;
          end else begin
               if (start) begin
                    //done <= 0;
                    vga_plot = 1;
                    vga_colour = vga_x % 8;
                    if (vga_x < 159) begin
                         vga_x <= vga_x + 1;
                    end else begin
                         vga_y <= vga_y + 1;
                         vga_x <= 0;
                    end
                    done = vga_y == 120; //? 1 : 0;  <-- -_- bro
               end
          end
     end

endmodule: fillscreen