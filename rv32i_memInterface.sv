/*
    Function to generate a value for w_be (write_bank_enable)
    The w_be depends on the alu_out and width signals generated independently in the code
*/
function logic [3:0] writeBankEnable(
        input logic [1:0] bank,              // Address input
        input logic [1:0] w                  // Width input
    );

    // Calculate the bank enable signal
    case (w)
        2'b00:
        begin
            case(bank)
                2'b00:   writeBankEnable = 4'b0001;     // 8-bit write, enable first bank
                2'b01:   writeBankEnable = 4'b0010;     // 8-bit write, enable second bank
                2'b10:   writeBankEnable = 4'b0100;     // 8-bit write, enable third bank
                2'b11:   writeBankEnable = 4'b1000;     // 8-bit write, enable fourth bank
                default: writeBankEnable = 4'b0000;     // Enable no banks
            endcase
        end

        2'b01:
        begin
            case (bank)
                2'b00:   writeBankEnable = 4'b0011;     // 16-bit write, enable first bank
                2'b01:   writeBankEnable = 4'b0110;     // 16-bit write, enable second bank
                2'b10:   writeBankEnable = 4'b1100;     // 16-bit write, enable third bank
                default: writeBankEnable = 4'b0000;     // Enable no banks
            endcase
        end

        2'b10:           writeBankEnable = 4'b1111;     // 32-bit write, enable first bank

        default:         writeBankEnable = 4'b1111;     // 32-bit write, enable fourth bank
    endcase

    return writeBankEnable;                             // Return the byte enable signals
endfunction

/*
    Function to shift rs2_data based on the address (alu_out).
    This ensure that the data bits are on the correct data bus lines
*/
function logic [31:0] shifted_data(
        input logic [31:0] rs2_data,
        input logic [1:0] bank
    );
    case (bank)
        2'b00:  shifted_data = rs2_data << 0;           // No shift required
        2'b01:  shifted_data = rs2_data << 8;           // Shift by 8 bits
        2'b10:  shifted_data = rs2_data << 16;          // Shift by 16 bits
        2'b11:  shifted_data = rs2_data << 24;          // Shift by 24 bits
    endcase

    return shifted_data;
endfunction

/*
    Function to convert output of memory (d_rdata) to a 32-bit
*/
function logic [31:0] shifted_d_rdata(
        input logic [31:0] d_rdata,
        input logic [1:0] bank,
        input logic [1:0] w,
        input logic sign
    );

    logic [31:0] temp;                      // To temporarily store right shifted values

    case (bank)                             // Address determines the shift value
        2'b00:      temp = d_rdata >> 00;
        2'b01:      temp = d_rdata >> 08;
        2'b10:      temp = d_rdata >> 16;
        2'b11:      temp = d_rdata >> 24;
        default:    temp = d_rdata;
    endcase

    if (sign)                               // Sign-extend the number only if the sign flag is set
    begin
        case (w)                            // Width determines the number of bits to sign-extend
            2'b00:      shifted_d_rdata = {{24{temp[07]}}, temp[07:00]};
            2'b01:      shifted_d_rdata = {{16{temp[15]}}, temp[15:00]};
            2'b10:      shifted_d_rdata = {{08{temp[24]}}, temp[24:00]};
            default:    shifted_d_rdata = temp;
        endcase
    end

    else                                    // Pad zeros (0) in case the sign flag is unset
    begin
        case (w)                            // Width determines the number of bits to pad
            2'b00:      shifted_d_rdata = {24'b0, temp[07:00]};
            2'b01:      shifted_d_rdata = {16'b0, temp[15:00]};
            2'b10:      shifted_d_rdata = {08'b0, temp[24:00]};
            default:    shifted_d_rdata = temp;
        endcase
    end

    return shifted_d_rdata;
endfunction
