# Linux Kernel device-tree (Agilex™ 5 Ethernet)

## Same model as Agx7 PTP — no files required here

DTS/DTSI live **in the kernel** branch used by this design:

| | |
|---|---|
| Repo | `altera-fpga/linux-socfpga` |
| Branch | `socfpga-6.18.37-lts-ethernet-sed` |
| Path | `arch/arm64/boot/dts/intel/` |
| Files | `socfpga_agilex5_ptp_2p25g.dts`, `socfpga_agilex5_ptp_2p25g.dtsi` |

`ETH_DESIGN` → DTB name is selected by `meta-custom/conf/eth-solution.inc` (`FPGA_LINUX_DTB_FILE`).

`kas/machine.yml` matches PTP style (base board DTS; custom DTS commented):

```text
LINUX_DTS_FILE = "socfpga_agilex5_socdk.dts"
#CUSTOM_LINUX_DTS_FILE = "socfpga_agilex5_ptp_2p25g.dts"
```

| `ETH_DESIGN` | DTB (from kernel `intel/*.dts`) |
|--------------|----------------------------------|
| `PTP_2P25G` | `socfpga_agilex5_ptp_2p25g.dtb` |

The kernel recipe **auto-builds** and stages:

```text
build/tmp/deploy/images/agilex5e/socfpga_agilex5_ptp_2p25g.dtb
```

**Do not** manually copy `.dts` or `.dtb` into this folder for the normal flow.

## Optional override

If you need a temporary out-of-tree change, you may place a `.dts` / `.dtsi` here; the recipe will inject it over the in-kernel copy. Prefer fixing the kernel branch instead.
