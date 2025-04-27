//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved	                               
//----------------------------------------------------------------------------------------
// File name:           can_controller
// Last modified Date:  2018/8/30 11:12:36
// Last Version:        V1.1
// Descriptions:        vga驱动
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/8/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module can_controller(
    //module clock
    input                csi_clk  ,
    input                rsi_reset,
    
    //Avalon MM interface
    input    [7:0]       avs_address,
    input                avs_chipselect,
    input                avs_write,
    input                avs_read,
    input    [7:0]       avs_writedata,
    output   [7:0]       avs_readdata,
    output               avs_waitrequest_n,

    // CAN interface
    input                can_clk,               //CAN控制器的操作时钟
    input                can_reset,             //CAN控制器复位信号
    input                can_rx,                //CAN控制器接收数据引脚
    output               can_tx,                //CAN控制器发送数据引脚
    output               can_irq_n,             //CAN控制器中断信号
    output               can_clkout             //CAN控制器分频时钟输出信号

);

//*****************************************************
//** main code
//*****************************************************

can_top u1_can_top(
    //Wishbone interface
    .wb_clk_i   (csi_clk              ),
    .wb_rst_i   (rsi_reset | can_reset),
    .wb_dat_i   (avs_writedata[7:0]   ),
    .wb_dat_o   (avs_readdata[7:0]    ),
    .wb_cyc_i   (avs_write | avs_read ),
    .wb_stb_i   (avs_chipselect       ),
    .wb_we_i    (avs_write & ~avs_read),
    .wb_adr_i   (avs_address[7:0]     ),
    .wb_ack_o   (avs_waitrequest_n    ),
    //CAN interface
    .clk_i      (can_clk              ),
    .rx_i       (can_rx               ),
    .tx_o       (can_tx               ),
    .bus_off_on (),
    .irq_on     (can_irq_n            ),
    .clkout_o   (can_clkout           )
);

endmodule
