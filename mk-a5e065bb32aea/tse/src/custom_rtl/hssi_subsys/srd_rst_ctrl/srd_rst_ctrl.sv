//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

`timescale 1ns/1ps

module srd_rst_ctrl #(
  parameter               NUM_CHANNELS =2    
) (
  //input                        i_pll_locked,
  //input                        i_sys_rst_n,
  input                          pwrgood_rst_n,
  input  [NUM_CHANNELS -1:0]  i_sys_rst_n, 
  input  [NUM_CHANNELS -1:0]  i_sys_tx_rst_n,
  input  [NUM_CHANNELS -1:0]  i_sys_rx_rst_n,
  input  [NUM_CHANNELS -1:0]  i_clk_csr,
  input  [NUM_CHANNELS -1:0]  i_clk_100,
  input  [NUM_CHANNELS -1:0]  i_clk_125,
  //input  [NUM_CHANNELS -1:0]   i_tx_pll_locked,
  output [NUM_CHANNELS -1:0]   o_eth_rx_rst_n,
  output [NUM_CHANNELS -1:0]   o_eth_tx_rst_n,
  output [NUM_CHANNELS -1:0]   o_eth_rst_n,
  output [NUM_CHANNELS -1:0]   o_eth_csr_rst_n,
  input [NUM_CHANNELS -1:0]    i_rst_ack_n,
  input [NUM_CHANNELS -1:0]    i_tx_rst_ack,     
  input [NUM_CHANNELS -1:0]    i_rx_rst_ack,    
  output [NUM_CHANNELS -1:0]   o_user_tx_rst_n_125,
  output [NUM_CHANNELS -1:0]   o_user_rx_rst_n_125,
    output [NUM_CHANNELS -1:0]  o_user_tx_rst_n_100,
  output [NUM_CHANNELS -1:0]   o_user_rx_rst_n_100
  
    );

    logic  [NUM_CHANNELS-1:0]   sync_ack_n;
	 logic  [NUM_CHANNELS-1:0]   sync_tx_ack;     
	 logic  [NUM_CHANNELS-1:0]   sync_rx_ack;     
	 
	 
	 logic  [NUM_CHANNELS-1:0]   sync_i_sys_rst_n;
	 logic  [NUM_CHANNELS-1:0]   sync_i_sys_tx_rst_n;
	 logic  [NUM_CHANNELS-1:0]   sync_i_sys_rx_rst_n;


    generate for (genvar i=0;i<NUM_CHANNELS;i++) begin : eth_reset_sync
    
    eth_f_altera_std_synchronizer_nocut eth_ack_rstn_sync (
     .clk                       ( i_clk_csr[i]),
     .reset_n                   ( 1'b1 ),
     .din                       ( i_rst_ack_n[i] ),
     .dout                      ( sync_ack_n[i])
    );
	 
    eth_f_altera_std_synchronizer_nocut eth_user_rstn_sync (
     .clk                       ( i_clk_csr[i]),
     .reset_n                   ( 1'b1 ),
     .din                       (i_sys_rst_n[i] ),
     .dout                      (sync_i_sys_rst_n[i])
    );

    srd_rst_seq eth_rst_seq (
    .i_clk                     ( i_clk_csr[i]),
    .i_pwrgood_rst_n           ( pwrgood_rst_n),
    .i_rst_n                   ( sync_i_sys_rst_n[i]),
    .o_rst_n                   ( o_eth_rst_n[i] ),
    .i_rst_ack_n               ( sync_ack_n[i]),
    .o_rst_done                ( )
	);


	  
   eth_f_altera_std_synchronizer_nocut eth_tx_ack_rstn_sync (
     .clk                       ( i_clk_csr[i]),
     .reset_n                   ( 1'b1 ),
     .din                       (i_tx_rst_ack[i] ),    
     .dout                      (sync_tx_ack[i])       
    );
	 
  eth_f_altera_std_synchronizer_nocut eth_user_tx_rstn_sync (
     .clk                       ( i_clk_csr[i]),
     .reset_n                   ( 1'b1 ),
     .din                       (i_sys_tx_rst_n[i] ),
     .dout                      (sync_i_sys_tx_rst_n[i])
    );
  
    srd_rst_seq eth_tx_rst_seq (
    .i_clk                     ( i_clk_csr[i]),
    .i_pwrgood_rst_n           ( pwrgood_rst_n),
    .i_rst_n                   ( sync_i_sys_tx_rst_n[i]),
    .o_rst_n                   ( o_eth_tx_rst_n[i] ),
    .i_rst_ack_n               ( !sync_tx_ack[i]),     
    .o_rst_done                ( )
	);


  eth_f_altera_std_synchronizer_nocut eth_rx_ack_rstn_sync (
      .clk                       ( i_clk_csr[i]),
      .reset_n                   ( 1'b1 ),
      .din                       (i_rx_rst_ack[i] ),     
      .dout                      ( sync_rx_ack[i])       
    );
	 
	eth_f_altera_std_synchronizer_nocut eth_user_rx_rstn_sync (
      .clk                       ( i_clk_csr[i]),
      .reset_n                   ( 1'b1 ),
      .din                       (i_sys_rx_rst_n[i] ),
      .dout                      (sync_i_sys_rx_rst_n[i])
    );
  
    srd_rst_seq eth_rx_rst_seq (
    .i_clk                     ( i_clk_csr[i]),
    .i_pwrgood_rst_n           ( pwrgood_rst_n ),
    .i_rst_n                   ( sync_i_sys_rx_rst_n[i]),
    .o_rst_n                   ( o_eth_rx_rst_n[i] ),
    .i_rst_ack_n               ( !sync_rx_ack[i]),  
    .o_rst_done                ( )
	 );
	
	 //assign o_user_tx_rst_n_100 [i] = sync_i_sys_tx_rst_n[i];
	 //assign o_user_rx_rst_n_100 [i] = sync_i_sys_rx_rst_n[i];	

    // Reset synchronizer with 125Mhz
    eth_f_altera_std_synchronizer_nocut eth_user_tx_rstn_sync_125M (
     .clk                       ( i_clk_125[i]),
     .reset_n                   ( 1'b1 ),
     .din                       (i_sys_tx_rst_n[i] ),
     .dout                      (o_user_tx_rst_n_125[i])
    );
	 
    eth_f_altera_std_synchronizer_nocut eth_user_rx_rstn_sync_125M (
     .clk                       ( i_clk_125[i]),
     .reset_n                   ( 1'b1 ),
     .din                       (i_sys_rx_rst_n[i] ),
     .dout                      (o_user_rx_rst_n_125[i])
    );
	 
    // Reset synchronizer with 100Mhz
    eth_f_altera_std_synchronizer_nocut eth_user_tx_rstn_sync_100M (
     .clk                       ( i_clk_100[i]),
     .reset_n                   ( 1'b1 ),
     .din                       (i_sys_tx_rst_n[i] ),
     .dout                      (o_user_tx_rst_n_100[i])
    );
	 
	 eth_f_altera_std_synchronizer_nocut eth_user_rx_rstn_sync_100M (
     .clk                       ( i_clk_100[i]),
     .reset_n                   ( 1'b1 ),
     .din                       (i_sys_rx_rst_n[i] ),
     .dout                      (o_user_rx_rst_n_100[i])
    );
    end endgenerate

  assign o_eth_csr_rst_n = o_eth_rx_rst_n; 
 

  

  endmodule
