# Map ETH_DESIGN -> RBF / DTB / SOLUTION
# Usage: ETH_DESIGN=PTP_2P10G kas shell kas.yml -c "bitbake console-image-minimal"
ETH_DESIGN ??= "PTP_2P10G"
python () {
    design = (d.getVar("ETH_DESIGN") or "PTP_2P10G").strip().upper()
    rbf_map = {
        "PTP_2P10G": "agilex5-dk-a5e065bb32aea_gsrd_ghrd_PTP_2P10G.core.rbf",
    }
    dtb_map = {
        "PTP_2P10G": "socfpga_agilex5_ptp_2p10g.dtb",
    }
    sol_map = {
        "PTP_2P10G": "PTP_2P10G",
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
