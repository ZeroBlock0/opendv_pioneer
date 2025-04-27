//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           fifo_2_st
// Last modified Date:  2018/11/1 8:41:06
// Last Version:        V1.0
// Descriptions:        模块将从 SDRAM 中读出的数据经FIFO缓存后，转成Avalon-ST格式输出
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/11/1 8:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module fifo_2_st(
    input               clk,
    input               clk_50m,
    input               rst_n,
    
    //从SDRAM中读出的数据
    input               source_valid,  
    input        [18:0] source_fifo_data,
    output       [9:0]  source_fifo_wrusedw,
    
    //Avalon-ST格式的数据
    input               st_source_ready,
    output              st_source_sop,
    output              st_source_eop,
    output              st_source_valid,
    output       [15:0] st_source_data
    );

//reg define 
reg         fifo_valid_r;
reg         fifo_rdreq_r;

//wire define
wire        fifo_rdempty;
wire        fifo_rdreq;
wire [18:0] fifo_data;

//*****************************************************
//**                    main code
//*****************************************************

assign st_source_sop    = fifo_data[18];
assign st_source_eop    = fifo_data[17];
assign st_source_data   = fifo_data[15:0];
assign st_source_valid  = fifo_valid_r;

//fifo读请求信号
assign fifo_rdreq = fifo_rdreq_r && (~fifo_rdempty) && (st_source_ready);

// FIFO：缓存SDRAM中读出的数据
source_st_fifo u_source_st_fifo(
	.wrclk          (clk),
	.rdclk          (clk_50m),
    
    .wrreq          (source_valid),
    .data           (source_fifo_data),
    .wrusedw        (source_fifo_wrusedw),
    
    .rdreq          (fifo_rdreq),
    .q              (fifo_data),
    .rdempty        (fifo_rdempty),
    
	.aclr           (~rst_n)
    );
       
always @ (posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        fifo_rdreq_r <= 1'b0;
        fifo_valid_r <= 1'b0;
    end
    else begin
        fifo_rdreq_r <= !fifo_rdempty;
        fifo_valid_r <= fifo_rdreq;
    end
end

endmodule       