module ext_top(

    // System Clock
    input ADC_CLK_10,

    // Following inputs are received from the Instruction Decode stage
    input [31:0] pc_in,
    input [31:0] iw_in,
    input [31:0] rs1_data_in,
    input [31:0] rs2_data_in,
    input [1:0] KEY,

    // To Memory
    output reg [31:0] alu_out);

    // Local clock
    wire clk = ADC_CLK_10;

    assign reg func3 = {iw_in[14:12]};      // Extract func3 from Instruction Word
    assign reg func7 = {iw_in[31:25]};      // Extract func7 from Instruction Word
    assign reg shamt = {iw_in[24:20]};      // Extract shamt from Instruction Word
    assign reg opcde = {iw_in[6:0]};        // Extract opcode from Instruction Word
    assign reg rd    = {iw_in[11:7]};       // Extract rd from Instruction Word


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
    always @ (func3, func7, opcde, posedge clk) begin                               // Determine the operation to be performed from the opcode, func3 and func7
        case (opcde)
            // R encoded instructions
            2'b0110011: begin                                                       // R encoded operations
                case (func3)
                    2'b000: begin                                                   // func3 = 000 supports two operations. Therefore compare func7 to determine operation
                        case (func7)
                            2'b0000000: alu_out = rs1_data_in + rs2_data_in;        // ADD operation
                            2'b0100000: alu_out = rs1_data_in - rs2_data_in;        // SUB operation
                            default:    alu_out = rs1_data_in;
                        endcase
                    end

                    2'b001: alu_out = rs1_data_in << (rs2_data_in & 16'h1F);        // Left shift RS1 operand by 5 bits

                    2'b010: begin                                                   // Compare RS1 and RS2
                        if (rs1_data_in < rs2_data_in)
                            alu_out = 1;
                        else
                            alu_out = 0;
                    end

                    2'b011: begin                                                   // Compare RS1 and RS2(unsigned)
                        if (rs1_data_in < rs2_data_in)
                            alu_out = 1;                                            // Assign 1 if lesser else assign 0
                        else
                            alu_out = 0;
                    end

                    2'b100: begin
                        alu_out = rs1_data_in ^ rs2_data_in;                        // XOR operation
                    end

                    2'b101: begin
                        case (func7)
                            2'b0000000: alu_out = rs1_data_in >> rs2_data_in;       // SRL (Shift Right Logical) operation
                            2'b0100000: alu_out = rs1_data_in >>> rs2_data_in;      // SRA (Shift Right Arithmatic) operation
                        endcase
                    end

                    2'b110: begin
                        alu_out = rs1_data_in | rs2_data_in;                        // OR operation
                    end

                    2'b111: begin
                        alu_out = rs1_data_in & rs2_data_in;                        // AND operation
                    end
                endcase
            end

            // I encoded operations
            2'b1100111: begin                                                       // JALR operation
                alu_out = pc_in + 4;                                                // Increment PC (program counter) by 4
                pc_in = {{20{i[11]}}, i};                                           // Update Program Counter
            end

            2'b0000011: begin
                case (func3)
                    2'b000: alu_out =                                               // JB operation
                    2'b001: alu_out = 
                    2'b010: alu_out = 
                    2'b100: alu_out = rs1_data_in + {{21{i}}, i};                   // LBU operation
                    2'b101: alu_out = 
                endcase
            end

            2'b0010011: begin
                case (func3)
                    2'b000: begin
                        alu_out = rs1_data_in + {21{i}};                            // I encoded operation ADDI
                    end

                    2'b010: begin
                        if(rs1_data_in < {21{i}})
                            alu_out = 1;                                            // I encoded operation ADDI
                        else
                            alu_out = 0;
                    end
                endcase
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
