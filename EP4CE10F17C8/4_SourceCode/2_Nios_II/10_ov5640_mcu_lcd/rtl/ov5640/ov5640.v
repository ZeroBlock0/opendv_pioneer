//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           ov5640
// Last modified Date:  2018/11/2 13:58:23
// Last Version:        V1.0
// Descriptions:        OV5640摄像头模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/11/2 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ov5640(
    input                 clk            ,  //时钟信号 
    input                 rst_n          ,  //复位信号（低有效）

    //摄像头接口
    input                 cam_pclk       ,  //cmos 数据像素时钟
    input                 cam_vsync      ,  //cmos 场同步信号
    input                 cam_href       ,  //cmos 行同步信号
    input        [7:0]    cam_data       ,  //cmos 数据  
    output                cam_rst_n      ,  //cmos 复位信号，低电平有效
    output                cam_pwdn       ,  //cmos 电源休眠模式选择信号
    output                cam_scl        ,  //cmos SCCB_SCL线
    inout                 cam_sda        ,  //cmos SCCB_SDA线

    output                cam_init_done  ,  //摄像头初始化完成
    output                wr_en          ,  //fifo写使能信号
    output      [15:0]    wr_data        ,  //往fifo中写的数据
    output                ID_flag        ,  //能否读取到ov5640的ID的判断信号
    input       [15:0]    ID_lcd         ,  //LCD的ID  
    output      [12:0]    cmos_h_pixel   ,  //CMOS水平方向像素个数 
    output      [12:0]    cmos_v_pixel      //CMOS垂直方向像素个数 
);

//parameter define
parameter  SLAVE_ADDR = 7'h3c            ;  //OV5640的器件地址7'h3c
parameter  BIT_CTRL   = 1'b1             ;  //OV5640的字节地址为16位  0:8位 1:16位
parameter  CLK_FREQ   = 27'd100_000_000  ; //i2c_dri模块的驱动时钟频率 
parameter  I2C_FREQ   = 18'd250_000      ;  //I2C的SCL时钟频率,不超过400KHz

//wire define
wire                  i2c_exec           ;  //I2C触发执行信号
wire   [23:0]         i2c_data           ;  //I2C要配置的地址与数据(高8位地址,低8位数据) 
wire                  i2c_done           ;  //I2C寄存器配置完成信号
wire                  i2c_dri_clk        ;  //I2C操作时钟
wire   [ 7:0]         i2c_data_r         ;  //I2C读出的数据
wire                  i2c_rh_wl          ;  //I2C读写控制信号
wire  [12:0]          total_h_pixel      ;  //水平总像素大小
wire  [12:0]          total_v_pixel      ;  //垂直总像素大小

//*****************************************************
//**                    main code
//*****************************************************

assign  cam_rst_n = 1'b1;
//电源休眠模式选择 0：正常模式 1：电源休眠模式
assign  cam_pwdn = 1'b0;

//I2C配置模块
i2c_ov5640_rgb565_cfg 
   u_i2c_cfg(
    .clk                  (i2c_dri_clk),
    .rst_n                (rst_n),
    .cmos_h_pixel         (cmos_h_pixel),
    .cmos_v_pixel         (cmos_v_pixel) ,  
    .total_h_pixel        (total_h_pixel),
    .total_v_pixel        (total_v_pixel),
    .i2c_done             (i2c_done),
    .i2c_exec             (i2c_exec),
    .i2c_data             (i2c_data),
    .i2c_rh_wl            (i2c_rh_wl),        //I2C读写控制信号
    .i2c_data_r           (i2c_data_r),   
    .init_done            (cam_init_done),
    .ID_flag              (ID_flag)
    );    

//I2C驱动模块
i2c_dri
   #(
    .SLAVE_ADDR           (SLAVE_ADDR),       //参数传递
    .CLK_FREQ             (CLK_FREQ  ),              
    .I2C_FREQ             (I2C_FREQ  )                
    ) 
   u_i2c_dri_ov5640(
    .clk                  (clk       ),
    .rst_n                (rst_n     ),   
    //i2c interface
    .i2c_exec             (i2c_exec  ),   
    .bit_ctrl             (BIT_CTRL  ),   
    .i2c_rh_wl            (i2c_rh_wl),        //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr             (i2c_data[23:8]),   
    .i2c_data_w           (i2c_data[7:0]),   
    .i2c_data_r           (i2c_data_r),   
    .i2c_done             (i2c_done  ),   
    .scl                  (cam_scl   ),   
    .sda                  (cam_sda   ),   
    //user interface
    .dri_clk              (i2c_dri_clk)       //I2C操作时钟
);

//CMOS图像数据采集模块
cmos_capture_data u_cmos_capture_data(
    .rst_n                (rst_n),
    .cam_pclk             (cam_pclk),
    .cam_vsync            (cam_vsync),
    .cam_href             (cam_href),
    .cam_data             (cam_data),         
    .cmos_frame_vsync     (),
    .cmos_frame_href      (),
    .cmos_frame_valid     (wr_en),            //数据有效使能信号
    .cmos_frame_data      (wr_data)           //有效数据 
    );

//摄像头图像分辨率设置模块
picture_size u_picture_size (
    .ID_lcd               (ID_lcd        ),   //LCD的ID，用于配置摄像头的图像大小
                        
    .cmos_h_pixel         (cmos_h_pixel  ),   //CMOS水平方向像素个数 
    .cmos_v_pixel         (cmos_v_pixel  ),   //CMOS垂直方向像素个数 
    .total_h_pixel        (total_h_pixel ),   //用于配置HTS寄存器
    .total_v_pixel        (total_v_pixel )    //用于配置VTS寄存器
);

endmodule