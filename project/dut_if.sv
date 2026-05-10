interface dut_if (
    input logic clk,
    input logic reset
);

    logic [3:0][2:0] dout;

    logic signed [2:0] ref_a, ref_b, ref_c, ref_d;

    logic [7:0] din;
    logic       tx_en;
endinterface
