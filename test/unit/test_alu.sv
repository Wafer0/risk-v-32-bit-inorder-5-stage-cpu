// Unit Test for ALU (with debugging)
module test_alu;
    logic [31:0] a, b, result;
    logic [1:0] alu_op;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic zero;
    
    alu dut (.*);
    
    initial begin
        $display("Testing ALU...");
        
        // Test ADD
        a = 10; b = 20; alu_op = 2'b10; funct3 = 3'b000; funct7 = 7'b0000000;
        #1; 
        $display("ADD: a=%0d b=%0d result=%0d (expected 30)", a, b, result);
        assert(result == 30) else $error("ADD failed");
        
        // Test SUB (R-type requires alu_op[0]=0 for funct7 check)
        a = 50; b = 30; alu_op = 2'b10; funct3 = 3'b000; funct7 = 7'b0100000;
        #1; 
        $display("SUB: a=%0d b=%0d result=%0d (expected 20) funct7[5]=%b", a, b, result, funct7[5]);
        assert(result == 20) else $error("SUB failed");
        
        // Test AND
        a = 32'hFF; b = 32'h0F; alu_op = 2'b10; funct3 = 3'b111; funct7 = 7'b0000000;
        #1; 
        $display("AND: a=%h b=%h result=%h (expected 0xF)", a, b, result);
        assert(result == 32'h0F) else $error("AND failed");
        
        // Test OR
        a = 32'hF0; b = 32'h0F; alu_op = 2'b10; funct3 = 3'b110; funct7 = 7'b0000000;
        #1;
        $display("OR: a=%h b=%h result=%h (expected 0xFF)", a, b, result);
        assert(result == 32'hFF) else $error("OR failed");
        
        // Test XOR
        a = 32'hFF; b = 32'h0F; alu_op = 2'b10; funct3 = 3'b100; funct7 = 7'b0000000;
        #1; 
        $display("XOR: a=%h b=%h result=%h (expected 0xF0)", a, b, result);
        assert(result == 32'hF0) else $error("XOR failed");
        
        // Test SLL (shift left)
        a = 32'h1; b = 32'h4; alu_op = 2'b10; funct3 = 3'b001; funct7 = 7'b0000000;
        #1; 
        $display("SLL: a=%h b=%h result=%h (expected 0x10)", a, b, result);
        assert(result == 32'h10) else $error("SLL failed");
        
        // Test SRL (shift right logical)
        a = 32'h10; b = 32'h2; alu_op = 2'b10; funct3 = 3'b101; funct7 = 7'b0000000;
        #1; 
        $display("SRL: a=%h b=%h result=%h (expected 0x4)", a, b, result);
        assert(result == 32'h4) else $error("SRL failed");
        
        // Test SLT (set less than)
        a = -5; b = 10; alu_op = 2'b10; funct3 = 3'b010; funct7 = 7'b0000000;
        #1;
        $display("SLT: a=%d b=%d result=%d (expected 1)", $signed(a), $signed(b), result);
        assert(result == 1) else $error("SLT failed");
        
        // Test zero flag
        a = 5; b = 5; alu_op = 2'b10; funct3 = 3'b000; funct7 = 7'b0100000;  // SUB
        #1; 
        $display("ZERO: a=%d b=%d result=%d zero=%b (expected 0, 1)", a, b, result, zero);
        assert(zero == 1) else $error("Zero flag failed");
        
        $display("OK: ALU tests passed");
        $finish;
    end
endmodule
