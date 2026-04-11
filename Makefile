RISCV_PREFIX = /opt/riscv
RISCV_TOOLCHAIN_DIR = $(HOME)/riscv-gnu-toolchain
GEM5_DIR = $(HOME)/gem5

RISCV_GCC = $(RISCV_PREFIX)/bin/riscv64-unknown-elf-gcc
RISCV_OBJDUMP = $(RISCV_PREFIX)/bin/riscv64-unknown-elf-objdump

SRC ?= main.c
OUT ?= $(basename $(SRC)).riscv

JOBS ?= 4

.PHONY: all toolchain gem5 build check run clean info

all: build

##############################
# Info
##############################
info:
	@echo "========== Makefile Help =========="
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  make toolchain"
	@echo "    -> Builds the RISC-V GNU toolchain"
	@echo ""
	@echo "  make gem5"
	@echo "    -> Compiles gem5 for RISCV (build/RISCV/gem5.opt)"
	@echo ""
	@echo "  make build SRC=<file.c> OUT=<output.riscv>"
	@echo "    -> Compiles C source into a RISC-V binary"
	@echo "       Default: SRC=main.c OUT=<src_filename>.riscv"
	@echo ""
	@echo "  make check OUT=<output.riscv>"
	@echo "    -> Disassembles binary and shows <main> section"
	@echo ""
	@echo "  make run OUT=<output.riscv>"
	@echo "    -> Runs the binary using gem5 simulator"
	@echo ""
	@echo "  make clean"
	@echo "    -> Removes generated RISC-V binaries"
	@echo ""
	@echo "  make info"
	@echo "    -> Shows this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make gem5 JOBS=2"
	@echo "  make build SRC=<path_to_code>/test.c"
	@echo "  make check OUT=<path_to_compiled_file>/test.riscv"
	@echo "  make run OUT=<path_to_compiled_file>/test.riscv"
	@echo ""
	@echo "==================================="

##############################
# Build RISC-V toolchain
##############################
toolchain:
	cd $(RISCV_TOOLCHAIN_DIR) && \
	sudo make clean && \
	./configure --prefix=$(RISCV_PREFIX) && \
	sudo make -j$(JOBS) && \
	sudo chmod -R 775 $(RISCV_PREFIX)

##############################
# Build gem5 (RISCV)
##############################
gem5:
	cd $(GEM5_DIR) && \
	scons build/RISCV/gem5.opt -j$(JOBS)

##############################
# Compile C code for RISC-V
##############################
build:
	$(RISCV_GCC) -O0 -static $(SRC) -o $(OUT)

##############################
# Inspect assembly (main)
##############################
check:
	$(RISCV_OBJDUMP) -d $(OUT) | grep -A20 "<main>"

##############################
# Run on gem5
##############################
run:
	$(GEM5_DIR)/build/RISCV/gem5.opt \
	$(GEM5_DIR)/configs/deprecated/example/se.py \
	--cpu-type=DerivO3CPU \
	--caches --l2cache \
	--cmd=$(PWD)/$(OUT)

##############################
# Clean outputs
##############################
clean:
	rm -f $(OUT)