THIS_MK_ABSPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MK_DIR := $(dir $(THIS_MK_ABSPATH))

# Enable pipefail for all commands
SHELL=/bin/bash -o pipefail

# Enable second expansion
.SECONDEXPANSION:

# Clear all built in suffixes
.SUFFIXES:

NOOP :=
SPACE := $(NOOP) $(NOOP)
COMMA := ,
HOSTNAME := $(shell hostname)
export PATH := $(PATH):/usr/sbin

##############################################################################
# Environment check
##############################################################################


##############################################################################
# Configuration
##############################################################################
PROJECT_DIR_ABS := $(abspath $(THIS_MK_DIR))

# Name of all the revisions
PROJECT_NAME :=
REVISION_NAMES :=

# Set defaults
INSTALL_ROOT_BINARIES ?= $(THIS_MK_DIR)/install/binaries
INSTALL_ROOT_DESIGNS ?= $(THIS_MK_DIR)/install/designs
INSTALL_ROOT_ARTIFACTS ?= $(THIS_MK_DIR)/install/artifacts

include $(THIS_MK_DIR)/project_config.mk
ifeq ($(PROJECT_NAME),)
$(error PROJECT_NAME is not defined in project_config.mk)
endif
ifeq ($(REVISION_NAMES),)
$(error REVISION_NAMES is not defined in project_config.mk)
endif
ARCHIVE_NAME ?= $(PROJECT_NAME)

# Hardware is compiled by synth/Makefile; SOF is top.sof in synth/
SYNTH_DIR := $(PROJECT_DIR_ABS)/synth
SYNTH_REVISION := top

# Set constants
INSTALL_RPT_NAMES := ipgen.rpt
ifneq ($(USE_ELAB_ONLY_FLOW),1)
INSTALL_RPT_NAMES += \
	syn.rpt \
	fit.rpt \
	sta.rpt \
	asm.rpt \
	pow.rpt \
	flow.rpt \
	tq.drc.signoff.rpt
endif

##############################################################################
# Set default goal before any targets. The default goal here is "test"
##############################################################################
DEFAULT_TARGET := test

.DEFAULT_GOAL := default
.PHONY: default
default: $(DEFAULT_TARGET)


##############################################################################
# Makefile starts here
##############################################################################

# Initialize variables
ALL_TARGET_STEM_NAMES =
ALL_SW_TARGET_STEM_NAMES =
ALL_BUILD_TARGETS =
ALL_SW_BUILD_TARGETS =
ALL_SW_CLEAN_TARGETS =
ALL_SW_INSTALL_TARGETS =
ALL_TEST_TARGETS =
ALL_INSTALL_TARGETS =

# Define function to create targets
define create_targets_on_revisions
ALL_TARGET_STEM_NAMES += $(strip $(1))
ALL_BUILD_TARGETS += $(addsuffix -build,$(strip $(1)))
ALL_TEST_TARGETS += $(addsuffix -test,$(strip $(1)))
ALL_INSTALL_TARGETS += $(addsuffix -install,$(strip $(1)))

$(strip $(1))-package-design : $(INSTALL_ROOT_DESIGNS)/$(ARCHIVE_NAME).zip

$(strip $(1))-build :
	rm -f output_files/$(strip $(1)).synth.done
	$(MAKE) --no-print-directory output_files/$(strip $(1)).sof

$(strip $(1))-build-sw :

$(strip $(1))-test : $(strip $(1))-build

$(strip $(1))-install-sw: | $(INSTALL_ROOT_BINARIES)

$(strip $(1))-install: $(strip $(1))-install-sof $(strip $(1))-install-rpt $(strip $(1))-install-sw

$(strip $(1))-install-sof : output_files/$(strip $(1)).sof | $(INSTALL_ROOT_BINARIES)
	cp output_files/$(strip $(1)).sof $(INSTALL_ROOT_BINARIES)/$(strip $(1)).sof

