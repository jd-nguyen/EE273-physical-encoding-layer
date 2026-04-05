`timescale 1ns / 1ps

module pcs_transmit_fsm (
    input  logic       clk,             // GTX_CLK / symb_timer (125 MHz)
    input  logic       reset_n,         // Hardware reset
    input  logic       pcs_reset,       // Management reset condition
    
    // Inputs from GMII and TX Enable FSM
    input  logic       tx_enable,       // From pcs_tx_enable_fsm
    input  logic       tx_error,        // From pcs_tx_enable_fsm
    input  logic [7:0] txd,             // GMII TXD<7:0>
    input  logic       _1000BTreceive,  // From PCS Receive function
    
    // Protocol Status Outputs
    output logic       _1000BTtransmit, // Indicates frame transmission in progress
    output logic       col,             // GMII Collision signal
    
    // Control Flags for pcs_symbol_mapper
    output logic       is_idle,
    output logic       is_ssd1,
    output logic       is_ssd2,
    output logic       is_xmt_err,
    output logic       is_tx_data,
    output logic       is_csreset,
    output logic       is_esd1,
    output logic       is_esd2_ext_0,
    output logic       is_esd2_ext_1,
    output logic       is_esd2_ext_2,
    output logic       is_esd_ext_err,
    output logic       is_csextend,
    output logic       is_csextend_err,
    output logic       is_cext,
    output logic       is_cext_err
);

    // -------------------------------------------------------------------------
    // State Enumerations
    // -------------------------------------------------------------------------
    typedef enum logic [4:0] {
        ST_SEND_IDLE,
        ST_SSD1,
        ST_SSD1_ERR,
        ST_SSD2,
        ST_SSD2_ERR,
        ST_TX_DATA,
        ST_TX_ERR,
        ST_CSRESET_1,
        ST_CSRESET_2,
        ST_ESD1,
        ST_ESD2_EXT_0,
        ST_CSEXT_1,
        ST_CSEXT_2,
        ST_ESD1_EXT,
        ST_ESD2_EXT,
        ST_ESD2_EXT_1,
        ST_CARRIER_EXT
    } tx_state_t;

    tx_state_t current_state, next_state;

    // -------------------------------------------------------------------------
    // 1. Sequential Logic (State Register & 1000BTtransmit tracking)
    // -------------------------------------------------------------------------
    // The variable 1000BTtransmit is updated sequentially upon entering specific 
    // states as defined by Figure 40-10.
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state   <= ST_SEND_IDLE;
            _1000BTtransmit <= 1'b0;
        end else if (pcs_reset) begin
            current_state   <= ST_SEND_IDLE;
            _1000BTtransmit <= 1'b0;
        end else begin
            current_state <= next_state;
            
            // 1000BTtransmit Assignment Tracking
            if (next_state == ST_SSD1 || next_state == ST_SSD1_ERR) begin
                _1000BTtransmit <= 1'b1;
            end else if (next_state == ST_SEND_IDLE  || next_state == ST_CSRESET_1 || 
                         next_state == ST_CSRESET_2  || next_state == ST_ESD1 || 
                         next_state == ST_ESD2_EXT_1) begin
                _1000BTtransmit <= 1'b0;
            end
            // For all other states, it holds its previous value.
        end
    end

    // -------------------------------------------------------------------------
    // 2. Combinational Logic (Next State Transitions)
    // -------------------------------------------------------------------------
    // Note: The 'STD' (symb_timer_done) condition is implicitly handled by the 
    // posedge clk transition in the sequential block above[cite: 559].
    always_comb begin
        next_state = current_state; 

        case (current_state)
            ST_SEND_IDLE: begin
                if (tx_enable && !tx_error)      next_state = ST_SSD1;
                else if (tx_enable && tx_error)  next_state = ST_SSD1_ERR;
            end

            ST_SSD1: begin
                if (!tx_error)                   next_state = ST_SSD2;
                else                             next_state = ST_SSD2_ERR;
            end

            ST_SSD1_ERR: begin
                next_state = ST_SSD2_ERR;
            end

            // The following states all funnel into the "ERROR CHECK" block 
            // which evaluates tx_enable and tx_error for the next transition.
            ST_SSD2, ST_SSD2_ERR, ST_TX_DATA, ST_TX_ERR: begin
                if (tx_enable && !tx_error)      next_state = ST_TX_DATA;
                else if (tx_enable && tx_error)  next_state = ST_TX_ERR; 
                else if (!tx_enable && !tx_error)next_state = ST_CSRESET_1;
                else if (!tx_enable && tx_error) next_state = ST_CSEXT_1;
            end

            ST_CSRESET_1: begin
                next_state = ST_CSRESET_2;
            end

            ST_CSRESET_2: begin
                next_state = ST_ESD1;
            end

            ST_ESD1: begin
                next_state = ST_ESD2_EXT_0;
            end

            ST_ESD2_EXT_0, ST_ESD2_EXT_1: begin
                next_state = ST_SEND_IDLE; // Routes to connector A [cite: 656, 710]
            end

            ST_CSEXT_1: begin
                if (!tx_error)                   next_state = ST_ESD1_EXT;
                else                             next_state = ST_CSEXT_2;
            end

            ST_CSEXT_2, ST_ESD1_EXT: begin
                if (!tx_error)                   next_state = ST_ESD2_EXT_1;
                else                             next_state = ST_ESD2_EXT;
            end

            ST_ESD2_EXT: begin
                if (!tx_error)                   next_state = ST_SEND_IDLE;   // Connector A 
                else                             next_state = ST_CARRIER_EXT; // Connector B 
            end

            ST_CARRIER_EXT: begin
                if (tx_enable && !tx_error)      next_state = ST_TX_DATA;     // Connector C 
                else if (tx_enable && tx_error)  next_state = ST_TX_ERR;      // Connector D 
                else if (!tx_enable && !tx_error)next_state = ST_SEND_IDLE;   // Connector A 
                // Loops back to ST_CARRIER_EXT on (!tx_enable && tx_error)
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // 3. Output Logic (Mapper Flags & Collision)
    // -------------------------------------------------------------------------
    always_comb begin
        // Default all flags to 0
        is_idle         = 1'b0; is_ssd1         = 1'b0; is_ssd2         = 1'b0;
        is_xmt_err      = 1'b0; is_tx_data      = 1'b0; is_csreset      = 1'b0;
        is_esd1         = 1'b0; is_esd2_ext_0   = 1'b0; is_esd2_ext_1   = 1'b0;
        is_esd2_ext_2   = 1'b0; is_esd_ext_err  = 1'b0; is_csextend     = 1'b0;
        is_csextend_err = 1'b0; is_cext         = 1'b0; is_cext_err     = 1'b0;
        col             = 1'b0; 

        case (current_state)
            ST_SEND_IDLE: begin
                is_idle = 1'b1; 
            end
            ST_SSD1, ST_SSD1_ERR: begin
                is_ssd1 = 1'b1;
                col     = _1000BTreceive; 
            end
            ST_SSD2, ST_SSD2_ERR: begin
                is_ssd2 = 1'b1;
                col     = _1000BTreceive; 
            end
            ST_TX_DATA: begin
                is_tx_data = 1'b1;
                col        = _1000BTreceive;
            end
            ST_TX_ERR: begin
                is_xmt_err = 1'b1;
                col        = _1000BTreceive; 
            end
            ST_CSRESET_1, ST_CSRESET_2: begin
                is_csreset = 1'b1; 
            end
            ST_ESD1: begin
                is_esd1 = 1'b1; 
            end
            ST_ESD2_EXT_0: begin
                is_esd2_ext_0 = 1'b1;
            end
            ST_ESD2_EXT_1: begin
                is_esd2_ext_1 = 1'b1;
            end
            
            // Extension evaluation based on GMII TXD<7:0> == 0x0F
            ST_CSEXT_1, ST_CSEXT_2: begin
                col = _1000BTreceive;
                if (txd == 8'h0F) is_csextend     = 1'b1;
                else              is_csextend_err = 1'b1;
            end
            ST_ESD1_EXT: begin
                col = _1000BTreceive; 
                if (txd == 8'h0F) is_esd1         = 1'b1; // Standard ESD1 used here
                else              is_esd_ext_err  = 1'b1; 
            end
            ST_ESD2_EXT: begin
                col = _1000BTreceive; 
                if (txd == 8'h0F) is_esd2_ext_2   = 1'b1; 
                else              is_esd_ext_err  = 1'b1; 
            end
            ST_CARRIER_EXT: begin
                col = _1000BTreceive;
                if (txd == 8'h0F) is_cext         = 1'b1;
                else              is_cext_err     = 1'b1;
            end
        endcase
    end

endmodule