
`timescale 1ns/1ps

module tb_alu_control;

    logic [2:0] alu_op;
    logic [2:0] fn3;
    logic [6:0] imm11_5;
    logic fn7_5;
    logic [4:0] control_out;

    integer passed = 0;
    integer failed = 0;

    alu_control dut (
        .alu_op(alu_op),
        .fn3(fn3),
        .imm11_5(imm11_5),
        .fn7_5(fn7_5),
        .control_out(control_out)
    );

    task check(input string name, input logic [4:0] expected);
        begin
            #1;
            if (control_out === expected) begin
                $display("PASS: %s", name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %s | Expected %b | Got %b",
                         name, expected, control_out);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $display("\n===== ALU CONTROL TESTS =====");

        imm11_5 = 0;
        fn7_5 = 0;

        // R-type operations
        alu_op = 3'b000;
        fn3 = 3'b000; check("R-type ADD", 5'b00000);
        fn7_5 = 1; check("R-type SUB", 5'b00001);
        fn7_5 = 0;
        fn3 = 3'b001; check("R-type SLL", 5'b00101);
        fn3 = 3'b010; check("R-type SLT", 5'b01000);
        fn3 = 3'b011; check("R-type SLTU", 5'b01001);
        fn3 = 3'b100; check("R-type XOR", 5'b00010);
        fn3 = 3'b101; check("R-type SRL", 5'b00110);
        fn7_5 = 1; check("R-type SRA", 5'b00111);
        fn7_5 = 0;
        fn3 = 3'b110; check("R-type OR", 5'b00011);
        fn3 = 3'b111; check("R-type AND", 5'b00100);

        // I-type operations
        alu_op = 3'b001;
        fn3 = 3'b000; check("I-type ADDI", 5'b00000);
        fn3 = 3'b001; check("I-type SLLI", 5'b00101);
        fn3 = 3'b010; check("I-type SLTI", 5'b01000);
        fn3 = 3'b011; check("I-type SLTIU", 5'b01001);
        fn3 = 3'b100; check("I-type XORI", 5'b00010);
        fn3 = 3'b101;
        imm11_5 = 7'h00; check("I-type SRLI", 5'b00110);
        imm11_5 = 7'h20; check("I-type SRAI", 5'b00111);
        fn3 = 3'b110; check("I-type ORI", 5'b00011);
        fn3 = 3'b111; check("I-type ANDI", 5'b00100);

        // Load, Store and JAL/LUI
        alu_op = 3'b010; check("Load ADD", 5'b00000);
        alu_op = 3'b011; check("Store ADD", 5'b00000);
        alu_op = 3'b110; check("JAL/LUI ADD", 5'b00000);

        // Branch operations
        alu_op = 3'b100;
        fn3 = 3'b000; check("BEQ", 5'b01010);
        fn3 = 3'b001; check("BNE", 5'b01011);
        fn3 = 3'b100; check("BLT", 5'b01100);
        fn3 = 3'b101; check("BGE", 5'b01101);
        fn3 = 3'b110; check("BLTU", 5'b01110);
        fn3 = 3'b111; check("BGEU", 5'b01111);
        fn3 = 3'b010; check("Invalid branch fn3", 5'b00000);
        fn3 = 3'b011; check("Invalid branch fn3", 5'b00000);

        // Default operation
        alu_op = 3'b101;
        check("Default ALU operation", 5'b00000);

        $display("\n===== RESULTS =====");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("ALU CONTROL TESTS PASSED!");
        else
            $display("ALU CONTROL TESTS FAILED!");

        $finish;
    end

endmodule
