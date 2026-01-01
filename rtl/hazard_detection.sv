// Hazard detection - determines when to stall the pipeline
// Uses stall-based resolution instead of forwarding for simplicity
module hazard_detection (
    input  logic [4:0]  id_rs1, id_rs2,
    input  logic [4:0]  ex_rd, mem_rd, wb_rd,
    input  logic        ex_reg_write, mem_reg_write, wb_reg_write,
    input  logic        ex_mem_read,
    input  logic        id_branch, id_jump,

    output logic        stall,
    output logic        bubble
);

    logic raw_hazard_ex, raw_hazard_mem, raw_hazard_wb;
    logic load_use_hazard;
    logic control_hazard;

    // Check if ID stage needs a register that's still being computed
    // Need to check all three stages (EX, MEM, WB) in case of long dependencies
    assign raw_hazard_ex = ex_reg_write && ex_rd != 0 &&
                          ((ex_rd == id_rs1) || (ex_rd == id_rs2));

    assign raw_hazard_mem = mem_reg_write && mem_rd != 0 &&
                           ((mem_rd == id_rs1) || (mem_rd == id_rs2));

    assign raw_hazard_wb = wb_reg_write && wb_rd != 0 &&
                          ((wb_rd == id_rs1) || (wb_rd == id_rs2));

    // Load-use is tricky - the load data isn't ready until after MEM stage
    assign load_use_hazard = ex_mem_read && ex_rd != 0 &&
                            ((ex_rd == id_rs1) || (ex_rd == id_rs2));

    // Branches and jumps need to stall until we know where we're going
    assign control_hazard = id_branch || id_jump;

    // Stall if any hazard is detected
    assign stall = raw_hazard_ex || raw_hazard_mem || raw_hazard_wb ||
                   load_use_hazard || control_hazard;

    // Insert a bubble (NOP) when we stall
    assign bubble = stall;

endmodule

