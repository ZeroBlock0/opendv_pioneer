//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved	                               
//----------------------------------------------------------------------------------------
// File name:           vip_st_decode
// Last modified Date:  2018/1/30 11:12:36
// Last Version:        V1.1
// Descriptions:        VIP格式数据流 转换成 Avalon-ST数据流
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/1/29 10:55:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module vip_st_decode(
    input                   clk,
    input                   rst_n,
    
    input  [DATA_WIDTH-1:0] din_data,
    input                   din_valid,
    input                   din_startofpacket,
    input                   din_endofpacket,
    output                  din_ready,
        
    output      [15:0]      dout_data,
    output                  dout_valid,
    output                  dout_startofpacket,
    output                  dout_endofpacket,
    input                   dout_ready,
    
    output	reg [15:0]      im_width,
    output  reg [15:0]      im_height,
    output	reg [ 3:0]	    im_interlaced
);

//parameter define
parameter DATA_WIDTH    = 24;
parameter COLOR_BITS    = 8;
parameter COLOR_PLANES	= 3;

localparam	IDLE = 3'b001;
localparam	HEAD = 3'b010;
localparam	DATA = 3'b100;

reg	[2:0]   state;
reg [2:0]   n_state;

reg         dout_startofpacket_reg;
reg         din_ready_reg;
reg	[3:0]   head_cnt;

//*****************************************************
//**                    main code
//*****************************************************

assign dout_data            = {din_data[23:19],din_data[15:10],din_data[7:3]};
assign dout_valid           = (state==DATA) && din_valid;
assign dout_startofpacket	= dout_startofpacket_reg & din_valid;
assign dout_endofpacket		= (state==DATA) && din_endofpacket;
assign din_ready            = din_ready_reg | dout_ready;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		state <= IDLE;
	else
		state <= n_state;
end

always @(*) begin
	case(state)
        IDLE: begin
            if(din_valid & din_startofpacket) begin
                case(din_data[3:0])
                    4'hF:
                        n_state = HEAD;
                    3'h0:
                        n_state = DATA;
                    default:
                        n_state = IDLE;
                endcase
            end
            else
                n_state = IDLE;
        end
        HEAD,DATA: begin
            if(din_valid & din_endofpacket)
                n_state = IDLE;
            else
                n_state = state;
        end
        default:
            n_state = IDLE;
	endcase
end

always @(state or n_state) begin
    case(state)
        IDLE: 
            din_ready_reg = (n_state != DATA);
        HEAD: 
            din_ready_reg = 1'b1;
        DATA: 
            din_ready_reg = 1'b0;
        default: 
            din_ready_reg = 1'b1;
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		dout_startofpacket_reg <= 1'b0;
	else if(state==IDLE && n_state==DATA)
		dout_startofpacket_reg <= 1'b1;
	else if(dout_startofpacket)
		dout_startofpacket_reg <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		head_cnt <= 4'd0;
	else if(state==HEAD)
		head_cnt <= din_valid ? head_cnt + 4'd1 : head_cnt;
	else
		head_cnt <= 4'd0;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		im_width <= 16'd0;
		im_height <= 16'd0;
		im_interlaced <= 4'd0;
	end
	else if(state==HEAD && din_valid) begin
		case(COLOR_PLANES)
            1:begin
                case(head_cnt)
                4'd0:im_width[15:12] <= din_data[3:0];
                4'd1:im_width[11:8] <= din_data[3:0];
                4'd2:im_width[7:4] <= din_data[3:0];
                4'd3:im_width[3:0] <= din_data[3:0];
                4'd4:im_height[15:12] <= din_data[3:0];
                4'd5:im_height[11:8] <= din_data[3:0];
                4'd6:im_height[7:4] <= din_data[3:0];
                4'd7:im_height[3:0] <= din_data[3:0];
                4'd8:im_interlaced <= din_data[3:0];
                endcase
            end
            2:begin
                case(head_cnt)
                4'd0:im_width[15:8] <= {din_data[3:0],din_data[COLOR_BITS+3:COLOR_BITS]};
                4'd1:im_width[7:0] <= {din_data[3:0],din_data[COLOR_BITS+3:COLOR_BITS]};
                4'd2:im_height[15:8] <= {din_data[3:0],din_data[COLOR_BITS+3:COLOR_BITS]};
                4'd3:im_height[7:0] <= {din_data[3:0],din_data[COLOR_BITS+3:COLOR_BITS]};
                4'd4:im_interlaced <= din_data[3:0];
                endcase
            end
            3:begin
                case(head_cnt)
                4'd0:im_width[15:4] <= {din_data[3:0],din_data[COLOR_BITS+3:COLOR_BITS],din_data[COLOR_BITS*2+3:COLOR_BITS*2]};
                4'd1:{im_width[3:0],im_height[15:8]} <= {din_data[3:0],din_data[COLOR_BITS+3:COLOR_BITS],din_data[COLOR_BITS*2+3:COLOR_BITS*2]};
                4'd2:{im_height[7:0],im_interlaced} <= {din_data[3:0],din_data[COLOR_BITS+3:COLOR_BITS],din_data[COLOR_BITS*2+3:COLOR_BITS*2]};
                endcase
            end
		endcase
	end
end

endmodule 