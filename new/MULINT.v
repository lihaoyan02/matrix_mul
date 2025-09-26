
//////////////////////////////////////////////////////////////////////////////////
// Module Name: MULINT
//////////////////////////////////////////////////////////////////////////////////

`define BOOTHCODE_LEN 3
`define PART_PRDT_NUM 5

module MULINT
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
    
    wire op1_sign = op1[DATA_W-1];
    wire op2_sign = op2[DATA_W-1];
    wire [DATA_W:0] part_prdt [`PART_PRDT_NUM-1:0];
    wire booth_sign[`PART_PRDT_NUM-1:0];
    wire part_prdt_sign[`PART_PRDT_NUM-1:0];
    wire [2:0] booth_code [4:0];

    //扩展位用于编码，左边补两位符号位，右边补一位0
    wire [DATA_W+2:0] op2_expd;
    
    assign op2_expd = {op2_sign,op2_sign,op2,1'b0};
    //对应编码位置进行连接
    genvar i;
    generate
        for ( i=0 ;i<5 ;i=i+1 ) begin
            assign booth_code[i] = op2_expd[(`BOOTHCODE_LEN-1)*i+:`BOOTHCODE_LEN];
        end
    endgenerate

    //对应编码位置进行连接
    //booth_code == 3'b000 =  0
    //booth_code == 3'b001 =  1
    //booth_code == 3'b010 =  1
    //booth_code == 3'b011 =  2
    //booth_code == 3'b100 = -2
    //booth_code == 3'b101 = -1
    //booth_code == 3'b110 = -1
    //booth_code == 3'b111 = -0
    genvar j;
    generate
        for ( j=0 ;j<5 ;j=j+1 ) begin
            assign booth_sign[j] = booth_code[j][`BOOTHCODE_LEN-1];

            // 如果part_prdt是reg,用以下方式
            // always @(*) begin
            //     case (booth_code[j])
            //         3'b000:begin
            //             part_prdt[j]={(DATA_W+1){1'b0}};
            //         end 
            //         3'b001:begin
            //             part_prdt[j]={op1_sign,op1};
            //         end 
            //         3'b010:begin
            //             part_prdt[j]={op1_sign,op1};
            //         end 
            //         3'b011:begin
            //             part_prdt[j]={op1,1'b0};
            //         end 
            //         3'b100:begin
            //             part_prdt[j]=~{op1,1'b0};
            //         end 
            //         3'b101:begin
            //             part_prdt[j]=~{op1_sign,op1};
            //         end 
            //         3'b110:begin
            //             part_prdt[j]=~{op1_sign,op1};
            //         end 
            //         3'b111:begin
            //             part_prdt[j]={(DATA_W+1){1'b0}};
            //         end 
            //         default: part_prdt[j]={(DATA_W+1){1'b0}};
            //     endcase    
            // end


            // if else 有优先级结构           
            // assign   part_prdt[j] = (booth_code[j]== 3'b000) ? {(DATA_W+1){1'b0}} :
            //                         (booth_code[j]== 3'b001) ? {op1_sign,op1} :
            //                         (booth_code[j]== 3'b010) ? {op1_sign,op1} :
            //                         (booth_code[j]== 3'b011) ? {op1,1'b0} :
            //                         (booth_code[j]== 3'b100) ? ~{op1,1'b0} :
            //                         (booth_code[j]== 3'b101) ? ~{op1_sign,op1} :
            //                         (booth_code[j]== 3'b110) ? ~{op1_sign,op1} :
            //                         (booth_code[j]== 3'b111) ? {(DATA_W+1){1'b0}} : {(DATA_W+1){1'b0}};
            
            // 无优先级结构 
            assign  part_prdt[j] = ({(DATA_W+1){booth_code[j]== 3'b000}} & {(DATA_W+1){1'b0}})
                                    | ({(DATA_W+1){booth_code[j]== 3'b001}} & {op1_sign,op1})
                                    | ({(DATA_W+1){booth_code[j]== 3'b010}} & {op1_sign,op1})
                                    | ({(DATA_W+1){booth_code[j]== 3'b011}} & {op1,1'b0})
                                    | ({(DATA_W+1){booth_code[j]== 3'b100}} & ~{op1,1'b0})
                                    | ({(DATA_W+1){booth_code[j]== 3'b101}} & ~{op1_sign,op1})
                                    | ({(DATA_W+1){booth_code[j]== 3'b110}} & ~{op1_sign,op1})
                                    | ({(DATA_W+1){booth_code[j]== 3'b111}} & {(DATA_W+1){1'b0}});
            assign  part_prdt_sign[j] = part_prdt[j][DATA_W];
        end
    endgenerate


//Dadda CSA Trees
wire s1_bt6_0;
wire s1_bt7_0, s1_bt7_1c;
wire s1_bt8_0, s1_bt8_1, s1_bt8_2c;
wire s1_bt9_0, s1_bt9_1c, s1_bt9_2c, s1_bt9_3;
wire s1_bt10_0, s1_bt10_1c, s1_bt10_2c, s1_bt10_3;
wire s1_bt11_0, s1_bt11_1c, s1_bt11_2c, s1_bt11_3;
wire s1_bt12_0, s1_bt12_1c, s1_bt12_2c;

wire s1_bt13_0c;
// first stage
FA  u_S1_FA1(part_prdt[0][6],part_prdt[1][6-2],part_prdt[2][6-4],s1_bt6_0,s1_bt7_1c);
FA  u_S1_FA2(part_prdt[0][7],part_prdt[1][7-2],part_prdt[2][7-4],s1_bt7_0,s1_bt8_2c);

FA  u_S1_FA3(part_prdt[0][8],part_prdt[1][8-2],part_prdt[2][8-4],s1_bt8_0,s1_bt9_1c);
FA  u_S1_FA4(part_prdt[3][8-6],part_prdt[4][8-8],booth_sign[4],s1_bt8_1,s1_bt9_2c);

FA  u_S1_FA5(part_prdt_sign[0],part_prdt[1][9-2],part_prdt[2][9-4],s1_bt9_0,s1_bt10_1c);
HA  u_S1_HA1(part_prdt[3][9-6],part_prdt[4][9-8], s1_bt9_3, s1_bt10_2c);

FA  u_S1_FA6(part_prdt_sign[0],part_prdt[1][10-2],part_prdt[2][10-4],s1_bt10_0,s1_bt11_1c);
HA  u_S1_HA2(part_prdt[3][10-6],part_prdt[4][10-8], s1_bt10_3, s1_bt11_2c);

FA  u_S1_FA7(~part_prdt_sign[0],~part_prdt_sign[1],part_prdt[2][11-4],s1_bt11_0,s1_bt12_1c);
HA  u_S1_HA3(part_prdt[3][11-6],part_prdt[4][11-8], s1_bt11_3, s1_bt12_2c);

FA  u_S1_FA8(1'b1,part_prdt[2][12-4],part_prdt[3][12-6],s1_bt12_0,s1_bt13_0c);


// second stage
wire s2_bt4_0;
wire s2_bt5_0, s2_bt5_1c;
wire s2_bt6_0, s2_bt6_1c;
wire s2_bt7_0, s2_bt7_1c;
wire s2_bt8_0, s2_bt8_1c;
wire s2_bt9_0, s2_bt9_1c;
wire s2_bt10_0, s2_bt10_1c;
wire s2_bt11_0, s2_bt11_1c;
wire s2_bt12_0, s2_bt12_1c;
wire s2_bt13_0, s2_bt13_1c;
wire s2_bt14_0, s2_bt14_1c;
wire s2_bt15_0c;

FA  u_S2_FA1(part_prdt[0][4],part_prdt[1][4-2],part_prdt[2][4-4],s2_bt4_0,s2_bt5_1c);
FA  u_S2_FA2(part_prdt[0][5],part_prdt[1][5-2],part_prdt[2][5-4],s2_bt5_0,s2_bt6_1c);

FA  u_S2_FA3(s1_bt6_0,part_prdt[3][6-6],booth_sign[3],s2_bt6_0,s2_bt7_1c);
FA  u_S2_FA4(s1_bt7_0,s1_bt7_1c,part_prdt[3][7-6],s2_bt7_0,s2_bt8_1c);
FA  u_S2_FA5(s1_bt8_0,s1_bt8_1,s1_bt8_2c,s2_bt8_0,s2_bt9_1c);
FA  u_S2_FA6(s1_bt9_0,s1_bt9_1c,s1_bt9_2c,s2_bt9_0,s2_bt10_1c);
FA  u_S2_FA7(s1_bt10_0,s1_bt10_1c,s1_bt10_2c,s2_bt10_0,s2_bt11_1c);
FA  u_S2_FA8(s1_bt11_0,s1_bt11_1c,s1_bt11_2c,s2_bt11_0,s2_bt12_1c);
FA  u_S2_FA9(s1_bt12_0,s1_bt12_1c,s1_bt12_2c,s2_bt12_0,s2_bt13_1c);

FA  u_S2_FA10(s1_bt13_0c,~part_prdt_sign[2],part_prdt[3][13-6],s2_bt13_0,s2_bt14_1c);
FA  u_S2_FA11(1'b1,part_prdt[3][14-6],part_prdt[4][14-8],s2_bt14_0,s2_bt15_0c);
//third stage
wire    [2*DATA_W-1:0]      op_pls_1;
wire    [2*DATA_W-1:0]      op_pls_2;
wire s3_bt2_0;
wire s3_bt3_0, s3_bt3_1c;
wire s3_bt4_0, s3_bt4_1c;
wire s3_bt5_0, s3_bt5_1c;
wire s3_bt6_0, s3_bt6_1c;
wire s3_bt7_0, s3_bt7_1c;
wire s3_bt8_0, s3_bt8_1c;
wire s3_bt9_0, s3_bt9_1c;
wire s3_bt10_0, s3_bt10_1c;
wire s3_bt11_0, s3_bt11_1c;
wire s3_bt12_0, s3_bt12_1c;
wire s3_bt13_0, s3_bt13_1c;
wire s3_bt14_0, s3_bt14_1c;
wire s3_bt15_0, s3_bt15_1c;
wire s3_bt16_0, s3_bt16_1c;
wire s3_bt17_0c;

FA  u_S3_FA1(part_prdt[0][2],   part_prdt[1][2-2],booth_sign[1],s3_bt2_0,s3_bt3_1c);
HA  u_S3_HA1(part_prdt[0][3],   part_prdt[1][3-2],  s3_bt3_0,   s3_bt4_1c);
HA  u_S3_HA2(s2_bt4_0, booth_sign[2], s3_bt4_0, s3_bt5_1c);
HA  u_S3_HA3(s2_bt5_0, s2_bt5_1c, s3_bt5_0, s3_bt6_1c);
HA  u_S3_HA4(s2_bt6_0, s2_bt6_1c, s3_bt6_0, s3_bt7_1c);
HA  u_S3_HA5(s2_bt7_0, s2_bt7_1c, s3_bt7_0, s3_bt8_1c);
HA  u_S3_HA6(s2_bt8_0, s2_bt8_1c, s3_bt8_0, s3_bt9_1c);

FA  u_S3_FA2(s2_bt9_0, s2_bt9_1c, s1_bt9_3, s3_bt9_0, s3_bt10_1c);
FA  u_S3_FA3(s2_bt10_0, s2_bt10_1c, s1_bt10_3, s3_bt10_0, s3_bt11_1c);
FA  u_S3_FA4(s2_bt11_0, s2_bt11_1c, s1_bt11_3, s3_bt11_0, s3_bt12_1c);
FA  u_S3_FA5(s2_bt12_0, s2_bt12_1c, part_prdt[4][12-8], s3_bt12_0, s3_bt13_1c);
FA  u_S3_FA6(s2_bt13_0, s2_bt13_1c, part_prdt[4][13-8], s3_bt13_0, s3_bt14_1c);

HA  u_S3_HA7(s2_bt14_0, s2_bt14_1c, s3_bt14_0, s3_bt15_1c);
FA  u_S3_FA7(s2_bt15_0, ~part_prdt_sign[3], part_prdt[4][15-8],s3_bt15_0,s3_bt16_1c);
HA  u_S3_HA8(1'b1, part_prdt[4][16-8], s3_bt16_0, s3_bt17_0c);

assign op_pls_1 = { part_prdt[0][0],
                    part_prdt[0][1],
                    s3_bt2_0,
                    s3_bt3_0,
                    s3_bt4_0,
                    s3_bt5_0,
                    s3_bt6_0,
                    s3_bt7_0,
                    s3_bt8_0,
                    s3_bt9_0,
                    s3_bt10_0,
                    s3_bt11_0,
                    s3_bt12_0,
                    s3_bt13_0,
                    s3_bt14_0,
                    s3_bt15_0};
                    // s3_bt16_0}

assign op_pls_2 = { booth_sign[0],
                    1'b0,
                    1'b0,
                    s3_bt3_1c,
                    s3_bt4_1c,
                    s3_bt5_1c,
                    s3_bt6_1c,
                    s3_bt7_1c,
                    s3_bt8_1c,
                    s3_bt9_1c,
                    s3_bt10_1c,
                    s3_bt11_1c,
                    s3_bt12_1c,
                    s3_bt13_1c,
                    s3_bt14_1c,
                    s3_bt15_1c};
                    // s3_bt16_1c}

// last stage
assign dout_C = op_pls_1 + op_pls_2;

endmodule
