module ILI932x(input         csi_clk50M,
               input         rsi_rst_n,
																						//avalon_ST_TFTLCD模块的avalon-mm接口
					input         avs_avalon_read,
					input [1:0]   avs_avalon_address,
					input         avs_avalon_write,
					output [31:0] avs_avalon_readdata,
					input  [31:0] avs_avalon_writedata,
					
					output [15:0] data,
					output        RS,
					output        CS,
					output        RD,
					output        WR,
					output        BL_CNT,
					output        RESET
					);
					
					
	wire        ref_addr_w;	
	wire  		wr_en_w;
	wire  		init_done_w;
	wire  		wr_able_w;
	wire [15:0] wr_data_w;
	wire [16:0] wr_address_w;
	wire [15:0] ctrl_data;
	wire [15:0] init_data;
	
	wire 			ctrl_RS, ctrl_CS, ctrl_RD, ctrl_WR, ctrl_BL_CNT, ctrl_RESET;
	wire 			init_RS, init_CS, init_RD, init_WR, init_BL_CNT, init_RESET;
	
	assign      avs_avalon_readdata[31:16] = 16'd0;
	
	
	avalon_interface  u1(
								.clk(csi_clk50M),
								.reset_n(rsi_rst_n),
								.read(avs_avalon_read),
								.address(avs_avalon_address),
								.write(avs_avalon_write),
								.readdata(avs_avalon_readdata[15:0]),
								.writedata(avs_avalon_writedata),
								.init_done(init_done_w),
								.wr_able(wr_able_w),
								.ref_addr(ref_addr_w),
								.wr_en(wr_en_w),
								.wr_address(wr_address_w),
								.wr_data(wr_data_w)
								);
				
	lcd_signal_sel    u2(
								.init_done(init_done_w),
								.init_data(init_data),
								.init_RS(init_RS),
								.init_CS(init_CS),
								.init_RD(init_RD),
								.init_WR(init_WR),
								.init_BL_CNT(init_BL_CNT),
								.init_RESET(init_RESET),
								.ctrl_data(ctrl_data),
								.ctrl_RS(ctrl_RS),
								.ctrl_CS(ctrl_CS),
								.ctrl_RD(ctrl_RD),
								.ctrl_WR(ctrl_WR),
								.ctrl_BL_CNT(ctrl_BL_CNT),
								.ctrl_RESET(ctrl_RESET),
								.data(data),
								.RS(RS),
								.CS(CS),
								.RD(RD),
								.WR(WR),
								.BL_CNT(BL_CNT),
								.RESET(RESET)
							);
							
	ILI9341 			  u3(
							   .clk50M(csi_clk50M),
							   .rst_n(rsi_rst_n),
							   .WR(init_WR),
							   .RD(init_RD),
							   .CS(init_CS),
							   .RS(init_RS),
							   .BL_cnt(init_BL_CNT),
							   .data(init_data),
							   .RESET(init_RESET),
							   .init_done(init_done_w)
				          );
			  
TFT_LCD TFT_LCD_u(
								.clk50M(csi_clk50M),
								.rst_n(rsi_rst_n),
								.ref_addr(ref_addr_w),
								.wr_en(wr_en_w),
								.wr_address(wr_address_w),
								.wr_data(wr_data_w),
								.data(ctrl_data),
								.RS(ctrl_RS),
								.CS(ctrl_CS),
								.RD(ctrl_RD),
								.WR(ctrl_WR),
								.BL_CNT(ctrl_BL_CNT),
								.RESET(ctrl_RESET),
								.init_done(init_done_w),
								.wr_able(wr_able_w)
								);

endmodule 