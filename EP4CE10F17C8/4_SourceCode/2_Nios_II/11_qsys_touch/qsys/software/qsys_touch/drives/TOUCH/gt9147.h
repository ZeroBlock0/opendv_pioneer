//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           gt9147
// Last modified Date:  2018/10/10 16:04:03
// Last Version:        V1.0
// Descriptions:        4.3寸电容触摸屏-GT9147 驱动代码
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/10 16:04:07
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

#ifndef __GT9147_H
#define __GT9147_H
#include "system.h"
#include "defines.h"
#include "mculcd.h"

//IO操作函数
#define GT9147_RST(x)       IOWR_ALTERA_AVALON_PIO_DATA(TOUCH_TCS_BASE,x) //GT9147复位引脚
#define GT9147_INT(x)       IOWR_ALTERA_AVALON_PIO_DATA(TOUCH_INT_BASE,x) //GT9147中断引脚
//设置PIO的方向
#define GT9147_INT_DIR(x)   IOWR_ALTERA_AVALON_PIO_DIRECTION(TOUCH_INT_BASE,x)

//I2C读写命令
#define GT_CMD_WR       0X28        //写命令
#define GT_CMD_RD       0X29        //读命令

//GT9147 部分寄存器定义
#define GT_CTRL_REG     0X8040      //GT9147控制寄存器
#define GT_CFGS_REG     0X8047      //GT9147配置起始地址寄存器
#define GT_CHECK_REG    0X80FF      //GT9147校验和寄存器
#define GT_PID_REG      0X8140      //GT9147产品ID寄存器

#define GT_GSTID_REG    0X814E      //GT9147当前检测到的触摸情况
#define GT_TP1_REG      0X8150      //第一个触摸点数据地址
#define GT_TP2_REG      0X8158      //第二个触摸点数据地址
#define GT_TP3_REG      0X8160      //第三个触摸点数据地址
#define GT_TP4_REG      0X8168      //第四个触摸点数据地址
#define GT_TP5_REG      0X8170      //第五个触摸点数据地址


u8 GT9147_Send_Cfg(u8 mode);                //发送GT9147配置参数
u8 GT9147_WR_Reg(u16 reg,u8 *buf,u8 len);   //向GT9147写入一次数据
void GT9147_RD_Reg(u16 reg,u8 *buf,u8 len); //从GT9147读出一次数据
u8 GT9147_Init(void);                       //初始化GT9147触摸屏
u8 GT9147_Scan(u8 mode);                    //扫描触摸屏(采用查询方式)
#endif
