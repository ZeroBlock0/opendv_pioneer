module ILI9341_top(input         clk50M,
                   input         rst_n,
					    //data stream compliant with Avalon-ST standard video proctol
						 input         sink_valid,
						 output        sink_ready,
						 input         sink_sop,
					 	 input         sink_eop,
				   	 input  [15:0] sink_data,
						 //TFT-LCD interface
						 output [15:0] data,
						 output        RS,
					    output        CS,
					    output        RD,
					    output        WR,
					    output        BL_CNT,
					    output        RESET
						 );


wire tft_read_w,tft_write_w;
wire [1:0] tft_address_w;
wire [31:0] tft_readdata_w;
wire [31:0] tft_writedata_w;
/*ILI932x_test u0(
               .clk50M(clk50M),
               .rst_n(rst_n),
					.sink_valid(sink_valid_w),
					.sink_ready(sink_ready_w),
					.sink_sop(sink_sop_w),
					.sink_eop(sink_eop_w),
					.sink_data(sink_data_w)
);
wire sink_valid_w1,sink_ready_w1,sink_sop_w1,sink_eop_w1;
 decoder u4(     
             .csi_clk50M(clk50M),
             .rsi_rst_n(rst_n),
							//data stream compliant with Avalon-ST standard video proctol
				.sink_valid(sink_valid_w),
				.sink_ready(sink_ready_w),
				.sink_sop(sink_sop_w),
				.sink_eop(sink_eop_w),
				.sink_data({sink_data_w[15:11],3'd0,sink_data_w[10:5],2'd0,sink_data_w[4:0],3'd0}),
							//unstandard Avalon-ST data stream that ignor control package
				.source_valid(sink_valid_w1),
				.source_ready(sink_ready_w1),
				.source_sop(sink_sop_w1),
				.source_eop(sink_eop_w1),
				.source_data(sink_data_w1)
				);
wire sink_valid_w1,sink_ready_w1,sink_sop_w1,sink_eop_w1;
decoder u0(     
             .csi_clk50M(clk50M),
             .rsi_rst_n(rst_n),
							//data stream compliant with Avalon-ST standard video proctol
				.sink_valid(sink_valid),
				.sink_ready(sink_ready),
				.sink_sop(sink_sop),
				.sink_eop(sink_eop),
				.sink_data(sink_data),
							//unstandard Avalon-ST data stream that ignor control package
				.source_valid(sink_valid_w1),
				.source_ready(sink_ready_w1),
				.source_sop(sink_sop_w1),
				.source_eop(sink_eop_w1),
				.source_data(sink_data_w1)
				);*/
ILI932x      u1(
               .csi_clk50M(clk50M),
               .rsi_rst_n(rst_n),
					.avs_avalon_read(tft_read_w),
					.avs_avalon_address(tft_address_w),
					.avs_avalon_write(tft_write_w),
					.avs_avalon_readdata(tft_readdata_w),
					.avs_avalon_writedata(tft_writedata_w),
					.data(data),
					.RS(RS),
					.CS(CS),
					.RD(RD),
					.WR(WR),
					.BL_CNT(BL_CNT),
					.RESET(RESET)
					);
wire sink_valid_w,sink_ready_w,sink_sop_w,sink_eop_w;
wire fifo_rdreq_w,fifo_wrreq_w;
wire [15:0] sink_data_w,sink_data_w1;
wire [17:0] fifo_data_w,fifo_q_w;
wire [9:0]  fifo_usedw_w;
Avalon_ST_tftlcd u2(
               .csi_clk50M(clk50M),
               .rsi_rst_n(rst_n),
					.sink_valid(sink_valid),
					.sink_ready(sink_ready),
					.sink_sop(sink_sop),
					.sink_eop(sink_eop),
					.sink_data(sink_data),
                     //below connect to fifo's interface
					.fifo_data(fifo_data_w),
					.fifo_rdreq(fifo_rdreq_w),
					.fifo_wrreq(fifo_wrreq_w),
					.fifo_q(fifo_q_w),
					.fifo_usedw(fifo_usedw_w),
							//below connect ILI932x's interface
					.tft_read(tft_read_w),
					.tft_address(tft_address_w),
					.tft_write(tft_write_w),
					.tft_readdata(tft_readdata_w[15:0]),
					.tft_writedata(tft_writedata_w)
							
							);
fifo  u3(
   .aclr(~rst_n),
	.clock(clk50M),
	.data(fifo_data_w),
	.rdreq(fifo_rdreq_w),
	.wrreq(fifo_wrreq_w),
	.q(fifo_q_w),
	.usedw(fifo_usedw_w));
endmodule 