module doublecrack(input logic clk, input logic rst_n,
			 input logic en, output logic rdy,
			 output logic [23:0] key, output logic key_valid,
			 output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

	// your code here
	
	reg [2:0] state;
	reg [1:0] en_;
	reg stop;

	wire [23:0] key_1, key_2;
	wire [7:0] addr, ct_addr_1, ct_addr_2;
	wire [1:0] rdy_;

	assign ct_addr = ct_addr_1 | ct_addr_2;
	assign key_valid = key_valid_[0] || key_valid_[1];

	// this memory must have the length-prefixed plaintext if key_valid
	pt_mem pt(.address(addr), .clock(clk), .data, .wren, .q);

	// for this task only, you may ADD ports to crack
	crack c1(.clk, .rst_n, .en(en_[0]), .rdy(rdy_[0]), .key(key_1), .key_valid(key_valid_[0]), .ct_addr(ct_addr_1), .ct_rddata, .is_2nd(1'b0), .stop);
	crack c2(.clk, .rst_n, .en(en_[1]), .rdy(rdy_[1]), .key(key_2), .key_valid(key_valid_[1]), .ct_addr(ct_addr_2), .ct_rddata, .is_2nd(1'b1), .stop);

	always_comb begin
		{rdy, en_, stop} = 0;
		case(state)
			idle:				begin rdy = 1; end
			wait_4_crack:		begin en_[0] = rdy_[0] && rdy_[1]; end
			wait_4_dbl_crack:	begin en_[1] = rdy_[1]; end
			do_crack:			;

		endcase
	end
	
	always_ff @(posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			state = idle;
		end else begin
			case (state)
				idle: 
					state <= en ? wait_4_crack : idle;
				wait_4_crack:
					state <= rdy_[0] && rdy_[1] ? wait_4_dbl_crack : wait_4_crack;
				wait_4_dbl_crack:
					state <= do_crack;
				do_crack: begin
					if ((rdy_[0] || rdy_[1]) && key_valid) begin
						state <= copy_pt;
					end
				end
				 
				default: 
			endcase
		end
	end
	// your code here

endmodule: doublecrack
