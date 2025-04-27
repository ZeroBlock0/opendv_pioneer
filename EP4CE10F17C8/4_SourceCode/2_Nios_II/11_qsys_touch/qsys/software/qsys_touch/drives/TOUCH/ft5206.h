//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ft5206.c
// Last modified Date:  2018/10/10 15:59:12
// Last Version:        V1.0
// Descriptions:        7寸电容触摸屏-FT5206/FT5426 驱动代码
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/10 15:59:18
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#ifndef __FT5206_H
#define __FT5206_H
#include "system.h"
#include "defines.h"
#include "mculcd.h"


//与电容触摸屏连接的芯片引脚(未包含IIC引脚) 
//IO操作函数
#define FT_RST(x)   IOWR_ALTERA_AVALON_PIO_DATA(TOUCH_TCS_BASE,x) //FT5206复位引脚
#define FT_INT(x)   IOWR_ALTERA_AVALON_PIO_DATA(TOUCH_INT_BASE,x) //FT5206断引脚
   
//I2C读写命令   
#define FT_CMD_WR               0X70        //写命令
#define FT_CMD_RD               0X71        //读命令
  
//FT5206 部分寄存器定义 
#define FT_DEVIDE_MODE          0x00        //FT5206模式控制寄存器
#define FT_REG_NUM_FINGER       0x02        //触摸状态寄存器

#define FT_TP1_REG              0X03        //第一个触摸点数据地址
#define FT_TP2_REG              0X09        //第二个触摸点数据地址
#define FT_TP3_REG              0X0F        //第三个触摸点数据地址
#define FT_TP4_REG              0X15        //第四个触摸点数据地址
#define FT_TP5_REG              0X1B        //第五个触摸点数据地址  
 

#define FT_ID_G_LIB_VERSION     0xA1        //版本        
#define FT_ID_G_MODE            0xA4        //FT5206中断模式控制寄存器
#define FT_ID_G_THGROUP         0x80        //触摸有效值设置寄存器
#define FT_ID_G_PERIODACTIVE    0x88        //激活状态周期设置寄存器


u8 FT5206_WR_Reg(u16 reg,u8 *buf,u8 len);
void FT5206_RD_Reg(u16 reg,u8 *buf,u8 len);
u8 FT5206_Init(void);
u8 FT5206_Scan(u8 mode);

#endif
