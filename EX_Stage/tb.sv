
`timescale 1ns/1ps

module tb_ex_stage;

    logic [31:0] rs1_data, rs2_data, imm_out, address;
    logic branch, alu_src, fn7_5, mux_inp;
    logic [2:0] fn3, aluop;
    logic [6:0] imm11_5, opcode;
    logic and_out_ex;
    logic [31:0] alu_out, pc_ex_out;

    integer passed = 0;
    integer failed = 0;

    ex_stage dut (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_out),
        .address(address),
        .branch(branch),
        .alu_src(alu_src),
        .fn7_5(fn7_5),
        .mux_inp(mux_inp),
        .fn3(fn3),
        .imm11_5(imm11_5),
        .aluop(aluop),
        .opcode(opcode),
        .and_out_ex(and_out_ex),
        .alu_out(alu_out),
        .pc_ex_out(pc_ex_out)
    );

    task check(
        input string name,
        input logic [31:0] expected_alu,
        input logic expected_jump,
        input logic [31:0] expected_pc
    );
        begin
            #1;
            if (alu_out === expected_alu &&
                and_out_ex === expected_jump &&
                pc_ex_out === expected_pc) begin
                $display("PASS: %s", name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %s | ALU expected %h got %h | Jump expected %b got %b | PC expected %h got %h",
                    name, expected_alu, alu_out,
                    expected_jump, and_out_ex,
                    expected_pc, pc_ex_out);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $display("\n===== EX STAGE TESTS =====");

        rs1_data = 10;
        rs2_data = 5;
        imm_out = 7;
        address = 100;
        branch = 0;
        alu_src = 0;
        fn7_5 = 0;
        mux_inp = 0;
        fn3 = 0;
        imm11_5 = 0;
        aluop = 3'b000;
        opcode = 7'h33;

        // Register-register ADD: 10 + 5 = 15
        check("Register ADD", 15, 0, 107);

        // Immediate ADD: 10 + 7 = 17
        alu_src = 1;
        aluop = 3'b001;
        check("Immediate ADD", 17, 0, 107);

        // BEQ taken: equal operands, target 100 + 8 = 108
        alu_src = 0;
        aluop = 3'b100;
        branch = 1;
        fn3 = 3'b000;
        opcode = 7'h63;
        rs1_data = 5;
        rs2_data = 5;
        imm_out = 8;
        check("BEQ taken", 0, 1, 108);

        // BEQ not taken
        rs2_data = 6;
        check("BEQ not taken", 0, 0, 108);

        // JAL: unconditional jump
         branch = 0;
         opcode = 7'h6F;
         aluop = 3'b110;
         alu_src = 1;
         rs1_data = 0;
         imm_out = 20;
         rs2_data = 0;
         mux_inp = 0;
         check("JAL", 20, 1, 120);

        // JALR: ALU calculates base + immediate, clears bit 0
        opcode = 7'h67;
        aluop = 3'b001;
        alu_src = 1;
        rs1_data = 32'h105;
        imm_out = 32'h20;
        mux_inp = 1;
        check("JALR", 32'h125, 1, 32'h124);

        $display("\n===== RESULTS =====");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("EX STAGE TESTS PASSED!");
        else
            $display("EX STAGE TESTS FAILED!");

        $finish;
    end

endmodule
