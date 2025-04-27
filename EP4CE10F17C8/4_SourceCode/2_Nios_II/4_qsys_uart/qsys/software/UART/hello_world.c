//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           UART
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

#include <stdio.h>
#include "unistd.h"
#include "system.h"
#include "alt_types.h"
#include "altera_avalon_uart_regs.h"
#include "sys\alt_irq.h"
#include "stddef.h"
#include "priv/alt_legacy_irq.h"
static alt_u8 txdata = 0;
static alt_u8 rxdata = 0;

void IRQ_UART_Interrupts();             //中断初始化函数
void IRQ_init();                        //中断服务子程序

int main()
{
    printf("Hello from Nios II!\n");
    IRQ_init();
    return 0;
}

void IRQ_init()
{
    //清除状态寄存器
    IOWR_ALTERA_AVALON_UART_STATUS(UART_BASE,0);
    //使能接受准备好中断,给控制寄存器相应位写1
    IOWR_ALTERA_AVALON_UART_CONTROL(UART_BASE,0X80);
	// 注册ISR
	alt_ic_isr_register(
    UART_IRQ_INTERRUPT_CONTROLLER_ID,  // 中断控制器标号，从system.h 复制
    UART_IRQ                        ,  // 硬件中断号，从system.h 复制
	IRQ_UART_Interrupts             ,  // 中断服务子函数
	0x0                             ,  // 指向与设备驱动实例相关的数据结构体
	0x0);                              // flags，保留未用
}

//UART中断服务函数
void IRQ_UART_Interrupts()
{
	//将radata寄存器中存储的值读入变量rxdata中
    rxdata = IORD_ALTERA_AVALON_UART_RXDATA(UART_BASE);
    //进行串口自收发，将变量rxdata中的值赋值给变量txdata
    txdata = rxdata;
    //查询发送准备好信号，如果没有准备好，则等待。
    while(!(IORD_ALTERA_AVALON_UART_STATUS(UART_BASE)&
    		ALTERA_AVALON_UART_STATUS_TRDY_MSK));
    //发送准备好，发送txdata
    IOWR_ALTERA_AVALON_UART_TXDATA(UART_BASE,txdata);
}
