//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           qsys_lcd.c
// Last modified Date:  2018/10/10 14:29:57
// Last Version:        V1.0
// Descriptions:        TFTLCD的Nios II驱动主程序
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/10 14:29:42
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#include <stdio.h>
#include <unistd.h>
#include "./drive/mculcd.h"
#include "pic01.h"          //显示的图片

int main()
{
	printf("Hello from Nios II!\n");
	MCULCD_Init();
    POINT_COLOR=MLCD_RED;

    LCD_DisplayPic(0,0,lcddev.width * lcddev.height,gImage_pic01);

    LCD_ShowString(30,50,300,30,24,1,"Welcome to PIONEER FPGA");
    LCD_ShowString(30,80,400,30,24,1,"This is a TFT LCD test application");
    LCD_ShowString(30,110,200,30,24,1,"ATOM@ALIENTEK");
    LCD_ShowString(30,140,200,30,24,1,"2018/10/10");

    return 0;
}
