module rv32i_idTop
    (
        input clk, reset,                   // System clock and synchronous reset
        input [31:0] iw_in, pc_in,          // From ifTop
        input [31:0] rs1_data, rs2_data,    // From Register interface
        output reg [4:0] rs1_reg, rs2_reg,  // To Register interface
        output reg [4:0] wb_reg,            // To Register Interface
        output reg [31:0] pc_out, iw_out,   // To exTop
        output wb_en_out
    );

    always_ff @ (posedge clk)
    begin
        rs1_reg <= iw_in[19:15];            // Calculate rs1 from Instruction Word
        rs2_reg <= iw_in[24:20];            // Calculate rs2 from Instruction Word
        wb_reg <= iw_in[11:07];             // Destination Register for Register Interface
        iw_out <= iw_in;                    // Pass them on to the next module stage
        pc_out <= pc_in;                    // Pass them on to the next module stage
    end

    // Determine if writeback must be enabled depending on the opcode in the Instruction Word
    always_ff @ (posedge clk)
    begin
        if (iw_in[06:00] == 7'b0100011) wb_en_out <= 0; // The only instruction that doesn't require writebacks
        else                            wb_en_out <= 1; // All others require writebacks
    end

endmodule