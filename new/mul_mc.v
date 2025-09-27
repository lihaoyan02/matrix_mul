`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Project Description: multiply for multi-cycle
// 
//////////////////////////////////////////////////////////////////////////////////

`define BOOTHCODE_LEN 3
`define PART_PRDT_NUM 5
`define CNT_MAX 5

module mul_mc
#(
parameter DATA_W=8
)
(
        input       clk,
        input       rst_n,
        input       in_valid,
        output      in_ready,
        input       [DATA_W-1:0]    op1,
        input       [DATA_W-1:0]    op2,
        
        output      [2*DATA_W-1:0]    dout_C,
        output      out_valid,
        input       out_ready
        
    );
    
    reg [32:0] part_prdt_hi_r;
    reg [32:0] part_prdt_lo_r;
    wire op1_sign = op1[DATA_W-1];
    wire op2_sign = op2[DATA_W-1];

    wire [2:0] booth_code [4:0];
    //扩展位用于编码，左边补两位符号位，右边补一位0
    wire op2_expd = {op2_sign,op2_sign,op2,1'b0};

    wire sel = in_valid & in_ready;
    // 计数器
    reg [2:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            cnt <= 3'd0;
        else if(sel)
            cnt <= 3'd1;
        else if (cnt>=`CNT_MAX)
            cnt <= 3'd0;
        else if (cnt>0)
        cnt <= cnt + 3'd1;
    end

    //对应编码位置进行连接
    // to be edited
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
