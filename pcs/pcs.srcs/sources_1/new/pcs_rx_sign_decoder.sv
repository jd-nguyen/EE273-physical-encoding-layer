`timescale 1ns / 1ps

module pcs_rx_sign_decoder
import pcs_types_pkg::*;
(
    input  symb_4d_t   r_symb,     // RA, RB, RC, RD from PMA
    input  logic [3:0] sgn,        // Sg_n[3:0] from RX Descrambler
    input  logic       rx_srev_n,  // Sign reversal state from RX FSM
    
    output symb_4d_t   t_symb      // Recovered TA, TB, TC, TD
);

    logic sn_a, sn_b, sn_c, sn_d;

    // The logic is identical to the TX path, but applied to the RX symbols
    always_comb begin
        sn_a = ((sgn[0] ^ rx_srev_n) == 1'b0) ? 1 : -1;
        sn_b = ((sgn[1] ^ rx_srev_n) == 1'b0) ? 1 : -1;
        sn_c = ((sgn[2] ^ rx_srev_n) == 1'b0) ? 1 : -1;
        sn_d = ((sgn[3] ^ rx_srev_n) == 1'b0) ? 1 : -1;

        // Multiply to remove the sign randomization
        t_symb.A = r_symb.A * sn_a;
        t_symb.B = r_symb.B * sn_b;
        t_symb.C = r_symb.C * sn_c;
        t_symb.D = r_symb.D * sn_d;
    end
endmodule