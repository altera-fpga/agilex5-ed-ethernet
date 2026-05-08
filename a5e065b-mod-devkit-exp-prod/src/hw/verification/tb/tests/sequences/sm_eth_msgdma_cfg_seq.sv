//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//#This is base sequence used to configure PKT CLIENTS,
//#TXDMA and RX DMA for basic data flow.
//########################################################################
class sm_eth_msgdma_cfg_seq extends sm_eth_basic_seq;
    
  rand int no_of_transactions ;
  rand int unsigned cfg_sequence_length = 10;
  rand bit                              h2d_descr_poll_en;
  rand bit                              d2h_descr_poll_en;

  `uvm_object_utils_begin(sm_eth_msgdma_cfg_seq);
    `uvm_field_int(h2d_descr_poll_en, UVM_ALL_ON)
    `uvm_field_int(d2h_descr_poll_en, UVM_ALL_ON)
  `uvm_object_utils_end

  function new (string name = "sm_eth_msgdma_cfg_seq");
    super.new(name);
  endfunction : new

    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]     data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]        wstrb [];
    bit [31:0]                            exp_data,obs_data,addr;
    bit [7:0]                             idle_cycle;   
    bit [1:0]                             mode_len;   
    bit                                   pkt_gap;   
    bit                                   pkt_chk_en;   
    bit                                   dyn_mode;   
    bit                                   traff_en;   
    bit [31:0]                            csr_wdata;   
    bit                                   h2f_cfg_done; 
    rand bit [5:0]                        ch_en;
    rand bit [1:0]                        usr_en;

  constraint ch_en_c {
     soft ch_en == 0;
  }

  constraint usr_en_c {
     soft usr_en == 0;
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
              $sformatf("desc poll en, h2d %0d, d2h %0d",
                        this.h2d_descr_poll_en, this.d2h_descr_poll_en),
              UVM_LOW)

    `uvm_info(get_full_name(), "Reset Tx prefetcher", UVM_LOW)
    addr = `SM_ETH_SSGDMA_CSR_ADDR;
    csr_wdata = 'h4;
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "Poll for Reset Tx prefetcher to cpmplete", UVM_LOW)
    addr = `SM_ETH_SSGDMA_CSR_ADDR;
    while (rd_data[0][4] == 1) begin
      axi_master_read(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .data(rd_data)
      );
    end
    `uvm_info(get_full_name(), "Reset Tx prefetcher complete", UVM_LOW)

    `uvm_info(get_full_name(), "Reset Rx prefetcher", UVM_LOW)
    addr = `SM_ETH_SSGDMA_CSR_ADDR+'h80;
    csr_wdata = 'h4;
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "Poll for Reset Rx prefetcher to cpmplete", UVM_LOW)
    addr = `SM_ETH_SSGDMA_CSR_ADDR+'h80;
    while (rd_data[0][4] == 1) begin
      axi_master_read(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .data(rd_data)
      );
    end
    `uvm_info(get_full_name(), "Reset Rx prefetcher complete", UVM_LOW)

    `uvm_info(get_full_name(), "Body: TX DMA CHANNELS CFG STARTS...", UVM_LOW)
    
    csr_wdata = 'h14000000;
    wstrb[0] = 'hf;
    addr = `SM_ETH_SSGDMA_CSR_ADDR+'h4;
    `uvm_info(get_full_name(), "PORT0 TX DMA CONFIG...", UVM_LOW)
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
 
    addr = `SM_ETH_SSGDMA_CSR_ADDR;
    if (h2d_descr_poll_en == 1)
      csr_wdata = 'h3;
    else
      csr_wdata = 'h1;
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "Body: TX DMA CHANNELS CFG ENDS...", UVM_LOW)
    `uvm_info(get_full_name(), "Body: RX DMA CHANNELS CFG STARTS...", UVM_LOW)

    csr_wdata = 'h10000000;
    // addr = DMA_PORT0_BASE_RXDMA_PREF_ADDR+'h4;
    addr = `SM_ETH_SSGDMA_CSR_ADDR+'h80+'h4;
    `uvm_info(get_full_name(), "PORT0 RX DMA CONFIG...", UVM_LOW)
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
 
    $display ("CHANNEL EN = %h", ch_en);
    addr = `SM_ETH_SSGDMA_CSR_ADDR+'h80;
    if (d2h_descr_poll_en == 1)
      csr_wdata = 'h3;
    else
      csr_wdata = 'h1;
    data[0] = csr_wdata;
    axi_master_write(
            .address(addr),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "Body: RX DMA CHANNELS CFG ENDS...", UVM_LOW)
    h2f_cfg_done = 1;
    `uvm_info(get_full_name(), "Body:ENDS...", UVM_DEBUG) 
  endtask: body
endclass : sm_eth_msgdma_cfg_seq
