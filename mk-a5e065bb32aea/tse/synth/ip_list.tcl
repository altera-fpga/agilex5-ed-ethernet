set_global_assignment -name IP_FILE ../src/ip/qsys_top/qsys_top_intel_eth_tse_0.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/qsys_top_intel_eth_tse_1.ip

set_global_assignment -name IP_FILE ../src/ip/hps_subsys/agilex_hps.ip
set_global_assignment -name IP_FILE ../src/ip/hps_subsys/hps_subsys_f2sdram_adapter_0.ip
set_global_assignment -name IP_FILE ../src/ip/hps_subsys/emif_io96b_hps.ip

set_global_assignment -name IP_FILE ../src/ip/gts/gts_reset_sequencer_0.ip
set_global_assignment -name IP_FILE ../src/ip/gts/gts_reset_sequencer.ip
set_global_assignment -name IP_FILE ../src/ip/gts/gts_systempll.ip

set_global_assignment -name IP_FILE ../src/ip/csr_bridges/csr_bridges_reset_in.ip
set_global_assignment -name IP_FILE ../src/ip/csr_bridges/user_space_csr.ip
set_global_assignment -name IP_FILE ../src/ip/csr_bridges/csr_bridges_clock_in.ip

set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/axi4lite_rst_bdg.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/host_clk_bdg.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/host_rstn.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/hssi_ets_ts_adapter_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_prefetcher_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_dispatcher_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_read_master_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_prefetcher_1.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_dispatcher_1.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_write_master_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_ts_chs_compl_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/tx_dma_fifo_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/tx_dma_csr.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/avst_axist_bridge_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/rx_dma_fifo_0.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/hssi_rst_rx.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/subsys_msgdma_avst_axist_bridge_1.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/axi4lite_clk_bdg.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/rst_user_bdg.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/fifo_user_rst_rx.ip
set_global_assignment -name IP_FILE ../src/ip/subsys_msgdma/fifo_clk_bdg.ip


set_global_assignment -name IP_FILE ../src/ip/qsys_top/clk_100.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/rst_in.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/user_rst_clkgate_0.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/iopll.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/rst_bdg_100.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/clk_bdg_100.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/qsys_top_mm_ccb_0.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/clk_bdg_125.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/rst_bdg_125.ip
set_global_assignment -name IP_FILE ../src/ip/qsys_top/clk_156.ip

set_global_assignment -name QSYS_FILE ../src/qsys/reset_req.qsys
set_global_assignment -name QSYS_FILE ../src/qsys/hps_subsys.qsys
set_global_assignment -name QSYS_FILE ../src/qsys/subsys_msgdma.qsys
set_global_assignment -name QSYS_FILE ../src/qsys/csr_bridges.qsys
set_global_assignment -name QSYS_FILE ../src/qsys/qsys_top_0.qsys
set_global_assignment -name QSYS_FILE ../src/qsys/qsys_top.qsys