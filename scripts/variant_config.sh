#!/bin/sh
# Per-design settings shared by scripts/build-hw.sh, scripts/build-sw.sh and the
# GitHub workflows (build_hardware.yml / build_software.yml "Resolve variant" step).
#
# Usage: VARIANT=<board>/<design> . scripts/variant_config.sh
#   VARIANT defaults to the original 1x10G Ethernet design.
#
# Exports:
#   ETH_DIR                    design root (contains Makefile, synth/, software/yocto_linux/)
#   MAKE_STEM                  public make target stem (MAKE_STEM in project_config.mk)
#   REVISION                   first REVISION_NAMES entry; core RBF is <REVISION>.core.rbf
#   NFS_RELPATH                path under .../sed/build/{nightly,release} for HW/SW publish
#   ARTIFACT_NAME_PREFIX_BASE  artifact / NFS file name prefix

VARIANT="${VARIANT:-mk-a5e065bb32aea/ethernet}"

case "$VARIANT" in
  mk-a5e065bb32aea/ethernet)
    MAKE_STEM="mk-a5e065bb32aea-baseline-ethernet"
    REVISION="agilex5-mk-a5e065bb32aea_gsrd_ghrd_ETH_1P10G"
    NFS_RELPATH="ethernet/agx5/sm72/mdk/1x10g"
    ARTIFACT_NAME_PREFIX_BASE="agilex5-sm72-ed-ethernet-1x10G"
    ;;
  dk-a5e065ab32aea/ptp)
    MAKE_STEM="dk-a5e065ab32aea-baseline-ptp25G"
    REVISION="agilex5-dk-a5e065ab32aea_gsrd_ghrd_PTP_2P25G"
    NFS_RELPATH="1588ptp/agx5/sm7plus/pdk/2x25g"
    ARTIFACT_NAME_PREFIX_BASE="agilex5-sm7plus-ed-1588ptp-2x25G"
    ;;
  dk-a5e065bb32aea/ptp)
    MAKE_STEM="dk-a5e065bb32aea-baseline-ptp10G"
    REVISION="agilex5-dk-a5e065bb32aea_gsrd_ghrd_PTP_2P10G"
    NFS_RELPATH="1588ptp/agx5/sm72/pdk/2x10g"
    ARTIFACT_NAME_PREFIX_BASE="agilex5-sm72-ed-1588ptp-2x10G"
    ;;
  mk-a5e065ab32aea/ethernet)
    MAKE_STEM="mk-a5e065ab32aea-baseline-ethernet25G"
    REVISION="agilex5-mk-a5e065ab32aea_gsrd_ghrd_ETH_1P25G"
    NFS_RELPATH="gsrd2/ethernet/agx5/sm72/mdk/1x25g"
    ARTIFACT_NAME_PREFIX_BASE="agilex5-sm72-ed-ethernet-1x25G"
    ;;
  mk-a5e065bb32aea/tse)
    MAKE_STEM="mk-a5e065bb32aea-baseline-tse"
    REVISION="baseline_a55"
    NFS_RELPATH="tse/agx5/sm72/mdk"
    ARTIFACT_NAME_PREFIX_BASE="agilex5-sm72-ed-tse"
    ;;
  *)
    echo "ERROR: unknown VARIANT '$VARIANT'" >&2
    echo "Valid: mk-a5e065bb32aea/ethernet mk-a5e065bb32aea/tse dk-a5e065ab32aea/ptp dk-a5e065bb32aea/ptp mk-a5e065ab32aea/ethernet" >&2
    return 1 2>/dev/null || exit 1
    ;;
esac

ETH_DIR="$VARIANT"
export VARIANT ETH_DIR MAKE_STEM REVISION NFS_RELPATH ARTIFACT_NAME_PREFIX_BASE
