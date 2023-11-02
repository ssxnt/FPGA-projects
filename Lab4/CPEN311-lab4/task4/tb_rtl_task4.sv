`timescale 1 ps / 1 ps

module tb_rtl_task4();
    logic [9:0] SW, LEDR;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
	reg [3:0] KEY;
	reg clk, rst_n, strt;

	logic [7:0] VGA_R, VGA_G, VGA_B, VGA_X;
	logic [6:0] VGA_Y;
	logic [2:0] VGA_COLOUR;
	logic VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT;

	
	assign KEY[3] = rst_n;
	assign KEY[0] = strt;
	
	task4 dut(.CLOCK_50(clk), .KEY, .SW, .LEDR, .VGA_R, .VGA_G, .VGA_B, .VGA_HS,
			  .VGA_VS, .VGA_CLK, .VGA_X, .VGA_Y, .VGA_COLOUR, .VGA_PLOT,
			  .HEX0(), .HEX1(), .HEX2(), .HEX3(), .HEX4(), .HEX5()); 

	task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask
	task start; strt = 1'b1; #1000000; strt = 1'b0; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		#3;
		reset;
		start;
		$display("==== START FSM TEST ====");
		// $monitor("x %3d y %3d", VGA_X, VGA_Y);

		$display("==== RESET ====");
		#1000000;
		$display("\n==== TEST SUMMARY ====");
		$stop;
		$stop();
	end

endmodule: tb_rtl_task4
