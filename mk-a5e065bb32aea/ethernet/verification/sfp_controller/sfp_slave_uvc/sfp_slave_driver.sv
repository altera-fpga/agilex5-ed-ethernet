`ifndef SFP_SLAVE_DRIVER
`define SFP_SLAVE_DRIVER
//Class: sfp_slave_driver
//

class sfp_slave_driver extends uvm_driver #(sfp_slave_seq_item);
 
  // Virtual Interface
  virtual sfp_slave_interface vif;
 
  `uvm_component_utils(sfp_slave_driver)
     
  //uvm_analysis_port #(sfp_slave_seq_item) Drvr2Sb_port;
 
  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual sfp_slave_interface)::get(this, "", "vif", vif))
     `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase
 
  // run phase
  virtual task run_phase(uvm_phase phase);
    sfp_slave_seq_item req;
    super.run_phase(phase);
    $display("-----Inside driver run phase ------");
    this.vif.waitrequest <= 0;  
    forever begin
    seq_item_port.get_next_item(req);
    //respond_to_transfer(req);
    drive_response(req);
    seq_item_port.item_done();
    end
  endtask : run_phase

  virtual task drive_response(sfp_slave_seq_item req);
     this.vif.waitrequest <= 0;  
     @(posedge this.vif.clk)
     this.vif.readdatavalid <=1 ; 
     this.vif.readdata <= req.readdata;
     @(posedge this.vif.clk)
     this.vif.readdatavalid <=0 ; 
  endtask : drive_response
 
endclass : sfp_slave_driver

`endif // SFP_SLAVE_DRIVER
