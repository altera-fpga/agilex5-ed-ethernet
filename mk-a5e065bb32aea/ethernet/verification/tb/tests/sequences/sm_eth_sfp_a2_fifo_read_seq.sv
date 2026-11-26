//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

`ifndef SM_ETH_SFP_A2_FIFO_READ_SEQ__SV
  `define SM_ETH_SFP_A2_FIFO_READ_SEQ__SV

class sm_eth_sfp_a2_fifo_read_seq extends sm_eth_sfp_basic_seq;
  rand bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] addr;
  `uvm_object_utils(sm_eth_sfp_a2_fifo_read_seq)

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "sm_eth_sfp_a2_fifo_read_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] wr_data [];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] rd_data [];

    init_sfp();
    #40us;

    wr_data = new[1];
    
    repeat(10) begin
      int addr;
		
      std::randomize(addr) with {addr inside {[0:127]};};

      read_a2(addr);
      #40us;

      axi_master_read(.address(`SM_ETH_SFP_SYSTEM_OFFSET + 'h44),
                      .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                      .data(rd_data), .burst_length(1));
      foreach (rd_data[r])
        `uvm_info(get_full_name(),
                  $sformatf("data read from A2 FIFO register is rdata[%0d] %0h", r, rd_data[r]),
                  UVM_LOW)
    end
    #10us;

  endtask: body
endclass: sm_eth_sfp_a2_fifo_read_seq

`endif
