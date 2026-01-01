// Data memory - 512 bytes for loads and stores
// Supports byte, halfword, and word accesses
module data_memory (
    input  logic        clk,
    input  logic        mem_read, mem_write,
    input  logic [3:0]  byte_en,
    input  logic [31:0] addr, write_data,
    output logic [31:0] read_data
);
    logic [7:0] mem [512];
    logic [8:0] byte_addr;
    integer i;

    initial for (i = 0; i < 512; i = i + 1) mem[i] = 8'h0;

    assign byte_addr = addr[8:0];

    // Reads - sign extend for bytes and halfwords
    always_comb begin
        if (byte_en == 4'b0001)  // LB
            read_data = {{24{mem[byte_addr][7]}}, mem[byte_addr]};
        else if (byte_en == 4'b0011)  // LH
            read_data = {{16{mem[byte_addr+1][7]}}, mem[byte_addr+1], mem[byte_addr]};
        else  // LW
            read_data = {mem[byte_addr+3], mem[byte_addr+2], mem[byte_addr+1], mem[byte_addr]};
    end

    // Writes - byte enables let us write just part of a word
    always_ff @(posedge clk) begin
        if (mem_write) begin
            if (byte_en[0]) mem[byte_addr]   <= write_data[7:0];
            if (byte_en[1]) mem[byte_addr+1] <= write_data[15:8];
            if (byte_en[2]) mem[byte_addr+2] <= write_data[23:16];
            if (byte_en[3]) mem[byte_addr+3] <= write_data[31:24];
        end
    end
endmodule
