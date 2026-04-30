// gmii_monitor.sv

// Monitor
	class gmii_monitor extends uvm_monitor;
		`uvm_component_utils(gmii_monitor)
		virtual gmii_if vif;

		uvm_analysis_port #(gmii_items) ap;

		function new(string name, uvm_component parent);
			super.new(name, parent);
			ap = new("ap", this);
		endfunction

		task run_phase(uvm_phase phase);
			gmii_items tr;
			forever begin
				@(posedge vif.gtx_clk);
				if (vif.tx_en) begin
					tr = gmii_items::type_id::create("tr");
					tr.txd = vif.txd;
					tr.tx_en = vif.tx_en;
					ap.write(tr);
				end
			end
		endtask
	endclass
