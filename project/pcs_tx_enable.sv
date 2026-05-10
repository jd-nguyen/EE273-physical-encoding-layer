// prof DUT has no tx_mode input and no TX_ER. TX_EN feeds into pipeline and FSM

module pcs_tx_enable (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       gmii_tx_en,
    input  logic       gmii_tx_er,    // tied to 0
    input  logic [1:0] tx_mode,       // ignored (always SEND_N)
    input  logic       link_status,   // ignored (always up)
    input  logic       pcs_reset,     // ignored

    output logic       tx_enable,
    output logic       tx_error
);

    // direct pass-through — no gating
    assign tx_enable = gmii_tx_en;
    assign tx_error  = 1'b0;

endmodule
