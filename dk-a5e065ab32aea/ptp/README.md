# Altera Agilex 5 Precision Time Protocol (IEEE 1588) System Example Design

System Example Design for the [Agilex 5 FPGA E-Series 065A Premium Development Kit (DK-A5E065AB32AEA)](https://www.altera.com/products/devkit/po-3285/agilex-5-fpga-e-series-065a-premium-development-kit)
(`dk-a5e065ab32aea`) demonstrating 2-port 25G PTP (IEEE 1588) with HPS, MSGDMA, and packet switch.



## Description

The 2-port 25G PTP System Example Design demonstrates IEEE 1588v2 with hardware timestamping on the Agilex™ 5 065A Premium Development Kit, with an HPS-hosted PTP software stack.

## Project Details

- **Family**: Agilex 5
- **Quartus Version**: 26.3
- **Patch Number**: Unknown
- **Development Kit**: [DK-A5E065AB32AEA](https://www.altera.com/products/devkit/po-3285/agilex-5-fpga-e-series-065a-premium-development-kit)
- **Device Part**: A5ED065AB32AE1V
- **Category**: HPS, Ethernet
- **URL**: https://github.com/altera-fpga/agilex5-ed-ethernet
- **Design Package**: dk-a5e065ab32aea-ptp-2p25g.zip

## Documentations

- **Title**: Design and Build Readme  
  **URL**: [./README.md](./README.md)
- **Title**: Software / Yocto Build Readme  
  **URL**: [./software/yocto_linux/README.md](./software/yocto_linux/README.md)

## Dependency

- Altera Quartus Prime Pro (see Release Notes for the supported version)
- Software / Yocto: [software/yocto_linux/README.md](software/yocto_linux/README.md)

## Compiling via Makefile (hardware and software)

The top level Makefile is in the design root (`ptp/`). The Quartus project (`top.qpf` / `top.qsf`) lives in `synth/`.

Run `make help` from `ptp/` for the full target list.

Public stem: `dk-a5e065ab32aea-baseline-ptp25G`  
Hardware revision (SOF / RBF basename): `agilex5-dk-a5e065ab32aea_gsrd_ghrd_PTP_2P25G` (`REVISION_NAMES` in `project_config.mk`).

**Full build (hardware and software):**

```bash
make dk-a5e065ab32aea-baseline-ptp25G-all
```

This runs the hardware build, generates the core RBF from the SOF, then runs the Yocto SD software build.

**Hardware build only:**

```bash
make dk-a5e065ab32aea-baseline-ptp25G-build
```

This calls `synth/Makefile` (`make -C synth all`) and then copies `synth/output_files/top.sof`
to `output_files/agilex5-dk-a5e065ab32aea_gsrd_ghrd_PTP_2P25G.sof` for the install and software targets.

**Software build only**, after the hardware build generates the required SOF (core RBF is produced automatically):

```bash
make dk-a5e065ab32aea-baseline-ptp25G-software-yocto_linux_sd-build-sw
```

This runs `quartus_pfg` to create the core RBF, then
`software/yocto_linux/build.sh <core.rbf> sd`.

**Install core RBF only** (SOF + `quartus_pfg` → `install/binaries/`):

```bash
make dk-a5e065ab32aea-baseline-ptp25G-install-core-rbf
```

Yocto design selection (`ETH_DESIGN`, default `PTP_2P25G`), RBF/DTB names, and kas details:
[software/yocto_linux/README.md](software/yocto_linux/README.md).

## Directory structure

```text
ptp/
+-- Makefile / project_config.mk / swbuild_config.mk
+-- src/                        # HARDWARE - RTL / Qsys / custom IP
+-- synth/                      # HARDWARE - Quartus project + Makefile
|   +-- output_files/
+-- verification/               # HARDWARE - UVM TB
+-- software/
    +-- yocto_linux/            # SOFTWARE - see software/yocto_linux/README.md
```

| Path | Role |
|------|------|
| `src/` | RTL, Qsys, custom IP |
| `synth/` | Quartus project and compile `Makefile` |
| `verification/` | UVM testbench and regressions |
| `software/yocto_linux/` | Yocto / KAS BSP |

## Hardware compile only from synth folder (`synth/Makefile`)

From `ptp/synth/`:

```bash
make all
# optional rate config (writes config.txt):
# make all CONFIG=25G_NON_ANLT
# make all CONFIG=10G_NON_ANLT
```

If `CONFIG` is omitted, the value currently in `config.txt` is used.

Also available: `make synth`, `make compile`, `make asm`, `make clean`. Outputs under `synth/output_files/` (SOF name is `top.sof`).

The top-level Makefile copies that SOF to
`output_files/agilex5-dk-a5e065ab32aea_gsrd_ghrd_PTP_2P25G.sof` and generates the matching
`.core.rbf` for Yocto.

## Programming files (SOF + FSBL)

`u-boot-spl-dtb.hex` comes from the Yocto deploy images after a Yocto build.

After a Yocto build:

```bash
cd synth/
quartus_pfg -c -o hps=on \
  -o hps_path=../software/yocto_linux/build/tmp/deploy/images/agilex5e/u-boot-spl-dtb.hex \
  output_files/top.sof \
  output_files/top.rbf
```

Or use the revision-named SOF produced by the top-level Makefile under `output_files/`.

## Verification (UVM)

See [verification/README.txt](verification/README.txt).

## Software

Software overview (board setup, FSBL, optional standalone kernel/ATF/U-Boot builds):  
**[software/README.md](software/README.md)**.

Yocto / KAS, `ETH_DESIGN`, RBF/DTB names, `build.sh`, binaries:  
**[software/yocto_linux/README.md](software/yocto_linux/README.md)**.
