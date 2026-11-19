//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_ETH_BASIC_SEQ__SV
`define SM_ETH_BASIC_SEQ__SV

class sm_eth_basic_seq extends uvm_sequence;
  `uvm_declare_p_sequencer(svt_axi_system_sequencer)

  bit port_lvl_loopbk;

  sm_eth_axi_master_base_seq mst_seq;

  `uvm_object_utils(sm_eth_basic_seq)

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_eth_basic_seq");
    super.new(name);
`ifdef SM_ETH_PORT_LEVEL_LOOPBACK
    port_lvl_loopbk = 1;
`else
    port_lvl_loopbk = 0;
`endif
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  virtual task body();
    super.body();

    wait_for_eth_ready();
  endtask: body

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task wait_for_eth_ready();
    `uvm_info(get_full_name(), "poll for eth ready...", UVM_LOW)
    // replace with polling through RAL status csr
`ifdef SM_ETH_MOD_DEVKIT
    wait ((`SM_ETH_HSSI_SS0_PATH.o_tx_lanes_stable === 1) && (`SM_ETH_HSSI_SS0_PATH.o_rx_pcs_ready === 1));
`else
    wait ((`SM_ETH_HSSI_SS0_PATH.o_tx_lanes_stable === 1) && (`SM_ETH_HSSI_SS0_PATH.o_rx_pcs_ready === 1));
`endif
    `uvm_info(get_full_name(), "eth is ready", UVM_LOW)
  endtask: wait_for_eth_ready

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task axi_master_write(
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0]        address,
    svt_axi_transaction::burst_size_enum     burst_sz,
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]        data [],
    bit [`SVT_AXI_MAX_BURST_LENGTH_WIDTH:0]  burst_length,
    bit [`SVT_AXI_WSTRB_WIDTH-1:0] 	         wstrb []
  );

    `uvm_create_on(mst_seq, p_sequencer.master_sequencer[0])

    if (!mst_seq.randomize() with {
            addr == address; // 'h100;
            xact_type == svt_axi_transaction::WRITE;
            burst_size == burst_sz; // svt_axi_transaction::BURST_SIZE_32BIT;
    }) `uvm_error(get_full_name(), "Randomization failure...")
    else begin
      mst_seq.burst_length = burst_length;
      mst_seq.data  = new[mst_seq.burst_length];
      mst_seq.wstrb = new[mst_seq.burst_length];
      foreach (mst_seq.data[i]) mst_seq.data[i] = data[i];
      foreach (mst_seq.wstrb[i]) mst_seq.wstrb[i] = wstrb[i];
      `uvm_info(get_full_name(),
                $sformatf(" mst_seq randomized with addr %0d\nxact_type %0s",
                            mst_seq.addr, mst_seq.xact_type),
                UVM_DEBUG)
      `uvm_info(get_full_name(), "Body: req is randomized", UVM_MEDIUM)
    end

    `uvm_send(mst_seq)
  endtask: axi_master_write

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task axi_master_read(
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0]        address,
    svt_axi_transaction::burst_size_enum     burst_sz,
    bit [`SVT_AXI_MAX_BURST_LENGTH_WIDTH:0]  burst_length,
    output bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data []
  );

    `uvm_create_on(mst_seq, p_sequencer.master_sequencer[0])

    if (!mst_seq.randomize() with {
            addr == address; // 'h100;
            xact_type == svt_axi_transaction::READ;
            burst_size == burst_sz; // svt_axi_transaction::BURST_SIZE_32BIT;
    }) `uvm_error(get_full_name(), "Randomization failure...")
    else begin
      mst_seq.burst_length = burst_length;
      `uvm_info(get_full_name(),
                $sformatf(" mst_seq randomized with addr %0d\nxact_type %0s",
                            mst_seq.addr, mst_seq.xact_type),
                UVM_DEBUG)
      `uvm_info(get_full_name(), "Body: req is randomized", UVM_DEBUG)
    end

    `uvm_send(mst_seq)

    $display($time, "wait for response object to be fetched");
    wait (mst_seq.rsp !== null);
    `uvm_info(get_full_name(),
              $sformatf(" print response object \n%s", mst_seq.rsp.sprint()),
              UVM_LOW
             )
    data = mst_seq.rsp.data;

  endtask: axi_master_read

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task poll_eth_stats();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];

    for (int addr = 'h4035_0334; addr < 'h4035_0454; addr = addr+4) begin
      axi_master_read(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
      );
      `uvm_info(get_full_name(),
                $sformatf("rx stat: addr = %0h, data = %0h", addr, data[0]),
                UVM_LOW)
    end

    for (int addr = 'h4035_0200; addr < 'h4035_0330; addr = addr+4) begin
      axi_master_read(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
      );
      `uvm_info(get_full_name(),
                $sformatf("tx stat: addr = %0h, data = %0h", addr, data[0]),
                UVM_LOW)
    end
  endtask

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_tcam0(
          int entry,
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3],
          int egr_port
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;
          
    // TCAM Entry at 0030
    data[0] = entry;
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM0_CSR_BASE +'h30),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Key register
    data[0] = key[0];
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM0_KEY_CSR_ADDR),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = key[1];
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM0_KEY_CSR_ADDR+4),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = key[2];
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM0_KEY_CSR_ADDR+8),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Result register
    data[0] = egr_port;
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM0_RESULT_CSR_ADDR),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Mask register
    for (int i=0; i<16; i=i+1) begin
      if (i < 3) begin
        data[0] = 'hFFFF_FFFF;
        axi_master_write(
                 .address(`SM_ETH_BRIDGE_TCAM0_MASK_CSR_ADDR+(i*4)),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data), .burst_length(1), .wstrb(wstrb)
        );
      end else begin
        data[0] = 'h0;
        axi_master_write(
                 .address(`SM_ETH_BRIDGE_TCAM0_MASK_CSR_ADDR+(i*4)),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data), .burst_length(1), .wstrb(wstrb)
        );
      end
    end

    // Insert the entry using Mgmt_ctrl register
    data[0] = 1;
    axi_master_write (
             .address(`SM_ETH_BRIDGE_TCAM0_CSR_BASE +'h20),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Checking whether the Entry successful or not
    while (!data[0][8]) begin
      #20ns;
      axi_master_read(
              .address(`SM_ETH_BRIDGE_TCAM0_CSR_BASE +'h20),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
      );
      if (data[0][8])
        `uvm_info(get_full_name(), "INSERT KEY IS  SUCCESSFULL..", UVM_DEBUG)
    end
  endtask: configure_tcam0

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_tcam1(
          int entry,
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3],
          int egr_port
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;
          
    // TCAM Entry at 0030
    data[0] = entry;
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM1_CSR_BASE +'h30),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Key register
    data[0] = key[0];
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM1_KEY_CSR_ADDR),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = key[1];
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM1_KEY_CSR_ADDR+4),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = key[2];
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM1_KEY_CSR_ADDR+8),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Result register
    data[0] = egr_port;
    axi_master_write(
             .address(`SM_ETH_BRIDGE_TCAM1_RESULT_CSR_ADDR),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Mask register
    for (int i=0; i<16; i=i+4) begin
      if (i < 3) begin
        data[0] = 'hFFFF_FFFF;
        axi_master_write(
                 .address(`SM_ETH_BRIDGE_TCAM1_MASK_CSR_ADDR+i),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data), .burst_length(1), .wstrb(wstrb)
        );
      end else begin
        data[0] = 'h0;
        axi_master_write(
                 .address(`SM_ETH_BRIDGE_TCAM1_MASK_CSR_ADDR+i),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data), .burst_length(1), .wstrb(wstrb)
        );
      end
    end

    // Insert the entry using Mgmt_ctrl register
    data[0] = 1;
    axi_master_write (
             .address(`SM_ETH_BRIDGE_TCAM1_CSR_BASE +'h20),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Checking whether the Entry successful or not
    while (!data[0][8]) begin
      #20ns;
      axi_master_read(
              .address(`SM_ETH_BRIDGE_TCAM1_CSR_BASE +'h20),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
      );
      if (data[0][8])
        `uvm_info(get_full_name(), "INSERT KEY IS  SUCCESSFULL..", UVM_DEBUG)
    end
  endtask: configure_tcam1

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_pkt_client0(
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] sa[2],
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] da[2],
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] num_pkts
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;

    // Setting up SA & DA 
    data[0] = da[0];
    axi_master_write(
            .address(`SM_ETH_PKTCLI0_DYN_DMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = da[1];
    axi_master_write(
            .address(`SM_ETH_PKTCLI0_DYN_DMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = sa[0];
    axi_master_write(
            .address(`SM_ETH_PKTCLI0_DYN_SMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = sa[1];
    axi_master_write(
            .address(`SM_ETH_PKTCLI0_DYN_SMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // No. of packets to transmit
    data[0] = num_pkts;
    axi_master_write(
            .address(`SM_ETH_PKTCLI0_DYN_PKT_NUM),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet size in bytes
    `uvm_info(get_full_name(), "PKTCLI0_CFG_DYN_PKT_SIZE_CFG...", UVM_DEBUG)
    data[0] = 0;
    data[0][29:16] = 'd1500;
    data[0][13:0] = 'd64;
    axi_master_write(
            .address(`SM_ETH_PKTCLI0_DYN_PKT_SIZE_CFG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet client control
    `uvm_info(get_full_name(), "PKTCLI0_CFG_PKT_CL_CTRL...", UVM_DEBUG)

    data[0] = 0;
    data[0][0] = 'h1;
    data[0][3:1] = 'h0;
    data[0][4] = 'h1;
    data[0][5] = 'h1;
    data[0][8:6] = 'h0;
    data[0][9] = 'h1;
    data[0][11:10] = 'h1;
    data[0][19:12] = 'h8;
    axi_master_write(
            .address(`SM_ETH_PKTCLI0_CFG_PKT_CL_CTRL),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );
  endtask: configure_pkt_client0

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_pkt_client1(
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] sa[2],
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] da[2],
          bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] num_pkts
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;

    // Setting up SA & DA 
    data[0] = da[0];
    axi_master_write(
            .address(`SM_ETH_PKTCLI1_DYN_DMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = da[1];
    axi_master_write(
            .address(`SM_ETH_PKTCLI1_DYN_DMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = sa[0];
    axi_master_write(
            .address(`SM_ETH_PKTCLI1_DYN_SMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = sa[1];
    axi_master_write(
            .address(`SM_ETH_PKTCLI1_DYN_SMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // No. of packets to transmit
    data[0] = num_pkts;
    axi_master_write(
            .address(`SM_ETH_PKTCLI1_DYN_PKT_NUM),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet size in bytes
    `uvm_info(get_full_name(), "PKTCLI1_CFG_DYN_PKT_SIZE_CFG...", UVM_DEBUG)
    data[0] = 0;
    data[0][29:16] = 'd1500;
    data[0][13:0] = 'd64;
    axi_master_write(
            .address(`SM_ETH_PKTCLI1_DYN_PKT_SIZE_CFG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet client control
    `uvm_info(get_full_name(), "PKTCLI1_CFG_PKT_CL_CTRL...", UVM_DEBUG)

    data[0] = 0;
    data[0][0] = 'h1;
    data[0][3:1] = 'h0;
    data[0][4] = 'h1;
    data[0][5] = 'h1;
    data[0][8:6] = 'h0;
    data[0][9] = 'h1;
    data[0][11:10] = 'h1;
    data[0][19:12] = 'h8;
    axi_master_write(
            .address(`SM_ETH_PKTCLI1_CFG_PKT_CL_CTRL),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );
  endtask: configure_pkt_client1

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task wait_for_pkts_to_complete(bit port, int num_pkts);
    bit pkt_cnt_match;
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];

    fork
      while (pkt_cnt_match != 1) begin
        repeat (100) @(posedge tb_top.clk_100m);
        if (port == 0) begin
`ifdef SM_ETH_PORT_LEVEL_LOOPBACK
          axi_master_read(
              .address(`SM_ETH_PKTCLI0_STAT_CHK_CNT),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
          );
`else
          axi_master_read(
              .address(`SM_ETH_PKTCLI1_STAT_CHK_CNT),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
          );
`endif
        end else begin
`ifdef SM_ETH_PORT_LEVEL_LOOPBACK
          axi_master_read(
              .address(`SM_ETH_PKTCLI1_STAT_CHK_CNT),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
          );
`else
          axi_master_read(
              .address(`SM_ETH_PKTCLI0_STAT_CHK_CNT),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
          );
`endif
        end
        pkt_cnt_match = (data[0] == num_pkts);
        foreach (data[i])
          `uvm_info(get_full_name(),
                    $sformatf("current packet count %0d, pkt_cnt_match %0d",
                              data[0], pkt_cnt_match),
                    UVM_LOW)
      end
      begin
        #500us;
        `uvm_error(get_full_name(), "timed out waiting for all transfers to complete")
      end
    join_any
    `uvm_info(get_full_name(), "Disabling fork", UVM_LOW)
    disable fork;
  endtask

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task read_pkt_client0_perf_stats();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    logic [63:0] rx_byte_cnt;
    logic [63:0] tx_byte_cnt;
    logic [63:0] tx_num_ticks;
    logic [63:0] rx_num_ticks;   

    real         tx_perf_data;
    real         rx_perf_data;

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_RX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_RX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_TX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_TX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_TX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_TX_NUM_TICKS_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[63:32] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_RX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_0_RX_NUM_TICKS_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_num_ticks[63:32] = data[0];

    // considering 6.2ns clk period fr 161MHz
    tx_perf_data = (tx_byte_cnt*8) / (6.2 * tx_num_ticks);
    `uvm_info("*** CLIENT 0 TX PERFORMANCE MEASUREMENT *** ",
              $sformatf("no. of bytes = 0x%0h  num_ticks = 0x%0h perf_data = %.4f Gb/s",
                         tx_byte_cnt, tx_num_ticks, tx_perf_data),
              UVM_LOW)
    rx_perf_data = (rx_byte_cnt*8) / (6.2 * rx_num_ticks);
    `uvm_info("*** CLIENT 0 RX PERFORMANCE MEASUREMENT *** ",
              $sformatf("no. of bytes = 0x%0h  num_ticks = 0x%0h perf_data = %.4f Gb/s",
                        rx_byte_cnt, rx_num_ticks, rx_perf_data),
              UVM_LOW)

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_CHK_MISC),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    foreach(data[i]) begin
      `uvm_info(get_full_name(),
                $sformatf("pkt client 0: STAT_CHECKER_MISC %0h", data[i]), UVM_LOW)
      if (data[i][0] == 1)
        `uvm_error(get_full_name(), "Data mismatch detected at pkt cli 0")
    end
  endtask: read_pkt_client0_perf_stats

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task read_pkt_client1_perf_stats();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    logic [63:0] rx_byte_cnt;
    logic [63:0] tx_byte_cnt;
    logic [63:0] tx_num_ticks;
    logic [63:0] rx_num_ticks;   

    real         tx_perf_data;
    real         rx_perf_data;

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_RX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_RX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_TX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_TX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_TX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_TX_NUM_TICKS_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[63:32] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_RX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_ETH_PKT_CLIENT_1_RX_NUM_TICKS_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_num_ticks[63:32] = data[0];

    // considering 6.2ns clk period fr 161MHz
    tx_perf_data = (tx_byte_cnt*8) / (6.2 * tx_num_ticks);
    `uvm_info("*** CLIENT 1 TX PERFORMANCE MEASUREMENT *** ",
              $sformatf("no. of bytes = 0x%0h  num_ticks = 0x%0h perf_data = %.4f Gb/s",
                         tx_byte_cnt, tx_num_ticks, tx_perf_data),
              UVM_LOW)
    rx_perf_data = (rx_byte_cnt*8) / (6.2 * rx_num_ticks);
    `uvm_info("*** CLIENT 1 RX PERFORMANCE MEASUREMENT *** ",
              $sformatf("no. of bytes = 0x%0h  num_ticks = 0x%0h perf_data = %.4f Gb/s",
                        rx_byte_cnt, rx_num_ticks, rx_perf_data),
              UVM_LOW)

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_CHK_MISC),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    foreach(data[i]) begin
      `uvm_info(get_full_name(),
                $sformatf("pkt client 1: STAT_CHECKER_MISC %0h", data[i]), UVM_LOW)
      if (data[i][0] == 1)
        `uvm_error(get_full_name(), "Data mismatch detected at pkt cli 1")
    end
  endtask: read_pkt_client1_perf_stats

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task match_sop_eop(bit port = 0);
    bit [63:0] p0_tx_sop, p0_tx_eop;
    bit [63:0] p0_rx_sop, p0_rx_eop;
    bit [63:0] p1_tx_sop, p1_tx_eop;
    bit [63:0] p1_rx_sop, p1_rx_eop;

    if (port == 0)
      read_p0_tx_sop_eop(p0_tx_sop, p0_tx_eop);
    else
      read_p1_tx_sop_eop(p1_tx_sop, p1_tx_eop);
`ifdef SM_ETH_PORT_LEVEL_LOOPBACK
    if (port == 0) begin
      read_p0_rx_sop_eop(p0_rx_sop, p0_rx_eop);
      if (p0_tx_sop !== p0_rx_sop)
        `uvm_error(get_full_name(),
                   $sformatf("p0_tx_sop %0d not same as p0_rx_sop %0d",
                              p0_tx_sop, p0_rx_sop))
      if (p0_tx_eop !== p0_rx_eop)
        `uvm_error(get_full_name(),
                   $sformatf("p0_tx_eop %0d not same as p0_rx_eop %0d",
                              p0_tx_eop, p0_rx_eop))
    end else begin
      read_p1_rx_sop_eop(p1_rx_sop, p1_rx_eop);
      if (p1_tx_sop !== p1_rx_sop)
        `uvm_error(get_full_name(),
                   $sformatf("p1_tx_sop %0d not same as p1_rx_sop %0d",
                              p1_tx_sop, p1_rx_sop))
      if (p1_tx_eop !== p1_rx_eop)
        `uvm_error(get_full_name(),
                   $sformatf("p1_tx_eop %0d not same as p1_rx_eop %0d",
                              p1_tx_eop, p1_rx_eop))
    end
`else
    if (port == 0) begin
      read_p1_rx_sop_eop(p1_rx_sop, p1_rx_eop);
      if (p1_tx_sop !== p1_rx_sop)
        `uvm_error(get_full_name(),
                   $sformatf("p1_tx_sop %0d not same as p1_rx_sop %0d",
                              p1_tx_sop, p1_rx_sop))
      if (p1_tx_eop !== p1_rx_eop)
        `uvm_error(get_full_name(),
                   $sformatf("p1_tx_eop %0d not same as p1_rx_eop %0d",
                              p1_tx_eop, p1_rx_eop))
    end else begin
      read_p0_rx_sop_eop(p0_rx_sop, p0_rx_eop);
      if (p0_tx_sop !== p0_rx_sop)
        `uvm_error(get_full_name(),
                   $sformatf("p0_tx_sop %0d not same as p0_rx_sop %0d",
                              p0_tx_sop, p0_rx_sop))
      if (p0_tx_eop !== p0_rx_eop)
        `uvm_error(get_full_name(),
                   $sformatf("p0_tx_eop %0d not same as p0_rx_eop %0d",
                              p0_tx_eop, p0_rx_eop))
    end
`endif
  endtask

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task read_p0_tx_sop_eop(bit [63:0] p0_tx_sop, bit [63:0] p0_tx_eop);
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];

    bit [31:0] p0_tx_sop_l, p0_tx_sop_u;
    bit [31:0] p0_tx_eop_l, p0_tx_eop_u;

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_TX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_tx_sop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_TX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_tx_sop_u = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_TX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_tx_eop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_TX_EOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_tx_eop_u = data[0];

    p0_tx_sop = {p0_tx_sop_u, p0_tx_sop_l};
    p0_tx_eop = {p0_tx_eop_u, p0_tx_eop_l};
    `uvm_info(get_full_name(),
              $sformatf({"p0_tx_sop_u %0d, p0_tx_sop_l %0d\n",
                         "p0_tx_eop_u %0d, p0_tx_eop_l %0d\n",
                         "p0_tx_sop %0d, p0_tx_eop %0d"},
                        p0_tx_sop_u, p0_tx_sop_l, p0_tx_eop_u, p0_tx_eop_l, p0_tx_sop, p0_tx_eop),
              UVM_LOW)
  endtask

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task read_p0_rx_sop_eop(bit [63:0] p0_rx_sop, bit [63:0] p0_rx_eop);
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];

    bit [31:0] p0_rx_sop_l, p0_rx_sop_u;
    bit [31:0] p0_rx_eop_l, p0_rx_eop_u;

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_RX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_rx_sop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_RX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_rx_sop_u = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_RX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_rx_eop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI0_STAT_RX_EOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_rx_eop_u = data[0];

    p0_rx_sop = {p0_rx_sop_u, p0_rx_sop_l};
    p0_rx_eop = {p0_rx_eop_u, p0_rx_eop_l};
    `uvm_info(get_full_name(),
              $sformatf({"p0_rx_sop_u %0d, p0_rx_sop_l %0d\n",
                         "p0_rx_eop_u %0d, p0_rx_eop_l %0d\n",
                         "p0_rx_sop %0d, p0_rx_eop %0d"},
                        p0_rx_sop_u, p0_rx_sop_l, p0_rx_eop_u, p0_rx_eop_l, p0_rx_sop, p0_rx_eop),
              UVM_LOW)
  endtask

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task read_p1_tx_sop_eop(bit [63:0] p1_tx_sop, bit [63:0] p1_tx_eop);
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];

    bit [31:0] p1_tx_sop_l, p1_tx_sop_u;
    bit [31:0] p1_tx_eop_l, p1_tx_eop_u;

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_TX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_tx_sop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_TX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_tx_sop_u = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_TX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_tx_eop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_TX_EOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_tx_eop_u = data[0];

    p1_tx_sop = {p1_tx_sop_u, p1_tx_sop_l};
    p1_tx_eop = {p1_tx_eop_u, p1_tx_eop_l};
    `uvm_info(get_full_name(),
              $sformatf({"p1_tx_sop_u %0d, p1_tx_sop_l %0d\n",
                         "p1_tx_eop_u %0d, p1_tx_eop_l %0d\n",
                         "p1_tx_sop %0d, p1_tx_eop %0d"},
                        p1_tx_sop_u, p1_tx_sop_l, p1_tx_eop_u, p1_tx_eop_l, p1_tx_sop, p1_tx_eop),
              UVM_LOW)
  endtask

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task read_p1_rx_sop_eop(bit [63:0] p1_rx_sop, bit [63:0] p1_rx_eop);
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];

    bit [31:0] p1_rx_sop_l, p1_rx_sop_u;
    bit [31:0] p1_rx_eop_l, p1_rx_eop_u;

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_RX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_rx_sop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_RX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_rx_sop_u = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_RX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_rx_eop_l = data[0];

    axi_master_read(
        .address(`SM_ETH_PKTCLI1_STAT_RX_EOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_rx_eop_u = data[0];

    p1_rx_sop = {p1_rx_sop_u, p1_rx_sop_l};
    p1_rx_eop = {p1_rx_eop_u, p1_rx_eop_l};
    `uvm_info(get_full_name(),
              $sformatf({"p1_rx_sop_u %0d, p1_rx_sop_l %0d\n",
                         "p1_rx_eop_u %0d, p1_rx_eop_l %0d\n",
                         "p1_rx_sop %0d, p1_rx_eop %0d"},
                        p1_rx_sop_u, p1_rx_sop_l, p1_rx_eop_u, p1_rx_eop_l, p1_rx_sop, p1_rx_eop),
              UVM_LOW)
  endtask
endclass: sm_eth_basic_seq

`endif // SM_ETH_BASIC_SEQ__SV
