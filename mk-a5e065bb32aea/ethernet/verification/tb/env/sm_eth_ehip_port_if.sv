//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################

`ifndef SM_ETH_EHIP_PORT_IF__SV
`define SM_ETH_EHIP_PORT_IF__SV

interface sm_eth_ehip_port_if;
        // port0 ingress
        logic p0_ingress_clk;
        logic p0_ingress_data;
        logic p0_ingress_valid;
        logic p0_ingress_ready;
        logic p0_ingress_sop;
        logic p0_ingress_eop;
        logic p0_ingress_error;

        // port0 egress
        logic p0_egress_clk;
        logic p0_egress_data;
        logic p0_egress_valid;
        logic p0_egress_ready;
        logic p0_egress_sop;
        logic p0_egress_eop;
        logic p0_egress_error;

        // port1 ingress
        logic p1_ingress_clk;
        logic p1_ingress_data;
        logic p1_ingress_valid;
        logic p1_ingress_ready;
        logic p1_ingress_sop;
        logic p1_ingress_eop;
        logic p1_ingress_error;

        // port1 egress
        logic p1_egress_clk;
        logic p1_egress_data;
        logic p1_egress_valid;
        logic p1_egress_ready;
        logic p1_egress_sop;
        logic p1_egress_eop;
        logic p1_egress_error;
endinterface

`endif
