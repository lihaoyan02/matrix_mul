`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/27 09:45:27
// Design Name: 
// Module Name: tb_mul
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define T_CLK 10

module tb_mul();
    logic signed [7:0] op1;
    logic signed [7:0] op2;
    logic signed [15:0] dout;
    logic signed [15:0] refout;
    logic signed [15:0] xorout;
    
    reg clk;
    
    always #(`T_CLK/2) clk=~clk;
    
    
    task automatic init_inputs();       
        op1 = $urandom_range(-(1<<7), (1<<7-1));
        op2 = $urandom_range(-(1<<7), (1<<7-1));
    endtask 
    
       
    assign refout = op1 * op2;
    assign xorout = dout ^ refout;

    
    int error = 0;
    function automatic comp(
        input logic signed [15:0] out1,
        input logic signed [15:0] out2
    );       
        if (out1 !== out2) begin
            $display("Mismatch");
            error++;
        end 
    endfunction
    
    initial begin
    #(`T_CLK)
        forever begin           
            @(posedge clk)begin
                comp(.out1(dout),.out2(refout));                
            end
            init_inputs();
        end
    end
    

    initial begin
        clk = 1;
        init_inputs();  
        #(100*`T_CLK)
        $finish;
        
    end
    

    mul_sign_int 
#(8
) u_mul_t
    (
        .op1(op1),
        .op2(op2),
        
        .dout_C(dout)
        
    );
endmodule
