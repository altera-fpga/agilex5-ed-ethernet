# Define the Quartus project name
PROJECT_NAME := top

# Define the Quartus revision names (must match FPGA_RBF_FILE / Yocto bitstream name)
REVISION_NAMES := \
	agilex5-mk-a5e065ab32aea_gsrd_ghrd_ETH_1P25G \

# Define the base revision
BASE_REVISION := $(firstword $(REVISION_NAMES))

MAKE_STEM := mk-a5e065ab32aea-baseline-ethernet25G
