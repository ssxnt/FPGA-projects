module ksa(input logic clk, input logic rst_n,
			input logic en, output logic rdy,
			input logic [23:0] key,
			output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

	localparam idle = 0;
	localparam ld_i = 1;
	localparam calc = 2;
	localparam ld_j = 3;
	localparam wr_j = 4;
	localparam wr_i = 5;

	reg [7:0] sti, stj, s, i, j, add;
	reg [2:0] state = idle;
	reg [7:0] key_byte[3];
	reg [7:0] temp;
	assign key_byte[0] = key[7:0];
	assign key_byte[1] = key[15:8];
	assign key_byte[2] = key[23:16];

	assign addr = add;
	assign wrdata = s;

	always_comb begin
		temp = i % 3;
		{add, s, rdy} = 0;
		case (state)
			idle: 	begin wren = 0; rdy = 1; end
			ld_i: 	begin wren = 0; add = i; end
			calc:	begin wren = 0; end
			ld_j:	begin wren = 0; add = j; end
			wr_j:	begin wren = 1; add = j; s = sti; end
			wr_i:	begin wren = 1; add = i; s = stj; end
			default:begin wren = 0; rdy = 1; end
		endcase
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin state = idle; {i, j} = 0; end
		else begin
			case (state)
				idle: begin state <= en ? ld_i : idle;
					j <= 0;
					i <= 0;
				end
				ld_i: 		state <= calc;
				calc: begin state <= ld_j;
					case(temp)
						2: j <= (j + rddata + key[7:0]) % 256;
						1: j <= (j + rddata + key[15:8]) % 256;
						0: j <= (j + rddata + key[23:16]) % 256;
					endcase
					sti <= rddata;
				end 
				ld_j: 		state <= wr_j;
				wr_j: begin state <= wr_i;
					stj <= rddata;
				end
				wr_i: begin state <= i < 255 ? ld_i : idle;
					i <= i + 1;
				end
				default: state <= idle;					
			endcase
		end
	end

endmodule: ksa
