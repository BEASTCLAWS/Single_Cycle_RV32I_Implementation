`timescale 1ns/1ps

module tb_decoder;

    logic [31:0] instruction;

    logic [4:0] rs1, rs2, rd;
    logic [6:0] opcode, imm11_5;
    logic [2:0] fn3;
    logic [11:0] imm;
    logic [19:0] imm_uj;
    logic fn7_5;

    decoder dut (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .imm11_5(imm11_5),
        .fn3(fn3),
        .imm(imm),
        .imm_uj(imm_uj),
        .fn7_5(fn7_5)
    );

    task check(input string name, input logic condition);
        begin
            if (condition)
                $display("PASS: %s", name);
            else
                $display("FAIL: %s", name);
        end
    endtask

    initial begin

        $display("Starting Decoder Tests");

        // Test 1: R-type
        instruction = 32'hFE6282B3;
        #1;
        check("R-type opcode", opcode == 7'b0110011);
        check("R-type fields", rd == 5 && rs1 == 5 &&
              rs2 == 6 && fn3 == 0 && fn7_5 == 1);

        // Test 2: I-type ALU
        instruction = 32'h00A30293;
        #1;
        check("I-type fields", rd == 5 && rs1 == 6 &&
              imm == 12'h00A && imm11_5 == 0);

        // Test 3: Load
        instruction = 32'h00432283;
        #1;
        check("Load fields", rd == 5 && rs1 == 6 &&
              imm == 12'h004);

        // Test 4: Store
        instruction = 32'h00632223;
        #1;
        check("Store fields", rs1 == 6 && rs2 == 6 &&
              imm == 12'h004);

        // Test 5: Branch
        instruction = 32'h00628463;
        #1;
        check("Branch fields", rs1 == 5 && rs2 == 6 &&
              imm == 12'h004);

        // Test 6: JAL
        instruction = 32'h008000EF;
        #1;
        check("JAL fields", rd == 1 &&
              imm_uj == 20'h00004);

        // Test 7: JALR
        instruction = 32'h004302E7;
        #1;
        check("JALR fields", rd == 5 && rs1 == 6 &&
              imm == 12'h004);

        // Test 8: LUI
        instruction = 32'h123452B7;
        #1;
        check("LUI fields", rd == 5 &&
              imm_uj == 20'h12345);

        // Test 9: AUIPC
        instruction = 32'h12345297;
        #1;
        check("AUIPC fields", rd == 5 &&
              imm_uj == 20'h12345);

        // Test 10: Unsupported opcode
        instruction = 32'h0000007F;
        #1;
        check("Unsupported opcode", opcode == 7'h7F &&
              rs1 == 0 && rs2 == 0 && rd == 0 &&
              fn3 == 0 && imm == 0 && imm_uj == 0 &&
              imm11_5 == 0 && fn7_5 == 0);

        $display("Decoder Tests Completed");
        $finish;

    end

endmodule
