module rv32i_ifTop(
        input clk, reset,               // System Clock and Snchronous Reset
        input [31:0] memIfData,         // From MemInterface
        output reg [31:2] memIfAddr,    // To MemInterface
        output reg [31:0] iw_out,       // To ID
        output reg [31:0] pc_out        // To ID
    );

    reg [31:0] pc = 32'd0;
    reg [31:00] pc_int;

    // set program counter
    always_ff @ (posedge(clk))
    begin
        if (reset) pc = 32'd0;      // Reset Program Counter
        else
        begin
            pc <= pc + 32'd4;       // Increment Program Counter
            memIfAddr <= pc[31:02]; // PC drives memIfAddr directly
            pc_int = pc;

        end

    end

    always_ff @ (posedge(clk))
    begin
        pc_out <= pc_int;
    end

    assign iw_out = memIfData;      // Instruction Word (memIfData) is registered in the memory module, so it directly drives iw_out

endmodule