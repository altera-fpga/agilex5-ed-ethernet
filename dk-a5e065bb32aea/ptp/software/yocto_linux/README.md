# Overview of yocto_linux

Yocto / KAS BSP for the Agilex™ 5 Ethernet SED (`MACHINE=agilex5e`).
Select the design with **`ETH_DESIGN`** (see `meta-custom/conf/eth-solution.inc`; default `PTP_2P10G`).
Hardware compile (`src` / `synth` / `verification`): [../../README.md](../../README.md).

The base layer is `meta-altera-fpga` / `meta-altera-bsp`. Configure and build with KAS and BitBake.

This `yocto_linux/` tree is the **software** BSP. Hardware for this Ethernet design lives
alongside it under `dk-a5e065bb32aea/ptp/`:

| Path | Role |
|------|------|
| `../../src/` | Hardware — RTL / Qsys |
| `../../synth/` | Hardware — Quartus project / Makefile |
| `../../verification/` | Hardware — verification |
| `../` (`software/`) | Software parent |
| `.` (`yocto_linux/`) | KAS / Yocto (this README) |

See [README.md](../../README.md) for hardware build and programming-file steps, and
[README.md](../README.md) for the software overview.

Following is the top level view of the yocto_linux framework.

```
.
├── kas
│   ├── bsp.yml
│   ├── gsrd
│   │   └── Kconfig
│   ├── image
│   │   ├── all-image-targets.yaml
│   │   ├── console-image-minimal.yaml
│   │   ├── core-image-minimal.yaml
│   │   ├── gsrd-console-image.yaml
│   │   └── Kconfig
│   └── machine.yml
├── kas.yml
├── Kconfig
├── meta-custom
│   ├── classes
│   ├── conf
│   │   ├── layer.conf
│   │   ├── eth-solution.inc
│   │   └── machine
│   ├── LICENSE
│   ├── README.md
│   ├── recipes-bsp
│   │   └── u-boot
│   ├── recipes-connectivity
│   │   └── linuxptp
│   ├── recipes-devtools
│   │   ├── packetgenerator
│   │   └── packetswitch
│   ├── recipes-files
│   │   ├── rootfs-files
│   │   ├── test-suite-agilex5
│   │   └── uboot-test-suite-agilex5
│   ├── recipes-fpga
│   │   └── fpga-bitstream
│   └── recipes-kernel
│       └── linux
│           ├── device-tree
│           └── linux-socfpga-lts
├── scripts
├── build.sh
├── kas_build.sh
├── clean_build.sh
└── README.md

```

## KAS
- **Kconfig**  
Contains configuration definitions for KAS menu options to configure the Yocto.
- **kas.yml**  
kas.yaml is the configuration file used by KAS and contains the info of repos to be cloned, machine and other Yocto related configurations.

- **kas/image**  
The image directory contains yaml configurations for core-image-minimal, console-image-minimal and gsrd-console-image targets.

    - **core-image-minimal**  
        In the Yocto core-image-minimal is the most basic reference image recipes provided by the Poky
        distribution. It’s essentially a minimal root filesystem which is just enough to boot the system and
        provide a command-line interface.
    - **console-image-minimal**  
        In addition to core-image-base, console-image-minimal enables following packages,
        - Common essentials
        - Network essentials
        - Openssh
        - NFS
        - lighttpd
        - udev
        - systemd
        - mtd-utils

    - **gsrd-console-image**  
        In addition to core-image-base, gsrd-console-image enables following packages,
        - Common essentials
        - dev-tools essentials
        - Network essentials
        - web-server essentials
        - nfs-utils-client
        - Openssh
        - FIO
        - perl
        - NFS
        - lighttpd
        - udev
        - systemd
        - mtd-utils

## meta-custom layer
- **conf**  
Contains layer configuration.
- **recipes-bsp**  
Contains _u-boot_ recipe for boot loader.
    - _u-boot_ recipe allows integration of custom device tree source to enable the hardware-specific modifications. Also, allows integration of custom U-Boot environment variables.
- **recipes-connectivity**  
Contains _linuxptp_ customizations for this design.
- **recipes-devtools**  
Contains _packetgenerator_ and _packetswitch_ application recipes.
- **recipes-files**  
Contains recipes for adding custom files and test suites to the root filesystem.
- **recipes-fpga**  
Contains the _fpga-bitstream_ recipe to include RBF file.
- **recipes-kernel**  
Contains _linux_ recipe to create Kernel Image with custom configurations.
    - _device-tree_ — optional out-of-tree DTS override only; Ethernet DTS is in-kernel (see device-tree README).
    - _linux-socfpga-lts_ contains kernel configuration fragments and patches.
Refer following links to understand more on BSP customization (Top level ```meta-custom/README.md``` provides introduction to each section).

- U-Boot — `meta-custom/recipes-bsp/u-boot/` (no separate README; see `kas/machine.yml`)
- Linux Kernel
	```meta-custom/recipes-kernel/linux/README.md```
