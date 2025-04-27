//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           lcd_signal_sel
// Last modified Date:  2018/12/4 16:20:36
// Last Version:        V1.1
// Descriptions:        LCD信号选择
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/11/2 16:20:36
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_signal_sel(
    input                   clk               , //时钟
    input                   rst_n             , //复位，低电平有效
    
    //MCU LCD interfac
    inout          [15:0]   mlcd_data         , // LCD 数据信号
    output  reg             mlcd_bl           , // LCD 背光信号
    output  reg             mlcd_cs_n         , // LCD 片选信号
    output  reg             mlcd_wr_n         , // LCD 写信号
    output  reg             mlcd_rd_n         , // LCD 读信号
    output  reg             mlcd_rs           , // LCD 命令/数据信号
    output  reg             mlcd_rst_n        , // LCD 复位信号  
    //LCD初始化
    input                   mlcd_cs_n_init    ,   
    input                   mlcd_wr_n_init    ,  
    input                   mlcd_rd_n_init    ,  
    input                   mlcd_rst_n_init   ,  
    input                   mlcd_rs_init      ,  
    input                   mlcd_bl_init      ,  
    input                   mlcd_data_dir_init,  
    input         [15:0]    mlcd_data_out_init,  
    output        [15:0]    mlcd_data_in_init ,  
    input                   lcd_init_done     ,
    //MCU LCD驱动
    input                   mlcd_bl_dri ,       
    input                   mlcd_cs_dri ,       
    input                   mlcd_rst_dri,       
    input                   mlcd_wr_dri ,       
    input                   mlcd_rd_dri ,       
    input                   mlcd_rs_dri ,       
    input         [15:0]    mlcd_data_dri
    );

//reg define
reg      [15:0]   mlcd_data_out;
reg               mlcd_data_dir;

//wire define
assign mlcd_data = (mlcd_data_dir == 1'b1) ? mlcd_data_out : {16{1'bz}};
assign mlcd_data_in_init = mlcd_data;

//*****************************************************
//**                    main code
//*****************************************************

always @(*) begin
    if(!lcd_init_done) begin   //初始化MCU LCD
        mlcd_rst_n = mlcd_rst_n_init;
        mlcd_bl = mlcd_bl_init;      
        mlcd_cs_n = mlcd_cs_n_init; 
        mlcd_rs = mlcd_rs_init; 
        mlcd_wr_n = mlcd_wr_n_init; 
        mlcd_rd_n= mlcd_rd_n_init;
        mlcd_data_dir = mlcd_data_dir_init;        
        mlcd_data_out = mlcd_data_out_init;
    end
    else begin                //驱动MCU LCD
        mlcd_data_dir = 1'b1;
        mlcd_rst_n = mlcd_rst_dri;
        mlcd_bl = mlcd_bl_dri;      
        mlcd_cs_n = mlcd_cs_dri; 
        mlcd_rs = mlcd_rs_dri; 
        mlcd_wr_n = mlcd_wr_dri; 
        mlcd_rd_n= mlcd_rd_dri;
        mlcd_data_out = mlcd_data_dri;
    end    
end

endmodule 
