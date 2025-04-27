/*
 * rtc.c
 *
 *  Created on: 2018-8-27
 *      Author: Administrator
 */
#include "rtc.h"
#include "myiic.h"
#include "delay.h"

//十进制转换为BCD码
//val:要转换的十进制数
//返回值:BCD码
u8 RTC_DEC2BCD(u8 val)
{
	u8 bcdhigh = 0;
	while(val>=10)
	{
		bcdhigh++;
		val-=10;
	}
	return ((u8)(bcdhigh<<4)|val);
}
//BCD码转换为十进制数据
//val:要转换的BCD码
//返回值:十进制数据
u8 RTC_BCD2DEC(u8 val)
{
	u8 temp=0;
	temp=(val>>4)*10;
	return (temp+(val&0X0F));
}

//reg:寄存器地址
//val:要写入寄存器的值
//返回值:0,成功;
//    其他,错误代码
u8 RTC_Write_REG(u8 reg,u8 *buf, u8 len)
{
     u8 i;
     u8 ret=0;
     u8 data;
     IIC_Start();
     IIC_Send_Byte((RTC_ADDR<<1)|0);//发送器件地址+写命令
     if(IIC_Wait_Ack())return 1;	//等待应答(成功?/失败?)
     IIC_Send_Byte(reg);			//写寄存器地址
     if(IIC_Wait_Ack())return 2;	//等待应答(成功?/失败?)
     for(i=0;i<len;i++){
    	 data = RTC_DEC2BCD(buf[len-i-1]);
    	 IIC_Send_Byte(data);		//发送数据
    	 ret=IIC_Wait_Ack();	//等待应答(成功?/失败?)
    	 if(ret) break;
     }
     IIC_Stop();
     return 0;
}

//reg:起始寄存器地址
//buf:数据缓缓存区
//len:读数据长度
void RTC_Read_REG(u8 reg,u8 *buf,u8 len)
{
     u8 i;
     IIC_Start();
     IIC_Send_Byte((RTC_ADDR<<1)|0);   //发送写命令
     IIC_Wait_Ack();
     IIC_Send_Byte(reg);   	//发送高8位地址
     IIC_Wait_Ack();
     IIC_Start();
     IIC_Send_Byte(RTC_ADDR<<1|1);   //发送读命令
     IIC_Wait_Ack();
     for(i=0;i<len;i++)
     {
          buf[len-1-i]=IIC_Read_Byte(i==(len-1)?0:1); //发数据
     }
     IIC_Stop();//产生一个停止条件
}

//设置RTC时间
//*hour,*min,*sec:小时,分钟,秒钟
void RTC_Set_Time(u8 hour,u8 min,u8 sec)
{
	u8 rtc_time[3] = {hour,min,sec};
	RTC_Write_REG(2,rtc_time,3);
}

//获取RTC时间
//*hour,*min,*sec:小时,分钟,秒钟
void RTC_Get_Time(u8 *hour,u8 *min,u8 *sec)
{
	u8 rtc_time[3];
	RTC_Read_REG(2,rtc_time,3);

	*hour=RTC_BCD2DEC(rtc_time[0]&0X3F);
	*min=RTC_BCD2DEC(rtc_time[1]&0X7F);
	*sec=RTC_BCD2DEC(rtc_time[2]&0X7F);
}

//获取RTC日期
//*year,*mon,*date:年,月,日
//*week:星期
void RTC_Get_Date(u8 *year,u8 *month,u8 *date,u8 *week)
{
	u8 rtc_date[4];
	RTC_Read_REG(5,rtc_date,4);
	*year=RTC_BCD2DEC(rtc_date[0]&0XFF);
	*month=RTC_BCD2DEC(rtc_date[1]&0X1F);
	*date=RTC_BCD2DEC(rtc_date[3]&0X3F);
	*week=(rtc_date[2])&0X07;
}
