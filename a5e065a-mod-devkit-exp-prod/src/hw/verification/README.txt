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

// Only DMA path with descriptor polling disabled
// This sequence triggers DMA to fetch data from host and transmit to ethernet subsys which loopsback to
// DMA followed by write on host memory by DMA. The payload length and number of descriptors are set so as to
// exercise the TX/RX FIFO depths
sm_eth_random_seq.sv"
sm_eth_h2d0_path_seq.sv"
sm_eth_h2d0_90B_seq.sv"
sm_eth_h2d0_511B_seq.sv"

// Only User client pkt generation enabled
// This sequence triggers traffic generation from user client
sm_eth_user0_seq.sv"

// Both, user and DMA path with descriptor polling disabled
// This sequence triggers traffic on both user client and DMA path, with payload
// set to 64B for each of the descriptors
sm_eth_all_ports_64B_traffic_seq.sv"
sm_eth_all_ports_traffic_seq.sv"

// DMA path enabled with descriptor polling
// Below sequences are configured with descriptor polling enabled for DMA
sm_eth_h2d0_path_poll_en_seq.sv"

// CSR sequences
sm_eth_hssi_csr_seq.sv"
sm_eth_ptp_bridge_csr_seq.sv"
sm_eth_msgdma_csr_seq.sv"

// SFP sequences
// This sequence configures I2C TFR_CMD register to initiate an I2C read from 
// the controller. The read data is then fetched from SFP controller CSR
sm_eth_sfp_a0_fifo_read_seq
sm_eth_sfp_a2_fifo_read_seq

// In the below sequence, poller FSM is enabled for both, A0 and A2 pages
// upon completion, the read data is fetched from shadow registers
sm_eth_sfp_a0_a2_poll_enable_seq

***************************************************
How to Run UVM Regressions?:
*****************************
1) cd $ETH_ROOTDIR/scripts
#Note: Sequence list for regression run is taken from the regress script itself
2)  Need to pass the arguments as per the variant
#  10G MDK-065A ETH Design
   "perl regress_run.pl nocov 10G"
#  25G MDK-065A ETH Design
   "perl regress_run.pl nocov 25G"
3) Command to run regression with coverage
#  10G MDK-065A ETH Design
   "perl regress_run.pl cov 10G"
#  25G MDK-065A ETH Design
   "perl regress_run.pl cov 25G"
4) Results are created in a sim directory ($ROOTDIR/sim/<sequence name>).Check stimulate_$seqname.log for Simulation result
5) To generate coverage report for a regression, execute:
   #“urg -dir <$VERDIR/sim/simv.vdb> <$VERDIR/sim/regression.vdb> -format both -dbname final.vdb”
   #Note: The default report directory is “urgReport” and coverage database (regression.vdb) will be present in the same directory
6)To open DVE of a single regression or testcase, execute:  ”dve -full64 -cov -covdir simv.vdb regression.vdb &”
7)To open DVE of a merged regression, execute: ”dve -full64 -cov -covdir <dirname.vdb> &
8)To load the coverage report, execute: “firefox urgReport/dashboard.html”
