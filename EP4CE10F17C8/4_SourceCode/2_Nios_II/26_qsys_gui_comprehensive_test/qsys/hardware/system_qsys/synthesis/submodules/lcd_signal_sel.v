module lcd_signal_sel(input         init_done,
                      input [15:0]  init_data,
                      input         init_RS,
							 input         init_CS,
							 input         init_RD,
							 input         init_WR,
							 input         init_BL_CNT,
							 input         init_RESET,
							 input [15:0]  ctrl_data,
							 input         ctrl_RS,
							 input         ctrl_CS,
							 input         ctrl_RD,
							 input         ctrl_WR,
							 input         ctrl_BL_CNT,
							 input         ctrl_RESET,
							 output [15:0] data,
					       output        RS,
					       output        CS,
					       output        RD,
					       output        WR,
					       output        BL_CNT,
					       output        RESET);

assign data   = init_done?ctrl_data:init_data;
assign RS     = init_done?ctrl_RS:init_RS;
assign CS     = init_done?ctrl_CS:init_CS;
assign RD     = init_done?ctrl_RD:init_RD;
assign WR     = init_done?ctrl_WR:init_WR;
assign BL_CNT = init_done?ctrl_BL_CNT:init_BL_CNT;
assign RESET  = init_done?ctrl_RESET:init_RESET;
endmodule 