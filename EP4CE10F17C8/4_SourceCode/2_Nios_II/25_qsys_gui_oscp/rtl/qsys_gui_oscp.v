//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           qsys_gui_oscp
// Last modified Date:  2018/10/25 14:56:00
// Last Version:        V1.1
// Descriptions:        示波器
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/11 8:24:48
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         正点原子
// Modified date:       2018/10/25 14:56:00
// Version:             V1.1
// Descriptions:        
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module qsys_gui_oscp(

    //时钟和复位接口
    input           sys_clk,      //晶振时钟
    input           sys_rst_n,    //按键复位
    
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

    //AD
    output          ad_clk,     //AD(AD9280)驱动时钟,30Mhz 
    input  [7:0]    ad_data,    //AD输入数据
    input           ad_otr,     //AD超量程标志
    //DA
    output          da_clk,     //DA(AD9708)驱动时钟,50Mhz
    output [7:0]    da_data,    //DA输出数据    
    
    //EPCS Flash 接口
    output          epcs_dclk,
    output          epcs_sce,
    output          epcs_sdo,
    input           epcs_data0,

    //LCD 触摸接口
    inout           tft_sda,
    output          tft_scl,
    inout           tft_int,
    output          tft_tcs,
    
    //LCD接口
    output          lcd_hs,
    output          lcd_vs,
    output          lcd_de,
    output [15:0]   lcd_rgb,
    output          lcd_bl,
    output          lcd_rst,
    output          lcd_pclk
);

//parameter define
parameter CLK_FS = 26'd50000000;    // 频率计基准时钟频率50Mhz

//wire define
wire        clk_100m_shift;
wire        clk_100m;
wire        lcd_clk;
wire        pll_locked;
wire        rst_n;

//读写 SDRAM 桥接信号
wire        bridge_write;
wire        bridge_read;  
wire [15:0] bridge_writedata;
wire [15:0] bridge_readdata;
wire [25:0] bridge_address;
wire [ 9:0] bridge_burstcount;
wire        bridge_waitrequest;             
wire        bridge_readdatavalid;

//source_st_fifo信号
wire [9:0]  source_fifo_wrusedw;

//触摸驱动模块 avalon 总线 (touch point)
wire [ 2:0] tp_avl_address;
wire [31:0] tp_avl_writedata;
wire        tp_avl_write;
wire        tp_avl_read;
wire [31:0] tp_avl_readdata;

wire        pio_lcd_rst;
//触摸模块输出的中断信号
wire        tp_interrupt;
wire        touch_valid;

//fifo请求数据接口信号
wire [15:0] fifo_pixel_data;
wire        fifo_data_req;

wire [19:0] ad_freq;    	//AD脉冲信号的频率
wire [ 7:0] ad_vpp;     	//AD输入信号峰峰值
wire [ 7:0] ad_max;     	//AD输入信号最大值
wire [ 7:0] ad_min;     	//AD输入信号最小值

wire [9:0]  deci_rate;	    //抽样率
wire [7:0]  trig_level;     //触发电平
wire [7:0]  trig_line;      //触发线位置
wire        trig_edge;      //触发边沿
wire        wave_run;       //波形采集运行/停止
wire [9:0]  h_shift;        //波形水平偏移量
wire [9:0]  v_shift;        //波形竖直偏移量
wire [4:0]  v_scale;        //波形竖直缩放比例

wire        deci_valid; 	//抽样有效信号
wire        lcd_data_req;   
wire        lcd_wr_over;	//LCD波形绘制完成信号
wire [ 7:0] rd_ad_data;
wire [ 8:0] rd_rom_addr;
wire        outrange;


wire        avalon_write;    
wire        avalon_read;     
wire [31:0] avalon_writedata;
wire [31:0] avalon_readdata; 
wire [ 4:0] avalon_address;  

//*****************************************************
//**                    main code
//*****************************************************

assign rst_n = sys_rst_n & pll_locked ;
assign sdram_clk = clk_100m_shift;

