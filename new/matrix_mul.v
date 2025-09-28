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
        input       in_Dvalid,
        output      out_Dready,        
        input       [DATA_W*`ROW*`NUM-1:0]    din_A,
        
        input       [DATA_W*`COL*`NUM-1:0]    din_B,
        // B transpose
        
        output      [2*DATA_W*`COL*`ROW-1:0]    dout_C,
        output      reg     out_vld
        
    );
    
    reg     [1:0]   cnt;
    integer number=0;
    wire    sel = in_Dvalid & out_Dready;
    // reg     trig;
    reg     [DATA_W*`ROW*`NUM-1:0]  d_A_buff [1:0];
    reg     [DATA_W*`COL*`NUM-1:0]  d_B_buff [1:0];
    reg     [`ROW-1:0]  tag_new_r;
    wire    [`ROW*`COL-1:0] MAC_out_valid;
    reg     out_musk;

    // save input data into internal buffer
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n)begin
            for(number=0;number<2;number=number+1)begin
            d_A_buff[number] <= {DATA_W*`ROW*`NUM{1'b0}};
            d_B_buff[number] <= {DATA_W*`COL*`NUM{1'b0}};
            end  
        end
        else if(sel|(cnt==2'd3))begin
            d_A_buff[1] <= sel ? din_A : {DATA_W*`ROW*`NUM{1'b0}};
            d_B_buff[1] <= sel ? din_B : {DATA_W*`COL*`NUM{1'b0}};
            d_A_buff[0] <= d_A_buff[1];
            d_B_buff[0] <= d_B_buff[1];
        end
    end

    // next data request
    assign out_Dready = ((cnt==0) | (cnt==3));// & (~trig);

    // data buffer feed into the MAC unit
    reg [DATA_W-1:0] row1 [`NUM-1:0];
    reg [DATA_W-1:0] row2 [`NUM-1:0];
    reg [DATA_W-1:0] row3 [`NUM-1:0];
    
    reg [DATA_W-1:0] col1 [`NUM-1:0];
    reg [DATA_W-1:0] col2 [`NUM-1:0];
    reg [DATA_W-1:0] col3 [`NUM-1:0];
        always@(*)begin
        if(en)begin            
            row1[0] <= d_A_buff[1][DATA_W-1:0];
            row1[1] <= d_A_buff[1][2*DATA_W-1:DATA_W];
            row1[2] <= d_A_buff[1][3*DATA_W-1:2*DATA_W];
            
            row2[0] <= d_A_buff[0][6*DATA_W-1:5*DATA_W];
            row2[1] <= d_A_buff[1][4*DATA_W-1:3*DATA_W];
            row2[2] <= d_A_buff[1][5*DATA_W-1:4*DATA_W];
            // row2[3] <= d_A_buff[1][6*DATA_W-1:5*DATA_W];
            
            row3[0] <= d_A_buff[0][8*DATA_W-1:7*DATA_W];
            row3[1] <= d_A_buff[0][9*DATA_W-1:8*DATA_W];
            row3[2] <= d_A_buff[1][7*DATA_W-1:6*DATA_W];
            // row3[3] <= din_A[8*DATA_W-1:7*DATA_W];
            // row3[4] <= din_A[9*DATA_W-1:8*DATA_W];
            
            
            col1[0] <= d_B_buff[1][DATA_W-1:0];
            col1[1] <= d_B_buff[1][2*DATA_W-1:DATA_W];
            col1[2] <= d_B_buff[1][3*DATA_W-1:2*DATA_W];
            
            col2[0] <= d_B_buff[0][6*DATA_W-1:5*DATA_W];
            col2[1] <= d_B_buff[1][4*DATA_W-1:3*DATA_W];
            col2[2] <= d_B_buff[1][5*DATA_W-1:4*DATA_W];
            // col2[3] <= d_B_buff[1][6*DATA_W-1:5*DATA_W];
            
            col3[0] <= d_B_buff[0][8*DATA_W-1:7*DATA_W];
            col3[1] <= d_B_buff[0][9*DATA_W-1:8*DATA_W];
            col3[2] <= d_B_buff[1][7*DATA_W-1:6*DATA_W];
            // col3[3] <= din_B[8*DATA_W-1:7*DATA_W];
            // col3[4] <= din_B[9*DATA_W-1:8*DATA_W];
        end                           
    end
    
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
    
    reg     [2*DATA_W-1:0]  mat_out_00_r;
    reg     [2*DATA_W-1:0]  mat_out_01_r;
    reg     [2*DATA_W-1:0]  mat_out_02_r;
    
    reg     [2*DATA_W-1:0]  mat_out_10_r;
    reg     [2*DATA_W-1:0]  mat_out_11_r;
    reg     [2*DATA_W-1:0]  mat_out_12_r;
    
    reg     [2*DATA_W-1:0]  mat_out_20_r;
    reg     [2*DATA_W-1:0]  mat_out_21_r;
    reg     [2*DATA_W-1:0]  mat_out_22_r;   

    reg     [2*DATA_W-1:0]  mat_out_00_2r;
    reg     [2*DATA_W-1:0]  mat_out_01_2r;
    reg     [2*DATA_W-1:0]  mat_out_02_2r;
    
    reg     [2*DATA_W-1:0]  mat_out_10_2r;
    reg     [2*DATA_W-1:0]  mat_out_11_2r;
    reg     [2*DATA_W-1:0]  mat_out_12_2r;
    
    reg     [2*DATA_W-1:0]  mat_out_20_2r;
    reg     [2*DATA_W-1:0]  mat_out_21_2r;
    reg     [2*DATA_W-1:0]  mat_out_22_2r;
        
//    assign row1[0][DATA_W-1:0]=din_A[DATA_W-1:0];
    // always@(posedge clk or negedge rst_n)begin
    //     if(!rst_n)begin
    //         for(number=0;number<2*`NUM-1;number=number+1)begin
    //         row1[number] <= {DATA_W{1'b0}};
    //         row2[number] <= {DATA_W{1'b0}};
    //         row3[number] <= {DATA_W{1'b0}};
    //         col1[number] <= {DATA_W{1'b0}};
    //         col2[number] <= {DATA_W{1'b0}};
    //         col3[number] <= {DATA_W{1'b0}};
    //         end  
    //         out_Dready_r <= 1'b1;
    //     end
    //     else if(sel)begin
            
    //         row1[0] <= din_A[DATA_W-1:0];
    //         row1[1] <= din_A[2*DATA_W-1:DATA_W];
    //         row1[2] <= din_A[3*DATA_W-1:2*DATA_W];
            
    //         row2[1] <= din_A[4*DATA_W-1:3*DATA_W];
    //         row2[2] <= din_A[5*DATA_W-1:4*DATA_W];
    //         row2[3] <= din_A[6*DATA_W-1:5*DATA_W];
            
    //         row3[2] <= din_A[7*DATA_W-1:6*DATA_W];
    //         row3[3] <= din_A[8*DATA_W-1:7*DATA_W];
    //         row3[4] <= din_A[9*DATA_W-1:8*DATA_W];
            
            
    //         col1[0] <= din_B[DATA_W-1:0];
    //         col1[1] <= din_B[2*DATA_W-1:DATA_W];
    //         col1[2] <= din_B[3*DATA_W-1:2*DATA_W];
            
    //         col2[1] <= din_B[4*DATA_W-1:3*DATA_W];
    //         col2[2] <= din_B[5*DATA_W-1:4*DATA_W];
    //         col2[3] <= din_B[6*DATA_W-1:5*DATA_W];
            
    //         col3[2] <= din_B[7*DATA_W-1:6*DATA_W];
    //         col3[3] <= din_B[8*DATA_W-1:7*DATA_W];
    //         col3[4] <= din_B[9*DATA_W-1:8*DATA_W];

    //         out_Dready_r <= 1'd0;
    //     end                           
    // end
    
    // triger the counter to initiate the entire module
    // always @(posedge clk or negedge rst_n) begin
    //     if(!rst_n)
    //         trig <= 0;
    //     else if(sel)
    //         trig <= 1;
    //     else
    //         trig <= 0;
    // end

    
    integer i=0;
    integer j=0;
    // counter
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
            cnt <= 0;
        else if(en)begin
            if(sel | cnt>=3)
            cnt <= 1;
            else if(cnt>0)
            cnt <= cnt+1;
        end else
            cnt <=0;
    end
    
    // push data into the MAC
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            leftin[0] <= {DATA_W{1'b0}};
            leftin[1] <= {DATA_W{1'b0}};
            leftin[2] <= {DATA_W{1'b0}};
            upin[0] <= {DATA_W{1'b0}};               
            upin[1] <= {DATA_W{1'b0}};      
            upin[2] <= {DATA_W{1'b0}}; 
            tag_new_r <= {`ROW{1'b0}};      
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
                tag_new_r <= 3'b001;
            end
            2:begin
                leftin[0] <= row1[1];
                leftin[1] <= row2[1];
                leftin[2] <= row3[1];
                upin[0] <= col1[1];               
                upin[1] <= col2[1];      
                upin[2] <= col3[1];
                tag_new_r <= 3'b010;
            end
            3:begin
                leftin[0] <= row1[2];
                leftin[1] <= row2[2];
                leftin[2] <= row3[2];
                upin[0] <= col1[2];               
                upin[1] <= col2[2];      
                upin[2] <= col3[2];
                tag_new_r <= 3'b100;
            end
            // 4:begin
            //     leftin[0] <= row1[3];
            //     leftin[1] <= row2[3];
            //     leftin[2] <= row3[3];
            //     upin[0] <= col1[3];               
            //     upin[1] <= col2[3];      
            //     upin[2] <= col3[3];
            // end
            // 5:begin
            //     leftin[0] <= row1[4];
            //     leftin[1] <= row2[4];
            //     leftin[2] <= row3[4];
            //     upin[0] <= col1[4];               
            //     upin[1] <= col2[4];      
            //     upin[2] <= col3[4];
            // end
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
    
    // data out flag, musk the first flag
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_vld <= 0;
        end
        else begin
            out_vld <= (!out_musk) & MAC_out_valid[8];
        end     
    end

    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            out_musk <= 1;
        end
        else if(MAC_out_valid[8])begin
            out_musk <= 0;
        end      
    end
    
    assign   dout_C[0+:2*DATA_W] = mat_out_00_2r; 

    assign   dout_C[2*DATA_W*1+:2*DATA_W] = mat_out_01_2r; 
    assign   dout_C[2*DATA_W*3+:2*DATA_W] = mat_out_10_2r; 

    assign   dout_C[2*DATA_W*2+:2*DATA_W] = mat_out_02_2r;     
    assign   dout_C[2*DATA_W*4+:2*DATA_W] = mat_out_11_2r;    
    assign   dout_C[2*DATA_W*6+:2*DATA_W] = mat_out_20_2r; 

    assign   dout_C[2*DATA_W*5+:2*DATA_W] = mat_out_12_r;
    assign   dout_C[2*DATA_W*7+:2*DATA_W] = mat_out_21_r; 

    assign   dout_C[2*DATA_W*8+:2*DATA_W] = mat_out_22_r; 
    

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mat_out_00_r <= {2*DATA_W{1'b0}};

            mat_out_01_r <= {2*DATA_W{1'b0}};
            mat_out_10_r <= {2*DATA_W{1'b0}};

            mat_out_02_r <= {2*DATA_W{1'b0}};
            mat_out_11_r <= {2*DATA_W{1'b0}};
            mat_out_20_r <= {2*DATA_W{1'b0}};

            mat_out_12_r <= {2*DATA_W{1'b0}};
            mat_out_21_r <= {2*DATA_W{1'b0}};

            mat_out_22_r <= {2*DATA_W{1'b0}};
        end else begin
            mat_out_00_r <= MAC_out_valid[0] ? mat_out_00_w : mat_out_00_r;
            mat_out_01_r <= MAC_out_valid[1] ? mat_out_01_w : mat_out_01_r;
            mat_out_02_r <= MAC_out_valid[2] ? mat_out_02_w : mat_out_02_r;
            mat_out_10_r <= MAC_out_valid[3] ? mat_out_10_w : mat_out_10_r;
            mat_out_11_r <= MAC_out_valid[4] ? mat_out_11_w : mat_out_11_r;
            mat_out_12_r <= MAC_out_valid[5] ? mat_out_12_w : mat_out_12_r;
            mat_out_20_r <= MAC_out_valid[6] ? mat_out_20_w : mat_out_20_r;
            mat_out_21_r <= MAC_out_valid[7] ? mat_out_21_w : mat_out_21_r;
            mat_out_22_r <= MAC_out_valid[8] ? mat_out_22_w : mat_out_22_r;
        end
        
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mat_out_00_2r <= {2*DATA_W{1'b0}};

            mat_out_01_2r <= {2*DATA_W{1'b0}};
            mat_out_10_2r <= {2*DATA_W{1'b0}};

            mat_out_02_2r <= {2*DATA_W{1'b0}};
            mat_out_11_2r <= {2*DATA_W{1'b0}};
            mat_out_20_2r <= {2*DATA_W{1'b0}};

            mat_out_12_2r <= {2*DATA_W{1'b0}};
            mat_out_21_2r <= {2*DATA_W{1'b0}};

            mat_out_22_2r <= {2*DATA_W{1'b0}};
        end else if(cnt==2) begin
            mat_out_00_2r <= mat_out_00_r;
            mat_out_01_2r <= mat_out_01_r;
            mat_out_02_2r <= mat_out_02_r;
            mat_out_10_2r <= mat_out_10_r;
            mat_out_11_2r <= mat_out_11_r;
            mat_out_12_2r <= mat_out_12_r;
            mat_out_20_2r <= mat_out_20_r;
            mat_out_21_2r <= mat_out_21_r;
            mat_out_22_2r <= mat_out_22_r;
        end
        
    end
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
    .Cellout_2_2(mat_out_22_w),
    .in_tag_new(tag_new_r),
    .out_valid(MAC_out_valid)
    );
endmodule
