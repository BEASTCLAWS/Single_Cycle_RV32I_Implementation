module id_stage(
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    output logic [6:0]  opcode_out_d,
    output logic [6:0]  imm11_5,
    output logic [2:0]  fn3_out_d,
    output logic        fn7_5,
    output logic [2:0]  aluop,
    output logic [1:0]  memtoreg,
    output logic        branch,
    output logic        mem_write,
    output logic        mem_read,
    output logic        alu_src,
    output logic        mux_inp
);

    // Internal signals from Decoder
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [11:0] imm;
    logic [19:0] imm_uj;

    // Internal register write control
    logic reg_write;

    // Decoder
    decoder decoder_unit (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode_out_d),
        .imm11_5(imm11_5),
        .fn3(fn3_out_d),
        .imm(imm),
        .imm_uj(imm_uj),
        .fn7_5(fn7_5)
    );

    // Immediate Generator
    imm_generator imm_unit (
        .imm_input(imm),
        .fn3(fn3_out_d),
        .opcode(opcode_out_d),
        .imm_input_uj(imm_uj),
        .imm_output(imm_out)
    );

    // Register File
    register_file register_unit (
        .rs1_sel(rs1),
        .rs2_sel(rs2),
        .reg_write(reg_write && !stall),
        .clk(clk),
        .reset(reset),
        .wb_data(wb_data),
        .rd_sel(rd),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Main Control
    main_control control_unit (
        .opcode(opcode_out_d),
        .fn3(fn3_out_d),
        .memtoreg(memtoreg),
        .branch(branch),
        .mux_inp(mux_inp),
        .memread(mem_read),
        .memwrite(mem_write),
        .alusrc(alu_src),
        .reg_write(reg_write),
        .aluop(aluop)
    );

endmodule
