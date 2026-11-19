//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

// Base sqeuences
`include "axi_base_sequence_pkg.sv"
`include "sm_tse_null_virtual_seq.sv"
`include "sm_tse_simple_reset_seq.sv"
`include "sm_tse_axi_master_base_seq.sv"
`include "sm_tse_basic_seq.sv"
`include "sm_tse_msgdma_cfg_seq.sv"
`include "sm_tse_axi_slave_host_response_seq.sv"
`include "sm_tse_basic_data_path_seq.sv"
// DMA only port 0 -> 1 sequences
// In 1 channel DUT, port 0 -> 0 loopback is tested
`include "sm_tse_h2d0_90B_seq.sv"
`include "sm_tse_h2d0_path_seq.sv"
//`include "sm_tse_h2d0_fifo_depth_cover_seq.sv"
// Descriptor-poll sequences hang waiting for all_dma_desc_done (PH_TIMEOUT); not supported.
//`include "sm_tse_h2d0_path_poll_en_seq.sv"

`include "sm_tse_h2d0_pkt_err_seq.sv"

`ifdef NUM_CHANNELS_2
// DMA only port 1 -> 0 sequences
`include "sm_tse_h2d1_90B_seq.sv"
`include "sm_tse_h2d1_path_seq.sv"
//`include "sm_tse_h2d1_fifo_depth_cover_seq.sv"
//`include "sm_tse_h2d1_path_poll_en_seq.sv"

// Both DMA ports enabled sequences
`include "sm_tse_all_dma_ports_traffic_seq.sv"
`include "sm_tse_all_dma_ports_64B_traffic_seq.sv"
`endif
