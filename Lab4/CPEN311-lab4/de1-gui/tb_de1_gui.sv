`timescale 1ps / 1ps

module tb_de1_gui();
    logic CLK;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [9:0] LEDR;
    logic [6:0] HEX0;
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4;
    logic [6:0] HEX5;

    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire [7:0] VGA_X;
    wire [6:0] VGA_Y;
    wire [2:0] VGA_COLOUR;
    wire VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT;

    de1_gui gui(.SW, .KEY, .LEDR, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    button_pusher dut(.CLK, .SW, .KEY, .LEDR, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    vga_demo demo(.CLOCK_50(CLK), .KEY, .SW, .VGA_R, .VGA_G, .VGA_B, .VGA_HS, .VGA_VS, .VGA_CLK, .VGA_X, .VGA_Y, .VGA_COLOUR, .VGA_PLOT);

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
endmodule
