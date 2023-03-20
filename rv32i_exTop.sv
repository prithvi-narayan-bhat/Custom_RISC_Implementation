/*
    @module top_gun: The crux of ALU arithmatic
    @param clk Input clock signal
    @param pc_in Input Program Counter
    @param rs1_data_in Input Argument 1 for ALU
    @param rs2_data_in Input argument 2 for ALU
    @param alu_out Output output of ALU arithmatic
*/
module rv32i_exTop(
        input clk, reset, wb_en_in,                             // System Clock
        input [31:0] pc_in, iw_in, rs1_data_in, rs2_data_in,    // Inputs are received from the Instruction Decode stage
        output reg [31:0] alu_out, iw_out, pc_out, wb_en_out    // To Memory
    );

    reg [31:0] alu_temp = 0;               // Internal storage
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

            default: alu_temp = 32'b0;                                                          // alu must always return something or a latch is assumed
        endcase
    end


    // Trigger condition for latching onto D flip-flop = reset button press
    always_ff @ (posedge(clk))
    begin
        if (reset)  alu_out <= 32'b0;
        else        alu_out <= alu_temp;

        iw_out <= iw_in;                    // Pass them on to the next module stage
        pc_out <= pc_in;                    // Pass them on to the next module stage
    end
endmodule