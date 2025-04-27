//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           qsys_CAN
// Last modified Date:  2018/12/18 15:53:38
// Last Version:        V1.0
// Descriptions:        Qsys CAN通信实验顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/12/18 15:53:40
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module qsys_CAN(
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
    output            epcs_dclk  ,        // EPCS 时钟信号
    output            epcs_sce   ,        // EPCS 片选信号
    output            epcs_sdo   ,        // EPCS 数据输出信号
    input             epcs_data0 ,        // EPCS 数据输入信号

    //can interface
    input             can_rx     ,        // CAN接收引脚
    output            can_tx     ,        // CAN发送引脚

    //segled interface
    output    [ 5:0]  sel        ,        // 数码管位选端
    output    [ 7:0]  seg_led    ,        // 数码管段选端

    //key interface
    input             key2                // 使能CAN发送信号
);

//wire define
wire        clk_100m;                     //SDRAM 控制器时钟
wire        can_clk ;                     //CAN驱动器的时钟
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
    .c2     (can_clk   ),                 // CAN控制器驱动时钟16MHz
    .locked (locked    )
);

//例化Nios2系统模块
system_qsys u_system_qsys(
    .clk_clk          (clk_100m   ),      // 时钟100M
    .reset_reset_n    (rst_n      ),      // 复位信号

    .sdram_addr       (sdram_addr ),      // SDRAM 行/列地址
    .sdram_ba         (sdram_ba   ),      // SDRAM Bank地址
    .sdram_cas_n      (sdram_cas_n),      // SDRAM 列有效
    .sdram_cke        (sdram_cke  ),      // SDRAM 时钟有效
    .sdram_cs_n       (sdram_cs_n ),      // SDRAM 片选
    .sdram_dq         (sdram_data ),      // SDRAM 数据
    .sdram_dqm        (sdram_dqm  ),      // SDRAM 数据掩码
    .sdram_ras_n      (sdram_ras_n),      // SDRAM 行有效
    .sdram_we_n       (sdram_we_n ),      // SDRAM 写有效

    .epcs_dclk        (epcs_dclk  ),      // EPCS 时钟信号
    .epcs_sce         (epcs_sce   ),      // EPCS 片选信号
    .epcs_sdo         (epcs_sdo   ),      // EPCS 数据输出信号
    .epcs_data0       (epcs_data0 ),      // EPCS 数据输入信号

    .can_clk_i_clk    (can_clk    ),      // can_clk_in
    .can_rt_rx        (can_rx     ),      // can_rt.rx
    .can_rt_tx        (can_tx     ),      //       .tx
    .can_clk_out_clk  (           ),      // can_clk_out

    .can_tx_en_export (key2       ),      // 使能CAN发送信号

    .segled_sel       (sel        ),      // 数码管位选端
    .segled_seg_led   (seg_led    )       // 数码管段选端
);

endmodule