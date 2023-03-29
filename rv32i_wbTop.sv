module rv32i_wbTop(
        input clk, reset, wb_en_in,         // System clock and synchronous reset
        input [4:0] wb_reg_in,              // From Insdtruction Decode: Writeback Register
        input [31:0] pc_in, iw_in, alu_in,  // From memTop
        output wb_en_out,                   // To Register Interface: Enable/Disable writeback
        output reg [31:0] wb_data,          // To Register Interface: Writeback Data
        output reg [4:0] wb_reg_out,        // To Register Interface: Writeback Register

        // Forwarded data from wbTop stage
        output df_wb_enable,                // Writeback enable signal at the wbTop stage
        output reg [4:0] df_wb_reg,         // Writeback register at the wbTop stage
        output reg [31:0] df_wb_data        // Writeback data at the wbTop stage
    );

        assign wb_data = alu_in;
        assign wb_en_out = wb_en_in;
        assign wb_reg_out = wb_reg_in;

        assign df_wb_enable = wb_en_in;
        assign df_wb_reg    = wb_reg_in;
        assign df_wb_data   = alu_in;

endmodule