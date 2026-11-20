SUMMARY = "PacketSwitch IP configurator for Linux on ARM"
DESCRIPTION = "PacketSwitch IP configurator executable for Linux to control PacketSwitch module"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "file://packetswitch_v1.1.tar.gz"
S = "${UNPACKDIR}/packetswitch_v1.1"

#do_compile () {
#	#bbnote "PacketSwitch Executing compile... - ${S}. Workdir: ${UNPACKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${UNPACKDIR}"
#	#cd ${S}
#	oe_runmake
#}

#do_install () {
#	#bbnote "PacketSwitch Executing install... - ${S}. Workdir: ${UNPACKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${UNPACKDIR}"
#	install -d ${D}/${bindir}
#	install -p ${S}/packetswitch ${D}/${bindir}
#}

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/packetswitch"
