#ifndef __CALENDAR_H
#define __CALENDAR_H
#include "rtc.h"
#include "LCD.h"
#include "common.h"
//////////////////////////////////////////////////////////////////////////////////	 
//本程序只供学习使用，未经作者许可，不得用于其它任何用途
//ALIENTEK STM32开发板
//APP-日历 代码
//正点原子@ALIENTEK
//技术论坛:www.openedv.com
//创建日期:2014/7/20
//版本：V1.0
//版权所有，盗版必究。
//Copyright(C) 广州市星翼电子科技有限公司 2009-2019
//All rights reserved									  
//*******************************************************************************
//修改信息
//无
////////////////////////////////////////////////////////////////////////////////// 	   

//画笔颜色
#define BLUE		 0X001F
#define BRED         0XF81F
#define GRED		 0XFFE0
#define GBLUE		 0X07FF
#define RED		 0XF800
#define MAGENTA		 0XF81F
#define GREEN		 0X07E0
#define CYAN		 0X7FFF
#define YELLOW		 0XFFE0
#define BROWN		 0XBC40 //棕色
#define BRRED		 0XFC07 //棕红色
#define GRAY		 0X8430 //灰色
#define GRAYBLUE       	 0X5458 //灰蓝色

//时间结构体
typedef struct 
{
	u8 hour;
	u8 min;
	u8 sec;			
	//公历日月年周
	u16 w_year;
	u8  w_month;
	u8  w_date;
	u8  week;	//1~7,代表周1~周日
}_calendar_obj;
/*
//LCD重要参数集
typedef struct
{
	u16 width;			//LCD 宽度
	u16 height;			//LCD 高度
//	u16 id;				//LCD ID
//	u8  dir;			//横屏还是竖屏控制：0，竖屏；1，横屏。
//	u16	wramcmd;		//开始写gram指令
//	u16 setxcmd;		//设置x坐标指令
//	u16 setycmd;		//设置y坐标指令
}_lcd_dev;
*/
_calendar_obj calendar;	//日历结构体
#define GUI_LANGUAGE_NUM	   	3			//语言种类数
											//0,简体中文
											//1,繁体中文
											//2,英文
u8 RTC_Init(void);
void calendar_get_time(_calendar_obj *calendarx);
void calendar_get_date(_calendar_obj *calendarx);
void calendar_date_refresh(void);
//void calendar_circle_clock_drawpanel(u16 x,u16 y,u16 size,u16 d);
//void calendar_circle_clock_showtime(u16 x,u16 y,u16 size,u16 d,u8 hour,u8 min,u8 sec);
u8 calendar_play(void);
					    				   
#endif












