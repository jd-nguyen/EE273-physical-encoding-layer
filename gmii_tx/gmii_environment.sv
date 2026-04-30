// gmii_env.sv

// Environment: used to wrap agent and scoreboard
class gmii_env extends uvm_env;
	`uvm_component_utils(gmii_env)
	gmii_agent agt;
	gmii_scoreboard scb;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		agt = gmii_agent::type_id::create("agt", this);
		scb = gmii_scoreboard::type_id::create("scb", this);
	endfunction

	// Connect monitor to the scoreboard
	function void connect_phase(uvm_phase phase);
		agt.mon.ap.connect(scb.mon_imp);
	endfunction
endclass
