module statemachine(input slow_clock, input resetb,
                    input [3:0] dscore, input [3:0] pscore, input [3:0] pcard3,
                    output load_pcard1, output load_pcard2,output load_pcard3,
                    output load_dcard1, output load_dcard2, output load_dcard3,
                    output player_win_light, output dealer_win_light);

// The code describing your state machine will go here.  Remember that
// a state machine consists of next state logic, output logic, and the 
// registers that hold the state.  You will want to review your notes from
// CPEN 211 or equivalent if you have forgotten how to write a state machine.
	wire [1:0] step;
	wire [1:0] state;
	reg [5:0] load;
	reg [1:0] n_state;
	reg waiting, p_win, d_win;

    // ctrl signals load_pcard1-3 load_dcard1-3
	assign load_pcard1 = load[0];
	assign load_pcard2 = load[1];
	assign load_pcard3 = load[2];
	assign load_dcard1 = load[3];
	assign load_dcard2 = load[4];
	assign load_dcard3 = load[5];
	assign player_win_light = p_win;
	assign dealer_win_light = d_win;

	// states
	parameter DEAL_CARDS 	= 2'd0; // deal two cards each
	parameter CHECK_SCORE 	= 2'd1;
	parameter GAME_OVER		= 2'd2;

	always_comb begin
		case (state)
			DEAL_CARDS : begin
				case (step)
					2'd0 : 		{waiting, load} = 1<<0;
					2'd1 : 		{waiting, load} = 1<<3;
					2'd2 :		{waiting, load} = 1<<1;
					default : 	{waiting, load} = 1<<4 | 1<<6;
				endcase
				n_state = waiting ? CHECK_SCORE : DEAL_CARDS;
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
				n_state = waiting ? GAME_OVER : CHECK_SCORE;
			end
			GAME_OVER : begin
				load = 0;
				p_win = pscore >= dscore;
				d_win = dscore >= pscore;
				waiting = 0;
			end
			default: begin
				load = 0;
				waiting = 1;
				n_state = DEAL_CARDS;
			end
		endcase
	end
	
	step_reg STP(.clk(slow_clock), .rst_n(resetb), .waiting, .step);
	state_reg STT(.clk(slow_clock), .rst_n(resetb), .n_state, .state);
endmodule

module step_reg(input clk, input rst_n, input waiting, output [1:0] step);
	reg [1:0] val;

	assign step = val;

	always_ff @(posedge clk) val <= !rst_n || waiting ? 2'b000 : 1 + val;
endmodule

module state_reg(input clk, input rst_n, input [1:0] n_state, output [1:0] state);
	reg [1:0] val;

	assign state = val;

	always_ff @(posedge clk) val <= rst_n ? n_state : 0;
endmodule