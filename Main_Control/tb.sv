`timescale 1ns/1ps

module tb_main_control;

    logic [6:0] opcode;
    logic [2:0] fn3;

    logic [1:0] memtoreg;
    logic branch, mux_inp, memread, memwrite;
    logic alusrc, reg_write;
    logic [2:0] aluop;

    main_control dut (
        .opcode(opcode),
        .fn3(fn3),
        .memtoreg(memtoreg),
        .branch(branch),
        .mux_inp(mux_inp),
        .memread(memread),
        .memwrite(memwrite),
        .alusrc(alusrc),
        .reg_write(reg_write),
        .aluop(aluop)
    );

    task check(
        input string name,
        input logic [1:0] expected_memtoreg,
        input logic expected_branch,
        input logic expected_mux_inp,
        input logic expected_memread,
        input logic expected_memwrite,
        input logic expected_alusrc,
        input logic expected_reg_write,
        input logic [2:0] expected_aluop
    );
        begin
            #1;
            if ({memtoreg, branch, mux_inp, memread,
                 memwrite, alusrc, reg_write, aluop} ===
                {expected_memtoreg, expected_branch,
                 expected_mux_inp, expected_memread,
                 expected_memwrite, expected_alusrc,
                 expected_reg_write, expected_aluop})
                $display("PASS: %s", name);
            else
                $display("FAIL: %s", name);
        end
    endtask

    initial begin

        $display("Starting Main Control Tests");

        fn3 = 0;

        // R-type
        opcode = 7'b0110011;
        check("R-type", 0, 0, 0, 0, 0, 0, 1, 0);

        // I-type ALU
        opcode = 7'b0010011;
        check("I-type ALU", 0, 0, 0, 0, 0, 1, 1, 1);

        // Load
        opcode = 7'b0000011;
        check("Load", 1, 0, 0, 1, 0, 1, 1, 2);

        // Store
        opcode = 7'b0100011;
        check("Store", 3, 0, 0, 0, 1, 1, 0, 3);

        // Branch
        opcode = 7'b1100011;
        check("Branch", 0, 1, 0, 0, 0, 0, 0, 4);

        // JAL
        opcode = 7'b1101111;
        check("JAL", 2, 0, 0, 0, 0, 1, 1, 6);

        // JALR
        opcode = 7'b1100111;
        check("JALR", 2, 0, 1, 0, 0, 1, 1, 1);

        // LUI
        opcode = 7'b0110111;
        check("LUI", 2, 0, 0, 0, 0, 1, 1, 6);

        // AUIPC
        opcode = 7'b0010111;
        check("AUIPC", 2, 0, 0, 0, 0, 1, 1, 0);

        // Unsupported opcode
        opcode = 7'b1111111;
        check("Unsupported", 0, 0, 0, 0, 0, 0, 0, 0);

        $display("Main Control Tests Completed");
        $finish;

    end

endmodule
