//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_TSE_ALL_DMA_PORTS_64B_TRAFFIC_SEQ__SV
`define SM_TSE_ALL_DMA_PORTS_64B_TRAFFIC_SEQ__SV

class sm_tse_all_dma_ports_64B_traffic_seq extends sm_tse_basic_seq;

  `uvm_object_utils(sm_tse_all_dma_ports_64B_traffic_seq)

  sm_tse_basic_data_path_seq     seq_h;

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_tse_all_dma_ports_64B_traffic_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3];
    bit [47:0] sa [2];
    bit [47:0] da [2];

    super.body();

    `uvm_info(get_full_name(), "config rules for dma port ", UVM_LOW)
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
    configure_mac0(1, key, 0);
    da[0] = {key[1][15:0], key[0][31:0]};
    sa[0] = {key[2][31:0], key[1][31:16]};
`endif

    `uvm_info(get_full_name(), "config dma port to start traffic", UVM_LOW)
    `uvm_do_with(seq_h, {
                         h2d_en == 2'b11;
                         d2h_en == 2'b11;
                         foreach (num_of_h2d_desc[i]) num_of_h2d_desc[i] == 4;
                         foreach (num_of_d2h_desc[i]) num_of_d2h_desc[i] == 4;
                         foreach (h2d_pyld_len[i])
                           foreach (h2d_pyld_len[i][j])
                             h2d_pyld_len[i][j] == 64;
                         foreach (d2h_pyld_len[i])
                           foreach (d2h_pyld_len[i][j])
                             d2h_pyld_len[i][j] == 64;
                         h2d_poll_en == 0;
                         d2h_poll_en == 0;
                         foreach (dma_da[i]) dma_da[i] == da[i];
                         foreach (dma_sa[i]) dma_sa[i] == sa[i];
                        })
    poll_eth_stats();
  endtask: body
endclass: sm_tse_all_dma_ports_64B_traffic_seq

`endif // SM_TSE_ALL_DMA_PORTS_64B_TRAFFIC_SEQ__SV
