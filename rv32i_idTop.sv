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
        output reg [31:00] rs1_data_out, rs2_data_out
    );

    assign rs1_reg = iw_in[19:15];            // Calculate rs1 from Instruction Word
    assign rs2_reg = iw_in[24:20];            // Calculate rs2 from Instruction Word

	reg halt_ex;
    reg [31:00] rs1_int, rs2_int;

    always_ff @ (posedge clk)
    begin

        if (halt_ex == 1'b1)    iw_out <= 32'h13;   // Set as no-op
        else                    iw_out <= iw_in;    // Pass them on to the next module stage
        pc_out <= pc_in;                            // Pass them on to the next module stage
        wb_reg <= iw_in[11:07];                     // Destination Register for Register Interface

        rs1_data_out <= rs1_int;
        rs2_data_out <= rs2_int;
    end

    // Determine if writeback must be enabled depending on the opcode in the Instruction Word
    always_ff @ (*)
    begin
        if (iw_in[06:00] == 7'b0100011) wb_en_out <= 0; // The only instruction that doesn't require writebacks
        else                            wb_en_out <= 1; // All others require writebacks

        // EBreak
        if (iw_in[06:00] == 7'b1110011) halt_ex = 1'b1;
        if (reset == 1'b1)              halt_ex = 1'b0;

    end

    // Data Forwarding
    always_ff @ (*)
    begin
        if      ((rs1_reg == df_ex_reg) && df_ex_enable && rs1_reg != 0)    rs1_int <= df_ex_data;
        else if ((rs1_reg == df_mem_reg) && df_mem_enable && rs1_reg != 0)  rs1_int <= df_mem_data;
        else if ((rs1_reg == df_wb_reg) && df_wb_enable && rs1_reg != 0)    rs1_int <= df_wb_data;
        else    rs1_int <= rs1_data_in;

        if      ((rs2_reg == df_ex_reg) && df_ex_enable && rs2_reg != 0)    rs2_int <= df_ex_data;
        else if ((rs2_reg == df_mem_reg) && df_mem_enable && rs2_reg != 0)  rs2_int <= df_mem_data;
        else if ((rs2_reg == df_wb_reg) && df_wb_enable && rs2_reg != 0)    rs2_int <= df_wb_data;
        else    rs2_int <= rs2_data_in;
    end

endmodule