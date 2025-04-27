//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           main.c
// Last modified Date:  2019/3/18 14:07:58
// Last Version:        V1.0
// Descriptions:        uC/GUI示波器UI界面
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/3/18 14:07:58
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#include <stdio.h>
#include "system.h"
#include "io.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "unistd.h"
#include <string.h>
#include "GUI.h"
#include "draw_disp.h"
#include "touch.h"
#include "altera_avalon_timer_regs.h" //定时器头文件

extern _lcd_dev lcddev;	    //LCD参数

//SDRAM显存的地址
alt_u16 *ram = (alt_u16 *)(SDRAM_BASE + SDRAM_SPAN - 2049000);

alt_u16 touch;              //是否有触摸操作
alt_u16 x_pos;              //当前x坐标
alt_u16 y_pos;              //当前y坐标
alt_u32 tp_pos = 0;		    //当前触点数据
alt_u32 tp_pos_pre = 0;	    //上一次触点数据
alt_u16 timer_flag = 0;     //定时器中断标志

alt_u32 timer_isr_context;  //定义全局变量以储存 isr_context 指针

void Timer_initial(void);   //定时器中断初始化
void Timer_ISR_Interrupt(void* isr_context , alt_u32 id); //定时器中断服务子程序
void init_tp_interrupt();   //触摸中断初始化

//LCD触摸中断程序
void tp_interrupt(void* context){
    tp_pos_pre = tp_pos;
    tp_pos = IORD(AVALON_MM_BRIDGE_0_BASE,1);

    if(tp_pos != tp_pos_pre){	//对同一坐标点长时间触摸时，只输出一次坐标
        x_pos = tp_pos>>16;
        y_pos = tp_pos&0xffff;
        touch = 1;

//        printf("x=%d, y=%d\n",x_pos,y_pos);
    }
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_TP_INT_BASE, 0x1); //清除边沿捕获寄存器
}

int main()
{
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_LCD_RST_BASE,0);  //LCD复位
    GUI_Init();                         //uC/GUI初始化
    GUI_UC_SetEncodeUTF8();             //设置字体
    GUI_SetFont(&GUI_FontChinese_ST16);
    init_tp_interrupt();                //触摸中断初始化
    Timer_initial();                    //定时器中断初始化

    lcddev.width  = 480;                //4.3'屏宽度
    lcddev.height = 272;                //4.3'屏高度
    IOWR_ALTERA_AVALON_PIO_DATA(PIO_LCD_RST_BASE,1);  //LCD结束复位
    Draw_Display();                     //绘制显示界面
    SendCfgPara();                      //配置硬件参数
    while(1){
    	if(touch)                       //检测到触摸中断
    	{
    		TouchPro(x_pos,y_pos);      //触摸处理
    		touch = 0;                  //清除触摸标志
    	}
    	                                //定时器定时完成并且示波器正在运行
    	if(timer_flag && dispdev.run_flag == 1){
    		GetDataDisp();              //获取硬件数据
    		timer_flag = 0;             //定时器标志清零
    	}
    }
    return 0;
}

/************************************************************
*
*           触摸屏中断函数
*
*************************************************************
*/

//触摸中断初始化
void init_tp_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_TP_INT_BASE, 0x1); //开触摸中断
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_TP_INT_BASE, 0x1); //清除边沿捕获寄存器
    alt_ic_isr_register(
        PIO_TP_INT_IRQ_INTERRUPT_CONTROLLER_ID, //中断控制器标号
        PIO_TP_INT_IRQ,							//硬件中断号
        tp_interrupt,							//中断服务函数
        NULL,									//指向与设备驱动实例相关的结构体，一般为NULL
        0										//保留位，设置为0
        );
}

/************************************************************
*
*           定时器中断函数
*
*************************************************************
*/

//定时器中断函数
void Timer_ISR_Interrupt(void* timer_isr_context, alt_u32 id)
{
	timer_flag = 1;
	//应答中断，将 STATUS 寄存器清零,ALTERA_AVALON_TIMER_STATUS_TO_MSK=0x1
	IOWR_ALTERA_AVALON_TIMER_STATUS(TIMER_BASE,~ALTERA_AVALON_TIMER_STATUS_TO_MSK);
}

//初始化定时器中断
void Timer_initial(void)
{
	//改写 timer_isr_context 指针以匹配 alt_irq_register()函数原型
	void* isr_context_ptr = (void*) &timer_isr_context;
	//设置 PERIOD 寄存器
	//PERIODH | PERIODL = 计数器周期因子 * 系统时钟频率因子 - 1
	//PERIODH | PERIODL = 0.3s*100M - 1 = 29999999 = 0x01C9_C37F(定时300ms)
	IOWR_ALTERA_AVALON_TIMER_PERIODH(TIMER_BASE, 0x01C9);
	IOWR_ALTERA_AVALON_TIMER_PERIODL(TIMER_BASE, 0xC37F);
	//设置 CONTROL 寄存器
	IOWR_ALTERA_AVALON_TIMER_CONTROL(TIMER_BASE,
	ALTERA_AVALON_TIMER_CONTROL_START_MSK | //0x4,START = 1,计数器开始运行
	ALTERA_AVALON_TIMER_CONTROL_CONT_MSK | //0x2,CONT = 1,计数器连续运行直到 STOP位被置 1
	ALTERA_AVALON_TIMER_CONTROL_ITO_MSK); //0x1,ITO = 1，产生 IRQ

	//注册定时器中断
	alt_ic_isr_register(
	TIMER_IRQ_INTERRUPT_CONTROLLER_ID, //中断控制器标号，从 system.h 复制
	TIMER_IRQ, //硬件中断号，从 system.h 复制
	Timer_ISR_Interrupt, //中断服务子函数
	isr_context_ptr, //指向与设备驱动实例相关的数据结构体
	0); //flags，保留未用
}


