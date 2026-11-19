# Agilex 5 TSE System Reference Design

This directory contains the Quartus Project for the Agilex 5 TSE System Design with 10/100/1000 Ethernet MAC and PCS with Embedded PMA (GTS)

---

## Dependency

- Quartus® Prime 26.3
- Supported Board:
  - [Agilex™ 5 FPGA E-Series 065B Modular Development Kit](https://www.intel.com/content/www/us/en/products/details/fpga/development-kits/agilex/a5e065b-modular.html)

---

## Build Steps

1. Compile design and generate configuration file:

```bash
    make all
    ```

## Programming Files Generation Steps

1. Get your boot loader .hex file
2. Generate binary file including boot loader files using following commands:

```bash
    quartus_pfg -c -o hps_path=../../sw/artifacts/u-boot-spl-dtb.hex ./output_files/top.sof ./output_files/top.sof
    quartus_pfg -c -o hps=on ./output_files/top.sof ./output_files/top.rbf
    ```

---

