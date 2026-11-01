`timescale 1ns/1ps

module tb_alu;

    logic [4:0] alu_control;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] alu_out;
    logic zero;

    alu dut (
        .alu_control(alu_control),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .alu_out(alu_out),
        .zero(zero)
    );

    task check(
        input string name,
        input logic [31:0] expected_out,
        input logic expected_zero
    );
        begin
            #1;
            if (alu_out === expected_out && zero === expected_zero)
                $display("PASS: %s", name);
            else
                $display("FAIL: %s | Expected: %h, %b | Got: %h, %b",
                         name, expected_out, expected_zero, alu_out, zero);
        end
    endtask

    initial begin
        rs1_data = 32'd10;
        rs2_data = 32'd5;

        $display("\n===== ALU TESTS =====");

        alu_control = 5'b00000;
        check("ADD", 32'd15, 0);

        alu_control = 5'b00001;
        check("SUB", 32'd5, 0);

        alu_control = 5'b00010;
        check("XOR", 32'd15, 0);

        alu_control = 5'b00011;
        check("OR", 32'd15, 0);

        alu_control = 5'b00100;
        check("AND", 32'd0, 0);

        alu_control = 5'b00101;
        check("SLL", 32'd320, 0);

        alu_control = 5'b00110;
        check("SRL", 32'd0, 0);

        alu_control = 5'b00111;
        check("SRA", 32'd0, 0);

        alu_control = 5'b01000;
        check("SLT", 32'd0, 0);

        alu_control = 5'b01001;
        check("SLTU", 32'd0, 0);

        alu_control = 5'b01010;
        check("BEQ false", 32'd0, 0);

        alu_control = 5'b01011;
        check("BNE true", 32'd0, 1);

        alu_control = 5'b01100;
        check("BLT false", 32'd0, 0);

        alu_control = 5'b01101;
        check("BGE true", 32'd0, 1);

        alu_control = 5'b01110;
        check("BLTU false", 32'd0, 0);

        alu_control = 5'b01111;
        check("BGEU true", 32'd0, 1);

        alu_control = 5'b10000;
        check("Unused operation", 32'd0, 0);

        // Signed comparison test
        rs1_data = 32'hFFFFFFFF;
        rs2_data = 32'd1;

        alu_control = 5'b01000;
        check("Signed SLT", 32'd1, 0);

        alu_control = 5'b01100;
        check("Signed BLT", 32'd0, 1);

        $display("\n===== ALU TESTS COMPLETED =====");
        $finish;
    end

endmodule
