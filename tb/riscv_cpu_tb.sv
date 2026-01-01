// Simple RISC-V CPU Testbench
module riscv_cpu_tb;
    `ifndef PROGRAM_FILE
    `define PROGRAM_FILE "program.hex"
    `endif
    `ifndef TEST_NAME
    `define TEST_NAME "test"
    `endif
    `ifndef SIMULATION_CYCLES
    `define SIMULATION_CYCLES 500
    `endif

    logic clk = 0;
    logic rst;
    logic [31:0] imem_addr, imem_data;
    logic [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    logic dmem_we, dmem_re;
    logic [3:0] dmem_byte_en;

    // Clock
    always #5 clk = ~clk;

    // CPU
    riscv_cpu cpu_inst (
        .clk(clk), .rst(rst),
        .imem_addr(imem_addr), .imem_data(imem_data),
        .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata), .dmem_rdata(dmem_rdata),
        .dmem_we(dmem_we), .dmem_re(dmem_re), .dmem_byte_en(dmem_byte_en)
    );

    // Instruction Memory
    instruction_memory #(.PROGRAM_FILE(`PROGRAM_FILE)) imem_inst (
        .addr(imem_addr), .instruction(imem_data)
    );

    // Data Memory
    data_memory dmem_inst (
        .clk(clk), .mem_read(dmem_re), .mem_write(dmem_we),
        .byte_en(dmem_byte_en), .addr(dmem_addr),
        .write_data(dmem_wdata), .read_data(dmem_rdata)
    );

    // VCD dump
    initial begin
        `ifdef DUMP_VCD
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, riscv_cpu_tb);
        `endif
    end

    // Benchmark statistics
    `ifdef BENCHMARK_MODE
    integer cycle_count = 0;
    integer instruction_count = 0;
    logic [31:0] prev_pc = 32'hFFFFFFFF;
    integer pc_stable_count = 0;
    `endif

    // Test
    initial begin
        $display("========================================");
        $display("RISC-V CPU Simulation: %s", `TEST_NAME);
        $display("========================================");

        rst = 1;
        #20 rst = 0;

        `ifdef BENCHMARK_MODE
        cycle_count = 0;
        instruction_count = 0;
        prev_pc = 32'hFFFFFFFF;
        pc_stable_count = 0;
        `endif

        // Run simulation until program completes or timeout
        begin
            integer sim_cycle;
            logic program_done = 0;
            for (sim_cycle = 0; sim_cycle < `SIMULATION_CYCLES && !program_done; sim_cycle = sim_cycle + 1) begin
                @(posedge clk);
                `ifdef BENCHMARK_MODE
                if (!rst) begin
                    cycle_count = cycle_count + 1;

                    // Count instructions when PC advances by exactly 4 (sequential fetch)
                    // Only count when PC actually advances, not on stalls
                    // Check if we're fetching NOPs (0x00000013) - indicates program done
                    if (prev_pc != 32'hFFFFFFFF) begin
                        if (cpu_inst.imem_addr == prev_pc + 4) begin
                            // Sequential fetch - check if it's a NOP
                            if (imem_data != 32'h00000013) begin
                                instruction_count = instruction_count + 1;
                                pc_stable_count = 0;
                            end else begin
                                // Fetching NOPs - program likely complete
                                pc_stable_count = pc_stable_count + 1;
                            end
                        end else if (cpu_inst.imem_addr != prev_pc) begin
                            // Non-sequential (branch/jump) - new instruction
                            if (imem_data != 32'h00000013) begin
                                instruction_count = instruction_count + 1;
                                pc_stable_count = 0;
                            end else begin
                                pc_stable_count = pc_stable_count + 1;
                            end
                        end else begin
                            // PC didn't change - might be stalled or program complete
                            pc_stable_count = pc_stable_count + 1;
                        end
                    end else if (cpu_inst.imem_addr == 32'h0) begin
                        // First instruction at PC=0
                        if (imem_data != 32'h00000013) begin
                            instruction_count = instruction_count + 1;
                        end
                    end

                    // Detect program completion: PC stops advancing OR fetching NOPs repeatedly
                    if (pc_stable_count > 15 || (imem_data == 32'h00000013 && pc_stable_count > 5)) begin
                        program_done = 1; // Program completed
                    end

                    prev_pc = cpu_inst.imem_addr;
                end
                `endif
            end
        end

        $display("\n========================================");
        $display("Simulation Complete");
        $display("========================================");
        $display("Register File:");
        // Wait for pipeline to complete all writes
        #50;

        // Read registers by forcing read addresses and sampling read data
        // Declare variables at module level would be better, but for now use this approach
        begin
            logic [31:0] reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8;

            // Force read addresses to sample each register
            force cpu_inst.rs1 = 5'd1; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg1 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            force cpu_inst.rs1 = 5'd2; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg2 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            force cpu_inst.rs1 = 5'd3; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg3 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            force cpu_inst.rs1 = 5'd4; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg4 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            force cpu_inst.rs1 = 5'd5; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg5 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            force cpu_inst.rs1 = 5'd6; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg6 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            force cpu_inst.rs1 = 5'd7; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg7 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            force cpu_inst.rs1 = 5'd8; force cpu_inst.rs2 = 5'd0;
            @(posedge clk); #1; reg8 = cpu_inst.rd1_id;
            release cpu_inst.rs1; release cpu_inst.rs2;

            // Format output to match expected format: "x1=0000000a x2=00000014 x3=0000001e"
            $write("x1=%08h x2=%08h x3=%08h x4=%08h", reg1, reg2, reg3, reg4);
            $write(" x5=%08h x6=%08h x7=%08h x8=%08h", reg5, reg6, reg7, reg8);
            $display("");
        end
        $display("========================================");

        `ifdef BENCHMARK_MODE
        $display("STATS: Cycles: %0d", cycle_count);
        $display("STATS: Instructions: %0d", instruction_count);
        if (cycle_count > 0) begin
            $display("STATS: IPC: %0.4f", real'(instruction_count) / real'(cycle_count));
        end else begin
            $display("STATS: IPC: 0.0000");
        end
        $display("========================================\n");
        `else
        $display("========================================\n");
        `endif

        $finish;
    end

    // Timeout
    initial begin
        #(`SIMULATION_CYCLES * 20);
        $display("ERROR: Timeout!");
        $finish;
    end
endmodule
