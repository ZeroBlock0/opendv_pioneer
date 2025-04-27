//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved	                               
//----------------------------------------------------------------------------------------
// File name:           top_comprehensive_test
// Last modified Date:  2018/10/25 14:56:00
// Last Version:        V1.1
// Descriptions:        综合实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/11 8:24:48
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:		    正点原子
// Modified date:	    2018/10/25 14:56:00
// Version:			    V1.1
// Descriptions:	    增加了对正点原子多款屏幕的兼容
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_comprehensive_test(

    //时钟和复位接口
    input           clk_50m,        //晶振时钟
    input           rst_n,          //按键复位
    
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

    //EPCS Flash 接口
    output          epcs_dclk,
    output          epcs_sce,
    output          epcs_sdo,
    input           epcs_data0,
    
    //串口
    input           uart_rxd,
    output          uart_txd,
    
    //I2C 接口
    output          i2c_scl,
    inout           i2c_sda,
    
    //AD/DA I2C 接口
    output          ad_scl,
    inout           ad_sda,
      
    //PIO 接口
    input  [ 3:0]   key,            //机械按键
    output [ 3:0]   led,            //LED灯
    output          buzzer,         //蜂鸣器
    input           touch_key,      //触摸按键
    
    //数码管
    output [ 5:0]   seg_sel,        //数码管位选
    output [ 7:0]   seg_led,        //数码管段选
    
    //红外接收
    input           remote_in,
    
    //ETH MDIO
    output          eth_mdc,
    inout           eth_mdio,
    
    //SD卡接口                           
    input           sd_miso ,       //SD卡SPI串行输入数据信号
    output          sd_clk  ,       //SD卡SPI时钟信号
    output          sd_cs   ,       //SD卡SPI片选信号
    output          sd_mosi ,       //SD卡SPI串行输出数据信号  
    
    //屏幕触摸芯片接口
    inout           touch_sda,
    input           touch_miso,
    output          touch_scl,
    inout           touch_int,
    output          touch_tcs,
    
    //音频模块接口
    input           aud_bclk,
    input           aud_lrc,
    input           aud_adcdat,
    output          aud_mclk,
    output          aud_dacdat,
    
    //摄像头接口
    input           cam_pclk,
    input           cam_vsync,
    input           cam_href,
    input  [ 7:0]   cam_data,
    output          cam_rst_n,
    output          cam_pwdn,
    output          cam_scl,
    inout           cam_sda,

    //VGA接口                                          
    output          vga_hs     ,  //行同步信号    
    output          vga_vs     ,  //场同步信号    
    output  [15:0]  vga_rgb    ,  //红绿蓝三原色输出 
    
    //LCD接口
    output          lcd_rst    ,  //LCD复位信号
    output          lcd_bl     ,  //LCD背光控制
    output          lcd_de_cs  ,  //LCD RGB:DE  MCU:CS
    output          lcd_vs_rs  ,  //LCD RGB:VS  MCU:RS
    output          lcd_hs_wr  ,  //LCD RGB:HS  MCU:WR
    output          lcd_clk_rd ,  //LCD RGB:CLK MCU:RD
    inout  [15:0]   lcd_data      //LCD DATA
);

//reg define


//wire define
wire        clk_100m;
wire        clk_100m_shift;
wire        sys_clk_100m;
wire        clk_50m_pll;
wire        lcd_clk;
wire        pll_locked;
wire        sys_rst_n;

//触摸驱动模块 avalon 总线
wire        tp_avl_write;
wire        tp_avl_read;
wire [31:0] tp_avl_writedata;
wire [31:0] tp_avl_readdata;
wire [ 2:0] tp_avl_address;

//数码管驱动模块 avalon 总线
wire        seg_avl_write;
wire        seg_avl_read;
wire [31:0] seg_avl_writedata;
wire [31:0] seg_avl_readdata;
wire [ 2:0] seg_avl_address;

//红外遥控驱动模块 avalon 总线
wire        remote_avl_write;
wire        remote_avl_read;
wire [31:0] remote_avl_writedata;
wire [31:0] remote_avl_readdata;
wire [ 2:0] remote_avl_address;

//ADDA模块 avalon 总线
wire        adda_avl_write;
wire        adda_avl_read;
wire [31:0] adda_avl_writedata;
wire [31:0] adda_avl_readdata;
wire [ 2:0] adda_avl_address;

