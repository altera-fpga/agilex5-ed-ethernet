# Linux Kernel device-tree (Agilex™ 5 Ethernet)

## Same model as Agx7 PTP — no files required here

DTS/DTSI live **in the kernel** branch used by this design:

| | |
|---|---|
| Repo | `applications.fpga.soc.linux-socfpga` |
| Branch | `socfpga-6.12.19-lts-ethernet-sed` |
| Path | `arch/arm64/boot/dts/intel/` |
| Files | `socfpga_agilex5_eth_tse.dts`, `socfpga_agilex5_eth_tse.dtsi` |

`TSE_DESIGN` → DTB name is selected by `meta-custom/conf/tse-solution.inc` (`FPGA_LINUX_DTB_FILE`).

`kas/machine.yml` matches PTP style (base board DTS; custom DTS commented):

```text
LINUX_DTS_FILE = "socfpga_agilex5_socdk.dts"
#CUSTOM_LINUX_DTS_FILE = "socfpga_agilex5_eth_tse.dts"
```

| `TSE_DESIGN` | DTB (from kernel `intel/*.dts`) |
|--------------|----------------------------------|
| `TSE_1P` | `socfpga_agilex5_eth_tse.dtb` |

The kernel recipe **auto-builds** and stages:

```text
build/tmp/deploy/images/agilex5e/socfpga_agilex5_eth_tse.dtb
```

**Do not** manually copy `.dts` or `.dtb` into this folder for the normal flow.

## Optional override

If you need a temporary out-of-tree change, you may place a `.dts` / `.dtsi` here; the recipe will inject it over the in-kernel copy. Prefer fixing the kernel branch instead.
