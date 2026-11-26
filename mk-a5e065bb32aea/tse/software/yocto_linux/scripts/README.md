# Steps to Regenerate Post-Yocto Binaries

This README explains how to manually generate binaries that appear in the install /
deploy directories but are not produced directly by Yocto. They are built from Yocto
outputs plus the hardware SOF using Quartus tools and the scripts in this folder.

**Related layout**
- Hardware SOF/RBF: `mk-a5e065bb32aea/tse/synth/output_files/` (see [../../../README.md](../../../README.md))
- Yocto deploy images: `../build/tmp/deploy/images/agilex5e/` (`MACHINE=agilex5e`)
- There is **no** `software/artifacts/` directory; use `u-boot-spl-dtb.hex` from the deploy folder

Scripts in this directory:

| File | Purpose |
|------|---------|
| `uboot_bin.sh` | Pad/extract `u-boot.bin` from `u-boot.itb` |
| `ubinize_nor.cfg` | UBI volumes for QSPI NOR (expects `console-image-minimal-agilex5e.rootfs_nor.ubifs`) |
| `qspi_helper.pfg` | U-Boot-only QSPI JIC (expects input SOF named `ghrd.sof`) |
| `qspi_boot.pfg` | Full QSPI JIC + RPD (expects `ghrd.sof`, `u-boot.bin`, `hps.bin`, `u-boot-spl-dtb.hex`) |

## Prerequisites

- Install mtd utilities
	```bash
	sudo apt update
	sudo apt install mtd-utils
	```
- Quartus Prime Pro tools must be installed and on PATH
- Complete Yocto build outputs available in:
  ```text
  yocto_linux/build/tmp/deploy/images/agilex5e/
  ```
  including `u-boot-spl-dtb.hex`, `u-boot.itb`, `kernel_sed.itb`, and (for QSPI) the NOR rootfs UBIFS

## Setup

Paths below are from `mk-a5e065bb32aea/tse/software/yocto_linux/`.

1. Copy the design SOF from the hardware build into the Yocto deploy directory:
   ```bash
   # Example design name — use the SOF produced under synth/output_files/
   REVISION=agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P
   cp ../../synth/output_files/${REVISION}.sof \
     build/tmp/deploy/images/agilex5e/
   ```

2. Copy these scripts into the Yocto deploy directory:
   ```bash
   cp scripts/* build/tmp/deploy/images/agilex5e/
   ```

3. Change to the Yocto deploy directory:
   ```bash
   cd build/tmp/deploy/images/agilex5e/
   ```

---

## Generate RBF Files from SOF

The PFG files in this folder expect the input SOF to be named `ghrd.sof`, so rename (or copy) your SOF first:
```bash
# Use the SOF copied from synth/output_files/
cp <sof_name>.sof ghrd.sof
# e.g. cp agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P.sof ghrd.sof
```

### Option 1: Core RBF without bootloader (Quartus 26.1+)
Creates `ghrd.core.rbf` - FPGA fabric configuration only, no bootloader embedded:
```bash
quartus_pfg -c ghrd.sof ghrd.core.rbf -o hps=ON -o hps_core_only=ON
```

### Option 2: RBF with bootloader
Creates `ghrd.hps.rbf` (bootloader) and `ghrd.core.rbf` (fabric) from SOF and SPL.
`u-boot-spl-dtb.hex` must already be present in this deploy directory (from the Yocto build):
```bash
quartus_pfg -c ghrd.sof ghrd.rbf -o hps=ON -o hps_path=u-boot-spl-dtb.hex
```
**Note:** This produces both `ghrd.hps.rbf` (HPS bootloader) and `ghrd.core.rbf` (core fabric).

**Usage notes:**
- To integrate `core.rbf` into kernel ITB, copy it to `meta-custom/recipes-fpga/fpga-bitstream/files/`
  (filename must match `TSE_DESIGN` → `FPGA_RBF_FILE` in `meta-custom/conf/tse-solution.inc`)
- Otherwise, use `core.rbf` to program FPGA from U-Boot (`fpga load`) or Linux (device tree overlay)

---

## Generate U-Boot Binary

Extract/pad U-Boot binary from ITB format (required for JIC file generation):
```bash
./uboot_bin.sh
```
**Output:** `u-boot.bin` (from `u-boot.itb`)

---

## SD/eMMC/NAND Boot Artifacts

### Generate U-Boot-Only JIC
If the daughter card (SDMMC, eMMC, NAND) is empty and you need to boot to U-Boot to access it, create a minimal JIC with U-Boot only and program it to QSPI flash:
```bash
cp <sof_name>.sof ghrd.sof
quartus_pfg -c qspi_helper.pfg
```
**Output:** `qspi_helper.hps.jic` - Contains U-Boot only (no Linux kernel/rootfs)

**Alternative method (explicit command):**
```bash
cp <sof_name>.sof ghrd.sof
quartus_pfg -c ghrd.sof ghrd.jic \
  -o device=MT25QU02G \
  -o flash_loader=A5ED065BB32AE4S \
  -o hps_path=u-boot-spl-dtb.hex \
  -o mode=ASX4 \
  -o hps=1
```
(`qspi_helper.pfg` / `qspi_boot.pfg` also use flash loader `A5ED065BB32AE4S` and device `MT25QU02G`.)

---

## QSPI Boot Artifacts

### Generate UBI Image

Create the UBI image containing Linux kernel and root filesystem:

**For QSPI (NOR flash):**
```bash
ubinize -o hps.bin -p 65536 -m 1 -s 1 ubinize_nor.cfg
```
**Output:** `hps.bin` - UBI image with kernel ITB and rootfs  
(`ubinize_nor.cfg` references `console-image-minimal-agilex5e.rootfs_nor.ubifs` among other deploy files.)

### Generate QSPI JIC Images

Create full QSPI JIC with HPS first-boot configuration:
```bash
cp <sof_name>.sof ghrd.sof
quartus_pfg -c qspi_boot.pfg
```
**Output:** 
- `qspi_boot.hps.jic` - Full QSPI image (Quartus Format)
- `qspi_boot.rpd` - Full QSPI Raw programming data

---

## Summary of Generated Files

### Common Files (All Boot Media):
| File | Source | Description |
|------|--------|-------------|
| `ghrd.core.rbf` | quartus_pfg | FPGA fabric bitstream (core-only) |
| `ghrd.hps.rbf` | quartus_pfg (Option 2) | HPS bootloader region |
| `u-boot.bin` | uboot_bin.sh | U-Boot binary extracted/padded from ITB |

### SD/eMMC/NAND Files:
| File | Source | Description |
|------|--------|-------------|
| `qspi_helper.hps.jic` | quartus_pfg + qspi_helper.pfg | U-Boot-only QSPI image for initial uboot bringup with empty daughter card |

### QSPI Files:
| File | Source | Description |
|------|--------|-------------|
| `hps.bin` | ubinize | UBI image for flash (kernel + rootfs) |
| `qspi_boot.hps.jic` | quartus_pfg + qspi_boot.pfg| Full QSPI image (Quartus Format) |
| `qspi_boot.rpd` | quartus_pfg + qspi_boot.pfg| Full QSPI Raw programming data |

**Note:** All other files (`Image`, `kernel_sed.itb`, `u-boot.itb`, `u-boot-spl-dtb.hex`, DTB, rootfs archives, etc.) are produced directly by Yocto under `build/tmp/deploy/images/agilex5e/`.
