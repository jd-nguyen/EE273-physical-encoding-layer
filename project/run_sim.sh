#!/bin/bash

./sv_uvm \
    gmii_if.sv \
    dut_if.sv \
    pcs_sym_table_pkg.sv \
    gmii_tx_pkg.sv \
    DUTS26_0.sv \
    pcs_tx_pipeline.sv \
    pcs_tx_fsm.sv \
    pcs_tx_enable.sv \
    pcs_lpi_request.sv \
    pcs_tx_top.sv \
    tb_top.sv
