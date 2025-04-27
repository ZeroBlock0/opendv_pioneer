//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           lcd_rgb_top
// Last modified Date:  2018/3/21 13:58:23
// Last Version:        V1.0
// Descriptions:        LCD顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/21 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_rgb_top(
    input           lcd_clk,        //LCD驱动时钟
    input           sys_rst_n,      //复位信号
    //lcd接口                          
    output          lcd_hs,         //LCD 行同步信号
    output          lcd_vs,         //LCD 场同步信号
    output          lcd_de,         //LCD 数据输入使能
    output  [15:0]  lcd_rgb,        //LCD RGB565颜色数据
    output          lcd_bl,         //LCD 背光控制信号
    output          lcd_rst,        //LCD 复位信号
    output          lcd_pclk,       //LCD 采样时钟
    
    input   [15:0]  fifo_pixel_data,//fifo中读出的像素数据 
    output          fifo_data_req,  //请求fifo中的数据    
    
    input   [7:0]   line_length,    
    output  [8:0]   line_cnt,
    output          data_req,       //请求像素点颜色数据输入
    output          wr_over,
    input           outrange,

    input   [9:0]   v_shift,        //波形竖直偏移量，bit[9]=0/1:左移/右移 
    input   [4:0]   v_scale,        //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input   [7:0]   trig_line       //触发电平
    );

//wire define
wire [15:0]  lcd_data_w  ;          //像素点数据
wire [ 9:0]  pixel_xpos_w;          //像素点横坐标
wire [ 9:0]  pixel_ypos_w;          //像素点纵坐标    
    
//*****************************************************
//**                    main code
//***************************************************** 

//lcd驱动模块
lcd_driver u_lcd_driver(            
    .lcd_clk        (lcd_clk),    
    .sys_rst_n      (sys_rst_n),    

    .lcd_hs         (lcd_hs),       
    .lcd_vs         (lcd_vs),       
    .lcd_de         (lcd_de),       
    .lcd_rgb        (lcd_rgb),
    .lcd_bl         (lcd_bl),
    .lcd_rst        (lcd_rst),
    .lcd_pclk       (lcd_pclk),
    
    .data_req       (fifo_data_req),
    .pixel_xpos     (pixel_xpos_w), 
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (lcd_data_w) 
    ); 
    
//lcd显示模块
lcd_display u_lcd_display(          
    .lcd_clk         (lcd_clk),    
    .sys_rst_n       (sys_rst_n),
    
    .pixel_xpos      (pixel_xpos_w),
    .pixel_ypos      (pixel_ypos_w),
    .lcd_data        (lcd_data_w),
    
    .fifo_pixel_data (fifo_pixel_data),
    
    .line_cnt        (line_cnt), 
    .line_length     (line_length),
    .data_req        (data_req),
    .wr_over         (wr_over),
    .outrange        (outrange),
    
    .v_shift         (v_shift),
    .v_scale         (v_scale),
    .trig_line       (trig_line)
    );   
    
endmodule 