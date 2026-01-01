# ============================================================================
# RISC-V 5-Stage Pipeline CPU - Makefile
# ============================================================================

# Directories
RTL_DIR := rtl
TB_DIR := tb
TEST_DIR := test
UNIT_TEST_DIR := test/unit
SIM_DIR := sim
SYN_DIR := syn
PROG_DIR := $(TEST_DIR)/programs

# RTL source files
RTL_FILES := $(RTL_DIR)/pc.sv \
             $(RTL_DIR)/instruction_memory.sv \
             $(RTL_DIR)/register_file.sv \
             $(RTL_DIR)/control_unit.sv \
             $(RTL_DIR)/immediate_generator.sv \
             $(RTL_DIR)/alu.sv \
             $(RTL_DIR)/data_memory.sv \
             $(RTL_DIR)/branch_control.sv \
             $(RTL_DIR)/hazard_detection.sv \
             $(RTL_DIR)/riscv_cpu.sv

# Testbenches
SYSTEM_TB := $(TB_DIR)/riscv_cpu_tb.sv
UNIT_TESTS := $(wildcard $(UNIT_TEST_DIR)/test_*.sv)

# Simulation parameters
PROGRAM ?= test01_basic_arithmetic
SIM_CYCLES ?= 500
DUMP_VCD ?= 1

# ============================================================================
# Main Targets
# ============================================================================

.PHONY: all help clean unit-tests system-test test-all
.PHONY: run-sim sim-verilator wave synth lint clean-sim
.PHONY: test-alu test-regfile test-control test-imm test-branch test-hazard test-dmem test-imem

all: unit-tests system-test

help:
	@echo "RISC-V 5-Stage Pipeline CPU - Makefile Commands"
	@echo ""
	@echo "TESTING:"
	@echo "  unit-tests          Run all unit tests for individual modules"
	@echo "  test-alu            Test ALU module only"
	@echo "  test-regfile        Test register file only"
	@echo "  test-control        Test control unit only"
	@echo "  test-hazard         Test hazard detection only"
	@echo "  system-test         Run full CPU system test"
	@echo "  test-all            Run all unit and system tests"
	@echo ""
	@echo "SIMULATION:"
	@echo "  run-sim             Simulate with Icarus Verilog (default program)"
	@echo "  sim-verilator       Simulate with Verilator"
	@echo "  wave                View waveforms in GTKWave"
	@echo ""
	@echo "SYNTHESIS:"
	@echo "  synth               Synthesize with Yosys"
	@echo "  lint                Run Verible linter"
	@echo ""
	@echo "OPENLANE ASIC FLOW:"
	@echo "  openlane-setup      Pull OpenLane Docker image (one-time)"
	@echo "  openlane-run        Run complete ASIC flow (RTL → GDSII)"
	@echo "  openlane-results    Show results summary"
	@echo "  openlane-clean      Clean OpenLane runs"
	@echo ""
	@echo "MAINTENANCE:"
	@echo "  clean               Remove all generated files"
	@echo "  clean-sim           Remove only simulation files"
	@echo ""
	@echo "VARIABLES:"
	@echo "  PROGRAM=<name>      Test program (default: test01_basic_arithmetic)"
	@echo "  SIM_CYCLES=<n>      Simulation cycles (default: 500)"
	@echo "  DUMP_VCD=<0|1>      Enable VCD waveform dump (default: 1)"
	@echo ""
	@echo "EXAMPLES:"
	@echo "  make test-all                            # Run all tests"
	@echo "  make run-sim PROGRAM=test02 DUMP_VCD=1   # Simulate with waveforms"
	@echo "  make openlane-run                        # Full ASIC flow"
	@echo ""

# ============================================================================
# Unit Tests
# ============================================================================

unit-tests:
	@echo "Running unit tests..."
	@$(MAKE) test-alu
	@$(MAKE) test-regfile
	@$(MAKE) test-control
	@$(MAKE) test-imm
	@$(MAKE) test-branch
	@$(MAKE) test-hazard
	@$(MAKE) test-dmem
	@$(MAKE) test-imem
	@echo ""
	@echo "All unit tests passed."

test-alu:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing ALU..."
	@iverilog -g2012 -o $(SIM_DIR)/test_alu.vvp \
		$(UNIT_TEST_DIR)/test_alu.sv $(RTL_DIR)/alu.sv
	@vvp $(SIM_DIR)/test_alu.vvp

