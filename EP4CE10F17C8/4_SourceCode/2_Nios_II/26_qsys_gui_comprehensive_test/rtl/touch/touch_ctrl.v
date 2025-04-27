//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           touch_ctrl
// Last modified Date:  2018/08/20 13:20:51
// Last Version:        V1.0
// Descriptions:        gt9147和gt9271的驱动模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/08/20 13:20:57
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module touch_ctrl #(parameter   WIDTH = 4'd8)    // 一次读写寄存器的个数的位宽)
(
    //module clock
    input                       sys_clk   , // 系统时钟
    input                       clk       , // 时钟信号
    input                       rst_n     , // 复位信号（低有效）
    input                       cfg_done  , // 配置完成标志
    output   reg                tft_tcs   , // 触摸屏片选
    inout                       tft_int   , // 触摸屏中断
            
    //I2C interface
    input                       ack       ,
    input                       i2c_done  , // i2c操作结束标志
    input                       once_done , // 一次读写操作完成
    output   reg                i2c_exec  , // i2c触发控制
    output   reg                i2c_rh_wl , // i2c读写控制
    output   reg [15:0]         i2c_addr  , // i2c操作地址
    output   reg [ 7:0]         i2c_data_w, // i2c写入的数据
    input        [ 7:0]         i2c_data_r, // i2c读出的数据
    output   reg                bit_ctrl  ,
    output   reg [WIDTH-1'b1:0] reg_num   , // 一次读写寄存器的个数
            
    //touch lcd interface
    output   reg [ 2:0]         tp_num    , // 触摸点数
    output   reg [31:0]         tp1_xy    , // 第1个触摸点的坐标
    output   reg [31:0]         tp2_xy    , // 第2个触摸点的坐标
    output   reg [31:0]         tp3_xy    , // 第3个触摸点的坐标
    output   reg [31:0]         tp4_xy    , // 第4个触摸点的坐标
    output   reg [31:0]         tp5_xy    , // 第5个触摸点的坐标
    //user interface
    output   reg                cfg_switch, // 配置切换信号
    output   reg                touch_done, // 读取触摸点坐标完成脉冲信号
    output   reg                touch_valid, // 连续触摸标志
    input                       bigger_en,
    input                       lcd_init_done,
    input        [15:0]         lcd_id   
    //Avalon 端口
//    input      [ 2:0]           avl_address,      //地址
//    input                       avl_write,        //写请求
//    input      [31:0]           avl_writedata,    //写数据
//    input                       avl_read,         //读请求
//    output reg [31:0]           avl_readdata      //读数据
);

localparam PID_REG      = 16'h8140;	 // 产品id寄存器地址
//localparam CTRL_REG     = 16'h8040;  // 控制寄存器地址
//localparam GTCH_REG     = 16'h814e;  // 检测到的当前触摸情况
//localparam TP1_REG      = 16'h8150;  // 第一个触摸点数据地址
//localparam TP2_REG      = 16'h8158;  // 第二个触摸点数据地址
//localparam TP3_REG      = 16'h8160;  // 第三个触摸点数据地址
//localparam TP4_REG      = 16'h8168;  // 第四个触摸点数据地址
//localparam TP5_REG      = 16'h8170;  // 第五个触摸点数据地址
//以下五点仅支持10.1'触摸屏
localparam TP6_REG      = 16'h8178;  // 第六个触摸点数据地址
localparam TP7_REG      = 16'h8180;  // 第七个触摸点数据地址
localparam TP8_REG      = 16'h8188;  // 第八个触摸点数据地址
localparam TP9_REG      = 16'h8190;  // 第九个触摸点数据地址
localparam TP10_REG     = 16'h8198;  // 第十个触摸点数据地址
//FT5206
localparam FT_ID_G_LIB_VERSION = 8'hA1;		//版本
localparam FT_ID_G_MODE        = 8'hA4;     //FT5206中断模式控制寄存器
localparam FT_ID_G_THGROUP	   = 8'h80;     //触摸有效值设置寄存器
localparam FT_ID_G_PERIODACTIVE= 8'h88;     //激活状态周期设置寄存器

localparam init         = 4'd0;      // 上电初始化
localparam get_id       = 4'd1;      // 获取ID
localparam cfg_state    = 4'd2;      // 配置状态
localparam chk_touch    = 4'd3;      // 检测触摸状态
localparam change_addr  = 4'd4;      // 改变触摸点坐标寄存器地址
localparam getpos_xy    = 4'd5;      // 获取触摸点坐标
localparam id_handle    = 4'd6;      // 针对不对尺寸的触摸的坐标数据进行处理
localparam tp_xy        = 4'd7;      // 触摸点坐标

//reg define
reg    [15:0]		touch_id   ;     // 触摸屏控制器的ID
reg    [ 7:0]		touch_id_t ;
reg    [ 2:0]       tp_num_t   ;     // 读取触摸点数
reg    [15:0]       reg_addr   ;     // 触摸点坐标寄存器
reg    [15:0]       tp_x       ;     // 触摸点X坐标   
reg    [15:0]       tp_y       ;     // 触摸点y坐标
reg    [31:0]       tp1_xy_t    ;     // 触摸点1X坐标 
reg                 cnt_1us_en ;     // 使能计时
reg    [19:0]       cnt_1us_cnt;     // 4us计时
reg    [ 3:0]       cur_state  ;     // 
reg    [ 3:0]       next_state ;     // 
reg    [ 3:0]       flow_cnt   ;     // 
reg                 st_done    ;     // 
reg                 int_dir    ;     // 
reg                 int_out    ;     // 

//reg define
reg    [15:0]       CTRL_REG   ;     // 控制寄存器地址
reg    [15:0]       GTCH_REG   ;     // 检测到的当前触摸情况
reg    [15:0]       TP1_REG    ;     // 第一个触摸点数据地址
reg    [15:0]       TP2_REG    ;     // 第二个触摸点数据地址
reg    [15:0]       TP3_REG    ;     // 第三个触摸点数据地址
reg    [15:0]       TP4_REG    ;     // 第四个触摸点数据地址
reg    [15:0]       TP5_REG    ;     // 第五个触摸点数据地址

//*****************************************************
//**                    main code
//*****************************************************

assign tft_int = int_dir ? int_out : 1'bz;
//assign int_in = tft_int;

always @(*) begin
    if(lcd_id[15:8] == 8'h70 || lcd_id[15:8]== 8'h19) begin    // 7寸屏的FT系列触摸芯片
            bit_ctrl     = 1'b0 ;   
            CTRL_REG     = 8'h00;        // 控制寄存器地址
            GTCH_REG     = 8'h02;	     // 检测到的当前触摸情况
            TP1_REG      = 8'h03;	     // 第一个触摸点数据地址
            TP2_REG      = 8'h09;	     // 第二个触摸点数据地址
            TP3_REG      = 8'h0f;	     // 第三个触摸点数据地址
            TP4_REG      = 8'h15;	     // 第四个触摸点数据地址
            TP5_REG      = 8'h1b;        // 第五个触摸点数据地址
    end 
    else begin
            bit_ctrl     = 1'b1    ;
            CTRL_REG     = 16'h8040;     // 控制寄存器地址
            GTCH_REG     = 16'h814e;	 // 检测到的当前触摸情况
            TP1_REG      = 16'h8150;	 // 第一个触摸点数据地址
            TP2_REG      = 16'h8158;	 // 第二个触摸点数据地址
            TP3_REG      = 16'h8160;	 // 第三个触摸点数据地址
            TP4_REG      = 16'h8168;	 // 第四个触摸点数据地址
            TP5_REG      = 16'h8170;     // 第五个触摸点数据地址
    end
end

//计时控制
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
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        touch_done <= 1'b0;
//    end
//    else if(tp_num && tp_num_t == tp_num)
//        touch_done <= 1'b1;
//    else
//        touch_done <= 1'b0;
//end

/*
//当触摸点1变化时输出脉冲
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        touch_done <= 1'b0;
        tp1_xy_t   <= 32'd0;
    end
    else begin
        tp1_xy_t <= tp1_xy;
        if(tp1_xy_t != tp1_xy)
            touch_done <= 1'b1;
        else
            touch_done <= 1'b0;
    end
end
*/

//当触摸点1变化时输出脉冲
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        touch_done <= 1'b0;
        tp1_xy_t   <= 32'd0;
    end
    else if(lcd_id== 16'h7016)
    begin
      tp1_xy_t <= tp1_xy;
        if(tp1_xy_t != tp1_xy&&tp_x<600&&tp_y<1024)
            touch_done <= 1'b1;
        else
            touch_done <= 1'b0;
    end
     else if(lcd_id== 16'h7084||lcd_id==  16'h4384 || lcd_id == 16'h5510)
    begin
      tp1_xy_t <= tp1_xy;
        if(tp1_xy_t != tp1_xy&&tp_x<480&&tp_y<800)
            touch_done <= 1'b1;
        else
            touch_done <= 1'b0;
    end
     else if(lcd_id== 16'h1018)
    begin
      tp1_xy_t <= tp1_xy;
        if(tp1_xy_t != tp1_xy&&tp_x<800&&tp_y<1280)
            touch_done <= 1'b1;
        else
            touch_done <= 1'b0;
    end
      else if(lcd_id== 16'h4342)
    begin
      tp1_xy_t <= tp1_xy;
        if(tp1_xy_t != tp1_xy&&tp_x<272&&tp_y<480)
            touch_done <= 1'b1;
        else
            touch_done <= 1'b0;
    end
    else begin
        tp1_xy_t <= tp1_xy;
        if(tp1_xy_t != tp1_xy)
            touch_done <= 1'b1;
        else
            touch_done <= 1'b0;
    end
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
//                next_state = get_id; // 因不需要读取触摸屏ID，且为了降低资源的消耗，屏蔽此状态
					 if(lcd_id == 16'h4384 || lcd_id == 16'h5510 || lcd_id == 16'h4342)
					     next_state = chk_touch;
					 else
				        next_state = cfg_state;	 
            else
                next_state = init;
        end
//        get_id: begin
//            if(st_done)
//                next_state = cfg_state;
//            else
//                next_state =get_id;
//        end
        cfg_state: begin
            if(st_done) begin
                next_state = chk_touch;
            end 
            else
                next_state = cfg_state;
        end
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
                next_state = id_handle;
            else
                next_state = getpos_xy;
        end
        id_handle: begin
            if(st_done)
                next_state = tp_xy;
            else
                next_state = id_handle;
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
            touch_valid  <=  1'b0;
            flow_cnt     <=  4'b0;
            st_done      <=  1'b0;
            cnt_1us_en   <=  1'b0;
            i2c_exec     <=  1'b0;
            tft_tcs      <=  1'b0;
            int_dir      <=  1'b0;
            int_out      <=  1'b0;
            i2c_addr     <= 16'b0;
            i2c_data_w   <=  8'd0;
            i2c_rh_wl    <=  1'd0;
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
                            if(bigger_en) begin
                                flow_cnt <= flow_cnt + 1'b1;
                                int_dir <= 1'b1;
                                int_out <= 1'b1;                                
                            end    
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
//                get_id: begin
//                    case(flow_cnt)
//                        'd0 : begin
//                            i2c_exec <= 1'b1;
//                            i2c_addr <= PID_REG;
//                            reg_num <=  'd4;
//                            i2c_rh_wl<= 1'b1;
//                            flow_cnt <= flow_cnt + 1'b1;
//                        end
//                        'd1 : begin
//                            if(once_done) begin
//                                touch_id_t <= i2c_data_r - 8'h30;
//                                touch_id   <= {touch_id[11:0],touch_id_t[3:0]};
//                            end
//                            if(i2c_done) begin
//                                touch_id <= {touch_id[11:0],touch_id_t[3:0]};
//                                flow_cnt <= 'd0;
//                                st_done <= 1'b1;
//                            end
//                        end
//                        default : ;
//                    endcase
//                end
                cfg_state: begin
                    case(flow_cnt)
                        'd0 : begin
                            i2c_exec <= 1'b1;
                            i2c_addr <= CTRL_REG;
                            if(lcd_id[15:8] == 8'h70 || lcd_id[15:8]== 8'h19)
                                i2c_data_w<= 8'h00;
                            else
                                i2c_data_w<= 8'h02;
                            reg_num   <=  'd1;
                            i2c_rh_wl <= 1'b0;
                            flow_cnt  <= flow_cnt + 1'b1;
                        end
                        'd1: begin
                            if(i2c_done) begin
                                if(ack)
                                    flow_cnt <= flow_cnt - 1'b1;
                                else
                                    flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd2 : begin
                            i2c_exec <= 1'b1;
                            if(lcd_id[15:8] == 8'h70 || lcd_id[15:8]== 8'h19)
                                i2c_addr <= FT_ID_G_MODE;
                            else
                                i2c_addr <= CTRL_REG;                           
                            i2c_data_w <= 8'h0;
                            i2c_rh_wl <= 1'b0;
                            reg_num   <=  'd1;
                            flow_cnt <= flow_cnt + 1'b1;
                        end
                        'd3 : begin
                            if(i2c_done) begin
                                if(ack)
                                    flow_cnt <= flow_cnt - 1'b1;
                                else
                                    flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd4 : begin
                            if(lcd_id[15:8] == 8'h70 || lcd_id[15:8]== 8'h19)
                                flow_cnt <= 'd7;
                            else begin
                                flow_cnt <= flow_cnt + 1'b1;
                                cfg_switch <= 1'b1;
                            end
                        end                        
                        'd5: begin
                            if(cfg_done) begin
                                cfg_switch <= 1'b0;
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd6 : begin
                            if(i2c_done) begin
                                st_done <= 1'b1;
                                flow_cnt <= 'd0;
                            end
                        end
                        'd7: begin      //设置触摸有效值
                            i2c_exec <= 1'b1;
                            i2c_addr <= FT_ID_G_THGROUP;
                            i2c_data_w<= 8'd22;
                            reg_num   <= 'd1;
                            i2c_rh_wl <= 1'b0;
                            flow_cnt  <= flow_cnt + 1'b1;
                        end
                        'd8: begin
                            if(i2c_done) begin
                                if(!ack)
                                    flow_cnt <= flow_cnt + 1'b1;
                                else
                                    flow_cnt <= flow_cnt - 1'b1;
                             end
                        end
                        'd9: begin					//激活周期，不能小于12，最大14
                            i2c_exec <= 1'b1;
                            i2c_addr <= FT_ID_G_PERIODACTIVE;
                            i2c_data_w<= 8'd12;
                            reg_num   <= 'd1;
                            i2c_rh_wl <= 1'b0;
                            flow_cnt  <= flow_cnt + 1'b1;
                        end
                        'd10: begin
                            if(i2c_done) begin
                                flow_cnt <=  'b0;
                                st_done  <= 1'd1;
                            end
                        end 
                        default : ;
                    endcase
                end
                chk_touch: begin	// 检测触摸状态
                    case(flow_cnt)
                        'd0: begin
                            tp_num_t <= 3'd0;
                            tp_num   <= 3'd0;
                            if(lcd_id[15:8] == 8'h70 || lcd_id[15:8]== 8'h19)
                                flow_cnt <= flow_cnt + 1'b1; 
                            else if(lcd_id[15:8] == 8'h10)begin
                                cnt_1us_en <= 1'b1;
                                if(cnt_1us_cnt == 50000) 
                                    flow_cnt <= flow_cnt + 1'b1; 
                            end 
                            else begin
                                cnt_1us_en <= 1'b1;
                                if(cnt_1us_cnt == 17000)      //模块驱动时钟周期为625ns（频率为I2C时钟的4倍，400Kbps*4）
                                    flow_cnt <= flow_cnt + 1'b1; //此处每隔625ns*17000采样一次，即LCD每隔10.625ms更新一次坐标 
                            end 
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
                            if(i2c_done) begin
                                if(ack)
                                    flow_cnt <= flow_cnt - 1'b1;
                                else
                                    flow_cnt <= flow_cnt + 1'b1;
                             end
                        end
                        'd3: begin
                            if(lcd_id[15:8] == 8'h70 || lcd_id[15:8]== 8'h19)
                                flow_cnt <= flow_cnt + 1'b1;
                            else
                                flow_cnt <= flow_cnt + 2'd2;
                        end
                        'd4: begin
                            if(i2c_data_r != 8'hff && i2c_data_r[3:0] != 4'd0 && i2c_data_r[3:0] < 4'd6) begin
                                flow_cnt <= 'd0;
                                st_done  <= 1'b1; 
                                touch_valid<= 1'b1; 
                                tp_num <= i2c_data_r[2:0];
                            end
                            else begin
                                touch_valid<= 1'b0;
                                flow_cnt <= 'd1;
                            end
                        end
                        'd5: begin
                            if(i2c_data_r[7]== 1'b1 && i2c_data_r[3:0] != 4'd0) begin
                                flow_cnt <= flow_cnt + 1'b1;
                                touch_valid<= 1'b1;           //i2c_data_r[4];
                                tp_num   <= i2c_data_r[2:0];
                            end
                            else begin
                                touch_valid<= 1'b0;           //i2c_data_r[4];
                                flow_cnt <= flow_cnt + 1'b1;
                            end
                        end
                        'd6: begin
                            i2c_exec <= 1'b1;
                            i2c_addr <= GTCH_REG;
                            i2c_rh_wl<= 1'b0;
                            i2c_data_w<= 8'd0;
                            reg_num  <=  'd1;
                            flow_cnt <= flow_cnt + 1'b1;    
                        end
                        'd7: begin
                            if(i2c_done) begin
                                if(ack)
                                    flow_cnt <= flow_cnt - 1'b1;
                                else if(tp_num) begin
                                    st_done <= 1'b1;
                                    flow_cnt <= 'd0;
                                end
                                else 
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
                            if(ack)
                                flow_cnt <= flow_cnt - 1'b1;
                            if(once_done) begin
                                tp_x[7:0] <= i2c_data_r;
                                flow_cnt  <= flow_cnt + 1'b1;
                            end
                        end
                        'd2 : begin
                            if(once_done) begin
                                tp_x[15:8] <= i2c_data_r;
                                flow_cnt  <= flow_cnt + 1'b1;
                            end
                        end
                        'd3 : begin
                            if(once_done) begin
                                tp_y[7:0] <= i2c_data_r;
                                flow_cnt  <= flow_cnt + 1'b1;
                             end
                        end
                        'd4 : begin
                            if(i2c_done) begin
                                tp_y[15:8] <= i2c_data_r;
                                st_done  <= 1'b1;
                                flow_cnt <= 'd0;
                            end
                        end
                        default : ;
                    endcase
                end
                id_handle: begin
                    case(lcd_id)
                        16'h4342: begin     // 4.3' RGB  
                            tp_x <= 271 - tp_y;//
                            tp_y <= tp_x;
                            st_done  <= 1'b1;
                        end
                        16'h7084,16'h1963: begin
                            tp_x <= 479 - {4'd0,tp_x[3:0],tp_x[15:8]};
                            tp_y <= {4'd0,tp_y[3:0],tp_y[15:8]};
                            st_done  <= 1'b1;        
                        end
                        16'h7016: begin
                            tp_x <= 599 - {4'd0,tp_x[3:0],tp_x[15:8]};
                            tp_y <= {4'd0,tp_y[3:0],tp_y[15:8]};
                            st_done  <= 1'b1;        
                        end
                        16'h1018: begin
                            tp_x <= 799 - tp_y;
                            tp_y <= tp_x;                        
                            st_done  <= 1'b1;
                        end 
                        16'h4384: begin
                            tp_x <= 479- tp_y;
                            tp_y <=tp_x;
                            st_done  <= 1'b1;                       
                        end                        
                        default: st_done  <= 1'b1; 
                     endcase
                end
                tp_xy: begin
                    case(tp_num_t)                   
                        'd0: begin
//                            touch_valid<= 1'b1;         //注意！该语句放在此处仅支持在NIOS中单点画图！
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