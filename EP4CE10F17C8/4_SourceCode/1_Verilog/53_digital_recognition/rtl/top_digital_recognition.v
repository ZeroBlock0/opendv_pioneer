//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           top_digital_recognition
// Last modified Date:  2018/11/2 13:58:23
// Last Version:        V1.0
// Descriptions:        基于几何特征的数字识别实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/21 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_digital_recognition(
    input                 sys_clk     ,  //系统时钟
    input                 sys_rst_n   ,  //系统复位，低电平有效
    //摄像头接口
    input                 cam_pclk    ,  //cmos 数据像素时钟
    input                 cam_vsync   ,  //cmos 场同步信号
    input                 cam_href    ,  //cmos 行同步信号
    input        [7:0]    cam_data    ,  //cmos 数据
    output                cam_rst_n   ,  //cmos 复位信号，低电平有效
    output                cam_pwdn    ,  //cmos 电源休眠模式选择信号
    output                cam_scl     ,  //cmos SCCB_SCL线
    inout                 cam_sda     ,  //cmos SCCB_SDA线
    //SDRAM接口
    output                sdram_clk   ,  //SDRAM 时钟
    output                sdram_cke   ,  //SDRAM 时钟有效
    output                sdram_cs_n  ,  //SDRAM 片选
    output                sdram_ras_n ,  //SDRAM 行有效
    output                sdram_cas_n ,  //SDRAM 列有效
    output                sdram_we_n  ,  //SDRAM 写有效
    output       [1:0]    sdram_ba    ,  //SDRAM Bank地址
    output       [1:0]    sdram_dqm   ,  //SDRAM 数据掩码
    output       [12:0]   sdram_addr  ,  //SDRAM 地址
    inout        [15:0]   sdram_data  ,  //SDRAM 数据
    //lcd接口
    output                lcd_hs      ,  //LCD 行同步信号
    output                lcd_vs      ,  //LCD 场同步信号
    output                lcd_de      ,  //LCD 数据输入使能
    inout        [15:0]   lcd_rgb     ,  //LCD RGB565颜色数据
    output                lcd_bl      ,  //LCD 背光控制信号
    output                lcd_rst     ,  //LCD 复位信号
    output                lcd_pclk    ,  //LCD 采样时钟
    //seg led
    output       [5:0]    sel         ,  //数码管位选
    output       [7:0]    seg_led        //数码管段选
    );

//parameter define
parameter  SLAVE_ADDR = 7'h3c         ;  //OV5640的器件地址7'h3c
parameter  BIT_CTRL   = 1'b1          ;  //OV5640的字节地址为16位  0:8位 1:16位
parameter  CLK_FREQ   = 27'd100_000_000; //i2c_dri模块的驱动时钟频率
parameter  I2C_FREQ   = 18'd250_000   ;  //I2C的SCL时钟频率,不超过400KHz
parameter  NUM_ROW    = 1'd1          ;  //需识别的图像的行数
parameter  NUM_COL    = 3'd4          ;  //需识别的图像的列数
parameter  DEPBIT     = 4'd11         ;  //数据位宽

//wire define
wire                  clk_100m        ;  //100mhz时钟,SDRAM操作时钟
wire                  clk_100m_shift  ;  //100mhz时钟,SDRAM相位偏移时钟
wire                  clk_100m_lcd    ;  //100mhz时钟
wire                  clk_lcd         ;  //提供给IIC驱动时钟和lcd驱动时钟
wire                  locked          ;
wire                  rst_n           ;

wire                  i2c_exec        ;  //I2C触发执行信号
wire   [23:0]         i2c_data        ;  //I2C要配置的地址与数据(高8位地址,低8位数据)
wire                  cam_init_done   ;  //摄像头初始化完成
wire                  i2c_done        ;  //I2C寄存器配置完成信号
wire                  i2c_dri_clk     ;  //I2C操作时钟
wire   [ 7:0]         i2c_data_r      ;  //I2C读出的数据
wire                  i2c_rh_wl       ;  //I2C读写控制信号

wire                  wr_en           ;  //sdram_ctrl模块写使能
wire   [15:0]         wr_data         ;  //sdram_ctrl模块写数据
wire                  rd_en           ;  //sdram_ctrl模块读使能
wire   [15:0]         rd_data         ;  //sdram_ctrl模块读数据
wire                  sdram_init_done ;  //SDRAM初始化完成
wire                  sys_init_done   ;  //系统初始化完成(sdram初始化+摄像头初始化)

