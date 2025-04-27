module avalon_interface(
								input         clk,
                        input         reset_n,
								input         read,
								input  [1:0]  address,
								input         write,
								output [15:0] readdata,
								input  [31:0] writedata,
								input         init_done,
								input         wr_able,
								output        ref_addr,
								output        wr_en,
								output [16:0] wr_address,
								output [15:0] wr_data
								);
								
	parameter idle      = 3'd0;
	parameter wr_addr_s = 3'd1;
	parameter wr_data_s = 3'd2;

	parameter step1     = 2'd0;
	parameter step2     = 2'd1;
	parameter step3     = 2'd2;

	reg [15:0] status;	 //只可读，不可写,地址2'd0
	reg [16:0] AC;			 //只可写，不可读，地址2'd1
	reg [15:0] wr_buffer; //只可写，不可读，地址2'd2

	reg [15:0] readdata_r;
	reg        wr_en_r;
	reg [16:0] wr_address_r;
	reg [15:0] wr_data_r;
	reg [2:0]  state;
	reg [1:0]  step;
	reg        ref_addr_r;

	assign wr_en      = wr_en_r;
	assign wr_address = wr_address_r;
	assign wr_data    = wr_data_r;
	assign ref_addr   = ref_addr_r;
	assign readdata   = readdata_r;

always@(posedge clk or negedge reset_n)
begin
	if(!reset_n)
	  begin
		 wr_en_r      <= 1'b0;
		 wr_address_r <= 17'd0;
		 wr_data_r    <= 16'd0;
		 ref_addr_r   <= 1'b0;
		 status       <= 16'h2; 
		 step         <= step1;
		 state        <= idle;
	  end
	else
	  begin
		 status[0]    <= init_done;
		 
		 if(read == 1'b1 && address == 2'd0)
			  readdata_r <= status;
		 else 
			  if(read == 1'b1 && address == 2'd2)
					readdata_r <= wr_buffer;
			  
		 case(state)
		 idle:
			 begin
					if(write == 1'b1 && address == 2'd1)
						begin
							AC          <= writedata[16:0];
							status[1:0] <= {1'b0,init_done};
							state       <= wr_addr_s;
						end
				  else if(write == 1'b1 && address == 2'd2)
						begin
							status[1:0] <= {1'b0,init_done};
							wr_buffer   <= writedata[15:0]; 
							state       <= wr_data_s;
						end
			 end
			 
		 wr_addr_s:
			 begin
				  case(step)
				  step1:
						begin
							 ref_addr_r   <= 1'b1;
							 wr_en_r      <= 1'b1;
							 wr_address_r <= AC;
							 step         <= step2;
						  end
				  step2:
						 begin
							ref_addr_r   <= 1'b0;
							wr_en_r      <= 1'b0;
							step         <= step3;
						 end
				  step3:
						 begin
							if(wr_able == 1'b1)
								 begin
									 step        <= step1;
									 state       <= idle;
									 status[1:0] <= 2'b11;
								 end
						 end
				  default:;
				  endcase
			 end
			 
		 wr_data_s:
			begin
				  case(step)
				  step1:
						begin
							ref_addr_r   <= 1'b0;
							wr_en_r      <= 1'b1;
							wr_data_r    <= wr_buffer;
							step         <= step2;
						end
				  step2:
						begin
							ref_addr_r   <= 1'b0;
							wr_en_r      <= 1'b0;
							step         <= step3;
						end
				  step3:
					  begin
							if(wr_able == 1'b1)
								 begin
									 step        <= step1;
									 state       <= idle;
									 status[1:0] <= 2'b11;
								 end
					  end
				  default:;
				  endcase
			 end
		 default:;
		 endcase
	end
end

endmodule 