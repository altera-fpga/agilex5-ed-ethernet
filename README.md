# Altera® Agilex™ 5 Ethernet-based System Example Designs

## Description

The Ethernet-based System Example Design demonstrates Ethernet functionality of the Altera Agilex 5 FPGA supporting multiple MACs along with providing other ethernet-related features like 1588PTP. This repo contains designs that showcase 1-Port 10GbE and 25GbE Ethernet designs on Agilex 5 onboard transceivers and 2-Port 10GbE / 25GbE PTP (IEEE 1588) designs on Agilex 5 onboard transceivers leveraging the Ethernet Altera® FPGA IP. A soft-MAC-based Triple-Speed Ethernet (TSE) design is also available in the repo that closely resembles the generic Ethernet design but provides Ethernet functionality through the TSE soft MAC.

The primary components in the design are:

- Hard Processor Subsystem (HPS)
- Channelized Modular Scatter-Gather Direct Memory Access (MSGDMA)
- Packet Switch module
- Packet Generator
- Ethernet MAC IP

The diagram below shows a generic Ethernet-based System Example Design which is leveraged across all designs on Altera Agilex 5 FPGAs. Additional blocks are enabled (PTP) as required for the specific designs.

![Altera® Agilex™ 5 Ethernet System Example Design block diagram](doc/SM_Ethernet_block_diagram.png)

Important features of the design include:

- Ethernet Software stack running on the HPS that handles control/management along with data generation.
- Programmable packet routing functionality handled within the Packet Switch module. Some designs do not support this functionality.
- DMA engines to efficiently transfer data between the HPS and Ethernet MAC

For more information, refer to the [documentation](https://altera-fpga.github.io/rel-25.3/ed-demo-list/ed-list/) site.

## Repository Structure

Directory structure used in this example design:

```bash
.
├── doc
├── dk-a5e065ab32aea
│   └── ptp                   # 2x25G PTP (IEEE 1588) on Agilex™ 5 FPGA E-Series 065A Premium Development Kit (DK-A5E065AB32AEA) 
├── dk-a5e065bb32aea
│   └── ptp                   # 2x10G PTP (IEEE 1588) on Agilex™ 5 FPGA SoC E-Series Premium Development Kit (ES) (DK-A5E065BB32AES1)
├── mk-a5e065bb32aea
│   ├── ethernet              # 1x10G Ethernet on Altera® Agilex™ 5 FPGA SoC E-Series 065B Modular Development Kit (MK-A5E065BB32AEA)
│   └── tse                   # 1-port Triple Speed Ethernet on Altera® Agilex™ 5 FPGA SoC E-Series 065B Modular Development Kit (MK-A5E065BB32AEA)
```



## Project Details

- **Family**: Altera® Agilex™ 5
- **Quartus Version**: 26.3
- **Development Kit**: Multiple (Refer to individual designs for more details)
- **Device Part**: Multiple

## Getting Started

Building the design is easy with the scripts provided in the repo. Clone the repository to get the source files

```bash
$ git clone https://github.com/altera-fpga/agilex5-ed-ethernet.git
$ cd agilex5-ed-ethernet
$ git checkout <Release tag>
```

Follow the below procedure to build the hardware and the software.


| Design                | Development kit                            | Hardware / Makefile                           | Software                                                          |
| --------------------- | ------------------------------------------ | --------------------------------------------- | ----------------------------------------------------------------- |
| 1x10G Ethernet        | E-Series 065B Modular (`mk-a5e065bb32aea`) | [README](mk-a5e065bb32aea/ethernet/README.md) | [Yocto](mk-a5e065bb32aea/ethernet/software/yocto_linux/README.md) |
| Triple Speed Ethernet | E-Series 065B Modular (`mk-a5e065bb32aea`) | [README](mk-a5e065bb32aea/tse/README.md)      | [Yocto](mk-a5e065bb32aea/tse/software/yocto_linux/README.md)      |
| 2x25G PTP (IEEE 1588) | E-Series 065A Premium (`dk-a5e065ab32aea`) | [README](dk-a5e065ab32aea/ptp/README.md)      | [Yocto](dk-a5e065ab32aea/ptp/software/yocto_linux/README.md)      |
| 2x10G PTP (IEEE 1588) | E-Series 065B Premium (`dk-a5e065bb32aea`) | [README](dk-a5e065bb32aea/ptp/README.md)      | [Yocto](dk-a5e065bb32aea/ptp/software/yocto_linux/README.md)      |




### Building with make

Run the targets from the design directory. Software-only builds need `output_files/<REVISION>.core.rbf`
(produced by the hardware build, or generated from `output_files/<REVISION>.sof`).


| Design directory            | Hardware + software                           | Software only (Yocto SD)                                                   |
| --------------------------- | --------------------------------------------- | -------------------------------------------------------------------------- |
| `mk-a5e065bb32aea/ethernet` | `make mk-a5e065bb32aea-baseline-ethernet-all` | `make mk-a5e065bb32aea-baseline-ethernet-software-yocto_linux_sd-build-sw` |
| `mk-a5e065bb32aea/tse`      | `make mk-a5e065bb32aea-baseline-tse-all`      | `make mk-a5e065bb32aea-baseline-tse-software-yocto_linux_sd-build-sw`      |
| `dk-a5e065ab32aea/ptp`      | `make dk-a5e065ab32aea-baseline-ptp25G-all`   | `make dk-a5e065ab32aea-baseline-ptp25G-software-yocto_linux_sd-build-sw`   |
| `dk-a5e065bb32aea/ptp`      | `make dk-a5e065bb32aea-baseline-ptp10G-all`   | `make dk-a5e065bb32aea-baseline-ptp10G-software-yocto_linux_sd-build-sw`   |


`make help` in a design directory lists all targets.
