module pc (
	clk,
	rst,
	pc_write,
	next_pc,
	pc_out
);
	input wire clk;
	input wire rst;
	input wire pc_write;
	input wire [31:0] next_pc;
	output reg [31:0] pc_out;
	always @(posedge clk)
		if (rst)
			pc_out <= 32'h00000000;
		else if (pc_write)
			pc_out <= next_pc;
endmodule
module instruction_memory (
	addr,
	instruction
);
	parameter PROGRAM_FILE = "program.hex";
	input wire [31:0] addr;
	output wire [31:0] instruction;
	reg [31:0] mem [0:127];
	integer i;
	initial begin
		for (i = 0; i < 128; i = i + 1)
			mem[i] = 32'h00000013;
		// $readmemh(PROGRAM_FILE, mem);
	end
	assign instruction = mem[addr[8:2]];
endmodule
module register_file (
	clk,
	rst,
	reg_write,
	read_addr1,
	read_addr2,
	write_addr,
	write_data,
	read_data1,
	read_data2
);
	input wire clk;
	input wire rst;
	input wire reg_write;
	input wire [4:0] read_addr1;
	input wire [4:0] read_addr2;
	input wire [4:0] write_addr;
	input wire [31:0] write_data;
	output wire [31:0] read_data1;
	output wire [31:0] read_data2;
	reg [31:0] registers [0:31];
	integer i;
	assign read_data1 = (read_addr1 == 0 ? 32'h00000000 : registers[read_addr1]);
	assign read_data2 = (read_addr2 == 0 ? 32'h00000000 : registers[read_addr2]);
	always @(posedge clk)
		if (rst)
			for (i = 0; i < 32; i = i + 1)
				registers[i] <= 32'h00000000;
		else if (reg_write && (write_addr != 0))
			registers[write_addr] <= write_data;
endmodule
module control_unit (
	opcode,
	funct3,
	funct7,
	reg_write,
	mem_to_reg,
	mem_read,
	mem_write,
	alu_src,
	branch,
	jump,
	alu_op,
	imm_sel,
	mem_width,
	auipc_sel
);
	reg _sv2v_0;
	input wire [6:0] opcode;
	input wire [2:0] funct3;
	input wire [6:0] funct7;
	output reg reg_write;
	output reg mem_to_reg;
	output reg mem_read;
	output reg mem_write;
	output reg alu_src;
	output reg branch;
	output reg jump;
	output reg [1:0] alu_op;
	output reg [1:0] imm_sel;
	output reg [1:0] mem_width;
	output reg auipc_sel;
	always @(*) begin
		if (_sv2v_0)
			;
		case (opcode)
			7'b0110011: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
				{alu_src, branch, jump} = 3'b000;
				{alu_op, imm_sel, mem_width} = 6'b100010;
				auipc_sel = 1'b0;
			end
			7'b0010011: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
				{alu_src, branch, jump} = 3'b100;
				{alu_op, imm_sel, mem_width} = 6'b100010;
				auipc_sel = 1'b0;
			end
			7'b0000011: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b1110;
				{alu_src, branch, jump} = 3'b100;
				{alu_op, imm_sel} = 4'b0000;
				auipc_sel = 1'b0;
				case (funct3)
					3'b000: mem_width = 2'b00;
					3'b001: mem_width = 2'b01;
					default: mem_width = 2'b10;
				endcase
			end
			7'b0100011: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b0001;
				{alu_src, branch, jump} = 3'b100;
				{alu_op, imm_sel} = 4'b0001;
				auipc_sel = 1'b0;
				case (funct3)
					3'b000: mem_width = 2'b00;
					3'b001: mem_width = 2'b01;
					default: mem_width = 2'b10;
				endcase
			end
			7'b1100011: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b0000;
				{alu_src, branch, jump} = 3'b010;
				{alu_op, imm_sel, mem_width} = 6'b011010;
				auipc_sel = 1'b0;
			end
			7'b1101111: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
				{alu_src, branch, jump} = 3'b001;
				{alu_op, imm_sel, mem_width} = 6'b001110;
				auipc_sel = 1'b0;
			end
			7'b1100111: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
				{alu_src, branch, jump} = 3'b101;
				{alu_op, imm_sel, mem_width} = 6'b000010;
				auipc_sel = 1'b0;
			end
			7'b0110111: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
				{alu_src, branch, jump} = 3'b100;
				{alu_op, imm_sel, mem_width} = 6'b111110;
				auipc_sel = 1'b0;
			end
			7'b0010111: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b1000;
				{alu_src, branch, jump} = 3'b100;
				{alu_op, imm_sel, mem_width} = 6'b001110;
				auipc_sel = 1'b1;
			end
			default: begin
				{reg_write, mem_to_reg, mem_read, mem_write} = 4'b0000;
				{alu_src, branch, jump} = 3'b000;
				{alu_op, imm_sel, mem_width} = 6'b000010;
				auipc_sel = 1'b0;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module immediate_generator (
	instruction,
	imm_sel,
	immediate
);
	reg _sv2v_0;
	input wire [31:0] instruction;
	input wire [1:0] imm_sel;
	output reg [31:0] immediate;
	always @(*) begin
		if (_sv2v_0)
			;
		case (imm_sel)
			2'b00: immediate = {{20 {instruction[31]}}, instruction[31:20]};
			2'b01: immediate = {{20 {instruction[31]}}, instruction[31:25], instruction[11:7]};
			2'b10: immediate = {{20 {instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
			2'b11:
				if (instruction[6:0] == 7'b1101111)
					immediate = {{12 {instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
				else
					immediate = {instruction[31:12], 12'b000000000000};
			default: immediate = 32'b00000000000000000000000000000000;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module alu (
	a,
	b,
	alu_op,
	funct3,
	funct7,
	result,
	zero
);
	reg _sv2v_0;
	input wire [31:0] a;
	input wire [31:0] b;
	input wire [1:0] alu_op;
	input wire [2:0] funct3;
	input wire [6:0] funct7;
	output reg [31:0] result;
	output wire zero;
	reg [4:0] alu_ctrl;
	always @(*) begin
		if (_sv2v_0)
			;
		case (alu_op)
			2'b00: alu_ctrl = 5'b00011;
			2'b01: alu_ctrl = 5'b00100;
			2'b11: alu_ctrl = 5'b00001;
			2'b10:
				case (funct3)
					3'b000: alu_ctrl = (funct7[5] ? 5'b00100 : 5'b00011);
					3'b001: alu_ctrl = 5'b00101;
					3'b010: alu_ctrl = 5'b01000;
					3'b011: alu_ctrl = 5'b01001;
					3'b100: alu_ctrl = 5'b00010;
					3'b101: alu_ctrl = (funct7[5] ? 5'b00111 : 5'b00110);
					3'b110: alu_ctrl = 5'b00001;
					3'b111: alu_ctrl = 5'b00000;
					default: alu_ctrl = 5'b00000;
				endcase
			default: alu_ctrl = 5'b00000;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		case (alu_ctrl)
			5'b00000: result = a & b;
			5'b00001: result = a | b;
			5'b00010: result = a ^ b;
			5'b00011: result = a + b;
			5'b00100: result = a - b;
			5'b00101: result = a << b[4:0];
			5'b00110: result = a >> b[4:0];
			5'b00111: result = $signed(a) >>> b[4:0];
			5'b01000: result = ($signed(a) < $signed(b) ? 32'h00000001 : 32'h00000000);
			5'b01001: result = (a < b ? 32'h00000001 : 32'h00000000);
			default: result = 32'h00000000;
		endcase
	end
	assign zero = result == 32'h00000000;
	initial _sv2v_0 = 0;
endmodule
module data_memory (
	clk,
	mem_read,
	mem_write,
	byte_en,
	addr,
	write_data,
	read_data
);
	reg _sv2v_0;
	input wire clk;
	input wire mem_read;
	input wire mem_write;
	input wire [3:0] byte_en;
	input wire [31:0] addr;
	input wire [31:0] write_data;
	output reg [31:0] read_data;
	reg [7:0] mem [0:511];
	wire [8:0] byte_addr;
	integer i;
	initial for (i = 0; i < 512; i = i + 1)
		mem[i] = 8'h00;
	assign byte_addr = addr[8:0];
	always @(*) begin
		if (_sv2v_0)
			;
		if (byte_en == 4'b0001)
			read_data = {{24 {mem[byte_addr][7]}}, mem[byte_addr]};
		else if (byte_en == 4'b0011)
			read_data = {{16 {mem[byte_addr + 1][7]}}, mem[byte_addr + 1], mem[byte_addr]};
		else
			read_data = {mem[byte_addr + 3], mem[byte_addr + 2], mem[byte_addr + 1], mem[byte_addr]};
	end
	always @(posedge clk)
		if (mem_write) begin
			if (byte_en[0])
				mem[byte_addr] <= write_data[7:0];
			if (byte_en[1])
				mem[byte_addr + 1] <= write_data[15:8];
			if (byte_en[2])
				mem[byte_addr + 2] <= write_data[23:16];
			if (byte_en[3])
				mem[byte_addr + 3] <= write_data[31:24];
		end
	initial _sv2v_0 = 0;
endmodule
module branch_control (
	funct3,
	alu_zero,
	alu_result,
	branch,
	branch_taken
);
	reg _sv2v_0;
	input wire [2:0] funct3;
	input wire alu_zero;
	input wire [31:0] alu_result;
	input wire branch;
	output reg branch_taken;
	always @(*) begin
		if (_sv2v_0)
			;
		case (funct3)
			3'b000: branch_taken = branch & alu_zero;
			3'b001: branch_taken = branch & ~alu_zero;
			3'b100: branch_taken = branch & alu_result[31];
			3'b101: branch_taken = branch & ~alu_result[31];
			3'b110: branch_taken = branch & (alu_result[31] & ~alu_zero);
			3'b111: branch_taken = branch & (~alu_result[31] | alu_zero);
			default: branch_taken = 1'b0;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module hazard_detection (
	id_rs1,
	id_rs2,
	ex_rd,
	mem_rd,
	wb_rd,
	ex_reg_write,
	mem_reg_write,
	wb_reg_write,
	ex_mem_read,
	id_branch,
	id_jump,
	stall,
	bubble
);
	input wire [4:0] id_rs1;
	input wire [4:0] id_rs2;
	input wire [4:0] ex_rd;
	input wire [4:0] mem_rd;
	input wire [4:0] wb_rd;
	input wire ex_reg_write;
	input wire mem_reg_write;
	input wire wb_reg_write;
	input wire ex_mem_read;
	input wire id_branch;
	input wire id_jump;
	output wire stall;
	output wire bubble;
	wire raw_hazard_ex;
	wire raw_hazard_mem;
	wire raw_hazard_wb;
	wire load_use_hazard;
	wire control_hazard;
	assign raw_hazard_ex = (ex_reg_write && (ex_rd != 0)) && ((ex_rd == id_rs1) || (ex_rd == id_rs2));
	assign raw_hazard_mem = (mem_reg_write && (mem_rd != 0)) && ((mem_rd == id_rs1) || (mem_rd == id_rs2));
	assign raw_hazard_wb = (wb_reg_write && (wb_rd != 0)) && ((wb_rd == id_rs1) || (wb_rd == id_rs2));
	assign load_use_hazard = (ex_mem_read && (ex_rd != 0)) && ((ex_rd == id_rs1) || (ex_rd == id_rs2));
	assign control_hazard = id_branch || id_jump;
	assign stall = (((raw_hazard_ex || raw_hazard_mem) || raw_hazard_wb) || load_use_hazard) || control_hazard;
	assign bubble = stall;
endmodule
module riscv_cpu (
	clk,
	rst,
	imem_addr,
	imem_data,
	dmem_addr,
	dmem_wdata,
	dmem_rdata,
	dmem_we,
	dmem_re,
	dmem_byte_en
);
	input wire clk;
	input wire rst;
	output wire [31:0] imem_addr;
	input wire [31:0] imem_data;
	output wire [31:0] dmem_addr;
	output wire [31:0] dmem_wdata;
	input wire [31:0] dmem_rdata;
	output wire dmem_we;
	output wire dmem_re;
	output wire [3:0] dmem_byte_en;
	reg [31:0] pc;
	wire [31:0] pc_next;
	wire [31:0] pc_plus_4_if;
	wire [31:0] instr_if;
	wire pc_write;
	reg [31:0] pc_plus_4_id;
	reg [31:0] instr_id;
	wire [31:0] rd1_id;
	wire [31:0] rd2_id;
	wire [31:0] imm_id;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [4:0] rd_id;
	wire reg_write_id;
	wire mem_to_reg_id;
	wire mem_read_id;
	wire mem_write_id;
	wire alu_src_id;
	wire branch_id;
	wire jump_id;
	wire auipc_id;
	wire [1:0] alu_op_id;
	wire [1:0] imm_sel_id;
	wire [1:0] mem_width_id;
	wire [2:0] funct3_id;
	wire [6:0] funct7_id;
	wire if_id_write;
	reg [31:0] pc_plus_4_ex;
	reg [31:0] rd1_ex;
	reg [31:0] rd2_ex;
	reg [31:0] imm_ex;
	wire [31:0] alu_a;
	wire [31:0] alu_b;
	wire [31:0] alu_out;
	wire [31:0] branch_tgt;
	wire [31:0] jump_tgt;
	reg [4:0] rd_ex;
	reg [2:0] funct3_ex;
	reg [6:0] funct7_ex;
	reg [1:0] alu_op_ex;
	reg reg_write_ex;
	reg mem_to_reg_ex;
	reg mem_read_ex;
	reg mem_write_ex;
	reg alu_src_ex;
	reg branch_ex;
	reg jump_ex;
	reg auipc_ex;
	wire alu_zero;
	reg [1:0] mem_width_ex;
	wire branch_taken;
	reg [31:0] alu_out_mem;
	reg [31:0] rd2_mem;
	reg [31:0] pc_plus_4_mem;
	wire [31:0] mem_data;
	reg [4:0] rd_mem;
	reg reg_write_mem;
	reg mem_to_reg_mem;
	reg mem_read_mem;
	reg mem_write_mem;
	reg jump_mem;
	reg [1:0] mem_width_mem;
	reg [31:0] alu_out_wb;
	reg [31:0] mem_data_wb;
	reg [31:0] pc_plus_4_wb;
	wire [31:0] wb_data;
	reg [4:0] rd_wb;
	reg reg_write_wb;
	reg mem_to_reg_wb;
	reg jump_wb;
	wire stall;
	wire bubble;
	hazard_detection haz_detect(
		.id_rs1(rs1),
		.id_rs2(rs2),
		.ex_rd(rd_ex),
		.mem_rd(rd_mem),
		.wb_rd(rd_wb),
		.ex_reg_write(reg_write_ex),
		.mem_reg_write(reg_write_mem),
		.wb_reg_write(reg_write_wb),
		.ex_mem_read(mem_read_ex),
		.id_branch(branch_id),
		.id_jump(jump_id),
		.stall(stall),
		.bubble(bubble)
	);
	assign pc_write = ~stall;
	assign if_id_write = ~stall;
	always @(posedge clk)
		if (rst)
			pc <= 32'h00000000;
		else if (pc_write)
			pc <= pc_next;
	assign pc_plus_4_if = pc + 4;
	assign imem_addr = pc;
	assign instr_if = imem_data;
	assign pc_next = (branch_taken & branch_ex ? branch_tgt : (jump_ex ? jump_tgt : pc_plus_4_if));
	always @(posedge clk)
		if (rst) begin
			pc_plus_4_id <= 32'h00000000;
			instr_id <= 32'h00000013;
		end
		else if (if_id_write) begin
			pc_plus_4_id <= pc_plus_4_if;
			instr_id <= instr_if;
		end
	assign rs1 = instr_id[19:15];
	assign rs2 = instr_id[24:20];
	assign rd_id = instr_id[11:7];
	assign funct3_id = instr_id[14:12];
	assign funct7_id = instr_id[31:25];
	register_file regfile(
		.clk(clk),
		.rst(rst),
		.reg_write(reg_write_wb),
		.read_addr1(rs1),
		.read_addr2(rs2),
		.write_addr(rd_wb),
		.write_data(wb_data),
		.read_data1(rd1_id),
		.read_data2(rd2_id)
	);
	control_unit ctrl(
		.opcode(instr_id[6:0]),
		.funct3(funct3_id),
		.funct7(funct7_id),
		.reg_write(reg_write_id),
		.mem_to_reg(mem_to_reg_id),
		.mem_read(mem_read_id),
		.mem_write(mem_write_id),
		.alu_src(alu_src_id),
		.branch(branch_id),
		.jump(jump_id),
		.alu_op(alu_op_id),
		.imm_sel(imm_sel_id),
		.mem_width(mem_width_id),
		.auipc_sel(auipc_id)
	);
	immediate_generator immgen(
		.instruction(instr_id),
		.imm_sel(imm_sel_id),
		.immediate(imm_id)
	);
	always @(posedge clk)
		if (rst || bubble) begin
			{pc_plus_4_ex, rd1_ex, rd2_ex, imm_ex, rd_ex, funct3_ex, funct7_ex} <= 1'sb0;
			{reg_write_ex, mem_to_reg_ex, mem_read_ex, mem_write_ex} <= 1'sb0;
			{alu_src_ex, branch_ex, jump_ex, auipc_ex, mem_width_ex, alu_op_ex} <= 1'sb0;
		end
		else begin
			pc_plus_4_ex <= pc_plus_4_id;
			rd1_ex <= rd1_id;
			rd2_ex <= rd2_id;
			imm_ex <= imm_id;
			rd_ex <= rd_id;
			funct3_ex <= funct3_id;
			funct7_ex <= funct7_id;
			reg_write_ex <= reg_write_id;
			mem_to_reg_ex <= mem_to_reg_id;
			mem_read_ex <= mem_read_id;
			mem_write_ex <= mem_write_id;
			alu_src_ex <= alu_src_id;
			branch_ex <= branch_id;
			jump_ex <= jump_id;
			auipc_ex <= auipc_id;
			mem_width_ex <= mem_width_id;
			alu_op_ex <= alu_op_id;
		end
	assign alu_a = (auipc_ex ? pc_plus_4_ex - 4 : rd1_ex);
	assign alu_b = (alu_src_ex ? imm_ex : rd2_ex);
	alu alu_unit(
		.a(alu_a),
		.b(alu_b),
		.alu_op(alu_op_ex),
		.funct3(funct3_ex),
		.funct7(funct7_ex),
		.result(alu_out),
		.zero(alu_zero)
	);
	assign branch_tgt = (pc_plus_4_ex - 4) + imm_ex;
	assign jump_tgt = (funct3_ex == 3'b000 ? (rd1_ex + imm_ex) & ~32'h00000001 : (pc_plus_4_ex - 4) + imm_ex);
	branch_control brctrl(
		.funct3(funct3_ex),
		.alu_zero(alu_zero),
		.alu_result(alu_out),
		.branch(branch_ex),
		.branch_taken(branch_taken)
	);
	always @(posedge clk)
		if (rst) begin
			{alu_out_mem, rd2_mem, pc_plus_4_mem, rd_mem} <= 1'sb0;
			{reg_write_mem, mem_to_reg_mem, mem_read_mem, mem_write_mem, jump_mem} <= 1'sb0;
			mem_width_mem <= 1'sb0;
		end
		else begin
			alu_out_mem <= alu_out;
			rd2_mem <= rd2_ex;
			pc_plus_4_mem <= pc_plus_4_ex;
			rd_mem <= rd_ex;
			reg_write_mem <= reg_write_ex;
			mem_to_reg_mem <= mem_to_reg_ex;
			mem_read_mem <= mem_read_ex;
			mem_write_mem <= mem_write_ex;
			jump_mem <= jump_ex;
			mem_width_mem <= mem_width_ex;
		end
	assign dmem_addr = alu_out_mem;
	assign dmem_wdata = rd2_mem;
	assign dmem_re = mem_read_mem;
	assign dmem_we = mem_write_mem;
	assign mem_data = dmem_rdata;
	assign dmem_byte_en = (mem_width_mem == 2'b00 ? 4'b0001 : (mem_width_mem == 2'b01 ? 4'b0011 : 4'b1111));
	always @(posedge clk)
		if (rst) begin
			{alu_out_wb, mem_data_wb, pc_plus_4_wb, rd_wb} <= 1'sb0;
			{reg_write_wb, mem_to_reg_wb, jump_wb} <= 1'sb0;
		end
		else begin
			alu_out_wb <= alu_out_mem;
			mem_data_wb <= mem_data;
			pc_plus_4_wb <= pc_plus_4_mem;
			rd_wb <= rd_mem;
			reg_write_wb <= reg_write_mem;
			mem_to_reg_wb <= mem_to_reg_mem;
			jump_wb <= jump_mem;
		end
	assign wb_data = (jump_wb ? pc_plus_4_wb : (mem_to_reg_wb ? mem_data_wb : alu_out_wb));
endmodule
