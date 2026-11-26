# rootfs-files Recipe

This recipe provides a simple, extensible mechanism to deploy generic files (documents, scripts, configs, static binaries, static libraries, etc.) into the target root filesystem.

## Purpose

The `rootfs-files` recipe allows you to bundle static content into your Yocto images without writing complex recipes or modifying existing packages. It's ideal for:

- Platform README files and documentation with getting-started instructions
- System configuration files
- Custom scripts or utilities
- Precompiled static binaries
- Static libraries
- Any static content needed on the target

## Current Behavior (this Ethernet design)

By default, the recipe installs from `files/`:

| Source | Target on rootfs |
|--------|------------------|
| `files/README.md` | `/home/root/README.md` |
| `files/1Port.sh` | `/home/root/scripts/1Port.sh` |
| `files/linkupdown.sh` | `/home/root/scripts/linkupdown.sh` |
| `files/ping.sh` | `/home/root/scripts/ping.sh` |

See `files/README.md` for a short description of each script.

## Configuration Variables

You can customize the installation path and primary filename via BitBake variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `FILE_DIR` | `/home/root` | Target directory for `FILE_NAME` and the `scripts/` subdirectory |
| `FILE_NAME` | `README.md` | Name of the primary file installed under `FILE_DIR` |

### Example: Installing an extra config under `/etc`

1. Add your file to `files/`, e.g., `files/custom.conf`
2. Override variables / extend `do_install` in the recipe or a bbappend
3. Update `SRC_URI` in `rootfs-files.bb` to include `file://custom.conf`

## Adding Multiple Files

The recipe already installs multiple files. To add more, extend `SRC_URI`, `do_install`, and `FILES:${PN}` in `rootfs-files.bb` (see current pattern for the Ethernet helper scripts).

## Testing

Build and verify the recipe standalone (from a `kas shell kas.yml` environment):

```bash
bitbake rootfs-files
oe-pkgdata-util list-pkg-files rootfs-files
```

Expected paths include:
```text
/home/root/README.md
/home/root/scripts/1Port.sh
/home/root/scripts/linkupdown.sh
/home/root/scripts/ping.sh
```

To test in a full image, ensure the package is in `IMAGE_INSTALL` and build:
```bash
bitbake console-image-minimal
# or: bitbake gsrd-console-image
```

After booting, verify:
```bash
cat /home/root/README.md
ls /home/root/scripts/
```
