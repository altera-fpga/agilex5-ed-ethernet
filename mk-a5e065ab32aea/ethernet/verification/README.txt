////////////////////////////////////////////////////////////////////////////////////////////////
IMP NOTE TO RUN TESTS in SMPLUS ETH DESIGN UVM TB.
-------------------------------------------------------
There are 2 variants in SMPLUS ETH DESIGN. i.e 10G,25G
Below steps needs to be done for each variant in a separate xterm.
Two variants cannot be run in a single xterm. This needs to be taken care primarily.
////////////////////////////////////////////////////////////////////////////////////////////////
cd <clone>/src/hw/verification
source env/env.sh
source env/setup.sh

***************************************************
to run single UVM test:

1. cd $ROOTDIR/verification/scripts

2. Below is a one time run that needs to be given when compiling
   the DUT for the first time or if there is any change in the IP
   10G SMPLUS ETH DESIGN
   make -f Makefile.mk cmplib HSSI_10G=1
   25G SMPLUS ETH DESIGN
   make -f Makefile.mk cmplib HSSI_25G=1

3. Run below make command to compile and elaborate the DUT and TESTBENCH
   
   10G SMPLUS ETH DESIGN
   make -f Makefile.mk build HSSI_10G=1
   25G SMPLUS ETH DESIGN
   make -f Makefile.mk build HSSI_25G=1

4. Run below command to run a sequence

  make -f Makefile.mk run SEQNAME=<sequence name>
  Eg:
  make -f Makefile.mk run SEQNAME=sm_eth_all_ports_64B_traffic_seq

5. Dumping a waveform
  Please add option DUMP=1 t0 steps 3 and 4 to enable waveform dumping

6. Results directory
  The test results are stored at $ROOTDIR/verification/sim
  Everytime step 2 is re-run, the previous sim directory gets renamed to sim.# and a new sim directory gets created
  The logs and waveform are dumped in $ROOTDIR/verification/sim/<sequence name> directory
  If same sequence is re-run, the previous result dir for that sequence gets renamed to $ROOTDIR/verification/sim/<sequence name>.#


***************************************************
List of tests that can be run standalone:

// Only DMA path with descriptor polling disabled
sm_eth_random_seq.sv"
sm_eth_h2d0_path_seq.sv"
sm_eth_h2d0_90B_seq.sv"
sm_eth_h2d0_511B_seq.sv"

// Only User client pkt generation enabled
sm_eth_user0_seq.sv"

// Both, user and DMA path with descriptor polling disabled
sm_eth_all_ports_64B_traffic_seq.sv"
sm_eth_all_ports_traffic_seq.sv"

// DMA path enabled with descriptor polling
sm_eth_h2d0_path_poll_en_seq.sv"

// CSR sequences
sm_eth_hssi_csr_seq.sv"
sm_eth_ptp_bridge_csr_seq.sv"
sm_eth_msgdma_csr_seq.sv"

***************************************************
How to Run UVM Regressions?:
*****************************
1) cd $ETH_ROOTDIR/scripts
#Note: Sequence list for regression run is taken from the regress script itself
2)  Need to pass the arguments as per the variant
#  10G SMPLUS ETH Design
   "perl regress_run.pl nocov 10G"
#  25G SMPLUS ETH Design
   "perl regress_run.pl nocov 25G"
3) Command to run regression with coverage
#  10G SMPLUS ETH Design
   "perl regress_run.pl cov 10G"
#  25G SMPLUS ETH Design
   "perl regress_run.pl cov 25G"
4) Results are created in a sim directory ($ROOTDIR/sim/<sequence name>).Check stimulate_$seqname.log for Simulation result
5) To generate coverage report for a regression, execute:
   #“urg -dir <$VERDIR/sim/simv.vdb> <$VERDIR/sim/regression.vdb> -format both -dbname final.vdb”
   #Note: The default report directory is “urgReport” and coverage database (regression.vdb) will be present in the same directory
6)To open DVE of a single regression or testcase, execute:  ”dve -full64 -cov -covdir simv.vdb regression.vdb &”
7)To open DVE of a merged regression, execute: ”dve -full64 -cov -covdir <dirname.vdb> &
8)To load the coverage report, execute: “firefox urgReport/dashboard.html”
