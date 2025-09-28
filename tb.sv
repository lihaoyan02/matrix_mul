`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/09/21 14:04:51
// Design Name: 
// Module Name: tb
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

//A*B=C 
//A，C的行数
`define ROW 3
//B，C的列数
`define COL 3
//A的列数，B的行数
`define NUM 3
`define T_CLK 10
`define DWIDTH 8

module tb();
    logic clk;
    logic rst_n;
    logic d_valid;
    logic d_ready;
    logic en;
    logic out_vld;
    logic [`DWIDTH*`ROW*`NUM-1:0] din_A_r;
    logic [`DWIDTH*`COL*`NUM-1:0] din_B_r;
    logic [2*`DWIDTH*`ROW*`COL-1:0] dout_C_r;
    
    logic handshaked;
    assign handshaked = d_valid & d_ready;
    
    reg     signed  [`DWIDTH-1:0] din_A_RAM [`ROW-1:0][`NUM-1:0];
    reg     signed  [`DWIDTH-1:0] din_B_RAM [`NUM-1:0][`COL-1:0];
    reg     signed  [2*`DWIDTH-1:0] dout_C_RAM [`ROW-1:0][`COL-1:0];
//    reg     signed  [2*`DWIDTH-1:0] dout_C_Ref [`ROW-1:0][`COL-1:0];
    
    typedef struct{
        logic signed [2*`DWIDTH-1:0] data[`ROW-1:0][`COL-1:0];
    } matrix_t;
    
    matrix_t ref_q[$];
    matrix_t dout_C_Ref;
    matrix_t exp_val;
    
    always #(`T_CLK/2) clk=~clk;
    initial begin
        clk=0;
        rst_n=0;
        en=0;
        d_valid = 0;
        #(10*`T_CLK)
        rst_n=1;
        
    end
    
    // 初始化输入矩阵
  task automatic init_inputs();
    for (int i = 0; i < `ROW; i++) begin
      for (int j = 0; j < `NUM; j++) begin
        din_A_RAM[i][j] = $urandom_range(-(1<<(`DWIDTH-1)), (1<<(`DWIDTH-1))-1);
      end
    end
    for (int i = 0; i < `NUM; i++) begin
      for (int j = 0; j < `COL; j++) begin
        din_B_RAM[i][j] = $urandom_range(-(1<<(`DWIDTH-1)), (1<<(`DWIDTH-1))-1);
      end
    end
  endtask

  // 参考模型 (矩阵乘法)
  task automatic matmul_ref();
    for (int i = 0; i < `ROW; i++) begin
      for (int j = 0; j < `COL; j++) begin
        dout_C_Ref.data[i][j] = 0;
        for (int k = 0; k < `NUM; k++) begin
          dout_C_Ref.data[i][j] += din_A_RAM[i][k] * din_B_RAM[k][j];
        end
      end
    end
    ref_q.push_back(dout_C_Ref);
  endtask
  
      // ===================================================
    // 将 din_A_RAM (ROW x NUM) 打平成 din_A_r
    // 顺序：从左到右，从上到下
    // ===================================================
    always_comb begin
      for (int i = 0; i < `ROW; i++) begin
        for (int j = 0; j < `NUM; j++) begin
          din_A_r[(i*`NUM + j)*`DWIDTH +: `DWIDTH] = din_A_RAM[i][j];
        end
      end
    end
    
    // ===================================================
    // 将 din_B_RAM (NUM x COL) 打平成 din_B_r
    // 这里要求输入 B 的转置矩阵 (COL x NUM)
    // 顺序：从左到右，从上到下
    // ===================================================
    always_comb begin
      for (int i = 0; i < `COL; i++) begin
        for (int j = 0; j < `NUM; j++) begin
          // 注意：转置后 B[i][j] = 原来的 B[j][i]
          din_B_r[(i*`NUM + j)*`DWIDTH +: `DWIDTH] = din_B_RAM[j][i];
        end
      end
    end
    
    initial begin
        forever begin
            @(posedge clk);
            if(handshaked) begin
                init_inputs();
                matmul_ref();
            end
        end
    end
    //捕获输出
    initial begin
        forever begin
        @(posedge clk);
        if (out_vld) begin
            // 收到有效信号，保存数据
            for (int i = 0; i < `ROW; i++) begin
            for (int j = 0; j < `COL; j++) begin
              dout_C_RAM[i][j] = dout_C_r[(i*`COL + j)*2*`DWIDTH +: 2*`DWIDTH];
            end
            end 
            exp_val = ref_q.pop_front();
            compare_matrices(
            .mat1(dout_C_RAM),
            .mat2(exp_val.data)
            );
        end 
        end
    end

    
    //比较结果
    function compare_matrices(
        input logic signed [2*`DWIDTH-1:0] mat1 [`ROW-1:0][`COL-1:0],
        input logic signed [2*`DWIDTH-1:0] mat2 [`ROW-1:0][`COL-1:0]
    );
        automatic int errors = 0;
        begin
            for (int i = 0; i < `ROW; i++) begin
                for (int j = 0; j < `COL; j++) begin
                    if (mat1[i][j] !== mat2[i][j]) begin
                        $display("Mismatch at [%0d][%0d]: DUT=%0d, REF=%0d", 
                                 i, j, mat1[i][j], mat2[i][j]);
                        errors++;
                    end
                end
            end
    
            if (errors != 0)
                $display(" Total mismatches: %0d", errors);
//            else
//                $display(" All elements match!");
        end
    endfunction
    
    initial begin
        init_inputs();
        matmul_ref();
        #(`T_CLK/2)
        #(15*`T_CLK)
        en=1;
        @(posedge clk)
        d_valid = 1;
        
        #(1000*`T_CLK)
        $finish;
        
    end
    


    
    matrix_mul #(`DWIDTH) u_mul
    (
        .clk        (clk    )        ,
        .rst_n      (rst_n  )        ,
        .en         (en     )        ,
        .in_Dvalid  (d_valid),
        .out_Dready (d_ready),       
        .din_A      (din_A_r)        ,       
        .din_B      (din_B_r)        ,
        .dout_C     (dout_C_r )        ,
        .out_vld    (out_vld  )
    );
        
endmodule
