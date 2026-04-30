// gmii_driver.sv

// Driver
	class gmii_driver extends uvm_driver #(gmii_items);
		`uvm_component_utils(gmii_driver)
		virtual gmii_if vif;

		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction

		// Initial state and driving the items
		task run_phase(uvm_phase phase);
			vif.txd <= 8'b00000000;
			vif.tx_en <= 1'b0;

			forever begin
				seq_item_port.get_next_item(req);
				@(posedge vif.gtx_clk);
				vif.txd <= req.txd;
				vif.tx_en <= req.tx_en;
				seq_item_port.item_done();
			end
		endtask
	endclass
