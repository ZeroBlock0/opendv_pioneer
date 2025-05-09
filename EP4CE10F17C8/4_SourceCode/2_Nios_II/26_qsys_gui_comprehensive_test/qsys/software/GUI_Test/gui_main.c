#include <stdio.h>
#include "GUI.h"
#include "system.h"
#include "io.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "draw_page.h"
#include "calendar.h"
#include "wm8978.h"
#include "unistd.h"
#include <string.h>
#include "mculcd.h"

alt_u16 page_now  = page_home;   //当前页面
alt_u16 page_next = page_home;   //下一个页面

alt_u16 icon = 0;		//触摸的图标
alt_u16 touch;          //是否有触摸操作
alt_u16 x_pos_pre; 		//前x坐标
alt_u16 y_pos_pre; 		//前y坐标
alt_u16 x_pos;          //当前x坐标
alt_u16 y_pos;          //当前y坐标
alt_u32 tp_pos = 0;		//当前触点数据
alt_u32 tp_pos_pre = 0;	//上一次触点数据
alt_u8 touch_flag = 0; //触摸TPAD按下的标志

//主页面各图标（分为16个区域）使能
#if (BOARD_TYPE==1)   //开拓者开发板各图标使能
	alt_u8 icon_en[16] = {1,1,1,1, 1,1,1,1, 1,1,1,1, 1,1,0,0 };
#else                 //新起点开发板各图标使能
	alt_u8 icon_en[16] = {1,1,1,1, 1,1,1,1, 1,1,1,0, 0,0,0,0 };
#endif
//各LED使能
alt_u8 led[4] = {0,0,0,0};

//蜂鸣器使能
alt_u8  buzzer = 0;

//数码管使能
alt_u8  seg_en = 0;
//数码管数值
alt_u8 seg_num = 0;
//AP3216C
extern _ap3216 ap3216;	//数据结构体

extern _lcd_dev lcddev;	//管理LCD重要参数
_lcd_gui lcdgui;

alt_u16 height_ave32 = 0;  //Y方向32等分
alt_u16 width_ave8 = 0;    //X方向8等分

//ADDA(PCF8591)
float ad_val;	//AD采集到的模拟电压
//UART发送字符串
char tx_buffer[25] = "Hello, World! \n";
//接收字符串完成标志
alt_u8  rx_flag = 0;
//RTC
extern _calendar_obj calendar;	//日历结构体
//音频音量
alt_u8 wm8978_en=0; //音量使能
alt_8  vol=30;   //音量设置
//红外遥控键值
alt_u8 remote_key = 0;
alt_u8 remote_key_pre = 0;
//手写画笔参数
alt_u8 paint_over = 1;
alt_u8 paint_en = 0;
//OV5640摄像头参数
alt_u8 ID_flag;                //ov5640的ID的判断信号
alt_u8 ov5640_exist = 0;
alt_u8 ov5640_exist_1 = 0;

//笔画结束中断程序
void paint_interrupt(void* context){
	paint_over = 1;  				//当手指离开屏幕时，一个笔画结束，该位置1
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_PAINT_BASE, 0x1); //清边沿捕获寄存器
}

//LCD触摸中断程序
void tp_interrupt(void* context){
	alt_u32 y_ave4 = 0;
	alt_u32 x_ave4 = 0;

    tp_pos_pre = tp_pos;
	x_pos_pre  = x_pos;
	y_pos_pre  = y_pos;

    tp_pos = IORD(MM_BRIDGE_TOUCH_BASE,1);
    x_pos = tp_pos>>16;
    y_pos = tp_pos&0xffff;
    if(lcddev.id == 0x9341){
          	x_pos -= 140;
          	y_pos -= 140;
          	x_pos = 240.0/3800 * x_pos;
          	y_pos = 320.0/3800 * y_pos;
          }
    else if(lcddev.id == 0x5310){
          	x_pos -= 140;
          	y_pos -= 140;
          	x_pos = 320.0/3800 * x_pos;
          	y_pos = 480.0/3800 * y_pos;
          }

//    printf("tp int!!\n\n");

    if((page_now==page_paint)&&(paint_over == 1)) {

  		tp_pos_pre = tp_pos;
		x_pos_pre  = x_pos;		//检测到一个笔画结束时，停止连线，开始新的笔画
    	y_pos_pre  = y_pos;
    	paint_over = 0;			//同时paint_over清零
    	paint_en = 1;			//在进入画板页面后，一旦有触摸动作，使能画笔
    }

	if ((page_now == page_paint) && (paint_en == 1)) {
		x_pos *= 480.0/lcdgui.width;
		y_pos *= 800.0/lcdgui.height;
	}

    if(tp_pos != tp_pos_pre){	//对同一坐标点长时间触摸时，只输出一次坐标
        touch = 1;

        if(page_now == page_home){
    		if(y_pos >= height_ave32*2 && y_pos <= height_ave32*30)
    		{
    			y_ave4 = height_ave32*28/4;
    			x_ave4 = lcdgui.width/4;
    			icon = ((y_pos - height_ave32*2)/y_ave4)*4 + x_pos/x_ave4;
                if(icon_en[icon]==1)
                    page_next = icon + 1; //在主页面下，点击的图标有效时，进入子界面
    		}
        }
    }
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_TOUCH_INT_BASE, 0x1); //清边沿捕获寄存器
}

