Please execute the below steps before executing UVM TB:
. source <user path>/<repo_name>/src/hw/verification/env/env.sh
. source <user path>/<repo_name>/src/hw/verification/env/setup.sh

# There are 2 TB variants:
  1. cross port loopback:
    . port 0 tx is connected to port 1 rx
    . port 1 tx is connected to port 0 rx
  2. port level loopback: This variant is created to test PTP Timestamp accuracy. Currently tested with 64B payload length
    . port 0 tx is connected to port 0 rx
    . port 1 tx is connected to port 1 rx

to run single UVM test:

1. cd $ROOTDIR/verification/scripts

2. Below is a one time run that needs to be given when compiling
   the DUT for the first time or if there is any change in the IP

   make -f Makefile.mk cmplib

3. Run below make command to compile and elaborate the DUT and TESTBENCH
   
   make -f Makefile.mk build

4. Run below command to run a sequence

  make -f Makefile.mk run SEQNAME=<sequence name>
  Eg:
  make -f Makefile.mk run SEQNAME=sm_ptp_h2d0_path_seq

5. Steps 3 and 4 can be combined and run in a single step

  make -f Makefile.mk build run SEQNAME=sm_ptp_h2d0_path_seq

6. Dumping a waveform
  Please add option DUMP=1 to steps 3 and 4 or step 5 to enable waveform dumping

  Eg 1:
  make -f Makefile.mk build DUMP=1
  make -f Makefile.mk run SEQNAME=sm_ptp_h2d0_path_seq DUMP=1
  
  Eg 2:
  make -f Makefile.mk build run SEQNAME=sm_ptp_h2d0_path_seq DUMP=1

7. Enabled DV for cross port / port level loopback
   . All the tests run on cross port port loopback connection be default
   . To run port level loopback, please add PORT_LB=1 during 'build' step
     in step 3 and step 5
     Eg:
        make -f Makefile.mk build PORT_LB=1
        make -f Makefile.mk build run SEQNAME=sm_ptp_h2d0_path_seq PORT_LB=1

8. Results directory
  . The test results are stored at $ROOTDIR/verification/sim
  . Everytime step 2 is re-run, the previous sim directory gets renamed to sim.# and a new sim directory gets created
  . The logs and waveform are dumped in $ROOTDIR/verification/sim/<sequence name> directory
  . If same sequence is re-run, the previous result dir for that sequence gets renamed to $ROOTDIR/verification/sim/<sequence name>.#
    and a new $ROOTDIR/verification/sim/<sequence name> directory gets created

***************************************************
To trigger regression

1. cd $ROOTDIR/verification/scripts

2. Run the below command to trigger regression without cov

   perl regress_run.pl nocov

   To trigger regression with cov

   perl regress_run.pl cov

***************************************************
List of tests that  can be run standalone:

// DMA only port 0 sequences
sm_ptp_h2d0_path_seq
sm_ptp_h2d0_90B_seq
sm_ptp_h2d0_fifo_depth_cover_seq

// DMA only port 1 sequences
sm_ptp_h2d1_path_seq
sm_ptp_h2d1_90B_seq
sm_ptp_h2d1_fifo_depth_cover_seq

// Both DMA ports enabled sequences
sm_ptp_all_dma_ports_traffic_seq
sm_ptp_all_dma_ports_64B_traffic_seq

// user client sequences
sm_ptp_user0_seq
sm_ptp_user1_seq
sm_ptp_user1_user0_seq

// DMA and user client enabled sequences
sm_ptp_all_dma_user0_path_seq
sm_ptp_all_dma_user1_path_seq
sm_ptp_all_ports_traffic_seq
sm_ptp_h2d0_all_user_path_seq
sm_ptp_h2d1_all_user_path_seq
sm_ptp_h2d0_user0_path_seq
sm_ptp_h2d0_user1_path_seq
sm_ptp_h2d1_user0_path_seq

