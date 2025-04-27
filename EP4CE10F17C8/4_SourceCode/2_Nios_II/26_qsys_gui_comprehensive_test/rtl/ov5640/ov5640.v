module ov5640(
    input                 clk            ,  //时钟信号 
    input                 rst_n          ,  //复位信号（低有效）

    //摄像头接口
    input                 cam_pclk       ,  //cmos 数据像素时钟
    input                 cam_vsync      ,  //cmos 场同步信号
    input                 cam_href       ,  //cmos 行同步信号
    input        [7:0]    cam_data       ,  //cmos 数据  
    output                cam_rst_n      ,  //cmos 复位信号，低电平有效
    output                cam_pwdn       ,  //cmos 电源休眠模式选择信号
    output                cam_scl        ,  //cmos SCCB_SCL线
    inout                 cam_sda        ,  //cmos SCCB_SDA线

    output                cam_init_done  ,  //摄像头初始化完成
    output                wr_en          ,  //fifo写使能信号
    output   [15:0]       wr_data        ,  //往fifo中写的数据
    output                ID_flag           //能否读取到ov5640的ID的判断信号

);

//parameter define
parameter  SLAVE_ADDR = 7'h3c         ;  //OV5640的器件地址7'h3c
parameter  BIT_CTRL   = 1'b1          ;  //OV5640的字节地址为16位  0:8位 1:16位
parameter  CLK_FREQ   = 27'd100_000_000; //i2c_dri模块的驱动时钟频率 
parameter  I2C_FREQ   = 18'd250_000   ;  //I2C的SCL时钟频率,不超过400KHz
//用于7寸RGB LCD
parameter  CMOS_H_PIXEL = 24'd800     ;  //CMOS水平方向像素个数
parameter  CMOS_V_PIXEL = 24'd480     ;  //CMOS垂直方向像素个数

////用于4.3寸RGB LCD
//parameter  CMOS_H_PIXEL = 24'd480     ;  //CMOS水平方向像素个数
//parameter  CMOS_V_PIXEL = 24'd480     ;  //CMOS垂直方向像素个数

//wire define
wire                  i2c_exec        ;  //I2C触发执行信号
wire   [23:0]         i2c_data        ;  //I2C要配置的地址与数据(高8位地址,低8位数据) 
wire                  i2c_done        ;  //I2C寄存器配置完成信号
wire                  i2c_dri_clk     ;  //I2C操作时钟
wire   [ 7:0]         i2c_data_r      ;  //I2C读出的数据
wire                  i2c_rh_wl       ;  //I2C读写控制信号

//*****************************************************
//**                    main code
//*****************************************************

assign  cam_rst_n = 1'b1;
//电源休眠模式选择 0：正常模式 1：电源休眠模式
assign  cam_pwdn = 1'b0;

//I2C配置模块
i2c_ov5640_rgb565_cfg 
   #(
     .CMOS_H_PIXEL        (CMOS_H_PIXEL),
     .CMOS_V_PIXEL        (CMOS_V_PIXEL)
    )
   u_i2c_cfg(
    .clk                  (i2c_dri_clk),
    .rst_n                (rst_n),
    .i2c_done             (i2c_done),
    .i2c_exec             (i2c_exec),
    .i2c_data             (i2c_data),
    .i2c_rh_wl            (i2c_rh_wl),              //I2C读写控制信号
    .i2c_data_r           (i2c_data_r),   
    .init_done            (cam_init_done),
    .ID_flag              (ID_flag)
    );    

//I2C驱动模块(在i2c_dri模块的基础上稍作修改,以兼容SCCB总线的读操作)
i2c_dri_ov5640 
   #(
    .SLAVE_ADDR           (SLAVE_ADDR),               //参数传递
    .CLK_FREQ             (CLK_FREQ  ),              
    .I2C_FREQ             (I2C_FREQ  )                
    ) 
   u_i2c_dri_ov5640(
    .clk                  (clk       ),
    .rst_n                (rst_n     ),   
    //i2c interface
    .i2c_exec             (i2c_exec  ),   
    .bit_ctrl             (BIT_CTRL  ),   
    .i2c_rh_wl            (i2c_rh_wl),                     //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr             (i2c_data[23:8]),   
    .i2c_data_w           (i2c_data[7:0]),   
    .i2c_data_r           (i2c_data_r),   
    .i2c_done             (i2c_done  ),   
    .scl                  (cam_scl   ),   
    .sda                  (cam_sda   ),   
    //user interface
    .dri_clk              (i2c_dri_clk)               //I2C操作时钟
);

//CMOS图像数据采集模块
cmos_capture_data u_cmos_capture_data(
    .rst_n                (rst_n & cam_init_done), //系统初始化完成之后再开始采集数据 
    .cam_pclk             (cam_pclk),
    .cam_vsync            (cam_vsync),
    .cam_href             (cam_href),
    .cam_data             (cam_data),         
    .cmos_frame_vsync     (),
    .cmos_frame_href      (),
    .cmos_frame_valid     (wr_en),            //数据有效使能信号
    .cmos_frame_data      (wr_data)           //有效数据 
    );

endmodule