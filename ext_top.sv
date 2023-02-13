/*
    Testing instructions with values where ever possible

    _____________________________________________________________
    |No. |SW pos |          Instruction Word             | Inst  |
    |------------------------------------------------------------|
    |                       R Instruction                        |
    |------------------------------------------------------------|
    | 0  | 00000 | 0000000 00000 00000 000 00000 0110011 | ADD   |
    | 1  | 00001 | 0100000 00000 00000 000 00000 0110011 | SUB   |
    | 2  | 00010 | 0000000 00000 00000 001 00000 0110011 | SLL   |
    | 3  | 00011 | 0000000 00000 00000 010 00000 0110011 | SLT   |
    | 4  | 00100 | 0000000 00000 00000 011 00000 0110011 | SLTU  |
    | 5  | 00101 | 0000000 00000 00000 100 00000 0110011 | XOR   |
    | 6  | 00110 | 0000000 00000 00000 101 00000 0110011 | SRL   |
    | 7  | 00111 | 0100000 00000 00000 101 00000 0110011 | SRA   |
    | 8  | 01000 | 0000000 00000 00000 110 00000 0110011 | OR    |
    | 9  | 01001 | 0000000 00000 00000 111 00000 0110011 | AND   |
    |____________________________________________________________|
    |                       I Instructions                       |
    |------------------------------------------------------------|
    | 10 | 01010 | 000000000010 00000 000 00000 1100111  | JALR  |
    | 11 | 01011 | 000000000010 00000 000 00000 0000011  | LB    |
    | 12 | 01100 | 000000000010 00000 001 00000 0000011  | LH    |
    | 13 | 01101 | 000000000010 00000 010 00000 0000011  | LW    |
    | 14 | 01110 | 000000000010 00000 100 00000 0000011  | LBU   |
    | 15 | 01111 | 000000000010 00000 101 00000 0000011  | LHU   |
    | 16 | 10000 | 000000000010 00000 000 00000 0010011  | ADDI  |
    | 17 | 10001 | 000000000010 00000 010 00000 0010011  | SLTI  |
    | 18 | 10010 | 000000000010 00000 011 00000 0010011  | SLTIU |
    | 19 | 10011 | 000000000010 00000 100 00000 0010011  | XORI  |
    | 20 | 10100 | 000000000010 00000 110 00000 0010011  | ORI   |
    | 21 | 10101 | 000000000010 00000 111 00000 0010011  | ANDI  |
    | 22 | 10110 | 000000000010 00000 001 00000 0010011  | SLLI  |
    | 23 | 10111 | 000000000010 00000 101 00000 0010011  | SRLI  |
    | 24 | 11000 | 000000000010 00000 101 00000 0010011  | SRAI  |
    |------------------------------------------------------------|
    |                       U Instructions                       |
    |------------------------------------------------------------|
    | 25 | 11001 | 00000000000000000000 00000 0110111    | LUI   |
    | 26 | 11010 | 00000000000000000000 00000 0010111    | AUIPC |
    |------------------------------------------------------------|
    |                       J Instructions                       |
    |------------------------------------------------------------|
    | 27 | 11011 | 00000000000000000000 00000 1101111    | JALR  |
    |------------------------------------------------------------|

*/
module ext_top(
    input ADC_CLK_10,
    input [1:0] KEY,
    input [9:0] SW);

    wire [4:0] operation = SW[4:0];
    wire [31:0] iw_out;

    // Set instruction word based on switch position
    always @ (SW) begin
        case (operation)
            5'b00000: iw_out = 32'b00000000000000000000000000110011;    // ADD  => 00000005
            5'b00001: iw_out = 32'b01000000000000000000000000110011;    // SUB  => 00000001
            5'b00010: iw_out = 32'b00000000000000000001000000110011;    // SLL  => 0000000c
            5'b00011: iw_out = 32'b00000000000000000010000000110011;    // SLT  => 00000000 rs1<rs2 or 00000000 rs1>rs2
            5'b00100: iw_out = 32'b00000000000000000011000000110011;    // SLTU => 00000000 rs1<rs2 or 00000000 rs1>rs2 (unsigned)
            5'b00101: iw_out = 32'b00000000000000000100000000110011;    // XOR  => 00000001
            5'b00110: iw_out = 32'b00000000000000000101000000110011;    // SRL  => 00000000
            5'b00111: iw_out = 32'b01000000000000000101000000110011;    // SRA  => 00000000
            5'b01000: iw_out = 32'b00000000000000000110000000110011;    // OR   => 00000003
            5'b01001: iw_out = 32'b00000000000000000111000000110011;    // AND  => 00000002

            5'b01010: iw_out = 32'b00000000001000000000000001100111;    // JALR => 00000005
            5'b01011: iw_out = 32'b00000000001000000000000000000011;    // LB   => 00000005
            5'b01100: iw_out = 32'b00000000001000000001000000000011;    // LH   => 00000005
            5'b01101: iw_out = 32'b00000000001000000010000000000011;    // LW   => 00000005
            5'b01110: iw_out = 32'b00000000001000000100000000000011;    // LBU  => 00000005
            5'b01111: iw_out = 32'b00000000001000000101000000000011;    // LHU  => 00000005
            5'b10000: iw_out = 32'b00000000001000000000000000010011;    // ADDI => 00000005
            5'b10001: iw_out = 32'b00000000001000000010000000010011;    // SLTI => 00000000
            5'b10010: iw_out = 32'b00000000001000000011000000010011;    // SLTIU=> 00000000
            5'b10011: iw_out = 32'b00000000001000000100000000010011;    // XORI => 00000001
            5'b10100: iw_out = 32'b00000000001000000110000000010011;    // ORI  => 00000003
            5'b10101: iw_out = 32'b00000000001000000111000000010011;    // ANDI => 00000002
            5'b10110: iw_out = 32'b00000000001000000001000000010011;    // SLLI => 0000000C
            5'b10111: iw_out = 32'b00000000001000000101000000010011;    // SRLI => 00000000
            5'b11000: iw_out = 32'b01000000001000000101000000010011;    // SRAI => 00000000

            5'b11001: iw_out = 32'b00000000000000000000000000110111;    // LUI  => 00000000
            5'b11010: iw_out = 32'b00000000000000000000000000010111;    // AUIPC=> 00000001

            5'b11011: iw_out = 32'b00000000000000000000000001101111;    // JALR => 00000005

            default:  iw_out = 32'b0;
        endcase
    end

    top_gun maverick (.clk(ADC_CLK_10), .reset(0), .pc_in(32'b1), .iw_in(iw_out), .rs1_data_in(32'd3), .rs2_data_in(32'd2));      // Instantiate module
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
    wire [20:0] i5 = {iw_in[31:12]};        // This is the last time, I promise, I extract some information from the Instruction Word
    wire [4:0]  i4 = {iw_in[11:08]};        // You guessed it, extract some more information from Instruction Word
    wire [11:0] i3 = {iw_in[11:07]};        // Extract even more information from Instruction Word
    wire [6:0]  i2 = {iw_in[31:25]};        // Extract some more encoding from Instruction Word
    wire [11:0] i1 = {iw_in[31:20]};        // Extract immediate value from Instruction Word
    wire [31:0]temp1, temp2;

    // The operation can be determined by scrutinising opcode func3 and func7 bits. The following case blocks achieve this
    always @ (func3, func7, shamt, opcde, reset) begin                              // Determine the operation to be performed from the opcode, func3 and func7
        case (opcde)
        /************************************************ R encoded instructions ******************************************************************/
            7'b0110011: begin                                                       // R encoded operations
                case (func3)
                    3'b000: begin                                                   // func3 = 000 supports two operations. Therefore compare func7 to determine operation
                        case (func7)
                            7'b0000000: alu_temp = rs1_data_in + rs2_data_in;       // ADD operation
                            7'b0100000: alu_temp = rs1_data_in - rs2_data_in;       // SUB operation
                            default:    alu_temp = rs1_data_in;                     // alu must always return something or a latch is assumed
                        endcase
                    end

                    3'b001: alu_temp = rs1_data_in << (rs2_data_in & 16'h1F);       // SLL operation

                    3'b010: begin                                                   // SLT operation
                        if (rs1_data_in < rs2_data_in)
                            alu_temp = 32'd1;
                        else
                            alu_temp = 32'd0;
                    end

                    3'b011: begin                                                   // SLTU operation
                        if (rs1_data_in < rs2_data_in)
                            alu_temp = 32'd1;                                       // Assign 1 if lesser else assign 0
                        else
                            alu_temp = 32'd0;
                    end

                    3'b100: alu_temp = rs1_data_in ^ rs2_data_in;                   // XOR operation

                    3'b101: begin
                        case (func7)
                            7'b0000000: alu_temp = rs1_data_in >> rs2_data_in;      // SRL (Shift Right Logical) operation
                            7'b0100000: alu_temp = rs1_data_in >>> rs2_data_in;     // SRA (Shift Right Arithmatic) operation
                            default: alu_temp = 32'b0;                              // alu must always return something or a latch is assumed
                        endcase
                    end

                    3'b110: alu_temp = rs1_data_in | rs2_data_in;                   // OR operation

                    3'b111: begin
                        alu_temp = rs1_data_in & rs2_data_in;                       // AND operation
                    end

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed
                endcase
            end

            /************************************************ I encoded instructions ******************************************************************/
            7'b1100111: alu_temp = pc_in + 32'd4;                                   // JALR operation

            7'b0000011: begin
                case (func3)
                    3'b000: alu_temp = rs1_data_in + {{20{i1[11]}}, i1};            // LB operation

                    3'b001: alu_temp = rs1_data_in + {{20{i1[11]}}, i1};            // LH operation

                    3'b010: alu_temp = rs1_data_in + {{20{i1[11]}}, i1};            // LW operation

                    3'b100: alu_temp = rs1_data_in + {{20{i1[11]}}, i1};            // LBU operation

                    3'b101: alu_temp = rs1_data_in + {{20{i1[11]}}, i1};            // LHU operation

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed
                endcase
            end

            7'b0010011: begin
                case (func3)
                    3'b000: alu_temp = rs1_data_in + {{20{i1[11]}}, i1};            // I encoded operation ADDI

                    3'b010: begin
                        if(rs1_data_in < {{20{i1[11]}}, i1})
                            alu_temp = 1;                                           // I encoded operation SLTI
                        else
                            alu_temp = 0;
                    end

                    3'b011: begin
                        if(rs1_data_in < {{20{i1[11]}}, i1})
                            alu_temp = 1;                                           // I encoded operation SLTIU | CHECKME
                        else
                            alu_temp = 0;
                    end

                    3'b100: alu_temp = rs1_data_in ^ {{20{i1[11]}}, i1};            // XORI operation

                    3'b110: alu_temp = rs1_data_in | {{20{i1[11]}}, i1};            // ORI operation

                    3'b111: alu_temp = rs1_data_in & {{20{i1[11]}}, i1};            // ANDI operation

                    3'b001: alu_temp = rs1_data_in << shamt;                        // SLLI operation

                    3'b101: begin
                        case (i2)
                            7'b0000000: alu_temp = rs1_data_in >> shamt;            // SRLI operation

                            7'b0100000: alu_temp = rs1_data_in >>> shamt;           // SRAI operation

                            default: alu_temp = 32'b0;                              // alu must always return something or a latch is assumed
                        endcase
                    end

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed

                endcase
            end

            /************************************************ S encoded instructions ******************************************************************/
            7'b0100011: begin
                case (func3)                                                        // SB operation - CHECKME
                    3'b000: begin
                       temp1 =  {i2, i3};
                       alu_temp = rs1_data_in + {{20{temp1[11]}}, temp1};
                    end

                    3'b001: begin                                                   // SH operation - CHECKME
                        temp1 =  {i2, i3};
                       temp2 = rs1_data_in + {{20{temp1[11]}}, temp1};
                       alu_temp = rs2_data_in[16:0];
                    end

                    3'b010: begin                                                   // SW operation - CHECKME
                        temp1 =  {i2, i3};
                       temp2 = rs1_data_in + {{20{temp1[11]}}, temp1};
                       alu_temp = rs2_data_in[31:0];
                    end

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed
                endcase
            end

            /************************************************ B encoded instructions ******************************************************************/
            7'b1100011: begin
                case (func3)
                    3'b000: begin                                                   // BEQ operation
                        if (rs1_data_in == rs2_data_in) begin
                            temp1 = {iw_in[7], i2, i4};
                            temp2 = {{20{temp1[11]}}, temp1};
                            alu_temp = pc_in + (2 * temp2);
                        end else
                            alu_temp = 32'b0;
                    end

                    3'b001: begin                                                   // BNE operation
                        if (rs1_data_in != rs2_data_in) begin
                            temp1 = {iw_in[7], i2, i4};
                            temp2 = {{20{temp1[11]}}, temp1};
                            alu_temp = pc_in + (2 * temp2);
                        end else
                            alu_temp = 32'b0;
                    end

                    3'b100: begin                                                   // BLT operation
                        if (rs1_data_in < rs2_data_in) begin
                            temp1 = {iw_in[7], i2, i4};
                            temp2 = {{20{temp1[11]}}, temp1};
                            alu_temp = pc_in + (2 * temp2);
                        end else
                            alu_temp = 32'b0;
                    end

                    3'b101: begin                                                   // BGE operation
                        if (rs1_data_in >= rs2_data_in) begin
                            temp1 = {iw_in[7], i2, i4};
                            temp2 = {{20{temp1[11]}}, temp1};
                            alu_temp = pc_in + (2 * temp2);
                        end else
                            alu_temp = 32'b0;
                    end

                    3'b110: begin                                                   // BLTU operation | CHECKME
                        if (rs1_data_in < rs2_data_in) begin
                            temp1 = {iw_in[7], i2, i4};
                            temp2 = {{20{temp1[11]}}, temp1};
                            alu_temp = pc_in + (2 * temp2);
                        end else
                            alu_temp = 32'b0;
                    end

                    3'b111: begin                                                   // BGEU operation | CHECKME
                        if (rs1_data_in >= rs2_data_in) begin
                            temp1 = {iw_in[7], i2, i4};
                            temp2 = {{20{temp1[11]}}, temp1};
                            alu_temp = pc_in + (2 * temp2);
                        end else
                            alu_temp = 32'b0;
                    end

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed
                endcase
            end

            /************************************************ U encoded instructions ******************************************************************/
            7'b0110111: alu_temp = {i5, 12'b0};                                     // LUI operation

            7'b0010111: alu_temp = {i5, 12'b0} + pc_in;                             // LUI operation

            /************************************************ J encoded instructions ******************************************************************/
            7'b1101111: alu_temp = pc_in + 32'd4;                                   // JALR operation
        endcase
    end


    // Trigger condition for latching onto D flip-flop = reset button press
    always_ff @ (posedge(clk))
    if (reset)  alu_out <= 32'b0;
    else        alu_out <= alu_temp;
endmodule