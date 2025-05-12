#path to the package file
PKG_FILE    = ../sv/apb_master_package.sv
#top module name
TOP_MODULE  = top
VCD_FILE    = ../sim/APB.vcd
#path to the sv directory
SV_DIR      = ../sv
#path to the sve directory
SVE_DIR     = ../sve
#path of the top directory
TB_TOP_DIR  = ../tb_top
SIM_DIR     = ../sim
WORK_LIB    = ../work
#all files with extension .sv in the sv directory except package 
SV_FILES    = $(filter-out $(PKG_FILE), $(wildcard $(SV_DIR)/*.sv))
#all files in sve directory with .sv extension
SVE_FILES   = $(wildcard $(SVE_DIR)/*.sv)
#top module file
TB_TOP_FILE = $(wildcard $(TB_TOP_DIR)/*.sv)
#compiling all files in order
SRC_FILES   = $(PKG_FILE) $(SV_FILES) $(SVE_FILES) $(TB_TOP_FILE)
#parameter for seed
override SEED     ?= 123
#paramater for waves 
override WAVES    ?= 0
#parameter for testcase
override TESTCASE ?= TEST1

all: run
#compile target
compile:
	@echo "Compiling SystemVerilog files with seed = $(SEED)"
	@vlib $(WORK_LIB)
	@vlog -sv +acc=rn -work $(WORK_LIB) $(SRC_FILES)
#run target
run: compile
	@echo "Running simulation (waves=$(WAVES), seed=$(SEED), testcase=$(TESTCASE))..."
	@mkdir -p $(SIM_DIR)
	#GUI mode with waveform dump
ifeq ($(WAVES),1)
	@vsim -lib $(WORK_LIB) $(TOP_MODULE) -sv_seed $(SEED) +$(TESTCASE) \
		-do "vcd file $(VCD_FILE); add wave -r /*; run -all; quit;"
	#terminal mode withoout waveform dumping
else
	@vsim -c -lib $(WORK_LIB) $(TOP_MODULE) -sv_seed $(SEED) +$(TESTCASE) \
		-do "run -all; quit;"
endif
#clean target
clean:
	@echo "Cleaning simulation files..."
	@rm -rf $(WORK_LIB) $(SIM_DIR)/transcript $(SIM_DIR)/vsim.wlf $(SIM_DIR)/*.vcd
