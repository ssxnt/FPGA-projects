module music(input CLOCK_50, input CLOCK2_50, input [3:0] KEY, input [9:0] SW,
			 input AUD_DACLRCK, input AUD_ADCLRCK, input AUD_BCLK, input AUD_ADCDAT,
			 input FPGA_I2C_SDAT, output FPGA_I2C_SCLK, output AUD_DACDAT, output AUD_XCK,
			 output [6:0] HEX0, output [6:0] HEX1, output [6:0] HEX2,
			 output [6:0] HEX3, output [6:0] HEX4, output [6:0] HEX5,
			 output [9:0] LEDR);
			
	// signals that are used to communicate with the audio core
	// DO NOT alter these -- we will use them to test your design

	reg read_ready, write_ready, write_s;
	reg [15:0] writedata_left, writedata_right;
	reg [15:0] readdata_left, readdata_right;	
	wire reset, read_s;

	// signals that are used to communicate with the flash core
	// DO NOT alter these -- we will use them to test your design

	reg flash_mem_read;
	reg flash_mem_waitrequest;
	reg [22:0] flash_mem_address;
	reg [31:0] flash_mem_readdata;
	reg flash_mem_readdatavalid;
	reg [3:0] flash_mem_byteenable;
	reg rst_n, clk;

	// DO NOT alter the instance names or port names below -- we will use them to test your design

	clock_generator my_clock_gen(CLOCK2_50, reset, AUD_XCK);
	audio_and_video_config cfg(CLOCK_50, reset, FPGA_I2C_SDAT, FPGA_I2C_SCLK);
	audio_codec codec(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);
	flash flash_inst(.clk_clk(clk), .reset_reset_n(rst_n), .flash_mem_write(1'b0), .flash_mem_burstcount(1'b1),
					.flash_mem_waitrequest(flash_mem_waitrequest), .flash_mem_read(flash_mem_read), .flash_mem_address(flash_mem_address),
					.flash_mem_readdata(flash_mem_readdata), .flash_mem_readdatavalid(flash_mem_readdatavalid), .flash_mem_byteenable(flash_mem_byteenable), .flash_mem_writedata());

	// your code for the rest of this task here 
	reg signed [31:0] rd_data;
	reg [22:0] fm_addr; 
	reg [2:0] state;

	assign clk = CLOCK_50;
	assign rst_n = KEY[3];
	assign flash_mem_byteenable = 4'b1111;
	assign flash_mem_address = fm_addr;

	localparam FM_START 	= 0; // wait for fm wait request
	localparam FM_READ 		= 1; // wait for read valid
	localparam WAIT_FIFO_1	= 2; // wait for FIFO
	localparam SEND_1ST_WD  = 3; // send 1st word wait for accept
	localparam WAIT_FIFO_2  = 4; // wait for FIFO
	localparam SEND_2ND_WD  = 5; // send 2nd word wait for accept
	localparam DONE			= 6; // fm empty

	// control signals
	// codec:
	//  - write_s
	// fm:
	//  - flash_mem_read
	//  - flash_mem_write
	// outputs
	//  - flash_mem_address -- ff
	//  - writedata_left
	//  - writedata_right
	
	assign read_s = 1'b0;

	always_comb begin
        {write_s, flash_mem_read, writedata_left, writedata_left} = 0;
		case (state)
			FM_START: 	    flash_mem_read = 1;
			FM_READ: 	    flash_mem_read = 1;
			WAIT_FIFO_1:    write_s = 0;
			SEND_1ST_WD: begin
				write_s = 1;
				writedata_left = rd_data[15:0] / 64;
				writedata_right = rd_data[15:0] / 64;
			end
			WAIT_FIFO_2:	write_s = 0;
			SEND_2ND_WD: begin
				write_s = 1;
				writedata_left = rd_data[31:16] / 64;
				writedata_right = rd_data[31:16] / 64;
			end
			DONE:			write_s = 0;
			default:		write_s = 0;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (!rst_n) begin
			rd_data = 0;
			fm_addr = 0;
		end else if (flash_mem_readdatavalid && (state == FM_READ)) begin
			rd_data <= flash_mem_readdata;
			fm_addr <= fm_addr + 1;
		end	else begin
			rd_data <= rd_data;
			fm_addr <= fm_addr;
		end
	end

	always_ff @(posedge clk) begin
		if (!rst_n) begin
			state <= FM_START;
		end else begin
			case (state)
				FM_START: state <= flash_mem_waitrequest ? FM_READ : FM_START;
				FM_READ: state <= flash_mem_readdatavalid ? WAIT_FIFO_1 : 
									flash_mem_waitrequest ? FM_READ : FM_START;
				WAIT_FIFO_1: state <= write_ready ? SEND_1ST_WD : WAIT_FIFO_1;
				SEND_1ST_WD: state <= !write_ready ? WAIT_FIFO_2 : SEND_1ST_WD;
				WAIT_FIFO_2: state <= write_ready ? SEND_2ND_WD : WAIT_FIFO_2;
				SEND_2ND_WD: state <= !write_ready ? DONE : SEND_2ND_WD;
				DONE: state <= fm_addr < 23'h100000 ? FM_START : DONE;
				default: state <= FM_START;
			endcase
		end
	end

endmodule: music
