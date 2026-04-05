`timescale 1ns / 1ps

module pcs_rx_descrambler
import pcs_types_pkg::*;
(
    input  logic         clk,
    input  logic         reset_n,
    input  config_mode_t config_mode, // MASTER or SLAVE
    
    // Outputs for symbol decoding
    output logic [3:0]   sx_n,
    output logic [3:0]   sy_n,
    output logic [3:0]   sg_n,
    output logic         scr_0      
);

    logic [32:0] scr;
    logic        new_bit;

    assign scr_0 = scr[0];

    // -------------------------------------------------------------------------
    // LFSR & Master/Slave Polynomial Selection (Inverted from TX)
    // -------------------------------------------------------------------------
    always_comb begin
        if (config_mode == MASTER) begin
            // MASTER RX uses SLAVE TX polynomial: 1 + x^20 + x^33 
            new_bit = scr[19] ^ scr[32]; 
        end else begin
            // SLAVE RX uses MASTER TX polynomial: 1 + x^13 + x^33 
            new_bit = scr[12] ^ scr[32];
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // The descrambler state must also NOT be initialized to all zeros.
            scr <= 33'h1_FFFF_FFFF; 
        end else begin
            scr <= {scr[31:0], new_bit};
        end
    end

    // -------------------------------------------------------------------------
    // Auxiliary Bit Generation (Identical to TX)
    // -------------------------------------------------------------------------
    logic x_n, y_n;

    always_comb begin
        x_n = scr[4] ^ scr[6];
        y_n = scr[1] ^ scr[5];

        sy_n[0] = scr[0];
        sy_n[1] = scr[3] ^ scr[8];
        sy_n[2] = scr[6] ^ scr[16];
        sy_n[3] = scr[9] ^ scr[14] ^ scr[19] ^ scr[24];

        sx_n[0] = x_n;
        sx_n[1] = scr[7] ^ scr[9] ^ scr[12] ^ scr[14];
        sx_n[2] = scr[10] ^ scr[12] ^ scr[20] ^ scr[22];
        sx_n[3] = scr[13] ^ scr[15] ^ scr[18] ^ scr[20] ^ 
                  scr[23] ^ scr[25] ^ scr[28] ^ scr[30];

        sg_n[0] = y_n;
        sg_n[1] = scr[4] ^ scr[8] ^ scr[9] ^ scr[13];
        sg_n[2] = scr[7] ^ scr[11] ^ scr[17] ^ scr[21];
        sg_n[3] = scr[10] ^ scr[14] ^ scr[15] ^ scr[19] ^ 
                  scr[20] ^ scr[24] ^ scr[25] ^ scr[29];
    end

endmodule