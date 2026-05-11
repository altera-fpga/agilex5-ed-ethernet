***************************************************
Please make sure to source the below resources and 
set all the environment variables from setup.sh as below
in the given order
1. set resources
  a. VCS version vcs/U-2023.03-SP2-1 vcs-vcsmx-lic
  b. QUARTUS VERSION 25.3
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

   make -f Makefile.mk cmplib

3. Run below make commands to compile and elaborate the DUT and TESTBENCH
   
   make -f Makefile.mk build

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
sm_eth_h2d0_fifo_depth_cover_seq.sv"

// Only User client pkt generation enabled
// This sequence triggers traffic generation from user client
sm_eth_user0_seq.sv"

// Both, user and DMA path with descriptor polling disabled
// This sequence triggers traffic on both user client and DMA path, with payload
// set to 64B for each of the descriptors
sm_eth_all_ports_64B_traffic_seq.sv"

// DMA path enabled with descriptor polling
// Below sequences are configured with descriptor polling enabled for DMA
sm_eth_h2d0_path_poll_en_seq.sv"
sm_eth_all_ports_dma_desc_poll_en_seq.sv

// SFP sequences
// This sequence configures I2C TFR_CMD register to initiate an I2C read from 
// the controller. The read data is then fetched from SFP controller CSR
sm_eth_sfp_a0_fifo_read_seq
sm_eth_sfp_a2_fifo_read_seq

// In the below sequence, poller FSM is enabled for both, A0 and A2 pages
// upon completion, the read data is fetched from shadow registers
sm_eth_sfp_a0_a2_poll_enable_seq
