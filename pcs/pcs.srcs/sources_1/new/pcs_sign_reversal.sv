`timescale 1ns / 1ps

module pcs_sign_reversal
import pcs_types_pkg::*;
(
    input  symb_4d_t     t_symb,       // TA, TB, TC, TD from mapper
    input  logic [3:0]   sgn,          // Sg_n[3:0] from scrambler
    input  logic         tx_en_n2,     // tx_enable delayed by 2 clocks
    input  logic         tx_en_n4,     // tx_enable delayed by 4 clocks
    output symb_4d_t     final_symb    // Final An, Bn, Cn, Dn for PMA
);

    logic srev_n;
    logic sn_a, sn_b, sn_c, sn_d; // Sign multipliers (+1 or -1)

    always_comb begin
        srev_n = tx_en_n2 | tx_en_n4;

        // SnA = +1 if (Sgn[0] XOR srev_n) == 0, else -1
        sn_a = ((sgn[0] ^ srev_n) == 1'b0) ? 1 : -1;
        sn_b = ((sgn[1] ^ srev_n) == 1'b0) ? 1 : -1;
        sn_c = ((sgn[2] ^ srev_n) == 1'b0) ? 1 : -1;
        sn_d = ((sgn[3] ^ srev_n) == 1'b0) ? 1 : -1;

        // Final output is the product
        final_symb.A = t_symb.A * sn_a;
        final_symb.B = t_symb.B * sn_b;
        final_symb.C = t_symb.C * sn_c;
        final_symb.D = t_symb.D * sn_d;
    end
endmodule
