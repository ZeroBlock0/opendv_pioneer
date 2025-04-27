module TFT_LCD(clk50M,rst_n,init_done,ref_addr,wr_en,wr_address,wr_data,data,RS,CS,RD,WR,BL_CNT,RESET,wr_able);





parameter step1 = 2'd0;
parameter step2 = 2'd1;
parameter step3 = 2'd2;
parameter step4 = 2'd3;
input clk50M,rst_n;
input init_done;
input ref_addr;//高电平表示需要刷新AC（address counter）的值
input wr_en;
input [16:0] wr_address;
input [15:0] wr_data;
output wr_able;
output [15:0] data;
output RS,CS,RD,WR,BL_CNT,RESET;
reg [15:0] data_r;
reg [5:0] state;
reg [4:0] cnt1;
reg [31:0] cnt2;
reg RS_r,CS_r,RD_r,WR_r,BL_CNT_r,RESET_r;
reg [1:0] wr_step;//write data to gram adress 
reg wr_able_r;
reg [16:0] wr_address_r;
assign data=data_r;
assign RS=RS_r;
assign CS=CS_r;
assign RD=RD_r;
assign WR=WR_r;
assign BL_CNT=BL_CNT_r;
assign RESET=RESET_r;
assign wr_able =wr_able_r;
always@(posedge clk50M or negedge rst_n)
begin
if(!rst_n)
begin
RS_r<=1'b1;
CS_r<=1'b0;
RD_r<=1'b1;
WR_r<=1'b1;
BL_CNT_r<=1'b0;
RESET_r<=1'b0;
state<=6'd0;
cnt1<=5'd0;
cnt2<=0;
data_r<=16'd0;
wr_step <= step1;
wr_able_r <= 1'b1;
wr_address_r <= 17'd0;
end
else
begin
BL_CNT_r<=1'b1;
RESET_r<=1'b1;
RD_r<=1'b1;
CS_r<=1'b0;
if(init_done)
    begin
	 //
		case(wr_step)
		step1:begin
		    if(wr_en == 1'b1)
			     begin
				  wr_address_r <= wr_address;
				  wr_able_r <= 1'b0;//写操作开始进行，不再响应写请求
				  if(ref_addr == 1'b1)
				      wr_step <= step2;
				  else
				      wr_step <= step4;
				  end
			 else
			     begin
				  wr_step <= step1;
				  end
		end
		step2:begin
		    if(cnt1>=5'd19)
			     begin
	           cnt1<=0;
				  wr_step <= step3;
				  end
	       else
	           cnt1<=cnt1+5'd1;
			 if(cnt1<=5'd1)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b0;
			     data_r<=16'h002A;//AC set regester
				  end
			 else if(cnt1<=5'd3)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd5)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h0000;
				  end
			 else if(cnt1<=5'd7)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd9)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h0000;
				  end
			 else if(cnt1<=5'd11)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd13)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h0001;
				  end
			 else if(cnt1<=5'd15)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd17)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h003F;
				  end
			 else
			     begin
				  WR_r<=1'b1;
				  end
		end
		step3:begin
		    if(cnt1>=5'd23)
			     begin
	           cnt1<=0;
				  wr_able_r <= 1'b1;//写操作完成，可以再次进行写操作
				  wr_step <= step1;
				  end
	       else
	           cnt1<=cnt1+5'd1;
			 if(cnt1<=5'd1)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b0;
			     data_r<=16'h002B;//AC set regester
				  end
			 else if(cnt1<=5'd3)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd5)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h0000;
				  end
			 else if(cnt1<=5'd7)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd9)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h0000;
				  end
			 else if(cnt1<=5'd11)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd13)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h0001;
				  end  
			 else if(cnt1<=5'd15)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd17)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=16'h003F;
				  end
			 else if(cnt1<=5'd19)
			     begin
				  WR_r<=1'b1;
				  end
			 else if(cnt1<=5'd21)//注意此处开始放在了step4中，导致写入一个像素数据需要花费8+1个时钟，修改后只需要4+1个时钟（+1是因为从step1态跳转到step4态需要花费一个时钟）
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b0;
			     data_r<=16'h002C;//GRAM access regester
				  end
			 else if(cnt1<=5'd23)
			     begin
				  WR_r<=1'b1;
				  end
		end
		step4:begin
		    if(cnt1>=5'd3)
			     begin
	           cnt1<=0;
				  wr_able_r <= 1'b1;//写操作完成，可以再次进行写操作
				  wr_step <= step1;
				  end
	       else
	           cnt1<=cnt1+5'd1;
		    if(cnt1<=5'd1)
			     begin
				  WR_r<=1'b0;
				  RS_r<=1'b1;
			     data_r<=wr_data;
				  end
			 else
			     begin
				  WR_r<=1'b1;
				  end
		end
		endcase
		
		//
		
     end

	  

	  
end

end
endmodule 