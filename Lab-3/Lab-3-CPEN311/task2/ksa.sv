module ksa(input logic clk, input logic rst_n,
			input logic en, output logic rdy,
			input logic [23:0] key,
			output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

	localparam idle = 0;
	localparam load = 1;
	localparam calc = 2;
	localparam wr_j = 3;
	localparam wr_i = 4;

	reg [7:0] sti, stj, s, i, j, add;
	reg [2:0] state = idle;
	reg [7:0] key_byte[3];
	assign key_byte[2] = key[7:0];
	assign key_byte[1] = key[15:8];
	assign key_byte[0] = key[23:16];


	assign addr = add;
	assign wrdata = s;

	always_comb begin
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
				idle: begin state <= en ? load : idle;
					j <= 0;
					i <= 0;
				end
				ld_i: 		state <= calc;
				calc: begin state <= wr_j;
					j <= (j + rddata + key_byte[i % 3]) % 256;
					sti <= rddata;
				end 
				ld_j: 		state <= wr_j;
				wr_j:		state <= wr_i;
				wr_i: begin state <= i < 255 ? ld_i : idle;
					i <= i + 1;
				end
				default: state <= idle;					
			endcase
		end
	end

endmodule: ksa
