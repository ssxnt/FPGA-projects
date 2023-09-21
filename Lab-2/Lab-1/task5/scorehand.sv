module scorehand(input [3:0] card1, input [3:0] card2, input [3:0] card3, output [3:0] total);

    // The code describing scorehand will go here.  Remember this is a combinational
    // block. The function is described in the handout.  Be sure to review the section
    // on representing numbers in the lecture notes.

    // total = score of the round
    reg [3:0] val1;
    reg [3:0] val2;
    reg [3:0] val3;
    reg [3:0] score;
    assign val1 = card1;
    assign val2 = card2;
    assign val3 = card3;
    assign score = total;

    always_comb begin
        if (val1 >= 4'b1010) begin
            val1 = 4'b0000;
        end
        if (val2 >= 4'b1010) begin
            val2 = 4'b0000;
        end
        if (val3 >= 4'b1010) begin
            val3 = 4'b0000;
        end
    end

    score = (val1 + val2 + val3) % 4'b1010;

endmodule

