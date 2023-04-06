module rv32i_ifTop(
        input clk, reset,               // System Clock and Snchronous Reset
        input [31:0] memIfData,         // From MemInterface

        input jump_en_in,               // Enable jump          | From idTop module
        input [31:0] jump_addr,         // Address to jump to   | From idTop module

        output reg [31:2] memIfAddr,    // To MemInterface
        output reg [31:0] iw_out,       // To ID
        output reg [31:0] pc_out,       // To ID
        output jump_en_out              // Enable jump          | To idTop module
    );

    reg [31:0] pc = 32'd0;

    wire jump_en_int;

    assign jump_en_int = jump_en_in;

    // set program counter
    always_ff @ (posedge clk)
    begin
        if (reset) pc <= 32'd0;                     // Reset Program Counter
        else
        begin
            if (jump_en_int)    pc <= jump_addr;    // Set Jump destination
            else                pc <= pc + 32'd4;   // Increment Program Counter
        end

        pc_out <= pc;                               // Latch signal to output with a delay

        // This is to ensure a jump is not propagated into two consecutive cycles
        jump_en_out <= jump_en_in;                  // Latch the signal to output as it is
    end

    assign iw_out = memIfData;                      // Instruction Word (memIfData) is registered in the memory module, so it directly drives iw_out
    assign memIfAddr = pc[31:02];                   // PC drives memIfAddr directly


endmodule