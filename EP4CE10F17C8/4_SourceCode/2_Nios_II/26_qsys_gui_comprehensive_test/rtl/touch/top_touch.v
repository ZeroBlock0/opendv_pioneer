//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           top_touch
// Last modified Date:  2018/08/20 15:11:59
// Last Version:        V1.0
// Descriptions:        触摸屏顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/20 15:12:09
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module top_touch(
    //module clock
    input                  sys_clk,          // 系统时钟信号
    input                  sys_rst_n,        // 复位信号（低有效）

    //tft interface
    inout                  tft_sda,
    input                  tft_miso,
    output   reg           tft_scl,
    inout                  tft_int,
    output   reg           tft_tcs,

    //touch lcd interface
    output   reg           touch_done,
    output   reg           touch_valid,      // 连续触摸标志
    output        [ 2:0]   tp_num,
//  output        [31:0]   tp1_xy,
//  output        [31:0]   tp2_xy,
//  output        [31:0]   tp3_xy,
//  output        [31:0]   tp4_xy,
//  output        [31:0]   tp5_xy,

	//avalon 端口
    input         [ 2:0]   avl_address,      //地址
    input                  avl_write,        //写请求
    input         [31:0]   avl_writedata,    //写数据
    input                  avl_read,         //读请求
    output   reg  [31:0]   avl_readdata,     //读数据

    input                  page_paint_flag,
    input                  lcd_init_done,
    input         [15:0]   lcd_id
);

//parameter define
parameter   WIDTH = 5'd8;

//reg define
reg                       little_en ;
reg                       bigger_en ;
reg     [31:0]            tp1_xy;
reg                       sda_out;
reg                       sda_dir;
//wire define
wire                      ack;
wire                      i2c_exec  ;
wire                      i2c_rh_wl ;
wire    [15:0]            i2c_addr  ;
wire    [ 7:0]            i2c_data_w;
wire    [WIDTH-1'b1:0]    reg_num   ;
wire    [ 7:0]            i2c_data_r;
wire                      i2c_done  ;
wire                      once_done ;
wire                      bit_ctrl  ;
wire                      clk       ;
wire                      cfg_done  ;
wire                      cfg_switch;
wire                      tft_mosi  ;
wire                      gf_cs;
wire                      gf_scl;
wire                      gf_done;
wire                      gf_valid;
wire    [31:0]            gf_xy;
wire                      xpt_cs;
wire                      xpt_scl;
wire                      xpt_done;
wire                      xpt_valid;
wire    [31:0]            xpt_xy;
wire                      gf_sda_in;
wire                      gf_sda_out;

//*****************************************************
//**                    main code
//*****************************************************

assign  tft_sda = sda_dir  ?  sda_out  :  1'bz;
assign  gf_sda_in = tft_sda;

//IIC复用
always @(*) begin
    if(lcd_id[15:8] == 8'h93 || lcd_id[15:8] == 8'h53) begin
            tft_scl = xpt_scl;
            sda_out = tft_mosi;
            sda_dir = 1'b1;
    end
    else begin
            tft_scl = gf_scl;
            sda_out = gf_sda_out;
            sda_dir = gf_sda_dir;
    end
end

always @(*) begin
    if(!lcd_init_done) begin
        little_en = 1'b0;
        bigger_en = 1'b0;
    end
    else begin
        if(lcd_id[15:8] == 8'h93 || lcd_id[15:8] == 8'h53) begin
            little_en = 1'b1;
            bigger_en = 1'b0;
            tft_tcs   = xpt_cs;
            touch_done= xpt_done;
            touch_valid= xpt_valid;
            tp1_xy    = xpt_xy;
        end
        else begin
            little_en = 1'b0;
            bigger_en = 1'b1;
            tft_tcs   = gf_cs;
            touch_done= gf_done;
            touch_valid= gf_valid;
            tp1_xy     = gf_xy;
        end
    end
end

//avalon 端口读操作
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        avl_readdata <= 32'd0;
	else begin
        if(avl_read) begin    //读操作
            case(avl_address)
                3'd0: avl_readdata <= {29'd0,tp_num};
                3'd1: avl_readdata <= tp1_xy;
