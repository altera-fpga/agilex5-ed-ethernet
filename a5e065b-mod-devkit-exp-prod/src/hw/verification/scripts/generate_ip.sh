#!/bin/bash
# Copyright 2020 Intel Corporation.
#
# THIS SOFTWARE MAY CONTAIN PREPRODUCTION CODE AND IS PROVIDED BY THE
# COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#-------------------------------------------------------------------------
# Script to upgrade IP/Qsys system given a list of .ip/.qsys
#-------------------------------------------------------------------------

usage()
{
   echo "usage: sh upgrade_ip.sh <Path to IP list> "
   echo "       e.g. sh upgrade_ip.sh \$ROOTDIR/ "
   exit -1
}
echo "markdtet generate_ip Started"

cleanup()
{
   find . -name synth -exec rm -rf {} \;
   find . -name aldec -exec rm -rf {} \;
   find . -name cadence -exec rm -rf {} \;
   find . -name xcelium -exec rm -rf {} \;
   find . -name ncsim_files.tcl -exec rm -rf {} \;
   find . -name riviera_files.tcl -exec rm -rf {} \;
   find . -name xcelium_files.tcl -exec rm -rf {} \;
   find . -name aldec_files.txt -exec rm -rf {} \;
   find . -name cadence_files.txt -exec rm -rf {} \;
   find . -name *_bb.v -exec rm -rf {} \;
   find . -name *.cmp -exec rm -rf {} \;
   find . -name *.csv -exec rm -rf {} \;
   find . -name *.html -exec rm -rf {} \;
   find . -name *_inst.v -exec rm -rf {} \;
   find . -name *_inst.vhd -exec rm -rf {} \;
   find . -name *.qgsimc -exec rm -rf {} \;
   find . -name *.qgsynthc -exec rm -rf {} \;
   find . -name *.rpt -exec rm -rf {} \;
   find . -name *.qip -exec rm -rf {} \;
   find . -name *.sopcinfo -exec rm -rf {} \;
   find . -name *.xml -exec rm -rf {} \;
   find . -name *.ppf -exec rm -rf {} \;
   find . -name *.bsf -exec rm -rf {} \;   
}

IP_FLIST=$1
#TILE=$2
#echo "markdtet generate_ip IP_FLIST TILE $IP_FLIST $TILE"
echo "markdtet generate_ip IP_FLIST $IP_FLIST"

if [ -z $IP_FLIST ]; then
   echo "Error: IP flist is not passed in to the script. "
   usage
fi

echo "markdtet generate_ip IP_FLIST $IP_FLIST"
if [ -z $IP_FLIST ] || [ ! -f $IP_FLIST ]; then
   echo "Error: IP flist \"$IP_FLIST\" does not exist."
   usage
fi

IP_FLIST=$(readlink -f $IP_FLIST)
first=1 

#set -xe

echo "markdtet generate_ip IP_FLIST $IP_FLIST"

for ip in `grep -vE '^(\s*$|#)' $IP_FLIST`
do
    #ip_dir="$ROOTDIR/$(dirname -- $ip)"
    #ip_file=$(basename -- $ip)
    
    #cd $ip_dir
    # need 1 ip file without a batch
    if [ $first -gt 0 ] 
    then
        batch_string="$ROOTDIR/$ip"
        first=0
    else
        batch_string="$batch_string --batch=$ROOTDIR/$ip"
    fi 
    
done

echo "markdtet generate_ip batch_string=$batch_string"

qsys-generate --simulation=VERILOG --simulator=VCS,VCSMX,MODELSIM $batch_string --search-path="$DESIGN_DIR/custom_ip/**/*,$DESIGN_DIR/custom_rtl/**/*,$ROOTDIR/synth/hssi_ets_ts_adapter_hw.tcl,$ROOTDIR/synth/avst_axist_bridge_hw.tcl,$ROOTDIR/synth/irq_bypass_hw.tcl,$ROOTDIR/synth/f2h_interface_tester_hw.tcl,$" 
##custom_ip/**/*; **/*,$"
cleanup || true >/dev/null 2>&1



echo "markdtet generate_ip DONE"
