// Top-level CPU module - ties everything together
// This is a classic 5-stage pipeline with stall-based hazard handling
module riscv_cpu (
    input  logic        clk,
    input  logic        rst,
    output logic [31:0] imem_addr,
    input  logic [31:0] imem_data,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    input  logic [31:0] dmem_rdata,
    output logic        dmem_we,
    output logic        dmem_re,
    output logic [3:0]  dmem_byte_en
);

    // IF stage
    logic [31:0] pc, pc_next, pc_plus_4_if, instr_if;
    logic        pc_write;

    // ID stage
    logic [31:0] pc_plus_4_id, instr_id, rd1_id, rd2_id, imm_id;
    logic [4:0]  rs1, rs2, rd_id;
    logic        reg_write_id, mem_to_reg_id, mem_read_id, mem_write_id;
    logic        alu_src_id, branch_id, jump_id, auipc_id;
    logic [1:0]  alu_op_id, imm_sel_id, mem_width_id;
    logic [2:0]  funct3_id;
    logic [6:0]  funct7_id;
    logic        if_id_write;

    // EX stage
    logic [31:0] pc_plus_4_ex, rd1_ex, rd2_ex, imm_ex;
    logic [31:0] alu_a, alu_b, alu_out, branch_tgt, jump_tgt;
    logic [4:0]  rd_ex;
    logic [2:0]  funct3_ex;
    logic [6:0]  funct7_ex;
    logic [1:0]  alu_op_ex;
    logic        reg_write_ex, mem_to_reg_ex, mem_read_ex, mem_write_ex;
    logic        alu_src_ex, branch_ex, jump_ex, auipc_ex, alu_zero;
    logic [1:0]  mem_width_ex;
    logic        branch_taken;

    // MEM stage
    logic [31:0] alu_out_mem, rd2_mem, pc_plus_4_mem, mem_data;
    logic [4:0]  rd_mem;
    logic        reg_write_mem, mem_to_reg_mem, mem_read_mem, mem_write_mem, jump_mem;
    logic [1:0]  mem_width_mem;

    // WB stage
    logic [31:0] alu_out_wb, mem_data_wb, pc_plus_4_wb, wb_data;
    logic [4:0]  rd_wb;
    logic        reg_write_wb, mem_to_reg_wb, jump_wb;

    // Hazard detection
    logic        stall, bubble;

    // ========== Hazard Detection ==========
    // Check if we need to stall due to data or control hazards
    hazard_detection haz_detect (
        .id_rs1(rs1), .id_rs2(rs2),
        .ex_rd(rd_ex), .mem_rd(rd_mem), .wb_rd(rd_wb),
        .ex_reg_write(reg_write_ex), .mem_reg_write(reg_write_mem),
        .wb_reg_write(reg_write_wb),
        .ex_mem_read(mem_read_ex),
        .id_branch(branch_id), .id_jump(jump_id),
        .stall(stall), .bubble(bubble)
    );

    // PC only updates if we're not stalling
    assign pc_write = ~stall;
    assign if_id_write = ~stall;

    // ========== IF Stage ==========
    // Program counter updates every cycle unless stalled (synchronous reset)
    always_ff @(posedge clk) begin
        if (rst) pc <= 32'h0;
        else if (pc_write) pc <= pc_next;
    end

    assign pc_plus_4_if = pc + 4;
    assign imem_addr = pc;
    assign instr_if = imem_data;

    // Choose next PC - branches and jumps resolved in EX
    assign pc_next = (branch_taken & branch_ex) ? branch_tgt :
                     (jump_ex) ? jump_tgt : pc_plus_4_if;

    // IF/ID pipeline register - holds if stalled (synchronous reset)
    always_ff @(posedge clk) begin
        if (rst) begin
            pc_plus_4_id <= 32'h0;
            instr_id <= 32'h00000013;  // NOP
        end else if (if_id_write) begin
            pc_plus_4_id <= pc_plus_4_if;
            instr_id <= instr_if;
        end
        // If stalled, keep the same values (don't update)
    end

    // ========== ID Stage ==========
    // Pull out instruction fields
    assign rs1 = instr_id[19:15];
    assign rs2 = instr_id[24:20];
    assign rd_id = instr_id[11:7];
    assign funct3_id = instr_id[14:12];
    assign funct7_id = instr_id[31:25];

    // Register file reads happen here
    register_file regfile (
        .clk(clk), .rst(rst),
        .reg_write(reg_write_wb),
        .read_addr1(rs1), .read_addr2(rs2), .write_addr(rd_wb),
        .write_data(wb_data),
        .read_data1(rd1_id), .read_data2(rd2_id)
    );

    // Figure out what this instruction needs
    control_unit ctrl (
        .opcode(instr_id[6:0]), .funct3(funct3_id), .funct7(funct7_id),
        .reg_write(reg_write_id), .mem_to_reg(mem_to_reg_id),
        .mem_read(mem_read_id), .mem_write(mem_write_id),
        .alu_src(alu_src_id), .branch(branch_id), .jump(jump_id),
        .alu_op(alu_op_id), .imm_sel(imm_sel_id),
        .mem_width(mem_width_id), .auipc_sel(auipc_id)
    );

    // Extract immediate value based on instruction type
    immediate_generator immgen (
        .instruction(instr_id), .imm_sel(imm_sel_id), .immediate(imm_id)
    );

    // ID/EX pipeline register - insert bubble if stalling (synchronous reset)
    always_ff @(posedge clk) begin
        if (rst || bubble) begin
            // Clear all control signals on bubble (creates NOP)
            {pc_plus_4_ex, rd1_ex, rd2_ex, imm_ex, rd_ex, funct3_ex, funct7_ex} <= '0;
            {reg_write_ex, mem_to_reg_ex, mem_read_ex, mem_write_ex} <= '0;
            {alu_src_ex, branch_ex, jump_ex, auipc_ex, mem_width_ex, alu_op_ex} <= '0;
        end else begin
            pc_plus_4_ex <= pc_plus_4_id;
            rd1_ex <= rd1_id;
            rd2_ex <= rd2_id;
            imm_ex <= imm_id;
            rd_ex <= rd_id;
            funct3_ex <= funct3_id;
            funct7_ex <= funct7_id;
            reg_write_ex <= reg_write_id;
            mem_to_reg_ex <= mem_to_reg_id;
            mem_read_ex <= mem_read_id;
            mem_write_ex <= mem_write_id;
            alu_src_ex <= alu_src_id;
            branch_ex <= branch_id;
            jump_ex <= jump_id;
            auipc_ex <= auipc_id;
            mem_width_ex <= mem_width_id;
            alu_op_ex <= alu_op_id;
        end
    end

    // ========== EX Stage ==========
    // Choose ALU inputs based on instruction type
    assign alu_a = auipc_ex ? (pc_plus_4_ex - 4) : rd1_ex;
    assign alu_b = alu_src_ex ? imm_ex : rd2_ex;

    // Main ALU does arithmetic and logic
    alu alu_unit (
        .a(alu_a), .b(alu_b),
        .alu_op(alu_op_ex), .funct3(funct3_ex), .funct7(funct7_ex),
        .result(alu_out), .zero(alu_zero)
    );

    // Calculate where to jump for branches and jumps
    assign branch_tgt = pc_plus_4_ex - 4 + imm_ex;
    assign jump_tgt = (funct3_ex == 3'b000) ?  // JALR uses register
                      ((rd1_ex + imm_ex) & ~32'h1) :
                      (pc_plus_4_ex - 4 + imm_ex);

    // Check if we should actually take the branch
    branch_control brctrl (
        .funct3(funct3_ex), .alu_zero(alu_zero), .alu_result(alu_out),
        .branch(branch_ex), .branch_taken(branch_taken)
    );

    // EX/MEM pipeline register (synchronous reset)
    always_ff @(posedge clk) begin
        if (rst) begin
            {alu_out_mem, rd2_mem, pc_plus_4_mem, rd_mem} <= '0;
            {reg_write_mem, mem_to_reg_mem, mem_read_mem, mem_write_mem, jump_mem} <= '0;
            mem_width_mem <= '0;
        end else begin
            alu_out_mem <= alu_out;
            rd2_mem <= rd2_ex;
            pc_plus_4_mem <= pc_plus_4_ex;
            rd_mem <= rd_ex;
            reg_write_mem <= reg_write_ex;
            mem_to_reg_mem <= mem_to_reg_ex;
            mem_read_mem <= mem_read_ex;
            mem_write_mem <= mem_write_ex;
            jump_mem <= jump_ex;
            mem_width_mem <= mem_width_ex;
        end
    end

    // ========== MEM Stage ==========
    // Connect to data memory
    assign dmem_addr = alu_out_mem;
    assign dmem_wdata = rd2_mem;
    assign dmem_re = mem_read_mem;
    assign dmem_we = mem_write_mem;
    assign mem_data = dmem_rdata;

    // Byte enable based on access size
    assign dmem_byte_en = (mem_width_mem == 2'b00) ? 4'b0001 :  // Byte
                          (mem_width_mem == 2'b01) ? 4'b0011 :  // Halfword
                                                      4'b1111;   // Word

    // MEM/WB pipeline register (synchronous reset)
    always_ff @(posedge clk) begin
        if (rst) begin
            {alu_out_wb, mem_data_wb, pc_plus_4_wb, rd_wb} <= '0;
            {reg_write_wb, mem_to_reg_wb, jump_wb} <= '0;
        end else begin
            alu_out_wb <= alu_out_mem;
            mem_data_wb <= mem_data;
            pc_plus_4_wb <= pc_plus_4_mem;
            rd_wb <= rd_mem;
            reg_write_wb <= reg_write_mem;
            mem_to_reg_wb <= mem_to_reg_mem;
            jump_wb <= jump_mem;
        end
    end

    // ========== WB Stage ==========
    // Choose what to write back to register file
    assign wb_data = jump_wb ? pc_plus_4_wb :       // JAL/JALR save return address
                     mem_to_reg_wb ? mem_data_wb :   // Load from memory
                     alu_out_wb;                     // ALU result

endmodule
