#ifndef __AP3216C_H
#define __AP3216C_H

#include "common.h"
#include "myiic.h"

//////////////////////////////////////////////////////////////////////////////////
//本程序只供学习使用，未经作者许可，不得用于其它任何用途
//ALIENTEK STM32开发板
//AP3216C驱动代码
//正点原子@ALIENTEK
//技术论坛:www.openedv.com
//创建日期:2015/12/28
//版本：V1.0
//版权所有，盗版必究。
//Copyright(C) 广州市星翼电子科技有限公司 2014-2024
//All rights reserved
//////////////////////////////////////////////////////////////////////////////////

#define AP3216C_ADDR    0X3C	//AP3216C器件IIC地址(左移了一位)

//=======================================================
//以下为测试部分
//数据结构体
typedef struct
{
	u16 ir;
	u16 ps;
	u16 als;
}_ap3216;

_ap3216 ap3216;	//数据结构体

void ap3216_data_get(_ap3216 *ap3216x);
//=======================================================

u8 AP3216C_Init(void);
u8 AP3216C_WriteOneByte(u8 reg,u8 data);
u8 AP3216C_ReadOneByte(u8 reg);
void AP3216C_ReadData(u16* ir,u16* ps,u16* als);
#endif
