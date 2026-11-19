# Linux Kernel - linux-socfpga-lts

## Device tree
Refer and follow the steps in:

```text
meta-custom/recipes-kernel/linux/device-tree/README.md
```

DTS lives in the kernel tree (`socfpga_agilex5_ptp_2p10g.dts`); selection is via
`ETH_DESIGN` / `eth-solution.inc`. No local copy under `device-tree/` is required.

> **Note:** Older docs pointed at `meta-custom/recipes-bsp/device-tree/README.md`. That path does **not** exist in this tree.

## Configuration fragments
Follow the below steps to create and add configuration fragments for Linux Kernel.

### Set bitbake build environment
```bash
$ kas shell kas.yml
```

### Create Linux Kernel configuration fragment
- Launch Linux configuration menu and edit configurations and Save & Exit.
```bash
$ bitbake -c menuconfig linux-socfpga-lts
```
- Generate kernel configuration fragment file.
```bash
$ bitbake -c diffconfig linux-socfpga-lts
# Note - This command generates the fragment.cfg file.
```

### Add configuration fragment for linux-socfpga-lts Kernel
- Copy `fragment.cfg` to `linux-socfpga-lts/configs/`
- Create `fragment.scc` at the same location with a line such as:
  `kconf non-hardware fragment.cfg`
  (kconf option depends on the fragment contents; see Yocto documentation.)
- Append to `SRC_URI` in `linux-socfpga-lts_%.bbappend`:
```bitbake
file://fragment.scc
```

This design already includes Ethernet-related fragments under `linux-socfpga-lts/configs/`:
- `config_eth.cfg` / `config-eth.scc`
- `config_mcq.cfg` / `config-mcq.scc`

### Build Linux kernel
```bash
$ bitbake -c clean linux-socfpga-lts
$ bitbake -c build linux-socfpga-lts
```

## Linux Kernel patching
Follow below steps to create the patch & build Linux Kernel.

### Clone Linux Kernel repo
For this design, the bbappend uses the innersource ethernet SED branch (see `linux-socfpga-lts_%.bbappend`). Example:

```bash
$ git clone https://github.com/altera-innersource/applications.fpga.soc.linux-socfpga.git
$ cd applications.fpga.soc.linux-socfpga
$ git checkout socfpga-6.12.19-lts-ethernet-sed
```

Do your source code changes.

### Generate the source patch
```bash
$ git add <changed files>
$ git commit -m "Add my custom feature"  # include Upstream-Status: per Yocto docs
$ git format-patch -1 HEAD
# generates e.g. 0001-Add-my-custom-feature.patch
```

### Add source patch for linux-socfpga-lts Kernel
- Copy the patch to `linux-socfpga-lts/patches/`
- Append to `SRC_URI` in `linux-socfpga-lts_%.bbappend`:
```bitbake
file://0001-Add-my-custom-feature.patch
```

### Build Linux kernel
```bash
$ kas shell kas.yml
$ bitbake -c clean linux-socfpga-lts
$ bitbake -c build linux-socfpga-lts
```

## List of Linux binaries
With `MACHINE=agilex5e`:

```text
build/tmp/deploy/images/agilex5e/Image
build/tmp/deploy/images/agilex5e/kernel_sed.itb
build/tmp/deploy/images/agilex5e/socfpga_agilex5_ptp_2p10g.dtb

build/tmp/work/agilex5e-poky-linux/linux-socfpga-lts/<Linux version>/deploy-linux-socfpga-lts/Image
build/tmp/work/agilex5e-poky-linux/linux-socfpga-lts/<Linux version>/deploy-linux-socfpga-lts/kernel_sed.itb
```