$(strip $(1))-install-rpt: output_files/$(strip $(1))-install-rpt.done

output_files/$(strip $(1))-install-rpt.done : output_files/$(strip $(1)).sof | $(INSTALL_ROOT_ARTIFACTS) output_files
	for rpt in $(addprefix output_files/$(strip $(1)).,$(INSTALL_RPT_NAMES)); do \
		if [ -f $$$$rpt ]; then \
			cp -f $$$$rpt $(INSTALL_ROOT_ARTIFACTS)/ && \
			gzip -f $(INSTALL_ROOT_ARTIFACTS)/$$$$(basename $$$$rpt); \
		fi; \
	done
	touch $$@

endef

# Create all targets
$(foreach revision,$(REVISION_NAMES),$(eval $(call create_targets_on_revisions,$(revision))))

# GHRD-style public stem aliases (MAKE_STEM in project_config.mk)
ifneq ($(MAKE_STEM),)
.PHONY: $(MAKE_STEM)-all $(MAKE_STEM)-build $(MAKE_STEM)-software-yocto_linux_sd-build-sw \
	$(MAKE_STEM)-install $(MAKE_STEM)-install-core-rbf
$(MAKE_STEM)-all : $(BASE_REVISION)-build software-yocto_linux_sd-build-sw
$(MAKE_STEM)-build : $(BASE_REVISION)-build
$(MAKE_STEM)-software-yocto_linux_sd-build-sw : software-yocto_linux_sd-build-sw
$(MAKE_STEM)-install : $(BASE_REVISION)-install
$(MAKE_STEM)-install-core-rbf : $(BASE_REVISION)-install-core-rbf
endif

###############################################################################
#                          UTILITY TARGETS
###############################################################################

output_files $(INSTALL_ROOT_BINARIES) $(INSTALL_ROOT_DESIGNS) $(INSTALL_ROOT_ARTIFACTS):
	mkdir -p $@

$(INSTALL_ROOT_DESIGNS)/$(ARCHIVE_NAME).zip: | $(INSTALL_ROOT_DESIGNS)
 	# Add root README.md first so quartus_sh create_metadata always picks it up before any nested README.md files.
	zip $@ README.md
	zip -r -g $@ * -x .gitignore "output_files/*" "qdb/*" "dni/*" "tmp-clearbox/*" "README.md"

.PHONY: package-design
package-design: $(INSTALL_ROOT_DESIGNS)/$(ARCHIVE_NAME).zip

# Support restoring the SOF from the install directory to support
# building the SW outside of building the FPGA design
ifneq ($(RESTORE_INSTALL),1)
.PRECIOUS: output_files/%.synth.done

output_files/%.sof: output_files/%.synth.done
	@test -f $@ || (echo "Error: $@ not found after synth build!" && exit 1)

output_files/%.synth.done: | output_files
	$(MAKE) -C $(SYNTH_DIR) all
	rm -f output_files/$*.synth.done
	touch $@
	cp -f $(SYNTH_DIR)/output_files/$(SYNTH_REVISION).sof output_files/$*.sof
	for rpt in $(INSTALL_RPT_NAMES); do \
		if [ -f $(SYNTH_DIR)/output_files/$(SYNTH_REVISION).$$rpt ]; then \
			cp -f $(SYNTH_DIR)/output_files/$(SYNTH_REVISION).$$rpt output_files/$*.$$rpt; \
		fi; \
	done
else
output_files/%.sof: $(INSTALL_ROOT_BINARIES)/%.sof
	mkdir -p $(dir $@)
	cp $< $@
	@test -f $@ && echo "$@ found after restore!" || (echo "Error: $@ not found after restore!" && exit 1)
endif

# Clean all files
.PHONY: clean
clean : clean-sw
	rm -rf output_files qdb tmp-clearbox dni
ifneq ($(QUARTUS_ROOTDIR),)
	$(MAKE) -C $(SYNTH_DIR) clean
