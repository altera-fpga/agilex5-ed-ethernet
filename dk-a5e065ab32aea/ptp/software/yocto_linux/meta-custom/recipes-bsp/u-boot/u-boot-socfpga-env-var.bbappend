# u-boot-env.txt is processed in do_compile (see u-boot-socfpga-env-var.bb).
# Edit it before MACHINE_STRIP subst + mkenvimage.
do_compile:prepend() {
	ENV_FILE="${UNPACKDIR}/u-boot-env.txt"
	if [ ! -f "${ENV_FILE}" ]; then
		bbfatal "u-boot-env.txt not found at ${ENV_FILE}"
	fi
	sed -i 's/^bootfile=kernel\.itb$/bootfile=kernel_sed.itb/' "${ENV_FILE}"
	bbnote "Updated bootfile in ${ENV_FILE} -> kernel_sed.itb"
}
