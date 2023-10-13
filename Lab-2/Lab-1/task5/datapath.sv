module datapath(input slow_clock, input fast_clock, input resetb,
                input load_pcard1, input load_pcard2, input load_pcard3,
                input load_dcard1, input load_dcard2, input load_dcard3,
                output [3:0] pcard3_out,
                output [3:0] pscore_out, output [3:0] dscore_out,
                output[6:0] HEX5, output[6:0] HEX4, output[6:0] HEX3,
                output[6:0] HEX2, output[6:0] HEX1, output[6:0] HEX0);
						
// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
//
// Follow the block diagram in the Lab 1 handout closely as you write this code.
	wire [3:0] new_card, pcard1_out, pcard2_out, dcard1_out, dcard2_out, dcard3_out;

    scorehand PHand(.card1(pcard1_out), .card2(pcard2_out), .card3(pcard3_out), .total(pscore_out));
    scorehand DHand(.card1(dcard1_out), .card2(dcard2_out), .card3(dcard3_out), .total(dscore_out));

	dealcard DLcard(.clock(fast_clock), .resetb, .new_card);

	reg4 PCard1(.in(new_card), .clk(slow_clock), .en(load_pcard1), .rst_n(resetb), .out(pcard1_out));
	reg4 PCard2(.in(new_card), .clk(slow_clock), .en(load_pcard2), .rst_n(resetb), .out(pcard2_out));
	reg4 PCard3(.in(new_card), .clk(slow_clock), .en(load_pcard3), .rst_n(resetb), .out(pcard3_out));

	reg4 DCard1(.in(new_card), .clk(slow_clock), .en(load_dcard1), .rst_n(resetb), .out(dcard1_out));
	reg4 DCard2(.in(new_card), .clk(slow_clock), .en(load_dcard2), .rst_n(resetb), .out(dcard2_out));
	reg4 DCard3(.in(new_card), .clk(slow_clock), .en(load_dcard3), .rst_n(resetb), .out(dcard3_out));

	card7seg P7seg1(.card(pcard1_out), .seg7(HEX0));
	card7seg P7seg2(.card(pcard2_out), .seg7(HEX1));
	card7seg P7seg3(.card(pcard3_out), .seg7(HEX2));

	card7seg D7seg1(.card(dcard1_out), .seg7(HEX3));
	card7seg D7seg2(.card(dcard2_out), .seg7(HEX4));
	card7seg D7seg3(.card(dcard3_out), .seg7(HEX5));
endmodule

module reg4(input [3:0] in, input clk, input en, input rst_n, output [3:0] out);
	reg [3:0] val;

	assign out = val;

	always_ff @(posedge clk) begin
		if (!rst_n)
			val <= 0;
		else if (en)
			val <= in;
	end

endmodule
