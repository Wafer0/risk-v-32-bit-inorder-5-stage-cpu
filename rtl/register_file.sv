// Register file - 32 registers, x0 is always zero
module register_file (
    input  logic        clk, rst,
    input  logic        reg_write,
    input  logic [4:0]  read_addr1, read_addr2, write_addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1, read_data2
);
    logic [31:0] registers [32];
    integer i;

    // Reads are combinational, but x0 is hardwired to 0
    assign read_data1 = (read_addr1 == 0) ? 32'h0 : registers[read_addr1];
    assign read_data2 = (read_addr2 == 0) ? 32'h0 : registers[read_addr2];

    // Writes happen on clock edge (synchronous reset for ASIC)
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) registers[i] <= 32'h0;
        end else if (reg_write && write_addr != 0) begin
            registers[write_addr] <= write_data;
        end
    end
endmodule
