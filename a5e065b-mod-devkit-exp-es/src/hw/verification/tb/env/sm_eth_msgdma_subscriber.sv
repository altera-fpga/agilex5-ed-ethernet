//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################
//# FETH Scoreboard
//# On TX Side, Input packets are collected in queu and on RX Side Output packets
//# are collected in queue and data comparion is done. If data mismatches happens
//# error is reported.   
//#########################################################################

`ifndef SM_ETH_MSGDMA_SUBSCRIBER__SV
`define SM_ETH_MSGDMA_SUBSCRIBER__SV

`uvm_analysis_imp_decl(_axi_port)
`uvm_analysis_imp_decl(_p0_ingress)
`uvm_analysis_imp_decl(_p0_egress)

class sm_eth_msgdma_subscriber extends uvm_scoreboard;

  svt_axi_transaction axi_trans;
  
  bit [`SM_MSGDMA_DESCR_LENGTH-1:0] h2d_descr [`SM_MSGDMA_NUM_OF_PORTS][*];
  bit [`SM_MSGDMA_DESCR_LENGTH-1:0] d2h_descr [`SM_MSGDMA_NUM_OF_PORTS][*];
  bit [`SM_MSGDMA_DESCR_LENGTH-1:0] h2d_wrbk_descr [`SM_MSGDMA_NUM_OF_PORTS][*];
  bit [`SM_MSGDMA_DESCR_LENGTH-1:0] d2h_wrbk_descr [`SM_MSGDMA_NUM_OF_PORTS][*];

  bit [7:0] h2d_payload [`SM_MSGDMA_NUM_OF_PORTS][*];
  bit [7:0] d2h_payload [`SM_MSGDMA_NUM_OF_PORTS][*];

  bit [63:0] h2d_pyld_addr[`SM_MSGDMA_NUM_OF_PORTS][$];
  bit [63:0] d2h_pyld_addr[`SM_MSGDMA_NUM_OF_PORTS][$];
  bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] h2d_desc_addr[`SM_MSGDMA_NUM_OF_PORTS][$];
  bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] d2h_desc_addr[`SM_MSGDMA_NUM_OF_PORTS][$];

  int h2d_descr_pntr [`SM_MSGDMA_NUM_OF_PORTS];
  int d2h_descr_pntr [`SM_MSGDMA_NUM_OF_PORTS];

  int agent_type;
  int data_type;
  int port_num;

  int polling_requests;
  int pending_h2d_bytes;
  int pending_d2h_bytes;
  int skip_h2d_bytes;
  int curr_h2d_desc;
  int curr_d2h_desc;
  
  realtime h2d_desc_fetch_start_time[`SM_MSGDMA_NUM_OF_PORTS]; 
  realtime d2h_desc_fetch_start_time[`SM_MSGDMA_NUM_OF_PORTS]; 
  realtime h2d_last_resp_desc_time[`SM_MSGDMA_NUM_OF_PORTS];
  realtime d2h_last_resp_desc_time[`SM_MSGDMA_NUM_OF_PORTS];

  sm_eth_ehip_port_tr p0_n_tr;
  sm_eth_ehip_port_tr p0_e_tr;

  `uvm_component_utils(sm_eth_msgdma_subscriber)

  uvm_analysis_imp_axi_port   #(svt_axi_transaction, sm_eth_msgdma_subscriber) axi_port;
  uvm_analysis_imp_p0_ingress #(sm_eth_ehip_port_tr, sm_eth_msgdma_subscriber) item_p0_n;
  uvm_analysis_imp_p0_egress  #(sm_eth_ehip_port_tr, sm_eth_msgdma_subscriber) item_p0_e;

  //---------------------------------------------------------------------------
  // new - constructor
  //---------------------------------------------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi_port  = new("axi_port", this);
    item_p0_n = new("item_p0_n", this);
    item_p0_e = new("item_p0_e", this);
    p0_n_tr = new();
    p0_e_tr = new();
  endfunction: build_phase
   
  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void write_p0_ingress(sm_eth_ehip_port_tr tr);
    // p0_n_tr.push_back(tr);
    p0_n_tr = new();
    p0_n_tr.copy(tr);
    `uvm_info(get_full_name(),
              $sformatf("p0 ingress: timestamp for pkt sop %0t, eop %0t",
                        tr.sop_time, tr.eop_time),
              UVM_LOW)
  endfunction: write_p0_ingress

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void write_p0_egress(sm_eth_ehip_port_tr tr);
    // p0_e_tr.push_back(tr);
    p0_e_tr = new();
    p0_e_tr.copy(tr);
    `uvm_info(get_full_name(),
              $sformatf("p0 egress: timestamp for pkt sop %0t, eop %0t",
                        tr.sop_time, tr.eop_time),
              UVM_LOW)
  endfunction: write_p0_egress

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void write_axi_port(svt_axi_transaction trans);
    $cast(axi_trans , trans.clone());

    agent_type = axi_trans.addr[27:26];
    data_type = axi_trans.addr[30:28];
    port_num = axi_trans.addr[25:22];

    `uvm_info(get_type_name(),
              $sformatf(" SCB:: Pkt received \n%s",axi_trans.sprint()),
              UVM_LOW)

    if (axi_trans.xact_type == svt_axi_transaction::READ) begin
      if (data_type == `DESCR) begin
        if (axi_trans.burst_length == 2)
          load_descriptor_data(axi_trans);
        else if (axi_trans.burst_length == 1)
          polling_requests = polling_requests+1;
      end else if (data_type == `DMA_DATA) begin
        load_h2d_dma_data(axi_trans);
      end
    end if (axi_trans.xact_type == svt_axi_transaction::WRITE) begin
      if (data_type == `DESCR) begin
        load_wrbk_descriptor_data(axi_trans);
      end else if (data_type == `DMA_DATA) begin
        load_d2h_dma_data(axi_trans);
      end
    end
  endfunction :write_axi_port

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  function void load_descriptor_data(svt_axi_transaction tr);
    int length;
    bit [`SM_MSGDMA_DESCR_LENGTH-1:0] data;

    if (agent_type == `H2D_ST_AGENT) begin
       for (int i=0; i<tr.burst_length; i++) begin
         h2d_descr[port_num][tr.addr][i*`SVT_AXI_MAX_DATA_WIDTH+:`SVT_AXI_MAX_DATA_WIDTH] = tr.data[i];
         `uvm_info(get_full_name(),
                   $sformatf("h2d_descr[%0d][%0h] = %0h",
                              port_num, tr.addr, h2d_descr[port_num][tr.addr]),
                   UVM_LOW)
       end
       if (tr.burst_length == 2) begin
         h2d_pyld_addr[port_num].push_back({h2d_descr[port_num][tr.addr][319:288], h2d_descr[port_num][tr.addr][31:0]});
         h2d_desc_addr[port_num].push_back(tr.addr);
       end
       if (h2d_descr[port_num].num() == 1) begin
          h2d_desc_fetch_start_time[port_num] = ($realtime/1ns);
          `uvm_info(get_full_name(),
                    $sformatf("Received first DESCR Read rquest on H2D @ %0t ns", ($realtime/1ns)), UVM_NONE)
       end
    end else if (agent_type == `D2H_ST_AGENT) begin
       for (int i=0; i<tr.burst_length; i++) begin
         d2h_descr[port_num][tr.addr][i*`SVT_AXI_MAX_DATA_WIDTH+:`SVT_AXI_MAX_DATA_WIDTH] = tr.data[i];
         `uvm_info(get_full_name(),
                   $sformatf("d2h_descr[%0d][%0h] = %0h",
                              port_num, tr.addr, d2h_descr[port_num][tr.addr]),
                   UVM_LOW)
       end
       if (tr.burst_length == 2) begin
         d2h_pyld_addr[port_num].push_back({d2h_descr[port_num][tr.addr][319:288], d2h_descr[port_num][tr.addr][31:0]});
         d2h_desc_addr[port_num].push_back(tr.addr);
       end
       if (d2h_descr[port_num].num() == 1) begin
          d2h_desc_fetch_start_time[port_num] = ($realtime/1ns);
          `uvm_info(get_full_name(),
                    $sformatf("Received first DESCR Read rquest on D2H @ %0t ns", ($realtime/1ns)), UVM_NONE)
       end
    end
  endfunction

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  function void load_h2d_dma_data(svt_axi_transaction tr);
    int burst_size_bytes;
    bit [63:0] pyld_addr;
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] desc_addr;

    burst_size_bytes = 2**tr.burst_size;
    `uvm_info(get_full_name(),
              $sformatf("pending_h2d_bytes %0d", pending_h2d_bytes),
              UVM_DEBUG)
    if (pending_h2d_bytes == 0) begin
      pyld_addr = h2d_pyld_addr[port_num].pop_front();
      desc_addr = h2d_desc_addr[port_num].pop_front();
      if (pyld_addr !== tr.addr) begin
        skip_h2d_bytes = pyld_addr - tr.addr;
        `uvm_info(get_full_name(),
                  $sformatf("assuming unaligned payload addr, skipping %0d bytes", skip_h2d_bytes),
                  UVM_DEBUG)
      end
      if (h2d_descr[port_num].exists(desc_addr) == 1) begin
        `uvm_info(get_full_name(),
                  $sformatf("pyld_addr %0h, desc_addr %0h, h2d_descr[%0d][%0h][31:0]=%0h",
                            pyld_addr, desc_addr, port_num, desc_addr,
                            h2d_descr[port_num][desc_addr][31:0]),
                  UVM_DEBUG)
        if ((h2d_descr[port_num][desc_addr][31:0] == pyld_addr)
            && (pyld_addr == (tr.addr+skip_h2d_bytes))) begin
          pending_h2d_bytes = h2d_descr[port_num][desc_addr][95:64];
          `uvm_info(get_full_name(),
                    $sformatf("pending_h2d_bytes %0d renewed @ addr %0h",
                              pending_h2d_bytes, tr.addr),
                    UVM_DEBUG)
        end else
          `uvm_warning(get_full_name(),
                       $sformatf("pending_h2d_bytes not renewed @ addr %0h", tr.addr))
      end else begin
        `uvm_warning(get_full_name(),
                     $sformatf("h2d_descr[%0d][%0h] doesn't exist", port_num, tr.addr))
      end
    end

    for (int l=0; l<tr.burst_length; l++) begin
      for (int b=0; b<burst_size_bytes; b++) begin
        if ((pending_h2d_bytes !== 0) && (skip_h2d_bytes == 0)) begin
          h2d_payload[port_num][tr.addr+(burst_size_bytes*l)+b] = tr.data[l][8*b+:8];
          `uvm_info(get_full_name(),
                    $sformatf("h2d_payload[%0d][%0h] = %0h",
                               port_num, tr.addr+(burst_size_bytes*l)+b,
                               h2d_payload[port_num][tr.addr+(burst_size_bytes*l)+b]),
                    UVM_DEBUG)
          pending_h2d_bytes = pending_h2d_bytes-1;
        end else if (skip_h2d_bytes !== 0) begin
          `uvm_info(get_full_name(),
                    $sformatf("skipping byte tr.data[%0d][%0d:%0d]", l, (8*b)+7, 8*b),
                    UVM_DEBUG)
          skip_h2d_bytes = skip_h2d_bytes-1;
        end
      end
    end
  endfunction: load_h2d_dma_data

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  function void load_d2h_dma_data(svt_axi_transaction tr);
    int burst_size_bytes;

    burst_size_bytes = 2**tr.burst_size;

    for (int l=0; l<tr.burst_length; l++) begin
      `uvm_info(get_full_name(),
                $sformatf("tr.data[%0d] = %0h, wstrb[%0d]=%0h",
                           l, tr.data[l], l, tr.wstrb[l]),
                UVM_DEBUG)
      for (int b=0; b<burst_size_bytes; b++) begin
        if (tr.wstrb[l][b] == 1) begin
          d2h_payload[port_num][tr.addr+(burst_size_bytes*l)+b] = tr.data[l][8*b+:8];
          `uvm_info(get_full_name(),
                    $sformatf("d2h_payload[%0d][%0h] = %0h",
                               port_num, tr.addr+(burst_size_bytes*l)+b,
                               d2h_payload[port_num][tr.addr+(burst_size_bytes*l)+b]),
                    UVM_DEBUG)
        end
      end
    end
  endfunction: load_d2h_dma_data

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  function void load_wrbk_descriptor_data(svt_axi_transaction tr);
    int length;
    bit [`SM_MSGDMA_DESCR_LENGTH-1:0] data;

    if (agent_type == `H2D_ST_AGENT) begin
       for (int i=0; i<tr.burst_length; i++) begin
         h2d_wrbk_descr[port_num][tr.addr][i*`SVT_AXI_MAX_DATA_WIDTH+:`SVT_AXI_MAX_DATA_WIDTH] = tr.data[i];
         `uvm_info(get_full_name(),
                   $sformatf("h2d_wrbk_descr[%0d][%0h] = %0h",
                              port_num, tr.addr, h2d_wrbk_descr[port_num][tr.addr]),
                   UVM_DEBUG)
       end
       h2d_last_resp_desc_time[port_num] = ($realtime/1ns);
    end else if (agent_type == `D2H_ST_AGENT) begin
       for (int i=0; i<tr.burst_length; i++) begin
         d2h_wrbk_descr[port_num][tr.addr][i*`SVT_AXI_MAX_DATA_WIDTH+:`SVT_AXI_MAX_DATA_WIDTH] = tr.data[i];
         `uvm_info(get_full_name(),
                   $sformatf("d2h_wrbk_descr[%0d][%0h] = %0h",
                              port_num, tr.addr, d2h_wrbk_descr[port_num][tr.addr]),
                   UVM_DEBUG)
       end
       d2h_last_resp_desc_time[port_num] = ($realtime/1ns);
    end
  endfunction

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    int h2d_buff_addr[$];
    int d2h_buff_addr[$];
    int h2d_addr, d2h_addr;
    real h2h_perf_data;
    real h2p0n_perf_data;
    real p0e2h_perf_data;

    super.final_phase(phase);

    foreach (h2d_payload[i]) begin
      if (h2d_payload[i].num() !== d2h_payload[i].num())
        `uvm_error(get_full_name(),
                   $sformatf("No of bytes recvd %0d is not same as transferred %0d",
                             d2h_payload[i].num(), h2d_payload[i].num()))
      else
        `uvm_info(get_full_name(),
                  $sformatf("No of bytes recvd %0d same as transferred %0d",
                            d2h_payload[i].num(), h2d_payload[i].num()), UVM_NONE)
    end

    foreach (h2d_payload[i])
      foreach (h2d_payload[i][j])
        h2d_buff_addr.push_back(j);

    foreach (d2h_payload[i])
      foreach (d2h_payload[i][j])
        d2h_buff_addr.push_back(j);

    foreach (d2h_payload[i]) begin
      repeat (d2h_payload[i].num()) begin
        h2d_addr = h2d_buff_addr.pop_front();
        d2h_addr = d2h_buff_addr.pop_front();

        if (d2h_payload[i][d2h_addr] !== h2d_payload[i][h2d_addr])
          `uvm_error(get_full_name(),
                     $sformatf("Payload received @ %0h = %0h, not same as tx @ %0h = %0h",
                               d2h_addr, d2h_payload[i][d2h_addr], h2d_addr,
                               h2d_payload[i][h2d_addr]))
        else
          `uvm_info(get_full_name(),
                     $sformatf("Payload received @ %0h = %0h, same as tx @ %0h = %0h",
                               d2h_addr, d2h_payload[i][d2h_addr], h2d_addr,
                               h2d_payload[i][h2d_addr]), UVM_DEBUG)
      end
    end

    // calculate performance data
    h2h_perf_data = (h2d_payload[0].num()*8) / (d2h_last_resp_desc_time[0]-h2d_desc_fetch_start_time[0]);
    h2p0n_perf_data = (h2d_payload[0].num()*8) / (p0_n_tr.eop_time-h2d_desc_fetch_start_time[0]);
    p0e2h_perf_data = (d2h_payload[0].num()*8) / (d2h_last_resp_desc_time[0]-p0_e_tr.sop_time);

    `uvm_info(get_full_name(),
              $sformatf({"PERFORMACE DATA:\n",
                         "host to host performance       = %.4f Gb/s\n",
                         "Host to P0 ingress performance = %.4f Gb/s\n",
                         "P0 egress to Host performance  = %.4f Gb/s"},
                         h2h_perf_data, h2p0n_perf_data, p0e2h_perf_data),
              UVM_NONE)

    for (int i=0; i<`SM_MSGDMA_NUM_OF_PORTS; i++) begin
      `uvm_info(get_full_name(),
                $sformatf({"\nh2d_desc_fetch_start_time[%0d] %t ns",
                           "\nd2h_desc_fetch_start_time[%0d] %t ns",
                           "\nh2d_last_resp_desc_time[%0d] %t ns",
                           "\nd2h_last_resp_desc_time[%0d] %t ns"},
                           i, h2d_desc_fetch_start_time[i],
                           i, d2h_desc_fetch_start_time[i],
                           i, h2d_last_resp_desc_time[i],
                           i, d2h_last_resp_desc_time[i]),
                UVM_NONE)
    end
    `uvm_info(get_full_name(),
              $sformatf({"\np0_n_tr.eop for last pkt %t ns",
                         "\np0_e_tr.sop for first pkt %t ns"},
                         p0_n_tr.eop_time, p0_e_tr.sop_time),
              UVM_NONE)

    `uvm_info(get_full_name(), $sformatf("number of descr polling requests %0d", polling_requests), UVM_NONE)
  endfunction

  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
  endfunction: final_phase

endclass : sm_eth_msgdma_subscriber

`endif
