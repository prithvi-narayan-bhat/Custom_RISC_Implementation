module rv32i_ioTop
    #(parameter ADDR_WIDTH=15)(
        input clk, reset,               // Clock and reset
        input KEY,                      // KEY press        | From board
        input io_we,                    // Write enable     | From memTop module
        input [ADDR_WIDTH-1:0] io_addr, // Write address    | From memTop module
        input [31:00] io_wdata,         // Write Data       | From memTop module

        output [9:0] LEDR,              // LEDs             | On board
        output [32:00] io_rdata         // Read data        | To memTop module
    );

    always @ (posedge clk)
    begin
        if (!io_we)         io_rdata <= KEY;
        else if (io_we)     LEDR <= io_wdata;
    end

endmodule