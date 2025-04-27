//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           irq
// Last modified Date:  2018/7/22 9:26:44
// Last Version:        V1.0
// Descriptions:        中断实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/7/22 9:26:47
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

module Pio_irq(
    input  sys_clk     ,
	 input  sys_rst_n   ,

	 input  key         ,
    output [3:0] led
);

//wire define
wire  clk_100M;

//锁相环
pll	pll_inst (
	.inclk0 (sys_clk),
	.c0     (clk_100M)
);

//例化Qsys系统
irq u0 (
   .clk_clk        (clk_100M),        // clk.clk
   .reset_reset_n  (sys_rst_n),       // reset.reset_n
   .pio_led_export (led),             // pio_led.export
   .pio_key_export (~key)             // pio_key.export
);

endmodule