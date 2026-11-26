//****************************************************************************
//
// SPDX-License-Identifier: MIT-0
// Copyright(c) 2019-2021 Intel Corporation.
//
//****************************************************************************
// This is a generated system top level RTL file. 

// Derive channel and width from hps_emif_topology

// Find and print each number individually

/*

	top -----+
		 |
		 +----- System Reset Synchronizer (sys_rst_inst)
		 |
		 +----- Synchronizers
		 |	|
		 |	+----- tx_lanes_stable
		 |	|
		 |	+----- tx_pll_locked
		 |	|
		 |	+----- rx_pcs_ready
		 |	|
		 |	+----- sync_iopll_lock_100M
		 |	|
		 |	+----- sync_iopll_lock_125M
		 |	|
		 |	+----- sync_iopll_lock_161_0
		 |	|
		 |	+----- sync_iopll_lock_161_1
		 |
	  	 +----- QSYS Top (soc_inst)
		 |
		 +----- GTS Reset Sequencer (reset_sequencer)
		 |
		 +----- GTS System PLL (system_pll)
		 |
		 +----- AVMM MDIO Bridge (u_avmm_mdio_bridge)


*/

import sm_tse_pkg::*;

module top #(
   `ifdef NUM_CHANNELS_2
    parameter NUM_CHANNELS = 2,
   `else
    parameter NUM_CHANNELS = 1,
   `endif
    parameter TS_REQ_FP_WIDTH = 20
   ,parameter RXIGR_TS_DW  = 96
)
(
//Reset&Clock
input          fpga_reset_n             , // Reset
input          clk_hvio_6a_100m         , // Clock

//Memory interface: DDR4 COMP Bank 3A
input          clk_3a_ddr4_150m_dp      , 
output         m_1_ddr4_clk_dp          , 
output         m_1_ddr4_clk_dn          , 
output [16:0]  m_1_ddr4_a               , 
output         m_1_ddr4_act_n           , 
output [1:0]   m_1_ddr4_ba              , 
output [1:0]   m_1_ddr4_bg              , 
output         m_1_ddr4_cke             , 
output         m_1_ddr4_cs_n            , 
output         m_1_ddr4_odt             , 
output         m_1_ddr4_reset_n         , 
output         m_1_ddr4_par             , 
input          m_1_ddr4_alert_n         , 
inout  [3:0]   m_1_ddr4_dqs_p           , // was [4:0]
inout  [3:0]   m_1_ddr4_dqs_n           , // was [4:0]
inout  [31:0]  m_1_ddr4_dq              , // was [39:0]
input          rzq_b_3a                 , 

//HPS GPIO
input          clk_hps_100m             ,

output         uart_ft4232_txd          ,
input          uart_ft4232_rxd          ,

output         hps_1pps_out             ,
input          hps_1pps_in              ,

inout          phy_mdio                 ,
output         phy_mdc                  ,

inout          hps_i2c_sda              ,
inout          hps_i2c_scl              ,

output         m_sd_clk                 ,
inout          m_sd_cmd                 ,
inout          m_sd_data0               ,
inout          m_sd_data1               ,
inout          m_sd_data2               ,
inout          m_sd_data3               ,

input          jtag_hps_tck             ,
input          jtag_hps_tms             ,
output         jtag_hps_tdo             ,
input          jtag_hps_tdi             ,

output         rgmii_tx_clk             ,
output         rgmii_tx_ctrl            ,
input          rgmii_rx_clk             ,
input          rgmii_rx_ctrl            ,
output         rgmii_txd_0              ,
output         rgmii_txd_1              ,
input          rgmii_rxd_0              ,
input          rgmii_rxd_1              ,
output         rgmii_txd_2              ,
output         rgmii_txd_3              ,
input          rgmii_rxd_2              ,
input          rgmii_rxd_3              ,
        
//Reference clock on Bank 1A
//input          clk_ux_1a_r_dp, 
//input          clk_ux_1a_r_dn,
input          clk_ux_1a_g_dp, 
//input          clk_ux_1a_g_dn,
        
//Reference clock on Bank 1B
//input          clk_ux_1b_r_dp, 
//input          clk_ux_1b_r_dn,
//input          clk_ux_1b_g_dp, 
//input          clk_ux_1b_g_dn,
        
//Reference clock on Bank 1C shared by SFP/SGMII/USB
//input          clk_ux_1c_r_dp           ,
//input          clk_ux_1c_r_dn           ,
//input          clk_ux_1c_g_100m_dp      ,
//input          clk_ux_1c_g_100m_dn      ,
//output         ux_1c_clkout_ch2_dp      ,
//output         ux_1c_clkout_ch2_dn      ,
      
//ETH SGMII
input          eth0_sgmii_rx_dp         , 
input          eth0_sgmii_rx_dn         ,
output         eth0_sgmii_tx_dp         , 
output         eth0_sgmii_tx_dn         ,
`ifdef NUM_CHANNELS_2
input          eth1_sgmii_rx_dp         ,
input          eth1_sgmii_rx_dn         ,  
output         eth1_sgmii_tx_dp         , 
output         eth1_sgmii_tx_dn         ,
`endif 
inout          eth_mdio                 ,
output         eth_mdc                  , 
//input          eth0_int_n               , 
//input          eth1_int_n               , 

//Miscellaneous
inout   wire            hps_gpio0_io0,    // hps_heart_beat_led
inout   wire            hps_gpio0_io1,    // eth_int_n
inout   wire            hps_gpio0_io10,   // hps_rst_out_n
inout   wire            hps_gpio1_io3,    // intn_c2m
inout   wire            hps_gpio1_io4     // hps_push_button
);

//----------------------+
//     Top Wires        |
//----------------------+
wire                    	   system_clk_100m;
wire                    	   ninit_done;
wire                   	 	   system_reset;

wire                         	iopll_locked_export;
wire 			     	            iopll_locked_export_100M;
wire 			     	            iopll_locked_export_125M;

wire                         	h2f_reset;

wire                         	clk_125m;
wire                         	clk_100m;

wire  [NUM_CHANNELS-1:0]      i_clk_125m;
wire  [NUM_CHANNELS-1:0]      i_clk_100m;

wire                          i_clk_ref_p;      // 156.25 MHz

wire                          system_pll_lock;

wire  [NUM_CHANNELS-1:0]     	i_src_rs_grant;
wire      			            i_pma_cu_clk;
wire  [NUM_CHANNELS-1:0]     	o_src_rs_req;

wire                         	user_space_csr_m0_waitrequest;
wire  [31:0]	             	user_space_csr_m0_readdata;
wire                         	user_space_csr_m0_readdatavalid;
wire                         	user_space_csr_m0_burstcount;
wire  [31:0]	             	user_space_csr_m0_writedata;
wire  [11:0]                  user_space_csr_m0_address;
wire                          user_space_csr_m0_write;
wire                          user_space_csr_m0_read;
wire  [3:0]                   user_space_csr_m0_byteenable;
wire                          user_space_csr_m0_debugaccess;
   
wire  [NUM_CHANNELS -1:0]    	o_user_tx_rst_n_100;
wire  [NUM_CHANNELS -1:0]    	o_user_rx_rst_n_100;
wire  [NUM_CHANNELS -1:0]    	o_user_rx_rst_n_125;
wire  [NUM_CHANNELS -1:0]    	o_user_tx_rst_n_125;

wire  [NUM_CHANNELS -1:0]    	eth_user_tx_rst_n;
wire  [NUM_CHANNELS -1:0]    	eth_user_rx_rst_n;
wire  [NUM_CHANNELS -1:0]    	fifo_tx_user_reset;
wire  [NUM_CHANNELS -1:0]    	fifo_rx_user_reset;

wire  [NUM_CHANNELS-1:0]     	i_rst_n;    // unused
wire  [NUM_CHANNELS-1:0]     	i_tx_rst_n;
wire  [NUM_CHANNELS-1:0]     	i_rx_rst_n;
                   
wire  [NUM_CHANNELS-1:0]     	rst_ack;    // unused
wire  [NUM_CHANNELS-1:0]     	tx_rst_ack;
wire  [NUM_CHANNELS-1:0]    	rx_rst_ack;

wire  [NUM_CHANNELS-1:0]  	   o_csr_rst_n;
wire  [NUM_CHANNELS-1:0]    	o_csr_tx_rst_n;
wire  [NUM_CHANNELS-1:0]    	o_csr_rx_rst_n;

    
wire                          port0_tx_dma_fifo_0_out_ts_req_valid;       
wire  [19:0]                  port0_tx_dma_fifo_0_out_ts_req_fingerprint; 
wire                          port1_tx_dma_fifo_0_out_ts_req_valid;        
wire  [19:0]                  port1_tx_dma_fifo_0_out_ts_req_fingerprint;  

wire  [NUM_CHANNELS-1:0]                        tx_ts_valid ;
wire  [NUM_CHANNELS-1:0][TS_REQ_FP_WIDTH-1:0]  	tx_ts_fp ;
wire  [NUM_CHANNELS-1:0][RXIGR_TS_DW-1:0]      	tx_ts_data ;

wire  [NUM_CHANNELS-1:0]                        i_reconfig_clk;

//----------------------+
// 	TSE 0/1		      |
//----------------------+
wire  [NUM_CHANNELS*1-1:0] 	tse_tx_pll_locked;

wire  [NUM_CHANNELS*1-1:0]	   tse_rx_is_lockedtodata;
wire  [NUM_CHANNELS*1-1:0]    tse_rx_is_lockedtoref;

wire  [NUM_CHANNELS*1-1:0]	   tse_tx_ready;
wire  [NUM_CHANNELS*1-1:0]	   tse_rx_ready;

//----------------------+
//     PHY MDIO	      |
//----------------------+
wire  [NUM_CHANNELS-1:0]	   phy_mdio_mdi;
wire  [NUM_CHANNELS-1:0]	   phy_mdio_mdo;
wire  [NUM_CHANNELS-1:0]	   phy_mdio_mdc;
wire  [NUM_CHANNELS-1:0]	   phy_mdio_mdoen;

//----------------------+
//     Misc. Assigns	   |
//----------------------+
assign system_clk_100m  = clk_hvio_6a_100m;
assign i_clk_ref_p      = clk_ux_1a_g_dp;

assign combined_reset_n = fpga_reset_n & ~h2f_reset & ~ninit_done;

// MDIO Signals
assign eth_mdio 	      = !phy_mdio_mdoen ? phy_mdio_mdo : 1'bz;
assign eth_mdc 	      = phy_mdio_mdc;
assign phy_mdio_mdi   	= eth_mdio;

// Per TSE Signals
generate
for(genvar i=0;i<NUM_CHANNELS;i++)
begin
   assign i_reconfig_clk[i]   = clk_100m;
   assign i_clk_125m[i]       = clk_125m;
   assign i_clk_100m[i]       = clk_100m;

   assign eth_user_tx_rst_n [i]  = o_user_tx_rst_n_100[i] & iopll_locked_export_100M;
   assign eth_user_rx_rst_n [i]  = o_user_rx_rst_n_100[i] & iopll_locked_export_100M;
   
   assign fifo_tx_user_reset [i] = o_user_tx_rst_n_100[i] & iopll_locked_export_100M;
   assign fifo_rx_user_reset [i] = o_user_rx_rst_n_100[i] & iopll_locked_export_100M;  
   
end
endgenerate

// Timestamp Completion
assign tx_ts_valid[0]   = port0_tx_dma_fifo_0_out_ts_req_valid;
assign tx_ts_fp[0]      = port0_tx_dma_fifo_0_out_ts_req_fingerprint;
assign tx_ts_data[0]    = '0;
`ifdef NUM_CHANNELS_2
assign tx_ts_valid[1]   = port1_tx_dma_fifo_0_out_ts_req_valid;
assign tx_ts_fp[1]      = port1_tx_dma_fifo_0_out_ts_req_fingerprint;
assign tx_ts_data[1]    = '0;
`endif

// ********************************************************************* //
//                   GTS Reset Sequencer
// ********************************************************************* //
`ifdef NUM_CHANNELS_2 gts_reset_sequencer `else gts_reset_sequencer_0 `endif
reset_sequencer (
   .o_src_rs_grant    (i_src_rs_grant),    
   .i_src_rs_priority ('0),             
   .i_src_rs_req      (o_src_rs_req),      
   .o_pma_cu_clk      (i_pma_cu_clk)       
);

// ********************************************************************* //
//                   Reset Controller
// ********************************************************************* //  
srd_rst_ctrl #(
  .NUM_CHANNELS (NUM_CHANNELS)
)inst_srd_rst_ctrl
(
  .pwrgood_rst_n             (iopll_locked_export_100M), 
  .i_sys_rst_n               (o_csr_rst_n   ),
  .i_sys_tx_rst_n            (o_csr_tx_rst_n),
  .i_sys_rx_rst_n            (o_csr_rx_rst_n),

  .i_clk_csr                 (i_reconfig_clk),     
  .i_clk_100                 (i_clk_100m),         
  .i_clk_125		           (i_clk_125m),         

  .o_eth_rx_rst_n            (i_rx_rst_n ),
  .o_eth_tx_rst_n            (i_tx_rst_n ),
  .o_eth_rst_n               (i_rst_n    ),
  .o_eth_csr_rst_n           (),
  
  .i_rst_ack_n               (2'b00       ),
  .i_tx_rst_ack              (tx_rst_ack  ),
  .i_rx_rst_ack              (rx_rst_ack  ),
  .o_user_tx_rst_n_125       (o_user_tx_rst_n_125),
  .o_user_rx_rst_n_125       (o_user_rx_rst_n_125),
  .o_user_tx_rst_n_100       (o_user_tx_rst_n_100),
  .o_user_rx_rst_n_100       (o_user_rx_rst_n_100)
);

// ********************************************************************* //
//                   Synchronizers                                        
// ********************************************************************* //
altera_reset_synchronizer #(
   .ASYNC_RESET (1),
   .DEPTH       (2)
) sys_rst_inst (
   .reset_in  (~combined_reset_n),
   .clk       (system_clk_100m),
   .reset_out (system_reset)
);

