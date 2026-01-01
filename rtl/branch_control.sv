// Branch logic - decides if we should take the branch
// The ALU does subtraction for comparisons, we just look at the result
module branch_control (
    input  logic [2:0]  funct3,
    input  logic        alu_zero,
    input  logic [31:0] alu_result,
    input  logic        branch,
    output logic        branch_taken
);
    always_comb begin
            case (funct3)
            3'b000: branch_taken = branch & alu_zero;           // BEQ
            3'b001: branch_taken = branch & ~alu_zero;          // BNE
            3'b100: branch_taken = branch & alu_result[31];     // BLT (negative = less than)
            3'b101: branch_taken = branch & ~alu_result[31];    // BGE
            3'b110: branch_taken = branch & (alu_result[31] & ~alu_zero); // BLTU
            3'b111: branch_taken = branch & (~alu_result[31] | alu_zero); // BGEU
                default: branch_taken = 1'b0;
            endcase
    end
endmodule
