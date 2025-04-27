//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           segled_controller
// Last modified Date:  2018/08/01 18:46:39
// Last Version:        V1.0
// Descriptions:        数码管自定义IP核控制器
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/01 18:46:48
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module segled_controller(
    input         clk,              // 时钟信号
    input         rst_n,            // 复位信号

    //Avalon-MM 接口
    input  [ 1:0] avs_address,      // Avalon地址总线
    input         avs_write,        // Avalon写请求
    input  [31:0] avs_writedata,    // Avalon写数据

    //数码管接口
    output [ 5:0] sel,              // 数码管位选
    output [ 7:0] seg_led           // 数码管段选
);

//wire define
wire [19:0] data;  // 6个数码管要显示的数值
wire [ 5:0] point; // 小数点显示的位置,从高(左)到低(右),高电平有效
wire        sign;  // 显示符号位（高电平显示负号）
wire        en;    // 数码管使能信号

//*****************************************************
//**                    main code
//*****************************************************

//数码管寄存器文件
segled_register u_segled_register(
    .clk            (clk),
    .rst_n          (rst_n),
    
    //Avalon-MM 接口  
    .avs_address    (avs_address),
    .avs_write      (avs_write),
    .avs_writedata  (avs_writedata),

    //用户接口
    .data           (data),
    .point          (point),
    .sign           (sign),
    .en             (en),
);

//数码管逻辑功能文件
segled_logic u_segled_logic(
    .clk            (clk),    
    .rst_n          (rst_n),

    //用户接口
    .data           (data),    
    .point          (point),
    .sign           (sign),
    .en             (en),    

    //数码管接口
    .sel            (sel),    
    .seg_led        (seg_led)     
);

endmodule 