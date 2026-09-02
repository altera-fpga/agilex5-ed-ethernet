***************************************************
Please make sure to source the below resources and 
set all the environment variables from setup.sh as below
in the given order
1. set resources
  a. VCS version vcs/U-2023.03-SP2-1 vcs-vcsmx-lic
  b. QUARTUS VERSION 26.1.1
  c. Synopsys_verdi version synopsys_verdi/U-2023.03-SP2-1
  d. ROOTDIR - <user path>/<repo name>/src/hw
2. The below env variables will be set by 
   source <user path>/<repo name>/src/hw/verification/setup.sh
  . WORKDIR=$ROOTDIR
  . QUARTUS_HOME=$QUARTUS_ROOTDIR
  . QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
  . DESIGNWARE_HOME=<synopsys vip location>
  . VERDIR=$WORKDIR/verification
  . DESIGN=src
  . DESIGN_DIR=$ROOTDIR/$DESIGN/
  . UVM_HOME=$VCS_HOME/etc/uvm-1.2
***************************************************
to run single UVM test:

1. cd $ROOTDIR/verification/scripts

2. Below is a one time run that needs to be given when compiling
   the DUT for the first time or if there is any change in the IP

   10G MDK-065A ETH DESIGN
   make -f Makefile.mk cmplib HSSI_10G=1
   25G MDK-065A ETH DESIGN
   make -f Makefile.mk cmplib HSSI_25G=1

3. Run below make commands to compile and elaborate the DUT and TESTBENCH
   
   10G MDK-065A ETH DESIGN
   make -f Makefile.mk build HSSI_10G=1
   25G MDK-065A ETH DESIGN
   make -f Makefile.mk build HSSI_25G=1

4. Run below command to run a sequence

  make -f Makefile.mk run SEQNAME=<sequence name>
  Eg:
  make -f Makefile.mk run SEQNAME=sm_eth_all_ports_64B_traffic_seq

5. Steps 3 and 4 can be combined and run in a single step
   
   make -f Makefile.mk build run SEQNAME=sm_eth_all_ports_64B_traffic_seq

6. Dumping a waveform
  Please add option DUMP=1 to steps 3 and 4 or step 5 to enable waveform dumping

  Eg 1:
  make -f Makefile.mk build DUMP=1
  make -f Makefile.mk run SEQNAME=sm_eth_all_ports_64B_traffic_seq DUMP=1
  
  Eg 2:
  make -f Makefile.mk build run SEQNAME=sm_eth_all_ports_64B_traffic_seq DUMP=1

7. Results directory
  . The test results are stored at $ROOTDIR/verification/sim
  . Everytime step 2 is re-run, the previous sim directory gets renamed to sim.# and a new sim directory gets created
  . The logs and waveform are dumped in $ROOTDIR/verification/sim/<sequence name> directory
  . If same sequence is re-run, the previous result dir for that sequence gets renamed to $ROOTDIR/verification/sim/<sequence name>.#
    and a new $ROOTDIR/verification/sim/<sequence name> directory gets created

***************************************************
List of tests that can be run standalone:

// Only User client pkt generation enabled
// This sequence triggers traffic generation from user client
sm_eth_user0_seq.sv"

// Both, user and DMA path with descriptor polling disabled
// This sequence triggers traffic on both user client and DMA path, with payload
// set to 64B for each of the descriptors
sm_eth_all_ports_64B_traffic_seq.sv"

