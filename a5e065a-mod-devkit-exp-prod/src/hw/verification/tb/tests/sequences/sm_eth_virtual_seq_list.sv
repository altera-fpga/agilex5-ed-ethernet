//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`include "axi_base_sequence_pkg.sv"
`include "sm_eth_null_virtual_seq.sv"
`include "sm_eth_simple_reset_seq.sv"
`include "sm_eth_axi_master_base_seq.sv"
`include "sm_eth_basic_seq.sv"
`include "sm_eth_msgdma_cfg_seq.sv"
`include "sm_eth_axi_slave_msgdma_host_response_seq.sv"
`include "sm_eth_basic_data_path_seq.sv"
`include "sm_eth_random_seq.sv"
`include "sm_eth_h2d0_path_seq.sv"
`include "sm_eth_h2d0_90B_seq.sv"
`include "sm_eth_h2d0_511B_seq.sv"
`include "sm_eth_h2d0_fifo_depth_cover_seq.sv"
`include "sm_eth_user0_seq.sv"
`include "sm_eth_all_ports_64B_traffic_seq.sv"
`include "sm_eth_all_ports_traffic_seq.sv"
`include "sm_eth_h2d0_path_poll_en_seq.sv"
`include "sm_eth_all_ports_dma_desc_poll_en_seq.sv"
// CSR sequences
`include "sm_eth_hssi_csr_seq.sv"
`include "sm_eth_ptp_bridge_csr_seq.sv"
`include "sm_eth_msgdma_csr_seq.sv"
`include "sm_eth_user_csr_seq.sv"
// TODO: mid sim reset sequences
