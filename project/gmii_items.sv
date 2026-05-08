// gmii_items.sv


// Sequence items
	class gmii_items extends uvm_sequence_item;
		`uvm_object_utils(gmii_items)

		rand logic [7:0] txd;
		rand logic tx_en;

		function new(string name = "gmii_items"); 
        		super.new(name);
    		endfunction
	endclass

