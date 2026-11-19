#!/bin/sh
set -ex

QUARTUS_VERSION=$QUARTUS_VERSION
echo "QUARTUS_VERSION - $QUARTUS_VERSION"
echo "WORKDIR - $WORKDIR"
echo "PROJECT_PATH - $PROJECT_PATH"
echo "SCRIPT_PATH - $SCRIPT_PATH"
LOG_DIR=$WORKDIR/logging

mkdir -p $LOG_DIR

# if [ -n "$BUILD_PATH" ]; then
#     arc shell $QUARTUS_VERSION -- "quartus_sh --version" | awk -F',' '/entering shell with resources/ { sub(/\/[^/]+$/, "", $2); print $2 }'  > $BUILD_PATH/quartus_info
# fi

sed -i "s|^[[:space:]]*QUARTUS_VERSION=.*|QUARTUS_VERSION=$QUARTUS_VERSION|" scripts/build-hw.sh
# New tree: mk-a5e065bb32aea/ethernet (was src/hw in agx5_ethernet_ori)
sed -i "s|^[[:space:]]*export QUARTUS_VER=.*|export QUARTUS_VER=\"$QUARTUS_VERSION\"|" \
  $PWD/mk-a5e065bb32aea/ethernet/verification/env/arc_resource_list.sh

echo "PWD --- $PWD"
# cd src/hw/a5e065bb32aes1_mdk_3x2.5G/
arc shell $QUARTUS_VERSION -- "$SCRIPT_PATH/auto_upgrade.sh $PROJECT_PATH/top.qpf top"  2>&1 | tee $LOG_DIR/quartus_update.log

# # we pick socfpga_refdes from GHRD release 25.1 RC8 build 
# arc shell $QUARTUS_VERSION socfpga_refdes/mainline -- 'quartus_pfg -c -o hps_path="$SOCFPGA_REFDES_ROOT"/designs/agilex5_devkit_soc_ghrd/u-boot-spl-dtb.hex ./output_files/top.sof ./output_files/top_hps.sof'
# arc shell $QUARTUS_VERSION socfpga_refdes/mainline -- 'quartus_pfg -c -o hps=on ./output_files/top_hps.sof ./output_files/mdk_3x2.5G.rbf'
