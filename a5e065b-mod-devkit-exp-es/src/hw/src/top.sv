    
//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 


import sm_ptp_pkg::*;

module top #(
     parameter ADDR_WIDTH        = 14 
    ,parameter DATA_WIDTH        = 64   
    ,parameter TS_REQ_FP_WIDTH   = 20
    ,parameter RXIGR_TS_DW       = 96
    ,parameter A0_PAGE_END_ADDR  = 128
    ,parameter A2_UPAGE_END_ADDR = 128
    ,parameter NUM_PG_SUPPORT    = 3
    )(

// Clock and Reset
input    wire          fpga_clk_100,

// HPS EMIF
output   wire          emif_hps_emif_mem_0_mem_ck_t,
output   wire          emif_hps_emif_mem_0_mem_ck_c,
output   wire [16:0]   emif_hps_emif_mem_0_mem_a,
output   wire          emif_hps_emif_mem_0_mem_act_n,
output   wire [1:0]    emif_hps_emif_mem_0_mem_ba,
output   wire [1:0]    emif_hps_emif_mem_0_mem_bg,
output   wire          emif_hps_emif_mem_0_mem_cke,
output   wire          emif_hps_emif_mem_0_mem_cs_n,
output   wire          emif_hps_emif_mem_0_mem_odt,
output   wire          emif_hps_emif_mem_0_mem_reset_n,
output   wire          emif_hps_emif_mem_0_mem_par,
input    wire          emif_hps_emif_mem_0_mem_alert_n,
input    wire          emif_hps_emif_oct_0_oct_rzqin,
input    wire          emif_hps_emif_ref_clk_0_clk,
inout    wire [4:0]    emif_hps_emif_mem_0_mem_dqs_t,
inout    wire [4:0]    emif_hps_emif_mem_0_mem_dqs_c,
inout    wire [39:0]   emif_hps_emif_mem_0_mem_dq,
input    wire          hps_jtag_tck,
input    wire          hps_jtag_tms,
output   wire          hps_jtag_tdo,
input    wire          hps_jtag_tdi,
output   wire          hps_sdmmc_CCLK, 
inout    wire          hps_sdmmc_CMD,          
inout    wire          hps_sdmmc_D0,          
inout    wire          hps_sdmmc_D1,          
inout    wire          hps_sdmmc_D2,        
inout    wire          hps_sdmmc_D3,        

output   wire          hps_emac2_TX_CLK,       
input    wire          hps_emac2_RX_CLK,      
output   wire          hps_emac2_TX_CTL,
input    wire          hps_emac2_RX_CTL,      
output   wire          hps_emac2_TXD0,       
output   wire          hps_emac2_TXD1,
input    wire          hps_emac2_RXD0,     
input    wire          hps_emac2_RXD1, 
output   wire          hps_emac2_PPS,    
input    wire          hps_emac2_PPS_TRIG,
output   wire          hps_emac2_TXD2,        
output   wire          hps_emac2_TXD3,
input    wire          hps_emac2_RXD2,        
input    wire          hps_emac2_RXD3,
inout    wire          hps_emac2_MDIO,         
output   wire          hps_emac2_MDC,
input    wire          hps_uart0_RX,       
output   wire          hps_uart0_TX, 
input    wire          hps_osc_clk,

//HSSI Subsystem
input  wire [NUM_CHANNELS*1-1:0]   i_rx_serial_data,
input  wire [NUM_CHANNELS*1-1:0]   i_rx_serial_data_n,
output wire [NUM_CHANNELS*1-1:0]   o_tx_serial_data,
output wire [NUM_CHANNELS*1-1:0]   o_tx_serial_data_n,

 input wire  [NUM_CHANNELS-1:0]     i_clk_ref_p,
//output wire  [NUM_CHANNELS*1-1:0] o_clk_rec_div_66

//SFP_CONTLR
inout  wire                sfp_i2c_scl,  
inout  wire                sfp_i2c_sda,
input  wire                sfp_mod_det,                  
input  wire                sfp_tx_fault,               
input  wire                sfp_rx_los,
output wire                sfp_tx_disable

);

  
  
  wire  [NUM_CHANNELS*1-1:0]   o_clk_rec_div_66;
  wire                         system_clk_100;
  wire                         ninit_done;
  wire                         fpga_reset_n_debounced_wire;
  reg                          fpga_reset_n_debounced;
  wire                         system_reset;
  wire [NUM_CHANNELS-1:0]      iopll_locked_export_161;
  wire                         iopll_locked_export,iopll_locked_export_100M,iopll_locked_export_125M;
  wire                         msgdma_app_reset_n;
  wire                         msgdma_app_reset_n_161_0;
  wire                         clk_bdg_125_clk;
  wire                         clk_bdg_100_clk;
  wire                         clk_bdg_161_0_in_clk_clk;
  wire                         rst_bdg_ap_resetn_reset;
  
