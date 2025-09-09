`ifndef SFP_SLAVE_ENV
`define SFP_SLAVE_ENV

//SFP slave ENV contains the SFP slave agent and the SFP registry component
//connecet QSFp block in connect phase 

class sfp_slave_env extends uvm_env;
 
  sfp_slave_agent sfp_agent_a0, sfp_agent_a2;
  sfp_registry_component sfp_a0, sfp_a2;

  virtual sfp_slave_interface vif;
  //imp  -> connect to agent. monport
  `uvm_component_utils(sfp_slave_env)
     
  // new - constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  // build_phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sfp_agent_a0 = sfp_slave_agent::type_id::create("sfp_agent_a0", this);
    sfp_agent_a2 = sfp_slave_agent::type_id::create("sfp_agent_a2", this);
    sfp_a0 = sfp_registry_component::type_id::create(.name("sfp_a0"), .parent(this));
    sfp_a2 = sfp_registry_component::type_id::create(.name("sfp_a2"), .parent(this));

    //uvm_config_db#(virtual sfp_slave_interface)::set(null, "sfp_tb_top.sfp_slave_env.agent*", "VIRTUAL_INTERFACE", intf0);
    // if (!uvm_config_db#(virtual sfp_slave_interface)::get(this, "", "vif", vif)) begin
    //    `uvm_fatal("build phase", "No virtual interface specified for this env instance")
    //  end
     // uvm_config_db#(virtual sfp_slave_interface)::set( this, "sfp_agent", "vif", vif);

 
  endfunction : build_phase
  
   //connect phase
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      //Connecting monitor analysis port with SFP Registry component 
      sfp_agent_a0.monitor.ap_seqitem_port.connect(sfp_a0.item_collected_export);
      sfp_agent_a2.monitor.ap_seqitem_port.connect(sfp_a2.item_collected_export);
      if(sfp_agent_a0.get_is_active() == UVM_ACTIVE) begin
          sfp_agent_a0.sequencer.sfp_registry = sfp_a0;
      end
      if(sfp_agent_a2.get_is_active() == UVM_ACTIVE) begin
          sfp_agent_a2.sequencer.sfp_registry = sfp_a2;
      end
   endfunction: connect_phase
  //run phase
endclass : sfp_slave_env

`endif // SFP_SLAVE_ENV
