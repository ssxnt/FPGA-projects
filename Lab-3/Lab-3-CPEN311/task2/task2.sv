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

	logic en;
	logic rdy;
	reg [7:0] addr;
	reg [7:0] wrdata;
	reg [7:0] wren;
	wire rst_n = KEY[3];
			
	reg [1:0] state;
	localparam idle = 0;
	localparam writeS = 1;
	localparam finished = 2;

	s_mem s(.address(addr), .clock(CLOCK_50), .data(wrdata), .wren, .q());
	init init(.clk(CLOCK_50), .rst_n, .en, .rdy, .addr, .wrdata, .wren);

	always_comb begin
		case (state)
			idle: en = rdy;
			default en = 0;
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		if (!rst_n) state = idle;
		else begin
			case (state)
				idle: state <= rdy ? writeS : idle;
				writeS: state <= rdy ? finished : writeS;
				finished: state <= finished;
				default: state <= idle;
			endcase
		end
	end

endmodule: task2
