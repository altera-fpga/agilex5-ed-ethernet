//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_TSE_BASIC_SEQ__SV
`define SM_TSE_BASIC_SEQ__SV

class sm_tse_basic_seq extends uvm_sequence;
  `uvm_declare_p_sequencer(svt_axi_system_sequencer)

  sm_tse_axi_master_base_seq mst_seq;

  `uvm_object_utils(sm_tse_basic_seq)

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_tse_basic_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  virtual task body();
    super.body();

    wait_for_eth_ready();
    configure_tse0();
    `ifdef NUM_CHANNELS_2
      configure_tse1();
    `endif
  endtask: body

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task wait_for_eth_ready();
    `uvm_info(get_full_name(), "poll for eth ready...", UVM_LOW)
    // replace with polling through RAL status csr
    wait ((&(`SM_TSE_TX_READY) === 1) && (&(`SM_TSE_RX_READY) === 1));
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

    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h68),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 aFramesTransmittedOK: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h68, data[0]),
             UVM_LOW)

    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h6c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 aFramesReceivedOK: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h6c, data[0]),
             UVM_LOW)
   `ifdef NUM_CHANNELS_2
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h68),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 aFramesTransmittedOK: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h68, data[0]),
             UVM_LOW)

    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h6c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 aFramesReceivedOK: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h6c, data[0]),
             UVM_LOW)
   `endif
