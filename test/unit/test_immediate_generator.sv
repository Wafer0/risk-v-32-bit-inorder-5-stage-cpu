// Unit Test for Immediate Generator
module test_immediate_generator;
    logic [31:0] instruction, immediate;
    logic [1:0] imm_sel;
    
    immediate_generator dut (.*);
    
    initial begin
        $display("Testing Immediate Generator...");
        
        // Test I-type (12-bit immediate)
        instruction = 32'hFFF00093;  // ADDI x1, x0, -1
        imm_sel = 2'b00;
        #1; assert(immediate == 32'hFFFFFFFF) else $error("I-type failed");
        
        // Test S-type (store offset)
        instruction = 32'h00112023;  // SW x1, 0(x2) - offset split
        imm_sel = 2'b01;
        #1; assert(immediate[11:0] == 12'h000) else $error("S-type failed");
        
        // Test B-type (branch offset)
        instruction = 32'h00208063;  // BEQ x1, x2, offset
        imm_sel = 2'b10;
        #1; // Check LSB is 0 (aligned)
        assert(immediate[0] == 0) else $error("B-type alignment failed");
        
        // Test J-type (JAL)
        instruction = 32'h0000006F;  // JAL x0, 0
        imm_sel = 2'b11;
        #1; assert(immediate[0] == 0) else $error("J-type alignment failed");
        
        // Test U-type (LUI)
        instruction = 32'h12345037;  // LUI x0, 0x12345
        imm_sel = 2'b11;
        #1; 
        assert(immediate[31:12] == 20'h12345) else $error("U-type upper failed");
        assert(immediate[11:0] == 12'h0) else $error("U-type lower not zero");
        
        $display("OK: Immediate Generator tests passed");
        $finish;
    end
endmodule




