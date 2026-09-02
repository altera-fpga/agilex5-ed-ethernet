//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_ETH_USER0_SEQ__SV
`define SM_ETH_USER0_SEQ__SV

class sm_eth_user0_seq extends sm_eth_basic_seq;
    
  `uvm_object_utils(sm_eth_user0_seq)

  function new (string name = "sm_eth_user0_seq");
   super.new(name);
  endfunction : new

    
  task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] key [3];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] sa [2];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] da [2];
    super.body();

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    key[0] = 'heeee_eeee;
    key[1] = 'hbbbb_eeee;
    key[2] = 'hbbbb_bbbb;
    configure_tcam0(1, key, 8);

    da[0] = 'hEEEE_EEEE;
    da[1] = 'hEEEE;
    sa[0] = 'hBBBB_BBBB;
    sa[1] = 'hBBBB;
    configure_pkt_client0(sa, da, 100);

    wait_for_pkts_to_complete(0, 100);
    read_pkt_client0_perf_stats();
    match_sop_eop(0);
    poll_eth_stats();
    `uvm_info(get_full_name(), "Body: CFG PKT CLIENT0 ENDS...", UVM_DEBUG)
  endtask: body
endclass:sm_eth_user0_seq 

`endif
