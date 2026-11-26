//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_TSE_BASIC_DATA_PATH_SEQ__SV
`define SM_TSE_BASIC_DATA_PATH_SEQ__SV

class sm_tse_basic_data_path_seq extends sm_tse_basic_seq;

  rand int num_of_h2d_desc[`SM_TSE_MAX_CHANNELS];
  rand int num_of_d2h_desc[`SM_TSE_MAX_CHANNELS];

  rand bit [47:0] dma_sa[`SM_TSE_MAX_CHANNELS];
  rand bit [47:0] dma_da[`SM_TSE_MAX_CHANNELS];

  rand int h2d_pyld_len[`SM_TSE_MAX_CHANNELS][];
  rand int d2h_pyld_len[`SM_TSE_MAX_CHANNELS][];

  bit csr_cfg_done;
  rand bit [`SM_TSE_MAX_CHANNELS-1:0] h2d_en;
  rand bit [`SM_TSE_MAX_CHANNELS-1:0] d2h_en;
  rand bit [`SM_TSE_MAX_CHANNELS-1:0] h2d_poll_en;
  rand bit [`SM_TSE_MAX_CHANNELS-1:0] d2h_poll_en;
  rand int sw_owned_h2d[`SM_TSE_MAX_CHANNELS][];
  rand int sw_owned_d2h[`SM_TSE_MAX_CHANNELS][];

  // TODO
  // bit descr_irq_en[] -
  //                      for each of the descriptors that are configured
  //                      currently irq is 1 for all descriptors

  `uvm_object_utils_begin(sm_tse_basic_data_path_seq)
    `uvm_field_int(h2d_poll_en, UVM_ALL_ON)
    `uvm_field_int(d2h_poll_en, UVM_ALL_ON)
  `uvm_object_utils_end

  sm_tse_msgdma_cfg_seq     q_csr_seq;

  sm_tse_axi_slave_host_response_seq host_resp_seq;

  constraint dma_constraints {
    (`SM_MSGDMA_NUM_OF_PORTS == 1) -> d2h_en[1:0] == {h2d_en[1], h2d_en[0]};
    (`SM_MSGDMA_NUM_OF_PORTS == 2) -> d2h_en[1:0] == {h2d_en[0], h2d_en[1]};
    soft foreach (h2d_pyld_len[i]) h2d_pyld_len[i].size() == num_of_h2d_desc[i];
    soft foreach (d2h_pyld_len[i]) d2h_pyld_len[i].size() == num_of_d2h_desc[i];
    soft foreach (h2d_pyld_len[i,j]) h2d_pyld_len[i][j] inside {[64:1500]};
    soft foreach (d2h_pyld_len[i,j]) d2h_pyld_len[i][j] == 1500;
    soft foreach (num_of_h2d_desc[i]) num_of_h2d_desc[i] inside {[2:40]};
    soft foreach (num_of_d2h_desc[i]) num_of_d2h_desc[i] inside {[2:40]};
    soft (`SM_TSE_NUM_CHANNELS == 1) -> num_of_h2d_desc[1] == 0;
    soft (`SM_TSE_NUM_CHANNELS == 1) -> num_of_d2h_desc[1] == 0;
    foreach (sw_owned_h2d[i]) sw_owned_h2d[i].size() == num_of_h2d_desc[i];
    soft foreach (sw_owned_h2d[i,j]) sw_owned_h2d[i][j] inside {[0:16]};
    foreach (sw_owned_d2h[i]) sw_owned_d2h[i].size() == num_of_d2h_desc[i];
    soft foreach (sw_owned_d2h[i,j]) sw_owned_d2h[i][j] inside {[0:16]};
    soft foreach (dma_sa[i]) dma_sa[i] == 48'haaaa_aaaa_aaaa;
    soft foreach (dma_da[i]) dma_da[i] == 48'hdddd_dddd_dddd;
    foreach (num_of_h2d_desc[i]) solve num_of_h2d_desc[i] before sw_owned_h2d[i].size();
    foreach (num_of_d2h_desc[i]) solve num_of_d2h_desc[i] before sw_owned_d2h[i].size();
    foreach (h2d_pyld_len[i,j]) {
      solve num_of_h2d_desc[i] before h2d_pyld_len[i].size();
      solve h2d_pyld_len[i].size() before h2d_pyld_len[i][j];
    }
    foreach (d2h_pyld_len[i,j]) {
      solve num_of_d2h_desc[i] before d2h_pyld_len[i].size();
      solve d2h_pyld_len[i].size() before d2h_pyld_len[i][j];
    }
  }

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_tse_basic_data_path_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task body();
    bit [`SM_TSE_NUM_CHANNELS-1:0] rsp_seq_h2d_en;
    bit [`SM_TSE_NUM_CHANNELS-1:0] rsp_seq_h2d_poll_en;
    bit [`SM_TSE_NUM_CHANNELS-1:0] rsp_seq_d2h_poll_en;

    csr_cfg_done = 0;
    rsp_seq_h2d_en = h2d_en;
    rsp_seq_h2d_poll_en = h2d_poll_en;
    rsp_seq_d2h_poll_en = d2h_poll_en;

    fork
      begin
        `uvm_info(get_full_name(),
                  $sformatf("h2d_en %b, d2h_en %b, descr poll en, h2d %0d, d2h %0d",
                            h2d_en, d2h_en, h2d_poll_en, d2h_poll_en),
                  UVM_LOW)
        `uvm_do_with(q_csr_seq, {
                      h2d_ch_en == h2d_en;
                      d2h_ch_en == d2h_en;
                      h2d_descr_poll_en == h2d_poll_en;
                      d2h_descr_poll_en == d2h_poll_en;
                    })
        `uvm_info(get_full_name(), "desc fetch sequence done", UVM_LOW)
        csr_cfg_done = 1;
      end
      begin
        `uvm_info(get_full_name(),
                  $sformatf("descr poll en, h2d %0d, d2h %0d",
                            h2d_poll_en, d2h_poll_en),
                  UVM_LOW)
        foreach (sw_owned_h2d[i,j])
          `uvm_info(get_full_name(), 
                    $sformatf("sw_owned_h2d[%0d][%0d]=%0d", i, j, sw_owned_h2d[i][j]),
                    UVM_LOW)
        foreach (sw_owned_d2h[i,j])
          `uvm_info(get_full_name(), 
                    $sformatf("sw_owned_d2h[%0d][%0d]=%0d", i, j, sw_owned_d2h[i][j]),
                    UVM_LOW)
        foreach (h2d_pyld_len[i,j])
          `uvm_info(get_full_name(),
                    $sformatf("cfg h2d_pyld_len[%0d][%0d]=%0d", i, j, h2d_pyld_len[i][j]),
                    UVM_DEBUG)
        foreach (d2h_pyld_len[i,j])
          `uvm_info(get_full_name(),
                    $sformatf("cfg d2h_pyld_len[%0d][%0d]=%0d", i, j, d2h_pyld_len[i][j]),
                    UVM_DEBUG)
        `uvm_do_on_with (host_resp_seq, p_sequencer.slave_sequencer[0], {
                        h2d_ch_en == rsp_seq_h2d_en;
                        foreach (num_of_h2d_desc[i]) 
                                h2d_max_desc[i] == num_of_h2d_desc[i];
                        foreach (num_of_d2h_desc[i]) 
                                d2h_max_desc[i] == num_of_d2h_desc[i];
                        foreach (h2d_pyld_len[i,j]) 
                          h2d_desc_length[i][j] == h2d_pyld_len[i][j];
                        foreach (d2h_pyld_len[i,j])
                          d2h_desc_length[i][j] == d2h_pyld_len[i][j];
                        foreach (dma_da[i])  h2d_da[i]  == dma_da[i];
                        foreach (dma_sa[i])  h2d_sa[i]  == dma_sa[i];
                        foreach (h2d_eth[i]) h2d_eth[i] == 'h0800;     
                        resp_time_in_ns == 65000;
                        foreach (rsp_seq_h2d_poll_en[i])
                                h2d_descr_poll_en[i] == rsp_seq_h2d_poll_en[i];
                        foreach (rsp_seq_d2h_poll_en[i])
                                d2h_descr_poll_en[i] == rsp_seq_d2h_poll_en[i];
                        foreach (h2d_sw_owned[i,j])
                                h2d_sw_owned[i][j] == sw_owned_h2d[i][j];
                        foreach (d2h_sw_owned[i,j])
                                d2h_sw_owned[i][j] == sw_owned_d2h[i][j];
                        })
        `uvm_info(get_full_name(), "slave respons sequence done", UVM_LOW)
      end
    
      wait (tb_top.all_dma_desc_done == 1) begin
        if (h2d_poll_en | d2h_poll_en) begin
            `uvm_do_with(q_csr_seq, {
                          h2d_ch_en == h2d_en;
                          d2h_ch_en == d2h_en;
                          h2d_descr_poll_en == 0;
                          d2h_descr_poll_en == 0;
                        })
        end
        #200ns;
        tb_top.end_response_seq = 1;
      end
    join
    `uvm_info(get_full_name(), "Body exiting...", UVM_LOW)
  endtask: body

endclass: sm_tse_basic_data_path_seq

`endif // SM_TSE_BASIC_DATA_PATH_SEQ__SV
