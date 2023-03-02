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
    rv32i_memInterfaceTest memInterfaceTest (.clk(ADC_CLK_10), .KEY(KEY));  // To test memory interface module

endmodule
