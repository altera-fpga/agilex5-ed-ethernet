# Building the Hardware

# Dependency

- Altera® Quartus® Prime Pro software suite (see [Project Details](../README.md#project-details) for the supported version)

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

   ```bash
   cd synth/
   make all
   ```

   Outputs are under `output_files/` (SOF name is `top.sof`).

   The top-level Makefile in `tse/` copies that SOF to
   `output_files/agilex5_mk-a5e065bb32aea_gsrd_ghrd_TSE_1P.sof` and generates the matching
   `.core.rbf` for Yocto (`REVISION_NAMES` in `project_config.mk`; must match
   `FPGA_RBF_FILE` from `tse-solution.inc`).
   Details: [software/yocto_linux/README.md](../software/yocto_linux/README.md).
