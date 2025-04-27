//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           i2c_reg_cfg
// Last modified Date:  2018/3/22 15:38:09
// Last Version:        V1.0
// Descriptions:        用于配置I2C器件寄存器（一般用于多寄存器配置）
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/22 15:38:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
`timescale  1ns/1ns
module i2c_reg_cfg #(parameter WIDTH = 4'd8
)(
    input                        clk       ,            // i2c_reg_cfg驱动时钟(一般取1MHz)
    input                        rst_n     ,            // 复位信号
    input                        once_done ,            // I2C一次操作完成反馈信号
           
    output  reg                  i2c_exec  ,            // I2C触发执行信号
    output  reg                  i2c_rh_wl ,            // I2C读写控制信号
    output  reg  [15:0]          i2c_addr  ,            // 寄存器地址
    output  reg  [ 7:0]          i2c_data  ,            // 寄存器数据
    output  reg                  cfg_done  ,            // WM8978配置完成
           
    //user interface           
    input                        cfg_switch,           // 配置切换
    output  reg  [WIDTH-1'b1:0]  reg_num  
);

//parameter define
localparam     MODE    = 8'h1  ;                //0X8100用于控制是否将配置保存在本地，写 0，则不保存配置，写 1 则保存配置。
localparam    REG_NUM = 8'd186;                // 总共需要配置的寄存器个数
//GT9147 部分寄存器定义
localparam    GT_CTRL_REG  = 16'h8040;          // GT9147控制寄存器
localparam    GT_CFGS_REG  = 16'h8047;          // GT9147配置起始地址寄存器
localparam    GT_CHECK_REG = 16'h80FF;          // GT9147校验和寄存器

//reg define
reg    [8:0]  start_init_cnt;                  // 初始化时间计数
reg    [7:0]  init_reg_cnt  ;                  // 寄存器配置个数计数器
reg    [7:0]  sum_t1;                          // 计算校验和

//wire define
wire   [7:0]  sum_t2;                          // 计算校验和

//*****************************************************
//**                    main code
//*****************************************************

//计算校验和
assign sum_t2 = init_reg_cnt == REG_NUM - 'd3 ? (~sum_t1 + 1'd1) : sum_t2;

//I2C写间隔控制（第1个和第2个寄存器配置时延时一段时间）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        start_init_cnt <= 9'b0;
    end
    else if(cfg_switch) begin
        if(start_init_cnt < 9'h2) 
            start_init_cnt <= start_init_cnt + 1'b1;
    end
end

// 触发I2C操作控制
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        i2c_exec <= 1'b0;
    else if(cfg_switch) begin
        if(start_init_cnt == 9'h1)
            i2c_exec <= 1'b1;
        // else if(once_done & (init_reg_cnt != 5'd1) & (init_reg_cnt < REG_NUM))
            // i2c_exec <= 1'b1;
        else
            i2c_exec <= 1'b0;
    end
end

//配置寄存器个数计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        init_reg_cnt <= 8'd0;
    end
    else if(cfg_switch & once_done)
        init_reg_cnt <= init_reg_cnt + 1'b1;
end

//寄存器配置完成信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cfg_done <= 1'b0;
    else if(init_reg_cnt == REG_NUM)
        cfg_done <= 1'b1;
end

//计算校验和
always @(*) begin
    if(!rst_n)
        sum_t1 = 8'h0;
    else if(once_done & (init_reg_cnt <= REG_NUM - 'd3))
        sum_t1 = sum_t1 + i2c_data;
    else
        sum_t1 = sum_t1;
end

//配置I2C器件内寄存器地址及其数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i2c_addr <= 16'd0;
        i2c_data <=  8'd0;
        i2c_rh_wl<=  1'b0;
    end
    else begin
        i2c_rh_wl<= 1'b1;
        i2c_addr <= GT_CFGS_REG;
        reg_num  <= REG_NUM;
        case(init_reg_cnt)
            8'd0  : i2c_data <= 8'h60;
            8'd1  : i2c_data <= 8'hE0;
            8'd2  : i2c_data <= 8'h01;
            8'd3  : i2c_data <= 8'h20;
            8'd4  : i2c_data <= 8'h03;
            8'd5  : i2c_data <= 8'h05;
            8'd6  : i2c_data <= 8'h35;
            8'd7  : i2c_data <= 8'h00;
            8'd8  : i2c_data <= 8'h02;
            8'd9  : i2c_data <= 8'h08;
            8'd10 : i2c_data <= 8'h1E;
            8'd11 : i2c_data <= 8'h08;
            8'd12 : i2c_data <= 8'h50;
            8'd13 : i2c_data <= 8'h3C;
            8'd14 : i2c_data <= 8'h0F;
            8'd15 : i2c_data <= 8'h05;
            8'd16 : i2c_data <= 8'h00;
            8'd17 : i2c_data <= 8'h00;
            8'd18 : i2c_data <= 8'hFF;
            8'd19 : i2c_data <= 8'h67;
            8'd20 : i2c_data <= 8'h50;
            8'd21 : i2c_data <= 8'h00;
            8'd22 : i2c_data <= 8'h00;
            8'd23 : i2c_data <= 8'h18;
            8'd24 : i2c_data <= 8'h1A;
            8'd25 : i2c_data <= 8'h1E;
            8'd26 : i2c_data <= 8'h14;
            8'd27 : i2c_data <= 8'h89;
            8'd28 : i2c_data <= 8'h28;
            8'd29 : i2c_data <= 8'h0A;
            8'd30 : i2c_data <= 8'h30;
            8'd31 : i2c_data <= 8'h2E;
            8'd32 : i2c_data <= 8'hBB;
            8'd33 : i2c_data <= 8'h0A;
            8'd34 : i2c_data <= 8'h03;
            8'd35 : i2c_data <= 8'h00;
            8'd36 : i2c_data <= 8'h00;
            8'd37 : i2c_data <= 8'h02;
            8'd38 : i2c_data <= 8'h33;
            8'd39 : i2c_data <= 8'h1D;
            8'd40 : i2c_data <= 8'h00;
            8'd41 : i2c_data <= 8'h00;
            8'd42 : i2c_data <= 8'h00;
            8'd43 : i2c_data <= 8'h00;
            8'd44 : i2c_data <= 8'h00;
            8'd45 : i2c_data <= 8'h00;
            8'd46 : i2c_data <= 8'h00;
            8'd47 : i2c_data <= 8'h32;
            8'd48 : i2c_data <= 8'h00;
            8'd49 : i2c_data <= 8'h00;
            8'd50 : i2c_data <= 8'h2A;
            8'd51 : i2c_data <= 8'h1C;
            8'd52 : i2c_data <= 8'h5A;
            8'd53 : i2c_data <= 8'h94;
            8'd54 : i2c_data <= 8'hC5;
            8'd55 : i2c_data <= 8'h02;
            8'd56 : i2c_data <= 8'h07;
            8'd57 : i2c_data <= 8'h00;
            8'd58 : i2c_data <= 8'h00;
            8'd59 : i2c_data <= 8'h00;
            8'd60 : i2c_data <= 8'hB5;
            8'd61 : i2c_data <= 8'h1F;
            8'd62 : i2c_data <= 8'h00;
            8'd63 : i2c_data <= 8'h90;
            8'd64 : i2c_data <= 8'h28;
            8'd65 : i2c_data <= 8'h00;
            8'd66 : i2c_data <= 8'h77;
            8'd67 : i2c_data <= 8'h32;
            8'd68 : i2c_data <= 8'h00;
            8'd69 : i2c_data <= 8'h62;
            8'd70 : i2c_data <= 8'h3F;
            8'd71 : i2c_data <= 8'h00;
            8'd72 : i2c_data <= 8'h52;
            8'd73 : i2c_data <= 8'h50;
            8'd74 : i2c_data <= 8'h00;
            8'd75 : i2c_data <= 8'h52;
            8'd76 : i2c_data <= 8'h00;
            8'd77 : i2c_data <= 8'h00;
            8'd78 : i2c_data <= 8'h00;
            8'd79 : i2c_data <= 8'h00;
            8'd80 : i2c_data <= 8'h00;
            8'd81 : i2c_data <= 8'h00;
            8'd82 : i2c_data <= 8'h00;
            8'd83 : i2c_data <= 8'h00;
            8'd84 : i2c_data <= 8'h00;
            8'd85 : i2c_data <= 8'h00;
            8'd86 : i2c_data <= 8'h00;
            8'd87 : i2c_data <= 8'h00;
            8'd88 : i2c_data <= 8'h00;
            8'd89 : i2c_data <= 8'h00;
            8'd90 : i2c_data <= 8'h00;
            8'd91 : i2c_data <= 8'h00;
            8'd92 : i2c_data <= 8'h00;
            8'd93 : i2c_data <= 8'h00;
            8'd94 : i2c_data <= 8'h00;
            8'd95 : i2c_data <= 8'h00;
            8'd96 : i2c_data <= 8'h00;
            8'd97 : i2c_data <= 8'h00;
            8'd98 : i2c_data <= 8'h00;
            8'd99 : i2c_data <= 8'h0F;
            8'd100: i2c_data <= 8'h0F;
            8'd101: i2c_data <= 8'h03;
            8'd102: i2c_data <= 8'h06;
            8'd103: i2c_data <= 8'h10;
            8'd104: i2c_data <= 8'h42;
            8'd105: i2c_data <= 8'hF8;
            8'd106: i2c_data <= 8'h0F;
            8'd107: i2c_data <= 8'h14;
            8'd108: i2c_data <= 8'h00;
            8'd109: i2c_data <= 8'h00;
            8'd110: i2c_data <= 8'h00;
            8'd111: i2c_data <= 8'h00;
            8'd112: i2c_data <= 8'h1A;
            8'd113: i2c_data <= 8'h18;
            8'd114: i2c_data <= 8'h16;
            8'd115: i2c_data <= 8'h14;
            8'd116: i2c_data <= 8'h12;
            8'd117: i2c_data <= 8'h10;
            8'd118: i2c_data <= 8'h0E;
            8'd119: i2c_data <= 8'h0C;
            8'd120: i2c_data <= 8'h0A;
            8'd121: i2c_data <= 8'h08;
            8'd122: i2c_data <= 8'h00;
            8'd123: i2c_data <= 8'h00;
            8'd124: i2c_data <= 8'h00;
            8'd125: i2c_data <= 8'h00;
            8'd126: i2c_data <= 8'h00;
            8'd127: i2c_data <= 8'h00;
            8'd128: i2c_data <= 8'h00;
            8'd129: i2c_data <= 8'h00;
            8'd130: i2c_data <= 8'h00;
            8'd131: i2c_data <= 8'h00;
            8'd132: i2c_data <= 8'h00;
            8'd133: i2c_data <= 8'h00;
            8'd134: i2c_data <= 8'h00;
            8'd135: i2c_data <= 8'h00;
            8'd136: i2c_data <= 8'h00;
            8'd137: i2c_data <= 8'h00;
            8'd138: i2c_data <= 8'h00;
            8'd139: i2c_data <= 8'h00;
            8'd140: i2c_data <= 8'h00;
            8'd141: i2c_data <= 8'h00;
            8'd142: i2c_data <= 8'h29;
            8'd143: i2c_data <= 8'h28;
            8'd144: i2c_data <= 8'h24;
            8'd145: i2c_data <= 8'h22;
            8'd146: i2c_data <= 8'h20;
            8'd147: i2c_data <= 8'h1F;
            8'd148: i2c_data <= 8'h1E;
            8'd149: i2c_data <= 8'h1D;
            8'd150: i2c_data <= 8'h0E;
            8'd151: i2c_data <= 8'h0C;
            8'd152: i2c_data <= 8'h0A;
            8'd153: i2c_data <= 8'h08;
            8'd154: i2c_data <= 8'h06;
            8'd155: i2c_data <= 8'h05;
            8'd156: i2c_data <= 8'h04;
            8'd157: i2c_data <= 8'h02;
            8'd158: i2c_data <= 8'h00;
            8'd159: i2c_data <= 8'hFF;
            8'd160: i2c_data <= 8'h00;
            8'd161: i2c_data <= 8'h00;
            8'd162: i2c_data <= 8'h00;
            8'd163: i2c_data <= 8'h00;
            8'd164: i2c_data <= 8'h00;
            8'd165: i2c_data <= 8'h00;
            8'd166: i2c_data <= 8'h00;
            8'd167: i2c_data <= 8'h00;
            8'd168: i2c_data <= 8'h00;
            8'd169: i2c_data <= 8'h00;
            8'd170: i2c_data <= 8'h00;
            8'd171: i2c_data <= 8'hFF;
            8'd172: i2c_data <= 8'hFF;
            8'd173: i2c_data <= 8'hFF;
            8'd174: i2c_data <= 8'hFF;
            8'd175: i2c_data <= 8'hFF;
            8'd176: i2c_data <= 8'hFF;
            8'd177: i2c_data <= 8'hFF;
            8'd178: i2c_data <= 8'hFF;
            8'd179: i2c_data <= 8'hFF;
            8'd180: i2c_data <= 8'hFF;
            8'd181: i2c_data <= 8'hFF;
            8'd182: i2c_data <= 8'hFF;
            8'd183: i2c_data <= 8'hFF;
            8'd184: i2c_data <= sum_t2;
            8'd185: i2c_data <= MODE ;
            default : ;
        endcase
    end
end

endmodule