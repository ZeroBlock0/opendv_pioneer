#include "dac.h"
//////////////////////////////////////////////////////////////////////////////////	 
//本程序只供学习使用，未经作者许可，不得用于其它任何用途
//ALIENTEK STM32开发板
//DAC 驱动代码	   
//正点原子@ALIENTEK
//技术论坛:www.openedv.com
//创建日期:2015/12/27
//版本：V1.0
//版权所有，盗版必究。
//Copyright(C) 广州市星翼电子科技有限公司 2014-2024
//All rights reserved 
////////////////////////////////////////////////////////////////////////////////// 	


u8 PCF8591_Write_Reg(u8 vol)
{
	IIC_Start();
	IIC_Send_Byte(PCF8591_ADDR|0);	    //发送写命令
    if(IIC_Wait_Ack())          //等待应答
    {
        IIC_Stop();
        return 1;
    }
    IIC_Send_Byte(CONTORL_BYTE);         //写寄存器地址
    IIC_Wait_Ack();             //等待应答
    IIC_Send_Byte(vol);        //发送数据
    if(IIC_Wait_Ack())          //等待ACK
    {
        IIC_Stop();
        return 1;
    }
    IIC_Stop();
    return 0;

}

//设置通道1输出电压
u8 PCF8591_Read_Reg(void)
{
	u8 vol;
	IIC_Start();
	IIC_Send_Byte(PCF8591_ADDR|1);	    //发送写命令
    if(IIC_Wait_Ack())          //等待应答
    {
        IIC_Stop();
        return 1;
    }
    vol=IIC_Read_Byte(0);		//读数据,发送nACK
    IIC_Stop();                 //产生一个停止条件
    return vol;
}


