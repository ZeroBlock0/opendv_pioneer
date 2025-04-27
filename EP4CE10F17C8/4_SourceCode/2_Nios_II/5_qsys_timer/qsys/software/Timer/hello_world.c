//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           Timer
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
// Modified date:       2019/1/21 15:57:00
// Version:
// Descriptions:		修改中断服务函数
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#include <stdio.h> 						//标准的输入输出头文件
#include "system.h" 					//系统头文件
#include "altera_avalon_timer_regs.h" 	//Timer 寄存器头文件
#include "altera_avalon_pio_regs.h" 	//PIO 寄存器头文件
#include "sys/alt_irq.h" 				//中断头文件

alt_u8 time_out = 0; //定时器计时结束标志

//定时器中断程序
void Timer_ISR_Interrupt(){
	time_out = 1;								   //定时器计时结束标志置1
	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_BASE,0); //清除状态寄存器
}

//定时器中断初始化函数
void Timer_initial(void){

	//设置定时器周期为1s，系统时钟周期为10ns，(0x5F5_E0FF + 1) * 10ns = 1s
	IOWR_ALTERA_AVALON_TIMER_PERIODH(TIMER_BASE, 0x05F5);
	IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_BASE, 0xE0FF);

	//设置CONTROL 寄存器
	IOWR_ALTERA_AVALON_TIMER_CONTROL(
			TIMER_BASE, ALTERA_AVALON_TIMER_CONTROL_ITO_MSK     //使能计时器中断
					  | ALTERA_AVALON_TIMER_CONTROL_CONT_MSK    //计时器连续运行
		              | ALTERA_AVALON_TIMER_CONTROL_START_MSK); //启动计时器

	//注册中断服务函数
	alt_ic_isr_register(
			TIMER_IRQ_INTERRUPT_CONTROLLER_ID, //中断控制器ID
			TIMER_IRQ,                         //硬件中断号
			Timer_ISR_Interrupt,               //中断服务程序
			0,                       		   //用于传递参数的结构体指针
			0);                                //保留位
}

int main(void){
	alt_u8 beep = 0; 		//蜂鸣器鸣叫状态

    Timer_initial();   		//初始化定时器中断

    while(1){
    	if(time_out == 1){  //定时器计时结束时,改变蜂鸣器状态
            beep = ~beep;
            IOWR_ALTERA_AVALON_PIO_DATA(PIO_BEEP_BASE, beep);
            time_out = 0;
        }
    }
}
