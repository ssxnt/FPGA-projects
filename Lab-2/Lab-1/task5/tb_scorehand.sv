module tb_scorehand();

    // Your testbench goes here. Make sure your tests exercise the entire design
    // in the .sv file.  Note that in our tests the simulator will exit after
    // 10,000 ticks (equivalent to "initial #10000 $finish();").
    reg [3:0] tbcard1;
    reg [3:0] tbcard2;
    reg [3:0] tbcard3;
    reg [3:0] tbtotal;
    reg flag = 1'b0;
    integer correct = 0;
    integer incorrect = 0;
    integer score = 0;
    integer tbscore = 5;
    assign error = flag;

    scorehand dut(.card1(tbcard1), .card2(tbcard2), .card3(tbcard3), .total(tbtotal));

    // "d" = decimal, "x" = expected
    function getScore(input [3:0] xcard1, input [3:0] xcard2, input [3:0] xcard3);
        // integer dxcard1 = xcard1;
        // integer dxcard2 = xcard2;
        // integer dxcard3 = xcard3;
        static integer score = 0;

        if (xcard1 >= 10) begin
            xcard1 = 0;
        end
        if (xcard2 >= 10) begin
            xcard2 = 0;
        end
        if (xcard3 >= 10) begin
            xcard3 = 0;
        end

        score = (xcard1 + xcard2 + xcard3) % 10;
        $display("The score is %d.", score);
        return 2;
    endfunction

    task checkEquals(input dxscore);
        // integer dxtotal = tbtotal;

        if (dxscore !== tbtotal) begin
            flag = 1'b1;
            incorrect++;
            $display("Test failed! Expected = %d; Actual = %d", dxscore, tbtotal);
        end else begin
            correct++;
            $display("Test passed!");
        end
    endtask

    initial begin
        // (1 + 8 + 3) % 10 = 2 = 4'b0010
        tbcard1 = 4'd1;
        tbcard2 = 4'd8;
        tbcard3 = 4'd3;
        #5;
        tbscore = getScore(tbcard1, tbcard2, tbcard3);
        $display("%d", tbscore);
        $display("%d", getScore(tbcard1, tbcard2, tbcard3));

        #5;
        checkEquals(tbscore);
    end
						
endmodule