SUMMARY = "PacketSwitch IP configurator for Linux on ARM"
DESCRIPTION = "PacketSwitch IP configurator executable for Linux to control PacketSwitch module"
HOMEPAGE = "https://github.com/altera-innersource/applications.fpga.hps.packetswitch.git"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "git://github.com/altera-innersource/applications.fpga.hps.packetswitch.git;protocol=http;branch=SM_PacketSwitch"
SRCREV = "${AUTOREV}"

#do_compile () {
#	#bbnote "PacketSwitch Executing compile... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	#cd ${S}
#	oe_runmake
#}

#do_install () {
#	#bbnote "PacketSwitch Executing install... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	install -d ${D}/${bindir}
#	install -p ${S}/packetswitch ${D}/${bindir}
#}

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/packetswitch"
