module alu_control (
    input  logic [2:0] alu_op,
    input  logic [2:0] fn3,
    input  logic [6:0] imm11_5,
    input  logic       fn7_5,
    output logic [4:0] control_out
);

    always_comb begin

        control_out = 5'b00000;

        case (alu_op)

            // R-type
            3'b000: begin
                case (fn3)
                    3'b000: control_out = fn7_5 ? 5'b00001 : 5'b00000;
                    3'b001: control_out = 5'b00101;
                    3'b010: control_out = 5'b01000;
                    3'b011: control_out = 5'b01001;
                    3'b100: control_out = 5'b00010;
                    3'b101: control_out = fn7_5 ? 5'b00111 : 5'b00110;
                    3'b110: control_out = 5'b00011;
                    3'b111: control_out = 5'b00100;
                endcase
            end

            // I-type ALU
            3'b001: begin
                case (fn3)
                    3'b000: control_out = 5'b00000;
                    3'b001: control_out = 5'b00101;
                    3'b010: control_out = 5'b01000;
                    3'b011: control_out = 5'b01001;
                    3'b100: control_out = 5'b00010;
                    3'b101: control_out =
                        (imm11_5 == 7'h20) ? 5'b00111 : 5'b00110;
                    3'b110: control_out = 5'b00011;
                    3'b111: control_out = 5'b00100;
                endcase
            end

            // Load and Store
            3'b010, 3'b011, 3'b110:
                control_out = 5'b00000;

            // Branch
            3'b100: begin
                case (fn3)
                    3'b000: control_out = 5'b01010;
                    3'b001: control_out = 5'b01011;
                    3'b100: control_out = 5'b01100;
                    3'b101: control_out = 5'b01101;
                    3'b110: control_out = 5'b01110;
                    3'b111: control_out = 5'b01111;
                    default: control_out = 5'b00000;
                endcase
            end

            default: control_out = 5'b00000;

        endcase
    end

endmodule
