//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           top_qsys_ip_segled
// Last modified Date:  2018/08/06 9:09:27
// Last Version:        V1.0
// Descriptions:        自定义IP核实验顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/06 9:09:30
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_qsys_ip_segled(
    input        sys_clk,      // 时钟
    input        sys_rst_n,    // 复位

    output [5:0] sel,          // 数码管位选端
    output [7:0] seg_led       // 数码管段选端
);

//*****************************************************
//**                    main code
//*****************************************************

//例化Qsys系统
system_qsys u0 (
    .clk_clk            (sys_clk  ),   // 时钟
    .reset_reset_n      (sys_rst_n),   // 复位
   
    .segled_sel         (sel      ),   // 数码管位选端
    .segled_seg_led     (seg_led  )    // 数码管段选端
    );


endmodule