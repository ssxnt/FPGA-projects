module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

    localparam idle = 0;
    localparam incrementS = 1;

    reg [7:0] s = 0;
    reg state = idle;

    assign addr = s;
    assign wrdata = s;

    always_comb begin
        case (state)
            idle: 		begin	wren = 0; rdy = 1; end
            incrementS: begin 	wren = 1; rdy = 0; end
        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state = idle;
		else begin
            case (state)
                idle: state <= en ? incrementS : idle;
                incrementS: begin
                    if (s < 255) begin
                        state <= incrementS;
                        s <= s + 1;
                    end else begin
                        state <= idle;
                    end
				end
            endcase
        end
    end

endmodule: init