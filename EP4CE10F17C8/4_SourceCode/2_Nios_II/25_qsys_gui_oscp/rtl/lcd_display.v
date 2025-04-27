//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           lcd_rgb_top
// Last modified Date:  2018/3/21 13:58:23
// Last Version:        V1.0
// Descriptions:        LCD显示模块
//                      LCD分辨率800*480,CMOS分辨率600*480,将CMOS像素数据在LCD中间位置显示
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/21 13:58:23
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module lcd_display(
    input             lcd_clk,                  //lcd驱动时钟
    input             sys_rst_n,                //复位信号
    
    input      [10:0] pixel_xpos,               //像素点横坐标
    input      [10:0] pixel_ypos,               //像素点纵坐标
    
    input      [15:0] fifo_pixel_data,          //fifo中读出的像素数据   
    
    input      [15:0] line_length,              //AD数据
    output     [8:0]  line_cnt,                 //显示点数
    input             outrange,
    output            data_req,                 //请求AD数据
    output            wr_over,                  //绘制波形完成
    output     [15:0] lcd_data,                 //LCD像素点数据

    input      [9:0]  v_shift,                  //波形竖直偏移量，bit[9]=0/1:左移/右移 
    input      [4:0]  v_scale,                  //波形竖直缩放比例，bit[4]=0/1:缩小/放大 
    input      [7:0]  trig_line                //触发电平
    );    

//parameter define  
parameter  H_LCD_DISP = 11'd480;                //LCD分辨率——行
parameter  V_LCD_DISP = 11'd272;                //LCD分辨率——行
localparam BLACK  = 16'b00000_000000_00000;     //RGB565 黑色
localparam WHITE  = 16'b11111_111111_11111;     //RGB565 白色
localparam BLUE   = 16'b00000_000000_11111;     //RGB565 蓝色

//reg define
reg  [15:0] pre_length;
reg         outrange_reg;

//wire define
wire [11:0] scale_length;
wire [15:0] shift_length;
wire [15:0] draw_length;

//*****************************************************
//**                    main code
//*****************************************************

//请求像素数据信号
assign data_req = ((pixel_xpos >= 49 -1) && (pixel_xpos < 349 -1)) 
                    ? 1'b1 : 1'b0;

//根据读出的AD值，在屏幕上绘点
assign lcd_data = (outrange_reg || outrange) ? fifo_pixel_data :
                  ((pixel_xpos > 49) && (pixel_xpos < 349) &&
                   (pixel_ypos >= 49) && (pixel_ypos < 250) && 
                   (((pixel_ypos >= pre_length) && (pixel_ypos <= draw_length))
                    ||((pixel_ypos <= pre_length)&&(pixel_ypos >= draw_length)))
                  ) ? WHITE : 
                  ((pixel_xpos > 49) && (pixel_xpos < 349) &&
                   (pixel_ypos >= 49) && (pixel_ypos < 250) &&
                   (pixel_ypos == trig_line)
                  ) ? BLUE : fifo_pixel_data;

//根据显示的X坐标计算数据在RAM中的地址
assign line_cnt = data_req ? (pixel_xpos - (49-1)) : 9'd0;

//标志一帧波形绘制完毕
assign wr_over  = (pixel_xpos == 349) && (pixel_ypos == 250);

//竖直方向上的缩放
assign scale_length = v_scale[4] ? 
                        (line_length * v_scale[3:0])-((128*v_scale[3:0])-128) : //放大
                            (line_length >> v_scale[3:1])+(128-(128>>v_scale[3:1])); //缩小


//对波形进行竖直方向的移动
assign shift_length = v_shift[9] ?                      //下移
                        ((scale_length >= 2048) ? 
                            (v_shift[7:0]+20-(~{4'hf,scale_length}+1)) :
                            (scale_length+v_shift[7:0]+20) 
                        ) :                             //上移
                        ((scale_length >= 2048) ? 16'd0 :
                            (scale_length+20 <= v_shift[7:0] ? 16'd0 :
                                (scale_length+20-v_shift[7:0])));

//处理负数长度
assign draw_length = shift_length[15] ? 16'd0 : shift_length;


//寄存前一个像素点的纵坐标，用于各点之间的连线
always @(posedge lcd_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        pre_length <= 16'd0;
    else 
    if((pixel_xpos >= 49) && (pixel_xpos < 349)
        && (pixel_ypos >= 49) && (pixel_ypos < 250))
        pre_length <= draw_length;
end

//寄存outrange,用于水平方向移动时处理左右边界
always @(posedge lcd_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        outrange_reg <= 1'b0;
    else 
        outrange_reg <= outrange;
end

endmodule 