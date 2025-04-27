module intface8080(input         clk,
                   input         rst_n,
						 input [17:0]  index,//index[17]为高表示读，为低表示写，index[16]为高表示index[15:0]为数据，为低表示index[15:0]为指令
						 output        WR,
						 output        RD,
						 output        CS,
						 output        RS,
						 output        BL_cnt,
						 output [15:0] data,
						 output        RESET
						 
						 );//16bit 8080 接口
//parameter clk_freq  = 12.5*1000000;
reg WR_n,RD_n;//低电平有效
reg RS_r;
reg [15:0] data_r;
reg RESET_r;
assign BL_cnt = 1'b1;//亮度设置为最亮
assign CS     = 1'b0;//片选低电平有效
assign WR     = WR_n | clk;
assign RD     = RD_n | clk;
assign RS     = RS_r;
assign data   = data_r;
assign RESET  = RESET_r;
always@(negedge clk or negedge rst_n)
begin
if(!rst_n)
    begin
	 WR_n <= 1'b1;
	 RD_n <= 1'b1;
	 RS_r <= 1'b0;
	 data_r <= 16'h0000;
	 RESET_r <= 1'b0;
	 end
else
    begin
	 RESET_r <= 1'b1;
	 if(index[17] == 1'b0)
	     begin
		  if(index[16])
		      begin
				WR_n <= 1'b0;
			   RS_r <= 1'b1;
			   data_r <= index[15:0];	
		      end
		  else
		      begin
				WR_n <= 1'b0;
			   RS_r <= 1'b0;
			   data_r <= index[15:0];
				end
		  end
	 else
	     WR_n <= 1'b1;
	 //
	 end
end
endmodule 