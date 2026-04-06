`timescale 1ns / 1ps

module pcs_1000base_t_top (
    input logic reset_n, // Hardware reset (pcs_reset = ON when low)
    input logic pcs_reset, // Software reset (Management entity request)
    
    // Interface ports
    gmii_if.dut gmii,
    pma_if.dut  pma
);
    import pcs_types_pkg::*;

    // Internal routing flags
    logic _1000BTtransmit;
    logic _1000BTreceive; 
    
    // Tie off the receive flag for now since we haven't built the RX path
    assign _1000BTreceive = 1'b0;
 

    // =========================================================================
    // Next: sub-module Instantiations. First, use simplified version of scrambler, can implement full side-stream scrambler later
    // =========================================================================

    // PCS Transmit Function
    // Includes Side-stream Scrambler, Data Enable, and Symbol Encoder
    
    pcs_tx_block u_pcs_tx (
        .clk             (gmii.gtx_clk), 
        .reset_n         (reset_n),
        .pcs_reset       (pcs_reset),
        
        // Configuration from PMA interface
        .config_mode     (pma.m_s_config),
        .tx_mode         (pma.tx_mode),
        .link_status_ok  (pma.link_status),
        
        // Data and Control from GMII interface
        .tx_en           (gmii.tx_en),
        .tx_er           (gmii.tx_er),
        .txd             (gmii.txd),
        
        // Cross-domain and Optional signals
        ._1000BTreceive  (_1000BTreceive),
        .loc_lpi_req     (pma.loc_lpi_req),     
        .loc_update_done (pma.loc_update_done), 
        
        // Outputs driving the interfaces
        .tx_symb_vector  (pma.tx_symb_vector),
        ._1000BTtransmit (_1000BTtransmit),
        .col             (gmii.col)
    );
    

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