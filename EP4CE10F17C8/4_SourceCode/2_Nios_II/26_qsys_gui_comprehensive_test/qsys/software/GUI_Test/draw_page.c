#include <stdio.h>
#include "GUI.h"
#include "system.h"
#include "io.h"
#include "alt_types.h"
#include "draw_page.h"
#include "calendar.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_uart_regs.h"
#include "mculcd.h"
#include "mdio.h"
#include "sd_spi.h"
#include "wm8978.h"

extern _lcd_dev lcddev;	//管理LCD重要参数

//画按键控件参数
#if (BOARD_TYPE==1)
	alt_u16 key_pos[4][2] = {{90,450},{240,450},{390,450},{240,300}};
	alt_u16 key_radii     = 45;


#else
	alt_u16 key_pos[4][2] = {{90,350},{190,350},{290,350},{390,350}};
	alt_u16 key_radii     = 35;

#endif

//画LED控件参数
alt_u16 led_pos[4][2] = {{66,350},{182,350},{298,350},{414,350}};
alt_u16 led_radii     = 45;

//画蜂鸣器控件参数
alt_u16 buzzer_pos[2] = {240,300};
alt_u16 buzzer_radii  = 150;

//画蜂鸣器控件参数
alt_u8  seg_bit_en[10][7] = {	//数码管段使能
        {1,1,1,1,1,1,0},  //0
        {0,1,1,0,0,0,0},  //1
        {1,1,0,1,1,0,1},  //2
        {1,1,1,1,0,0,1},  //3
        {0,1,1,0,0,1,1},  //4
        {1,0,1,1,0,1,1},  //5
        {1,0,1,1,1,1,1},  //6
        {1,1,1,0,0,0,0},  //7
        {1,1,1,1,1,1,1},  //8
        {1,1,1,1,0,1,1},  //9
};

//画数码管控件参数
GUI_POINT segled_pos[7][6] = {
        { {240-70 ,140 }, {240-60,140-10  }, {240+60,140-10  }, {240+70 ,140 }, {240+60,140+10  }, {240-60,140+10  }},
        { {320 ,220-70 }, {320+10 ,220-60 }, {320+10 ,220+60 }, {320 ,220+70 }, {320-10 ,220+60 }, {320-10 ,220-60 }},
        { {320 ,380-70 }, {320+10 ,380-60 }, {320+10 ,380+60 }, {320 ,380+70 }, {320-10 ,380+60 }, {320-10 ,380-60 }},
        { {240-70 ,460 }, {240-60,460-10  }, {240+60,460-10  }, {240+70 ,460 }, {240+60,460+10  }, {240-60,460+10  }},
        { {160 ,380-70 }, {160+10 ,380-60 }, {160+10 ,380+60 }, {160 ,380+70 }, {160-10 ,380+60 }, {160-10 ,380-60 }},
        { {160 ,220-70 }, {160+10 ,220-60 }, {160+10 ,220+60 }, {160 ,220+70 }, {160-10 ,220+60 }, {160-10 ,220-60 }},
        { {240-70 ,300 }, {240-60,300-10  }, {240+60,300-10  }, {240+70 ,300 }, {240+60,300+10  }, {240-60,300+10  }}
};

extern alt_u16 page_next;
extern alt_u8 led[4];		//各LED使能
extern alt_u8 buzzer;		//蜂鸣器使能
extern alt_u8 seg_en;		//数码管使能
extern alt_u8 seg_num;		//数码管数值
//EEPROM
extern _eeprom eeprom_rw;	//数据结构体
//串口相关参数
char rxdata;				//UART接收的字符
char rx_str[25];			//UART接收的字符串
alt_u8  cnt = 0;			//串口接收计数器
extern char tx_buffer[25];	//UART发送字符串
extern alt_u8  rx_flag;		//接收字符串完成标志
extern alt_u8 touch_flag;
extern alt_u8 paint_en;
extern alt_u32 tp_pos;		//当前触点数据
extern alt_u32 tp_pos_pre;	//上一次触点数据
extern alt_u16 x_pos_pre;   //前x坐标
extern alt_u16 y_pos_pre; 	//前y坐标
extern alt_u16 x_pos;       //当前x坐标
extern alt_u16 y_pos;       //当前y坐标
extern alt_u16 page_now ;   //当前页面
extern alt_u8 wm8978_en;    //音量使能

alt_u8 minute = 60;

//红外遥控键值
extern alt_u8 remote_key;
extern alt_u8 remote_key_pre;

alt_u16 *ram = (alt_u16 *)(SDRAM_BASE + SDRAM_SPAN - 769000);

alt_u16 eth_id = 0;

void factory_common_clear(){
    touch_flag = 0;
    GUI_SetColor(GUI_WHITE);
    GUI_FillRect(0,0,480,5+36*5);
    alt_dcache_flush_all();
    GUI_SetColor(GUI_BLUE);
}

