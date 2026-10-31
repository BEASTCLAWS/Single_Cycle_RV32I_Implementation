`timescale 1ns/1ps

module tb_imm_generator;

    logic [11:0] imm_input;
    logic [2:0] fn3;
    logic [6:0] opcode;
    logic [19:0] imm_input_uj;
    logic [31:0] imm_output;

    imm_generator dut (
        .imm_input(imm_input),
        .fn3(fn3),
        .opcode(opcode),
        .imm_input_uj(imm_input_uj),
        .imm_output(imm_output)
    );

    task check(input string name, input logic [31:0] expected);
        begin
            #1;
            if (imm_output === expected)
                $display("PASS: %s", name);
            else
                $display("FAIL: %s | Expected: %h | Got: %h",
                         name, expected, imm_output);
        end
    endtask

    initial begin

        $display("Starting Immediate Generator Tests");

        // Test 1: Branch positive
        opcode = 7'b1100011;
        imm_input = 12'h004;
        imm_input_uj = 0;
        fn3 = 0;
        check("Branch positive", 32'h00000008);

        // Test 2: Branch negative
        imm_input = 12'hFFC;
        check("Branch negative", 32'hFFFFFFF8);

        // Test 3: JAL positive
        opcode = 7'b1101111;
        imm_input_uj = 20'h00004;
        check("JAL positive", 32'h00000008);

        // Test 4: JAL negative
        imm_input_uj = 20'hFFFFC;
        check("JAL negative", 32'hFFFFFFF8);

        // Test 5: LUI
        opcode = 7'b0110111;
        imm_input_uj = 20'h12345;
        check("LUI", 32'h12345000);

        // Test 6: AUIPC
        opcode = 7'b0010111;
        check("AUIPC", 32'h12345000);

        // Test 7: JALR positive
        opcode = 7'b1100111;
        imm_input = 12'h004;
        check("JALR positive", 32'h00000004);

        // Test 8: JALR negative
        imm_input = 12'hFFC;
        check("JALR negative", 32'hFFFFFFFC);

        // Test 9: I-type arithmetic
        opcode = 7'b0010011;
        fn3 = 3'b000;
        imm_input = 12'hFFF;
        check("I-type arithmetic", 32'hFFFFFFFF);

        // Test 10: Shift immediate
        fn3 = 3'b001;
        imm_input = 12'hFE5;
        check("Shift immediate", 32'h00000005);

        // Test 11: Default instruction
        opcode = 7'b0110011;
        imm_input = 12'h008;
        check("Default", 32'h00000008);

        $display("Immediate Generator Tests Completed");

        $finish;

    end

endmodule
