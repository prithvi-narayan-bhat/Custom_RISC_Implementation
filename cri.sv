/*
    Top code to test all other modules
*/

module cri(
        input ADC_CLK_10,
        input [1:0] KEY,
        input [9:0] SW,
        output reg [31:0] rs1_data_out, rs2_data_out
    );

    wire wb_enable;
    wire [4:0] wb_reg;
    wire [4:0] rs1_reg, rs2_reg;
    wire [31:0] wb_data, rs1_data, rs2_data;
    wire reset;

    always_ff @ (posedge ADC_CLK_10)
    begin
        reset <= !KEY[1];
    end

    always_ff @ (SW)
    begin
        case (SW[4:0])
            5'd0:
            begin
                wb_data = 32'h25;
                wb_enable = 1;
                wb_reg = 5'd10;
                rs1_reg = 5'd10;
                rs2_reg = 5'd15;
            end
            5'd1:
            begin
                wb_data = 32'h20;
                wb_enable = 1;
                wb_reg = 5'd5;
                rs1_reg = 5'd2;
                rs2_reg = 5'd0;
            end
            5'd2:
            begin
                wb_data = 32'd321;
                wb_enable = 1;
                wb_reg = 5'd0;
                rs1_reg = 5'd0;
                rs2_reg = 5'd10;
            end
            5'd3:
            begin
                wb_data = 32'd321;
                wb_enable = 0;
                wb_reg = 5'd0;
                rs1_reg = 5'd0;
                rs2_reg = 5'd10;
            end
        endcase
    end

    rv32i_reg testBench (
        .reset(reset),
        .clk(ADC_CLK_10),
        .wb_enable(wb_enable),
        .rs1_reg(rs1_reg),
        .rs2_reg(rs2_reg),
        .wb_reg(wb_reg),
        .wb_data(wb_data),
        .rs1_data(rs1_data_out),
        .rs2_data(rs2_data_out),
    );
endmodule