- Linux Device Tree
	```meta-custom/recipes-kernel/linux/device-tree/README.md```
- FPGA Bitstream
	```meta-custom/recipes-fpga/fpga-bitstream/README.md```

## scripts
Contains helper scripts and configuration files for generating QSPI JIC images from Yocto build outputs.
Refer to ```scripts/README.md``` for detailed instructions on creating bootable images for QSPI flash.

# Yocto Build

## Prepare FPGA Bitstream (RBF)

`ETH_DESIGN` (default `PTP_2P10G`) selects the RBF name via
`meta-custom/conf/eth-solution.inc` → `FPGA_RBF_FILE`. Do **not** hard-code
`FPGA_RBF_FILE` in `kas.yml`.

| `ETH_DESIGN` | Filename under `fpga-bitstream/files/` |
|--------------|----------------------------------------|
| `PTP_2P10G` | `agilex5-dk-a5e065bb32aea_gsrd_ghrd_PTP_2P10G.core.rbf` |

**Preferred (top-level Make):** HW + SW together — Make creates the core RBF and
`kas_build.sh` copies it to `fpga-bitstream/files/<REVISION>.core.rbf`
(`REVISION` from `project_config.mk`; must match `FPGA_RBF_FILE` above):

```bash
# from dk-a5e065bb32aea/ptp/
make dk-a5e065bb32aea-baseline-ptp10G-all
```

**Manual copy** (if building Yocto without that Make target):

```bash
# From software/yocto_linux/
REVISION=agilex5-dk-a5e065bb32aea_gsrd_ghrd_PTP_2P10G
cp ../../output_files/${REVISION}.core.rbf \
  meta-custom/recipes-fpga/fpga-bitstream/files/${REVISION}.core.rbf
```

DTB is built from the in-kernel DTS (`socfpga_agilex5_ptp_2p10g.dts` on
`KBRANCH`); see `meta-custom/recipes-kernel/linux/device-tree/README.md`.

## Build environment

**Prerequisites**
- Ubuntu 22.04 LTS or later is recommended for Yocto builds
- The system shell must use bash instead of dash. On Ubuntu 22.04, run:
  ```bash
  sudo ln -sf /bin/bash /bin/sh
  ```

Install the following host packages and tools required for yocto build.

**Host packages**
```bash
# apt install build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit python3-newt socat texinfo unzip wget xz-utils zstd
```
Reference: [Yocto project](https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages)

