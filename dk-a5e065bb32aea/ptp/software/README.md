# Intel® Agilex™ 5 Ethernet System Example Design - Software

## Description
The Ethernet System Example Design software helps build the software pieces required to run Linux
on the HPS subsystem. It uses a KAS-driven Yocto flow under `yocto_linux/` and builds:

- Linux kernel (`linux-socfpga-lts`)
- U-Boot (`u-boot-socfpga`)
- Arm Trusted Firmware (ATF)
- Root filesystem and SD card WIC image

Hardware (RTL, Quartus, verification) lives next to this folder — not under `software/`:

| Hardware directory | Role |
|--------------------|------|
| `../src/` | RTL / Qsys sources |
| `../synth/` | Quartus project and Makefile |
| `../verification/` | Testbench / verification |

See [../README.md](../README.md) for the hardware build and programming-file steps.

**Note:** There is **no** `software/artifacts/` directory. FSBL hex and other binaries are produced by Yocto under `yocto_linux/build/tmp/deploy/images/agilex5e/`.

## Directory structure

```bash
ethernet/
├── src/                 # Hardware
├── synth/               # Hardware
├── verification/        # Hardware
└── software/            # Software (this README)
    └── yocto_linux/
        ├── kas.yml
        ├── kas/
        │   ├── machine.yml      # MACHINE = agilex5e
        │   ├── bsp.yml
        │   └── image/
        ├── meta-custom/
        │   └── recipes-fpga/fpga-bitstream/files/   # place .core.rbf here
        ├── build.sh
        ├── kas_build.sh
        └── build/tmp/deploy/images/agilex5e/        # generated after build
```

## Getting Started

### Design selection (`ETH_DESIGN`)

Valid values: `PTP_2P10G` (default). Maps to RBF / DTB / `SOLUTION` via
`yocto_linux/meta-custom/conf/eth-solution.inc`.

Makefile compile targets (HW / SW / both): [../README.md](../README.md).

### Configuring the Board
Please refer to https://altera-fpga.github.io/rel-25.1/embedded-designs/agilex-5/e-series/modular/gsrd/ug-gsrd-agx5e-modular/#booting-from-sd-card for board setup (HPS-first boot and SD card programming).

### Prepare FPGA bitstream (RBF)
1. Build the hardware design (see [../README.md](../README.md)), or use top-level Make which builds HW then SW.
2. Place the core RBF under `yocto_linux/meta-custom/recipes-fpga/fpga-bitstream/files/`.

**Preferred:** top-level Make generates the core RBF and `kas_build.sh` copies it:

```bash
# from dk-a5e065bb32aea/ptp/
make dk-a5e065bb32aea-baseline-ptp10G-all
# Software only:
make dk-a5e065bb32aea-baseline-ptp10G-software-yocto_linux_sd-build-sw
```

**Manual:** use the filename from `ETH_DESIGN` → `FPGA_RBF_FILE` in
`yocto_linux/meta-custom/conf/eth-solution.inc` (default `PTP_2P10G`):

```bash
# From software/yocto_linux/
REVISION=agilex5-dk-a5e065bb32aea_gsrd_ghrd_PTP_2P10G
cp ../../output_files/${REVISION}.core.rbf \
  meta-custom/recipes-fpga/fpga-bitstream/files/${REVISION}.core.rbf
```

Do not hard-code `FPGA_RBF_FILE` in `kas.yml`; `eth-solution.inc` sets it.

### Yocto Build (KAS)

```bash
cd dk-a5e065bb32aea/ptp/software/yocto_linux

python3 -m venv venv --system-site-packages
source venv/bin/activate
pip install --upgrade pip
pip install kas kconfiglib

ETH_DESIGN=PTP_2P10G kas shell kas.yml
bitbake -c build console-image-minimal
```

All required images are written to:

```text
yocto_linux/build/tmp/deploy/images/agilex5e/
```

Key outputs:

| File | Description |
|------|-------------|
| `console-image-minimal-agilex5e.rootfs.wic` | SD card image |
| `u-boot-spl-dtb.hex` | FSBL / U-Boot SPL (hex) — use this with `quartus_pfg` (replaces old `artifacts/u-boot-spl-dtb.hex`) |
| `u-boot.itb` | U-Boot proper |
| `kernel_sed.itb` | Kernel FIT (includes RBF when enabled) |

#### Using FSBL hex with Quartus (no artifacts folder)

After Yocto completes, generate programming files from the hardware `synth/` directory:

```bash
cd ../../synth
quartus_pfg -c -o hps=on \
  -o hps_path=../software/yocto_linux/build/tmp/deploy/images/agilex5e/u-boot-spl-dtb.hex \
  output_files/<design>.sof \
  output_files/<design>.rbf
```

Do **not** use `../../sw/artifacts/u-boot-spl-dtb.hex` — that path no longer exists.

For full KAS options, binaries list, QSPI, and eSDK steps, see [yocto_linux/README.md](yocto_linux/README.md).

### Linux kernel build (optional, outside Yocto)
You can build the Linux kernel alone for debugging. Download the Arm GNU toolchain, then:

```bash
$ export ARCH=arm64
$ export CROSS_COMPILE=`pwd`/arm-gnu-toolchain-11.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
$ git clone https://github.com/altera-fpga/applications.fpga.soc.linux-socfpga.git -b socfpga-6.12.19-lts-ethernet-sed
$ cd applications.fpga.soc.linux-socfpga
$ git checkout <Release Tag>
$ make defconfig
$ make menuconfig
  Enable the configs listed under:
    yocto_linux/meta-custom/recipes-kernel/linux/linux-socfpga-lts/configs/
$ make -j32
```

### Building ATF from source (optional)

```bash
$ git clone https://github.com/altera-fpga/applications.fpga.soc.arm-trusted-firmware-dev.git -b socfpga_v2.14.0
$ cd applications.fpga.soc.arm-trusted-firmware-dev
$ make bl31 CROSS_COMPILE=$CROSS_COMPILE PLAT=agilex5 DEPRECATED=1
```

### Building U-Boot from source (optional)

```bash
$ git clone https://github.com/altera-fpga/u-boot-socfpga.git -b socfpga_v2026.07
$ cd u-boot-socfpga
# copy bl31.bin into the U-Boot tree as required by your flow
$ make socfpga_agilex5_defconfig
$ make -j32
```
