//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/20 16:18:11
// Design Name: 
// Module Name: PE
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


module PE
#(parameter DATA_W=8)
(
        input   clk,
        input   rst_n,
        input   clr_in,
        input   signed  [DATA_W-1:0]    DRowin,
        input   signed  [DATA_W-1:0]    DColin,     
        
        output  signed  [DATA_W-1:0]    DRowout,
        output  signed  [DATA_W-1:0]    DColout,
        
        output  signed  [DATA_W*2-1:0]  Cellout,
        output  clr_out
    );
    
    reg     signed  [DATA_W-1:0]        DRowout_r;
    reg     signed  [DATA_W-1:0]        DColout_r;
    reg     signed  [DATA_W*2-1:0]      Cellout_r;
    reg     clr_out_r;
    
    wire    signed  [DATA_W-1:0]        DRow_w;
    wire    signed  [DATA_W-1:0]        DCol_w;
    wire    signed  [DATA_W*2-1:0]      Cell_w;
    wire    signed  [DATA_W*2-1:0]      Cellout_nxt;
    
    assign DRowout = DRowout_r;
    assign DColout = DColout_r;
    assign Cellout = Cellout_r;
    
    // mul and plus
    // always@(posedge clk or negedge rst_n)begin
    //     if(!rst_n)begin
    //     Cellout_pre <= 0;
    //     end
    //     else if(clr_in) begin
    //         Cellout_pre <= #1 {DATA_W*2{1'b0}};
    //     end else
    //     Cellout_pre <= #1 Cellout;
    // end

    // assign Cellout = Cellout_mul + Cellout_pre;
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
        Cellout_r <= 0;
        end
        else begin
            if(clr_in)
            Cellout_r <= #1 Cellout_nxt;
            else
            Cellout_r <= #1 Cellout_nxt + Cellout;
        end  
    end

    // pass row and coloum data
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
            DRowout_r <= 0;
            DColout_r <= 0;
        end
        else begin
            DRowout_r <= DRowin;
            DColout_r <= DColin;
        end  
    end

    //pass clear
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)begin
        clr_out_r <= 0;
        end
        else begin
            clr_out_r <= clr_in;
        end  
    end
    
    assign DRow_w = DRowout_r;
    assign DCol_w = DColout_r;
    // assign Cell_w = Cellout_r;
    assign clr_out = clr_out_r;
    // xbip_multadd_0  u_MACline(
    // .A(DRow_w),                // input wire [7 : 0] A
    // .B(DCol_w),                // input wire [7 : 0] B
    // .C(Cell_w),                // input wire [15 : 0] C
    // .SUBTRACT(),  // input wire SUBTRACT
    // .P(Cellout_nxt),                // output wire [15 : 0] P
    // .PCOUT()    
    // );

    mult_gen_0  u_mult(
        .A(DRowin),             // input wire [7 : 0] A
        .B(DColin),             // input wire [7 : 0] B
        .P(Cellout_nxt)         // output wire [15 : 0] P
    );
endmodule
