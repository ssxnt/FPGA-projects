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

    // "x" = expected
    task checkScore()
    endtask

    tbcard1 = 4'b
						
endmodule

