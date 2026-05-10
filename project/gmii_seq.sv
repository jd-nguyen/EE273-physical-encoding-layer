// gmii_seq.sv

// Sequence
	class gmii_seq extends uvm_sequence #(gmii_items);
		`uvm_object_utils(gmii_seq)

		function new(string name = "gmii_seq"); 
        		super.new(name);
    		endfunction

		// Helper: drive N idle cycles (tx_en=0, randomized txd)
		task send_idle(int unsigned n);
			gmii_items items;
			repeat(n) begin
				items = gmii_items::type_id::create("items");
				start_item(items);
				if(!items.randomize() with {tx_en == 1'b0;})
					`uvm_error("SEQ", "Idle randomization failed")
				finish_item(items);
			end
		endtask

		// Helper: drive N cycles of data with a fixed TXD value
		task send_fixed_data(logic [7:0] txd_val, int unsigned n);
			gmii_items items;
			repeat(n) begin
				items = gmii_items::type_id::create("items");
				start_item(items);
				if(!items.randomize() with {tx_en == 1'b1; txd == txd_val;})
					`uvm_error("SEQ", $sformatf("Fixed TXD 0x%02X randomization failed", txd_val))
				finish_item(items);
			end
		endtask

		// Helper: drive a full structured frame — tx_en=1 for n data cycles (random txd),
		// then tx_en=0 to let the FSM complete DATA→CSR1→CSR2→ESD1→ESD2→IDLE
		task send_frame(int unsigned n);
			gmii_items items;
			// data phase
			repeat(n) begin
				items = gmii_items::type_id::create("items");
				start_item(items);
				if(!items.randomize() with {tx_en == 1'b1;})
					`uvm_error("SEQ", "Frame data randomization failed")
				finish_item(items);
			end
			// de-assert tx_en — FSM needs 4 cycles to drain (CSR1, CSR2, ESD1, ESD2)
			send_idle(10);
		endtask

		task body();
			gmii_items items;

			// Idle check. State needs to stay idle even with randomized txd
			repeat(20000) begin
				items = gmii_items::type_id::create("items");
				start_item(items);
				if(!items.randomize() with {tx_en == 1'b0;}) begin
					`uvm_error("SEQ", "IDLE check failed")
				end
				finish_item(items);
			end

			// error check with txd and enable active
			repeat(2000) begin
				items = gmii_items::type_id::create("items");
				start_item(items);
				if(!items.randomize() with {tx_en == 1'b1;}) begin
					`uvm_error("SEQ", "Randomization failed")
				end
				finish_item(items);
			end

			// Test case 1: structured single frames — exercises full FSM path
			// IDLE → SSD1 → SSD2 → DATA → CSR1 → CSR2 → ESD1 → ESD2 → IDLE

			// short frame (10 data cycles)
			`uvm_info("SEQ", "TC1: short frame (10 cycles)", UVM_LOW)
			send_idle(20);
			send_frame(10);

			// medium frame (50 data cycles)
			`uvm_info("SEQ", "TC1: medium frame (50 cycles)", UVM_LOW)
			send_idle(20);
			send_frame(50);

			// long frame (200 data cycles)
			`uvm_info("SEQ", "TC1: long frame (200 cycles)", UVM_LOW)
			send_idle(20);
			send_frame(200);

			// repeated short frames — verify FSM resets correctly each time
			`uvm_info("SEQ", "TC1: repeated short frames", UVM_LOW)
			repeat(10) begin
				send_idle(20);
				send_frame(15);
			end

			// Test case 5: corner-case TXD patterns
			// Each pattern: idle gap → transmit fixed TXD for 200 cycles → idle gap

			// 0x55 — Ethernet preamble byte
			`uvm_info("SEQ", "TC5: TXD=0x55 (preamble)", UVM_LOW)
			send_idle(20);
			send_fixed_data(8'h55, 200);
			send_idle(20);

			// 0x00 — all zeros (scrambler stress)
			`uvm_info("SEQ", "TC5: TXD=0x00 (all zeros)", UVM_LOW)
			send_idle(20);
			send_fixed_data(8'h00, 200);
			send_idle(20);

			// 0xFF — all ones (scrambler stress)
			`uvm_info("SEQ", "TC5: TXD=0xFF (all ones)", UVM_LOW)
			send_idle(20);
			send_fixed_data(8'hFF, 200);
			send_idle(20);

			// 0xAA — alternating bits
			`uvm_info("SEQ", "TC5: TXD=0xAA (alternating)", UVM_LOW)
			send_idle(20);
			send_fixed_data(8'hAA, 200);
			send_idle(20);

			// 0x0F — carrier extension code (cextn trigger when tx_en=0)
			`uvm_info("SEQ", "TC5: TXD=0x0F (carrier extension code)", UVM_LOW)
			send_idle(20);
			send_fixed_data(8'h0F, 200);
			send_idle(20);

			// 0x01 — LPI request code
			`uvm_info("SEQ", "TC5: TXD=0x01 (LPI request code)", UVM_LOW)
			send_idle(20);
			send_fixed_data(8'h01, 200);
			send_idle(20);

		endtask
	endclass
