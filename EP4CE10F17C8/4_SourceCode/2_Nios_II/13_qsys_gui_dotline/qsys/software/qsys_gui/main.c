//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           gui_main.c
// Last modified Date:  2018/11/30 14:07:58
// Last Version:        V1.0
// Descriptions:        uC/GUI实现打点画线
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/11/30 14:07:32
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#include <stdio.h>
#include "system.h"
#include "mculcd.h"
#include "GUI.h"

_lcd_gui lcdgui;
extern _lcd_dev lcddev;     //管理LCD重要参数

//SDRAM显存的地址
alt_u16 *ram = (alt_u16 *)(SDRAM_BASE + SDRAM_SPAN - 2049000);

int main()
{
    printf("Hello from NiosII!\n");

    MY_LCD_Init();                      //LCD初始化
    GUI_Init();                         //uC/GUI初始化

    lcdgui.width  = lcddev.height;
    lcdgui.height = lcddev.width;

    GUI_SetBkColor(GUI_VERYLIGHTCYAN);  //设置GUI背景色
    GUI_Clear();                        //GUI清屏

    GUI_SetPenSize(10);                 //设置点的大小
    GUI_SetColor(GUI_RED);              //设置GUI前景色
    GUI_DrawPoint(lcdgui.width/2,lcdgui.height/2);   //画点
    GUI_DrawLine(0,lcdgui.height/2 + 11,lcdgui.width,lcdgui.height/2 + 11);  //画线

    alt_dcache_flush_all();

    return 0;
}
