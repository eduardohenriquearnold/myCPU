/*
Byte addressable memory

Memory map:
256 KB RAM ~ 2^18 bytes
256 KB ROM ~ 2^18 bytes
  1 KB Memory-Mapped IO Reserved
  
Address range:
0000000-0003FFFF RAM
0004000-0007FFFF ROM
0008000-00080400 GP-IO
*/

module memory
(
        input logic clk, wen,
        input logic [31:0] addr,
        input logic [31:0] wdata,
        
        output logic [31:0] data
);

        //Memory Allocation
        logic [7:0] ram [0:2**18];
        logic [7:0] rom [0:2**18];
        logic [7:0]  io [0:2**10];
        
        //Get memory partition from addr
        function getPartition(logic [31:0] addr);
                if (addr <= 'h0003FFFF)
                        return 1;
                        
                if (addr >= 'h0003FFFF & addr<= 'h0003FFFF)
                        return 2;

                if (addr >= 'h0008000 & addr<= 'h00080400)
                       return 3;                        
                       
               return 0;                        
        endfunction;
        
        always_ff @ (posedge clk)
        begin
                if (wen==1)                                        
                        case(getPartition(addr))
                                1: ram[int'(addr)] = wdata;
                                2: rom[int'(addr)-2**18] = wdata;
                                3:  io[int'(addr)-2**19] = wdata;
                        endcase
        end
        
        always_comb
        begin
                        case(getPartition(addr))
                                1: data = ram[int'(addr)];
                                2: data = rom[int'(addr)-2**18];
                                3: data =  io[int'(addr)-2**19];
                                default: data = 0;
                        endcase
        end
                
endmodule


