//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           wm8978_ctrl
// Last modified Date:  2018/05/24 16:20:57
// Last Version:        V1.0
// Descriptions:        WM8978控制模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/05/24 16:21:23
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module wm8978_ctrl(
    //system clock
    input                clk        ,        // 时钟信号
    input                rst_n      ,        // 复位信号

    //wm8978 interface
    //audio interface(master mode)
    input                aud_bclk   ,        // WM8978位时钟
    input                aud_lrc    ,        // 对齐信号
    input                aud_adcdat ,        // 音频输入
    output               aud_dacdat ,        // 音频输出
    //user interface
    input                aud_sel    ,        // 音频信号选择 0：LINE_IN输入源 1:rom数据 
    input      [31:0]    dac_data   ,        // 输出的音频数据
    output     [31:0]    adc_data            // 录音的数据
);

//parameter define
parameter    WL = 6'd32;                     // word length音频字长定义

wire               rx_done    ;        // 一次采集完成
wire               tx_done    ;        // 一次发送完成
wire    [31:0]     aud_data   ;        // 音频数据

//*****************************************************
//**                    main code
//*****************************************************

//例化audio_receive，FPGA接收WM8978的音频数据
audio_receive #(.WL(WL)) u_audio_receive(
    //system reset
    .rst_n     (rst_n   ),          // 复位信号
    //wm8978 interface
    .aud_bclk  (aud_bclk),          // WM8978位时钟
    .aud_lrc   (aud_lrc ),          // 对齐信号
    .aud_adcdat(aud_adcdat),        // 音频输入
    //user interface
    .rx_done   (rx_done ),          // FPGA接收数据完成
    .adc_data  (adc_data)           // FPGA接收的数据
);

//例化audio_send，FPGA向WM8978传送音频数据
audio_send #(.WL(WL)) u_audio_send(
    //system reset
    .rst_n     (rst_n     ),        // 复位信号
    //wm8978 interface
    .aud_bclk  (aud_bclk  ),        // WM8978位时钟
    .aud_lrc   (aud_lrc   ),        // 对齐信号
    .aud_dacdat(aud_dacdat),        // 音频数据输出
    //user interface
    .dac_data  (aud_data  ),        // 预输出的音频数据
    .tx_done   (tx_done   )         // 发送完成信号
);

music_ctrl  u_music_ctrl(
    .clk        (aud_bclk),
    .rst_n      (rst_n),
    .aud_sel    (aud_sel),
    .tx_done    (tx_done),
    .dac_data   (dac_data),
    .aud_data   (aud_data) 
);

endmodule