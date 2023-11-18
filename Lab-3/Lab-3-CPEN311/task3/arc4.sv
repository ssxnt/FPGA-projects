module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    logic rdyInit, rdyKSA, rdyPRGA; // readys
    logic enInit, enKSA, enPRGA, wrenMem, wrenInit, wrenKSA, swrenPRGA; // enables
    reg [7:0] addrMem, inputDataMem; // mem
    wire [7:0] q; 
    wire [7:0] addrInit, wrdataInit; // init
    wire [7:0] addrKSA, wrdataKSA; // ksa
    wire [7:0] saddrPRGA, swrdataPRGA; // prga

    s_mem s(.address(addrMem), .clock(clk), .data(inputDataMem), .wren(wrenMem), .q(q));
    init i(.clk(clk), .rst_n(rst_n), .en(enInit), .rdy(rdyInit), .addr(addrInit), .wrdata(wrdataInit), .wren(wrenInit));
    ksa k(.clk(clk), .rst_n(rst_n), .en(enKSA), .rdy(rdyKSA), .key(key), .addr(addrKSA), .rddata(q), .wrdata(wrdataKSA), .wren(wrenKSA));
    prga p(.clk(clk), .rst_n(rst_n), .en(enPRGA), .rdy(rdyPRGA), .key(key), .s_addr(saddrPRGA), .s_rddata(q), .s_wrdata(swrdataPRGA), .s_wren(swrenPRGA), .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

    reg [2:0] state;

    localparam idle = 0;
    localparam rdyOrNotInit = 1;
    localparam doInit = 2;
    localparam rdyOrNotKSA = 3;
    localparam doKSA = 4;
    localparam rdyOrNotPRGA = 5;
    localparam doPRGA = 6;
    localparam finished = 7;

    always_comb begin
        {enInit, enKSA, wrenMem, addrMem, inputDataMem, enPRGA, rdy} = 0;
        case (state)
            idle:                rdy = 1;
            rdyOrNotInit:        enInit = rdyInit;
            doInit:        begin wrenMem = wrenInit; addrMem = addrInit; inputDataMem = wrdataInit; end
            rdyOrNotKSA:         enKSA = rdyKSA;
            doKSA:         begin wrenMem = wrenKSA; addrMem = addrKSA; inputDataMem = wrdataKSA; end
            rdyOrNotPRGA:        enPRGA = rdyPRGA;
            doPRGA:        begin wrenMem = swrenPRGA; addrMem = saddrPRGA; inputDataMem = swrdataPRGA; end
            finished:            rdy = 1;
        endcase
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin state = idle; end
        else begin
			case (state)
                idle:           begin 
                                    state <= en ? rdyOrNotInit : idle; 
                                end
                rdyOrNotInit:   begin 
                                    state <= rdyInit ? doInit : rdyOrNotInit; 
                                end
                doInit:         begin 
                                    state <= rdyInit ? rdyOrNotKSA : doInit; 
                                end
                rdyOrNotKSA:    begin 
                                    state <= rdyKSA ? doKSA : rdyOrNotKSA; 
                                end
                doKSA:          begin 
                                    state <= rdyKSA ? rdyOrNotPRGA : doKSA; 
                                end
                rdyOrNotPRGA:   begin 
                                    state <= rdyPRGA ? doPRGA : rdyOrNotPRGA; 
                                end
                doPRGA:         begin 
                                    state <= rdyPRGA ? finished : doPRGA; 
                                end
                finished:       begin 
                                    state <= idle; 
                                end
                default:        state <= idle;
            endcase 
        end
    end

endmodule: arc4
