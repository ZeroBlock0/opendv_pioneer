//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved	                               
//----------------------------------------------------------------------------------------
// File name:           sdram_bridge_control
// Last modified Date:  2018/3/13 9:03:06 
// Last Version:        V1.0
// Descriptions:        SDRAM桥控制模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/13 9:03:06 
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//****************************************************************************************// 

module sdram_bridge_control(
    input               clk,
    input               rst_n,
    
    output  reg         bridge_write,
    output  reg         bridge_read,
    output  reg  [25:0] bridge_address,
    output  reg  [9:0]  bridge_burstcount,
    input               bridge_waitrequest,
    input               bridge_readdatavalid,
    input        [15:0] bridge_readdata,
    
    input               ov5640_id_flag,
    input        [11:0] ov5640_fifo_rdusedw,
    
    output reg          source_valid,
    output       [18:0] source_fifo_data,
    input        [ 9:0] source_fifo_wrusedw
    );

//parameter define

//SDRAM 存储容量 = 2^13(row)*2^9(col)*4(bank)*2(byte)
parameter SDRAM_SPAN = 33554432;

//7寸RGB LCD参数（800*480）
parameter  gui_addr_start   = SDRAM_SPAN - 768000 - 1000;   //GUI显存起始地址;
parameter  gui_addr_end     = SDRAM_SPAN - 1000;            //GUI显存结束地址（800*480）
parameter  cam_addr_start   = SDRAM_SPAN - 769000 - 769000; //摄像头显存起始地址
parameter  cam_addr_end     = cam_addr_start + 768000;      //摄像头显存结束地址（800*480）
parameter  lcd_addr_end     = cam_addr_start + 768000;      //LCD显示摄像头图像时，读取摄像头显存的所有地址 

parameter  burstcount       = 10'd512;                      //SDRAM 突发长度
parameter  burst_num        = 10'd512;
parameter  burst_addr       = 11'd1024 ;
parameter  usedw_wr         = 512;                          //读fifo的数据深度
parameter  usedw_rd         = 512;                          //写fifo的数据深度

//reg define
reg  [25:0] address_wr;     //写fifo端写数据的sdram地址
reg  [25:0] address_rd;     //读fifo端读取数据的sdram地址
reg  [9:0]  cnt_burst;      //计数一次突发读数据过程中已读取的个数
reg  [3:0]  cnt_delay;
reg         clr;
reg         step;
reg         step_1;
reg         wr_flag;        //读写标志信号,高电平读,低电平写
reg         id_flag_0;
reg         id_flag_1;

reg         source_sop;
reg         source_eop;
reg [15:0]  source_data;

//wire define 
wire burst_start;   
wire id_flag_pos;

//*****************************************************
//**                    main code
//*****************************************************

assign source_fifo_data = {source_sop,source_eop,source_valid,source_data};

//捕获ov5640_id_flag信号上升沿
assign id_flag_pos = (~id_flag_1) & id_flag_0;

//采集step上升沿信号，标志着突发传输指令已发出
assign burst_start = (~step_1 ) & step;

//对id_flag信号连续寄存两次
always @ (posedge clk  or negedge rst_n ) begin 
    if(!rst_n ) begin
        id_flag_0 <= 1'b0;
        id_flag_1 <= 1'b0;
    end
    else begin
        id_flag_0 <= ov5640_id_flag;
        id_flag_1 <= id_flag_0;
    end 
end 

//寄存step信号，用于边沿捕获
always @ (posedge clk  or negedge rst_n ) begin 
    if(!rst_n ) 
        step_1 <= 1'b0;
    else    
        step_1 <=  step;  
end

