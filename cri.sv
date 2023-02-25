/*
    Top code to test all other modules
*/

module cri(
        input ADC_CLK_10,
        input [1:0] KEY,
        input [9:0] SW
    );

    // rv32i_memTest memTest (.clk(ADC_CLK_10), .KEY(KEY), .SW(SW));         // To test memory module
    // rv32i_exTest exTest (.clk(ADC_CLK_10), .KEY(KEY), .SW(SW));           // To test ALU module

    // Parameters to be passsed to the RAM module
    wire [14:0] i_addr = 14'd3;
    wire [14:0] d_addr = 14'b10;
    wire d_we = 1'b1;
    wire [3:0] d_be = 4'b10;
    wire [31:0] d_wdata = 32'b10;

    rv32i_syncDualPortRam ramTest (.clk(ADC_CLK_10), .i_addr(i_addr), .d_addr(d_addr), .d_we(d_we), .d_be(d_be), .d_wdata(d_wdata));   // To test dual port RAM module
endmodule
