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

    assign rst_n = KEY[3];

    fillscreen fs(.clk(CLOCK_50), .rst_n(rst_n), .colour(colour), .start(start), .done(done), .vga_x(VGA_X), .vga_y(VGA_Y), .vga_colour(VGA_COLOUR), .vga_plot(VGA_PLOT));
    vga_demo vgad(.CLOCK_50, .KEY, .SW, .VGA_R, .VGA_G, .VGA_B, .VGA_HS, .VGA_VS, .VGA_CLK, .VGA_X, .VGA_Y, .VGA_COLOUR, .VGA_PLOT);

    always_ff @(posedge CLOCK_50, negedge rst_n) begin
        start <= !rst_n;
        start <= !done;
    end

endmodule: task2