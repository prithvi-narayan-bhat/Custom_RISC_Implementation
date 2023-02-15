/*
    Testing instructions with values where ever possible

    ________________________________________________________________________________________________
    |No. |SW pos |          Instruction Word             | Inst | rs1_data |    rs2      | output   |
    |-----------------------------------------------------------------------------------------------|
    |                       R Instruction                                                           |
    |-----------------------------------------------------------------------------------------------|
    | 0  | 00000 | 0000000 00000 00000 000 00000 0110011 | ADD  | h2000000  | h30000000  | 32000000 |
    | 1  | 00001 | 0100000 00000 00000 000 00000 0110011 | SUB  | d3        | d2         | 00000001 |
    | 2  | 00010 | 0000000 00000 00000 001 00000 0110011 | SLL  | h2000000  | h00000002  | 08000000 |
    | 3  | 00011 | 0000000 00000 00000 010 00000 0110011 | SLT  | d3        | d2         | 00000000 |
    | 4  | 00100 | 0000000 00000 00000 011 00000 0110011 | SLTU | h2000000  | h30000000  | 00000001 |
    | 5  | 00101 | 0000000 00000 00000 100 00000 0110011 | XOR  | d3        | d2         | 00000001 |
    | 6  | 00110 | 0000000 00000 00000 101 00000 0110011 | SRL  | d3        | d2         | 00000000 |
    | 7  | 00111 | 0100000 00000 00000 101 00000 0110011 | SRA  | d3        | d2         | 00000000 |
    | 8  | 01000 | 0000000 00000 00000 110 00000 0110011 | OR   | d3        | d2         | 00000003 |
    | 9  | 01001 | 0000000 00000 00000 111 00000 0110011 | AND  | d3        | d2         | 00000002 |
    |_______________________________________________________________________________________________|
    |                       I Instructions                                                          |
    |-----------------------------------------------------------------------------------------------|
    | 10 | 01010 | 000000000010 00000 000 00000 1100111  | JALR | d3        | DC         | 00000005 |
    | 11 | 01011 | 000000000010 00000 000 00000 0000011  | LB   | d3        | DC         | 00000005 |
    | 12 | 01100 | 000000000010 00000 001 00000 0000011  | LH   | d3        | DC         | 00000005 |
    | 13 | 01101 | 000000000010 00000 010 00000 0000011  | LW   | d3        | DC         | 00000005 |
    | 14 | 01110 | 000000000010 00000 100 00000 0000011  | LBU  | d3        | DC         | 00000005 |
    | 15 | 01111 | 000000000010 00000 101 00000 0000011  | LHU  | d3        | DC         | 00000005 |
    | 16 | 10000 | 000000000010 00000 000 00000 0010011  | ADDI | h2000000  | h456       | 02000456 |
    | 17 | 10001 | 000000000010 00000 010 00000 0010011  | SLTI | d3        | DC         | 00000000 |
    | 18 | 10010 | 000000000010 00000 011 00000 0010011  | SLTIU| d3        | DC         | 00000000 |
    | 19 | 10011 | 000000000010 00000 100 00000 0010011  | XORI | d3        | DC         | 00000001 |
    | 20 | 10100 | 000000000010 00000 110 00000 0010011  | ORI  | d3        | DC         | 00000003 |
    | 21 | 10101 | 000000000010 00000 111 00000 0010011  | ANDI | d3        | DC         | 00000002 |
    | 22 | 10110 | 000000000010 00000 001 00000 0010011  | SLLI | d3        | DC         | 0000000C |
    | 23 | 10111 | 000000000010 00000 101 00000 0010011  | SRLI | d3        | DC         | 00000000 |
    | 24 | 11000 | 000000000010 00000 101 00000 0010011  | SRAI | d3        | DC         | 00000000 |
    |-----------------------------------------------------------------------------------------------|
    |                       U Instructions                                                          |
    |-----------------------------------------------------------------------------------------------|
    | 25 | 11001 | 00000000000000000000 00000 0110111    | LUI  | DC        | DC         | 12345000 |
    | 26 | 11010 | 00000000000000000000 00000 0010111    | AUIPC| DC        | DC         | 00000001 |
    |-----------------------------------------------------------------------------------------------|
    |                       J Instructions                                                          |
    |-----------------------------------------------------------------------------------------------|
    | 27 | 11011 | 00000000000000000000 00000 1101111    | JAL  | h12345678 | DC         | 1234567C |
    |-----------------------------------------------------------------------------------------------|
    |                       S Instructions                                                          |
    |-----------------------------------------------------------------------------------------------|
    | 28 | 11100 | 0100010 00000 00000 000 10110 0100011 |  SB  | h2000000  | DC         | 02000456 |
    | 29 | 11101 | 0100010 00000 00000 001 00000 0100011 |  SH  | d3        | 00000005   | 02000456 |
    | 30 | 11110 | 0100010 00000 00000 010 00000 0100011 |  SW  | d3        | 00000005   | 02000456 |
    |-----------------------------------------------------------------------------------------------|

*/
module ext_top(
    input ADC_CLK_10,
    input [1:0] KEY,
    input [9:0] SW);

    wire [4:0] operation = SW[4:0];
    wire [31:0] iw_out;
    wire [31:0] rs1_data_out, rs2_data_out, pc_out;

    // Set instruction word based on switch position
    always @ (SW) begin
        case (operation)
            /*---------------------------------------------------------Register---------------------------------------------------------*/
            5'b00000:
            begin
                iw_out = 32'b00000000000000000000000000110011;          // ADD  => 32000000
                rs1_data_out = 32'h2000000;
                rs2_data_out = 32'h30000000;
            end

            5'b00001:
            begin
                iw_out = 32'b01000000000000000000000000110011;          // SUB  => 00000001
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b00010:
            begin
                iw_out = 32'b00000000000000000001000000110011;          // SLL  => 08000000
                rs1_data_out = 32'h2000000;
                rs2_data_out = 32'h00000002;
            end

            5'b00011:
            begin
                iw_out = 32'b00000000000000000010000000110011;          // SLT  => 00000000
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b00100:
            begin
                iw_out = 32'b00000000000000000011000000110011;          // SLTU => 00000001
                rs1_data_out = 32'h2000000;
                rs2_data_out = 32'h30000000;
            end

            5'b11111:
            begin
                iw_out = 32'b00000000000000000011000000110011;          // SLTU => 00000001
                rs1_data_out = 32'h2000000;
                rs2_data_out = 32'h20000000;
            end

            5'b00101:
            begin
                iw_out = 32'b00000000000000000100000000110011;          // XOR  => 00000001
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b00110:
            begin
                iw_out = 32'b00000000000000000101000000110011;          // SRL  => 00000000
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b00111:
            begin
                iw_out = 32'b01000000000000000101000000110011;          // SRA  => 00000000
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b01000:
            begin
                iw_out = 32'b00000000000000000110000000110011;          // OR   => 00000003
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b01001:
            begin
                iw_out = 32'b00000000000000000111000000110011;          // AND  => 00000002
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            /*---------------------------------------------------------Immediate---------------------------------------------------------*/
            5'b01010:
            begin
                iw_out = 32'b00000000001000000000000001100111;          // JALR => 00000005
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b01011:
            begin
                iw_out = 32'b00000000001000000000000000000011;          // LB   => 00000005
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b01100:
            begin
                iw_out = 32'b00000000001000000001000000000011;          // LH   => 00000005
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b01101:
            begin
                iw_out = 32'b00000000001000000010000000000011;          // LW   => 00000005
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b01110:
            begin
                iw_out = 32'b00000000001000000100000000000011;          // LBU  => 00000005
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b01111:
            begin
                iw_out = 32'b00000000001000000101000000000011;          // LHU  => 00000005
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b10000:
            begin
                iw_out = 32'b01000101011000000000000000010011;          // ADDI => 02000456
                rs1_data_out = 32'h2000000;
            end

            5'b10001:
            begin
                iw_out = 32'b00000000001000000010000000010011;    // SLTI => 00000000
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b10010:
            begin
                iw_out = 32'b00000000001000000011000000010011;    // SLTIU=> 00000000
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b10011:
            begin
                iw_out = 32'b00000000001000000100000000010011;    // XORI => 00000001
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b10100:
            begin
                iw_out = 32'b00000000001000000110000000010011;    // ORI  => 00000003
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b10101:
            begin
                iw_out = 32'b00000000001000000111000000010011;    // ANDI => 00000002
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b10110:
            begin
                iw_out = 32'b00000000001000000001000000010011;    // SLLI => 0000000C
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b10111:
            begin
                iw_out = 32'b00000000001000000101000000010011;    // SRLI => 00000000
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b11000:
            begin
                iw_out = 32'b01000000001000000101000000010011;    // SRAI => 00000000
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b11001:
            begin
                iw_out = 32'b00010010001101000101000000110111;    // LUI  => 00012345
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
            end

            5'b11010:
            begin
                iw_out = 32'b00000000000000000000000000010111;    // AUIPC=> 00000001
                rs1_data_out = 32'd3;
                rs2_data_out = 32'd2;
                pc_out = 32'd1;
            end

            5'b11011:
            begin
                iw_out = 32'b00000000000000000000000001101111;          // JAL => 1234567C
                pc_out = 32'h12345678;
            end

            5'b11100:
            begin
                iw_out = 32'b01000100000000000000101100100011;          // SB   => 02000456
                rs1_data_out = 32'h2000000;
            end

            5'b11101:
            begin
                iw_out = 32'b01000100000000000000101100100011;    // SH   => 00000005
                rs1_data_out = 32'd3;
            end

            5'b11110:
            begin
                iw_out = 32'b01000100000000000000101100100011;    // SW   => 00000005
                rs1_data_out = 32'd3;
            end


            default:  iw_out = 32'b0;
        endcase
    end

    top_gun maverick (.clk(ADC_CLK_10), .reset(0), .pc_in(pc_out), .iw_in(iw_out), .rs1_data_in(rs1_data_out), .rs2_data_in(rs2_data_out));      // Instantiate module
