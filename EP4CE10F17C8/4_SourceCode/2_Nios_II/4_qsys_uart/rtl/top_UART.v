//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           top_UART
// Last modified Date:  2018/7/25 9:26:44
// Last Version:        V1.0
// Descriptions:        UART实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/7/25 9:26:47
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

module top_UART(
    input             sys_clk    ,
	 input             sys_rst_n  ,

//UART端口    
	 input             rxd        ,   //UART 接收端
    output            txd            //UART 发送端
);

//wire define
wire  clk_100m;                      //100mHZ时钟

//例化pll模块，用以产生
pll	pll_inst (
	 .inclk0         (sys_clk) ,              
	 .c0             (clk_100m)
	 );	

//例化UART核
UART u0 (
    .clk_clk        (clk_100m),      //   clk.clk
    .reset_reset_n  (sys_rst_n),     //   reset.reset_n
    .uart_rxd       (rxd),           //   uart.rxd
    .uart_txd       (txd)            //   .txd
    );
	
endmodule	
