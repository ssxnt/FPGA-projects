module card7seg(input [3:0] card, output[6:0] seg7);

   // your code goes here
   reg [6:0] sevSeg = 7'd0;
   assign seg7 = sevSeg;

   always_comb begin
      case(card)
         4'b0001 : sevSeg = 7'b1110111; // 1
         4'b0010 : sevSeg = 7'b1101101; // 2
         4'b0011 : sevSeg = 7'b1111001; // 3
         4'b0100 : sevSeg = 7'b0110011; // 4
         4'b0101 : sevSeg = 7'b1011011; // 5
         4'b0110 : sevSeg = 7'b1011111; // 6
         4'b0111 : sevSeg = 7'b1110000; // 7
         4'b1000 : sevSeg = 7'b1111111; // 8
         4'b1001 : sevSeg = 7'b1111011; // 9
         4'b1010 : sevSeg = 7'b1111110; // 10
         4'b1011 : sevSeg = 7'b0111100; // J
         4'b1100 : sevSeg = 7'b1110011; // Q
         4'b1101 : sevSeg = 7'b0110111; // K
         default : sevSeg = 7'b0000000; // 0, 14, 15
      endcase
   end

endmodule

