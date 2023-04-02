/*
    Top code to test all other modules
*/
module cri(
        input MAX10_CLK1_50,
        input [1:0] KEY
    );

    wire clk = MAX10_CLK1_50;

    reg reset, pre_reset;
    wire wb_en_stage2, wb_en_stage3, wb_en_stage4, wb_en_stage5;
    wire [04:00] rs1_reg, rs2_reg, wb_reg_stage2, wb_reg_stage3, wb_reg_stage4, wb_reg_stage5;
    wire [31:02] memIfAddr;
    wire [31:00] rs1_data, rs2_data, alu_out_stage3, alu_out_stage4, alu_out_stage5, i_rdata, d_rdata, wb_data;
    wire [31:00] iw_stage1, iw_stage2, iw_stage3,iw_stage4, pc_stage1, pc_stage2, pc_stage3, pc_stage4;
    wire [31:00] rs1_data_out, rs2_data_out;

    wire df_ex_enable, df_mem_enable, df_wb_enable, jump_enable;
    wire [04:00] df_ex_reg, df_mem_reg, df_wb_reg;
    wire [31:00] df_ex_data, df_mem_data, df_wb_data, jump_addr;

    // Include files
    `include "rv32i_memInterface.sv"    // Files to format data for Dual Port RAM module

    // handle input metastability safely
    always_ff @ (posedge(clk))
    begin
        pre_reset <= !KEY[0];
        reset <= pre_reset;
    end

    rv32i_syncDualPortRam ramTest(      // Instantiate Dual Port RAM module
        .clk(clk),                      // Clock
        .i_addr(memIfAddr),             // Instruction Address                      | From ifTop module
        .i_rdata(i_rdata)               // Read Instruction Word                    | To ifTop module
    );

    rv32i_reg regFsInstance (           // Instantiate Register File System
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset

        .rs1_reg(rs1_reg),              // Register to read                         | From idTop module
        .rs2_reg(rs2_reg),              // Register to read                         | From idTop module

        .wb_reg(wb_reg_stage5),         // Register to write into                   | From wbTop module
        .wb_data(alu_out_stage5),       // Data to write to register                | From wbTop module
        .wb_enable(wb_en_stage5),       // Write Enable/Disable                     | From wbTop module

        .rs1_data(rs1_data),            // Read data                                | To idTop module
        .rs2_data(rs2_data)             // Read data                                | To idTop module
    );

    rv32i_ifTop ifTopInstance(          // Instantiate the Instruction Fetch stage
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset
        .memIfData(i_rdata),            // Data                                     | From SyncDualPortRam module

        .jump_enable(jump_enable),      // Jump enable                              | From idTop module
        .jump_addr(jump_addr),          // Jump destination                         | From idTop module

        .memIfAddr(memIfAddr),          // Return value                             | To SyncDualPortRam module
        .iw_out(iw_stage1),             // Instruction Word                         | To idTop module
        .pc_out(pc_stage1)              // Program Counter as calculated here       | To idTop module
    );

    rv32i_idTop idTopInstance(          // Instantiate the Instruction Decode stage
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset
        .iw_in(iw_stage1),              // Instruction Word                         | From ifTop module
        .pc_in(pc_stage1),              // Program Counter                          | From ifTop module
        .rs1_data_in(rs1_data),         // Register data from Register Interface    | From regFs module
        .rs2_data_in(rs2_data),         // Register data from Register Interface    | From regFs module

        .rs1_reg(rs1_reg),              // Register to read from                    | To regFs module
        .rs2_reg(rs2_reg),              // Register to read from                    | To regFs module

        .jump_enable(jump_enable),      // Jump enable                              | To ifTop module
        .jump_addr(jump_addr),          // Jump destination                         | To ifTop module

        .df_ex_enable(df_ex_enable),    // Forwaded values                          | From exTop module
        .df_ex_reg(df_ex_reg),          // Forwaded values                          | From exTop module
        .df_ex_data(df_ex_data),        // Forwaded values                          | From exTop module

        .df_mem_enable(df_mem_enable),  // Forwaded values                          | From memTop module
        .df_mem_reg(df_mem_reg),        // Forwaded values                          | From memTop module
        .df_mem_data(df_mem_data),      // Forwaded values                          | From memTop module

        .df_wb_enable(df_wb_enable),    // Forwaded values                          | From wbTop module
        .df_wb_reg(df_wb_reg),          // Forwaded values                          | From wbTop module
        .df_wb_data(df_wb_data),        // Forwaded values                          | From wbTop module

        .wb_reg(wb_reg_stage2),         // Register to write into                   | To exTop module
        .wb_en_out(wb_en_stage2),       // Writeback enable/disable                 | To exTop module
        .iw_out(iw_stage2),             // Instruction Word                         | To exTop module
        .pc_out(pc_stage2),             // Program Counter                          | To exTop module
        .rs1_data_out(rs1_data_out),    // Data                                     | To exTop module
        .rs2_data_out(rs2_data_out)     // Data                                     | To exTop module
    );

    rv32i_exTop exTopInstance(          // Instantiate ALU system
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset

        .pc_in(pc_stage2),              // Current Program Counter                  | From idTop module
        .iw_in(iw_stage2),              // Current Instruction Word                 | From idTop module
        .wb_en_in(wb_en_stage2),        // Writeback enable/disable                 | From idTop module
        .rs1_data_in(rs1_data_out),     // Data to manipulate                       | From regFs module
        .rs2_data_in(rs2_data_out),     // Data to manipulate                       | From regFs module
        .wb_reg_in(wb_reg_stage2),      // Writeback register                       | From idTop module

        .alu_out(alu_out_stage3),       // Result of operations                     | To memTop & syncDualPortRam modules
        .pc_out(pc_stage3),             // Updated Program Counter                  | To memTop module
        .iw_out(iw_stage3),             // Updated Instruction Word                 | To memTop module
        .wb_en_out(wb_en_stage3),       // Writeback enable/disable                 | To memTop module
        .wb_reg_out(wb_reg_stage3),     // Writeback register                       | To memTop module

        .df_ex_enable(df_ex_enable),
        .df_ex_reg(df_ex_reg),
        .df_ex_data(df_ex_data)
    );

    rv32i_memTop memTopInstance(        // Instantiate Memory stage
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset

        .pc_in(pc_stage3),              // Current Program Counter                  | From exTop module
        .iw_in(iw_stage3),              // Current Instruction Word                 | From exTop module
        .wb_reg_in(wb_reg_stage3),      // Destination register                     | From exTop module
        .alu_in(alu_out_stage3),        // Output from the ALU                      | From exTop module
        .wb_en_in(wb_en_stage3),        // Writeback enable/disable                 | From exTop module

        .pc_out(pc_stage4),             // Updated Program Counter                  | To wbTop module
        .iw_out(iw_stage4),             // Updated Instruction Word                 | To wbTop module
        .wb_en_out(wb_en_stage4),       // Writeback enable/disable                 | To wbTop module
        .wb_reg_out(wb_reg_stage4),     // Destination register                     | To wbTop module
        .alu_out(alu_out_stage4),       // Writeback value                          | TO wbTop module

        .df_mem_enable(df_mem_enable),
        .df_mem_reg(df_mem_reg),
        .df_mem_data(df_mem_data)
    );

    rv32i_wbTop wbTopinstance(          // Instantiate WriteBack stage
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset
        .pc_in(pc_stage4),              // Current Program Counter                  | From memTop module
        .iw_in(iw_stage4),              // Current Instruction Word                 | From memTop module
        .wb_en_in(wb_en_stage4),        // Writeback enable/disable                 | From memTop module
        .wb_reg_in(wb_reg_stage4),      // Destination Register                     | From idTop module
        .alu_in(alu_out_stage4),        // Calculated output                        | From exTop module

        .wb_data(alu_out_stage5),       // Writeback data                           | To regFsTop module
        .wb_reg_out(wb_reg_stage5),     // Destination Register                     | To regFsTop module
        .wb_en_out(wb_en_stage5),       // Writeback enable/disbale                 | To regFsTop module

        .df_wb_enable(df_wb_enable),
        .df_wb_reg(df_wb_reg),
        .df_wb_data(df_wb_data)
    );
endmodule
