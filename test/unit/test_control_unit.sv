// Unit Test for Control Unit
module test_control_unit;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic reg_write, mem_to_reg, mem_read, mem_write;
    logic alu_src, branch, jump;
    logic [1:0] alu_op, imm_sel, mem_width;
    logic auipc_sel;
    
    control_unit dut (.*);
    
    initial begin
        $display("Testing Control Unit...");
        
        // Test R-type (ADD)
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000;
        #1;
        assert(reg_write && !mem_read && !mem_write && !alu_src) 
            else $error("R-type failed");
        assert(alu_op == 2'b10) else $error("R-type alu_op failed");
        
        // Test I-type ALU (ADDI)
        opcode = 7'b0010011;
        #1;
        assert(reg_write && !mem_read && !mem_write && alu_src)
            else $error("I-type ALU failed");
        
        // Test Load (LW)
        opcode = 7'b0000011; funct3 = 3'b010;
        #1;
        assert(reg_write && mem_read && !mem_write && alu_src && mem_to_reg)
            else $error("Load failed");
        assert(mem_width == 2'b10) else $error("LW mem_width failed");
        
        // Test Store (SW)
        opcode = 7'b0100011; funct3 = 3'b010;
        #1;
        assert(!reg_write && !mem_read && mem_write && alu_src)
            else $error("Store failed");
        
        // Test Branch (BEQ)
        opcode = 7'b1100011; funct3 = 3'b000;
        #1;
        assert(!reg_write && branch && !jump) else $error("Branch failed");
        assert(alu_op == 2'b01) else $error("Branch alu_op failed");
        
        // Test JAL
        opcode = 7'b1101111;
        #1;
        assert(reg_write && jump && !branch) else $error("JAL failed");
        
        // Test LUI
        opcode = 7'b0110111;
        #1;
        assert(reg_write && alu_op == 2'b11) else $error("LUI failed");
        
        $display("OK: Control Unit tests passed");
        $finish;
    end
endmodule




