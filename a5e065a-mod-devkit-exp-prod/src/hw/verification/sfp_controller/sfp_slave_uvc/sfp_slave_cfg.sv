`ifndef SFP_SLAVE_CFG
`define SFP_SLAVE_CFG
//File : SFP slave config file

class sfp_slave_cfg extends uvm_object;
  `uvm_object_utils(sfp_slave_cfg)
  
  //bit has_scoreboard=1;
  //bit has_sagent=1;
  
  //sfp_slave_config sfp_agent_cfg;
  
  
  function new(string name="sfp_env_config");
  super.new(name);
  endfunction

endclass : sfp_slave_cfg

`endif // SFP_SLAVE_CFG
