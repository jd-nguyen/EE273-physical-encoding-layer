`timescale 1ns / 1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

import pcs_sym_table_pkg::*;
import gmii_tx_pkg::*;

module tb_top;

    logic clk;
    logic reset;  // Active HIGH

    initial clk = 0;
    always #4 clk = ~clk;  // 125 MHz

    initial begin
        reset = 1;
        #80;
        reset = 0;
    end

    gmii_if gmii (
        .gtx_clk(clk),
        .rx_clk(clk)
    );

    logic [3:0][2:0] dut_dout;

    DUTS26_0 u_dut (
        .Clk    (clk),
        .Reset  (reset),
        .Din    (gmii.txd),
        .TX_EN  (gmii.tx_en),
        .Dout   (dut_dout)
    );

    logic signed [2:0] ref_a, ref_b, ref_c, ref_d;
    logic              ref_transmitting, ref_col, ref_crs;
    logic              ref_loc_lpi_req;
    logic [8:0]        ref_sd_debug;
    logic [7:0]        ref_sc_debug;
    logic [32:0]       ref_scr_state;

    pcs_tx_top u_ref (
        .clk              (clk),
        .rst_n            (~reset),
        .pcs_reset        (1'b0),
        .link_status      (1'b1),
        .tx_mode          (2'd2),
        .config_master    (1'b1),
        .gmii_txd         (gmii.txd),
        .gmii_tx_en       (gmii.tx_en),
        .gmii_tx_er       (1'b0),
        .gmii_col         (ref_col),
        .gmii_crs         (ref_crs),
        .receiving        (1'b0),
        .repeater_mode    (1'b0),
        .loc_rcvr_status  (1'b1),
        .loc_update_done  (1'b1),
        .scr_init         (33'h0_0000_0001),
        .scr_init_load    (1'b0),
        .sym_a            (ref_a),
        .sym_b            (ref_b),
        .sym_c            (ref_c),
        .sym_d            (ref_d),
        .transmitting     (ref_transmitting),
        .loc_lpi_req      (ref_loc_lpi_req),
        .sd_debug         (ref_sd_debug),
        .sc_debug         (ref_sc_debug),
        .scr_state_debug  (ref_scr_state)
    );

    dut_if dut_obs (
        .clk   (clk),
        .reset (reset)
    );

    assign dut_obs.dout  = dut_dout;
    assign dut_obs.ref_a = ref_a;
    assign dut_obs.ref_b = ref_b;
    assign dut_obs.ref_c = ref_c;
    assign dut_obs.ref_d = ref_d;
    assign dut_obs.din   = gmii.txd;
    assign dut_obs.tx_en = gmii.tx_en;

    initial begin
        // GMII interface for driver/monitor
        uvm_config_db#(virtual gmii_if)::set(null, "*", "vif", gmii);

        // DUT observation interface for scoreboard
        uvm_config_db#(virtual dut_if)::set(null, "*", "dut_vif", dut_obs);

        run_test("gmii_test");
    end

    initial begin
        $dumpfile("pcs_dut_tb.vcd");
        $dumpvars(0, tb_top);
    end

endmodule
