module ILI9341(input clk50M,
               input rst_n,
					output        WR,
					output        RD,
					output        CS,
					output        RS,
					output        BL_cnt,
					output [15:0] data,
					output        RESET,
					output        init_done);
wire clk12_5_w;
clk12_5M u0(.clk50M(clk50M),
            .rst_n(rst_n),
				.clk12_5(clk12_5_w));
wire [17:0] index_w;
index_lut u1(.clk(clk12_5_w),
             .rst_n(rst_n),
				 .index(index_w),
				 .init_done(init_done)
				 );
intface8080 u2(.clk(clk12_5_w),
            .rst_n(rst_n),
				.index(index_w),//index[17]为高表示读，为低表示写，index[16]为高表示index[15:0]为数据，为低表示index[15:0]为指令
				.WR(WR),
				.RD(RD),
				.CS(CS),
				.RS(RS),
				.BL_cnt(BL_cnt),
				.data(data),
				.RESET(RESET)
				
						 );//16bit 8080 接口
endmodule 