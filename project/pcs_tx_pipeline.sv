import pcs_sym_table_pkg::*;

module pcs_tx_pipeline (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        config_master,
    input  logic [7:0]  txd,
    input  logic        tx_enable,      // Raw TX_EN
    input  logic        tx_error,       // Tied to 0
    input  logic [1:0]  tx_mode,
    input  logic        loc_rcvr_status,
    input  logic        loc_lpi_req,
    input  logic        loc_update_done,
    input  sym_condition_t condition,
    input  logic [32:0] scr_init,
    input  logic        scr_init_load,
    output logic signed [2:0] sym_a,
    output logic signed [2:0] sym_b,
    output logic signed [2:0] sym_c,
    output logic signed [2:0] sym_d,
    output logic [8:0]  sd_debug,
    output logic [7:0]  sc_debug,
    output logic [32:0] scr_state_debug
);

    // registers
    logic [32:0] scr;
    logic [3:0]  synm1;
    logic [4:0]  tx_en_pipe;
    logic [2:0]  cs_reg;
    logic        oe;

    // scrambler
    function automatic logic [32:0] scrambler_master(logic [32:0] scrin);
        return {scrin[31:0], scrin[32] ^ scrin[12]};
    endfunction

    // combinational
    logic [3:0] sx, sy, sg;
    logic [7:0] sc;
    logic [8:0] sd;
    logic [2:0] cs_next;
    logic       csreset;
    logic       srev;
    logic [32:0] scr_next;
    logic [11:0] lookup_result;
    logic signed [2:0] post_a, post_b, post_c, post_d;
    logic signed [2:0] final_a, final_b, final_c, final_d;

    always_comb begin
        scr_next = scrambler_master(scr);

        // Scrambler taps (exact copy from DUTS26_0)
        sy[0] = scr[0];
        sy[1] = scr[3] ^ scr[8];
        sy[2] = scr[6] ^ scr[16];
        sy[3] = scr[9] ^ scr[14] ^ scr[19] ^ scr[24];

        sx[0] = scr[4] ^ scr[6];
        sx[1] = scr[7] ^ scr[9] ^ scr[12] ^ scr[14];
        sx[2] = scr[10] ^ scr[12] ^ scr[20] ^ scr[22];
        sx[3] = scr[13] ^ scr[15] ^ scr[18] ^ scr[20] ^
                scr[23] ^ scr[25] ^ scr[28] ^ scr[30];

        sg[0] = scr[1] ^ scr[5];
        sg[1] = scr[4] ^ scr[8] ^ scr[9] ^ scr[13];
        sg[2] = scr[7] ^ scr[11] ^ scr[17] ^ scr[21];
        sg[3] = scr[10] ^ scr[14] ^ scr[15] ^ scr[19] ^
                scr[20] ^ scr[24] ^ scr[25] ^ scr[29];

        // Sc (matches DUTS26_0)
        sc[7] = tx_en_pipe[2] ? sx[3] : 1'b0;
        sc[6] = tx_en_pipe[2] ? sx[2] : 1'b0;
        sc[5] = tx_en_pipe[2] ? sx[1] : 1'b0;
        sc[4] = tx_en_pipe[2] ? sx[0] : 1'b0;

        if (!oe) begin
            sc[3] = sy[3];
            sc[2] = sy[2];
            sc[1] = sy[1];
        end else begin
            sc[3] = ~synm1[3];
            sc[2] = ~synm1[2];
            sc[1] = ~synm1[1];
        end
        sc[0] = sy[0];

        // csreset from condition
        csreset = (condition == COND_CSRESET);

        // sd
        sd[7] = (csreset == 0 && tx_en_pipe[2]) ? (sc[7] ^ txd[7]) :
                (csreset ? cs_reg[1] : sc[7]);
        sd[6] = (csreset == 0 && tx_en_pipe[2]) ? (sc[6] ^ txd[6]) :
                (csreset ? cs_reg[1] : sc[6]);

        // conv encoder (matches profs DUT: CS[2]=Sd[7]^TXD[7])
        cs_next[2] = tx_en_pipe[2] ? (sd[7] ^ txd[7]) : 1'b0;
        cs_next[1] = tx_en_pipe[2] ? (sd[6] ^ cs_reg[1]) : 1'b0;
        cs_next[0] = cs_reg[2];

        sd[8] = cs_next[0];
        sd[5] = tx_en_pipe[2] ? (sc[5] ^ txd[5]) : sc[5];
        sd[4] = tx_en_pipe[2] ? (sc[4] ^ txd[4]) : sc[4];
        sd[3] = tx_en_pipe[2] ? (sc[3] ^ txd[3]) : sc[3];
        sd[2] = tx_en_pipe[2] ? (sc[2] ^ txd[2]) : sc[2];
        sd[1] = tx_en_pipe[2] ? (sc[1] ^ txd[1]) : (sc[1] ^ 1'b1);
        sd[0] = (sc[0] ^ tx_en_pipe[2]) ? txd[0] : 1'b0;

        // srev: addition (not using OR)
        srev = tx_en_pipe[4] + tx_en_pipe[2];

        // table lookup
        lookup_result = sym_lookup(condition, sd);
        post_a = signed'(lookup_result[11:9]);
        post_b = signed'(lookup_result[8:6]);
        post_c = signed'(lookup_result[5:3]);
        post_d = signed'(lookup_result[2:0]);

        // sign reversal
        final_a = (sg[0] ^ srev) ? -post_a : post_a;
        final_b = (sg[1] ^ srev) ? -post_b : post_b;
        final_c = (sg[2] ^ srev) ? -post_c : post_c;
        final_d = (sg[3] ^ srev) ? -post_d : post_d;

        sd_debug = sd;
        sc_debug = sc;
        scr_state_debug = scr;
    end

    // sequential
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            scr        <= 33'h0_0000_0001;  // Scr <= 1
            synm1      <= 4'b0;
            tx_en_pipe <= 5'b0;
            cs_reg     <= 3'b0;
            oe         <= 1'b1;             // OE <= 1
            sym_a      <= 3'sd0;
            sym_b      <= 3'sd0;
            sym_c      <= 3'sd0;
            sym_d      <= 3'sd0;
        end else if (scr_init_load) begin
            scr <= scr_init;
        end else begin
            scr        <= scr_next;
            synm1      <= sy;
            tx_en_pipe <= {tx_en_pipe[3:0], tx_enable};
            cs_reg     <= cs_next;
            oe         <= ~oe;
            sym_a      <= final_a;
            sym_b      <= final_b;
            sym_c      <= final_c;
            sym_d      <= final_d;
        end
    end

endmodule
