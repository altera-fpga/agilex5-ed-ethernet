# Map ETH_DESIGN -> RBF / DTB / SOLUTION
# Usage: ETH_DESIGN=ETH_1P25G kas shell kas.yml -c "bitbake console-image-minimal"
ETH_DESIGN ??= "ETH_1P25G"
python () {
    design = (d.getVar("ETH_DESIGN") or "ETH_1P25G").strip().upper()
    rbf_map = {
        "ETH_1P25G": "agilex5-mk-a5e065ab32aea_gsrd_ghrd_ETH_1P25G.core.rbf",
    }
    dtb_map = {
        "ETH_1P25G": "socfpga_agilex5_eth_1p25g.dtb",
    }
    sol_map = {
        "ETH_1P25G": "ETH_1P25G",
    }
    if design not in rbf_map:
        bb.fatal("Unsupported ETH_DESIGN='%s'. Valid: %s" %
                 (design, " ".join(sorted(rbf_map))))
    rbf = rbf_map[design]
    dtb = dtb_map[design]
    sol = sol_map[design]
    d.setVar("ETH_DESIGN", design)
    d.setVar("FPGA_RBF_FILE", rbf)
    d.setVar("FPGA_LINUX_DTB_FILE", dtb)
    d.setVar("SOLUTION", sol)
    # Do NOT set CUSTOM_LINUX_DEVICE_TREE here; kas.yml keeps it as "1"
}
