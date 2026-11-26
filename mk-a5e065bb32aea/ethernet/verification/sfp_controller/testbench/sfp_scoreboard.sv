//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

//Class : SFP scoreboard
//
//Macro declaration for multiple ports
`uvm_analysis_imp_decl( _sfp_slave )
`uvm_analysis_imp_decl( _axi4_master )

class sfp_scoreboard extends uvm_scoreboard;
 
  `uvm_component_utils(sfp_scoreboard)
  //Port from SFP slave ENV monitor
  uvm_analysis_imp_sfp_slave#(sfp_slave_seq_item, sfp_scoreboard) sfp_item_collected_export_a0;
  uvm_analysis_imp_sfp_slave#(sfp_slave_seq_item, sfp_scoreboard) sfp_item_collected_export_a2;
  //Port from AXI4 ENV monitor
  uvm_analysis_imp_axi4_master#(svt_axi_transaction, sfp_scoreboard) axi4_item_collected_export;
  
  sfp_registry_component sfp_sb_mem_a0;
  sfp_registry_component sfp_sb_mem_a2;

  //TLM FIFO for AXI and SFP 
  uvm_tlm_analysis_fifo #(sfp_slave_seq_item) sfp_fifo;
  uvm_tlm_analysis_fifo #(svt_axi_transaction) axi_fifo;

  //SFP_Registry element for storing READ data from I2C 
  logic [31:0] shadow_register_comp_a0[int];
  logic [31:0] shadow_register_comp_a2[int];
  logic [31:0] address;

  bit [3:0] axi_wr_cnt;
  logic [31:0] axi_wr_data, axi_wdata, sfp_wdata;
  logic [63:0] axi_rdata, sfp_rdata;
  logic [7:0]  axi_wr_data_byte0, axi_wr_data_byte1, axi_wr_data_byte2, axi_wr_data_byte3;
  logic [17:0] axi_wr_addr, axi_rd_addr;

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
    sfp_item_collected_export_a0 = new("sfp_item_collected_export_a0", this);
    sfp_item_collected_export_a2 = new("sfp_item_collected_export_a2", this);
    axi4_item_collected_export = new("axi4_item_collected_export", this);
    sfp_fifo = new("sfp_fifo",this);
    axi_fifo = new("axi_fifo",this);
  endfunction: build_phase
   
  //---------------------------------------------------------------------------
  // Write function for SFP slave packet
  //---------------------------------------------------------------------------
  virtual function void write_sfp_slave(sfp_slave_seq_item pkt);
    sfp_slave_seq_item sfp_pkt;
    $cast(sfp_pkt , pkt.clone());
    `uvm_info(get_type_name(),$sformatf(" SCB:: Pkt received from SFP slave ENV \n %s",sfp_pkt.sprint()),UVM_LOW)

    if (sfp_pkt.sfp_slv_pkt_type == SFP_SLV_WRITE )begin   //SFP write 
      sfp_fifo.write(sfp_pkt);
    end 
    else if (sfp_pkt.sfp_slv_pkt_type == SFP_SLV_RD_HDR )begin  //SFP rea
      if(sfp_sb_mem_a0.set_data_for_sb==1)begin
        shadow_register_comp_a0[sfp_pkt.address] = sfp_sb_mem_a0.data_to_sb; 
	sfp_sb_mem_a0.set_data_for_sb=0;
	`uvm_info(get_full_name(),
                  $sformatf("Value inside the sb for A0 Addr: %0h Data: 0%h",
                            sfp_pkt.address,shadow_register_comp_a0[sfp_pkt.address]),
                  UVM_LOW)
      end
      if(sfp_sb_mem_a2.set_data_for_sb==1)begin
        shadow_register_comp_a2[sfp_pkt.address] = sfp_sb_mem_a2.data_to_sb; 
	sfp_sb_mem_a2.set_data_for_sb=0;
        `uvm_info(get_full_name(),
                  $sformatf("Value inside the sb for A2 Addr: %0h Data: 0%h",
                            sfp_pkt.address,shadow_register_comp_a2[sfp_pkt.address]),
                  UVM_LOW)
      end
    end 
  endfunction : write_sfp_slave

  //---------------------------------------------------------------------------
  // Write function for AXI 4 master packet
  //---------------------------------------------------------------------------
  virtual function void write_axi4_master(svt_axi_transaction trans);
    svt_axi_transaction axi_pkt;
    $cast(axi_pkt , trans.clone());
    `uvm_info(get_type_name(),
	      $sformatf(" SCB:: Pkt received from AXI4 Lite Master ENV \n %s",axi_pkt.sprint()),
	      UVM_LOW)
    
    if(axi_pkt.xact_type == (svt_axi_transaction::WRITE))begin
      if((axi_pkt.addr == 32'h40))begin
        axi_fifo.write(axi_pkt); 
      end
    end
    
    if(axi_pkt.xact_type == (svt_axi_transaction::READ))begin
      if(((axi_pkt.addr >= 64'h44040800) && (axi_pkt.addr < 64'h44040880)) || ((axi_pkt.addr >= 64'h44040100) && (axi_pkt.addr < 64'h44040700)) || (axi_pkt.addr == 64'h44040044))begin
        axi_fifo.write(axi_pkt);
      end
    end 	    
  endfunction : write_axi4_master

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  task run_phase(uvm_phase phase) ;
    sfp_slave_seq_item sfp_cmp_pkt;
    svt_axi_transaction axi_cmp_pkt;
    super.run_phase(phase);
    forever begin
      axi_fifo.get(axi_cmp_pkt);
      `uvm_info(get_type_name(),
                $sformatf(" SCB:: Pkt received from AXI4 Analysis FIFO \n %s",axi_cmp_pkt.sprint()),
                UVM_LOW)

      if(axi_cmp_pkt.xact_type == (svt_axi_transaction::READ)) begin
        if((axi_cmp_pkt.addr >= 64'h44040800) && (axi_cmp_pkt.addr < 64'h44040880))begin
          `uvm_info(get_full_name(), 
		    $sformatf("Inisde the A0 %0h Addr:%0h",axi_cmp_pkt.data[0],axi_cmp_pkt.addr), 
		    UVM_LOW);
          check_full_match_a0(axi_cmp_pkt.data[0]);
        end

        if((axi_cmp_pkt.addr >= 64'h44040100) && (axi_cmp_pkt.addr < 64'h44040700))begin
          `uvm_info(get_full_name(), 
		    $sformatf("Inisde the A2 %0h Addr:%0h",axi_cmp_pkt.data[0],axi_cmp_pkt.addr), 
		    UVM_LOW);
          check_full_match_a2(axi_cmp_pkt.data[0]);
        end

        if(axi_cmp_pkt.addr == 64'h44040044)begin
          `uvm_info(get_full_name(), 
		    $sformatf("Inside the FIFO  %0h Addr:%0h",axi_cmp_pkt.data[0],axi_cmp_pkt.addr), 
		    UVM_LOW);
          byte_match(axi_cmp_pkt.data[0]);
        end
      end

      if (axi_cmp_pkt.xact_type == (svt_axi_transaction::WRITE)) begin
        axi_wr_cnt = axi_wr_cnt+1;
        if (axi_wr_cnt == 2) begin
          axi_wr_addr = axi_cmp_pkt.data[0];
          `uvm_info("sfp_scoreboard", $sformatf("axi address 'h %h",axi_wr_addr),UVM_LOW);
        end
        if (axi_wr_cnt == 3 || axi_wr_cnt ==4 || axi_wr_cnt ==5 || axi_wr_cnt ==6) begin
          case (axi_wr_cnt) 
            'h3:  axi_wr_data_byte0 = axi_cmp_pkt.data[0];
            'h4:  axi_wr_data_byte1 = axi_cmp_pkt.data[0];
            'h5:  axi_wr_data_byte2 = axi_cmp_pkt.data[0];
            'h6:  axi_wr_data_byte3 = axi_cmp_pkt.data[0];
          endcase
      
          axi_wr_data = {axi_wr_data_byte3,axi_wr_data_byte2,axi_wr_data_byte1,axi_wr_data_byte0};
          `uvm_info("sfp_scoreboard", $sformatf("axidata is  %h",axi_wr_data),UVM_LOW);
          if(axi_wr_cnt ==6) begin
            axi_wr_cnt=0;
            sfp_fifo.get(sfp_cmp_pkt);
            sfp_wdata = sfp_cmp_pkt.writedata;
            `uvm_info("sfp_scoreboard", $sformatf("sfpdata is  %h",sfp_wdata),UVM_LOW);
            `uvm_info("sfp_scoreboard", $sformatf("axidata is  %h",axi_wr_data),UVM_LOW);
             compare_write_data(sfp_wdata,axi_wr_data);
          end
        end
      end
    end
  endtask : run_phase

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void compare_write_data(logic [31:0] sfp_wdata,logic [31:0] axi_wdata);
    if (axi_wdata == sfp_wdata )begin
     `uvm_info("sfp_scoreboard", 
	        $sformatf("Write data comparison successful  for address 'h %h: AXI write data = `h%h , SFP SLAVE write data = `h%h ",axi_wr_addr, axi_wdata,sfp_wdata), 
		UVM_LOW);  
    end 
    else begin
      `uvm_error("sfp_scoreboard", 
	          $sformatf("Write data comparison ERROR : AXI write data = `h%h , SFP SLAVE write data = `h%h ", axi_wdata,sfp_wdata)); 
    end
  endfunction:compare_write_data

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void byte_match(logic [7:0] val1);
    int count;
    logic [31:0] ref_data_a0, ref_data_a2;

    if(shadow_register_comp_a0.num()>0)begin
      foreach(shadow_register_comp_a0[i])begin
	`uvm_info(get_full_name(), 
		  $sformatf("Associative array A0 %0h val1:%0h",shadow_register_comp_a0[i], val1),
		  UVM_LOW);
        if(shadow_register_comp_a0[i]>0)begin
          ref_data_a0=shadow_register_comp_a0[i];
          for (int i = 0; i < 4; i++) begin
            if (ref_data_a0[i*8 +: 8] == val1)begin
              count=count+1;
            end
          end
        end
      end 
    end

    if(shadow_register_comp_a2.num()>0)begin
      foreach(shadow_register_comp_a2[i])begin
	`uvm_info(get_full_name(), 
		  $sformatf("Associative array A2 %0h val1:%0h",shadow_register_comp_a2[i], val1), 
		  UVM_LOW);
        if(shadow_register_comp_a2[i]>0)begin
          ref_data_a2=shadow_register_comp_a2[i];
          for (int i = 0; i < 4; i++) begin
            if (ref_data_a2[i*8 +: 8] == val1)begin
              count=count+1; 
            end
          end
        end
      end
    end
    
    if(count>0)begin
      `uvm_info("sfp_scoreboard", 
	         $sformatf("Read FIFO data comparison successful AXI Read data = %0h ",val1), 
		 UVM_LOW);
    end
      else if(count==0)begin
        `uvm_error(get_full_name(),
		   $sformatf("Read FIFO data comparision FAILED for AXI Read data = %0h",val1));
    end

  endfunction:byte_match

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void check_full_match_a0(logic [63:0] incoming_data);
    int matched = 0;

    foreach (shadow_register_comp_a0[i]) begin
	    `uvm_info(get_type_name(),
		      $sformatf("Before checking for A0 the match index %0h %0h, %0h",i,shadow_register_comp_a0[i],incoming_data), 
		      UVM_LOW);
      if (incoming_data[63:32] == shadow_register_comp_a0[i] || incoming_data[31:0] == shadow_register_comp_a0[i]) begin
	      matched=matched+1;
	      `uvm_info(get_full_name(),
		        $sformatf("Matched the datat at A0 %0h %0h:", incoming_data,shadow_register_comp_a0[i]), 
			UVM_LOW);
      end
    end
    if (matched > 0)begin
      `uvm_info("sfp_scoreboard", 
	         $sformatf("A0 Read data comparison successful AXI Read data = %0h ",incoming_data), 
		 UVM_LOW);
    end else if (matched == 0)begin
      `uvm_error("sfp_scoreboard", 
	          $sformatf("A0 Read data comparison unsuccessful AXI Read data = %0h",incoming_data));
    end
  endfunction:check_full_match_a0

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------
  virtual function void check_full_match_a2(logic [63:0] incoming_data);
    int matched = 0;

    foreach (shadow_register_comp_a2[i]) begin
	    `uvm_info(get_type_name(),
		      $sformatf("Before checking for A2 the match index %0h %0h, %0h",i,shadow_register_comp_a0[i],incoming_data), 
		      UVM_LOW);
      if (incoming_data[63:32] == shadow_register_comp_a2[i] || incoming_data[31:0] == shadow_register_comp_a2[i]) begin
	      matched=matched+1;
	      `uvm_info(get_full_name(),
		        $sformatf("Matched the datat at A2 %0h %0h:", incoming_data,shadow_register_comp_a2[i]), 
			UVM_LOW);
      end
    end
    if(matched > 0)begin
       `uvm_info("sfp_scoreboard", 
	          $sformatf("A2 Read data comparison successful AXI Read data = %0h ",incoming_data), 
		  UVM_LOW);
     end else if (matched == 0) begin
       `uvm_error("sfp_scoreboard", 
	           $sformatf("A2 Read data comparison unsuccessful AXI Read data = %0h ",incoming_data));
     end
  endfunction:check_full_match_a2

endclass : sfp_scoreboard
