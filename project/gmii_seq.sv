// gmii_seq.sv

// Sequence
	class gmii_seq extends uvm_sequence #(gmii_items);
		`uvm_object_utils(gmii_seq)

		function new(string name = "gmii_seq"); 
        		super.new(name);
    		endfunction

		task body();
			gmii_items items;

			// Idle check. State needs to stay idle even with randomized txd
			repeat(20) begin 
				items = gmii_items::type_id::create("items"); 
				start_item(items); 
				if(!items.randomize() with {tx_en == 1'b0;}) begin         
					`uvm_error("SEQ", "IDLE check failed") 
				end 
				finish_item(items); 
			end

			// Idle check with error. State needs to stay idle even with randomized txd
			repeat(20) begin 
				items = gmii_items::type_id::create("items"); 
				start_item(items); 
				if(!items.randomize() with {tx_en == 1'b0;}) begin         
					`uvm_error("SEQ", "ERROR check failed") 
				end 
				finish_item(items); 
			end

			// Check if txd is sent properly
			repeat(20) begin 
				items = gmii_items::type_id::create("items"); 
				start_item(items); 
				if(!items.randomize() with {tx_en == 1'b1;}) begin         
					`uvm_error("SEQ", "Randomization failed") 
				end 
				finish_item(items); 
			end

			// error check with txd and enable active
			repeat(20) begin 
				items = gmii_items::type_id::create("items"); 
				start_item(items); 
				if(!items.randomize() with {tx_en == 1'b1;}) begin         
					`uvm_error("SEQ", "Randomization failed") 
				end 
				finish_item(items); 
			end
		endtask	
	endclass
