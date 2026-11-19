# ######################################################################## 
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
# ######################################################################## 

$DESIGN_DIR/custom_ip/reset_sync/altera_reset_synchronizer.v
$DESIGN_DIR/custom_ip/altera_eth_mdio/altera_eth_mdio.v

$DESIGN_DIR/custom_rtl/common/axis_if.sv
$DESIGN_DIR/custom_rtl/common/sm_tse_pkg.sv

$DESIGN_DIR/custom_rtl/hssi_subsys/axi_avst_bridges/hssi_axist_to_avst_bridge_wrapper.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/axi_avst_bridges/axist_to_avst_bridge.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/axi_avst_bridges/avst_to_axist_rx_mac_seg_if.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/axi_avst_bridges/axist_to_avst_tx_mac_seg_if.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/axi_avst_bridges/hssi_ss_delay_reg.v
$DESIGN_DIR/custom_rtl/hssi_subsys/axi_avst_bridges/keep2empty.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/axi_avst_bridges/hssi_scfifo.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/srd_rst_ctrl/srd_rst_ctrl.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/srd_rst_ctrl/srd_rst_seq.sv
$DESIGN_DIR/custom_rtl/hssi_subsys/srd_rst_ctrl/eth_f_altera_std_synchronizer_nocut.v

$DESIGN_DIR/custom_rtl/user_space_csr/top_user_space_csr.sv
$DESIGN_DIR/custom_rtl/user_space_csr/user_csr_space.v

$DESIGN_DIR/custom_rtl/components_8chs/components_pkg.sv
$DESIGN_DIR/custom_rtl/components_8chs/tx_dma_fifo.sv
$DESIGN_DIR/custom_rtl/components_8chs/ts_pack.sv
$DESIGN_DIR/custom_rtl/components_8chs/ts_chs_compl.sv
$DESIGN_DIR/custom_rtl/components_8chs/s10_memory.sv
$DESIGN_DIR/custom_rtl/components_8chs/rx_dma_fifo.sv
$DESIGN_DIR/custom_rtl/components_8chs/period_bus_sync.sv
$DESIGN_DIR/custom_rtl/components_8chs/parameter_scfifo.sv
$DESIGN_DIR/custom_rtl/components_8chs/packet_mux_pd_8chs.sv
$DESIGN_DIR/custom_rtl/components_8chs/packet_mux.sv
$DESIGN_DIR/custom_rtl/components_8chs/packet_demux_pd_8chs.sv
$DESIGN_DIR/custom_rtl/components_8chs/packet_demux.sv
$DESIGN_DIR/custom_rtl/components_8chs/dc_fifo_param.sv
$DESIGN_DIR/custom_rtl/components_8chs/clock_bus.sv
$DESIGN_DIR/custom_rtl/components_8chs/cdc_toggle_synchronizer.sv
$DESIGN_DIR/custom_rtl/components_8chs/cdc_synchronizer.sv
$DESIGN_DIR/custom_rtl/components_8chs/cdc_packet_fifo.sv
$DESIGN_DIR/custom_rtl/components_8chs/cdc_avmm_sync_v2.sv


