module control(
        input logic clk, reset,
        input logic [31:0] inst,
        input logic aluzero,
        
        output logic wpc, wins,
        output logic selmemaddr, wmem,
        output logic selext, selalu1, output logic [2:0] selalu2, output logic [3:0] aluop,
        output logic selregwd, selregaddr, wreg
);

        //Define opcode and funct from instuction
        logic [5:0] opcode, funct;
        assign opcode = inst[31:26];
        assign funct = inst[5:0];

        //States
        enum {FETCH, DECODE, MRTYPE, MALUIMM, LW, SW, BENEQ, J, JR, BPCINC, REGPCINC} state, next;
        
        //Update current state
        always_ff @(posedge clk)
                if (reset)
                        state <= FETCH;
                else
                        state <= next;
                        
        //Next state logic
        always_comb
        begin
                unique case(state)
                        FETCH: next = DECODE;
                        
                        DECODE: begin
                                unique case(opcode)
                                     //Mainstream R-Type (have op=0): add, sub, slt, or, and , nor 
                                     6'b000000: next = MRTYPE;
                                     
                                     //Mainstream ALU immediate: addi, andi, ori
                                     6'b001000, 6'b001100, 6'b001101: next = MALUIMM;
                                     
                                     //LW
                                     6'b100011: next = LW;
                                     
                                     //SW
                                     6'b101011: next = SW;
                                     
                                     //BEQ, BNEQ
                                     6'b000100, 6'b000101: next = BENEQ;
                                     
                                     //J
                                     6'b000010: next = J;                                     
                                endcase
                                //JR is RType with funct b001000 
                                if (funct == 6'b001000)
                                     next = JR;
                                end
                                
                        MRTYPE, MALUIMM, LW, SW: next = REGPCINC;
                        
                        BENEQ: if ((inst == 6'b000100 & aluzero) | (inst == 6'b000101 & ~aluzero))
                                next = BPCINC;
                               else
                                next = REGPCINC;
                                
                        BPCINC, J, JR, REGPCINC: next = FETCH;
                endcase
        end
        
        //Output logic
        always_comb 
        begin
                //Default values
                wpc = 0;
                wins = 0;
                selmemaddr=0;
                wmem=0;
                selext=0; selalu1=0; selalu2=0;
                aluop= 0;
                selregwd=0; selregaddr=0; 
                wreg=0;
                
                unique case(state)
                        FETCH: begin
                                selmemaddr=0;
                                wmem=0;
                                wins=1'b1;
                                end
                                
                        MRTYPE: begin
                                        selalu1=0;
                                        selalu2=0;
                                        selregwd=0;
                                        selregaddr=0;
                                        wreg=1'b1;
                                        
                                        unique case(funct)
                                         //add
                                         6'b100000: aluop= 4'b0010;
                                         //sub
                                         6'b100010: aluop= 4'b0110;
                                         //slt
                                         6'b101010: aluop= 4'b0111;
                                         //or
                                         6'b100101: aluop= 4'b0001;
                                         //and
                                         6'b100100: aluop= 4'b0000;
                                         //nor
                                         6'b100111: aluop= 4'b1100;
                                        endcase
                                end
                                
                        MALUIMM: begin
                                  selalu1=0;
                                  selalu2=3'b100;
                                  selregwd=0;
                                  selregaddr=1'b1;
                                  wreg=1'b1;
                                  
                                  unique case(inst)
                                        //Arith: addi
                                        6'b001000: selext=0;
                                        
                                        //Logical: andi, ori
                                        6'b001100, 6'b001101: selext=1;                                        
                                  endcase
                                 end
                         
                       LW: begin
                             selalu1=0;
                             selalu2=3'b100;
                             selext=1'b1;
                             selregaddr=1'b1;
                             selregwd=1'b1;
                             selmemaddr=1'b1;
                             wreg=1'b1;
                           end
                           
                       SW: begin
                            selalu1=0;
                            selalu2=3'b100;
                            selext=1'b1;
                            selmemaddr=1'b1;
                            wmem=1'b1;
                           end
                           
                        BENEQ: begin
                                selalu1=0;
                                selalu2=0;
                                aluop=4'b0110;
                               end
                               
                       J: begin
                           selalu1= 1'b1;
                           selalu2= 3'b011;
                           aluop=4'b0010;
                           wpc= 1'b1;
                          end
                          
                       JR: begin
                             selalu1=0;
                             selalu2=3'b010;
                             aluop=4'b0010;
                             wpc = 1'b1;
                           end
                           
                        REGPCINC: begin
                                    selalu1=1'b1;
                                    selalu2=3'b001;
                                    aluop=4'b0010;
                                    wpc=1'b1;
                                  end
                                  
                        BPCINC:  begin
                                   selalu1=1'b1;
                                   selalu2=3'b011;
                                   aluop=4'b0010;
                                   wpc=1'b1;
                                 end
                                                                              
                endcase        
        
        end
        
        

endmodule