endif

# Deep clean using git
.PHONY: dev-clean
dev-clean : clean
	git clean -dfx .

# Build all revisions
.PHONY: build
build : $(ALL_BUILD_TARGETS)

# Run all tests
.PHONY: test
test : $(ALL_TEST_TARGETS)

# Install binaries and designs
.PHONY: install
install : $(ALL_INSTALL_TARGETS)

.PHONY: print-targets
print-targets:
	$(info $(ALL_TARGET_STEM_NAMES))

###############################################################################
#                           SW Build Targets
###############################################################################
-include $(THIS_MK_DIR)/swbuild_config.mk
ALL_SW_BUILD_TARGETS += $(addsuffix -build-sw, $(ALL_SW_TARGET_STEM_NAMES))
ALL_SW_CLEAN_TARGETS += $(addsuffix -clean-sw, $(ALL_SW_TARGET_STEM_NAMES))
ALL_SW_INSTALL_TARGETS += $(addsuffix -install-sw, $(ALL_SW_TARGET_STEM_NAMES))

# Build all SW projects
.PHONY: build-sw
build-sw : $(ALL_SW_BUILD_TARGETS)

.PHONY: clean-sw
clean-sw: $(ALL_SW_CLEAN_TARGETS)

.PHONY: install-sw
install-sw: $(ALL_SW_INSTALL_TARGETS)

.PHONY: print-sw-targets
print-sw-targets:
	$(info $(ALL_SW_TARGET_STEM_NAMES))


###############################################################################
#                                HELP
###############################################################################
.PHONY: help
help:
	@echo "Agilex 5 Ethernet SED build ($(MAKE_STEM))"
	@echo ""
	@echo "Usage:"
	@echo "  make [target]"
	@echo ""
	@echo "Public targets:"
	@echo "  $(MAKE_STEM)-build"
	@echo "      Hardware only: make -C synth all, then copy"
	@echo "      synth/output_files/top.sof -> output_files/$(BASE_REVISION).sof"
	@echo "  $(MAKE_STEM)-software-yocto_linux_sd-build-sw"
	@echo "      Software only: generate core.rbf from SOF, then"
	@echo "      software/yocto_linux/build.sh <core.rbf> sd"
	@echo "  $(MAKE_STEM)-all"
	@echo "      Hardware then software"
	@echo "  $(MAKE_STEM)-install"
	@echo "      Install SOF, reports, and software artifacts under install/"
	@echo "  $(MAKE_STEM)-install-core-rbf"
	@echo "      Build SOF if needed, then quartus_pfg core RBF -> install/binaries/"
	@echo ""
	@echo "Common targets:"
	@echo "  build / $(BASE_REVISION)-build   Hardware compile (same as *-build)"
	@echo "  test                            Same as build (default goal)"
	@echo "  build-sw                        All software build targets"
	@echo "  install / install-sw            Install hardware / software artifacts"
	@echo "  clean                           Clean Yocto + output_files (+ synth if Quartus set)"
	@echo "  package-design                  Zip design sources to install/designs/"
	@echo "  help                            Show this message"
	@echo ""
	@echo "Examples:"
	@echo "  make $(MAKE_STEM)-build"
	@echo "  make $(MAKE_STEM)-software-yocto_linux_sd-build-sw"
	@echo "  make $(MAKE_STEM)-all"
	@echo "  make $(MAKE_STEM)-install-core-rbf"
	@echo ""
	@echo "Project directory : $(PROJECT_DIR_ABS)"
	@echo "Synth directory   : $(SYNTH_DIR)"
	@echo "HW build targets  : $(ALL_BUILD_TARGETS)"
	@echo "HW install targets: $(ALL_INSTALL_TARGETS)"
	@echo "SW build targets  : $(ALL_SW_BUILD_TARGETS)"
	@echo "SW install targets: $(ALL_SW_INSTALL_TARGETS)"
