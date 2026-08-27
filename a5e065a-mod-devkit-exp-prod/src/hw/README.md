# Altera Agilex™ 5 Ethernet System Example Design Build Scripts


# Dependency

- Altera Quartus Prime (See Release Notes for the supported version)

# Build Steps

Compile design and generate configuration (sof) file:

The synth folder contains a Makefile and the Quartus Project.The Makefile support various compile options such as:

- `make compile` - runs the compile stage of Quartus
- `make synth` - runs synthesis stage of Quartus
- `make all` - runs a full Quartus compile including the Assembler
Running `make` will print out all the options supported

The Design can be compiled to specificate datarate with or w/o ANLT option using two methods as explaied below.


**Config File Method:**

The project Makefile reads `src/hw/synth/config.txt` to determine the Ethernet data rate for the Ethernet Subsystem IPs. Open config.txt and set the configuration to the desired Ethernet data rate with ANLT support as shown in the snippet below.

The config text file will have below config for 25GbE with ANLT;

```
Configuration=25G_NON_ANLT
```

User needs to modify above text content with required option by replacing `25G_NON_ANLT` with ant one of following options.

`10G_NON_ANLT`, `25G_NON_ANLT`

**Command Method:**

- User can specify the configuration using the optional argument CONFIG. 
- Supported options are `10G_NON_ANLT`and `25G_NON_ANLT`
   - For e.g. `make all CONFIG=10G_ANLT`. 
- if the **CONFIG** argument is not specified, the value currently in `config.txt` will be built. 
- Running <make> will print out all the options supported

   ```
   cd synth/
   make all CONFIG=10G_ANLT     - Runs a full Quartus compile including the Assembler for 10G_ANLT
   
   ```

# Programming Files Generation Steps <UPDATE BELOW>

 1. File link of [`u-boot-spl-dtb.hex`](../../artifacts/u-boot-spl-dtb.hex) 

 2. Generate `top.{core,hps}.rbf` including U-Boot SPL:

    ```
    cd synth/
    quartus_pfg -c -o hps=on -o hps_path=../../sw/artifacts/u-boot-spl-dtb.hex output_files/top.sof output_files/top.rbf
    ```
