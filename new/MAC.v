`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/20 16:18:11
// Design Name: 
// Module Name: MAC
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


module MAC
#( 
    parameter DATA_W=8)
(
    input   clk,
    input   rst_n,
    input   signed  [DATA_W-1:0]    din_r1,
    input   signed  [DATA_W-1:0]    din_c1,
    input   signed  [DATA_W-1:0]    din_r2,
    input   signed  [DATA_W-1:0]    din_c2,
    input   signed  [DATA_W-1:0]    din_r3,
    input   signed  [DATA_W-1:0]    din_c3, 
    output  signed  [DATA_W*2-1:0]  Cellout_0_0,
    output  signed  [DATA_W*2-1:0]  Cellout_0_1,
    output  signed  [DATA_W*2-1:0]  Cellout_0_2,
    output  signed  [DATA_W*2-1:0]  Cellout_1_0,
    output  signed  [DATA_W*2-1:0]  Cellout_1_1,
    output  signed  [DATA_W*2-1:0]  Cellout_1_2,
    output  signed  [DATA_W*2-1:0]  Cellout_2_0,
    output  signed  [DATA_W*2-1:0]  Cellout_2_1,
    output  signed  [DATA_W*2-1:0]  Cellout_2_2

    );

    wire     signed  [2*DATA_W-1:0]  Cell[`ROW-1:0][`COL-1:0];
    
//    wire    [DATA_W-1:0]    row1_1_2;
//    wire    [DATA_W-1:0]    row1_2_3;
//    wire    [DATA_W-1:0]    row2_1_2;
//    wire    [DATA_W-1:0]    row2_2_3;
//    wire    [DATA_W-1:0]    row3_1_2;
//    wire    [DATA_W-1:0]    row3_2_3;
    
//    wire    [DATA_W-1:0]    col1_1_2; 
//    PE #(DATA_W) u_PE 
//    (
//    .clk(clk),
//    .rst_n(rst_n),
//    .DRowin(din_a1),
//    .DColin(),     
    
//    .DRowout(),
//    .oDColout(),
    
//    .Cellout()
//    );
    
    wire    signed  [DATA_W-1:0]    ROW_connection[`ROW-1:0][`COL:0];
    wire    signed  [DATA_W-1:0]    COL_connection[`ROW:0][`COL-1:0];
    
    assign ROW_connection[0][0] = din_r1;
    assign ROW_connection[1][0] = din_r2;
    assign ROW_connection[2][0] = din_r3;
    
    assign COL_connection[0][0] = din_c1;
    assign COL_connection[0][1] = din_c2;
    assign COL_connection[0][2] = din_c3;
    
    assign Cellout_0_0 = Cell[0][0];
    assign Cellout_0_1 = Cell[0][1];
    assign Cellout_0_2 = Cell[0][2];
    assign Cellout_1_0 = Cell[1][0];
    assign Cellout_1_1 = Cell[1][1];
    assign Cellout_1_2 = Cell[1][2];
    assign Cellout_2_0 = Cell[2][0];
    assign Cellout_2_1 = Cell[2][1];
    assign Cellout_2_2 = Cell[2][2];
    
    genvar i;
    genvar j;
    generate
        for(i=0;i<`ROW;i=i+1)begin: PE_matrix
            for(j=0;j<`COL;j=j+1)begin
                PE #(DATA_W) u_PE 
                (
                .clk(clk),
                .rst_n(rst_n),
                .DRowin(ROW_connection[i][j]),
                .DColin(COL_connection[i][j]),     
                
                .DRowout(ROW_connection[i][j+1]),
                .DColout(COL_connection[i+1][j]),
                
                .Cellout(Cell[i][j])
                );
            end
        end
    endgenerate
endmodule
