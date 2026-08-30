`timescale 1ns / 1ps  

module unused (
    input  unused_in1,
    input  unused_in2,
    input  unused_in3,
    input  unused_in4,
    input  unused_in5,
    input  unused_in6,
    input  unused_in7,
    input  unused_in8,
    input  unused_in9,
    output unused_out1
);

wire a,b,c;
assign a = unused_in1 | unused_in2 | unused_in3;
assign b = unused_in4 | unused_in5 | unused_in6;
assign c = unused_in7 | unused_in8 | unused_in9;
//assign c = unused_in7 | unused_in8 ;
assign unused_out1 = a| b| c ;
endmodule
