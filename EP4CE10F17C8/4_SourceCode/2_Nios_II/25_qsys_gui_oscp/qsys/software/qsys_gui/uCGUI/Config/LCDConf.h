/*
*********************************************************************************************************
*                                                uC/GUI
*                        Universal graphic software for embedded applications
*
*                       (c) Copyright 2002, Micrium Inc., Weston, FL
*                       (c) Copyright 2002, SEGGER Microcontroller Systeme GmbH
*
*              礐/GUI is protected by international copyright laws. Knowledge of the
*              source code may not be used to write a similar product. This file may
*              only be used in accordance with a license and should not be redistributed
*              in any way. We appreciate your understanding and fairness.
*
----------------------------------------------------------------------
File        : LCDConf.h
Purpose     : Sample configuration file
----------------------------------------------------------------------
*/

#ifndef LCDCONF_H
#define LCDCONF_H

/*********************************************************************
*
*                   General configuration of LCD
*
**********************************************************************
*/

#define LCD_XSIZE          (480)    /* 配置TFT的水平分辨率  */
#define LCD_YSIZE          (272)    /* 配置TFT的垂直分辨率  */

#define LCD_BITSPERPIXEL   (16)     /* 每个像素的位数  */

#define LCD_CONTROLLER     (666)    /* TFT控制器的名称 */
#define LCD_FIXEDPALETTE   (565)    /* 调色板格式 */
#define LCD_SWAP_RB        (1)      /* 红蓝反色交换 */
// #define LCD_SWAP_XY        (1)
#define LCD_INIT_CONTROLLER()  LCD_L0_Init();   /* TFT初始化函数  */

#endif /* LCDCONF_H */

 
