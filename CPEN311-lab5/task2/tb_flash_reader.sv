module tb_flash_reader();

	reg [9:0] sw, ledr;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
    reg [3:0] KEY;
    reg clk, rst_n;
    assign KEY[3] = rst_n;

	flash_reader DUT(.CLOCK_50(clk), .KEY(KEY), .SW(sw),
                    .HEX0, .HEX1, .HEX2,
                    .HEX3, .HEX4, .HEX5,
                    .LEDR(ledr));

	task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		#3;
        reset;
        $display("==== START FSM TEST ====");


		$display("==== RESET ====");
        $display("\n==== TEST SUMMARY ====");

        $stop();
	end

endmodule: tb_flash_reader

module flash(input logic clk_clk, input logic reset_reset_n,
			 input logic flash_mem_write, input logic [6:0] flash_mem_burstcount,
			 output logic flash_mem_waitrequest, input logic flash_mem_read,
			 input logic [22:0] flash_mem_address, output logic [31:0] flash_mem_readdata,
			 output logic flash_mem_readdatavalid, input logic [3:0] flash_mem_byteenable,
			 input logic [31:0] flash_mem_writedata);

// Your simulation-only flash module goes here.

endmodule: flash
