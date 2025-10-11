
//AND, OR, NOT, XOR gate modules
//ANDmodule
module m_and (
    input in1,
    input in2,
    output out1
);

assign out1 = in1 & in2 ;
    
endmodule

//OR module
module m_or (
    input in1,
    input in2,
    output out1
);

assign out1 = in1 | in2 ;

endmodule

//NOT module
module m_not (
    input in1,
    output out1

);

assign out1 = ~in1 ;

endmodule

//XOR module
module m_xor (
    input in1,
    input in2,
    output out1
);
assign out1 = in1 ^ in2 ;
endmodule

//NAND module
module m_nand (
    input in1,
    input in2,
    output out1
);
assign out1 = ~(in1 & in2) ;
endmodule

