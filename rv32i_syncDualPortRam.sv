/*
    Module to convert the endianess during reads and writes
        The Intel hex file is used to initialize the M9K ram modules
        Quartis interprets the file data as big-endian but RISC-V is a little-endian machine
*/
module rv32i_syncDualPortRam
    #(parameter ADDR_WIDTH=15)
    (
        input clk,                          // Clock
        input [ADDR_WIDTH-1:0] i_addr,      // Instruction port (RO)
        input [ADDR_WIDTH-1:0] d_addr,      // Data port (RW)
        input d_we,
        input [3:0] d_be,
        input [31:0] d_wdata,
        output reg [31:0] i_rdata,
        output reg [31:0] d_rdata
    );

    // Multi-dimensional packed array initialized by bit stream from "ram.hex"
    (* ram_init_file = "ram.hex" *) logic [3:0][7:0] ram[(2**ADDR_WIDTH)-1:0];

    always @ (posedge clk)      // Instruction fetch
    begin
        {i_rdata[7:0],i_rdata[15:8],i_rdata[23:16],i_rdata[31:24]} <= ram[i_addr];
    end

    always @ (posedge clk)      // Data r/w
    begin
        if (d_we)
        begin
            if (d_be[0]) ram[d_addr][3] <= d_wdata[7:0];
            if (d_be[1]) ram[d_addr][2] <= d_wdata[15:8];
            if (d_be[2]) ram[d_addr][1] <= d_wdata[23:16];
            if (d_be[3]) ram[d_addr][0] <= d_wdata[31:24];
        end
        {d_rdata[7:0],d_rdata[15:8],d_rdata[23:16],d_rdata[31:24]} <= ram[d_addr];
    end
endmodule