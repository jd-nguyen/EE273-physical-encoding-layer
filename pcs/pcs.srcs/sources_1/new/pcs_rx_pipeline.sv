`timescale 1ns / 1ps

module pcs_rx_pipeline (
    input  logic       clk,
    input  logic       reset_n,
    input  logic       pcs_reset,

    // -------------------------------------------------------------------------
    // Inputs: Time 'n' (Directly from pcs_rx_symbol_decoder)
    // -------------------------------------------------------------------------
    input  logic [7:0] rxd_n,
    input  logic       is_idle_n,
    input  logic       is_ssd1_n,
    input  logic       is_ssd2_n,
    input  logic       is_csreset_n,
    input  logic       is_csextend_n,
    input  logic       is_esd1_n,
    input  logic       is_esd2_ext_0_n,
    input  logic       is_xmt_err_n,

    // -------------------------------------------------------------------------
    // Outputs: Time 'n-1' (Delayed 1 Cycle)
    // -------------------------------------------------------------------------
    output logic [7:0] rxd_n1,
    output logic       is_idle_n1,
    output logic       is_ssd1_n1,
    output logic       is_ssd2_n1,
    output logic       is_esd1_n1,
    output logic       is_csreset_n1,
    output logic       is_csextend_n1,
    output logic       is_xmt_err_n1,

    // -------------------------------------------------------------------------
    // Outputs: Time 'n-2' (Delayed 2 Cycles)
    // -------------------------------------------------------------------------
    output logic [7:0] rxd_n2,
    output logic       is_ssd1_n2,
    output logic       is_esd1_n2,
    output logic       is_csreset_n2,

    // -------------------------------------------------------------------------
    // Outputs: Time 'n-3' (Delayed 3 Cycles)
    // -------------------------------------------------------------------------
    output logic [7:0] rxd_n3,
    output logic       is_esd1_n3
);

    // -------------------------------------------------------------------------
    // Synchronous Shift Register
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Hardware reset flush
            rxd_n1 <= 8'h00; is_idle_n1 <= 0; is_ssd1_n1 <= 0; is_ssd2_n1 <= 0;
            is_esd1_n1 <= 0; is_csreset_n1 <= 0; is_csextend_n1 <= 0; is_xmt_err_n1 <= 0;
            
            rxd_n2 <= 8'h00; is_ssd1_n2 <= 0; is_esd1_n2 <= 0; is_csreset_n2 <= 0;
            
            rxd_n3 <= 8'h00; is_esd1_n3 <= 0;
            
        end else if (pcs_reset) begin
            // Software/Management reset flush
            rxd_n1 <= 8'h00; is_idle_n1 <= 0; is_ssd1_n1 <= 0; is_ssd2_n1 <= 0;
            is_esd1_n1 <= 0; is_csreset_n1 <= 0; is_csextend_n1 <= 0; is_xmt_err_n1 <= 0;
            
            rxd_n2 <= 8'h00; is_ssd1_n2 <= 0; is_esd1_n2 <= 0; is_csreset_n2 <= 0;
            
            rxd_n3 <= 8'h00; is_esd1_n3 <= 0;
            
        end else begin
            // Shift stage 1 (n-1)
            rxd_n1         <= rxd_n;
            is_idle_n1     <= is_idle_n;
            is_ssd1_n1     <= is_ssd1_n;
            is_ssd2_n1     <= is_ssd2_n;
            is_esd1_n1     <= is_esd1_n;
            is_csreset_n1  <= is_csreset_n;
            is_csextend_n1 <= is_csextend_n;
            is_xmt_err_n1  <= is_xmt_err_n;

            // Shift stage 2 (n-2)
            rxd_n2         <= rxd_n1;
            is_ssd1_n2     <= is_ssd1_n1;
            is_esd1_n2     <= is_esd1_n1;
            is_csreset_n2  <= is_csreset_n1;

            // Shift stage 3 (n-3)
            rxd_n3         <= rxd_n2;
            is_esd1_n3     <= is_esd1_n2;
        end
    end

endmodule