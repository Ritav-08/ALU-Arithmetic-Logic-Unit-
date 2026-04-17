`timescale 1ns / 1ps

module tb_ALU4ops();
reg [31:0]a_ti;
reg [31:0]b_ti;
reg [1:0]sel_ti;
wire [31:0]dout_to;
wire fZero_to;
wire fCarry_to;
wire fOverflow_to;
wire fNegative_to;

//net(s)
reg [31:0]exp_result; //self checker ports (exp_...)
reg exp_fCarry; 
reg exp_Scarry; 
reg exp_fOverflow;
reg exp_fNegative;
reg exp_fZero;
integer check_count; //total checks performed
integer pass; //passed check count
integer fail; //failed -- --
integer flag_O; //Overflow flag trigger count
integer flag_Z; //Zero -- -- --

//instantiation
ALU4ops DUT(.a_i(a_ti), 
   .b_i(b_ti), 
   .sel_i(sel_ti), 
   .dout_o(dout_to), 
   .fZero_o(fZero_to), 
   .fCarry_o(fCarry_to), 
   .fOverflow_o(fOverflow_to), 
   .fNegative_o(fNegative_to));

//reset count
task rst_count(); begin
check_count = 0;
pass = 0;
fail = 0;
flag_Z = 0;
flag_O = 0;
end
endtask

//feeding inputs
initial begin
//Addition
rst_count(); //count reset
sel_ti = 2'b00; 
$display("Addition");
a_ti = 32'h00000005; b_ti = 32'h00000003; //normal
#2; checker();
#3 a_ti = 32'h00000000; b_ti = 32'h00000000; //Zero flag, all low
#2; checker();
#3 a_ti = 32'hffffffff; b_ti = 32'h00000001; //Carry flag
#2; checker();
#3 a_ti = 32'h7fffffff; b_ti = 32'h00000001; //Overflow flag, +ve ADD +ve -> -ve (MSB 0 -> MSB 1) => +ve overflow, Negative flag
#2; checker();
#3 a_ti = 32'h80000000; b_ti = 32'h80000000; //Overflow flag, -ve overflow
#2; checker();
#3 a_ti = 32'hffffffff; b_ti = 32'hffffffff; //all high
#2; checker();
#3 a_ti = 32'h88888888; b_ti = 32'h77777777; //alternating bits
#2; checker();
//Subtraction
#3 sel_ti = 2'b01;
   $display("Subtraction");
   a_ti = 32'h00000007; b_ti = 32'h00000006; //A>B, Carry flag (No Borrow), Negative flag
   #2; checker();
#3 a_ti = 32'h00000006; b_ti = 32'h00000007; //A<B, Negative flag, Carry flag (Borrow)
#2; checker();
#3 a_ti = 32'hffffffff; b_ti = 32'hffffffff; //all high, Zero flag
#2; checker();
#3 a_ti = 32'h00000000; b_ti = 32'h00000000; //all low,  Zero flag
#2; checker();
#3 a_ti = 32'h33333333; b_ti = 32'hcccccccc; //alternating bits
#2; checker();
#3 a_ti = 32'habcdef01; b_ti = 32'habcdef01; //Zero flag
#2; checker();
#3 a_ti = 32'h7fffffff; b_ti = 32'hffffffff; //overflow
#2; checker();
//AND
#3 sel_ti = 2'b10;
   $display("AND");
   a_ti = 32'h00000007; b_ti = 32'h00000007; //same
   #2; checker();
#3 a_ti = 32'h73a739bf; b_ti = 32'h173c14f0; //different
#2; checker();
#3 a_ti = 32'h00000000; b_ti = 32'h00000000; //all 0s
#2; checker();
#3 a_ti = 32'hffffffff; b_ti = 32'hffffffff; //all 1s
#2; checker();
#3 a_ti = 32'h99999999; b_ti = 32'h66666666; //alternate
#2; checker();
//OR
#3 sel_ti = 2'b11;
   $display("OR");
   a_ti = 32'h00000007; b_ti = 32'h00000007; //same
   #2; checker();
#3 a_ti = 32'h73a739bf; b_ti = 32'h173c14f0; //different
#2; checker();
#3 a_ti = 32'h00000000; b_ti = 32'h00000000; //all 0s
#2; checker();
#3 a_ti = 32'hffffffff; b_ti = 32'hffffffff; //all 1s
#2; checker();
#3 a_ti = 32'h22222222; b_ti = 32'hdddddddd; //alternate
#2; checker();

#3
repeat(100) begin //random unsigned inputs
#3 a_ti = $urandom; 
   b_ti = $urandom; 
   sel_ti = $urandom_range(0, 3);
   #2; checker();
end
$display("-----------"); //check status display
#5 $display("Total Checks: %d | Pass: %d, Fail: %d", check_count, pass, fail);
#5 $display("Overflow Count: %d, Zero Count: %d", flag_O, flag_Z);
$display("-----------");
#10 $finish;
end

//self checking
task checker(); begin
//initialization
   exp_fZero = 1'b0;
   exp_Scarry = 1'b0;
   exp_fCarry = 1'b0;
   exp_fOverflow = 1'b0;
   exp_fNegative = 1'b0;
//operation mapping, expected value generation
case (sel_ti)
//Addition
2'b00: begin 
{exp_fCarry, exp_result} = {1'b0, a_ti} + {1'b0, b_ti};
exp_fOverflow = (a_ti[31] & b_ti[31] & ~exp_result[31]) | (~a_ti[31] & ~b_ti[31] & exp_result[31]);
end
//Subtraction
2'b01: begin 
   {exp_Scarry, exp_result} = {1'b0, a_ti} + {1'b0, ~b_ti} + 1'b1;
   exp_fCarry = ~exp_Scarry;
   exp_fOverflow = (a_ti[31] & ~b_ti[31] & ~exp_result[31]) | (~a_ti[31] & b_ti[31] & exp_result[31]);
end
//AND
2'b10: exp_result = a_ti & b_ti;
//OR
2'b11: exp_result = a_ti | b_ti;
default: exp_result = 32'b0;
endcase
exp_fNegative = exp_result[31];
exp_fZero = (exp_result == 32'b0);
   
//Matching results
check_count = check_count + 1;
if((exp_result !== dout_to) ||
   (exp_fZero !== fZero_to) ||
   (exp_fCarry !== fCarry_to) ||
   (exp_fOverflow !== fOverflow_to) ||
   (exp_fNegative !== fNegative_to)) begin
      $display("Error | Time: %t | A: %h, B: %h, S: %b | Out: %h, Exp_Out: %h", $time, a_ti, b_ti, sel_ti, dout_to, exp_result);
      fail = fail + 1;
end
else 
   pass = pass + 1;
if(exp_fOverflow) flag_O = flag_O + 1;
if(exp_fZero) flag_Z = flag_Z + 1;
end
endtask

//capture
initial begin
//monitor
$monitor("Time: %0t | A: %h, B: %h, Sel: %b | Out: %h | Flags- Zero: %b, Carry: %b, Overflow: %b, Negative: %b", 
    $time, 
    a_ti, b_ti, sel_ti, 
    dout_to, 
    fZero_to, fCarry_to, fOverflow_to, fNegative_to);
//dumping
$dumpfile("ALU.vcd");
$dumpvars(0, tb_ALU4ops);
end

endmodule
