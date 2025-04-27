// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/13.1/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#5 $
// $Revision: #5 $
// $Date: 2013/09/30 $
// $Author: perforce $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module system_qsys_mm_interconnect_0_addr_router_001_default_decode
  #(
     parameter DEFAULT_CHANNEL = 2,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 37 
   )
  (output [102 - 97 : 0] default_destination_id,
   output [40-1 : 0] default_wr_channel,
   output [40-1 : 0] default_rd_channel,
   output [40-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[102 - 97 : 0];

  generate begin : default_decode
    if (DEFAULT_CHANNEL == -1) begin
      assign default_src_channel = '0;
    end
    else begin
      assign default_src_channel = 40'b1 << DEFAULT_CHANNEL;
    end
  end
  endgenerate

  generate begin : default_decode_rw
    if (DEFAULT_RD_CHANNEL == -1) begin
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin
      assign default_wr_channel = 40'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 40'b1 << DEFAULT_RD_CHANNEL;
    end
  end
  endgenerate

endmodule


module system_qsys_mm_interconnect_0_addr_router_001
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [116-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [116-1    : 0] src_data,
    output reg [40-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 61;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 102;
    localparam PKT_DEST_ID_L = 97;
    localparam PKT_PROTECTION_H = 106;
    localparam PKT_PROTECTION_L = 104;
    localparam ST_DATA_W = 116;
    localparam ST_CHANNEL_W = 40;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 64;
    localparam PKT_TRANS_READ  = 65;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h2000000 - 64'h0); 
    localparam PAD1 = log2ceil(64'h2001800 - 64'h2001000); 
    localparam PAD2 = log2ceil(64'h2002000 - 64'h2001800); 
    localparam PAD3 = log2ceil(64'h2002200 - 64'h2002000); 
    localparam PAD4 = log2ceil(64'h2002220 - 64'h2002200); 
    localparam PAD5 = log2ceil(64'h2002240 - 64'h2002220); 
    localparam PAD6 = log2ceil(64'h2002260 - 64'h2002240); 
    localparam PAD7 = log2ceil(64'h2002280 - 64'h2002260); 
    localparam PAD8 = log2ceil(64'h20022a0 - 64'h2002280); 
    localparam PAD9 = log2ceil(64'h20022b0 - 64'h20022a0); 
    localparam PAD10 = log2ceil(64'h20022c0 - 64'h20022b0); 
    localparam PAD11 = log2ceil(64'h20022d0 - 64'h20022c0); 
    localparam PAD12 = log2ceil(64'h20022e0 - 64'h20022d0); 
    localparam PAD13 = log2ceil(64'h20022f0 - 64'h20022e0); 
    localparam PAD14 = log2ceil(64'h2002300 - 64'h20022f0); 
    localparam PAD15 = log2ceil(64'h2002310 - 64'h2002300); 
    localparam PAD16 = log2ceil(64'h2002320 - 64'h2002310); 
    localparam PAD17 = log2ceil(64'h2002330 - 64'h2002320); 
    localparam PAD18 = log2ceil(64'h2002340 - 64'h2002330); 
    localparam PAD19 = log2ceil(64'h2002350 - 64'h2002340); 
    localparam PAD20 = log2ceil(64'h2002360 - 64'h2002350); 
    localparam PAD21 = log2ceil(64'h2002370 - 64'h2002360); 
    localparam PAD22 = log2ceil(64'h2002380 - 64'h2002370); 
    localparam PAD23 = log2ceil(64'h2002390 - 64'h2002380); 
    localparam PAD24 = log2ceil(64'h20023a0 - 64'h2002390); 
    localparam PAD25 = log2ceil(64'h20023b0 - 64'h20023a0); 
    localparam PAD26 = log2ceil(64'h20023c0 - 64'h20023b0); 
    localparam PAD27 = log2ceil(64'h20023d0 - 64'h20023c0); 
    localparam PAD28 = log2ceil(64'h20023e0 - 64'h20023d0); 
    localparam PAD29 = log2ceil(64'h20023f0 - 64'h20023e0); 
    localparam PAD30 = log2ceil(64'h2002400 - 64'h20023f0); 
    localparam PAD31 = log2ceil(64'h2002410 - 64'h2002400); 
    localparam PAD32 = log2ceil(64'h2002420 - 64'h2002410); 
    localparam PAD33 = log2ceil(64'h2002430 - 64'h2002420); 
    localparam PAD34 = log2ceil(64'h2002440 - 64'h2002430); 
    localparam PAD35 = log2ceil(64'h2002450 - 64'h2002440); 
    localparam PAD36 = log2ceil(64'h2002460 - 64'h2002450); 
    localparam PAD37 = log2ceil(64'h2002470 - 64'h2002460); 
    localparam PAD38 = log2ceil(64'h2002478 - 64'h2002470); 
    localparam PAD39 = log2ceil(64'h2002480 - 64'h2002478); 
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h2002480;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam RG = RANGE_ADDR_WIDTH-1;
    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [40-1 : 0] default_src_channel;




    // -------------------------------------------------------
    // Write and read transaction signals
    // -------------------------------------------------------
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    system_qsys_mm_interconnect_0_addr_router_001_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

    // ( 0x0 .. 0x2000000 )
    if ( {address[RG:PAD0],{PAD0{1'b0}}} == 26'h0   ) begin
            src_channel = 40'b0000000000000000000000000000000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 37;
    end

    // ( 0x2001000 .. 0x2001800 )
    if ( {address[RG:PAD1],{PAD1{1'b0}}} == 26'h2001000   ) begin
            src_channel = 40'b0000000000000000000000000000000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
    end

    // ( 0x2001800 .. 0x2002000 )
    if ( {address[RG:PAD2],{PAD2{1'b0}}} == 26'h2001800   ) begin
            src_channel = 40'b0000000000000000000000000000000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
    end

    // ( 0x2002000 .. 0x2002200 )
    if ( {address[RG:PAD3],{PAD3{1'b0}}} == 26'h2002000   ) begin
            src_channel = 40'b0000000010000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
    end

    // ( 0x2002200 .. 0x2002220 )
    if ( {address[RG:PAD4],{PAD4{1'b0}}} == 26'h2002200   ) begin
            src_channel = 40'b0000000000000000000000000000001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 39;
    end

    // ( 0x2002220 .. 0x2002240 )
    if ( {address[RG:PAD5],{PAD5{1'b0}}} == 26'h2002220   ) begin
            src_channel = 40'b0000000000000000000000000000000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
    end

    // ( 0x2002240 .. 0x2002260 )
    if ( {address[RG:PAD6],{PAD6{1'b0}}} == 26'h2002240   ) begin
            src_channel = 40'b0000000000000000000000000000000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
    end

    // ( 0x2002260 .. 0x2002280 )
    if ( {address[RG:PAD7],{PAD7{1'b0}}} == 26'h2002260   ) begin
            src_channel = 40'b0000000000000000000000000000000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
    end

    // ( 0x2002280 .. 0x20022a0 )
    if ( {address[RG:PAD8],{PAD8{1'b0}}} == 26'h2002280   ) begin
            src_channel = 40'b0000000000000000000000000000000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
    end

    // ( 0x20022a0 .. 0x20022b0 )
    if ( {address[RG:PAD9],{PAD9{1'b0}}} == 26'h20022a0   ) begin
            src_channel = 40'b1000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
    end

    // ( 0x20022b0 .. 0x20022c0 )
    if ( {address[RG:PAD10],{PAD10{1'b0}}} == 26'h20022b0   ) begin
            src_channel = 40'b0100000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 30;
    end

    // ( 0x20022c0 .. 0x20022d0 )
    if ( {address[RG:PAD11],{PAD11{1'b0}}} == 26'h20022c0  && read_transaction  ) begin
            src_channel = 40'b0010000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 34;
    end

    // ( 0x20022d0 .. 0x20022e0 )
    if ( {address[RG:PAD12],{PAD12{1'b0}}} == 26'h20022d0   ) begin
            src_channel = 40'b0001000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 35;
    end

    // ( 0x20022e0 .. 0x20022f0 )
    if ( {address[RG:PAD13],{PAD13{1'b0}}} == 26'h20022e0   ) begin
            src_channel = 40'b0000100000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 32;
    end

    // ( 0x20022f0 .. 0x2002300 )
    if ( {address[RG:PAD14],{PAD14{1'b0}}} == 26'h20022f0   ) begin
            src_channel = 40'b0000010000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 33;
    end

    // ( 0x2002300 .. 0x2002310 )
    if ( {address[RG:PAD15],{PAD15{1'b0}}} == 26'h2002300   ) begin
            src_channel = 40'b0000001000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 21;
    end

    // ( 0x2002310 .. 0x2002320 )
    if ( {address[RG:PAD16],{PAD16{1'b0}}} == 26'h2002310   ) begin
            src_channel = 40'b0000000100000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 20;
    end

    // ( 0x2002320 .. 0x2002330 )
    if ( {address[RG:PAD17],{PAD17{1'b0}}} == 26'h2002320   ) begin
            src_channel = 40'b0000000001000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 17;
    end

    // ( 0x2002330 .. 0x2002340 )
    if ( {address[RG:PAD18],{PAD18{1'b0}}} == 26'h2002330   ) begin
            src_channel = 40'b0000000000100000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 18;
    end

    // ( 0x2002340 .. 0x2002350 )
    if ( {address[RG:PAD19],{PAD19{1'b0}}} == 26'h2002340   ) begin
            src_channel = 40'b0000000000010000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 14;
    end

    // ( 0x2002350 .. 0x2002360 )
    if ( {address[RG:PAD20],{PAD20{1'b0}}} == 26'h2002350   ) begin
            src_channel = 40'b0000000000001000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 16;
    end

    // ( 0x2002360 .. 0x2002370 )
    if ( {address[RG:PAD21],{PAD21{1'b0}}} == 26'h2002360  && read_transaction  ) begin
            src_channel = 40'b0000000000000100000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 15;
    end

    // ( 0x2002370 .. 0x2002380 )
    if ( {address[RG:PAD22],{PAD22{1'b0}}} == 26'h2002370   ) begin
            src_channel = 40'b0000000000000010000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 22;
    end

    // ( 0x2002380 .. 0x2002390 )
    if ( {address[RG:PAD23],{PAD23{1'b0}}} == 26'h2002380   ) begin
            src_channel = 40'b0000000000000001000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 25;
    end

    // ( 0x2002390 .. 0x20023a0 )
    if ( {address[RG:PAD24],{PAD24{1'b0}}} == 26'h2002390   ) begin
            src_channel = 40'b0000000000000000100000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 26;
    end

    // ( 0x20023a0 .. 0x20023b0 )
    if ( {address[RG:PAD25],{PAD25{1'b0}}} == 26'h20023a0   ) begin
            src_channel = 40'b0000000000000000010000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 24;
    end

    // ( 0x20023b0 .. 0x20023c0 )
    if ( {address[RG:PAD26],{PAD26{1'b0}}} == 26'h20023b0   ) begin
            src_channel = 40'b0000000000000000001000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 27;
    end

    // ( 0x20023c0 .. 0x20023d0 )
    if ( {address[RG:PAD27],{PAD27{1'b0}}} == 26'h20023c0   ) begin
            src_channel = 40'b0000000000000000000100000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 23;
    end

    // ( 0x20023d0 .. 0x20023e0 )
    if ( {address[RG:PAD28],{PAD28{1'b0}}} == 26'h20023d0  && read_transaction  ) begin
            src_channel = 40'b0000000000000000000010000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 29;
    end

    // ( 0x20023e0 .. 0x20023f0 )
    if ( {address[RG:PAD29],{PAD29{1'b0}}} == 26'h20023e0   ) begin
            src_channel = 40'b0000000000000000000001000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 28;
    end

    // ( 0x20023f0 .. 0x2002400 )
    if ( {address[RG:PAD30],{PAD30{1'b0}}} == 26'h20023f0   ) begin
            src_channel = 40'b0000000000000000000000100000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 31;
    end

    // ( 0x2002400 .. 0x2002410 )
    if ( {address[RG:PAD31],{PAD31{1'b0}}} == 26'h2002400   ) begin
            src_channel = 40'b0000000000000000000000010000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 12;
    end

    // ( 0x2002410 .. 0x2002420 )
    if ( {address[RG:PAD32],{PAD32{1'b0}}} == 26'h2002410   ) begin
            src_channel = 40'b0000000000000000000000001000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 19;
    end

    // ( 0x2002420 .. 0x2002430 )
    if ( {address[RG:PAD33],{PAD33{1'b0}}} == 26'h2002420  && read_transaction  ) begin
            src_channel = 40'b0000000000000000000000000100000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 13;
    end

    // ( 0x2002430 .. 0x2002440 )
    if ( {address[RG:PAD34],{PAD34{1'b0}}} == 26'h2002430   ) begin
            src_channel = 40'b0000000000000000000000000010000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
    end

    // ( 0x2002440 .. 0x2002450 )
    if ( {address[RG:PAD35],{PAD35{1'b0}}} == 26'h2002440   ) begin
            src_channel = 40'b0000000000000000000000000001000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 36;
    end

    // ( 0x2002450 .. 0x2002460 )
    if ( {address[RG:PAD36],{PAD36{1'b0}}} == 26'h2002450   ) begin
            src_channel = 40'b0000000000000000000000000000100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
    end

    // ( 0x2002460 .. 0x2002470 )
    if ( {address[RG:PAD37],{PAD37{1'b0}}} == 26'h2002460   ) begin
            src_channel = 40'b0000000000000000000000000000010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
    end

    // ( 0x2002470 .. 0x2002478 )
    if ( {address[RG:PAD38],{PAD38{1'b0}}} == 26'h2002470  && read_transaction  ) begin
            src_channel = 40'b0000000000000000000000000000000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 38;
    end

    // ( 0x2002478 .. 0x2002480 )
    if ( {address[RG:PAD39],{PAD39{1'b0}}} == 26'h2002478   ) begin
            src_channel = 40'b0000000000000000000000000000000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
    end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


