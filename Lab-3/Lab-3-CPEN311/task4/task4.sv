module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
			 output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
			 output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
			 output logic [9:0] LEDR);

    logic en, rdy, wren, key_valid; 
    reg [7:0] ct_rddata, ct_addr, data;
    reg [23:0] key;
    wire rst_n = KEY[3];

    assign data = 0;

    assign wren = 0;

	ct_mem   ct(.address(ct_addr), .clock(CLOCK_50), .data, .wren, .q(ct_rddata));
	crack    c(.clk(CLOCK_50), .rst_n, .en, .rdy, .key, .key_valid, .ct_addr, .ct_rddata);
	card7seg h0(.card(key[3:0]), .seg7(HEX0), .en(key_valid));
	card7seg h1(.card(key[7:4]), .seg7(HEX1), .en(key_valid));
	card7seg h2(.card(key[11:8]), .seg7(HEX2), .en(key_valid));
	card7seg h3(.card(key[15:12]), .seg7(HEX3), .en(key_valid));
	card7seg h4(.card(key[19:16]), .seg7(HEX4), .en(key_valid));
	card7seg h5(.card(key[23:20]), .seg7(HEX5), .en(key_valid));

	reg [1:0] state;

	localparam idle = 0;
	localparam wt_rdy = 1;
	localparam crack = 2;
	localparam finished = 3;

	always_comb begin
		case (state)
			idle:       en = 0;        
			wt_rdy:     en = rdy; 
			crack:      en = 0;
            finished:   en = 0;
		endcase
	end

	always_ff @(posedge CLOCK_50, negedge rst_n) begin
		case (state)
			idle: 		state <= !rst_n ? wt_rdy : idle;
			wt_rdy: 	state <= rdy ? crack : wt_rdy;
			crack: 		state <= rdy ? finished : crack;
			finished: 	state <= finished;
			default: 	state <= idle;
		endcase
	end

endmodule: task4