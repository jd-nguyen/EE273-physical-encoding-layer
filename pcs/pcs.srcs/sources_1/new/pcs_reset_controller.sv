`timescale 1ns / 1ps

module pcs_reset_controller (
    input  logic clk,           // 125 MHz Main Clock
    input  logic reset_n,       // Hardware Power-On Reset (Async, Active Low)
    
    // Management Interface
    input  logic sw_reset_req,  // Software Reset from MDIO (Async to clk, Active High)

    // Synchronized Output
    output logic pcs_reset      // Clean, Synchronized Software Reset to PCS blocks
);

    // -------------------------------------------------------------------------
    // 2-Stage Flip-Flop Synchronizer (Clock Domain Crossing)
    // -------------------------------------------------------------------------
    // We double-flop the incoming asynchronous signal. If the first flop 
    // goes metastable (captures the signal exactly as it changes), the second 
    // flop gives it a full clock cycle to settle into a deterministic 1 or 0.
    
    logic reset_meta;
    logic reset_sync;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            reset_meta <= 1'b0;
            reset_sync <= 1'b0;
        end else begin
            reset_meta <= sw_reset_req;
            reset_sync <= reset_meta;
        end
    end

    // Route the safely synchronized signal to the rest of the PCS
    assign pcs_reset = reset_sync;

endmodule