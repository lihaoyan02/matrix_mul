`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: MULINT
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

`define BOOTHCODE_LEN 3
`define PART_PRDT_NUM 5

module MULINT_MC
#(
parameter DATA_W=8
)
(
        // input       clk,
        // input       rst_n,
        input       [DATA_W-1:0]    op1,
        input       [DATA_W-1:0]    op2,
        
        output      [2*DATA_W-1:0]    dout_C
        
    );
    
    wire [32:0] part_prdt_hi_r;
    wire [32:0] part_prdt_lo_r;

    wire [2:0] booth_code [4:0];
    //扩展位用于编码，左边补两位符号位，右边补一位0
    wire op2_expd = {2{op2[DATA_W-1]},op2,0}
    
    //对应编码位置进行连接
    genvar i;
    generate
        for ( i=0 ;i<5 ;i=i+1 ) begin
            assign booth_code[i] = op2_expd[(`BOOTHCODE_LEN-1)*i+:`BOOTHCODE_LEN];
        end
    endgenerate

    wire part_prdt_sft1_r;
    wire [2:0] booth_code = cycle_0th  ? {muldiv_i_rs1[1:0],1'b0}
                            : cycle_16th ? {mul_rs1_sign,part_prdt_lo_r[0],part_prdt_sft1_r}
                            : {part_prdt_lo_r[1:0],part_prdt_sft1_r};
        //booth_code == 3'b000 =  0
        //booth_code == 3'b001 =  1
        //booth_code == 3'b010 =  1
        //booth_code == 3'b011 =  2
        //booth_code == 3'b100 = -2
        //booth_code == 3'b101 = -1
        //booth_code == 3'b110 = -1
        //booth_code == 3'b111 = -0
    wire booth_sel_zero = (booth_code == 3'b000) | (booth_code == 3'b111);
    wire booth_sel_two  = (booth_code == 3'b011) | (booth_code == 3'b100);
    wire booth_sel_one  = (~booth_sel_zero) & (~booth_sel_two);
    wire booth_sel_sub  = booth_code[2];  
endmodule
