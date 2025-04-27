//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           OV5640摄像头MCU TFT-LCD显示实验
// Last modified Date:  2018/12/2 14:56:00
// Last Version:        V1.1
// Descriptions:        在MCU上显示摄像头图像实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/12/2 8:24:48
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         正点原子
// Modified date:       2018/12/2 14:56:00
// Version:             V1.1
// Descriptions:        增加了对正点原子多款MCU TFT-LCD屏幕的兼容
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov5640_mcu_lcd(
    //时钟和复位接口
    input           sys_clk,      //系统时钟
    input           sys_rst_n,    //系统复位，低电平有效
    
    //SDRAM 接口
    output          sdram_clk,
    output [12:0]   sdram_addr,
    output [ 1:0]   sdram_ba,
    output          sdram_cas_n,
    output          sdram_cke,
    output          sdram_cs_n,
    inout  [15:0]   sdram_dq,
    output [ 1:0]   sdram_dqm,
    output          sdram_ras_n,
    output          sdram_we_n,
    
    //摄像头接口
    input           cam_pclk,
    input           cam_vsync,
    input           cam_href,
    input  [ 7:0]   cam_data,
    output          cam_rst_n,
    output          cam_pwdn,
    output          cam_scl,
    inout           cam_sda,

    //EPCS Flash 接口
    output          epcs_dclk,
    output          epcs_sce,
    output          epcs_sdo,
    input           epcs_data0,
    
    //MCU LCD interface
    inout  [15:0]   mlcd_data ,   // LCD 数据信号
    output          mlcd_bl   ,   // LCD 背光信号
    output          mlcd_cs_n ,   // LCD 片选信号
    output          mlcd_wr_n ,   // LCD 写信号
    output          mlcd_rd_n ,   // LCD 读信号
    output          mlcd_rs   ,   // LCD 命令/数据信号
    output          mlcd_rst_n    // LCD 复位信号
);

//wire define
wire                clk_100m;
wire                clk_100m_shift;
wire                clk_50m_pll;
wire                lcd_clk;
wire                locked;
wire                rst_n;

//摄像头模块的接口信号
wire                ov5640_init_done;

//OV5640 写FIFO信号
wire                wr_en;
wire [15:0]         wr_data;
wire [8:0]          rdusedw;

//LCD驱动模块接口信号
wire                lcd_data_req;
wire [15:0]         lcd_pixel_data;

//LCD初始化信号
wire                lcd_init_done     ;
wire [15:0]         lcd_id            ;
wire                mlcd_cs_n_init    ; 
wire                mlcd_wr_n_init    ;
wire                mlcd_rd_n_init    ;
wire                mlcd_rst_n_init   ;
wire                mlcd_rs_init      ;
wire                mlcd_bl_init      ;
wire                mlcd_data_dir_init;
wire [15:0]         mlcd_data_out_init;
wire [15:0]         mlcd_data_in_init ;

//*****************************************************
//**                    main code
//*****************************************************

assign rst_n = sys_rst_n & locked ;
assign sdram_clk = clk_100m_shift;

//例化锁相环模块
pll u_pll (
    .inclk0                (sys_clk   ),
    .areset                (~sys_rst_n),
    .c0                    (clk_100m),             //QSYS 系统时钟
    .c1                    (clk_100m_shift),       //SDRAM 驱动时钟
    .c2                    (clk_50m_pll),          //LCD 驱动时钟
    .locked                (locked)
    );

