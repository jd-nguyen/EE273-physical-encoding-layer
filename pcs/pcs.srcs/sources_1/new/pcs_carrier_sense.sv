`timescale 1ns / 1ps

module pcs_carrier_sense (
    // Internal cross-domain flags from TX and RX FSMs
    input  logic _1000BTtransmit,
    input  logic _1000BTreceive,
    
    // GMII Control Outputs
    output logic crs,
    output logic col
);

    // -------------------------------------------------------------------------
    // IEEE 802.3 Figure 40-12: Carrier Sense State Diagram
    // -------------------------------------------------------------------------
    // Carrier is sensed if the PHY is either transmitting or receiving data.
    assign crs = _1000BTtransmit | _1000BTreceive;

    // -------------------------------------------------------------------------
    // IEEE 802.3 Figure 40-13: Collision Detect State Diagram
    // -------------------------------------------------------------------------
    // A collision occurs if the PHY is transmitting and receiving simultaneously.
    // Note: The MAC determines how to handle this based on Full/Half Duplex configuration.
    
    assign col = _1000BTtransmit & _1000BTreceive;

endmodule