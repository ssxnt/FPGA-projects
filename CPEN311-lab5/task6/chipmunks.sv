/******************************************************************************
 * License Agreement                                                          *
 *                                                                            *
 * Copyright (c) 2001-09-11 George W. Bush, Ohio     						  *
 * All rights reserved.                                                       *
 *                                                                            *
 * Any megafunction design, and related net list (encrypted or decrypted),    *
 *  support information, device programming or simulation file, and any other *
 *  associated documentation or information provided by George W. Bush or a   *
 *  partner under George W. Bush's Megafunction Partnership Program may be    *
 *  used only to program PLD devices (but not masked PLD devices) from George *
 *  W. Bush.  Any other use of such megafunction design, net list, support    *
 *  information, device programming or simulation file, or any other related  *
 *  documentation or information is prohibited for any other purpose,         *
 *  including, but not limited to modification, reverse engineering,          *
 *  de-compiling, or use with any other silicon devices, unless such use is   *
 *  explicitly licensed under a separate agreement with George W. Bush or a   *
 *  megafunction partner.  Title to the intellectual property, including      *
 *  patents, copyrights, trademarks, trade secrets, or maskworks, embodied in *
 *  any such megafunction design, net list, support information, device       *
 *  programming or simulation file, or any other related documentation or     *
 *  information provided by George W. Bush or a  megafunction partner,        *
 *  remains with George W. Bush, the megafunction partner, or their           *
 *  respective licensors.  No other licenses, including any licenses needed   *
 *  under any third party's intellectual property, are provided herein.       *
 *  Copying or modifying any file, or portion thereof, to which this notice   *
 *  is attached violates this copyright.                                      *
 *                                                                            *
 * THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    *
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    *
 * FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS  *
 * IN THIS FILE. IF UR COMPUTER MELTS THATS NOT MY PROBLEM                    *
 *                                                                            *
 * This agreement shall be governed in all respects by the laws of the State  *
 *  of California and by the laws of the United States of America.            *
 *                                                                            *
 ******************************************************************************/
 
