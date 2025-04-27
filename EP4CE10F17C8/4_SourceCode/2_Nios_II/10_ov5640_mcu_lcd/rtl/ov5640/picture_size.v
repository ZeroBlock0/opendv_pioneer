//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           picture_size
// Last modified Date:  2018/12/3 17:31:29
// Last Version:        V1.0
// Descriptions:        摄像头输出图像尺寸及帧率配置
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/11/2 14:26:05
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module picture_size (
    input       [15:0] ID_lcd      ,
             
    output  reg [12:0] cmos_h_pixel,
    output  reg [12:0] cmos_v_pixel,   
    output  reg [12:0] total_h_pixel,
    output  reg [12:0] total_v_pixel
);

//parameter define
parameter  ID_9341   =   16'h9341;
parameter  ID_5310   =   16'h5310;
parameter  ID_5510   =   16'h5510;
parameter  ID_1963   =   16'h1963;

//*****************************************************
//**                    main code                      
//*****************************************************

//配置摄像头输出图像的尺寸大小
always @(*) begin
    case(ID_lcd) 
        ID_9341 : begin
            cmos_h_pixel = 13'd320;    
            cmos_v_pixel = 13'd240;
        end 
        ID_5310 : begin
            cmos_h_pixel = 13'd480;    
            cmos_v_pixel = 13'd320;           
        end 
        ID_5510 : begin
            cmos_h_pixel = 13'd800;    
            cmos_v_pixel = 13'd480;           
        end    
        ID_1963 : begin
            cmos_h_pixel = 13'd800;    
            cmos_v_pixel = 13'd480;           
        end 
        default : begin
            cmos_h_pixel = 13'd480;    
            cmos_v_pixel = 13'd320;           
        end
    endcase
end 

//对HTS及VTS的配置会影响摄像头输出图像的帧率
always @(*) begin
    case(ID_lcd)
        ID_9341 : begin 
            total_h_pixel =   13'd1610;
            total_v_pixel =   13'd1000;
        end
        ID_5310 : begin 
            total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000;
        end
        ID_5510 : begin 
            total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000;
        end
        ID_1963 : begin
            total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000;
        end 
        default : begin
            total_h_pixel =   13'd1800;
            total_v_pixel =   13'd1000;
        end
    endcase
end 

endmodule