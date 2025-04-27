//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           sdram_rw_top
// Last modified Date:  2018/07/22 15:41:01
// Last Version:        V1.0
// Descriptions:        SDRAM顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/07/22 15:41:18
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module qsys_sdram(
    //module clock 
    input            sys_clk    ,        // 时钟信号
    input            sys_rst_n  ,        // 复位信号（低有效）
    
    //SDRAM interface
    output            sdram_clk  ,        //SDRAM 芯片时钟
    output            sdram_cke  ,        //SDRAM 时钟有效
    output            sdram_cs_n ,        //SDRAM 片选
    output            sdram_ras_n,        //SDRAM 行有效
    output            sdram_cas_n,        //SDRAM 列有效
    output            sdram_we_n ,        //SDRAM 写有效
    output   [ 1:0]   sdram_ba   ,        //SDRAM Bank地址
    output   [12:0]   sdram_addr ,        //SDRAM 行/列地址
    inout    [15:0]   sdram_data ,        //SDRAM 数据
    output   [ 1:0]   sdram_dqm           //SDRAM 数据掩码
);

//wire define
wire        clk_100m;                     //SDRAM 控制器时钟
wire        rst_n   ;                     //系统复位信号
wire        locked  ;                     //PLL输出稳定标志

//*****************************************************
//**                    main code
//*****************************************************

//待PLL输出稳定之后，停止系统复位
assign rst_n = sys_rst_n & locked;

//例化PLL
pll_clk u_pll_clk(
    .areset (~sys_rst_n),
    .inclk0 (sys_clk   ),
    .c0     (clk_100m  ),
    .c1     (sdram_clk ),
    .locked (locked    )
);

//例化Nios2系统模块
sdram u_sdram (
    .clk_clk          (clk_100m   ),    // 时钟100M
    .reset_reset_n    (rst_n      ),    // 复位信号
    .sdram_addr       (sdram_addr ),    // SDRAM 行/列地址
    .sdram_ba         (sdram_ba   ),    // SDRAM Bank地址
    .sdram_cas_n      (sdram_cas_n),    // SDRAM 列有效
    .sdram_cke        (sdram_cke  ),    // SDRAM 时钟有效
    .sdram_cs_n       (sdram_cs_n ),    // SDRAM 片选
    .sdram_dq         (sdram_data ),    // SDRAM 数据
    .sdram_dqm        (sdram_dqm  ),    // SDRAM 数据掩码
    .sdram_ras_n      (sdram_ras_n),    // SDRAM 行有效
    .sdram_we_n       (sdram_we_n )     // SDRAM 写有效
);

endmodule
