module sum_element (input logic cin, a, b, output logic r, cout);
        assign r = a^b^cin;
        assign cout = a&(b^cin) | (b&cin);
endmodule

module adder #(parameter len) 
(input logic [len-1:0] a, b, 
 input logic cin,
 output logic [len-1:0] r,
 output logic cout);

        logic [len:0] carry;
        assign carry[0] = cin;
        assign cout = carry[len];

        generate
                genvar i;
                for (i=0; i<len; i++)
                        sum_element s(carry[i], a[i], b[i], r[i], carry[i+1]);
        endgenerate

endmodule

module ALU #(parameter wordLen) 
(input logic [wordLen-1:0] A,B,
 input logic [3:0] op, 
 output logic [wordLen-1:0] res,
 output logic zero,
 output logic overflow);
 
        logic [wordLen-1:0] outAdder;
        logic [wordLen-1:0] inBadder;
        logic cin;
        logic cout;
        
        adder #(wordLen) ad (A, inBadder, cin, outAdder, cout);
        
        always_comb
        begin
                inBadder = 0;
                cin = 0;
                overflow = 0;
                
                case(op) 
                        //ADD signed
                        4'b0010: begin
                                        inBadder = B;
                                        cin = 0;
                                        res = outAdder; 
                                        overflow = (~A[wordLen-1])&(~B[wordLen-1])&outAdder[wordLen-1] | A[wordLen-1]&B[wordLen-1]&(~outAdder[wordLen-1]);
                                 end
                        //SUB signed     
                        4'b0110: begin
                                        inBadder = ~B;
                                        cin = 1;
                                        res = outAdder;
                                        overflow = (A[wordLen-1])&(~B[wordLen-1])&outAdder[wordLen-1] | (~A[wordLen-1])&B[wordLen-1]&outAdder[wordLen-1];                              
                                 end
                        //SLT
                        4'b0111: begin
                                        inBadder = ~B;
                                        cin = 1;
                                        res = outAdder[wordLen-1];
                                        overflow = cout;
                                 end
                        //OR
                        4'b0001: res = A|B; 
                        //AND                                
                        4'b0000: res = A&B;
                        //NOR
                        4'b1100: res = ~(A|B);
                        
          		//Default
          		default: begin
                        	     res = 0;
                                     overflow=0;
                                  end
                endcase
        end
        
        assign zero = (~|res);
endmodule
 
 

