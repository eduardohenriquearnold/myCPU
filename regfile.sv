module regFile #(parameter wordLen, addrLen) 
(input logic  clk, wen,
 input logic  [addrLen-1:0] addr1, addr2, addrW,
 input logic  [wordLen-1:0] dataW,
 output logic [wordLen-1:0] data1, data2);

        logic [wordLen-1:0] data [2**addrLen-1:0];

        always_ff @(posedge clk)
        begin
                if (wen)
                        data[addrW] <= dataW;                        
        end
        
        assign data1 = data[addr1];
        assign data2 = data[addr2];
endmodule
