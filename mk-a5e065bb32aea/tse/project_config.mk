# Define the Quartus project name (matches synth/top.qpf)
PROJECT_NAME := top

# Logical revision / artifact name used under output_files/ and install/.
# kas_build.sh stages the core RBF as ${REVISION_NAME}.core.rbf, which must
# match FPGA_RBF_FILE in software/yocto_linux/meta-custom/conf/tse-solution.inc.
REVISION_NAMES := \
	agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P \

# Define the base revision
BASE_REVISION := $(firstword $(REVISION_NAMES))

MAKE_STEM := mk-a5e065bb32aea-baseline-tse