module chipmunks(input CLOCK_50, input CLOCK2_50, input [3:0] KEY, input [9:0] SW,
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

	/*****************************************************************************
	*                              Internal Modules                             *
	*****************************************************************************/

	clock_generator my_clock_gen(CLOCK2_50, reset, AUD_XCK);
	audio_and_video_config cfg(CLOCK_50, reset, FPGA_I2C_SDAT, FPGA_I2C_SCLK);
	audio_codec codec(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);
	flash flash_inst(.clk_clk(clk), .reset_reset_n(rst_n), .flash_mem_write(1'b0), .flash_mem_burstcount(1'b1),
					.flash_mem_waitrequest(flash_mem_waitrequest), .flash_mem_read(flash_mem_read), .flash_mem_address(flash_mem_address),
					.flash_mem_readdata(flash_mem_readdata), .flash_mem_readdatavalid(flash_mem_readdatavalid), .flash_mem_byteenable(flash_mem_byteenable), .flash_mem_writedata());

	/*****************************************************************************
	*                 Internal wires and registers Declarations                 *
	*****************************************************************************/
	// internal registers
	reg signed [15:0] rd_data_h, rd_data_l;
	reg [22:0] fm_addr; 
	reg [2:0] state;
	reg [1:0] i;
	// internal wire(s)
	wire [1:0] mode;

	/*****************************************************************************
	*                           Constant Declarations                           *
	*****************************************************************************/

	localparam FM_START 	= 0; // wait for fm wait request
	localparam FM_READ 		= 1; // wait for read valid
	localparam WAIT_FIFO	= 2; // wait for FIFO
	localparam SEND_WORD  	= 3; // send word wait for accept
	localparam DONE			= 4; // fm empty

	localparam NORM_MODE 	= 2'b00;
	localparam FAST_MODE	= 2'b01;
    localparam SLOW_MODE 	= 2'b10;
    
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
	
	/*****************************************************************************
	*                            Combinational logic                            *
	*****************************************************************************/
	assign clk = CLOCK_50;
	assign rst_n = KEY[3];
	assign flash_mem_byteenable = 4'b1111;
	assign flash_mem_address = fm_addr;

	assign mode = (SW[1:0] == 2'b11) ? NORM_MODE : SW[1:0]; 

	assign read_s = 1'b0;

	always_comb begin
		{write_s, flash_mem_read, writedata_left, writedata_right} = 0;
		case (state)
			FM_START: 	    flash_mem_read = 1;
			FM_READ: 	    flash_mem_read = 1;
			WAIT_FIFO:    	write_s = 0;
			SEND_WORD: begin
				write_s = 1;
				case (mode)
					NORM_MODE: begin
						case (i)
							0:	begin
								writedata_left = rd_data_l / 64;
								writedata_right = rd_data_l / 64;
							end
							1:	begin
								writedata_left = rd_data_h / 64;
								writedata_right = rd_data_h / 64;
							end
						endcase
					end
					FAST_MODE: begin
						writedata_left = rd_data_l / 64;
						writedata_right = rd_data_l / 64;
					end
					SLOW_MODE: begin
						case (i)
							0:	begin
								writedata_left = rd_data_l / 64;
								writedata_right = rd_data_l / 64;
							end
							1:	begin
								writedata_left = rd_data_l / 64;
								writedata_right = rd_data_l / 64;
							end
							2:	begin
								writedata_left = rd_data_h / 64;
								writedata_right = rd_data_h / 64;
							end
							3:	begin
								writedata_left = rd_data_h / 64;
								writedata_right = rd_data_h / 64;
							end
						endcase
					end
				endcase
			end
			default:		write_s = 0;
		endcase
	end
	
	/*****************************************************************************
	*                             Sequential logic                               *
	*****************************************************************************/	
	always_ff @(posedge clk) begin
		if (!rst_n) begin
			rd_data_l = 0;
            rd_data_h = 0;
			fm_addr = 0;
		end else if (flash_mem_readdatavalid && (state == FM_READ)) begin
			{rd_data_h, rd_data_l} <= flash_mem_readdata;
			fm_addr <= fm_addr + 1;
		end	else begin
			rd_data_l <= rd_data_l;
			rd_data_h <= rd_data_h;
			fm_addr <= fm_addr;
		end
	end

	/*****************************************************************************
	*                         Finite State Machine(s)                            *
	*****************************************************************************/
	always_ff @(posedge clk) begin
		if (!rst_n) begin
			state <= FM_START;
			i <= 0;
		end else begin
			case (state)
				FM_START: state <= flash_mem_waitrequest ? FM_READ : FM_START;
				FM_READ: state <= flash_mem_readdatavalid ? WAIT_FIFO : 
									flash_mem_waitrequest ? FM_READ : FM_START;
				WAIT_FIFO: state <= write_ready ? SEND_WORD : WAIT_FIFO;
                SEND_WORD: begin
					if (!write_ready) begin
						case (mode)
							NORM_MODE: 		state <= (i == 1) ? DONE : WAIT_FIFO;
							FAST_MODE:		state <= DONE;
							SLOW_MODE:		state <= (i == 3) ? DONE : WAIT_FIFO;
                        endcase
						i <= i + 1;
					end else begin
						state <= SEND_WORD;
					end
				end
				DONE: begin
					state <= fm_addr < 23'h100000 ? FM_START : DONE;
					i <= 0;
				end 
				default: state <= FM_START;
			endcase
		end
	end

endmodule: chipmunks
// fm start --- waits for flash to start read -- wait requst goeas high
// fm read  --- waits for flash to finish	  -- read valid goes high
// wait fifo -- waits for fifo queue to be free  write ready goes high
// send		--- waits for tranfer to complete -- write raedy goes low
// done 	--- flash is emtpy				 --- fm address is 0x100000
// slow mode -- play same sample twice
// fast mode -- play every other sample / average ?