// gmii_test.sv

// Test

class gmii_test extends uvm_test; 
	`uvm_component_utils(gmii_test) 
	gmii_env env; 

	function new(string name, uvm_component parent); 
		super.new(name, parent); 
	endfunction 

	function void build_phase(uvm_phase phase); 
		env = gmii_env::type_id::create("env", this); 
	endfunction 

	task run_phase(uvm_phase phase); 
		gmii_seq seq = gmii_seq::type_id::create("seq"); 
		phase.raise_objection(this); 
		seq.start(env.agt.sqr); 
		#200; 
		phase.drop_objection(this); 
	endtask 
endclass
