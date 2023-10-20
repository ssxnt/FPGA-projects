module crack(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [23:0] key, output logic key_valid,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    wire [7:0] a4_addr_pt, cpt_addr_pt, wr_data, rd_d_pt;
	reg en_a4, en_cpt, rdy_a4, rdy_cpt, ptwren;
	reg [3:0] state;
	reg [7:0] ptaddr;

	localparam idle = 0;
	localparam wt_rdy_a4 = 1;
	localparam do_a4 = 2;
	localparam wt_rdy_cpt = 3;
	localparam do_cpt = 4;
    localparam check = 5;

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem 	  pt(.address(ptaddr), .clock(clk), .data(wr_data), .wren(ptwren), .q(rd_d_pt));
    arc4      a4( .clk, .rst_n, .en(en_a4),  .rdy(rdy_a4), .pt_addr(a4_addr_pt), .pt_rddata(rd_d_pt), .pt_wrdata(wr_data), .pt_wren(ptwren), .ct_rddata,  .ct_addr, .key);
	check_pt  cpt(.clk, .rst_n, .en(en_cpt), .rdy(rdy_cpt),   .addr(cpt_addr_pt),  .rd_data(rd_d_pt), .key_valid);

	always_comb begin
		{rdy, en_a4, en_cpt, ptaddr} = 0;
		case (state)
			idle:			begin rdy = 1; end
			wt_rdy_a4: 		begin en_a4 = rdy_a4; end
			do_a4:			begin ptaddr = a4_addr_pt; end
			wt_rdy_cpt: 	begin en_cpt = rdy_cpt; end
			do_cpt:			begin ptaddr = cpt_addr_pt; end
			//check: 			begin end
		endcase
	end

	always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            key = 0;
            state = idle;
        end else begin
            case(state)
                idle: 			begin 
                                    state <= en ? wt_rdy_a4 : idle;				 			
                                end
                wt_rdy_a4:		begin
                                    state <= rdy_a4 ? do_a4 : wt_rdy_a4;
                                end
                do_a4:			begin
                                    state <= rdy_a4 ? wt_rdy_cpt : do_a4;
                                end
                wt_rdy_cpt: 	begin
                                    state <= rdy_cpt ? do_cpt : wt_rdy_cpt;
                                end
                do_cpt:			begin
                                    state <= rdy_cpt ? check : do_cpt;
                                end
                check:          begin
                                    state <= key_valid ? idle : wt_rdy_a4;
                                    key <= key + 1;
                                end
                default:			state <= idle;
            endcase
        end
	end

endmodule: crack

module check_pt(input logic clk, input logic rst_n, input logic en, 
			  input logic [7:0] rd_data, output logic [7:0] addr,
			  output logic rdy, output logic key_valid);

	reg in_range, is_valid;
	reg [2:0] state;
	reg [7:0] i, len;

	localparam idle = 0;
	localparam rd_len = 1;
	localparam ld_adr = 2;
	localparam ck_key = 3;
	localparam key_found = 4;

	assign in_range = (rd_data > 8'h1f && rd_data < 8'h7f) || state != ck_key;

	always_comb begin
		{key_valid, rdy, addr} = 0;
		case(state)
			idle: 		rdy = 1; 
			rd_len:		;
			ld_adr: 	addr = i;
			ck_key: 	;
			key_found:	begin key_valid = 1; rdy = 1; end
		endcase
	end

	always_ff @(posedge clk, negedge rst_n) begin 
		if (!rst_n) begin
			state = idle;
			i = 1;
			is_valid = 1;
		end else begin
			case(state)
				idle: begin	
					state <= en ? rd_len : idle;
					is_valid <= 1;
				end
				rd_len:	begin 
					state <= ld_adr;
					len <= rd_data;
					i <= 1;
				end
				ld_adr: 
					state <= ck_key;
				ck_key: begin
					if (is_valid && in_range) begin
						state <= i < len ? ld_adr : key_found;
						is_valid <= 1;
					end else begin
						state <= idle;
					end
					i <= i + 1;
				end
				key_found: begin
					state <= key_found;
					is_valid <= 1;
				end
				default: state <= idle;
			endcase
		end
	end

endmodule: check_pt