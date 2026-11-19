KERNEL_REPO = "git://github.com/altera-innersource/applications.fpga.soc.linux-socfpga.git"
SRCREV = "SED-Ethernet-PTP-Agilex5-Quartus-26.3-Rel-D1.1"
LINUX_VERSION = "6.18.37"
KBRANCH = "socfpga-6.18.37-lts-ethernet-sed"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

# Append GSRD specific kernel config fragments and Patches.
FILESEXTRAPATHS:prepend := "${THISDIR}/device-tree:${THISDIR}/linux-socfpga-lts/configs:${THISDIR}/linux-socfpga-lts/patches:"

# Build TSE DTB from kernel sources (arch/${ARCH}/boot/dts/intel/*.dts).
# FPGA_LINUX_DTB_FILE comes from meta-custom/conf/tse-solution.inc via TSE_DESIGN.
# No prebuilt .dtb under device-tree/ is required.
KERNEL_DEVICETREE:append = " intel/${FPGA_LINUX_DTB_FILE}"

IMAGE_BOOT_FILES:append = " ${FPGA_LINUX_DTB_FILE}"

SRC_URI:append = " file://config-eth.scc \
"

# Optional override: if someone still drops .dts/.dtsi under device-tree/, pull them in.
# Not required when DTS is already on KBRANCH (socfpga-6.18.37-lts-ethernet-sed).
python __anonymous () {
    import os

    layerdir = d.getVar("LAYERDIR_meta_custom")
    tree = os.path.join(layerdir, "recipes-kernel/linux/device-tree")
    if not os.path.isdir(tree):
        return

    for fname in os.listdir(tree):
        if fname.endswith(".dts") or fname.endswith(".dtsi"):
            d.appendVar("SRC_URI", " file://%s" % fname)
}

do_patch:append() {
    DTS_SRC_DIR="${WORKDIR}/sources"
    DTS_DST_DIR="${S}/arch/arm64/boot/dts/intel"
    MAKEFILE="${DTS_DST_DIR}/Makefile"
    # BitBake does not expand ${VAR%.dtb}; assign then use shell suffix removal
    dtb_file="${FPGA_LINUX_DTB_FILE}"
    dts_name="${dtb_file%.dtb}.dts"

    if [ -z "${dtb_file}" ]; then
        bbfatal "FPGA_LINUX_DTB_FILE is empty (check TSE_DESIGN / tse-solution.inc)"
    fi

    # Prefer optional out-of-tree override; else require in-kernel DTS
    if [ -f "${DTS_SRC_DIR}/${dts_name}" ]; then
        install -m 0644 "${DTS_SRC_DIR}/${dts_name}" "${DTS_DST_DIR}"
        bbnote "Override: installed ${dts_name} from device-tree/"
    elif [ -f "${DTS_DST_DIR}/${dts_name}" ]; then
        bbnote "Using in-kernel DTS: ${DTS_DST_DIR}/${dts_name}"
    else
        bbfatal "DTS ${dts_name} not in kernel (${DTS_DST_DIR}) or device-tree/ (check TSE_DESIGN / tse-solution.inc)"
    fi

    if [ -d "${DTS_SRC_DIR}" ]; then
        find "${DTS_SRC_DIR}" -type f -name "*.dtsi" | while read DTSI; do
            install -m 0644 "${DTSI}" "${DTS_DST_DIR}/$(basename "${DTSI}")"
        done
    fi

    if ! grep -Fq "${dtb_file}" "${MAKEFILE}"; then
        echo "dtb-\$(CONFIG_ARCH_INTEL_SOCFPGA) += ${dtb_file}" >> "${MAKEFILE}"
    fi
}

addtask do_patch after do_unpack before do_configure

# Auto-build DTB from in-kernel DTS (no manual .dtb)
do_compile:append() {
	if [ -n "${FPGA_LINUX_DTB_FILE}" ]; then
		dtb_rel="intel/${FPGA_LINUX_DTB_FILE}"
		bbnote "Building TSE DTB from kernel: ${dtb_rel}"
		oe_runmake ${dtb_rel} || oe_runmake dtbs
	fi
}

do_deploy:prepend() {
	if [ -z "${FPGA_LINUX_DTB_FILE}" ]; then
		bbfatal "FPGA_LINUX_DTB_FILE is empty (check TSE_DESIGN / tse-solution.inc)"
	fi

	dtb_name="${FPGA_LINUX_DTB_FILE}"
	dtb_src=""

	for cand in \
		"${B}/arch/${ARCH}/boot/dts/intel/${dtb_name}" \
		"${B}/arch/${ARCH}/boot/dts/${dtb_name}" \
		"${D}${nonarch_base_libdir}/firmware/${dtb_name}" \
		"${D}/boot/${dtb_name}"; do
		if [ -f "${cand}" ]; then
			dtb_src="${cand}"
			break
		fi
	done

	if [ -z "${dtb_src}" ]; then
		dts="${S}/arch/${ARCH}/boot/dts/intel/${dtb_name%.dtb}.dts"
		if [ ! -f "${dts}" ]; then
			bbfatal "Cannot find kernel-built DTB or DTS for ${dtb_name}. Expected ${dts}"
		fi
		bbnote "Compiling ${dtb_name} with dtc from ${dts}"
		dtb_src="${B}/${dtb_name}"
		dtc -I dts -O dtb -o "${dtb_src}" \
			-i "${S}/arch/${ARCH}/boot/dts" \
			-i "${S}/arch/${ARCH}/boot/dts/intel" \
			"${dts}" || bbfatal "dtc failed for ${dts}"
	fi

	if [ -n "${DEPLOYDIR}" ]; then
		install -d "${DEPLOYDIR}"
		install -m 0644 "${dtb_src}" "${DEPLOYDIR}/${dtb_name}"
	fi
	if [ -n "${LINUXDEPLOYDIR}" ]; then
		install -d "${LINUXDEPLOYDIR}"
		install -m 0644 "${dtb_src}" "${LINUXDEPLOYDIR}/${dtb_name}"
	fi
	bbnote "Staged TSE DTB: ${dtb_src} -> deploy/${dtb_name}"
}

do_deploy:append() {
        if [ ! -f "${DEPLOYDIR}/kernel.itb" ]; then
                bbfatal "kernel.itb not found in ${DEPLOYDIR}"
        fi
        if [ ! -f "${B}/.config" ]; then
                bbfatal "kernel .config not found at ${B}/.config"
        fi
        mv -f "${DEPLOYDIR}/kernel.itb" "${DEPLOYDIR}/kernel_sed.itb"
}
