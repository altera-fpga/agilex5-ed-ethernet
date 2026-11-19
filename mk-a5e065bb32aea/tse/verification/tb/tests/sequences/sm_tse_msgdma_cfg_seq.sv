//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//#This is base sequence used to configure PKT CLIENTS,
//#TXDMA and RX DMA for basic data flow.
//########################################################################
class sm_tse_msgdma_cfg_seq extends sm_tse_basic_seq;
    
  rand int no_of_transactions ;
  rand int unsigned cfg_sequence_length = 10;
  rand bit [`SM_MSGDMA_NUM_OF_PORTS-1:0] h2d_descr_poll_en;
  rand bit [`SM_MSGDMA_NUM_OF_PORTS-1:0] d2h_descr_poll_en;

  `uvm_object_utils_begin(sm_tse_msgdma_cfg_seq);
    `uvm_field_int(h2d_descr_poll_en, UVM_ALL_ON)
    `uvm_field_int(d2h_descr_poll_en, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "sm_tse_msgdma_cfg_seq");
    super.new(name);
  endfunction : new

    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]     data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]        wstrb [];
    bit [31:0]                            addr;
    bit [31:0]                            csr_wdata;   
    bit                                   h2f_cfg_done; 
    rand bit [`SM_TSE_MAX_CHANNELS-1:0]   h2d_ch_en;
    rand bit [`SM_TSE_MAX_CHANNELS-1:0]   d2h_ch_en;

  constraint ch_en_c {
     soft h2d_ch_en == 0;
     soft d2h_ch_en == 0;
     (`SM_TSE_NUM_CHANNELS == 1) -> h2d_ch_en == 1;
     (`SM_TSE_NUM_CHANNELS == 1) -> d2h_ch_en == 1;
     soft h2d_descr_poll_en == 0;
     soft d2h_descr_poll_en == 0;
  }

  task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] rd_data [];

     super.body();

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    data = new[1];
    wstrb = new[1];
    h2f_cfg_done = 0;

    csr_wdata = 'h0;
    `uvm_info(get_full_name(), "Body:DESC CFG START...", UVM_LOW) 

    `uvm_info(get_full_name(),
              $sformatf("h2d_ch_en %b, d2h_ch_en %b, desc poll en, h2d %0d, d2h %0d",
                        h2d_ch_en, d2h_ch_en, this.h2d_descr_poll_en, this.d2h_descr_poll_en),
              UVM_LOW)

    `uvm_info(get_full_name(), "Reset Tx prefetcher", UVM_LOW)
    addr = `SM_TSE_MSGDMA_TX_PREF_0_CSR;
    csr_wdata = 'h4;
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    if (`SM_TSE_NUM_CHANNELS !== 1) begin
      addr = `SM_TSE_MSGDMA_TX_PREF_1_CSR;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
    end

    `uvm_info(get_full_name(), "Poll for Reset Tx prefetcher to cpmplete", UVM_LOW)
    addr = `SM_TSE_MSGDMA_TX_PREF_0_CSR;
    while (rd_data[0][4] == 1) begin
      axi_master_read(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .data(rd_data)
      );
    end
    rd_data.delete();
    if (`SM_TSE_NUM_CHANNELS !== 1) begin
      addr = `SM_TSE_MSGDMA_TX_PREF_1_CSR;
      while (rd_data[0][4] == 1) begin
        axi_master_read(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .data(rd_data)
        );
      end
    end
    `uvm_info(get_full_name(), "Reset Tx prefetcher complete", UVM_LOW)

    `uvm_info(get_full_name(), "Reset Rx prefetcher", UVM_LOW)
    addr = `SM_TSE_MSGDMA_RX_PREF_0_CSR;
    csr_wdata = 'h4;
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    if (`SM_TSE_NUM_CHANNELS !== 1) begin
      addr = `SM_TSE_MSGDMA_RX_PREF_1_CSR;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
    end

    `uvm_info(get_full_name(), "Poll for Reset Rx prefetcher to cpmplete", UVM_LOW)
    addr = `SM_TSE_MSGDMA_RX_PREF_0_CSR;
    while (rd_data[0][4] == 1) begin
      axi_master_read(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .data(rd_data)
      );
    end
    rd_data.delete();
    if (`SM_TSE_NUM_CHANNELS !== 1) begin
      addr = `SM_TSE_MSGDMA_RX_PREF_1_CSR;
      while (rd_data[0][4] == 1) begin
        axi_master_read(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .data(rd_data)
        );
      end
    end
    `uvm_info(get_full_name(), "Reset Rx prefetcher complete", UVM_LOW)

    `uvm_info(get_full_name(), "Body: TX DMA CHANNELS CFG STARTS...", UVM_LOW)

    // csr_wdata = 'h14000000;
    csr_wdata = {1'b0, `DESCR, `H2D_ST_AGENT, 3'd0, 23'h0};
    wstrb[0] = 'hf;
    addr = `SM_TSE_MSGDMA_TX_PREF_0_CSR+'h4;
    `uvm_info(get_full_name(), "PORT0 TX DMA CONFIG...", UVM_LOW)
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
 
    if (h2d_ch_en[0] == 1) begin
      addr = `SM_TSE_MSGDMA_TX_PREF_0_CSR;
      csr_wdata = {30'h0, h2d_descr_poll_en[0], h2d_ch_en[0]};
      data[0] = csr_wdata;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
    end

    if (`SM_TSE_NUM_CHANNELS !== 1) begin
      // csr_wdata = 'h14000000;
      csr_wdata = {1'b0, `DESCR, `H2D_ST_AGENT, 3'd1, 23'h0};
      wstrb[0] = 'hf;
      addr = `SM_TSE_MSGDMA_TX_PREF_1_CSR+'h4;
      `uvm_info(get_full_name(), "PORT1 TX DMA CONFIG...", UVM_LOW)
      data[0] = csr_wdata;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
 
      if (h2d_ch_en[1] == 1) begin
        addr = `SM_TSE_MSGDMA_TX_PREF_1_CSR;
        csr_wdata = {30'h0, h2d_descr_poll_en[1], h2d_ch_en[1]};
        data[0] = csr_wdata;
        axi_master_write(
                .address(addr),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
    end

    `uvm_info(get_full_name(), "Body: TX DMA CHANNELS CFG ENDS...", UVM_LOW)
    `uvm_info(get_full_name(), "Body: RX DMA CHANNELS CFG STARTS...", UVM_LOW)

    // csr_wdata = 'h10000000;
    csr_wdata = {1'b0, `DESCR, `D2H_ST_AGENT, 3'd0, 23'h0};
    addr = `SM_TSE_MSGDMA_RX_PREF_0_CSR+'h4;
    `uvm_info(get_full_name(), "PORT0 RX DMA CONFIG...", UVM_LOW)
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
 
    if (d2h_ch_en[0] == 1) begin
      addr = `SM_TSE_MSGDMA_RX_PREF_0_CSR;
      csr_wdata = {30'h0, d2h_descr_poll_en[0], d2h_ch_en[0]};
      data[0] = csr_wdata;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
    end

    if (`SM_TSE_NUM_CHANNELS !== 1) begin
      // csr_wdata = 'h10000000;
      csr_wdata = {1'b0, `DESCR, `D2H_ST_AGENT, 3'd1, 23'h0};
      addr = `SM_TSE_MSGDMA_RX_PREF_1_CSR+'h4;
      `uvm_info(get_full_name(), "PORT1 RX DMA CONFIG...", UVM_LOW)
      data[0] = csr_wdata;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
 
      if (d2h_ch_en[1] == 1) begin
        addr = `SM_TSE_MSGDMA_RX_PREF_1_CSR;
        csr_wdata = {30'h0, d2h_descr_poll_en[1], d2h_ch_en[1]};
        data[0] = csr_wdata;
        axi_master_write(
                .address(addr),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
    end

    `uvm_info(get_full_name(), "Body: RX DMA CHANNELS CFG ENDS...", UVM_LOW)
    h2f_cfg_done = 1;
    `uvm_info(get_full_name(), "Body:ENDS...", UVM_DEBUG) 
  endtask: body
endclass : sm_tse_msgdma_cfg_seq
