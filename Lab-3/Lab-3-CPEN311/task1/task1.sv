module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
            output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
            output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
            output logic [9:0] LEDR);

    logic en;
    logic rdy;
    reg [7:0] addr;
    reg [7:0] wrdata;
    reg [7:0] wren;
    reg currentState = 0;

    s_mem s(.address(address), .clock(CLOCK_50), .data(data), .wren(wren), .q());
    init init(.clk(CLOCK_50), .rst_n(KEY[3]), .en(en), .rdy(rdy), .addr(addr), .wrdata(wrdata), .wren(wren));

    always_comb begin
        case (currentState)
            0: begin
                if (rdy == 1) begin
                    en = 1;
                end else begin
                    en = 0;
                end
            end

            1, 2: begin
                en = 0;
            end
        endcase
    end

    always_ff @(posedge CLOCK_50) begin
        case (currentState)
            0: begin
                if (KEY[3]) begin
                    currentState <= 0;
                end else begin
                    currentState <= 1;
                end
            end

            1: begin
                if (rdy == 1) begin
                    currentState <= 2;
                end else begin
                    currentState <= 1;
                end
            end

            2: begin
                if (rdy == 1) begin
                    currentState <= 0;
                end else begin
                    currentState <= 2;
                end
            end
        endcase
    end

endmodule: task1
