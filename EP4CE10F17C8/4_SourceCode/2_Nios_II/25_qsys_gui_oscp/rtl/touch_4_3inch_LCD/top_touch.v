//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           top_touch
// Last modified Date:  2018/08/20 15:11:59
// Last Version:        V1.0
// Descriptions:        触摸屏顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/20 15:12:09
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_touch(
    //module clock 
    input             sys_clk,          // 系统时钟信号
    input             sys_rst_n,        // 复位信号（低有效）

    //tft interface
    inout             tft_sda,
    output            tft_scl,
    inout             tft_int,
    output            tft_tcs, 
    
    //touch lcd interface
    output            touch_done,
    output            touch_valid,      // 连续触摸标志
    output     [ 2:0] tp_num,
    output     [31:0] tp1_xy,
    output     [31:0] tp2_xy,
    output     [31:0] tp3_xy,
    output     [31:0] tp4_xy,
    output     [31:0] tp5_xy,
    
	//avalon 端口				
    input      [ 2:0] avl_address,      //地址
    input             avl_write,        //写请求
    input      [31:0] avl_writedata,    //写数据
    input             avl_read,         //读请求
    output     [31:0] avl_readdata     //读数据
);

//parameter define
parameter   WIDTH = 5'd8;

//wire define
wire                      i2c_exec  ;
wire                      i2c_rh_wl ;
wire    [15:0]            i2c_addr  ;
wire    [ 7:0]            i2c_data_w;
wire    [WIDTH-1'b1:0]    reg_num   ;
wire    [ 7:0]            i2c_data_r;
wire                      i2c_done  ;
wire                      once_done ;
wire                      clk       ;
wire                      cfg_done  ;
wire                      cfg_switch;


//*****************************************************
//**                    main code
//*****************************************************

gt9147_cfg #(.WIDTH(4'd8)
) u_gt9147_cfg(
    //system clock
    .clk                (sys_clk  ),           // 时钟信号
    .rst_n              (sys_rst_n),           // 复位信号
       
    //GT7147 interface     
    .scl                (tft_scl)      ,       // 时钟线scl
    .sda                (tft_sda)      ,       // 数据线sda

    //I2C interface
    .i2c_exec           (i2c_exec  ),          // i2c触发控制
    .i2c_rh_wl          (i2c_rh_wl ),          // i2c读写控制
    .i2c_addr           (i2c_addr  ),          // i2c操作地址
    .i2c_data_w         (i2c_data_w),          // i2c写入的数据
    .reg_num            (reg_num   ),
    .i2c_data_r         (i2c_data_r),          // i2c读出的数据
    .i2c_done           (i2c_done  ),          // i2c操作结束标志
    .once_done          (once_done ),          // 一次读写操作完成
    .clk_i2c            (clk       ),          // I2C操作时钟
    .cfg_done           (cfg_done  ),          // 寄存器配置完成标志
    //user interfacd
    .cfg_switch         (cfg_switch) 
);

gt9147_ctrl 
    #(.WIDTH(4'd8))                            // 一次读写寄存器的个数的位宽
U_gt9147_ctrl(
    //module clock 
    .sys_clk            (sys_clk),
    .clk                (clk      ),           // 时钟信号
    .rst_n              (sys_rst_n),           // 复位信号（低有效）
    .cfg_done           (cfg_done ),           // 配置完成标志
    .tft_tcs            (tft_tcs  ),       
    .tft_int            (tft_int  ),
  
    //I2C interface         
    .i2c_exec           (i2c_exec  ),          // i2c触发控制
    .i2c_rh_wl          (i2c_rh_wl ),          // i2c读写控制
    .i2c_addr           (i2c_addr  ),          // i2c操作地址
    .i2c_data_w         (i2c_data_w),          // i2c写入的数据
    .i2c_data_r         (i2c_data_r),          // i2c读出的数据
    .once_done          (once_done ),          // 一次读写操作完成
    .i2c_done           (i2c_done  ),          // i2c操作结束标志
    .reg_num            (reg_num   ),          // 一次读写寄存器的个数
    
    //touch lcd interface
    .touch_done         (touch_done),
    .touch_valid        (touch_valid),
    .tp_num             (tp_num),
    .tp1_xy             (tp1_xy),
    .tp2_xy             (tp2_xy),
    .tp3_xy             (tp3_xy),
    .tp4_xy             (tp4_xy),
    .tp5_xy             (tp5_xy),
    
    //user interface
    .cfg_switch         (cfg_switch),
  
    //avalon interface
    .avl_address        (avl_address),  
    .avl_writedata      (avl_writedata) ,
    .avl_write          (avl_write),
    .avl_read           (avl_read),
    .avl_readdata       (avl_readdata)
);

endmodule
