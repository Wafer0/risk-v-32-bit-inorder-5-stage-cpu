// ALU with integrated control logic
// ALU control merged into this module for simplicity
module alu (
    input  logic [31:0] a, b,
    input  logic [1:0]  alu_op,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,
    output logic [31:0] result,
    output logic        zero
);
    logic [4:0] alu_ctrl;

    // Figure out which operation we need
    always_comb begin
        case (alu_op)
            2'b00: alu_ctrl = 5'b00011;  // ADD for loads/stores
            2'b01: alu_ctrl = 5'b00100;  // SUB for branch comparisons
            2'b11: alu_ctrl = 5'b00001;  // OR for LUI
            2'b10: begin  // R-type or I-type ops
                case (funct3)
                    3'b000: alu_ctrl = funct7[5] ? 5'b00100 : 5'b00011; // SUB or ADD
                    3'b001: alu_ctrl = 5'b00101;  // shift left
                    3'b010: alu_ctrl = 5'b01000;  // signed less than
                    3'b011: alu_ctrl = 5'b01001;  // unsigned less than
                    3'b100: alu_ctrl = 5'b00010;  // XOR
                    3'b101: alu_ctrl = funct7[5] ? 5'b00111 : 5'b00110;
                        // shift right (arith or logic)
                    3'b110: alu_ctrl = 5'b00001;  // OR
                    3'b111: alu_ctrl = 5'b00000;  // AND
                    default: alu_ctrl = 5'b00000;
                endcase
            end
            default: alu_ctrl = 5'b00000;
        endcase
        end

    // Do the actual operation
    always_comb begin
        case (alu_ctrl)
            5'b00000: result = a & b;
            5'b00001: result = a | b;
            5'b00010: result = a ^ b;
            5'b00011: result = a + b;
            5'b00100: result = a - b;
            5'b00101: result = a << b[4:0];
            5'b00110: result = a >> b[4:0];
            5'b00111: result = $signed(a) >>> b[4:0];
            5'b01000: result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            5'b01001: result = (a < b) ? 32'h1 : 32'h0;
            default:  result = 32'h0;
        endcase
    end

    assign zero = (result == 32'h0);
endmodule