endmodule

/*
    @module top_gun: The crux of ALU arithmatic
    @param clk Input clock signal
    @param pc_in Input Program Counter
    @param rs1_data_in Input Argument 1 for ALU
    @param rs2_data_in Input argument 2 for ALU
    @param alu_out Output output of ALU arithmatic
*/
module top_gun(
    // System Clock
    input clk, reset,
    // Following inputs are received from the Instruction Decode stage
    input [31:0] pc_in, iw_in, rs1_data_in, rs2_data_in,
    output reg [31:0] alu_out);

    // To Memory
    wire [31:0] alu_temp;

    wire [2:0] func3 = {iw_in[14:12]};      // Extract func3 from Instruction Word
    wire [6:0] func7 = {iw_in[31:25]};      // Extract func7 from Instruction Word
    wire [4:0] shamt = {iw_in[24:20]};      // Extract shamt from Instruction Word
    wire [6:0] opcde = {iw_in[6:0]};        // Extract opcode from Instruction Word
    wire [4:0] rd    = {iw_in[11:7]};       // Extract rd from Instruction Word
    wire [6:0] i1    = {iw_in[31:25]};      // Extract encoding from Instruction Word

    // The operation can be determined by scrutinising opcode func3 and func7 bits. The following case blocks achieve this
    always @ (func3, func7, shamt, opcde, reset) begin                              // Determine the operation to be performed from the opcode, func3 and func7
        case (opcde)
        /************************************************ R encoded instructions ******************************************************************/
            7'b0110011:                                                             // R encoded operations
            begin
                case (func3)
                    3'b000:                                                         // func3 = 000 supports two operations. Therefore compare func7 to determine operation
                    begin
                        case (func7)
                            7'b0000000: alu_temp = rs1_data_in + rs2_data_in;       // ADD operation
                            7'b0100000: alu_temp = rs1_data_in - rs2_data_in;       // SUB operation
                            default:    alu_temp = rs1_data_in;                     // alu must always return something or a latch is assumed
                        endcase
                    end

                    3'b001: alu_temp = rs1_data_in << (rs2_data_in & 16'h1F);       // SLL operation

                    3'b010:                                                         // SLT operation
                    begin
                        if (signed'(rs1_data_in) < signed'(rs2_data_in))
                            alu_temp = 32'd1;
                        else
                            alu_temp = 32'd0;
                    end

                    3'b011:                                                         // SLTU operation
                    begin
                        if (rs1_data_in < rs2_data_in)
                            alu_temp = 32'd1;                                       // Assign 1 if lesser else assign 0
                        else
                            alu_temp = 32'd0;
                    end

                    3'b100: alu_temp = rs1_data_in ^ rs2_data_in;                   // XOR operation

                    3'b101:
                    begin
                        case (func7)
                            7'b0000000: alu_temp = rs1_data_in >> rs2_data_in;      // SRL (Shift Right Logical) operation
                            7'b0100000: alu_temp = rs1_data_in >>> rs2_data_in;     // SRA (Shift Right Arithmatic) operation
                            default: alu_temp = 32'b0;                              // alu must always return something or a latch is assumed
                        endcase
                    end

                    3'b110: alu_temp = rs1_data_in | rs2_data_in;                   // OR operation

                    3'b111: alu_temp = rs1_data_in & rs2_data_in;                   // AND operation

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed
                endcase
            end

            /************************************************ I encoded instructions ******************************************************************/
            7'b1100111: alu_temp = pc_in + 32'd4;                                   // JALR operation

            7'b0000011:
            begin
                case (func3)
                    3'b000: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:20]};               // LB operation
                    3'b001: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:20]};               // LH operation
                    3'b010: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:20]};               // LW operation
                    3'b100: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:20]};               // LBU operation
                    3'b101: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:20]};               // LHU operation
                    default: alu_temp = 32'b0;                                                      // alu must always return something or a latch is assumed
                endcase
            end

            7'b0010011:
            begin
                case (func3)
                    3'b000: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:20]};               // ADDI operation

                    3'b010:                                                                         // SLTI operation
                    begin
                        if(signed'(rs1_data_in) < signed'({{20{iw_in[31]}}, iw_in[31:20]}))
                            alu_temp = 1;
                        else
                            alu_temp = 0;
                    end

                    3'b011:                                                                         // SLTIU operation
                    begin
                        if(rs1_data_in < {{20{iw_in[31]}}, iw_in[31:20]})
                            alu_temp = 1;
                        else
                            alu_temp = 0;
                    end

                    3'b100: alu_temp = rs1_data_in ^ {{20{iw_in[31]}}, iw_in[31:20]};               // XORI operation
                    3'b110: alu_temp = rs1_data_in | {{20{iw_in[31]}}, iw_in[31:20]};               // ORI operation
                    3'b111: alu_temp = rs1_data_in & {{20{iw_in[31]}}, iw_in[31:20]};               // ANDI operation
                    3'b001: alu_temp = rs1_data_in << shamt;                                        // SLLI operation

                    3'b101:
                    begin
                        case (i1)
                            7'b0000000: alu_temp = rs1_data_in >> shamt;                            // SRLI operation
                            7'b0100000: alu_temp = rs1_data_in >>> shamt;                           // SRAI operation
                            default: alu_temp = 32'b0;                                              // alu must always return something or a latch is assumed
                        endcase
                    end

                    default: alu_temp = 32'b0;                                                      // alu must always return something or a latch is assumed

                endcase
            end

            /************************************************ S encoded instructions ******************************************************************/
            7'b0100011:
            begin
                case (func3)
                    3'b000: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:25], iw_in[11:07]};     // SB operation
                    3'b001: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:25], iw_in[11:07]};     // SH operation
                    3'b010: alu_temp = rs1_data_in + {{20{iw_in[31]}}, iw_in[31:25], iw_in[11:07]};     // SW operation
                    default: alu_temp = 32'b0;                                                          // alu must always return something or a latch is assumed
                endcase
            end

            /************************************************ B encoded instructions ******************************************************************/
            7'b1100011:
            begin
                case (func3)
                    3'b000:                                                                             // BEQ operation
                    begin
                        if (rs1_data_in == rs2_data_in)
                            alu_temp = pc_in + (2 * {{20{iw_in[7]}}, iw_in[7], iw_in[31:25], iw_in[11:08]});
                        else
                            alu_temp = 32'b0;
                    end

                    3'b001:                                                                             // BNE operation
                    begin
                        if (rs1_data_in != rs2_data_in)
                            alu_temp = pc_in + (2 * {{20{iw_in[7]}}, iw_in[7], iw_in[31:25], iw_in[11:08]});
                        else
                            alu_temp = 32'b0;
                    end

                    3'b100:                                                                             // BLT operation
                    begin
                        if (signed'(rs1_data_in) < signed'(rs2_data_in))
                            alu_temp = pc_in + (2 * {{20{iw_in[7]}}, iw_in[7], iw_in[31:25], iw_in[11:08]});
                        else
                            alu_temp = 32'b0;
                    end

                    3'b101:                                                                             // BGE operation
                    begin
                        if (rs1_data_in >= rs2_data_in)
                            alu_temp = pc_in + (2 * {{20{iw_in[7]}}, iw_in[7], iw_in[31:25], iw_in[11:08]});
                        else
                            alu_temp = 32'b0;
                    end

                    3'b110:                                                                             // BLTU operation
                    begin
                        if (rs1_data_in < rs2_data_in)
                            alu_temp = pc_in + (2 * {{20{iw_in[7]}}, iw_in[7], iw_in[31:25], iw_in[11:08]});
                        else
                            alu_temp = 32'b0;
                    end

                    3'b111:                                                                             // BGEU operation
                    begin
                        if (rs1_data_in >= rs2_data_in)
                            alu_temp = pc_in + (2 * {{20{iw_in[7]}}, iw_in[7], iw_in[31:25], iw_in[11:08]});
                        else
                            alu_temp = 32'b0;
                    end

                    default: alu_temp = 32'b0;                                                          // alu must always return something or a latch is assumed
                endcase
            end

            /************************************************ U encoded instructions ******************************************************************/
            7'b0110111: alu_temp = {iw_in[31:12], 12'b0};                                               // LUI operation

            7'b0010111: alu_temp = {iw_in[31:12], 12'b0} + pc_in;                                       // AUIPC operation

            /************************************************ J encoded instructions ******************************************************************/
            7'b1101111: alu_temp = pc_in + 32'd4;                                                       // JALR operation
        endcase
    end


    // Trigger condition for latching onto D flip-flop = reset button press
    always_ff @ (posedge(clk))
    if (reset)  alu_out <= 32'b0;
    else        alu_out <= alu_temp;
endmodule