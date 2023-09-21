module tb_card7seg();

    // Your testbench goes here. Make sure your tests exercise the entire design
    // in the .sv file.  Note that in our tests the simulator will exit after
    // 10,000 ticks (equivalent to "initial #10000 $finish();").\

    reg [3:0] tbSW;
    reg [6:0] tbHEX0;
    reg flag = 1'b0;
    integer correct = 0;
    integer incorrect = 0;
    assign error = flag;

    card7seg dut(.SW(tbSW), .HEX0(tbHEX0));

    // "x" = expected
    task checkEquals(input xHEX00, input xHEX01, input xHEX02, input xHEX03, input xHEX04, input xHEX05, input xHEX06);
        if (xHEX00 !== tbHEX0[0] && xHEX01 !== tbHEX0[1] && xHEX02 !== tbHEX0[2] && xHEX03 !== tbHEX0[3] && xHEX04 !== tbHEX0[4] && xHEX05 !== tbHEX0[5] && xHEX06 !== tbHEX0[6]) begin
            flag = 1'b1;
            incorrect = incorrect + 1;
            $display("Test failed! Expected = %b%b%b%b%b%b%b; Actual = %b", xHEX00, xHEX01, xHEX02, xHEX03, xHEX04, xHEX05, xHEX06, tbHEX0);
        end else begin
            correct++;
                $display("Test passed!");
        end
    endtask

    // now parse inputs (SW) to test outputs (HEX0) from 0-15
    initial begin
        // 0
        tbSW = 4'b0000;
        #5;
        checkEquals(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        // A = 1
        tbSW = 4'b0001;
        #5;
        checkEquals(1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1);

         // 2
        tbSW = 4'b0010;
        #5;
        checkEquals(1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1);

         // 3
        tbSW = 4'b0011;
        #5;
        checkEquals(1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1);

         // 4
        tbSW = 4'b0100;
        #5;
        checkEquals(1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1);

         // 5
        tbSW = 4'b0101;
        #5;
        checkEquals(1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1);

         // 6
        tbSW = 4'b0110;
        #5;
        checkEquals(1'b1, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1);

         // 7
        tbSW = 4'b0111;
        #5;
        checkEquals(1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0);

         // 8
        tbSW = 4'b1000;
        #5;
        checkEquals(1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1);

         // 9
        tbSW = 4'b1001;
        #5;
        checkEquals(1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1);

         // 10
        tbSW = 4'b1010;
        #5;
        checkEquals(1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0);

         // J = 11
        tbSW = 4'b1011;
        #5;
        checkEquals(1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0);

         // Q = 12
        tbSW = 4'b1100;
        #5;
        checkEquals(1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b1, 1'b1);

         // K = 13
        tbSW = 4'b1101;
        #5;
        checkEquals(1'b0, 1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b1);

         // 14 = 0 = blank
        tbSW = 4'b1110;
        #5;
        checkEquals(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

         // 15 = 0 = blank
        tbSW = 4'b1111;
        #5;
        checkEquals(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
    end
						
endmodule