# Altera Agilex 5 Ethernet System Example Design

System Example Design for the [Agilex 5 FPGA E-Series 065B Modular Development Kit (MK-A5E065BB32AEA)](https://www.altera.com/products/devkit/po-3274/agilex-5-fpga-and-soc-e-series-065b-modular-development-kit)
(`mk-a5e065bb32aea`) demonstrating 1-port Ethernet with HPS, MSGDMA, and packet switch.



## Description

The Ethernet System Example Design demonstrates 1-port 10GbE on the Agilex™ 5 Modular Development Kit with HPS, MSGDMA, packet switch, and GTS Ethernet Hard IP.

## Project Details

- **Family**: Agilex 5
- **Quartus Version**: 26.3
- **Patch Number**: Unknown
- **Development Kit**: [MK-A5E065BB32AEA](https://www.altera.com/products/devkit/po-3274/agilex-5-fpga-and-soc-e-series-065b-modular-development-kit)
- **Device Part**: A5ED065BB32AE4S
- **Category**: HPS, Ethernet
- **URL**: https://github.com/altera-fpga/agilex5-ed-ethernet
- **Design Package**: mk-a5e065bb32aea-ethernet-10g.zip

## Documentations

- **Title**: Design and Build Readme  
  **URL**: [./README.md](./README.md)
- **Title**: Software / Yocto Build Readme  
  **URL**: [./software/yocto_linux/README.md](./software/yocto_linux/README.md)

## Dependency

- Altera Quartus Prime Pro (see Release Notes for the supported version)
- Software / Yocto: [software/yocto_linux/README.md](software/yocto_linux/README.md)

## Compiling via Makefile (hardware and software)

The top level Makefile is in the design root (`ethernet/`). The Quartus project (`top.qpf` / `top.qsf`) lives in `synth/`.

Run `make help` from `ethernet/` for the full target list.

**Design selection (`ETH_DESIGN`):** default / supported value is `ETH_1P10G` (see `software/yocto_linux/meta-custom/conf/eth-solution.inc`). The hardware revision name is `agilex5-mk-a5e065bb32aea_gsrd_ghrd_ETH_1P10G` (`REVISION_NAMES` in `project_config.mk`).

**Full build (hardware and software):**

```bash
make mk-a5e065bb32aea-baseline-ethernet-all
```

This runs the hardware build, generates the core RBF from the SOF, then runs the Yocto SD software build.

**Hardware build only:**

```bash
make mk-a5e065bb32aea-baseline-ethernet-build
```

This calls `synth/Makefile` (`make -C synth all`) and then copies `synth/output_files/top.sof`
to `output_files/agilex5-mk-a5e065bb32aea_gsrd_ghrd_ETH_1P10G.sof` for the install and software targets.

**Software build only**, after the hardware build generates the required SOF (core RBF is produced automatically):

```bash
make mk-a5e065bb32aea-baseline-ethernet-software-yocto_linux_sd-build-sw
```

This runs `quartus_pfg` to create the core RBF, then
`software/yocto_linux/build.sh <core.rbf> sd` (Make supplies the RBF path).
`kas_build.sh` copies it to `fpga-bitstream/files/<REVISION>.core.rbf`
(`REVISION` from `project_config.mk` `REVISION_NAMES`). That name must match
`FPGA_RBF_FILE` from `ETH_DESIGN` / `eth-solution.inc`.

**Install core RBF only** (SOF + `quartus_pfg` → `install/binaries/`):

```bash
make mk-a5e065bb32aea-baseline-ethernet-install-core-rbf
```

RBF/DTB placement, `ETH_DESIGN`, and Yocto details: [software/yocto_linux/README.md](software/yocto_linux/README.md).

## Directory structure

```text
ethernet/
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

From `ethernet/synth/`:

```bash
make all
```

Also available: `make synth`, `make compile`, `make asm`, `make clean`. Outputs under `synth/output_files/` (SOF name is `top.sof`).

The top-level Makefile copies that SOF to
`output_files/agilex5-mk-a5e065bb32aea_gsrd_ghrd_ETH_1P10G.sof` and generates the matching
`.core.rbf` for Yocto (`REVISION_NAMES` in `project_config.mk`; must match
`FPGA_RBF_FILE` from `eth-solution.inc`).
Details: [software/yocto_linux/README.md](software/yocto_linux/README.md).

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
