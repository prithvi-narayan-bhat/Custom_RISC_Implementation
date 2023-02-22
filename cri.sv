/*
    Top code to test all other modules
*/

module cri(
        input ADC_CLK_10,
        input [1:0] KEY,
        input [9:0] SW
    );

    // rv32i_memTest test (.clk(ADC_CLK_10), .KEY(KEY), .SW(SW));       // Uncomment to test memory module
    rv32i_exTest test (.clk(ADC_CLK_10), .KEY(KEY), .SW(SW));           // Uncomment to test ALU module
endmodule