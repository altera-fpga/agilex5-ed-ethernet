# Altera Agilex 5 Ethernet System Example Design

System Example Design for the Agilex 5 FPGA E-Series 065B Modular Development Kit
(`mk-a5e065ab32aea`) demonstrating 1-port 25G Ethernet with HPS, MSGDMA, and packet switch.

## Dependency

- Altera Quartus Prime Pro (see Release Notes for the supported version)
- Software / Yocto: [software/yocto_linux/README.md](software/yocto_linux/README.md)

## Compiling via Makefile (hardware and software)

The top level Makefile is in the design root (`ethernet/`). The Quartus project (`top.qpf` / `top.qsf`) lives in `synth/`.

Run `make help` from `ethernet/` for the full target list.

Public stem: `mk-a5e065ab32aea-baseline-ethernet25G`  
Hardware revision (SOF / RBF basename): `agilex5-mk-a5e065ab32aea_gsrd_ghrd_ETH_1P25G` (`REVISION_NAMES` in `project_config.mk`).

**Full build (hardware and software):**

```bash
make mk-a5e065ab32aea-baseline-ethernet25G-all
```

This runs the hardware build, generates the core RBF from the SOF, then runs the Yocto SD software build.

**Hardware build only:**

```bash
make mk-a5e065ab32aea-baseline-ethernet25G-build
```

This calls `synth/Makefile` (`make -C synth all`) and then copies `synth/output_files/top.sof`
to `output_files/agilex5-mk-a5e065ab32aea_gsrd_ghrd_ETH_1P25G.sof` for the install and software targets.

**Software build only**, after the hardware build generates the required SOF (core RBF is produced automatically):

```bash
make mk-a5e065ab32aea-baseline-ethernet25G-software-yocto_linux_sd-build-sw
```

This runs `quartus_pfg` to create the core RBF, then
`software/yocto_linux/build.sh <core.rbf> sd`.

**Install core RBF only** (SOF + `quartus_pfg` → `install/binaries/`):

```bash
make mk-a5e065ab32aea-baseline-ethernet25G-install-core-rbf
```

Yocto design selection (`ETH_DESIGN`, default `ETH_1P25G`), RBF/DTB names, and kas details:
[software/yocto_linux/README.md](software/yocto_linux/README.md).

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
# optional rate config (writes config.txt):
# make all CONFIG=25G_NON_ANLT
# make all CONFIG=10G_NON_ANLT
```

If `CONFIG` is omitted, the value currently in `config.txt` is used.

Also available: `make synth`, `make compile`, `make asm`, `make clean`. Outputs under `synth/output_files/` (SOF name is `top.sof`).

The top-level Makefile copies that SOF to
`output_files/agilex5-mk-a5e065ab32aea_gsrd_ghrd_ETH_1P25G.sof` and generates the matching
`.core.rbf` for Yocto.

## Programming files (SOF + FSBL)

There is **no** `software/artifacts/` directory in this repository.
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
