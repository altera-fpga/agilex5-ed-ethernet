#****************************************************************************
#
# SPDX-License-Identifier: MIT-0
# Copyright(c) 2019-2021 Intel Corporation.
#
#****************************************************************************

#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
derive_clock_uncertainty

#create_clock -name {altera_reserved_tck}  -period 100.000 [get_ports {altera_reserved_tck}]
create_clock -name {clk_hvio} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk_hvio_6a_100m}]
set  clk_hvio_g clk_hvio

#**************************************************************
# Create Generated Clock
#**************************************************************
#create_generated_clock -add -name    {soc_inst|intel_eth_tse_0|intel_eth_tse_0|i_tse_mac|U_MDIO|U_CLKGEN|mdio_clk} \
#                       -source       {soc_inst|iopll_0|iopll|tennm_ph2_iopll|out_clk[1]} \
#                       -divide_by 50 {soc_inst|intel_eth_tse_0|intel_eth_tse_0|i_tse_mac|U_MDIO|U_CLKGEN|mdio_clk}

#**************************************************************
# Set Clock Groups
#**************************************************************
#set_clock_groups -asynchronous -group {altera_reserved_tck}
set_clock_groups -asynchronous -group {soc_inst|iopll_0|iopll|tennm_ph2_iopll|ref_clk0}
set_clock_groups -asynchronous -group {soc_inst|iopll_0|*} -group {soc_inst|intel_eth_tse_*|intel_eth_tse_*|i_nd_native_phyip_0|sip_inst|o_*x_clkout*}
set_clock_groups -asynchronous -group {soc_inst|iopll_0|*} -group {hps_internal_osc}
#set_clock_groups -asynchronous -group {soc_inst|iopll_0|*} -group {internal_clk}
set_clock_groups -asynchronous -group {soc_inst|iopll_0|*} -group {internal_clk (INVERTED)}

#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_ports {fpga_reset_n}]

#set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma_*|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
#set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma_*|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]

#set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_125M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma_*|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
#set_false_path -from [get_keepers -no_duplicates {sync_iopll_lock_125M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma_*|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]

set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[*].eth_user_rx_rstn_sync_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma_*|rx_dma_fifo_0|rx_dma_fifo_0|cdc_packet_fifo|translate_read_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]
set_false_path -from [get_keepers -no_duplicates {inst_srd_rst_ctrl|eth_reset_sync[*].eth_user_tx_rstn_sync_100M|dreg[1]}] -to [get_keepers -no_duplicates {soc_inst|subsys_msgdma_*|tx_dma_fifo_0|tx_dma_fifo_0|cdc_packet_fifo|translate_write_pointer|toggle_in|inst_cdc_sync_for_rst|in_data_meta[0]}]

set_false_path -from [get_ports {phy_mdio}] -to *
set_false_path -from * -to [get_ports {phy_mdio}]
set_false_path -from * -to [get_ports {phy_mdc}]
set_false_path -from [get_ports {eth_mdio}] -to *
set_false_path -from * -to [get_ports {eth_mdio}]
set_false_path -from * -to [get_ports {eth_mdc}]

set_input_delay   -source_latency_included 1 -clock $clk_hvio_g  [get_ports phy_mdio]
set_output_delay  -source_latency_included 1 -clock $clk_hvio_g  [get_ports phy_mdio]
set_output_delay  -source_latency_included 1 -clock $clk_hvio_g  [get_ports phy_mdc]
set_input_delay   -source_latency_included 1 -clock $clk_hvio_g  [get_ports eth_mdio]
set_output_delay  -source_latency_included 1 -clock $clk_hvio_g  [get_ports eth_mdio]
set_output_delay  -source_latency_included 1 -clock $clk_hvio_g  [get_ports eth_mdc]

