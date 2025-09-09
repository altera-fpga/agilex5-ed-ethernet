`ifndef SFP_SLAVE_SEQ_ITEM
`define SFP_SLAVE_SEQ_ITEM
//Class : SFP slave sequence item

class sfp_slave_seq_item extends uvm_sequence_item;
  
  // variable: address
  rand logic [31:0]     address;
  
  // variable: data
  rand logic [31:0]    writedata;
  
  // variable: data
  rand logic [31:0]    readdata;

  rand logic write;

  rand logic read;

  rand sfp_slv_pkt_t   sfp_slv_pkt_type; //SFP_SLV_WRITE, SFP_SLV_READ, SFP_SLV_RD_HDR

  //Wait request
  rand logic waitrequest ;
  //Byte Enable
  rand logic [3:0] byteenable ;

 
  `uvm_object_utils_begin (sfp_slave_seq_item)
    `uvm_field_int( address,    UVM_ALL_ON) 
    `uvm_field_int( writedata,  UVM_ALL_ON)
    `uvm_field_int( readdata,   UVM_ALL_ON)
    `uvm_field_enum (sfp_slv_pkt_t, sfp_slv_pkt_type, UVM_ALL_ON)
    `uvm_field_int( read,       UVM_ALL_ON)
    `uvm_field_int( write,      UVM_ALL_ON)
    `uvm_field_int( waitrequest,UVM_ALL_ON)
    `uvm_field_int( byteenable, UVM_ALL_ON)
  `uvm_object_utils_end

  //Constructor
  function  new(string name = "sfp_slave_seq_item");
   super.new(name);
  endfunction: new

endclass: sfp_slave_seq_item

`endif // SFP_SLAVE_SEQ_ITEM