/************************************************************
*
*           画系统测试页面
*
*************************************************************
*/
void gui_draw_sys_test_page(){
	alt_u8 sd_error_flag = 1;
	alt_u8 sec=0,time_cnt=0,time_ok_cnt=0;

	GUI_SetTextMode(GUI_TM_TRANS);
	GUI_SetBkColor(GUI_DEEPDARK);
    GUI_Clear();

    GUI_SetColor(GUI_WHITE);
    GUI_SetFont(&GUI_FontChinese_WRYH32);
    GUI_SetTextMode(GUI_TM_TRANS);
    GUI_SetTextAlign(GUI_TA_LEFT | GUI_TA_TOP);
    GUI_DispStringAt("ALIENTEK  FPGA",10,5);
    GUI_DispStringAt("CopyRight (C) 2018-2028",10,5+36*1);
    GUI_DispStringAt("HARDWARE:V1.6, SOFTWARE:V1.2",10,5+36*2);
    GUI_DispStringAt("FPGA:EP4CE10F17C8",10,5+36*3);
    GUI_DispStringAt("LE:10320  RAM:414KBit",10,5+36*4);
    alt_dcache_flush_all();
    usleep(600000);
    //EEPROM Check
    GUI_DispStringAt("EEPROM Check...",10,5+36*5);
    if(AT24CXX_Check()){
    	GUI_SetColor(GUI_RED);
    	GUI_DispStringAt("Error",282,5+36*5);
    	GUI_SetColor(GUI_WHITE);
    }
    else
    	GUI_DispStringAt("OK",282,5+36*5);
    alt_dcache_flush_all();

    //判断SD卡是否初始化完成
    GUI_DispStringAt("SD Card Check...",10,5+36*6);
    alt_dcache_flush_all();
    sd_error_flag = SD_Test();
    if(sd_error_flag==0)
    	GUI_DispStringAt("OK",282,5+36*6);
    else{
		GUI_SetColor(GUI_RED);
		GUI_DispStringAt("Error",282,5+36*6);
		GUI_SetColor(GUI_WHITE);
    }
    alt_dcache_flush_all();

    //AP3216C测试
    GUI_DispStringAt("AP3216C Check...",10,5+36*7);
    alt_dcache_flush_all();
  	if(AP3216C_Init()){
    	GUI_SetColor(GUI_RED);
    	GUI_DispStringAt("Error",282,5+36*7);
    	GUI_SetColor(GUI_WHITE);
  	}
  	else
    	GUI_DispStringAt("OK",282,5+36*7);
    alt_dcache_flush_all();

	//RTC 测试
	GUI_DispStringAt("RTC Check...",10,5+36*8);
	alt_dcache_flush_all();
	calendar_get_time(&calendar);	//更新时间
	sec = calendar.sec;
	while(1)
	{
		calendar_get_time(&calendar);	//更新时间
		if((calendar.sec == sec+1) || (calendar.sec == 0 && sec == 59)){
			time_cnt = 0;
			sec = calendar.sec;
			time_ok_cnt++;
		}
		else if(time_cnt>11){
			GUI_SetColor(GUI_RED);
			GUI_DispStringAt("Error",282,5+36*8);
			GUI_SetColor(GUI_WHITE);
			break;
		}
		time_cnt++;
		usleep(100000);
		if(time_ok_cnt>=1){
			GUI_DispStringAt("OK",282,5+36*8);
			break;
		}
	}
	alt_dcache_flush_all();

    usleep(1000000);
}

/************************************************************
*
*           画主页面
*
*************************************************************
*/

void gui_draw_home_page(){

	GUI_DrawBitmap(&bmhome_pic, 0, 0);

    minute = 60;
    alt_dcache_flush_all();
}

void draw_home()
{
	GUI_SetTextMode(GUI_TM_NORMAL);
	GUI_SetBkColor(GUI_DEEPDARK);
	GUI_SetColor(GUI_WHITE);
    GUI_SetFont(&GUI_FontChinese_WRYH32);
    GUI_SetTextAlign(GUI_TA_LEFT | GUI_TA_TOP);
	calendar_get_time(&calendar);	//更新时间
	if(minute!=calendar.min)		//分钟改变了
	{
		minute = calendar.min;
		GUI_DispDecAt(calendar.hour,390,5,2);	//显示时
		GUI_DispCharAt(':',425,5);	//":"
		GUI_DispDecAt(calendar.min,437,5,2);	//显示分

		alt_dcache_flush_all();	//立即执行cache中的绘图指令
	}
}
/************************************************************
*
*           测试页面的共同部分
*
*************************************************************
*/

void common_draw()
{
	GUI_SetTextMode(GUI_TM_TRANS);
	GUI_SetBkColor(GUI_VERYLIGHTCYAN);
    GUI_Clear();
    GUI_SetColor(GUI_LIGHTBLUE);
    GUI_FillRect(0,0,480,15);
    GUI_SetColor(GUI_BLUEIGHTBLUE);
    GUI_FillRect(0,15,480,40);
    GUI_SetColor(GUI_WHITE);
    GUI_SetTextAlign(GUI_TA_HCENTER);
}

/************************************************************
*
*           画按键测试页面
*
*************************************************************
*/
void gui_draw_page_key(){
	common_draw();
    GUI_DispStringAt("按键测试",240,5);

    GUI_SetColor(GUI_YELLOW);
    GUI_AA_FillCircle(key_pos[0][0],key_pos[0][1],key_radii);
    GUI_AA_FillCircle(key_pos[1][0],key_pos[1][1],key_radii);
    GUI_AA_FillCircle(key_pos[2][0],key_pos[2][1],key_radii);
    GUI_AA_FillCircle(key_pos[3][0],key_pos[3][1],key_radii);

    GUI_SetColor(GUI_BLUE);
    GUI_DispStringAt("KEY0",key_pos[0][0]-32,key_pos[0][1]-16);
    GUI_DispStringAt("KEY1",key_pos[1][0]-32,key_pos[1][1]-16);
    GUI_DispStringAt("KEY2",key_pos[2][0]-32,key_pos[2][1]-16);
    GUI_DispStringAt("KEY3",key_pos[3][0]-32,key_pos[3][1]-16);

    alt_dcache_flush_all();
}

//画按键控件
void draw_key(int key_num, int color){
     GUI_SetColor(color);
     GUI_AA_FillCircle(key_pos[key_num][0],key_pos[key_num][1],key_radii);
     GUI_SetColor(GUI_BLUE);
     GUI_DispStringAt("KEY",key_pos[key_num][0]-32,key_pos[key_num][1]-16);
     GUI_DispDecAt(key_num,key_pos[key_num][0]+16,key_pos[key_num][1]-16,1);

     alt_dcache_flush_all();
}

/************************************************************
*
*           画LED测试页面
*
*************************************************************
*/

