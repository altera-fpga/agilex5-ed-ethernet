do_configure:prepend() {
        # ponytail: MK/Modular (agilex5_mk_a5e065bb32aes1) is B0 silicon; the kernel renamed its
        # dts to socfpga_agilex5_socdk_b0.dts (not the unsuffixed one, which is a different, non-B0
        # variant with different mem/mmc/spi settings). refdes's device-tree.bb still copies from
        # the old socfpga_agilex5_socdk_a0.dts name and fails do_configure. Stage it under the old
        # name pointing at the real B0 file so upstream's cp succeeds. Drop once refdes is fixed upstream.
        if [[ "${MACHINE}" == "agilex5_mk_a5e065bb32aes1" && ! -e "${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_socdk_a0.dts" ]]; then
                ln -sf socfpga_agilex5_socdk_b0.dts ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_socdk_a0.dts
        fi
}

do_configure:append() {
        if [[ "${MACHINE}" == *"agilex5"* ]]; then
                # DTB Generation
                cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_eth_1p10g.dts ${WORKDIR}/socfpga_agilex5_eth_1p10g.dts
                cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_eth_1p10g.dtsi ${WORKDIR}/socfpga_agilex5_eth_1p10g.dtsi
                cp ${STAGING_KERNEL_DIR}/arch/${ARCH}/boot/dts/intel/socfpga_agilex5_socdk.dts ${WORKDIR}/socfpga_agilex5_socdk.dts

		# Removing the LED and PIO changes that GHRD adds to socfpga_agilex5_socdk_modular.dts
		sed -i '/#include "socfpga_agilex5_ghrd.dtsi"/d' ${WORKDIR}/socfpga_agilex5_socdk_modular.dts
        fi

}

