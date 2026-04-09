`timescale 1ns / 1ps

module pcs_1000base_t_top (
    input logic reset_n, // Hardware reset (pcs_reset = ON when low)
    input logic sw_reset_req, // Software reset (Management entity request)
    
    // Interface ports
    gmii_if.dut gmii,
    pma_if.dut  pma
);
    import pcs_types_pkg::*;

    // Internal routing flags
    logic _1000BTtransmit;
    logic _1000BTreceive; 
    logic pcs_reset;
    


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
     // .col             (gmii.col)
        .col             ()
    );
    

    // Phase 4: PCS Receive Function
    // Includes Symbol Decoder, Descrambler, and Receive State Machine
    // =========================================================================
    // Receive Path Instantiation (Phase 4)
    // =========================================================================
    pcs_rx_block u_pcs_rx (
        .clk             (pma.symb_clk),  // Nominal 125 MHz recovered clock
        .reset_n         (reset_n),
        .pcs_reset       (pcs_reset),
        
        // Configuration from PMA interface
        .config_mode     (pma.m_s_config),
        .link_status_ok  (pma.link_status),
        
        // Incoming Symbols from PMA interface
        .rx_symb_vector  (pma.rx_symb_vector),
        
        // Decoded Data and Control driving the GMII interface
        .rxd             (gmii.rxd),
        .rx_dv           (gmii.rx_dv),
        .rx_er           (gmii.rx_er),
        
        // Cross-domain output to Carrier Sense / TX FSM
        ._1000BTreceive  (_1000BTreceive)
    );
    

    // =========================================================================
    // Control & Status (Phase 5)
    // =========================================================================
    pcs_reset_controller u_pcs_reset_ctrl (
        .clk          (gmii.gtx_clk),
        .reset_n      (reset_n),
        .sw_reset_req (sw_reset_req),
        .pcs_reset    (pcs_reset)
    );
    
    pcs_carrier_sense u_pcs_carrier_sense (
        ._1000BTtransmit (_1000BTtransmit),
        ._1000BTreceive  (_1000BTreceive),
        .crs             (gmii.crs),
        .col             (gmii.col)
    );

endmodule