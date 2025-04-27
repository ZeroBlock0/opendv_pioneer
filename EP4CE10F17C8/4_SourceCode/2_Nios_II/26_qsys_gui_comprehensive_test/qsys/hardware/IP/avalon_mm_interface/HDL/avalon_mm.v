module avalon_mm(input              clk50M,
                 input              rst_n,
					  input              avalon_write,
					  input              avalon_read,
					  input  [31:0]      avalon_writedata,
					  output [31:0]      avalon_readdata,
					  input [width-1:0]  avalon_address,
					  output             write,
					  output             read,
					  output [31:0]      writedata,
					  input  [31:0]      readdata,
					  output [width-1:0] address
					  ) ;
parameter width = 9;
assign avalon_readdata = readdata;
assign write           = avalon_write;
assign read            = avalon_read;
assign writedata      = avalon_writedata;
assign address         = avalon_address;
endmodule 