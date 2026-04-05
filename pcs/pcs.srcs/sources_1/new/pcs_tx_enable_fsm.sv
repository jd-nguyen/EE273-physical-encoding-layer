`timescale 1ns / 1ps

// Table 40-8 PCS Data Transmission Enable implementation

module pcs_tx_enable_fsm
import pcs_types_pkg::*;
(
    input  logic         clk,
    input  logic         reset_n,      // Hardware reset
    input  logic         pcs_reset,    // Software/management reset
    input  logic         link_status_ok, // OK = 1, FAIL = 0
    input  tx_mode_t     tx_mode,      // SEND_N, SEND_I, SEND_Z
    input  logic         tx_en,        // GMII TX_EN
    input  logic         tx_er,        // GMII TX_ER
    
    output logic         tx_enable,
    output logic         tx_error
);

    typedef enum logic {
        DISABLE_DATA_TRANSMISSION = 1'b0,
        ENABLE_DATA_TRANSMISSION  = 1'b1
    } state_t;

    state_t current_state, next_state;

    // -------------------------------------------------------------------------
    // 1. Sequential Logic (State Register)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= DISABLE_DATA_TRANSMISSION;
        end else if (pcs_reset || !link_status_ok) begin // "pcs_reset = ON + link_status = FAIL"
            current_state <= DISABLE_DATA_TRANSMISSION;
        end else begin
            current_state <= next_state;
        end
    end

    // -------------------------------------------------------------------------
    // 2. Combinational Logic (Next State)
    // -------------------------------------------------------------------------
    always_comb begin
        next_state = current_state; // Default hold

        case (current_state)
            DISABLE_DATA_TRANSMISSION: begin
                // Transition condition: tx_mode = SEND_N * TX_EN = FALSE * TX_ER = FALSE
                if ((tx_mode == SEND_N) && !tx_en && !tx_er) begin
                    next_state = ENABLE_DATA_TRANSMISSION;
                end
            end

            ENABLE_DATA_TRANSMISSION: begin
                // Loop condition is tx_mode = SEND_N. 
                // Exit condition: tx_mode != SEND_N
                if (tx_mode != SEND_N) begin
                    next_state = DISABLE_DATA_TRANSMISSION;
                end
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // 3. Output Logic
    // -------------------------------------------------------------------------
    always_comb begin
        // Default outputs
        tx_enable = 1'b0;
        tx_error  = 1'b0;

        case (current_state)
            DISABLE_DATA_TRANSMISSION: begin
                tx_enable = 1'b0;
                tx_error  = 1'b0;
            end

            ENABLE_DATA_TRANSMISSION: begin
                tx_enable = tx_en;
                tx_error  = tx_er;
            end
        endcase
    end

endmodule