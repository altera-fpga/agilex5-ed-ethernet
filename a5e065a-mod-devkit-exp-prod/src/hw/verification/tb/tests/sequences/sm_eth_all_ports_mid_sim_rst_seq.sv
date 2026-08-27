//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

`ifndef SM_ETH_ALL_PORTS_MID_SIM_RST_SEQ__SV
`define SM_ETH_ALL_PORTS_MID_SIM_RST_SEQ__SV

class sm_eth_all_ports_mid_sim_rst_seq extends sm_eth_basic_seq;

  `uvm_object_utils(sm_eth_all_ports_mid_sim_rst_seq)

  sm_eth_basic_data_path_seq     seq_h;

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_eth_all_ports_mid_sim_rst_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] sa [2];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] da [2];

    super.body();

    `uvm_info(get_full_name(), "config rules for user client 0", UVM_LOW)
    key[0] = 'heeee_eeee;
    key[1] = 'hbbbb_eeee;
    key[2] = 'hbbbb_bbbb;
    configure_tcam0(1, key, 8);

    `uvm_info(get_full_name(), "config rules for dma port 0", UVM_LOW)
    key[0] = 'hdddd_dddd;
    key[1] = 'haaaa_dddd;
    key[2] = 'haaaa_aaaa;
    configure_tcam0(2, key, 0);

    fork
      begin: resp_en
        `uvm_info(get_full_name(), "config dma port 0 to start traffic", UVM_LOW)
        `uvm_do_with(seq_h, {
                             num_of_desc == 4;
                             desc_pyld_len == 64;
                             h2d_poll_en == 0;
                             d2h_poll_en == 0;
                            })
        `uvm_info(get_full_name(), "config done dma port 0 to start traffic", UVM_LOW)
      end
      begin: cfg_pkt_client
        wait (seq_h.csr_cfg_done == 1);
        `uvm_info(get_full_name(), "config pkt client0 to start traffic", UVM_LOW)
        da[0] = 'hEEEE_EEEE;
        da[1] = 'hEEEE;
        sa[0] = 'hBBBB_BBBB;
        sa[1] = 'hBBBB;
        configure_pkt_client0(sa, da, 100);
        `uvm_info(get_full_name(), "config done pkt client0 to start traffic", UVM_LOW)
      end
      begin: apply_rst
        bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]        data [];
        bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]        rd_data [];
        bit [`SVT_AXI_WSTRB_WIDTH-1:0] 	         wstrb [];

        wait (seq_h.host_resp_seq !== null);
        wait (seq_h.host_resp_seq.d2h_desc_wrbk_cntr !== 0);
        data = new[1];
        wstrb = new[1];

        // apply rst on rx pcs
        data[0] = 0;
        data[0] = {15'd0, 1'b1, 12'd0, 4'b1101};
        wstrb[0] = 'hf;
        axi_master_write(
            .address(`SM_ETH_USER_CSR_CTRL_REG), .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1), .data(data), .wstrb(wstrb)
        );

        // wait for RX PCS ready to be de-assserted
        while (rd_data[0][0] == 1) begin
          axi_master_read(
            .address(`SM_ETH_USER_CSR_STATUS_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT), .burst_length(1), .data(rd_data)
          );
        end

        // apply soft reset on DMA Rx
        data[0] = 0;
        data[0][2] = 1'b1;
        wstrb[0] = 'hf;
        axi_master_write(
            .address(`SM_ETH_SSGDMA_CSR_ADDR+'h80), .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1), .data(data), .wstrb(wstrb)
        );

        // wait for DMA soft reset to complete
        while (rd_data[0][2] == 1) begin
          axi_master_read(
            .address(`SM_ETH_SSGDMA_CSR_ADDR+'h80),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT), .burst_length(1), .data(rd_data)
          );
        end

        // wait for PCS ready to be assserted
        while (rd_data[0][0] == 0) begin
          axi_master_read(
            .address(`SM_ETH_USER_CSR_STATUS_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT), .burst_length(1), .data(rd_data)
          );
        end
        disable resp_en;
      end
    join

    // wait_for_pkts_to_complete(0, 100);
    `uvm_info(get_full_name(), "Read pkt client perf stats", UVM_LOW)
    read_pkt_client0_perf_stats();
    match_sop_eop(0);
    poll_eth_stats();
  endtask: body

endclass: sm_eth_all_ports_mid_sim_rst_seq

`endif // SM_ETH_ALL_PORTS_MID_SIM_RST_SEQ__SV
