//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           gt9147_ctrl
// Last modified Date:  2018/08/20 13:20:51
// Last Version:        V1.0
// Descriptions:        gt9147的驱动模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/20 13:20:57
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module gt9147_ctrl #(parameter   WIDTH = 4'd8)    // 一次读写寄存器的个数的位宽)
(
    //module clock
    input                       sys_clk   , //系统时钟
    input                       clk       , // 时钟信号
    input                       rst_n     , // 复位信号（低有效）
    input                       cfg_done  , // WM8978配置完成标志
    output   reg                tft_tcs   , // 触摸屏片选
    inout                       tft_int   , // 触摸屏中断
            
    //I2C interface
    input                       i2c_done  , // i2c操作结束标志
    input                       once_done , // 一次读写操作完成
    output   reg                i2c_exec  , // i2c触发控制
    output   reg                i2c_rh_wl , // i2c读写控制
    output   reg [15:0]         i2c_addr  , // i2c操作地址
    output   reg [ 7:0]         i2c_data_w, // i2c写入的数据
    input        [ 7:0]         i2c_data_r, // i2c读出的数据
    output   reg [WIDTH-1'b1:0] reg_num   , // 一次读写寄存器的个数
            
    //touch lcd interface
    output   reg [ 2:0]         tp_num,     // 触摸点数
    output   reg [31:0]         tp1_xy,     // 第1个触摸点的坐标
    output   reg [31:0]         tp2_xy,     // 第2个触摸点的坐标
    output   reg [31:0]         tp3_xy,     // 第3个触摸点的坐标
    output   reg [31:0]         tp4_xy,     // 第4个触摸点的坐标
    output   reg [31:0]         tp5_xy,     // 第5个触摸点的坐标
    //user interface
    output   reg                cfg_switch, // 配置切换信号
    output   reg                touch_done, // 读取触摸点坐标完成脉冲信号
    output   reg                touch_valid, // 连续触摸标志

    //Avalon 端口
    input      [ 2:0]           avl_address,      //地址
    input                       avl_write,        //写请求
    input      [31:0]           avl_writedata,    //写数据
    input                       avl_read,         //读请求
    output reg [31:0]           avl_readdata      //读数据
);

localparam PID_REG      = 16'h8140;	 // 产品id寄存器地址
localparam CTRL_REG     = 16'h8040;  // 控制寄存器地址
localparam GTCH_REG     = 16'h814e;	 // 检测到的当前触摸情况
localparam TP1_REG      = 16'h8150;	 // 第一个触摸点数据地址
localparam TP2_REG      = 16'h8158;	 // 第二个触摸点数据地址
localparam TP3_REG      = 16'h8160;	 // 第三个触摸点数据地址
localparam TP4_REG      = 16'h8168;	 // 第四个触摸点数据地址
localparam TP5_REG      = 16'h8170;  // 第五个触摸点数据地址
localparam GESTURE_REG  = 16'h814b;
localparam GESTURE_POINT= 16'h814c;

localparam init         = 4'd0;      // 上电初始化
localparam get_id       = 4'd1;      // 获取ID
localparam cfg_state    = 4'd2;      // 配置状态
localparam chk_touch    = 4'd3;      // 检测触摸状态
localparam change_addr  = 4'd4;      // 改变触摸点坐标寄存器地址
localparam getpos_xy    = 4'd5;      // 获取触摸点坐标
localparam tp_xy        = 4'd6;      // 触摸点坐标

//reg define
reg    [15:0]		id         ;     // 控制器的ID
reg    [ 2:0]       tp_num_t   ;     // 读取触摸点数
reg    [15:0]       reg_addr   ;     // 触摸点坐标寄存器
reg    [15:0]       tp_x       ;     // 触摸点X坐标
reg    [15:0]       tp_y       ;     // 触摸点X坐标
reg                 cnt_1us_en ;     // 使能计时
reg    [19:0]       cnt_1us_cnt;     // 4us计时
reg    [ 3:0]       cur_state/*synthesis preserve*/;     // 
reg    [ 3:0]       next_state ;     // 
reg    [ 2:0]       flow_cnt   ;     // 
reg                 st_done    ;     // 
reg                 int_dir    ;     // 
reg                 int_out    ;     // 

reg  [19:0]   cunt ;
reg           flag;
reg  [8:0]     touch_cnt;

//wire define
///*synthesis preserve*/;

//*****************************************************
//**                    main code
//*****************************************************

assign tft_int = int_dir ? int_out : 1'bz;
//assign int_in = tft_int;

//avalon 端口读操作
always@(posedge sys_clk or negedge rst_n) begin
    if(!rst_n) 
        avl_readdata <= 32'd0;
	else begin
        if(avl_read) begin    //读操作
            case(avl_address)
                3'd0: avl_readdata <= {29'd0,tp_num};
                3'd1: avl_readdata <= tp1_xy;
                3'd2: avl_readdata <= tp2_xy;
                3'd3: avl_readdata <= tp3_xy;
                3'd4: avl_readdata <= tp4_xy;
                3'd5: avl_readdata <= tp5_xy;
                default:;
            endcase
        end
	end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
       cnt_1us_cnt <= 20'd0;
    end
    else if(cnt_1us_en)
      cnt_1us_cnt <= cnt_1us_cnt + 1'b1;
    else
      cnt_1us_cnt <= 'd0;
