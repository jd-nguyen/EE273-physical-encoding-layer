`timescale 1ns / 1ps

module pcs_tx_scrambler
import pcs_types_pkg::*;
(
    input  logic         clk,
    input  logic         reset_n,
    input  config_mode_t config_mode, // MASTER or SLAVE
    
    // Outputs for symbol generation
    output logic [3:0]   sx_n,
    output logic [3:0]   sy_n,
    output logic [3:0]   sg_n,
    output logic         scr_0      // Scr_n[0]
);

    // 33-bit Shift Register
    logic [32:0] scr;
    logic        new_bit;

    // Output the newest bit for downstream logic
    assign scr_0 = scr[0];

    // -------------------------------------------------------------------------
    // LFSR & Master/Slave Polynomial Selection
    // -------------------------------------------------------------------------
    always_comb begin
        if (config_mode == MASTER) begin
            // MASTER: 1 + x^13 + x^33
            new_bit = scr[12] ^ scr[32]; 
        end else begin
            // SLAVE: 1 + x^20 + x^33
            new_bit = scr[19] ^ scr[32];
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // The scrambler state must NOT be initialized to all zeros[cite: 122].
            scr <= 33'h1_FFFF_FFFF; 
        end else begin
            // Shift left and insert the new bit at index 0 [cite: 118]
            scr <= {scr[31:0], new_bit};
        end
    end

    // -------------------------------------------------------------------------
    // Auxiliary Bit Generation
    // -------------------------------------------------------------------------
    logic x_n, y_n;

    always_comb begin
        // Base uncorrelated bits [cite: 150, 151]
        x_n = scr[4] ^ scr[6];
        y_n = scr[1] ^ scr[5];

        // Generation of Sy_n[3:0] [cite: 154, 155, 156, 157]
        sy_n[0] = scr[0];
        sy_n[1] = scr[3] ^ scr[8];
        sy_n[2] = scr[6] ^ scr[16];
        sy_n[3] = scr[9] ^ scr[14] ^ scr[19] ^ scr[24];

        // Generation of Sx_n[3:0] [cite: 163, 164, 165, 167, 168]
        sx_n[0] = x_n;
        sx_n[1] = scr[7] ^ scr[9] ^ scr[12] ^ scr[14];
        sx_n[2] = scr[10] ^ scr[12] ^ scr[20] ^ scr[22];
        sx_n[3] = scr[13] ^ scr[15] ^ scr[18] ^ scr[20] ^ 
                  scr[23] ^ scr[25] ^ scr[28] ^ scr[30];

        // Generation of Sg_n[3:0] [cite: 170, 171, 172, 173, 174]
        sg_n[0] = y_n;
        sg_n[1] = scr[4] ^ scr[8] ^ scr[9] ^ scr[13];
        sg_n[2] = scr[7] ^ scr[11] ^ scr[17] ^ scr[21];
        sg_n[3] = scr[10] ^ scr[14] ^ scr[15] ^ scr[19] ^ 
                  scr[20] ^ scr[24] ^ scr[25] ^ scr[29];
    end

endmodule