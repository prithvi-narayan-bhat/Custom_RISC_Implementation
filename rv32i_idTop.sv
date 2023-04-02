module rv32i_idTop
    (
        input clk, reset,                           // System clock and synchronous reset
        input [31:0] iw_in, pc_in,                  // From ifTop
        input [31:0] rs1_data_in, rs2_data_in,            // From Register interface

        // Forwarded data from exTop stage
        input df_ex_enable,                         // Writeback enable signal at the exTop stage
        input [4:0] df_ex_reg,                      // Writeback register at the exTop stage
        input [31:0] df_ex_data,                    // Writeback data at the exTop stage

        // Forwarded data from memTop stage
        input df_mem_enable,                        // Writeback enable signal at the exTop stage
        input [4:0] df_mem_reg,                     // Writeback register at the exTop stage
        input [31:0] df_mem_data,                   // Writeback data at the exTop stage

        // Forwarded data from wbTop stage
        input df_wb_enable,                         // Writeback enable signal at the exTop stage
        input [4:0] df_wb_reg,                      // Writeback register at the exTop stage
        input [31:0] df_wb_data,                    // Writeback data at the exTop stage

        output wb_en_out,
        output reg [4:0] rs1_reg, rs2_reg, wb_reg,  // To Register interface
        output reg [31:0] pc_out, iw_out,           // To exTop
        output reg [31:00] rs1_data_out, rs2_data_out,

        output jump_enable,                         // Enable jump          | To ifTop module
        output reg [31:0] jump_addr                 // Address to jump to   | To ifTop module
    );

    assign rs1_reg = iw_in[19:15];                  // Calculate rs1 from Instruction Word
    assign rs2_reg = iw_in[24:20];                  // Calculate rs2 from Instruction Word

	reg halt_ex;
    reg [31:00] rs1_int, rs2_int;

    wire [6:0] opcode = {iw_in[6:0]};               // Extract opcode from Instruction Word

    always_ff @ (posedge clk)
    begin

        if (halt_ex == 1'b1 || jump_enable == 1'b1)     iw_out <= 32'h13;   // Set as no-op
        else                                            iw_out <= iw_in;    // Pass them on to the next module stage

        pc_out <= pc_in;                            // Pass them on to the next module stage
        wb_reg <= iw_in[11:07];                     // Destination Register for Register Interface

        rs1_data_out <= rs1_int;                    // Assign fetched and/or forwarded data synchronously
        rs2_data_out <= rs2_int;                    // Assign fetched and/or forwarded data synchronously
    end

    // Determine if writeback must be enabled depending on the opcode in the Instruction Word
    always_ff @ (*)
    begin
        if (
                opcode == 7'b1100011 ||             // BEQ, BNE, BLT, BGE, BLTU, BGEU
                opcode == 7'b1100111 ||             // JALR
                opcode == 7'b1101111 ||             // JAL
                opcode == 7'b0001111 ||             // FENCE
                opcode == 7'b1110011                // EBREAK, ECALL
            )   wb_en_out <= 0;                     // For instructions that don't require writebacks
        else    wb_en_out <= 1;                     // All others require writebacks

        /* EBreak
            Set a flag if the Ebreak opcode is encountered
            The flag will be synchronously read in a parallel always block and acted upon
        */
        if (opcode == 7'b1110011) halt_ex = 1'b1;
        if (reset == 1'b1)
        begin
            halt_ex = 1'b0;
            jump_enable = 0;
        end

        /* Data Forwarding
            Determine if data hazards exist by checking the following conditions:
                1. the latest wb_reg is same as the wb_reg from the previous instruction
                2. previous instruction has wb_enable set
                3. wb_reg or detination reg of present instruction is not Zero reg
        */
        if      ((rs1_reg == df_ex_reg) && df_ex_enable && rs1_reg != 0)    rs1_int <= df_ex_data;
        else if ((rs1_reg == df_mem_reg) && df_mem_enable && rs1_reg != 0)  rs1_int <= df_mem_data;
        else if ((rs1_reg == df_wb_reg) && df_wb_enable && rs1_reg != 0)    rs1_int <= df_wb_data;
        else    rs1_int <= rs1_data_in;

        if      ((rs2_reg == df_ex_reg) && df_ex_enable && rs2_reg != 0)    rs2_int <= df_ex_data;
        else if ((rs2_reg == df_mem_reg) && df_mem_enable && rs2_reg != 0)  rs2_int <= df_mem_data;
        else if ((rs2_reg == df_wb_reg) && df_wb_enable && rs2_reg != 0)    rs2_int <= df_wb_data;
        else    rs2_int <= rs2_data_in;

        /* Branch hazards
            Determine from the opcode if a jump is required.
            Set a flag and calculate the address appropriately
            clear the flag if no jump is required or the branch condition fails
        */
        if(opcode == 7'b1100111)                                                                                // JALR instruction
        begin
            jump_addr <= rs1_int + {{20{iw_in[31]}}, iw_in[31:20]};                                             // Set jump destination
            jump_enable <= 1;                                                                                   // Set jump enable flag
        end

        else if (opcode == 7'b1101111)                                                                          // JAL instruction
        begin
            jump_addr <= pc_in + {2 * {{12{iw_in[31]}}, iw_in[31], iw_in[19:12], iw_in[20], iw_in[30:21]}};     // Set jump destination
            jump_enable <= 1;                                                                                   // Set jump enable flag
        end

        else if (opcode == 7'b1100011)                                                                          // BRANCH instructions
        begin
            case (iw_in[14:12])
                3'b000:
                begin
                    if (rs1_int == rs2_int)                                                                                 // BEQ instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_enable <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_enable <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b001:
                begin
                    if (rs1_int != rs2_int)                                                                                 // BNE instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_enable <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_enable <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b100:
                begin
                    if (signed'(rs1_int) < signed'(rs2_int))                                                                // BLT instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_enable <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_enable <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b101:
                begin
                    if (signed'(rs1_int) >= signed'(rs2_int))                                                               // BGE instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_enable <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_enable <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b110:
                begin
                    if (rs1_int < rs2_int)                                                                                  // BLTU instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_enable <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_enable <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b111:
                begin
                    if (rs1_int >= rs2_int)                                                                                 // BGE instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_enable <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_enable <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                default:
                begin
                    jump_addr <= pc_in;                                                                                     // Follow regular program execution flow
                    jump_enable <= 0;                                                                                       // Clear jump enable flag
                end
            endcase

        end

        else
        begin
            jump_addr <= pc_in;                                                                                             // Follow regular program execution flow
            jump_enable <= 0;                                                                                               // Clear jump enable flag
        end
    end
endmodule