test-regfile:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing Register File..."
	@iverilog -g2012 -o $(SIM_DIR)/test_regfile.vvp \
		$(UNIT_TEST_DIR)/test_register_file.sv $(RTL_DIR)/register_file.sv
	@vvp $(SIM_DIR)/test_regfile.vvp

test-control:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing Control Unit..."
	@iverilog -g2012 -o $(SIM_DIR)/test_control.vvp \
		$(UNIT_TEST_DIR)/test_control_unit.sv $(RTL_DIR)/control_unit.sv
	@vvp $(SIM_DIR)/test_control.vvp

test-imm:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing Immediate Generator..."
	@iverilog -g2012 -o $(SIM_DIR)/test_imm.vvp \
		$(UNIT_TEST_DIR)/test_immediate_generator.sv $(RTL_DIR)/immediate_generator.sv
	@vvp $(SIM_DIR)/test_imm.vvp

test-branch:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing Branch Control..."
	@iverilog -g2012 -o $(SIM_DIR)/test_branch.vvp \
		$(UNIT_TEST_DIR)/test_branch_control.sv $(RTL_DIR)/branch_control.sv
	@vvp $(SIM_DIR)/test_branch.vvp

test-hazard:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing Hazard Detection..."
	@iverilog -g2012 -o $(SIM_DIR)/test_hazard.vvp \
		$(UNIT_TEST_DIR)/test_hazard_detection.sv $(RTL_DIR)/hazard_detection.sv
	@vvp $(SIM_DIR)/test_hazard.vvp

test-dmem:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing Data Memory..."
	@iverilog -g2012 -o $(SIM_DIR)/test_dmem.vvp \
		$(UNIT_TEST_DIR)/test_data_memory.sv $(RTL_DIR)/data_memory.sv
	@vvp $(SIM_DIR)/test_dmem.vvp

test-imem:
	@mkdir -p $(SIM_DIR)
	@echo "\n→ Testing Instruction Memory..."
	@iverilog -g2012 -o $(SIM_DIR)/test_imem.vvp \
		$(UNIT_TEST_DIR)/test_instruction_memory.sv $(RTL_DIR)/instruction_memory.sv
	@vvp $(SIM_DIR)/test_imem.vvp

# ============================================================================
# System Tests
# ============================================================================

system-test:
	@echo "\nRunning system tests..."
	@for test in test01_basic_arithmetic test02_logic_operations test03_shifts \
	             test06_memory_ops test07_branches test08_jumps; do \
		echo "\n→ Testing: $$test"; \
		$(MAKE) run-sim PROGRAM=$$test DUMP_VCD=0 2>&1 | tail -5 || exit 1; \
	done
	@echo "\nAll system tests passed."

test-all: unit-tests system-test

run-sim:
	@mkdir -p $(SIM_DIR)
	@echo "Simulating: $(PROGRAM)"
	@iverilog -g2012 -Wall -Winfloop \
		`if [ $(DUMP_VCD) -eq 1 ]; then echo "-DDUMP_VCD"; fi` \
		-DPROGRAM_FILE=\"../$(PROG_DIR)/$(PROGRAM).hex\" \
		-DTEST_NAME=\"$(PROGRAM)\" \
		-DSIMULATION_CYCLES=$(SIM_CYCLES) \
		-o $(SIM_DIR)/$(PROGRAM).vvp \
		$(SYSTEM_TB) $(RTL_FILES)
	@cd $(SIM_DIR) && vvp $(PROGRAM).vvp

sim-verilator:
	@mkdir -p $(SIM_DIR)
	@echo "Building with Verilator..."
	@verilator --binary --timing -Wall -Wno-fatal --trace \
		--top-module riscv_cpu_tb \
		--Mdir $(SIM_DIR)/obj_dir \
		$(SYSTEM_TB) $(RTL_FILES)
	@$(SIM_DIR)/obj_dir/Vriscv_cpu_tb

wave: $(SIM_DIR)/waves.vcd
	@gtkwave $(SIM_DIR)/waves.vcd &

# ============================================================================
# Synthesis
# ============================================================================

