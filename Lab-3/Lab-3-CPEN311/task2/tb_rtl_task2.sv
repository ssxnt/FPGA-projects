`timescale 1 ps / 1 ps

module tb_rtl_task2();

    reg clk, rst_n;
    reg [3:0] KEY;
    reg [9:0] SW = 2'haa;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    wire [9:0] LEDR;

    assign KEY[3] = rst_n;

    task2 dut(.CLOCK_50(clk), .KEY, .SW, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR);

    task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

    initial begin
        $readmemh("C:/Users/sants/Desktop/CPEN-311/Lab-3", dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data);
		#3;
        reset;
        $display("==== START FSM TEST ====");
		$monitor("q: %8d", dut.wrdata);

		$display("==== RESET ====");
        #9000
        $display("\n==== TEST SUMMARY ====");
		$stop;
    end


endmodule: tb_rtl_task2
