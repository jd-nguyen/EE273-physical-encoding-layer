`timescale 1ns / 1ps

module pcs_receive_fsm (
    input  logic       clk,             // Recovered rx_clk (125 MHz)
    input  logic       reset_n,         // Hardware reset
    input  logic       pcs_reset,       // Management reset
    
    // Control & Status Inputs
    input  logic       link_status_ok,  // 1 = OK, 0 = FAIL
    
    // Pipeline Inputs (Time 'n' - Current instantaneous symbol)
    input  logic       is_idle_n,
    input  logic       is_ssd1_n,
    input  logic       is_ssd2_n,
    input  logic       is_esd1_n,
    input  logic       is_esd2_ext_0_n,
    input  logic       is_xmt_err_n,
    input  logic       is_csreset_n,
    
    // Pipeline Inputs (Time 'n-1' and 'n-2' - Delayed data)
    input  logic [7:0] rxd_n2,          // Descrambled data delayed by 2 clocks
    
    // GMII Interface Outputs
    output logic       rx_dv,
    output logic       rx_er,
    output logic [7:0] rxd,
    
    // Internal Routing Outputs
    output logic       _1000BTreceive,  // To Carrier Sense (Phase 5)
    output logic       rx_srev_n        // To Sign Decoder
);

    // -------------------------------------------------------------------------
    // State Enumerations (Using 5 bits to prevent rollover)
    // -------------------------------------------------------------------------
    typedef enum logic [4:0] {
        ST_LINK_FAILED,
        ST_IDLE,
        ST_CHECK_SSD1,
        ST_CHECK_SSD2,
        ST_DATA,
        ST_DATA_ERR,
        ST_ESD1,
        ST_ESD2,
        ST_FALSE_CARRIER,
        ST_CARRIER_EXT,
        ST_RX_ERROR
    } rx_state_t;

    rx_state_t current_state, next_state;

    // -------------------------------------------------------------------------
    // 1. Sequential Logic (State Register)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= ST_LINK_FAILED;
        end else if (pcs_reset || !link_status_ok) begin
            current_state <= ST_LINK_FAILED;
        end else begin
            current_state <= next_state;
        end
    end

    // -------------------------------------------------------------------------
    // 2. Combinational Logic (Next State Transitions)
    // -------------------------------------------------------------------------
    always_comb begin
        next_state = current_state; 

        case (current_state)
            ST_LINK_FAILED: begin
                if (link_status_ok) next_state = ST_IDLE;
            end

            ST_IDLE: begin
                if (is_ssd1_n) next_state = ST_CHECK_SSD1;
            end

            ST_CHECK_SSD1: begin
                if (is_ssd2_n) next_state = ST_CHECK_SSD2;
                else           next_state = ST_FALSE_CARRIER; // Invalid SSD sequence
            end

            ST_CHECK_SSD2: begin
                // At this point, the pipeline holds SSD1 at n-2, SSD2 at n-1. 
                // Time 'n' contains the first actual data symbol.
                next_state = ST_DATA;
            end

            ST_DATA: begin
                if (is_esd1_n) begin
                    next_state = ST_ESD1;
                end 
                else if (is_idle_n || is_xmt_err_n) begin
                    // Unexpected control symbol during payload
                    next_state = ST_DATA_ERR;
                end
            end

            ST_DATA_ERR: begin
                if (is_esd1_n) next_state = ST_ESD1;
                else if (is_idle_n) next_state = ST_IDLE; // Premature termination
            end

            ST_ESD1: begin
                // Looking at time 'n' to confirm the second half of the ESD sequence
                if (is_esd2_ext_0_n) next_state = ST_ESD2;
                else                 next_state = ST_RX_ERROR;
            end

            ST_ESD2: begin
                next_state = ST_IDLE; 
            end

            ST_FALSE_CARRIER: begin
                if (is_idle_n) next_state = ST_IDLE;
            end

            ST_RX_ERROR: begin
                if (is_idle_n) next_state = ST_IDLE;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // 3. Output Logic
    // -------------------------------------------------------------------------
    always_comb begin
        // Default assignments
        rx_dv          = 1'b0;
        rx_er          = 1'b0;
        rxd            = 8'h00;
        _1000BTreceive = 1'b0;
        rx_srev_n      = 1'b0; 

        case (current_state)
            ST_LINK_FAILED, ST_IDLE: begin
                rx_dv          = 1'b0;
                rx_er          = 1'b0;
                _1000BTreceive = 1'b0;
                rx_srev_n      = 1'b0;
            end

            ST_CHECK_SSD1, ST_CHECK_SSD2: begin
                rx_dv          = 1'b0;
                rx_er          = 1'b0;
                _1000BTreceive = 1'b1; // Carrier detected
                rx_srev_n      = 1'b1; // Turn on sign reversal for incoming data
            end

            ST_DATA: begin
                rx_dv          = 1'b1;
                rx_er          = 1'b0;
                rxd            = rxd_n2; // Output the descrambled data from the pipeline
                _1000BTreceive = 1'b1;
                rx_srev_n      = 1'b1;
            end

            ST_DATA_ERR: begin
                rx_dv          = 1'b1;
                rx_er          = 1'b1;   // Flag the error to the MAC
                rxd            = rxd_n2;
                _1000BTreceive = 1'b1;
                rx_srev_n      = 1'b1;
            end

            ST_ESD1, ST_ESD2: begin
                // During ESD, data valid drops. We don't send the ESD symbols to the MAC.
                rx_dv          = 1'b0;
                rx_er          = 1'b0;
                _1000BTreceive = 1'b1;
                rx_srev_n      = 1'b1;
            end

            ST_FALSE_CARRIER: begin
                rx_dv          = 1'b0;
                rx_er          = 1'b1;
                rxd            = 8'h0E;  // Standard GMII False Carrier encoding
                _1000BTreceive = 1'b1;
                rx_srev_n      = 1'b0;
            end

            ST_RX_ERROR: begin
                rx_dv          = 1'b0;
                rx_er          = 1'b1;
                _1000BTreceive = 1'b1;
                rx_srev_n      = 1'b1;
            end
        endcase
    end

endmodule