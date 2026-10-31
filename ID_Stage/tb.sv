`timescale 1ns/1ps

module tb_id_stage;

    logic clk, reset, stall;
    logic [31:0] instruction, wb_data;

    logic [31:0] rs1_data, rs2_data, imm_out;
    logic [6:0] opcode_out_d, imm11_5;
    logic [2:0] fn3_out_d, aluop;
    logic fn7_5;
    logic [1:0] memtoreg;
    logic branch, mem_write, mem_read, alu_src, mux_inp;

    id_stage dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .instruction(instruction),
        .wb_data(wb_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_out),
        .opcode_out_d(opcode_out_d),
        .imm11_5(imm11_5),
        .fn3_out_d(fn3_out_d),
        .fn7_5(fn7_5),
        .aluop(aluop),
        .memtoreg(memtoreg),
        .branch(branch),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_src(alu_src),
        .mux_inp(mux_inp)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        stall = 0;
        instruction = 0;
        wb_data = 0;

        $display("\n===== ID STAGE TESTS =====");

        // TEST 1: Reset
        #2;
        if (rs1_data == 0)
            $display("PASS: Reset");
        else
            $display("FAIL: Reset");

        reset = 0;

        // TEST 2: Write x5 using ADDI
        @(negedge clk);
        instruction = {12'hFFF, 5'd0, 3'b000, 5'd5, 7'b0010011};
        wb_data = 32'hCAFEBABE;

        #1;
        if (imm_out == 32'hFFFFFFFF)
            $display("PASS: Immediate sign extension");
        else
            $display("FAIL: Immediate sign extension");

        if (opcode_out_d == 7'b0010011 &&
            fn3_out_d == 3'b000 &&
            imm11_5 == 7'b1111111)
            $display("PASS: Decoder outputs");
        else
            $display("FAIL: Decoder outputs");

        @(posedge clk);
        #1;

        // TEST 3: Read x5 through both register ports
        instruction = {7'b0000000, 5'd5, 5'd5,
                       3'b000, 5'd0, 7'b0110011};

        #1;
        if (rs1_data == 32'hCAFEBABE &&
            rs2_data == 32'hCAFEBABE)
            $display("PASS: Register write and dual read");
        else
            $display("FAIL: Register write and dual read");

        if (aluop == 3'b000 && opcode_out_d == 7'b0110011)
            $display("PASS: R-type control signals");
        else
            $display("FAIL: R-type control signals");

        // TEST 4: Stall must prevent register write to x6
        @(negedge clk);
        instruction = {12'h001, 5'd0, 3'b000, 5'd6, 7'b0010011};
        wb_data = 32'hDEADBEEF;
        stall = 1;

        @(posedge clk);
        #1;

        stall = 0;

        instruction = {7'b0000000, 5'd6, 5'd6,
                       3'b000, 5'd0, 7'b0110011};

        #1;
        if (rs1_data == 0 && rs2_data == 0)
            $display("PASS: Stall prevents register write");
        else
            $display("FAIL: Stall prevents register write");

        // TEST 5: Store control signals
        instruction = {7'b0000000, 5'd2, 5'd1,
                       3'b010, 5'd4, 7'b0100011};

        #1;
        if (mem_write == 1 && mem_read == 0 &&
            alu_src == 1 && branch == 0)
            $display("PASS: Store control signals");
        else
            $display("FAIL: Store control signals");

        // TEST 6: Branch control signals
        instruction = {7'b0000000, 5'd2, 5'd1,
                       3'b000, 5'b00010, 7'b1100011};

        #1;
        if (branch == 1 && aluop == 3'b100)
            $display("PASS: Branch control signals");
        else
            $display("FAIL: Branch control signals");

        // TEST 7: JALR control signals
        instruction = {12'h004, 5'd1, 3'b000,
                       5'd5, 7'b1100111};

        #1;
        if (mux_inp == 1 && memtoreg == 2'b10 &&
            alu_src == 1 && imm_out == 32'd4)
            $display("PASS: JALR control signals");
        else
            $display("FAIL: JALR control signals");

        // TEST 8: Reset clears previously written x5
        instruction = {7'b0000000, 5'd5, 5'd5,
                       3'b000, 5'd0, 7'b0110011};

        #1;
        reset = 1;
        #1;

        if (rs1_data == 0 && rs2_data == 0)
            $display("PASS: Reset clears registers");
        else
            $display("FAIL: Reset clears registers");

        $display("\n===== ID STAGE TESTS COMPLETED =====");

        $finish;

    end

endmodule
