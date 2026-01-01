# RISC-V 32-bit 5-Stage Pipeline CPU

A complete, synthesizable RISC-V CPU implementation with full ASIC design flow from RTL to GDSII.

**Author:** Andreas Tzitzikas

---

## Overview

This project implements a complete RISC-V RV32I CPU using a 5-stage in-order pipeline architecture. The design has been synthesized and verified through the full ASIC design flow, resulting in a fabrication-ready GDSII layout using the Sky130 130nm process.

**Key Stats:**
- **10,121 cells** synthesized
- **1.0 mm²** die area
- **50 MHz** clock frequency
- **0 DRC violations** 
- **0 LVS errors**
- **All timing met**
- **GDSII ready for tapeout**

---

## Architecture

### 5-Stage Pipeline

```
IF → ID → EX → MEM → WB
```

1. **IF (Instruction Fetch)**: Gets instruction from memory
2. **ID (Instruction Decode)**: Decodes instruction, reads registers
3. **EX (Execute)**: Performs ALU operations, calculates branches
4. **MEM (Memory)**: Reads/writes data memory
5. **WB (Write Back)**: Writes results back to registers

### Hazard Resolution

The design implements pipeline stalls for hazard resolution without data forwarding or branch prediction. This approach prioritizes design simplicity and verification:

- **Data hazards**: Pipeline stalls when an instruction requires data from a preceding instruction
- **Load-use hazards**: Pipeline stalls when the subsequent instruction depends on load data
- **Control hazards**: Pipeline flush on branches and jumps

### Modules

| Module | Purpose |
|--------|---------|
| `riscv_cpu.sv` | Top-level pipeline with all stages |
| `alu.sv` | Arithmetic and logic operations |
| `control_unit.sv` | Decodes instructions, generates control signals |
| `register_file.sv` | 32 general-purpose registers |
| `hazard_detection.sv` | Detects hazards, generates stalls |
| `immediate_generator.sv` | Extracts immediates from instructions |
| `branch_control.sv` | Decides if branches are taken |
| `instruction_memory.sv` | Holds the program |
| `data_memory.sv` | Stores data for loads/stores |
| `pc.sv` | Program counter |

---

## Features

**RV32I ISA**
- Integer instructions: add, sub, and, or, xor, sll, srl, sra, slt, sltu
- Load/store: lb, lh, lw, lbu, lhu, sb, sh, sw
- Branches: beq, bne, blt, bge, bltu, bgeu
- Jumps: jal, jalr
- Upper immediates: lui, auipc

**Verification**
- Unit tests for all modules
- System tests with programs
- All tests passing

**ASIC Implementation**
- Synthesized to Sky130 130nm
- Place and route complete
- DRC violations: 0
- LVS errors: 0
- GDSII generated

---

## Project Structure

```
.
├── rtl/                    # RTL source files (10 modules)
│   ├── riscv_cpu.sv       # Top-level CPU
│   ├── alu.sv             # ALU
│   ├── control_unit.sv    # Control logic
│   ├── register_file.sv   # Registers
│   ├── hazard_detection.sv # Hazard detection
│   └── ...                # 5 more modules
├── tb/                     # Testbench
│   └── riscv_cpu_tb.sv
├── test/                   # Tests
│   ├── unit/              # Unit tests (8 test files)
│   │   ├── test_alu.sv
│   │   ├── test_register_file.sv
│   │   ├── test_control_unit.sv
│   │   └── ...            # 5 more unit tests
│   └── programs/          # Test programs (.hex)
├── scripts/                # Build scripts
│   ├── setup_arch.sh        # Complete setup for Arch Linux
│   ├── simulate.sh          # Run simulation
│   ├── test_all.sh          # Run all tests
│   ├── synthesize.sh        # Synthesize design
│   ├── install_pdk.sh       # Install Sky130 PDK (optional)
│   └── run_openlane.sh      # Full ASIC flow
├── openlane/               # OpenLane configuration
│   ├── config.json         # OpenLane settings
│   └── runs/               # Run results (generated)
│       └── run_1/
│           └── results/
│               └── final/
│                   └── gds/
│                       └── riscv_cpu.gds  # Final GDSII output
├── Makefile                # Build automation
└── README.md               # This file
```

