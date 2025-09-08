//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 


//
// Description: 
// sfp_controller top module instantiates all sub modules
// implementes AVMM address decoding logic


module sfp_top  #(
   parameter ADDR_WIDTH        = 14,                         
   parameter DATA_WIDTH        = 64,
   parameter A0_PAGE_END_ADDR  = 128,
   parameter A2_UPAGE_END_ADDR = 128,
   parameter NUM_PG_SUPPORT    = 3
   
  )(
   input   logic                   clk,                   
   input   logic                   reset,
   input   wire                    mod_det,                  
   input   wire                    tx_fault,               
   input   wire                    rx_los,
   output  wire                    tx_disable,
								   
   input   wire                    i2c_0_i2c_serial_sda_in,
   input   wire                    i2c_0_i2c_serial_scl_in,
   output  wire                    i2c_0_i2c_serial_sda_oe,  
   output  wire                    i2c_0_i2c_serial_scl_oe,
								  
   input   wire [7:0]              axi_bdg_s0_awid,            
   input   wire [ADDR_WIDTH-1:0]   axi_bdg_s0_awaddr,          
   input   wire [7:0]              axi_bdg_s0_awlen,           
   input   wire [2:0]              axi_bdg_s0_awsize,          
   input   wire [1:0]              axi_bdg_s0_awburst,         
   input   wire [0:0]              axi_bdg_s0_awlock,          
   input   wire [3:0]              axi_bdg_s0_awcache,         
   input   wire [2:0]              axi_bdg_s0_awprot,          
   input   wire                    axi_bdg_s0_awvalid,         
   output  wire                    axi_bdg_s0_awready,         
   input   wire [DATA_WIDTH-1:0]   axi_bdg_s0_wdata,           
   input   wire [DATA_WIDTH/8-1:0] axi_bdg_s0_wstrb,           
   input   wire                    axi_bdg_s0_wlast,           
   input   wire                    axi_bdg_s0_wvalid,          
   output  wire                    axi_bdg_s0_wready,          
   output  wire [7:0]              axi_bdg_s0_bid,             
   output  wire [1:0]              axi_bdg_s0_bresp,           
   output  wire                    axi_bdg_s0_bvalid,          
   input   wire                    axi_bdg_s0_bready,          
   input   wire [7:0]              axi_bdg_s0_arid,            
   input   wire [ADDR_WIDTH-1:0]   axi_bdg_s0_araddr,          
   input   wire [7:0]              axi_bdg_s0_arlen,           
   input   wire [2:0]              axi_bdg_s0_arsize,          
   input   wire [1:0]              axi_bdg_s0_arburst,         
   input   wire [0:0]              axi_bdg_s0_arlock,          
   input   wire [3:0]              axi_bdg_s0_arcache,         
   input   wire [2:0]              axi_bdg_s0_arprot,          
   input   wire                    axi_bdg_s0_arvalid,         
   output  wire                    axi_bdg_s0_arready,         
   output  wire [7:0]              axi_bdg_s0_rid,             
   output  wire [DATA_WIDTH-1:0]   axi_bdg_s0_rdata,           
   output  wire [1:0]              axi_bdg_s0_rresp,           
   output  wire                    axi_bdg_s0_rlast,           
   output  wire                    axi_bdg_s0_rvalid,          
   input   wire                    axi_bdg_s0_rready           
);

    localparam  ADDR_WIDTH_COM_CSR     = 8;               // to accomodate 0x00,0x10,0x20,0x30,0x80,0x88,0x90
    localparam  ADDR_WIDTH_SFP_REG     = 8;               // Each page has 256Bytes of Data. So 8 no.of addr bits are required.
    localparam  ADDR_WIDTH_SHADOW_REG  = 8;//8;
    localparam  DATA_WIDTH_I2C_MSTR    = 32;              // I2C Mstr is having 32bit data, So address will be word address.
    localparam  SINK_DATA_WIDTH        = 16;
    localparam  SRC_DATA_WIDTH         = 8;

    // Signals
    logic [7:0]                       byte_offset_address;// The address value got from tfr_cmds, this value%8 gives byte_psn
    logic                             mod_det_d1, mod_det_d2, mod_det_sync;
    logic                             reset_hard_soft_d1, reset_hard_soft_d2, reset_hard_soft_sync;
    //Poller FSM signals --------------------------------------------
    logic [31:0]                      delay_csr_in_com;
    //logic                             wren_logic;
    logic                             rd_done;
    logic [ADDR_WIDTH_SFP_REG-1:0]    curr_rd_addr; 
    logic [7:0]                       curr_rd_page;
    //logic [3:0]                       curr_fsm_state;
    //logic                             read_timeout_fsm_flag;
    logic                             rd_done_ack;
    logic                             wr_cnt_rst;
    logic                             waitrequest;
    // Common csr signals --------------------------------------------
    logic [DATA_WIDTH-1:0]            sfp_com_csr_writedata;
    logic                             sfp_com_csr_read;
    logic                             sfp_com_csr_write;
    logic [DATA_WIDTH-1:0]            sfp_com_csr_readdata;
    logic                             sfp_com_csr_readdatavalid;
    logic [ADDR_WIDTH_COM_CSR-1:0]    sfp_com_csr_address;
    logic                             com_csr_read;
    logic                             com_csr_write;
    logic [DATA_WIDTH-1:0]            csr_readdata_comcsr;
    logic                             csr_readdata_valid_comcsr;
    logic [DATA_WIDTH-1:0]            csr_readdata_comcsr_dly1;
    logic                             csr_readdata_valid_comcsr_dly1;
    logic [DATA_WIDTH-1:0]            csr_readdata_comcsr_dly2;
    logic                             csr_readdata_valid_comcsr_dly2;
    logic [DATA_WIDTH-1:0]            csr_readdata_a0_ocm2s1;
    logic                             csr_readdata_valid_a0_ocm2s1;
    logic [DATA_WIDTH-1:0]            csr_readdata_a2_ocm2s1;
    logic                             csr_readdata_valid_a2_ocm2s1;

    // config signals-------------------------------------------------
    logic                             config_poll_en_com;  
    logic                             config_update_a0_page_com;
    logic                             config_softresetsfpc_com;
    logic                             reset_hard_soft;
    // poller_fsm signals    
    logic                             fsm_paused;
    logic                             init_done;
    // I2C Mstr signals 
    logic [3:0]                       i2c_0_csr_address;
    logic                             i2c_0_csr_read;
    logic                             i2c_0_csr_write;
    logic [DATA_WIDTH/8-1:0]          csr_byteenable_bkp;
    logic [DATA_WIDTH/8-1:0]          csr_byteenable_bkp1;
    logic [DATA_WIDTH_I2C_MSTR-1:0]   i2c_0_csr_writedata;
    logic [DATA_WIDTH_I2C_MSTR-1:0]   i2c_0_csr_readdata;
    logic                             i2c_0_csr_readdata_valid;
    logic                             i2c_0_csr_readdata_valid_dly;
    logic                             i2c_0_csr_read_q;
    logic [DATA_WIDTH-1:0]            i2c_0_csr_writedata_64;
    logic [DATA_WIDTH-1:0]            i2c_0_csr_readdata_64;
    logic                             src_valid;
    logic [SRC_DATA_WIDTH-1:0]        src_data;
    logic                             src_ready;
    logic [SINK_DATA_WIDTH-1:0]       sink_data;
    logic                             sink_valid;
    logic                             sink_ready;
    logic                             status_int_i2c_i;
    logic                             idle_flag;
    logic [7:0]                       slave_address;  
    logic                             ocm_a0_s1_read;
    logic                             ocm_a0_s1_write;
    logic                             ocm_a2_s1_read;
    logic                             ocm_a2_s1_write;  
    // Shadow reg signals---Read interface to S/m level csr space--------
    logic                             sfp_cntrl_ocm_a0_s1_read; 
    logic [ADDR_WIDTH_SHADOW_REG-1:0] sfp_cntrl_ocm_a0_s1_address;      
    logic                             sfp_cntrl_ocm_a0_s1_write;
    logic [DATA_WIDTH-1:0]            sfp_cntrl_ocm_a0_s1_readdata;      
    logic                             sfp_cntrl_ocm_a0_s1_readdata_valid;
    logic                             sfp_cntrl_ocm_a2_s1_read; 
    logic [ADDR_WIDTH_SHADOW_REG-1:0] sfp_cntrl_ocm_a2_s1_address;      
    logic                             sfp_cntrl_ocm_a2_s1_write;
    logic [DATA_WIDTH-1:0]            sfp_cntrl_ocm_a2_s1_readdata;      
    logic                             sfp_cntrl_ocm_a2_s1_readdata_valid;
    // Csr write logic -> Shadow reg mem write --------------------------
    logic                             shadow_mem_wren;
    logic [DATA_WIDTH-1:0]            shadow_mem_wdata;
    logic [DATA_WIDTH/8-1:0]          shadow_mem_byteenable;
    logic [ADDR_WIDTH_SHADOW_REG-1:0] shadow_mem_waddr;
    logic                             shadow_mem_chipsel;
    // Below signals are coming from csr write     
    logic                             mem_wren;
    logic [DATA_WIDTH-1:0]            mem_wdata;
    logic [DATA_WIDTH/8-1:0]          mem_byteenable;
    logic [ADDR_WIDTH_SHADOW_REG-1:0] mem_waddr;
    logic                             mem_chipsel;
    logic [DATA_WIDTH-1:0]            csr_readdata;      
    logic                             csr_readdata_valid; 
    logic [DATA_WIDTH-1:0]            csr_wdata;     
    logic [ADDR_WIDTH-1:0]            csr_addr;       
    logic                             csr_write;         
    logic                             csr_read;
    logic                             csr_waitreq;
    logic [DATA_WIDTH/8-1:0]          csr_byteenable;
 	logic                             status_a0_update_rdy_to_start_com;
	logic                             status_a0_update_in_progress_com ;
	logic                             status_a0_page_read_complete_com ;
	logic                             status_a2_update_in_progress_com ;
	logic                             status_a2_page_read_complete_com ;
	logic                             status_a0_page_read_error_com    ;   
	logic                             status_a2_page_read_error_com    ;  
	logic                             reset_a0_update_config_bit_com   ;  
    logic                             config_update_a0_page_com        ;
	logic [1:0]                       config_sfp_sel_com               ;
	logic [7:0]                       rxdata                           ;
    logic [2:0]                       a2_ocm_up_bits;
	logic [3:0]                       curr_fsm_state                   ;
	logic                             rd_data_en, rd_data_en_d1, rd_data_en_d2;
 
    always @(*) 
	  begin            
        if(reset_hard_soft_sync) 
          waitrequest = 1'b0; //:tag A1
        else if(~idle_flag) //csr_wr_en fsm is not in idle :tag A0
          waitrequest = 1'b1;   
        else if(csr_write | csr_read) 
          waitrequest = 1'b0; 
        else 
          waitrequest = 1'b0; //:tag A1
      end
 
    assign csr_waitreq           = waitrequest;
    assign reset_hard_soft       = reset || config_softresetsfpc_com;
    
