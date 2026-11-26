# meta-custom

This BitBake layer contains design-specific metadata for this Ethernet System Example Design:
device trees, kernel/U-Boot customizations, FPGA bitstream integration, and application recipes.

Hardware for this design lives under `mk-a5e065bb32aea/ethernet/` (`src/`, `synth/`, `verification/`).
This layer is the Yocto customization side under `software/yocto_linux/meta-custom/`.

## Layer layout

```text
meta-custom/
├── conf/
│   ├── layer.conf
│   └── eth-solution.inc             # ETH_DESIGN → RBF / DTB / SOLUTION
├── classes/
├── recipes-bsp/u-boot/              # U-Boot env / appends
├── recipes-connectivity/linuxptp/   # linuxptp customizations
├── recipes-devtools/
│   ├── packetgenerator/
│   └── packetswitch/
├── recipes-files/
│   ├── rootfs-files/
│   ├── test-suite-agilex5/
│   └── uboot-test-suite-agilex5/
├── recipes-fpga/fpga-bitstream/     # core.rbf integration
└── recipes-kernel/linux/
    ├── device-tree/                 # optional DTS override (README only by default)
    └── linux-socfpga-lts/           # config fragments / patches
```

## U-Boot
U-Boot customizations for this design are under `recipes-bsp/u-boot/`
(for example `u-boot-socfpga-env-var.bbappend`).

There is no separate `recipes-bsp/u-boot/README.md` in this tree. Machine/boot settings are
also driven from `kas/machine.yml` and `kas.yml` (see the parent [../README.md](../README.md)).

## Linux Kernel
For detailed instructions and customization guidance, refer to:
`recipes-kernel/linux/README.md`

- Device Tree — in-kernel DTS selected by `ETH_DESIGN` / `eth-solution.inc`
  (see `recipes-kernel/linux/device-tree/README.md`; no local `.dts` required)
- Configuration fragments — under `recipes-kernel/linux/linux-socfpga-lts/configs/`
  (for example `config_eth.cfg`, `config_mcq.cfg`)
- Source patching — under `recipes-kernel/linux/linux-socfpga-lts/patches/`

## FPGA Bitstream
For details on FPGA bitstream handling, refer to:
`recipes-fpga/fpga-bitstream/README.md`

- Place the design `.core.rbf` under `recipes-fpga/fpga-bitstream/files/`
- Filename comes from `ETH_DESIGN` → `FPGA_RBF_FILE` in `conf/eth-solution.inc`
  (default `ETH_1P10G` → `agilex5-mk-a5e065bb32aea_gsrd_ghrd_ETH_1P10G.core.rbf`)
- Top-level Make / `kas_build.sh` copies the HW-generated core RBF there automatically

## Other recipes in this layer
- **recipes-devtools** — `packetgenerator`, `packetswitch`
- **recipes-connectivity** — `linuxptp` config/patches
- **recipes-files** — rootfs helper scripts and test suites
  (see `recipes-files/rootfs-files/README.md`)
