# Map TSE_DESIGN -> RBF / DTB / SOLUTION
# Usage: TSE_DESIGN=TSE_1P kas shell kas.yml -c "bitbake console-image-minimal"
# FPGA_RBF_FILE must match the first REVISION_NAMES entry in ../../project_config.mk
# because kas_build.sh stages the core RBF as ${REVISION_NAME}.core.rbf.
TSE_DESIGN ??= "TSE_1P"
python () {
    design = (d.getVar("TSE_DESIGN") or "TSE_1P").strip().upper()
    rbf_map = {
        "TSE_1P": "agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P.core.rbf",
    }
    dtb_map = {
        "TSE_1P": "socfpga_agilex5_eth_tse.dtb",
    }
    sol_map = {
        "TSE_1P": "TSE_1P",
    }
    if design not in rbf_map:
        bb.fatal("Unsupported TSE_DESIGN='%s'. Valid: %s" %
                 (design, " ".join(sorted(rbf_map))))
    rbf = rbf_map[design]
    dtb = dtb_map[design]
    sol = sol_map[design]
    d.setVar("TSE_DESIGN", design)
    d.setVar("FPGA_RBF_FILE", rbf)
    d.setVar("FPGA_LINUX_DTB_FILE", dtb)
    d.setVar("SOLUTION", sol)
    # Do NOT set CUSTOM_LINUX_DEVICE_TREE here; kas.yml keeps it as "1"
}
