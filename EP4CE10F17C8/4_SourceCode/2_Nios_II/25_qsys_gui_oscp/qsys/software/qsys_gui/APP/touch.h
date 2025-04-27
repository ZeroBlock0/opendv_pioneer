//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           touch.h
// Last modified Date:  2019/3/6 13:32:30
// Last Version:        V1.0
// Descriptions:        触摸
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:      
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#ifndef TOUCH_H
#define TOUCH_H

#include "system.h"
#include "altera_avalon_pio_regs.h"

#define   u8   unsigned char
#define   u16  unsigned int
#define   u32  unsigned long
#define   s8   char
#define   s16  int
#define   s32  long

//触摸按键功能
#define TP_AUTO		 0
#define TP_RUN_STOP  1 
#define TP_LEFT      2 
#define TP_RIGHT     3 
#define TP_UP        4 
#define TP_DOWN      5 
#define TP_HOR_ADD   6 
#define TP_HOR_SUB   7 
#define TP_VER_ADD   8 
#define TP_VER_SUB   9 
#define TP_TRIG_ADD  10
#define TP_TRIG_SUB  11
#define TP_EDGE 	 12

void TouchPro(alt_u16 x_pos,alt_u16 y_pos);
void TouchAUTOPro(void);
void TouchFBRunDisp(void);
void TouchFBTrigTypeDisp(void);
void TouchFBStringDisp(const char *s, int x, int y,unsigned long BkColor);

#endif







