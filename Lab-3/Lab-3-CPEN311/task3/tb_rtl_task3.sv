`timescale 1ps / 1ps

module tb_rtl_task3();

    reg [9:0] SW, LEDR;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg [3:0] KEY;
    reg clk;

    task3 dut(.CLOCK_50(clk), .KEY(KEY), .SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(LEDR));

    initial forever begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end

    initial begin

	    $readmemh("C:/Users/sants/Desktop/CPEN-311/Lab-3/Lab-3-CPEN311/task3/test1.memh", dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
	    #1000;
        #5;
        KEY[3] = 0;
        #50;
        KEY[3] = 1;
        #10000;
	$stop();
    end

endmodule: tb_rtl_task3