void gui_draw_page_led(){
    int i =0;

    for(i=0;i<=3;i++) led[i] = 0;

    common_draw();
    GUI_DispStringAt("LED测试",240,5);

    for(i=0;i<=3;i++){
        GUI_SetColor(GUI_WHITE);
        GUI_AA_FillCircle(led_pos[i][0],led_pos[i][1],led_radii);
        GUI_SetColor(GUI_LIGHTGRAY);
        GUI_FillRect(led_pos[i][0]-45,led_pos[i][1]+90,led_pos[i][0]+45,led_pos[i][1]+150);

        GUI_SetColor(GUI_WHITE);
        GUI_DrawHLine(led_pos[i][1]+90, led_pos[i][0]-45, led_pos[i][0]+45);
        GUI_DrawVLine(led_pos[i][0]-45, led_pos[i][1]+90, led_pos[i][1]+150);
        GUI_SetColor(GUI_DARKGRAY);
        GUI_DrawHLine(led_pos[i][1]+150,led_pos[i][0]-45, led_pos[i][0]+45);
        GUI_DrawVLine(led_pos[i][0]+45, led_pos[i][1]+90, led_pos[i][1]+150);

        GUI_SetColor(GUI_BLACK);
        GUI_DispStringAt("DS  亮",led_pos[i][0]-36,led_pos[i][1]+105);
        GUI_DispDecAt(i,led_pos[i][0]-4,led_pos[i][1]+105,1);
    }

    alt_dcache_flush_all();
}

void draw_led(int led_num, int on_off){
    GUI_SetBkColor(GUI_LIGHTGRAY);
    GUI_SetColor(GUI_BLACK);
    GUI_SetTextMode(GUI_TM_NORMAL);
    if(on_off == 0){
        GUI_DispStringAt("亮",led_pos[led_num][0]+12,led_pos[led_num][1]+105);
        GUI_SetColor(GUI_WHITE);
    }
    else if(on_off == 1){
        GUI_DispStringAt("灭",led_pos[led_num][0]+12,led_pos[led_num][1]+105);
        GUI_SetColor(GUI_RED);
    }
    GUI_FillCircle(led_pos[led_num][0],led_pos[led_num][1],led_radii);

    alt_dcache_flush_all();
}


/************************************************************
*
*           画数码管测试页面
*
*************************************************************
*/

void gui_draw_page_segled(){
    int i;

    seg_en = 0;
    seg_num = 0;

    common_draw();
    GUI_DispStringAt("数码管测试",240,5);

    GUI_SetColor(GUI_WHITE);
    for(i=0;i<=6;i++){
        GUI_FillPolygon(segled_pos[i],6,0,0);
    }
    GUI_FillCircle(350,450,15);

    GUI_SetColor(GUI_LIGHTGRAY);
    GUI_FillRect(240-50,600-50,240+50,600+50);
    GUI_FillRect(90-50, 600-50,90+50, 600+50);
    GUI_FillRect(390-50,600-50,390+50,600+50);

    GUI_SetColor(GUI_WHITE);
    GUI_DrawHLine(600-50,240-50,240+50);
    GUI_DrawHLine(600-50,90-50, 90+50 );
    GUI_DrawHLine(600-50,390-50,390+50);
    GUI_DrawVLine(240-50,600-50,600+50);
    GUI_DrawVLine(90-50, 600-50,600+50);
    GUI_DrawVLine(390-50,600-50,600+50);
    GUI_SetColor(GUI_DARKGRAY);
    GUI_DrawHLine(600+50,240-50,240+50);
    GUI_DrawHLine(600+50,90-50, 90+50 );
    GUI_DrawHLine(600+50,390-50,390+50);
    GUI_DrawVLine(240+50,600-50,600+50);
    GUI_DrawVLine(90+50, 600-50,600+50);
    GUI_DrawVLine(390+50,600-50,600+50);

    GUI_SetColor(GUI_BLACK);
    GUI_SetFont(&GUI_FontST80);
    GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_DispStringAt("-",90,600);
    GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_DispStringAt("+",390,600);

    GUI_SetFont(&GUI_FontChinese_WRYH32);
    GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_DispStringAt("打开",240,600);

    alt_dcache_flush_all();
}

void draw_segled(int seg_en, int seg_num){
    int i;
    if(seg_en == 0){
        GUI_SetColor(GUI_WHITE);
        for(i=0;i<=6;i++){
            GUI_FillPolygon(segled_pos[i],6,0,0);
        }
        GUI_FillCircle(350,450,15);
    }else {
        for(i=0;i<=6;i++){
            if(seg_bit_en[seg_num][i] == 0)
                GUI_SetColor(GUI_WHITE);
            else
                GUI_SetColor(GUI_RED);
            GUI_FillPolygon(segled_pos[i],6,0,0);
        }
        GUI_SetColor(GUI_RED);
        GUI_FillCircle(350,450,15);
      }
    GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_SetTextMode(GUI_TM_NORMAL);
    GUI_SetBkColor(GUI_LIGHTGRAY);
    GUI_SetColor(GUI_BLACK);
    GUI_SetFont(&GUI_FontChinese_WRYH32);
    if(seg_en == 0)
          GUI_DispStringAt("打开",240,600);
    else
          GUI_DispStringAt("关闭",240,600);

    alt_dcache_flush_all();
}

/************************************************************
*
*           画EEPROM测试页面
*
*************************************************************
*/