**KAS tool**
```bash
$ python3 -m venv venv --system-site-packages
$ source venv/bin/activate
$ pip install --upgrade pip
$ pip install kas
$ pip install kconfiglib
```
Reference: [KAS](https://kas.readthedocs.io/en/latest/userguide/getting-started.html#dependencies-installation)

## How to build

### Ethernet design selection (`ETH_DESIGN`)

Valid values: `PTP_2P10G`  
Default: `PTP_2P10G`

| Value | Behavior |
|-------|----------|
| `PTP_2P10G` | One FIT (`kernel_sed.itb`) for the 2-port 10G PTP (IEEE 1588) design |

### From design root (`ptp/`) — top-level make

```bash
cd ../..   # ptp/
make dk-a5e065bb32aea-baseline-ptp10G-all
# Hardware only:
make dk-a5e065bb32aea-baseline-ptp10G-build
# Software only (needs SOF / core RBF from HW):
make dk-a5e065bb32aea-baseline-ptp10G-software-yocto_linux_sd-build-sw
```

### Recommended — `build.sh`

Make supplies the core RBF path. Manual equivalent from `yocto_linux/`:

```bash
./build.sh ../../output_files/agilex5-dk-a5e065bb32aea_gsrd_ghrd_PTP_2P10G.core.rbf sd
# Usage: ./build.sh <RBF_FILE> <BOOT_SOURCE>
# BOOT_SOURCE: sd | qspi | emmc | nand
```

### From command line — `kas shell`

```bash
ETH_DESIGN=PTP_2P10G kas shell kas.yml -c "bitbake console-image-minimal"
```

Or:

```bash
export ETH_DESIGN=PTP_2P10G
kas shell kas.yml
bitbake console-image-minimal
```

### Using Yocto GUI (`kas menu`)

```bash
export ETH_DESIGN=PTP_2P10G   # optional; default is PTP_2P10G
kas menu
# configure options, then Build — or Save & Exit and:
kas shell .config.yaml
bitbake console-image-minimal
```

### Binaries
After the build, the generated binaries can be found in:

```text
build/tmp/deploy/images/agilex5e/
```

(`MACHINE` is set to `agilex5e` in `kas/machine.yml`.)

There is **no** checked-in `artifacts/` folder under `software/`. Use the deploy directory above
(for example `u-boot-spl-dtb.hex` for FSBL insertion with `quartus_pfg`).

**List of Binaries**
|Binaries								        |Description                                                            |
|-----------------------------------------------|-----------------------------------------------------------------------|
|uboot.env										|U-Boot environment file.                                               |
|boot.scr.uimg  								|Boot script.                                                           |
|u-boot-spl-dtb.bin								|U-Boot FSBL image in binary format.                                    |
|u-boot-spl-dtb.hex								|U-Boot FSBL image in hex format (replaces old `sw/artifacts/*.hex`).   |
|u-boot.itb										|U-Boot proper + device tree blob.                                      |
|bl31.bin                                       |Arm Trusted Firmware                                                   |
|Image											|Linux Kernel image.                                                    |
|kernel_sed.itb									|Linux kernel FIT (Image + DTB + RBF, if RBF programming is enabled).   |
|socfpga_agilex5_ptp_2p10g.dtb					|Ethernet SED device tree blob for Linux Kernel.                        |
|socfpga_agilex5_socdk.dtb						|Dev kit device tree blob (U-Boot / platform).                          |
|console-image-minimal-agilex5e.rootfs.tar.gz	|console-image-minimal rootfs.					                        |
|console-image-minimal-agilex5e.rootfs.wic      |SD/MMC bootable disk image.                                            |
|gsrd-console-image-agilex5e.rootfs.wic         |SD/MMC bootable disk image (if building gsrd-console-image).           |

### Programming files with FSBL (quartus_pfg)

After Yocto has produced `u-boot-spl-dtb.hex`, run from `synth/` (or pass absolute paths):

```bash
# From dk-a5e065bb32aea/ptp/synth/
quartus_pfg -c -o hps=on \
  -o hps_path=../software/yocto_linux/build/tmp/deploy/images/agilex5e/u-boot-spl-dtb.hex \
  output_files/<design>.sof \
  output_files/<design>.rbf
```

Optional: write an SOF with FSBL into the Yocto deploy directory:

```bash
# From software/yocto_linux/
DEPLOY=build/tmp/deploy/images/agilex5e
REVISION=agilex5-dk-a5e065bb32aea_gsrd_ghrd_PTP_2P10G
SOF_IN=../../synth/output_files/${REVISION}.sof   # adjust if needed

quartus_pfg -c -o hps_path=${DEPLOY}/u-boot-spl-dtb.hex \
  ${SOF_IN} \
  ${DEPLOY}/${REVISION}_yocto_linux_sd.sof
```

Hardware compile details: [README.md](../../README.md).
### Steps to create QSPI bootable image (JIC)
Follow steps mentioned in ```scripts/README.md``` file.

### Notes

#### KAS Configuration - Include and Append/Override configurations

KAS supports modularizing build configurations by allowing multiple YAML files to be included and merged.
When multiple files are specified, KAS processes and merges them **in order**, with settings in later files overriding those from earlier ones.
This mechanism enables maintaining a stable base configuration while applying targeted overrides or additions as needed.

**Usage Example**

Before building, verify final configuration after merge:
```bash
kas dump kas.yml:bsp.yml
```

To build the project:
```bash
kas build kas.yml:bsp.yml
```

* `kas.yml` is the base configuration file.
* `bsp.yml` contains override or additional settings that modify the base.
* `device-tree.yml` contains device tree specific settings that extend or override the base configuration.

This layered approach promotes a clean and maintainable configuration strategy, allowing you to customize specific settings without altering the main configuration directly.

**Example `kas.yml` with Includes**

```yaml
header:
  version: 11
  includes:
    - bsp.yml
    - device-tree.yml
```

* Here, `bsp.yml`, and `device-tree.yml` are included and merged in that order.
* Later files can override or add settings to earlier ones.

**References**

* [Including In-Tree Configuration Files](https://kas.readthedocs.io/en/latest/userguide/project-configuration.html#including-in-tree-configuration-files)
* [Including Configuration Files from Other Repos](https://kas.readthedocs.io/en/latest/userguide/project-configuration.html#including-configuration-files-from-other-repos)
* [Including Configuration Files via the Command Line](https://kas.readthedocs.io/en/latest/userguide/project-configuration.html#including-configuration-files-via-the-command-line)

#### Bitbake commands for building key targets
- **Core Image**
```bash
$ bitbake -c build core-image-minimal
```
- **Baseline System Example Design image**
```bash
$ bitbake -c build gsrd-console-image
```
- **U-Boot**
```bash
$ bitbake -c build u-boot-socfpga (or) bitbake -c build virtual/bootloader
```
- **Linux**
```bash
$ bitbake -c build linux-socfpga-lts  (or) bitbake -c build virtual/kernel
```
- **ATF**
```bash
$ bitbake -c build arm-trusted-firmware
```
- **Device Tree** (built with the kernel; DTB selected by `ETH_DESIGN` / `eth-solution.inc`)
```bash
$ bitbake -c build linux-socfpga-lts
```
### Documentation
- [KAS] https://kas.readthedocs.io/en/latest/
- [YOCTO] https://docs.yoctoproject.org/