// Synchronizing mod_det reset
   always @(posedge clk) begin
     if (reset_hard_soft) begin
       //by default, mod_det should be 0.
       mod_det_d1           <= '0;
       mod_det_d2           <= '0;
       reset_hard_soft_d1   <= 1;     //Active high reset
       reset_hard_soft_d2   <= 1;     //Active high reset
	 end
     else begin
       mod_det_d1           <= mod_det;
       mod_det_d2           <= mod_det_d1;
       reset_hard_soft_d1   <= reset_hard_soft; 
       reset_hard_soft_d2   <= reset_hard_soft_d1; 
	 end
   end 
   
   assign mod_det_sync                     = mod_det_d2;
   assign reset_hard_soft_sync             = reset_hard_soft_d2;
   
   // Assignment of Common csr, Shadow csr, Csr_write signals   
   assign sfp_com_csr_address              = csr_addr[ADDR_WIDTH_COM_CSR-1:0];// byte address, changed from [5:0] to [7:0] to accomodate 0x00,0x10,0x20,0x30,0x80,0x88,0x90
   assign sfp_com_csr_read                 = com_csr_read;                                                                                                                                       
   assign sfp_com_csr_write                = com_csr_write;
   assign sfp_com_csr_writedata            = csr_wdata;
   
   // ------------System level user space CSR - Shadow reg csr path---------------------- 
   assign sfp_cntrl_ocm_a0_s1_address      =  csr_addr[10:3]; // Each address is for 64-bit data -- Adress translation from 0x800 to 0x880 (which is local offset for A0)     
   assign sfp_cntrl_ocm_a0_s1_read         =  ocm_a0_s1_read; // Bits of lsb has been removed from addr, since 3 bits{2,1,0} stans for 2^3=8B=64bit 
   assign sfp_cntrl_ocm_a0_s1_write        =  ocm_a0_s1_write;   
  
   assign sfp_cntrl_ocm_a2_s1_address      =  {a2_ocm_up_bits, csr_addr[7:3]}; // Each address is for 64-bit data -- Adress translation from  0x100 to 0x700 (which is local offset for A2)        
   assign sfp_cntrl_ocm_a2_s1_read         =  ocm_a2_s1_read; // Bits of lsb has been removed from addr, since 3 bits{2,1,0} stans for 2^3=8B=64bit 
   assign sfp_cntrl_ocm_a2_s1_write        =  ocm_a2_s1_write;       
 
   
   always_comb
   begin
     case (csr_addr[10:8])
	   3'b001:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b0;
	 	end
	   3'b010:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b001;
	 	end
	   3'b011:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b010;
	 	end
	   3'b100:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b011;
	 	end
	   3'b101:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b100;
	 	end
	   3'b110:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b101;
	 	end
	   3'b111:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b110;
	 	end
	   default:
	     begin
 	       a2_ocm_up_bits[2:0] = 3'b0;
	 	 end
     endcase
   end	
	
   // ------------CSR_write - Shadow reg data path-----------------------------------------
   //mem_wren is from csr write. shadow_mem_wren is going to multiple SFP-----------------
    assign shadow_mem_wren                 =  mem_wren    ;
    assign shadow_mem_waddr                =  mem_waddr   ;
    assign shadow_mem_chipsel              =  mem_chipsel ; 
    assign shadow_mem_wdata                =  mem_wdata   ; 
    assign shadow_mem_byteenable           =  mem_byteenable;

    
