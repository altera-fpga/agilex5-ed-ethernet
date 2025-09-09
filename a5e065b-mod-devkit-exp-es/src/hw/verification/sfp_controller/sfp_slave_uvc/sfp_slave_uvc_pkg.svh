`ifndef SFP_SLAVE_UVC_PKG_SVH
`define SFP_SLAVE_UVC_PKG_SVH

typedef enum {
	SFP_SLV_WRITE    = 0,
	SFP_SLV_READ     = 1,
	SFP_SLV_RD_HDR   = 2
 } sfp_slv_pkt_t;

    `include "sfp_slave_interface.sv"
    `include "sfp_slave_seq_item.sv"
    `include "sfp_slave_cfg.sv"
    `include "sfp_registry_component.sv"
    `include "sfp_slave_driver.sv"
    `include "sfp_slave_sequencer.sv"
    `include "sfp_slave_monitor.sv"
    `include "sfp_slave_agent.sv"
    `include "sfp_slave_env.sv"
    `include "sfp_slave_auto_response_sequence.sv"

`endif // SFP_SLAVE_UVC_PKG_SVH
