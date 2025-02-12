`timescale 1ps / 1ps

module tb_rtl_task5();

    reg [9:0] sw, ledr;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
    reg [3:0] KEY;
    reg clk, rst_n;
    assign KEY[3] = rst_n;

    task5 dut(.CLOCK_50(clk), .KEY(KEY), .SW(sw), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(ledr));

    task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
    initial begin
        #38065;
        $stop();
    end
    initial begin
        #55815;
        $stop();
    end
    initial begin
        #73565;
        $stop();
    end

    initial begin
        $readmemh("C:\\Users\\Administrator\\Documents\\Verilog\\311\\CPEN-311\\Lab-3\\Lab-3-CPEN311\\task3\\test2.memh", dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
        //$readmemh("C:\\Users\\Administrator\\Documents\\Verilog\\311\\CPEN-311\\Lab-3\\Lab-3-CPEN311\\task3\\test2.memh", dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);

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

endmodule: tb_rtl_task5

