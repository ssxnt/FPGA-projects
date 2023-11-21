module flash_reader(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
                    output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
                    output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
                    output logic [9:0] LEDR);

    // You may use the SW/HEX/LEDR ports for debugging. DO NOT delete or rename any ports or signals.

    logic clk, rst_n;

    assign clk = CLOCK_50;
    assign rst_n = KEY[3];

    logic flash_mem_read, flash_mem_waitrequest, flash_mem_readdatavalid;
    logic [22:0] flash_mem_address;
    logic [31:0] flash_mem_readdata;
    logic [3:0] flash_mem_byteenable;

	logic wren;
	logic [7:0] s_addr;
	logic [15:0] s_wr_data, s_rd_data;

    flash flash_inst(.clk_clk(clk), .reset_reset_n(rst_n), .flash_mem_write(1'b0), .flash_mem_burstcount(1'b1),
                     .flash_mem_waitrequest(flash_mem_waitrequest), .flash_mem_read(flash_mem_read), .flash_mem_address(flash_mem_address),
                     .flash_mem_readdata(flash_mem_readdata), .flash_mem_readdatavalid(flash_mem_readdatavalid), .flash_mem_byteenable(flash_mem_byteenable), .flash_mem_writedata());

    s_mem samples(.address(s_addr), .clock(clk), .data(s_wr_data), .wren(wren), .q(s_rd_data));

    assign flash_mem_byteenable = 4'b1111;

    // the rest of your code goes here.  don't forget to instantiate the on-chip memory

    reg [2:0] state;
	reg [15:0] buffer;

	localparam START = 0;		// waits for flash_mem_waitrequest
	localparam WAIT_FOR_FM = 1; // waits for flash_mem_readdatavalid
	localparam WR_1ST_WORD = 2; // writes first word
	localparam WR_2ND_WORD = 3; // writes sencond word
	localparam DONE = 4;		// s_addr reaches 255

	always_comb begin
		case (state)
			START : begin
				wren = 0;
				s_wr_data = 0;
				flash_mem_read = 1;
			end
			WAIT_FOR_FM : begin
				wren = 0;
				s_wr_data = 0;
				flash_mem_read = 1;
			end
			WR_1ST_WORD : begin
				wren = 1;
				s_wr_data = flash_mem_readdata[15:0];
				flash_mem_read = 1;
			end
			WR_2ND_WORD : begin
				wren = 1;
				s_wr_data = flash_mem_readdata[31:16];
				flash_mem_read = 0;
			end
			DONE : begin
				wren = 0;
				s_wr_data = 0;
				flash_mem_read = 0;
			end
			default : begin
				wren = 0;
				s_wr_data = 0;
				flash_mem_read = 0;
			end
		endcase
	end

	
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state <= START;
			s_addr <= 0;
			flash_mem_address <= 0;
		end else begin
			case(state)
				START : 		state <= flash_mem_waitrequest ? WAIT_FOR_FM : START;
				WAIT_FOR_FM : 	state <= flash_mem_readdatavalid ? WR_1ST_WORD : 
										 flash_mem_waitrequest ? WAIT_FOR_FM : START;
				WR_1ST_WORD : begin
					state <= WR_2ND_WORD;
					s_addr <= s_addr + 1;
				end
				WR_2ND_WORD : begin
					state <= s_addr < 255 ? START : DONE;
					s_addr <= s_addr + 1;
					flash_mem_address <= flash_mem_address + 1;
				end
				DONE : state <= DONE;
				default : state <= START;
			endcase
		end
		
	end
	/* 
	wire [39:0] data;
				//  3b  +  1b  +          1b         +  1b  +          1b           +  1b  +       32b        = 40b
	assign data = {state, 1'b0, flash_mem_waitrequest, 1'b0, flash_mem_readdatavalid, 1'b0, flash_mem_readdata};

	wave log_(.clk, .rst_n, .data);
	*/
endmodule: flash_reader

module wave(input logic clk, input logic rst_n, input logic [39:0] data);
	reg [9:0] addr;
	reg wren;

	wv_mem log(.address(addr), .clock(clk), .data(data), .wren(wren), .q());

	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			addr <= 0;
			wren <= 0;
		end else begin
			addr <= addr < 10'b1111111111 ? addr + 1 : addr;
			wren <= addr < 10'b1111111111;
		end
	end

endmodule: wave