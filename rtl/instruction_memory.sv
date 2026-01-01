// Instruction memory - loads the program from a hex file
// For synthesis, this becomes a simple ROM
// verible-lint-disable-line explicit-parameter-storage-type
module instruction_memory #(parameter PROGRAM_FILE = "program.hex") (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);
    logic [31:0] mem [128];  // 128 words
    integer i;

    // Fill with NOPs, then load the actual program
    // Only for simulation, not synthesis
    `ifndef SYNTHESIS
    initial begin
            for (i = 0; i < 128; i = i + 1) mem[i] = 32'h00000013;  // NOP
            $readmemh(PROGRAM_FILE, mem);
        end
    `else
    // For synthesis, initialize with NOPs
    initial begin
        for (i = 0; i < 128; i = i + 1) mem[i] = 32'h00000013;  // NOP
    end
    `endif

    assign instruction = mem[addr[8:2]];  // Word-aligned
endmodule
