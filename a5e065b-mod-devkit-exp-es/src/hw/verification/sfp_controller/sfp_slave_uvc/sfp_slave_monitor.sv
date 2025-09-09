`ifndef SFP_SLAVE_MONITOR
`define SFP_SLAVE_MONITOR
//Class: sfp_slave_monitor
//       The slave monitor will receive the incoming transaction and send it to
//       the SFP registry component outside the agent
//


class sfp_slave_monitor extends uvm_monitor;
  `uvm_component_utils (sfp_slave_monitor);
 
  // Virtual Interface
  virtual sfp_slave_interface vif;

  uvm_analysis_port #(sfp_slave_seq_item) ap_seqitem_port;

  function new (string name, uvm_component parent = null);
      super.new(name, parent);
  endfunction: new
  
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ap_seqitem_port = new("ap_seqitem_port", this);
      if(!uvm_config_db#(virtual sfp_slave_interface)::get(this, "", "vif", vif))
         `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
      sfp_slave_seq_item _req_item, _read_item;
      super.run_phase(phase);
     
      forever begin
       @( posedge this.vif.clk);
        if((this.vif.write == 1) || (this.vif.read == 1) ) begin
        _req_item = sfp_slave_seq_item::type_id::create ("_req_item",this);
        _req_item = create_req_item();
        //Send data object through the analysis port
        ap_seqitem_port.write(_req_item);
        @( this.vif.clk);
        wait(this.vif.waitrequest == 1'b0);
        if (this.vif.read == 1) begin  //Read operation
           $cast(_read_item, _req_item.clone());
             //read_from_mem_array();
           _read_item.sfp_slv_pkt_type = SFP_SLV_READ;
           _read_item.readdata = this.vif.readdata; 
           ap_seqitem_port.write(_read_item);//Complete Read packet  
        end
        end     
       end         //End of forever loop
  endtask :run_phase


  virtual function sfp_slave_seq_item create_req_item();
       sfp_slave_seq_item req_item = sfp_slave_seq_item::type_id::create ("req_item",this);
       req_item.sfp_slv_pkt_type  = this.vif.write? SFP_SLV_WRITE : SFP_SLV_RD_HDR;
       req_item.writedata = this.vif.writedata;
       req_item.byteenable = this.vif.byteenable;
       req_item.address = this.vif.address;
       req_item.read   = this.vif.read;
       req_item.write   = this.vif.write;
       return(req_item);
  endfunction 



endclass:sfp_slave_monitor
`endif // SFP_SLAVE_MONITOR