end
  
//读取坐标后输出脉冲
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        touch_done <= 1'b0;
    end
    else if(tp_num && tp_num_t == tp_num)
        touch_done <= 1'b1;
    else
        touch_done <= 1'b0;
end

//状态跳转
always @ (posedge clk or negedge rst_n) begin
    if(!rst_n)
        cur_state <= init;
    else
        cur_state <= next_state;
end

//组合逻辑状态判断转换条件
always @( * ) begin
    case(cur_state)
        init: begin
            if(st_done)
                next_state = chk_touch;
            else
                next_state = init;
        end
        //GT9147无需配置参数
        /*
        get_id: begin
            if(st_done)
                next_state = cfg_state;
            else
                next_state =get_id;
        end
        cfg_state: begin
            if(st_done) begin
                next_state = chk_touch;
            end 
            else
                next_state = cfg_state;
        end
        */
        chk_touch: begin
            if(st_done)
                next_state = change_addr;
            else
                next_state = chk_touch;
        end
        change_addr: begin
            if(st_done)
                next_state = getpos_xy;
            else
                next_state = change_addr;
        end
        getpos_xy: begin
            if(st_done)
                next_state = tp_xy;
            else
                next_state = getpos_xy;
        end
        tp_xy: begin
            if(st_done) begin
                if(tp_num_t == tp_num)
                    next_state = chk_touch;
                else
                    next_state = change_addr;
            end
            else
                next_state = tp_xy;
        end
        default: next_state = init;
    endcase
end

