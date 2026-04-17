//Problem 15: Design an ALU (Arithmetic Logic Unit) with 4 operations.
`timescale 1ns / 1ps

module ALU4ops( 
    input [31:0]a_i, //A, first input
    input [31:0]b_i, //B, Second input
    input [1:0]sel_i, //S1 S0, Select line
    output reg [31:0]dout_o, //D, data Output
    output reg fZero_o, //Zero flag
    output reg fCarry_o, //Carry Flag (High -> No borrow in Subtraction or Carry in Addition)
    output reg fOverflow_o, //Overflow Flag
    output reg fNegative_o //Negative ALU result Flag
);

//net(s)
wire [31:0]sum_o; //Sum of Adder
wire Acarry_o; //Carry of Adder
wire [31:0]diff_o; //Result of Subtraction via 2s comp method
wire Scarry_o; //Carry of Addition in 2s comp Subtraction method
wire [31:0]and_o; //Result of 32 parallel ANDs
wire [31:0]or_o; //Result of 32 parallel ORs

//Addition
assign {Acarry_o, sum_o} = a_i + b_i;
//Subtraction
assign {Scarry_o, diff_o} = a_i + (~b_i) + 1;
//AND
assign and_o = a_i & b_i;
//OR
assign or_o = a_i | b_i;

//ALU Output selection
always@(a_i, 
   b_i, 
   sel_i) begin
    
//initialization -- Reset ALU outputs -- 
dout_o = 32'b0;
fCarry_o = 1'b0;
fOverflow_o = 1'b0;
    
//MUX -- selecting ALU output
case (sel_i)
2'b00: begin //Addition (00)
   dout_o = sum_o; 
   fCarry_o = Acarry_o; //Carry Flag = Carry of Adder
   fOverflow_o = (a_i[31] & b_i[31] & ~sum_o[31]) | (~a_i[31] & ~b_i[31] & sum_o[31]); //P+P=N or N+N=P ? (P -> +ve, N -> -ve)
end
//Subtraction
2'b01: begin 
   dout_o = diff_o;
   fCarry_o = ~Scarry_o; //Carry = no borrow
   fOverflow_o = (a_i[31] & ~b_i[31] & ~diff_o[31]) | (~a_i[31] & b_i[31] & diff_o[31]); //P-N=N or N-P=P ?
end
//AND
2'b10: dout_o = and_o;
//OR
2'b11: dout_o = or_o;
//Default
default: dout_o = 32'b0;
endcase
//Update Flags
fNegative_o = dout_o[31]; //MSB of ALU output
fZero_o = (dout_o == 32'b0); //ALU optput zero or not?

end
endmodule
