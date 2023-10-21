module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
			output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
			output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
			output logic [9:0] LEDR);

	reg [23:0] key;
	reg [7:0] addr, wrdata, addr_ksa, wr_d_ksa, addr_ini, wr_d_ini;
	reg [1:0] en_;
	reg wren;
	wire [7:0] q;
	wire [1:0] wr_en, rdy_; 
	
	wire rst_n = KEY[3];
	
			
	reg [2:0] state;
	localparam idle = 0;
	localparam init_ = 1;
	localparam ksa_w = 2;
	localparam ksa_ = 3;
	localparam finished = 7;

	assign key = 24'h00033C; //{14'b0, SW};

	s_mem s(.address(addr), .clock(CLOCK_50), .data(wrdata), .wren, .q);

	init init(.clk(CLOCK_50), .rst_n, .en(en_[0]), .rdy(rdy_[0]), .addr(addr_ini), .wrdata(wr_d_ini), .wren(wr_en[0]));
	ksa  KSA( .clk(CLOCK_50), .rst_n, .en(en_[1]), .rdy(rdy_[1]), .addr(addr_ksa), .wrdata(wr_d_ksa), .wren(wr_en[1]), .key, .rddata(q));

	always_comb begin
		en_ = 0;
		case (state)
			idle: 	  begin en_[0] = rdy_[0]; addr =        0; wrdata = 	   0; wren = 	    0; end
			init_:	  begin en_[0] =       0; addr = addr_ini; wrdata = wr_d_ini; wren = wr_en[0]; end
			ksa_w:	  begin en_[1] = rdy_[1]; addr = 		0; wrdata = 	   0; wren = 		0; end
			ksa_:	  begin en_[1] = 	   0; addr = addr_ksa; wrdata = wr_d_ksa; wren = wr_en[1]; end
			finished: begin addr = 0; wrdata = 0; wren = 0; end
			default:  begin addr = 0; wrdata = 0; wren = 0; end
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		if (!rst_n) state = idle;
		else begin
			case (state)
				idle: 		state <= rdy_[0] ? init_ : idle;
				init_: 		state <= rdy_[0] ? ksa_w : init_;
				ksa_w:		state <= ksa_;
				ksa_:		state <= rdy_[1] ? finished : ksa_;
				finished: 	state <= finished;
				default: 	state <= idle;
			endcase
		end
	end

endmodule: task2
