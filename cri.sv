/*
    Top code to test all other modules
*/
module cri(
        input ADC_CLK_10,
        input [1:0] KEY
    );

    reg reset, pre_reset;
    wire wb_en_stage1, wb_en_stage2, wb_en_stage3;
    wire [04:00] rs1_reg, rs2_reg, rsd_reg;
    wire [31:02] memIfAddr;
    wire [31:00] rs1_data, rs2_data, alu_out, i_rdata, d_rdata, wb_data;
    wire [31:00] iw_stage1, pc_stage1,  iw_stage2, pc_stage2,  iw_stage3, pc_stage3,  iw_stage4, pc_stage4;

    // Include files
    `include "rv32i_memInterface.sv"    // Files to format data for Dual Port RAM module

    // handle input metastability safely
    always_ff @ (posedge(ADC_CLK_10))
    begin
        pre_reset <= !KEY[0];
        reset <= pre_reset;
    end

    rv32i_syncDualPortRam ramTest(      // Instantiate Dual Port RAM module
        .clk(ADC_CLK_10),               // Clock
        .i_addr(memIfAddr),             // Instruction Address                      | From ifTop module
        .d_addr(alu_out[31:2]),         // Data Address                             | From exTop module
        .i_rdata(i_rdata)               // Read Instruction Word                    | To ifTop module
    );

    rv32i_reg regFsInstance (           // Instantiate Register File System
        .clk(ADC_CLK_10),               // Clock
        .reset(reset),                  // Reset
        .wb_enable(wb_en_out),          // Write Enable/Disable                     | From idTop module
        .rs1_reg(rs1_reg),              // Register to read                         | From idTop module
        .rs2_reg(rs2_reg),              // Register to read                         | From idTop module
        .wb_reg(rsd_reg),               // Register to write into                   | From idTop module
        .wb_data(wb_data),              // Data to write to register                | From exTop module
        .rs1_data(rs1_data),            // Read data                                | To idTop module
        .rs2_data(rs2_data)             // Read data                                | To idTop module
    );


    rv32i_ifTop ifTopInstance(          // Instantiate the Instruction Fetch stage
        .clk(ADC_CLK_10),               // Clock
        .reset(reset),                  // Reset
        .memIfData(i_rdata),            // Data                                     | From SyncDualPortRam module
        .memIfAddr(memIfAddr),          // Return value                             | To SyncDualPortRam module
        .iw_out(iw_stage1),             // Instruction Word                         | To idTop module
        .pc_out(pc_stage1)              // Program Counter as calculated here       | To idTop module
    );

    rv32i_idTop idTopInstance(          // Instantiate the Instruction Decode stage
        .clk(ADC_CLK_10),               // Clock
        .reset(reset),                  // Reset
        .iw_in(iw_stage1),              // Instruction Word                         | From ifTop module
        .pc_in(pc_stage1),              // Program Counter                          | From ifTop module
        .rs1_data(rs1_data),            // Register data from Register Interface    | From regFs module
        .rs2_data(rs2_data),            // Register data from Register Interface    | From regFs module
        .rs1_reg(rs1_reg),              // Register to read from                    | To regFs module
        .rs2_reg(rs2_reg),              // Register to read from                    | To regFs module
        .wb_reg(rsd_reg),               // Register to write into                   | To regFs module
        .wb_en_out(wb_en_stage1),       // Writeback enable/disable                 | To exTop module
        .iw_out(iw_stage2),             // Instruction Word                         | To exTop module
        .pc_out(pc_stage2)              // Program Counter                          | To exTop module
    );

    rv32i_exTop exTopInstance(          // Instantiate ALU system
        .clk(ADC_CLK_10),               // Clock
        .reset(reset),                  // Reset
        .pc_in(pc_stage2),              // Current Program Counter                  | From idTop module
        .iw_in(iw_stage2),              // Current Instruction Word                 | From idTop module
        .wb_en_in(wb_en_stage1),        // Writeback enable/disable                 | From idTop module
        .rs1_data_in(rs1_data),         // Data to manipulate                       | From regFs module
        .rs2_data_in(rs2_data),         // Data to manipulate                       | From regFs module
        .alu_out(alu_out),              // Result of operations                     | To memTop syncDualPortRam modules
        .pc_out(pc_stage3),             // Updated Program Counter                  | To memTop module
        .iw_out(iw_stage3),             // Updated Instruction Word                 | To memTop module
        .wb_en_out(wb_en_stage2)        // Writeback enable/disable                 | To memTop module
    );

    rv32i_memTop memTopInstance(        // Instantiate Memory stage
        .clk(ADC_CLK_10),               // Clock
        .reset(reset),                  // Reset
        .pc_in(pc_stage3),              // Current Program Counter                  | From exTop module
        .iw_in(iw_stage3),              // Current Instruction Word                 | From exTop module
        .alu_in(alu_out),               // Output from the ALU                      | From exTop module
        .wb_en_in(wb_en_stage2),        // Writeback enable/disable                 | From memTop module
        .pc_out(pc_stage4),             // Updated Program Counter                  | To wbTop module
        .iw_out(iw_stage4),             // Updated Instruction Word                 | To wbTop module
        .wb_en_out(wb_en_stage3)        // Writeback enable/disable                 | To wbTop module
    );

    rv32i_wbTop wbTopinstance(          // Instantiate WriteBack stage
        .clk(ADC_CLK_10),               // Clock
        .reset(reset),                  // Reset
        .pc_in(pc_stage4),              // Current Program Counter                  | From memTop module
        .iw_in(iw_stage4),              // Current Instruction Word                 | From memTop module
        .wb_en_in(wb_en_stage3),        // Writeback enable/disable                 | From memTop module
        .wb_reg_in(rsd_reg),            // Destination Register                     | From idTop module
        .alu_in(alu_out),               // Calculated output                        | From exTop
        .wb_data(wb_data),              // Writeback data                           | To regFsTop
        .wb_reg_out(rsd_reg_out)        // Destination Register                     | To regFsTop module
    );

    rv32i_reg (                         // Instantiate Register File System with updated values
        .clk(ADC_CLK_10),               // Clock
        .reset(reset),                  // Reset
        .wb_enable(wb_en_stage3),       // Write Enable/Disable                     | From idTop module
        .wb_reg(rsd_reg_out),           // Register to write into                   | From idTop module
        .wb_data(wb_data)               // Data to write to register                | From exTop module
    );

endmodule
