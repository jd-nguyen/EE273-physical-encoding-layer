// gmii_sequencer.sv

// Sequencer
	class gmii_sequencer extends uvm_sequencer #(gmii_items);
    		`uvm_component_utils(gmii_sequencer)
    		function new(string name, uvm_component parent);
        		super.new(name, parent);
    		endfunction
	endclass
