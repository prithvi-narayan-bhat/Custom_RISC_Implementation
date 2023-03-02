/*
    Top code to test all other modules
*/

module cri(
        input ADC_CLK_10,
        input [1:0] KEY,
        input [9:0] SW,
        output [31:0] func_return
    );

    // rv32i_memTest memTest (.clk(ADC_CLK_10), .KEY(KEY), .SW(SW));         // To test memory module
    // rv32i_exTest exTest (.clk(ADC_CLK_10), .KEY(KEY), .SW(SW));           // To test ALU module

    // Parameters to be passsed to the RAM module
    // wire [31:0] alu_out;                // alu output from ALU stage

    wire d_we;                          // Write enable
    wire [31:0] d_wdata, rs2_data, d_rdata, alu_out;
    wire [1:0] width, w_be;
    wire sign, w_enable;
    wire [1:0] bank;     // Extract last two bits of alu_out
    int inst_counter = -1;
    int data_counter = 511;

    /*
        Function to generate a value for w_be (write_bank_enable)
        The w_be depends on the alu_out and width signals generated independently in the code
    */
    function logic [3:0] writeBankEnable(
            input logic [1:0] bank,              // Address input
            input logic [1:0] w                     // Width input
        );

        // Calculate the bank enable signal
        case (w)
            2'b00:
            begin
                case(bank)
                    2'b00:  writeBankEnable = 4'b0001;     // 8-bit write, enable first bank
                    2'b01:  writeBankEnable = 4'b0010;     // 8-bit write, enable second bank
                    2'b10:  writeBankEnable = 4'b0100;     // 8-bit write, enable third bank
                    2'b11:  writeBankEnable = 4'b1000;     // 8-bit write, enable fourth bank
                    default: writeBankEnable = 4'b0000;    // Enable no banks
                endcase
            end

            2'b01:
            begin
                case (bank)
                    2'b00:  writeBankEnable = 4'b0011;     // 16-bit write, enable first bank
                    2'b01:  writeBankEnable = 4'b0110;     // 16-bit write, enable second bank
                    2'b10:  writeBankEnable = 4'b1100;     // 16-bit write, enable third bank
                    default: writeBankEnable = 4'b0000;    // Enable no banks
                endcase
            end

            2'b10:  writeBankEnable = 4'b1111;     // 32-bit write, enable first bank
            // begin
            //     case (bank)
            //         2'b00:  writeBankEnable = 4'b1111;     // 16-bit write, enable first bank
            //         2'b01:  writeBankEnable = 4'b1110;     // 16-bit write, enable second bank
            //         2'b10:  writeBankEnable = 4'b1100;     // 16-bit write, enable third bank
            //         default: writeBankEnable = 4'b1000;    // Enable no banks
            //     endcase
            // end

            default:        writeBankEnable = 4'b1111;     // 32-bit write, enable fourth bank
        endcase

        return writeBankEnable;                            // Return the byte enable signals
    endfunction

    /*
        Function to shift rs2_data based on the address (alu_out).
        This ensure that the data bits are on the correct data bus lines
    */
    function logic [31:0] shifted_rs2_data(
            input logic [31:0] rs2_data,
            input logic [1:0] bank
        );
        case (bank)
            2'b00:  shifted_rs2_data = rs2_data << 0;   // No shift required
            2'b01:  shifted_rs2_data = rs2_data << 8;   // Shift by 8 bits
            2'b10:  shifted_rs2_data = rs2_data << 16;  // Shift by 16 bits
            2'b11:  shifted_rs2_data = rs2_data << 24;  // Shift by 24 bits
        endcase

        return shifted_rs2_data;
    endfunction

    /*
        Function to convert output of memory (d_rdata) to a 32-bit
    */
    function logic [31:0] shifted_d_rdata(
            input logic [31:0] d_rdata,
            input logic [1:0] bank,
            input logic [1:0] w,
            input logic sign
        );

        logic [31:0] temp;

        case (bank)
            2'b00:      temp = d_rdata >> 00;
            2'b01:      temp = d_rdata >> 08;
            2'b10:      temp = d_rdata >> 16;
            2'b11:      temp = d_rdata >> 24;
            default:    temp = d_rdata;
        endcase

        case (w)
            2'b00:      shifted_d_rdata = {{24{temp[07]}}, temp[07:00]};
            2'b01:      shifted_d_rdata = {{16{temp[15]}}, temp[15:0]};
            2'b10:      shifted_d_rdata = {{08{temp[24]}}, temp[24:0]};
            default:    shifted_d_rdata = temp;
        endcase

        return shifted_d_rdata;
    endfunction

    always_ff @ (posedge KEY[1])                // Trigger on posedge of Key press
    begin
        if (inst_counter > 6)     inst_counter = -1;       // Reset counter at 5

        inst_counter++;                         // Increment counter value

        case (inst_counter)
            32'd0:
            begin
                d_we        = 1'b1;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 1'b0;             // Size: Word
                alu_out     = 32'h50;           // Word Data (depends on width)
                rs2_data    = 32'h80;           // Test data

            end

            32'd1:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd1;             // Size: Half Word
                alu_out     = 32'h50;           // Word Data (depends on width)
                rs2_data    = 32'h100;          // Test data
            end

            32'd2:
            begin
                d_we        = 1'b1;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd0;             // Size: Byte
                alu_out     = 32'h51;           // Word Data (depends on width)
                rs2_data    = 32'h1191;         // Test data
            end

            32'd3:
            begin
                d_we        = 1'b1;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd1;             // Size: Half Word
                alu_out     = 32'h51;           // Word Data (depends on width)
                rs2_data    = 32'h200;          // Test data
            end

            32'd4:
            begin
                d_we        = 1'b1;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'hC;           // Word Data (depends on width)
                rs2_data    = 32'h12345678;     // Test data
            end

            32'd5:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end

            32'd6:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end

            32'd7:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end

            32'd8:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end

            32'd9:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end

            32'd10:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end

            32'd11:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end

            32'd12:
            begin
                d_we        = 1'b0;             // Write enabled (1 bit)
                sign        = 1'b0;             // Signed data
                width       = 2'd2;             // Size: Word
                alu_out     = 32'h52;           // Word Data (depends on width)
                rs2_data    = 32'h300;          // Test data
            end
        endcase
    end

    assign w_be = writeBankEnable(alu_out, width);

    // To test dual port RAM module
    rv32i_syncDualPortRam ramTest(
        .clk(ADC_CLK_10),
        .i_addr(alu_out),
        .d_addr(alu_out),
        .d_we(d_we),
        .d_be(w_be),
        .d_wdata(shifted_rs2_data(rs2_data, alu_out)),
        .d_rdata(d_rdata)
    );

    assign func_return = shifted_d_rdata(d_rdata, alu_out, width, sign);

endmodule