//SFP_CONTLR-------------------------------------------------- 
  wire                         sfp_i2c_scl_in;
  wire                         sfp_i2c_sda_in;
  wire                         sfp_i2c_scl_oe;
  wire                         sfp_i2c_sda_oe;
  integer                      i_qsfpa_reset;
  integer                      i_qsfpa_modesel;
  
  logic [7:0]                 qsfp_cntlr_axi_bdg_m0_awid;
  logic [13:0]                qsfp_cntlr_axi_bdg_m0_awaddr;
  logic [7:0]                 qsfp_cntlr_axi_bdg_m0_awlen;
  logic [2:0]                 qsfp_cntlr_axi_bdg_m0_awsize;
  logic [1:0]                 qsfp_cntlr_axi_bdg_m0_awburst;
  logic [0:0]                 qsfp_cntlr_axi_bdg_m0_awlock;
  logic [3:0]                 qsfp_cntlr_axi_bdg_m0_awcache;
  logic [2:0]                 qsfp_cntlr_axi_bdg_m0_awprot;
  logic                       qsfp_cntlr_axi_bdg_m0_awvalid;         
  logic                       qsfp_cntlr_axi_bdg_m0_awready;   
  logic [63:0]                qsfp_cntlr_axi_bdg_m0_wdata;     
  logic [7:0]                 qsfp_cntlr_axi_bdg_m0_wstrb;     
  logic                       qsfp_cntlr_axi_bdg_m0_wlast;     
  logic                       qsfp_cntlr_axi_bdg_m0_wvalid;    
  logic                       qsfp_cntlr_axi_bdg_m0_wready;    
  logic [7:0]                 qsfp_cntlr_axi_bdg_m0_bid;       
  logic [1:0]                 qsfp_cntlr_axi_bdg_m0_bresp;     
  logic                       qsfp_cntlr_axi_bdg_m0_bvalid;    
  logic                       qsfp_cntlr_axi_bdg_m0_bready;    
  logic [7:0]                 qsfp_cntlr_axi_bdg_m0_arid;      
  logic [13:0]                qsfp_cntlr_axi_bdg_m0_araddr;    
  logic [7:0]                 qsfp_cntlr_axi_bdg_m0_arlen;     
  logic [2:0]                 qsfp_cntlr_axi_bdg_m0_arsize;    
  logic [1:0]                 qsfp_cntlr_axi_bdg_m0_arburst;   
  logic [0:0]                 qsfp_cntlr_axi_bdg_m0_arlock;    
  logic [3:0]                 qsfp_cntlr_axi_bdg_m0_arcache;   
  logic [2:0]                 qsfp_cntlr_axi_bdg_m0_arprot;    
  logic                       qsfp_cntlr_axi_bdg_m0_arvalid;   
  logic                       qsfp_cntlr_axi_bdg_m0_arready;   
  logic [7:0]                 qsfp_cntlr_axi_bdg_m0_rid;       
  logic [63:0]                qsfp_cntlr_axi_bdg_m0_rdata;     
  logic [1:0]                 qsfp_cntlr_axi_bdg_m0_rresp;     
  logic                       qsfp_cntlr_axi_bdg_m0_rlast;     
  logic                       qsfp_cntlr_axi_bdg_m0_rvalid;    
  logic                       qsfp_cntlr_axi_bdg_m0_rready;   
       
  wire  [NUM_CHANNELS-1:0]    o_clk_pll_161m;
  wire  [NUM_CHANNELS-1:0]    msgdma_app_reset_n_161;

  wire                        user_space_csr_m0_waitrequest     ;
  wire     [31:0]             user_space_csr_m0_readdata        ;
  wire                        user_space_csr_m0_readdatavalid   ;
  wire                        user_space_csr_m0_burstcount      ;
  wire     [31:0]             user_space_csr_m0_writedata       ;
  wire     [11:0]             user_space_csr_m0_address         ;
  wire                        user_space_csr_m0_write           ;
  wire                        user_space_csr_m0_read            ;
  wire     [3:0]              user_space_csr_m0_byteenable      ;
  wire                        user_space_csr_m0_debugaccess     ;
 
  wire [NUM_CHANNELS -1:0]   o_user_tx_rst_n_161;
  wire [NUM_CHANNELS -1:0]   o_user_rx_rst_n_161;
  wire [NUM_CHANNELS -1:0]   o_user_tx_rst_n_100;
  wire [NUM_CHANNELS -1:0]   o_user_rx_rst_n_100;
  wire [NUM_CHANNELS -1:0]   eth_user_tx_rst_n;
  wire [NUM_CHANNELS -1:0]   eth_user_rx_rst_n;
  wire [NUM_CHANNELS -1:0]   fifo_tx_user_reset;
  wire [NUM_CHANNELS -1:0]   fifo_rx_user_reset;

  
  wire [NUM_CHANNELS-1:0]     i_rst_n         ;
  wire [NUM_CHANNELS-1:0]     i_tx_rst_n      ;
  wire [NUM_CHANNELS-1:0]     i_rx_rst_n      ;
  reg  [NUM_CHANNELS-1:0]     i_tx_rst_n_161  ;
  reg  [NUM_CHANNELS-1:0]     i_rx_rst_n_161  ;
                      
  wire [NUM_CHANNELS-1:0]     rst_ack_n       ;
  wire [NUM_CHANNELS-1:0]     tx_rst_ack_n    ;
  wire [NUM_CHANNELS-1:0]     rx_rst_ack_n    ;

  wire [NUM_CHANNELS-1:0]     i_src_rs_grant;
  wire [NUM_CHANNELS-1:0]     i_pma_cu_clk;
  wire [NUM_CHANNELS-1:0]     o_src_rs_req;
  
  wire [NUM_CHANNELS-1:0]      o_rx_pcs_ready    ;
  wire [NUM_CHANNELS-1:0]      o_tx_lanes_stable ;
  wire [NUM_CHANNELS-1:0]      o_tx_pll_locked   ;
  wire [NUM_CHANNELS-1:0]      o_cdr_lock        ;
  
  wire  [NUM_CHANNELS-1:0]     o_csr_rst_n;
  wire  [NUM_CHANNELS-1:0]     o_csr_tx_rst_n;
  wire  [NUM_CHANNELS-1:0]     o_csr_rx_rst_n;
  wire  [NUM_CHANNELS-1:0]     o_csr_tx_rst_n_161;
  wire  [NUM_CHANNELS-1:0]     o_csr_rx_rst_n_161;
  
  wire                         o_clk_sys;
  wire                         o_pll_lock;
  
  wire  [NUM_CHANNELS-1:0]                               avst_tx_ready_int;
  wire  [NUM_CHANNELS-1:0]                               avst_tx_valid_int;
  wire  [NUM_CHANNELS-1:0]                               avst_tx_sop_int;
  wire  [NUM_CHANNELS-1:0]                               avst_tx_eop_int;
  wire  [NUM_CHANNELS-1:0]  [EMPTY_WIDTH-1:0]            avst_tx_empty_int;
  wire  [NUM_CHANNELS-1:0]  [WORDS*DATA_WIDTH-1:0]       avst_tx_data_int;
  wire  [NUM_CHANNELS-1:0]                               avst_tx_error_int;
  wire  [NUM_CHANNELS-1:0]                               avst_tx_skip_crc_int;
  logic [NUM_CHANNELS-1:0]                               avst_rx_valid_int;
  wire  [NUM_CHANNELS-1:0] [WORDS*DATA_WIDTH-1:0]        avst_rx_tdata_int;
  wire  [NUM_CHANNELS-1:0] [EMPTY_WIDTH*WORDS-1:0]       avst_rx_empty_int;
  logic [NUM_CHANNELS-1:0]                               avst_rx_sop_int;
  logic [NUM_CHANNELS-1:0]                               avst_rx_eop_int;
  
  logic [NUM_CHANNELS-1:0]                               user_axi_st_tx_tvalid_i;
  logic [NUM_CHANNELS-1:0] [USER_DATA_WIDTH-1:0]         user_axi_st_tx_tdata_i;
  logic [NUM_CHANNELS-1:0] [USER_DATA_WIDTH/8-1:0]       user_axi_st_tx_tkeep_i;
  logic [NUM_CHANNELS-1:0]                               user_axi_st_tx_tlast_i;
  logic [NUM_CHANNELS-1:0] [PTP_WIDTH-1:0]               user_axi_st_tx_tuser_ptp_i;
  logic [NUM_CHANNELS-1:0]                               user_axi_st_tx_tready_o;
  logic [NUM_CHANNELS-1:0] [USER_NUM_OF_SEG-1:0]         user_axi_st_tx_tuser_last_segment_i;                                            


  logic [NUM_CHANNELS-1:0] [PTP_EXT_WIDTH-1:0]      		user_axi_st_tx_tuser_ptp_extended_i;
  logic [NUM_CHANNELS-1:0] [USER_NUM_OF_SEG-1:0] 
                                         [TX_CLIENT_WIDTH-1:0] user_axi_st_tx_tuser_client_i;
  logic [NUM_CHANNELS-1:0] [USER_NUM_OF_SEG-1:0]    		user_axi_st_tx_tuser_pkt_seg_parity_i;


  logic [NUM_CHANNELS-1:0]                                  user_axi_st_rx_tvalid_o;
  logic [NUM_CHANNELS-1:0] [USER_DATA_WIDTH-1:0]            user_axi_st_rx_tdata_o;
  logic [NUM_CHANNELS-1:0] [USER_DATA_WIDTH/8-1:0]          user_axi_st_rx_tkeep_o;
  logic [NUM_CHANNELS-1:0]                                  user_axi_st_rx_tlast_o;                    
  logic [NUM_CHANNELS-1:0][USER_NUM_OF_SEG-1:0]
                                       [RX_CLIENT_WIDTH-1:0] user_axi_st_rx_tuser_client_o;                         
  logic [NUM_CHANNELS-1:0][USER_NUM_OF_SEG-1:0] 
                                        [STS_WIDTH-1:0]     user_axi_st_rx_tuser_sts_o;
  logic [NUM_CHANNELS-1:0][USER_NUM_OF_SEG-1:0]
                                       [STS_EXT_WIDTH-1:0]  user_axi_st_rx_tuser_sts_extended_o;
  logic [NUM_CHANNELS-1:0][USER_NUM_OF_SEG-1:0]             user_axi_st_rx_tuser_pkt_seg_parity_o;
  logic [NUM_CHANNELS-1:0][USER_NUM_OF_SEG-1:0]             user_axi_st_rx_tuser_last_segment_o;                    
  logic [NUM_CHANNELS-1:0]                                  user_axi_st_rx_tready_i;
  
  wire [NUM_CHANNELS-1:0]                                   hssi_ss_st_tx_tvalid ;            
  wire [NUM_CHANNELS-1:0] [HSSI_DATA_WIDTH-1:0]             hssi_ss_st_tx_tdata  ;            
  wire [NUM_CHANNELS-1:0] [HSSI_DATA_WIDTH/8-1:0]           hssi_ss_st_tx_tkeep  ;            
  wire [NUM_CHANNELS-1:0]                                   hssi_ss_st_tx_tlast  ;            
  wire [NUM_CHANNELS-1:0]                                   hssi_ss_st_tx_tready ;            
  wire [NUM_CHANNELS-1:0]                                   hssi_ss_st_rx_tvalid ;            
  wire [NUM_CHANNELS-1:0] [HSSI_DATA_WIDTH-1:0]             hssi_ss_st_rx_tdata  ;            
  wire [NUM_CHANNELS-1:0] [HSSI_DATA_WIDTH/8-1:0]           hssi_ss_st_rx_tkeep  ;            
  wire [NUM_CHANNELS-1:0]                                   hssi_ss_st_rx_tlast  ;            

  logic [NUM_CHANNELS-1:0]                                  dma_axi_st_tx_tvalid_i              ;
  logic [NUM_CHANNELS-1:0][DMA_DATA_WIDTH-1:0]              dma_axi_st_tx_tdata_i               ;
  logic [NUM_CHANNELS-1:0][DMA_DATA_WIDTH/8-1:0]            dma_axi_st_tx_tkeep_i               ;
  logic [NUM_CHANNELS-1:0]                                  dma_axi_st_tx_tlast_i               ;
  logic [NUM_CHANNELS-1:0]                                  dma_axi_st_rx_tready_i              ;
           
  logic [NUM_CHANNELS-1:0][DMA_NUM_OF_SEG-1:0]              dma_axi_st_tx_tuser_last_segment_i  ;
  logic [NUM_CHANNELS-1:0]                                  dma_axi_st_tx_tready_o              ;
  logic [NUM_CHANNELS-1:0]                                  dma_axi_st_rx_tvalid_o;
  logic [NUM_CHANNELS-1:0][DMA_DATA_WIDTH-1:0]              dma_axi_st_rx_tdata_o ;
  logic [NUM_CHANNELS-1:0][DMA_DATA_WIDTH/8-1:0]            dma_axi_st_rx_tkeep_o ;
  logic [NUM_CHANNELS-1:0]                                  dma_axi_st_rx_tlast_o ;
  wire  [NUM_CHANNELS-1:0]                                  ss_app_cold_rst_ack_n, ss_app_warm_rst_ack_n, ss_app_cold_rst_ack_n_sync, ss_app_warm_rst_ack_n_sync;
  reg   [NUM_CHANNELS-1:0]                                  tcam_cold_rst_n, tcam_warm_rst_n;
  wire  [NUM_CHANNELS-1:0]                                  hssi_ptp_tx_egrts_tvalid ;      
  wire  [NUM_CHANNELS-1:0] [TXEGR_TS_DW-1:0]                hssi_ptp_tx_egrts_tdata;                          
  wire  [NUM_CHANNELS-1:0]                                  hssi_ptp_rx_ingrts_tvalid ;    
  wire  [NUM_CHANNELS-1:0] [RXIGR_TS_DW-1:0]                hssi_ptp_rx_ingrts_tdata;      
  wire                                                      port0_tx_dma_fifo_0_out_ts_req_valid;       
  wire   [19:0]                                             port0_tx_dma_fifo_0_out_ts_req_fingerprint;   
  logic [NUM_CHANNELS-1:0]                                  tx_ts_valid ;
  logic [NUM_CHANNELS-1:0] [TS_REQ_FP_WIDTH-1:0]            tx_ts_fp ;
  logic [NUM_CHANNELS-1:0] [RXIGR_TS_DW-1:0]                tx_ts_data ;
  logic [NUM_CHANNELS-1:0]                                  dma_axi_st_rxigrts0_tvalid;
  logic [NUM_CHANNELS-1:0]  [RXIGR_TS_DW-1:0]               dma_axi_st_rxigrts0_tdata;   
														   
  wire [NUM_CHANNELS-1:0]                                   axi_st_txegrts_tvalid_o;
  wire [NUM_CHANNELS-1:0][TX_EGRESS-1:0]                    axi_st_txegrts_tdata_o;
                                                               
  wire [NUM_CHANNELS-1:0]                                   axi_st_rxingrts_tvalid_o;
  wire [NUM_CHANNELS-1:0][RX_INGRESS-1:0]                   axi_st_rxingrts_tdata_o;
  wire [NUM_CHANNELS-1:0][20-1:0]                           i_reconfig_eth_addr           ;
  wire [NUM_CHANNELS-1:0][4-1:0]                            i_reconfig_eth_byteenable     ;
  wire [NUM_CHANNELS-1:0]                                   o_reconfig_eth_readdata_valid ;
  wire [NUM_CHANNELS-1:0]                                   i_reconfig_eth_read           ;
  wire [NUM_CHANNELS-1:0]                                   i_reconfig_eth_write          ;
  wire [NUM_CHANNELS-1:0][32-1:0]                           o_reconfig_eth_readdata       ;
  wire [NUM_CHANNELS-1:0][32-1:0]                           i_reconfig_eth_writedata      ;
  wire [NUM_CHANNELS-1:0]                                   o_reconfig_eth_waitrequest    ;
  wire [NUM_CHANNELS-1:0]                                   i_reconfig_clk    ;
  
 // wire [NUM_CHANNELS-1:0] [FIFO_DEPTH-1:0]                  tx_fifo_length;
 // wire [NUM_CHANNELS-1:0] [FIFO_DEPTH-1:0]                  rx_fifo_length;
  assign i_reconfig_clk[0] = clk_bdg_125_clk;
  assign sfp_i2c_scl_in    = sfp_i2c_scl;
  assign sfp_i2c_sda_in    = sfp_i2c_sda;
  assign sfp_i2c_scl       = sfp_i2c_scl_oe ? 1'b0 : 1'bz;
  assign sfp_i2c_sda       = sfp_i2c_sda_oe ? 1'b0 : 1'bz;

  assign                 system_clk_100   = fpga_clk_100;
  
  wire                   o_pma_cpu_clk;

  axis_if #(.DATA_W(TDATA_WIDTH),.TID(TID)) axis_h2d_if [NUM_CHANNELS-1:0]();
  axis_if #(.DATA_W(TDATA_WIDTH),.TID(TID)) axis_d2h_if [NUM_CHANNELS-1:0]();

 

