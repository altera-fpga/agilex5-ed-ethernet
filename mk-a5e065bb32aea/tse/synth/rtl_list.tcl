# ######################################################################## 
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
# ######################################################################## 

set_global_assignment -name VERILOG_FILE       ../src/custom_ip/reset_sync/altera_reset_synchronizer.v

set_global_assignment -name VERILOG_FILE       ../src/custom_ip/altera_eth_mdio/altera_eth_mdio.v

set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/common/axis_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/common/sm_tse_pkg.sv

set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/axi_avst_bridges/hssi_axist_to_avst_bridge_wrapper.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/axi_avst_bridges/axist_to_avst_bridge.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/axi_avst_bridges/avst_to_axist_rx_mac_seg_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/axi_avst_bridges/axist_to_avst_tx_mac_seg_if.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/axi_avst_bridges/hssi_ss_delay_reg.v
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/axi_avst_bridges/keep2empty.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/axi_avst_bridges/hssi_scfifo.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/srd_rst_ctrl/srd_rst_ctrl.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/srd_rst_ctrl/srd_rst_seq.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/hssi_subsys/srd_rst_ctrl/eth_f_altera_std_synchronizer_nocut.v

set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/user_space_csr/top_user_space_csr.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/user_space_csr/user_csr_space.v


set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/components_pkg.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/tx_dma_fifo.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/ts_pack.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/ts_chs_compl.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/s10_memory.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/rx_dma_fifo.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/period_bus_sync.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/parameter_scfifo.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/packet_mux_pd_8chs.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/packet_mux.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/packet_demux_pd_8chs.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/packet_demux.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/dc_fifo_param.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/clock_bus.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/cdc_toggle_synchronizer.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/cdc_synchronizer.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/cdc_packet_fifo.sv
set_global_assignment -name SYSTEMVERILOG_FILE ../src/custom_rtl/components_8chs/cdc_avmm_sync_v2.sv



set_global_assignment -name SYSTEMVERILOG_FILE ../src/top.sv
