// Unit Test for Branch Control
module test_branch_control;
    logic [2:0] funct3;
    logic alu_zero;
    logic [31:0] alu_result;
    logic branch;
    logic branch_taken;
    
    branch_control dut (.*);
    
    initial begin
        $display("Testing Branch Control...");
        
        branch = 1;  // Enable branch
        
        // Test BEQ (branch if equal)
        funct3 = 3'b000; alu_zero = 1; alu_result = 0;
        #1; assert(branch_taken == 1) else $error("BEQ (equal) failed");
        
        funct3 = 3'b000; alu_zero = 0; alu_result = 5;
        #1; assert(branch_taken == 0) else $error("BEQ (not equal) failed");
        
        // Test BNE (branch if not equal)
        funct3 = 3'b001; alu_zero = 0;
        #1; assert(branch_taken == 1) else $error("BNE failed");
        
        // Test BLT (branch if less than)
        funct3 = 3'b100; alu_result = 32'hFFFFFFFF;  // Negative
        #1; assert(branch_taken == 1) else $error("BLT failed");
        
        // Test BGE (branch if greater or equal)
        funct3 = 3'b101; alu_result = 32'h00000001;  // Positive
        #1; assert(branch_taken == 1) else $error("BGE failed");
        
        // Test not branching when branch signal is off
        branch = 0; funct3 = 3'b000; alu_zero = 1;
        #1; assert(branch_taken == 0) else $error("Branch disable failed");
        
        $display("OK: Branch Control tests passed");
        $finish;
    end
endmodule




