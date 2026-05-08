// gmii_agent.sv

// Agent: used to wrap the sequencer, driver, and monitor
	class gmii_agent extends uvm_agent;
		`uvm_component_utils(gmii_agent)
		gmii_driver drv;
		gmii_monitor mon;
		gmii_sequencer sqr;

		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction

		function void build_phase(uvm_phase phase);
			drv = gmii_driver::type_id::create("drv", this);
			mon = gmii_monitor::type_id::create("mon", this);
			sqr = gmii_sequencer::type_id::create("sqr", this);
		endfunction

		// Connect driver to sequencer and get the virtual interface
		function void connect_phase(uvm_phase phase);
			drv.seq_item_port.connect(sqr.seq_item_export);

			if (!uvm_config_db#(virtual gmii_if)::get(this, "", "vif", drv.vif))
				`uvm_fatal("AGENT", "Virtual interface not found")

			mon.vif = drv.vif;
		endfunction
	endclass
