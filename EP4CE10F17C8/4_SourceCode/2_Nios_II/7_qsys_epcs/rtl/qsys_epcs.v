//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           qsys_epcs_rw
// Last modified Date:  2018/07/25 15:30:25
// Last Version:        V1.0
// Descriptions:        EPCS读写
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/07/25 15:30:41
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module qsys_epcs_rw(
    input    sys_clk,
    input    sys_rst_n,

    //EPCS 接口
    output   epcs_flash_dclk,
    output   epcs_flash_sce,
    output   epcs_flash_sdo,
    input    epcs_flash_data0
);

//*****************************************************
//**                    main code
//*****************************************************

//例化Qsys系统
qsys_epcs u_qsys_epcs(
    .clk_clk          (sys_clk         ),     // 驱动时钟
    .reset_reset_n    (sys_rst_n       ),     // 复位信号（低有效）
    
    .epcs_flash_dclk  (epcs_flash_dclk ),     // 时钟
    .epcs_flash_sce   (epcs_flash_sce  ),     // 片选信号
    .epcs_flash_sdo   (epcs_flash_sdo  ),     // 数据输出
    .epcs_flash_data0 (epcs_flash_data0)      // 数据输入
);

endmodule 