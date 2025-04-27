#include "calendar.h" 	      						  
#include "stdio.h"
//#include "ds18b20.h"
#include "math.h"
#include "rtc.h"
#include "gui.h"
#include "../draw_page.h"

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
 
extern _calendar_obj calendar;	//日历结构体

static u16 TIME_TOPY;		//	120
static u16 OTHER_TOPY;		//	200 	

//LCD的画笔颜色和背景色
 u32 POINT_COLOR;		//画笔颜色
 u32 BACK_COLOR;  	//背景色

extern alt_u16 page_next;


u8*const calendar_week_table[2][7]=
{
{"星期天","星期一","星期二","星期三","星期四","星期五","星期六"},
{"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"},
};

u8*const calendar_loading_str[2][3]=
{
{
	"正在加载,请稍候...",
	"检测DS18B20!",

},
{
	"Loading...",
	"DS18B20 Check Failed!",
},
};	 
//u8 date_time[7]={18,8,1,28,9,30,30};

//初始化RTC
//返回值:0,初始化成功
//      1,初始化失败
u8 RTC_Init(void)
{
	u8 hour = 9,min=30,sec=0;
	RTC_Set_Time(hour,min,sec);    //9:30:00
	calendar_get_time(&calendar);	//更新时间
	if(hour == calendar.hour && min==calendar.min)
		return 0;                  //RTC初始化成功
	else
		return 1;				   //RTC初始化失败
}

//得到时间
//calendarx:日历结构体
void calendar_get_time(_calendar_obj *calendarx)
{
	RTC_Get_Time(&calendarx->hour,&calendarx->min,&calendarx->sec);//得到时间
}
//得到日期
//calendarx:日历结构体
void calendar_get_date(_calendar_obj *calendarx)
{
	u8 year;
	RTC_Get_Date(&year,&calendarx->w_month,&calendarx->w_date,&calendarx->week);
	calendarx->w_year=year+2000;//从2000年开始算起
}
//根据当前的日期,更新日历表.
void calendar_date_refresh(void) 
{
 	u8 weekn;   //周寄存
	u16 offx=(480-240)/2;
 	//显示阳历年月日
	GUI_SetFont(&GUI_FontChinese_WRYH32);
	GUI_SetBkColor(GUI_BLACK);
	GUI_SetColor(BRED);
	GUI_DispDecAt((calendar.w_year/100),offx+10,OTHER_TOPY+9,2);//显示年  20/19
	GUI_DispDecAt(calendar.w_year%100,offx+42,OTHER_TOPY+9,2);     //显示年
	GUI_DispStringAt("-",offx+74,OTHER_TOPY+9); //"-"
	GUI_DispDecAt(calendar.w_month,offx+90,OTHER_TOPY+9,2);     //显示月
	GUI_DispStringAt("-",offx+122,OTHER_TOPY+9); //"-"
	GUI_DispDecAt(calendar.w_date,offx+138,OTHER_TOPY+9,2);      //显示日
	//显示周几?
	GUI_SetColor(GUI_RED);
	weekn=calendar.week;
    GUI_DispStringAt(calendar_week_table[0][weekn],5+offx,OTHER_TOPY+35); //显示周几?
													 
}

