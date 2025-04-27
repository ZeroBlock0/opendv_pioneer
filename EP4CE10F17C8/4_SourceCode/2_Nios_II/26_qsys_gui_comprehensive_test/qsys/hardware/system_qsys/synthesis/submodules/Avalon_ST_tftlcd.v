module Avalon_ST_tftlcd(                           //本模块按AVAlon_ST格式接收解码模块传输的图像数据,由FIFO缓冲后按avalon_mm传输给TFT控制器
                     input         csi_clk50M,
                     input         rsi_rst_n,	
																	//input image data in avalon_ST format
							input         sink_valid,
							output        sink_ready,
							input         sink_sop,
							input         sink_eop,
							input  [15:0] sink_data,
																	//below connect to fifo's interface
							output [17:0] fifo_data,
							output        fifo_rdreq,
							output        fifo_wrreq,
							input  [17:0] fifo_q,
							input  [9:0]  fifo_usedw,
																	//below connect ILI932x's avalon_mm interface 
							output        tft_read,
							output [1:0]  tft_address,
							output        tft_write,
							input  [15:0] tft_readdata,
							output [31:0] tft_writedata
							);
							
	parameter  wait_ILI932x_ready = 3'd0;  			//循读status寄存器，察看ILI932x是否准备好
	parameter  idle               = 3'd1;
	parameter  rdfifo_s           = 3'd2;  			//读fifo状态
	parameter  wr_tft_s           = 3'd3;  			//把读出的fifo数据写入到TFTLCD控制器

	parameter  step1      = 4'd0;
	parameter  step2      = 4'd1;
	parameter  step3      = 4'd2;
	parameter  step4      = 4'd3;
	parameter  step5      = 4'd4;
	
	reg [2:0]  state;           							//工作状态
	reg [3:0]  step;
	
	reg [17:0] fifo_q_r;		
	reg [17:0] fifo_data_r;     							//要写入fifo的数据最低两位分别是sop和eop信号,注:fifo_data_r[1]是sop,fifo_data_r[0]是eop
	reg        fifo_rdreq_r;    							//送给fifo的读请求信号
	reg        fifo_wrreq_r;    							//送给fifo的写请求信号

	assign     fifo_data  = fifo_data_r;
	assign     fifo_rdreq = fifo_rdreq_r;
	assign     fifo_wrreq = fifo_wrreq_r;	
	
	reg        tft_read_r;      							//送给TFTLCD控制器的读使能
	reg [1:0]  tft_address_r;   							//TFTLCD控制器的寄存器地址
	reg        tft_write_r;     							//送给TFTLCD控制器的写使能
	reg [31:0] tft_writedata_r; 							//写入TFTLCD控制器的对应寄存器的数据

	assign 	  tft_read      = tft_read_r;
	assign 	  tft_address   = tft_address_r;
	assign 	  tft_write     = tft_write_r;
	assign 	  tft_writedata = tft_writedata_r;

	reg        ILI932x_ready;  							//判断TFTLCD控制器初始化完成并且第一次准备好接收数据(即init_done == 1 && write_able == 1)
	reg        sink_ready_r;    							//告诉前端模块，本模块是否准备好接收数据，高电平表示准备好
	
	assign     sink_ready = sink_ready_r && ILI932x_ready;



	always@(posedge csi_clk50M or negedge rsi_rst_n )
	begin
		if(!rsi_rst_n)
			 begin
				 sink_ready_r    <= 1'b1;										   //准备好接收数据
				 fifo_data_r     <= 18'd0;
				 fifo_q_r        <= 18'd0;
				 fifo_rdreq_r    <= 1'b0;
				 fifo_wrreq_r    <= 1'b0;
				 tft_read_r      <= 1'b0;
				 tft_address_r   <= 2'd0;										   //指向status寄存器
				 tft_write_r     <= 1'b0;
				 tft_writedata_r <= 0;
				 state           <= wait_ILI932x_ready;
				 step            <= step1;
				 ILI932x_ready   <= 1'b0;
			 end
	else
		 begin
		 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  FIFO 读写操作
			 if(sink_valid == 1'b1)
				  begin																	//将图像数据和包头、包尾信号合并，作为fifo的输入数据
				    fifo_data_r  <= {sink_data,sink_sop,sink_eop};
				    fifo_wrreq_r <= 1'b1;											//往fifo中写入数据
				  end
			 else
				  begin
				    fifo_wrreq_r    <= 1'b0;										//停止往fifo中写入数据
				  end
			 if(fifo_usedw >= 10'd1000)
				  sink_ready_r    <= 1'b0;
			 else
				  sink_ready_r    <= 1'b1;
				  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////			  
			 case(state)		 
/***********/wait_ILI932x_ready:                                     //等待TFTLCD控制器初始化完成
						begin
						  case(step)
							  step1:
									begin
									  tft_read_r      <= 1'b1;                //avalon_mm 读status寄存器
									  tft_address_r   <= 2'd0;
									  step            <= step2;
									end
							  step2:
									begin
									  tft_read_r      <= 1'b0;
									  step            <= step3;
									end
							  step3:
									begin
									  if(tft_readdata[1:0] == 2'b11)				//TFTLCD控制器初始化完成并且第一次准备好接收数据
											begin										   //(即init_done == 1 && write_able == 1)
											  ILI932x_ready   <= 1'b1;          
											  state <= idle;                    
											  step  <= step1;
										 end
									  else
											begin
											  step <= step1;
											end
									end
							  default:;
						  endcase
						end
/***********/idle:
						begin
						  if(fifo_usedw >= 10'd1)
								begin
									fifo_rdreq_r    <= 1'b1;						//发起读fifo请求
									state           <= rdfifo_s;
									step            <= step1;
								end
						  else
								begin
									state           <= state;
								end
						end
/***********/rdfifo_s:
						begin
						  case(step)
							   step1:
								    begin
										fifo_rdreq_r    <= 1'b0;               //关闭读fifo使能
										step            <= step2;
							      end
							   step2:
								   begin
									  fifo_q_r        <= fifo_q;              //保存fifo读出的数据
									  step            <= step1;
									  state           <= wr_tft_s;
							      end
							   default:;
						  endcase
						end
/***********/wr_tft_s:                                               //将fifo读出的数据通过AVAlon_mm写到tft控制器
					   begin
						  case(step)
							  step1:
							      begin
										tft_read_r      <= 1'b1;               						//avalon_mm 读status寄存器
										tft_address_r   <= 2'd0;
										step            <= step2;
							      end
							  step2:
									begin
										tft_read_r      <= 1'b0;
										step            <= step3;
									end
							  step3:
									begin
										if(tft_readdata[1:0] == 2'b11)									//若TFTLCD控制器准备好接收数据，则操作寄存器进行显示地址或者显示数据的写入
											 begin
												 if(fifo_q_r[1] == 1'b1)									//sop为1，即代表一个包（设定一帧数据为一个包）开始，那么将显示的首地址设为0行319列??
													  begin
														  tft_write_r           <= 1'b1;
														  tft_address_r         <= 2'd1;
														  tft_writedata_r[16:8] <= 9'd0;//319;				//列地址为319
														  tft_writedata_r[7:0]  <= 8'd0;					//行地址为0
														  step                  <= step4;
													  end
												 else                    									//sop为0，此时只要写入像素数据到TFTLCD控制器的wr_buffer寄存器里就行,
													  begin                                			//TFTLCD控制器会自动完成数据写入到对应的gram地址并显示
														  tft_write_r     <= 1'b1;							//TFTLCD控制器的写使能拉高
														  tft_address_r   <= 2'd2;							//TFTLCD控制器的寄存器地址设为2，即wr_buffer寄存器
														  tft_writedata_r[15:0] <= fifo_q_r[17:2];	//向TFTLCD控制器的wr_buffer寄存器写入像素数据
														  step <= step5;										//下一个时钟把TFTLCD控制器的写使能拉低，并且跳转状态
													  end
												 end
											else
												 begin
													step        <= step1;
												 end
									end
							  step4:
									begin
										tft_write_r <= 1'b0;                                     //TFTLCD控制器的写使能拉低
										fifo_q_r[1] <= 1'b0;
										step        <= step1;
									end
							  step5:
							      begin
										tft_write_r <= 1'b0;                                     //TFTLCD控制器的写使能拉低
										step        <= step1;
										state       <= idle;
							      end
							  default:;
						  endcase
					   end
/***********/default:;
			 endcase
			 
			 end
	end
endmodule   