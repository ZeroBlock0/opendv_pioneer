//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           xpt2046
// Last modified Date:  2019/02/28 19:26:28
// Last Version:        V1.0
// Descriptions:        XPT2046的驱动模块代码
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/02/28 19:26:28
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module xpt2046(
    //module clock
    input                 clk  ,        // 模块驱动时钟
    input                 rst_n,        // 模块复位信号

    input                 cnt_clk,      // int_cnt计数时钟

    //XPT2046 interface
    input                 tft_int,
    output  reg           tft_scl,
    output  reg           tft_mosi,
    output                tft_tcs,
    input                 tft_miso,

    //touch lcd interface
    output   reg          touch_done ,  // 读取触摸点坐标完成脉冲信号
    output   reg          touch_valid,  // 连续触摸标志
    output   reg [11:0]   tp_x ,        // X坐标
    output   reg [11:0]   tp_y ,        // Y坐标
    output   reg [31:0]   tp_xy,        // XY坐标

    //user interface
    input                 page_paint_flag, //画板界面标志
    input        [15:0]   lcd_id         ,
    input                 little_en
);

//param define
localparam S          = 1'b1;           // 起始位
localparam MODE       = 1'b0;           // 采样精度
localparam SER_DFR    = 1'b0;           // 单端/差分采样模式
localparam PD         = 2'b00;          // 功耗控制
parameter  CONV_TIMES = 20;             // 每CONV_TIMES次计算一次均值
parameter  AVERAGE    = 2'd3;           // 除以8 == 右移3位，求平均值
parameter  INT_DELAY_TIME = 16'd16000;  // INT信号延时消抖时间

//reg define
reg    [4:0]    clk_div_cnt     ;       // 对clk信号分频计数
reg    [5:0]    flow_cnt        ;       // 流控制
reg    [5:0]    conv_cnt        ;       // 记录转换次数
reg    [15:0]   int_cnt         ;
reg             tft_scl_2x      ;       // tft_scl频率的2倍脉冲
reg             conv_en         ;       // 转换使能信号
reg             conv_done       ;       // 转换结束
reg    [11:0]   dq_rd           ;       // 从触摸芯片读取的数据
reg             dq_handle_flag  ;       // 对采集完成后的数据进行处理

reg    [15:0]   tp_x_add,tp_y_add;      // X、Y的采样数据累加和
reg    [11:0]   tp_x_t,tp_y_t;
reg    [11:0]   x_sap_max,x_sap_min,y_sap_max,y_sap_min;  // X、Y的采样数据最大最小值
reg    [11:0]   tp_x_ave,tp_y_ave;      // X、Y的采样数据平均值（除最大、最小值）
reg    [31:0]   tp_xy_t;
reg             touch_valid_cnt_en;
reg             tft_int_cnt_en;
reg    [ 4:0]   touch_valid_cnt;
reg    [ 4:0]   touch_int_cnt;
reg             tft_int_d0,tft_int_d1;
reg             conv_en_d0,conv_en_d1;

//wire define
wire [2:0]      addr        ;           //采样通道
wire            int_cnt_done;           //tft_int消抖结束信号
wire            tft_int_pos /*synthesis keep*/;
wire            conv_en_neg;

//*****************************************************
//**                    main code
//*****************************************************

assign tft_tcs = ~conv_en;             // 片选信号
//conv_cnt值为奇数，选择测量X通道（101）
assign addr = (conv_cnt[0]) ? 3'b101:3'b001;
assign int_cnt_done = (int_cnt == INT_DELAY_TIME);  //tft_int消抖结束
assign tft_int_pos = tft_int_d0 & (~tft_int_d1);
assign conv_en_neg = ~conv_en_d0 & (conv_en_d1);

