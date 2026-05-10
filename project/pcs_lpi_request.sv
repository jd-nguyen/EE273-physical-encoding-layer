// Detects GMII LPI indication pattern:
//   TX_EN=FALSE, TX_ER=TRUE, TXD<7:0>=0x01, 1000BTtransmit=FALSE
//
// LOC LPI REQ OFF → ON: All four conditions met simult.
//
// LOC LPI REQ ON → OFF:
//   Any one of: TX_EN=TRUE, TX_ER=FALSE, TXD \neq 0x01, 1000BTtransmit=TRUE

module pcs_lpi_request (
    input  logic       clk,
    input  logic       rst_n,

    input  logic       pcs_reset,
    input  logic       link_status,     // 1=OK
    input  logic       gmii_tx_en,      // TX_EN (raw, not gated)
    input  logic       gmii_tx_er,      // TX_ER (raw)
    input  logic [7:0] txd,             // TXD<7:0>
    input  logic       transmitting,    // 1000BTtransmit

    output logic       loc_lpi_req      // LPI request to PMA
);

    typedef enum logic {
        S_OFF = 1'b0,
        S_ON  = 1'b1
    } state_t;

    state_t state, state_next;

    // LPI pattern detection
    logic lpi_pattern;
    assign lpi_pattern = !gmii_tx_en && gmii_tx_er &&
                         (txd == 8'h01) && !transmitting;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_OFF;
        else
            state <= state_next;
    end

    always_comb begin
        state_next = state;

        if (pcs_reset || !link_status) begin
            state_next = S_OFF;
        end else begin
            case (state)
                S_OFF: begin
                    if (lpi_pattern)
                        state_next = S_ON;
                end

                S_ON: begin
                    if (!lpi_pattern)
                        state_next = S_OFF;
                end
            endcase
        end
    end

    assign loc_lpi_req = (state == S_ON);

endmodule
