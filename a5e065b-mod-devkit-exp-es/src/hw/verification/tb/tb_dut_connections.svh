//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

// F2H AXI slave (Data path) connections
// ----------------------------------------------------------------------------------------------------------------
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awready) = axi_if.slave_if[0].awready;
assign axi_if.slave_if[0].awvalid = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awvalid);
assign axi_if.slave_if[0].awaddr  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awaddr);
assign axi_if.slave_if[0].awlen   = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awlen);
assign axi_if.slave_if[0].awburst = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awburst);
assign axi_if.slave_if[0].awsize  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awsize);
assign axi_if.slave_if[0].awprot  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awprot);
assign axi_if.slave_if[0].awid    = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awid);
assign axi_if.slave_if[0].awcache = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(awcache);

assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(wready) = axi_if.slave_if[0].wready;
assign axi_if.slave_if[0].wvalid = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(wvalid);
assign axi_if.slave_if[0].wdata  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(wdata); 
assign axi_if.slave_if[0].wstrb  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(wstrb); 
assign axi_if.slave_if[0].wlast  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(wlast); 

assign axi_if.slave_if[0].bready = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(bready);
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(bvalid) = axi_if.slave_if[0].bvalid;
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(bresp)  = axi_if.slave_if[0].bresp;
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(bid)    = axi_if.slave_if[0].bid;
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(buser)  = axi_if.slave_if[0].buser;

assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arready) = axi_if.slave_if[0].arready;
assign axi_if.slave_if[0].arvalid = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arvalid);
assign axi_if.slave_if[0].araddr  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(araddr);
assign axi_if.slave_if[0].arlen   = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arlen);
assign axi_if.slave_if[0].arburst = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arburst);
assign axi_if.slave_if[0].arsize  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arsize);
assign axi_if.slave_if[0].arprot  = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arprot);
assign axi_if.slave_if[0].arid    = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arid);
assign axi_if.slave_if[0].arcache = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(arcache);

assign axi_if.slave_if[0].rready = `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(rready);
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(rvalid) = axi_if.slave_if[0].rvalid;
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(rdata)  = axi_if.slave_if[0].rdata;
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(rlast)  = axi_if.slave_if[0].rlast;
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(rresp)  = axi_if.slave_if[0].rresp;
assign `SM_ETH_QSYS_TOP_MM_INT_SS_F2H_AXI4(rid)    = axi_if.slave_if[0].rid;
// ----------------------------------------------------------------------------------------------------------------

// H2F AXI master (CSR path) connections
assign axi_if.master_if[0].awready     = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awready;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awvalid = axi_if.master_if[0].awvalid;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awaddr  = axi_if.master_if[0].awaddr;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awlen   = axi_if.master_if[0].awlen;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awburst = axi_if.master_if[0].awburst;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awsize  = axi_if.master_if[0].awsize;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awprot  = axi_if.master_if[0].awprot;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awid    = axi_if.master_if[0].awid;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_awcache = axi_if.master_if[0].awcache;

assign axi_if.master_if[0].wready     = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_wready;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_wvalid = axi_if.master_if[0].wvalid;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_wdata  = axi_if.master_if[0].wdata;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_wstrb  = axi_if.master_if[0].wstrb;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_wlast  = axi_if.master_if[0].wlast;

assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_bready = axi_if.master_if[0].bready;
assign axi_if.master_if[0].bvalid     = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_bvalid;
assign axi_if.master_if[0].bresp      = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_bresp;
assign axi_if.master_if[0].bid        = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_bid;

assign axi_if.master_if[0].arready     = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arready;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arvalid = axi_if.master_if[0].arvalid;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_araddr  = axi_if.master_if[0].araddr;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arlen   = axi_if.master_if[0].arlen;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arburst = axi_if.master_if[0].arburst;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arsize  = axi_if.master_if[0].arsize;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arprot  = axi_if.master_if[0].arprot;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arid    = axi_if.master_if[0].arid;
assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_arcache = axi_if.master_if[0].arcache;

assign `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_rready = axi_if.master_if[0].rready;
assign axi_if.master_if[0].rvalid     = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_rvalid;
assign axi_if.master_if[0].rdata      = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_rdata;
assign axi_if.master_if[0].rlast      = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_rlast;
assign axi_if.master_if[0].rresp      = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_rresp;
assign axi_if.master_if[0].rid        = `SM_ETH_QSYS_TOP.subsys_hps_hps2fpga_rid;
// ----------------------------------------------------------------------------------------------------------------
// Ingress Port 0
assign ehip_if.p0_ingress_clk   = `SM_ETH_EHIP_PORT0.i_clk_tx;
assign ehip_if.p0_ingress_data  = `SM_ETH_EHIP_PORT0.i_tx_data;
assign ehip_if.p0_ingress_valid = `SM_ETH_EHIP_PORT0.i_tx_valid;
assign ehip_if.p0_ingress_sop   = `SM_ETH_EHIP_PORT0.i_tx_startofpacket;
assign ehip_if.p0_ingress_eop   = `SM_ETH_EHIP_PORT0.i_tx_endofpacket;
assign ehip_if.p0_ingress_ready = `SM_ETH_EHIP_PORT0.o_tx_ready;
assign ehip_if.p0_ingress_error = `SM_ETH_EHIP_PORT0.i_tx_error;

// Egress Port 0
assign ehip_if.p0_egress_clk   = `SM_ETH_EHIP_PORT0.i_clk_rx;
assign ehip_if.p0_egress_data  = `SM_ETH_EHIP_PORT0.o_rx_data;
assign ehip_if.p0_egress_valid = `SM_ETH_EHIP_PORT0.o_rx_valid;
assign ehip_if.p0_egress_sop   = `SM_ETH_EHIP_PORT0.o_rx_startofpacket;
assign ehip_if.p0_egress_eop   = `SM_ETH_EHIP_PORT0.o_rx_endofpacket;
assign ehip_if.p0_egress_error = `SM_ETH_EHIP_PORT0.o_rx_error;
// ----------------------------------------------------------------------------------------------------------------

// initial
//   force `SM_ETH_QSYS_TOP.reset_reset_n = sm_eth_reset_if.resetn;
