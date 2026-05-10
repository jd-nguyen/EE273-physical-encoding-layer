import pcs_sym_table_pkg::*;

module pcs_tx_top (
    input  logic        clk,
    input  logic        rst_n,

    // config
    input  logic        pcs_reset,
    input  logic        link_status,
    input  logic [1:0]  tx_mode,
    input  logic        config_master,

    // GMII inputs
    input  logic [7:0]  gmii_txd,
    input  logic        gmii_tx_en,
    input  logic        gmii_tx_er,     // Tied to 0 for DUTS26_0

    // GMII outputs
    output logic        gmii_col,
    output logic        gmii_crs,

    // status inputs
    input  logic        receiving,
    input  logic        repeater_mode,
    input  logic        loc_rcvr_status,
    input  logic        loc_update_done,

    // scrambler init (using 33'h0_0000_0001 for DUTS26_0)
    input  logic [32:0] scr_init,
    input  logic        scr_init_load,

    // symbol outputs
    output logic signed [2:0] sym_a,
    output logic signed [2:0] sym_b,
    output logic signed [2:0] sym_c,
    output logic signed [2:0] sym_d,

    // status outputs
    output logic        transmitting,
    output logic        loc_lpi_req,

    // debug
    output logic [8:0]  sd_debug,
    output logic [7:0]  sc_debug,
    output logic [32:0] scr_state_debug
);

    // internal wires
    logic             tx_enable;
    logic             tx_error;
    sym_condition_t   condition;
    logic             fsm_col;

    // tx enable
    pcs_tx_enable u_enable (
        .clk         (clk),
        .rst_n       (rst_n),
        .gmii_tx_en  (gmii_tx_en),
        .gmii_tx_er  (gmii_tx_er),
        .tx_mode     (tx_mode),
        .link_status (link_status),
        .pcs_reset   (pcs_reset),
        .tx_enable   (tx_enable),
        .tx_error    (tx_error)
    );

    // tx fsm
    pcs_tx_fsm u_fsm (
        .clk          (clk),
        .rst_n        (rst_n),
        .tx_enable    (tx_enable),
        .tx_error     (tx_error),
        .txd          (gmii_txd),
        .receiving    (receiving),
        .condition    (condition),
        .transmitting (transmitting),
        .col          (fsm_col)
    );

    // tx pipeline
    pcs_tx_pipeline u_pipeline (
        .clk              (clk),
        .rst_n            (rst_n),
        .config_master    (config_master),
        .txd              (gmii_txd),
        .tx_enable        (tx_enable),
        .tx_error         (tx_error),
        .tx_mode          (tx_mode),
        .loc_rcvr_status  (loc_rcvr_status),
        .loc_lpi_req      (1'b0),
        .loc_update_done  (loc_update_done),
        .condition        (condition),
        .scr_init         (scr_init),
        .scr_init_load    (scr_init_load),
        .sym_a            (sym_a),
        .sym_b            (sym_b),
        .sym_c            (sym_c),
        .sym_d            (sym_d),
        .sd_debug         (sd_debug),
        .sc_debug         (sc_debug),
        .scr_state_debug  (scr_state_debug)
    );

    // lpi
    assign loc_lpi_req = 1'b0;

    // crs/col
    assign gmii_col = fsm_col;
    assign gmii_crs = transmitting | receiving;

endmodule
