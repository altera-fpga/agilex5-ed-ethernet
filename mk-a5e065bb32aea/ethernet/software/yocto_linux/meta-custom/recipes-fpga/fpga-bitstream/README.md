# Core RBF FPGA configuration (Agilex™ 5 Ethernet)

## Place the bitstream

Copy the hardware-generated **core** RBF into:

```text
meta-custom/recipes-fpga/fpga-bitstream/files/
```

Use the **exact** filename for the design you will build (`ETH_DESIGN` → `FPGA_RBF_FILE` in `meta-custom/conf/eth-solution.inc`):

| `ETH_DESIGN` | Filename |
|--------------|----------|
| `ETH_1P10G` | `agilex5-mk-a5e065bb32aea_gsrd_ghrd_ETH_1P10G.core.rbf` |

**Preferred:** top-level Make does this for you. After HW:

```bash
make mk-a5e065bb32aea-baseline-ethernet-all
# or software only:
make mk-a5e065bb32aea-baseline-ethernet-software-yocto_linux_sd-build-sw
```

That generates `output_files/<REVISION>.core.rbf` and `kas_build.sh` copies it into
`files/<REVISION>.core.rbf` (`REVISION` from `project_config.mk` `REVISION_NAMES`).
That name must match the table above (`FPGA_RBF_FILE` from `eth-solution.inc`).

**Manual copy** (if not using Make):

```bash
# From software/yocto_linux/
REVISION=agilex5-mk-a5e065bb32aea_gsrd_ghrd_ETH_1P10G
cp ../../output_files/${REVISION}.core.rbf \
  meta-custom/recipes-fpga/fpga-bitstream/files/${REVISION}.core.rbf
```

Do **not** hard-code `FPGA_RBF_FILE` in `kas.yml`. `eth-solution.inc` sets it from `ETH_DESIGN` (default `ETH_1P10G`).

## Build

```bash
# from yocto_linux/ — Make path already ran build.sh with the core.rbf
kas shell kas.yml -c "bitbake console-image-minimal"

# or only the bitstream recipe:
kas shell kas.yml -c "bitbake fpga-bitstream"
```

## What the recipe installs

- Input: `${FPGA_RBF_FILE}` from `files/` (name from `eth-solution.inc`)
- Deployed for HPS-first boot when `FPGA_ENABLE_CORE_PGM` is enabled
- Kernel FIT can stage the core RBF inside the ITB

## Optional: kas menu

If you use `kas menu`, enable **Enable core RBF FPGA configuration** and set the Core RBF filename to match the table above. The supported flow for this SED is `ETH_DESIGN` + `eth-solution.inc`.
