
`timescale 1ns/1ps

module tb_if_stage;

    logic clk;
    logic reset;
    logic stall;
    logic and_out;
    logic [31:0] pc_signed_offset;

    logic [31:0] address;
    logic [31:0] pc_new;

    // DUT
    if_stage dut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .and_out(and_out),
        .pc_signed_offset(pc_signed_offset),
        .address(address),
        .pc_new(pc_new)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 0;
        stall = 0;
        and_out = 0;
        pc_signed_offset = 0;

        $display("Starting IF Stage Tests");

        // Test 1: Reset
        #2 reset = 1;
        #2;

        if (address == 32'h80000000)
            $display("PASS: Reset");
        else
            $display("FAIL: Reset");

        #6 reset = 0;

        // Test 2: Normal PC increment
        @(posedge clk);
        #1;

        if (address == 32'h80000004)
            $display("PASS: PC Increment");
        else
            $display("FAIL: PC Increment");

        // Test 3: Branch
        @(negedge clk);
        and_out = 1;
        pc_signed_offset = 32'h80000100;

        @(posedge clk);
        #1;

        if (address == 32'h80000100)
            $display("PASS: Branch");
        else
            $display("FAIL: Branch");

        // Test 4: Stall
        @(negedge clk);
        and_out = 0;
        stall = 1;

        @(posedge clk);
        #1;

        if (address == 32'h80000100)
            $display("PASS: Stall");
        else
            $display("FAIL: Stall");

        // Test 5: Branch and stall together
        @(negedge clk);
        and_out = 1;
        pc_signed_offset = 32'h80000200;

        @(posedge clk);
        #1;

        if (address == 32'h80000100)
            $display("PASS: Stall Priority");
        else
            $display("FAIL: Stall Priority");

        // Test 6: PC + 4 output
        if (pc_new == 32'h80000104)
            $display("PASS: PC New");
        else
            $display("FAIL: PC New");

        $display("IF Stage Tests Completed");

        $finish;

    end

endmodule
