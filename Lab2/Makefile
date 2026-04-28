.DEFAULT_GOAL := info
RISCV_PREFIX = /opt/riscv
RISCV_TOOLCHAIN_DIR = $(HOME)/riscv-gnu-toolchain
GEM5_DIR = $(HOME)/gem5
SRC_CODES_DIR = $(GEM5_DIR)/../src_codes

RISCV_GCC = $(RISCV_PREFIX)/bin/riscv64-unknown-elf-gcc

# default number of parallel workers for run_all
J ?= 4

.PHONY: compile run_all get_stats clean info 

##############################
# Compile C code for RISC-V
##############################
compile:
	@echo "Compiling cpu.riscv..."
	$(RISCV_GCC) -O2 -static $(SRC_CODES_DIR)/compute_intensive.c -o $(SRC_CODES_DIR)/cpu.riscv
	@echo "Compiling mem.riscv..."
	$(RISCV_GCC) -O2 -static $(SRC_CODES_DIR)/memory_intensive.c -o $(SRC_CODES_DIR)/mem.riscv

##############################
# Run Experiments
##############################
run_all: compile
	@echo "Starting full automation script..."
	chmod +x run_experiments.sh
	./run_experiments.sh $(J)

###################################
# Get Stats from Experiment Results
###################################
get_stats:
	python3 extract_results.py
	
##############################
# Clean outputs
##############################
clean:
	rm -f $(SRC_CODES_DIR)/cpu.riscv $(SRC_CODES_DIR)/mem.riscv
	rm -rf $(GEM5_DIR)/m5out_lab2

##############################
# Info
##############################
info:
	@echo "========== Makefile Help =========="
	@echo "Available targets:"
	@echo ""
	@echo "  make compile"
	@echo "    -> Compiles C test codes into RISC-V binaries"
	@echo ""
	@echo "  make run_all [J=workers]"
	@echo "    -> Runs all experiments with run_experiments.sh"
	@echo "    -> Default: J=4"
	@echo "    -> Example: make run_all J=8"
	@echo ""
	@echo "  make get_stats"
	@echo "    -> Gather stats from all runs and save them to a file"
	@echo ""
	@echo "  make clean"
	@echo "    -> Removes compiled binaries and result outputs"
	@echo ""
	@echo "  make info"
	@echo "    -> Shows this help message"
	@echo "==================================="
