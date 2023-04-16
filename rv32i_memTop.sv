module rv32i_memTop(
        input clk, reset, wb_en_in,                 // system clock and synchronous reset
        input [31:0] pc_in, iw_in, alu_in,          // Program counter, and alu_out | From exTop module
        input [4:0] wb_reg_in,                      // Writeback register           | From exTop module
        input [1:0] width_in,                       // Width of data                | From exTop module
        input [3:0] bank_en_in,                     // Bank Enable                  | From exTop module

        input [31:0] rs2_data_in,                   // rs2 data                     | From exTop module

        input [31:0] rdata,                         // Memory interface read data   | From syncDualPortRam module
        input [31:0] io_rdata,                      // IO read data                 | From ioInterface module

        output d_we_out,                            // Write enable                 | To syncDualPortRam module
        output [1:0] width_out,                     // Width                        | To syncDualPortRam module
        output [3:0] bank_en_out,                   // Bank Enable                  | To syncDualPortRam module
        output [31:2] addr,                         // Write address                | To syncDualPortRam module
        output [31:0] wdata,                        // Write data                   | To syncDualPortRam module

        output io_we,                               // Write enable                 | To ioInterface module
        output [31:2] io_addr,                      // Write address                | To ioInterface module
        output [3:0] io_be,                         // Bank enable                  | To ioInterface module
        output [31:0] io_wdata,                     // Write data                   | To ioInterface module

        output wb_en_out,                           // To wbTop
        output reg [31:0] pc_out, iw_out, alu_out,  // To wbTop
        output reg [4:0] wb_reg_out,

        // Forwarded data from memTop stage
        output df_mem_enable,                       // Forwarded writeback enable   | To idTop module
        output reg [4:0] df_mem_reg,                // Forwarded writeback register | To idTop module
        output reg [31:0] df_mem_data               // Forwarded writeback data     | To idTop module
    );

    // Include files
    `include "rv32i_memInterface.sv"                // Files to format data for Dual Port RAM module

    always_ff @ (*)
    begin
        if (reset)
        begin
            iw_out      <= 0;               // Clear on reset
            pc_out      <= 0;               // Clear on reset
            alu_out     <= 0;               // Clear on reset
            wb_en_out   <= 0;               // Clear on reset
            wb_reg_out  <= 0;               // Clear on reset
            d_we_out    <= 0;               // Clear on reset
            bank_en_out <= 0;               // Clear on reset
            width_out   <= 0;               // Clear on reset
            addr        <= 0;               // Clear on reset
        end
        else
        begin
            iw_out      <= iw_in;           //                      | To wbTop module
            pc_out      <= pc_in;           //                      | To wbTop module
            alu_out     <= alu_in;          //                      | To wbTop module
            wb_en_out   <= wb_en_in;        //                      | To wbTop module
            wb_reg_out  <= wb_reg_in;       // Destination register | To wbTop module
            d_we_out    <= wb_en_in;        // Data write enable    | To syncDualPortRam module
            bank_en_out <= bank_en_in;      // Bank enable          | To syncDualPortRam module
            width_out   <= width_in;        // Data width           | To syncDualPortRam module
            addr        <= alu_in[31:2];    // Destination address  | To syncDualPortRam module
        end
    end

    assign df_mem_enable = wb_en_out;
    assign df_mem_reg    = wb_reg_out;
    assign df_mem_data   = alu_out;
    assign wdata         = shifted_data(rs2_data_in, alu_in[1:0]);

endmodule