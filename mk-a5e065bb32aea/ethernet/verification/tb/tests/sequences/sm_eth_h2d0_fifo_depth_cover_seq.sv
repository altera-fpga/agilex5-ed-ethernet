//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_ETH_H2D0_FIFO_DEPTH_COVER_SEQ__SV
`define SM_ETH_H2D0_FIFO_DEPTH_COVER_SEQ__SV

class sm_eth_h2d0_fifo_depth_cover_seq extends sm_eth_basic_seq;


  `uvm_object_utils(sm_eth_h2d0_fifo_depth_cover_seq)

  sm_eth_basic_data_path_seq     seq_h;

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_eth_h2d0_fifo_depth_cover_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] sa [2];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] da [2];

    super.body();

    `uvm_info(get_full_name(), "config rules for dma port 0", UVM_LOW)
    key[0] = 'hdddd_dddd;
    key[1] = 'haaaa_dddd;
    key[2] = 'haaaa_aaaa;
    configure_tcam0(2, key, 0);

    `uvm_info(get_full_name(), "config dma port 0 to start traffic", UVM_LOW)
    `uvm_do_with(seq_h, {
                         num_of_desc == 180;
                         desc_pyld_len == 1500;
                         h2d_poll_en == 0;
                         d2h_poll_en == 0;
                        })
    poll_eth_stats();
  endtask: body

endclass: sm_eth_h2d0_fifo_depth_cover_seq

`endif // SM_ETH_H2D0_FIFO_DEPTH_COVER_SEQ__SV
