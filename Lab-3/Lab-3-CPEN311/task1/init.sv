module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

    localparam idle = 0;
    localparam incrementS = 1;
    localparam finished = 2;

    reg [7:0] s = 0;
    reg currentState = idle;

    assign addr = s;
    assign wrdata = s;

    always_comb begin
        case (currentState)
            idle: begin
                wren = 0;
            end

            incrementS: begin
                wren = 1;
            end

            finished: begin
                wren = 0;
            end
        endcase
    end

always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            currentState = idle;
        end else begin
            case (currentState)
                idle: begin
                    if (en == 1) begin
                        rdy <= 0;
                        s <= 0;
                        currentState <= incrementS;
                    end else begin
                        rdy <= 1;
                        s <= 0;
                        currentState <= idle;
                    end
                end

                incrementS: begin
                    if (s < 255) begin
                        currentState <= incrementS;
                        s <= s + 1;
                    end else begin
                        currentState <= finished;
                    end
                end

                finished: begin
                    rdy <= 1;
                    currentState <= idle;
                end
            endcase
        end
    end

endmodule: init