//音频模块
wire        audio_sel;

//读写 SDRAM 桥接信号
wire        bridge_write;
wire        bridge_read;  
wire [15:0] bridge_writedata;
wire [15:0] bridge_readdata;
wire [25:0] bridge_address;
wire [ 9:0] bridge_burstcount;
wire        bridge_waitrequest;             
wire        bridge_readdatavalid;

//FPGA采集的音频数据
wire [31:0] adc_data;

//摄像头模块的接口信号
wire        ov5640_init_done;
wire        ov5640_ID_flag;
wire        ov5640_en;

//OV5640 写FIFO信号
wire        ov5640_wr_en;
wire [15:0] ov5640_wr_data;
wire [11:0] ov5640_fifo_rdusedw;

//source_st_fifo信号
wire [9:0]  source_fifo_wrusedw;

//LCD驱动模块接口信号
wire        lcd_data_req;
wire [15:0] lcd_pixel_data;
wire        lcd_rst_n;

//触摸相关信号
wire        page_paint_flag;
wire        touch_done;
wire        touch_valid;

//LCD初始化完成
wire        lcd_init_done     ;
wire [15:0] lcd_id            ;
wire        mlcd_cs_n_init    ; 
wire        mlcd_wr_n_init    ;
wire        mlcd_rd_n_init    ;
wire        mlcd_rst_n_init   ;
wire        mlcd_rs_init      ;
wire        mlcd_bl_init      ;
wire        mlcd_data_dir_init;
wire [15:0] mlcd_data_out_init;
wire [15:0] mlcd_data_in_init ;

//SDRAM 中读出的数据
wire        source_valid_w;
wire [18:0] source_fifo_data_w;

//Avalon-ST 格式信号
wire        st_source_ready;
wire        st_source_sop;
wire        st_source_eop;
wire        st_source_valid;
wire [15:0] st_source_data;

//Avalon-ST VIP 格式信号
wire        vip_st_ready;
wire        vip_st_sop;
wire        vip_st_eop;
wire        vip_st_valid;
wire [23:0] vip_st_data;

//Avalon-ST VIP 格式信号
wire        scale_st_ready;
wire        scale_st_sop;
wire        scale_st_eop;
wire        scale_st_valid;
wire [23:0] scale_st_data;

//Avalon-ST 格式信号
wire        st_sink_ready;
wire        st_sink_sop;
wire        st_sink_eop;
wire        st_sink_valid;
wire [15:0] st_sink_data;

//*****************************************************
//**                    main code
//*****************************************************

assign sys_rst_n = rst_n & pll_locked;
assign sdram_clk = clk_100m_shift;

//例化锁相环模块
pll0 u_pll (
	.inclk0                             (clk_50m),
	.areset                             (~rst_n),
                                
	.c0                                 (sys_clk_100m),             //QSYS 系统时钟
	.c1                                 (clk_100m_shift),           //SDRAM 时钟
    .c2                                 (aud_mclk),                 //音频芯片时钟
    .c3                                 (clk_50m_pll),              //LCD 驱动时钟
    .c4                                 (clk_100m),
	.locked                             (pll_locked)
	);

