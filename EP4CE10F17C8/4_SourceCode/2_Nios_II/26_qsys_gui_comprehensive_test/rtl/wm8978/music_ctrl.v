//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           music_ctrl
// Last modified Date:  2019/03/24 16:20:57
// Last Version:        V1.0
// Descriptions:        音乐控制模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/03/24 16:21:23
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module music_ctrl(
    input          clk,
    input          rst_n,
    
    input          aud_sel,  // 音频信号选择 0：LINE_IN输入源 1:rom数据 
    input          tx_done,  // 音频数据发送完成信号
    input  [31:0]  dac_data, // LINE_IN输入源
    output [31:0]  aud_data  // 输出的音频数据     
);

reg    [7:0]   rd_addr;
reg            sel_flag;
reg    [21:0]  sel_cnt; 

wire   [15:0]  rom_data;
wire   [31:0]  rom_data_t;

//左右声道各16位，共32位音频数据
assign rom_data_t = sel_flag ?  {rom_data,rom_data} : 32'd0;
//音频信号选择
assign aud_data = aud_sel ? rom_data_t : dac_data;

//读ROM地址累加 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rd_addr <= 8'd0;
    else if(tx_done) begin
        rd_addr <= rd_addr + 1'b1;
        if(rd_addr == 8'd95)
            rd_addr <= 8'd0;   
    end
end

//计时，使喇叭周期性的发声
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sel_flag <= 1'b0;
        sel_cnt <= 22'd0;
    end    
    else begin
        sel_cnt <= sel_cnt + 1'b1;
        if(sel_cnt == 22'h3f_ffff) begin
            sel_flag <= ~sel_flag;
            sel_cnt <= 22'd0;
        end    
    end
end        

//ROM存储和弦声音文件
rom_sin_wave  u_rom_sin_wave(
    .address       (rd_addr),
    .clock         (clk),
    .rden          (tx_done),
    .q             (rom_data)
);

endmodule
