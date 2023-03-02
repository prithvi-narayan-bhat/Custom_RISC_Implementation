/*
    @module rv32i_reg: The crux of Register management
    @param clk          Input   clock signal
    @param reset        Input   reset signal
    @param wb_enable    Input   Writeback enable
    @param wb_reg       Input   Register to write into
    @param rs1_reg      Input   Register adddress 1
    @param rs2_reg      Input   Register adddress 2
    @param wb_data      Input   Data to write into register specified by wb_reg
    @param rs1_data     Output  output the data in register1
    @param rs2_data     Output  output the data in register2
*/
module rv32i_reg(
        input reset, clk, wb_enable,                // System clock and reset
        input [4:0] rs1_reg, rs2_reg, wb_reg,       // Register addresses
        input [31:0] wb_data,                       // Writeback enable
        output reg [31:0] rs1_data, rs2_data        // Outputs
    );

    /*
        Register Heirarchy
            zero:   hardwired zero
            ra:     return address
            sp:     stack pointer
            gp:     global pointer
            tp:     thread pointer
            t0:     Temporary/alternate link register
            t1–t2:  Temporaries
            s0/fp:  Saved register/frame pointer
            s1:     Saved register
            a0–a1:  Function arguments/return values
            a2–a7:  Function arguments
            s2–s11: Saved registers
            t3–t6:  Temporaries
    */
    logic [31:0] register [32];                     // How registers are handled internally (saves a few lines of code)

    always_ff @ (posedge clk)
    begin
        if (reset)                                  // Set all registers to zero on reset button press
        begin
           for (int i = 1; i < 32; i++)
           begin
                register[i] = 0;
           end
        end

        // Write
        else if (wb_enable == 1)                            // Write only if the wb_enable bit is set
        begin
            if (wb_reg > 5'b0)  register[wb_reg] = wb_data; // Store data in all other registers
        end
    end


    assign rs1_data = register[rs1_reg];  // Asynchronuously output rs1_data associated with contents of register rs1_reg
    assign rs2_data = register[rs2_reg];  // Asynchronuously output rs2_data associated with contents of register rs2_reg

endmodule