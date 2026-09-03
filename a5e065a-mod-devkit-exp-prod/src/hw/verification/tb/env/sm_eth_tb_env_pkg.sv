//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

//-----------------------------------------------------------------------------
// Description: Includes vip package ans all TB compenent files
//-----------------------------------------------------------------------------

`ifndef SM_ETH_TB_ENV_PKG__SV
`define SM_ETH_TB_ENV_PKG__SV

  `include "uvm_pkg.sv"
  import uvm_pkg::*;
  `include "sm_eth_common_defines.svh"
  `include "uvm_macros.svh"

  `include "svt_axi.uvm.pkg"
  `include "svt_axi_system_configuration.uvm.pkg"
  import svt_uvm_pkg::*;
  import svt_axi_uvm_pkg::*;
  import svt_axi_system_configuration_uvm_pkg::*;
  `include "svt_axi_master_if.svi"
  `include "svt_axi_if.svi"
  `include "sm_eth_ehip_port_if.sv"
  `include "sm_eth_ehip_port_tr.sv"
  `include "svt_axi_master_sequencer.svp"

  `include "sfp_slave_uvc_pkg.svh"

  `include "cust_svt_axi_system_configuration.sv"
  `include "sm_eth_reset_if.sv"
  `include "sm_eth_reset_sequencer.sv"
  `include "sm_eth_ehip_port_monitor.sv"
  `include "sm_eth_msgdma_subscriber.sv"
  `include "sm_eth_env.sv"

`endif // SM_ETH_TB_ENV_PKG__SV
