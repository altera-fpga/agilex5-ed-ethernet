//SFP slave interface file
//Interface for I2C 
`ifndef SFP_SLAVE_INTERFACE
`define SFP_SLAVE_INTERFACE

interface sfp_slave_interface(input wire clk , input wire rst_n);

  logic [31:0] address ;
  logic        read ;
  logic [31:0] readdata;
  logic        readdatavalid ;
  logic        waitrequest ;
  logic        write ;
  logic [3:0]  byteenable;
  logic [31:0] writedata;
  logic        i2c_data_in ;
  logic        i2c_clk_in ;
  logic        i2c_data_oe ;
  logic        i2c_clk_oe ;

endinterface
`endif // SFP_SLAVE_INTERFACE
