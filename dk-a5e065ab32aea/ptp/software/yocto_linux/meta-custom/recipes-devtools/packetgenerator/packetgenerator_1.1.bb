SUMMARY = "Packet Generator configurator for Linux on ARM"
DESCRIPTION = "Packet Generator configurator executable for Linux to control pktgen module"
HOMEPAGE = "https://github.com/altera-fpga/agilex5-ed-ethernet"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "https://raw.githubusercontent.com/altera-fpga/agilex5-ed-ethernet/2b046d58376a64f56c055e310c8cf7a7ba367dd7/a5e065a-mod-devkit-exp-prod/src/sw/yocto/meta-agilex5-sed/recipes-devtools/packetgenerator/files/packetgenerator_v1.1.tgz"
SRC_URI[sha256sum] = "b46af10f5c80cbff705b13869c1e25dfce3ad63248ff02b5d39c5c6f0d262835"
S = "${WORKDIR}/packetgenerator_v1.1"


#do_compile () {
#	#bbnote "Packetgenerator Executing compile... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	#cd ${S}
#	oe_runmake
#}

#do_install () {
#	#bbnote "Packetgenerator Executing install... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	install -d ${D}/${bindir}
#	install -p ${S}/packetgenerator  ${D}/${bindir}
#}

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/packetgenerator"
