SUMMARY = "PTP Bridge IP configurator for Linux on ARM"
DESCRIPTION = "PTP Bridge IP configurator executable for Linux to control ptpbridge module"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1ebbd3e34237af26da5dc08a4e440464"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
 
SRC_URI = "file://ptpbridge_v1.1.tgz"
S = "${WORKDIR}/ptpbridge_v1.1"

#do_compile () {
#	#bbnote "PTPBridge Executing compile... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	#cd ${S}
#	oe_runmake
#}

#do_install () {
#	#bbnote "PTPBridge Executing install... - ${S}. Workdir: ${WORKDIR}"
#	#echo -n "Source Dir - ${S}. Workdir: ${WORKDIR}"
#	install -d ${D}/${bindir}
#	install -p ${S}/ptpbridge  ${D}/${bindir}
#}

inherit autotools pkgconfig
FILES:${PN} += "${bindir}/ptpbridge"
