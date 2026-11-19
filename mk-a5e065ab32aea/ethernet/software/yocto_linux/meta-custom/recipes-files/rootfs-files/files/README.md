# Custom rootfs files (1-port 25G Ethernet)

These files are installed onto the target root filesystem by the `rootfs-files` recipe
(see [../README.md](../README.md)).

| File | Installed path |
|------|----------------|
| `README.md` | `/home/root/README.md` |
| `1Port.sh` | `/home/root/scripts/1Port.sh` |
| `linkupdown.sh` | `/home/root/scripts/linkupdown.sh` |
| `ping.sh` | `/home/root/scripts/ping.sh` |

To add more files, place them in this directory and add them to `SCRIPT_FILES` in
`../rootfs-files.bb`.
