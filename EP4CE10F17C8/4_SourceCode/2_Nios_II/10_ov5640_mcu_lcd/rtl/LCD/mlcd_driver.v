//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           mlcd_driver
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        MCU LCD驱动
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:         正点原子
// Modified date:       2018/8/15 14:23:12
// Version:             V1.1
// Descriptions:        Intel8080总线
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module mlcd_driver(
    input         clk       ,    //时钟
    input         rst_n     ,    //复位，低电平有效
    output        mlcd_bl   ,    //MCU LCD 背光控制信号 
    output        mlcd_cs   ,    //MCU LCD 片选信号 
    output        mlcd_rst  ,    //MCU LCD 复位信号
    output        mlcd_wr   ,    //MCU LCD 写使能信号
    output        mlcd_rd   ,    //MCU LCD 读使能信号
    output        mlcd_rs   ,    //MCU LCD 指令/数据控制信号
    output [15:0] mlcd_data ,    //MCU LCD 
    
    input         lcd_init_done, //LCD初始化完成
    input  [15:0] lcd_id    ,    //LCD ID
    input  [15:0] pixel_data,    //从fifo中读出的数据    
    output  reg   rd_en     ,    //fifo读使能信号
    input  [8:0]  rdusedw        //fifo深度
    ); 
    
//parameter define     
parameter  idle  = 3'd0;
parameter  step1 = 3'd1;
parameter  step2 = 3'd2;
parameter  step3 = 3'd3;
parameter  step4 = 3'd4;

//reg define
reg        lcd_done_d0;
reg        lcd_done_d1;
reg [15:0] lcd_id_r;
reg [10:0] lcd_height;
reg [10:0] lcd_width;
reg        wr_r; 
reg        rd_r;
reg        rs_r;
reg [15:0] data_r;
reg [2:0]  wr_step;
reg [10:0] h_cnt;
reg [10:0] v_cnt; 

//wire define
wire       pos_lcd_done;

//*****************************************************
//**                    main code
//*****************************************************  

assign mlcd_bl   = 1'b1;        //设置屏幕背光为最亮
assign mlcd_cs   = 1'b0;        //片选信号低电平有效
assign mlcd_rst  = 1'b1;        //初始化完成后，LCD不复位
assign mlcd_wr   = wr_r;        //LCD写信号
assign mlcd_rd   = rd_r;        //LCD读信号
assign mlcd_rs   = rs_r;        //LCD指令/数据控制信号
assign mlcd_data = data_r;      //LCD数据线

assign pos_lcd_done = ~lcd_done_d1 & lcd_done_d0;

//lcd_init_done上升沿
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        lcd_done_d0 <= 1'b0;
        lcd_done_d1 <= 1'b0;
    end
    else begin
        lcd_done_d0 <= lcd_init_done;
        lcd_done_d1 <= lcd_done_d0;
    end        
end    

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        lcd_id_r <= 16'd0;
    else if(pos_lcd_done)
        lcd_id_r <= lcd_id;
end

//利用状态机向LCD控制器写指令及数据
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wr_r     <= 1'b1;
        rd_r     <= 1'b1;
        rs_r     <= 1'b0;
        data_r   <= 16'd0;           
        rd_en    <= 1'b0;
        lcd_height <= 11'b0;
        lcd_width <= 11'b0;
        h_cnt <= 11'd0;
        v_cnt <= 11'b0;
        wr_step <= idle;
    end
    else begin
        case(wr_step)      
            idle: begin
                rd_r <= 1'b1; 
                wr_r     <= 1'b1;
                rd_en <= 1'b0;   
                if(lcd_done_d1) begin   
                    wr_step <= step1; 
                    case(lcd_id_r)           //根据LCD ID,选择不同的分辨率
                        16'h9341 : begin
                            lcd_width  <= 11'd320 - 1'd1;
                            lcd_height <= 11'd240 - 1'd1;
                        end    
                        16'h5310 : begin
                            lcd_width <= 11'd480 - 1'd1;
                            lcd_height <= 11'd320 - 1'd1;
                        end    
                        16'h5510 : begin
                            lcd_width <= 11'd800 - 1'd1;
                            lcd_height <= 11'd480 - 1'd1;
                        end                      
                        16'h1963 : begin
                            lcd_height <= 11'd800 - 1'd1;
                            lcd_width <= 11'd480 - 1'd1;
                        end       
                        default : wr_step <= idle;
                    endcase     
                end 
                else
                    wr_step <= idle;
            end
            step1: begin                               //发送写GRAM指令
                wr_r <= 1'b0;
                rs_r <= 1'b0;   
                if(lcd_id_r == 16'h5510)
                     data_r <= 16'h2c00;              
                else
                     data_r <= 16'h002c;    
                if(wr_r == 1'b0) begin
                    wr_r <= 1'b1;
                    wr_step <= step2;
                end
            end
            step2 : begin            //当fifo中的深度大于8的时候读取像素数据
                wr_r <= 1'b1;
                rd_en <= 1'b0;
                if(rdusedw > 9'd8) begin
                    h_cnt <= h_cnt + 1'b1;
                    rd_en <= 1'b1;          //从fifo中请求数据
                    wr_step <= step3;  
                    if(h_cnt == lcd_width ) begin
                        h_cnt <= 11'd0;
                        v_cnt <= v_cnt + 1'b1;
                        if(v_cnt == lcd_height ) begin
                            v_cnt <= 11'd0;
                            wr_step <= idle;
                        end                        
                    end  
                end 
                else
                    ;
            end
            step3: begin
                rd_en <= 1'b0;                  //不再从fifo请求数据
                wr_step <= step4;
            end
            step4: begin                        //写像素数据
                wr_r <= 1'b0;
                rs_r <= 1'b1;                                       
                data_r <= pixel_data;                                        
                wr_step <= step2;
            end
        default :;
        endcase     
    end
end   

endmodule 