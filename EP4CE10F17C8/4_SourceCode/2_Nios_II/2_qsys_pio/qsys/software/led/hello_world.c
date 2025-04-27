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

#include <stdio.h>
#include "system.h" //系统头文件
#include "alt_types.h" //数据类型头文件
#include "altera_avalon_pio_regs.h"//pio 寄存器头文件

 int main(void)
 {
  alt_u32 key,led; //key和led缓存变量
  while(1)
  {
  //读取按键的值，并赋值给key。
  key = IORD_ALTERA_AVALON_PIO_DATA(PIO_KEY_BASE);
  //Key按下时为低电平，没有按下时为高电平。Led在高电平时亮，低电平灭。我们要将按键的值按位取反后，再赋值给led。
  led = ~key;
  //用led的值控制Led亮灭。
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, led);
  }

  return(0);
}