synth:
	@mkdir -p $(SYN_DIR)
	@echo "Converting SystemVerilog to Verilog..."
	@sv2v $(RTL_FILES) > $(SYN_DIR)/riscv_cpu_flat.v
	@echo "Fixing readmemh for synthesis..."
	@sed -i 's/\$$readmemh/\/\/ \$$readmemh/g' $(SYN_DIR)/riscv_cpu_flat.v
	@echo "Synthesizing with Yosys..."
	@yosys -p "read_verilog $(SYN_DIR)/riscv_cpu_flat.v; \
	          hierarchy -check -top riscv_cpu; \
	          proc; opt; fsm; opt; memory; opt; \
	          synth -top riscv_cpu; \
	          write_verilog syn/riscv_cpu_synth.v; \
	          stat" | tee $(SYN_DIR)/synth.log
	@echo ""
	@echo "Synthesis complete! Check syn/ directory for results."

lint:
	@echo "Running Verible linter..."
	@verible-verilog-lint $(RTL_FILES) $(SYSTEM_TB) || true

# ============================================================================
# OpenLane ASIC Flow
# ============================================================================

.PHONY: openlane-setup openlane-run openlane-clean openlane-results

openlane-setup:
	@echo "Setting up OpenLane..."
	@echo "Pulling OpenLane Docker image..."
	docker pull efabless/openlane:2023.11.03

openlane-run:
	@echo "Running OpenLane ASIC flow (RTL to GDSII)..."
	@echo ""
	@echo "This will take 30min-2hrs depending on your machine."
	@echo "Watch the progress in your terminal..."
	@echo ""
	@if [ -d "/home/archi/pdk" ]; then \
		echo "Using local PDK at /home/archi/pdk"; \
		docker run --rm \
			-v $(shell pwd):/project \
			-v /home/archi/pdk:/build/pdk:ro \
			-w /project \
			efabless/openlane:2023.11.03 \
			bash -c "cd openlane && /openlane/flow.tcl -design . -tag run_1 -overwrite"; \
	else \
		echo "No local PDK found. Install with: ./install_pdk_local.sh"; \
		echo "Or the Docker image should have a built-in PDK..."; \
		docker run --rm \
			-v $(shell pwd):/project \
			-w /project \
			efabless/openlane:2023.11.03 \
			bash -c "cd openlane && /openlane/flow.tcl -design . -tag run_1 -overwrite"; \
	fi

openlane-clean:
	@echo "Cleaning OpenLane runs..."
	@rm -rf openlane/runs

openlane-local:
	@echo "Running OpenLane locally (no Docker)..."
	@		if [ -z "$$OPENLANE_ROOT" ]; then \
		echo ""; \
		echo "Error: OpenLane environment not set up."; \
		echo ""; \
		echo "Run:"; \
		echo "  source ~/asic_tools/setup_env.sh"; \
		echo "  make openlane-local"; \
		echo ""; \
		echo "Or install OpenLane first:"; \
		echo "  ./install_openlane_local.sh"; \
		echo ""; \
		exit 1; \
	fi
	@echo "Using local OpenLane at: $$OPENLANE_ROOT"
	@echo "PDK: $$PDK_ROOT"
	@echo ""
	cd $$OPENLANE_ROOT && ./flow.tcl -design $(PWD) -tag run_1

openlane-results:
	@echo "OpenLane Results:"
	@if [ -d openlane/runs/run_1/results ]; then \
		echo ""; \
		echo "Results available in openlane/runs/run_1/results/"; \
		echo ""; \
		echo "Key Outputs:"; \
		echo "  Synthesis:  openlane/runs/run_1/results/synthesis/"; \
		echo "  Placement:  openlane/runs/run_1/results/placement/"; \
		echo "  Routing:    openlane/runs/run_1/results/routing/"; \
		echo "  Final GDS:  openlane/runs/run_1/results/signoff/"; \
		echo ""; \
		echo "Reports:"; \
		echo "  Timing:     openlane/runs/run_1/reports/"; \
		echo "  Area:       openlane/runs/run_1/reports/"; \
		echo ""; \
		if [ -f openlane/runs/run_1/results/signoff/*.gds ]; then \
			echo "GDSII file found. Design ready for fabrication."; \
		fi; \
	else \
		echo ""; \
		echo "No results found."; \
		echo "Run 'make openlane-run' first."; \
		echo ""; \
	fi

# ============================================================================
# Cleanup
# ============================================================================

clean:
	@echo "Cleaning all generated files..."
	@rm -rf $(SIM_DIR) $(SYN_DIR)
	@rm -f *.vcd *.vvp *.log
	@rm -f $(UNIT_TEST_DIR)/*.vvp $(UNIT_TEST_DIR)/test_prog.hex

clean-sim:
	@echo "Cleaning simulation files..."
	@rm -rf $(SIM_DIR)
	@rm -f *.vcd *.vvp