// Address mapping-----------------------------------------------
//assign i2c_0_csr_address            =  csr_addr[5:2]; // word address (byte address to word address conversion)  
// I2C Mstr contains registers like TFR_CMD, RX_DATA, ISER. All are 32 bits wide regs.                                     
// Write data mapping--------------------------------------------
   assign i2c_0_csr_writedata_64       = csr_wdata;

   always_comb
   begin
     if(csr_byteenable== 8'hF0) 
	 begin // Upper/Odd 
       i2c_0_csr_writedata = i2c_0_csr_writedata_64[63:32];
       i2c_0_csr_address   = csr_addr[5:2];
       i2c_0_csr_address[0]= 1; 
	 end
     else if(csr_byteenable== 8'h0F) 
	 begin // Lower/Even
       i2c_0_csr_writedata = i2c_0_csr_writedata_64[31:0];
       i2c_0_csr_address   = csr_addr[5:2]; 
	 end
     else begin
       i2c_0_csr_writedata = '0;
       i2c_0_csr_address   = '0; 
	 end
   end 

   // byteenable for read will be valid only on that pulse. During rd_data_vld we need to configure accordinly.
   always @(posedge clk) 
   begin
     if(reset_hard_soft_sync)
	 begin 
       csr_byteenable_bkp   <=  '0;
       csr_byteenable_bkp1  <=  '0;
	 end
     else 
	 begin 
       csr_byteenable_bkp  <= csr_byteenable;
       csr_byteenable_bkp1 <= csr_byteenable_bkp;
	 end
   end
   
   always @(posedge clk) 
   begin
     if(reset_hard_soft_sync)
	 begin 
        rd_data_en    <= 0;
        rd_data_en_d1 <= 0;
        rd_data_en_d2 <= 0;
	 end
     else 
	 begin 
        if (((csr_byteenable== 8'hF0) && (csr_addr == 0'h040)) || ((csr_byteenable== 8'h0F) && (csr_addr == 0'h044)))
		  rd_data_en <= csr_read;
		else
		  rd_data_en <= 0;
		  
		rd_data_en_d1 <= rd_data_en;
		rd_data_en_d2 <= rd_data_en_d1;
	 end
   end

   always @(posedge clk) 
   begin
      if(reset_hard_soft_sync)  
         i2c_0_csr_readdata_64 <= '0;
      else
      begin
	    if(csr_byteenable_bkp1== 8'hF0 && i2c_0_csr_readdata_valid)  // Upper/Odd 
            if (rd_data_en_d1)  // Upper/Odd 
               i2c_0_csr_readdata_64 <= {24'h0, rxdata, 32'h0};
	        else
               i2c_0_csr_readdata_64 <= {i2c_0_csr_readdata,32'h0};
        else if(csr_byteenable_bkp1== 8'h0F && i2c_0_csr_readdata_valid)  // Lower/Even
 	        if (rd_data_en_d1)
	           i2c_0_csr_readdata_64 <= {32'h0,24'h0, rxdata};
	        else
              i2c_0_csr_readdata_64 <= {32'h0,i2c_0_csr_readdata};
      end 
   end 

  // Read-Write mapping
  always_comb
  begin
    com_csr_read                     = 1'b0;
    com_csr_write                    = 1'b0;
    i2c_0_csr_read                   = 1'b0;
    i2c_0_csr_write                  = 1'b0;
    casez (csr_addr[11:6])
      6'h00,
      6'h02: begin // Common CSR  -- 0x000 -> 0x030, 0x80,0x88,0x90 
         com_csr_read                = csr_read;
         com_csr_write               = csr_write;
         ocm_a0_s1_read              = 1'b0;
         ocm_a0_s1_write             = 1'b0;
         ocm_a2_s1_read              = 1'b0;
         ocm_a2_s1_write             = 1'b0;
         i2c_0_csr_read              = 1'b0;
         i2c_0_csr_write             = 1'b0;
      end   
      6'h01 : begin // I2C controller CSR -- 0x040 -> 0x068
         com_csr_read                = 1'b0;
         com_csr_write               = 1'b0;
         ocm_a0_s1_read              = 1'b0;
         ocm_a0_s1_write             = 1'b0;
         ocm_a2_s1_read              = 1'b0;
         ocm_a2_s1_write             = 1'b0;
         i2c_0_csr_read              = csr_read;
         i2c_0_csr_write             = csr_write;
       end
       6'b100???: begin // A0 OCM -> 0x800 -> 0x900 (256 bytes)
         com_csr_read                = 1'b0;
         com_csr_write               = 1'b0;
         ocm_a0_s1_read              = csr_read;
         ocm_a0_s1_write             = ~csr_read;  // No read signal for OCM, so invert read input to write port
         ocm_a2_s1_read              = 1'b0;
         ocm_a2_s1_write             = 1'b0;
         i2c_0_csr_read              = 1'b0;
         i2c_0_csr_write             = 1'b0;
       end
       6'b0001??,6'b001???,6'b01????: begin  // A2 OCM -> 0x100 -> 0x700 (256 bytes)
         com_csr_read                = 1'b0;
         com_csr_write               = 1'b0;
         ocm_a0_s1_read              = 1'b0;
         ocm_a0_s1_write             = 1'b0;
         ocm_a2_s1_read              = csr_read;
         ocm_a2_s1_write             = ~csr_read;  // No read signal for OCM, so invert read input to write port
         i2c_0_csr_read              = 1'b0;
         i2c_0_csr_write             = 1'b0;
       end
       default: begin
         com_csr_read                = 1'b0;
         com_csr_write               = 1'b0;
         ocm_a0_s1_read              = 1'b0;
         ocm_a0_s1_write             = 1'b0;
         ocm_a2_s1_read              = 1'b0;
         ocm_a2_s1_write             = 1'b0;
         i2c_0_csr_read              = 1'b0;
         i2c_0_csr_write             = 1'b0;
       end
     endcase
   end

   //Read data Valid generation-----------------------------------------
   always_ff @(posedge clk) begin
      if(reset_hard_soft_sync) 
	  begin
        i2c_0_csr_readdata_valid     <= 0;
        i2c_0_csr_read_q             <= 0;
		i2c_0_csr_readdata_valid_dly <= 0;
	  end
      else  
	  begin
        i2c_0_csr_read_q             <= i2c_0_csr_read;                  // 2 clk latency for I2C controller read
        i2c_0_csr_readdata_valid     <= i2c_0_csr_read_q; 
		i2c_0_csr_readdata_valid_dly <= i2c_0_csr_readdata_valid;
	  end
   end 

   always_ff @(posedge clk) 
   begin 
     if(reset_hard_soft_sync)
       sfp_cntrl_ocm_a0_s1_readdata_valid <= 2'd0;
     else
       sfp_cntrl_ocm_a0_s1_readdata_valid <= sfp_cntrl_ocm_a0_s1_read  
                                         & (~sfp_cntrl_ocm_a0_s1_write);  // 1 clk latency for on-chip mem
   end

   always_ff @(posedge clk) 
   begin 
     if (reset_hard_soft_sync)
       sfp_cntrl_ocm_a2_s1_readdata_valid    <=2'd0;
     else
       sfp_cntrl_ocm_a2_s1_readdata_valid  <= sfp_cntrl_ocm_a2_s1_read 
                                         & (~sfp_cntrl_ocm_a2_s1_write);  // 1 clk latency for on-chip mem
   end

   always @(*) 
   begin 
     if(reset_hard_soft_sync) 
     begin
       csr_readdata_comcsr       = '0;
       csr_readdata_valid_comcsr = 1'b0;
     end
     else if(~(|sfp_com_csr_readdatavalid)) 
     begin
       csr_readdata_comcsr       = '0;
       csr_readdata_valid_comcsr = 1'b0;
     end
     else 
	 begin
	   if (sfp_com_csr_readdatavalid) 
       begin                 
         csr_readdata_comcsr       = sfp_com_csr_readdata;
         csr_readdata_valid_comcsr = sfp_com_csr_readdatavalid; 
       end 
     end 
   end

   always_ff @(posedge clk) 
   begin 
     if (reset_hard_soft_sync) 
     begin
       csr_readdata_a0_ocm2s1       <= '0;
       csr_readdata_valid_a0_ocm2s1 <= 1'b0;
     end
     else if(~(|sfp_cntrl_ocm_a0_s1_readdata_valid))
     begin
       csr_readdata_a0_ocm2s1       <= '0;
       csr_readdata_valid_a0_ocm2s1 <= 0;
     end       
     else 
     begin 
       if (sfp_cntrl_ocm_a0_s1_readdata_valid) 
       begin                 
         csr_readdata_a0_ocm2s1       <= sfp_cntrl_ocm_a0_s1_readdata;
         csr_readdata_valid_a0_ocm2s1 <= sfp_cntrl_ocm_a0_s1_readdata_valid; 
       end                                       
     end 
   end 

   always_ff @(posedge clk) 
   begin 
     if (reset_hard_soft_sync) 
     begin
       csr_readdata_a2_ocm2s1       <= '0;
       csr_readdata_valid_a2_ocm2s1 <= 1'b0;
     end
     else if(~(|sfp_cntrl_ocm_a2_s1_readdata_valid))
     begin
       csr_readdata_a2_ocm2s1       <= '0;
       csr_readdata_valid_a2_ocm2s1 <= 0;
     end       
     else 
     begin 
       if (sfp_cntrl_ocm_a2_s1_readdata_valid) 
       begin                 
         csr_readdata_a2_ocm2s1       <= sfp_cntrl_ocm_a2_s1_readdata;
         csr_readdata_valid_a2_ocm2s1 <= sfp_cntrl_ocm_a2_s1_readdata_valid; 
       end                                       
     end
   end

 // always_ff @(posedge clk) 
 // begin          
 //   if (reset_hard_soft_sync) 
 //   begin
 //     csr_readdata_comcsr_dly2       <=0;
 //     csr_readdata_comcsr_dly1       <=0;
 //     csr_readdata_valid_comcsr_dly2 <=0;
 //     csr_readdata_valid_comcsr_dly1 <=0;
 //   end
 //   else 
 //   begin
 //     csr_readdata_comcsr_dly2       <= csr_readdata_comcsr_dly1;
 //     csr_readdata_comcsr_dly1       <= csr_readdata_comcsr;
 //     csr_readdata_valid_comcsr_dly2 <= csr_readdata_valid_comcsr_dly1;
 //     csr_readdata_valid_comcsr_dly1 <= csr_readdata_valid_comcsr; 
 //   end
 // end 
  
  // Read data mapping  
  always_ff @(posedge clk) 
  begin      
    if (reset_hard_soft_sync) 
    begin
      csr_readdata       <= '0;
      csr_readdata_valid <= 1'b0;
    end
    else if (csr_readdata_valid_comcsr) //csr_readdata_valid_comcsr_dly2) 
    begin
      csr_readdata       <= csr_readdata_comcsr; //csr_readdata_comcsr_dly2;
      csr_readdata_valid <= 1'b1; 
    end           
    else if (i2c_0_csr_readdata_valid_dly) 
    begin
      csr_readdata       <= i2c_0_csr_readdata_64;
      csr_readdata_valid <= 1'b1; 
    end
    else if (csr_readdata_valid_a0_ocm2s1) 
    begin
      csr_readdata       <= csr_readdata_a0_ocm2s1;
      csr_readdata_valid <= 1'b1; 
    end
    else if (csr_readdata_valid_a2_ocm2s1) 
    begin
      csr_readdata       <= csr_readdata_a2_ocm2s1;
      csr_readdata_valid <= 1'b1; 
    end
    else 
    begin
      csr_readdata       <= '0;
      csr_readdata_valid <= 1'b0; 
    end  
  end 

axi_to_avmm_qsfp_cntlr u0 (
    .avmm_bdg_0_m0_waitrequest   (csr_waitreq),   //   input,   width = 1, avmm_bdg_0_m0.waitrequest
    .avmm_bdg_0_m0_readdata      (csr_readdata),      //   input,  width = 64,              .readdata
    .avmm_bdg_0_m0_readdatavalid (csr_readdata_valid), //   input,   width = 1,              .readdatavalid
    .avmm_bdg_0_m0_burstcount    (csr_burstcount),    //  output,   width = 1,              .burstcount
    .avmm_bdg_0_m0_writedata     (csr_wdata),     //  output,  width = 64,              .writedata
    .avmm_bdg_0_m0_address       (csr_addr),       //  output,  width = 14,              .address
    .avmm_bdg_0_m0_write         (csr_write),         //  output,   width = 1,              .write
    .avmm_bdg_0_m0_read          (csr_read),          //  output,   width = 1,              .read
    .avmm_bdg_0_m0_byteenable    (csr_byteenable),    //  output,   width = 8,              .byteenable
    .avmm_bdg_0_m0_debugaccess   (csr_debugaccess),   //  output,   width = 1,              .debugaccess
    .axi_bdg_s0_awid             (axi_bdg_s0_awid),             //   input,   width = 8,    axi_bdg_s0.awid
    .axi_bdg_s0_awaddr           (axi_bdg_s0_awaddr),           //   input,  width = 14,              .awaddr
    .axi_bdg_s0_awlen            (axi_bdg_s0_awlen),            //   input,   width = 8,              .awlen
    .axi_bdg_s0_awsize           (axi_bdg_s0_awsize),           //   input,   width = 3,              .awsize
    .axi_bdg_s0_awburst          (axi_bdg_s0_awburst),          //   input,   width = 2,              .awburst
    .axi_bdg_s0_awlock           (axi_bdg_s0_awlock),           //   input,   width = 1,              .awlock
    .axi_bdg_s0_awcache          (axi_bdg_s0_awcache),          //   input,   width = 4,              .awcache
    .axi_bdg_s0_awprot           (axi_bdg_s0_awprot),           //   input,   width = 3,              .awprot
    .axi_bdg_s0_awvalid          (axi_bdg_s0_awvalid),          //   input,   width = 1,              .awvalid
    .axi_bdg_s0_awready          (axi_bdg_s0_awready),          //  output,   width = 1,              .awready
    .axi_bdg_s0_wdata            (axi_bdg_s0_wdata),            //   input,  width = 64,              .wdata
    .axi_bdg_s0_wstrb            (axi_bdg_s0_wstrb),            //   input,   width = 8,              .wstrb
    .axi_bdg_s0_wlast            (axi_bdg_s0_wlast),            //   input,   width = 1,              .wlast
    .axi_bdg_s0_wvalid           (axi_bdg_s0_wvalid),           //   input,   width = 1,              .wvalid
    .axi_bdg_s0_wready           (axi_bdg_s0_wready),           //  output,   width = 1,              .wready
    .axi_bdg_s0_bid              (axi_bdg_s0_bid),              //  output,   width = 8,              .bid
    .axi_bdg_s0_bresp            (axi_bdg_s0_bresp),            //  output,   width = 2,              .bresp
    .axi_bdg_s0_bvalid           (axi_bdg_s0_bvalid),           //  output,   width = 1,              .bvalid
    .axi_bdg_s0_bready           (axi_bdg_s0_bready),           //   input,   width = 1,              .bready
    .axi_bdg_s0_arid             (axi_bdg_s0_arid),             //   input,   width = 8,              .arid
    .axi_bdg_s0_araddr           (axi_bdg_s0_araddr),           //   input,  width = 14,              .araddr
    .axi_bdg_s0_arlen            (axi_bdg_s0_arlen),            //   input,   width = 8,              .arlen
    .axi_bdg_s0_arsize           (axi_bdg_s0_arsize),           //   input,   width = 3,              .arsize
    .axi_bdg_s0_arburst          (axi_bdg_s0_arburst),          //   input,   width = 2,              .arburst
    .axi_bdg_s0_arlock           (axi_bdg_s0_arlock),           //   input,   width = 1,              .arlock
    .axi_bdg_s0_arcache          (axi_bdg_s0_arcache),          //   input,   width = 4,              .arcache
    .axi_bdg_s0_arprot           (axi_bdg_s0_arprot),           //   input,   width = 3,              .arprot
    .axi_bdg_s0_arvalid          (axi_bdg_s0_arvalid),          //   input,   width = 1,              .arvalid
    .axi_bdg_s0_arready          (axi_bdg_s0_arready),          //  output,   width = 1,              .arready
    .axi_bdg_s0_rid              (axi_bdg_s0_rid),              //  output,   width = 8,              .rid
    .axi_bdg_s0_rdata            (axi_bdg_s0_rdata),            //  output,  width = 64,              .rdata
    .axi_bdg_s0_rresp            (axi_bdg_s0_rresp),            //  output,   width = 2,              .rresp
    .axi_bdg_s0_rlast            (axi_bdg_s0_rlast),            //  output,   width = 1,              .rlast
    .axi_bdg_s0_rvalid           (axi_bdg_s0_rvalid),           //  output,   width = 1,              .rvalid
    .axi_bdg_s0_rready           (axi_bdg_s0_rready),           //   input,   width = 1,              .rready
    .clk_clk                     (clk),                     //   input,   width = 1,           clk.clk
    .reset_reset                 (reset)                  //   input,   width = 1,         reset.reset
    );
   
poller_fsm 
    #(
    .CSR_ADDR_WIDTH (12),
    .CSR_DATA_WIDTH (10),
	.MEM_ADDR_WIDTH (14),
	.MEM_DATA_WIDTH (64),
	.SRC_DATA_WIDTH (8),
    .SINK_DATA_WIDTH(16),
    .ADDR_WIDTH_SFP_REG (8),
    .A0_PAGE_END_ADDR (A0_PAGE_END_ADDR),
	.A2_UPAGE_END_ADDR (A2_UPAGE_END_ADDR),
	.NUM_PG_SUPPORT (NUM_PG_SUPPORT)
	
    ) poller_fsm_inst
    (
    .clk                           (clk         ),
    .reset                         (reset_hard_soft_sync),
    .mod_det                       (mod_det_sync),
    .poll_en                       (config_poll_en_com),  // Register of poll_en 
    .src_valid                     (src_valid   ),
    .src_data                      (src_data    ),
    .src_ready                     (src_ready   ),
    .sink_data                     (sink_data   ),
    .sink_valid                    (sink_valid  ),
    .sink_ready                    (sink_ready  ),
    .curr_rd_addr                  (curr_rd_addr),
    .curr_rd_page                  (curr_rd_page),
    .init_done                     (init_done   ),
    .status_a0_update_rdy_to_start (status_a0_update_rdy_to_start_com),
	.status_a0_update_in_progress  (status_a0_update_in_progress_com ),
	.status_a0_page_read_complete  (status_a0_page_read_complete_com ),
	.status_a2_update_in_progress  (status_a2_update_in_progress_com ),
	.status_a2_page_read_complete  (status_a2_page_read_complete_com ),
	.status_a0_page_read_error     (status_a0_page_read_error_com    ),   
	.status_a2_page_read_error     (status_a2_page_read_error_com    ),   
    .config_update_a0_page         (config_update_a0_page_com        ),
	.reset_a0_update_config_bit    (reset_a0_update_config_bit_com   ),
    .csr_wdata                     (i2c_0_csr_writedata[9:0]),
    .csr_write                     (csr_write),
    .csr_addr                      (csr_addr[11:0]),
    .delay_csr_in                  (delay_csr_in_com),
    .slave_address                 (slave_address),
    .idle_flag                     (idle_flag),
    .mem_wren                      (mem_wren    ),
    .mem_chipsel                   (mem_chipsel ),
    .mem_wdata                     (mem_wdata   ),
    .mem_byteenable                (mem_byteenable),
    .mem_waddr                     (mem_waddr    ),
	.rxdata                        (rxdata       ),
	.curr_fsm_state                (curr_fsm_state                   )
	);
    
i2c_init_done_check #(
    .ADDR_WIDTH          (4),
    .DATA_WIDTH          (32)
    )i2c_init_done_check_inst
    (
    .clk                              (clk),
    .reset                            (reset_hard_soft_sync),
    .i2c_0_csr_address_snoop          (i2c_0_csr_address),
    .i2c_0_csr_write_snoop            (i2c_0_csr_write),
    .i2c_0_csr_writedata_snoop        (i2c_0_csr_writedata),
    .init_done                        (init_done)
    );
    
qsfp_ctrl qsfp_ctrl_inst (
   .clk_clk                           (clk),
   .i2c_0_interrupt_sender_irq        (status_int_i2c_i),    // Interrupt from I2C mstr 
   .i2c_0_csr_address                 (i2c_0_csr_address   ), //AVMM Csr to access RX_DATA,CTRL,ISER,ISR,STATUS,TFR_CMD_FIFO_LVL,RX_DATA_FIFO_LVL,SCL_LOW,SCL_HIGH,SDA_HOLD
   .i2c_0_csr_read                    (i2c_0_csr_read      ), // To access TFR_CMD_FIFO, software uses poller fsm. Since poller fsm is only connected to the sink path of I2C mastr.
   .i2c_0_csr_write                   (i2c_0_csr_write     ),
   .i2c_0_csr_writedata               (i2c_0_csr_writedata ),
   .i2c_0_csr_readdata                (i2c_0_csr_readdata  ), //Latency 2 clk
   .i2c_0_i2c_serial_sda_in           (i2c_0_i2c_serial_sda_in),
   .i2c_0_i2c_serial_scl_in           (i2c_0_i2c_serial_scl_in),
   .i2c_0_i2c_serial_sda_oe           (i2c_0_i2c_serial_sda_oe),
   .i2c_0_i2c_serial_scl_oe           (i2c_0_i2c_serial_scl_oe),
   .i2c_0_rx_data_source_data         (src_data),
   .i2c_0_rx_data_source_valid        (src_valid),
   .i2c_0_rx_data_source_ready        (src_ready),
   .i2c_0_transfer_command_sink_data  (sink_data),  //AVST
   .i2c_0_transfer_command_sink_valid (sink_valid),
   .i2c_0_transfer_command_sink_ready (sink_ready),  
   .reset_reset                       (reset_hard_soft_sync)
   );

// Common CSR space 
sfp_com  #(
    .ADDR_WIDTH            (8),
    .DATA_WIDTH            (DATA_WIDTH),
    .ADDR_WIDTH_SFP_REG    (8)
   ) sfp_com_inst (

    .clk                           (clk                              ),
    .reset                         (reset_hard_soft_sync             ),
    .writedata                     (sfp_com_csr_writedata            ),
    .read                          (sfp_com_csr_read                 ),
    .delay_csr_in                  (delay_csr_in_com                 ),
    .write                         (sfp_com_csr_write                ),
    .byteenable                    (csr_byteenable                   ),
    .readdata                      (sfp_com_csr_readdata             ),
    .readdatavalid                 (sfp_com_csr_readdatavalid        ),
    .address                       (sfp_com_csr_address              ),
    .init_done                     (init_done                        ),
    .status_mod_det_i              (mod_det_sync                     ),
    .status_int_i2c_i              (status_int_i2c_i                 ),
    .status_txfault                (tx_fault                         ),
    .status_rxlos                  (rx_los                           ),
 	.status_a0_update_rdy_to_start (status_a0_update_rdy_to_start_com),
	.status_a0_update_in_progress  (status_a0_update_in_progress_com ),
	.status_a0_page_read_complete  (status_a0_page_read_complete_com ),
	.status_a2_update_in_progress  (status_a2_update_in_progress_com ),
	.status_a2_page_read_complete  (status_a2_page_read_complete_com ),
	.status_a0_page_read_error     (status_a0_page_read_error_com    ),   
	.status_a2_page_read_error     (status_a2_page_read_error_com    ),   
    .config_softresetsfpc          (config_softresetsfpc_com         ),
    .config_txdisable              (tx_disable                       ),
    .config_poll_en                (config_poll_en_com               ),
    .config_update_a0_page         (config_update_a0_page_com        ),
	.reset_a0_update_config_bit    (reset_a0_update_config_bit_com   ),
	.config_sfp_sel                (config_sfp_sel_com               ),
    .curr_rd_addr                  (curr_rd_addr                     ),
    .curr_rd_page                  (curr_rd_page                     ),
	.curr_fsm_state                (curr_fsm_state                   ),
	.src_ready_int                 (src_ready                        ),
	.sink_ready_int                (sink_ready                       )
  );

//onchip_memory2_s1 is for csr access for SW    
shadow_reg #(
    .ADDR_WIDTH          (8), // Total memory size is 768B.Hence no.of addr bits required will be 768/8=96=x69 (7 bits)
    .DATA_WIDTH          (64),
    .BYTE_ENABLE_WIDTH   (DATA_WIDTH/8)
  ) shadow_reg_inst (
    .clk                   (clk),
    .reset                 (reset_hard_soft_sync), 
    .ocm_a0_s1_address     (sfp_cntrl_ocm_a0_s1_address),
    .ocm_a0_s1_read        (sfp_cntrl_ocm_a0_s1_read),
    .ocm_a0_s1_readdata    (sfp_cntrl_ocm_a0_s1_readdata),
    .ocm_a0_s1_byteenable  (8'hff),//2*8   --parametrization  needed
    .ocm_a0_s1_write       (),
    .ocm_a0_s1_writedata   (),
    .ocm_a0_s2_address     (shadow_mem_waddr),
    .ocm_a0_s2_read        (),
    .ocm_a0_s2_readdata    (),
    .ocm_a0_s2_byteenable  (shadow_mem_byteenable),//8'hffff),
    .ocm_a0_s2_write       (shadow_mem_wren && (slave_address =='hA0)),//(shadow_mem_wren && ~poll_en_start)
    .ocm_a0_s2_writedata   (shadow_mem_wdata),
    
    .ocm_a2_s1_address     (sfp_cntrl_ocm_a2_s1_address),
    .ocm_a2_s1_read        (sfp_cntrl_ocm_a2_s1_read),
    .ocm_a2_s1_readdata    (sfp_cntrl_ocm_a2_s1_readdata),
    .ocm_a2_s1_byteenable  (8'hffff),
    .ocm_a2_s1_write       (),
    .ocm_a2_s1_writedata   (),
    .ocm_a2_s2_address     (shadow_mem_waddr),
    .ocm_a2_s2_read        (),
    .ocm_a2_s2_readdata    (),
    .ocm_a2_s2_byteenable  (shadow_mem_byteenable),//8'hffff),

    .ocm_a2_s2_write       (shadow_mem_wren && (slave_address == 'hA2)),//(shadow_mem_wren && poll_en_start),
    .ocm_a2_s2_writedata   (shadow_mem_wdata)
  );


(* syn_preserve = 1 *) reg [6:0]count_stp_clk; 
(* syn_preserve = 1 *) wire stp_clk; 
  //create 1MHz clk for stp
 always@(posedge clk)
  begin

    if(reset)
       count_stp_clk <='0;
     else if(count_stp_clk==7'd99)
       count_stp_clk <=0;
     else 
       count_stp_clk <=  count_stp_clk+1;
  end 
 
assign stp_clk = (count_stp_clk <'d49) ? 1'b1 : 1'b0;
 
endmodule
