
`timescale 1ns/1ps

module tb_wb_stage;

    logic [31:0] mem_out, alu_out, return_addr;
    logic [31:0] imm_out, pc_signed_offset;
    logic [1:0] memtoreg;
    logic [6:0] opcode_out_d;
    logic [31:0] wb_data;

    integer passed = 0;
    integer failed = 0;

    wb_stage dut (
        .mem_out(mem_out),
        .alu_out(alu_out),
        .return_addr(return_addr),
        .imm_out(imm_out),
        .pc_signed_offset(pc_signed_offset),
        .memtoreg(memtoreg),
        .opcode_out_d(opcode_out_d),
        .wb_data(wb_data)
    );

    task check(input string name, input logic [31:0] expected);
        begin
            #1;
            if (wb_data === expected) begin
                $display("PASS: %s", name);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: %s | Expected %h | Got %h",
                         name, expected, wb_data);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $display("\n===== WB STAGE TESTS =====");

        mem_out = 32'h12345678;
        alu_out = 32'hAABBCCDD;
        return_addr = 32'h80000004;
        imm_out = 32'h00001234;
        pc_signed_offset = 32'h80000100;
        opcode_out_d = 7'h33;

        // memtoreg = 00
        memtoreg = 2'b00;
        check("ALU result", 32'hAABBCCDD);

        // memtoreg = 01
        memtoreg = 2'b01;
        check("Memory result", 32'h12345678);

        // memtoreg = 10: JAL and JALR
        memtoreg = 2'b10;
        opcode_out_d = 7'h6F;
        check("JAL return address", 32'h80000004);

        opcode_out_d = 7'h67;
        check("JALR return address", 32'h80000004);

        // LUI
        opcode_out_d = 7'h37;
        check("LUI immediate", 32'h00001234);

        // AUIPC
        opcode_out_d = 7'h17;
        check("AUIPC address", 32'h80000100);

        // Unsupported opcode fallback
        opcode_out_d = 7'h33;
        check("Default ALU fallback", 32'hAABBCCDD);

        // memtoreg = 11
        memtoreg = 2'b11;
        check("memtoreg 11 fallback", 32'hAABBCCDD);

        $display("\n===== RESULTS =====");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);

        if (failed == 0)
            $display("WB STAGE TESTS PASSED!");
        else
            $display("WB STAGE TESTS FAILED!");

        $finish;
    end

endmodule
