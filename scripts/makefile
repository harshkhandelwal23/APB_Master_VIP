# Makefile (place this inside the scripts/ folder)
PKG_FILE = ../sv/apb_master_package.sv
TOP_MODULE = top
VCD_FILE = ../sim/APB.vcd
SV_DIR = ../sv
SVE_DIR = ../sve
TB_TOP_DIR = ../tb_top
SIM_DIR = ../sim
WORK_LIB = ../work
SV_FILES = $(wildcard $(SV_DIR)/*.sv)
SVE_FILES = $(wildcard $(SVE_DIR)/*.sv)
TB_TOP_FILE = $(wildcard $(TB_TOP_DIR)/*.sv)
SRC_FILES = $(PKG_FILE) $(SV_FILES) $(SVE_FILES) $(TB_TOP_FILE)
override SEED ?= 123
override WAVES ?= 0
all: run
compile:
	@echo "Compiling SystemVerilog files with seed = $(SEED)"
	@vlib $(WORK_LIB)
	@vlog -sv -work $(WORK_LIB) $(SRC_FILES)
run: compile
	@echo "Running simulation (waves=$(WAVES), seed=$(SEED))..."
ifeq ($(WAVES),1)
	@vsim -lib $(WORK_LIB) $(TOP_MODULE) +ntb_random_seed=$(SEED) -do "vcd file $(VCD_FILE); add wave -r /*; run -all; quit;"
else
	@vsim -c -lib $(WORK_LIB) $(TOP_MODULE) +ntb_random_seed=$(SEED) -do "run -all; quit;"
endif
clean:
	@echo "Cleaning simulation files..."
	@rm -rf $(WORK_LIB) $(SIM_DIR)/transcript $(SIM_DIR)/vsim.wlf $(SIM_DIR)/*.vcd
.PHONY: all compile run clean
