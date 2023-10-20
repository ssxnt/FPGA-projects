module card7seg(input [3:0] card, output[6:0] seg7, input en);

   	reg [6:0] sevSeg = 7'd0;
   	assign seg7 = sevSeg;

   	always_comb begin
         if (!en) begin
            sevSeg = ~(7'b0);
         end else begin
            case(card)              // 6543210
               4'b0001 : sevSeg = ~(7'b0000110); // 1
               4'b0010 : sevSeg = ~(7'b1011011); // 2
               4'b0011 : sevSeg = ~(7'b1001111); // 3
               4'b0100 : sevSeg = ~(7'b1100110); // 4
               4'b0101 : sevSeg = ~(7'b1101101); // 5
               4'b0110 : sevSeg = ~(7'b1111101); // 6
               4'b0111 : sevSeg = ~(7'b0000111); // 7
               4'b1000 : sevSeg = ~(7'b1111111); // 8
               4'b1001 : sevSeg = ~(7'b1101111); // 9
               4'b1010 : sevSeg = ~(7'b0110111); // A
               4'b1011 : sevSeg = ~(7'b1111100); // b
               4'b1100 : sevSeg = ~(7'b0111001); // C
               4'b1101 : sevSeg = ~(7'b1011110); // d
               4'b1110 : sevSeg = ~(7'b1111001); // E
               4'b1111 : sevSeg = ~(7'b1110001); // F
               default : sevSeg = ~(7'b0000000); // 0
            endcase
         end
   	end

endmodule

