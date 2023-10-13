module scorehand(input [3:0] card1, input [3:0] card2, input [3:0] card3, output [3:0] total);

    // The code describing scorehand will go here.  Remember this is a combinational
    // block. The function is described in the handout.  Be sure to review the section
    // on representing numbers in the lecture notes.

    // total = score of the round
    reg [3:0] val1;
    reg [3:0] val2;
    reg [3:0] val3;
    
    always_comb begin
		val1 = card1 > 4'd9 ? 4'b0 : card1;
		val2 = card2 > 4'd9 ? 4'b0 : card2;
		val3 = card3 > 4'd9 ? 4'b0 : card3;
    end

    assign total = (val1 + val2 + val3) % 4'd10;

endmodule