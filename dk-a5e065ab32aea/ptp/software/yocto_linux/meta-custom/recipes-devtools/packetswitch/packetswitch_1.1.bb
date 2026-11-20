SUMMARY = "PacketSwitch IP configurator for Linux on ARM"
DESCRIPTION = "PacketSwitch IP configurator executable for Linux to control PacketSwitch module"
HOMEPAGE = "https://github.com/altera-fpga/agilex5-ed-ethernet"
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7c6367005511b6ea56cf4966d5ba33fb"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "file://packetswitch_v1.1.tar.gz"
SRC_URI[sha256sum] = "ece0060952a433923b64145a8daf0aafee3f767c1688b8cc3680eaeb2b0c3410"
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