always @(*) begin
    if(lcd_id[15:8] == 8'h93) begin             // 2.8'触摸屏9341
        tp_x = tp_x_t;
        tp_y = tp_y_t;
    end
    else if(lcd_id[15:8] == 8'h53) begin        // 3.5'触摸屏5310
        tp_x = 4095 - tp_x_t;
        tp_y = 4095 - tp_y_t;
    end
end

//xy的坐标
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tp_xy <= 32'd0;
    else
        tp_xy <= {4'd0,tp_x,4'd0,tp_y};
end

//当触摸点变化时输出脉冲
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        touch_done <= 1'b0;
        tp_xy_t   <= 32'd0;
    end
    else begin
        tp_xy_t <= tp_xy;
        if(tp_xy_t != tp_xy) begin
            if(page_paint_flag) begin
                if(touch_int_cnt[0])
                    touch_done <= 1'b1;
                else
                    touch_done <= 1'b0;
            end
            else if(touch_int_cnt == 5'd1)
                touch_done <= 1'b1;
            else
                touch_done <= 1'b0;
        end
        else
            touch_done <= 1'b0;
    end
end

//对tft_int信号打拍采上升沿
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tft_int_d0 <= 1'd0;
        tft_int_d1 <= 1'd0;
    end
    else begin
        tft_int_d0 <= tft_int;
        tft_int_d1 <= tft_int_d0;
    end
end

//对conv_en信号打拍采下降沿
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        conv_en_d0 <= 1'd0;
        conv_en_d1 <= 1'd0;
    end
    else begin
        conv_en_d0 <= conv_en;
        conv_en_d1 <= conv_en_d0;
    end
end

//tft_int上升沿时使能touch_valid_cnt_en信号，并在touch_valid_cnt为20时无效
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        touch_valid_cnt_en <= 1'd0;
    else if(tft_int_pos)
        touch_valid_cnt_en <= 1'b1;
    else if(touch_valid_cnt < 5'd20)
        touch_valid_cnt_en <= 1'b1;
    else
        touch_valid_cnt_en <= 1'b0;
end

//touch_valid_cnt计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        touch_valid_cnt <= 5'd0;
    else if(tft_int_pos)
        touch_valid_cnt <= 5'b0;
    else if(touch_valid_cnt_en)
        touch_valid_cnt <= touch_valid_cnt + 1'b1;
end

//如果在touch_valid_cnt到达指定值时，tft_int为低，使能touch_valid信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        touch_valid <= 1'b0;
    else if(!tft_int)
        touch_valid <= 1'b1;
    else if(touch_valid_cnt == 5'd19) begin
        if(!tft_int)
            touch_valid <= 1'b1;
        else
            touch_valid <= 1'b0;
    end
end

//touch_int_cnt控制输出坐标和连续触摸
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        touch_int_cnt <= 'd0;
    else if(touch_valid) begin
        if(conv_en_neg)
            touch_int_cnt <= touch_int_cnt + 1'b1;
    end
    else
        touch_int_cnt <= 'd0;
end

//控制tft_int信号消抖使能
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tft_int_cnt_en <= 1'd0;
    else if(tft_int_pos)
        tft_int_cnt_en <= 1'b1;
    else if(int_cnt_done)
        tft_int_cnt_en <= 1'b0;
end

//tft_int引脚延时消抖计数
always@(posedge cnt_clk or negedge rst_n) begin
    if(!rst_n)
        int_cnt <= 16'd0;
    else if(!tft_int && little_en && tft_int_cnt_en) begin   //tft_int为低电平
        if(int_cnt_done)
            int_cnt <= 16'd0;
        else
            int_cnt <= int_cnt + 1'b1;
    end
    else
        int_cnt <= 16'd0;
end

//使能CONV_TIMES次转换
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        conv_en <= 1'b0;
    else if(int_cnt_done)
        conv_en <= 1'b1;
    else if(conv_cnt == CONV_TIMES && conv_done)
        conv_en <= 1'b0;
end

//clk为100MHz，tft_scl选用2MHz，
//clk 25分频
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        clk_div_cnt <= 5'd0;
    else if(conv_en) begin
        if(clk_div_cnt == 5'd24)
            clk_div_cnt <= 5'd0;
        else
            clk_div_cnt <= clk_div_cnt + 1'b1;
    end
    else
        clk_div_cnt <= 5'd0;
end

//生成2倍tft_scl频率的脉冲
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
       tft_scl_2x <= 1'b0;
    else if(clk_div_cnt == 5'd24)
       tft_scl_2x <= 1'b1;
    else
       tft_scl_2x <= 1'b0;
end

//用tft_scl_2x控制flow_cnt
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        flow_cnt <= 6'd0;
    else if(conv_en)begin
        if(tft_scl_2x)begin
            if(flow_cnt == 6'd45)   //一次转换完成后，开始下次转换
                flow_cnt <= 6'd16;
            else
                flow_cnt <= flow_cnt + 1'b1;
        end
    end
    else
        flow_cnt <= 6'd0;
end

//根据flow_cnt值发送控制字并读取采样坐标
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tft_scl  <=  1'd0;
        tft_mosi <=  1'b0;
        conv_cnt <=  6'd0;
        dq_rd    <= 12'd0;
    end
    else if(conv_en)begin
        if(tft_scl_2x)begin
            case(flow_cnt)
                6'd0 :begin                    //发送转换起始位
                    tft_mosi <= S;
                    tft_scl  <= 1'b0;
                end
                6'd1 : tft_scl  <= 1'b1;
                6'd2 :begin                    //发送采样通道
                    tft_mosi <= addr[2];
                    tft_scl  <= 1'b0;
                end
                6'd3 : tft_scl  <= 1'b1;
                6'd4 :begin
                    tft_mosi <= addr[1];
                    tft_scl  <= 1'b0;
                end
                6'd5 : tft_scl  <= 1'b1;
                6'd6 :begin
                    tft_mosi <= addr[0];
                    tft_scl  <= 1'b0;
                end
                6'd7 : tft_scl  <= 1'b1;
                6'd8 :begin                    //发送采样精度设置位
                    tft_mosi <= MODE;
                    tft_scl  <= 1'b0;
                end
                6'd9 : tft_scl  <= 1'b1;
                6'd10:begin                    //发送ADC输入模式位
                    tft_mosi <= SER_DFR;
                    tft_scl  <= 1'b0;
                end
                6'd11: tft_scl  <= 1'b1;
                6'd12:begin                    //发送功耗控制位PD
                    tft_mosi <= PD[1];
                    tft_scl  <= 1'b0;
                end
                6'd13: tft_scl  <= 1'b1;
                6'd14:begin
                    tft_mosi <= PD[0];
                    tft_scl  <= 1'b0;
                end
                6'd15: tft_scl  <= 1'b1;
                6'd16:begin                    //开始转换，BUSY信号拉高
                    tft_mosi <= 0;
                    tft_scl  <= 1'b0;
                end
                6'd17: tft_scl  <= 1'b1;
                6'd18: tft_scl  <= 1'b0;       //BUSY信号拉低，芯片输出数据
                6'd19:begin                    //读取转换结果
                    dq_rd[11]<= tft_miso;
                    tft_scl  <= 1'b1;
                end
                6'd20: tft_scl  <= 1'b0;
                6'd21:begin
                    dq_rd[10]<= tft_miso;
                    tft_scl  <= 1'b1;
                end
                6'd22: tft_scl  <= 1'b0;
                6'd23:begin
                    dq_rd[9] <= tft_miso;
                    tft_scl  <= 1'b1;
                end
                6'd24: tft_scl  <= 1'b0;
                6'd25:begin
                    dq_rd[8] <= tft_miso;
                    tft_scl  <= 1'b1;
                end
                6'd26: tft_scl  <= 1'b0;
                6'd27:begin
                    dq_rd[7] <= tft_miso;
                    tft_scl <= 1'b1;
                end
                6'd28: tft_scl <= 1'b0;
                6'd29:begin
                    dq_rd[6] <= tft_miso;
                    tft_scl <= 1'b1;
                end
                6'd30:begin                    //开始发送下次转换的控制字
                    tft_mosi <= S;
                    tft_scl <= 1'b0;
                end
                6'd31:begin
                    dq_rd[5] <= tft_miso;
                    tft_scl <= 1'b1;
                end
                6'd32:begin
                    tft_mosi <= addr[2];
                    tft_scl <= 1'b0;
                end
                6'd33:begin
                    dq_rd[4] <= tft_miso;
                    tft_scl <= 1'b1;
                end
                6'd34:begin
                    tft_mosi <= addr[1];
                    tft_scl <= 1'b0;
                end
                6'd35:begin
                    dq_rd[3] <= tft_miso;
                    tft_scl <= 1'b1;
                end
                6'd36:begin
                    tft_mosi <= addr[0];
                    tft_scl <= 1'b0;
                end
                6'd37:begin
                    dq_rd[2] <= tft_miso;
                    tft_scl  <= 1'b1;
                end
                6'd38:begin
                    tft_mosi <= MODE;
                    tft_scl  <= 1'b0;
                end
                6'd39:begin
                    dq_rd[1] <= tft_miso;
                    tft_scl  <= 1'b1;
                end
                6'd40:begin
                    tft_mosi <= SER_DFR;
                    tft_scl  <= 1'b0;
                end
                6'd41:begin
                    dq_rd[0] <= tft_miso;
                    tft_scl  <= 1'b1;
                    conv_cnt <= conv_cnt + 1'b1;
                end //接收转换数据结束
                6'd42:begin
                    tft_mosi <= PD[1];
                    tft_scl  <= 1'b0;
                end
                6'd43: tft_scl  <= 1'b1;
                6'd44:begin
                    tft_mosi <= PD[0];
                    tft_scl  <= 1'b0;
                end //发送下次转换控制字结束
                6'd45:begin
                    tft_scl  <= 1'b1;
                    conv_done<= 1'b1;
                end
            endcase
        end
        else
            conv_done <= 1'b0;
    end
    else begin
        conv_cnt  <=  'd0;
        conv_done <= 1'b0;
    end
end

//累加X通道的采样结果(conv_cnt[0]==1为X通道)
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tp_x_add <= 17'd0;
    else if(conv_en == 1'b0)
        tp_x_add <= 17'd0;
    else if(conv_done && conv_cnt[0])
        tp_x_add <= tp_x_add + dq_rd;
end

//采样X通道的最大值
always@(posedge clk) begin
    if(!conv_en)
        x_sap_max <= 12'd0;
    else if(conv_done && conv_cnt[0]) begin
        if(dq_rd > x_sap_max)
            x_sap_max <= dq_rd;
    end
end

//采样X通道的最小值
always@(posedge clk) begin
    if(!conv_en)
        x_sap_min <= 12'd4095;
    else if(conv_done && conv_cnt[0]) begin
        if(dq_rd < x_sap_min)
            x_sap_min <= dq_rd;
        else
            x_sap_min <= x_sap_min;
    end
end

//累加Y通道的采样结果
always@(posedge clk) begin
    if(!conv_en)
        tp_y_add <= 17'd0;
    else if(conv_done && (!conv_cnt[0]))
        tp_y_add <= tp_y_add + dq_rd;
end

//采样Y通道的最大值
always@(posedge clk) begin
    if(!conv_en)
        y_sap_max <= 12'd0;
    else if(conv_done && (~conv_cnt[0])) begin
        if(dq_rd > y_sap_max)
            y_sap_max <= dq_rd;
    end
end

//采样Y通道的最小值
always@(posedge clk) begin
    if(!conv_en)
        y_sap_min <= 12'd4095;
    else if(conv_done && (~conv_cnt[0])) begin
        if(dq_rd < y_sap_min)
            y_sap_min <= dq_rd;
    end
end

//数据处理标志
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        dq_handle_flag <= 1'b0;
    else if((conv_cnt == CONV_TIMES) && conv_done)
        dq_handle_flag <= 1'b1;
    else
        dq_handle_flag <= 1'b0;
end

//计算采样后的X均值，EX = （累加值 - 最大值 - 最小值）/ 8
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tp_x_ave <= 12'd0;
    else if(dq_handle_flag)
        tp_x_ave <= (tp_x_add - x_sap_max - x_sap_min) >> AVERAGE;
    else
        tp_x_ave <= tp_x_ave;
end

//计算采样后的Y均值，EY = （累加值 - 最大值 - 最小值）/ 8
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tp_y_ave <= 12'd0;
    else if(dq_handle_flag)
        tp_y_ave <= (tp_y_add - y_sap_max - y_sap_min) >> AVERAGE;
end

//寄存X的坐标
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tp_x_t <= 12'd0;
    else if(!dq_handle_flag)
        tp_x_t <= tp_x_ave;
end

//寄存Y的坐标
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tp_y_t <= 12'd0;
    else if(!dq_handle_flag)
        tp_y_t <= tp_y_ave;
end

endmodule
