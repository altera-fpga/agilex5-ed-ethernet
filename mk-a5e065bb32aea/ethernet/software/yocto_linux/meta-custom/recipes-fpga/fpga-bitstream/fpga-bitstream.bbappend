SUMMARY = "Altera SoCFPGA Bitstream"
DESCRIPTION = "Custom FPGA bitstream for SOC Development Kit"
SECTION = "bsp"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Bridge SED kas.yml flag to the base recipe variable used by SRC_URI / tasks
FPGA_CORE_PGM_ENABLE = "${FPGA_ENABLE_CORE_PGM}"

python () {
    if not d.getVar('FPGA_ENABLE_CORE_PGM'):
        raise bb.parse.SkipRecipe("FPGA Enable Core Programming option is not set!")
    if not d.getVar('FPGA_RBF_FILE'):
        raise bb.parse.SkipRecipe("FPGA_RBF_FILE is not set (check *-solution.inc)")
}

# Override meta-altera-fpga's hardcoded top.core.rbf deploy/install name.
# Deploy as ${FPGA_RBF_FILE}; keep top.core.rbf as a symlink so the FIT
# generation in meta-altera-fpga (linux-socfpga-lts) still finds it.
do_install () {
	install -D -m 0644 ${UNPACKDIR}/${FPGA_RBF_FILE} ${D}/boot/${FPGA_RBF_FILE}
	ln -sfn ${FPGA_RBF_FILE} ${D}/boot/top.core.rbf
}

do_deploy () {
	install -D -m 0644 ${UNPACKDIR}/${FPGA_RBF_FILE} ${DEPLOYDIR}/${FPGA_RBF_FILE}
	ln -sfn ${FPGA_RBF_FILE} ${DEPLOYDIR}/top.core.rbf
}
