module rv32i_memTop(
        input clk, reset, wb_en_in,                 // system clock and synchronous reset
        input [31:0] pc_in, iw_in, alu_in,          // From exTop
        input [31:0] rs1_data_in, rs2_data_in,
        input [4:0] wb_reg_in,
        output wb_en_out,                           // To wbTop
        output reg [31:0] pc_out, iw_out, alu_out,  // To wbTop
        output reg [31:0] rs1_data_out, rs2_data_out,
        output reg [4:0] wb_reg_out
    );

    always_ff @ (posedge clk)
    begin
        iw_out <= iw_in;                    // Pass onto wbTop module
        pc_out <= pc_in;                    // Pass onto wbTop module
        alu_out <= alu_in;                  // Pass onto wbTop module
        wb_en_out <= wb_en_in;              // Pass onto wbTop module
        rs1_data_out <= rs1_data_in;
        rs2_data_out <= rs2_data_in;
        wb_reg_out <= wb_reg_in;
    end

endmodule