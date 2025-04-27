//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           qsys_hello_world
// Last modified Date:  2018/9/9 16:08:52
// Last Version:        V1.0
// Descriptions:        hello_world顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/9/9 16:08:52
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:       正点原子
// Modified date:     
// Version:         
// Descriptions:      
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module qsys_hello_world(
    input  sys_clk,     //晶振时钟，50Mhz
    input  sys_rst_n    //按键复位，低电平有效
);

//wire define
wire clk_100m;          //Qsys系统时钟，100Mhz

//例化pll IP核
pll	u_pll(
    .inclk0         (sys_clk),
    .c0             (clk_100m)
);

//例化Qsys系统
system_qsys u_qsys(
    .clk_clk        (clk_100m),
    .reset_reset_n  (sys_rst_n)
);

endmodule 