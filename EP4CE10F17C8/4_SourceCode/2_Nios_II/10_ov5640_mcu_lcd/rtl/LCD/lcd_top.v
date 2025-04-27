//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           lcd_top
// Last modified Date:  2018/12/3 16:20:36
// Last Version:        V1.1
// Descriptions:        
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/11/2 16:20:36
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_top(
    input              clk               , //时钟50Mhz
    input              rst_n             , //复位，低电平有效  
    input    [15:0]    pixel_data        , //
    output             pixel_en          ,
    output             lcd_clk           ,                      
    //MCU LCD interfac
    inout     [15:0]   mlcd_data         , // LCD 数据信号
    output             mlcd_bl           , // LCD 背光信号
    output             mlcd_cs_n         , // LCD 片选信号
    output             mlcd_wr_n         , // LCD 写信号
    output             mlcd_rd_n         , // LCD 读信号
    output             mlcd_rs           , // LCD 命令/数据信号
    output             mlcd_rst_n        , // LCD 复位信号
    //LCD初始化
    input              mlcd_cs_n_init    ,   
    input              mlcd_wr_n_init    ,  
    input              mlcd_rd_n_init    ,  
    input              mlcd_rst_n_init   ,  
    input              mlcd_rs_init      ,  
    input              mlcd_bl_init      ,  
    input              mlcd_data_dir_init,  
    input    [15:0]    mlcd_data_out_init,  
    output   [15:0]    mlcd_data_in_init ,  
    input              lcd_init_done     ,
    input    [15:0]    lcd_id            ,
    input    [8:0]     rdusedw
    );

//wire define
wire          mlcd_bl_dri; 
wire          mlcd_cs_dri; 
wire          mlcd_rst_dri; 
wire          mlcd_wr_dri; 
wire          mlcd_rd_dri; 
wire          mlcd_rs_dri; 
wire  [15:0]  mlcd_data_dri;  

//*****************************************************
//**                    main code
//*****************************************************

lcd_signal_sel u_lcd_signal_sel(
    .clk                 (clk),
    .rst_n               (rst_n), 
    //LCD 接口
    .mlcd_data           (mlcd_data ),
    .mlcd_bl             (mlcd_bl   ),
    .mlcd_cs_n           (mlcd_cs_n ),
    .mlcd_wr_n           (mlcd_wr_n ),
    .mlcd_rd_n           (mlcd_rd_n ),
    .mlcd_rs             (mlcd_rs   ),
    .mlcd_rst_n          (mlcd_rst_n),   
    //LCD初始化
    .mlcd_cs_n_init      (mlcd_cs_n_init    ),
    .mlcd_wr_n_init      (mlcd_wr_n_init    ),
    .mlcd_rd_n_init      (mlcd_rd_n_init    ),
    .mlcd_rst_n_init     (mlcd_rst_n_init   ),
    .mlcd_rs_init        (mlcd_rs_init      ),
    .mlcd_bl_init        (mlcd_bl_init      ),
    .mlcd_data_dir_init  (mlcd_data_dir_init),
    .mlcd_data_out_init  (mlcd_data_out_init),
    .mlcd_data_in_init   (mlcd_data_in_init ),
    .lcd_init_done       (lcd_init_done     ),
    //MCU LCD驱动
    .mlcd_bl_dri         (mlcd_bl_dri    ),
    .mlcd_cs_dri         (mlcd_cs_dri    ),
    .mlcd_rst_dri        (mlcd_rst_dri   ),
    .mlcd_wr_dri         (mlcd_wr_dri    ),
    .mlcd_rd_dri         (mlcd_rd_dri    ),
    .mlcd_rs_dri         (mlcd_rs_dri    ),
    .mlcd_data_dri       (mlcd_data_dri  )
    );

//MCU LCD 驱动
mlcd_driver  u_mlcd_driver(
    .clk                 (lcd_clk      ),
    .rst_n               (rst_n        ),
    .mlcd_bl             (mlcd_bl_dri  ),
    .mlcd_cs             (mlcd_cs_dri  ),
    .mlcd_rst            (mlcd_rst_dri ),
    .mlcd_wr             (mlcd_wr_dri  ),
    .mlcd_rd             (mlcd_rd_dri  ),
    .mlcd_rs             (mlcd_rs_dri  ),
    .mlcd_data           (mlcd_data_dri),
    .lcd_init_done       (lcd_init_done),
    .lcd_id              (lcd_id       ),
    .pixel_data          (pixel_data),
    .rd_en               (pixel_en),   
    .rdusedw             (rdusedw)
    );

//分频模块，根据LCD ID输出相应频率的时钟
clk_div  u_clk_div(
    .clk_50m             (clk),
    .rst_n               (rst_n),
    .lcd_id              (lcd_id),
    .clk_lcd             (lcd_clk)
);

endmodule 
        