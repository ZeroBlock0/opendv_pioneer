//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved	                               
//----------------------------------------------------------------------------------------
// File name:           rlcd_driver
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        RGB LCD驱动
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
// Descriptions:	    RGB LCD驱动
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module rlcd_driver(
    input              lcd_clk,      //lcd模块驱动时钟
    input              sys_rst_n,    //复位信号
    //RGB LCD接口                             
    output             lcd_hs,       //LCD 行同步信号
    output             lcd_vs,       //LCD 场同步信号
    output             lcd_de,       //LCD 数据输入使能
    output     [15:0]  lcd_data,     //LCD RGB565颜色数据    
    output             lcd_bl,       //LCD 背光控制信号
    output             lcd_rst,      //LCD 复位信号
    output             lcd_pclk,     //LCD 采样时钟
       
    output             data_req  ,   //请求像素点颜色数据输入 
    output     [10:0]  pixel_xpos,   //像素点横坐标
    output     [10:0]  pixel_ypos,   //像素点纵坐标
    input      [15:0]  pixel_data,  //像素点数据
    input      [15:0]  lcd_id        //LCD的ID
    );                             

//parameter define  
//480*272 4.3'
parameter  H_SYNC_4342   =  11'd41;   //行同步
parameter  H_BACK_4342   =  11'd2;    //行显示后沿
parameter  H_DISP_4342   =  11'd480;  //行有效数据
parameter  H_FRONT_4342  =  11'd2;    //行显示前沿
parameter  H_TOTA_4342   =  11'd525;  //行扫描周期

parameter  V_SYNC_4342   =  11'd10;     //场同步
parameter  V_BACK_4342   =  11'd2;    //场显示后沿
parameter  V_DISP_4342   =  11'd272;   //场有效数据
parameter  V_FRONT_4342  =  11'd2;    //场显示前沿
parameter  V_TOTAL_4342  =  11'd286;   //场扫描周期

//7' 800*480
parameter  H_SYNC_7084   =  11'd128;   //行同步
parameter  H_BACK_7084   =  11'd88;    //行显示后沿
parameter  H_DISP_7084   =  11'd800;   //行有效数据
parameter  H_FRONT_7084  =  11'd40;    //行显示前沿
parameter  H_TOTAL_7084  =  11'd1056;  //行扫描周期

parameter  V_SYNC_7084   =  11'd2;     //场同步
parameter  V_BACK_7084   =  11'd33;    //场显示后沿
parameter  V_DISP_7084   =  11'd480;   //场有效数据
parameter  V_FRONT_7084  =  11'd10;    //场显示前沿
parameter  V_TOTAL_7084  =  11'd525;   //场扫描周期
          
//7' 1024*600
parameter  H_SYNC_7016   =  11'd20;   //行同步
parameter  H_BACK_7016   =  11'd140;    //行显示后沿
parameter  H_DISP_7016   =  11'd1024;   //行有效数据
parameter  H_FRONT_7016  =  11'd160;    //行显示前沿
parameter  H_TOTAL_7016  =  11'd1344;  //行扫描周期

parameter  V_SYNC_7016   =  11'd3;     //场同步
parameter  V_BACK_7016   =  11'd20;    //场显示后沿
parameter  V_DISP_7016   =  11'd600;   //场有效数据
parameter  V_FRONT_7016  =  11'd12;    //场显示前沿
parameter  V_TOTAL_7016  =  11'd635;   //场扫描周期

//10.1' 1280*800
parameter  H_SYNC_1018   =  11'd10;   //行同步
parameter  H_BACK_1018   =  11'd80;    //行显示后沿
parameter  H_DISP_1018   =  11'd1280;   //行有效数据
parameter  H_FRONT_1018  =  11'd70;    //行显示前沿
parameter  H_TOTAL_1018  =  11'd1440;  //行扫描周期

parameter  V_SYNC_1018   =  11'd3;     //场同步
parameter  V_BACK_1018   =  11'd10;    //场显示后沿
parameter  V_DISP_1018   =  11'd800;   //场有效数据
parameter  V_FRONT_1018  =  11'd10;    //场显示前沿
parameter  V_TOTAL_1018  =  11'd823;   //场扫描周期

//reg define                                     
reg  [10:0] cnt_h;
reg  [10:0] cnt_v;
reg  [10:0] h_sync ;
reg  [10:0] h_back ;
reg  [10:0] h_disp ;
reg  [10:0] h_front;
reg  [10:0] h_total;
reg  [10:0] v_sync ;
reg  [10:0] v_back ;
reg  [10:0] v_disp ;
reg  [10:0] v_front;
reg  [10:0] v_total;

//wire define
wire       lcd_en;

//*****************************************************
//**                    main code
//*****************************************************
assign lcd_bl   = 1'b1;           //RGB LCD显示模块背光控制信号
assign lcd_rst  = 1'b1;           //RGB LCD显示模块系统复位信号
assign lcd_pclk = lcd_clk;        //RGB LCD显示模块采样时钟

