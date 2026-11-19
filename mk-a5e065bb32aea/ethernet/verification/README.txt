Please execute the below steps to set proper env variables prior to executing the testbench:

cd <clone>/src/hw/verification
source env/env.sh
source env/setup.sh

***************************************************
to run single UVM test:

1. cd $ROOTDIR/verification/scripts

2. Below is a one time run that needs to be given when compiling
   the DUT for the first time or if there is any change in the IP

   make -f Makefile.mk cmplib

3. Run below make commands to compile and elaborate the DUT and TESTBENCH
   
   make -f Makefile.mk build

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
To trigger regression

1. cd $ROOTDIR/verification/scripts

There are different scripts available for DMA tests and SFP tests.

//For DMA and other tests 
2. Run the below command to trigger regression without cov

   perl regress_run.pl nocov

   To trigger regression with cov

   perl regress_run.pl cov

//For SFP tests
2. Run the below command to trigger regression without cov

   perl regress_sfp.pl nocov

   To trigger regression with cov

   perl regress_sfp.pl cov

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
