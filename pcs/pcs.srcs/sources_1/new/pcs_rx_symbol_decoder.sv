`timescale 1ns / 1ps

module pcs_rx_symbol_decoder
import pcs_types_pkg::*;
(
    input  symb_4d_t   t_symb,     // Un-signed TA, TB, TC, TD
    input  logic [7:0] sc_n,       // Scrambler bits Sc_n[7:0] from RX Descrambler
    
    // Decoded GMII Data (Valid only during DATA state)
    output logic [7:0] rxd,
    
    // Control Symbol Identifiers for the RX FSM
    output logic       is_idle,
    output logic       is_ssd1,
    output logic       is_ssd2,
    output logic       is_csreset,
    output logic       is_csextend,
    output logic       is_esd1,
    output logic       is_esd2_ext_0,
    output logic       is_xmt_err
);

    logic [8:0] sdn_recovered;

    always_comb begin
        // Default outputs
        is_idle       = 1'b0;
        is_ssd1       = 1'b0;
        is_ssd2       = 1'b0;
        is_csreset    = 1'b0;
        is_csextend   = 1'b0;
        is_esd1       = 1'b0;
        is_esd2_ext_0 = 1'b0;
        is_xmt_err    = 1'b0;
        sdn_recovered = 9'b0;

        // 1. Identify Control Symbols directly from the Quartet
        // These match the literal coordinates from Tables 40-1 and 40-2
        if      (t_symb.A ==  2 && t_symb.B ==  2 && t_symb.C ==  2 && t_symb.D ==  2) is_ssd1 = 1'b1; // SSD1 [cite: 283]
        else if (t_symb.A ==  2 && t_symb.B ==  2 && t_symb.C ==  2 && t_symb.D == -2) is_ssd2 = 1'b1; // SSD2 [cite: 283]
        else if (t_symb.A ==  2 && t_symb.B == -2 && t_symb.C == -2 && t_symb.D ==  2) is_csreset = 1'b1; // CSReset [cite: 283]
        // Note: ESD1 and SSD1 share the same symbol (+2,+2,+2,+2). The RX FSM differentiates them by state context.
        else if (t_symb.A ==  0 && t_symb.B ==  0 && t_symb.C ==  0 && t_symb.D ==  0) is_idle = 1'b1; // Basic IDLE [cite: 283]
        
// 2. Inverse Mapping for Data (Fallback)
        else begin
            case ({t_symb.A, t_symb.B, t_symb.C, t_symb.D})
                
                // --- TABLE 40-1 (EVEN SUBSETS) ---
                
                // Row: Sd_n[5:0] = 000000
				{3'sd0,  3'sd0,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b000000}; // Col [000]
				{3'sd0,  3'sd0,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000000}; // Col [010]
				{3'sd0,  3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000000}; // Col [100]
				{3'sd0,  3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b110, 6'b000000}; // Col [110]
               
                // Row: Sd_n[5:0] = 000001
				{-3'sd2,  3'sd0,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b000001}; // Col [000]
				{-3'sd2,  3'sd0,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000001}; // Col [010]
				{-3'sd2,  3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000001}; // Col [100]
				{-3'sd2,  3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b110, 6'b000001}; // Col [110]
               
                // Row: Sd_n[5:0] = 000010
				{3'sd0,  -3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b000010}; // Col [000]
				{3'sd0,  -3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000010}; // Col [010]
				{3'sd0,  -3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000010}; // Col [100]
				{3'sd0,  -3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b110, 6'b000010}; // Col [110]
               
                // Row: Sd_n[5:0] = 000011
				{-3'sd2,  -3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b000011}; // Col [000]
				{-3'sd2,  -3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000011}; // Col [010]
				{-3'sd2,  -3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000011}; // Col [100]
				{-3'sd2,  -3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b110, 6'b000011}; // Col [110]
               
                // Row: Sd_n[5:0] = 000100
				{3'sd0,  3'sd0,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b000100}; // Col [000]
				{3'sd0,  3'sd0,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000100}; // Col [010]
				{3'sd0,  3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000100}; // Col [100]
				{3'sd0,  3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b000100}; // Col [110]
               
                // Row: Sd_n[5:0] = 000101
				{-3'sd2,  3'sd0,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b000101}; // Col [000]
				{-3'sd2,  3'sd0,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000101}; // Col [010]
				{-3'sd2,  3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000101}; // Col [100]
				{-3'sd2,  3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b000101}; // Col [110]
               
                // Row: Sd_n[5:0] = 000110
				{3'sd0,  -3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b000110}; // Col [000]
				{3'sd0,  -3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000110}; // Col [010]
				{3'sd0,  -3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000110}; // Col [100]
				{3'sd0,  -3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b000110}; // Col [110]
               
                // Row: Sd_n[5:0] = 000111
				{-3'sd2,  -3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b000111}; // Col [000]
				{-3'sd2,  -3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b000111}; // Col [010]
				{-3'sd2,  -3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b000111}; // Col [100]
				{-3'sd2,  -3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b000111}; // Col [110]
               
                // Row: Sd_n[5:0] = 001000
				{3'sd0,  3'sd0,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b001000}; // Col [000]
				{3'sd0,  3'sd0,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001000}; // Col [010]
				{3'sd0,  3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001000}; // Col [100]
				{3'sd0,  3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b110, 6'b001000}; // Col [110]
               
                // Row: Sd_n[5:0] = 001001
				{-3'sd2,  3'sd0,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b001001}; // Col [000]
				{-3'sd2,  3'sd0,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001001}; // Col [010]
				{-3'sd2,  3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001001}; // Col [100]
				{-3'sd2,  3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b110, 6'b001001}; // Col [110]
               
                // Row: Sd_n[5:0] = 001010
				{3'sd0,  -3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b001010}; // Col [000]
				{3'sd0,  -3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001010}; // Col [010]
				{3'sd0,  -3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001010}; // Col [100]
				{3'sd0,  -3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b110, 6'b001010}; // Col [110]
               
                // Row: Sd_n[5:0] = 001011
				{-3'sd2,  -3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b001011}; // Col [000]
				{-3'sd2,  -3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001011}; // Col [010]
				{-3'sd2,  -3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001011}; // Col [100]
				{-3'sd2,  -3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b110, 6'b001011}; // Col [110]
               
                // Row: Sd_n[5:0] = 001100
				{3'sd0,  3'sd0,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b001100}; // Col [000]
				{3'sd0,  3'sd0,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001100}; // Col [010]
				{3'sd0,  3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001100}; // Col [100]
				{3'sd0,  3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b001100}; // Col [110]
               
                // Row: Sd_n[5:0] = 001101
				{-3'sd2,  3'sd0,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b001101}; // Col [000]
				{-3'sd2,  3'sd0,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001101}; // Col [010]
				{-3'sd2,  3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001101}; // Col [100]
				{-3'sd2,  3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b001101}; // Col [110]
               
                // Row: Sd_n[5:0] = 001110
				{3'sd0,  -3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b001110}; // Col [000]
				{3'sd0,  -3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001110}; // Col [010]
				{3'sd0,  -3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001110}; // Col [100]
				{3'sd0,  -3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b001110}; // Col [110]
               
                // Row: Sd_n[5:0] = 001111
				{-3'sd2,  -3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b001111}; // Col [000]
				{-3'sd2,  -3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b001111}; // Col [010]
				{-3'sd2,  -3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b001111}; // Col [100]
				{-3'sd2,  -3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b001111}; // Col [110]
               
                // Row: Sd_n[5:0] = 010000
				{3'sd1,  3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010000}; // Col [000]
				{3'sd1,  3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b010, 6'b010000}; // Col [010]
				{3'sd1,  3'sd0,  3'sd0,  3'sd1} : sdn_recovered = {3'b100, 6'b010000}; // Col [100]
				{3'sd1,  3'sd0,  3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010000}; // Col [110]
               
                // Row: Sd_n[5:0] = 010001
				{-3'sd1,  3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010001}; // Col [000]
				{-3'sd1,  3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b010, 6'b010001}; // Col [010]
				{-3'sd1,  3'sd0,  3'sd0,  3'sd1} : sdn_recovered = {3'b100, 6'b010001}; // Col [100]
				{-3'sd1,  3'sd0,  3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010001}; // Col [110]
               
                // Row: Sd_n[5:0] = 010010
				{3'sd1,  -3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010010}; // Col [000]
				{3'sd1,  -3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b010, 6'b010010}; // Col [010]
				{3'sd1,  -3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b100, 6'b010010}; // Col [100]
				{3'sd1,  -3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010010}; // Col [110]
               
                // Row: Sd_n[5:0] = 010011
				{-3'sd1,  -3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010011}; // Col [000]
				{-3'sd1,  -3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b010, 6'b010011}; // Col [010]
				{-3'sd1,  -3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b100, 6'b010011}; // Col [100]
				{-3'sd1,  -3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010011}; // Col [110]
               
                // Row: Sd_n[5:0] = 010100
				{3'sd1,  3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010100}; // Col [000]
				{3'sd1,  3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b010100}; // Col [010]
				{3'sd1,  3'sd0,  -3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b010100}; // Col [100]
				{3'sd1,  3'sd0,  -3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010100}; // Col [110]
               
                // Row: Sd_n[5:0] = 010101
				{-3'sd1,  3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010101}; // Col [000]
				{-3'sd1,  3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b010101}; // Col [010]
				{-3'sd1,  3'sd0,  -3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b010101}; // Col [100]
				{-3'sd1,  3'sd0,  -3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010101}; // Col [110]
               
                // Row: Sd_n[5:0] = 010110
				{3'sd1,  -3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010110}; // Col [000]
				{3'sd1,  -3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b010110}; // Col [010]
				{3'sd1,  -3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b010110}; // Col [100]
				{3'sd1,  -3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010110}; // Col [110]
               
                // Row: Sd_n[5:0] = 010111
				{-3'sd1,  -3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b000, 6'b010111}; // Col [000]
				{-3'sd1,  -3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b010111}; // Col [010]
				{-3'sd1,  -3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b010111}; // Col [100]
				{-3'sd1,  -3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b010111}; // Col [110]
               
                // Row: Sd_n[5:0] = 011000
				{3'sd1,  3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011000}; // Col [000]
				{3'sd1,  3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b010, 6'b011000}; // Col [010]
				{3'sd1,  3'sd0,  3'sd0,  -3'sd1} : sdn_recovered = {3'b100, 6'b011000}; // Col [100]
				{3'sd1,  3'sd0,  3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011000}; // Col [110]
               
                // Row: Sd_n[5:0] = 011001
				{-3'sd1,  3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011001}; // Col [000]
				{-3'sd1,  3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b010, 6'b011001}; // Col [010]
				{-3'sd1,  3'sd0,  3'sd0,  -3'sd1} : sdn_recovered = {3'b100, 6'b011001}; // Col [100]
				{-3'sd1,  3'sd0,  3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011001}; // Col [110]
               
                // Row: Sd_n[5:0] = 011010
				{3'sd1,  -3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011010}; // Col [000]
				{3'sd1,  -3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b010, 6'b011010}; // Col [010]
				{3'sd1,  -3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b100, 6'b011010}; // Col [100]
				{3'sd1,  -3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011010}; // Col [110]
               
                // Row: Sd_n[5:0] = 011011
				{-3'sd1,  -3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011011}; // Col [000]
				{-3'sd1,  -3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b010, 6'b011011}; // Col [010]
				{-3'sd1,  -3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b100, 6'b011011}; // Col [100]
				{-3'sd1,  -3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011011}; // Col [110]
               
                // Row: Sd_n[5:0] = 011100
				{3'sd1,  3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011100}; // Col [000]
				{3'sd1,  3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b011100}; // Col [010]
				{3'sd1,  3'sd0,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b011100}; // Col [100]
				{3'sd1,  3'sd0,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011100}; // Col [110]
               
                // Row: Sd_n[5:0] = 011101
				{-3'sd1,  3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011101}; // Col [000]
				{-3'sd1,  3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b011101}; // Col [010]
				{-3'sd1,  3'sd0,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b011101}; // Col [100]
				{-3'sd1,  3'sd0,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011101}; // Col [110]
               
                // Row: Sd_n[5:0] = 011110
				{3'sd1,  -3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011110}; // Col [000]
				{3'sd1,  -3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b011110}; // Col [010]
				{3'sd1,  -3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b011110}; // Col [100]
				{3'sd1,  -3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011110}; // Col [110]
               
                // Row: Sd_n[5:0] = 011111
				{-3'sd1,  -3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b000, 6'b011111}; // Col [000]
				{-3'sd1,  -3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b011111}; // Col [010]
				{-3'sd1,  -3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b011111}; // Col [100]
				{-3'sd1,  -3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b011111}; // Col [110]
               
                // Row: Sd_n[5:0] = 100000
				{3'sd2,  3'sd0,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b100000}; // Col [000]
				{3'sd2,  3'sd0,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b100000}; // Col [010]
				{3'sd2,  3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b100000}; // Col [100]
				{3'sd2,  3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b110, 6'b100000}; // Col [110]
               
                // Row: Sd_n[5:0] = 100001
				{3'sd2,  -3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b100001}; // Col [000]
				{3'sd2,  -3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b100001}; // Col [010]
				{3'sd2,  -3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b100001}; // Col [100]
				{3'sd2,  -3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b110, 6'b100001}; // Col [110]
               
                // Row: Sd_n[5:0] = 100010
				{3'sd2,  3'sd0,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b100010}; // Col [000]
				{3'sd2,  3'sd0,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b100010}; // Col [010]
				{3'sd2,  3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b100010}; // Col [100]
				{3'sd2,  3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b100010}; // Col [110]
               
                // Row: Sd_n[5:0] = 100011
				{3'sd2,  -3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b100011}; // Col [000]
				{3'sd2,  -3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b100011}; // Col [010]
				{3'sd2,  -3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b100, 6'b100011}; // Col [100]
				{3'sd2,  -3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b100011}; // Col [110]
               
                // Row: Sd_n[5:0] = 100100
				{3'sd2,  3'sd0,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b100100}; // Col [000]
				{3'sd2,  3'sd0,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b100100}; // Col [010]
				{3'sd2,  3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b100100}; // Col [100]
				{3'sd2,  3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b110, 6'b100100}; // Col [110]
               
                // Row: Sd_n[5:0] = 100101
				{3'sd2,  -3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b100101}; // Col [000]
				{3'sd2,  -3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b100101}; // Col [010]
				{3'sd2,  -3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b100101}; // Col [100]
				{3'sd2,  -3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b110, 6'b100101}; // Col [110]
               
                // Row: Sd_n[5:0] = 100110
				{3'sd2,  3'sd0,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b100110}; // Col [000]
				{3'sd2,  3'sd0,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b100110}; // Col [010]
				{3'sd2,  3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b100110}; // Col [100]
				{3'sd2,  3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b100110}; // Col [110]
               
                // Row: Sd_n[5:0] = 100111
				{3'sd2,  -3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b100111}; // Col [000]
				{3'sd2,  -3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b100111}; // Col [010]
				{3'sd2,  -3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b100, 6'b100111}; // Col [100]
				{3'sd2,  -3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b100111}; // Col [110]
               
                // Row: Sd_n[5:0] = 101000
				{3'sd0,  3'sd0,  3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b101000}; // Col [000]
				{3'sd1,  3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b101000}; // Col [010]
				{3'sd1,  3'sd0,  3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b101000}; // Col [100]
				{3'sd0,  3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b101000}; // Col [110]
               
                // Row: Sd_n[5:0] = 101001
				{-3'sd2,  3'sd0,  3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b101001}; // Col [000]
				{-3'sd1,  3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b101001}; // Col [010]
				{-3'sd1,  3'sd0,  3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b101001}; // Col [100]
				{-3'sd2,  3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b101001}; // Col [110]
               
                // Row: Sd_n[5:0] = 101010
				{3'sd0,  -3'sd2,  3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b101010}; // Col [000]
				{3'sd1,  -3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b101010}; // Col [010]
				{3'sd1,  -3'sd2,  3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b101010}; // Col [100]
				{3'sd0,  -3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b101010}; // Col [110]
               
                // Row: Sd_n[5:0] = 101011
				{-3'sd2,  -3'sd2,  3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b101011}; // Col [000]
				{-3'sd1,  -3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b010, 6'b101011}; // Col [010]
				{-3'sd1,  -3'sd2,  3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b101011}; // Col [100]
				{-3'sd2,  -3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b110, 6'b101011}; // Col [110]
               
                // Row: Sd_n[5:0] = 101100
				{3'sd0,  3'sd0,  3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b101100}; // Col [000]
				{3'sd1,  3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b101100}; // Col [010]
				{3'sd1,  3'sd0,  3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b101100}; // Col [100]
				{3'sd0,  3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b101100}; // Col [110]
               
                // Row: Sd_n[5:0] = 101101
				{-3'sd2,  3'sd0,  3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b101101}; // Col [000]
				{-3'sd1,  3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b101101}; // Col [010]
				{-3'sd1,  3'sd0,  3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b101101}; // Col [100]
				{-3'sd2,  3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b101101}; // Col [110]
               
                // Row: Sd_n[5:0] = 101110
				{3'sd0,  -3'sd2,  3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b101110}; // Col [000]
				{3'sd1,  -3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b101110}; // Col [010]
				{3'sd1,  -3'sd2,  3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b101110}; // Col [100]
				{3'sd0,  -3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b101110}; // Col [110]
               
                // Row: Sd_n[5:0] = 101111
				{-3'sd2,  -3'sd2,  3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b101111}; // Col [000]
				{-3'sd1,  -3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b010, 6'b101111}; // Col [010]
				{-3'sd1,  -3'sd2,  3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b101111}; // Col [100]
				{-3'sd2,  -3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b110, 6'b101111}; // Col [110]
               
                // Row: Sd_n[5:0] = 110000
				{3'sd0,  3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b110000}; // Col [000]
				{3'sd0,  3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b110000}; // Col [010]
				{3'sd1,  3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b100, 6'b110000}; // Col [100]
				{3'sd1,  3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b110000}; // Col [110]
               
                // Row: Sd_n[5:0] = 110001
				{-3'sd2,  3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b000, 6'b110001}; // Col [000]
				{-3'sd2,  3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b110001}; // Col [010]
				{-3'sd1,  3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b100, 6'b110001}; // Col [100]
				{-3'sd1,  3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b110001}; // Col [110]
               
                // Row: Sd_n[5:0] = 110010
				{3'sd0,  3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b110010}; // Col [000]
				{3'sd0,  3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b110010}; // Col [010]
				{3'sd1,  3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b110010}; // Col [100]
				{3'sd1,  3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b110010}; // Col [110]
               
                // Row: Sd_n[5:0] = 110011
				{-3'sd2,  3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b000, 6'b110011}; // Col [000]
				{-3'sd2,  3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b010, 6'b110011}; // Col [010]
				{-3'sd1,  3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b100, 6'b110011}; // Col [100]
				{-3'sd1,  3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b110, 6'b110011}; // Col [110]
               
                // Row: Sd_n[5:0] = 110100
				{3'sd0,  3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b110100}; // Col [000]
				{3'sd0,  3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b110100}; // Col [010]
				{3'sd1,  3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b100, 6'b110100}; // Col [100]
				{3'sd1,  3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b110100}; // Col [110]
               
                // Row: Sd_n[5:0] = 110101
				{-3'sd2,  3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b000, 6'b110101}; // Col [000]
				{-3'sd2,  3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b110101}; // Col [010]
				{-3'sd1,  3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b100, 6'b110101}; // Col [100]
				{-3'sd1,  3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b110101}; // Col [110]
               
                // Row: Sd_n[5:0] = 110110
				{3'sd0,  3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b110110}; // Col [000]
				{3'sd0,  3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b110110}; // Col [010]
				{3'sd1,  3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b110110}; // Col [100]
				{3'sd1,  3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b110110}; // Col [110]
               
                // Row: Sd_n[5:0] = 110111
				{-3'sd2,  3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b000, 6'b110111}; // Col [000]
				{-3'sd2,  3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b010, 6'b110111}; // Col [010]
				{-3'sd1,  3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b100, 6'b110111}; // Col [100]
				{-3'sd1,  3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b110, 6'b110111}; // Col [110]
               
                // Row: Sd_n[5:0] = 111000
				{3'sd0,  3'sd0,  3'sd0,  3'sd2} : sdn_recovered = {3'b000, 6'b111000}; // Col [000]
				{3'sd1,  3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b010, 6'b111000}; // Col [010]
				{3'sd0,  3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111000}; // Col [100]
				{3'sd1,  3'sd0,  3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111000}; // Col [110]
               
                // Row: Sd_n[5:0] = 111001
				{-3'sd2,  3'sd0,  3'sd0,  3'sd2} : sdn_recovered = {3'b000, 6'b111001}; // Col [000]
				{-3'sd1,  3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b010, 6'b111001}; // Col [010]
				{-3'sd2,  3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111001}; // Col [100]
				{-3'sd1,  3'sd0,  3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111001}; // Col [110]
               
                // Row: Sd_n[5:0] = 111010
				{3'sd0,  -3'sd2,  3'sd0,  3'sd2} : sdn_recovered = {3'b000, 6'b111010}; // Col [000]
				{3'sd1,  -3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b010, 6'b111010}; // Col [010]
				{3'sd0,  -3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111010}; // Col [100]
				{3'sd1,  -3'sd2,  3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111010}; // Col [110]
               
                // Row: Sd_n[5:0] = 111011
				{-3'sd2,  -3'sd2,  3'sd0,  3'sd2} : sdn_recovered = {3'b000, 6'b111011}; // Col [000]
				{-3'sd1,  -3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b010, 6'b111011}; // Col [010]
				{-3'sd2,  -3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111011}; // Col [100]
				{-3'sd1,  -3'sd2,  3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111011}; // Col [110]
               
                // Row: Sd_n[5:0] = 111100
				{3'sd0,  3'sd0,  -3'sd2,  3'sd2} : sdn_recovered = {3'b000, 6'b111100}; // Col [000]
				{3'sd1,  3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b010, 6'b111100}; // Col [010]
				{3'sd0,  3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111100}; // Col [100]
				{3'sd1,  3'sd0,  -3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111100}; // Col [110]
               
                // Row: Sd_n[5:0] = 111101
				{-3'sd2,  3'sd0,  -3'sd2,  3'sd2} : sdn_recovered = {3'b000, 6'b111101}; // Col [000]
				{-3'sd1,  3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b010, 6'b111101}; // Col [010]
				{-3'sd2,  3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111101}; // Col [100]
				{-3'sd1,  3'sd0,  -3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111101}; // Col [110]
               
                // Row: Sd_n[5:0] = 111110
				{3'sd0,  -3'sd2,  -3'sd2,  3'sd2} : sdn_recovered = {3'b000, 6'b111110}; // Col [000]
				{3'sd1,  -3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b010, 6'b111110}; // Col [010]
				{3'sd0,  -3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111110}; // Col [100]
				{3'sd1,  -3'sd2,  -3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111110}; // Col [110]
               
                // Row: Sd_n[5:0] = 111111
				{-3'sd2,  -3'sd2,  -3'sd2,  3'sd2} : sdn_recovered = {3'b000, 6'b111111}; // Col [000]
				{-3'sd1,  -3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b010, 6'b111111}; // Col [010]
				{-3'sd2,  -3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b100, 6'b111111}; // Col [100]
				{-3'sd1,  -3'sd2,  -3'sd1,  3'sd2} : sdn_recovered = {3'b110, 6'b111111}; // Col [110]
               

 ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
                // --- TABLE 40-2 (ODD SUBSETS) ---
                // Row: Sd_n[5:0] = 000000
				{3'sd0,  3'sd0,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b000000}; // Col [001]
				{3'sd0,  3'sd0,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000000}; // Col [011]
				{3'sd0,  3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000000}; // Col [101]
				{3'sd0,  3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b111, 6'b000000}; // Col [111]

				// Row: Sd_n[5:0] = 000001
				{-3'sd2,  3'sd0,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b000001}; // Col [001]
				{-3'sd2,  3'sd0,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000001}; // Col [011]
				{-3'sd2,  3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000001}; // Col [101]
				{-3'sd2,  3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b111, 6'b000001}; // Col [111]

				// Row: Sd_n[5:0] = 000010
				{3'sd0,  -3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b000010}; // Col [001]
				{3'sd0,  -3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000010}; // Col [011]
				{3'sd0,  -3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000010}; // Col [101]
				{3'sd0,  -3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b111, 6'b000010}; // Col [111]

				// Row: Sd_n[5:0] = 000011
				{-3'sd2,  -3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b000011}; // Col [001]
				{-3'sd2,  -3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000011}; // Col [011]
				{-3'sd2,  -3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000011}; // Col [101]
				{-3'sd2,  -3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b111, 6'b000011}; // Col [111]

				// Row: Sd_n[5:0] = 000100
				{3'sd0,  3'sd0,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b000100}; // Col [001]
				{3'sd0,  3'sd0,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000100}; // Col [011]
				{3'sd0,  3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000100}; // Col [101]
				{3'sd0,  3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b000100}; // Col [111]

				// Row: Sd_n[5:0] = 000101
				{-3'sd2,  3'sd0,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b000101}; // Col [001]
				{-3'sd2,  3'sd0,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000101}; // Col [011]
				{-3'sd2,  3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000101}; // Col [101]
				{-3'sd2,  3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b000101}; // Col [111]

				// Row: Sd_n[5:0] = 000110
				{3'sd0,  -3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b000110}; // Col [001]
				{3'sd0,  -3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000110}; // Col [011]
				{3'sd0,  -3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000110}; // Col [101]
				{3'sd0,  -3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b000110}; // Col [111]

				// Row: Sd_n[5:0] = 000111
				{-3'sd2,  -3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b000111}; // Col [001]
				{-3'sd2,  -3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b000111}; // Col [011]
				{-3'sd2,  -3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b000111}; // Col [101]
				{-3'sd2,  -3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b000111}; // Col [111]

				// Row: Sd_n[5:0] = 001000
				{3'sd0,  3'sd0,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b001000}; // Col [001]
				{3'sd0,  3'sd0,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001000}; // Col [011]
				{3'sd0,  3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001000}; // Col [101]
				{3'sd0,  3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b111, 6'b001000}; // Col [111]

				// Row: Sd_n[5:0] = 001001
				{-3'sd2,  3'sd0,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b001001}; // Col [001]
				{-3'sd2,  3'sd0,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001001}; // Col [011]
				{-3'sd2,  3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001001}; // Col [101]
				{-3'sd2,  3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b111, 6'b001001}; // Col [111]

				// Row: Sd_n[5:0] = 001010
				{3'sd0,  -3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b001010}; // Col [001]
				{3'sd0,  -3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001010}; // Col [011]
				{3'sd0,  -3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001010}; // Col [101]
				{3'sd0,  -3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b111, 6'b001010}; // Col [111]

				// Row: Sd_n[5:0] = 001011
				{-3'sd2,  -3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b001011}; // Col [001]
				{-3'sd2,  -3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001011}; // Col [011]
				{-3'sd2,  -3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001011}; // Col [101]
				{-3'sd2,  -3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b111, 6'b001011}; // Col [111]

				// Row: Sd_n[5:0] = 001100
				{3'sd0,  3'sd0,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b001100}; // Col [001]
				{3'sd0,  3'sd0,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001100}; // Col [011]
				{3'sd0,  3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001100}; // Col [101]
				{3'sd0,  3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b001100}; // Col [111]

				// Row: Sd_n[5:0] = 001101
				{-3'sd2,  3'sd0,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b001101}; // Col [001]
				{-3'sd2,  3'sd0,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001101}; // Col [011]
				{-3'sd2,  3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001101}; // Col [101]
				{-3'sd2,  3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b001101}; // Col [111]

				// Row: Sd_n[5:0] = 001110
				{3'sd0,  -3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b001110}; // Col [001]
				{3'sd0,  -3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001110}; // Col [011]
				{3'sd0,  -3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001110}; // Col [101]
				{3'sd0,  -3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b001110}; // Col [111]

				// Row: Sd_n[5:0] = 001111
				{-3'sd2,  -3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b001111}; // Col [001]
				{-3'sd2,  -3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b001111}; // Col [011]
				{-3'sd2,  -3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b001111}; // Col [101]
				{-3'sd2,  -3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b001111}; // Col [111]

				// Row: Sd_n[5:0] = 010000
				{3'sd1,  3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010000}; // Col [001]
				{3'sd1,  3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b011, 6'b010000}; // Col [011]
				{3'sd1,  3'sd0,  3'sd0,  3'sd0} : sdn_recovered = {3'b101, 6'b010000}; // Col [101]
				{3'sd1,  3'sd0,  3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010000}; // Col [111]

				// Row: Sd_n[5:0] = 010001
				{-3'sd1,  3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010001}; // Col [001]
				{-3'sd1,  3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b011, 6'b010001}; // Col [011]
				{-3'sd1,  3'sd0,  3'sd0,  3'sd0} : sdn_recovered = {3'b101, 6'b010001}; // Col [101]
				{-3'sd1,  3'sd0,  3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010001}; // Col [111]

				// Row: Sd_n[5:0] = 010010
				{3'sd1,  -3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010010}; // Col [001]
				{3'sd1,  -3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b011, 6'b010010}; // Col [011]
				{3'sd1,  -3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b101, 6'b010010}; // Col [101]
				{3'sd1,  -3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010010}; // Col [111]

				// Row: Sd_n[5:0] = 010011
				{-3'sd1,  -3'sd1,  3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010011}; // Col [001]
				{-3'sd1,  -3'sd1,  3'sd0,  3'sd1} : sdn_recovered = {3'b011, 6'b010011}; // Col [011]
				{-3'sd1,  -3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b101, 6'b010011}; // Col [101]
				{-3'sd1,  -3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010011}; // Col [111]

				// Row: Sd_n[5:0] = 010100
				{3'sd1,  3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010100}; // Col [001]
				{3'sd1,  3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b010100}; // Col [011]
				{3'sd1,  3'sd0,  -3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b010100}; // Col [101]
				{3'sd1,  3'sd0,  -3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010100}; // Col [111]

				// Row: Sd_n[5:0] = 010101
				{-3'sd1,  3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010101}; // Col [001]
				{-3'sd1,  3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b010101}; // Col [011]
				{-3'sd1,  3'sd0,  -3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b010101}; // Col [101]
				{-3'sd1,  3'sd0,  -3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010101}; // Col [111]

				// Row: Sd_n[5:0] = 010110
				{3'sd1,  -3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010110}; // Col [001]
				{3'sd1,  -3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b010110}; // Col [011]
				{3'sd1,  -3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b010110}; // Col [101]
				{3'sd1,  -3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010110}; // Col [111]

				// Row: Sd_n[5:0] = 010111
				{-3'sd1,  -3'sd1,  -3'sd1,  3'sd0} : sdn_recovered = {3'b001, 6'b010111}; // Col [001]
				{-3'sd1,  -3'sd1,  -3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b010111}; // Col [011]
				{-3'sd1,  -3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b010111}; // Col [101]
				{-3'sd1,  -3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b010111}; // Col [111]

				// Row: Sd_n[5:0] = 011000
				{3'sd1,  3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011000}; // Col [001]
				{3'sd1,  3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b011, 6'b011000}; // Col [011]
				{3'sd1,  3'sd0,  3'sd0,  -3'sd2} : sdn_recovered = {3'b101, 6'b011000}; // Col [101]
				{3'sd1,  3'sd0,  3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011000}; // Col [111]

				// Row: Sd_n[5:0] = 011001
				{-3'sd1,  3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011001}; // Col [001]
				{-3'sd1,  3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b011, 6'b011001}; // Col [011]
				{-3'sd1,  3'sd0,  3'sd0,  -3'sd2} : sdn_recovered = {3'b101, 6'b011001}; // Col [101]
				{-3'sd1,  3'sd0,  3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011001}; // Col [111]

				// Row: Sd_n[5:0] = 011010
				{3'sd1,  -3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011010}; // Col [001]
				{3'sd1,  -3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b011, 6'b011010}; // Col [011]
				{3'sd1,  -3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b101, 6'b011010}; // Col [101]
				{3'sd1,  -3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011010}; // Col [111]

				// Row: Sd_n[5:0] = 011011
				{-3'sd1,  -3'sd1,  3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011011}; // Col [001]
				{-3'sd1,  -3'sd1,  3'sd0,  -3'sd1} : sdn_recovered = {3'b011, 6'b011011}; // Col [011]
				{-3'sd1,  -3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b101, 6'b011011}; // Col [101]
				{-3'sd1,  -3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011011}; // Col [111]

				// Row: Sd_n[5:0] = 011100
				{3'sd1,  3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011100}; // Col [001]
				{3'sd1,  3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b011100}; // Col [011]
				{3'sd1,  3'sd0,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b011100}; // Col [101]
				{3'sd1,  3'sd0,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011100}; // Col [111]

				// Row: Sd_n[5:0] = 011101
				{-3'sd1,  3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011101}; // Col [001]
				{-3'sd1,  3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b011101}; // Col [011]
				{-3'sd1,  3'sd0,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b011101}; // Col [101]
				{-3'sd1,  3'sd0,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011101}; // Col [111]

				// Row: Sd_n[5:0] = 011110
				{3'sd1,  -3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011110}; // Col [001]
				{3'sd1,  -3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b011110}; // Col [011]
				{3'sd1,  -3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b011110}; // Col [101]
				{3'sd1,  -3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011110}; // Col [111]

				// Row: Sd_n[5:0] = 011111
				{-3'sd1,  -3'sd1,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b001, 6'b011111}; // Col [001]
				{-3'sd1,  -3'sd1,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b011111}; // Col [011]
				{-3'sd1,  -3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b011111}; // Col [101]
				{-3'sd1,  -3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b011111}; // Col [111]

				// Row: Sd_n[5:0] = 100000
				{3'sd2,  3'sd0,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b100000}; // Col [001]
				{3'sd2,  3'sd0,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b100000}; // Col [011]
				{3'sd2,  3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b100000}; // Col [101]
				{3'sd2,  3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b111, 6'b100000}; // Col [111]

				// Row: Sd_n[5:0] = 100001
				{3'sd2,  -3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b100001}; // Col [001]
				{3'sd2,  -3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b100001}; // Col [011]
				{3'sd2,  -3'sd1,  3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b100001}; // Col [101]
				{3'sd2,  -3'sd1,  3'sd0,  3'sd0} : sdn_recovered = {3'b111, 6'b100001}; // Col [111]

				// Row: Sd_n[5:0] = 100010
				{3'sd2,  3'sd0,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b100010}; // Col [001]
				{3'sd2,  3'sd0,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b100010}; // Col [011]
				{3'sd2,  3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b100010}; // Col [101]
				{3'sd2,  3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b100010}; // Col [111]

				// Row: Sd_n[5:0] = 100011
				{3'sd2,  -3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b100011}; // Col [001]
				{3'sd2,  -3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b100011}; // Col [011]
				{3'sd2,  -3'sd1,  -3'sd1,  3'sd1} : sdn_recovered = {3'b101, 6'b100011}; // Col [101]
				{3'sd2,  -3'sd1,  -3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b100011}; // Col [111]

				// Row: Sd_n[5:0] = 100100
				{3'sd2,  3'sd0,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b100100}; // Col [001]
				{3'sd2,  3'sd0,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b100100}; // Col [011]
				{3'sd2,  3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b100100}; // Col [101]
				{3'sd2,  3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b111, 6'b100100}; // Col [111]

				// Row: Sd_n[5:0] = 100101
				{3'sd2,  -3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b100101}; // Col [001]
				{3'sd2,  -3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b100101}; // Col [011]
				{3'sd2,  -3'sd1,  3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b100101}; // Col [101]
				{3'sd2,  -3'sd1,  3'sd0,  -3'sd2} : sdn_recovered = {3'b111, 6'b100101}; // Col [111]

				// Row: Sd_n[5:0] = 100110
				{3'sd2,  3'sd0,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b100110}; // Col [001]
				{3'sd2,  3'sd0,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b100110}; // Col [011]
				{3'sd2,  3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b100110}; // Col [101]
				{3'sd2,  3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b100110}; // Col [111]

				// Row: Sd_n[5:0] = 100111
				{3'sd2,  -3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b100111}; // Col [001]
				{3'sd2,  -3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b100111}; // Col [011]
				{3'sd2,  -3'sd1,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b101, 6'b100111}; // Col [101]
				{3'sd2,  -3'sd1,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b100111}; // Col [111]

				// Row: Sd_n[5:0] = 101000
				{3'sd0,  3'sd0,  3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b101000}; // Col [001]
				{3'sd1,  3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b101000}; // Col [011]
				{3'sd1,  3'sd0,  3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b101000}; // Col [101]
				{3'sd0,  3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b101000}; // Col [111]

				// Row: Sd_n[5:0] = 101001
				{-3'sd2,  3'sd0,  3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b101001}; // Col [001]
				{-3'sd1,  3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b101001}; // Col [011]
				{-3'sd1,  3'sd0,  3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b101001}; // Col [101]
				{-3'sd2,  3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b101001}; // Col [111]

				// Row: Sd_n[5:0] = 101010
				{3'sd0,  -3'sd2,  3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b101010}; // Col [001]
				{3'sd1,  -3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b101010}; // Col [011]
				{3'sd1,  -3'sd2,  3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b101010}; // Col [101]
				{3'sd0,  -3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b101010}; // Col [111]

				// Row: Sd_n[5:0] = 101011
				{-3'sd2,  -3'sd2,  3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b101011}; // Col [001]
				{-3'sd1,  -3'sd1,  3'sd2,  3'sd1} : sdn_recovered = {3'b011, 6'b101011}; // Col [011]
				{-3'sd1,  -3'sd2,  3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b101011}; // Col [101]
				{-3'sd2,  -3'sd1,  3'sd2,  3'sd0} : sdn_recovered = {3'b111, 6'b101011}; // Col [111]

				// Row: Sd_n[5:0] = 101100
				{3'sd0,  3'sd0,  3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b101100}; // Col [001]
				{3'sd1,  3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b101100}; // Col [011]
				{3'sd1,  3'sd0,  3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b101100}; // Col [101]
				{3'sd0,  3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b101100}; // Col [111]

				// Row: Sd_n[5:0] = 101101
				{-3'sd2,  3'sd0,  3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b101101}; // Col [001]
				{-3'sd1,  3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b101101}; // Col [011]
				{-3'sd1,  3'sd0,  3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b101101}; // Col [101]
				{-3'sd2,  3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b101101}; // Col [111]

				// Row: Sd_n[5:0] = 101110
				{3'sd0,  -3'sd2,  3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b101110}; // Col [001]
				{3'sd1,  -3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b101110}; // Col [011]
				{3'sd1,  -3'sd2,  3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b101110}; // Col [101]
				{3'sd0,  -3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b101110}; // Col [111]

				// Row: Sd_n[5:0] = 101111
				{-3'sd2,  -3'sd2,  3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b101111}; // Col [001]
				{-3'sd1,  -3'sd1,  3'sd2,  -3'sd1} : sdn_recovered = {3'b011, 6'b101111}; // Col [011]
				{-3'sd1,  -3'sd2,  3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b101111}; // Col [101]
				{-3'sd2,  -3'sd1,  3'sd2,  -3'sd2} : sdn_recovered = {3'b111, 6'b101111}; // Col [111]

				// Row: Sd_n[5:0] = 110000
				{3'sd0,  3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b110000}; // Col [001]
				{3'sd0,  3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b110000}; // Col [011]
				{3'sd1,  3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b101, 6'b110000}; // Col [101]
				{3'sd1,  3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b110000}; // Col [111]

				// Row: Sd_n[5:0] = 110001
				{-3'sd2,  3'sd2,  3'sd0,  3'sd1} : sdn_recovered = {3'b001, 6'b110001}; // Col [001]
				{-3'sd2,  3'sd2,  3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b110001}; // Col [011]
				{-3'sd1,  3'sd2,  3'sd0,  3'sd0} : sdn_recovered = {3'b101, 6'b110001}; // Col [101]
				{-3'sd1,  3'sd2,  3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b110001}; // Col [111]

				// Row: Sd_n[5:0] = 110010
				{3'sd0,  3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b110010}; // Col [001]
				{3'sd0,  3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b110010}; // Col [011]
				{3'sd1,  3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b110010}; // Col [101]
				{3'sd1,  3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b110010}; // Col [111]

				// Row: Sd_n[5:0] = 110011
				{-3'sd2,  3'sd2,  -3'sd2,  3'sd1} : sdn_recovered = {3'b001, 6'b110011}; // Col [001]
				{-3'sd2,  3'sd2,  -3'sd1,  3'sd0} : sdn_recovered = {3'b011, 6'b110011}; // Col [011]
				{-3'sd1,  3'sd2,  -3'sd2,  3'sd0} : sdn_recovered = {3'b101, 6'b110011}; // Col [101]
				{-3'sd1,  3'sd2,  -3'sd1,  3'sd1} : sdn_recovered = {3'b111, 6'b110011}; // Col [111]

				// Row: Sd_n[5:0] = 110100
				{3'sd0,  3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b110100}; // Col [001]
				{3'sd0,  3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b110100}; // Col [011]
				{3'sd1,  3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b101, 6'b110100}; // Col [101]
				{3'sd1,  3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b110100}; // Col [111]

				// Row: Sd_n[5:0] = 110101
				{-3'sd2,  3'sd2,  3'sd0,  -3'sd1} : sdn_recovered = {3'b001, 6'b110101}; // Col [001]
				{-3'sd2,  3'sd2,  3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b110101}; // Col [011]
				{-3'sd1,  3'sd2,  3'sd0,  -3'sd2} : sdn_recovered = {3'b101, 6'b110101}; // Col [101]
				{-3'sd1,  3'sd2,  3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b110101}; // Col [111]

				// Row: Sd_n[5:0] = 110110
				{3'sd0,  3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b110110}; // Col [001]
				{3'sd0,  3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b110110}; // Col [011]
				{3'sd1,  3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b110110}; // Col [101]
				{3'sd1,  3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b110110}; // Col [111]

				// Row: Sd_n[5:0] = 110111
				{-3'sd2,  3'sd2,  -3'sd2,  -3'sd1} : sdn_recovered = {3'b001, 6'b110111}; // Col [001]
				{-3'sd2,  3'sd2,  -3'sd1,  -3'sd2} : sdn_recovered = {3'b011, 6'b110111}; // Col [011]
				{-3'sd1,  3'sd2,  -3'sd2,  -3'sd2} : sdn_recovered = {3'b101, 6'b110111}; // Col [101]
				{-3'sd1,  3'sd2,  -3'sd1,  -3'sd1} : sdn_recovered = {3'b111, 6'b110111}; // Col [111]

				// Row: Sd_n[5:0] = 111000
				{3'sd1,  3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111000}; // Col [001]
				{3'sd0,  3'sd0,  3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111000}; // Col [011]
				{3'sd1,  3'sd0,  3'sd0,  3'sd2} : sdn_recovered = {3'b101, 6'b111000}; // Col [101]
				{3'sd0,  3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b111, 6'b111000}; // Col [111]

				// Row: Sd_n[5:0] = 111001
				{-3'sd1,  3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111001}; // Col [001]
				{-3'sd2,  3'sd0,  3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111001}; // Col [011]
				{-3'sd1,  3'sd0,  3'sd0,  3'sd2} : sdn_recovered = {3'b101, 6'b111001}; // Col [101]
				{-3'sd2,  3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b111, 6'b111001}; // Col [111]

				// Row: Sd_n[5:0] = 111010
				{3'sd1,  -3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111010}; // Col [001]
				{3'sd0,  -3'sd2,  3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111010}; // Col [011]
				{3'sd1,  -3'sd2,  3'sd0,  3'sd2} : sdn_recovered = {3'b101, 6'b111010}; // Col [101]
				{3'sd0,  -3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b111, 6'b111010}; // Col [111]

				// Row: Sd_n[5:0] = 111011
				{-3'sd1,  -3'sd1,  3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111011}; // Col [001]
				{-3'sd2,  -3'sd2,  3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111011}; // Col [011]
				{-3'sd1,  -3'sd2,  3'sd0,  3'sd2} : sdn_recovered = {3'b101, 6'b111011}; // Col [101]
				{-3'sd2,  -3'sd1,  3'sd0,  3'sd2} : sdn_recovered = {3'b111, 6'b111011}; // Col [111]

				// Row: Sd_n[5:0] = 111100
				{3'sd1,  3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111100}; // Col [001]
				{3'sd0,  3'sd0,  -3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111100}; // Col [011]
				{3'sd1,  3'sd0,  -3'sd2,  3'sd2} : sdn_recovered = {3'b101, 6'b111100}; // Col [101]
				{3'sd0,  3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b111, 6'b111100}; // Col [111]

				// Row: Sd_n[5:0] = 111101
				{-3'sd1,  3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111101}; // Col [001]
				{-3'sd2,  3'sd0,  -3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111101}; // Col [011]
				{-3'sd1,  3'sd0,  -3'sd2,  3'sd2} : sdn_recovered = {3'b101, 6'b111101}; // Col [101]
				{-3'sd2,  3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b111, 6'b111101}; // Col [111]

				// Row: Sd_n[5:0] = 111110
				{3'sd1,  -3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111110}; // Col [001]
				{3'sd0,  -3'sd2,  -3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111110}; // Col [011]
				{3'sd1,  -3'sd2,  -3'sd2,  3'sd2} : sdn_recovered = {3'b101, 6'b111110}; // Col [101]
				{3'sd0,  -3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b111, 6'b111110}; // Col [111]

				// Row: Sd_n[5:0] = 111111
				{-3'sd1,  -3'sd1,  -3'sd1,  3'sd2} : sdn_recovered = {3'b001, 6'b111111}; // Col [001]
				{-3'sd2,  -3'sd2,  -3'sd1,  3'sd2} : sdn_recovered = {3'b011, 6'b111111}; // Col [011]
				{-3'sd1,  -3'sd2,  -3'sd2,  3'sd2} : sdn_recovered = {3'b101, 6'b111111}; // Col [101]
				{-3'sd2,  -3'sd1,  -3'sd2,  3'sd2} : sdn_recovered = {3'b111, 6'b111111}; // Col [111]

                // Default catch for symbols that violate encoding rules
                default: begin 
                    sdn_recovered = 9'b0; 
                    // Note: You may want to assert a local 'invalid_symbol' flag here
                    // to feed into your RX FSM for robust error handling.
                end
            endcase
        end
    end
    
    // 3. Descramble Sd_n to recover RXD<7:0>
    // This reverses the TX path logic: Sd_n[x] = Sc_n[x] ^ TXD[x] becomes RXD[x] = Sc_n[x] ^ Sd_n[x]
    always_comb begin
        rxd[7] = sdn_recovered[7] ^ sc_n[7];
        rxd[6] = sdn_recovered[6] ^ sc_n[6];
        rxd[5] = sdn_recovered[5] ^ sc_n[5];
        rxd[4] = sdn_recovered[4] ^ sc_n[4];
        rxd[3] = sdn_recovered[3] ^ sc_n[3];
        rxd[2] = sdn_recovered[2] ^ sc_n[2];
        rxd[1] = sdn_recovered[1] ^ sc_n[1];
        rxd[0] = sdn_recovered[0] ^ sc_n[0];
    end

endmodule