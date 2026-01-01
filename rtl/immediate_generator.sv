// Immediate generator - pulls out immediate values from instructions
// RISC-V packs immediates in different places depending on instruction type
module immediate_generator (
    input  logic [31:0] instruction,
    input  logic [1:0]  imm_sel,
    output logic [31:0] immediate
);

    always_comb begin
        case (imm_sel)
            2'b00: begin  // I-type (12 bits)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            2'b01: begin  // S-type (12 bits, split between two fields)
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            2'b10: begin  // B-type (13 bits for branch offsets)
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25],
                             instruction[11:8], 1'b0};
            end

            2'b11: begin  // J-type or U-type
                if (instruction[6:0] == 7'b1101111) begin  // JAL
                    immediate = {{12{instruction[31]}}, instruction[19:12],
                                 instruction[20], instruction[30:21], 1'b0};
                end else begin  // LUI/AUIPC
                    immediate = {instruction[31:12], 12'b0};
                end
            end

            default: immediate = 32'b0;
        endcase
    end

endmodule
