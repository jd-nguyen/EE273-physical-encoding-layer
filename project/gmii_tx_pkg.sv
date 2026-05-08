package gmii_tx_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"


	// sequences ===========
	`include "gmii_items.sv"
	`include "gmii_seq.sv"
	`include "gmii_sequencer.sv"


	// components ==========	
	`include "gmii_driver.sv"
	`include "gmii_monitor.sv"
	`include "gmii_scoreboard.sv"
	`include "gmii_agent.sv"
	`include "gmii_environment.sv"
	`include "gmii_test.sv"	
endpackage