eth_f_altera_std_synchronizer_nocut sync_iopll_lock_100M (
   .clk                       (clk_100m),
   .reset_n                   (iopll_locked_export),
   .din                       (1'b1),
   .dout                      (iopll_locked_export_100M)
 );

eth_f_altera_std_synchronizer_nocut sync_iopll_lock_125M (
   .clk                       (clk_125m),
   .reset_n                   (iopll_locked_export),
   .din                       (1'b1),
   .dout                      (iopll_locked_export_125M)
 );

// **************************************************************************//
//                 qsys_top module instance                                  //
// **************************************************************************//  
/*
  ___  ______   ______    _____ ___  ____  
 / _ \/ ___\ \ / / ___|  |_   _/ _ \|  _ \ 
| | | \___ \\ V /\___ \    | || | | | |_) |
| |_| |___) || |  ___) |   | || |_| |  __/ 
 \__\_\____/ |_| |____/    |_| \___/|_|           
*/                        
`ifdef NUM_CHANNELS_2 qsys_top `else qsys_top_0 `endif
soc_inst (
	.ninit_done_ninit_done                     (ninit_done),
	
   .i_clk_100m_clk                            (system_clk_100m),
	.reset_reset_n                             (~system_reset),
   
	.o_clk_100m_clk                            (clk_100m),
	.o_clk_125m_clk                            (clk_125m),
	
   .iopll_locked_export                       (iopll_locked_export),
	
   .i_rst_100m_reset_n                        (iopll_locked_export_100M), 
	.i_rst_125m_reset_n                        (iopll_locked_export_125M),

   .i_refclk_156m_clk                         (i_clk_ref_p),
   
   .gts_systemclk_i_refclk_rdy_data           (1'b1),
   .gts_systemclk_o_pll_lock_o_pll_lock       (system_pll_lock),

	.hps_io_jtag_tck                           (jtag_hps_tck),                
	.hps_io_jtag_tms                           (jtag_hps_tms),                
	.hps_io_jtag_tdo                           (jtag_hps_tdo),                 
	.hps_io_jtag_tdi                           (jtag_hps_tdi),  
	
   .hps_io_sdmmc_cclk                         (m_sd_clk),   
	.hps_io_sdmmc_cmd                          (m_sd_cmd), 
	.hps_io_sdmmc_data0                        (m_sd_data0),          
	.hps_io_sdmmc_data1                        (m_sd_data1),          
	.hps_io_sdmmc_data2                        (m_sd_data2),         
	.hps_io_sdmmc_data3                        (m_sd_data3),  

	.emif_hps_emif_mem_ck_0_mem_ck_t           (m_1_ddr4_clk_dp),
	.emif_hps_emif_mem_ck_0_mem_ck_c           (m_1_ddr4_clk_dn),
	.emif_hps_emif_mem_0_mem_a                 (m_1_ddr4_a),
	.emif_hps_emif_mem_0_mem_act_n             (m_1_ddr4_act_n),
	.emif_hps_emif_mem_0_mem_ba                (m_1_ddr4_ba),
	.emif_hps_emif_mem_0_mem_bg                (m_1_ddr4_bg),
	.emif_hps_emif_mem_0_mem_cke               (m_1_ddr4_cke),
	.emif_hps_emif_mem_0_mem_cs_n              (m_1_ddr4_cs_n),
	.emif_hps_emif_mem_0_mem_odt               (m_1_ddr4_odt),
	.emif_hps_emif_mem_reset_n_mem_reset_n     (m_1_ddr4_reset_n),
	.emif_hps_emif_mem_0_mem_par               (m_1_ddr4_par),
	.emif_hps_emif_mem_0_mem_alert_n           (m_1_ddr4_alert_n),
	.emif_hps_emif_mem_0_mem_dqs_t             (m_1_ddr4_dqs_p),
	.emif_hps_emif_mem_0_mem_dqs_c             (m_1_ddr4_dqs_n),
	.emif_hps_emif_mem_0_mem_dq                (m_1_ddr4_dq),
	.emif_hps_emif_oct_0_oct_rzqin             (rzq_b_3a),
	.emif_hps_emif_ref_clk_0_clk               (clk_3a_ddr4_150m_dp),
  
	.hps_io_emac2_tx_clk                       (rgmii_tx_clk),      
	.hps_io_emac2_rx_clk                       (rgmii_rx_clk),  
	.hps_io_emac2_tx_ctl                       (rgmii_tx_ctrl),     
	.hps_io_emac2_rx_ctl                       (rgmii_rx_ctrl),  
	.hps_io_emac2_txd0                         (rgmii_txd_0),        
	.hps_io_emac2_txd1                         (rgmii_txd_1),  
	.hps_io_emac2_rxd0                         (rgmii_rxd_0),   
	.hps_io_emac2_rxd1                         (rgmii_rxd_1),     
	.hps_io_emac2_txd2                         (rgmii_txd_2),      
	.hps_io_emac2_txd3                         (rgmii_txd_3),  
	.hps_io_emac2_rxd2                         (rgmii_rxd_2),     
	.hps_io_emac2_rxd3                         (rgmii_rxd_3), 
   
	.hps_io_emac2_pps                          (hps_1pps_out),      
	.hps_io_emac2_pps_trig                     (hps_1pps_in),
   
	.hps_io_mdio2_mdio                         (phy_mdio),  
	.hps_io_mdio2_mdc                          (phy_mdc),  

	.hps_io_i2c_emac1_sda                      (hps_i2c_sda),     
	.hps_io_i2c_emac1_scl                      (hps_i2c_scl),
   
	.hps_io_uart0_rx                           (uart_ft4232_rxd),          
	.hps_io_uart0_tx                           (uart_ft4232_txd),

 
	.hps_io_gpio0                          	 (hps_gpio0_io0),
	.hps_io_gpio1                          	 (hps_gpio0_io1),
	.hps_io_gpio10                         	 (hps_gpio0_io10),
	.hps_io_gpio27                             (hps_gpio1_io3),
	.hps_io_gpio28                             (hps_gpio1_io4),
   
	.hps_io_hps_osc_clk                        (clk_hps_100m),

	.h2f_reset_reset                           (h2f_reset),

/*
	 _____ ____  _____      ____   ___  ____ _____       ___  
	|_   _/ ___|| ____|    |  _ \ / _ \|  _ \_   _|     / _ \ 
	  | | \___ \|  _|      | |_) | | | | |_) || |      | | | |
	  | |  ___) | |___     |  __/| |_| |  _ < | |      | |_| |
	  |_| |____/|_____|    |_|    \___/|_| \_\|_|       \___/ 
*/				
// --- Miscellaneous Connections ---
// .intel_eth_tse_0_mac_misc_connection_magic_wakeup        (				),
// .intel_eth_tse_0_mac_misc_connection_magic_sleep_n       ( 1'b1		),
	.intel_eth_tse_0_mac_misc_connection_ff_tx_crc_fwd       ( 1'b0		),
	.intel_eth_tse_0_mac_misc_connection_ff_tx_septy         (				),
	.intel_eth_tse_0_mac_misc_connection_tx_ff_uflow         (				),
	.intel_eth_tse_0_mac_misc_connection_ff_tx_a_full        (				),
	.intel_eth_tse_0_mac_misc_connection_ff_tx_a_empty       (				),
	.intel_eth_tse_0_mac_misc_connection_rx_err_stat         (				),
	.intel_eth_tse_0_mac_misc_connection_rx_frm_type         (				),
	.intel_eth_tse_0_mac_misc_connection_ff_rx_dsav          (				),
	.intel_eth_tse_0_mac_misc_connection_ff_rx_a_full        (				),
	.intel_eth_tse_0_mac_misc_connection_ff_rx_a_empty       (				),
// --- Status LEDs ---
	.intel_eth_tse_0_status_led_connection_led_crs           (				),
	.intel_eth_tse_0_status_led_connection_led_link          (				),
	.intel_eth_tse_0_status_led_connection_led_panel_link    (				),
	.intel_eth_tse_0_status_led_connection_led_col           (				),
	.intel_eth_tse_0_status_led_connection_led_an            (				),
	.intel_eth_tse_0_status_led_connection_led_char_err      (				),
	.intel_eth_tse_0_status_led_connection_led_disp_err      (				),
   
// --- GTS Reset Sequencer ---
	.intel_eth_tse_0_i_pma_cu_clk_clk                        ( i_pma_cu_clk			   ),
	.intel_eth_tse_0_i_src_rs_grant_src_rs_grant             ( i_src_rs_grant[0]		),
	.intel_eth_tse_0_o_src_rs_req_src_rs_req                 ( o_src_rs_req[0]		   ),
// --- System PLL ---
  // .intel_eth_tse_0_system_pll_lock_system_pll_lock         ( system_pll_lock       ),
	.intel_eth_tse_0_system_pll_lock_o_pll_lock              ( system_pll_lock       ),
// --- Reference Clocking --- 
	.intel_eth_tse_0_tx_pll_locked_o_tx_pll_locked           ( tse_tx_pll_locked[0]  ), 
// --- Tx Serial Differential Pair ---
	.intel_eth_tse_0_tx_serial_data_o_tx_serial_data         ( eth0_sgmii_tx_dp 	   ),
	.intel_eth_tse_0_tx_serial_data_n_o_tx_serial_data_n     ( eth0_sgmii_tx_dn	   ),
// --- Rx Serial Differential Pair ---
	.intel_eth_tse_0_rx_serial_data_i_rx_serial_data         ( eth0_sgmii_rx_dp	   ),
	.intel_eth_tse_0_rx_serial_data_n_i_rx_serial_data_n     ( eth0_sgmii_rx_dn	   ),
// --- Rx Status Signals ---
	.intel_eth_tse_0_rx_is_lockedtodata_o_rx_is_lockedtodata ( tse_rx_is_lockedtodata[0]),
	.intel_eth_tse_0_rx_is_lockedtoref_o_rx_is_lockedtoref   ( tse_rx_is_lockedtoref[0]	),
// --- PHY Reset ---
	.intel_eth_tse_0_phyip_reset_tx_ack_o_tx_reset_ack       ( tx_rst_ack[0] 	   ),
	.intel_eth_tse_0_phyip_reset_rx_ack_o_rx_reset_ack       ( rx_rst_ack[0]	   ),
	.intel_eth_tse_0_phyip_reset_tx_in_tx_reset              ( !i_tx_rst_n[0]  	),
	.intel_eth_tse_0_phyip_reset_rx_in_rx_reset              ( !i_rx_rst_n[0]		),
// --- Ready Signals ---
	.intel_eth_tse_0_tx_ready_tx_ready                       ( tse_tx_ready[0]		),
	.intel_eth_tse_0_rx_ready_rx_ready                       ( tse_rx_ready[0]		),
// --- PHY MDIO ---
	.intel_eth_tse_0_mac_mdio_connection_mdc                 ( phy_mdio_mdc	   	),
	.intel_eth_tse_0_mac_mdio_connection_mdio_in             ( phy_mdio_mdi	   	),
	.intel_eth_tse_0_mac_mdio_connection_mdio_out            ( phy_mdio_mdo	   	),
	.intel_eth_tse_0_mac_mdio_connection_mdio_oen            ( phy_mdio_mdoen   	),
   
// --- Tx mSGDMA ---
   .tx_dma_fifo_0_out_ts_req_valid              (port0_tx_dma_fifo_0_out_ts_req_valid),
   .tx_dma_fifo_0_out_ts_req_fingerprint        (port0_tx_dma_fifo_0_out_ts_req_fingerprint),
  
   .ts_chs_compl_0_clk_bus_in_clk_bus           (clk_100m),
   .ts_chs_compl_0_rst_bus_in_rst_bus           (~eth_user_tx_rst_n[0]),
  
   .fifo_user_rst_tx_reset_n                    (fifo_tx_user_reset[0]),
   .fifo_user_rst_rx_reset_n                    (fifo_rx_user_reset[0]),
  
   .hssi_rst_tx_reset_n                         (eth_user_tx_rst_n[0]),
   .hssi_rst_rx_reset_n                         (eth_user_rx_rst_n[0]),
  
   .rx_dma_fifo_in_ts_0_data                    ('0),  
   .rx_dma_fifo_in_ts_0_valid                   (1'b0),  

// --- Rx mSGDMA ---  
   .hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid   (tx_ts_valid[0]),
   .hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata    ({tx_ts_fp[0],tx_ts_data[0]}),  
  
   `ifdef NUM_CHANNELS_2
/*
	 _____ ____  _____      ____   ___  ____ _____      _ 
	|_   _/ ___|| ____|    |  _ \ / _ \|  _ \_   _|    / |
	  | | \___ \|  _|      | |_) | | | | |_) || |      | |
	  | |  ___) | |___     |  __/| |_| |  _ < | |      | |
	  |_| |____/|_____|    |_|    \___/|_| \_\|_|      |_|
*/
// --- Miscellaneous Connections --- 
// .intel_eth_tse_1_mac_misc_connection_magic_wakeup        (				),
// .intel_eth_tse_1_mac_misc_connection_magic_sleep_n       ( 1'b1		),
	.intel_eth_tse_1_mac_misc_connection_ff_tx_crc_fwd       ( 1'b0		),
	.intel_eth_tse_1_mac_misc_connection_ff_tx_septy         (				),
	.intel_eth_tse_1_mac_misc_connection_tx_ff_uflow         (				),
	.intel_eth_tse_1_mac_misc_connection_ff_tx_a_full        (				),
	.intel_eth_tse_1_mac_misc_connection_ff_tx_a_empty       (				),
	.intel_eth_tse_1_mac_misc_connection_rx_err_stat         (				),
	.intel_eth_tse_1_mac_misc_connection_rx_frm_type         (				),
	.intel_eth_tse_1_mac_misc_connection_ff_rx_dsav          (				),
	.intel_eth_tse_1_mac_misc_connection_ff_rx_a_full        (				),
	.intel_eth_tse_1_mac_misc_connection_ff_rx_a_empty       (				),
// --- Status LEDs --- 
	.intel_eth_tse_1_status_led_connection_led_crs           (				),
	.intel_eth_tse_1_status_led_connection_led_link          (				),
	.intel_eth_tse_1_status_led_connection_led_panel_link    (				),
	.intel_eth_tse_1_status_led_connection_led_col           (				),
	.intel_eth_tse_1_status_led_connection_led_an            (				),
	.intel_eth_tse_1_status_led_connection_led_char_err      (				),
	.intel_eth_tse_1_status_led_connection_led_disp_err      (				),
   
// --- GTS Reset Sequencer ---
	.intel_eth_tse_1_i_pma_cu_clk_clk                        ( i_pma_cu_clk			   ),
	.intel_eth_tse_1_i_src_rs_grant_src_rs_grant             ( i_src_rs_grant[1]		),
	.intel_eth_tse_1_o_src_rs_req_src_rs_req                 ( o_src_rs_req[1]		   ),
// --- System PLL ---
   .intel_eth_tse_1_system_pll_lock_o_pll_lock              ( system_pll_lock       ),
// --- Reference Clocking --- 
	.intel_eth_tse_1_tx_pll_locked_o_tx_pll_locked           ( tse_tx_pll_locked[1]  ),
// --- Tx Serial Differential Pair ---
	.intel_eth_tse_1_tx_serial_data_o_tx_serial_data         ( eth1_sgmii_tx_dp 	   ),
	.intel_eth_tse_1_tx_serial_data_n_o_tx_serial_data_n     ( eth1_sgmii_tx_dn	   ),
// --- Rx Serial Differential Pair ---
	.intel_eth_tse_1_rx_serial_data_i_rx_serial_data         ( eth1_sgmii_rx_dp	   ),
	.intel_eth_tse_1_rx_serial_data_n_i_rx_serial_data_n     ( eth1_sgmii_rx_dn	   ),
// --- Rx Status Signals ---
	.intel_eth_tse_1_rx_is_lockedtodata_o_rx_is_lockedtodata ( tse_rx_is_lockedtodata[1]),
	.intel_eth_tse_1_rx_is_lockedtoref_o_rx_is_lockedtoref   ( tse_rx_is_lockedtoref[1]	),
// --- PHY Reset ---
	.intel_eth_tse_1_phyip_reset_tx_ack_o_tx_reset_ack       ( tx_rst_ack[1] 	   ),
	.intel_eth_tse_1_phyip_reset_rx_ack_o_rx_reset_ack       ( rx_rst_ack[1]	   ),
	.intel_eth_tse_1_phyip_reset_tx_in_tx_reset              ( !i_tx_rst_n[1]  	),
	.intel_eth_tse_1_phyip_reset_rx_in_rx_reset              ( !i_rx_rst_n[1]		),
// --- Ready Signals ---
	.intel_eth_tse_1_tx_ready_tx_ready                       ( tse_tx_ready[1]		),
	.intel_eth_tse_1_rx_ready_rx_ready                       ( tse_rx_ready[1]		),

// --- Tx mSGDMA ---
   .tx_dma_fifo_0_out_ts_req_1_valid            (port1_tx_dma_fifo_0_out_ts_req_valid),
   .tx_dma_fifo_0_out_ts_req_1_fingerprint      (port1_tx_dma_fifo_0_out_ts_req_fingerprint),
  
   .ts_chs_compl_0_clk_bus_in_1_clk_bus         (clk_100m),
   .ts_chs_compl_0_rst_bus_in_1_rst_bus         (~eth_user_tx_rst_n[1]),
  
   .hssi_rst_tx_1_reset_n                       (eth_user_tx_rst_n[1]),
   .hssi_rst_rx_1_reset_n                       (eth_user_rx_rst_n[1]),
  
   .fifo_user_rst_tx_1_reset_n                  (fifo_tx_user_reset[1]),
   .fifo_user_rst_rx_1_reset_n                  (fifo_rx_user_reset[1]),
   
   .rx_dma_fifo_in_ts_1_data                    ('0),
	.rx_dma_fifo_in_ts_1_valid                   (1'b1),     

// --- Rx mSGDMA ---  
   .hssi_ets_ts_adapter_0_egrs_ts_hssi_1_tvalid (tx_ts_valid[1]),
   .hssi_ets_ts_adapter_0_egrs_ts_hssi_1_tdata  ({tx_ts_fp[1],tx_ts_data[1]}),	   
   `endif // NUM_CHANNELS_2
   
   .user_space_csr_m0_waitrequest        (user_space_csr_m0_waitrequest  ),
   .user_space_csr_m0_readdata           (user_space_csr_m0_readdata     ),
   .user_space_csr_m0_readdatavalid      (user_space_csr_m0_readdatavalid),
   .user_space_csr_m0_burstcount         (user_space_csr_m0_burstcount   ),
   .user_space_csr_m0_writedata          (user_space_csr_m0_writedata    ),
   .user_space_csr_m0_address            (user_space_csr_m0_address      ),
   .user_space_csr_m0_write              (user_space_csr_m0_write        ),
   .user_space_csr_m0_read               (user_space_csr_m0_read         ),
   .user_space_csr_m0_byteenable         (user_space_csr_m0_byteenable   ),
   .user_space_csr_m0_debugaccess        (user_space_csr_m0_debugaccess  )
   
   //.irq_bypass_ip_interrupt_sender_irq   ()     //Unused
);

// ********************************************************************* //
//                  USER SPACE CSR Module
// ********************************************************************* //  
top_user_space_csr #(
.NUM_CHANNELS (NUM_CHANNELS),
.FIFO_DEPTH   (FIFO_DEPTH)
)top_user_space_csr (
   .csr_clk               (clk_100m),
   .reset                 (iopll_locked_export_100M),
   .csr_wr_data           (user_space_csr_m0_writedata     ),
   .csr_read              (user_space_csr_m0_read          ),
   .csr_write             (user_space_csr_m0_write         ),
   .csr_byteenable        (user_space_csr_m0_byteenable    ),
   .csr_address           (user_space_csr_m0_address       ),
   .csr_waitrequest       (user_space_csr_m0_waitrequest   ),
   .csr_rd_data           (user_space_csr_m0_readdata      ),
   .csr_rd_vld            (user_space_csr_m0_readdatavalid ),

   .ack_i_rst_n           (2'b00      ), 
   .ack_i_tx_rst          (tx_rst_ack), 	 
   .ack_i_rx_rst          (rx_rst_ack),    

   .o_rst_n               (o_csr_rst_n   ),
   .o_tx_rst_n            (o_csr_tx_rst_n),
   .o_rx_rst_n            (o_csr_rx_rst_n),

   .i_rx_pcs_ready        ('d0),
   .i_tx_lanes_stable     ('d0),
   .i_tx_pll_locked       ('d0),
   .i_cdr_lock            ('d0),
   .i_sys_pll_locked      ('d0)
);

endmodule

