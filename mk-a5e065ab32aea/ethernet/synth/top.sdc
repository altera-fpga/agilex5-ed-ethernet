# ######################################################################## 
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
# ######################################################################## 


set_time_format -unit ns -decimal_places 3

set sfp_csr_clk soc_inst|iopll_0|iopll_csr_clk

set_false_path -from [get_ports {sfp_i2c_scl}] -to *
set_false_path -from * -to [get_ports {sfp_i2c_scl}]
set_false_path -from [get_ports {sfp_i2c_sda}] -to *
set_false_path -from * -to [get_ports {sfp_i2c_sda}]
set_false_path -from [get_ports {sfp_mod_det}] -to *
set_false_path -from [get_ports {sfp_tx_fault}] -to *
set_false_path -from [get_ports {sfp_rx_los}] -to *

set_output_delay  -source_latency_included 1 -clock $sfp_csr_clk [get_ports {sfp_tx_disable}]
set_false_path -from * -to [get_ports {sfp_tx_disable}]

set tennm_refclk_grp    soc_inst|iopll_0|iopll|tennm_ph2_iopll|ref_clk0
set hps_clk_grp         soc_inst|iopll_0|iopll_hps_clk
set hssi_clk_p0_grp     gen_mulit_inst[0].hssi_ss_top|u0|intel_eth_gts_0|sip_inst|tx_clkout
set csr_clk_grp         soc_inst|iopll_0|iopll_csr_clk
set iopll_refclk_grp    soc_inst|iopll_0|iopll_refclk

disable_min_pulse_width [get_registers gen_mulit_inst[0].hssi_ss_top|u0|intel_eth_gts_0|hip_inst|n_channel_superset_wrapper_inst|n_channel_superset|hal_top_wrapper_inst|hal_top_ip|one_lane_inst_0|one_lane_hal_top_p0|gen_non_usb_mode.pldif_hal_top_inst|pldif_hal_top|pldif_hal_coreip_inst|gen_sm_ch4_pldif_inst.sm_block.ch4_pldif_inst|x_std_sm_hssi_pld_chnl_dp_0~pldif_lavmm_reg]

set_clock_groups -asynchronous -group [get_clocks $tennm_refclk_grp] -group [get_clocks $hps_clk_grp]
set_clock_groups -asynchronous -group [get_clocks $hps_clk_grp] -group [get_clocks $hssi_clk_p0_grp]
set_clock_groups -asynchronous -group [get_clocks $tennm_refclk_grp] -group [get_clocks $hssi_clk_p0_grp]
set_clock_groups -asynchronous -group [get_clocks $tennm_refclk_grp] -group [get_clocks $csr_clk_grp]
set_clock_groups -asynchronous -group [get_clocks $hssi_clk_p0_grp] -group [get_clocks $csr_clk_grp]
set_clock_groups -asynchronous -group [get_clocks $iopll_refclk_grp] -group [get_clocks $csr_clk_grp]
