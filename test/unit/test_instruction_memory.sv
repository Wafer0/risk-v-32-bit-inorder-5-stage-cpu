// Unit Test for Instruction Memory
module test_instruction_memory;
    logic [31:0] addr, instruction;
    integer f;
    
    // Create the test file before instantiating the module
    initial begin
        f = $fopen("sim/test_prog.hex", "w");
        $fwrite(f, "00500093\n");  // ADDI x1, x0, 5
        $fwrite(f, "00A00113\n");  // ADDI x2, x0, 10
        $fwrite(f, "002081B3\n");  // ADD x3, x1, x2
        $fclose(f);
    end
    
    instruction_memory #(.PROGRAM_FILE("sim/test_prog.hex")) dut (.*);
    
    initial begin
        #2;  // Wait for file to be written and loaded
        $display("Testing Instruction Memory...");
        
        addr = 32'h0;
        #1; 
        assert(instruction == 32'h00500093) else $error("Instruction 0 failed: got %h", instruction);
        
        addr = 32'h4;
        #1; 
        assert(instruction == 32'h00A00113) else $error("Instruction 1 failed: got %h", instruction);
        
        addr = 32'h8;
        #1; 
        assert(instruction == 32'h002081B3) else $error("Instruction 2 failed: got %h", instruction);
        
        // Uninitialized memory should be NOP
        addr = 32'h100;
        #1; 
        assert(instruction == 32'h00000013) else $error("NOP fill failed: got %h", instruction);
        
        $display("OK: Instruction Memory tests passed");
        $finish;
    end
endmodule
