//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           st_2_fifo
// Last modified Date:  2018/3/9 14:21:12
// Last Version:        V1.0
// Descriptions:        Avalon-ST 格式的数据流转化为FIFO接口
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/9 14:21:04
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module st_2_fifo(
    input           clk50m,
    input           lcd_clk,
    input           rst_n,
    
    output          sink_ready,
    input           sink_valid,
    input           sink_sop,
    input           sink_eop,
    input  [15:0]   sink_data,
    
    input           lcd_data_req,
    output [15:0]   lcd_pixel_data
    );

//wire define
wire [9:0] fifo_usedw_w;

//*****************************************************
//**                    main code
//*****************************************************
    
assign sink_ready = (fifo_usedw_w < 500) ? 1'b1 : 1'b0;

lcd_disp_fifo u_lcd_disp_fifo1(
	.wrclk          (clk50m),
	.rdclk          (lcd_clk),
    
    .wrreq          (sink_valid),
    .data           (sink_data),
    .wrusedw        (fifo_usedw_w),
    
    .rdreq          (lcd_data_req),
    .q              (lcd_pixel_data),
    .rdempty        (),
    
	.aclr           (~rst_n)
    );
 
endmodule 