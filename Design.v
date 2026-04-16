`timescale 1ns / 1ps

//4 ops: Addition, Subtraction, AND, OR
module ALU4ops(
    input [31:0]a_i, //A
    input [31:0]b_i, //B
    input [1:0]sel_i, //S0 S1
    output reg [31:0]dout_o, //D
    output reg fZero_o, //Zero flag
    output reg fCarry_o, //Carry Flag (no borrow, adder carry)
    output reg fOverflow_o, //Overflow Flag
    output reg fNegative_o //Negative Flag
);

//net(s)
wire [31:0]sum_o; //A+B
wire Acarry_o; //Carry of A+B
wire [31:0]diff_o; //A-B = A + B's 2s comp
wire Scarry_o; //Carry of [A + B's 2s comp])
wire [31:0]and_o; //parallel AND
wire [31:0]or_o; //-- OR

//Addition
assign {Acarry_o, sum_o} = a_i + b_i;

//Subtraction
assign {Scarry_o, diff_o} = a_i + (~b_i) + 1; //A + B's 2s comp

//logical AND
assign and_o = a_i & b_i;

//logical OR
assign or_o = a_i | b_i;

//ALU Output selection
always@(*) begin
//default outputs
dout_o = 32'b0;
//fZero_o = 1'b0; //going to calculate anyway
fCarry_o = 1'b0;
fOverflow_o = 1'b0;
//fNegative_o = 1'b0; //going to calculate anyway
//MUX
case (sel_i)
//Addition
2'b00: begin 
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