//例化QSYS系统
system_qsys u_qsys(

    //时钟和复位
    .clk_clk                            (sys_clk_100m),
    .reset_reset_n                      (sys_rst_n),
        
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
    
    //触摸屏
    .touch_write                        (tp_avl_write),
    .touch_read                         (tp_avl_read),
    .touch_writedata                    (tp_avl_writedata),
    .touch_readdata                     (tp_avl_readdata),
    .touch_address                      (tp_avl_address),
        
    //数码管   
    .seg_write                          (seg_avl_write),
    .seg_read                           (seg_avl_read),
    .seg_writedata                      (seg_avl_writedata),
    .seg_readdata                       (seg_avl_readdata),
    .seg_address                        (seg_avl_address),
        
    //红外遥控  
    .remote_write                       (remote_avl_write),
    .remote_read                        (remote_avl_read),
    .remote_writedata                   (remote_avl_writedata),
    .remote_readdata                    (remote_avl_readdata),
    .remote_address                     (remote_avl_address),
        
    //AD+DA 
    .adda_write                         (adda_avl_write),
    .adda_read                          (adda_avl_read),
    .adda_writedata                     (adda_avl_writedata),
    .adda_readdata                      (adda_avl_readdata),
    .adda_address                       (adda_avl_address),
        
    //UART  
    .uart_rxd                           (uart_rxd),
    .uart_txd                           (uart_txd),
        
    //I2C   
    .i2c_scl_export                     (i2c_scl),
    .i2c_sda_export                     (i2c_sda),
    
    //MDIO
    .eth_mdc_export                     (eth_mdc),
    .eth_mdio_export                    (eth_mdio),

    //SD卡
    .sd_cs_export                       (sd_cs),                
    .sd_clk_export                      (sd_clk),               
    .sd_mosi_export                     (sd_mosi),              
    .sd_miso_export                     (sd_miso),     

    //PIO 输入输出
    .key_export                         (~key),                     //按键
    .led_export                         (led),                      //LED
    .buzzer_export                      (buzzer),                   //蜂鸣器
    .back_export                        (touch_key),                //触摸按键（返回键）

    //PIO 内部信号
    .touch_int_export                   (touch_done),               //触摸屏中断
    .paint_export                       (touch_valid),              //画笔有效
    .page_paint_flag_export             (page_paint_flag),          //画笔界面标志  
    .ov5640_en_export                   (ov5640_en),                //摄像头使能
    .ov5640_id_export                   (ov5640_ID_flag),           //摄像头ID有效

    .mlcd_cs_n_export                   (mlcd_cs_n_init),            
    .mlcd_wr_n_export                   (mlcd_wr_n_init),            
    .mlcd_rd_n_export                   (mlcd_rd_n_init),            
    .mlcd_rst_n_export                  (mlcd_rst_n_init),            
    .mlcd_rs_export                     (mlcd_rs_init),            
    .mlcd_bl_export                     (mlcd_bl_init),            
    .lcd_data_in_export                 (mlcd_data_in_init),            
    .lcd_data_out_export                (mlcd_data_out_init),            
    .lcd_data_dir_export                (mlcd_data_dir_init),            
    .lcd_init_done_export               (lcd_init_done),            //LCD初始化完成    
    .lcd_id_export                      (lcd_id),                   //LCD ID     
    .audio_sel_export                   (audio_sel),
    
    //VIP 缩放
//    .clk_vip_clk                        (sys_clk_100m),  
//    .reset_vip_reset_n                   (sys_rst_n),
    
    .vip_scl_din_data                   (vip_st_data),  
    .vip_scl_din_valid                  (vip_st_valid),  
    .vip_scl_din_startofpacket          (vip_st_sop), 
    .vip_scl_din_endofpacket            (vip_st_eop),  
    .vip_scl_din_ready                  (vip_st_ready),
    
    .vip_scl_dout_data                  (scale_st_data),   
    .vip_scl_dout_valid                 (scale_st_valid),  
    .vip_scl_dout_startofpacket         (scale_st_sop),   
    .vip_scl_dout_endofpacket           (scale_st_eop),    
    .vip_scl_dout_ready                 (scale_st_ready)
    );    

//触摸驱动
top_touch u_top_touch(
    .sys_clk                            (clk_100m),
    .sys_rst_n                          (sys_rst_n),
                
    .avl_write                          (tp_avl_write),
    .avl_read                           (tp_avl_read),
    .avl_writedata                      (tp_avl_writedata),
    .avl_readdata                       (tp_avl_readdata),
    .avl_address                        (tp_avl_address),
    
    .lcd_init_done                      (lcd_init_done),        //LCD初始化完成    
    .lcd_id                             (lcd_id),               //LCD ID 
    
    .tft_sda                            (touch_sda ),
    .tft_miso                           (touch_miso),
    .tft_scl                            (touch_scl),
    .tft_int                            (touch_int),
    .tft_tcs                            (touch_tcs), 
    
    .page_paint_flag                    (page_paint_flag),
    .touch_done                         (touch_done),
    .touch_valid                        (touch_valid),
              
    .tp_num                             ()
    );

//静态数码管驱动
seg_led_static u_seg_led_static(
    .clk                                (clk_100m),
    .rst_n                              (sys_rst_n),
                    
    .avl_write                          (seg_avl_write),
    .avl_read                           (seg_avl_read),
    .avl_writedata                      (seg_avl_writedata),
    .avl_readdata                       (seg_avl_readdata),
    .avl_address                        (seg_avl_address),
                
    .sel                                (seg_sel),
    .seg_led                            (seg_led)
    );

