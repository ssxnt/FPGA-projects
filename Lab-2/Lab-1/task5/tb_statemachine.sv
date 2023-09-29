module tb_statemachine();
    reg clk, rst_n;
	reg [3:0] dscore, pscore, pcard3;
	wire p_win, d_win;
	wire [5:0] load;

	integer pass = 0;
	integer fail = 0;

    statemachine DUT(.slow_clock(clk), .resetb(rst_n),
                    .dscore, .pscore, .pcard3,
                    .load_pcard1(load[0]), .load_pcard2(load[1]), .load_pcard3(load[2]),
                    .load_dcard1(load[3]), .load_dcard2(load[4]), .load_dcard3(load[5]),
    				.player_win_light(p_win), .dealer_win_light(d_win));

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
	task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

    initial begin
		#3;
        $display("==== START FSM TEST ====");
		$display("==== RESET ====");
		reset;
		#5;
		$display("");
		$monitor("OUT: %6b", load);
		dscore = 4'd7;
		pscore = 4'd7;
		#100

        $display("\n==== TEST SUMMARY ====");
		$display("PASSED: %-d", pass);
		$display("FAILED: %-d", fail);
		$stop;
    end
						
endmodule