`ifdef SIM_MODE
   assign system_reset_n = ~ninit_done;
`else
   defparam rd1.CNTR_BITS = 28;
   alt_reset_delay rd1 (.clk(fpga_clk_100), .ready_in(~ninit_done), .ready_out(system_reset_n) );
`endif
  assign system_reset = (~system_reset_n);

  ipm_cdc_async_rst #(
      .NUM_STAGES                 (3)
   ) sync_ninit_done (
      .clk                        (clk_bdg_125_clk),        
      .arst_in                    (system_reset),    
      .srst_out                   (system_reset_csr) 
   );
 

   
  axi4lite_if #(.AWADDR_WIDTH(16), .WDATA_WIDTH(32), .ARADDR_WIDTH(16), .RDATA_WIDTH(32))  axi4lite_pktcli [NUM_CHANNELS-1:0]();
  axi4lite_if #(.AWADDR_WIDTH(16), .WDATA_WIDTH(32), .ARADDR_WIDTH(16), .RDATA_WIDTH(32))  axi4lite_packetsw();
  

  logic [NUM_CHANNELS-1:0] [3:0] trafficgen_system_status;
  wire [1:0] o_tx_lanes_stable_sync, o_tx_pll_locked_sync, o_rx_pcs_ready_sync;

  assign trafficgen_system_status[0] = {o_rx_pcs_ready_sync[0] ,o_tx_pll_locked_sync[0], o_tx_lanes_stable_sync[0] , system_reset_csr};

// **************************************************************************//
//                 synchronizers                                             //
// **************************************************************************//  
  for (genvar i=0; i < NUM_CHANNELS; i++) begin : sts_tx_lanes_stable
    eth_f_altera_std_synchronizer_nocut tx_lanes_stable (
        .clk        (clk_bdg_125_clk),
        .reset_n    (o_tx_lanes_stable[i]),
        .din        (1'b1),         
        .dout       (o_tx_lanes_stable_sync[i])
    );
   end

  for (genvar i=0; i < NUM_CHANNELS; i++) begin : sts_tx_pll_locked
    eth_f_altera_std_synchronizer_nocut tx_pll_locked (
        .clk        (clk_bdg_125_clk),
        .reset_n    (o_tx_pll_locked[i]),
        .din        (1'b1),        
        .dout       (o_tx_pll_locked_sync[i])
    );
   end
    
  for (genvar i=0; i < NUM_CHANNELS; i++) begin : sts_rx_pcs_ready
    eth_f_altera_std_synchronizer_nocut rx_pcs_ready (
        .clk        (clk_bdg_125_clk),
        .reset_n    (o_rx_pcs_ready[i]),
        .din        (1'b1 ),         
        .dout       (o_rx_pcs_ready_sync[i])
    );
   end   

   eth_f_altera_std_synchronizer_nocut sync_iopll_lock_100M (
      .clk                       (clk_bdg_100_clk),
      .reset_n                   (iopll_locked_export),
      .din                       (1'b1),
      .dout                      (iopll_locked_export_100M)
    );
   eth_f_altera_std_synchronizer_nocut sync_iopll_lock_125M (
      .clk                       (clk_bdg_125_clk),
      .reset_n                   (iopll_locked_export),
      .din                       (1'b1),
      .dout                      (iopll_locked_export_125M)
    );
	
   eth_f_altera_std_synchronizer_nocut sync_iopll_lock_161_0 (
      .clk                       (o_clk_pll_161m[0]),
      .reset_n                   (iopll_locked_export),
      .din                       (1'b1 ),
      .dout                      (iopll_locked_export_161[0])
    );
	 
//	    eth_f_altera_std_synchronizer_nocut sync_iopll_lock_161_1 (
//     .clk                       (o_clk_pll_161m[1]),
//     .reset_n                   (iopll_locked_export),
//     .din                       (1'b1 ),
//     .dout                      (iopll_locked_export_161[1])
//   );

// **************************************************************************//
//                 Dummy timestamp generation(egress)                        //
// **************************************************************************// 
`ifdef NON_PTP_ETHERNET
    //h2d egress port 0
 reg msgdma_h2d0_ptp_d1;
 reg msgdma_h2d0_ptp_d2;
 reg msgdma_h2d0_ptp_d3;
 reg [19:0]fp1,fp2,fp3;
 always@ (posedge o_clk_pll_161m[0] or negedge eth_user_tx_rst_n[0]) begin
  if(!eth_user_tx_rst_n[0]) begin
  {msgdma_h2d0_ptp_d1,msgdma_h2d0_ptp_d2,msgdma_h2d0_ptp_d3 } <= 'd0;
  {fp1,fp2,fp3}  <= 'd0;
  end
  else begin
  msgdma_h2d0_ptp_d1 <= port0_tx_dma_fifo_0_out_ts_req_valid;//axis_h2d_if[0].tready && axis_h2d_if[0].tvalid && axis_h2d_if[0].tlast;
  msgdma_h2d0_ptp_d2 <= msgdma_h2d0_ptp_d1;
  msgdma_h2d0_ptp_d3 <= msgdma_h2d0_ptp_d2;
  fp1 <= port0_tx_dma_fifo_0_out_ts_req_fingerprint;
  fp2 <= fp1;
  fp3 <= fp2;
 end
 end
 
 for(genvar i = 0; i < NUM_CHANNELS; i++) begin : tx_ts_assign
    always_comb begin
       tx_ts_valid[i] = msgdma_h2d0_ptp_d3;
       tx_ts_fp[i]    = fp3;;
       tx_ts_data[i]  = 'ha;
    end
end

// **************************************************************************//
//                 Dummy timestamp generation(ingress)                       //
// **************************************************************************// 

 logic frame_start0,frame_end0,frame_in_prog0;
 logic msgdma_d2h0_st_nonptp_tvalid,msgdma_d2h1_st_nonptp_tvalid;

 assign frame_start0 = axis_d2h_if[0].tvalid ? 1'b1 : 1'b0;
 assign frame_end0   = axis_d2h_if[0].tvalid ? axis_d2h_if[0].tlast: 1'b0;
 
 always@ (posedge o_clk_pll_161m[0] or negedge eth_user_rx_rst_n[0]) begin
    if(!eth_user_rx_rst_n[0]) begin
      frame_in_prog0 <= 1'b0;
     end else begin
      frame_in_prog0 <= (frame_in_prog0 | frame_start0) & ~frame_end0;
      end
    end 
        
    
assign dma_axi_st_rxigrts0_tvalid = axis_d2h_if[0].tvalid  & ~frame_in_prog0;

assign  dma_axi_st_rxigrts0_tdata = 'd0;
 
