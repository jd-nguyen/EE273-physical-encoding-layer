class gmii_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(gmii_scoreboard)

    uvm_analysis_imp #(gmii_items, gmii_scoreboard) mon_imp;

    virtual dut_if dut_vif;

    // counters
    int total_compared;
    int total_mismatches;
    int mismatch_a, mismatch_b, mismatch_c, mismatch_d;
    int transactions_received;
    int first_mismatch_cycle;

    // max mismatches
    localparam int MAX_LOG = 50;

    // 1-cycle delayed reference signals (to satisfy prof DUT)
    logic signed [2:0] ref_a_d1, ref_b_d1, ref_c_d1, ref_d_d1;
    logic              ref_valid; 

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_imp = new("mon_imp", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual dut_if)::get(this, "", "dut_vif", dut_vif))
            `uvm_fatal("SCB", "DUT observation interface not found in config_db")

        total_compared      = 0;
        total_mismatches    = 0;
        mismatch_a          = 0;
        mismatch_b          = 0;
        mismatch_c          = 0;
        mismatch_d          = 0;
        transactions_received = 0;
        first_mismatch_cycle = -1;
    endfunction

    function void write(gmii_items item);
        transactions_received++;
    endfunction

    // main comparison
    task run_phase(uvm_phase phase);
        @(negedge dut_vif.reset);
        repeat(5) @(posedge dut_vif.clk);

        `uvm_info("SCB", "Scoreboard comparison started", UVM_LOW)

        // prime the delay pipeline
        @(posedge dut_vif.clk);
        #1;
        ref_a_d1  = dut_vif.ref_a;
        ref_b_d1  = dut_vif.ref_b;
        ref_c_d1  = dut_vif.ref_c;
        ref_d_d1  = dut_vif.ref_d;
        ref_valid = 1'b1;

        // comparison loop
        forever begin
            @(posedge dut_vif.clk);
            #1; 

            begin
                automatic logic signed [2:0] dut_a, dut_b, dut_c, dut_d;
                automatic logic signed [2:0] ref_a_now, ref_b_now, ref_c_now, ref_d_now;
                automatic logic match_a, match_b, match_c, match_d, all_match;

                dut_a = signed'(dut_vif.dout[3]);
                dut_b = signed'(dut_vif.dout[2]);
                dut_c = signed'(dut_vif.dout[1]);
                dut_d = signed'(dut_vif.dout[0]);

                ref_a_now = dut_vif.ref_a;
                ref_b_now = dut_vif.ref_b;
                ref_c_now = dut_vif.ref_c;
                ref_d_now = dut_vif.ref_d;

                // compare DUT against delayed ref
                match_a = (dut_a == ref_a_d1);
                match_b = (dut_b == ref_b_d1);
                match_c = (dut_c == ref_c_d1);
                match_d = (dut_d == ref_d_d1);
                all_match = match_a && match_b && match_c && match_d;

                total_compared++;

                if (!all_match) begin
                    total_mismatches++;
                    if (!match_a) mismatch_a++;
                    if (!match_b) mismatch_b++;
                    if (!match_c) mismatch_c++;
                    if (!match_d) mismatch_d++;

                    if (first_mismatch_cycle == -1)
                        first_mismatch_cycle = total_compared;

                    if (total_mismatches <= MAX_LOG) begin
                        `uvm_error("SCB", $sformatf(
                            "MISMATCH #%0d cycle %0d: DUT=(%0d,%0d,%0d,%0d) REF_d1=(%0d,%0d,%0d,%0d) Diff:%s%s%s%s",
                            total_mismatches, total_compared,
                            dut_a, dut_b, dut_c, dut_d,
                            ref_a_d1, ref_b_d1, ref_c_d1, ref_d_d1,
                            match_a ? "" : " A", match_b ? "" : " B",
                            match_c ? "" : " C", match_d ? "" : " D"))
                    end
                end

                // shift pipeline
                ref_a_d1 = ref_a_now;
                ref_b_d1 = ref_b_now;
                ref_c_d1 = ref_c_now;
                ref_d_d1 = ref_d_now;
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("SCB", "============================================================", UVM_LOW)
        `uvm_info("SCB", "  SCOREBOARD SUMMARY", UVM_LOW)
        `uvm_info("SCB", "============================================================", UVM_LOW)
        `uvm_info("SCB", $sformatf("  Cycles compared:    %0d", total_compared), UVM_LOW)
        `uvm_info("SCB", $sformatf("  Total mismatches:   %0d", total_mismatches), UVM_LOW)
        `uvm_info("SCB", $sformatf("  Transactions (tx_en=1): %0d", transactions_received), UVM_LOW)
        if (total_compared > 0)
            `uvm_info("SCB", $sformatf("  Match rate: %0.2f%%",
                100.0 * (total_compared - total_mismatches) / total_compared), UVM_LOW)
        if (total_mismatches > 0) begin
            `uvm_info("SCB", $sformatf("  A: %0d  B: %0d  C: %0d  D: %0d",
                mismatch_a, mismatch_b, mismatch_c, mismatch_d), UVM_LOW)
            `uvm_info("SCB", $sformatf("  First mismatch: cycle %0d", first_mismatch_cycle), UVM_LOW)
        end
        if (total_mismatches == 0)
            `uvm_info("SCB", "  RESULT: PASS", UVM_LOW)
        else
            `uvm_error("SCB", "  RESULT: FAIL")
        `uvm_info("SCB", "============================================================", UVM_LOW)
    endfunction
endclass
