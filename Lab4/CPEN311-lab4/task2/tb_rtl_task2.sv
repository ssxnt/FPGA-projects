module tb_rtl_task2();

    reg clk, vgahs, vgavs, vgaclk, vgaplot;
    reg [2:0] vgacolour;
    reg [3:0] key;
    reg [6:0] vgay;
    reg [7:0] vgar, vgag, vgab, vgax;
    reg [9:0] sw, ledr;

    task2 dut(.CLOCK_50(clk), .KEY(key), .SW(sw), .LEDR(ledr), .VGA_R(vgar), .VGA_G(vgag), .VGA_B(vgab), .VGA_HS(vgahs),
              .VGA_VS(vgavs), .VGA_CLK(vgaclk), .VGA_X(vgax), .VGA_Y(vgay), .VGA_COLOUR(vgacolour), .VGA_PLOT(vgaplot)); 

    initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

    initial begin
		key[3] = 1;
    #50;
    key[3] = 0;
    #50;
    key[3] = 1;
	end

endmodule: tb_rtl_task2