void gui_draw_page_eeprom(){
	 common_draw();
     GUI_DispStringAt("EEPROM测试",240,5);

     GUI_SetColor(GUI_WHITE);
     GUI_FillRect(50,150,430,300);
     GUI_FillRect(50,350,430,500);


     GUI_SetColor(GUI_LIGHTGRAY);
     GUI_FillRect(240-50,600-50,240+50,600+50);
     GUI_SetColor(GUI_WHITE);
     GUI_DrawHLine(600-50,240-50,240+50);
     GUI_DrawVLine(240-50,600-50,600+50);
     GUI_SetColor(GUI_DARKGRAY);
     GUI_DrawHLine(600+50,240-50,240+50);
     GUI_DrawVLine(240+50,600-50,600+50);

     GUI_SetTextMode(GUI_TM_NORMAL);
     GUI_SetBkColor(GUI_LIGHTGRAY);
     GUI_SetColor(GUI_BLACK);
     GUI_SetFont(&GUI_FontChinese_WRYH32);
     GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
     GUI_DispStringAt("测试",240,600);

     GUI_DrawRect(50,150,430,300);
     GUI_DrawRect(50,350,430,500);

     GUI_SetBkColor(GUI_WHITE);
     GUI_DispStringAt("写数据：",50,150);
     GUI_DispStringAt("读数据：",50,350);

     alt_dcache_flush_all();
}

void draw_eeprom(){

     GUI_SetTextMode(GUI_TM_NORMAL);
     GUI_SetFont(&GUI_FontD48);
	 int i;
     for(i=0;i<100;i++){
		 GUI_GotoXY(50+50,150+50);
		 GUI_SetBkColor(GUI_WHITE);
		 GUI_SetColor(GUI_RED);
		 eeprom_data_get(i,&eeprom_rw);
		 GUI_DispDec(eeprom_rw.wr,2);
		 GUI_GotoXY(50+50,350+50);
		 GUI_DispDec(eeprom_rw.rd,2);

	     alt_dcache_flush_all();

		 usleep(100000);
         if(page_next != page_eeprom)
         	break;
     }
}


/************************************************************
 *
 *           画实时时钟页面
 *
 *************************************************************
 */
void gui_draw_page_paint(){
     GUI_SetBkColor(GUI_WHITE);
     GUI_Clear();
     GUI_SetColor(GUI_RED);
     GUI_SetPenSize(5);
     alt_dcache_flush_all();
}

void gui_draw_page_clock(){
     GUI_SetBkColor(GUI_BLACK);
     GUI_Clear();
     GUI_SetColor(GUI_WHITE);
}


/************************************************************
 *
 *           画AD/DA测试页面
 *
 *************************************************************
 */

void gui_draw_page_adda(){
	 common_draw();
     GUI_DispStringAt("AD\\DA测试",240,5);

     GUI_SetColor(GUI_WHITE);
     GUI_FillRect(50,150,430,300);
     GUI_FillRect(50,350,430,500);

     GUI_SetColor(GUI_LIGHTGRAY);
     GUI_FillRect(240-50,600-50,240+50,600+50);
     GUI_SetColor(GUI_WHITE);
     GUI_DrawHLine(600-50,240-50,240+50);
     GUI_DrawVLine(240-50,600-50,600+50);
     GUI_SetColor(GUI_DARKGRAY);
     GUI_DrawHLine(600+50,240-50,240+50);
     GUI_DrawVLine(240+50,600-50,600+50);

     GUI_SetTextMode(GUI_TM_NORMAL);
     GUI_SetBkColor(GUI_LIGHTGRAY);
     GUI_SetColor(GUI_BLACK);
     GUI_SetFont(&GUI_FontChinese_WRYH32);
     GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
     GUI_DispStringAt("测试",240,600);

     GUI_DrawRect(50,150,430,300);
     GUI_DrawRect(50,350,430,500);

     GUI_SetBkColor(GUI_WHITE);
     GUI_DispStringAt("AD采集到的模拟电压值(V)：",50,150);
     GUI_DispStringAt("DA输出的数字量：",50,350);

     GUI_SetTextMode(GUI_TM_TRANS);
     GUI_DispStringAt("注意：请将DA输出引脚'AOUT'连接到",20,70);
     GUI_DispStringAt("           AD输入'AIN0'！",20,100);
     alt_dcache_flush_all();
}

void draw_adda(unsigned char da_val,float ad_val){

     GUI_SetTextMode(GUI_TM_NORMAL);
     GUI_SetTextAlign(GUI_TA_RIGHT | GUI_TA_TOP);
     GUI_SetBkColor(GUI_WHITE);
     GUI_SetColor(GUI_RED);
     GUI_SetFont(&GUI_FontD48);
     GUI_GotoXY(290,200);
     GUI_DispFloatFix(ad_val,4,2);

     GUI_SetTextAlign(GUI_TA_RIGHT | GUI_TA_TOP);
     GUI_GotoXY(290,400);
     GUI_DispDecSpace(da_val,6);

     alt_dcache_flush_all();
}

/************************************************************
 *
 *           画AP3216测试页面
 *
 *************************************************************
 */
void gui_draw_page_ap3216(){

	 common_draw();
     GUI_DispStringAt("AP3216C测试",240,5);

     GUI_SetColor(GUI_WHITE);
     GUI_FillRect(50,150,430,300);
     GUI_FillRect(50,350,430,500);
     GUI_SetColor(GUI_BLACK);
     GUI_DrawRect(50,150,430,300);
     GUI_DrawRect(50,350,430,500);

     GUI_SetTextMode(GUI_TM_NORMAL);
     GUI_SetBkColor(GUI_WHITE);
     GUI_SetColor(GUI_BLACK);
     GUI_SetFont(&GUI_FontChinese_WRYH32);
     GUI_DispStringAt("环境光强度(lux)：",50+5,150+5);
     GUI_DispStringAt("距离：",50+5,350+5);
}

void draw_ap3216(){
	int ps;
    GUI_SetTextMode(GUI_TM_NORMAL);
    GUI_SetTextAlign(GUI_TA_RIGHT | GUI_TA_TOP);
    GUI_SetBkColor(GUI_WHITE);
    GUI_SetColor(GUI_RED);
    GUI_SetFont(&GUI_FontD48);
    GUI_GotoXY(240+70,225-24);
    GUI_DispDecSpace(ap3216.als,9);

    GUI_SetTextAlign(GUI_TA_RIGHT | GUI_TA_TOP);
    GUI_GotoXY(240+70,425-24);
    ps = (ap3216.ps)/10-5;		//不显示个位，防止数据变化太快
    if(ps<0) ps = 0;
    GUI_DispDecSpace(ps,9);

    alt_dcache_flush_all();
}

