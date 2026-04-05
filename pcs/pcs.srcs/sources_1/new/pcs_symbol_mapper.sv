module pcs_symbol_mapper
import pcs_types_pkg::*;
(
    input  logic [8:0] sdn,
    
    // Control Flags (Generated from PCS Transmit FSM and tx_enable pipelines)
    input  logic       is_xmt_err,
    input logic        is_csextend_err,
    input logic        is_csextend,
    input  logic       is_csreset,
    input  logic       is_ssd1,
    input  logic       is_ssd2,
    input logic        is_esd1,
    input logic        is_esd2_ext_0,
    input logic        is_esd2_ext_1,
    input logic        is_esd2_ext_2,
    input logic        is_esd2_ext_err,
    input logic        is_idle,
    input logic        is_carrier_extension,
    
    output symb_4d_t   t_symb // Contains TA, TB, TC, TD
);

    always_comb begin
        // Default assignment to avoid latches
        t_symb.A = 0; t_symb.B = 0; t_symb.C = 0; t_symb.D = 0;

        // Control Symbol Overrides (Highest Priority)
        if (is_xmt_err) begin // xmt_err
            case (sdn[6:8])
                3'b000: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = +2; t_symb.D = 0; end	
                3'b010: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = +2; end	
                3'b100: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +2; end	
                3'b110: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = +2; t_symb.D = +1; end

                3'b001: begin t_symb.A = +2;  t_symb.B = +2; t_symb.C = 0; t_symb.D = +1; end	
                3'b011: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = +1; t_symb.D = +2; end	
                3'b101: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = +2; t_symb.D = 0; end	
                3'b111: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = +2; t_symb.D = 0; end

            endcase
        end
        else if (is_csextend_err) begin // CSExtend_Err
            case (sdn[6:8])
                3'b000: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = +2; t_symb.D = -2; end
                3'b010: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = +2; end	
                3'b100: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +2; end	
                3'b110: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -1; end
                
                3'b001: begin t_symb.A = +2;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -1; end	
                3'b011: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -1; t_symb.D = +2; end	
                3'b101: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = +2; t_symb.D = -2; end	
                3'b111: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -2; end

            endcase
        end
        else if (is_csextend) begin // CSExtend
            case (sdn[6:8])
                3'b000: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +2; end	
                3'b010: begin t_symb.A = +2;  t_symb.B = +2; t_symb.C = +1; t_symb.D = +1; end	
                3'b100: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = +2; t_symb.D = +1; end	
                3'b110: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = +2; end
                
                3'b001: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = +2; t_symb.D = +1; end	
                3'b011: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +2; end	
                3'b101: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = +2; end	
                3'b111: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +2; end
            endcase
        end
        else if(is_csreset) begin // CSReset
            case (sdn[6:8])
                3'b000: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +2; end
                3'b010: begin t_symb.A = +2;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -1; end
                3'b100: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = +2; t_symb.D = -1; end
                3'b110: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = +2; end

                3'b001: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -1; end	
                3'b011: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +2; end	
                3'b101: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = +2; end	
                3'b111: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +2; end
            endcase
        end        
        else if (is_ssd1) begin // SSD1
            t_symb.A = +2; t_symb.B = +2; t_symb.C = +2; t_symb.D = +2;
        end
        else if (is_ssd2) begin // SSD2
            t_symb.A = +2; t_symb.B = +2; t_symb.C = +2; t_symb.D = -2;
        end
        else if (is_esd1) begin // ESD1
            t_symb.A = +2;  t_symb.B = +2; t_symb.C = +2; t_symb.D = +2;
        end
        else if (is_esd2_ext_0) begin // ESD2_Ext_0
            t_symb.A = +2;  t_symb.B = +2; t_symb.C = +2; t_symb.D = -2;
        end
        else if (is_esd2_ext_1) begin // ESD2_Ext_1
            t_symb.A = +2;  t_symb.B = +2; t_symb.C = -2; t_symb.D = +2;
        end
        else if (is_esd2_ext_2) begin // ESD2_Ext_2
            t_symb.A = +2;  t_symb.B = -2; t_symb.C = +2; t_symb.D = +2;
        end
        else if (is_esd2_ext_err) begin // ESD2_Ext_Err
            t_symb.A = -2;  t_symb.B = +2; t_symb.C = +2; t_symb.D = +2;
        end
        
        // 2. Normal Data Mapping (Fallback)
        else begin // first split by Sd_n[6:8]
            case (sdn[6:8])
                3'b000: begin // then decode Sd_n[5:0]
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = 0; t_symb.D = 0; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = 0; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = 0; t_symb.D = 0; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = 0; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -2; t_symb.D = 0; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = 0; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -2; t_symb.D = 0; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = 0; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -2; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -2; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -2; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -2; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -2; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -2; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -2; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -2; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +1; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +1; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +1; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +1; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +1; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +1; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +1; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +1; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -1; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -1; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -1; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -1; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -1; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -1; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -1; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -1; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = 0; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = 0; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = 0; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = 0; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -2; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -2; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -2; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -2; end
                        6'b101000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +2; t_symb.D = 0; end
                        6'b101001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +2; t_symb.D = 0; end
                        6'b101010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +2; t_symb.D = 0; end
                        6'b101011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +2; t_symb.D = 0; end
                        6'b101100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -2; end
                        6'b101101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -2; end
                        6'b101110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -2; end
                        6'b101111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -2; end
                        6'b110000: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = 0; t_symb.D = 0; end
                        6'b110001: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = 0; t_symb.D = 0; end
                        6'b110010: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -2; t_symb.D = 0; end
                        6'b110011: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -2; t_symb.D = 0; end
                        6'b110100: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -2; end
                        6'b110101: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -2; end
                        6'b110110: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -2; end
                        6'b110111: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -2; end
                        6'b111000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +2; end
                    endcase
                end
                
                3'b010: begin
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +1; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +1; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +1; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +1; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +1; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +1; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +1; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +1; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -1; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -1; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -1; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -1; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -1; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -1; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -1; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -1; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = 0; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = 0; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = 0; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = 0; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = 0; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = 0; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = 0; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = 0; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -2; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -2; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -2; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -2; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -2; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -2; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -2; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -2; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +1; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +1; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +1; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +1; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -1; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -1; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -1; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -1; end
                        6'b101000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -2; end
                        6'b101101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -2; end
                        6'b101110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -2; end
                        6'b101111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -2; end
                        6'b110000: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = +1; t_symb.D = +1; end
                        6'b110001: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = +1; t_symb.D = +1; end
                        6'b110010: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -1; t_symb.D = +1; end
                        6'b110011: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -1; t_symb.D = +1; end
                        6'b110100: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -1; end
                        6'b110101: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -1; end
                        6'b110110: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -1; end
                        6'b110111: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -1; end
                        6'b111000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +2; end

                    endcase
                end
                
                3'b100: begin
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +1; t_symb.D = 0; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = 0; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +1; t_symb.D = 0; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = 0; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -1; t_symb.D = 0; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = 0; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -1; t_symb.D = 0; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = 0; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -2; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -2; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -2; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -2; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -2; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -2; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -2; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -2; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +1; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +1; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +1; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +1; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +1; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +1; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +1; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +1; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -1; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -1; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -1; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -1; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -1; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -1; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -1; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -1; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = 0; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = 0; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = 0; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = 0; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -2; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -2; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -2; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -2; end
                        6'b101000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = +1; end
                        6'b101001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = +1; end
                        6'b101010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = +1; end
                        6'b101011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = +1; end
                        6'b101100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -1; end
                        6'b101101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -1; end
                        6'b101110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -1; end
                        6'b101111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -1; end
                        6'b110000: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = +1; end
                        6'b110001: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = +1; end
                        6'b110010: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = +1; end
                        6'b110011: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = +1; end
                        6'b110100: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -1; end
                        6'b110101: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -1; end
                        6'b110110: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -1; end
                        6'b110111: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -1; end
                        6'b111000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +2; end
                        
                    endcase
                end
                
                3'b110: begin
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +1; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +1; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +1; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +1; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +1; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +1; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +1; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +1; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -1; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -1; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -1; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -1; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -1; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -1; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -1; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -1; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = 0; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = 0; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = 0; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = 0; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = 0; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = 0; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = 0; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = 0; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -2; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -2; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -2; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -2; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -2; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -2; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -2; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -2; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +1; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +1; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +1; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +1; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -1; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -1; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -1; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -1; end
                        6'b101000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -1; end
                        6'b101101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -1; end
                        6'b101110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -1; end
                        6'b101111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -1; end
                        6'b110000: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = 0; end
                        6'b110001: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = 0; end
                        6'b110010: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = 0; end
                        6'b110011: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = 0; end
                        6'b110100: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -2; end
                        6'b110101: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -2; end
                        6'b110110: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -2; end
                        6'b110111: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -2; end
                        6'b111000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +2; end

                    endcase
                end 
                
                3'b001: begin
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +1; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +1; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +1; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +1; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +1; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +1; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +1; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +1; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -1; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -1; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -1; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -1; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -1; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -1; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -1; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -1; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = 0; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = 0; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = 0; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = 0; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = 0; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = 0; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = 0; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = 0; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -2; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -2; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -2; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -2; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -2; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -2; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -2; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -2; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +1; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +1; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +1; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +1; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -1; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -1; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -1; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -1; end
                        6'b101000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +2; t_symb.D = +1; end
                        6'b101001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +2; t_symb.D = +1; end
                        6'b101010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +2; t_symb.D = +1; end
                        6'b101011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +2; t_symb.D = +1; end
                        6'b101100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -1; end
                        6'b101101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -1; end
                        6'b101110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -1; end
                        6'b101111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -1; end
                        6'b110000: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = 0; t_symb.D = +1; end
                        6'b110001: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = 0; t_symb.D = +1; end
                        6'b110010: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -2; t_symb.D = +1; end
                        6'b110011: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -2; t_symb.D = +1; end
                        6'b110100: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -1; end
                        6'b110101: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -1; end
                        6'b110110: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -1; end
                        6'b110111: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -1; end
                        6'b111000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +2; end

                    endcase
                end
                
                3'b011: begin
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +1; t_symb.D = 0; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = 0; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +1; t_symb.D = 0; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = 0; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -1; t_symb.D = 0; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = 0; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -1; t_symb.D = 0; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = 0; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -2; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -2; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -2; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -2; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -2; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -2; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -2; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -2; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +1; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +1; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +1; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +1; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +1; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +1; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +1; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +1; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -1; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -1; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -1; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -1; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -1; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -1; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -1; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -1; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = 0; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = 0; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = 0; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = 0; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -2; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -2; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -2; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -2; end
                        6'b101000: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101001: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101010: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101011: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = +1; end
                        6'b101100: begin t_symb.A = +1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -1; end
                        6'b101101: begin t_symb.A = -1;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -1; end
                        6'b101110: begin t_symb.A = +1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -1; end
                        6'b101111: begin t_symb.A = -1;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -1; end
                        6'b110000: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = +1; t_symb.D = 0; end
                        6'b110001: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = +1; t_symb.D = 0; end
                        6'b110010: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -1; t_symb.D = 0; end
                        6'b110011: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -1; t_symb.D = 0; end
                        6'b110100: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -2; end
                        6'b110101: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -2; end
                        6'b110110: begin t_symb.A = 0;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -2; end
                        6'b110111: begin t_symb.A = -2;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -2; end
                        6'b111000: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = 0;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -2;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = 0;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -2;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +2; end

                    endcase
                end
                
                3'b101: begin
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +1; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +1; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +1; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +1; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +1; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +1; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +1; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +1; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -1; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -1; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -1; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -1; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -1; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -1; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -1; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -1; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = 0; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = 0; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = 0; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = 0; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = 0; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = 0; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = 0; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = 0; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -2; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = -2; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -2; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = -2; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -2; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = -2; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -2; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = -2; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = +1; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = +1; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = +1; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = +1; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = +1; t_symb.D = -1; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = +1; t_symb.D = -1; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -1; t_symb.D = -1; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -1; t_symb.D = -1; end
                        6'b101000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = 0; end
                        6'b101001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = 0; end
                        6'b101010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = 0; end
                        6'b101011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = 0; end
                        6'b101100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -2; end
                        6'b101101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +2; t_symb.D = -2; end
                        6'b101110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -2; end
                        6'b101111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +2; t_symb.D = -2; end
                        6'b110000: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = 0; end
                        6'b110001: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = 0; end
                        6'b110010: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = 0; end
                        6'b110011: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = 0; end
                        6'b110100: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -2; end
                        6'b110101: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = 0; t_symb.D = -2; end
                        6'b110110: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -2; end
                        6'b110111: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -2; t_symb.D = -2; end
                        6'b111000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = 0; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = 0; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -2; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -2; t_symb.D = +2; end

                    endcase
                end
                
                3'b111: begin
                    case (sdn[5:0])
                        6'b000000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = 0; t_symb.D = 0; end
                        6'b000001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = 0; end
                        6'b000010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = 0; t_symb.D = 0; end
                        6'b000011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = 0; end
                        6'b000100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -2; t_symb.D = 0; end
                        6'b000101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = 0; end
                        6'b000110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -2; t_symb.D = 0; end
                        6'b000111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = 0; end
                        6'b001000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -2; end
                        6'b001001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -2; end
                        6'b001010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -2; end
                        6'b001011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -2; end
                        6'b001100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -2; end
                        6'b001101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -2; end
                        6'b001110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -2; end
                        6'b001111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -2; end
                        6'b010000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +1; end
                        6'b010001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = +1; end
                        6'b010010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +1; end
                        6'b010011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = +1; end
                        6'b010100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +1; end
                        6'b010101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = +1; end
                        6'b010110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +1; end
                        6'b010111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = +1; end
                        6'b011000: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -1; end
                        6'b011001: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = +1; t_symb.D = -1; end
                        6'b011010: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -1; end
                        6'b011011: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = +1; t_symb.D = -1; end
                        6'b011100: begin t_symb.A = +1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -1; end
                        6'b011101: begin t_symb.A = -1;  t_symb.B = 0; t_symb.C = -1; t_symb.D = -1; end
                        6'b011110: begin t_symb.A = +1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -1; end
                        6'b011111: begin t_symb.A = -1;  t_symb.B = -2; t_symb.C = -1; t_symb.D = -1; end
                        6'b100000: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = 0; end
                        6'b100001: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = 0; end
                        6'b100010: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = 0; end
                        6'b100011: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = 0; end
                        6'b100100: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = -2; end
                        6'b100101: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = -2; end
                        6'b100110: begin t_symb.A = +2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = -2; end
                        6'b100111: begin t_symb.A = +2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = -2; end
                        6'b101000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +2; t_symb.D = 0; end
                        6'b101100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -2; end
                        6'b101101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = +2; t_symb.D = -2; end
                        6'b101110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -2; end
                        6'b101111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = +2; t_symb.D = -2; end
                        6'b110000: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = +1; end
                        6'b110001: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = +1; end
                        6'b110010: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = +1; end
                        6'b110011: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = +1; end
                        6'b110100: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -1; end
                        6'b110101: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = +1; t_symb.D = -1; end
                        6'b110110: begin t_symb.A = +1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -1; end
                        6'b110111: begin t_symb.A = -1;  t_symb.B = +2; t_symb.C = -1; t_symb.D = -1; end
                        6'b111000: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111001: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111010: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111011: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = 0; t_symb.D = +2; end
                        6'b111100: begin t_symb.A = 0;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +2; end
                        6'b111101: begin t_symb.A = -2;  t_symb.B = +1; t_symb.C = -2; t_symb.D = +2; end
                        6'b111110: begin t_symb.A = 0;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +2; end
                        6'b111111: begin t_symb.A = -2;  t_symb.B = -1; t_symb.C = -2; t_symb.D = +2; end

                    endcase
                end
               
            endcase
        end
    end
endmodule