//触摸按键中断程序
void touch_key_interrupt(void* context){
	touch_flag = 1;
    page_next = page_home;
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_OV5640_EN_BASE, 0);     //关闭ov5640显示
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(PIO_BACK_BASE, 0x1);    //清边沿捕获寄存器

}

//SDRAM显存的地址
alt_u16 *ram_cam = (alt_u16 *)(SDRAM_BASE + SDRAM_SPAN - 769000);

int main()
{
    alt_u8 key;
    alt_u8 key_pre;

    alt_u8 led_button;
    alt_u8 led_num;

	alt_u8 grade=vol/8;            //音频的音量级别
    alt_u8 page_5640_done = 0;     //5640子页面绘制完成页面

    int i;

    MY_LCD_Init();              //LCD初始化
    WM8978_Init();              //WM8978初始化
    WM8978_Output_Cfg(0,0);     //不使能WM8978
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_OV5640_EN_BASE, 0);     //显示GUI界面
    GUI_Init();					//uC/GUI初始化
    GUI_UC_SetEncodeUTF8();     //设置汉字编码格式
    GUI_SetFont(&GUI_FontChinese_WRYH32);

    lcdgui.width = lcddev.height;
    lcdgui.height = lcddev.width;
	height_ave32 = lcdgui.height/32;
	width_ave8 = lcdgui.width/8;