---

## Quick Start

### Basic Setup (Simulation Only)

For simulation and testing:

```bash
# Install required packages
sudo pacman -S base-devel git icarus-verilog gtkwave make

# Clone the repository
git clone <repository-url>
cd risk-v-32-bit-inorder-5-stage-cpu

# Run all tests
./scripts/test_all.sh

# Run a single simulation
./scripts/simulate.sh test01_basic_arithmetic
```

### Complete Setup (Full ASIC Flow)

For the full ASIC design flow including GDSII generation, use the automated setup script:

```bash
# Run the complete setup script (requires sudo)
sudo ./scripts/setup_arch.sh
```

This script installs everything automatically. Alternatively, you can install manually:

#### Step 1: Install System Packages

**Arch Linux:**
```bash
sudo pacman -S base-devel git make \
    icarus-verilog gtkwave \
    verilator yosys \
    python python-pip python-pipx \
    docker docker-compose \
    klayout
```

**Ubuntu/Debian:**
```bash
sudo apt install build-essential git make \
    iverilog gtkwave \
    verilator yosys \
    python3 python3-pip pipx \
    docker.io docker-compose \
    klayout
```

#### Step 2: Configure Docker

Configure Docker to run without sudo:

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Configure Docker data directory
sudo mkdir -p /etc/docker
sudo bash -c 'cat > /etc/docker/daemon.json << EOF
{
  "data-root": "/home/docker",
  "storage-driver": "overlay2"
}
EOF'

# Create data directory
sudo mkdir -p /home/docker
sudo chmod 775 /home/docker

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Note: Logout and login required for group changes to take effect
# Alternatively, run: newgrp docker
```

#### Step 3: Install Sky130 PDK

The Process Design Kit requires approximately 2-3 GB of storage:

```bash
./scripts/install_pdk.sh
```

This installs the Sky130 PDK to `/home/archi/pdk/sky130A/`.

#### Step 4: Download OpenLane Docker Image

```bash
docker pull efabless/openlane:2023.11.03
```

Download size: approximately 3-5 GB.

---

## Usage

### Running Tests

```bash
# Run all test programs with correctness verification
./scripts/simulate all

# Run a single test program
./scripts/simulate test01_basic_arithmetic

# Run unit tests only
make unit-tests

# View waveforms (after running a simulation)
gtkwave waves.vcd
```

### Running Synthesis

```bash
./scripts/synthesize.sh
```

Output: `syn/riscv_cpu_synth.v`

### Running ASIC Flow

Complete place and route with GDSII generation:

```bash
./scripts/run_openlane.sh
```

Estimated runtime: 30 minutes to 2 hours.

Output: `openlane/runs/run_1/results/final/gds/riscv_cpu.gds`

View layout:
```bash
klayout openlane/runs/run_1/results/final/gds/riscv_cpu.gds
```

### Makefile Commands

Alternative command interface:

```bash
# Testing
make unit-tests          # Run all unit tests

# Individual unit tests
make test-alu           # Test ALU module
make test-register-file # Test register file
make test-control-unit  # Test control unit
make test-hazard-detection # Test hazard detection
make test-branch-control # Test branch control
make test-immediate-generator # Test immediate generator
make test-data-memory   # Test data memory
make test-instruction-memory # Test instruction memory

# Simulation
./scripts/simulate all              # Run all tests with verification
./scripts/simulate test01_basic_arithmetic  # Run single test

# Synthesis
make synth

# Linting
make lint

# ASIC flow
make openlane-run

