
module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        and_out,
    input  logic [31:0] pc_signed_offset,
    output logic [31:0] address,
    output logic [31:0] pc_new
);

    // Calculate the next sequential instruction address
    assign pc_new = address + 32'd4;

    // Program Counter register
    always_ff @(posedge clk or posedge reset)
    begin
        if (reset)
            address <= 32'h8000_0000;

        else if (!stall)
        begin
            if (and_out)
                address <= pc_signed_offset;
            else
                address <= pc_new;
        end
    end

endmodule
