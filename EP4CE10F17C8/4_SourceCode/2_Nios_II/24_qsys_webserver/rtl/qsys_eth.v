//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           qsys_eth
// Last modified Date:  2018/10/11 8:24:48
// Last Version:        V1.0
// Descriptions:        Qsys以太网实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/10/11 8:24:48
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module qsys_eth(
    //时钟和复位接口
    input             sys_clk     ,    //系统时钟
    input             sys_rst_n   ,    //按键复位

    //SDRAM 接口
    output            sdram_clk  ,     //SDRAM 芯片时钟
    output            sdram_cke  ,     //SDRAM 时钟有效
    output            sdram_cs_n ,     //SDRAM 片选
    output            sdram_ras_n,     //SDRAM 行有效
    output            sdram_cas_n,     //SDRAM 列有效
    output            sdram_we_n ,     //SDRAM 写有效
    output   [ 1:0]   sdram_ba   ,     //SDRAM Bank地址
    output   [12:0]   sdram_addr ,     //SDRAM 行/列地址
    inout    [15:0]   sdram_dq   ,     //SDRAM 数据
    output   [ 1:0]   sdram_dqm  ,     //SDRAM 数据掩码

    //EPCS Flash 接口
    output            epcs_dclk  ,     //EPCS 时钟信号
    output            epcs_sce   ,     //EPCS 片选信号
    output            epcs_sdo   ,     //EPCS 数据输出信号
    input             epcs_data0 ,     //EPCS 数据输入信号

    //以太网接口
    input             eth_rx_clk  ,    //MII接收数据时钟
    input             eth_rxdv    ,    //MII输入数据有效信号
    input             eth_tx_clk  ,    //MII发送数据时钟
    input    [3:0]    eth_rx_data ,    //MII输入数据
    output            eth_tx_en   ,    //MII输出数据有效信号
    output   [3:0]    eth_tx_data ,    //MII输出数据
    output            eth_rst_n   ,    //以太网芯片复位信号，低电平有效

    //user interface
    output   [3:0]    led              //4个LED灯
);

//wire define
wire        clk_100m;
wire        pll_locked;
wire        rst_n;

//*****************************************************
//**                    main code
//*****************************************************

assign rst_n = sys_rst_n & pll_locked ;
//以太网芯片复位信号
assign eth_rst_n = rst_n;

//例化锁相环模块
pll u_pll (
    .inclk0                             (sys_clk   ),
    .areset                             (~sys_rst_n),
    .c0                                 (clk_100m),             //QSYS 系统时钟
    .c1                                 (sdram_clk ),           //SDRAM 时钟
    .c0                                 (),
    .locked                             (pll_locked)
);

//例化Nios2系统模块
nios2os u_nios2os(
    //时钟和复位
    .clk_clk                            (clk_100m),
    .reset_reset_n                      (rst_n),
    //EPCS
    .epcs_flash_dclk                    (epcs_dclk ),
    .epcs_flash_sce                     (epcs_sce  ),
    .epcs_flash_sdo                     (epcs_sdo  ),
    .epcs_flash_data0                   (epcs_data0),
    //SDRAM
    .sdram_addr                         (sdram_addr),
    .sdram_ba                           (sdram_ba),
    .sdram_cas_n                        (sdram_cas_n),
    .sdram_cke                          (sdram_cke),
    .sdram_cs_n                         (sdram_cs_n),
    .sdram_dq                           (sdram_dq),
    .sdram_dqm                          (sdram_dqm),
    .sdram_ras_n                        (sdram_ras_n),
    .sdram_we_n                         (sdram_we_n),
    //三速以太网
    .tse_pcs_tx_clk_clk                 (eth_tx_clk),     //tse_pcs_tx_clk.clk
    .tse_pcs_rx_clk_clk                 (eth_rx_clk),     //tse_pcs_rx_clk.clk
    .tse_mac_stu_set_10                 (1'b0),           //tse_mac_stu.set_10
    .tse_mac_stu_set_1000               (1'b0),           //           .set_1000
    .tse_mac_stu_eth_mode               (),               //           .eth_mode
    .tse_mac_stu_ena_10                 (),               //           .ena_10
    .tse_mac_mii_rx_d                   (eth_rx_data),    //    tse_mac.mii_rx_d
    .tse_mac_mii_rx_dv                  (eth_rxdv),       //           .mii_rx_dv
    .tse_mac_mii_rx_err                 (1'b0),           //           .mii_rx_err
    .tse_mac_mii_tx_d                   (eth_tx_data),    //           .mii_tx_d
    .tse_mac_mii_tx_en                  (eth_tx_en),      //           .mii_tx_en
    .tse_mac_mii_tx_err                 (1'b0),           //           .mii_tx_err
    .tse_mac_misc_ff_tx_crc_fwd         (1'b0),           //tse_mac_misc.ff_tx_crc_fwd
    .tse_mac_misc_ff_tx_septy           (),               //            .ff_tx_septy
    .tse_mac_misc_tx_ff_uflow           (),               //            .tx_ff_uflow
    .tse_mac_misc_ff_tx_a_full          (),               //            .ff_tx_a_full
    .tse_mac_misc_ff_tx_a_empty         (),               //            .ff_tx_a_empty
    .tse_mac_misc_rx_err_stat           (),               //            .rx_err_stat
    .tse_mac_misc_rx_frm_type           (),               //            .rx_frm_type
    .tse_mac_misc_ff_rx_dsav            (),               //            .ff_rx_dsav
    .tse_mac_misc_ff_rx_a_full          (),               //            .ff_rx_a_full
    .tse_mac_misc_ff_rx_a_empty         (),               //            .ff_rx_a_empty
    //led
    .led_export                         (led)
 );

endmodule