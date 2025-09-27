`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/20 16:18:11
// Design Name: 
// Module Name: MUL
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

`define ROW 3
//B，C的列数
`define COL 3
//A的列数，B的行数
`define NUM 3

module matrix_mul
#(
parameter DATA_W=8
)
(
        input       clk,
        input       rst_n,
        input       en,
        input       trig,
        
        input       [DATA_W*`ROW*`NUM-1:0]    din_A,
        
        input       [DATA_W*`COL*`NUM-1:0]    din_B,
        // B transpose
        
        output      [2*DATA_W*`COL*`ROW-1:0]    dout_C,
        output      reg     out_vld
        
    );
    
    reg     [3:0]   cnt;
//    reg     [DATA_W-1:0]    A_RAM[`ROW*`COL-1:0];
    
    reg [DATA_W-1:0] row1 [2*`NUM-1-1:0];
    reg [DATA_W-1:0] row2 [2*`NUM-1-1:0];
    reg [DATA_W-1:0] row3 [2*`NUM-1-1:0];
    
    reg [DATA_W-1:0] col1 [2*`NUM-1-1:0];
    reg [DATA_W-1:0] col2 [2*`NUM-1-1:0];
    reg [DATA_W-1:0] col3 [2*`NUM-1-1:0];
    
    reg    [DATA_W-1:0]    leftin[`ROW-1:0];
    reg    [DATA_W-1:0]    upin[`COL-1:0];
    
    reg     [2*DATA_W-1:0]    dout_C_r[`COL*`ROW-1:0];
    
    wire    [2*DATA_W-1:0]  mat_out_00_w;
    wire    [2*DATA_W-1:0]  mat_out_01_w;
    wire    [2*DATA_W-1:0]  mat_out_02_w;
    
    wire    [2*DATA_W-1:0]  mat_out_10_w;
    wire    [2*DATA_W-1:0]  mat_out_11_w;
    wire    [2*DATA_W-1:0]  mat_out_12_w;
    
    wire    [2*DATA_W-1:0]  mat_out_20_w;
    wire    [2*DATA_W-1:0]  mat_out_21_w;
    wire    [2*DATA_W-1:0]  mat_out_22_w;
    
    
    
    
    integer number=0;
//    assign row1[0][DATA_W-1:0]=din_A[DATA_W-1:0];
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            for(number=0;number<2*`NUM-1;number=number+1)begin
            row1[number] <= {DATA_W{1'b0}};
            row2[number] <= {DATA_W{1'b0}};
            row3[number] <= {DATA_W{1'b0}};
            col1[number] <= {DATA_W{1'b0}};
            col2[number] <= {DATA_W{1'b0}};
            col3[number] <= {DATA_W{1'b0}};
            end  
        end
        else if(trig)begin
            
            row1[0] <= din_A[DATA_W-1:0];
            row1[1] <= din_A[2*DATA_W-1:DATA_W];
            row1[2] <= din_A[3*DATA_W-1:2*DATA_W];
            
            row2[1] <= din_A[4*DATA_W-1:3*DATA_W];
            row2[2] <= din_A[5*DATA_W-1:4*DATA_W];
            row2[3] <= din_A[6*DATA_W-1:5*DATA_W];
            
            row3[2] <= din_A[7*DATA_W-1:6*DATA_W];
            row3[3] <= din_A[8*DATA_W-1:7*DATA_W];
            row3[4] <= din_A[9*DATA_W-1:8*DATA_W];
            
            
            col1[0] <= din_B[DATA_W-1:0];
            col1[1] <= din_B[2*DATA_W-1:DATA_W];
            col1[2] <= din_B[3*DATA_W-1:2*DATA_W];
            
            col2[1] <= din_B[4*DATA_W-1:3*DATA_W];
            col2[2] <= din_B[5*DATA_W-1:4*DATA_W];
            col2[3] <= din_B[6*DATA_W-1:5*DATA_W];
            
            col3[2] <= din_B[7*DATA_W-1:6*DATA_W];
            col3[3] <= din_B[8*DATA_W-1:7*DATA_W];
            col3[4] <= din_B[9*DATA_W-1:8*DATA_W];
        end                           
    end
    
//    for(i=0;i<`ROW;i=i+1)begin
//        for(j=0;i<`COL;i=i+1)begin
//            A_RAM[i*`ROW+j] <= 0;
//        end 
//    end   

    
    integer i=0;
    integer j=0;
    // counter
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt <= 0;
        else if(en)begin
            if(trig)
            cnt <=1;
            else if(cnt>=3*`NUM)
            cnt <= 0;
            else if(cnt>0)
            cnt <= cnt+1;
        end else
            cnt <=0;
    end
    
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            leftin[0] <= {DATA_W{1'b0}};
            leftin[1] <= {DATA_W{1'b0}};
            leftin[2] <= {DATA_W{1'b0}};
            upin[0] <= {DATA_W{1'b0}};               
            upin[1] <= {DATA_W{1'b0}};      
            upin[2] <= {DATA_W{1'b0}};       
        end
        else if(en) begin
            case(cnt)
            1:begin
                leftin[0] <= row1[0];
                leftin[1] <= row2[0];
                leftin[2] <= row3[0];
                upin[0] <= col1[0];               
                upin[1] <= col2[0];      
                upin[2] <= col3[0];
            end
            2:begin
                leftin[0] <= row1[1];
                leftin[1] <= row2[1];
                leftin[2] <= row3[1];
                upin[0] <= col1[1];               
                upin[1] <= col2[1];      
                upin[2] <= col3[1];
            end
            3:begin
                leftin[0] <= row1[2];
                leftin[1] <= row2[2];
                leftin[2] <= row3[2];
                upin[0] <= col1[2];               
                upin[1] <= col2[2];      
                upin[2] <= col3[2];
            end
            4:begin
                leftin[0] <= row1[3];
                leftin[1] <= row2[3];
                leftin[2] <= row3[3];
                upin[0] <= col1[3];               
                upin[1] <= col2[3];      
                upin[2] <= col3[3];
            end
            5:begin
                leftin[0] <= row1[4];
                leftin[1] <= row2[4];
                leftin[2] <= row3[4];
                upin[0] <= col1[4];               
                upin[1] <= col2[4];      
                upin[2] <= col3[4];
            end
            default:begin
                leftin[0] <= {DATA_W{1'b0}};
                leftin[1] <= {DATA_W{1'b0}};
                leftin[2] <= {DATA_W{1'b0}};
                upin[0] <= {DATA_W{1'b0}};               
                upin[1] <= {DATA_W{1'b0}};      
                upin[2] <= {DATA_W{1'b0}};
            end
//            6:begin
//                leftin[0] <= row1[5];
//                leftin[1] <= row2[5];
//                leftin[2] <= row3[5];
//                upin[0] <= col1[5];               
//                upin[1] <= col2[5];      
//                upin[2] <= col3[5];
//            end
//            7:begin
//                leftin[0] <= row1[6];
//                leftin[1] <= row2[6];
//                leftin[2] <= row3[6];
//                upin[0] <= col1[6];               
//                upin[1] <= col2[6];      
//                upin[2] <= col3[6];
//            end
//            8:begin
//                leftin[0] <= row1[7];
//                leftin[1] <= row2[7];
//                leftin[2] <= row3[7];
//                upin[0] <= col1[7];               
//                upin[1] <= col2[7];      
//                upin[2] <= col3[7];
//            end
            endcase
       end else begin
            leftin[0] <= {DATA_W{1'b0}};
            leftin[1] <= {DATA_W{1'b0}};
            leftin[2] <= {DATA_W{1'b0}};
            upin[0] <= {DATA_W{1'b0}};               
            upin[1] <= {DATA_W{1'b0}};      
            upin[2] <= {DATA_W{1'b0}};
       end
    end
    
    // data out
    integer mat_num = 0;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
//            for(mat_num=0;mat_num<`COL*`ROW;mat_num=mat_num+1)begin
//            dout_C_r[mat_num] <= {2*DATA_W{1'b0}};
//            end 
            out_vld <= 0;
        end
        else if(cnt==3*`NUM)begin
