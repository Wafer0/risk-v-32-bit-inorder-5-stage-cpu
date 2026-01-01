// Unit Test for Hazard Detection
module test_hazard_detection;
    logic [4:0] id_rs1, id_rs2, ex_rd, mem_rd, wb_rd;
    logic ex_reg_write, mem_reg_write, wb_reg_write;
    logic ex_mem_read, id_branch, id_jump;
    logic stall, bubble;
    
    hazard_detection dut (.*);
    
    initial begin
        $display("Testing Hazard Detection...");
        
        // Initialize - no hazards
        {id_rs1, id_rs2, ex_rd, mem_rd, wb_rd} = '0;
        {ex_reg_write, mem_reg_write, wb_reg_write} = '0;
        {ex_mem_read, id_branch, id_jump} = '0;
        #1; assert(stall == 0) else $error("No hazard failed");
        
        // Test RAW hazard in EX stage
        id_rs1 = 5'd1; ex_rd = 5'd1; ex_reg_write = 1;
        #1; assert(stall == 1) else $error("RAW EX hazard not detected");
        
        // Test RAW hazard in MEM stage
        id_rs1 = 5'd2; ex_rd = 5'd0; ex_reg_write = 0;
        mem_rd = 5'd2; mem_reg_write = 1;
        #1; assert(stall == 1) else $error("RAW MEM hazard not detected");
        
        // Test load-use hazard
        {id_rs1, id_rs2, ex_rd, mem_rd} = '0;
        {ex_reg_write, mem_reg_write, wb_reg_write} = '0;
        id_rs1 = 5'd3; ex_rd = 5'd3; ex_mem_read = 1;
        #1; assert(stall == 1) else $error("Load-use hazard not detected");
        
        // Test control hazard (branch)
        {id_rs1, id_rs2, ex_rd} = '0;
        {ex_reg_write, ex_mem_read} = '0;
        id_branch = 1;
        #1; assert(stall == 1) else $error("Branch hazard not detected");
        
        // Test control hazard (jump)
        id_branch = 0; id_jump = 1;
        #1; assert(stall == 1) else $error("Jump hazard not detected");
        
        // Test no hazard when rd is x0
        id_jump = 0; id_rs1 = 5'd0; ex_rd = 5'd0; ex_reg_write = 1;
        #1; assert(stall == 0) else $error("x0 hazard false positive");
        
        $display("OK: Hazard Detection tests passed");
        $finish;
    end
endmodule