wire   [15:0]         ID_lcd          ;  //LCD的ID
wire   [12:0]         cmos_h_pixel    ;  //CMOS水平方向像素个数
wire   [12:0]         cmos_v_pixel    ;  //CMOS垂直方向像素个数
wire   [12:0]         total_h_pixel   ;  //水平总像素大小
wire   [12:0]         total_v_pixel   ;  //垂直总像素大小
wire   [23:0]         sdram_max_addr  ;  //sdram读写的最大地址
wire   [23:0]         digit           ;  //识别到的数字
wire   [15:0]         color_rgb       ;
wire   [15:0]         post_rgb	     ;
wire   [10:0]         xpos            ;  //像素点横坐标
wire   [10:0]         ypos            ;  //像素点纵坐标
wire                  hs_t            ;
wire                  vs_t            ;
wire                  de_t            ;

//*****************************************************
//**                    main code
//*****************************************************

assign  rst_n = sys_rst_n & locked;
//系统初始化完成：SDRAM和摄像头都初始化完成
//避免了在SDRAM初始化过程中向里面写入数据
assign  sys_init_done = sdram_init_done & cam_init_done;
assign  cam_rst_n = 1'b1;
//电源休眠模式选择 0：正常模式 1：电源休眠模式
assign  cam_pwdn = 1'b0;
//assign  lcd_de = 1'b1;

//锁相环
pll u_pll(
    .areset       (~sys_rst_n),
    .inclk0       (sys_clk),
    .c0           (clk_100m),
    .c1           (clk_100m_shift),
    .c2           (clk_100m_lcd),
    .locked       (locked)
);

//I2C配置模块
i2c_ov5640_rgb565_cfg u_i2c_cfg(
    .clk                  (i2c_dri_clk),
    .rst_n                (rst_n),
    .i2c_done             (i2c_done),
    .i2c_exec             (i2c_exec),
    .i2c_data             (i2c_data),
    .i2c_rh_wl            (i2c_rh_wl),              //I2C读写控制信号
    .i2c_data_r           (i2c_data_r),
    .init_done            (cam_init_done),
    .cmos_h_pixel         (cmos_h_pixel),           //CMOS水平方向像素个数
    .cmos_v_pixel         (cmos_v_pixel) ,          //CMOS垂直方向像素个数
    .total_h_pixel        (total_h_pixel),          //水平总像素大小
    .total_v_pixel        (total_v_pixel)           //垂直总像素大小
);

//I2C驱动模块
i2c_dri
   #(
    .SLAVE_ADDR           (SLAVE_ADDR),             //参数传递
    .CLK_FREQ             (CLK_FREQ  ),
    .I2C_FREQ             (I2C_FREQ  )
    )
   u_i2c_dri(
    .clk                  (clk_100m_lcd),
    .rst_n                (rst_n     ),
    //i2c interface
    .i2c_exec             (i2c_exec  ),
    .bit_ctrl             (BIT_CTRL  ),
    .i2c_rh_wl            (i2c_rh_wl ),             //固定为0，只用到了IIC驱动的写操作
    .i2c_addr             (i2c_data[23:8]),
    .i2c_data_w           (i2c_data[7:0]),
    .i2c_data_r           (i2c_data_r),
    .i2c_done             (i2c_done  ),
    .scl                  (cam_scl   ),
    .sda                  (cam_sda   ),
    //user interface
    .dri_clk              (i2c_dri_clk)             //I2C操作时钟
);

//CMOS图像数据采集模块
cmos_capture_data u_cmos_capture_data(
    .rst_n                (rst_n & sys_init_done),  //系统初始化完成之后再开始采集数据
    .cam_pclk             (cam_pclk),
    .cam_vsync            (cam_vsync),
    .cam_href             (cam_href),
    .cam_data             (cam_data),
    .cmos_frame_vsync     (),
    .cmos_frame_href      (),
    .cmos_frame_clken     (wr_en),                  //数据有效使能信号
    .cmos_frame_data      (wr_data)                 //有效数据
);

//摄像头图像分辨率设置模块
picture_size u_picture_size (
    .rst_n                (rst_n         ),

    .ID_lcd               (ID_lcd        ),   //LCD的ID，用于配置摄像头的图像大小

    .cmos_h_pixel         (cmos_h_pixel  ),   //CMOS水平方向像素个数
    .cmos_v_pixel         (cmos_v_pixel  ),   //CMOS垂直方向像素个数
    .total_h_pixel        (total_h_pixel ),   //用于配置HTS寄存器
    .total_v_pixel        (total_v_pixel ),   //用于配置VTS寄存器
    .sdram_max_addr       (sdram_max_addr)    //sdram读写的最大地址
);

