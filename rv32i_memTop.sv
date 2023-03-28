module rv32i_memTop(
        input clk, reset, wb_en_in,                 // system clock and synchronous reset
        input [31:0] pc_in, iw_in, alu_in,          // From exTop
        input [4:0] wb_reg_in,
        output wb_en_out,                           // To wbTop
        output reg [31:0] pc_out, iw_out, alu_out,  // To wbTop
        output reg [4:0] wb_reg_out,

        // Forwarded data from memTop stage
        output df_mem_enable,               // Writeback enable signal at the exTop stage
        output reg [4:0] df_mem_reg,        // Writeback register at the exTop stage
        output reg [31:0] df_mem_data       // Writeback data at the exTop stage
    );

    always_ff @ (posedge clk)
    begin
        iw_out <= iw_in;                    // Pass onto wbTop module
        pc_out <= pc_in;                    // Pass onto wbTop module
        alu_out <= alu_in;                  // Pass onto wbTop module
        wb_en_out <= wb_en_in;              // Pass onto wbTop module
        wb_reg_out <= wb_reg_in;
    end

    assign df_mem_enable = wb_en_in;
    assign df_mem_reg    = wb_reg_in;
    assign df_mem_data   = alu_out;

endmodule