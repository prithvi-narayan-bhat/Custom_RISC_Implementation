module ext_top(ADC_CLK_10, pc_in, iw_in, rs1_data_in, rs2_data_in, KEY, alu_out);

    // System Clock
    input ADC_CLK_10;

    // Following inputs are received from the Instruction Decode stage
    input reg [31:0] pc_in, iw_in, rs1_data_in, rs2_data_in;
    input reg [1:0] KEY;
    output reg [31:0] alu_out;

    // To Memory
    wire [31:0] alu_temp, pc_temp;

    // Local clock
    wire clk = ADC_CLK_10;

    assign func3 = {iw_in[14:12]};      // Extract func3 from Instruction Word
    assign func7 = {iw_in[31:25]};      // Extract func7 from Instruction Word
    assign shamt = {iw_in[24:20]};      // Extract shamt from Instruction Word
    assign opcde = {iw_in[6:0]};        // Extract opcode from Instruction Word
    assign rd    = {iw_in[11:7]};       // Extract rd from Instruction Word
    wire [0:20] i5 = {iw_in[31:12]};    // This is the last time, I promise, I extract some information from the Instruction Word
    wire [0:4]  i4 = {iw_in[11:08]};    // You guessed it, extract some more information from Instruction Word
    wire [0:11] i3 = {iw_in[11:07]};    // Extract even more information from Instruction Word
    wire [0:6]  i2 = {iw_in[31:25]};    // Extract some more encoding from Instruction Word
    wire [0:11] i1 = {iw_in[31:20]};    // Extract immediate value from Instruction Word
    reg [31:0]temp1, temp2, temp3;

    /*
        Opcode will determine the Operation encoding.

        /*
               |ENC |Opcode|func3|  func7  |
               |----|------|-----|---------|
               | R  | ADD  | 000 | 0000000 |
               | R  | SUB  | 000 | 0100000 |
               | R  | SLL  | 001 | 0000000 |
               | R  | SLT  | 010 | 0000000 |
               | R  | SLTU | 011 | 0000000 |
               | R  | XOR  | 100 | 0000000 |
               | R  | SRL  | 101 | 0000000 |
               | R  | SRA  | 101 | 0100000 |
               | R  | OR   | 110 | 0000000 |
               | R  | AND  | 111 | 0000000 |

        The operation itself can be determined by further scrutinising func3 and func7 values
        The following case blocks achieve this.
    */
    always @ (func3, func7, shamt, opcde) begin                                      // Determine the operation to be performed from the opcode, func3 and func7
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

                    3'b001: alu_temp = rs1_data_in << (rs2_data_in & 16'h1F);       // Left shift RS1 operand by 5 bits

                    3'b010: begin                                                   // Compare RS1 and RS2
                        if (rs1_data_in < rs2_data_in)
                            alu_temp = 1;
                        else
                            alu_temp = 0;
                    end

                    3'b011: begin                                                   // Compare RS1 and RS2(unsigned)
                        if (rs1_data_in < rs2_data_in)
                            alu_temp = 1;                                           // Assign 1 if lesser else assign 0
                        else
                            alu_temp = 0;
                    end

                    3'b100: begin
                        alu_temp = rs1_data_in ^ rs2_data_in;                       // XOR operation
                    end

                    3'b101: begin
                        case (func7)
                            7'b0000000: alu_temp = rs1_data_in >> rs2_data_in;      // SRL (Shift Right Logical) operation
                            7'b0100000: alu_temp = rs1_data_in >>> rs2_data_in;     // SRA (Shift Right Arithmatic) operation
                            default: alu_temp = 32'b0;                              // alu must always return something or a latch is assumed
                        endcase
                    end

                    3'b110: begin
                        alu_temp = rs1_data_in | rs2_data_in;                       // OR operation
                    end

                    3'b111: begin
                        alu_temp = rs1_data_in & rs2_data_in;                       // AND operation
                    end

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed
                endcase
            end

            /************************************************ I encoded instructions ******************************************************************/
            7'b1100111: begin                                                       // JALR operation
                pc_temp = pc_in + 32'd4;                                            // Increment PC (program counter) by 4
                alu_temp = {{20{i1[11]}}, i1};                                      // Update Program Counter
            end

            7'b0000011: begin
                case (func3)
                    3'b000: begin
                        temp1 = rs1_data_in + {{20{i1[11]}}, i1};                   // Signex immediate value and add to rs1
                        temp2 = temp1[8:0];                                         // Extract the LSB byte of the result
                        alu_temp = {{24{temp2[7]}}, temp2};                         // LB operation
                    end

                    3'b001: begin
                        temp1 = rs1_data_in + {{20{i1[11]}}, i1};                   // Signex immediate value and add to rs1
                        temp2 = temp1[15:0];                                        // Extract the LSB half word of the result
                        alu_temp = {{16{temp2[7]}}, temp2};                         // LH operation
                    end

                    3'b010: begin
                        alu_temp = rs1_data_in + {{20{i1[11]}}, i1};                // Signex immediate value and add to rs1 LW operation
                    end

                    3'b100: begin
                        temp1 = rs1_data_in + {{20{i1[11]}}, i1};                   // Signex immediate value and add to rs1
                        alu_temp = temp1[23:0];                                     // Extract the LSB 24 bits of the result LBU operation
                    end

                    3'b101: begin
                        temp1 = rs1_data_in + {{20{i1[11]}}, i1};                   // Signex immediate value and add to rs1
                        alu_temp = temp1[16:0];                                     // Extract the LSB 16 bits of the result LHU operation
                    end

                    default: alu_temp = 32'b0;                                      // alu must always return something or a latch is assumed
                endcase
            end

            7'b0010011: begin
                case (func3)
                    3'b000: begin
                        alu_temp = rs1_data_in + {{20{i1[11]}}, i1};                // I encoded operation ADDI
                    end

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

                    3'b100: begin
                        alu_temp = rs1_data_in ^ {{20{i1[11]}}, i1};                // XORI operation
                    end

                    3'b110: begin
                        alu_temp = rs1_data_in | {{20{i1[11]}}, i1};                // ORI operation
                    end

                    3'b111: begin
                        alu_temp = rs1_data_in & {{20{i1[11]}}, i1};                // ANDI operation
                    end

                    3'b001: begin
                        alu_temp = rs1_data_in << shamt;                            // SLLI operation
                    end

                    3'b101: begin
                        case (i2)
                            7'b0000000: begin
                                alu_temp = rs1_data_in >> shamt;                    // SRLI operation
                            end

                            7'b0100000: begin
                                alu_temp = rs1_data_in >>> shamt;                   // SRAI operation
                            end

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
                       temp2 = rs1_data_in + {{20{temp1[11]}}, temp1};
                       alu_temp = rs2_data_in[7:0];
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
            7'b0110111: begin
                alu_temp = {i5, 12'b0};                                             // LUI operation
            end

            7'b0010111: begin
                alu_temp = {i5, 12'b0} + pc_in;                                     // LUI operation
            end

            /************************************************ U encoded instructions ******************************************************************/
            7'b1101111: begin
                alu_temp = pc_in + 32'd4;
            end
        endcase
    end


    // handle input metastability safely
    reg reset;
    reg pre_reset;
    always_ff @ (posedge(clk))
    begin
        pre_reset <= !KEY[0];
        reset <= pre_reset;
    end
    reg shift_in;
    reg pre_shift_in;
    always_ff @ (posedge(clk))
    begin
        pre_shift_in <= !KEY[1];
        shift_in <= pre_shift_in;
    end

endmodule


module seq_logic(
    input MAX10_CLK1_50,
    inout [35:0] GPIO,
    output [7:0] HEX0,
    output [7:0] HEX1,
    output [7:0] HEX2,
    output [7:0] HEX3,
    output [7:0] HEX4,
    output [7:0] HEX5,
    input [1:0] KEY,
    output [9:0] LEDR,
    input [9:0] SW);

    // set unused output values
    assign GPIO = 36'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
    assign HEX0 = 8'b11111111;
    assign HEX1 = 8'b11111111;
    assign HEX2 = 8'b11111111;
    assign HEX3 = 8'b11111111;
    assign HEX4 = 8'b11111111;
    assign HEX5 = 8'b10010010; // S for sequential logic example

    // local clock

    // 1 Hz tick
    wire sec_tick;
    reg out;
    reg [3:0] count;
    reg [2:0] three;
    divide_by_50000000 divider (clk, sec_tick);

    // // toggle LED, inc count every second
    // always_ff @ (posedge(clk))
    // begin
    //     if (reset)
    //     begin
    //         count <= 0;
    //         three <= 0;
    //     end
    //     else
    //         if (sec_tick)
    //         begin
    //             out <= !out;
    //             count <= count + 1;
    //             three[2] <= three[1];
    //             three[1] <= three[0];
    //             three[0] <= shift_in;
    //         end
    // end

    // assign LEDR = {three, 1'b0, count, 1'b0, out};
endmodule

module divide_by_50000000(
    input clk,
    output reg out);

    reg [26:0] count;

    always_ff @ (posedge(clk))
    begin
        if (count < 50000000)
        begin
           count <= count + 1;
           out <= 0;
        end
        else
        begin
            count <= 0;
            out <= 1;
        end
    end
endmodule
