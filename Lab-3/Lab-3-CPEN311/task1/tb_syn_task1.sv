`timescale 1ps / 1ps

module tb_syn_task1();

    reg [9:0] SW, LEDR;
    reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    reg [3:0] KEY;
    reg clk;

    task1 dut(.CLOCK_50(clk), .KEY(KEY), .SW(SW),
            .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2),
            .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5),
            .LEDR(LEDR));

    initial forever begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end

    initial begin
        #5;
        KEY[3] = 0;
        #50;
        KEY[3] = 1;
        #50;
        KEY[3] = 0;
        #10000;
    end

endmodule: tb_syn_task1