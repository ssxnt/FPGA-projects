module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    logic rdyInit, rdyKSA, rdyPRGA; // readys
    logic enInit, enKSA, enPRGA, wrenMem, wrenInit, wrenKSA, swrenPRGA; // enables
    logic [7:0] addrMem, inputDataMem, readValMem; // mem
    logic [7:0] addrInit, wrdataInit; // init
    logic [7:0] rddataKSA, addrKSA, wrdataKSA; // ksa
    logic [7:0] srddataPRGA, saddrPRGA, swrdataPRGA; // prga

    s_mem s(.address(addrMem), .clock(clk), .data(inputDataMem), .wren(wrenMem), .q(readValMem));
    init i(.clk(clk), .rst_n(rst_n), .en(enInit), .rdy(rdyInit), .addr(addrInit), .wrdata(wrdataInit), .wren(wrenInit));
    ksa k(.clk(clk), .rst_n(rst_n), .en(enKSA), .rdy(rdyKSA), .key(key), .addr(addrKSA), .rddata(rddataKSA), .wrdata(wrdataKSA), .wren(wrenKSA));
    prga p(.clk(clk), .rst_n(rst_n), .en(enPRGA), .rdy(rdyPRGA), .key(key), .s_addr(saddrPRGA), .s_rddata(srddataPRGA), .s_wrdata(swrdataPRGA), 
           .s_wren(swrenPRGA), .ct_addr(ct_addr), .ct_rddata(ct_rddata), .pt_addr(pt_addr), .pt_rddata(pt_rddata), .pt_wrdata(pt_wrdata), .pt_wren(pt_wren));

    reg [3:0] state;

    localparam idle = 0;
    localparam rdyOrNotInit = 1;
    localparam doInit = 2;
    localparam rdyOrNotKSA = 3;
    localparam doKSA = 4;
    localparam rdyOrNotPRGA = 5;
    localparam doPRGA = 6;
    localparam finished = 7;

    always_comb begin
        case (state)
            idle:          {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {0, 0, 0, 0, 0, 0, 0, 0};
            rdyOrNotInit:  {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {(rdyInit == 1) ? 1 : 0, 0, 0, 0, 0, 0, 0, 0};
            doInit:        {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {0, 0, 0, wrenInit, addrInit, wrdataInit, 0, 0};
            rdyOrNotKSA:   {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {0, (rdyKSA == 1) ? 1 : 0, 0, 0, 0, 0, 0, 0};
            doKSA:         {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {0, 0, readValMem, wrenKSA, addrKSA, wrdataKSA, 0, 0};
            rdyOrNotPRGA:  {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {0, 0, 0, 0, 0, 0, (rdyPRGA == 1) ? 1 : 0, 0};
            doPRGA:        {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {0, 0, 0, swrenPRGA, saddrPRGA, swrdataPRGA, 0, readValMem};
            finished:      {enInit, enKSA, rddataKSA, wrenMem, addrMem, inputDataMem, enPRGA, srddataPRGA} = {0, 0, 0, 0, 0, 0, 0, 0};
        endcase
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin state = idle; end
        else begin
			case (state)
                idle:           begin 
                                    state <= (en == 1) ? rdyInit : idle; 
                                    rdy <= (en == 1) ? 1 : 0; 
                                end
                rdyOrNotInit:   begin 
                                    state <= (rdyInit == 1) ? doInit : rdyInit; 
                                end
                doInit:         begin 
                                    state <= (rdyInit == 1) ? rdyKSA : doInit; 
                                end
                rdyOrNotKSA:    begin 
                                    state <= (rdyKSA == 1) ? doKSA : rdyKSA; 
                                end
                doKSA:          begin 
                                    state <= (rdyKSA == 1) ? rdyPRGA : doKSA; 
                                end
                rdyOrNotPRGA:   begin 
                                    state <= (rdyPRGA == 1) ? doPRGA : rdyPRGA; 
                                end
                doPRGA:         begin 
                                    state <= (rdyPRGA == 1) ? finished : doPRGA; 
                                end
                finished:       begin 
                                    state <= idle; rdy <= 1; 
                                end
                default:        state <= idle;
            endcase 
        end
    end

endmodule: arc4