always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            touch_valid    <= 1'b0;
            flow_cnt     <=  3'b0;
            st_done      <=  1'b0;
            cnt_1us_en   <=  1'b1;
            i2c_exec     <=  1'b0;
            tft_tcs      <=  1'b0;
            int_dir      <=  1'b0;
            int_out      <=  1'b0;
            i2c_addr     <= 16'b0;
            i2c_data_w   <=  8'd0;
            i2c_rh_wl    <=  1'd0;
            reg_num      <=   'd0;
            cfg_switch   <=  1'd0;
            tp_num       <=  3'b0;
            tp_num_t     <=  3'd0;
            reg_addr     <= 16'd0;
            tp_x         <= 16'd0;
            tp_y         <= 16'd0;
            tp1_xy       <= 32'd0;
            tp2_xy       <= 32'd0;
            tp3_xy       <= 32'd0;
            tp4_xy       <= 32'd0;
            tp5_xy       <= 32'd0;
        end
        else begin
            i2c_exec <= 1'b0;
            st_done <= 1'b0;
            case(next_state)
                init: begin
                    case(flow_cnt)
                        'd0: begin
                            flow_cnt <= flow_cnt + 1'b1;
                            int_dir <= 1'b1;
                            int_out <= 1'b1;                                   
                        end
                        'd1: begin
                            cnt_1us_en <= 1'b1;
                            if(cnt_1us_cnt <= 20000) begin  // 延时20ms
                                tft_tcs <= 1'b0;
                            end
                            else begin
                                tft_tcs <= 1'b1;
                                cnt_1us_en <= 1'b0;
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd2 : begin
                            cnt_1us_en <= 1'b1;
                            if(cnt_1us_cnt == 10000) begin        // 延时10ms设置IIC地址
                                int_dir <= 1'b0;
                            end    
                            else if(cnt_1us_cnt == 100000) begin  //延时100ms
                                cnt_1us_en <= 1'b0;
                                st_done <= 1'b1;
                                int_dir <= 1'b0;
                                flow_cnt <= 'd0;
                            end
                        end
                        default : ;
                    endcase
                end
                /*
                get_id: begin
                    case(flow_cnt)
                        'd0 : begin
                            i2c_exec <= 1'b1;
                            i2c_addr <= PID_REG;
                            reg_num <=  'd4;
                            i2c_rh_wl<= 1'b1;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd1 : begin
                            if(i2c_done) begin
                                flow_cnt <= 'd0;
                                st_done <= 1'b1;
                            end
                        end
                        default : ;
                    endcase
                end
                cfg_state: begin
                    case(flow_cnt)
                        'd0 : begin
                            i2c_exec <= 1'b1;
                            i2c_addr <= CTRL_REG;
                            i2c_data_w<= 8'h02;
                            reg_num   <=  'd1;
                            i2c_rh_wl <= 1'b0;
                            flow_cnt  <= flow_cnt + 1'b1;
                        end
                        'd1 : begin
                            if(i2c_done)
                                flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd2 : begin
                            i2c_exec <= 1'b1;
                            i2c_addr <= CTRL_REG;
                            i2c_data_w <= 8'h0;
                            i2c_rh_wl <= 1'b0;
                            reg_num   <=  'd1;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd3 : begin
                            if(i2c_done) begin
                                flow_cnt <= flow_cnt + 1'b1;
                                cfg_switch <= 1'b1;
                            end
                        end
                        'd4: begin
                            if(cfg_done) begin
                                cfg_switch <= 1'b0;
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd5 : begin
                            if(i2c_done) begin
                                st_done <= 1'b1;
                                flow_cnt <= 'd0;
                            end
                        end                      
                        default : ;
                    endcase
                end
                */
                chk_touch: begin	// 检测触摸状态
                    case(flow_cnt)
                        'd0: begin
                            tp_num_t <= 3'd0;
                            tp_num   <= 3'd0;
                            cnt_1us_en <= 1'b1;
                            if(cnt_1us_cnt == 17000)         //模块驱动时钟周期为62ns（频率为I2C时钟的4倍，400Kbps*4）
                                flow_cnt <= flow_cnt + 1'b1; //此处每隔62ns*17000采样一次，即LCD每隔1.054ms更新一次坐标 
                        end
                        'd1: begin //'d2
                            cnt_1us_en <= 1'b0;
                            i2c_exec <= 1'b1;
                            i2c_addr <= GTCH_REG;
                            i2c_rh_wl<= 1'b1;
                            reg_num  <=  'd1;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd2: begin
                            if(i2c_done)
                              flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd3: begin
                            if(i2c_data_r[7]== 1'b1 & i2c_data_r[3:0] != 4'd0) begin
                                flow_cnt <= flow_cnt + 1'b1;
                                //touch_valid<= 1'b1;           //i2c_data_r[4];
                                tp_num   <= i2c_data_r[2:0];
                            end
                            else begin
                                touch_valid<= 1'b0;           //i2c_data_r[4];
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd4: begin
                            i2c_exec <= 1'b1;
                            i2c_addr <= GTCH_REG;
                            i2c_rh_wl<= 1'b0;
                            i2c_data_w<= 8'd0;
                            reg_num  <=  'd1;
                            flow_cnt <= flow_cnt + 1'b1;    
                        end
                        'd5: begin
                            if(i2c_done) begin
                                if(tp_num)
                                    st_done <= 1'b1;
                                flow_cnt <= 'd0;
                            end
                        end
                        default : ;
                    endcase
                end // case: touch_statue
                change_addr: begin
                    if(tp_num_t < tp_num) begin
                        case(tp_num_t)
                            'd0 : begin
                                reg_addr <= TP1_REG;
                                st_done <= 1'b1;
                            end
                            'd1 : begin
                                reg_addr <= TP2_REG;
                                st_done <= 1'b1;
                            end
                            'd2 : begin
                                reg_addr <= TP3_REG;
                                st_done <= 1'b1;
                            end
                            'd3 : begin
                                reg_addr <= TP4_REG;
                                st_done <= 1'b1;
                            end
                            'd4 : begin
                                reg_addr <= TP5_REG;
                                st_done <= 1'b1;
                            end
                            default : ;
                        endcase
                    end
                    else begin
                        st_done <= 1'b1;
                    end
                end
                getpos_xy: begin
                    case(flow_cnt)
                        'd0 : begin
                            i2c_exec <= 1'b1;
                            i2c_rh_wl<= 1'b1;
                            i2c_addr <= reg_addr;
                            reg_num  <= 'd4;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd1 : begin
                            if(once_done) begin
                                tp_x[7:0] <= i2c_data_r;
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd2 : begin
                            if(once_done) begin
                                tp_x[15:8] <= i2c_data_r;
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd3 : begin
                            if(once_done) begin
                                tp_y[7:0] <= i2c_data_r;
                                flow_cnt <= flow_cnt + 1'b1;
                             end
                        end
                        'd4 : begin
                            if(i2c_done) begin
                                tp_y[15:8] <= i2c_data_r;
                                st_done <= 1'b1;
                                flow_cnt <= 'd0;
                            end
                        end
                        default : ;
                    endcase
                end
                tp_xy: begin
                    case(tp_num_t)                   
                        'd0: begin
                            touch_valid<= 1'b1;         //注意！该语句放在此处仅支持在NIOS中单点画图！
                            tp1_xy <= {tp_x,tp_y};
                            st_done <= 1'b1;
                            tp_num_t <= tp_num_t + 1'b1;
                        end
                        'd1 : begin
                            tp2_xy <= {tp_x,tp_y};
                            st_done <= 1'b1;
                            tp_num_t <= tp_num_t + 1'b1;
                        end
                        'd2: begin
                            tp3_xy <= {tp_x,tp_y};
                            st_done <= 1'b1;
                            tp_num_t <= tp_num_t + 1'b1;
                        end
                        'd3: begin
                            tp4_xy <= {tp_x,tp_y};
                            st_done <= 1'b1;
                            tp_num_t <= tp_num_t + 1'b1;
                        end
                        'd4: begin
                            tp5_xy <= {tp_x,tp_y};
                            st_done <= 1'b1;
                            tp_num_t <= tp_num_t + 1'b1;
                        end
                        default : ;
                    endcase
                end
                default : ;
            endcase
        end
end

endmodule 