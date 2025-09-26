module FA(A,B,Cin,Y,Cout);
// full adder
input A,B,Cin;
output Y,Cout;
    
assign Y = A^B^Cin;
assign Cout = (A&B)|(A&Cin)|(B&Cin);
    
endmodule