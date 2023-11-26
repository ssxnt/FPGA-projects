`timescale 1 ps / 1 ps

module tb_chipmunks();

	reg [9:0] sw, ledr;
	reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
	reg [3:0] KEY;
	reg clk, clk2, rst_n, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, FPGA_I2C_SDAT, FPGA_I2C_SCLK, AUD_DACDAT, AUD_XCK;
	assign KEY[3] = rst_n;
	assign clk2 = clk;
	assign AUD_ADCLRCK = 0;
	assign AUD_BCLK

	chipmunks DUT(.CLOCK_50(clk), .CLOCK2_50(clk2), .KEY(KEY), .SW(sw), .AUD_DACLRCK, .AUD_ADCLRCK, .AUD_BCLK, .AUD_ADCDAT,
			  .FPGA_I2C_SDAT, .FPGA_I2C_SCLK, .AUD_DACDAT, .AUD_XCK, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .LEDR(ledr));

	task reset; rst_n = 1'b0; #10; rst_n = 1'b1; endtask

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		AUD_DACLRCK = 0;
		forever #1000 AUD_DACLRCK = ~AUD_DACLRCK;
	end

	initial begin
		AUD_BCLK = 0;
		forever #100 AUD_BCLK = ~AUD_BCLK;
	end

	initial begin
		sw = 0;
		#3;
		reset;
		$display("==== START FSM TEST ====");
		#100000;
		$display("==== RESET ====");
		$display("\n==== TEST SUMMARY ====");

		$stop();
	end

endmodule: tb_chipmunks

// Any other simulation-only modules you need
module flash(input logic clk_clk, input logic reset_reset_n,
			 input logic flash_mem_write, input logic [6:0] flash_mem_burstcount,
			 output logic flash_mem_waitrequest, input logic flash_mem_read,
			 input logic [22:0] flash_mem_address, output logic [31:0] flash_mem_readdata,
			 output logic flash_mem_readdatavalid, input logic [3:0] flash_mem_byteenable,
			 input logic [31:0] flash_mem_writedata);

// Your simulation-only flash module goes here.
	reg [31:0] out = 0;
	reg [3:0] timer = 0;
	reg [2:0] state = 0;

	wire [31:0] fake_data;
	assign fake_data = {9'b0, flash_mem_address};

	localparam SETUP = 0;
	localparam READ_0 = 1;
	localparam READ_1 = 2;
	localparam READ_2 = 3;
	localparam READ_3 = 4;
	localparam READ_DONE = 5;
	localparam KILL_TIME = 6;
	localparam IDLE = 7;

	assign flash_mem_readdata = out;
	assign flash_mem_readdatavalid = state == READ_DONE;

	always_comb begin
		case (state)
			SETUP : flash_mem_waitrequest = 0;
			READ_0 : flash_mem_waitrequest = 1;
			READ_1 : flash_mem_waitrequest = 1;
			READ_2 : flash_mem_waitrequest = 1;
			READ_3 : flash_mem_waitrequest = 1;
			READ_DONE : flash_mem_waitrequest = 1;
			KILL_TIME : flash_mem_waitrequest = 1;
			IDLE : flash_mem_waitrequest = 0;
		endcase
	end

	always_ff @(posedge clk_clk) begin
		if (!reset_reset_n) begin
			state <= SETUP;
			out <= 0;
			timer <= 0;
		end else begin
			case (state)
				SETUP : begin
					if (timer < 3) begin
						state <= SETUP;
						timer <= timer + 1;
					end else begin
						state <= READ_0;
						timer <= 0;
					end					 
				end
				READ_0 : begin
					if (timer < 15) begin
						state <= READ_0;
						timer <= timer + 1;
					end else begin
						state <= READ_1;
						timer <= 0;
						out <= { out[23:0], fake_data[31:24]};
					end
				end
				READ_1 : begin
					if (timer < 7) begin
						state <= READ_1;
						timer <= timer + 1;
					end else begin
						state <= READ_2;
						timer <= 0;
						out <= { out[23:0], fake_data[23:16]};
					end
				end
				READ_2 : begin
					if (timer < 7) begin
						state <= READ_2;
						timer <= timer + 1;
					end else begin
						state <= READ_3;
						timer <= 0;
						out <= { out[23:0], fake_data[16:8]};
					end
				end
				READ_3 : begin
					if (timer < 7) begin
						state <= READ_3;
						timer <= timer + 1;
					end else begin
						state <= READ_DONE;
						timer <= 0;
						out <= { out[23:0], fake_data[7:0]};
					end
				end
				READ_DONE : begin
					state <= KILL_TIME;
				end
				KILL_TIME : begin
					if (timer < 1) begin
						state <= KILL_TIME;
						timer <= timer + 1;
					end else begin
						state <= IDLE;
						timer <= 0;
					end
				end
				IDLE : begin
					state <= flash_mem_read? READ_0 : IDLE;
				end
			endcase
		end
	end

endmodule: flash