/************************************************************
 *
 *           画MUSIC测试页面
 *
 *************************************************************
 */

void gui_draw_page_music(unsigned char wm8978_en, alt_u8 vol){
	 common_draw();
     GUI_DispStringAt("WM8978测试",240,5);

     GUI_SetColor(GUI_LIGHTGRAY);
     GUI_FillRect(240-50,600-50,240+50,600+50);
     GUI_FillRect(90-50, 600-50,90+50, 600+50);
     GUI_FillRect(390-50,600-50,390+50,600+50);

     GUI_SetColor(GUI_WHITE);
     GUI_DrawHLine(600-50,240-50,240+50);
     GUI_DrawVLine(240-50,600-50,600+50);
     GUI_DrawHLine(600-50,90-50,90+50);
     GUI_DrawVLine(90-50,600-50,600+50);
     GUI_DrawHLine(600-50,390-50,390+50);
     GUI_DrawVLine(390-50,600-50,600+50);
     GUI_SetColor(GUI_DARKGRAY);
     GUI_DrawHLine(600+50,240-50,240+50);
     GUI_DrawVLine(240+50,600-50,600+50);
     GUI_DrawHLine(600+50,90-50,90+50);
     GUI_DrawVLine(90+50,600-50,600+50);
     GUI_DrawHLine(600+50,390-50,390+50);
     GUI_DrawVLine(390+50,600-50,600+50);

     GUI_SetColor(GUI_BLACK);
     GUI_SetFont(&GUI_FontST80);
     GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
     GUI_DispStringAt("-",90,600);
     GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
     GUI_DispStringAt("+",390,600);

     GUI_SetFont(&GUI_FontChinese_WRYH32);
     GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
     if(wm8978_en == 0)
           GUI_DispStringAt("打开",240,600);
     else
           GUI_DispStringAt("关闭",240,600);

     GUI_SetColor(GUI_BLACK);
     GUI_SetFont(&GUI_FontChinese_WRYH32);
     GUI_DispStringAt("请确认已连接音频线！",30,70);

     GUI_DrawBitmap(&bmyinfu_01, 50, 110);

     GUI_SetColor(GUI_WHITE);
     GUI_FillRect(240+69,705-20,240+95,705+20);
     GUI_SetColor(GUI_BLACK);
     GUI_DispStringAt("音量（0~8）:",240-90,705);
     GUI_SetBkColor(GUI_WHITE);
     GUI_SetColor(GUI_BLACK);
     GUI_SetFont(&GUI_Font32B_1);
     GUI_GotoXY(240+75,705);
     GUI_DispDec(vol,1);

     alt_dcache_flush_all();
}

void draw_music(unsigned char wm8978_en, alt_u8 vol)
{
	GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_SetTextMode(GUI_TM_NORMAL);
    GUI_SetBkColor(GUI_LIGHTGRAY);
    GUI_SetColor(GUI_BLACK);
    GUI_SetFont(&GUI_FontChinese_WRYH32);
    if(wm8978_en == 0)
          GUI_DispStringAt("打开",240,600);
    else
          GUI_DispStringAt("关闭",240,600);
    GUI_SetBkColor(GUI_WHITE);
    GUI_SetColor(GUI_BLACK);
    GUI_SetFont(&GUI_Font32B_1);
    GUI_GotoXY(240+75,705);
    GUI_DispDec(vol,1);

    alt_dcache_flush_all();
}

/************************************************************
 *
 *           画蜂鸣器测试页面
 *
 *************************************************************
 */

void gui_draw_page_buzzer(){
    buzzer = 0;

    common_draw();
    GUI_DispStringAt("蜂鸣器测试",240,5);

    GUI_SetColor(GUI_RED);
    GUI_AA_FillCircle(buzzer_pos[0],buzzer_pos[1],buzzer_radii);
    GUI_SetBkColor(GUI_RED);
    GUI_SetColor(GUI_WHITE);
    GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_SetFont(&GUI_FontST80);
    GUI_DispStringAt("OFF",buzzer_pos[0],buzzer_pos[1]);

    GUI_SetColor(GUI_LIGHTGRAY);
    GUI_FillRect(buzzer_pos[0]-150,buzzer_pos[1]+250,buzzer_pos[0]+150,buzzer_pos[1]+350);
    GUI_SetColor(GUI_WHITE);
    GUI_DrawHLine(buzzer_pos[1]+250,buzzer_pos[0]-150,buzzer_pos[0]+150);
    GUI_DrawVLine(buzzer_pos[0]-150,buzzer_pos[1]+250,buzzer_pos[1]+350);
    GUI_SetColor(GUI_DARKGRAY);
    GUI_DrawHLine(buzzer_pos[1]+350,buzzer_pos[0]-150,buzzer_pos[0]+150);
    GUI_DrawVLine(buzzer_pos[0]+150,buzzer_pos[1]+250,buzzer_pos[1]+350);

    GUI_SetFont(&GUI_FontChinese_WRYH32);
    GUI_SetColor(GUI_BLACK);
    GUI_DispStringAt("打开",buzzer_pos[0]-24,buzzer_pos[1]+300);

    alt_dcache_flush_all();
}

void draw_buzzer(int buzzer){
    GUI_SetBkColor(GUI_RED);
    GUI_SetColor(GUI_WHITE);
    GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_SetTextMode(GUI_TM_NORMAL);
    if(buzzer == 0){
          GUI_SetFont(&GUI_FontST80);
          GUI_DispStringAt("OFF",buzzer_pos[0],buzzer_pos[1]);
          GUI_SetBkColor(GUI_LIGHTGRAY);
          GUI_SetFont(&GUI_FontChinese_WRYH32);
          GUI_SetColor(GUI_BLACK);
          GUI_DispStringAt("打开",buzzer_pos[0]-24,buzzer_pos[1]+300);
    }
    else{
          GUI_SetFont(&GUI_FontST80);
          GUI_DispStringAt(" ON ",buzzer_pos[0],buzzer_pos[1]);
          GUI_SetBkColor(GUI_LIGHTGRAY);
          GUI_SetFont(&GUI_FontChinese_WRYH32);
          GUI_SetColor(GUI_BLACK);
          GUI_DispStringAt("关闭",buzzer_pos[0]-24,buzzer_pos[1]+300);
    }

    alt_dcache_flush_all();
}

