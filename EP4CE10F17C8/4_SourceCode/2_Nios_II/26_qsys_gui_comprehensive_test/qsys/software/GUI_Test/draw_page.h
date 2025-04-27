#ifndef _DRAW_PAGE_H_
#define _DRAW_PAGE_H_

#include "GUI.h"
#include "24cxx.h"
#include "ap3216c.h"

//LCD重要参数集
typedef struct{
    u16 width;         //LCD 宽度
    u16 height;        //LCD 高度
}_lcd_gui;

extern GUI_CONST_STORAGE GUI_BITMAP bmhome_pic;
extern GUI_CONST_STORAGE GUI_BITMAP bmyinfu_01;

#define BOARD_TYPE  1   //0:新起点   1:开拓者

#define page_home   0 	//主页
#define page_key    1 	//按键测试页面
#define page_led    2   //LED测试页面
#define page_buzzer 3   //蜂鸣器测试页面
#define page_segled 4   //数码管测试页面
#define page_uart   5   //串口测试页面
#define page_remote 6   //红外遥控测试页面
#define page_eeprom 7   //EEPROM页面
#define page_ap3216 8   //AP3216页面
#define page_clock  9   //实时时钟页面
#if (BOARD_TYPE==1)
	#define page_music  10  //音乐界面
	#define page_adda   11  //AD/DA页面
	#define page_paint  12  //画板页面
	#define page_camera 13  //ov5640摄像头
#else
	#define page_paint  10  //画板页面
	#define page_camera 11  //ov5640摄像头
	#define page_music  12  //音乐界面
	#define page_adda   13  //AD/DA页面
#endif

#define page_ethernet 14//网络通信

//UART收发显示的字符串个数
#define uart_disp_str 15

//EEPROM
extern _eeprom eeprom_rw;	//数据结构体

/************************************************************
*
*           屏幕坐标定义
*
*************************************************************
*/

//屏幕原点
#define x0		  0
#define y0		  0

//图标（左上角）行地址
#define icon_row1 75
#define icon_row2 255
#define icon_row3 435
#define icon_row4 615

//图标（左上角）列地址
#define icon_col1 5
#define icon_col2 125
#define icon_col3 245
#define icon_col4 365

/************************************************************
*
*           画图函数
*
*************************************************************
*/

//画主页面及各子页面
void gui_draw_factory_test();               //画出厂测试界面
void gui_draw_sys_test_page();              //画系统测试界面
void gui_draw_home_page();                  //主页面
void gui_draw_page_key();                   //按键测试页面
void gui_draw_page_led();                   //LED测试页面
void gui_draw_page_segled();                //数码管测试页面
void gui_draw_page_buzzer();                //蜂鸣器测试页面
void gui_draw_page_uart();                  //串口测试页面
void gui_draw_page_remote();				//画红外遥控测试页面
void gui_draw_page_eeprom();
void gui_draw_page_ap3216();
void gui_draw_page_adda();
void gui_draw_page_clock();
void gui_draw_page_paint();
//void gui_draw_page_music(unsigned char wm8978_en);
void gui_draw_page_music(unsigned char wm8978_en, alt_u8 vol);
void gui_draw_page_camera();
void gui_draw_page_ethernet();

//画各子页面控件
void draw_home();							//显示时间
void draw_key(int key_num, int color);      //画按键
void draw_led(int led_num, int on_off);     //画LED
void draw_buzzer(int buzzer);               //画蜂鸣器
void draw_segled(int seg_en, int seg_num);  //画数码管
void draw_uart_rx();                        //画串口接收控件
void draw_uart_tx();                        //画串口发送控件
void draw_remote();							//画红外遥控控件
void draw_eeprom();

void draw_adda(unsigned char da_val,float ad_val);
void draw_ap3216();
//void draw_music(unsigned char wm8978_en);
void draw_music(unsigned char wm8978_en, alt_u8 vol);
void draw_ov5640();
void draw_ethernet();

/************************************************************
*
*           中断函数
*
*************************************************************
*/

//中断初始化
void init_tp_interrupt();
void init_touch_key_interrupt();
void init_paint_interrupt();

//中断服务程序
void tp_interrupt(void* context);
void touch_key_interrupt(void* context);
void paint_interrupt(void* context);

//中断开关程序
void disable_tp_interrupt();
void enable_tp_interrupt();

void disable_touch_key_interrupt();
void enable_touch_key_interrupt();

void disable_paint_interrupt();
void enable_paint_interrupt();

/************************************************************
*
*           串口函数
*
*************************************************************
*/

void uart_interrupt(void * context);
void init_uart_interrupt();
void uart_send_byte(unsigned char tx_data);
void uart_send_str(unsigned int len, unsigned char *str);

#endif
