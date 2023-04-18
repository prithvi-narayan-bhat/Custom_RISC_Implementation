module rv32i_memTop(
        input clk, reset, wb_en_in,                 // system clock and synchronous reset
        input [31:0] pc_in, iw_in, alu_in,          // From exTop
        input [4:0] wb_reg_in,
        output wb_en_out,                           // To wbTop
        output reg [31:0] pc_out, iw_out, alu_out,  // To wbTop
        output reg [4:0] wb_reg_out,

        input [31:00] memif_rdata,                  // Read data            | From syncDualPortRam module
        input [31:00] io_rdata,                     // Read data            | From ioTop module

        input [31:00] rs2_data_in,                  // Write data           | From exTop module
        input w_en_in,                              // mem/io write enable  | From exTop module

        // Memory Interface
        output memif_we,                            // Write enable         | To syncDualPortRam module
        output [3:0] memif_be,                      // Bank enable          | To syncDualPortRam module
        output [31:2] memif_addr,                   // Write address        | To syncDualPortRam module
        output [31:0] memif_wdata,                  // Write Data           | To syncDualPortRam module
        output [31:00] memif_rdata_out,             // Read data            | To syncDualPortRam module

        // IO Interface
        // output io_we,                               //  Write enable     | To ioTop module
        // output [3:0] io_be_out,                     //  Bank enable      | To ioTop module
        // output [31:2] io_addr,                      //  Write address    | To ioTop module
        // output [31:0] io_wdata,                     //  Write Data       | To ioTop module

        output [01:00] src_sel_out,                 // Source for writeback | To wbTop module
        output w_en_out,                            // mem/io write enable  | To wbTop module

        // Forwarded data from memTop stage
        output df_mem_enable,               // Writeback enable signal at the exTop stage
        output reg [4:0] df_mem_reg,        // Writeback register at the exTop stage
        output reg [31:0] df_mem_data       // Writeback data at the exTop stage
    );

    // Include files
    `include "rv32i_memInterface.sv"        // Files to format data for Dual Port RAM module

    wire [01:00] width = iw_in[13:12];      // Width
    wire [01:00] bank = alu_in[1:0];        // Extract bank from alu_in

    always @ (*)
    begin
        if (w_en_in && alu_in[31])
        begin
            // io_we   <= 1;               // Enable io if alu_out[31] is 1
            memif_we  <= 0;             // Disable mem
        end
        else if (w_en_in && !alu_in[31])
        begin
            // io_we   <= 0;               // Disable io
            memif_we  <= 1;             // Enable mem if alu_out[31] is 0
        end
        else
        begin
            // io_we   <= 0;               // Leave nothing hanging
            memif_we  <= 0;             // Leave nothing hanging
        end

        if (!w_en_in)
        begin
            if (!alu_in[31])        src_sel_out <= 0;   // Memory
            else if (alu_in[31])    src_sel_out <= 1;   // IO
            else                    src_sel_out <= 2;   // ALU
        end
        else                        src_sel_out <= 2;   // ALU


    end

    always @ (posedge clk)
    begin
        if (reset)
        begin
            iw_out <= 0;                // Pass onto wbTop module
            pc_out <= 0;                // Pass onto wbTop module
            alu_out <= 0;               // Pass onto wbTop module
            wb_en_out <= 0;             // Pass onto wbTop module
            wb_reg_out <= 0;
        end
        else
        begin
            iw_out <= iw_in;            // Pass onto wbTop module
            pc_out <= pc_in;            // Pass onto wbTop module
            alu_out <= alu_in;          // Pass onto wbTop module
            wb_en_out <= wb_en_in;      // Pass onto wbTop module
            wb_reg_out <= wb_reg_in;
        end
    end

    assign memif_addr  = alu_in[31:02];     // Latch and pass   | To syncDualPortRam module
    assign w_en_out = w_en_in;              // Latch and pass   | To syncDualPortRam module

    assign memif_be     = writeBankEnable(bank, width);         // Calculate bank enable signal
    assign memif_wdata  = shifted_rs2_data(rs2_data_in, bank);  // Format write data

    assign df_mem_enable = wb_en_out;
    assign df_mem_reg    = wb_reg_out;
    assign df_mem_data   = alu_out;
    assign memif_rdata_out = memif_rdata; // shifted_d_rdata(memif_rdata, alu_in, width, iw_in[14]); // Latch and pass   | To wbTop module

endmodule