# Cleanup
make clean              # Clean all generated files
make clean-sim          # Clean only simulation files
```

---

## Design Metrics

| Metric | Value |
|--------|-------|
| **Technology** | Sky130 130nm |
| **Cells** | 10,121 |
| **Utilization** | 30% |
| **Die Area** | 1.0 mm² (988.54 × 976.48 µm) |
| **Clock Period** | 20 ns (50 MHz) |
| **WNS** | 0.0 ns (timing met) |
| **TNS** | 0.0 ns (timing met) |
| **Wire Length** | 742,122 units |
| **Vias** | 88,210 |
| **DRC Violations** | 0 |
| **LVS Errors** | 0 |

---

## Test Programs

The following test programs verify CPU functionality:

| Test | Description |
|------|-------------|
| `benchmark` | 100-instruction benchmark for IPC measurement |
| `test01_basic_arithmetic` | ADD, SUB, ADDI |
| `test02_logic_operations` | AND, OR, XOR, ANDI, ORI, XORI |
| `test03_shifts` | SLL, SRL, SRA, SLLI, SRLI, SRAI |
| `test06_memory_ops` | LW, SW |
| `test07_branches` | BEQ, BNE, BLT, BGE |
| `test08_jumps` | JAL, JALR |

All tests pass.

---

## Benchmark Suite

The `benchmark` test program measures IPC performance. Run it with:

```bash
./scripts/simulate benchmark benchmark
```

This runs the benchmark in benchmark mode and captures performance statistics.

---

## GDSII Output

The final GDSII file is ready for fabrication:

**Location**: `openlane/runs/run_1/results/final/gds/riscv_cpu.gds`  
**Size**: 38 MB  
**Status**: Ready for tapeout

View it with:
```bash
klayout openlane/runs/run_1/results/final/gds/riscv_cpu.gds
```

---

## Design Decisions

### Pipeline Hazard Resolution

The design implements stall-based hazard resolution rather than data forwarding for the following reasons:
- Reduced control logic complexity
- Simplified verification process
- Improved synthesizability with fewer critical paths
- Maintains correctness while trading some performance

### Reset Strategy

Synchronous reset is used throughout the design:
- Eliminates multi-edge sensitivity issues in ASIC synthesis
- Follows current industry practices for digital design
- Simplifies static timing analysis
- Improves timing closure

### Clock Frequency Target

The 50 MHz clock frequency (20 ns period) was selected based on:
- Conservative timing target ensuring first-pass success
- Compatibility with Sky130 process characteristics
- Sufficient performance for embedded applications
- Headroom for design iteration and optimization

---

## Development Methodology

The design was developed using the following flow:

1. **RTL Design** - SystemVerilog implementation of all modules
2. **Unit Testing** - Individual module verification
3. **System Integration** - Full CPU verification with test programs
4. **Code Quality** - Linting with Verible
5. **Logic Synthesis** - Gate-level synthesis with Yosys
6. **Physical Design** - Place and route with OpenLane
7. **Signoff** - Final verification and GDSII generation

---

## Tools Used

- **Icarus Verilog** - Simulation
- **GTKWave** - Waveform viewing
- **Verible** - Linting
- **Yosys** - Synthesis
- **OpenLane** - ASIC flow (place & route)
- **Docker** - Containerized toolchain
- **Sky130 PDK** - 130nm process design kit
- **KLayout** - GDSII viewer
- **Make** - Build automation

---

## Troubleshooting

### Docker Permission Issues

If Docker commands fail with permission errors:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Insufficient Disk Space

Verify Docker is using the home directory:
```bash
docker info | grep "Docker Root Dir"
```

Expected output: `/home/docker`

### PDK Not Found

Install the PDK:
```bash
./scripts/install_pdk.sh
```

### Simulation Failures

Verify test programs exist:
```bash
ls test/programs/*.hex
```

### Alternative Platforms

**Ubuntu/Debian**: Replace `pacman` commands with `apt`  
**macOS**: Most tools compatible, OpenLane requires Docker Desktop  
**Windows**: Use WSL2 with Ubuntu

---

## Resource Usage

- **Simulation**: ~100 MB RAM, ~50 MB storage, < 1 minute
- **Synthesis**: ~500 MB RAM, ~100 MB storage, 1-2 minutes
- **ASIC Flow**: 2-4 GB RAM peak, ~5 GB storage, 30 minutes - 2 hours

---

## Acknowledgments

- RISC-V International for the ISA specification
- Efabless Corporation for the open-source Sky130 PDK and OpenLane tools
- Google and SkyWater Technology for sponsoring the Sky130 process
- The open-source EDA community for development tools

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.