`endif


// **************************************************************************//
//                 qsys_top module instance                                  //
// **************************************************************************//                                 

qsys_top soc_inst (
  .clk_100_clk                               (system_clk_100),
  .clk_bdg_100_clk                           (clk_bdg_100_clk),
  .clk_bdg_125_clk                           (clk_bdg_125_clk),
  .clk_in_0_161m_clk                         (o_clk_pll_161m[0]),
  .iopll_locked_export                       (iopll_locked_export),
  .rst_bdg_100_clk_clk                       (clk_bdg_100_clk),
  .rst_bdg_100_rst_reset_n                   (iopll_locked_export_100M), //edit
  .rst_bdg_125_clk_clk                       (clk_bdg_125_clk),
  .rst_bdg_125_in_rst_reset_n                (iopll_locked_export_125M),
  .qsfp_cntlr_axi_bdg_m0_awid                (qsfp_cntlr_axi_bdg_m0_awid),           
  .qsfp_cntlr_axi_bdg_m0_awaddr              (qsfp_cntlr_axi_bdg_m0_awaddr),         
  .qsfp_cntlr_axi_bdg_m0_awlen               (qsfp_cntlr_axi_bdg_m0_awlen),          
  .qsfp_cntlr_axi_bdg_m0_awsize              (qsfp_cntlr_axi_bdg_m0_awsize),         
  .qsfp_cntlr_axi_bdg_m0_awburst             (qsfp_cntlr_axi_bdg_m0_awburst),        
  .qsfp_cntlr_axi_bdg_m0_awlock              (qsfp_cntlr_axi_bdg_m0_awlock),         
  .qsfp_cntlr_axi_bdg_m0_awcache             (qsfp_cntlr_axi_bdg_m0_awcache),        
  .qsfp_cntlr_axi_bdg_m0_awprot              (qsfp_cntlr_axi_bdg_m0_awprot),         
  .qsfp_cntlr_axi_bdg_m0_awvalid             (qsfp_cntlr_axi_bdg_m0_awvalid),        
  .qsfp_cntlr_axi_bdg_m0_awready             (qsfp_cntlr_axi_bdg_m0_awready),        
  .qsfp_cntlr_axi_bdg_m0_wdata               (qsfp_cntlr_axi_bdg_m0_wdata),          
  .qsfp_cntlr_axi_bdg_m0_wstrb               (qsfp_cntlr_axi_bdg_m0_wstrb),          
  .qsfp_cntlr_axi_bdg_m0_wlast               (qsfp_cntlr_axi_bdg_m0_wlast),          
  .qsfp_cntlr_axi_bdg_m0_wvalid              (qsfp_cntlr_axi_bdg_m0_wvalid),         
  .qsfp_cntlr_axi_bdg_m0_wready              (qsfp_cntlr_axi_bdg_m0_wready),         
  .qsfp_cntlr_axi_bdg_m0_bid                 (qsfp_cntlr_axi_bdg_m0_bid),            
  .qsfp_cntlr_axi_bdg_m0_bresp               (qsfp_cntlr_axi_bdg_m0_bresp),          
  .qsfp_cntlr_axi_bdg_m0_bvalid              (qsfp_cntlr_axi_bdg_m0_bvalid),         
  .qsfp_cntlr_axi_bdg_m0_bready              (qsfp_cntlr_axi_bdg_m0_bready),         
  .qsfp_cntlr_axi_bdg_m0_arid                (qsfp_cntlr_axi_bdg_m0_arid),           
  .qsfp_cntlr_axi_bdg_m0_araddr              (qsfp_cntlr_axi_bdg_m0_araddr),         
  .qsfp_cntlr_axi_bdg_m0_arlen               (qsfp_cntlr_axi_bdg_m0_arlen),          
  .qsfp_cntlr_axi_bdg_m0_arsize              (qsfp_cntlr_axi_bdg_m0_arsize),         
  .qsfp_cntlr_axi_bdg_m0_arburst             (qsfp_cntlr_axi_bdg_m0_arburst),        
  .qsfp_cntlr_axi_bdg_m0_arlock              (qsfp_cntlr_axi_bdg_m0_arlock),         
  .qsfp_cntlr_axi_bdg_m0_arcache             (qsfp_cntlr_axi_bdg_m0_arcache),        
  .qsfp_cntlr_axi_bdg_m0_arprot              (qsfp_cntlr_axi_bdg_m0_arprot),         
  .qsfp_cntlr_axi_bdg_m0_arvalid             (qsfp_cntlr_axi_bdg_m0_arvalid),        
  .qsfp_cntlr_axi_bdg_m0_arready             (qsfp_cntlr_axi_bdg_m0_arready),        
  .qsfp_cntlr_axi_bdg_m0_rid                 (qsfp_cntlr_axi_bdg_m0_rid),            
  .qsfp_cntlr_axi_bdg_m0_rdata               (qsfp_cntlr_axi_bdg_m0_rdata),          
  .qsfp_cntlr_axi_bdg_m0_rresp               (qsfp_cntlr_axi_bdg_m0_rresp),          
  .qsfp_cntlr_axi_bdg_m0_rlast               (qsfp_cntlr_axi_bdg_m0_rlast),          
  .qsfp_cntlr_axi_bdg_m0_rvalid              (qsfp_cntlr_axi_bdg_m0_rvalid),         
  .qsfp_cntlr_axi_bdg_m0_rready              (qsfp_cntlr_axi_bdg_m0_rready), 
  
  .ninit_done_ninit_done                     (ninit_done),

  .emif_hps_emif_mem_ck_0_mem_ck_t           (emif_hps_emif_mem_0_mem_ck_t),
  .emif_hps_emif_mem_ck_0_mem_ck_c           (emif_hps_emif_mem_0_mem_ck_c),
  .emif_hps_emif_mem_0_mem_a                 (emif_hps_emif_mem_0_mem_a),
  .emif_hps_emif_mem_0_mem_act_n             (emif_hps_emif_mem_0_mem_act_n),
  .emif_hps_emif_mem_0_mem_ba                (emif_hps_emif_mem_0_mem_ba),
  .emif_hps_emif_mem_0_mem_bg                (emif_hps_emif_mem_0_mem_bg),
  .emif_hps_emif_mem_0_mem_cke               (emif_hps_emif_mem_0_mem_cke),
  .emif_hps_emif_mem_0_mem_cs_n              (emif_hps_emif_mem_0_mem_cs_n),
  .emif_hps_emif_mem_0_mem_odt               (emif_hps_emif_mem_0_mem_odt),
  .emif_hps_emif_mem_reset_n_mem_reset_n     (emif_hps_emif_mem_0_mem_reset_n),
  .emif_hps_emif_mem_0_mem_par               (emif_hps_emif_mem_0_mem_par),
  .emif_hps_emif_mem_0_mem_alert_n           (emif_hps_emif_mem_0_mem_alert_n),
  .emif_hps_emif_mem_0_mem_dqs_t             (emif_hps_emif_mem_0_mem_dqs_t),
  .emif_hps_emif_mem_0_mem_dqs_c             (emif_hps_emif_mem_0_mem_dqs_c),
  .emif_hps_emif_mem_0_mem_dq                (emif_hps_emif_mem_0_mem_dq),
  .emif_hps_emif_oct_0_oct_rzqin             (emif_hps_emif_oct_0_oct_rzqin),
  .emif_hps_emif_ref_clk_0_clk               (emif_hps_emif_ref_clk_0_clk),
  .hps_io_jtag_tck                           (hps_jtag_tck),                
  .hps_io_jtag_tms                           (hps_jtag_tms),                
  .hps_io_jtag_tdo                           (hps_jtag_tdo),                 
  .hps_io_jtag_tdi                           (hps_jtag_tdi),    
  .hps_io_emac2_tx_clk                       (hps_emac2_TX_CLK),      
  .hps_io_emac2_rx_clk                       (hps_emac2_RX_CLK),  
  .hps_io_emac2_tx_ctl                       (hps_emac2_TX_CTL),     
  .hps_io_emac2_rx_ctl                       (hps_emac2_RX_CTL),  
  .hps_io_emac2_txd0                         (hps_emac2_TXD0),        
  .hps_io_emac2_txd1                         (hps_emac2_TXD1),  
  .hps_io_emac2_rxd0                         (hps_emac2_RXD0),   
  .hps_io_emac2_rxd1                         (hps_emac2_RXD1),     
  .hps_io_emac2_pps                          (hps_emac2_PPS),      
  .hps_io_emac2_pps_trig                     (hps_emac2_PPS_TRIG), 
  .hps_io_emac2_txd2                         (hps_emac2_TXD2),      
  .hps_io_emac2_txd3                         (hps_emac2_TXD3),  
  .hps_io_emac2_rxd2                         (hps_emac2_RXD2),     
  .hps_io_emac2_rxd3                         (hps_emac2_RXD3),   
  .hps_io_mdio2_mdio                         (hps_emac2_MDIO),  
  .hps_io_mdio2_mdc                          (hps_emac2_MDC),  
  .hps_io_sdmmc_cclk                         (hps_sdmmc_CCLK),   
  .hps_io_sdmmc_cmd                          (hps_sdmmc_CMD), 
  .hps_io_sdmmc_data0                        (hps_sdmmc_D0),          
  .hps_io_sdmmc_data1                        (hps_sdmmc_D1),          
  .hps_io_sdmmc_data2                        (hps_sdmmc_D2),         
  .hps_io_sdmmc_data3                        (hps_sdmmc_D3),        
  .hps_io_uart0_rx                           (hps_uart0_RX),          
  .hps_io_uart0_tx                           (hps_uart0_TX), 
  .hps_io_hps_osc_clk                        (hps_osc_clk),
  .h2f_reset_reset                           (),
  .reset_reset_n                             (system_reset_n),
  // --------------   Tx mSGDMA to HSSI ----------------------//
  .axi_tx_st_tready                          (axis_h2d_if[0].tready),
  .axi_tx_st_tvalid                          (axis_h2d_if[0].tvalid),
  .axi_tx_st_tdata                           (axis_h2d_if[0].tdata ),
  .axi_tx_st_tlast                           (axis_h2d_if[0].tlast ),
  .axi_tx_st_tkeep                           (axis_h2d_if[0].tkeep ),
  .axi_tx_st_tuser                           (),//axis_h2d_if_pkt_fifo.tuser ),

  .avst_tx_ptp_i_av_st_tx_skip_crc           ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_ts_valid       ('d0),
  //.avst_tx_ptp_i_av_st_tx_ptp_ts_req         ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_ins_ets        ('d0),
  //.avst_tx_ptp_i_av_st_tx_ptp_fp             ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_ins_cf         ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_tx_its         ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx   ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_asym_sign      ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_asym           ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_p2p            ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_ts_format      ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_update_eb      ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_zero_csum      ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_eb_offset      ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_csum_offset    ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_cf_offset      ('d0),
  .avst_tx_ptp_i_av_st_tx_ptp_ts_offset      ('d0),
  .avst_tx_ptp_valid                         (port0_tx_dma_fifo_0_out_ts_req_valid),
  .avst_tx_ptp_fingerprint                   (port0_tx_dma_fifo_0_out_ts_req_fingerprint),

  .tx_dma_fifo_0_out_ts_req_valid            (port0_tx_dma_fifo_0_out_ts_req_valid), //out
  .tx_dma_fifo_0_out_ts_req_fingerprint      (port0_tx_dma_fifo_0_out_ts_req_fingerprint), //out
  
  .ts_chs_compl_0_clk_bus_in_clk_bus         (o_clk_pll_161m[0]),
  .ts_chs_compl_0_rst_bus_in_rst_bus         (~eth_user_tx_rst_n[0]),
  
  .fifo_user_rst_tx_reset_n                  (fifo_tx_user_reset[0]), //100Mhz
  .fifo_user_rst_rx_reset_n                  (fifo_rx_user_reset[0]), //100Mhz
  
  .hssi_rst_tx_reset_n                       (eth_user_tx_rst_n[0]),
  .hssi_rst_rx_reset_n                       (eth_user_rx_rst_n[0]),
  
  .tx_tuser_ptp_tuser_1                      (),//out
  .tx_tuser_ptp_extended_tuser_2             (),//out
  
  .rx_tuser_sts_tuser_1                     ('d0),
  .rx_ingrts0_interface_tdata               (dma_axi_st_rxigrts0_tdata),
  .rx_ingrts0_interface_tvalid              (dma_axi_st_rxigrts0_tvalid),
 // --------------  HSSI to Rx mSGDMA  ----------------------//                                              
   .axi_rx_st_tvalid                        (axis_d2h_if[0].tvalid),
   .axi_rx_st_tdata                         (axis_d2h_if[0].tdata ),
   .axi_rx_st_tlast                         (axis_d2h_if[0].tlast ),
   .axi_rx_st_tkeep                         (axis_d2h_if[0].tkeep ),
   .axi_rx_st_tuser                         ('d0),//axis_d2h_if_pkt_fifo.tuser ),

   .hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid(tx_ts_valid),
   .hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata ({tx_ts_fp[0],tx_ts_data[0]}),
   
  
   .qhip_port_0_m0_waitrequest            (o_reconfig_eth_waitrequest[0]   ),
   .qhip_port_0_m0_readdata               (o_reconfig_eth_readdata[0]      ),  
   .qhip_port_0_m0_readdatavalid          (o_reconfig_eth_readdata_valid[0]),
   .qhip_port_0_m0_burstcount             (),
   .qhip_port_0_m0_writedata              (i_reconfig_eth_writedata[0]      ),
   .qhip_port_0_m0_address                (i_reconfig_eth_addr[0]           ),  
   .qhip_port_0_m0_write                  (i_reconfig_eth_write [0]         ), 
   .qhip_port_0_m0_read                   (i_reconfig_eth_read[0]           ),
   .qhip_port_0_m0_byteenable             (i_reconfig_eth_byteenable[0]     ),
   .qhip_port_0_m0_debugaccess            (),
     
   .user_space_csr_m0_waitrequest        (user_space_csr_m0_waitrequest  ),
   .user_space_csr_m0_readdata           (user_space_csr_m0_readdata     ),
   .user_space_csr_m0_readdatavalid      (user_space_csr_m0_readdatavalid),
   .user_space_csr_m0_burstcount         (user_space_csr_m0_burstcount   ),
   .user_space_csr_m0_writedata          (user_space_csr_m0_writedata    ),
   .user_space_csr_m0_address            (user_space_csr_m0_address      ),
   .user_space_csr_m0_write              (user_space_csr_m0_write        ),
   .user_space_csr_m0_read               (user_space_csr_m0_read         ),
   .user_space_csr_m0_byteenable         (user_space_csr_m0_byteenable   ),
   .user_space_csr_m0_debugaccess        (user_space_csr_m0_debugaccess  ),
 
  
   .axi4lite_pktcli_0_m0_awaddr          (axi4lite_pktcli[0].awaddr  ),
   .axi4lite_pktcli_0_m0_awprot          (axi4lite_pktcli[0].awprot  ),
   .axi4lite_pktcli_0_m0_awvalid         (axi4lite_pktcli[0].awvalid ),
   .axi4lite_pktcli_0_m0_awready         (axi4lite_pktcli[0].awready ),
   .axi4lite_pktcli_0_m0_wdata           (axi4lite_pktcli[0].wdata   ),
   .axi4lite_pktcli_0_m0_wstrb           (axi4lite_pktcli[0].wstrb   ),
   .axi4lite_pktcli_0_m0_wvalid          (axi4lite_pktcli[0].wvalid  ),
   .axi4lite_pktcli_0_m0_wready          (axi4lite_pktcli[0].wready  ),
   .axi4lite_pktcli_0_m0_bresp           (axi4lite_pktcli[0].bresp   ),
   .axi4lite_pktcli_0_m0_bvalid          (axi4lite_pktcli[0].bvalid  ),
   .axi4lite_pktcli_0_m0_bready          (axi4lite_pktcli[0].bready  ),
   .axi4lite_pktcli_0_m0_araddr          (axi4lite_pktcli[0].araddr  ),
   .axi4lite_pktcli_0_m0_arprot          (axi4lite_pktcli[0].arprot  ),
   .axi4lite_pktcli_0_m0_arvalid         (axi4lite_pktcli[0].arvalid ),
   .axi4lite_pktcli_0_m0_arready         (axi4lite_pktcli[0].arready ),
   .axi4lite_pktcli_0_m0_rdata           (axi4lite_pktcli[0].rdata   ),
   .axi4lite_pktcli_0_m0_rresp           (axi4lite_pktcli[0].rresp   ),
   .axi4lite_pktcli_0_m0_rvalid          (axi4lite_pktcli[0].rvalid  ),
   .axi4lite_pktcli_0_m0_rready          (axi4lite_pktcli[0].rready  ),

   .axi4lite_packetsw_m0_awaddr          (axi4lite_packetsw.awaddr  ),
   .axi4lite_packetsw_m0_awprot          (axi4lite_packetsw.awprot  ),
   .axi4lite_packetsw_m0_awvalid         (axi4lite_packetsw.awvalid ),
   .axi4lite_packetsw_m0_awready         (axi4lite_packetsw.awready ),
   .axi4lite_packetsw_m0_wdata           (axi4lite_packetsw.wdata   ),
   .axi4lite_packetsw_m0_wstrb           (axi4lite_packetsw.wstrb   ),
   .axi4lite_packetsw_m0_wvalid          (axi4lite_packetsw.wvalid  ),
   .axi4lite_packetsw_m0_wready          (axi4lite_packetsw.wready  ),
   .axi4lite_packetsw_m0_bresp           (axi4lite_packetsw.bresp   ),
   .axi4lite_packetsw_m0_bvalid          (axi4lite_packetsw.bvalid  ),
   .axi4lite_packetsw_m0_bready          (axi4lite_packetsw.bready  ),
   .axi4lite_packetsw_m0_araddr          (axi4lite_packetsw.araddr  ),
   .axi4lite_packetsw_m0_arprot          (axi4lite_packetsw.arprot  ),
   .axi4lite_packetsw_m0_arvalid         (axi4lite_packetsw.arvalid ),
   .axi4lite_packetsw_m0_arready         (axi4lite_packetsw.arready ),
   .axi4lite_packetsw_m0_rdata           (axi4lite_packetsw.rdata   ),
   .axi4lite_packetsw_m0_rresp           (axi4lite_packetsw.rresp   ),
   .axi4lite_packetsw_m0_rvalid          (axi4lite_packetsw.rvalid  ),
   .axi4lite_packetsw_m0_rready          (axi4lite_packetsw.rready  )
    
); 



for(genvar i = 0; i < NUM_CHANNELS; i++) begin : user_last_segment_assign
  assign user_axi_st_tx_tuser_last_segment_i[i][0] = user_axi_st_tx_tlast_i[i] ;
  assign user_axi_st_tx_tuser_pkt_seg_parity_i[i]  = 1'b0;
end

 
generate for(genvar i=0;i<NUM_CHANNELS;i++) begin : gen_mulit_inst

      assign eth_user_tx_rst_n [i]  = o_user_tx_rst_n_161[i] & iopll_locked_export_161[i];
      assign eth_user_rx_rst_n [i]  = o_user_rx_rst_n_161[i] & iopll_locked_export_161[i];
      assign fifo_tx_user_reset [i] = o_user_tx_rst_n_100[i] & iopll_locked_export_100M;
		assign fifo_rx_user_reset [i] = o_user_rx_rst_n_100[i] & iopll_locked_export_100M;   


// ********************************************************************* //
// GTS Reset Sequencer Intel FPGA Hard IP provides 
// the PMA Control Unit clock i_pma_cu_clk to the GTS Ethernet Intel FPGA Hard IP.
// ********************************************************************* //

 gts_reset_sequencer reset_sequencer (
         .o_src_rs_grant    (i_src_rs_grant[i]),   //  output,  width = 2,    o_src_rs_grant.src_rs_grant
         .i_src_rs_priority (1'b0),                //   input,  width = 2, i_src_rs_priority.src_rs_priority
         .i_src_rs_req      (o_src_rs_req[i]),     //   input,  width = 2,      i_src_rs_req.src_rs_req
         .o_pma_cu_clk      (i_pma_cu_clk[i])      //  output,  width = 2,      o_pma_cu_clk.clk
    );

// ********************************************************************* //
// GTS System PLL Intel FPGA Hard IP provides 
// i_clk_sys to the GTS Ethernet Intel FPGA Hard IP.
// ********************************************************************* //
 gts_systempll system_pll (
        .o_pll_lock     (o_pll_lock),     //  output,  width = 1,   o_pll_lock.o_pll_lock
        .o_syspll_c0    (o_clk_sys),    //  output,  width = 1,  o_syspll_c0.clk
        .i_refclk       (i_clk_ref_p),       //   input,  width = 1,  refclk_xcvr.clk
        .i_refclk_ready (1'b1)  //   input,  width = 1, i_refclk_rdy.data
    );   
// ********************************************************************* //
//                  HSSI Subsystem Instance
// ********************************************************************* //
  
 hssi_ss_top #(
   .DEBUG_ENABLE (DEBUG_ENABLE)
   )hssi_ss_top
   (
 //.i_refclk2pll_p        (i_refclk2pll_p_d[i]), //Ethernet system clock
   .i_clk_sys             (o_clk_sys),//Ethernet system clock
   .i_pll_lock            (o_pll_lock),
   .i_reconfig_clk        (i_reconfig_clk[i]),
   .i_clk_ref_p           (i_clk_ref_p[i]), //reference clock for TX PLL channel
   
   .i_rx_serial_data      (i_rx_serial_data[i*1+:1]   ),
   .i_rx_serial_data_n    (i_rx_serial_data_n[i*1+:1] ),
   .o_tx_serial_data      (o_tx_serial_data[i*1+:1]   ),
   .o_tx_serial_data_n    (o_tx_serial_data_n[i*1+:1] ),
   
   .i_rst_n               (i_rst_n   [i]),
   .i_tx_rst_n            (i_tx_rst_n[i]),
   .i_rx_rst_n            (i_rx_rst_n[i]),
   .eth_user_tx_rst_n     (eth_user_tx_rst_n[i]),
   .eth_user_rx_rst_n     (eth_user_rx_rst_n[i]),
   
   .rst_ack_n             (rst_ack_n   [i]),
   .tx_rst_ack_n          (tx_rst_ack_n[i]),
   .rx_rst_ack_n          (rx_rst_ack_n[i]),
   
   .i_reconfig_reset      (!iopll_locked_export_125M),
   
   .o_clk_pll_161m        (o_clk_pll_161m[i]),
  
   .o_cdr_lock            (o_cdr_lock [i]),
   .o_tx_pll_locked       (o_tx_pll_locked[i]),
   .o_tx_lanes_stable     (o_tx_lanes_stable[i] ),
   .o_rx_pcs_ready        (o_rx_pcs_ready[i]),
   .o_clk_rec_div64       (),
   
   .o_rx_block_lock        (),
   .o_local_fault_status   (),
   .o_remote_fault_status  (),
   .i_stats_snapshot       ('d0),  
   .o_rx_hi_ber            (),
   .o_rx_pcs_fully_aligned (),

   //------------  Tx ports  ----------------------/                                                                                  
   //  AXI Stream Tx, from Packet Switch subystem   
   .pp_app_ss_st_tx_tready       (hssi_ss_st_tx_tready[i]),
   .app_pp_ss_st_tx_tvalid       (hssi_ss_st_tx_tvalid[i]),
   .app_pp_ss_st_tx_tdata        (hssi_ss_st_tx_tdata[i] ),
   .app_pp_ss_st_tx_tlast        (hssi_ss_st_tx_tlast[i] ),
   .app_pp_ss_st_tx_tkeep        (hssi_ss_st_tx_tkeep[i] ),
   .app_pp_ss_st_tx_client       ('d0),
   .app_pp_ss_st_tx_ptp          ('d0),
   .app_pp_ss_st_tx_ptp_extended ('d0),
   .app_pp_ss_st_tx_seg_parity   (),
   
    //---------- TX EGRESS ------------------
   .axi_st_txegrts_tvalid_o      (hssi_ptp_tx_egrts_tvalid[i]),          
   .axi_st_txegrts_tdata_o       (hssi_ptp_tx_egrts_tdata[i]),
   
  //------------  Rx ports  ----------------------/                                                                                  
  //  AXI Stream Rx, to Packet Switch subystem                                                                                   
   .ss_pp_app_rx_tvalid                  (hssi_ss_st_rx_tvalid[i]),
   .ss_pp_app_rx_tdata                   (hssi_ss_st_rx_tdata[i] ),
   .ss_pp_app_rx_tkeep                   (hssi_ss_st_rx_tkeep[i] ),
   .ss_pp_app_rx_tlast                   (hssi_ss_st_rx_tlast[i] ),
   .ss_pp_app_rx_tuser_client            (),
   .ss_pp_app_rx_tuser_sts               (),
   .ss_pp_app_rx_tuser_sts_extended      (),
   .ss_pp_app_st_rx_tuser_pkt_seg_parity (),
 
   .axi_st_rxingrts_tvalid_o             (hssi_ptp_rx_ingrts_tvalid[i]),  
   .axi_st_rxingrts_tdata_o              (hssi_ptp_rx_ingrts_tdata[i]),
                                         
   .axi_st_txtod_tvalid_i                (),
   .axi_st_txtod_tdata_i                 (),
                                       
   .axi_st_rxtod_tvalid                  (),
   .axi_st_rxtod_tdata                   (),
                                      
   .o_clk_tx_div_66                      (),
   .o_clk_rec_div_66                     (o_clk_rec_div_66[i]),
                                  
   .i_tx_pause                           (),
   .o_rx_pause                           (),
                                      
   .i_tx_pfc                             (),
   .o_rx_pfc                             (),
 
   .i_reconfig_eth_addr                  (i_reconfig_eth_addr          [i] >> 2),
   .i_reconfig_eth_byteenable            (i_reconfig_eth_byteenable    [i]),
   .o_reconfig_eth_readdata_valid        (o_reconfig_eth_readdata_valid[i]),
   .i_reconfig_eth_read                  (i_reconfig_eth_read          [i]),
   .i_reconfig_eth_write                 (i_reconfig_eth_write         [i]),
   .o_reconfig_eth_readdata              (o_reconfig_eth_readdata      [i]),
   .i_reconfig_eth_writedata             (i_reconfig_eth_writedata     [i]),
   .o_reconfig_eth_waitrequest           (o_reconfig_eth_waitrequest   [i]),
   .i_src_rs_grant                       (i_src_rs_grant[i]),
   .o_src_rs_req                         (o_src_rs_req  [i]),
   .i_pma_cu_clk                         (i_pma_cu_clk  [i])
);  

// ********************************************************************* //
//                  Packet Client adaptor
// ********************************************************************* //

 eth_f_packet_client_top_axi_adaptor #(
    .WIDTH                                 (DATA_WIDTH),
    .WORDS                                 (WORDS),
    .EMPTY_WIDTH                           (EMPTY_WIDTH)
  ) packet_client_axi_adaptor_top_0(
    .i_arst                                (eth_user_rx_rst_n[i]), // active low reset
    .i_clk_tx                              (o_clk_pll_161m[i] ),
    .i_clk_rx                              (o_clk_pll_161m[i] ),
    
    //from packet client tx
    .o_avst_tx_ready                       (avst_tx_ready_int            [i]),
    .i_avst_tx_valid                       (avst_tx_valid_int            [i]),
    .i_avst_tx_sop                         (avst_tx_sop_int              [i]),
    .i_avst_tx_eop                         (avst_tx_eop_int              [i]),
    .i_avst_tx_empty                       (avst_tx_empty_int            [i]),
    .i_avst_tx_data                        (avst_tx_data_int             [i]),
    .i_avst_tx_error                       (avst_tx_error_int            [i]),
    .i_avst_tx_skip_crc                    (avst_tx_skip_crc_int         [i]),

																	     
    // to packet_switch                                                         

    .i_axis_tx_ready                       (user_axi_st_tx_tready_o      [i]),
    .o_axis_tx_valid                       (user_axi_st_tx_tvalid_i      [i]),
    .o_axis_tx_tdata                       (user_axi_st_tx_tdata_i       [i]),
    .o_axis_tx_tkeep                       (user_axi_st_tx_tkeep_i       [i]),
    .o_axis_tx_tlast                       (user_axi_st_tx_tlast_i       [i]),
    .o_axis_tx_tuser                       (user_axi_st_tx_tuser_ptp_i   [i]),

    // from packet_switch
    .o_axis_rx_ready                       (user_axi_st_rx_tready_i      [i]),
    .i_axis_rx_valid                       (user_axi_st_rx_tvalid_o      [i]),
    .i_axis_rx_tdata                       (user_axi_st_rx_tdata_o       [i]),
    .i_axis_rx_tlast                       (user_axi_st_rx_tlast_o       [i]),
    .i_axis_rx_tkeep                       (user_axi_st_rx_tkeep_o       [i]),
    .i_axis_rx_tuser                       (user_axi_st_rx_tuser_client_o[i]),

    // to packet client rx
    .i_avst_rx_ready                       (1'b1),
    .o_avst_rx_valid                       (avst_rx_valid_int            [i]),
    .o_avst_rx_tdata                       (avst_rx_tdata_int            [i]),
    .o_avst_rx_empty                       (avst_rx_empty_int            [i]),
    .o_avst_rx_sop                         (avst_rx_sop_int              [i]),
    .o_avst_rx_eop                         (avst_rx_eop_int              [i]),
    .o_tx_st_eop_sync_with_macsec_tuser_error ()
  );

// ********************************************************************* //
//                  Packet Client Top
// ********************************************************************* //  
 eth_f_packet_client_top #(
     .PKT_CYL          (PKT_CYL          ) 
    ,.CLIENT_IF_TYPE   (CLIENT_IF_TYPE   ) 
    ,.READY_LATENCY    (READY_LATENCY    ) 
    ,.DATA_WIDTH       (DATA_WIDTH       ) 
    ,.WORDS            (WORDS            ) 
    ,.EMPTY_WIDTH      (EMPTY_WIDTH      ) 
    ) i_eth_f_packet_client_top (
    .i_arst_tx                                (!eth_user_tx_rst_n[i]) , 
    .i_arst_rx                                (!eth_user_rx_rst_n[i]) , 
    .i_clk_tx                              (o_clk_pll_161m   [i] ),
    .i_clk_rx                              (o_clk_pll_161m   [i] ),
    .i_clk_status                          (clk_bdg_125_clk),
    .i_clk_status_rst                      (!iopll_locked_export_125M),
	
     //AVST TX IF -done
    .i_tx_ready                            (avst_tx_ready_int     [i]),
    .o_tx_valid                            (avst_tx_valid_int     [i]),
    .o_tx_sop                              (avst_tx_sop_int       [i]),
    .o_tx_eop                              (avst_tx_eop_int       [i]),
    .o_tx_empty                            (avst_tx_empty_int     [i]),
    .o_tx_data                             (avst_tx_data_int      [i]),
    .o_tx_error                            (avst_tx_error_int     [i]),
    .o_tx_skip_crc                         (avst_tx_skip_crc_int  [i]),
    .i_rx_valid                            (avst_rx_valid_int     [i]),
    .i_rx_sop                              (avst_rx_sop_int       [i]),
    .i_rx_eop                              (avst_rx_eop_int       [i]),
    .i_rx_empty                            (avst_rx_empty_int     [i]),
    .i_rx_data                             (avst_rx_tdata_int     [i]),
    .i_rx_error                            (7'b0),    
    .i_rxstatus_valid                      (1'b0),
    .i_rxstatus_data                       (40'd0),
    .i_rx_preamble                         (64'b0),
    .o_tx_preamble                         (),
    
    .pktcli_csr_if_slv                     (axi4lite_pktcli [i]),
    .o_cold_rst_csr                        (), 
    .i_sadb_config_done                    (1'b0),
    .i_system_status                       (trafficgen_system_status [i])
);
                                   
end endgenerate

// ********************************************************************* //
//                  Reset Controller
// ********************************************************************* //  
srd_rst_ctrl #(
  .NUM_CHANNELS (NUM_CHANNELS)
)inst_srd_rst_ctrl
(
  .pwrgood_rst_n             (iopll_locked_export_125M), 
  .i_sys_rst_n               (o_csr_rst_n   ),
  .i_sys_tx_rst_n            (o_csr_tx_rst_n),
  .i_sys_rx_rst_n            (o_csr_rx_rst_n),

  .i_clk_pll_161m            (o_clk_pll_161m),//161Mhz ETH clk
  .i_clk_csr                 (i_reconfig_clk), //125Mhz CSR clk
  .i_clk_100                 (clk_bdg_100_clk),//100Mhz DMA clk

  .o_eth_rx_rst_n            (i_rx_rst_n ),
  .o_eth_tx_rst_n            (i_tx_rst_n ),
  .o_eth_rst_n               (i_rst_n    ),
  .o_eth_csr_rst_n           (),
  
  .i_rst_ack_n               (rst_ack_n    ),
  .i_tx_rst_ack_n            (tx_rst_ack_n ),
  .i_rx_rst_ack_n            (rx_rst_ack_n ),
  .o_user_tx_rst_n_161       (o_user_tx_rst_n_161),
  .o_user_rx_rst_n_161       (o_user_rx_rst_n_161),
  .o_user_tx_rst_n_100       (o_user_tx_rst_n_100),
  .o_user_rx_rst_n_100       (o_user_rx_rst_n_100)
);

// ********************************************************************* //
//                  USER SPACE CSR Module
// ********************************************************************* //  
  
 top_user_space_csr #(
  .NUM_CHANNELS (NUM_CHANNELS),
  .FIFO_DEPTH   (FIFO_DEPTH)
 )top_user_space_csr (
  .csr_clk               (clk_bdg_125_clk),
  .reset                 (iopll_locked_export_125M),
  .csr_wr_data           (user_space_csr_m0_writedata     ),
  .csr_read              (user_space_csr_m0_read          ),
  .csr_write             (user_space_csr_m0_write         ),
  .csr_byteenable        (user_space_csr_m0_byteenable    ),
  .csr_address           (user_space_csr_m0_address       ),
  .csr_waitrequest       (user_space_csr_m0_waitrequest   ),
  .csr_rd_data           (user_space_csr_m0_readdata      ),
  .csr_rd_vld            (user_space_csr_m0_readdatavalid ),
   
  .ack_i_rst_n           (rst_ack_n), 
  .ack_i_tx_rst_n        (tx_rst_ack_n),                    
  .ack_i_rx_rst_n        (rx_rst_ack_n),
 
  .o_rst_n               (o_csr_rst_n   ),
  .o_tx_rst_n            (o_csr_tx_rst_n),
  .o_rx_rst_n            (o_csr_rx_rst_n),
  
  .i_rx_pcs_ready        (o_rx_pcs_ready   ),
  .i_tx_lanes_stable     (o_tx_lanes_stable),
  .i_tx_pll_locked       (o_tx_pll_locked  ),
  .i_cdr_lock            (o_cdr_lock       ),
  .i_sys_pll_locked      (iopll_locked_export),
  
  .port0_tx_fifo_depth_i  ('d0),//(tx_fifo_length[0]),
  .port0_rx_fifo_depth_i  ('d0),//(rx_fifo_length[0])
  .port1_tx_fifo_depth_i  ('d0),//(tx_fifo_length[1]),
  .port1_rx_fifo_depth_i  ('d0)//(rx_fifo_length[1])
  
);

//generate for(genvar i=0;i<NUM_PORTS;i++) begin : gen_rst_sync_inst

// ################################################################### // 
//RES-50004 - Multiple Asynchronous Resets within Reset Synchronizer Chain	
// During asynchronous reset synchronizer chain, we should use common reset pin for every register//
// so removing the negedge iopll_locked_export_125M, we should during synchronous reset 
// ################################################################### // 
// ********************************************************************* //
//                  Packet Switch reset sequence
// ********************************************************************* //  

// cold boot reset logic
  eth_f_altera_std_synchronizer_nocut cold_boot_rstack_tcam_inst_1 (
    .clk        (clk_bdg_125_clk),
    .reset_n    (ss_app_cold_rst_ack_n[0]),
    .din        (1'b1),         
    .dout       (ss_app_cold_rst_ack_n_sync[0])
  );
  
always @(posedge clk_bdg_125_clk or negedge iopll_locked_export_125M) 
  if(~iopll_locked_export_125M)
    tcam_cold_rst_n[0] <= 1'b0;
  else if(~ss_app_cold_rst_ack_n_sync[0])
    tcam_cold_rst_n[0] <= 1'b1;
	 
// warm boot reset logic
  eth_f_altera_std_synchronizer_nocut warm_boot_rstack_tcam_inst_1 (
    .clk        (clk_bdg_125_clk),
    .reset_n    (ss_app_warm_rst_ack_n[0]),
    .din        (1'b1),         
    .dout       (ss_app_warm_rst_ack_n_sync[0])
  );

always @(posedge clk_bdg_125_clk or negedge iopll_locked_export_125M) 
  if(~iopll_locked_export_125M)
    tcam_warm_rst_n[0] <= 1'b0;
  else if(~ss_app_warm_rst_ack_n_sync[0])
    tcam_warm_rst_n[0] <= 1'b1;

assign dma_axi_st_tx_tvalid_i[0]                = axis_h2d_if[0].tvalid;
assign dma_axi_st_tx_tdata_i[0]                 = axis_h2d_if[0].tdata;
assign dma_axi_st_tx_tkeep_i[0]                 = axis_h2d_if[0].tkeep;
assign dma_axi_st_tx_tlast_i[0]                 = axis_h2d_if[0].tlast;
assign dma_axi_st_tx_tuser_last_segment_i[0][0] = axis_h2d_if[0].tlast;
assign axis_h2d_if[0].tready                    = dma_axi_st_tx_tready_o[0];

assign axis_d2h_if[0].tvalid                  = dma_axi_st_rx_tvalid_o[0];
assign axis_d2h_if[0].tdata                   = dma_axi_st_rx_tdata_o[0]  ;
assign axis_d2h_if[0].tkeep                   = dma_axi_st_rx_tkeep_o[0]  ;
assign axis_d2h_if[0].tlast                   = dma_axi_st_rx_tlast_o[0]  ;
assign dma_axi_st_rx_tready_i[0]              = 1'b1;
assign axis_d2h_if[0].tid                     = 'd0;  



// ********************************************************************* //
//                  Packet Switch subsystem
// ********************************************************************* //      
packet_switch_subsys
   #(.HSSI_PORT  (NUM_CHANNELS )   
     ,.USER_PORT  (NUM_CHANNELS )   
     ,.DMA_CHNL   (NUM_CHANNELS )   
    
    ,.DMA_DATA_WIDTH           (DMA_DATA_WIDTH         )       
    ,.USER_DATA_WIDTH          (USER_DATA_WIDTH        )     
    ,.HSSI_DATA_WIDTH          (HSSI_DATA_WIDTH        )     
                              
    ,.DMA_NUM_OF_SEG           (DMA_NUM_OF_SEG         )      
    ,.HSSI_NUM_OF_SEG          (HSSI_NUM_OF_SEG        )      
    ,.USER_NUM_OF_SEG          (USER_NUM_OF_SEG        )   

    ,.HSSI_IGR_FIFO_DEPTH      (PTP_BRDG_HSSI_IGR_FIFO_DEPTH)
    ,.USER_IGR_FIFO_DEPTH      (PTP_BRDG_USER_IGR_FIFO_DEPTH)
    ,.DMA_IGR_FIFO_DEPTH       (PTP_BRDG_DMA_IGR_FIFO_DEPTH )   

    ,.TX_CLIENT_WIDTH          (TX_CLIENT_WIDTH        )
    ,.RX_CLIENT_WIDTH          (RX_CLIENT_WIDTH        )
 
    ,.TXEGR_TS_DW              (TXEGR_TS_DW            )      
    ,.RXIGR_TS_DW              (RXIGR_TS_DW            )      
    ,.SYS_FINGERPRINT_WIDTH    (TS_REQ_FP_WIDTH        )
                               
    ,.PTP_WIDTH                (PTP_WIDTH              )      
    ,.PTP_EXT_WIDTH            (PTP_EXT_WIDTH          )      
    ,.STS_WIDTH                (STS_WIDTH              )      
    ,.STS_EXT_WIDTH            (STS_EXT_WIDTH          )      
                               
    ,.AWADDR_WIDTH             (PTP_BRDG_AWADDR_WIDTH)      
    ,.WDATA_WIDTH              (PTP_BRDG_WDATA_WIDTH )      
                              
    ,.TCAM_KEY_WIDTH           (SM_TCAM_KEY_WIDTH         )      
    ,.TCAM_RESULT_WIDTH        (SM_TCAM_RESULT_WIDTH      )      
    ,.TCAM_ENTRIES             (SM_TCAM_ENTRIES           )      
    ,.TCAM_USERMETADATA_WIDTH  (SM_TCAM_USERMETADATA_WIDTH)      

    // default: IGR HSSI, msgDMA, and User are all little endian
    ,.IGR_DMA_BYTE_ROTATE      (IGR_DMA_BYTE_ROTATE  )    
    ,.IGR_USER_BYTE_ROTATE     (IGR_USER_BYTE_ROTATE )    
    ,.IGR_HSSI_BYTE_ROTATE     (IGR_HSSI_BYTE_ROTATE )    

    // default: EGR HSSI, msgDMA, and User are all little endian
    ,.EGR_DMA_BYTE_ROTATE      (EGR_DMA_BYTE_ROTATE )      
    ,.EGR_USER_BYTE_ROTATE     (EGR_USER_BYTE_ROTATE)      
    ,.EGR_HSSI_BYTE_ROTATE     (EGR_HSSI_BYTE_ROTATE) 
    ,.DBG_CNTR_EN              (DBG_CNTR_EN            )    	 
   ) packet_switch_subsys

  (
    //AXI Streaming Interface     
    // Tx streaming clock
     .tx_clk_i             (o_clk_pll_161m)
    ,.tx_areset_n_i        (eth_user_tx_rst_n)
     // Rx streaming clock & reset                 
    ,.rx_clk_i             (o_clk_pll_161m)
    ,.rx_areset_n_i        (eth_user_rx_rst_n)
                                                   
    // axi_lite csr clock & reset                  
    ,.axi_lite_clk_i   (clk_bdg_125_clk)	  
    ,.axi_lite_rst_n_i (iopll_locked_export_125M) 
    //----------------------------------------------------------------------------------------- 
    // init_done status
    ,.tx_init_done_o        ()
    ,.rx_init_done_o        ()

    //-----------------------------------------------------------------------------------------
    //TCAM Reset Interface
    ,.app_ss_cold_rst_n     (tcam_cold_rst_n)      
    ,.app_ss_warm_rst_n     (tcam_warm_rst_n)       
    ,.app_ss_rst_req        ('0)     
    ,.ss_app_rst_rdy        ()
    ,.ss_app_cold_rst_ack_n (ss_app_cold_rst_ack_n)
    ,.ss_app_warm_rst_ack_n (ss_app_warm_rst_ack_n)

    //-----------------------------------------------------------------------------------------
    // axi_lite: sync to axi_lite_clk

    //-----WRITE ADDRESS CHANNEL-------
    ,.axi_lite_awaddr_i    (axi4lite_packetsw.awaddr )
    ,.axi_lite_awvalid_i   (axi4lite_packetsw.awvalid)
    ,.axi_lite_awready_o   (axi4lite_packetsw.awready)
    //---------------------------------            
    //-----WRITE DATA CHANNEL----------            
    ,.axi_lite_wdata_i     (axi4lite_packetsw.wdata )
    ,.axi_lite_wvalid_i    (axi4lite_packetsw.wvalid)
    ,.axi_lite_wready_o    (axi4lite_packetsw.wready)
    ,.axi_lite_wstrb_i     (axi4lite_packetsw.wstrb )
    //---------------------------------            
    //-----WRITE RESPONSE CHANNEL------            
    ,.axi_lite_bresp_o    (axi4lite_packetsw.bresp  )
    ,.axi_lite_bvalid_o   (axi4lite_packetsw.bvalid )
    ,.axi_lite_bready_i   (axi4lite_packetsw.bready )
    //---------------------------------            
    //-----READ ADDRESS CHANNEL-------             
    ,.axi_lite_araddr_i   (axi4lite_packetsw.araddr )
    ,.axi_lite_arvalid_i  (axi4lite_packetsw.arvalid)
    ,.axi_lite_arready_o  (axi4lite_packetsw.arready)
    //---------------------------------            
    //-----READ DATA CHANNEL----------             
    ,.axi_lite_rresp_o    (axi4lite_packetsw.rresp )
    ,.axi_lite_rdata_o    (axi4lite_packetsw.rdata )
    ,.axi_lite_rvalid_o   (axi4lite_packetsw.rvalid)
    ,.axi_lite_rready_i   (axi4lite_packetsw.rready)

    //=========================================================================================
    // TX Interface:  
    //-----------------------------------------------------------------------------------------
    // tx ingress interface - Input from DMA
    // inputs
    ,.dma_axi_st_tx_tvalid_i                (dma_axi_st_tx_tvalid_i          )
    ,.dma_axi_st_tx_tdata_i                 (dma_axi_st_tx_tdata_i           )
    ,.dma_axi_st_tx_tkeep_i                 (dma_axi_st_tx_tkeep_i           )
    ,.dma_axi_st_tx_tlast_i                 (dma_axi_st_tx_tlast_i           )
    ,.dma_axi_st_tx_tuser_ptp_i             ('d0 )
    ,.dma_axi_st_tx_tuser_ptp_extended_i    ('d0 )
    ,.dma_axi_st_tx_tuser_client_i          ('d0 )
    ,.dma_axi_st_tx_tuser_pkt_seg_parity_i  ('d0 )  
    ,.dma_axi_st_tx_tuser_last_segment_i    (dma_axi_st_tx_tuser_last_segment_i )  

    // output                                                                     
    ,.dma_axi_st_tx_tready_o                (dma_axi_st_tx_tready_o          )
    //-----------------------------------------------------------------------------------------
    // tx ingress interface - Input from USER
    ,.user_axi_st_tx_tvalid_i               (user_axi_st_tx_tvalid_i              )  
    ,.user_axi_st_tx_tdata_i                (user_axi_st_tx_tdata_i               )  
    ,.user_axi_st_tx_tkeep_i                (user_axi_st_tx_tkeep_i               )  
    ,.user_axi_st_tx_tlast_i                (user_axi_st_tx_tlast_i               )  
    ,.user_axi_st_tx_tuser_ptp_i            (user_axi_st_tx_tuser_ptp_i           )  
    ,.user_axi_st_tx_tuser_ptp_extended_i   ('d0 )  
    ,.user_axi_st_tx_tuser_client_i         ('d0 )  
    ,.user_axi_st_tx_tuser_pkt_seg_parity_i (user_axi_st_tx_tuser_pkt_seg_parity_i )  
    ,.user_axi_st_tx_tuser_last_segment_i   (user_axi_st_tx_tuser_last_segment_i  )  
    ,.user_axi_st_tx_tready_o               (user_axi_st_tx_tready_o              )                

    //-----------------------------------------------------------------------------------------
    // tx egress interface - Outputs to HSSI
    // outputs
    ,.hssi_axi_st_tx_tvalid_o               (hssi_ss_st_tx_tvalid                 )
    ,.hssi_axi_st_tx_tdata_o                (hssi_ss_st_tx_tdata                  )
    ,.hssi_axi_st_tx_tkeep_o                (hssi_ss_st_tx_tkeep                  )
    ,.hssi_axi_st_tx_tlast_o                (hssi_ss_st_tx_tlast                  )
    ,.hssi_axi_st_tx_tuser_ptp_o            (                                     )
    ,.hssi_axi_st_tx_tuser_ptp_extended_o   (                                     )
    ,.hssi_axi_st_tx_tuser_client_o         (                                     )
    ,.hssi_axi_st_tx_tuser_pkt_seg_parity_o (                                     )  
    ,.hssi_axi_st_tx_tuser_last_segment_o   (                                     )

    // input                                                                      
    ,.hssi_axi_st_tx_tready_i               (hssi_ss_st_tx_tready                 )

    //=========================================================================================
    // RX Interface
    //-----------------------------------------------------------------------------------------
    // rx ingress interface -  Inputs from HSSI
    // inputs
    ,.hssi_axi_st_rx_tvalid_i               (hssi_ss_st_rx_tvalid                 )
    ,.hssi_axi_st_rx_tdata_i                (hssi_ss_st_rx_tdata                  )
    ,.hssi_axi_st_rx_tkeep_i                (hssi_ss_st_rx_tkeep                  )
    ,.hssi_axi_st_rx_tlast_i                (hssi_ss_st_rx_tlast                  )
    //Rx Packet Error Status                                                      
    ,.hssi_axi_st_rx_tuser_client_i         ('d0 )
    //Rx Packet Status                                                            
    ,.hssi_axi_st_rx_tuser_sts_i            ('d0 )
    ,.hssi_axi_st_rx_tuser_sts_extended_i   ('d0 ) 
    ,.hssi_axi_st_rx_tuser_pkt_seg_parity_i ('d0 ) 
    ,.hssi_axi_st_rx_tuser_last_segment_i   ('d0 )

    // outputs                                                                    
    ,.hssi_axi_st_rx_tready_o               (                                     )  
    ,.hssi_axi_st_rx_pause_o                (                                     )

    //-----------------------------------------------------------------------------------------
    // rx egress interface - Output to DMA
    // outputs
    ,.dma_axi_st_rx_tvalid_o                (dma_axi_st_rx_tvalid_o          )
    ,.dma_axi_st_rx_tdata_o                 (dma_axi_st_rx_tdata_o           )
    ,.dma_axi_st_rx_tkeep_o                 (dma_axi_st_rx_tkeep_o           )
    ,.dma_axi_st_rx_tlast_o                 (dma_axi_st_rx_tlast_o           )
    //Rx Packet Error Status                                                    
    ,.dma_axi_st_rx_tuser_client_o          (                                    )
    //Rx Packet Status                                                          
    ,.dma_axi_st_rx_tuser_sts_o             (                                    )
    ,.dma_axi_st_rx_tuser_sts_extended_o    (                                    )
    ,.dma_axi_st_rx_tuser_pkt_seg_parity_o  (                                    )
    ,.dma_axi_st_rx_tuser_last_segment_o    (                                    )

    // input                                                                    
    ,.dma_axi_st_rx_tready_i                (dma_axi_st_rx_tready_i      ) 
    //-----------------------------------------------------------------------------------------
    // rx egress interface - Output to USER
    ,.user_axi_st_rx_tvalid_o               (user_axi_st_rx_tvalid_o             )   
    ,.user_axi_st_rx_tdata_o                (user_axi_st_rx_tdata_o              )  
    ,.user_axi_st_rx_tkeep_o                (user_axi_st_rx_tkeep_o              )   
    ,.user_axi_st_rx_tlast_o                (user_axi_st_rx_tlast_o              )   
    //Rx Packet Error Status                                                     
    ,.user_axi_st_rx_tuser_client_o         (user_axi_st_rx_tuser_client_o       )  
    //Rx Packet Status                                                           
    ,.user_axi_st_rx_tuser_sts_o            (                                    ) 
    ,.user_axi_st_rx_tuser_sts_extended_o   (                                    ) 
    ,.user_axi_st_rx_tuser_pkt_seg_parity_o (                                    ) 
    ,.user_axi_st_rx_tuser_last_segment_o   (                                    ) 

    ,.user_axi_st_rx_tready_i               (user_axi_st_rx_tready_i             )  

    //=========================================================================================
    // Time Stamp Interface:
    //-----------------------------------------------------------------------------------------
    // tx egress timestamp from HSSI
    //inputs
    ,.hssi_axi_st_txegrts0_tvalid_i         ('d0)
    ,.hssi_axi_st_txegrts0_tdata_i          ('d0)
    ,.hssi_axi_st_txegrts1_tvalid_i         ('d0)
    ,.hssi_axi_st_txegrts1_tdata_i          ('d0)

    // tx egress timestamp to DMA                                        
    ,.dma_axi_st_txegrts0_tvalid_o          (axi_st_txegrts_tvalid_o             )
    ,.dma_axi_st_txegrts0_tdata_o           (axi_st_txegrts_tdata_o              )
    ,.dma_axi_st_txegrts1_tvalid_o          (                                    )
    ,.dma_axi_st_txegrts1_tdata_o           (                                    )

     // tx egress timestamp to USER                               
    ,.user_axi_st_txegrts0_tvalid_o         (                                    ) 
    ,.user_axi_st_txegrts0_tdata_o          (                                    ) 
    ,.user_axi_st_txegrts1_tvalid_o         (                                    ) 
    ,.user_axi_st_txegrts1_tdata_o          (                                    ) 

    //-----------------------------------------------------------------------------------------
    // rx ingress timestamp from HSSI
    // inputs
    ,.hssi_axi_st_rxigrts0_tvalid_i        ('d0)
    ,.hssi_axi_st_rxigrts0_tdata_i         ('d0)
    ,.hssi_axi_st_rxigrts1_tvalid_i        ('d0)
    ,.hssi_axi_st_rxigrts1_tdata_i         ('d0)

    // rx ingress timestamp to DMA  
    // outputs                                                              
    ,.dma_axi_st_rxigrts0_tvalid_o         (axi_st_rxingrts_tvalid_o             )
    ,.dma_axi_st_rxigrts0_tdata_o          (axi_st_rxingrts_tdata_o              )
    ,.dma_axi_st_rxigrts1_tvalid_o         (                                     )
    ,.dma_axi_st_rxigrts1_tdata_o          (                                     )

    // rx ingress timestamp to USER                               
    ,.user_axi_st_rxigrts0_tvalid_o        (                                     ) 
    ,.user_axi_st_rxigrts0_tdata_o         (                                     ) 
    ,.user_axi_st_rxigrts1_tvalid_o        (                                     ) 
    ,.user_axi_st_rxigrts1_tdata_o         (                                     )                                      
   );


// ********************************************************************* //
//                  SFP  Module
// ********************************************************************* //  
sfp_top #(
   .ADDR_WIDTH(ADDR_WIDTH),                   
   .DATA_WIDTH(DATA_WIDTH),
   .A0_PAGE_END_ADDR (A0_PAGE_END_ADDR),
   .A2_UPAGE_END_ADDR (A2_UPAGE_END_ADDR),
   .NUM_PG_SUPPORT (NUM_PG_SUPPORT)
    )sfp_top_inst(
        .clk                         (clk_bdg_125_clk),
        .reset                       (~iopll_locked_export_125M),   
        .mod_det                     (~sfp_mod_det),
        .tx_fault                    (sfp_tx_fault), 
        .rx_los                      (sfp_rx_los),
        .tx_disable                  (sfp_tx_disable),  
        .i2c_0_i2c_serial_sda_in     (sfp_i2c_sda_in),
        .i2c_0_i2c_serial_scl_in     (sfp_i2c_scl_in),
        .i2c_0_i2c_serial_sda_oe     (sfp_i2c_sda_oe),  
        .i2c_0_i2c_serial_scl_oe     (sfp_i2c_scl_oe),
        .axi_bdg_s0_awid             (qsfp_cntlr_axi_bdg_m0_awid),            
        .axi_bdg_s0_awaddr           (qsfp_cntlr_axi_bdg_m0_awaddr),        
        .axi_bdg_s0_awlen            (qsfp_cntlr_axi_bdg_m0_awlen),         
        .axi_bdg_s0_awsize           (qsfp_cntlr_axi_bdg_m0_awsize),        
        .axi_bdg_s0_awburst          (qsfp_cntlr_axi_bdg_m0_awburst),       
        .axi_bdg_s0_awlock           (qsfp_cntlr_axi_bdg_m0_awlock),        
        .axi_bdg_s0_awcache          (qsfp_cntlr_axi_bdg_m0_awcache),       
        .axi_bdg_s0_awprot           (qsfp_cntlr_axi_bdg_m0_awprot),        
        .axi_bdg_s0_awvalid          (qsfp_cntlr_axi_bdg_m0_awvalid),       
        .axi_bdg_s0_awready          (qsfp_cntlr_axi_bdg_m0_awready),       
        .axi_bdg_s0_wdata            (qsfp_cntlr_axi_bdg_m0_wdata),         
        .axi_bdg_s0_wstrb            (qsfp_cntlr_axi_bdg_m0_wstrb),         
        .axi_bdg_s0_wlast            (qsfp_cntlr_axi_bdg_m0_wlast),         
        .axi_bdg_s0_wvalid           (qsfp_cntlr_axi_bdg_m0_wvalid),        
        .axi_bdg_s0_wready           (qsfp_cntlr_axi_bdg_m0_wready),        
        .axi_bdg_s0_bid              (qsfp_cntlr_axi_bdg_m0_bid),           
        .axi_bdg_s0_bresp            (qsfp_cntlr_axi_bdg_m0_bresp),         
        .axi_bdg_s0_bvalid           (qsfp_cntlr_axi_bdg_m0_bvalid),        
        .axi_bdg_s0_bready           (qsfp_cntlr_axi_bdg_m0_bready),        
        .axi_bdg_s0_arid             (qsfp_cntlr_axi_bdg_m0_arid),          
        .axi_bdg_s0_araddr           (qsfp_cntlr_axi_bdg_m0_araddr),        
        .axi_bdg_s0_arlen            (qsfp_cntlr_axi_bdg_m0_arlen),         
        .axi_bdg_s0_arsize           (qsfp_cntlr_axi_bdg_m0_arsize),        
        .axi_bdg_s0_arburst          (qsfp_cntlr_axi_bdg_m0_arburst),       
        .axi_bdg_s0_arlock           (qsfp_cntlr_axi_bdg_m0_arlock),        
        .axi_bdg_s0_arcache          (qsfp_cntlr_axi_bdg_m0_arcache),       
        .axi_bdg_s0_arprot           (qsfp_cntlr_axi_bdg_m0_arprot),        
        .axi_bdg_s0_arvalid          (qsfp_cntlr_axi_bdg_m0_arvalid),       
        .axi_bdg_s0_arready          (qsfp_cntlr_axi_bdg_m0_arready),       
        .axi_bdg_s0_rid              (qsfp_cntlr_axi_bdg_m0_rid),           
        .axi_bdg_s0_rdata            (qsfp_cntlr_axi_bdg_m0_rdata),         
        .axi_bdg_s0_rresp            (qsfp_cntlr_axi_bdg_m0_rresp),         
        .axi_bdg_s0_rlast            (qsfp_cntlr_axi_bdg_m0_rlast),         
        .axi_bdg_s0_rvalid           (qsfp_cntlr_axi_bdg_m0_rvalid),           
        .axi_bdg_s0_rready           (qsfp_cntlr_axi_bdg_m0_rready)
    );
    

endmodule


