`timescale 1ns / 1ps

module pcs_tx_block
import pcs_types_pkg::*;
(
    input  logic         clk,             // GTX_CLK (125 MHz)
    input  logic         reset_n,         // Hardware reset
    input  logic         pcs_reset,       // Management reset
    
    // Management/Configuration
    input  config_mode_t config_mode,     // MASTER or SLAVE
    input  tx_mode_t     tx_mode,         // SEND_N, SEND_I, SEND_Z
    input  logic         link_status_ok,  // 1 = OK, 0 = FAIL
    
    // GMII Interface Inputs
    input  logic         tx_en,
    input  logic         tx_er,
    input  logic [7:0]   txd,
    
    // Cross-domain inputs
    input  logic         _1000BTreceive,  // From PCS RX
    input  logic         loc_lpi_req,     // For EEE (Tie to 0 if unused)
    input  logic         loc_update_done, // For PMA training (Tie to 1 if unused)
    
    // Outputs
    output symb_4d_t     tx_symb_vector,  // To PMA
    output logic         _1000BTtransmit, // To Carrier Sense / RX
    output logic         col              // To GMII
);

    // -------------------------------------------------------------------------
    // Internal Signals
    // -------------------------------------------------------------------------
    // Scrambler Outputs
    logic [3:0] sx_n, sy_n, sg_n;
    logic       scr_0;

    // TX Enable FSM Outputs
    logic       tx_enable;
    logic       tx_error;

    // Transmit Pipeline (n-1, n-2, n-3, n-4)
    logic       tx_en_n1, tx_en_n2, tx_en_n3, tx_en_n4;

    // Convolutional Encoder Signals
    logic [7:0] sc_n;
    logic [8:0] sd_n;
    logic [2:0] cs_n, cs_n_reg;
    logic       csreset;

    // Master Transmit FSM Control Flags
    logic       is_idle, is_ssd1, is_ssd2, is_xmt_err, is_tx_data;
    logic       is_csreset, is_esd1, is_esd2_ext_0, is_esd2_ext_1;
    logic       is_esd2_ext_2, is_esd_ext_err, is_csextend;
    logic       is_csextend_err, is_cext, is_cext_err;

    // Symbol Mapping Intermediate
    symb_4d_t   mapped_symb;

    // -------------------------------------------------------------------------
    // 1. Shift Register Pipeline for tx_enable
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tx_en_n1 <= 0; tx_en_n2 <= 0; 
            tx_en_n3 <= 0; tx_en_n4 <= 0;
        end else begin
            tx_en_n1 <= tx_enable;
            tx_en_n2 <= tx_en_n1;
            tx_en_n3 <= tx_en_n2;
            tx_en_n4 <= tx_en_n3;
        end
    end

    // -------------------------------------------------------------------------
    // 2. Convolutional Encoder & Scrambled Bit Generation
    // -------------------------------------------------------------------------
    assign csreset = tx_en_n2 & !tx_enable; // 

    // Generate Sc_n bits based on scrambler outputs and tx_enable_n2
    always_comb begin
        sc_n[7:4] = (tx_en_n2) ? sx_n[3:0] : 4'b0000; // [cite: 182]
        sc_n[3:1] = (tx_mode == SEND_Z) ? 3'b000 : sy_n[3:1]; // [cite: 184, 185, 186, 187]
        sc_n[0]   = (tx_mode == SEND_Z) ? 1'b0 : sy_n[0]; // [cite: 192]
    end

    // Convolutional State (cs_n) generation [cite: 200, 201]
    always_comb begin
        cs_n[0] = cs_n_reg[2];
        cs_n[1] = (tx_en_n2) ? (sd_n[6] ^ cs_n_reg[0]) : 1'b0;
        cs_n[2] = (tx_en_n2) ? (sd_n[7] ^ cs_n_reg[1]) : 1'b0;
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) cs_n_reg <= 3'b000;
        else          cs_n_reg <= cs_n;
    end

    // Generate Sd_n[8:0] bits for the mapper [cite: 203, 208, 210, 212, 224, 227]
    always_comb begin
        sd_n[8]   = cs_n[0];
        
        if (csreset == 1'b0 && tx_en_n2 == 1'b1) begin
            sd_n[7] = sc_n[7] ^ txd[7];
            sd_n[6] = sc_n[6] ^ txd[6];
        end else if (csreset == 1'b1) begin
            sd_n[7] = cs_n[1];
            sd_n[6] = cs_n[0];
        end else begin
            sd_n[7] = sc_n[7];
            sd_n[6] = sc_n[6];
        end

        sd_n[5:4] = (tx_en_n2) ? (sc_n[5:4] ^ txd[5:4]) : sc_n[5:4];
        
        // Lower bits include handling for LPI and receiver status if not transmitting data
        sd_n[3]   = (tx_en_n2) ? (sc_n[3] ^ txd[3]) : 
                    ((loc_lpi_req && tx_mode != SEND_Z) ? (sc_n[3] ^ 1'b1) : sc_n[3]);
        
        sd_n[2]   = (tx_en_n2) ? (sc_n[2] ^ txd[2]) : sc_n[2]; // Simplified loc_rcvr_status hook
        
        // Bits 1 and 0 handle carrier extension encoding during IDLE/SEND_N
        sd_n[1]   = (tx_en_n2) ? (sc_n[1] ^ txd[1]) : 
                    ((!tx_enable && txd == 8'h0F) ? sc_n[1] : (sc_n[1] ^ tx_error)); // Simplified
        sd_n[0]   = (tx_en_n2) ? (sc_n[0] ^ txd[0]) : sc_n[0];
    end

    // -------------------------------------------------------------------------
    // 3. Module Instantiations
    // -------------------------------------------------------------------------
    
    pcs_tx_scrambler u_scrambler (
        .clk         (clk),
        .reset_n     (reset_n),
        .config_mode (config_mode),
        .sx_n        (sx_n),
        .sy_n        (sy_n),
        .sg_n        (sg_n),
        .scr_0       (scr_0)
    );

    pcs_tx_enable_fsm u_tx_enable_fsm (
        .clk            (clk),
        .reset_n        (reset_n),
        .pcs_reset      (pcs_reset),
        .link_status_ok (link_status_ok),
        .tx_mode        (tx_mode),
        .tx_en          (tx_en),
        .tx_er          (tx_er),
        .tx_enable      (tx_enable),
        .tx_error       (tx_error)
    );

    pcs_transmit_fsm u_transmit_fsm (
        .clk             (clk),
        .reset_n         (reset_n),
        .pcs_reset       (pcs_reset),
        .tx_enable       (tx_enable),
        .tx_error        (tx_error),
        .txd             (txd),
        ._1000BTreceive  (_1000BTreceive),
        ._1000BTtransmit (_1000BTtransmit),
        .col             (col),
        
        // Control Flags
        .is_idle         (is_idle),
        .is_ssd1         (is_ssd1),
        .is_ssd2         (is_ssd2),
        .is_xmt_err      (is_xmt_err),
        .is_tx_data      (is_tx_data),
        .is_csreset      (is_csreset),
        .is_esd1         (is_esd1),
        .is_esd2_ext_0   (is_esd2_ext_0),
        .is_esd2_ext_1   (is_esd2_ext_1),
        .is_esd2_ext_2   (is_esd2_ext_2),
        .is_esd_ext_err  (is_esd_ext_err),
        .is_csextend     (is_csextend),
        .is_csextend_err (is_csextend_err),
        .is_cext         (is_cext),
        .is_cext_err     (is_cext_err)
    );

    pcs_symbol_mapper u_mapper (
        .sdn             (sd_n),
        
        // Hook up the control flags from the Transmit FSM
        .is_xmt_err      (is_xmt_err),
        .is_csreset      (is_csreset),
        .is_ssd1         (is_ssd1),
        .is_ssd2         (is_ssd2),
        .is_esd1         (is_esd1),
        .is_esd2_ext_0   (is_esd2_ext_0),
        .is_esd2_ext_1   (is_esd2_ext_1),
        .is_esd2_ext_2   (is_esd2_ext_2),
        .is_esd_ext_err  (is_esd_ext_err),
        .is_csextend     (is_csextend),
        .is_csextend_err (is_csextend_err),
        
        .t_symb          (mapped_symb)
    );

    pcs_sign_reversal u_sign_rev (
        .t_symb          (mapped_symb),
        .sgn             (sg_n),
        .tx_en_n2        (tx_en_n2),
        .tx_en_n4        (tx_en_n4),
        .final_symb      (tx_symb_vector)
    );

endmodule