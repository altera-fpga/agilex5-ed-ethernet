//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

/**
 * Abstract:
 * Top-level SystemVerilog tb_top.
 * It instantites the interface and interconnect wrapper.  Clock generation
 * is also  done in the same file.  It includes each test file and initiates
 * the UVM phase manager by calling run_test().
 */
`timescale 1ns/1ps

//======================================================
// Common Package / Interface - PCIE/SOC/DMA 
//======================================================

module tb_top ();
  //======================================================
  // Import Package  
  //======================================================
	import uvm_pkg::*;			// Import UVM package
	import svt_uvm_pkg::*;		// Import SVT UVM package
	import svt_axi_uvm_pkg::*;	// Import the AXI VIP package
	
	/* Include all test files */

  //======================================================
  // Wire declaration
  //======================================================
  wire        ssgdma_h2d0_st_tvalid     ;
  wire        ssgdma_h2d0_st_tready     ;
  wire [63:0] ssgdma_h2d0_st_tdata      ;
  wire        ssgdma_h2d0_st_tid        ;
  wire [7:0]  ssgdma_h2d0_st_tkeep      ;
  wire        ssgdma_h2d0_st_tlast      ;
  wire        ssgdma_h2d0_st_eth_tvalid ;
  wire        ssgdma_h2d0_st_eth_tready ;
  wire [95:0] ssgdma_h2d0_st_eth_tdata  ;
  wire        ssgdma_h2d0_st_eth_tid    ;
  wire        ssgdma_h2d1_st_tvalid     ;
  wire        ssgdma_h2d1_st_tready     ;
  wire [63:0] ssgdma_h2d1_st_tdata      ;
  wire        ssgdma_h2d1_st_tid        ;
  wire [7:0]  ssgdma_h2d1_st_tkeep      ;
  wire        ssgdma_h2d1_st_tlast      ;
  wire        ssgdma_h2d1_st_eth_tvalid ;
  wire        ssgdma_h2d1_st_eth_tready ;
  wire [95:0] ssgdma_h2d1_st_eth_tdata  ;
  wire        ssgdma_h2d1_st_eth_tid    ;
  wire        ssgdma_d2h0_st_tvalid     ;
  wire        ssgdma_d2h0_st_tready     ;
  wire [63:0] ssgdma_d2h0_st_tdata      ;
  wire        ssgdma_d2h0_st_tid        ;
  wire [7:0]  ssgdma_d2h0_st_tkeep      ;
  wire        ssgdma_d2h0_st_tlast      ;
  wire        ssgdma_d2h0_st_eth_tvalid ;
  wire        ssgdma_d2h0_st_eth_tready ;
  wire [95:0] ssgdma_d2h0_st_eth_tdata  ;
  wire        ssgdma_d2h0_st_eth_tid    ;
  wire        ssgdma_d2h1_st_tvalid     ;
  wire        ssgdma_d2h1_st_tready     ;
  wire [63:0] ssgdma_d2h1_st_tdata      ;
  wire        ssgdma_d2h1_st_tid        ;
  wire [7:0]  ssgdma_d2h1_st_tkeep      ;
  wire        ssgdma_d2h1_st_tlast      ;
  wire        ssgdma_d2h1_st_eth_tvalid ;
  wire        ssgdma_d2h1_st_eth_tready ;
  wire [95:0] ssgdma_d2h1_st_eth_tdata  ;
  wire        ssgdma_d2h1_st_eth_tid    ;

  wire [1:0]  serial_data;
  wire [1:0]  serial_data_n;

  wire        clk_bdg_100_clk;
  wire        clk_bdg_250_clk;
  wire        iopll_locked_export;

  bit clk_100m;
  bit clk_161m;
  bit clk_156m;

  bit ninit_done;
  bit h2f_reset;
  bit reset_n;
  bit system_reset_n;
  bit fpga_reset_n;
  
	bit reset_h2d_st;
	bit reset_h2d_mm;
	bit reset_soc_host;
	
	bit irq;
	bit [9:0] sdl8_arlen;
	int watchdog_timeout_slave;
	int watchdog_timeout_master;

  /* SFP wire dclaration */
  wire  a0_bfm_sda_in;
  wire  a0_bfm_scl_in;
  wire  a0_bfm_sda_oe;
  wire  a0_bfm_scl_oe;
  wire  a2_bfm_sda_in;
  wire  a2_bfm_scl_in;
  wire  a2_bfm_sda_oe;
  wire  a2_bfm_scl_oe;
  tri1 sda;
  tri1 scl;

  wand sda_wand;
  wand scl_wand;

  bit all_dma_desc_done = 0;
  bit end_response_seq = 0;

  //======================================================
  // Interface Instantiation
  //======================================================
	/* VIP Interface instance representing the AXI system */
	svt_axi_if 		axi_if();		// AXI VIP interface
  sm_eth_reset_if 	sm_eth_reset_if(); // common reset 
  sm_eth_ehip_port_if ehip_if();
	
  // I2c Slave AVMM Interface
  sfp_slave_interface    sfp_slv_a0_if ( clk_100m, sm_eth_reset_if.resetn);
  sfp_slave_interface    sfp_slv_a2_if ( clk_100m, sm_eth_reset_if.resetn);
  
  //======================================================
  // Clock & reset 
  //======================================================
	/** Testbench clock generators */
	parameter simulation_cycle = 4;
  
  /* 100MHz clk */
  initial begin
    clk_100m <= 0;
    forever #5ns clk_100m <= ~clk_100m;
  end

  /* 156MHz clk */
  initial begin
    clk_156m <= 0;
    forever #3200ps clk_156m <= ~clk_156m;
  end

  /* 161MHz clk */
  initial begin
    clk_161m <= 0;
    forever #3100ps clk_161m <= ~clk_161m;
  end

  initial begin
    sm_eth_reset_if.resetn = 1;
    fpga_reset_n = 1;
    force dut.h2f_reset = 0;
    force dut.ninit_done = 0;
  end

  /* Apply clk to AXI interface */
	// assign axi_if.common_aclk = clk_100m;
  assign axi_if.master_if[0].aclk = `SM_ETH_H2F_CLK;
  assign axi_if.slave_if[0].aclk  = `SM_ETH_F2H_CLK;
  assign sm_eth_reset_if.clk = clk_100m;
  assign sm_eth_reset_if.ninit_done = ninit_done;

  /* I2C wire assignments*/
  assign sda_wand = sda;
  assign scl_wand = scl;

  // assign sda = a0_bfm_sda_oe ? 1'b0 : 1'bz;
  assign sda_wand = a0_bfm_sda_oe ? 1'b0 : 1'bz;
  // assign scl = a0_bfm_scl_oe ? 1'b0 :1'bz;
  assign scl_wand = a0_bfm_scl_oe ? 1'b0 :1'bz;
  assign a0_bfm_sda_in = sda_wand;
  assign a0_bfm_scl_in = scl_wand;

  // assign sda = a2_bfm_sda_oe ? 1'b0 : 1'bz;
  assign sda_wand = a2_bfm_sda_oe ? 1'b0 : 1'bz;
  // assign scl = a2_bfm_scl_oe ? 1'b0 :1'bz;
  assign scl_wand = a2_bfm_scl_oe ? 1'b0 :1'bz;
  assign a2_bfm_sda_in = sda_wand;
  assign a2_bfm_scl_in = scl_wand;

  //======================================================
  // Verification IP
  //======================================================
	//assign axi_if.master_if[0].bready  = 1; //rfq:removed due to vip error 
  // axi_if.slave -> F2H for data transfer
  assign axi_if.slave_if[0].aresetn = sm_eth_reset_if.resetn;
  // assign axi_if.slave_if[1].aresetn = `SM_ETH_SSGDMA_PATH.app_reset_status_n;
  // axi_if.master -> H2F for CSR access
  assign axi_if.master_if[0].aresetn = sm_eth_reset_if.resetn;

  //======================================================
  // DUT Instantiation
  //======================================================
  top #(
       .A0_PAGE_END_ADDR  (128),
       .A2_UPAGE_END_ADDR (128),
	   .NUM_PG_SUPPORT    (1)
       ) dut (
        .fpga_clk_100          (clk_100m),
        .fpga_reset_n          (sm_eth_reset_if.resetn),
        .i_rx_serial_data      (serial_data[0]),
        .i_rx_serial_data_n    (serial_data_n[0]),
        .o_tx_serial_data      (serial_data[0]),
        .o_tx_serial_data_n    (serial_data_n[0]),
        .i_clk_ref_p           (clk_156m),
        .sfp_i2c_scl           (scl_wand),
        .sfp_i2c_sda           (sda_wand),
        .sfp_mod_det           ('0), // active low
        .sfp_tx_fault          ('0),
        .sfp_rx_los            ('0),
        .sfp_tx_disable        ()
  );

  //======================================================
  // AXI - DUT connections
  //======================================================
  `include "tb_dut_connections.svh"

  i2c_bfm #(7'b1010000) i2c_bfm_a0
  (
        .clk                 (clk_100m),
        .address             (sfp_slv_a0_if.address),
        .read                (sfp_slv_a0_if.read),
        .readdata            (sfp_slv_a0_if.readdata),
        .readdatavalid       (sfp_slv_a0_if.readdatavalid),
        .waitrequest         (sfp_slv_a0_if.waitrequest),
        .write               (sfp_slv_a0_if.write),
        .byteenable          (sfp_slv_a0_if.byteenable),
        .writedata           (sfp_slv_a0_if.writedata),
        .rst_n               (sm_eth_reset_if.resetn),
        .i2c_data_in         (a0_bfm_sda_in),
        .i2c_clk_in          (a0_bfm_scl_in),
        .i2c_data_oe         (a0_bfm_sda_oe),
        .i2c_clk_oe          (a0_bfm_scl_oe)
  );

  i2c_bfm #(7'b1010001) i2c_bfm_a2
  (
        .clk                 (clk_100m),
        .address             (sfp_slv_a2_if.address),
        .read                (sfp_slv_a2_if.read),
        .readdata            (sfp_slv_a2_if.readdata),
        .readdatavalid       (sfp_slv_a2_if.readdatavalid),
        .waitrequest         (sfp_slv_a2_if.waitrequest),
        .write               (sfp_slv_a2_if.write),
        .byteenable          (sfp_slv_a2_if.byteenable),
        .writedata           (sfp_slv_a2_if.writedata),
        .rst_n               (sm_eth_reset_if.resetn),
        .i2c_data_in         (a2_bfm_sda_in),
        .i2c_clk_in          (a2_bfm_scl_in),
        .i2c_data_oe         (a2_bfm_sda_oe),
        .i2c_clk_oe          (a2_bfm_scl_oe)
  );

  //======================================================
  // START TEST
  //======================================================
	initial begin
		/** Set the reset interface on the virtual sequencer */
    uvm_config_db#(virtual sm_eth_reset_if.axi_reset_modport)::set(uvm_root::get(), "uvm_test_top.env.rst_sequencer", "reset_mp", sm_eth_reset_if.axi_reset_modport);

		/**
		* Provide the AXI SV interface to the AXI System ENV. This step
		* establishes the connection between the AXI System ENV and the HDL
		* Interconnect wrapper, through the AXI interface.
		*/
		uvm_config_db#(svt_axi_vif)::set(uvm_root::get(), "uvm_test_top.env.axi_system_env", "vif", axi_if);

		uvm_config_db#(virtual sm_eth_ehip_port_if)::set(uvm_root::get(), "uvm_test_top.env.ehip_port_mon", "vif", ehip_if);
    uvm_config_db#(virtual sfp_slave_interface)::set(uvm_root::get(), "uvm_test_top.env.i2c_slv_env.sfp_agent_a0", "vif", sfp_slv_a0_if);
    uvm_config_db#(virtual sfp_slave_interface)::set(uvm_root::get(), "uvm_test_top.env.i2c_slv_env.sfp_agent_a2", "vif", sfp_slv_a2_if);

		/** Start the UVM tests */
		run_test();
	end

  //======================================================
  // Waveform Dumps 
  //======================================================
  initial begin
    // Enable debugging
    `ifdef postprocess
      $vcdpluson(0,tb_top);
      $vcdplustraceon(tb_top);
      $vcdplusdeltacycleon;
      $vcdplusglitchon;
    `elsif VCS_DUMP
      $vcdplusfile("dump.vpd");
      $vcdpluson(0,tb_top);
      // $vcdplusmemon#
      // #(0,tb_top);
    `endif
  end
endmodule
