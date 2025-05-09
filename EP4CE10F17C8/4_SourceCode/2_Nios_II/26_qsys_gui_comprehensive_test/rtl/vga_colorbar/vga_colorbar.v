//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved	                               
//----------------------------------------------------------------------------------------
// File name:           vga_colorbar
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        vga彩条显示
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:		    正点原子
// Modified date:	    2018/1/30 11:12:36
// Version:			    V1.1
// Descriptions:	    vga彩条显示
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module vga_colorbar(
    input           vga_clk_w,        //系统时钟
    input           sys_rst_n,      //复位信号
    //VGA接口                          
    output          vga_hs,         //行同步信号
    output          vga_vs,         //场同步信号
    output  [15:0]  vga_rgb         //红绿蓝三原色输出 
    ); 

//reg define
reg          clk_25m;

//wire define
wire         rst_n_w;               //内部复位信号
wire [15:0]  pixel_data_w;          //像素点数据
wire [ 9:0]  pixel_xpos_w;          //像素点横坐标
wire [ 9:0]  pixel_ypos_w;          //像素点纵坐标    
    
//*****************************************************
//**                    main code
//***************************************************** 
//待PLL输出稳定之后，停止复位
assign rst_n_w = sys_rst_n;

always @(posedge vga_clk_w or negedge sys_rst_n) begin
    if(!sys_rst_n)
        clk_25m <= 1'b0;
    else
        clk_25m <= ~clk_25m;
end

vga_driver u_vga_driver(
    .vga_clk        (clk_25m),    
    .sys_rst_n      (rst_n_w),    

    .vga_hs         (vga_hs),       
    .vga_vs         (vga_vs),       
    .vga_rgb        (vga_rgb),      
    
    .pixel_data     (pixel_data_w), 
    .pixel_xpos     (pixel_xpos_w), 
    .pixel_ypos     (pixel_ypos_w)
    ); 
    
vga_display u_vga_display(
    .vga_clk        (clk_25m),
    .sys_rst_n      (rst_n_w),
    
    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (pixel_data_w)
    );   
    
endmodule 