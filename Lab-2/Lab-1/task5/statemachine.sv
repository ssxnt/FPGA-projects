module statemachine(input slow_clock, input resetb,
                    input [3:0] dscore, input [3:0] pscore, input [3:0] pcard3,
                    output load_pcard1, output load_pcard2,output load_pcard3,
                    output load_dcard1, output load_dcard2, output load_dcard3,
                    output player_win_light, output dealer_win_light);

// The code describing your state machine will go here.  Remember that
// a state machine consists of next state logic, output logic, and the 
// registers that hold the state.  You will want to review your notes from
// CPEN 211 or equivalent if you have forgotten how to write a state machine.
	wire [2:0] step;
	reg [2:0] load;

    // ctrl signals load_pcard1-3 load_dcard1-3
	assign load_pcard1 = load[0];
	assign load_pcard2 = load[1];
	assign load_pcard3 = load[2];
	assign load_dcard1 = load[3];
	assign load_dcard2 = load[4];
	assign load_dcard3 = load[5];

	// states
	parameter DEAL_CARDS 	= d'0; // deal two cards each
	parameter CHECK_SCORE 	= d'1;

	always_comb begin
		case (state)
			DEAL_CARDS : begin
				case (step)
					2'd0 : 		{waiting, load} = 1<<0;
					2'd1 : 		{waiting, load} = 1<<3;
					2'd2 : 		{waiting, load} = 1<<1;
					default : 	{waiting, load} = 1<<4 || 1<<6;
				endcase
				state = waiting ? CHECK_SCORE : DEAL_CARDS;
			end
			CHECK_SCORE : begin
				if (dscore > 4'd7 || pscore > 4'd7) begin
					// state = GAME_OVER;
					{waiting, load} = 1<<6;
				end
				else if (pscore < 4'd6) begin
					case (step)
						2'd0 :	{waiting, load} = 1<<2;
						default : begin
							case (dscore)
								4'd7 : load = 0;
								4'd6 : load = pcard3 > 5 && pcard3 < 8 ? 1<<5 : 0;
								4'd5 : load = pcard3 > 3 && pcard3 < 8 ? 1<<5 : 0;
								4'd4 : load = pcard3 > 1 && pcard3 < 8 ? 1<<5 : 0;
								4'd3 : load = pcard3 != 8 ? 1<<5 : 0;
								default : load = 1<<5;
							endcase
							waiting = 1'b1;
						end
					endcase
				end
				else begin
					load = dscore < 4'd6 ? 1<<5 : 0;
					waiting = 1'b1;
				end
				state = waiting ? GAME_OVER : CHECK_SCORE;
			end
			GAME_OVER : begin
				load = 0;
				player_win_light = pscore >= dscore;
				dealer_win_light = dscore >= pscore;
				waiting = 0;
			end
			default: 
		endcase
	end
	
endmodule

module step_reg(input clk, input rst_n, input waiting, output [2:0] step);
	reg [2:0] val;

	assign step = val;

	always_ff @(posedge clk) begin
		if (!rst_n) val <= 3'b111;
		else if (waiting) val <=3'b000;
		else val <= 1 + val;
	end
endmodule