module doublecrack(input logic clk, input logic rst_n,
			 input logic en, output logic rdy,
			 output logic [23:0] key, output logic key_valid,
			 output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

	// your code here
	localparam idle = 0;
	localparam wait_4_crack = 1;
	localparam wait_4_dbl_crack = 2;
	localparam do_crack = 3;
	localparam copy_pt_w = 4;
	localparam copy_pt = 5;

	reg [7:0] data, addr, q;
	reg [2:0] state;
	reg [1:0] en_, wren_;
	reg stop, wren;

	wire [23:0] key_1, key_2;
	wire [7:0] paddr1, paddr2, pdata1, pdata2, ct_addr_1, ct_addr_2;
	wire [1:0] rdy_, key_valid_;

	assign wren = wren_[0] || wren_[1];
	assign data = pdata1 | paddr2;
	assign addr = paddr1 | paddr2;
	assign ct_addr = ct_addr_1 | ct_addr_2;
	assign key_valid = key_valid_[0] || key_valid_[1];

	// this memory must have the length-prefixed plaintext if key_valid
	pt_mem pt(.address(addr), .clock(clk), .data(data), .wren(wren_), .q(q));

	// for this task only, you may ADD ports to crack
	crack c1(.clk(clk), .rst_n(rst_n), .en(en_[0]), .rdy(rdy_[0]), .key(key_1), .key_valid(key_valid_[0]), .ct_addr(ct_addr_1), .ct_rddata(ct_rddata), .is_2nd(1'b0), .stop(stop), .pt_out_addr(paddr1), .pt_out_data(pdata1), .pt_out_wren(wren_[0]));
	crack c2(.clk(clk), .rst_n(rst_n), .en(en_[1]), .rdy(rdy_[1]), .key(key_2), .key_valid(key_valid_[1]), .ct_addr(ct_addr_2), .ct_rddata(ct_rddata), .is_2nd(1'b1), .stop(stop), .pt_out_addr(paddr2), .pt_out_data(pdata2), .pt_out_wren(wren_[1]));

	always_comb begin
		{rdy, en_, stop} = 0;
		case(state)
			idle:				begin rdy = 1; end
			wait_4_crack:		begin en_[0] = rdy_[0] && rdy_[1]; end
			wait_4_dbl_crack:	begin en_[1] = rdy_[1]; end
			do_crack:			;
			copy_pt_w:			begin 
				stop = 1;
				en_[0] = rdy_[0] && key_valid_[0];
				en_[1] = rdy_[1] && key_valid_[1];
			end
			copy_pt:			begin

			end


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
						state <= copy_pt_w;
					end
				end
				copy_pt_w:
					state <= rdy_[0] && rdy_[1] ? copy_pt : copy_pt_w;
				copy_pt:
					state <= rdy_[0] && rdy_[1] ? idle : copy_pt;
				default: state <= idle;
			endcase
		end
	end
	// your code here

endmodule: doublecrack