//SDRAM 控制器顶层模块,封装成FIFO接口
//SDRAM 控制器地址组成: {bank_addr[1:0],row_addr[12:0],col_addr[8:0]}
sdram_top u_sdram_top(
    .ref_clk      (clk_100m),                 //sdram 控制器参考时钟
    .out_clk      (clk_100m_shift),           //用于输出的相位偏移时钟
    .rst_n        (rst_n),                    //系统复位

    //用户写端口
    .wr_clk       (cam_pclk),                 //写端口FIFO: 写时钟
    .wr_en        (wr_en),                    //写端口FIFO: 写使能
    .wr_data      (wr_data),                  //写端口FIFO: 写数据
    .wr_min_addr  (24'd0),                    //写SDRAM的起始地址
    .wr_max_addr  (sdram_max_addr),           //写SDRAM的结束地址
    .wr_len       (10'd512),                  //写SDRAM时的数据突发长度
    .wr_load      (~rst_n),                   //写端口复位: 复位写地址,清空写FIFO

    //用户读端口
    .rd_clk       (clk_lcd),                  //读端口FIFO: 读时钟
    .rd_en        (rd_en),                    //读端口FIFO: 读使能
    .rd_data      (rd_data),                  //读端口FIFO: 读数据
    .rd_min_addr  (24'd0),                    //读SDRAM的起始地址
    .rd_max_addr  (sdram_max_addr),           //读SDRAM的结束地址
    .rd_len       (10'd512),                  //从SDRAM中读数据时的突发长度
    .rd_load      (~rst_n),                   //读端口复位: 复位读地址,清空读FIFO

    //用户控制端口
    .sdram_read_valid  (1'b1),                //SDRAM 读使能
    .sdram_pingpang_en (1'b1),                //SDRAM 乒乓操作使能
    .sdram_init_done (sdram_init_done),       //SDRAM 初始化完成标志

    //SDRAM 芯片接口
    .sdram_clk    (sdram_clk),                //SDRAM 芯片时钟
    .sdram_cke    (sdram_cke),                //SDRAM 时钟有效
    .sdram_cs_n   (sdram_cs_n),               //SDRAM 片选
    .sdram_ras_n  (sdram_ras_n),              //SDRAM 行有效
    .sdram_cas_n  (sdram_cas_n),              //SDRAM 列有效
    .sdram_we_n   (sdram_we_n),               //SDRAM 写有效
    .sdram_ba     (sdram_ba),                 //SDRAM Bank地址
    .sdram_addr   (sdram_addr),               //SDRAM 行/列地址
    .sdram_data   (sdram_data),               //SDRAM 数据
    .sdram_dqm    (sdram_dqm)                 //SDRAM 数据掩码
);

//例化LCD顶层模块
lcd u_lcd(
    .clk        (clk_100m_lcd),
    .rst_n      (rst_n),

    .lcd_hs     (hs_t ),
    .lcd_vs     (vs_t ),
    .lcd_de     (de_t ),
    .lcd_rgb    (lcd_rgb),
    .lcd_bl     (lcd_bl),
    .lcd_rst    (lcd_rst),
    .lcd_pclk   (lcd_pclk),
    .ID_lcd     (ID_lcd),
    //user interface
	 .clk_lcd    (clk_lcd),
    .pixel_data (rd_data),
    .rd_en      (rd_en  ),
	 .pre_rgb    (color_rgb), 
	 .post_rgb   (post_rgb),
	 .post_de    (lcd_de),	
    .pixel_xpos (xpos  ),
    .pixel_ypos (ypos  )
);

//图像处理模块
vip #(
    .NUM_ROW(NUM_ROW),
    .NUM_COL(NUM_COL),
    .DEPBIT (DEPBIT)
) u_vip(
    //module clock
    .clk              (clk_lcd),     // 时钟信号
    .rst_n            (rst_n    ),     // 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync  (vs_t   ),
    .pre_frame_hsync  (hs_t   ),
    .pre_frame_de     (de_t   ),
    .pre_rgb          (color_rgb),
    .xpos             (xpos   ),
    .ypos             (ypos   ),
    //图像处理后的数据接口
    .post_frame_vsync (lcd_vs ),        // 场同步信号
    .post_frame_hsync (lcd_hs ),        // 行同步信号
    .post_frame_de    (lcd_de ),        // 数据输入使能
    .post_rgb         (post_rgb),       // RGB565颜色数据
    //user interface
    .h_total_pexel    (cmos_h_pixel),   //CMOS水平方向像素个数
    .v_total_pexel    (cmos_v_pixel),   //CMOS垂直方向像素个数	 
    .digit            (digit  )         // 识别到的数字
);

//例化数码管驱动模块
seg_bcd_dri u_seg_bcd_dri(
   //input
   .clk          (clk_lcd),             // 时钟信号
   .rst_n        (rst_n  ),             // 复位信号
   .num          (digit  ),             // 6个数码管要显示的数值
   .point        (6'b0   ),             // 小数点具体显示的位置,从高到低,高有效
   //output      
   .sel          (sel    ),             // 数码管位选
   .seg_led      (seg_led)              // 数码管段选
);

endmodule