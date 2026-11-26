# 1-Port Triple Speed Ethernet Agilex™ 5 System Example Design

The 1-Port Triple Speed Ethernet Agilex™ 5 System Example Design targets the [Agilex™ 5 FPGA E-Series 065B Modular Development Kit (MK-A5E065BB32AEA)](https://www.altera.com/products/devkit/po-3274/agilex-5-fpga-and-soc-e-series-065b-modular-development-kit) with HPS, MSGDMA, and Triple Speed Ethernet IP with GTS PCS/PMA.

## Description

The Triple Speed Ethernet System Example Design demonstrates 10M/100M/1GbE Ethernet functionality of the Altera Agilex™ 5 FPGA. It provides a 1-port design using the Triple Speed Ethernet Intel® FPGA IP with an integrated GTS PCS/PMA (SGMII) link to the board PHY, managed over MDIO.

The Hard Processor Subsystem (HPS) runs Linux with the Altera TSE kernel driver. Packet traffic moves between HPS DDR and the MAC through a Channelized Modular Scatter-Gather DMA (MSGDMA) subsystem.

The primary components in the design are:

- Hard Processor Subsystem (HPS)
- Channelized Modular Scatter-Gather Direct Memory Access (MSGDMA) Subsystem
- Triple Speed Ethernet Intel® FPGA IP (MAC)
- GTS PCS/PMA (SGMII)
- GTS reset sequencing (`gts_reset_sequencer`, `srd_rst_ctrl`) and IOPLL clocking
- User CSR space

![Intel Agilex 5 TSE Ethernet System Example Design block diagram](./SM_TSE_Ethernet_block_diagram.png)

Important features of the design include:

- 1-port 10M/100M/1GbE via Triple Speed Ethernet MAC + GTS PCS (SGMII)
- Ethernet software stack running on the HPS (Linux + TSE driver) that handles the generation of iperf traffic
- MSGDMA datapath to efficiently transfer data between HPS DDR and the Ethernet MAC
- GTS reset sequencing and IOPLL clocking

## Project Details

- **Family**: Agilex 5
- **Quartus Version**: 26.3
- **Patch Number**: Unknown
- **Development Kit**: [MK-A5E065BB32AEA](https://www.altera.com/products/devkit/po-3274/agilex-5-fpga-and-soc-e-series-065b-modular-development-kit)
- **Device Part**: A5ED065BB32AE4S
- **Category**: HPS, Ethernet
- **URL**: https://github.com/altera-fpga/agilex5-ed-ethernet
- **Design Package**: mk-a5e065bb32aea-tse.zip

## Documentations

- **Title**: Design and Build Readme  
  **URL**: [README.md](./README.md)
- **Title**: Hardware Build (synth)  
  **URL**: [synth/README.md](./synth/README.md)
- **Title**: Software / Yocto Build Readme  
  **URL**: [software/yocto_linux/README.md](./software/yocto_linux/README.md)

## Dependency

- Altera Quartus Prime Pro (see Project Details for the supported version)
- Software / Yocto: [software/yocto_linux/README.md](software/yocto_linux/README.md)

## Directory structure

```text
tse/
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

## Compiling via Makefile (hardware and software)

The top level Makefile is in the design root (`tse/`). The Quartus project (`top.qpf` / `top.qsf`) lives in `synth/`.

Run `make help` from `tse/` for the public build targets and common commands.

**Design selection (`TSE_DESIGN`):** default / supported value is `TSE_1P` (see `software/yocto_linux/meta-custom/conf/tse-solution.inc`). The hardware revision name is `agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P` (`REVISION_NAMES` in `project_config.mk`). The core RBF filename is `agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P.core.rbf`.

Public stem: `mk-a5e065bb32aea-baseline-tse`

**Full build (hardware and software):**

```bash
make mk-a5e065bb32aea-baseline-tse-all
```

This builds the hardware SOF, generates its core RBF, then builds the Yocto SD
software image. If `TSE_DESIGN` is omitted, the default `TSE_1P` is used. The
FSBL-inserted SD SOF and QSPI/JIC outputs are generated separately by
`make sd-postprocess`.
Use this target rather than plain `make`: the default `make` target builds hardware only and does not run the software build that generates the core RBF.

**Hardware build only:**

```bash
make mk-a5e065bb32aea-baseline-tse-build
```

This calls `synth/Makefile` (`make -C synth all`) and then copies `synth/output_files/top.sof`
to `output_files/agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P.sof` for the install and software targets.

**Software build only**, after the hardware build generates the required SOF (core RBF is produced automatically):

```bash
make mk-a5e065bb32aea-baseline-tse-software-yocto_linux_sd-build-sw
```

This runs `quartus_pfg` to create the core RBF, then
`software/yocto_linux/build.sh <core.rbf> sd` (Make supplies the RBF path).
The KAS build includes this module's `meta-custom` layer, whose U-Boot environment
append sets `bootfile=kernel_sed.itb` and the SD root device to `/dev/mmcblk0p2`.
`kas_build.sh` copies it to `fpga-bitstream/files/agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P.core.rbf`
(`REVISION` from `project_config.mk` `REVISION_NAMES`). That name must match
`FPGA_RBF_FILE` from `TSE_DESIGN` / `tse-solution.inc`.

**Install core RBF only** (SOF + `quartus_pfg` → `install/binaries/`):

```bash
make mk-a5e065bb32aea-baseline-tse-install-core-rbf
```

**Generate QSPI JIC files** (after the hardware build; Make builds the Yocto SD
image if needed):

```bash
make mk-a5e065bb32aea-baseline-tse-all
make sd-postprocess
```

`sd-postprocess` uses Quartus `quartus_pfg` and the Yocto deploy outputs to generate
`qspi_helper.hps.jic` (U-Boot-only), `ghrd.hps.jic`, `ghrd.core.rbf`, and
`ghrd.hps.rbf`, then copies them to `install/binaries/software/yocto_linux_sd/`.
Quartus must be on `PATH`. Running plain `make` or only the hardware target does
not produce the Yocto inputs required for JIC generation. The target is also
listed by `make help`.

RBF/DTB placement, `TSE_DESIGN`, and Yocto details: [software/yocto_linux/README.md](software/yocto_linux/README.md).

## Building the Hardware only

See [synth/README.md](./synth/README.md).

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

Yocto / KAS, `TSE_DESIGN`, RBF/DTB names, `build.sh`, binaries:  
**[software/yocto_linux/README.md](software/yocto_linux/README.md)**.
