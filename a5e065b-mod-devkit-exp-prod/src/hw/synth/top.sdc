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

set_false_path -from [get_keepers -no_duplicates {soc_inst|iopll_0|iopll|tennm_ph2_iopll~pll_ctrl_reg}] -to [get_keepers -no_duplicates {sync_iopll_lock_161_0|dreg[0]}]
set_false_path -from [get_keepers -no_duplicates {gen_mulit_inst[0].hssi_ss_top|u0|intel_eth_gts_0|hip_inst|n_channel_superset_wrapper_inst|n_channel_superset|hal_top_wrapper_inst|hal_top_ip|one_lane_inst_0|one_lane_hal_top_p0|gen_non_usb_mode.pldif_hal_top_inst|pldif_hal_top|pldif_hal_coreip_inst|gen_sm_ch4_pldif_inst.sm_block.ch4_pldif_inst|x_std_sm_hssi_pld_chnl_dp_0~pldif_reset_reg}] -to [get_keepers -no_duplicates {sts_tx_pll_locked[0].tx_pll_locked|dreg[0]}]
set_false_path -from [get_keepers -no_duplicates {gen_mulit_inst[0].hssi_ss_top|u0|intel_eth_gts_0|hip_inst|n_channel_superset_wrapper_inst|n_channel_superset|hal_top_wrapper_inst|hal_top_ip|one_lane_inst_0|one_lane_hal_top_p0|gen_non_usb_mode.pldif_hal_top_inst|pldif_hal_top|pldif_hal_coreip_inst|gen_sm_ch4_pldif_inst.sm_block.ch4_pldif_inst|x_std_sm_hssi_pld_chnl_dp_0~pldif_reset_reg}] -to [get_keepers -no_duplicates {sts_tx_pll_locked[0].tx_pll_locked|dreg[1]}]
set_false_path -from [get_keepers -no_duplicates {gen_mulit_inst[0].hssi_ss_top|u0|intel_eth_gts_0|sip_inst|o_rx_pcs_ready}] -to [get_keepers -no_duplicates {sts_rx_pcs_ready[0].rx_pcs_ready|dreg[*]}]
set_false_path -from [get_keepers -no_duplicates {gen_mulit_inst[0].hssi_ss_top|u0|intel_eth_gts_0|sip_inst|o_tx_lanes_stable}] -to [get_keepers -no_duplicates {sts_tx_lanes_stable[0].tx_lanes_stable|dreg[*]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|iopll_0|iopll|tennm_ph2_iopll~pll_ctrl_reg}] -to [get_keepers -no_duplicates {sync_iopll_lock_161_0|dreg[1]}]   
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|reg_in[*]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|sync|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|reg_in[*]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|sync|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|toggled_signal}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|toggled_signal}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|reg_in[*]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|sync|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|reg_in[*]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|sync|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|to_cntr[*]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|*}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|toggled_signal}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|toggled_signal}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|ts_fifo_rst}]
set_false_path -from [get_keepers -no_duplicates {soc_inst|iopll_0|iopll|tennm_ph2_iopll~pll_ctrl_reg}] -to [get_keepers -no_duplicates {sync_iopll_lock_125M|dreg[*]}]
set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[0].eth_user_rx_rstn_sync_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[0].eth_user_tx_rstn_sync_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[0].eth_user_rx_rstn_sync_161M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[0].eth_user_tx_rstn_sync_161M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_161_0|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_161_0|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|ts_chs_compl_0|ts_chs_compl_0|ts_ch_resp[0].ts_fifo|dcfifo_component|auto_generated|wraclr|dffe7a[0]}] 
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[0].eth_user_tx_rstn_sync_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|ts_chs_compl_0|ts_chs_compl_0|ts_ch_resp[0].ts_fifo|dcfifo_component|auto_generated|wraclr|dffe7a[0]}]
set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|ts_chs_compl_0|ts_chs_compl_0|ts_ch_resp[0].ts_fifo|dcfifo_component|auto_generated|wraclr|dffe8a[0]}] 
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[0].eth_user_tx_rstn_sync_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|ts_chs_compl_0|ts_chs_compl_0|ts_ch_resp[0].ts_fifo|dcfifo_component|auto_generated|wraclr|dffe8a[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|o_user_rx_rst_n_161_*d[*]*}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0*|rx_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|o_user_rx_rst_n_100_*d[*]*}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|rx_dma_fifo_0*|rx_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|o_user_tx_rst_n_161_*d[*]*}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0*|tx_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|o_user_tx_rst_n_100_*d[*]*}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0*|tx_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[*]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|o_user_tx_rst_n_100_*d[*]*}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|ts_chs_compl_0|ts_chs_compl_0|ts_ch_resp[*].ts_fifo|dcfifo_component|auto_generated|wraclr|*}]
set_false_path -from [get_keepers -no_duplicates {rd1|cntr[*]}] -to [get_keepers -no_duplicates {sync_ninit_done|*}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|o_user_rx_rst_n_161_sig[*]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|*x_dma_fifo_0*|*x_dma_fifo_0|cdc_packet_fifo|translate_*_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|o_user_tx_rst_n_161_sig[*]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]

