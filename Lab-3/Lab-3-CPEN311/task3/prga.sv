module prga(input logic clk, input logic rst_n, input logic en, output logic rdy, input logic [23:0] key,
			output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
			output logic [7:0] ct_addr, input logic [7:0] ct_rddata, output logic [7:0] pt_addr, 
			input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

	reg [7:0] i = 0, j = 0, k = 0, si = 0, sj = 0, padk = 0, ctk = 0, msglen = 0, encryptedbyte = 0;
	reg [3:0] state;    

	localparam idle = 0;
	localparam messageLength = 1;
	localparam encryptedText = 2;
	localparam incrementI = 3;
	localparam readSI = 4;
	localparam incrementJ = 5;
	localparam readSJ = 6;
	localparam si2sj = 7;
	localparam sj2si = 8;
	localparam getPadK = 9;
	localparam readPadK = 10;
	localparam writePT = 11;
	localparam incrementK = 12;

	always_comb begin
		case (state)
			idle:          {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, 0, 0, 0, 0}; 
			messageLength: {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, 0, 0, 0, 0}; 
			encryptedText: {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, 0, 0, 0, k}; 
			incrementI:    {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {i, 0, 0, 0, 0, 0, 0}; 
			readSI:        {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, 0, 0, 0, 0}; 
			incrementJ:    {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {j, 0, 0, 0, 0, 0, 0}; 
			readSJ:        {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, 0, 0, 0, 0}; 
			si2sj:         {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {j, si, 1, 0, 0, 0, 0}; 
			sj2si:         {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {i, sj, 1, 0, 0, 0, 0}; 
			getPadK:       {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {(si + sj) % 256, 0, 0, 0, 0, 0, 0}; 
			readPadK:      {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, 0, 0, 0, 0}; 
			writePT:       {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, k - 1, padk ^ encryptedbyte, 1, 0}; 
			incrementK:    {s_addr, s_wrdata, s_wren, pt_addr, pt_wrdata, pt_wren, ct_addr} = {0, 0, 0, 0, 0, 0, 0};
		endcase
	end

	always_ff @(posedge  clk, negedge rst_n) begin
		if (!rst_n) begin state = idle; end
		else begin
			case (state)
				idle:			begin state <= (en == 1) ? messageLength : idle; rdy <= (en == 1) ? 0 : 1; end
				messageLength:  begin state <= encryptedText; msglen <= ct_rddata; k <= 1; end
				encryptedText:  begin state <= incrementI; encryptedbyte <= ct_rddata; end
				incrementI:     begin state <= readSI; i <= (i + 1) % 256; end
				readSI:         begin state <= incrementJ; si <= s_rddata; end
				incrementJ:     begin state <= readSJ; j <= (j + si) % 256; end
				readSJ:         begin state <= si2sj; sj <= s_rddata; end
				si2sj:          begin state <= sj2si; end
				sj2si:          begin state <= getPadK; end
				getPadK:        begin state <= readPadK; padk <= s_rddata; end
				writePT:        begin state <= incrementK; end
				incrementK:     begin state <= (k < msglen) ? messageLength : idle; k <= (k < msglen) ? k + 1 : k; rdy <= (k < msglen) ? rdy : 1; end
				default: 		state <= idle;
			endcase 
		end
	end

endmodule: prga
