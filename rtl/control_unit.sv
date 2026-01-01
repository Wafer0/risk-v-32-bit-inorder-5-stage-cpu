// Control unit - decodes the opcode and generates all the control signals
module control_unit (
    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,
    output logic        reg_write,
    output logic        mem_to_reg,
    output logic        mem_read,
    output logic        mem_write,
    output logic        alu_src,
    output logic        branch,
    output logic        jump,
    output logic [1:0]  alu_op,
    output logic [1:0]  imm_sel,
    output logic [1:0]  mem_width,
    output logic        auipc_sel
);

    // Big case statement to decode each instruction type
    always_comb begin
        case (opcode)
            7'b0110011: begin  // R-type (register ops like ADD, SUB, etc.)
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
                {alu_src, branch, jump} = 3'b000;
                {alu_op, imm_sel, mem_width} = 6'b100010;
                auipc_sel = 1'b0;
            end

            7'b0010011: begin  // I-type ALU ops (immediate versions)
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
                {alu_src, branch, jump} = 3'b100;
                {alu_op, imm_sel, mem_width} = 6'b100010;
                auipc_sel = 1'b0;
            end

            7'b0000011: begin  // Loads - funct3 tells us the size
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b1110;
                {alu_src, branch, jump} = 3'b100;
                {alu_op, imm_sel} = 4'b0000;
                auipc_sel = 1'b0;
                case (funct3)
                    3'b000: mem_width = 2'b00;  // byte
                    3'b001: mem_width = 2'b01;  // halfword
                    default: mem_width = 2'b10; // word
                endcase
            end

            7'b0100011: begin  // Stores
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b0001;
                {alu_src, branch, jump} = 3'b100;
                {alu_op, imm_sel} = 4'b0001;
                auipc_sel = 1'b0;
                case (funct3)
                    3'b000: mem_width = 2'b00;  // byte
                    3'b001: mem_width = 2'b01;  // halfword
                    default: mem_width = 2'b10; // word
                endcase
            end

            7'b1100011: begin  // Branches
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b0000;
                {alu_src, branch, jump} = 3'b010;
                {alu_op, imm_sel, mem_width} = 6'b011010;
                auipc_sel = 1'b0;
            end

            7'b1101111: begin  // JAL
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
                {alu_src, branch, jump} = 3'b001;
                {alu_op, imm_sel, mem_width} = 6'b001110;
                auipc_sel = 1'b0;
            end

            7'b1100111: begin  // JALR
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
                {alu_src, branch, jump} = 3'b101;
                {alu_op, imm_sel, mem_width} = 6'b000010;
                auipc_sel = 1'b0;
            end

            7'b0110111: begin  // LUI
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
                {alu_src, branch, jump} = 3'b100;
                {alu_op, imm_sel, mem_width} = 6'b111110;
                auipc_sel = 1'b0;
            end

            7'b0010111: begin  // AUIPC
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
                {alu_src, branch, jump} = 3'b100;
                {alu_op, imm_sel, mem_width} = 6'b001110;
                auipc_sel = 1'b1;
            end

            default: begin  // Treat unknown opcodes as NOP
                {reg_write, mem_to_reg, mem_read, mem_write} = 4'b0000;
                {alu_src, branch, jump} = 3'b000;
                {alu_op, imm_sel, mem_width} = 6'b000010;
                auipc_sel = 1'b0;
            end
        endcase
    end

endmodule