//画圆形指针表盘
//x,y:坐标中心点
//size:表盘大小(直径)
//d:表盘分割,秒钟的高度
void calendar_circle_clock_drawpanel(u16 x,u16 y,u16 size,u16 d)
{
	u16 r=size/2;//得到半径
	u16 sx=x-r;
	u16 sy=y-r;
	u16 px0,px1;
	u16 py0,py1; 
	u16 i; 
	GUI_SetColor(GUI_WHITE);
	GUI_AA_FillCircle(x,y,r);		//画外圈
	GUI_SetColor(GUI_BLACK);
	GUI_AA_FillCircle(x,y,r-4);		//画内圈
	for(i=0;i<60;i++)//画秒钟格
	{ 
		px0=sx+r+(r-4)*sin((app_pi/30)*i); 
		py0=sy+r-(r-4)*cos((app_pi/30)*i); 
		px1=sx+r+(r-d)*sin((app_pi/30)*i); 
		py1=sy+r-(r-d)*cos((app_pi/30)*i);  
		GUI_SetPenSize(1);
		GUI_SetColor(GUI_WHITE);
		GUI_AA_DrawLine(px0,py0,px1,py1);
	}
	for(i=0;i<12;i++)//画小时格
	{ 
		px0=sx+r+(r-5)*sin((app_pi/6)*i); 
		py0=sy+r-(r-5)*cos((app_pi/6)*i); 
		px1=sx+r+(r-d)*sin((app_pi/6)*i); 
		py1=sy+r-(r-d)*cos((app_pi/6)*i);
		GUI_SetPenSize(5);
		GUI_SetColor(GUI_YELLOW);
		GUI_AA_DrawLine(px0,py0,px1,py1);
	}
	for(i=0;i<4;i++)//画3小时格
	{ 
		px0=sx+r+(r-5)*sin((app_pi/2)*i); 
		py0=sy+r-(r-5)*cos((app_pi/2)*i); 
		px1=sx+r+(r-d-3)*sin((app_pi/2)*i); 
		py1=sy+r-(r-d-3)*cos((app_pi/2)*i);
		GUI_SetPenSize(8);
		GUI_SetColor(GUI_YELLOW);
		GUI_AA_DrawLine(px0,py0,px1,py1);
	}
	GUI_SetColor(GUI_WHITE);
	GUI_AA_FillCircle(x,y,d/2);		//画中心圈
}
//显示时间
//x,y:坐标中心点
//size:表盘大小(直径)
//d:表盘分割,秒钟的高度
//hour:时钟
//min:分钟
//sec:秒钟
void calendar_circle_clock_showtime(u16 x,u16 y,u16 size,u16 d,u8 hour,u8 min,u8 sec)
{
	static u8 oldhour=0;	//最近一次进入该函数的时分秒信息
	static u8 oldmin=0;
	static u8 oldsec=0;
	float temp;
	u16 r=size/2;//得到半径
	u16 sx=x-r;
	u16 sy=y-r;
	u16 px0,px1;
	u16 py0,py1;  
	u8 r1; 
	if(hour>11)hour-=12;
///////////////////////////////////////////////
	//清除小时
	r1=d/2+4;
	//清除上一次的数据
	temp=(float)oldmin/60;
	temp+=oldhour;
	px0=sx+r+(r-3*d-7)*sin((app_pi/6)*temp); 
	py0=sy+r-(r-3*d-7)*cos((app_pi/6)*temp); 
	px1=sx+r+r1*sin((app_pi/6)*temp); 
	py1=sy+r-r1*cos((app_pi/6)*temp); 
	GUI_SetPenSize(8);
	GUI_SetColor(GUI_BLACK);
	GUI_DrawLine(px0,py0,px1,py1);
	//清除分钟
	r1=d/2+3;
	temp=(float)oldsec/60;
	temp+=oldmin;
	//清除上一次的数据
	px0=sx+r+(r-2*d-7)*sin((app_pi/30)*temp); 
	py0=sy+r-(r-2*d-7)*cos((app_pi/30)*temp); 
	px1=sx+r+r1*sin((app_pi/30)*temp); 
	py1=sy+r-r1*cos((app_pi/30)*temp); 
	GUI_SetPenSize(4);
	GUI_SetColor(GUI_BLACK);
	GUI_DrawLine(px0,py0,px1,py1);
	//清除秒钟
	r1=d/2+3;
	//清除上一次的数据
	px0=sx+r+(r-d-7)*sin((app_pi/30)*oldsec); 
	py0=sy+r-(r-d-7)*cos((app_pi/30)*oldsec); 
	px1=sx+r+r1*sin((app_pi/30)*oldsec); 
	py1=sy+r-r1*cos((app_pi/30)*oldsec); 
	GUI_SetPenSize(1);
	GUI_SetColor(GUI_BLACK);
	GUI_DrawLine(px0,py0,px1,py1);
///////////////////////////////////////////////
	//显示小时
	r1=d/2+4; 
	//显示新的时钟
	temp=(float)min/60;
	temp+=hour;
	px0=sx+r+(r-3*d-7)*sin((app_pi/6)*temp); 
	py0=sy+r-(r-3*d-7)*cos((app_pi/6)*temp); 
	px1=sx+r+r1*sin((app_pi/6)*temp); 
	py1=sy+r-r1*cos((app_pi/6)*temp); 
	GUI_SetPenSize(8);
	GUI_SetColor(GUI_YELLOW);
	GUI_DrawLine(px0,py0,px1,py1);
	//显示分钟
	r1=d/2+3; 
	temp=(float)sec/60;
	temp+=min;
	//显示新的分钟
	px0=sx+r+(r-2*d-7)*sin((app_pi/30)*temp); 
	py0=sy+r-(r-2*d-7)*cos((app_pi/30)*temp); 
	px1=sx+r+r1*sin((app_pi/30)*temp); 
	py1=sy+r-r1*cos((app_pi/30)*temp);
	GUI_SetPenSize(4);
	GUI_SetColor(GUI_GREEN);
	GUI_DrawLine(px0,py0,px1,py1);
	//显示秒钟
	r1=d/2+3;
	//显示新的秒钟
	px0=sx+r+(r-d-7)*sin((app_pi/30)*sec); 
	py0=sy+r-(r-d-7)*cos((app_pi/30)*sec); 
	px1=sx+r+r1*sin((app_pi/30)*sec); 
	py1=sy+r-r1*cos((app_pi/30)*sec); 
	GUI_SetPenSize(1);
	GUI_SetColor(GUI_RED);
	GUI_DrawLine(px0,py0,px1,py1);
	oldhour=hour;	//保存时
	oldmin=min;		//保存分
	oldsec=sec;		//保存秒
}	    
//时间显示模式
u8 calendar_play(void)
{
	u8 second=0;
	short temperate=0;	//温度值
	u8 t=0;
	u8 tempdate=0;
	u8 rval=0;			//返回值
	u8 res;
	u16 xoff=0;
	u16 yoff=0;	//表盘y偏移量
	u16 r=0;	//表盘半径
	u8 d=0;		//指针长度

	u8 test = 0;
	  
	u8 TEMP_SEN_TYPE=0;	//不使用DS18B20
	GUI_SetTextMode(GUI_TM_NORMAL);
	if(rval==0)//无错误
	{	  
 		GUI_SetColor(GUI_WHITE);//清黑屏
		second=calendar.sec;//得到此刻的秒钟
		GUI_SetColor(GUI_BLUE);
		GUI_DispStringAt((u8*)calendar_loading_str[0][0],48,60); //显示进入信息
//		if(DS18B20_Init())
//		{
//			GUI_DispStringAt(48,76,(u8*)calendar_loading_str[gui_phy.language][1],16,0x01);
//			delay_ms(500);
//			GUI_DispStringAt(48,92,(u8*)calendar_loading_str[gui_phy.language][2],16,0x01);
//			TEMP_SEN_TYPE=1;
//		}
		alt_dcache_flush_all();
		usleep(500000);//等待500ms
		BACK_COLOR= GUI_BLACK;
		GUI_Clear();
		GUI_SetBkColor(GUI_BLACK);//清黑屏
		r=480/3;
		d=480/40;
		yoff=(800-r*2-140)/2;
		TIME_TOPY=yoff+r*2+10;
		OTHER_TOPY=TIME_TOPY+60+10;
		xoff=(480-240)/2;
		calendar_circle_clock_drawpanel(480/2,yoff+r,r*2,d);//显示指针时钟表盘
		calendar_date_refresh();  //加载日历
		tempdate=calendar.w_date;//天数暂存器
		GUI_SetBkColor(GUI_BLACK);
		GUI_SetColor(GUI_CYAN);
		GUI_SetFont(&GUI_FontD48);
		GUI_DispCharAt(':',xoff+72,TIME_TOPY);	//":"
		GUI_DispCharAt(':',xoff+160,TIME_TOPY);	//":"
	}
  	while(rval==0)
	{	
		calendar_get_time(&calendar);	//更新时间
		if(page_next != page_clock)break;	//需要返回
 		if(second!=calendar.sec)//秒钟改变了
		{ 	
  			second=calendar.sec;  
			calendar_circle_clock_showtime(480/2,yoff+r,r*2,d,calendar.hour,calendar.min,calendar.sec);//指针时钟显示时间
			GUI_SetBkColor(GUI_BLACK);
			GUI_SetColor(GUI_CYAN);
			GUI_SetFont(&GUI_FontD48);
			GUI_DispDecAt(calendar.hour,xoff,TIME_TOPY,2);	//显示时+10
			GUI_DispDecAt(calendar.min,xoff+88,TIME_TOPY,2);	//显示分
			GUI_DispDecAt(calendar.sec,xoff+180,TIME_TOPY,2);	//显示秒

			alt_dcache_flush_all();


//			if(t%2==0)//等待2秒钟
//			{
//  				if(TEMP_SEN_TYPE)temperate=MPU_Get_Temperature()/10;//得到MPU6050采集到的温度,0.1℃
//				else temperate=DS18B20_Get_Temp();//得到18b20温度
//				if(temperate<0)//温度为负数的时候，红色显示
//				{
//					POINT_COLOR=GUI_RED;
//					temperate=-temperate;	//改为正温度
//				}else POINT_COLOR=BRRED;	//正常为棕红色字体显示
//				GUI_SetColor(GBLUE);
//				GUI_DispDecAt(temperate/10,xoff+90,OTHER_TOPY,2);	//XX
//				GUI_DispCharAt(xoff+150,OTHER_TOPY,480,800,0,GBLUE,60,'.',0);	//"."
//				GUI_DispCharAt(xoff+180-15,OTHER_TOPY,480,800,0,GBLUE,60,temperate%10+'0',0);//显示小数
//				GUI_DispCharAt(xoff+210-10,OTHER_TOPY,480,800,0,GBLUE,60,95+' ',0);//显示℃
//				if(t>0)t=0;
//			}
			calendar_get_date(&calendar);	//更新日期
			if(calendar.w_date!=tempdate)
			{
				calendar_date_refresh();	//天数变化了,更新日历.
				tempdate=calendar.w_date;	//修改tempdate，防止重复进入
			}
			t++;   
 		} 
		usleep(20000);
 	}
// 	while(tp_dev.sta&TP_PRES_DOWN)tp_dev.scan(0);//等待TP松开.

	return rval;
}
