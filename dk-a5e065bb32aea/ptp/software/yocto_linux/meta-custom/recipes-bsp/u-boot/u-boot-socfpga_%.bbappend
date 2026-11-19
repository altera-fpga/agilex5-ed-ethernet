FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:agilex5 = " file://si5518_fpga.patch"
SRC_URI:append:agilex5e = " file://si5518_fpga.patch"
SRC_URI:append:agilex5_dk_a5e065bb32aes1 = " file://si5518_fpga.patch"
SRC_URI:append:agilex5_dk_a5e065bb32aes1_b0 = " file://si5518_fpga.patch"
