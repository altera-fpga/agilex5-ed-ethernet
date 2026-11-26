//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_ETH_USER_CSR_SEQ__SV
`define SM_ETH_USER_CSR_SEQ__SV

class sm_eth_user_csr_seq extends sm_eth_basic_seq;
  `uvm_object_utils(sm_eth_user_csr_seq)

  // ----------------------------------------------------------------------
  function new (string name = "sm_eth_user_csr_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  virtual task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data [];

    super.body();
    
	 
    for (int addr=`SM_ETH_USER_CSR; addr<`SM_ETH_USER_CSR+16; addr=addr+4) begin
      axi_master_read(
                      .address(addr),
                      .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                      .burst_length(1),
                      .data(data)
      );
    end
	
  endtask: body
endclass: sm_eth_user_csr_seq

`endif // SM_ETH_USER_CSR_SEQ__SV
