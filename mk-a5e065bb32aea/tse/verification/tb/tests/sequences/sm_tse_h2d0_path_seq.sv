//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_TSE_H2D0_PATH_SEQ__SV
`define SM_TSE_H2D0_PATH_SEQ__SV

class sm_tse_h2d0_path_seq extends sm_tse_basic_seq;

  `uvm_object_utils(sm_tse_h2d0_path_seq)

  sm_tse_basic_data_path_seq     seq_h;

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_tse_h2d0_path_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] sa [`SM_TSE_NUM_CHANNELS];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] da [`SM_TSE_NUM_CHANNELS];

    super.body();

    `uvm_info(get_full_name(), "config tcam rules for dma port", UVM_LOW)
`ifdef NUM_CHANNELS_2
    key[0] = 'hdddd_dddd;
    key[1] = 'haaaa_dddd;
    key[2] = 'haaaa_aaaa;
    configure_mac1(1, key, 0);
    da[0] = {key[1][15:0], key[0][31:0]};
    sa[0] = {key[2][31:0], key[1][31:16]};
    key[0] = 'hcccc_cccc;
    key[1] = 'hbbbb_cccc;
    key[2] = 'hbbbb_bbbb;
    configure_mac0(1, key, 0);
    da[1] = {key[1][15:0], key[0][31:0]};
    sa[1] = {key[2][31:0], key[1][31:16]};
`else
    key[0] = 'hdddd_dddd;
    key[1] = 'haaaa_dddd;
    key[2] = 'haaaa_aaaa;
    configure_mac0(2, key, 0);
    da[0] = {key[1][15:0], key[0][31:0]};
    sa[0] = {key[2][31:0], key[1][31:16]};
`endif

    `uvm_info(get_full_name(), "config dma port to start traffic", UVM_LOW)
    `uvm_do_with(seq_h, {
                         h2d_en == 2'b01;
                         h2d_poll_en == 0;
                         d2h_poll_en == 0;
                         foreach (dma_da[i]) dma_da[i] == da[i];
                         foreach (dma_sa[i]) dma_sa[i] == sa[i];
                        })
    `uvm_info(get_full_name(), "config done dma port 0 to start traffic", UVM_LOW)
    poll_eth_stats();
  endtask: body
endclass: sm_tse_h2d0_path_seq

`endif // SM_TSE_H2D0_PATH_SEQ__SV
