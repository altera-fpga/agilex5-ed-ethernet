#!/bin/bash
# Variables


# Clean build artifacts
#cd $REG_LOCAL_ROOT_DIR_PATH/scripts && /p/psg/flows/sw/make_altera/4.3/linux64/gmake -f Makefile.mk clean
#cd $CURR_DIR

    export CURR_DIR="/p/psg/pac/release/main/github/psgpac/sed/regression_test/simulation/eth_agx5_sm72/applications.fpga.system-example-designs.agilex5-ed-ethernet/src/hw/verification/scripts/itf"

    SIM_REPO_PATH="$(realpath "$CURR_DIR/../..")"
    export REG_LOCAL_ROOT_DIR_PATH="$SIM_REPO_PATH"
    SIM_SCRIPTS_PATH="$CURR_DIR"
    GIT_REPO_PATH="$(realpath "$SIM_REPO_PATH/../../..")"
    SIM_LAUNCH_FILE="$SIM_REPO_PATH/scripts/itf/regr_launch.sh"
    SIM_RUN_LAUNCH_FILE="$SIM_REPO_PATH/scripts/itf/run_regr_launch.sh"
    SIM_OUTPUT_FILE="$SIM_SCRIPTS_PATH/SIM_SED_SM7ETH_PDK_STDOUT.out"
    SIM_LOG_FILE="$SIM_SCRIPTS_PATH/SIM_SED_SM7ETH_PDK_LOG.out"



    # Cleanup files
    rm -rf $SIM_RUN_LAUNCH_FILE
    rm -rf $SIM_OUTPUT_FILE
    rm -rf $SIM_LOG_FILE
    rm -rf t.log

    # Copy launch file
    cp $SIM_LAUNCH_FILE $SIM_RUN_LAUNCH_FILE

    ### Update REG_LOCAL_ROOT_DIR_PATH
    #sed -i "s#^export REG_LOCAL_ROOT_DIR_PATH=.*#export REG_LOCAL_ROOT_DIR_PATH=$SIM_REPO_PATH" "$SIM_RUN_LAUNCH_FILE"

    ## Temp file to hold modified contents
    TMP_FILE=$(mktemp)

    ## Path prefix to match
    PREFIX="/p/psg/flows/sw/regutils/23.4/5/linux64/bin/reg_exe"

    awk -v prefix="$PREFIX" '
    {
        # If line starts with the known prefix
        if (index($0, prefix) == 1) {
            # Escape any double quotes for the echo part
            gsub(/"/, "\\\"", $0)
            echo_part = "echo \"" $0 "\" >> '${SIM_OUTPUT_FILE}'"
   
            # Undo quote escaping for actual execution part
            gsub(/\\"/, "\"", $0)
            exec_part = $0 " >> '${SIM_OUTPUT_FILE}'"

            # Print the combined output
            print echo_part " && " exec_part
        } else {
            # Print the line as-is
            print $0
        }
    }' "$SIM_RUN_LAUNCH_FILE" > "$TMP_FILE"
    cat $TMP_FILE

    #sleep 1
    #
    ## Overwrite the original file
    mv "$TMP_FILE" "$SIM_RUN_LAUNCH_FILE"

    rm -rf "$TMP_FILE"

    chmod +x $SIM_RUN_LAUNCH_FILE

    # git pull repo
    #echo " Executng test cmd"
    #echo "cd $SIM_REPO_PATH"
    #echo "/usr/intel/bin/git pull" >> $SIM_OUTPUT_FILE
    #test_cmd=$(cd $GIT_REPO_PATH; /usr/intel/bin/git pull)
    #echo -ne "# " >> $SIM_OUTPUT_FILE
    #echo "$test_cmd" >> $SIM_OUTPUT_FILE
    #echo "" >> $SIM_OUTPUT_FILE

    #sleep 10m
    # submit job to arc
    echo "/p/psg/ctools/arc/2019.1/bin/arc submit vcs-vcsmx-lic,acds/26.3,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1,synopsys_verdi/U-2023.03-SP2-1  -- '${SIM_RUN_LAUNCH_FILE}'" >> $SIM_OUTPUT_FILE
    test_cmd=$(/p/psg/ctools/arc/2019.1/bin/arc submit flow/sw/bigmem vcs-vcsmx-lic,acds/26.3,devacds/23.4,testutils/23.4/79,regutils/23.4,itf/23.4,ostype/suse15,synopsys_vip_common/vip_W-2025.03C,p4/psgeng,perl/5.8.8,python/3.7.7/1,vcsmx/X-2025.06-SP1-1,synopsys_verdi/U-2023.03-SP2-1 mem=32000  -- "$SIM_RUN_LAUNCH_FILE")
    echo -ne "# ARC Job Id: " >> $SIM_OUTPUT_FILE
    echo "$test_cmd" >> $SIM_OUTPUT_FILE
    echo "" >> $SIM_OUTPUT_FILE




