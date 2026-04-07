`timescale 1ns / 1ps

module pcs_rx_block
import pcs_types_pkg::*;
(
    input  logic         clk,             // RX_CLK / Symb_clk (125 MHz)
    input  logic         reset_n,         // Hardware reset
    input  logic         pcs_reset,       // Management reset
    
    // Management/Configuration
    input  config_mode_t config_mode,     // MASTER or SLAVE
    input  logic         link_status_ok,  // 1 = OK, 0 = FAIL
    
    // PMA Interface Inputs
    input  symb_4d_t     rx_symb_vector,  // RA, RB, RC, RD from PMA
    
    // GMII Interface Outputs
    output logic [7:0]   rxd,
    output logic         rx_dv,
    output logic         rx_er,
    
    // Cross-domain Outputs
    output logic         _1000BTreceive   // To Carrier Sense (Phase 5)
);

    // -------------------------------------------------------------------------
    // Internal Signals
    // -------------------------------------------------------------------------
    // Descrambler Outputs
    logic [3:0] sx_n, sy_n, sg_n;
    logic [7:0] sc_n;

    // Sign Decoder Outputs
    logic       rx_srev_n;
    symb_4d_t   t_symb;

    // Symbol Decoder Outputs (Time 'n')
    logic [7:0] rxd_n;
    logic       is_idle_n, is_ssd1_n, is_ssd2_n;
    logic       is_csreset_n, is_csextend_n;
    logic       is_esd1_n, is_esd2_ext_0_n, is_xmt_err_n;

    // Pipeline Outputs (Delayed)
    logic [7:0] rxd_n1, rxd_n2, rxd_n3;
    logic       is_idle_n1, is_ssd1_n1, is_ssd2_n1, is_esd1_n1, is_csreset_n1;
    logic       is_csextend_n1, is_xmt_err_n1;
    logic       is_ssd1_n2, is_esd1_n2, is_csreset_n2;
    logic       is_esd1_n3;

    // -------------------------------------------------------------------------
    // 1. Assemble Scrambler Bits
    // -------------------------------------------------------------------------
    // The RX descrambler bits Sc_n[7:0] are a simple concatenation of Sx_n and Sy_n
    assign sc_n = {sx_n, sy_n};

    // -------------------------------------------------------------------------
    // 2. Module Instantiations
    // -------------------------------------------------------------------------
    
    pcs_rx_descrambler u_rx_descrambler (
        .clk         (clk),
        .reset_n     (reset_n),
        .config_mode (config_mode),
        .sx_n        (sx_n),
        .sy_n        (sy_n),
        .sg_n        (sg_n),
        .scr_0       () // Unused at this level
    );

    pcs_rx_sign_decoder u_sign_decoder (
        .r_symb      (rx_symb_vector),
        .sgn         (sg_n),
        .rx_srev_n   (rx_srev_n),
        .t_symb      (t_symb)
    );

    pcs_rx_symbol_decoder u_symbol_decoder (
        .t_symb      (t_symb),
        .sc_n        (sc_n),
        .rxd         (rxd_n),
        .is_idle     (is_idle_n),
        .is_ssd1     (is_ssd1_n),
        .is_ssd2     (is_ssd2_n),
        .is_csreset  (is_csreset_n),
        .is_csextend (is_csextend_n),
        .is_esd1     (is_esd1_n),
        .is_esd2_ext_0(is_esd2_ext_0_n),
        .is_xmt_err  (is_xmt_err_n)
    );

    pcs_rx_pipeline u_rx_pipeline (
        .clk             (clk),
        .reset_n         (reset_n),
        .pcs_reset       (pcs_reset),
        
        // Time 'n' Inputs
        .rxd_n           (rxd_n),
        .is_idle_n       (is_idle_n),
        .is_ssd1_n       (is_ssd1_n),
        .is_ssd2_n       (is_ssd2_n),
        .is_csreset_n    (is_csreset_n),
        .is_csextend_n   (is_csextend_n),
        .is_esd1_n       (is_esd1_n),
        .is_esd2_ext_0_n (is_esd2_ext_0_n),
        .is_xmt_err_n    (is_xmt_err_n),
        
        // Time 'n-1' Outputs
        .rxd_n1          (rxd_n1),
        .is_idle_n1      (is_idle_n1),
        .is_ssd1_n1      (is_ssd1_n1),
        .is_ssd2_n1      (is_ssd2_n1),
        .is_esd1_n1      (is_esd1_n1),
        .is_csreset_n1   (is_csreset_n1),
        .is_csextend_n1  (is_csextend_n1),
        .is_xmt_err_n1   (is_xmt_err_n1),
        
        // Time 'n-2' Outputs
        .rxd_n2          (rxd_n2),
        .is_ssd1_n2      (is_ssd1_n2),
        .is_esd1_n2      (is_esd1_n2),
        .is_csreset_n2   (is_csreset_n2),
        
        // Time 'n-3' Outputs
        .rxd_n3          (rxd_n3),
        .is_esd1_n3      (is_esd1_n3)
    );

    pcs_receive_fsm u_receive_fsm (
        .clk             (clk),
        .reset_n         (reset_n),
        .pcs_reset       (pcs_reset),
        .link_status_ok  (link_status_ok),
        
        // Time 'n' control flags
        .is_idle_n       (is_idle_n),
        .is_ssd1_n       (is_ssd1_n),
        .is_ssd2_n       (is_ssd2_n),
        .is_esd1_n       (is_esd1_n),
        .is_esd2_ext_0_n (is_esd2_ext_0_n),
        .is_xmt_err_n    (is_xmt_err_n),
        .is_csreset_n    (is_csreset_n),
        
        // Delayed data for GMII alignment
        .rxd_n2          (rxd_n2),
        
        // Outputs
        .rx_dv           (rx_dv),
        .rx_er           (rx_er),
        .rxd             (rxd),
        ._1000BTreceive  (_1000BTreceive),
        .rx_srev_n       (rx_srev_n)
    );

endmodule