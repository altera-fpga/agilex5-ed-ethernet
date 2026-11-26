//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

`ifndef SM_ETH_EHIP_PORT_TR__SV
`define SM_ETH_EHIP_PORT_TR__SV

class sm_eth_ehip_port_tr extends uvm_transaction;

  bit [63:0] data[$];
  realtime sop_time;
  realtime eop_time;

  `uvm_object_utils_begin(sm_eth_ehip_port_tr)
    `uvm_field_queue_int(data,     UVM_ALL_ON)
    `uvm_field_real(     sop_time, UVM_ALL_ON)
    `uvm_field_real(     eop_time, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="sm_eth_ehip_port_tr");
    super.new(name);
  endfunction: new
endclass

`endif