//例化QSYS系统
qsys u_qsys(
    //时钟和复位
    .clk_clk               (clk_100m),
    .reset_reset_n         (rst_n),
        
    //EPCS  
    .epcs_flash_dclk       (epcs_dclk ),
    .epcs_flash_sce        (epcs_sce  ),
    .epcs_flash_sdo        (epcs_sdo  ),
    .epcs_flash_data0      (epcs_data0),
        
    //SDRAM 
    .sdram_addr            (sdram_addr),
    .sdram_ba              (sdram_ba),
    .sdram_cas_n           (sdram_cas_n),
    .sdram_cke             (sdram_cke),
    .sdram_cs_n            (sdram_cs_n),
    .sdram_dq              (sdram_dq),
    .sdram_dqm             (sdram_dqm),
    .sdram_ras_n           (sdram_ras_n),
    .sdram_we_n            (sdram_we_n),

    //PIO 输入输出
    .mlcd_cs_n_export      (mlcd_cs_n_init),            
    .mlcd_wr_n_export      (mlcd_wr_n_init),            
    .mlcd_rd_n_export      (mlcd_rd_n_init),            
    .mlcd_rst_n_export     (mlcd_rst_n_init),            
    .mlcd_rs_export        (mlcd_rs_init),            
    .mlcd_bl_export        (mlcd_bl_init),            
    .mlcd_data_in_export   (mlcd_data_in_init),            
    .mlcd_data_out_export  (mlcd_data_out_init),            
    .mlcd_data_dir_export  (mlcd_data_dir_init),            
    .lcd_init_done_export  (lcd_init_done),           //LCD初始化完成    
    .lcd_id_export         (lcd_id)                   //LCD ID     
    );

//例化ov5640模块
ov5640  u_ov5640(
    .clk                   (clk_100m),          
    .rst_n                 (rst_n & lcd_init_done),
                           
    .cam_pclk              (cam_pclk ),
    .cam_vsync             (cam_vsync),
    .cam_href              (cam_href ),
    .cam_data              (cam_data ),
    .cam_rst_n             (cam_rst_n),
    .cam_pwdn              (cam_pwdn ),
    .cam_scl               (cam_scl  ),
    .cam_sda               (cam_sda  ),
                           
    .cam_init_done         (ov5640_init_done),
    .wr_en                 (wr_en  ),
    .wr_data               (wr_data),
                
    .ID_flag               (),
    .ID_lcd                (lcd_id),
    .cmos_h_pixel          (),
    .cmos_v_pixel          ()
    );    

// FIFO：缓存ov5640输出的数据供LCD读取
fifo u_fifo(
    .wrclk                 (cam_pclk),
    .rdclk                 (lcd_clk),
                        
    .wrreq                 (wr_en ),
    .data                  (wr_data),
    .wrusedw               (),
                        
    .rdreq                 (lcd_data_req),
    .q                     (lcd_pixel_data),
    .rdempty               (),
    .rdusedw               (rdusedw),
                        
    .aclr                  (~ov5640_init_done)
    );
    
//MCU LCD驱动
lcd_top  u_lcd_top(
    .clk                   (clk_50m_pll),
    .rst_n                 (rst_n),
    .pixel_data            (lcd_pixel_data),
    .pixel_en              (lcd_data_req),
    .lcd_clk               (lcd_clk),

    .mlcd_data             (mlcd_data ),
    .mlcd_bl               (mlcd_bl   ),
    .mlcd_cs_n             (mlcd_cs_n ),
    .mlcd_wr_n             (mlcd_wr_n ),
    .mlcd_rd_n             (mlcd_rd_n ),
    .mlcd_rs               (mlcd_rs   ),
    .mlcd_rst_n            (mlcd_rst_n),
                
    .mlcd_cs_n_init        (mlcd_cs_n_init),
    .mlcd_wr_n_init        (mlcd_wr_n_init),
    .mlcd_rd_n_init        (mlcd_rd_n_init),
    .mlcd_rst_n_init       (mlcd_rst_n_init),
    .mlcd_rs_init          (mlcd_rs_init),
    .mlcd_bl_init          (mlcd_bl_init),
    .mlcd_data_dir_init    (mlcd_data_dir_init),
    .mlcd_data_out_init    (mlcd_data_out_init),
    .mlcd_data_in_init     (mlcd_data_in_init ),
    .lcd_init_done         (lcd_init_done),
    .lcd_id                (lcd_id),
    .rdusedw               (rdusedw)
    );

endmodule 