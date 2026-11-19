//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_ETH_H2D0_PATH_POLL_EN_SEQ__SV
`define SM_ETH_H2D0_PATH_POLL_EN_SEQ__SV

class sm_eth_h2d0_path_poll_en_seq extends sm_eth_basic_seq;


  `uvm_object_utils(sm_eth_h2d0_path_poll_en_seq)

  sm_eth_basic_data_path_seq     seq_h;

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_eth_h2d0_path_poll_en_seq");
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
                         h2d_poll_en == 1;
                         d2h_poll_en == 1;
                         host_sw_owned[0] == 2;
                         num_of_desc == 4;
                         desc_pyld_len == 90;
                        })
    `uvm_info(get_full_name(), "config done dma port 0 to start traffic", UVM_LOW)
    poll_eth_stats();
  endtask: body
endclass: sm_eth_h2d0_path_poll_en_seq

`endif // SM_ETH_H2D0_PATH_POLL_EN_SEQ__SV
