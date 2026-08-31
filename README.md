# Altera Agilex™ 5 Ethernet System Example Design


## Description
The Ethernet System Example Design demonstrates Ethernet functionality of the Altera Agilex 5 FPGA 
supporting GTS transceivers. It provides a 1-Port, 25GbE/10GbE design leveraging the GTS Ethernet Hard IP.

The primary components in the design are
- Hard Processor Subsystem (HPS)
- Channelized Modular scatter-Gather Direct Memory Access (MSGDMA) Subsystem
- Packet Switch module
- Packet Generator
- GTS Ethernet Hard IP

![](e10g_sed_functional_bd.png)


Important features of the design include
- Ethernet Software stack running on the HPS that handles the generation of iperf traffic
- Programmable packet routing functionality handled within the Packet Switch module
- DMA engines to efficiently transfer data between the HPS and Ethernet MAC

The System Example Design supports the following design configurations on Altera Development Kits.

|SL No| Design configuration | Data-rate | Development Kit Supported | Device Family | Device Part | Quartus Release | Documentation |
|-----|-----------------------|-----------|:--------------------------:|:--------------:|:-------------:|:------:|:-------------:|
|1.   |1-port 10GbE           | 10GbE     | [MK-A5E065BB32AEA](https://www.altera.com/products/devkit/po-3274/agilex-5-fpga-and-soc-e-series-065b-modular-development-kit) | Agilex™ 5 E-Series (Group B) | A5ED065BB32AE4S | Quartus Prime Pro 26.1 | [10G Git Doc]((https://altera-fpga.github.io/rel-26.1/embedded-designs/agilex-5/e-series/modular-065b/ethernet/agx5e-ethernet-10g/ug-agx5e-ethernet-10g/)) |
|2.   |1-port 25GbE/10GbE           | 25GbE/10GbE     | [MK-A5E065AB32AEA](https://www.altera.com/products/devkit/po-3278/agilex-5-fpga-and-soc-e-series-065a-modular-development-kit) | Agilex™ 5 E-Series (Group A) | A5ED065AB32AE1V | Quartus Prime Pro 26.1.1 |[25G/10G Git Doc](https://altera-fpga.github.io/rel-26.1.1/embedded-designs/agilex-5/e-series/modular-065a/ethernet/agx5e-ethernet/ug-agx5e-ethernet/) |

<!-- ponytail: a5e065a-mod-devkit-exp-prod is currently an identical copy of the 10GbE design (dts not yet swapped to 25GbE); update this table/links once the 25G dts change lands. -->

## Repository Structure

Directory Structure used in this example design:

 ```bash
agilex5-ed-ethernet
    |--- a5e065a-mod-devkit-exp-prod/src
    |   |--- hw
    |   |--- sw
    |--- a5e065b-mod-devkit-exp-prod/src
    |   |--- hw
    |   |--- sw
 ```
 
 

## Project Details

- **Family**: Agilex™ 5
- **Quartus Version**: 26.1.1
- **Development Kit**: [Agilex™ 5 FPGA E-Series 065A Modular Development Kit (MK-A5E065BB32AEA)](https://www.altera.com/products/devkit/po-3278/agilex-5-fpga-and-soc-e-series-065a-modular-development-kit)
- **Device Part**: A5ED065AB32AE1V

## Getting Started

Building the design is easy with the scripts provided in the repo. Clone the repository to get the source files
	
	$ git clone https://github.com/altera-fpga/agilex5-ed-ethernet.git
	$ cd agilex5-ed-ethernet
	$ git checkout main



Follow the below procedure to build the HW and the Software artifacts. 
- Building 10GbE design on MK-A5E065BB32AEA: [Hardware](a5e065b-mod-devkit-exp-prod/src/hw/README.md) / [Software](a5e065b-mod-devkit-exp-prod/src/sw/README.md)
- Building 25GbE/10GbE design on MK-A5E065AB32AEA: [Hardware](a5e065a-mod-devkit-exp-prod/src/hw/README.md) / [Software](a5e065a-mod-devkit-exp-prod/src/sw/README.md)

**NOTE**: 

1. Kindly refer to this [Release Q25.3-Rel-1.1](https://github.com/altera-fpga/agilex5-ed-ethernet/releases/tag/SED-1x10GE-a5e065b-mdk-Q25.3-Rel-1.1) for Design targetted to [Agilex™ 5 FPGA and SoC E-Series Modular Development Kit (ES)](https://www.altera.com/products/devkit/po-3001/agilex-5-fpga-and-soc-e-series-modular-development-kit-es)
