`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
//Pending- Self flag checker
//////////////////////////////////////////////////////////////////////

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
reg [31:0]exp_result;
integer check_count;
integer pass;
integer fail;

//instantiation
ALU4ops DUT(.a_i(a_ti), 
   .b_i(b_ti), 
   .sel_i(sel_ti), 
   .dout_o(dout_to), 
   .fZero_o(fZero_to), 
   .fCarry_o(fCarry_to), 
   .fOverflow_o(fOverflow_to), 
   .fNegative_o(fNegative_to));

initial begin
check_count = 0;
pass = 0;
fail = 0;
end
//feeding inputs
initial begin
//Addition
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
repeat(100) begin
#3 a_ti = $urandom; 
   b_ti = $urandom; 
   sel_ti = $urandom_range(0, 3);
   #2; checker();
end
$display("-----------");
#5 $display("Total Checks: %d | Pass: %d, Fail: %d", check_count, pass, fail);
$display("-----------");
#10 $finish;
end

//self checking
always@(*) begin
case (sel_ti)
2'b00: exp_result = a_ti + b_ti;
2'b01: exp_result = a_ti - b_ti;
2'b10: exp_result = a_ti & b_ti;
2'b11: exp_result = a_ti | b_ti;
default: exp_result = 32'b0;
endcase
end
task checker(); begin
check_count = check_count + 1;
if(exp_result !== dout_to) begin
   $display("Error | Time: %t | A: %h, B: %h, S: %b | Out: %h, Exp_Out: %h", $time, a_ti, b_ti, sel_ti, dout_to, exp_result);
   fail = fail + 1;
end
else 
   pass = pass + 1;
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