switch(lcddev.id){
	case 0x9341:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,320);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,240);	//设置缩放后图像高度
		break;
	}
	case 0x5310:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,480);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,320);	//设置缩放后图像高度
		break;
	}
	case 0x5510:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,800);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,480);	//设置缩放后图像高度
		break;
	}
	case 0x1963:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,800);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,480);	//设置缩放后图像高度
		break;
	}
	case 0x4342:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,480);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,272);	//设置缩放后图像高度
		break;
	}
	case 0x4384:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,800);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,480);	//设置缩放后图像高度
		break;
	}
	case 0x7084:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,800);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,480);	//设置缩放后图像高度
		break;
	}
	case 0x7016:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,1024);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,600);	//设置缩放后图像高度
		break;
	}
	case 0x1018:{
		IOWR(ALT_VIP_CL_SCL_0_BASE,3,1280);	//设置缩放后图像宽度
		IOWR(ALT_VIP_CL_SCL_0_BASE,4,800);	//设置缩放后图像高度
		break;
	}
	default: ;
}

    IOWR(ALT_VIP_CL_SCL_0_BASE,0,1);	//启动缩放模块
	IOWR_ALTERA_AVALON_PIO_DATA(PIO_LCD_INIT_DONE_BASE,1);    //初始化完成

    init_tp_interrupt();		//触摸屏中断初始化
    init_touch_key_interrupt(); //触摸按键中断初始化
    init_uart_interrupt();		//串口中断初始化
    init_paint_interrupt();		//手写画笔中断初始化
    disable_paint_interrupt();	//初始化关闭画笔结束中断

	gui_draw_sys_test_page();   //画系统测试界面
    gui_draw_home_page();		//画主界面

    while(1){
    	if(page_next != page_now){				//页面跳转后重新绘制页面
          switch(page_next){
              case page_home :{
            	  disable_paint_interrupt();  	//主页面关闭画笔结束中断
                  disable_tp_interrupt();
                  if( (page_now == page_camera) && (ov5640_exist_1 == 1))
                	  ;
                  else
                  gui_draw_home_page();
                  IOWR_ALTERA_AVALON_PIO_DATA(PIO_PAGE_PAINT_FLAG_BASE, 0);

                  page_now = page_next;
                  enable_tp_interrupt();
                  break;}
              case page_key :{
                  disable_tp_interrupt();
                  disable_touch_key_interrupt();
                  gui_draw_page_key();
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                  break;}
              case page_led :{
                  disable_tp_interrupt();
                  disable_touch_key_interrupt();
                  gui_draw_page_led();
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                  break;}
              case page_segled:{
                  disable_tp_interrupt();
                  disable_touch_key_interrupt();
                  gui_draw_page_segled();
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                  break;}
              case page_buzzer:{
                  disable_tp_interrupt();
                  disable_touch_key_interrupt();
                  gui_draw_page_buzzer();
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                  break;}
              case page_uart:{
                  disable_tp_interrupt();
                  disable_touch_key_interrupt();
                  gui_draw_page_uart();
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                  break;}
              case page_remote:{
                  disable_tp_interrupt();
                  disable_touch_key_interrupt();
                  gui_draw_page_remote();
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                  break;}
              case page_paint :{
                   disable_tp_interrupt();
            	   disable_touch_key_interrupt();
                   gui_draw_page_paint();
                   page_now = page_next;
                   enable_touch_key_interrupt();
                   enable_tp_interrupt();
                   enable_paint_interrupt();     //使能画笔结束中断
                   paint_en = 0;			     //在刚进入画板时，关闭画笔使能，等待触摸操作
                   IOWR_ALTERA_AVALON_PIO_DATA(PIO_PAGE_PAINT_FLAG_BASE, 1);
                   break;}
              case page_eeprom :{
                  disable_tp_interrupt();
            	   disable_touch_key_interrupt();
                   gui_draw_page_eeprom();
                   page_now = page_next;
                   enable_touch_key_interrupt();
                   enable_tp_interrupt();
                   break;}
              case page_clock :{
                  disable_tp_interrupt();
            	   disable_touch_key_interrupt();
                   gui_draw_page_clock();
                   page_now = page_next;
                   enable_touch_key_interrupt();
                   enable_tp_interrupt();
                   break;}
              case page_adda :{
                  disable_tp_interrupt();
            	   disable_touch_key_interrupt();
                   gui_draw_page_adda();
                   page_now = page_next;
                   enable_touch_key_interrupt();
                   enable_tp_interrupt();
                   break;}
              case page_ap3216 :{
                  disable_tp_interrupt();
            	  disable_touch_key_interrupt();
                  gui_draw_page_ap3216();
                  AP3216C_Init();
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                   break;}
              case page_music :{
                  disable_tp_interrupt();
            	  disable_touch_key_interrupt();
                  gui_draw_page_music(wm8978_en,grade);
                  WM8978_I2S_Cfg(2,3);
                  WM8978_ADDA_Cfg(1,1);
                  WM8978_Input_Cfg(0,1,0);
                  WM8978_LINEIN_Gain(7);
                  page_now = page_next;
                  enable_touch_key_interrupt();
                  enable_tp_interrupt();
                   break;
                   }
			  case page_camera:{
                  disable_tp_interrupt();
            	   disable_touch_key_interrupt();
                   gui_draw_page_camera();
			       page_5640_done = 0;
                   page_now = page_next;
                   enable_touch_key_interrupt();
                   enable_tp_interrupt();
				  break;}
			  case page_ethernet:{
                  disable_tp_interrupt();
            	   disable_touch_key_interrupt();
            	   gui_draw_page_ethernet();
                   page_now = page_next;
                   enable_touch_key_interrupt();
                   enable_tp_interrupt();
				  break;}
          }
      }
      else {
          switch(page_now){						//当前页面下的动态操作
              case page_home:{
            	  draw_home();
                  break;}
              case page_key :{
                  while(page_next == page_key){
                      key_pre = key;
                      key = IORD_ALTERA_AVALON_PIO_DATA(PIO_KEY_BASE);
                      if(key != key_pre){
                          switch(key_pre){
                              case 0:break;
                              case 1:{draw_key(0, GUI_YELLOW);break;}
                              case 2:{draw_key(1, GUI_YELLOW);break;}
                              case 4:{draw_key(2, GUI_YELLOW);break;}
                              case 8:{draw_key(3, GUI_YELLOW);break;}}
                          switch(key){
                              case 0:break;
                              case 1:{draw_key(0, GUI_RED);break;}
                              case 2:{draw_key(1, GUI_RED);break;}
                              case 4:{draw_key(2, GUI_RED);break;}
                              case 8:{draw_key(3, GUI_RED);break;}}
                      }
                  }
                  break;}
              case page_led :{
                  while(page_next == page_led){
                      if(touch && (y_pos > height_ave32*17) && (y_pos < height_ave32*21)){
                          led_button = x_pos*4/lcdgui.width;
                          if(led[led_button] == 0)
                              led[led_button] = 1;
                          else
                              led[led_button] = 0;
                          touch = 0;
                          for(i=0;i<=3;i++){
                              if(led[i] == 0) draw_led(i, 0);
                              else  draw_led(i, 1);
                          }
                      }

                      led_num = led[0] + 2*led[1] + 4*led[2] + 8*led[3];
                      IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, led_num);
                      }
                  break;}
              case page_segled :{
                  while(page_next == page_segled){
                      if(touch && (y_pos > height_ave32*22) && (y_pos < height_ave32*26)){
                          if((x_pos > width_ave8*3) && (x_pos < width_ave8*5)){
                              if(seg_en == 0) seg_en = 1;
                              else seg_en = 0;
                          }
                          else if((seg_en == 1) && (x_pos > width_ave8) && (x_pos < width_ave8*2)){
                              if(seg_num>0) seg_num--;
                              else seg_num = 0;
                          }
                          else if((seg_en == 1) && (x_pos > width_ave8*6) && (x_pos < width_ave8*7)){
                              if(seg_num<9) seg_num++;
                              else seg_num = 9;
                          }
                          touch = 0;
                      draw_segled(seg_en, seg_num);
                      }
                      IOWR(MM_BRIDGE_SEG_BASE, 0,seg_num);
                      IOWR(MM_BRIDGE_SEG_BASE, 1,seg_en);
                  }
                  break;}
              case page_buzzer :{
                  while(page_next == page_buzzer){
                      if(touch && (y_pos > height_ave32*22) && (y_pos < height_ave32*26) && (x_pos > width_ave8*1) && (x_pos < width_ave8*7)){
                          if(buzzer == 0) buzzer = 1;
                          else buzzer = 0;
                          touch = 0;
                          draw_buzzer(buzzer);

                      }
                      IOWR_ALTERA_AVALON_PIO_DATA(PIO_BUZZER_BASE, buzzer);

                  }
                  break;}
              case page_uart :{
                  while(page_next == page_uart){
                      draw_uart_rx(rx_flag);
                      if(touch && (y_pos > height_ave32*22) && (y_pos < height_ave32*26) && (x_pos > width_ave8*3) && (x_pos < width_ave8*6)){
                          uart_send_str(strlen(tx_buffer),tx_buffer);
                          touch = 0;
                          draw_uart_tx();
                      }
                  }
                  break;}
              case page_remote :{
                  while(page_next == page_remote){
                      remote_key_pre = remote_key;
                      remote_key = IORD(MM_BRIDGE_REMOTE_BASE,0);
                      if(remote_key != remote_key_pre)
                      {
                    	  draw_remote();
                      }

                  }
                  break;}
              case page_paint :{
                  while(page_next == page_paint){
                       if(paint_en == 1){
      						if (tp_pos_pre == tp_pos)
   							GUI_DrawPoint(x_pos, y_pos);
   						else
   							GUI_DrawLine(x_pos_pre,y_pos_pre,x_pos,y_pos );

                       	alt_dcache_flush_all();
                       }
                  }
                  break;}
              case page_eeprom :{
                  while(page_next == page_eeprom){
                     if(touch && (y_pos > height_ave32*22) && (y_pos < height_ave32*26) && (x_pos > width_ave8*3) && (x_pos < width_ave8*6)){
                  	   draw_eeprom();
                  	   touch = 0;
                     }
                  }
                  break;}
              case page_clock :{
                  while(page_next == page_clock){
                     calendar_play();
                  }
                  break;}
              case page_adda :{
                  while(page_next == page_adda){
                  	  if(touch && (y_pos > height_ave32*22) && (y_pos < height_ave32*26) && (x_pos > width_ave8*3) && (x_pos < width_ave8*6)){
                  	  	alt_u16 da_val=0;
                  	  	alt_u8 ad,adda_en;
                  	  	while(da_val<=255){
                  	  		adda_en = 1;
                  	  		IOWR(MM_BRIDGE_ADDA_BASE,0,da_val);
                                IOWR(MM_BRIDGE_ADDA_BASE,1,adda_en);	//地址1,使能adda
                                adda_en = 0;
                                while(IORD(MM_BRIDGE_ADDA_BASE,2)==0) {
                                	if(page_next != page_adda)
                                		break;
                                }
                                IOWR(MM_BRIDGE_ADDA_BASE,1,adda_en);	//地址1,使能adda
                                while(IORD(MM_BRIDGE_ADDA_BASE,3)==0) {
                                	if(page_next != page_adda)
                                		break;
                                }
                                ad = IORD(MM_BRIDGE_ADDA_BASE,4);
                                ad_val= ad * 3.3f;
                                ad_val /= 255;
                                if(da_val >= 256)
                                	draw_adda(255,ad_val);
                                else
                                	draw_adda(da_val,ad_val);
                                touch = 0;
                                if((da_val >= 256) || (page_next != page_adda))
                                	break;
                                //da_val++;
                                da_val = da_val + 5;
                                if(da_val >= 256) da_val = 256;
                                usleep(10000);
                  	  	}
                  	  }
                  	  IOWR(MM_BRIDGE_ADDA_BASE,1,0);
                  }
                  break;}
              case page_ap3216:{
                  while(page_next == page_ap3216){
                	   ap3216_data_get(&ap3216);
                	   draw_ap3216();
                  }
                  break;}
              case page_music :{
                  while(page_next == page_music){
                	  if(touch && (y_pos > height_ave32*22) && (y_pos < height_ave32*26)){
                		   if((x_pos > width_ave8*3) && (x_pos < width_ave8*5)){
               			   if(wm8978_en == 0) {
               				   wm8978_en = 1;
               				   WM8978_Output_Cfg(1,0);
               			   }
               			   else {
               				   wm8978_en = 0;
               				   WM8978_Output_Cfg(0,0);
               			   }
               		   }
                 		   else if((wm8978_en == 1) && (x_pos > width_ave8) && (x_pos < width_ave8*2)){
               			   if(vol>0) {
               				   vol -= 8;
               				   vol = (vol < 0) ? 0 :vol;
               			   }
               			   else vol = 0;
               		   }
                 		   else if((wm8978_en == 1) && (x_pos > width_ave8*6) && (x_pos < width_ave8*7)){
               			   if(vol<63) {
               				   vol += 8;
               				   vol = vol >= 64 ? 63 : vol;
               			   }
               			   else vol = 63;
               		   }
               		   app_wm8978_volset(vol);
               		   touch = 0;
               		   grade = (vol + 1)/8;
               		   draw_music(wm8978_en,grade);
               	   }
                  }
                  break;
              }
    		  case page_camera :{
    			  while(page_next == page_camera){
					  usleep(10000);
					  ID_flag = IORD_ALTERA_AVALON_PIO_DATA(PIO_OV5640_ID_BASE);
					  if((!ID_flag)&(!page_5640_done)&(ov5640_exist == 0))
					  {
					 		//printf("draw ov5640 not connected\n");
					 	draw_ov5640();
					 	page_5640_done = 1;
					 	ov5640_exist_1 = 0;
					  }
					  else if(ID_flag == 1){
					 	ov5640_exist = 1;
					 	ov5640_exist_1 = 1;
					  }
					  else if(ID_flag == 0)
					 	ov5640_exist = 0;
				  }
    			  break;}
			  case page_ethernet:{
                  while(page_next == page_ethernet){
                	  draw_ethernet();}
				  break;}
          }
    }
}
return 0;
}

