# Building the Hardware

# Dependency

- Altera® Quartus® Prime Pro software suite (see [Project Details](../../README.md#project-details) for the supported version)

# Build Steps

1. Compile the design and generate the configuration (SOF) file.

   This `synth/` folder contains a Makefile and the Quartus project (`top.qpf` / `top.qsf`). The Makefile supports various compile options such as:

   - `make compile` — runs the compile stage of Quartus
   - `make synth` — runs the synthesis stage of Quartus
   - `make all` — runs a full Quartus compile including the Assembler
   - `make asm` — runs the Assembler
   - `make clean` — cleans build outputs

   Running `make` (or `make help`) prints the options supported.

   Alternatively, if using the GUI is preferred, open `top.qpf` in Quartus and select compile options there.

   The design can be compiled for a specific data rate without ANLT using either of the methods below.

   **Config file method:**

   The project Makefile reads `synth/config.txt` to determine the Ethernet data rate. Example for 25GbE without ANLT:

   ```
   Configuration=25G_NON_ANLT
   ```

   Supported options: `10G_NON_ANLT`, `25G_NON_ANLT`.

   **Command method:**

   - Specify the configuration with the optional `CONFIG` argument.
   - Supported options: `10G_NON_ANLT`, `25G_NON_ANLT`
   - Example: `make all CONFIG=10G_NON_ANLT`
   - If `CONFIG` is omitted, the value currently in `config.txt` is used.

   ```bash
   cd synth/
   make all
   # optional:
   # make all CONFIG=25G_NON_ANLT
   # make all CONFIG=10G_NON_ANLT
   ```

   Outputs are under `synth/output_files/` (SOF name is `top.sof`).

# Programming Files Generation Steps

1. File link of [`u-boot-spl-dtb.hex`](../sw/artifacts/u-boot-spl-dtb.hex)

2. Generate `top.{core,hps}.rbf` including U-Boot SPL:

   ```bash
   cd synth/
   quartus_pfg -c -o hps=on \
     -o hps_path=../../sw/artifacts/u-boot-spl-dtb.hex \
     output_files/top.sof \
     output_files/top.rbf
   ```