//红外遥控驱动
remote_rcv u_remote_rcv(
    .clk_100m                           (clk_100m),
    .sys_clk                            (clk_50m),
    .sys_rst_n                          (sys_rst_n),
                    
    .avl_write                          (remote_avl_write),
    .avl_read                           (remote_avl_read),
    .avl_writedata                      (remote_avl_writedata),
    .avl_readdata                       (remote_avl_readdata),
    .avl_address                        (remote_avl_address),
                    
    .remote_in                          (remote_in)
    );

//AD/DA驱动  
 adda_top u_adda_top(
    .sys_clk                            (clk_100m),
    .sys_rst_n                          (sys_rst_n),

    .avl_write                          (adda_avl_write),
    .avl_read                           (adda_avl_read),
    .avl_writedata                      (adda_avl_writedata),
    .avl_readdata                       (adda_avl_readdata),
    .avl_address                        (adda_avl_address),
    
    .scl                                (ad_scl),                   //PCF8591 interface
    .sda                                (ad_sda)
    ); 

//音频驱动
wm8978_ctrl u_wm8978_ctrl(
    .clk                                (clk_50m),
    .rst_n                              (sys_rst_n),
                
    .aud_bclk                           (aud_bclk),
    .aud_lrc                            (aud_lrc),
    .aud_adcdat                         (aud_adcdat),
    .aud_dacdat                         (aud_dacdat),
                
    .dac_data                           (adc_data),
    .adc_data                           (adc_data),
    .aud_sel                            (audio_sel),
    
    .rx_done                            (),
    .tx_done                            ()
    );
  
//ov5640摄像头驱动
ov5640  u_ov5640(
    .clk                                (clk_100m),          
    .rst_n                              (sys_rst_n & ov5640_en),
                                        
    .cam_pclk                           (cam_pclk),
    .cam_vsync                          (cam_vsync),
    .cam_href                           (cam_href),
    .cam_data                           (cam_data),
    .cam_rst_n                          (cam_rst_n),
    .cam_pwdn                           (cam_pwdn),
    .cam_scl                            (cam_scl),
    .cam_sda                            (cam_sda),
                                        
    .ID_flag                            (ov5640_ID_flag),
    .cam_init_done                      (ov5640_init_done),
    
    .wr_en                              (ov5640_wr_en),
    .wr_data                            (ov5640_wr_data)
    );

//FIFO：缓存向SDRAM中写入的数据，摄像头输出数据
ov5640_wr_fifo u_ov5640_fifo(
    .aclr                               (~(rst_n & ov5640_init_done & ov5640_en)),
                        
    .wrclk                              (cam_pclk),
    .wrreq                              (ov5640_wr_en),
    .data                               (ov5640_wr_data),
                        
    .rdclk                              (sys_clk_100m),
    .rdreq                              (bridge_write & (!bridge_waitrequest)),
    .q                                  (bridge_writedata),
    .rdusedw                            (ov5640_fifo_rdusedw)
    );

//读写 SDRAM 桥 控制模块
sdram_bridge_control u_bridge_ctrl(
    .clk                                (sys_clk_100m),
    .rst_n                              (sys_rst_n),
    
    .bridge_write                       (bridge_write),
    .bridge_read                        (bridge_read),
    .bridge_address                     (bridge_address),
    .bridge_burstcount                  (bridge_burstcount), 
    .bridge_waitrequest                 (bridge_waitrequest),
    .bridge_readdatavalid               (bridge_readdatavalid),
    .bridge_readdata                    (bridge_readdata),
    
    .ov5640_id_flag                     (ov5640_ID_flag),
    .ov5640_fifo_rdusedw                (ov5640_fifo_rdusedw),

    .source_valid                       (source_valid_w),
    .source_fifo_data                   (source_fifo_data_w),
    .source_fifo_wrusedw                (source_fifo_wrusedw)
 );

