`timescale 1ns / 1ps

module tb_pcs_loopback;
    import pcs_types_pkg::*;

    // -------------------------------------------------------------------------
    // TB Signals
    // -------------------------------------------------------------------------
    logic clk;
    logic reset_n;
    logic pcs_reset;

    // GMII TX (Stimulus)
    logic       gmii_tx_en;
    logic       gmii_tx_er;
    logic [7:0] gmii_txd;

    // GMII RX (Outputs)
    logic       gmii_rx_dv;
    logic       gmii_rx_er;
    logic [7:0] gmii_rxd;

    // The Physical Medium (Loopback Wire)
    symb_4d_t   loopback_symb;

    // -------------------------------------------------------------------------
    // Clock Generation (125 MHz)
    // -------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #4 clk = ~clk; 
    end

    // -------------------------------------------------------------------------
    // 1. Instantiating the TRANSMITTER (Configured as MASTER)
    // -------------------------------------------------------------------------
    pcs_tx_block tx_phy (
        .clk             (clk), 
        .reset_n         (reset_n),
        .pcs_reset       (pcs_reset),
        
        .config_mode     (MASTER),    // <--- MUST BE MASTER
        .tx_mode         (SEND_N),
        .link_status_ok  (1'b1),
        
        .tx_en           (gmii_tx_en),
        .tx_er           (gmii_tx_er),
        .txd             (gmii_txd),
        
        ._1000BTreceive  (1'b0),
        .loc_lpi_req     (1'b0),     
        .loc_update_done (1'b1), 
        
        .tx_symb_vector  (loopback_symb), // <--- Driving the loopback wire
        ._1000BTtransmit (),
        .col             ()
    );

    // -------------------------------------------------------------------------
    // 2. Instantiating the RECEIVER (Configured as SLAVE)
    // -------------------------------------------------------------------------
    pcs_rx_block rx_phy (
        .clk             (clk),  
        .reset_n         (reset_n),
        .pcs_reset       (pcs_reset),
        
        .config_mode     (SLAVE),     // <--- MUST BE SLAVE
        .link_status_ok  (1'b1),
        
        .rx_symb_vector  (loopback_symb), // <--- Receiving from the loopback wire
        
        .rxd             (gmii_rxd),
        .rx_dv           (gmii_rx_dv),
        .rx_er           (gmii_rx_er),
        
        ._1000BTreceive  ()
    );

    // -------------------------------------------------------------------------
    // Data Latency Tracker (For Scoreboarding)
    // -------------------------------------------------------------------------
    // The TX pipeline and RX pipeline introduce several cycles of latency.
    // To automatically check the data, we must delay the TX stimulus to align
    // with the RX outputs. (Adjust the depth based on your exact pipeline).
    localparam LATENCY = 4; 
    
    logic [7:0] delayed_txd [LATENCY-1:0];
    logic       delayed_tx_en [LATENCY-1:0];

    always_ff @(posedge clk) begin
        delayed_txd[0]   <= gmii_txd;
        delayed_tx_en[0] <= gmii_tx_en;
        for (int i = 1; i < LATENCY; i++) begin
            delayed_txd[i]   <= delayed_txd[i-1];
            delayed_tx_en[i] <= delayed_tx_en[i-1];
        end
    end

    // Auto-Checker
    always_ff @(posedge clk) begin
        if (gmii_rx_dv && delayed_tx_en[LATENCY-1]) begin
            if (gmii_rxd !== delayed_txd[LATENCY-1]) begin
                $error("DATA MISMATCH! Time: %0t | Expected: %h | Received: %h", 
                        $time, delayed_txd[LATENCY-1], gmii_rxd);
            end
        end
    end

    // -------------------------------------------------------------------------
    // Main Stimulus
    // -------------------------------------------------------------------------
    initial begin
        $display("Starting PCS Datapath Loopback Simulation...");

        // Initialize Defaults
        reset_n    = 0;
        pcs_reset  = 0;
        gmii_tx_en = 0;
        gmii_tx_er = 0;
        gmii_txd   = 8'h00;

        // Apply Reset
        #20;
        reset_n = 1;
        #100; // Let IDLE symbols propagate and sync

        // Transmit a Frame
        $display("Transmitting GMII Frame...");
        
        // Preamble / SSD
        @(posedge clk); gmii_tx_en = 1; gmii_txd = 8'h55;
        @(posedge clk); gmii_txd = 8'hD5;
        
        // Payload Data
        @(posedge clk); gmii_txd = 8'hAA;
        @(posedge clk); gmii_txd = 8'hBB;
        @(posedge clk); gmii_txd = 8'hCC;
        @(posedge clk); gmii_txd = 8'hDD;

        
        // End of Stream / ESD
        @(posedge clk); gmii_tx_en = 0; gmii_txd = 8'h00;

        // Wait for pipeline to flush
        #200;
        
        $display("Simulation Complete. Check waveform and console for mismatches.");
        $finish;
    end

endmodule