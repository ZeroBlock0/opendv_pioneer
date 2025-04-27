//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           qsys_lcd
// Last modified Date:  2018/09/29 9:14:29
// Last Version:        V1.0
// Descriptions:        Qsys MCU LCD屏的使用
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/09/29 9:14:29
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module qsys_lcd(
    //module clock
    input             sys_clk    ,        //系统时钟，50Mhz
    input             sys_rst_n  ,        //系统复位，低电平有效

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
    output   [ 1:0]   sdram_dqm  ,        //SDRAM 数据掩码

    //EPCS FLASH interface
    output            epcs_dclk ,         // EPCS 时钟信号
    output            epcs_sce  ,         // EPCS 片选信号
    output            epcs_sdo  ,         // EPCS 数据输出信号
    input             epcs_data0,         // EPCS 数据输入信号

    //MCU LCD interface
    inout    [15:0]   mlcd_data ,         // LCD 数据信号
    output            mlcd_bl   ,         // LCD 背光信号
    output            mlcd_cs_n ,         // LCD 片选信号
    output            mlcd_wr_n ,         // LCD 写信号
    output            mlcd_rd_n ,         // LCD 读信号
    output            mlcd_rs   ,         // LCD 命令/数据信号
    output            mlcd_rst_n          // LCD 复位信号
    //user interface

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
nios2os u_nios2os (
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
    .sdram_we_n       (sdram_we_n ),    // SDRAM 写有效
    .epcs_dclk        (epcs_dclk  ),    // EPCS 时钟信号
    .epcs_sce         (epcs_sce   ),    // EPCS 片选信号
    .epcs_sdo         (epcs_sdo   ),    // EPCS 数据输出信号
    .epcs_data0       (epcs_data0 ),    // EPCS 数据输入信号
    .mlcd_data_export (mlcd_data  ),    // LCD 数据信号
    .mlcd_cs_n_export (mlcd_cs_n  ),    // LCD 片选信号
    .mlcd_wr_n_export (mlcd_wr_n  ),    // LCD 写信号
    .mlcd_rd_n_export (mlcd_rd_n  ),    // LCD 读信号
    .mlcd_rst_n_export(mlcd_rst_n ),    // LCD 复位信号
    .mlcd_rs_export   (mlcd_rs    ),    // LCD 命令/数据信号
    .mlcd_bl_export   (mlcd_bl    )     // LCD 背光信号
);

endmodule