// FSM using DUTS26_0 logic:
//   RESET → IDLE → SDD2 → DATA → CSR2 → ESD1 → ESD2 → IDLE
// SDD1 symbols output during IDLE→SDD2 transition
// first CSReset symbols output during DATA→CSR2 transition

import pcs_sym_table_pkg::*;

module pcs_tx_fsm (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_enable,       // raw TX_EN from GMII
    input  logic        tx_error,        // tied to 0
    input  logic [7:0]  txd,
    input  logic        receiving,       // tied to 0

    output sym_condition_t condition,    // to pipeline - which lookup to use
    output logic        transmitting,
    output logic        col              // collision (always 0)
);

    typedef enum logic [3:0] {
        ST_RESET,
        ST_SEND_IDLE,
        ST_SDD2,
        ST_TRANSMIT_DATA,
        ST_CSR2,
        ST_ESD1,
        ST_ESD2
    } state_t;

    state_t cstate, nstate;

    always_comb begin
        nstate = cstate;
        condition = COND_IDLE;
        col = 1'b0;

        case (cstate)
            ST_RESET: begin
                condition = COND_IDLE;
                nstate = ST_SEND_IDLE;
            end

            ST_SEND_IDLE: begin
                if (tx_enable) begin
                    condition = COND_SSD1;      // output SDD1 pattern
                    nstate = ST_SDD2;
                end else begin
                    condition = COND_IDLE;
                end
            end

            ST_SDD2: begin
                condition = COND_SSD2;
                nstate = ST_TRANSMIT_DATA;
            end

            ST_TRANSMIT_DATA: begin
                if (tx_enable) begin
                    condition = COND_NORMAL;     // normal data
                end else begin
                    condition = COND_CSRESET;    // first CSReset cycle
                    nstate = ST_CSR2;
                end
            end

            ST_CSR2: begin
                condition = COND_CSRESET;        // second CSReset cycle
                nstate = ST_ESD1;
            end

            ST_ESD1: begin
                condition = COND_ESD1;
                nstate = ST_ESD2;
            end

            ST_ESD2: begin
                condition = COND_ESD2_EXT_0;
                nstate = ST_SEND_IDLE;
            end

            default: begin
                condition = COND_IDLE;
                nstate = ST_SEND_IDLE;
            end
        endcase
    end

    // transmitting flag
    always_comb begin
        transmitting = (cstate != ST_SEND_IDLE) &&
                       (cstate != ST_RESET) &&
                       (cstate != ST_ESD2);
    end

    // state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cstate <= ST_RESET;
        else
            cstate <= nstate;
    end

endmodule