/************************************************************
*
*           画串口测试页面
*
*************************************************************
*/

void gui_draw_page_uart(){
	common_draw();
    GUI_DispStringAt("串口测试",240,5);

    GUI_SetColor(GUI_WHITE);
    GUI_FillRect(50,150,430,300);
    GUI_FillRect(50,350,430,500);

    GUI_SetColor(GUI_LIGHTGRAY);
    GUI_FillRect(240-50,600-50,240+50,600+50);
    GUI_SetColor(GUI_WHITE);
    GUI_DrawHLine(600-50,240-50,240+50);
    GUI_DrawVLine(240-50,600-50,600+50);
    GUI_SetColor(GUI_DARKGRAY);
    GUI_DrawHLine(600+50,240-50,240+50);
    GUI_DrawVLine(240+50,600-50,600+50);

    GUI_SetTextMode(GUI_TM_NORMAL);
    GUI_SetBkColor(GUI_LIGHTGRAY);
    GUI_SetColor(GUI_BLACK);
    GUI_SetFont(&GUI_FontChinese_WRYH32);
    GUI_SetTextAlign(GUI_TA_HCENTER | GUI_TA_VCENTER);
    GUI_DispStringAt("发送",240,600);

    GUI_DrawRect(50,150,430,300);
    GUI_DrawRect(50,350,430,500);

    GUI_SetBkColor(GUI_WHITE);
    GUI_DispStringAt("接收数据：",50,150);
    GUI_DispStringAt("发送数据：",50,350);

    GUI_SetFont(&GUI_FontChinese_ST36_B);
    memset(tx_buffer,0,50);
    strcpy(tx_buffer,"Hello, World! \n");
    GUI_GotoXY(50+16,350+30);
    GUI_DispStringLen(tx_buffer,uart_disp_str+3);

    GUI_SetFont(&GUI_FontChinese_WRYH32);
    GUI_SetTextMode(GUI_TM_TRANS);
    GUI_DispStringAt("1、请确认已连接USB串口线！",12,70);
    GUI_DispStringAt("2、上位机发送字符串需要以换行符结束！",12,100);

    GUI_DispStringAt("波特率：115200",30,720);
    GUI_DispStringAt("数据位：8",250,720);
    GUI_DispStringAt("校验位：None",30,750);
    GUI_DispStringAt("停止位：1",250,750);

    alt_dcache_flush_all();
}

void draw_uart_rx(){
    if(rx_flag == 1){

//          GUI_SetColor(GUI_WHITE);
//          GUI_FillRect(50+16,150+30,428,150+30+36);

    	  GUI_SetFont(&GUI_FontChinese_ST36_B);
          GUI_SetColor(GUI_BLACK);
    	  GUI_SetTextMode(GUI_TM_NORMAL);
          GUI_GotoXY(50+16,150+30);
          GUI_SetBkColor(GUI_GREEN);
          GUI_DispStringLen(rx_str,uart_disp_str+3);

          alt_dcache_flush_all();

          usleep(500000);
          GUI_SetFont(&GUI_FontChinese_ST36_B);
          GUI_GotoXY(50+16,150+30);
          GUI_SetBkColor(GUI_WHITE);
          GUI_DispStringLen(rx_str,uart_disp_str+3);
          memset(tx_buffer,0,50);      //将内存某地址后面的50个字节 用0替换
          strcpy(tx_buffer,rx_str);

//          GUI_SetColor(GUI_WHITE);
//          GUI_FillRect(50+16,350+30,428,350+30+36);

          GUI_SetColor(GUI_BLACK);
          GUI_GotoXY(50+16,350+30);
          GUI_DispStringLen(tx_buffer,uart_disp_str+3);
          rx_flag = 0;
          GUI_SetFont(&GUI_FontChinese_WRYH32);
          alt_dcache_flush_all();
    }
}

    void draw_uart_tx(){
//        GUI_SetColor(GUI_WHITE);
//        GUI_FillRect(50+16,350+30,428,350+30+36);

        GUI_SetFont(&GUI_FontChinese_ST36_B);
        GUI_SetColor(GUI_BLACK);
        GUI_SetTextMode(GUI_TM_NORMAL);
        GUI_GotoXY(50+16,350+30);
        GUI_SetBkColor(GUI_GREEN);
        GUI_DispStringLen(tx_buffer,uart_disp_str+3);

        alt_dcache_flush_all();

        usleep(500000);
        GUI_SetBkColor(GUI_WHITE);
        GUI_GotoXY(50+16,350+30);
        GUI_DispStringLen(tx_buffer,uart_disp_str+3);
        GUI_SetFont(&GUI_FontChinese_WRYH32);

        alt_dcache_flush_all();
    }

