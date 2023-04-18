module rv32i_wbTop(
        input clk, reset, wb_en_in,         // System clock and synchronous reset
        input [4:0] wb_reg_in,              // From Insdtruction Decode: Writeback Register
        input [31:0] pc_in, iw_in, alu_in,  // From memTop
        input [31:00] memif_rdata,          // Data read from Memory        | From syncDualPortRam module
        input [01:00] src_sel_in,           // Data source selector         | From exTop module
        output wb_en_out,                   // To Register Interface: Enable/Disable writeback
        output reg [31:0] wb_data,          // To Register Interface: Writeback Data
        output reg [4:0] wb_reg_out,        // To Register Interface: Writeback Register

        // Forwarded data from wbTop stage
        output df_wb_enable,                // Writeback enable signal at the wbTop stage
        output reg [4:0] df_wb_reg,         // Writeback register at the wbTop stage
        output reg [31:0] df_wb_data        // Writeback data at the wbTop stage
    );

    wire [01:00] src_sel_int = src_sel_in;

    always @ (*)
    begin
        if (reset)  wb_en_out <= 0;
        else        wb_en_out <= wb_en_in;

        wb_reg_out <= wb_reg_in;

        if (src_sel_int == 2'd2)        wb_data <= alu_in;      // Store output of exTop stage
        // else if (src_sel_int == 2'd1)   wb_data <= io_rdata;    // Store output of syncDualPortRam module
        else if (src_sel_int == 2'd0)   wb_data <= memif_rdata; // Store output of ioTop module
        else                            wb_data <= alu_in;
    end

    assign df_wb_enable = wb_en_out;
    assign df_wb_reg    = wb_reg_out;
    assign df_wb_data   = alu_in;

endmodule