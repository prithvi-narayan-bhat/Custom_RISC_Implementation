module rv32i_ioTop
    #(parameter ADDR_WIDTH=15)(
        input clk, reset,               // Clock and reset
        input KEY,                      // KEY press        | From board
        input io_we,                    // Write enable     | From memTop module
        input [ADDR_WIDTH-1:0] io_addr, // Write address    | From memTop module
        input [31:00] io_wdata,         // Write Data       | From memTop module

        output [09:00] led,             // LEDs             | On board
        output reg [31:00] io_rdata     // Read data        | To memTop module
    );

    always @ (posedge clk)
    begin
        if (reset)  led <= 10'b0000000000;
        else if (!reset)
        begin
            if (!io_we && !io_addr[0])      io_rdata <= KEY;
            else if (io_we && io_addr[0])   led <= io_wdata;
            else                            led <= 10'b0000000000;
        end
        else                                io_rdata <= 10'b0000000000;
    end

endmodule