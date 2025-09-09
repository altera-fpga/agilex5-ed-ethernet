//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_ETH_BASIC_DATA_PATH_SEQ__SV
`define SM_ETH_BASIC_DATA_PATH_SEQ__SV

class sm_eth_basic_data_path_seq extends sm_eth_basic_seq;

  rand int num_of_desc = 2;

  bit [47:0] dma_sa = 48'haaaa_aaaa_aaaa;
  bit [47:0] dma_da = 48'hdddd_dddd_dddd;

  rand int desc_pyld_len = 64;

  bit csr_cfg_done;
  rand bit h2d_poll_en;
  rand bit d2h_poll_en;
  rand int host_sw_owned[];

  // TODO
  // bit descr_irq_en[] -
  //                      for each of the descriptors that are configured
  //                      currently irq is 1 for all descriptors

  `uvm_object_utils_begin(sm_eth_basic_data_path_seq)
    `uvm_field_int(h2d_poll_en, UVM_ALL_ON)
    `uvm_field_int(d2h_poll_en, UVM_ALL_ON)
  `uvm_object_utils_end

  sm_eth_msgdma_cfg_seq     q_csr_seq;

  sm_eth_axi_slave_host_response_seq host_resp_seq;

  constraint dma_constraints {
    soft desc_pyld_len inside {[64:1500]};
    soft num_of_desc inside {[2:40]};
    host_sw_owned.size() == num_of_desc;
    soft foreach (host_sw_owned[i]) host_sw_owned[i] inside {[0:16]};
    solve num_of_desc before host_sw_owned.size();
  }

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_eth_basic_data_path_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task body();
    bit rsp_seq_h2d_poll_en;
    bit rsp_seq_d2h_poll_en;

    csr_cfg_done = 0;
    rsp_seq_h2d_poll_en = h2d_poll_en;
    rsp_seq_d2h_poll_en = d2h_poll_en;

    fork
      begin
        `uvm_info(get_full_name(),
                  $sformatf("descr poll en, h2d %0d, d2h %0d",
                            h2d_poll_en, d2h_poll_en),
                  UVM_LOW)
        `uvm_do_with(q_csr_seq, {
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
        foreach (host_sw_owned[i])
          `uvm_info(get_full_name(), 
                    $sformatf("host_sw_owned[%0d]=%0d", i, host_sw_owned[i]),
                    UVM_LOW)
        `uvm_do_on_with (host_resp_seq, p_sequencer.slave_sequencer[0], {
                        ch0_max_desc == num_of_desc;
                        ch0_desc_length == desc_pyld_len;
                        ch0_da == dma_da;
                        ch0_sa == dma_sa;
                        ch0_eth == 'h0800;     
                        resp_time_in_ns == 65000;
                        h2d_descr_poll_en == rsp_seq_h2d_poll_en;
                        d2h_descr_poll_en == rsp_seq_d2h_poll_en;
                        foreach (sw_owned[i]) sw_owned[i] == host_sw_owned[i];
                        })
        `uvm_info(get_full_name(), "slave respons sequence done", UVM_LOW)
      end
    join
    
    if (h2d_poll_en || d2h_poll_en) begin
      if (tb_top.all_dma_desc_done == 1) begin
        `uvm_do_with(q_csr_seq, {
                      h2d_descr_poll_en == 0;
                      d2h_descr_poll_en == 0;
                    })
      end
      #100ns;
      tb_top.end_response_seq = 1;
    end
    `uvm_info(get_full_name(), "Body exiting...", UVM_LOW)
  endtask: body

endclass: sm_eth_basic_data_path_seq

`endif // SM_ETH_BASIC_DATA_PATH_SEQ__SV
