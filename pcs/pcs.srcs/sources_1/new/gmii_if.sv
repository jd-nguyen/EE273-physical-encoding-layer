interface gmii_if (
    input logic gtx_clk, // Transmit clock
    input logic rx_clk   // Receive clock (recovered)
);
    // Transmit Path
    logic [7:0] txd;     // Transmit Data
    logic       tx_en;   // Transmit Enable 
    logic       tx_er;   // Transmit Error

    // Receive Path
    logic [7:0] rxd;     // Receive Data 
    logic       rx_dv;   // Receive Data Valid
    logic       rx_er;   // Receive Error

    // Control/Status
    logic       col;     // Collision
    logic       crs;     // Carrier Sense

    // Modport for the DUT
    modport dut (
        input  gtx_clk, rx_clk, txd, tx_en, tx_er,
        output rxd, rx_dv, rx_er, col, crs
    );
endinterface