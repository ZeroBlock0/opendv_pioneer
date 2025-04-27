#ifndef __DAC_H
#define __DAC_H	 
#include "common.h"
#include "myiic.h"
//////////////////////////////////////////////////////////////////////////////////	 
//本程序只供学习使用，未经作者许可，不得用于其它任何用途
//ALIENTEK STM32开发板
//DAC 驱动代码	   
//正点原子@ALIENTEK
//技术论坛:www.openedv.com
//创建日期:2015/12/27
//版本：V1.0
//版权所有，盗版必究。
//Copyright(C) 广州市星翼电子科技有限公司 2014-2024
//All rights reserved 
////////////////////////////////////////////////////////////////////////////////// 	
#define PCF8591_ADDR 0X48<<1
#define CONTORL_BYTE 0x40

u8 PCF8591_Write_Reg(u8 vol);
u8 PCF8591_Read_Reg(void);
#endif