/************************************************************
*
*           画红外遥控测试页面
*
*************************************************************
*/

    void gui_draw_page_remote(){
        remote_key = 0;
        remote_key_pre = 0;

        common_draw();
        GUI_DispStringAt("红外遥控测试",240,5);

        GUI_SetColor(GUI_WHITE);
        GUI_FillRect(100,150,380,300);
        GUI_FillRect(100,350,380,500);
        GUI_SetColor(GUI_BLACK);
        GUI_DrawRect(100,150,380,300);
        GUI_DrawRect(100,350,380,500);

        GUI_SetTextMode(GUI_TM_NORMAL);
        GUI_SetBkColor(GUI_WHITE);
        GUI_SetColor(GUI_BLACK);
        GUI_SetFont(&GUI_FontChinese_WRYH32);
        GUI_DispStringAt("键值：",100+5,150+5);
        GUI_DispStringAt("符号：",100+5,350+5);

        alt_dcache_flush_all();
    }

    void draw_remote(){
          GUI_SetTextMode(GUI_TM_NORMAL);
          GUI_SetTextAlign(GUI_TA_RIGHT | GUI_TA_TOP);
          GUI_SetBkColor(GUI_WHITE);
          GUI_SetColor(GUI_RED);
            GUI_SetFont(&GUI_FontD48);
            GUI_GotoXY(240+48,225-24);
            GUI_DispDecSpace(remote_key,6);
            GUI_SetFont(&GUI_Font32B_1);
            GUI_SetTextAlign(GUI_TA_RIGHT | GUI_TA_TOP);
            GUI_GotoXY(240+32,425-24);
            switch(remote_key){ //字符串前补空格，以覆盖较长字符
            case 0x45:  GUI_DispString("   POWER"); break;
            case 0x47:  GUI_DispString("   ALIEN"); break;
            case 0x46 :  GUI_DispString("         UP"); break;
            case 0x44 :  GUI_DispString("     LEFT"); break;
            case 0x40:  GUI_DispString("     PLAY"); break;
            case 0x43:  GUI_DispString("   RIGHT"); break;
            case 0x15:  GUI_DispString("     DOWN"); break;
            case 0x7:  GUI_DispString("      VOL-"); break;
            case 0x9:  GUI_DispString("      VOL+"); break;
            case 0x16:  GUI_DispString("            1"); break;
            case 0x19:  GUI_DispString("            2"); break;
            case 0xd:  GUI_DispString("            3"); break;
            case 0xc :  GUI_DispString("            4"); break;
            case 0x18 :  GUI_DispString("            5"); break;
            case 0x5e:  GUI_DispString("            6"); break;
            case 0x8 :  GUI_DispString("            7"); break;
            case 0x1c :  GUI_DispString("            8"); break;
            case 0x5a :  GUI_DispString("            9"); break;
            case 0x42 :  GUI_DispString("            0"); break;
            case 0x4a :  GUI_DispString("DELETE"); break;
            }

            alt_dcache_flush_all();
    }

/************************************************************
*
*           画摄像头页面
*
*************************************************************
*/
void gui_draw_page_camera(){
    alt_dcache_flush_all();
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_OV5640_EN_BASE, 1);  //使能ov5640显示
}

void draw_ov5640(){
    common_draw();
    GUI_DispStringAt("摄像头测试",240,5);
	GUI_SetColor(GUI_RED);
    GUI_SetTextAlign(GUI_TA_CENTER);
    GUI_DispStringAt("请连接OV5640!",240,400);
    alt_dcache_flush_all();
}


/************************************************************
*
*           画网络通信页面
*
*************************************************************
*/
void gui_draw_page_ethernet(){
	alt_dcache_flush_all();

	common_draw();
    GUI_DispStringAt("以太网测试",240,5);
    //读以太网ID
    eth_id = mdio_read(9,3);              //PHY Address = 9, Reg Address = 3;
    eth_id = mdio_read(9,3);              //PHY Address = 9, Reg Address = 3;
    //判断以太网ID是否读取正确
    if(eth_id != 0x8201){
    	GUI_SetColor(GUI_RED);
    	GUI_SetTextAlign(GUI_TA_CENTER);
    	GUI_DispStringAt("Check Error!",240,400);
    }
/*
    //读以太网ID
    IOWR(AVALON_MM_BRIDGE_6_BASE,1,1);    //1：读写控制   1：读
    IOWR(AVALON_MM_BRIDGE_6_BASE,2,3);    //2：地址  3：寄存器地址3
    IOWR(AVALON_MM_BRIDGE_6_BASE,0,1);    //0：拉高开始信号
    usleep(100);

    if(IORD(AVALON_MM_BRIDGE_6_BASE,4))
    	eth_id = IORD(AVALON_MM_BRIDGE_6_BASE,5);
 	IOWR(AVALON_MM_BRIDGE_6_BASE,0,0);    //0：拉低开始信号

    //再次读以太网ID
    IOWR(AVALON_MM_BRIDGE_6_BASE,1,1);    //1：读写控制   1：读
    IOWR(AVALON_MM_BRIDGE_6_BASE,2,3);    //2：地址  3：寄存器地址3
    IOWR(AVALON_MM_BRIDGE_6_BASE,0,1);    //0：拉高开始信号
    usleep(100);

    if(IORD(AVALON_MM_BRIDGE_6_BASE,4))
    	eth_id = IORD(AVALON_MM_BRIDGE_6_BASE,5);
 	IOWR(AVALON_MM_BRIDGE_6_BASE,0,0);    //0：拉低开始信号

	common_draw();
    GUI_DispStringAt("以太网测试",lcddev.width/2,lcddev.height/160);
    //判断以太网ID是否读取正确
    if(eth_id != 0x8201){
    	GUI_SetColor(GUI_RED);
    	GUI_SetTextAlign(GUI_TA_CENTER);
    	GUI_DispStringAt("Check Error!",lcddev.width/2,lcddev.height/2);
    }*/
    alt_dcache_flush_all();
}