//RGB LCD 采用数据输入使能信号同步时，行场同步信号需要拉高
assign lcd_de  = lcd_en;          //LCD输入的颜色数据采用数据输入使能信号同步
assign lcd_hs  = 1'b1;
assign lcd_vs  = 1'b1;

//RGB565数据输出                 
assign lcd_data = lcd_de ? pixel_data : 16'd0;

//使能RGB565数据输出
assign lcd_en  = (((cnt_h >= h_sync+h_back) && (cnt_h < h_sync+h_back+h_disp))
                 &&((cnt_v >= v_sync+v_back) && (cnt_v < v_sync+v_back+v_disp)))
                 ?  1'b1 : 1'b0;
                 


//请求像素点颜色数据输入                
assign data_req = (((cnt_h >= h_sync+h_back-1'b1) && (cnt_h < h_sync+h_back+h_disp-1'b1))
                  && ((cnt_v >= v_sync+v_back) && (cnt_v < v_sync+v_back+v_disp)))
                  ?  1'b1 : 1'b0;

//像素点坐标                
assign pixel_xpos = data_req ? (cnt_h - (h_sync + h_back - 1'b1)) : 11'd0;
assign pixel_ypos = data_req ? (cnt_v - (v_sync + v_back - 1'b1)) : 11'd0;

//行场时序参数
always @(posedge lcd_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        h_sync  <= H_SYNC_4342; 
        h_back  <= H_BACK_4342; 
        h_disp  <= H_DISP_4342; 
        h_front <= H_FRONT_4342;
        h_total <= H_TOTA_4342;
        v_sync  <= V_SYNC_4342; 
        v_back  <= V_BACK_4342; 
        v_disp  <= V_DISP_4342; 
        v_front <= V_FRONT_4342;
        v_total <= V_TOTAL_4342;
    end 
    else begin
        case(lcd_id)
        16'h4342 : begin
            h_sync  <= H_SYNC_4342; 
            h_back  <= H_BACK_4342; 
            h_disp  <= H_DISP_4342; 
            h_front <= H_FRONT_4342;
            h_total <= H_TOTA_4342;
            v_sync  <= V_SYNC_4342; 
            v_back  <= V_BACK_4342; 
            v_disp  <= V_DISP_4342; 
            v_front <= V_FRONT_4342;
            v_total <= V_TOTAL_4342;
        end 
        16'h4384 : begin
            h_sync  <= H_SYNC_7084; 
            h_back  <= H_BACK_7084; 
            h_disp  <= H_DISP_7084; 
            h_front <= H_FRONT_7084;
            h_total <= H_TOTAL_7084;
            v_sync  <= V_SYNC_7084; 
            v_back  <= V_BACK_7084; 
            v_disp  <= V_DISP_7084; 
            v_front <= V_FRONT_7084;
            v_total <= V_TOTAL_7084;
        end 		  
        16'h7084 : begin
            h_sync  <= H_SYNC_7084; 
            h_back  <= H_BACK_7084; 
            h_disp  <= H_DISP_7084; 
            h_front <= H_FRONT_7084;
            h_total <= H_TOTAL_7084;
            v_sync  <= V_SYNC_7084; 
            v_back  <= V_BACK_7084; 
            v_disp  <= V_DISP_7084; 
            v_front <= V_FRONT_7084;
            v_total <= V_TOTAL_7084;
        end 
        16'h7016 : begin 
            h_sync  <= H_SYNC_7016; 
            h_back  <= H_BACK_7016; 
            h_disp  <= H_DISP_7016; 
            h_front <= H_FRONT_7016;
            h_total <= H_TOTAL_7016;
            v_sync  <= V_SYNC_7016; 
            v_back  <= V_BACK_7016; 
            v_disp  <= V_DISP_7016; 
            v_front <= V_FRONT_7016;
            v_total <= V_TOTAL_7016;
        end          
        16'h1018 : begin 
            h_sync  <= H_SYNC_1018; 
            h_back  <= H_BACK_1018; 
            h_disp  <= H_DISP_1018; 
            h_front <= H_FRONT_1018;
            h_total <= H_TOTAL_1018;
            v_sync  <= V_SYNC_1018; 
            v_back  <= V_BACK_1018; 
            v_disp  <= V_DISP_1018; 
            v_front <= V_FRONT_1018;
            v_total <= V_TOTAL_1018;
        end 
        default : ;
        endcase
    end 
end 

//行计数器对像素时钟计数
always @(posedge lcd_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)
        cnt_h <= 11'd0;                                  
    else begin
        if(cnt_h < h_total - 1'b1)                                               
            cnt_h <= cnt_h + 1'b1;                               
        else 
            cnt_h <= 11'd0;  
    end
end

//场计数器对行计数
always @(posedge lcd_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n)
        cnt_v <= 11'd0;                                  
    else if(cnt_h == h_total - 1'b1) begin
        if(cnt_v < v_total - 1'b1)                                               
            cnt_v <= cnt_v + 1'b1;                               
        else 
            cnt_v <= 11'd0;  
    end
end

endmodule 