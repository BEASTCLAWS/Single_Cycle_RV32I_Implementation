`timescale 1ns/1ps

module tb_register_file;

    logic [4:0] rs1_sel, rs2_sel;
    logic reg_write;
    logic clk, reset;
    logic [31:0] wb_data;
    logic [4:0] rd_sel;

    logic [31:0] rs1_data, rs2_data;

    register_file dut (
        .rs1_sel(rs1_sel),
        .rs2_sel(rs2_sel),
        .reg_write(reg_write),
        .clk(clk),
        .reset(reset),
        .wb_data(wb_data),
        .rd_sel(rd_sel),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    always #5 clk = ~clk;

    task check(input string name, input logic condition);
        begin
            if (condition)
                $display("PASS: %s", name);
            else
                $display("FAIL: %s", name);
        end
    endtask

    initial begin

        clk = 0;
        reset = 0;
        reg_write = 0;
        rs1_sel = 0;
        rs2_sel = 0;
        rd_sel = 0;
        wb_data = 0;

        $display("Starting Register File Tests");

        // Test 1: Asynchronous reset
        #2 reset = 1;
        #1;

        rs1_sel = 5'd5;
        rs2_sel = 5'd10;
        #1;

        check("Asynchronous reset", 
              rs1_data == 0 && rs2_data == 0);

        #6 reset = 0;

        // Test 2: Write to register 5
        @(negedge clk);
        reg_write = 1;
        rd_sel = 5'd5;
        wb_data = 32'h12345678;

        @(posedge clk);
        #1;

        rs1_sel = 5'd5;
        #1;

        check("Write register 5", 
              rs1_data == 32'h12345678);

        // Test 3: Write to register 10
        @(negedge clk);
        rd_sel = 5'd10;
        wb_data = 32'hABCDEF12;

        @(posedge clk);
        #1;

        rs2_sel = 5'd10;
        #1;

        check("Write register 10",
              rs2_data == 32'hABCDEF12);

        // Test 4: Simultaneous dual read
        rs1_sel = 5'd5;
        rs2_sel = 5'd10;
        #1;

        check("Dual read",
              rs1_data == 32'h12345678 &&
              rs2_data == 32'hABCDEF12);

        // Test 5: x0 always reads zero
        rs1_sel = 5'd0;
        #1;

        check("x0 reads zero", rs1_data == 0);

        // Test 6: Attempt to write to x0
        @(negedge clk);
        rd_sel = 5'd0;
        wb_data = 32'hFFFFFFFF;

        @(posedge clk);
        #1;

        rs1_sel = 5'd0;
        #1;

        check("x0 cannot be written", rs1_data == 0);

        // Test 7: Write disabled
        @(negedge clk);
        reg_write = 0;
        rd_sel = 5'd5;
        wb_data = 32'hFFFFFFFF;

        @(posedge clk);
        #1;

        rs1_sel = 5'd5;
        #1;

        check("Write disabled",
              rs1_data == 32'h12345678);

        // Test 8: Reset clears previously written data
        #2 reset = 1;
        #1;

        rs1_sel = 5'd5;
        rs2_sel = 5'd10;
        #1;

        check("Reset clears registers",
              rs1_data == 0 && rs2_data == 0);

        $display("Register File Tests Completed");

        $finish;

    end

endmodule
