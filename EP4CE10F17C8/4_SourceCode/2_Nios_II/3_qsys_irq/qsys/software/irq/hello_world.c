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

#include <stdio.h>
#include "system.h"                 //系统头文件
#include "altera_avalon_pio_regs.h" //pio 寄存器头文件
#include "sys/alt_irq.h"            //中断头文件
#include "unistd.h"                 //延迟头文件

void IRQ_Init();                    //中断初始化函数
void IRQ_Key_Interrupts();          //中断服务子程序

int main(void)
{
	alt_u8 led,i;                   //有符号8 位整数
    IRQ_Init();                     //初始化PIO 中断
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 0x0F); //初始化LED 全亮
    //流水灯
    while(1)
  {
    for(i=0;i<4;i++)
    {
    	led = 1 << i;               //从低位到高位移位
        IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, led);
        usleep(100000);             //延迟一段时间
    }
  }
}


void IRQ_Init()
{
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_KEY_BASE, 0x01); // 使能中断
    // 注册ISR
    alt_ic_isr_register(
    PIO_KEY_IRQ_INTERRUPT_CONTROLLER_ID, // 中断控制器标号，从system.h 复制
    PIO_KEY_IRQ,                         // 硬件中断号，从system.h 复制
    IRQ_Key_Interrupts,                  // 中断服务子函数
    0x0,                                 // 指向与设备驱动实例相关的数据结构体
    0x0);                                // flags，保留未用
}

void IRQ_Key_Interrupts()
{
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 0x0f);//中断函数，让LED 全亮
}
