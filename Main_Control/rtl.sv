module main_control (
    input  logic [6:0] opcode,
    input  logic [2:0] fn3,
    output logic [1:0] memtoreg,
    output logic       branch,
    output logic       mux_inp,
    output logic       memread,
    output logic       memwrite,
    output logic       alusrc,
    output logic       reg_write,
    output logic [2:0] aluop
);

    always_comb begin

        // Default control signals
        memtoreg = 2'b00;
        branch   = 0;
        mux_inp  = 0;
        memread  = 0;
        memwrite = 0;
        alusrc   = 0;
        reg_write = 0;
        aluop    = 3'b000;

        case (opcode)

            // R-type
            7'b0110011: begin
                reg_write = 1;
                aluop = 3'b000;
            end

            // I-type ALU
            7'b0010011: begin
                alusrc = 1;
                reg_write = 1;
                aluop = 3'b001;
            end

            // Load
            7'b0000011: begin
                memtoreg = 2'b01;
                memread = 1;
                alusrc = 1;
                reg_write = 1;
                aluop = 3'b010;
            end

            // Store
            7'b0100011: begin
                memtoreg = 2'b11;
                memwrite = 1;
                alusrc = 1;
                aluop = 3'b011;
            end

            // Branch
            7'b1100011: begin
                branch = 1;
                aluop = 3'b100;
            end

            // JAL
            7'b1101111: begin
                memtoreg = 2'b10;
                alusrc = 1;
                reg_write = 1;
                aluop = 3'b110;
            end

            // JALR
            7'b1100111: begin
                memtoreg = 2'b10;
                mux_inp = 1;
                alusrc = 1;
                reg_write = 1;
                aluop = 3'b001;
            end

            // LUI
            7'b0110111: begin
                memtoreg = 2'b10;
                alusrc = 1;
                reg_write = 1;
                aluop = 3'b110;
            end

            // AUIPC
            7'b0010111: begin
                memtoreg = 2'b10;
                alusrc = 1;
                reg_write = 1;
                aluop = 3'b000;
            end

            // Unsupported instruction: defaults remain

        endcase

    end

endmodule