/*
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
*/
  endtask

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_tse0();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hff;
    
    // COMMAND_CONFIG REGISTER
    // TX_ENA and RX_ENA = 0 
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h8, data[0]),
             UVM_LOW)
            
    assert ( data[0][1:0] == 2'b00 ) else begin
      `uvm_info(get_full_name(), "TX_ENA and RX_ENA not set 0...", UVM_LOW)
      
       data[0][0]       = 1'b0;     // TX_ENA = 0 
       data[0][1]       = 1'b0;     // RX_ENA = 0 

       axi_master_write(
                .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data), .burst_length(1), .wstrb(wstrb)
       );
       axi_master_read(
              .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
       );
      `uvm_info(get_full_name(),
                $sformatf("mac0 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h8, data[0]),
                UVM_LOW) 
    end
                
    // OPEN: External PHY Initialization using MDIO
    
    // PCS Configuration Register Initialization...
/*
    // PCS AUTO NEGOTIATION LINK TIMER REGISTERS
    data[0]    = ( 'h0d40 );

    axi_master_write(
             .address(`SM_TSE_PCS_PORT0_BASE + 'h48),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_PCS_PORT0_BASE + 'h48),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs0 link_timer0: addr = %0h, data = %0h", `SM_TSE_PCS_PORT0_BASE + 'h48, data[0]),
             UVM_LOW)

    data[0]    = ( 'h03 );

    axi_master_write(
             .address(`SM_TSE_PCS_PORT0_BASE + 'h4c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_PCS_PORT0_BASE + 'h4c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs0 link_timer1: addr = %0h, data = %0h", `SM_TSE_PCS_PORT0_BASE + 'h4c, data[0]),
             UVM_LOW)
*/             
    // PCS IF_MODE REGISTER
    // Configure SGMII (SGMII_ENA = 1, USE_SGMII_AN = 0)
    axi_master_read(
           .address(`SM_TSE_PCS_PORT0_BASE + 'h50),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs0 if_mode: addr = %0h, data = %0h", `SM_TSE_PCS_PORT0_BASE + 'h50, data[0]),
             UVM_LOW)    
    
    data[0][0]    = 1'b1;    // SGMII_ENA = 1
    data[0][1]    = 1'b0;    // USE_SGMII_AN = 0
    data[0][3:2]  = 2'b10;   // SGMII_SPEED = 10 (1 Gigabit)
    
    axi_master_write(
             .address(`SM_TSE_PCS_PORT0_BASE + 'h50),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_PCS_PORT0_BASE + 'h50),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs0 if_mode: addr = %0h, data = %0h", `SM_TSE_PCS_PORT0_BASE + 'h50, data[0]),
             UVM_LOW)
    
    // PCS CONTROL REGISTER
    // Disable Auto-Negotiation; Select Gigabit Speed; PCS Reset
    axi_master_read(
           .address(`SM_TSE_PCS_PORT0_BASE),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs0 control: addr = %0h, data = %0h", `SM_TSE_PCS_PORT0_BASE, data[0]),
             UVM_LOW)  

    data[0][12]      = 1'b0;     // AUTO_NEGOTIATION_ENABLE = 0
    { data[0][6],
      data[0][13] }  = 2'b10;    // SPEED_SELECTION = 10
    data[0][15]      = 1'b1;     // PCS RESET = 1 (self-clearing)
    
    axi_master_write(
             .address(`SM_TSE_PCS_PORT0_BASE),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    // Wait for PCS RESET to clear...
    while ( data[0][15] ) begin  
       axi_master_read(
              .address(`SM_TSE_PCS_PORT0_BASE),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
       );
      `uvm_info(get_full_name(),
                $sformatf("pcs0 control: addr = %0h, data = %0h", `SM_TSE_PCS_PORT0_BASE, data[0]),
                UVM_LOW)  
    end
    
    // PCS STATUS REGISTER (RO)
    axi_master_read(
           .address(`SM_TSE_PCS_PORT0_BASE + 'h4),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs0 status: addr = %0h, data = %0h", `SM_TSE_PCS_PORT0_BASE + 'h4, data[0]),
             UVM_LOW)
             
    // MAC Configuration Register Initialization...

    // TX_SECTION_EMPTY
    data[0]    = ( 8192 - 16 );  // Max FIFO size - 16
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h24),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h24),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 tx_section_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h24, data[0]),
             UVM_LOW)    

    // TX_ALMOST_FULL
    data[0]    = ( 3 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h38),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h38),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 tx_almost_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h38, data[0]),
             UVM_LOW)   

    // TX_ALMOST_EMPTY
    data[0]    = ( 8 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h34),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h34),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 tx_almost_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h34, data[0]),
             UVM_LOW)  

    // RX_SECTION_EMPTY
    data[0]    = ( 8192 - 16 );  // Max FIFO size - 16
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h1c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h1c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 rx_section_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h1c, data[0]),
             UVM_LOW)    

    // RX_ALMOST_FULL
    data[0]    = ( 8 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h30),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h30),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 rx_almost_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h30, data[0]),
             UVM_LOW)   

    // RX_ALMOST_EMPTY
    data[0]    = ( 8 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h2c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h2c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 rx_almost_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h2c, data[0]),
             UVM_LOW)  

    // TX_SECTION_FULL
    data[0]    = ( 16 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h28),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h28),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 tx_section_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h28, data[0]),
             UVM_LOW) 

    // RX_SECTION_FULL
    data[0]    = ( 16 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h20),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h20),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 rx_section_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h20, data[0]),
             UVM_LOW)

    // MAC_0 ADDRESS
    data[0]    = {SM_TSE_MAC_PORT0_ADDR[23:16],
                  SM_TSE_MAC_PORT0_ADDR[31:24],
                  SM_TSE_MAC_PORT0_ADDR[39:32],
                  SM_TSE_MAC_PORT0_ADDR[47:40]};
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'hc),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'hc),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 mac_0 address: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'hc, data[0]),
             UVM_LOW)

    // MAC_1 ADDRESS
    data[0]    = {8'h00,
                  8'h00,
                  SM_TSE_MAC_PORT0_ADDR[7:0],
                  SM_TSE_MAC_PORT0_ADDR[15:8]};
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h10),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h10),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 mac_1 address: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h10, data[0]),
             UVM_LOW)

    // FRAME_LENGTH
    data[0]    = ( 1518 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h14),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h14),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 frame_length: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h14, data[0]),
             UVM_LOW)

    // TX_IPG_LENGTH
    data[0]    = ( 12 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h5c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h5c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 frame_length: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h5c, data[0]),
             UVM_LOW)

    // PAUSE_QUANT
    data[0]    = ( 'hffff );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h18),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h18),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 frame_length: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h18, data[0]),
             UVM_LOW)

    // COMMAND_CONFIG REGISTER
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h8, data[0]),
             UVM_LOW)

    data[0][3]       = 1'b1;     // 1000Mbps
    data[0][5]       = 1'b1;     // Padding Removal on Receive
    data[0][6]       = 1'b0;     // CRC Removal
    data[0][9]       = 1'b1;     // TX MAC Address Insertion on Transmit Packet
    data[0][13]      = 1'b1;     // MAC RESET (self-clearing)
    data[0][18:16]   = 3'b000;   // Select mac_0 and mac_1 as the source MAC Address
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    // Wait for MAC RESET to clear...
    while ( data[0][13] ) begin  
       axi_master_read(
              .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
       );
      `uvm_info(get_full_name(),
                $sformatf("mac0 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h8, data[0]),
                UVM_LOW)  
    end

    data[0][0]       = 1'b1;     // TX_ENA = 1 
    data[0][1]       = 1'b1;     // RX_ENA = 1 

    axi_master_write(
             .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT0_BASE + 'h8),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac0 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT0_BASE + 'h8, data[0]),
             UVM_LOW)

  endtask: configure_tse0

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_tse1();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hff;

    // COMMAND_CONFIG REGISTER
    // TX_ENA and RX_ENA = 0 
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h8, data[0]),
             UVM_LOW)
            
    assert ( data[0][1:0] == 2'b00 ) else begin
      `uvm_info(get_full_name(), "TX_ENA and RX_ENA not set 0...", UVM_LOW)
      
       data[0][0]       = 1'b0;     // TX_ENA = 0 
       data[0][1]       = 1'b0;     // RX_ENA = 0 

       axi_master_write(
                .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data), .burst_length(1), .wstrb(wstrb)
       );
       axi_master_read(
              .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
       );
      `uvm_info(get_full_name(),
                $sformatf("mac1 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h8, data[0]),
                UVM_LOW) 
    end
                
    // OPEN: External PHY Initialization using MDIO
    
    // PCS Configuration Register Initialization...
/*
    // PCS AUTO NEGOTIATION LINK TIMER REGISTERS
    data[0]    = ( 'h0d40 );

    axi_master_write(
             .address(`SM_TSE_PCS_PORT1_BASE + 'h48),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_PCS_PORT1_BASE + 'h48),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs1 link_timer0: addr = %0h, data = %0h", `SM_TSE_PCS_PORT1_BASE + 'h48, data[0]),
             UVM_LOW)

    data[0]    = ( 'h03 );

    axi_master_write(
             .address(`SM_TSE_PCS_PORT1_BASE + 'h4c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_PCS_PORT1_BASE + 'h4c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs1 link_timer1: addr = %0h, data = %0h", `SM_TSE_PCS_PORT1_BASE + 'h4c, data[0]),
             UVM_LOW)
*/    
    // PCS IF_MODE REGISTER
    // Configure SGMII (SGMII_ENA = 1, USE_SGMII_AN = 0)
    axi_master_read(
           .address(`SM_TSE_PCS_PORT1_BASE + 'h50),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs1 if_mode: addr = %0h, data = %0h", `SM_TSE_PCS_PORT1_BASE + 'h50, data[0]),
             UVM_LOW)    
    
    data[0][0]    = 1'b1;    // SGMII_ENA = 1
    data[0][1]    = 1'b0;    // USE_SGMII_AN = 0
    data[0][3:2]  = 2'b10;   // SGMII_SPEED = 10 (1 Gigabit)
    
    axi_master_write(
             .address(`SM_TSE_PCS_PORT1_BASE + 'h50),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_PCS_PORT1_BASE + 'h50),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs1 if_mode: addr = %0h, data = %0h", `SM_TSE_PCS_PORT1_BASE + 'h50, data[0]),
             UVM_LOW)
    
    // PCS CONTROL REGISTER
    // Disable Auto-Negotiation; Select Gigabit Speed; PCS Reset
    axi_master_read(
           .address(`SM_TSE_PCS_PORT1_BASE),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs1 control: addr = %0h, data = %0h", `SM_TSE_PCS_PORT1_BASE, data[0]),
             UVM_LOW)  

    data[0][12]      = 1'b0;     // AUTO_NEGOTIATION_ENABLE = 0
    { data[0][6],
      data[0][13] }  = 2'b10;    // SPEED_SELECTION = 10
    data[0][15]      = 1'b1;     // PCS RESET = 1 (self-clearing)
    
    axi_master_write(
             .address(`SM_TSE_PCS_PORT1_BASE),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    // Wait for PCS RESET to clear...
    while ( data[0][15] ) begin  
       axi_master_read(
              .address(`SM_TSE_PCS_PORT1_BASE),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
       );
      `uvm_info(get_full_name(),
                $sformatf("pcs1 control: addr = %0h, data = %0h", `SM_TSE_PCS_PORT1_BASE, data[0]),
                UVM_LOW)  
    end
    
    // PCS STATUS REGISTER (RO)
    axi_master_read(
           .address(`SM_TSE_PCS_PORT1_BASE + 'h4),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("pcs1 status: addr = %0h, data = %0h", `SM_TSE_PCS_PORT1_BASE + 'h4, data[0]),
             UVM_LOW)
             
    // MAC Configuration Register Initialization...

    // TX_SECTION_EMPTY
    data[0]    = ( 8192 - 16 );  // Max FIFO size - 16
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h24),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h24),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 tx_section_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h24, data[0]),
             UVM_LOW)    

    // TX_ALMOST_FULL
    data[0]    = ( 3 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h38),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h38),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 tx_almost_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h38, data[0]),
             UVM_LOW)   

    // TX_ALMOST_EMPTY
    data[0]    = ( 8 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h34),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h34),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 tx_almost_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h34, data[0]),
             UVM_LOW)  

    // RX_SECTION_EMPTY
    data[0]    = ( 8192 - 16 );  // Max FIFO size - 16
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h1c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h1c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 rx_section_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h1c, data[0]),
             UVM_LOW)    

    // RX_ALMOST_FULL
    data[0]    = ( 8 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h30),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h30),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 rx_almost_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h30, data[0]),
             UVM_LOW)   

    // RX_ALMOST_EMPTY
    data[0]    = ( 8 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h2c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h2c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 rx_almost_empty: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h2c, data[0]),
             UVM_LOW)  

    // TX_SECTION_FULL
    data[0]    = ( 16 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h28),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h28),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 tx_section_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h28, data[0]),
             UVM_LOW) 

    // RX_SECTION_FULL
    data[0]    = ( 16 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h20),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h20),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 rx_section_full: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h20, data[0]),
             UVM_LOW)

    // MAC_0 ADDRESS
    data[0]    = {SM_TSE_MAC_PORT1_ADDR[23:16],
                  SM_TSE_MAC_PORT1_ADDR[31:24],
                  SM_TSE_MAC_PORT1_ADDR[39:32],
                  SM_TSE_MAC_PORT1_ADDR[47:40]};
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'hc),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'hc),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 mac_0 address: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'hc, data[0]),
             UVM_LOW)

    // MAC_1 ADDRESS
    data[0]    = {8'h00,
                  8'h00,
                  SM_TSE_MAC_PORT1_ADDR[7:0],
                  SM_TSE_MAC_PORT1_ADDR[15:8]};
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h10),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h10),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 mac_1 address: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h10, data[0]),
             UVM_LOW)

    // FRAME_LENGTH
    data[0]    = ( 1518 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h14),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h14),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 frame_length: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h14, data[0]),
             UVM_LOW)

    // TX_IPG_LENGTH
    data[0]    = ( 12 );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h5c),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h5c),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 frame_length: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h5c, data[0]),
             UVM_LOW)

    // PAUSE_QUANT
    data[0]    = ( 'hffff );
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h18),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h18),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 frame_length: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h18, data[0]),
             UVM_LOW)

    // COMMAND_CONFIG REGISTER
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h8, data[0]),
             UVM_LOW)

    data[0][3]       = 1'b1;     // 1000Mbps
    data[0][5]       = 1'b1;     // Padding Removal on Receive
    data[0][6]       = 1'b0;     // CRC Removal
    data[0][9]       = 1'b1;     // TX MAC Address Insertion on Transmit Packet
    data[0][13]      = 1'b1;     // MAC RESET (self-clearing)
    data[0][18:16]   = 3'b000;   // Select mac_0 and mac_1 as the source MAC Address
    
    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    // Wait for MAC RESET to clear...
    while ( data[0][13] ) begin  
       axi_master_read(
              .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
       );
      `uvm_info(get_full_name(),
                $sformatf("mac1 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h8, data[0]),
                UVM_LOW)  
    end

    data[0][0]       = 1'b1;     // TX_ENA = 1 
    data[0][1]       = 1'b1;     // RX_ENA = 1 

    axi_master_write(
             .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data), .burst_length(1), .wstrb(wstrb)
    );
    axi_master_read(
           .address(`SM_TSE_MAC_PORT1_BASE + 'h8),
           .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
           .burst_length(1), .data(data)
    );
   `uvm_info(get_full_name(),
             $sformatf("mac1 command_config: addr = %0h, data = %0h", `SM_TSE_MAC_PORT1_BASE + 'h8, data[0]),
             UVM_LOW)
             
  endtask: configure_tse1

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_mac0(
          input int entry,
          inout bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3],
          input int egr_port
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;

