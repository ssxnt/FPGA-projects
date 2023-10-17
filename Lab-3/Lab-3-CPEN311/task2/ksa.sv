module ksa(input logic clk, input logic rst_n,
			input logic en, output logic rdy,
			input logic [23:0] key,
			output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

	localparam idle = 0;
	localparam KSA = 1;

	reg [7:0] s, i, j, add, out;
	reg state = idle;

	assign addr = add;
	assign wrdata = s;

	always_comb begin
		add, s = 0;
		case (state)
			idle: 	begin	wren = 0; rdy = 1; i, j = 0; end
			KSA: 	begin 	wren = 1; rdy = 0; 
				
			end
		endcase
	end

	always_ff @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin state = idle; i, j = 0; end
		else begin
			case (state)
				idle: state <= en ? KSA : idle;
				KSA: state <= i == 255 ? idle : KSA; 
			endcase
		end
	end

endmodule: ksa
