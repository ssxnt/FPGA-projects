// module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
//             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
//             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
//             output logic [9:0] LEDR);

//     logic en_init, en_ksa, rdy_init, rdy_ksa, wren;
//     reg [7:0] addr, data, wren;
//     wire rst_n = KEY[3];
//     reg [7:0] data, address;
//     reg [23:0] key;
            
//     reg [1:0] state;
//     localparam idle = 0;
//     localparam writeS = 1;
//     localparam ksa = 2;
//     localparam finished = 3;

//     s_mem s(.address, .clock(CLOCK_50), .data(wrdata), .wren, .q());
//     init init(.clk(CLOCK_50), .rst_n, .en(en_init), .rdy(rdy_init), .addr(addr_init), .wrdata(wr_d_init), .wren(wr_en_init));
//     ksa KSA(.clk(CLOCK_50), .rst_n, .en(en_ksa), .rdy(rdy_ksa), .key, .addr(addr_ksa), .rddata, .wrdata(wr_d_ksa), .wren(wr_en_ksa));

//     always_comb begin
//         case (state)
//             idle: en = rdy;
//             default en = 0;
//         endcase
//     end

//     always_ff @(posedge CLOCK_50, negedge rst_n) begin
//         if (!rst_n) state = idle;
//         else begin
//             case (state)
//                 idle: state <= rdy ? writeS : idle;
//                 writeS: state <= rdy ? ksa : writeS;
//                 ksa: state <= 
//                 finished: state <= finished;
//                 default: state <= idle;
//             endcase
//         end
//     end
// endmodule: task2

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
	localparam ksa_ = 2;
	localparam finished = 7;

	assign key = {14'b0, SW};

	s_mem s(.address(addr), .clock(CLOCK_50), .data(wrdata), .wren, .q);

	init init(.clk(CLOCK_50), .rst_n, .en(en_[0]), .rdy(rdy_[0]), .addr(addr_ini), .wrdata(wr_d_ini), .wren(wr_en[0]));
	ksa  KSA( .clk(CLOCK_50), .rst_n, .en(en_[1]), .rdy(rdy_[1]), .addr(addr_ksa), .wrdata(wr_d_ksa), .wren(wr_en[1]), .key, .rddata(q));

	always_comb begin
		en_ = 0;
		case (state)
			idle: 	  begin en_[0] = rdy_[0]; addr =        0; wrdata = 	   0; wren = 	    0; end
			init_:	  begin en_[0] =       0; addr = addr_ini; wrdata = wr_d_ini; wren = wr_en[0]; end
			ksa_:	  begin en_[1] = rdy_[1]; addr = addr_ksa; wrdata = wr_d_ksa; wren = wr_en[1]; end
			finished: begin addr = 0; wrdata = 0; wren = 0; end
			default:  begin addr = 0; wrdata = 0; wren = 0; end
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		if (!rst_n) state = idle;
		else begin
			case (state)
				idle: 		state <= rdy_[0] ? init_ : idle;
				init_: 		state <= rdy_[0] ? ksa_ : init_;
				ksa_:		state <= rdy_[1] ? finished : ksa_;
				finished: 	state <= finished;
				default: 	state <= idle;
			endcase
		end
	end

endmodule: task2
