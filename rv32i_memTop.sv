module rv32i_memTop(
        input clk, reset, wb_en_in,                 // system clock and synchronous reset
        input [31:0] pc_in, iw_in, alu_in,          // From exTop
        output wb_en_out,                           // To wbTop
        output reg [31:0] pc_out, iw_out, alu_out   // To wbTop
    );

    always_ff @ (posedge clk)
    begin
        iw_out <= iw_in;                    // Pass onto wbTop module
        pc_out <= pc_in;                    // Pass onto wbTop module
        alu_out <= alu_in;                  // Pass onto wbTop module
        wb_en_out <= wb_en_in;              // Pass onto wbTop module
    end

endmodule