void draw_ethernet(){
	alt_u16 eth_link_status = 0;
	GUI_SetTextMode(GUI_TM_NORMAL);
	GUI_SetColor(GUI_RED);
	GUI_SetTextAlign(GUI_TA_CENTER);

	if(eth_id != 0x8201)
		return;
	else{
		//读取是否连接网线
		eth_link_status = mdio_read(9,1);    //PHY Address = 1, Reg Address = 3;
    	if(eth_link_status&0x0004)
	    	GUI_DispStringAt("    Check OK!    ",240,400);
	    else
	    	GUI_DispStringAt("       请连接网线!       ",240,400);
	}

/*
	if(eth_id != 0x8201)
		return;
	else{
		//读取是否连接网线
	    IOWR(AVALON_MM_BRIDGE_6_BASE,1,1);    //1：读写控制   1：读
	    IOWR(AVALON_MM_BRIDGE_6_BASE,2,1);    //2：地址  3：寄存器地址1
	    IOWR(AVALON_MM_BRIDGE_6_BASE,0,1);    //0：拉高开始信号
	    usleep(100);
	    if(IORD(AVALON_MM_BRIDGE_6_BASE,4))
	    {
	    	eth_link_status = IORD(AVALON_MM_BRIDGE_6_BASE,5);
	    	if(eth_link_status&0x0004)
		    	GUI_DispStringAt("    Check OK!    ",lcddev.width/2,lcddev.height/2);
		    else
		    	GUI_DispStringAt("       请连接网线!       ",lcddev.width/2,lcddev.height/2);
	    }
	    else
	    	GUI_DispStringAt("Ethernet Check Error!",lcddev.width/2,lcddev.height/2);
	    IOWR(AVALON_MM_BRIDGE_6_BASE,0,0);    //0：拉低开始信号


	}
*/
	alt_dcache_flush_all();
}

/************************************************************
*
*           触摸屏手写画笔中断函数
*
*************************************************************
*/

//手写画笔中断初始化
void init_paint_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_PAINT_BASE, 0x1); //开触摸中断
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_PAINT_BASE, 0x1); //清边沿捕获寄存器
    alt_ic_isr_register(
    	PIO_PAINT_IRQ_INTERRUPT_CONTROLLER_ID, //中断控制器标号
		PIO_PAINT_IRQ,							//硬件中断号
		paint_interrupt,							//中断服务函数
        NULL,									//指向与设备驱动实例相关的结构体，一般为NULL
        0										//保留位，设置为0
        );
}

//关触摸屏中断
void disable_paint_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_PAINT_BASE, 0x0);
}

//开触摸屏中断
void enable_paint_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_PAINT_BASE, 0x1);
}
/************************************************************
*
*           触摸屏中断函数
*
*************************************************************
*/

//触摸中断初始化
void init_tp_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_TOUCH_INT_BASE, 0x1); //开触摸中断
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_TOUCH_INT_BASE, 0x1); //清边沿捕获寄存器
    alt_ic_isr_register(
    	PIO_TOUCH_INT_IRQ_INTERRUPT_CONTROLLER_ID, //中断控制器标号
    	PIO_TOUCH_INT_IRQ,							//硬件中断号
        tp_interrupt,							//中断服务函数
        NULL,									//指向与设备驱动实例相关的结构体，一般为NULL
        0										//保留位，设置为0
        );
}

//关触摸屏中断
void disable_tp_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_TOUCH_INT_BASE, 0x0);
}

//开触摸屏中断
void enable_tp_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_TOUCH_INT_BASE, 0x1);
}

/************************************************************
*
*           触摸屏中断函数
*
*************************************************************
*/

//触摸按键中断初始化
void init_touch_key_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_BACK_BASE, 0x1); //开触摸按键中断
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_BACK_BASE, 0x1); //清边沿捕获寄存器
    alt_ic_isr_register(
        PIO_BACK_IRQ_INTERRUPT_CONTROLLER_ID,   //中断控制器标号
        PIO_BACK_IRQ,							//硬件中断号
        touch_key_interrupt,					//中断服务函数
        NULL,
        0										//保留位，设置为0
        );
}

//关触摸按键中断
void disable_touch_key_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_BACK_BASE, 0x0);
}

//开触摸按键中断
void enable_touch_key_interrupt(){
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(PIO_BACK_BASE, 0x1);
}

/************************************************************
*
*           串口函数
*
*************************************************************
*/

//UART中断服务程序,串口接收输入的字符串
void uart_interrupt(void * context){
    while(!(IORD_ALTERA_AVALON_UART_STATUS(UART_BASE)     //检查状态寄存器RX_RDY位,等待其置1(接收完毕)
             & ALTERA_AVALON_UART_STATUS_RRDY_MSK ));
    rxdata = IORD_ALTERA_AVALON_UART_RXDATA(UART_BASE);   //读取接收数据(char型)
    if(rx_flag == 0){
		rx_str[cnt++] =  rxdata;								//将字符保存到字符串中
		if(rxdata == '\n'){                                     //判断换行符作为结束标志(必有且只有一个换行符)
			rx_str[cnt] = '\0';									//串口助手输入的字符串必须以换行符结束
			rx_flag = 1;
			cnt = 0;}
		else if(cnt == uart_disp_str){
			rx_str[cnt] = '\0';									//串口助手输入的字符串必须以换行符结束
			rx_flag = 1;
			cnt = 0;}
    }
}

//UART中断初始化程序
void init_uart_interrupt(){
    usleep(100000);											//延时等待设备空闲
    IOWR_ALTERA_AVALON_UART_STATUS(UART_BASE,0);          //清零状态寄存器
    IOWR_ALTERA_AVALON_UART_CONTROL(
            UART_BASE,
            ALTERA_AVALON_UART_CONTROL_RRDY_MSK				//使能接收数据完成中断
            );
    alt_irq_register(UART_IRQ,NULL,uart_interrupt);		//注册中断服务程序
}

//UART发送字符函数
void uart_send_byte(unsigned char tx_data){
    IOWR_ALTERA_AVALON_UART_TXDATA(UART_BASE, tx_data);
    while(!(IORD_ALTERA_AVALON_UART_STATUS(UART_BASE)     //检查状态寄存器TX_RDY位,等待其置1(发送完毕)，
            & ALTERA_AVALON_UART_STATUS_TRDY_MSK ));        //然后才能继续发送
    }

//UART发送字符串函数
void uart_send_str(unsigned int len, unsigned char *str){
    while(len--){
        uart_send_byte(*str++);
        }
    }

