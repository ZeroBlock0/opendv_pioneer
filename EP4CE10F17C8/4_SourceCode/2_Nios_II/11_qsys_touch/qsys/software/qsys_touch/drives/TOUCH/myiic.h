//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           myiic.h
// Last modified Date:  2018/10/10 16:04:03
// Last Version:        V1.0
// Descriptions:        IIC 驱动代码的头文件
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/10 16:04:07
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#ifndef __MYIIC_H
#define __MYIIC_H
#include "delay.h"
#include "system.h"
#include "altera_avalon_pio_regs.h"

//IO方向设置
#define SDA_IN()  {IOWR_ALTERA_AVALON_PIO_DIRECTION(TOUCH_SDA_BASE,0x0);} //输入模式
#define SDA_OUT() {IOWR_ALTERA_AVALON_PIO_DIRECTION(TOUCH_SDA_BASE,0x1);} //输出模式

//IO 操作函数
#define IIC_SCL(x)  IOWR_ALTERA_AVALON_PIO_DATA(TOUCH_SCL_BASE,x)  //SCL
#define IIC_SDA(x)  IOWR_ALTERA_AVALON_PIO_DATA(TOUCH_SDA_BASE,x)  //写入SDA
#define READ_SDA    IORD_ALTERA_AVALON_PIO_DATA(TOUCH_SDA_BASE)    //读取 SDA

//IIC所有操作函数
void IIC_Init(void);                    //初始化IIC的IO口
void IIC_Start(void);                   //发送IIC开始信号
void IIC_Stop(void);                    //发送IIC停止信号
void IIC_Send_Byte(u8 txd);             //IIC发送一个字节
u8   IIC_Read_Byte(unsigned char ack);  //IIC读取一个字节
u8   IIC_Wait_Ack(void);                //IIC等待ACK信号
void IIC_Ack(void);                     //IIC发送ACK信号
void IIC_NAck(void);                    //IIC不发送ACK信号
#endif