//从SDRAM中读出的数据转Avalon-ST格式 
fifo_2_st u_fifo_2_st(
    .clk                                (sys_clk_100m),  
    .clk_50m                            (sys_clk_100m),
    .rst_n                              (sys_rst_n),

    .source_valid                       (source_valid_w),     
    .source_fifo_data                   (source_fifo_data_w),    
    .source_fifo_wrusedw                (source_fifo_wrusedw),

    .st_source_data                     (st_source_data),    
    .st_source_valid                    (st_source_valid),  
    .st_source_sop                      (st_source_sop),  
    .st_source_eop                      (st_source_eop),
    .st_source_ready                    (st_source_ready),    
    );

//Avalon-ST数据流 转换成 VIP格式数据流
ST_VIP_bridge u_ST_VIP_bridge(
    .clk                                (sys_clk_100m),
    .rst_n                              (sys_rst_n),

    .din_data                           (st_source_data), 
    .din_valid                          (st_source_valid),
    .din_startofpacket                  (st_source_sop),  
    .din_endofpacket                    (st_source_eop),
    .din_ready                          (st_source_ready),
    
    .dout_data                          (vip_st_data), 
    .dout_valid                         (vip_st_valid),  
    .dout_startofpacket                 (vip_st_sop),
    .dout_endofpacket                   (vip_st_eop), 
    .dout_ready                         (vip_st_ready)   
);

//VIP格式数据流 转换成 Avalon-ST数据流
vip_st_decode u_vip_st_decode(
    .clk                                (sys_clk_100m),
    .rst_n                              (sys_rst_n),

    .din_data                           (scale_st_data),
    .din_valid                          (scale_st_valid),
    .din_startofpacket                  (scale_st_sop), 
    .din_endofpacket                    (scale_st_eop), 
    .din_ready                          (scale_st_ready),
    
    .dout_data                          (st_sink_data), 
    .dout_valid                         (st_sink_valid),  
    .dout_startofpacket                 (st_sink_sop),
    .dout_endofpacket                   (st_sink_eop), 
    .dout_ready                         (st_sink_ready)   
);

//Avalon-ST 数据流转FIFO输出
st_2_fifo u_st_2_fifo(
    .clk50m                             (sys_clk_100m),
    .lcd_clk                            (lcd_clk),
    .rst_n                              (sys_rst_n),

    .sink_data                          (st_sink_data),    
    .sink_valid                         (st_sink_valid),  
    .sink_sop                           (st_sink_sop),
    .sink_eop                           (st_sink_eop),  
    .sink_ready                         (st_sink_ready),
    
    .lcd_data_req                       (lcd_data_req),
    .lcd_pixel_data                     (lcd_pixel_data)
    );

//RGB LCD 和 MCU LCD驱动
lcd_top  u_lcd_top(
    .clk                                (clk_50m_pll),
    .rst_n                              (sys_rst_n),

    .pixel_data                         (lcd_pixel_data),
    .pixel_en                           (lcd_data_req),
    .lcd_clk                            (lcd_clk),

    .lcd_rst                            (lcd_rst),
    .lcd_bl                             (lcd_bl),
    .lcd_de_cs                          (lcd_de_cs),
    .lcd_vs_rs                          (lcd_vs_rs),
    .lcd_hs_wr                          (lcd_hs_wr),
    .lcd_clk_rd                         (lcd_clk_rd),
    .lcd_data                           (lcd_data),
                
    .mlcd_cs_n_init                     (mlcd_cs_n_init),
    .mlcd_wr_n_init                     (mlcd_wr_n_init),
    .mlcd_rd_n_init                     (mlcd_rd_n_init),
    .mlcd_rst_n_init                    (mlcd_rst_n_init),
    .mlcd_rs_init                       (mlcd_rs_init),
    .mlcd_bl_init                       (mlcd_bl_init),
    .mlcd_data_dir_init                 (mlcd_data_dir_init),
    .mlcd_data_out_init                 (mlcd_data_out_init),
    .mlcd_data_in_init                  (mlcd_data_in_init ),
    .lcd_init_done                      (lcd_init_done),
    .lcd_id                             (lcd_id)
    );

//VGA彩条显示    
vga_colorbar  u_vga_colorbar(
    .vga_clk_w     (clk_50m_pll),
    .sys_rst_n     (sys_rst_n),
    .vga_hs        (vga_hs ),
    .vga_vs        (vga_vs ),
    .vga_rgb       (vga_rgb)
    );    

endmodule 