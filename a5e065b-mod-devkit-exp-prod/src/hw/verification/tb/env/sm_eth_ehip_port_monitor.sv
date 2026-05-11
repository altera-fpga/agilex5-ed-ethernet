//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

`ifndef SM_ETH_EHIP_PORT_MONITOR__SV
`define SM_ETH_EHIP_PORT_MONITOR__SV

class sm_eth_ehip_port_monitor extends uvm_monitor;

  sm_eth_ehip_port_tr p0_n_pkt;
  sm_eth_ehip_port_tr p0_e_pkt;
  virtual sm_eth_ehip_port_if vif;

  uvm_analysis_port #(sm_eth_ehip_port_tr) port_p0_n;
  uvm_analysis_port #(sm_eth_ehip_port_tr) port_p0_e;

  bit p0_n_first_sop;
  bit p0_e_first_sop;

  `uvm_component_utils(sm_eth_ehip_port_monitor)

  //---------------------------------------------------------------------------
  function new(string name="sm_eth_ehip_port_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  //---------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port_p0_n = new("port_p0_n", this);
    port_p0_e = new("port_p0_e", this);
    if(!uvm_config_db#(virtual sm_eth_ehip_port_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  //---------------------------------------------------------------------------
  task run();
    p0_n_first_sop = 0;
    p0_e_first_sop = 0;

    fork
      collect_p0_ingress();
      collect_p0_egress();
    join
  endtask: run

  //---------------------------------------------------------------------------
  task collect_p0_ingress();
    p0_n_pkt = new();
    forever begin
      `uvm_info(get_full_name(), "p0 ingress: wait for SOP", UVM_LOW)
      wait (vif.p0_ingress_sop);
      `uvm_info(get_full_name(), "p0 ingress: wait for SOP to be valid", UVM_LOW)
      wait ((vif.p0_ingress_valid == 1) && (vif.p0_ingress_ready == 1));
      if (p0_n_first_sop == 0) begin
        p0_n_pkt.sop_time = ($realtime/1ns);
        p0_n_first_sop = 1;
        `uvm_info(get_full_name(),
                  $sformatf("p0 ingress: p0_n_pkt.sop_time %0t", p0_n_pkt.sop_time),
                  UVM_LOW)
        if (vif.p0_ingress_eop === 1) begin
          `uvm_info(get_full_name(), "p0 ingress: EOP detected w/ SOP", UVM_LOW)
          p0_n_pkt.eop_time = ($realtime/1ns);
        end
        p0_n_pkt.data.push_back(vif.p0_ingress_data);
        `uvm_info(get_full_name(), "p0 ingress: data collected", UVM_LOW)
      end
      while (vif.p0_ingress_eop !== 1) begin
        @ (posedge vif.p0_ingress_clk);
        `uvm_info(get_full_name(), "p0 ingress: wait for valid ready", UVM_LOW)
        wait ((vif.p0_ingress_valid == 1) && (vif.p0_ingress_ready == 1));
        if (vif.p0_ingress_eop === 1) begin
          `uvm_info(get_full_name(), "p0 ingress: EOP detected", UVM_LOW)
          p0_n_pkt.eop_time = ($realtime/1ns);
        end
        p0_n_pkt.data.push_back(vif.p0_ingress_data);
        `uvm_info(get_full_name(), "p0 ingress: data collected", UVM_LOW)
      end
      `uvm_info(get_full_name(), "p0 ingress: write to TLM", UVM_LOW)
      port_p0_n.write(p0_n_pkt);
    end
  endtask: collect_p0_ingress

  //---------------------------------------------------------------------------
  task collect_p0_egress();
    p0_e_pkt = new();
    forever begin
      `uvm_info(get_full_name(), "p0 egress: wait for SOP at", UVM_LOW)
      wait (vif.p0_egress_sop);
      if (p0_e_first_sop == 0) begin
        p0_e_pkt.sop_time = ($realtime/1ns);
        p0_e_first_sop = 1;
        `uvm_info(get_full_name(),
                  $sformatf("p0 egress: p0_e_pkt.sop_time %0t", p0_e_pkt.sop_time),
                  UVM_LOW)
        if (vif.p0_egress_eop === 1) begin
          `uvm_info(get_full_name(), "p0 egress: EOP detected w/ SOP", UVM_LOW)
          p0_e_pkt.eop_time = ($realtime/1ns);
        end
        p0_e_pkt.data.push_back(vif.p0_egress_data);
        `uvm_info(get_full_name(), "p0 egress: data collected", UVM_LOW)
      end
      while (vif.p0_egress_eop !== 1) begin
        @ (posedge vif.p0_egress_clk);
        `uvm_info(get_full_name(), "p0 egress: wait for valid", UVM_LOW)
        wait (vif.p0_egress_valid == 1);
        if (vif.p0_egress_eop === 1) begin
          `uvm_info(get_full_name(), "p0 egress: EOP detected", UVM_LOW)
          p0_e_pkt.eop_time = ($realtime/1ns);
        end
        p0_e_pkt.data.push_back(vif.p0_egress_data);
        `uvm_info(get_full_name(), "p0 egress: data collected", UVM_LOW)
      end
      `uvm_info(get_full_name(), "p0 egress: write to TLM", UVM_LOW)
      port_p0_e.write(p0_e_pkt);
    end
  endtask: collect_p0_egress
endclass: sm_eth_ehip_port_monitor

`endif
