`timescale 1ns / 1ps
module pcs_1000base_t_top (
    input logic reset_n, // Hardware reset (pcs_reset = ON when low)
    
    // Interface ports
    gmii_if.dut gmii,
    pma_if.dut  pma
);
    import pcs_types_pkg::*;

    // Internal routing signals (Phase 5/6 integration)
    logic tx_enable;
    logic tx_error;
    logic _1000BTtransmit;
    logic _1000BTreceive;

    // =========================================================================
    // Next: sub-module Instantiations. First, use simplified version of scrambler, can implement full side-stream scrambler later
    // =========================================================================

    // Phase 2 & 3: PCS Transmit Function
    // Includes Side-stream Scrambler, Data Enable, and Symbol Encoder
    /*
    pcs_transmit_block u_pcs_tx (
        .clk             (gmii.gtx_clk),
        .reset_n         (reset_n),
        .gmii            (gmii),
        .pma             (pma),
        .tx_enable_out   (tx_enable),
        .tx_error_out    (tx_error),
        ._1000BTtransmit (_1000BTtransmit)
    );
    */

    // Phase 4: PCS Receive Function
    // Includes Symbol Decoder, Descrambler, and Receive State Machine
    /*
    pcs_receive_block u_pcs_rx (
        .clk             (pma.symb_clk),
        .reset_n         (reset_n),
        .pma             (pma),
        .gmii            (gmii),
        ._1000BTreceive  (_1000BTreceive)
    );
    */

    // Phase 5: Carrier Sense Function
    /*
    pcs_carrier_sense u_pcs_crs (
        .clk             (gmii.gtx_clk), // or asynchronous depending on implementation
        .reset_n         (reset_n),
        ._1000BTtransmit (_1000BTtransmit),
        ._1000BTreceive  (_1000BTreceive),
        .crs_out         (gmii.crs)
    );
    */

endmodule