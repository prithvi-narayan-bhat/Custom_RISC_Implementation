module rv32i_idTop
    (
        input clk, reset,                           // System clock and synchronous reset
        input [31:0] iw_in, pc_in,                  // From ifTop
        input [31:0] rs1_data_in, rs2_data_in,      // From Register interface
        input jump_en_in,                           // Form ifTop module

        input df_w_en_ex,                           // Forwarded w_en       | From exTop module
        input df_w_en_mem,                          // Forwarded w_en       | From memTop module

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
        output w_en_out,                            // mem/io write enable  | To exTop module
        output halt_ex,

        output pc_halt_out,                         // PC halt flag         | To ifTop module
        output jump_en_out,                         // Enable jump          | To ifTop module
        output reg [31:0] jump_addr                 // Address to jump to   | To ifTop module
    );

    assign rs1_reg = iw_in[19:15];                  // Calculate rs1 from Instruction Word
    assign rs2_reg = iw_in[24:20];                  // Calculate rs2 from Instruction Word

	reg /*halt_ex,*/ jump_en_flag, jump_en_int;
    reg [31:00] rs1_int, rs2_int;

    wire [6:0] opcode = {iw_in[6:0]};               // Extract opcode from Instruction Word

    reg [01:00] halt_ex_2cycles;
    reg [31:00] pc_current;

    always @ (posedge clk)
    begin

        if (reset)  iw_out <= 0;

        else if (halt_ex)   iw_out <= 32'h13;       // Set as no-op if flag is encountered

        else if (halt_ex_2cycles[0])
        begin
            halt_ex_2cycles[0] <= 0;
            iw_out <= 32'h13;
        end

        else if (halt_ex_2cycles[1])
        begin
            halt_ex_2cycles[1] <= 0;
            iw_out <= 32'h13;
        end

        else if (jump_en_int)
        begin
            jump_en_flag <= 1;                      // Set an internal flag for the next clock cycle
            iw_out <= iw_in;                        // Push out the Branch Instruction down the pipeline
        end

        else if (jump_en_flag)
        begin
            iw_out <= 32'h13;                       // Set as no-op if the flag has been set in the previous clock cycle
            jump_en_flag <= 0;                      // Clear flag
        end

        else    iw_out <= iw_in;                    // Pass them on to the next module stage

        pc_out <= pc_in;                            // Pass them on to the next module stage
        wb_reg <= iw_in[11:07];                     // Destination Register for Register Interface

        rs1_data_out <= rs1_int;                    // Assign fetched and/or forwarded data synchronously
        rs2_data_out <= rs2_int;                    // Assign fetched and/or forwarded data synchronously

        /*
            Memory interface handling
        */
        if (reset)                      w_en_out <= 0;                  // Clear if reset
        else if (opcode == 7'b0100011)  w_en_out <= 1;                  // Store Instructions
        else                            w_en_out <= 0;                  // ALU output

        if (
		        opcode == 7'b0100011 ||		        // SB, SH, SW
                opcode == 7'b1100011 ||             // BEQ, BNE, BLT, BGE, BLTU, BGEU
                opcode == 7'b1100111 ||             // JALR
                opcode == 7'b1101111 ||             // JAL
                opcode == 7'b0001111 ||             // FENCE
                opcode == 7'b1110011                // EBREAK, ECALL
            )               wb_en_out <= 0;         // For instructions that don't require writebacks
        else if (
                opcode == 7'b0110011 ||             // R
	            opcode == 7'b1100111 ||             // JALR
	            opcode == 7'b0000011 ||             // L
	            opcode == 7'b0010011 ||             // I
	            opcode == 7'b0110111 ||             // LUI
	            opcode == 7'b0010111 ||             // AUIPC
	            opcode == 7'b1101111                // JAL instruction
        )                   wb_en_out <= 1;         //
        else if (reset)     wb_en_out <= 0;         // Reset condition
        else                wb_en_out <= 0;         // Default condition

        if (df_w_en_ex)
        begin
            halt_ex_2cycles <= 2'd3;

            if (halt_ex_2cycles[0] && halt_ex_2cycles[1])
            begin
                pc_halt_out = 1;
                pc_current = pc_in;
            end

            else if (halt_ex_2cycles[1])
            begin
                pc_halt_out = 1;
                pc_current = pc_in;
            end
        end

        else
        begin
            pc_halt_out = 0;
            pc_current = pc_in;
        end

    end

    // Determine if writeback must be enabled depending on the opcode in the Instruction Word
    always @ (*)
    begin
        /* Memory and IO operation Hazard handling
            If instruction in exTop deals with memory,
        */

        /* EBreak
            Set a flag if the Ebreak opcode is encountered
            The flag will be synchronously read in a parallel always block and acted upon
        */
        if (opcode == 7'b1110011)   halt_ex = 1;
        else if (reset)             halt_ex = 0;
        else                        halt_ex = 0;

        /*
            Jump enable on jump signal detection
        */
        if (reset)                      jump_en_out = 0;                // Regardless nobody jumps on reset
        else if (jump_en_in)            jump_en_out = 0;                // Indicates that the previous instruction was a jump
        else                            jump_en_out = jump_en_int;      // Set the jump

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
        if (jump_en_in)
        begin
            jump_en_int <= 0;
            jump_addr <=0;
        end

        else if(opcode == 7'b1100111)                                                                           // JALR instruction
        begin
            jump_addr <= rs1_int + {{20{iw_in[31]}}, iw_in[31:20]};                                             // Set jump destination
            jump_en_int <= 1;                                                                                   // Set jump enable flag
        end

        else if (opcode == 7'b1101111)                                                                          // JAL instruction
        begin
            jump_addr <= pc_in + {2 * {{12{iw_in[31]}}, iw_in[31], iw_in[19:12], iw_in[20], iw_in[30:21]}};     // Set jump destination
            jump_en_int <= 1;                                                                                   // Set jump enable flag
        end

        else if (opcode == 7'b1100011)                                                                          // BRANCH instructions
        begin
            case (iw_in[14:12])
                3'b000:
                begin
                    if (rs1_int == rs2_int)                                                                                 // BEQ instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_en_int <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_en_int <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b001:
                begin
                    if (rs1_int != rs2_int)                                                                                 // BNE instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_en_int <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_en_int <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b100:
                begin
                    if (signed'(rs1_int) < signed'(rs2_int))                                                                // BLT instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_en_int <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_en_int <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b101:
                begin
                    if (signed'(rs1_int) >= signed'(rs2_int))                                                               // BGE instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_en_int <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_en_int <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b110:
                begin
                    if (rs1_int < rs2_int)                                                                                  // BLTU instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_en_int <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_en_int <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                3'b111:
                begin
                    if (rs1_int >= rs2_int)                                                                                 // BGE instruction
                    begin
                        jump_addr <= pc_in + {2 * {{20{iw_in[31]}}, iw_in[31], iw_in[07], iw_in[30:25], iw_in[11:08]}};     // Set jump destination
                        jump_en_int <= 1;                                                                                   // Set jump enable flag
                    end
                    else
                    begin
                        jump_en_int <= 0;                                                                                   // Follow regular program execution flow
                        jump_addr <= 0;                                                                                     // Clear Jump flag
                    end
                end

                default:
                begin
                    jump_addr <= 0;                                                                                         // Follow regular program execution flow
                    jump_en_int <= 0;                                                                                       // Clear jump enable flag
                end
            endcase

        end

        // Leave nothing dangling or Quartus Prime will complain about inferred latches
        else
        begin
            jump_addr <= 0;                                                                                                 // Follow regular program execution flow
            jump_en_int <= 0;                                                                                               // Clear jump enable flag
        end
    end
endmodule