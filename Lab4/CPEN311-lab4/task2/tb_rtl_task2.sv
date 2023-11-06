`timescale 1 ps / 1 ps

module tb_rtl_task2();

	reg clk, vgahs, vgavs, vgaclk, vgaplot, rst_n, strt;
	reg [2:0] vgacolour;
	reg [3:0] key;
	reg [6:0] vgay;
	reg [7:0] vgar, vgag, vgab, vgax;
	reg [9:0] sw, ledr;
	assign key[3] = rst_n;
	assign key[0] = strt;

	task2 dut(.CLOCK_50(clk), .KEY(key), .SW(sw), .LEDR(ledr), .VGA_R(vgar), .VGA_G(vgag), .VGA_B(vgab), .VGA_HS(vgahs),
			  .VGA_VS(vgavs), .VGA_CLK(vgaclk), .VGA_X(vgax), .VGA_Y(vgay), .VGA_COLOUR(vgacolour), .VGA_PLOT(vgaplot),
			  .HEX0(), .HEX1(), .HEX2(), .HEX3(), .HEX4(), .HEX5()); 

    task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask
	task start; strt = 1'b1; #100000; strt = 1'b0; endtask


	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		#3;
		reset;
		#10;
		start;
		#200000;
		$stop;
	end

endmodule: tb_rtl_task2
