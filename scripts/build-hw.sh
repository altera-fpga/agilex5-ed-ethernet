#!/bin/sh
set -ex

# Match agx5_ethernet_ori/scripts/build-hw.sh (quartus_upgrade.sh sed-replaces this line)
QUARTUS_VERSION=acds/26.3
# VARIANT selects the design (default mk-a5e065bb32aea/ethernet); sets ETH_DIR, MAKE_STEM, REVISION, NFS_RELPATH
. "$(dirname "$0")/variant_config.sh"

if [ -n "$BUILD_PATH" ]; then
  arc shell $QUARTUS_VERSION -- "quartus_sh --version" | \
    awk -F',' '/entering shell with resources/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' \
    > "$BUILD_PATH/quartus_info"
fi

echo "Building Ethernet HW ($MAKE_STEM)"
cd "$ETH_DIR"

# Hardware compile (SOF + reports under synth/ and ethernet/output_files)
arc shell $QUARTUS_VERSION -- "make ${MAKE_STEM}-build"

# Core RBF for Yocto / NFS (install/binaries/ghrd.core.rbf)
arc shell $QUARTUS_VERSION -- "make ${MAKE_STEM}-install-core-rbf"

# Stage names expected by GitHub HW workflows (top.sof / top.core.rbf)
mkdir -p synth/output_files
if [ -f "output_files/${REVISION}.sof" ]; then
  cp -f "output_files/${REVISION}.sof" synth/output_files/top.sof
elif [ -f synth/output_files/top.sof ]; then
  :
else
  echo "ERROR: SOF not found under output_files/ or synth/output_files/"
  ls -l output_files/ synth/output_files/ || true
  exit 1
fi

if [ -f "output_files/${REVISION}.core.rbf" ]; then
  cp -f "output_files/${REVISION}.core.rbf" synth/output_files/top.core.rbf
elif [ -f install/binaries/ghrd.core.rbf ]; then
  cp -f install/binaries/ghrd.core.rbf synth/output_files/top.core.rbf
else
  echo "ERROR: core.rbf not found"
  ls -l output_files/ install/binaries/ || true
  exit 1
fi

# HPS RBF for regression (*.ghrd.hps.rbf). Needs u-boot-spl-dtb.hex — prefer a
# prior SW publish on NFS latest/sw, then local Yocto deploy (rare on HW-only).
HEX_PATH=""
for cand in \
  "${BUILD_PATH:+$BUILD_PATH/../latest/sw/u-boot-spl-dtb.hex}" \
  "/nfs/site/disks/pac_release_1/github/psgpac/sed/build/nightly/${NFS_RELPATH}/latest/sw/u-boot-spl-dtb.hex" \
  "software/yocto_linux/build/tmp/deploy/images/agilex5e/u-boot-spl-dtb.hex" \
  "software/artifacts/u-boot-spl-dtb.hex"
do
  [ -n "$cand" ] && [ -f "$cand" ] || continue
  HEX_PATH="$cand"
  break
done
if [ -n "$HEX_PATH" ] && [ -f synth/output_files/top.sof ]; then
  echo "Generating top.hps.rbf with SPL hex: $HEX_PATH"
  arc shell $QUARTUS_VERSION -- \
    "quartus_pfg -c -o hps=on -o hps_path=$HEX_PATH synth/output_files/top.sof synth/output_files/top.rbf"
  # PFG writes top.hps.rbf (+ top.core.rbf) next to the output basename
  ls -l synth/output_files/top.hps.rbf synth/output_files/top.rbf* || true
else
  echo "WARNING: No u-boot-spl-dtb.hex found — top.hps.rbf not generated."
  echo "Regression needs *.ghrd.hps.rbf; SW job will PFG after publishing the hex."
fi

# Copy DRC report name expected by timing/drc scripts if present under revision name
if [ -f "output_files/${REVISION}.tq.drc.signoff.rpt" ] && \
   [ ! -f synth/output_files/top.tq.drc.signoff.rpt ]; then
  cp -f "output_files/${REVISION}.tq.drc.signoff.rpt" synth/output_files/top.tq.drc.signoff.rpt
fi

ls -l synth/output_files/ || true
