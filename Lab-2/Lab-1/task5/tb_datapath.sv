module tb_datapath();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
						
    reg s_clk, f_clk, rst_n;
	reg [5:0] load;
	wire [3:0] dscore, pscore, pcard3;
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

	integer pass = 0;
	integer fail = 0;
	int i, j;

	datapath DUT(.slow_clock(s_clk), .fast_clock(f_clk), .resetb(rst_n),
                .load_pcard1(load[0]), .load_pcard2(load[1]), .load_pcard3(load[2]),
                .load_dcard1(load[3]), .load_dcard2(load[4]), .load_dcard3(load[5]),
                .pcard3_out(pcard3),
                .pscore_out(pscore), .dscore_out(dscore),
                .HEX5, .HEX4, .HEX3,
                .HEX2, .HEX1, .HEX0);

	task reset; rst_n = 1'b0; #20; rst_n = 1'b1; endtask

	initial begin
		f_clk = 0;
		forever #2 f_clk = ~f_clk;
	end

	initial begin
		#1;
		s_clk = 0;
		forever #10 s_clk = ~s_clk;
	end

	initial begin
		$display("==== START DATAPATH TEST ====");
		$monitor("HEX0: %7b", HEX0);
		$monitor("HEX1: %7b", HEX1);
		$monitor("HEX2: %7b", HEX2);
		$monitor("HEX3: %7b", HEX3);
		$monitor("HEX4: %7b", HEX4);
		$monitor("HEX5: %7b", HEX5);


		$monitor("pscore: %4d ", pscore);
		$monitor("dscore: %4d ", dscore);
		$monitor("dscore: %4d ", pcard3);

		$display("==== RESET ====");
		#6;
		reset;
		for (i = 0; i < 10; i++) begin
			for (j = 0; j < 6; j++) begin
				$display("%d", j);
				load = 1<<j;
				#20;
			end
			$display("==== RESET ====");
			reset;
		end
		$display("\n==== TEST SUMMARY ====");
		$display("PASSED: %-d", pass);
		$display("FAILED: %-d", fail);
		$stop;
	end
endmodule

