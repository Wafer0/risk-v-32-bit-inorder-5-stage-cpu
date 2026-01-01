// Unit Test for Data Memory
module test_data_memory;
    logic clk = 0, mem_read, mem_write;
    logic [3:0] byte_en;
    logic [31:0] addr, write_data, read_data;
    
    data_memory dut (.*);
    
    always #5 clk = ~clk;
    
    initial begin
        $display("Testing Data Memory...");
        
        // Test word write and read
        addr = 32'h0; write_data = 32'hDEADBEEF; 
        mem_write = 1; byte_en = 4'b1111;
        @(posedge clk); #1;
        mem_write = 0; mem_read = 1;
        #1; assert(read_data == 32'hDEADBEEF) else $error("Word read/write failed");
        
        // Test byte write
        addr = 32'h4; write_data = 32'h000000FF;
        mem_write = 1; byte_en = 4'b0001;  // Write only lowest byte
        @(posedge clk); #1;
        mem_write = 0; byte_en = 4'b1111;
        #1; assert(read_data[7:0] == 8'hFF) else $error("Byte write failed");
        
        // Test halfword write
        addr = 32'h8; write_data = 32'h0000ABCD;
        mem_write = 1; byte_en = 4'b0011;  // Write lower 2 bytes
        @(posedge clk); #1;
        mem_write = 0; byte_en = 4'b1111;
        #1; assert(read_data[15:0] == 16'hABCD) else $error("Halfword write failed");
        
        // Test sign extension for byte
        addr = 32'h10; write_data = 32'h00000080;  // Negative byte
        mem_write = 1; byte_en = 4'b0001;
        @(posedge clk); #1;
        mem_write = 0; byte_en = 4'b0001;
        #1; assert(read_data[31:8] == 24'hFFFFFF) else $error("Byte sign extension failed");
        
        $display("OK: Data Memory tests passed");
        $finish;
    end
endmodule




