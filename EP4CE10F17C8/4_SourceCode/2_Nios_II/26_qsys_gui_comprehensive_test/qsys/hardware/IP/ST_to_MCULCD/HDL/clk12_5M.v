module clk12_5M(input clk50M,
                input rst_n,
					 output clk12_5);
reg clk12_5_r;
reg [2:0] div_cnt;
assign clk12_5 = clk12_5_r;
always@(posedge clk50M or negedge rst_n)
begin
if(!rst_n)
    begin
	 clk12_5_r <= 1'b0;
	 div_cnt   <= 3'd0;
	 end
else
    begin
	 if(div_cnt >= 3'd3)
	     begin
		  div_cnt <= 3'd0;
		  clk12_5_r <= ~clk12_5_r;
		  end
	 else
	     begin
		  div_cnt <= div_cnt+3'd1;
        end
    end
end
endmodule 