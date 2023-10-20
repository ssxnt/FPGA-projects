`timescale 1ps / 1ps

module tb_rtl_task4();

    reg [9:0] sw, ledr;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
    reg [3:0] KEY;
    reg clk, rst_n;
    assign KEY[3] = rst_n;

    task4 dut(.CLOCK_50(clk), .KEY(KEY), .SW(sw), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(ledr));

    task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
    initial begin
        #19274;
        $stop();
    end

    initial begin
        $readmemh("C:/Users/sants/Desktop/CPEN-311/Lab-3/Lab-3-CPEN311/task4/test1.memh", dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
	    #3;
        reset;
        $display("==== START FSM TEST ====");
		//$monitor("q:);

		$display("==== RESET ====");
        #1000000;
        $display("\n==== TEST SUMMARY ====");
		$stop;
        $stop();
    end

endmodule: tb_rtl_task4
