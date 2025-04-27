//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           top_Timer
// Last modified Date:  2018/7/29 9:26:44
// Last Version:        V1.0
// Descriptions:        定时器实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/7/29 9:26:47
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         正点原子
// Modified date:     
// Version:         
// Descriptions:      
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_Timer(
    input   sys_clk,
    input   sys_rst_n,

    output  beep        //蜂鸣器
);

//wire define
wire  clk_100m;         

//例化pll模块
pll	u_pll(
    .inclk0             (sys_clk),              
    .c0                 (clk_100m)
    );	

//例化Qsys系统
qsys_timer u_qsys_timer(
    .clk_clk            (clk_100m),
    .reset_reset_n      (sys_rst_n),
    
    .pio_beep_export    (beep) 
    );
	
endmodule 