# Custom rootfs files (2-port 10G PTP (IEEE 1588))

These files are installed onto the target root filesystem by the `rootfs-files` recipe
(see [../README.md](../README.md)).

| File | Installed path |
|------|----------------|
| `README.md` | `/home/root/README.md` |
| `2PortMCQ.sh` | `/home/root/scripts/2PortMCQ.sh` |
| `linkupdown.sh` | `/home/root/scripts/linkupdown.sh` |
| `ping.sh` | `/home/root/scripts/ping.sh` |
| `portRecovery.sh` | `/home/root/scripts/portRecovery.sh` |
| `si5518config.sh` | `/home/root/scripts/si5518config.sh` |

To add more files, place them in this directory and add them to `SCRIPT_FILES` in
`../rootfs-files.bb`.
