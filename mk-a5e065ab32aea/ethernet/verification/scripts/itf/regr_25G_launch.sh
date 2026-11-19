/usr/intel/bin/bash
#1 source env.sh and setup.sh for Makefile qsys/rtl and build
export ITF_DIR_PATH="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/eth_agx5_sm72plus/25g_non_anlt/applications.fpga.system-example-designs.sm7plus-ed-ethernet/src/hw/verification/scripts/itf"
echo "$ITF_DIR_PATH"
export REG_LOCAL_ROOT_DIR_PATH="$(realpath "$ITF_DIR_PATH/../..")"
source $REG_LOCAL_ROOT_DIR_PATH/env/env.sh
echo "Executing env25G.sh"

#/usr/intel/bin/bash 
source $REG_LOCAL_ROOT_DIR_PATH/env/setup.sh

cd $REG_LOCAL_ROOT_DIR_PATH/scripts/ && /p/psg/flows/sw/make_altera/4.3/linux64/gmake -f Makefile.mk cmplib HSSI_25G=1 | tee cmp.log && /p/psg/flows/sw/make_altera/4.3/linux64/gmake -f Makefile.mk build HSSI_25G=1 
#2 Cleanup old files, launch regression through ITF flow and generate Spetc report
cd $REG_LOCAL_ROOT_DIR_PATH/scripts/itf
/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_reset
/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_exe --farm --title="SM7PLUS_ED_Ethernet_25G" --regr_cfg=sanity_regr

