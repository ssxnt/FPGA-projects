module prga(input logic clk, input logic rst_n, input logic en, output logic rdy, input logic [23:0] key,
			output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
			output logic [7:0] ct_addr, input logic [7:0] ct_rddata, output logic [7:0] pt_addr, 
			input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

	reg [7:0] i = 0, j = 0, k = 0, i_n, j_n, shit_bucket, poopi, sti = 0, stj = 0, padk = 0, ctk = 0, msglen = 0, encrypted = 0;
	reg [3:0] state;    

	localparam idle = 0;
	localparam ld_len = 1;
	localparam rd_len = 2;
	localparam inc_i = 3;
	localparam clc_j = 4;
	localparam rd_j = 5;
	localparam wr_j = 6;
	localparam wr_i = 7;
	localparam ld_pad = 8;
	localparam wr_pad = 9;
	localparam clc_k = 10;
	localparam ld_k = 11;
	localparam xor_pt = 12;

	reg [7:0] saddr, swrdata, swren, ptaddr, ptwrdata, ptwren, ctaddr;

	assign s_addr = saddr;
	assign s_wrdata = swrdata;
	assign s_wren = swren;
	assign pt_addr = ptaddr;
	assign pt_wrdata = ptwrdata;
	assign pt_wren = ptwren;
	assign ct_addr = ctaddr;

	assign i_n = i + 1;
	assign j_n = (j + s_rddata) % 256;
	assign shit_bucket = (sti + stj) % 256;
	assign poopi = pt_rddata ^ ct_rddata;
	// always_comb begin
	// 	case(i%3)
	// 		2: j_n = (j + s_rddata + key[7:0]) % 256;
	// 		1: j_n = (j + s_rddata + key[15:8]) % 256;
	// 		0: j_n = (j + s_rddata + key[23:16]) % 256;
	// 	endcase
	// end

	always_comb begin
		{saddr, swrdata, swren, ptaddr, ptwrdata, ptwren, ctaddr, rdy} = 0;
		case (state)
			idle: 			rdy = 1; 
			ld_len: 		ctaddr = 0; 
			rd_len:;
			inc_i:    		saddr = i_n; 
			clc_j:			saddr = j_n; 
			rd_j:;
			wr_j: 	  begin saddr = j; swrdata = sti; swren = 1; end
			wr_i:     begin saddr = i; swrdata = stj; swren = 1; end 
			ld_pad:     	saddr = shit_bucket; 
			wr_pad:   begin ptaddr = k; ptwrdata = s_rddata; ptwren = 1; end
			clc_k:;
			ld_k:     begin ptaddr = k-1; ctaddr = k; end
			xor_pt:   begin ptaddr = k-1; ptwrdata = poopi; ptwren = 1; end
		endcase
	end

	always_ff @(posedge  clk, negedge rst_n) begin
		if (!rst_n) begin state = idle; end
		else begin
			case (state)
				idle:	begin 
							state <= en ? ld_len : idle; 
							{i, j, k} <= 0;
						end
				ld_len:	begin 
							state <= rd_len; 
						end
				rd_len: begin 
							state <= inc_i; 
							msglen <= ct_rddata;
						end
				inc_i:  begin 
							state <= clc_j; 
							i <= i_n; 
						end
				clc_j:  begin 
							state <= rd_j; 
							j <= j_n;
							sti <= s_rddata; 
						end
				rd_j:   begin 
							state <= wr_j;  
						end
				wr_j:   begin 
							state <= wr_i;
							stj <= s_rddata; 
						end
				wr_i:   begin 
							state <= ld_pad; 
						end
				ld_pad: begin 
							state <= wr_pad; 
						end
				wr_pad: begin 
							state <= (k < msglen) ? inc_i : clc_k;
							k <= k + 1;
						end
				clc_k:  begin 
							state <= ld_k; 
							k <= 1;
						end
				ld_k:   begin 
							state <= xor_pt;  
						end
				xor_pt: begin
							state <= (k < msglen) ? ld_k : idle;
							k <= k + 1;
						end
				default: 	state <= idle;
			endcase 
		end
	end

endmodule: prga