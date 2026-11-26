//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

`ifndef SM_TSE_NULL_VIRTUAL_SEQ__SV
`define SM_TSE_NULL_VIRTUAL_SEQ__SV

class sm_tse_null_virtual_seq extends uvm_sequence;
  `uvm_object_utils(sm_tse_null_virtual_seq)
  
  function new(string name = "sm_tse_null_virtual_seq");
    super.new(name);
  endfunction: new

  virtual task body();
  endtask: body
endclass: sm_tse_null_virtual_seq

`endif // SM_TSE_NULL_VIRTUAL_SEQ__SV
