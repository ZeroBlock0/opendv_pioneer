module index_lut(input         clk,
                 input         rst_n,
					  output [17:0] index,
					  output        init_done);
parameter clk_freq = 12500000;
parameter para_time = clk_freq/5-1;//延迟200ms
reg [17:0] index_r;
reg [9:0] index_cnt;
reg [31:0] delay_cnt,delay_cnt1;
reg init_done_r;
assign init_done = init_done_r;
assign index = index_r;
always@(negedge clk or negedge rst_n)
begin
if(!rst_n)
    begin
	 index_r     <= {1'b1,1'b1,16'h0000};//{wr/rd,RS,data}
	 index_cnt   <= 10'd0;
	 delay_cnt   <= 0;
	 delay_cnt1  <= 0;
	 init_done_r <= 1'b0;
	 end
else
    begin
	 //
	 if(delay_cnt1 >= para_time)
	     begin
	     if(index_cnt <= 10'd81)
	         index_cnt <= index_cnt+10'd1;
	     else if(index_cnt == 10'd82 || index_cnt == 10'd84)
	         begin
		      if(delay_cnt >= para_time)
				    index_cnt <= index_cnt+10'd1;
				else
				    index_cnt <= index_cnt;
		      end
		  else if(index_cnt <= 10'd1000)
		      index_cnt <= index_cnt+10'd1;
		  //
		  end
	 else
	     delay_cnt1 <= delay_cnt1+1;
	 //
	 case(index_cnt)
	 10'd0:index_r <= {1'b0,1'b0,16'h00CF};
	 10'd1:index_r <= {1'b0,1'b1,16'h0000};
	 10'd2:index_r <= {1'b0,1'b1,16'h0099};
	 10'd3:index_r <= {1'b0,1'b1,16'h0030};
	 
	 10'd4:index_r <= {1'b0,1'b0,16'h00ED};
	 10'd5:index_r <= {1'b0,1'b1,16'h0064};
	 10'd6:index_r <= {1'b0,1'b1,16'h0003};
	 10'd7:index_r <= {1'b0,1'b1,16'h0012};
	 10'd8:index_r <= {1'b0,1'b1,16'h0081};
	 
	 10'd9:index_r <= {1'b0,1'b0,16'h00CB};
	 10'd10:index_r <= {1'b0,1'b1,16'h0039};
	 10'd11:index_r <= {1'b0,1'b1,16'h002C};
	 10'd12:index_r <= {1'b0,1'b1,16'h0000};
	 10'd13:index_r <= {1'b0,1'b1,16'h0034};
	 10'd14:index_r <= {1'b0,1'b1,16'h0002};
	 
	 10'd15:index_r <= {1'b0,1'b0,16'h00EA};
	 10'd16:index_r <= {1'b0,1'b1,16'h0000};
	 10'd17:index_r <= {1'b0,1'b1,16'h0000};
	 
	 10'd18:index_r <= {1'b0,1'b0,16'h00E8};
	 10'd19:index_r <= {1'b0,1'b1,16'h0085};
	 10'd20:index_r <= {1'b0,1'b1,16'h0000};
	 10'd21:index_r <= {1'b0,1'b1,16'h0078};

	 10'd22:index_r <= {1'b0,1'b0,16'h00C0};
	 10'd23:index_r <= {1'b0,1'b1,16'h0023};
	 //
	 10'd24:index_r <= {1'b0,1'b0,16'h00C1};
	 10'd25:index_r <= {1'b0,1'b1,16'h0012};
	 //
	 10'd26:index_r <= {1'b0,1'b0,16'h00C2};
	 10'd27:index_r <= {1'b0,1'b1,16'h0011};
	 //
	 10'd28:index_r <= {1'b0,1'b0,16'h00C5};
	 10'd29:index_r <= {1'b0,1'b1,16'h0040};
	 10'd30:index_r <= {1'b0,1'b1,16'h0030};
	 
	 10'd31:index_r <= {1'b0,1'b0,16'h00C7};
	 10'd32:index_r <= {1'b0,1'b1,16'h00A9};
	 //
	 10'd33:index_r <= {1'b0,1'b0,16'h003A};
	 10'd34:index_r <= {1'b0,1'b1,16'h0055};
	 //
	 10'd35:index_r <= {1'b0,1'b0,16'h0036};
	 10'd36:index_r <= {1'b0,1'b1,16'h0068};//0x48:竖屏 0x68横屏
	 
	 10'd37:index_r <= {1'b0,1'b0,16'h00B1};
	 10'd38:index_r <= {1'b0,1'b1,16'h0000};
	 10'd39:index_r <= {1'b0,1'b1,16'h0018};
	 
	 10'd40:index_r <= {1'b0,1'b0,16'h00B6};
	 10'd41:index_r <= {1'b0,1'b1,16'h000A};
	 10'd42:index_r <= {1'b0,1'b1,16'h00A2};
	 //
	 10'd43:index_r <= {1'b0,1'b0,16'h00F2};
	 10'd44:index_r <= {1'b0,1'b1,16'h0000};
	 //
	 10'd45:index_r <= {1'b0,1'b0,16'h00F7};
	 10'd46:index_r <= {1'b0,1'b1,16'h0020};
	 
	 10'd47:index_r <= {1'b0,1'b0,16'h0026};
	 10'd48:index_r <= {1'b0,1'b1,16'h0001};
	 
	 10'd49:index_r <= {1'b0,1'b0,16'h00E0};
	 10'd50:index_r <= {1'b0,1'b1,16'h001F};
	 10'd51:index_r <= {1'b0,1'b1,16'h0024};
	 10'd52:index_r <= {1'b0,1'b1,16'h0023};
	 10'd53:index_r <= {1'b0,1'b1,16'h000B};
	 10'd54:index_r <= {1'b0,1'b1,16'h000F};
	 10'd55:index_r <= {1'b0,1'b1,16'h0008};
	 10'd56:index_r <= {1'b0,1'b1,16'h0050};
	 10'd57:index_r <= {1'b0,1'b1,16'h00D8};
	 10'd58:index_r <= {1'b0,1'b1,16'h003B};
	 10'd59:index_r <= {1'b0,1'b1,16'h0008};
	 10'D60:index_r <= {1'b0,1'b1,16'h000A};
	 10'D61:index_r <= {1'b0,1'b1,16'h0000};
	 10'D62:index_r <= {1'b0,1'b1,16'h0000};
	 10'D63:index_r <= {1'b0,1'b1,16'h0000};
	 10'D64:index_r <= {1'b0,1'b1,16'h0000};
	 
	 10'D65:index_r <= {1'b0,1'b0,16'h00E1};
	 10'D66:index_r <= {1'b0,1'b1,16'h0000};
	 10'D67:index_r <= {1'b0,1'b1,16'h001B};
	 10'D68:index_r <= {1'b0,1'b1,16'h001C};
	 10'D69:index_r <= {1'b0,1'b1,16'h0004};
	 10'D70:index_r <= {1'b0,1'b1,16'h0010};
	 10'D71:index_r <= {1'b0,1'b1,16'h0007};
	 10'D72:index_r <= {1'b0,1'b1,16'h002F};
	 10'D73:index_r <= {1'b0,1'b1,16'h0027};
	 10'D74:index_r <= {1'b0,1'b1,16'h0044};
	 10'D75:index_r <= {1'b0,1'b1,16'h0007};
	 10'D76:index_r <= {1'b0,1'b1,16'h0015};
	 10'D77:index_r <= {1'b0,1'b1,16'h000F};
	 10'D78:index_r <= {1'b0,1'b1,16'h003F};
	 10'D79:index_r <= {1'b0,1'b1,16'h003F};
	 10'D80:index_r <= {1'b0,1'b1,16'h001F};
	 //
	 10'D81:index_r <= {1'b0,1'b0,16'h0011};
	 
	 10'D82:begin
	     //index_r <= {1'b1,1'b1,16'h0000};
	     if(delay_cnt >= para_time)
		      delay_cnt <= 0;
		  else
		      delay_cnt <= delay_cnt+1;
	 end
	 10'D83:index_r <= {1'b0,1'b0,16'h0029};
	 //
	 10'd84:begin
	     index_r <= {1'b1,1'b1,16'h0000};
	     if(delay_cnt >= para_time)
		      delay_cnt <= 0;
		  else
		      delay_cnt <= delay_cnt+1;
	 end
	 //
	 10'd85:index_r <= {1'b0,1'b0,16'h002A};
	 10'd86:index_r <= {1'b0,1'b1,16'h0000};
	 10'd87:index_r <= {1'b0,1'b1,16'h0000};
	 10'd88:index_r <= {1'b0,1'b1,16'h0001};
	 10'd89:index_r <= {1'b0,1'b1,16'h003F};
	 //
	 10'd90:index_r <= {1'b0,1'b0,16'h002B};
	 10'd91:index_r <= {1'b0,1'b1,16'h0000};
	 10'd92:index_r <= {1'b0,1'b1,16'h0000};
	 10'd93:index_r <= {1'b0,1'b1,16'h0001};
	 10'd94:index_r <= {1'b0,1'b1,16'h003F};
	 //
	 10'd95:begin
	     index_r <= {1'b0,1'b0,16'h002C};
		  init_done_r <= 1'b1;
    end
	 default:index_r <= {1'b1,1'b1,16'hf000};
	 endcase


    end
end
endmodule 