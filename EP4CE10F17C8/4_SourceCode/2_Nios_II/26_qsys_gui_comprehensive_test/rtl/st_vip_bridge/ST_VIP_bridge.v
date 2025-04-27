//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ST_VIP_bridge
// Last modified Date:  2018/3/9 14:21:12
// Last Version:        V1.0
// Descriptions:        Avalon-ST数据流 转换成 VIP格式数据流
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/9 14:21:04
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ST_VIP_bridge(
    input                   clk,
    input                   rst_n,
    
    input  [15:0]           din_data,
    input                   din_valid,
    input                   din_startofpacket,
    input                   din_endofpacket,
    output                  din_ready,
    
    output [DATA_WIDTH-1:0] dout_data,
    output                  dout_valid,
    output                  dout_startofpacket,
    output                  dout_endofpacket,
    input                   dout_ready
);

//parameter define

//数据格式
parameter DATA_WIDTH        = 24;
parameter DATA_BITS         = 8; 
parameter DATA_PLANES	    = 3;        //symbols
//视频格式
parameter video_width       = 16'd800; 
parameter video_height		= 16'd480; 
parameter video_interlaced  = 4'b0010;  //progressive
//状态空间
localparam IDLE = 3'b001;
localparam CODE = 3'b010;
localparam DATA = 3'b100;

//reg define
reg [ 2:0]              state;
reg [ 2:0]              n_state;

reg [ 3:0]              cnt;

reg [15:0]				width;
reg [15:0]				height;
reg [ 3:0]              interlaced;
reg                     dout_ready_reg;
reg [DATA_WIDTH-1:0]    dout_data_reg;

//wire define

//VIP 控制包 包含一个ID nibble(半字节4'hF)和其他9个nibble
wire [DATA_BITS-1:0] ctrl_pack[9];

//*****************************************************
//**                    main code
//*****************************************************

//控制包 9个nibble 包含图像大小及交错格式等信息
assign ctrl_pack[0] = video_width[15:12];
assign ctrl_pack[1] = video_width[11:8];
assign ctrl_pack[2] = video_width[7:4];
assign ctrl_pack[3] = video_width[3:0];
assign ctrl_pack[4] = video_height[15:12];
assign ctrl_pack[5] = video_height[11:8];
assign ctrl_pack[6] = video_height[7:4];
assign ctrl_pack[7] = video_height[3:0];
assign ctrl_pack[8] = video_interlaced;

//将Avalon-ST转成VIP协议只需要在数据流前加入一帧控制包
assign din_ready            = (n_state != CODE) && dout_ready;
assign dout_data            = dout_data_reg;

assign dout_valid           = ((state == CODE) && dout_ready_reg) ||    //控制包: VIP "ready latency" 为1 
                              ((state == DATA) && din_valid);           //视频包
                              
assign dout_startofpacket   = (cnt == 4'd1) ||                          //控制包起始
                              ((DATA_PLANES == 1) && (cnt == 4'hB)) ||  //视频包起始
                              ((DATA_PLANES == 2) && (cnt == 4'h7)) || 
                              ((DATA_PLANES == 3) && (cnt == 4'h5));
                              
assign dout_endofpacket		= ((DATA_PLANES==1)&&(cnt==4'hA)) ||        //控制包结束
                              ((DATA_PLANES==2)&&(cnt==4'h6)) || 
                              ((DATA_PLANES==3)&&(cnt==4'h4)) ||
                              (din_endofpacket & din_valid) ;           //视频包结束

//状态机_状态跳转
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
		state <= IDLE;
	else
		state <= n_state;
end

//状态机_指定下个状态
always @(*) begin
	case(state)
        IDLE:
            n_state = (din_startofpacket & din_valid) ? CODE : IDLE;
        CODE: begin
            case(DATA_PLANES)
                1: n_state = ((cnt==4'hC) && dout_ready_reg) ? DATA : CODE;
                2: n_state = ((cnt==4'h8) && dout_ready_reg) ? DATA : CODE;
                3: n_state = ((cnt==4'h6) && dout_ready_reg) ? DATA : CODE;
            endcase
        end
        DATA: 
            n_state = (din_endofpacket & din_valid) ? IDLE : DATA;
        default: 
            n_state = IDLE;
	endcase
end

//将 dout_ready 打一拍
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		dout_ready_reg <= 1'b0;
	else
		dout_ready_reg <= dout_ready;
end

//对控制包发送过程计数
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cnt <= 4'd0;
	else if(n_state == CODE)
		cnt <= dout_ready_reg ? (cnt + 4'd1) : cnt;
	else
		cnt <= 4'd0;
end

//VIP 输出的数据
always @(*) begin
	if(state == CODE) begin
        case(DATA_PLANES)
			1: begin
				case(cnt)
                    4'h1:   dout_data_reg = 'hF;            //控制包 ID 为 4'hF
                    4'h2:   dout_data_reg = ctrl_pack[0];
                    4'h3:   dout_data_reg = ctrl_pack[1];
                    4'h4:   dout_data_reg = ctrl_pack[2];
                    4'h5:   dout_data_reg = ctrl_pack[3];
                    4'h6:   dout_data_reg = ctrl_pack[4];
                    4'h7:   dout_data_reg = ctrl_pack[5];
                    4'h8:   dout_data_reg = ctrl_pack[6];
                    4'h9:   dout_data_reg = ctrl_pack[7];
                    4'hA:   dout_data_reg = ctrl_pack[8];
                    4'hB:   dout_data_reg = 'h0;            //视频包 ID 为 4'h0
                    4'hC:   dout_data_reg = din_data;
                    default:
                            dout_data_reg = din_data;
				endcase
			end
			2: begin
				case(cnt)
                    4'h1:   dout_data_reg = 'hF;            //控制包 ID 为 4'hF
                    4'h2:   dout_data_reg = {ctrl_pack[1],ctrl_pack[0]};
                    4'h3:   dout_data_reg = {ctrl_pack[3],ctrl_pack[2]};
                    4'h4:   dout_data_reg = {ctrl_pack[5],ctrl_pack[4]};
                    4'h5:   dout_data_reg = {ctrl_pack[7],ctrl_pack[6]};
                    4'h6:   dout_data_reg = ctrl_pack[8];
                    4'h7:   dout_data_reg = 'h0;            //视频包 ID 为 4'h0
                    4'h8:   dout_data_reg = din_data;
                    default:
                            dout_data_reg = din_data;
				endcase
			end
			3:begin
				case(cnt)
                    4'h1:   dout_data_reg = 'hF;            //控制包 ID 为 4'hF
                    4'h2:   dout_data_reg = {ctrl_pack[2],ctrl_pack[1],ctrl_pack[0]};
                    4'h3:   dout_data_reg = {ctrl_pack[5],ctrl_pack[4],ctrl_pack[3]};
                    4'h4:   dout_data_reg = {ctrl_pack[8],ctrl_pack[7],ctrl_pack[6]};
                    4'h5:   dout_data_reg = 'h0;            //视频包 ID 为 4'h0
                    4'h6:   dout_data_reg = {din_data[15:11],3'b111,din_data[10:5],2'b11,din_data[4:0],3'b111};
                    default:
                            dout_data_reg = {din_data[15:11],3'b111,din_data[10:5],2'b11,din_data[4:0],3'b111};
				endcase
			end
			default:
                dout_data_reg = {din_data[15:11],3'b111,din_data[10:5],2'b11,din_data[4:0],3'b111};
        endcase
    end
	else
		dout_data_reg = {din_data[15:11],3'b111,din_data[10:5],2'b11,din_data[4:0],3'b111};
end

endmodule 