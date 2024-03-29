/*
    Top code to test all other modules
*/
module cri(
        input ADC_CLK_10,
        input [1:0] KEY,
        output reg [9:0] LEDR              // LEDs             | On board
    );

    wire clk = ADC_CLK_10;

    reg reset, pre_reset, pre_pre_reset;
    wire wb_en_stage2, wb_en_stage3, wb_en_stage4, wb_en_stage5;
    wire [04:00] rs1_reg, rs2_reg, wb_reg_stage2, wb_reg_stage3, wb_reg_stage4, wb_reg_stage5;
    wire [31:02] memIfAddr;
    wire [31:00] rs1_data, rs2_data, alu_out_stage3, alu_out_stage4, alu_out_stage5, i_rdata, d_rdata, wb_data;
    wire [31:00] iw_stage1, iw_stage2, iw_stage3,iw_stage4, pc_stage1, pc_stage2, pc_stage3, pc_stage4;
    wire [31:00] rs1_data_stage2, rs2_data_stage2, rs2_data_stage3, rs2_data_io_stage4, rs2_data_me_stage4;

    wire df_ex_enable, df_mem_enable, df_wb_enable, jump_en_stage1, jump_en_stage2;
    wire [04:00] df_ex_reg, df_mem_reg, df_wb_reg;
    wire [31:00] df_ex_data, df_mem_data, df_wb_data, jump_addr;

    wire [03:00] memif_be_stage4;
    wire [31:02] memif_addr_stage4;
    wire [31:00] memif_wdata_stage4, memif_rdata_stage4;

    wire [01:00] width_stage2, width_stage3, width_stage4;

    wire memif_we_stage4;
    wire io_we_stage4;
    wire b_en_stage3;
    wire w_en_stage2, w_en_stage3, w_en_stage4;
    wire [01:00] src_sel_stage4;
    wire [03:00] io_be_stage4;
    wire [31:02] io_addr_stage4;
    wire [31:00] io_rdata;
    wire [09:00] led_data;

    // Handle input metastability safely
    always @ (posedge clk)
    begin
        pre_pre_reset <= !KEY[0];
        pre_reset <= pre_pre_reset;
    end
    assign reset = !pre_reset & pre_pre_reset;

    rv32i_syncDualPortRam ramTest(      // Instantiate Dual Port RAM module
        .clk(clk),                      // Clock
        .i_addr(memIfAddr),             // Instruction Address                      | From ifTop module
        .d_we(memif_we_stage4),         // Write enable                             | From memTop module
        .d_be(memif_be_stage4),         // Bank enable                              | From memTop module
        .d_addr(memif_addr_stage4),     // Write address                            | From memTop module
        .d_wdata(rs2_data_me_stage4),   // Write data                               | From memTop module
        .d_rdata(d_rdata),              // Read data                                | To memTop module
        .i_rdata(i_rdata)               // Read Instruction Word                    | To ifTop module
    );

    rv32i_ioTop ioTop(                  // Instantiate IO space
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset
        .KEY(KEY[1]),                   // Key                                      | From board

        .io_we(io_we_stage4),           // Write enable                             | From memTop module
        .io_addr(io_addr_stage4),       // Read/Write address                       | From memTop module
        .io_wdata(rs2_data_io_stage4),  // Write data                               | From memTop module
        .io_rdata(io_rdata),            // Read data                                | To memTop module
        .led(LEDR[9:0])
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

        .jump_en_in(jump_en_stage2),    // Jump enable                              | From idTop module
        .jump_addr(jump_addr),          // Jump destination                         | From idTop module

        .memIfAddr(memIfAddr),          // Return value                             | To SyncDualPortRam module
        .iw_out(iw_stage1),             // Instruction Word                         | To idTop module
        .pc_out(pc_stage1),             // Program Counter as calculated here       | To idTop module
        .jump_en_out(jump_en_stage1)    // Jump_en from the previous cycle          | To idTop module
    );

    rv32i_idTop idTopInstance(          // Instantiate the Instruction Decode stage
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset

        .iw_in(iw_stage1),              // Instruction Word                         | From ifTop module
        .pc_in(pc_stage1),              // Program Counter                          | From ifTop module
        .jump_en_in(jump_en_stage1),    // Jump enable signal from previous cycle   | from ifTop module

        .rs1_data_in(rs1_data),         // Register data from Register Interface    | From regFs module
        .rs2_data_in(rs2_data),         // Register data from Register Interface    | From regFs module

        .rs1_reg(rs1_reg),              // Register to read from                    | To regFs module
        .rs2_reg(rs2_reg),              // Register to read from                    | To regFs module

        .jump_en_out(jump_en_stage2),   // Jump enable                              | To ifTop module
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

        .w_en_out(w_en_stage2),         // Write enable                             | To exTop module
        .wb_reg(wb_reg_stage2),         // Register to write into                   | To exTop module
        .wb_en_out(wb_en_stage2),       // Writeback enable/disable                 | To exTop module
        .iw_out(iw_stage2),             // Instruction Word                         | To exTop module
        .pc_out(pc_stage2),             // Program Counter                          | To exTop module
        .rs1_data_out(rs1_data_stage2), // Data                                     | To exTop module
        .rs2_data_out(rs2_data_stage2)  // Data                                     | To exTop module
    );

    rv32i_exTop exTopInstance(          // Instantiate ALU system
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset

        .pc_in(pc_stage2),              // Current Program Counter                  | From idTop module
        .iw_in(iw_stage2),              // Current Instruction Word                 | From idTop module
        .wb_en_in(wb_en_stage2),        // Writeback enable/disable                 | From idTop module
        .rs1_data_in(rs1_data_stage2),  // Data to manipulate                       | From regFs module
        .rs2_data_in(rs2_data_stage2),  // Data to manipulate                       | From regFs module
        .wb_reg_in(wb_reg_stage2),      // Writeback register                       | From idTop module
        .w_en_in(w_en_stage2),          // Write enable                             | From idTop module

        .alu_out(alu_out_stage3),       // Result of operations                     | To memTop & syncDualPortRam modules
        .pc_out(pc_stage3),             // Updated Program Counter                  | To memTop module
        .iw_out(iw_stage3),             // Updated Instruction Word                 | To memTop module
        .wk_en_out(wb_en_stage3),       // Writeback enable/disable                 | To memTop module
        .wb_reg_out(wb_reg_stage3),     // Writeback register                       | To memTop module
        .w_en_out(w_en_stage3),         // Write enable                             | To memTop module
        .rs2_data_out(rs2_data_stage3), // Write data                               | To memTop module

        .df_ex_enable(df_ex_enable),    // Forwarded data to handle data hazards    | To idTop module
        .df_ex_reg(df_ex_reg),          // Forwarded data to handle data hazards    | To idTop module
        .df_ex_data(df_ex_data)         // Forwarded data to handle data hazards    | To idTop module
    );

    rv32i_memTop memTopInstance(        // Instantiate Memory stage
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset

        .pc_in(pc_stage3),              // Current Program Counter                  | From exTop module
        .iw_in(iw_stage3),              // Current Instruction Word                 | From exTop module
        .wb_reg_in(wb_reg_stage3),      // Destination register                     | From exTop module
        .alu_in(alu_out_stage3),        // Output from the ALU                      | From exTop module
        .wb_en_in(wb_en_stage3),        // Writeback enable/disable                 | From exTop module
        .w_en_in(w_en_stage3),          // Write enable                             | From exTop module
        .rs2_data_in(rs2_data_stage3),  // Write data                               | From exTop module

        .memif_rdata(d_rdata),          // Read data                                | From syncDualPortRam module
        .io_rdata(io_rdata),            // Read data                                | From ioTop module

        .pc_out(pc_stage4),             // Updated Program Counter                  | To wbTop module
        .iw_out(iw_stage4),             // Updated Instruction Word                 | To wbTop module
        .wb_en_out(wb_en_stage4),       // Writeback enable/disable                 | To wbTop module
        .wb_reg_out(wb_reg_stage4),     // Destination register                     | To wbTop module
        .alu_out(alu_out_stage4),       // Writeback value                          | TO wbTop module
        .memif_rdata_out(memif_rdata_stage4),   // Read data                        | To wbTop module
        .src_sel_out(src_sel_stage4),   // Desitnation selector                     | To wbTop module

        .df_mem_enable(df_mem_enable),  // Forwarded data to handle data hazards    | To idTop module
        .df_mem_reg(df_mem_reg),        // Forwarded data to handle data hazards    | To idTop module
        .df_mem_data(df_mem_data),      // Forwarded data to handle data hazards    | To idTop module

        .memif_addr(memif_addr_stage4),     // Address                              | To syncDualPortRam modue
        .memif_we(memif_we_stage4),         // Write enable                         | To syncDualPortRam modue
        .memif_be(memif_be_stage4),         // Bank enable                          | To syncDualPortRam modue
        .memif_wdata(rs2_data_me_stage4),   // Data                                 | To syncDualPortRam modue

        .io_addr(io_addr_stage4),           // Address                              | To ioTop module
        .io_we(io_we_stage4),               // Write enable                         | To ioTop module
        .io_wdata(rs2_data_io_stage4)       // Data                                 | To ioTop module
    );

    rv32i_wbTop wbTopinstance(          // Instantiate WriteBack stage
        .clk(clk),                      // Clock
        .reset(reset),                  // Reset

        .pc_in(pc_stage4),              // Current Program Counter                  | From memTop module
        .iw_in(iw_stage4),              // Current Instruction Word                 | From memTop module
        .wb_en_in(wb_en_stage4),        // Writeback enable/disable                 | From memTop module
        .src_sel_in(src_sel_stage4),    // Data source selector                     | From memTop module
        .memif_rdata(memif_rdata_stage4),   // Read data                            | From memTop module
        .io_rdata(io_rdata),            // Read data                                | From ioTop module
        .wb_reg_in(wb_reg_stage4),      // Destination Register                     | From idTop module
        .alu_in(alu_out_stage4),        // Calculated output                        | From exTop module

        .wb_data(alu_out_stage5),       // Writeback data                           | To regFsTop module
        .wb_reg_out(wb_reg_stage5),     // Destination Register                     | To regFsTop module
        .wb_en_out(wb_en_stage5),       // Writeback enable/disbale                 | To regFsTop module

        .df_wb_enable(df_wb_enable),    // Forwarded data to handle data hazards    | To idTop module
        .df_wb_reg(df_wb_reg),          // Forwarded data to handle data hazards    | To idTop module
        .df_wb_data(df_wb_data)         // Forwarded data to handle data hazards    | To idTop module
    );

endmodule