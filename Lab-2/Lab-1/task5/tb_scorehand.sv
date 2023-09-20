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
    assign error = flag;

    scorehand dut(.card1(tbcard1), .card2(tbcard2), .card3(tbcard3), .total(tbtotal));

    // "d" = decimal, "x" = expected
    task checkScore(input [3:0] xcard1, input [3:0] xcard2, input [3:0] xcard3);
        integer dxcard1 = xcard1;
        integer dxcard2 = xcard2;
        integer dxcard3 = xcard3;

        if (dxcard1 >= 10)
    endtask

    task checkEquals();
    endtask

    // (1 + 8 + 3) % 10 = 2 = 4'b0010
    tbcard1 = 4'b0001;
    tbcard2 = 4'b1000;
    tbcard3 = 4'b0011;
    #5;
    checkScore(tbcard1, tbcard2, tbcard3);
						
endmodule

