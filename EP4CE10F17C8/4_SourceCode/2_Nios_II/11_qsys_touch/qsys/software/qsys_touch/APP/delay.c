//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           delay.c
// Last modified Date:  2018/10/23 9:52:50
// Last Version:        V1.0
// Descriptions:        延时函数文件
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/23 9:52:50
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#include "delay.h"
#include <unistd.h>

//延时函数，单位毫秒
void delay_ms(u32 n)
{
    usleep(n*1000);
}

//延时函数，单位微秒
void delay_us(u32 n)
{
    usleep(n);
}