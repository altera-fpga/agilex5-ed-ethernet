//SFP slave auto response sequence
//
class sfp_slave_auto_response_sequence extends uvm_sequence#(sfp_slave_seq_item);
  
  `uvm_object_utils(sfp_slave_auto_response_sequence)
  `uvm_declare_p_sequencer(sfp_slave_sequencer)
 
  function new (string name = "sfp_slave_auto_response_sequence");
    super.new(name);
  endfunction
  
  task body();
    sfp_slave_seq_item m_req,m_item;
    int  _readdata;
    forever begin
    p_sequencer.h_req_fifo.get(m_req);
    _readdata = p_sequencer.sfp_registry.get_read_data(m_req.address,m_req.read);
    if (m_req.sfp_slv_pkt_type == SFP_SLV_RD_HDR)  begin
        `uvm_do_with(m_item,{ m_item.readdata == _readdata; })
    end
    end      //end of forever loop
   endtask
endclass : sfp_slave_auto_response_sequence


