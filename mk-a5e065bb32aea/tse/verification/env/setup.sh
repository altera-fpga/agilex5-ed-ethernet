#!/usr/bin/env bash
# Customer / local simulation environment setup (no arc required).
# Prerequisites: set tool roots before sourcing this file (see ../README.txt).

if test -n "$BASH" ; then SCRIPT_NAME=$BASH_SOURCE
elif test -n "$TMOUT"; then SCRIPT_NAME=${.sh.file}
elif test -n "$ZSH_NAME" ; then SCRIPT_NAME=${(%):-%x}
elif test ${0##*/} = dash; then x=$(lsof -p $$ -Fn0 | tail -1); SCRIPT_NAME=${x#n}
else SCRIPT_NAME=$0
fi

SCRIPT_DIR="$(cd "$(dirname -- "$SCRIPT_NAME")" 2>/dev/null && pwd -P)"

# ROOTDIR = <repo>/a5e065b-mod-devkit-exp-prod/src/hw
if [ -z "${ROOTDIR}" ]; then
  export ROOTDIR=$(readlink -f "${SCRIPT_DIR}/../../")
fi
unset SCRIPT_DIR

if [ -z "${QUARTUS_ROOTDIR}" ]; then
  echo "ERROR: QUARTUS_ROOTDIR is not set. Point it at your Quartus/ACDS install (quartus/)."
  return 1 2>/dev/null || exit 1
fi
if [ -z "${VCS_HOME}" ]; then
  echo "ERROR: VCS_HOME is not set. Point it at your Synopsys VCS/VCSMX install."
  return 1 2>/dev/null || exit 1
fi
#if [ -z "${DESIGNWARE_HOME}" ]; then
#  echo "ERROR: DESIGNWARE_HOME is not set. Point it at your Synopsys DesignWare VIP install"
#  echo "       (directory that contains bin/dw_vip_setup and vip/svt/amba_svt)."
#  return 1 2>/dev/null || exit 1
#fi

export WORKDIR=$ROOTDIR
export QUARTUS_HOME=$QUARTUS_ROOTDIR
export QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
export QUARTUS_ROOTDIR_OVERRIDE=$QUARTUS_ROOTDIR
export IMPORT_IP_ROOTDIR=$QUARTUS_ROOTDIR/../ip
export DESIGNWARE_HOME=/p/psg/EIP/synopsys/vip_common/vip_W-2025.03C
export https_proxy=http://proxy-chain.intel.com:912
export http_proxy=http://proxy-chain.intel.com:911
#export BOARD_TYPE=devkit_fm87 
#export QUARTUS_DEVICE=A5ED065BB32AE6SR0
#export IMPORT_IP_ROOTDIR=${IMPORT_IP_ROOTDIR:-$QUARTUS_ROOTDIR/../ip}
export VERDIR=$WORKDIR/verification
export DESIGN=src
export DESIGN_DIR=$ROOTDIR/$DESIGN/
export UVM_HOME=$VCS_HOME/etc/uvm-1.2
#export UVM_HOME=${UVM_HOME:-$VCS_HOME/etc/uvm-1.2}

echo "ROOTDIR             " $ROOTDIR
echo "VCS_HOME            " $VCS_HOME
echo "QUARTUS_ROOTDIR     " $QUARTUS_ROOTDIR
echo "QUARTUS_HOME        " $QUARTUS_HOME
echo "IMPORT_IP_ROOTDIR   " $IMPORT_IP_ROOTDIR
echo "DESIGNWARE_HOME     " $DESIGNWARE_HOME
echo "VERDIR              " $VERDIR
echo "DESIGN              " $DESIGN
echo "DESIGN_DIR          " $DESIGN_DIR
echo "UVM_HOME            " $UVM_HOME
