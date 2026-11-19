SUMMARY = "Add custom files to the Linux rootfs"
DESCRIPTION = "Recipe to install generic files (like README, documentation, scripts) into the target rootfs"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit allarch

FILE_DIR ?= "/home/root"
FILE_NAME ?= "README.md"
SRC_URI = "file://${FILE_NAME} file://1Port.sh file://linkupdown.sh  file://ping.sh"

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${FILE_DIR}
    install -m 0644 ${S}/${FILE_NAME} ${D}${FILE_DIR}/${FILE_NAME}

    install -d ${D}${FILE_DIR}/scripts
    install -m 0644 ${S}/1Port.sh ${D}${FILE_DIR}/scripts/1Port.sh
    install -m 0644 ${S}/linkupdown.sh ${D}${FILE_DIR}/scripts/linkupdown.sh
    install -m 0644 ${S}/ping.sh ${D}${FILE_DIR}/scripts/ping.sh

}
FILES:${PN} += "${FILE_DIR}/${FILE_NAME} ${FILE_DIR}/scripts/1Port.sh ${FILE_DIR}/scripts/linkupdown.sh ${FILE_DIR}/scripts/ping.sh"
