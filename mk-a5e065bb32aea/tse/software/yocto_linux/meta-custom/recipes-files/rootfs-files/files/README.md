# Custom rootfs files (Ethernet SED)

These files are installed onto the target root filesystem by the `rootfs-files` recipe
(see [../README.md](../README.md)).

| File | Installed path | Purpose |
|------|----------------|---------|
| `README.md` | `/home/root/README.md` | Placeholder / notes on target |
| `1Port.sh` | `/home/root/scripts/1Port.sh` | 1-port Ethernet helper script |
| `linkupdown.sh` | `/home/root/scripts/linkupdown.sh` | Link up/down helper |
| `ping.sh` | `/home/root/scripts/ping.sh` | Ping helper |

To add more files, place them in this directory and update `SRC_URI` / `do_install` in
`../rootfs-files.bb`.
