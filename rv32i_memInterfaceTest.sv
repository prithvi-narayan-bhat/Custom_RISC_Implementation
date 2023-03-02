module rv32i_memInterfaceTest(
        input clk,
        input [1:0] KEY,
        output [31:0] func_return
    );

    `include "rv32i_memInterface.sv"                    // Include files

    wire [31:0] rs2_data, d_rdata, alu_out;             // 32 bit values
    wire [3:0] d_be;                                    // 04 bit values
    wire [1:0] width, bank;                             // 02 bit values
    wire sign, w_enable, d_we;                          // 01 bit values

    int counter = -1;

    always_ff @ (posedge KEY[1])                        // Trigger on posedge of Key press
    begin
        if (counter > 6)     counter = -1;    // Reset counter

        counter++;                                 // Increment counter value

        case (counter)
            32'd0:
            begin
                d_we        = 1'b1;             // Write enabled
                sign        = 1'b0;             // Signed data
                width       = 1'b0;             // Size: Byte
                alu_out     = 32'h50;           // Address
                rs2_data    = 32'h80;           // Test data

            end

            32'd1:
            begin
                d_we        = 1'b0;             // Write disabled
                sign        = 1'b0;             // Signed data
                width       = 2'd1;             // Size: Byte
                alu_out     = 32'h50;           // Address
                rs2_data    = 32'h100;          // Test data
            end

            32'd2:
            begin
                d_we        = 1'b1;             // Write enabled
                sign        = 1'b0;             // Signed data
                width       = 2'd0;             // Size: Byte
                alu_out     = 32'h51;           // Address
                rs2_data    = 32'h1191;         // Test data
            end

            32'd3:
            begin
                d_we        = 1'b0;             // Write disabled
                sign        = 1'b0;             // Signed data
                width       = 2'd1;             // Size: Byte
                alu_out     = 32'h51;           // Address
                rs2_data    = 32'h200;          // Test data
            end

            32'd4:
            begin
                d_we        = 1'b1;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'hC;            // Address
                rs2_data    = 32'h12345678;     // Test data
            end

            32'd5:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end

            32'd6:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end

            32'd7:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end

            32'd8:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end

            32'd9:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end

            32'd10:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end

            32'd11:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end

            32'd12:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Address
                rs2_data    = 32'h300;          // Test data
            end
        endcase
    end

    // To test dual port RAM module
    rv32i_syncDualPortRam ramTest(
        .clk(ADC_CLK_10),
        .i_addr(alu_out),
        .d_addr(alu_out),
        .d_we(d_we),
        .d_be(writeBankEnable(alu_out, width)),
        .d_wdata(shifted_rs2_data(rs2_data, alu_out)),
        .d_rdata(d_rdata)
    );

    assign func_return = shifted_d_rdata(d_rdata, alu_out, width, sign);
endmodule