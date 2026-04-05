`timescale 1ns / 1ps

module tb_pcs_tx;
    import pcs_types_pkg::*;

    // -------------------------------------------------------------------------
    // TB Signals
    // -------------------------------------------------------------------------
    logic clk;
    logic reset_n;
    logic pcs_reset;

    // -------------------------------------------------------------------------
    // Clock Generation (125 MHz = 8ns nominal period)
    // -------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #4 clk = ~clk; 
    end

    // -------------------------------------------------------------------------
    // Interface Instantiations
    // -------------------------------------------------------------------------
    // Note: The TB drives the interfaces directly, acting as the MAC and PMA
    gmii_if gmii (
        .gtx_clk (clk), 
        .rx_clk  (clk)
    );
    
    pma_if pma (
        .symb_clk(clk)
    );

    // -------------------------------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------------------------------
    pcs_1000base_t_top dut (
        .reset_n   (reset_n),
        .pcs_reset (pcs_reset),
        .gmii      (gmii),
        .pma       (pma)
    );

    // -------------------------------------------------------------------------
    // Main Stimulus
    // -------------------------------------------------------------------------
    initial begin
        $display("Starting 1000BASE-T PCS TX Simulation...");

        // 1. Initialize Default State
        reset_n         = 0;
        pcs_reset       = 0;
        
        // Setup PMA Config
        pma.m_s_config      = MASTER;
        pma.tx_mode     = SEND_N;    // Normal data mode
        pma.link_status = 0;         // Link down initially
        
        // Setup GMII Inputs
        gmii.tx_en      = 0;
        gmii.tx_er      = 0;
        gmii.txd        = 8'h00;

        // 2. Apply Hardware Reset
        #20;
        reset_n = 1;
        #20;

        // 3. Bring Link Up
        $display("Bringing Link UP...");
        pma.link_status = 1;
        
        // Allow a few clock cycles for the FSM to transition to ENABLE_DATA_TRANSMISSION 
        // and SEND_IDLE
        #40; 

        // 4. Transmit a Short Frame
        $display("Asserting TX_EN. Sending dummy frame...");
        @(posedge clk);
        gmii.tx_en = 1;
        gmii.txd   = 8'h55; // Preamble byte 1 (Triggers SSD1)

        @(posedge clk);
        gmii.txd   = 8'hD5; // SFD (Triggers SSD2)

        @(posedge clk);
        gmii.txd   = 8'hDE; // Data byte 1

        @(posedge clk);
        gmii.txd   = 8'hAD; // Data byte 2
        
        @(posedge clk);
        gmii.txd   = 8'hBE; // Data byte 3

        @(posedge clk);
        gmii.txd   = 8'hEF; // Data byte 4

        // 5. End of Frame
        $display("De-asserting TX_EN. Triggering End-of-Stream...");
        @(posedge clk);
        gmii.tx_en = 0;
        gmii.txd   = 8'h00; // Triggers CSRESET 1 & 2, then ESD1 & ESD2

        // 6. Wait and Observe
        // Give the FSM time to flush the ESD and return to IDLE
        #100;
        
        $display("Simulation Complete.");
        $finish;
    end

    // -------------------------------------------------------------------------
    // Optional: FSM State Monitor
    // -------------------------------------------------------------------------
    // This probes into the DUT to print state changes to the console, 
    // saving you from having to hunt through the Vivado waveform viewer immediately.
    initial begin
        $monitor("Time: %0t | TX_EN: %b | TXD: %h || TX FSM State: %s | Out Symb: (A:%d, B:%d, C:%d, D:%d)", 
                 $time, gmii.tx_en, gmii.txd, 
                 dut.u_pcs_tx.u_transmit_fsm.current_state.name(),
                 pma.tx_symb_vector.A, pma.tx_symb_vector.B, 
                 pma.tx_symb_vector.C, pma.tx_symb_vector.D);
    end

endmodule