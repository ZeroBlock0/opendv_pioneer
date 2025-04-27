//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                
//----------------------------------------------------------------------------------------
// File name:           Pio_led
// Last modified Date:  2018/7/9 16:08:52
// Last Version:        V1.0
// Descriptions:        hello_world顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/7/9 16:08:52
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

module Pio_led(
    input  sys_clk,
	 input  sys_rst_n,
	 
	 //flash
	 input  flash_data0,
	 output flash_sdo,
	 output flash_sce,
	 output flash_dclk,
	 
	 input  [3:0] key,
	 output [3:0] led
);

//wire define
wire  clk_100m ;

//例化pll（锁相环)IP核
pll	pll_inst (
	.inclk0         ( sys_clk ),
	.c0             ( clk_100m )
);

//例化Qsys系统
led u0 (
   .clk_clk          (clk_100m ),          //      clk.clk
   .reset_reset_n    (sys_rst_n),          //      reset.reset_n
   .epcs_flash_dclk  (flash_dclk),         //      epcs_flash.dclk
   .epcs_flash_sce   (flash_sce),          //      .sce
   .epcs_flash_sdo   (flash_sdo),          //      .sdo
   .epcs_flash_data0 (flash_data0),        //      .data0
   .pio_led_export   (led),                //      pio_led.export
   .pio_key_export   (key)                 //      pio_key.export
);

endmodule