`ifdef NUM_CHANNELS_2    
    key[0] = SM_TSE_MAC_PORT0_ADDR[31:0];
    key[1] = {SM_TSE_MAC_PORT1_ADDR[15:0], SM_TSE_MAC_PORT0_ADDR[47:32]};
    key[2] = SM_TSE_MAC_PORT1_ADDR[47:16];
`else
    key[0] = SM_TSE_MAC_PORT0_ADDR[31:0];
    key[1] = {SM_TSE_MAC_PORT0_ADDR[15:0], SM_TSE_MAC_PORT0_ADDR[47:32]};
    key[2] = SM_TSE_MAC_PORT0_ADDR[47:16];
`endif

  endtask: configure_mac0

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_mac1(
          input int entry,
          inout bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3],
          input int egr_port
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;
    
`ifdef NUM_CHANNELS_2    
    key[0] = SM_TSE_MAC_PORT1_ADDR[31:0];
    key[1] = {SM_TSE_MAC_PORT0_ADDR[15:0], SM_TSE_MAC_PORT1_ADDR[47:32]};
    key[2] = SM_TSE_MAC_PORT0_ADDR[47:16];
`else
    key[0] = SM_TSE_MAC_PORT1_ADDR[31:0];
    key[1] = {SM_TSE_MAC_PORT1_ADDR[15:0], SM_TSE_MAC_PORT1_ADDR[47:32]};
    key[2] = SM_TSE_MAC_PORT1_ADDR[47:16];
`endif

  endtask: configure_mac1

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_pkt_client0(
    bit [47:0] sa, bit [47:0] da,
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] num_pkts,
    bit soft_rst, bit fxd_gap, bit [1:0] len_mode, bit [7:0] idle_cycles
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;

    // Setting up SA & DA 
    data[0] = da[31:0];
    axi_master_write(
            .address(`SM_TSE_PKTCLI0_DYN_DMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0][15:0] = da[47:32];
    axi_master_write(
            .address(`SM_TSE_PKTCLI0_DYN_DMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = sa[31:0];
    axi_master_write(
            .address(`SM_TSE_PKTCLI0_DYN_SMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0][15:0] = sa[47:32];
    axi_master_write(
            .address(`SM_TSE_PKTCLI0_DYN_SMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // No. of packets to transmit
    data[0] = num_pkts;
    axi_master_write(
            .address(`SM_TSE_PKTCLI0_DYN_PKT_NUM),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet size in bytes
    `uvm_info(get_full_name(), "PKTCLI0_CFG_DYN_PKT_SIZE_CFG...", UVM_DEBUG)
    data[0] = 0;
    data[0][29:16] = 'd1500;
    data[0][13:0] = 'd64;
    axi_master_write(
            .address(`SM_TSE_PKTCLI0_DYN_PKT_SIZE_CFG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet client control
    `uvm_info(get_full_name(), "PKTCLI0_CFG_PKT_CL_CTRL...", UVM_DEBUG)

    data[0] = 0;
    data[0][0] = 'h1;
    data[0][2:1] = 'h0;
    data[0][3] = soft_rst;
    data[0][4] = 'h1;
    data[0][5] = 'h1;
    data[0][8:6] = 'h0;
    data[0][9] = fxd_gap;
    data[0][11:10] = len_mode;
    data[0][19:12] = idle_cycles;
    axi_master_write(
            .address(`SM_TSE_PKTCLI0_CFG_PKT_CL_CTRL),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );
  endtask: configure_pkt_client0

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task configure_pkt_client1(
    bit [47:0] sa, bit [47:0] da,
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] num_pkts,
    bit soft_rst, bit fxd_gap, bit [1:0] len_mode, bit [7:0] idle_cycles
  );
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]    wstrb [];
  
    data = new[1];
    wstrb = new[1];
    wstrb[0] = 'hf;

    // Setting up SA & DA 
    data[0] = da[31:0];
    axi_master_write(
            .address(`SM_TSE_PKTCLI1_DYN_DMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0][15:0] = da[47:32];
    axi_master_write(
            .address(`SM_TSE_PKTCLI1_DYN_DMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0] = sa[31:0];
    axi_master_write(
            .address(`SM_TSE_PKTCLI1_DYN_SMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    data[0][15:0] = sa[47:32];
    axi_master_write(
            .address(`SM_TSE_PKTCLI1_DYN_SMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // No. of packets to transmit
    data[0] = num_pkts;
    axi_master_write(
            .address(`SM_TSE_PKTCLI1_DYN_PKT_NUM),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet size in bytes
    `uvm_info(get_full_name(), "PKTCLI1_CFG_DYN_PKT_SIZE_CFG...", UVM_DEBUG)
    data[0] = 0;
    data[0][29:16] = 'd1500;
    data[0][13:0] = 'd64;
    axi_master_write(
            .address(`SM_TSE_PKTCLI1_DYN_PKT_SIZE_CFG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data), .burst_length(1), .wstrb(wstrb)
    );

    // Configuring the Packet client control
    `uvm_info(get_full_name(), "PKTCLI1_CFG_PKT_CL_CTRL...", UVM_DEBUG)

    data[0] = 0;
    data[0][0] = 'h1;
    data[0][2:1] = 'h0;
    data[0][3] = soft_rst;
    data[0][4] = 'h1;
    data[0][5] = 'h1;
    data[0][8:6] = 'h0;
    data[0][9] = fxd_gap;
    data[0][11:10] = len_mode;
    data[0][19:12] = idle_cycles;
    axi_master_write(
            .address(`SM_TSE_PKTCLI1_CFG_PKT_CL_CTRL),
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
`ifdef SM_TSE_PORT_LEVEL_LOOPBACK
          axi_master_read(
              .address(`SM_TSE_PKTCLI0_STAT_CHK_CNT),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
          );
`else
          axi_master_read(
              .address(`SM_TSE_PKTCLI1_STAT_CHK_CNT),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
          );
`endif
        end else begin
`ifdef SM_TSE_PORT_LEVEL_LOOPBACK
          axi_master_read(
              .address(`SM_TSE_PKTCLI1_STAT_CHK_CNT),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1), .data(data)
          );
`else
          axi_master_read(
              .address(`SM_TSE_PKTCLI0_STAT_CHK_CNT),
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
        .address(`SM_TSE_PKT_CLIENT_0_RX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_0_RX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_0_TX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_0_TX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_0_TX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_0_TX_NUM_TICKS_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[63:32] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_0_RX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_0_RX_NUM_TICKS_U),
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
        .address(`SM_TSE_PKTCLI0_STAT_CHK_MISC),
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
        .address(`SM_TSE_PKT_CLIENT_1_RX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_1_RX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_1_TX_BYTE_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_1_TX_BYTE_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_byte_cnt[63:32] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_1_TX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_1_TX_NUM_TICKS_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    tx_num_ticks[63:32] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_1_RX_NUM_TICKS_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    rx_num_ticks[31:0] = data[0];

    axi_master_read(
        .address(`SM_TSE_PKT_CLIENT_1_RX_NUM_TICKS_U),
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
        .address(`SM_TSE_PKTCLI1_STAT_CHK_MISC),
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
`ifdef SM_TSE_PORT_LEVEL_LOOPBACK
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
        .address(`SM_TSE_PKTCLI0_STAT_TX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_tx_sop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI0_STAT_TX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_tx_sop_u = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI0_STAT_TX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_tx_eop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI0_STAT_TX_EOP_CNT_U),
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
        .address(`SM_TSE_PKTCLI0_STAT_RX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_rx_sop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI0_STAT_RX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_rx_sop_u = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI0_STAT_RX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p0_rx_eop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI0_STAT_RX_EOP_CNT_U),
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
        .address(`SM_TSE_PKTCLI1_STAT_TX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_tx_sop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI1_STAT_TX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_tx_sop_u = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI1_STAT_TX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_tx_eop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI1_STAT_TX_EOP_CNT_U),
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
        .address(`SM_TSE_PKTCLI1_STAT_RX_SOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_rx_sop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI1_STAT_RX_SOP_CNT_U),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_rx_sop_u = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI1_STAT_RX_EOP_CNT_L),
        .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
        .burst_length(1), .data(data)
    );
    p1_rx_eop_l = data[0];

    axi_master_read(
        .address(`SM_TSE_PKTCLI1_STAT_RX_EOP_CNT_U),
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
endclass: sm_tse_basic_seq

`endif // SM_TSE_BASIC_SEQ__SV
