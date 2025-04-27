//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           segled_register
// Last modified Date:  2018/08/01 14:23:22
// Last Version:        V1.0
// Descriptions:        数码管自定义IP核寄存器文件
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/01 14:23:31
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module segled_register(
    input             clk,              // 时钟信号
    input             rst_n,            // 复位信号（低有效）
    
    //Avalon-MM 接口
    input      [ 1:0] avs_address,      // Avalon 地址
    input             avs_write,        // Avalon 写请求
    input      [31:0] avs_writedata,    // Avalon 写数据

    //用户接口
    output reg [19:0] data,             // 6个数码管要显示的数值
    output reg [ 5:0] point,            // 小数点显示的位置,从左到右,高电平有效
    output reg        sign,             // 显示符号位（高电平显示“-”号）
    output reg        en                // 数码管使能信号
);

//*****************************************************
//**                    main code
//*****************************************************

//用于给进行赋值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data  <= 20'd0;   //显示数值寄存器
        point <= 6'd0;    //小数点位置寄存器
        sign  <= 1'b0;    //符号使能寄存器
        en    <= 1'b0;    //显示使能寄存器
    end
    else if(avs_write) begin
        case(avs_address)
            2'd0:                             //地址0：显示数值寄存器
                data  <= avs_writedata[19:0];  
            2'd1:                             //地址1：小数点位置寄存器
                point <= avs_writedata[5:0];  
            2'd2:                             //地址2：符号使能寄存器
                sign  <= avs_writedata[0];     
            2'd3:                             //地址3：显示使能寄存器
                en    <= avs_writedata[0];
        endcase
    end
end

endmodule 