//摄像头写SDRAM的地址
always @ (posedge clk or negedge rst_n ) begin
    if(!rst_n )
        address_wr <= cam_addr_start;
    else if (id_flag_pos == 1'b1)
        address_wr <= cam_addr_start;
    else if (address_wr == cam_addr_end )
        address_wr <= cam_addr_start;
    else if (burst_start & (!wr_flag)) 
        address_wr <= address_wr + burst_addr; 
end 

//读SDRAM的地址
always @ (posedge clk or negedge rst_n ) begin
    if(!rst_n )
        address_rd <= gui_addr_start;
    else if ((address_rd == gui_addr_end) || (address_rd == lcd_addr_end)) begin
        if(ov5640_id_flag)
            address_rd <= cam_addr_start;
        else
            address_rd <= gui_addr_start;
    end
    else if (burst_start & wr_flag)
        address_rd <= address_rd + burst_addr; 
end

//计数突发读出的数据个数
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_burst <= 10'b0;
    else if (cnt_burst == burstcount) 
        cnt_burst <= 10'b0;
    else if (bridge_readdatavalid || 
            (bridge_write & (! bridge_waitrequest)) )
        cnt_burst <= cnt_burst + 1'b1;
end 

//source_st_fifo中的数据量低于512时，从sdram中读数据
//OV5640写fifo中的数据量大于512时，往sdram中写数据
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        step                <= 1'b0;   
        bridge_read         <= 1'b0;         
        bridge_write        <= 1'b0;
        bridge_address      <= 26'b0;
        bridge_burstcount   <= 10'b0;
        wr_flag    <= 1'b1;
        clr  <= 1'b0;
    end 
    else if((! bridge_waitrequest) && (source_fifo_wrusedw < usedw_wr) 
            &&(cnt_burst == 10'd0) && (wr_flag == 1'b1)) begin  //从sdram读数据
        case(step)    
            1'b0: begin 
                if(cnt_delay == 4'd10) begin
                    clr                 <= 1'b1;
                    step                <= 1'b1;
                    bridge_read         <= 1'b1;   
                    bridge_write        <= 1'b0;
                    bridge_address      <= address_rd;
                    bridge_burstcount   <= burstcount;
                end
                else 
                    clr <= 1'b0;
            end 
            1'b1: begin
                bridge_read       <= 1'b0;   
                bridge_address    <= 26'b0;
                bridge_burstcount <= 10'b0;
            end
            default: ;         
        endcase   
    end 
    else if ((cnt_burst == burstcount) && (wr_flag == 1'b1)) 
        step <= 1'b0;
    else if((! bridge_waitrequest) && (ov5640_fifo_rdusedw > usedw_rd) 
            &&(cnt_burst == 10'd0) && (wr_flag == 1'b0)) begin   //往sdram写数据
        case(step)    
            1'b0 : begin 
                clr  <= 1'b0;
                if(cnt_delay == 4'd10) begin
                    clr                 <= 1'b1;
                    step                <= 1'b1;
                    bridge_read         <= 1'b0;   
                    bridge_write        <= 1'b1;
                    bridge_address      <= address_wr;
                    bridge_burstcount   <= burstcount;
                end
                else
                    clr  <= 1'b0;
            end 
            1'b1 : begin
                bridge_write        <= 1'b1;   
                bridge_address      <= 26'b0;
                bridge_burstcount   <= 10'b0;
            end
            default : ;         
        endcase   
    end 
    else if ((cnt_burst == burstcount- 1'b1)&&(wr_flag == 1'b0)&&(! bridge_waitrequest)) begin
        step <= 1'b0;
        bridge_write      <= 1'b0;
    end
    else if ((cnt_burst == 10'd0)&&(source_fifo_wrusedw < usedw_wr))
        wr_flag <= 1'b1;
    else if ((cnt_burst == 10'd0)&&(ov5640_fifo_rdusedw >= usedw_rd))
        wr_flag <= 1'b0;
end

//延时模块
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) 
        cnt_delay <= 4'd0;
    else if(clr)
        cnt_delay <= 4'd0;
    else
        cnt_delay <= cnt_delay + 1'b1;
end


//将SDRAM中读出的数据转换成Avalon-ST格式
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        source_sop     <= 1'b0;
        source_eop     <= 1'b1;
        source_data    <= 0;
        source_valid   <= bridge_readdatavalid;
    end
    else begin
        source_data    <= bridge_readdata;
        source_valid   <= bridge_readdatavalid;

        if( ((address_rd == gui_addr_start + burst_addr) || (address_rd == cam_addr_start + burst_addr))
          && (cnt_burst == 0) && bridge_readdatavalid )
            source_sop <= 1'b1;
        else
            source_sop <= 1'b0;
            
        if( ((address_rd == gui_addr_start) || (address_rd == cam_addr_start))
          && (cnt_burst == burstcount- 1'b1) && bridge_readdatavalid)
            source_eop <= 1'b1;
        else
            source_eop <= 1'b0;
    end
end

endmodule       