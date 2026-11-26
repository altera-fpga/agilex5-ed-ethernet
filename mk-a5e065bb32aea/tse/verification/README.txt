Agilex 5E Triple-Speed Ethernet (TSE) UVM simulation
====================================================

These instructions run the verification testbench in a local (non-arc) environment.
You do not need Intel arc resources.

Tool dependencies
-----------------
Install and license the following before building or running:

  1. Altera Quartus Prime Pro / ACDS
     - Provides qsys-generate, IP simulation models, and Quartus EDA sim libs
     - Verified with: ACDS 26.3
     - Set:  export QUARTUS_ROOTDIR=<quartus_install>/quartus

  2. Synopsys VCS / VCSMX (64-bit) with UVM 1.2
     - Verified with: VCS U-2023.03-SP2-1
     - Set:  export VCS_HOME=<vcs_install>
     - Ensure vcs, vlogan, and related tools are on PATH

  3. Synopsys DesignWare Verification IP (AMBA SVT / AXI)
     - Required for dw_vip_setup and AXI VIP compile
     - Verified with VIP package vip_W-2025.03C (or compatible amba_svt release)
     - Set:  export DESIGNWARE_HOME=<dw_vip_install>
       (directory that contains bin/dw_vip_setup and vip/svt/amba_svt)

  4. Host utilities
     - bash, make (gmake compatible), perl, python3, rsync
     - A C/C++ toolchain usable by VCS DPI and DesignWare VIP setup (gcc/g++)

Optional (waveform debug only):

  - Synopsys Verdi (matched to your VCS version)

Environment setup (no arc)
--------------------------
From a bash shell, set tool roots, then source setup.sh only:

  export QUARTUS_ROOTDIR=<path_to>/quartus
  export VCS_HOME=<path_to_vcs>
  export DESIGNWARE_HOME=<path_to_dw_vip>
  # Optional if IP is not beside Quartus:
  # export IMPORT_IP_ROOTDIR=<path_to>/ip

  source <repo>/a5e065b-mod-devkit-exp-prod/src/hw/verification/env/setup.sh

setup.sh sets ROOTDIR to .../src/hw (parent of verification/) when ROOTDIR is unset.

Note: env/env.sh launches an Intel-internal "arc shell" and is not required for
customer or local runs. Prefer setup.sh as shown above.

Build and run
-------------
1. cd $ROOTDIR/verification/scripts

2. One-time (or after IP/RTL changes): compile IP libraries and VIP

     make -f Makefile.mk cmplib

3. Compile and elaborate DUT + testbench

     make -f Makefile.mk build

4. Run a sequence

     make -f Makefile.mk run SEQNAME=<sequence_name>
     Example:
     make -f Makefile.mk run SEQNAME=sm_tse_h2d0_path_seq

5. Combine build and run

     make -f Makefile.mk build run SEQNAME=sm_tse_h2d0_path_seq

6. Waveform dump: add DUMP=1 to build and/or run

     make -f Makefile.mk build DUMP=1
     make -f Makefile.mk run SEQNAME=sm_tse_h2d0_path_seq DUMP=1

7. Results
   - Output under $ROOTDIR/verification/sim
   - Re-running cmplib renames the previous sim/ directory to sim.#
   - Per-sequence logs (and waves if DUMP=1) are under
     $ROOTDIR/verification/sim/<sequence_name>/

Supported standalone sequences
------------------------------
// DMA only port 0 -> 1 sequences
// In 1-channel DUT, port 0 -> 0 loopback is tested
sm_tse_h2d0_90B_seq
sm_tse_h2d0_path_seq
sm_tse_h2d0_fifo_depth_cover_seq
sm_tse_h2d0_pkt_err_seq

Unsupported / not enabled
-------------------------
Descriptor-poll sequences currently hang (UVM PH_TIMEOUT waiting for
all_dma_desc_done while poll mode keeps fetching descriptors). They are
commented out of the sequence include list and are not supported:

  sm_tse_h2d0_path_poll_en_seq
  sm_tse_h2d1_path_poll_en_seq

Below sequences are unsupported for 1-channel DUT

// DMA only port 1 -> 0 sequences
sm_tse_h2d1_90B_seq
sm_tse_h2d1_path_seq
sm_tse_h2d1_fifo_depth_cover_seq

// Both DMA ports enabled sequences
sm_tse_all_dma_ports_traffic_seq
sm_tse_all_dma_ports_64B_traffic_seq
