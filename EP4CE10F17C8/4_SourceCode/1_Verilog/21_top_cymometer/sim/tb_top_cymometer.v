// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "04/11/2018 17:07:12"
                                                                                
// Verilog Test Bench template for design : top_cymometer
// 
// Simulation tool : ModelSim (Verilog)
// 

`timescale 1 ns/ 1 ns
`define  clk_period 20
module tb_top_cymometer();

// constants                                           
// general purpose registers
// test vector input registers
reg clk_fx;
reg sys_clk;
reg sys_rst_n;
// wires                                               
wire clk_out;
//wire [7:0]  seg7_d;
//wire [5:0]  seg7_w;

// assign statements (if any)                          


initial                                                
begin                                                  
// code that executes only once                        
// insert code here --> begin                          
    sys_rst_n = 1'b0;
    #(`clk_period * 10 + 1'b1);
    sys_rst_n = 1'b1;                                                       
// --> end                                             
$display("Running testbench");                       
end 

always clk_fx = clk_out;

initial sys_clk = 1'b1;                                                   
always #(`clk_period/2) sys_clk = ~sys_clk;                                               
// optional sensitivity list                           
// @(event1 or event2 or .... eventn)                  
// code executes for every event on sensitivity list   
// insert code here --> begin                          

top_cymometer i1 (
// port map - connection between master ports and signals/registers   
	.clk_fx(clk_fx),
	.clk_out(clk_out),
//	.seg7_d(seg7_d),
//	.seg7_w(seg7_w),
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n)
);
                                                          
// --> end                                             
endmodule

