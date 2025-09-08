
//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 


//
// Description:  This logic is the set of shadow regs for SFPs. 

module shadow_reg #(
   parameter ADDR_WIDTH = 8,    
   parameter DATA_WIDTH = 64,
    parameter BYTE_ENABLE_WIDTH= DATA_WIDTH/8
)(
 
input  logic                           clk,
input  logic                           reset, 
input  logic [ADDR_WIDTH-1:0]          ocm_a0_s1_address,
input  logic                           ocm_a0_s1_read,
output logic [DATA_WIDTH-1:0]          ocm_a0_s1_readdata,
input  logic [BYTE_ENABLE_WIDTH-1:0]   ocm_a0_s1_byteenable,
input  logic                           ocm_a0_s1_write,
input  logic [DATA_WIDTH-1:0]          ocm_a0_s1_writedata,
input  logic [ADDR_WIDTH-1:0]          ocm_a0_s2_address,
input  logic                           ocm_a0_s2_read,
output logic [DATA_WIDTH-1:0]          ocm_a0_s2_readdata,
input  logic [BYTE_ENABLE_WIDTH-1:0]   ocm_a0_s2_byteenable,
input  logic                           ocm_a0_s2_write,
input  logic [DATA_WIDTH-1:0]          ocm_a0_s2_writedata,

input  logic [ADDR_WIDTH-1:0]          ocm_a2_s1_address,
input  logic                           ocm_a2_s1_read,
output logic [DATA_WIDTH-1:0]          ocm_a2_s1_readdata,
input  logic [BYTE_ENABLE_WIDTH-1:0]   ocm_a2_s1_byteenable,
input  logic                           ocm_a2_s1_write,
input  logic [DATA_WIDTH-1:0]          ocm_a2_s1_writedata,
input  logic [ADDR_WIDTH-1:0]          ocm_a2_s2_address,
input  logic                           ocm_a2_s2_read,
output logic [DATA_WIDTH-1:0]          ocm_a2_s2_readdata,
input  logic [BYTE_ENABLE_WIDTH-1:0]   ocm_a2_s2_byteenable,
input  logic                           ocm_a2_s2_write,
input  logic [DATA_WIDTH-1:0]          ocm_a2_s2_writedata
);

logic rst_controller_reset_out_reset;
logic rst_controller_reset_out_reset_req;

//A0
  ocm2_0 ocm2_a0_inst (
        .clk         (clk),         
        .address     (ocm_a0_s1_address),     
        .read        (ocm_a0_s1_read),           
        .readdata    (ocm_a0_s1_readdata),    
        .byteenable  (ocm_a0_s1_byteenable),     
        .write       (ocm_a0_s1_write),          
        .writedata   (ocm_a0_s1_writedata),     
        .reset       (rst_controller_reset_out_reset),          
        .reset_req   (rst_controller_reset_out_reset_req),      
        .address2    (ocm_a0_s2_address),       
        .read2       (ocm_a0_s2_read),          
        .readdata2   (ocm_a0_s2_readdata),   
        .byteenable2 (ocm_a0_s2_byteenable),    
        .write2      (ocm_a0_s2_write),         
        .writedata2  (ocm_a0_s2_writedata)    
    );

//A2 
  ocm2_1 ocm2_a2_inst (
        .clk         (clk),         
        .address     (ocm_a2_s1_address),     
        .read        (ocm_a2_s1_read),           
        .readdata    (ocm_a2_s1_readdata),    
        .byteenable  (ocm_a2_s1_byteenable),     
        .write       (ocm_a2_s1_write),          
        .writedata   (ocm_a2_s1_writedata),     
        .reset       (rst_controller_reset_out_reset),          
        .reset_req   (rst_controller_reset_out_reset_req),      
        .address2    (ocm_a2_s2_address),       
        .read2       (ocm_a2_s2_read),          
        .readdata2   (ocm_a2_s2_readdata),   
        .byteenable2 (ocm_a2_s2_byteenable),    
        .write2      (ocm_a2_s2_write),         
        .writedata2  (ocm_a2_s2_writedata)    
    );
    
reset_req reset_req_inst (
        .clk_clk                             (clk),                                //   input,  width = 1,                       clk.clk
        .reset_reset                         (reset),                              //   input,  width = 1,                     reset.reset
        .reset_req_cntlr_reset_out_reset     (rst_controller_reset_out_reset),     //  output,  width = 1, reset_req_cntlr_reset_out.reset
        .reset_req_cntlr_reset_out_reset_req (rst_controller_reset_out_reset_req)  //  output,  width = 1,                          .reset_req
    );

endmodule
