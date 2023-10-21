module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic [7:0] ptaddr, ptrddata, ptwrdata;
    logic [7:0] ctaddr, ctrddata, ctwrdata;
    logic ptwren, ctwren, rdy, en;

    wire rst_n = KEY[3];

    reg [23:0] key;
    assign key [23:0] = 24'h000018;
    assign ctwren = 0;
    //assign key [9:0] = SW[9:0];

    ct_mem ct(.address(ctaddr), .clock(CLOCK_50), .data(ctwrdata), .wren(ctwren), .q(ctrddata));
    pt_mem pt(.address(ptaddr), .clock(CLOCK_50), .data(ptwrdata), .wren(ptwren), .q(ptrddata));
    arc4 a4(.clk(CLOCK_50), .rst_n(rst_n), .en(en), .rdy(rdy), .key(key), .ct_addr(ctaddr), .ct_rddata(ctrddata), .pt_addr(ptaddr), .pt_rddata(ptrddata), .pt_wrdata(ptwrdata), .pt_wren(ptwren));

    reg [1:0] state;

    localparam idle = 0;
    localparam rdyOrNot = 1;
    localparam decrypt = 2;

    always_comb begin
        case (state)
            idle:       en = 0;
            rdyOrNot:   en = rdy;
            decrypt:    en = 0; 
        endcase
    end

    always_ff @(posedge CLOCK_50, negedge rst_n) begin
        case (state)
            idle:     state <= !rst_n ? rdyOrNot: idle; 
            rdyOrNot: state <= rdy ? decrypt : rdyOrNot; 
            decrypt:  state <= rdy ? idle : decrypt; 
            default:  state <= idle;
        endcase
    end

endmodule: task3