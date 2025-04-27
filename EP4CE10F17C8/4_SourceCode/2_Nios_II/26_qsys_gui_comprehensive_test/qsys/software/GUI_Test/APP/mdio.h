#ifndef __MDIO_H
#define __MDIO_H
#include "common.h"

//////////////////////////////////////////////////////////////////////////////////	 
//本程序只供学习使用，未经作者许可，不得用于其它任何用途
//ALIENTEK STM32开发板
//IIC 驱动代码	   
//正点原子@ALIENTEK
//技术论坛:www.openedv.com
//创建日期:2015/12/27
//版本：V1.0
//版权所有，盗版必究。
//Copyright(C) 广州市星翼电子科技有限公司 2014-2024
//All rights reserved									  
////////////////////////////////////////////////////////////////////////////////// 	

//IO方向设置
#define MDIO_IN()  {IOWR_ALTERA_AVALON_PIO_DIRECTION(PIO_MDIO_BASE,0x0);}   //输入模式
#define MDIO_OUT() {IOWR_ALTERA_AVALON_PIO_DIRECTION(PIO_MDIO_BASE,0x1);}   //输出模式
#define MDIO_READ  2
#define MDIO_WRITE 1 

//IIC所有操作函数
void mdc_wr(u8 mdc);                
void mdio_wr(u8 mdio);
u8 mdio_rd(void);
void mdio_send_bit(u8 bit);
u8 mdio_get_bit();
mdio_send_num(u16 value,u8 bits);
u16 mdio_get_num(u8 bits);
void mdio_set_turnaround(void);
void mdio_cmd(u8 op,u8 phy,u16 reg);
u16 mdio_read(u8 phy,u16 reg);
u16 mdio_write(u8 phy,u16 reg,u16 val);
#endif
