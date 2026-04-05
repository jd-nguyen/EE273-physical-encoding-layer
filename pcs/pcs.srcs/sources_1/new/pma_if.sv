interface pma_if (
    input logic symb_clk // Nominal 125 MHz (8ns period) symbol clock
);
    import pcs_types_pkg::*;

    // Data Vectors
    symb_4d_t  tx_symb_vector; // To PMA
    symb_4d_t  rx_symb_vector; // From PMA

    // Management & Control Signals
    config_mode_t m_s_config;      // MASTER or SLAVE
    tx_mode_t     tx_mode;         // Transmit mode
    logic         link_status;     // Link monitor status
    logic         loc_rcvr_status; // Local receiver status
    logic         rem_rcvr_status; // Remote receiver status
    logic         scr_status;      // Scrambler status
    logic         loc_update_done; // Local update done
    logic         rem_update_done; // Remote update done

    // Optional EEE Signals (Can tie off if not used)
    logic         loc_lpi_req; 
    logic         rem_lpi_req;
    logic         lpi_mode;

    // Modport for the DUT
    modport dut (
        input  symb_clk, rx_symb_vector, m_s_config, tx_mode, link_status, 
               loc_rcvr_status, rem_rcvr_status, lpi_mode, rem_update_done,
        output tx_symb_vector, scr_status, loc_update_done, 
               loc_lpi_req, rem_lpi_req
    );
endinterface