//                3'd2: avl_readdata <= tp2_xy;
//                3'd3: avl_readdata <= tp3_xy;
//                3'd4: avl_readdata <= tp4_xy;
//                3'd5: avl_readdata <= tp5_xy;
                default:;
            endcase
        end
	end
end

touch_gt_cfg #(.WIDTH(4'd8)
) u_touch_gt_cfg(
    //module clock
    .clk                (sys_clk   ),          // 时钟信号
    .rst_n              (sys_rst_n ),          // 复位信号
    //port interface
    .scl                (gf_scl    ),          // 时钟线scl
    .sda_in             (gf_sda_in ),          // 数据线sda
    .sda_out            (gf_sda_out),
    .sda_dir            (gf_sda_dir),  
    //I2C interface
    .ack                (ack       ),
    .i2c_exec           (i2c_exec  ),          // i2c触发控制
    .i2c_rh_wl          (i2c_rh_wl ),          // i2c读写控制
    .i2c_addr           (i2c_addr  ),          // i2c操作地址
    .i2c_data_w         (i2c_data_w),          // i2c写入的数据
    .reg_num            (reg_num   ),
    .i2c_data_r         (i2c_data_r),          // i2c读出的数据
    .i2c_done           (i2c_done  ),          // i2c操作结束标志
    .once_done          (once_done ),          // 一次读写操作完成
    .bit_ctrl           (bit_ctrl  ),
    .clk_i2c            (clk       ),          // I2C操作时钟
    .cfg_done           (cfg_done  ),          // 寄存器配置完成标志
    //user interfacd
    .cfg_switch         (cfg_switch),
    .lcd_id             (lcd_id    )           //LCD ID
);

touch_ctrl
    #(.WIDTH(4'd8))                            // 一次读写寄存器的个数的位宽
u_touch_ctrl(
    //module clock
    .sys_clk            (sys_clk),
    .clk                (clk      ),           // 时钟信号
    .rst_n              (sys_rst_n),           // 复位信号（低有效）
    .cfg_done           (cfg_done ),           // 配置完成标志
    .tft_tcs            (gf_cs  ),
    .tft_int            (tft_int  ),

    //I2C interface
    .ack                (ack       ),
    .i2c_exec           (i2c_exec  ),          // i2c触发控制
    .i2c_rh_wl          (i2c_rh_wl ),          // i2c读写控制
    .i2c_addr           (i2c_addr  ),          // i2c操作地址
    .i2c_data_w         (i2c_data_w),          // i2c写入的数据
    .i2c_data_r         (i2c_data_r),          // i2c读出的数据
    .once_done          (once_done ),          // 一次读写操作完成
    .i2c_done           (i2c_done  ),          // i2c操作结束标志
    .bit_ctrl           (bit_ctrl  ),
    .reg_num            (reg_num   ),          // 一次读写寄存器的个数

    //touch lcd interface
    .touch_done         (gf_done),
    .touch_valid        (gf_valid),
    .tp_num             (tp_num),
    .tp1_xy             (gf_xy),
    .tp2_xy             (),
    .tp3_xy             (),
    .tp4_xy             (),
    .tp5_xy             (),

    //user interface
    .cfg_switch         (cfg_switch),
    .lcd_init_done      (lcd_init_done),      //LCD初始化完成
    .lcd_id             (lcd_id       ),      //LCD ID
    .bigger_en          (bigger_en),
);

xpt2046 u_xpt2046(
    //module clock
    .clk                (sys_clk  ),
	.rst_n              (sys_rst_n),
    .cnt_clk            (clk    ), // 用于给int信号滤波延时计数，之所以引入该信号，是为了减少资源的消耗（特殊情况下使用）
    //XPT2046 interface
	.tft_int            (tft_int),
	.tft_scl            (xpt_scl),
	.tft_mosi           (tft_mosi),
	.tft_tcs            (xpt_cs),
	.tft_miso           (tft_miso),
    //touch lcd interface
    .touch_done         (xpt_done ),  // 读取触摸点坐标完成脉冲信号
    .touch_valid        (xpt_valid),  // 连续触摸标志
	.tp_x               (),
	.tp_y               (),
    .tp_xy              (xpt_xy),
    .page_paint_flag    (page_paint_flag),
    .lcd_id             (lcd_id   ),      //LCD ID
    .little_en          (little_en)
);

endmodule