//            dout_C_r[0] <= mat_out_00_w;
//            dout_C_r[1] <= mat_out_01_w;
//            dout_C_r[2] <= mat_out_02_w;
//            dout_C_r[3] <= mat_out_10_w;
//            dout_C_r[4] <= mat_out_11_w;
//            dout_C_r[5] <= mat_out_12_w;
//            dout_C_r[6] <= mat_out_20_w;
//            dout_C_r[7] <= mat_out_21_w;
//            dout_C_r[8] <= mat_out_22_w;
            out_vld <= 1;
        end
        else
        out_vld <= 0;
    end
    
    
    assign   dout_C[0+:2*DATA_W] = mat_out_00_w; 
    assign   dout_C[2*DATA_W*1+:2*DATA_W] = mat_out_01_w; 
    assign   dout_C[2*DATA_W*2+:2*DATA_W] = mat_out_02_w; 
    assign   dout_C[2*DATA_W*3+:2*DATA_W] = mat_out_10_w; 
    assign   dout_C[2*DATA_W*4+:2*DATA_W] = mat_out_11_w; 
    assign   dout_C[2*DATA_W*5+:2*DATA_W] = mat_out_12_w; 
    assign   dout_C[2*DATA_W*6+:2*DATA_W] = mat_out_20_w; 
    assign   dout_C[2*DATA_W*7+:2*DATA_W] = mat_out_21_w; 
    assign   dout_C[2*DATA_W*8+:2*DATA_W] = mat_out_22_w; 
    
//    genvar mat_number;
//    generate
//    for(mat_number=0;mat_number<`COL*`ROW;mat_number=mat_number+1)begin
//        assign dout_C[2*DATA_W*(mat_number+1)-1:2*DATA_W*mat_number] = dout_C_r[mat_number];
//    end
//    endgenerate
    // save A to ram
//    always@(posedge clk or negedge rst_n)begin
//        if(!rst_n)begin
//        for(i=0;i<`ROW;i=i+1)begin
//            for(j=0;i<`COL;i=i+1)begin
//                A_RAM[i*`ROW+j] <= 0;
//            end
//        end   
//        end
//        else if(A_vld)begin
//            A_RAM[ADDR_A] <= din_A;
//        end
//    end
    // save B to ram    
    
    // trig to start
    
    
    MAC#(DATA_W) u_mac
    (
    .clk(clk),
    .rst_n(rst_n),
    .din_r1(leftin[0]),
    .din_c1(upin[0]),
    .din_r2(leftin[1]),
    .din_c2(upin[1]),
    .din_r3(leftin[2]),
    .din_c3(upin[2]),
    
    .Cellout_0_0(mat_out_00_w),
    .Cellout_0_1(mat_out_01_w),
    .Cellout_0_2(mat_out_02_w),
    .Cellout_1_0(mat_out_10_w),
    .Cellout_1_1(mat_out_11_w),
    .Cellout_1_2(mat_out_12_w),
    .Cellout_2_0(mat_out_20_w),
    .Cellout_2_1(mat_out_21_w),
    .Cellout_2_2(mat_out_22_w)

    );
endmodule
