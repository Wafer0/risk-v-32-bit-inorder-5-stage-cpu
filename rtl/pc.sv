// Program counter - just holds the current instruction address
// pc_write lets us stall it when there's a hazard
module pc (
    input  logic        clk,
    input  logic        rst,
    input  logic        pc_write,
    input  logic [31:0] next_pc,
    output logic [31:0] pc_out
);
    // Synchronous reset for ASIC synthesis
    always_ff @(posedge clk) begin
        if (rst) pc_out <= 32'h0;
        else if (pc_write) pc_out <= next_pc;
        end
endmodule