//例化锁相环模块
pll u_pll (
    .inclk0                             (sys_clk   ),
    .areset                             (~sys_rst_n),
    .c0                                 (clk_100m),       //QSYS 系统时钟
    .c1                                 (clk_100m_shift), //SDRAM 时钟
    .c2                                 (ad_clk),         //30MHz
    .c3                                 (lcd_clk),        //10MHz
    .locked                             (pll_locked)
    );

//生成波形并送到DA
da_wave_gen u_da_wave_gen(
    .sys_clk            (sys_clk), 
    .rst_n              (rst_n),
        
    .da_clk             (da_clk),  
    .da_data            (da_data)
    );    
    
//例化QSYS系统
qsys u_qsys(

    //时钟和复位
    .clk_clk                            (clk_100m),
    .reset_reset_n                      (rst_n),
        
    //EPCS  
    .epcs_flash_dclk                    (epcs_dclk ),
    .epcs_flash_sce                     (epcs_sce  ),
    .epcs_flash_sdo                     (epcs_sdo  ),
    .epcs_flash_data0                   (epcs_data0),
        
    //SDRAM 
    .sdram_addr                         (sdram_addr),
    .sdram_ba                           (sdram_ba),
    .sdram_cas_n                        (sdram_cas_n),
    .sdram_cke                          (sdram_cke),
    .sdram_cs_n                         (sdram_cs_n),
    .sdram_dq                           (sdram_dq),
    .sdram_dqm                          (sdram_dqm),
    .sdram_ras_n                        (sdram_ras_n),
    .sdram_we_n                         (sdram_we_n),

    //读写SDRAM的桥     
    .sdram_bridge_slave_waitrequest     (bridge_waitrequest),
    .sdram_bridge_slave_readdata        (bridge_readdata),
    .sdram_bridge_slave_readdatavalid   (bridge_readdatavalid),
    .sdram_bridge_slave_burstcount      (bridge_burstcount),
    .sdram_bridge_slave_writedata       (bridge_writedata),
    .sdram_bridge_slave_address         (bridge_address),
    .sdram_bridge_slave_write           (bridge_write),
    .sdram_bridge_slave_read            (bridge_read),
    .sdram_bridge_slave_byteenable      (2'b11),
    .sdram_bridge_slave_debugaccess     (),

    .pio_lcd_rst_export                 (pio_lcd_rst),
    
    .tp_write                           (tp_avl_write),                        
    .tp_read                            (tp_avl_read),                         
    .tp_writedata                       (tp_avl_writedata),                   
    .tp_readdata                        (tp_avl_readdata),               
    .tp_address                         (tp_avl_address),     
    .tp_int_export                      (tp_interrupt),
    
    .cfg_write                          (avalon_write),                 
    .cfg_read                           (avalon_read),                 
    .cfg_writedata                      (avalon_writedata),                 
    .cfg_readdata                       (avalon_readdata),                 
    .cfg_address                        (avalon_address) 
    );
    
//读写SDRAM桥控制模块
sdram_bridge_control u_bridge_ctrl(
    .clk                                (clk_100m),
    .rst_n                              (rst_n & pio_lcd_rst),
    
    .bridge_write                       (bridge_write),
    .bridge_read                        (bridge_read),
    .bridge_address                     (bridge_address),
    .bridge_burstcount                  (bridge_burstcount), 
    .bridge_waitrequest                 (bridge_waitrequest),
    .bridge_readdatavalid               (bridge_readdatavalid),
    
    .lcd_id                             (16'h4342),
    .source_fifo_wrusedw                (source_fifo_wrusedw)
 );

//FIFO：缓存SDRAM中读出的数据供LCD读取
fifo u_fifo(
    .wrclk          (clk_100m),
    .rdclk          (lcd_clk),
    
    .wrreq          (bridge_readdatavalid),
    .data           (bridge_readdata),
    .wrusedw        (source_fifo_wrusedw),
    
    .rdreq          (fifo_data_req),
    .q              (fifo_pixel_data),
    .rdempty        (),
    
    .aclr           (~(rst_n & pio_lcd_rst))
    );

  
avalmm_interface u_avalmm_interface(
    .sys_clk            (clk_100m),
    .rst_n              (rst_n),
    
    .avalon_write       (avalon_write),
    .avalon_read        (avalon_read),
    .avalon_writedata   (avalon_writedata),
    .avalon_readdata    (avalon_readdata),
    .avalon_address     (avalon_address),
    
    .ad_freq            (ad_freq),
    .ad_vpp             (ad_vpp),
    .ad_max             (ad_max),
    .ad_min             (ad_min),
    
    .deci_rate          (deci_rate),
    .trig_level         (trig_level),
    .trig_edge          (trig_edge),
    .trig_line          (trig_line),
    .wave_run           (wave_run),
    .h_shift            (h_shift),
    .v_shift            (v_shift),
    .v_scale            (v_scale)
    );
      
//参数测量模块，测量输入波形峰峰值和频率    
param_measure #(
    .CLK_FS             (CLK_FS)        // 系统时钟频率值
) u_param_measure(
    .sys_clk            (sys_clk),
    .rst_n              (rst_n),
    
    .trig_level         (trig_level),
    
    .ad_clk             (ad_clk), 
    .ad_data            (ad_data),
        
    .ad_freq            (ad_freq),      // 频率
    .ad_vpp             (ad_vpp),       // 峰峰值
    .ad_max             (ad_max),
    .ad_min             (ad_min)
    );

//数据抽样模块
decimator u_decimator(
    .ad_clk             (ad_clk),
    .rst_n              (rst_n),
    
    .deci_rate          (deci_rate),
    
    .deci_valid         (deci_valid)
);
  
  
//波形数据存储模块  
data_store u_data_store(
    .rst_n              (rst_n),

    .trig_level         (trig_level),
    .trig_edge          (trig_edge),
    .wave_run           (wave_run),
    
    .ad_clk             (ad_clk),
    .ad_data            (ad_data),
    .deci_valid         (deci_valid),
    .h_shift            (h_shift),
        
    .lcd_clk            (lcd_clk),
    .lcd_data_req       (lcd_data_req),
    .lcd_wr_over        (lcd_wr_over),
    .rd_ad_data         (rd_ad_data),
    .rd_rom_addr        (rd_rom_addr),
    .outrange           (outrange)
);


//LCD驱动显示模块
lcd_rgb_top  u_lcd_rgb_top(
    .lcd_clk            (lcd_clk),
    .sys_rst_n          (rst_n & pio_lcd_rst),
        
    .lcd_hs             (lcd_hs),
    .lcd_vs             (lcd_vs),
    .lcd_de             (lcd_de),
    .lcd_rgb            (lcd_rgb),
    .lcd_bl             (lcd_bl),
    .lcd_rst            (lcd_rst),
    .lcd_pclk           (lcd_pclk),
    
    .fifo_pixel_data    (fifo_pixel_data),
    .fifo_data_req      (fifo_data_req),
    
    .line_cnt           (rd_rom_addr), 
    .line_length        (rd_ad_data),
    .data_req           (lcd_data_req),
    .wr_over            (lcd_wr_over),
    .outrange           (outrange),

    .v_shift            (v_shift),
    .v_scale            (v_scale),
    .trig_line          (trig_line)
    );    
    
//例化触摸屏驱动 
top_touch u_top_touch(
    .sys_clk            (clk_100m),
    .sys_rst_n          (rst_n),

    .tft_sda            (tft_sda),
    .tft_scl            (tft_scl),
    .tft_int            (tft_int),
    .tft_tcs            (tft_tcs), 

    .avl_address        (tp_avl_address),
    .avl_write          (tp_avl_write),
    .avl_writedata      (tp_avl_writedata),
    .avl_read           (tp_avl_read),
    .avl_readdata       (tp_avl_readdata),
    
    .touch_done         (tp_interrupt),
    .touch_valid        (touch_valid),

    .tp_num             (),
    .tp1_xy             (),
    .tp2_xy             (),
    .tp3_xy             (),
    .tp4_xy             (),
    .tp5_xy             ()
);    
  
    
endmodule 