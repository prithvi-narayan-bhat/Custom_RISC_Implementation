module rv32i_wbTop(
        input clk, reset, wb_en_in,         // System clock and synchronous reset
        input [4:0] wb_reg_in,              // From Insdtruction Decode: Writeback Register
        input [31:0] pc_in, iw_in, alu_in,  // From memTop
        output wb_en_out,                   // To Register Interface: Enable/Disable writeback
        output reg [31:0] wb_data,          // To Register Interface: Writeback Data
        output reg [4:0] wb_reg_out         // To Register Interface: Writeback Register
    );

        assign wb_data = alu_in;
        assign wb_en_out = wb_en_in;
        assign wb_reg_out = wb_reg_in;

endmodule