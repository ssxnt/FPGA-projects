`timescale 1ps / 1ps

module tb_rtl_task3();

    reg [9:0] SW, LEDR;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg [3:0] KEY;
    reg clk, rst_n;
    assign KEY[3] = rst_n;

    task3 dut(.CLOCK_50(clk), .KEY(KEY), .SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5), .LEDR(LEDR));

    task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
    initial begin
        #19225
        $stop();
    end

    initial begin
	    $readmemh("C:\\Users\\admin\\Documents\\Verilog\\CPEN 311\\CPEN-311\\CPEN-311\\Lab-3\\Lab-3-CPEN311\\task3/test2.memh", dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
	    #3;
        reset;
        $display("==== START FSM TEST ====");
		$monitor("q: %8d", dut.a4.q);

		$display("==== RESET ====");
        #40000
        $display("\n==== TEST SUMMARY ====");
		$stop;
        $stop();
    end

endmodule: tb_rtl_task3
