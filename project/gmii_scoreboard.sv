// gmii_scoreboard.sv
`uvm_analysis_imp_decl(_gmii)
`uvm_analysis_imp_decl(_pma)

class gmii_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(gmii_scoreboard)

    // -------------------------------------------------------------------------
    // TLM Interfaces (Analysis Exports and FIFOs)
    // -------------------------------------------------------------------------
    // We use FIFOs because the GMII input and PMA output happen on different 
    // clock cycles due to the RTL pipeline latency. FIFOs safely buffer them.
    uvm_tlm_analysis_fifo #(gmii_items)    gmii_fifo;
    uvm_tlm_analysis_fifo #(pma_symb_item) pma_fifo;

    // Analysis Implementations to connect to the Monitors
    uvm_analysis_imp_gmii #(gmii_items, gmii_scoreboard)    mon_imp_gmii;
    uvm_analysis_imp_pma  #(pma_symb_item, gmii_scoreboard) mon_imp_pma;

    // -------------------------------------------------------------------------
    // Internal State Variables (For the Predictor)
    // -------------------------------------------------------------------------
    int byte_count;      // Tracks where we are in the frame to inject SSDs
    logic [32:0] scr_tx; // Software replica of the Master LFSR

    // Statistics
    int match_count;
    int error_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        gmii_fifo    = new("gmii_fifo", this);
        pma_fifo     = new("pma_fifo", this);
        mon_imp_gmii = new("mon_imp_gmii", this);
        mon_imp_pma  = new("mon_imp_pma", this);
        
        byte_count  = 0;
        match_count = 0;
        error_count = 0;
        scr_tx      = 33'h1_FFFF_FFFF; // Master LFSR reset value
    endfunction

    // -------------------------------------------------------------------------
    // Write Functions (Called automatically by the Monitors)
    // -------------------------------------------------------------------------
    virtual function void write_gmii(gmii_items tr);
        gmii_fifo.try_put(tr);
    endfunction

    virtual function void write_pma(pma_symb_item tr);
        pma_fifo.try_put(tr);
    endfunction

    // -------------------------------------------------------------------------
    // Main Checking Loop
    // -------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        gmii_items    gmii_tx;
        pma_symb_item pma_act;
        pma_symb_item pma_exp;

        forever begin
            // Wait until we have BOTH an input from GMII and an output from PMA
            gmii_fifo.get(gmii_tx);
            pma_fifo.get(pma_act);

            // 1. Run the GMII data through our software predictor
            pma_exp = predict_symbol(gmii_tx);

            // 2. Compare the prediction against the actual RTL output
            if (pma_exp.compare(pma_act)) begin
                match_count++;
                `uvm_info("SCB_MATCH", $sformatf("Data matched! Expected A:%0d B:%0d C:%0d D:%0d", 
                          pma_exp.A, pma_exp.B, pma_exp.C, pma_exp.D), UVM_HIGH)
            end else begin
                error_count++;
                `uvm_error("SCB_MISMATCH", $sformatf(
                    "Byte #%0d | TXD: %h\nEXPECTED: A:%0d B:%0d C:%0d D:%0d\nACTUAL:   A:%0d B:%0d C:%0d D:%0d", 
                    byte_count, gmii_tx.txd, 
                    pma_exp.A, pma_exp.B, pma_exp.C, pma_exp.D,
                    pma_act.A, pma_act.B, pma_act.C, pma_act.D))
            end

            // Reset byte count if tx_en drops
            if (!gmii_tx.tx_en) begin
                byte_count = 0;
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // The Reference Model (Software Predictor)
    // -------------------------------------------------------------------------
    virtual function pma_symb_item predict_symbol(gmii_items tx);
        pma_symb_item exp = pma_symb_item::type_id::create("exp");
        logic [7:0] sc_n;
        logic [8:0] sd_n;
        
        if (tx.tx_en) begin
            byte_count++;
            
            // Handle the Protocol Overrides (SSD1 and SSD2)
            if (byte_count == 1) begin
                exp.A =  2; exp.B =  2; exp.C =  2; exp.D =  2; // SSD1
                advance_lfsr(); // LFSR still shifts during control symbols
                return exp;
            end
            else if (byte_count == 2) begin
                exp.A =  2; exp.B =  2; exp.C =  2; exp.D = -2; // SSD2
                advance_lfsr(); 
                return exp;
            end
            
            // Standard Data Payload Encoding
            // 1. Generate Scrambler Bits (Sc_n) from current LFSR state
            sc_n = {scr_tx[20], scr_tx[19], scr_tx[18], scr_tx[17], 
                    scr_tx[16], scr_tx[15], scr_tx[14], scr_tx[13]}; 
            
            // 2. Convolutional Math (Sd_n = Sc_n ^ TXD)
            sd_n[7:0] = sc_n ^ tx.txd;
            sd_n[8]   = 1'b0; // Simplified for tx_en active state
            
            // 3. 8B1Q4 Mapping (Simplified Example for Scoreboard)
            // In a full implementation, you would port your entire Table 40-1/40-2 logic here.
            // For now, we will map a known subset or call a dedicated mapping function.
            map_8b1q4(sd_n, exp);
            
            // 4. Sign Reversal
            // Multiply expected symbols by software-generated Sg_n bits
            
            // 5. Advance the software LFSR for the next clock cycle
            advance_lfsr();
            
        end else begin
            // If tx_en is low, expect IDLE symbols (0,0,0,0)
            exp.A = 0; exp.B = 0; exp.C = 0; exp.D = 0;
            advance_lfsr();
        end
        
        return exp;
    endfunction

    // Helper: Software LFSR Advance
    function void advance_lfsr();
        logic next_bit;
        next_bit = scr_tx[12] ^ scr_tx[32]; // Master polynomial
        scr_tx = {scr_tx[31:0], next_bit};
    endfunction
    
    // Helper: 8B1Q4 Mapper
    function void map_8b1q4(logic [8:0] sdn, pma_symb_item sym);
        // Copy the SystemVerilog logic from your pcs_symbol_mapper here
        // to strictly predict the A, B, C, D output based on the 9-bit sdn.
        // ...
    endfunction

    // -------------------------------------------------------------------------
    // Report Phase
    // -------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        `uvm_info("SCB_REPORT", "========================================", UVM_NONE)
        `uvm_info("SCB_REPORT", $sformatf("Total Matches: %0d", match_count), UVM_NONE)
        `uvm_info("SCB_REPORT", $sformatf("Total Errors:  %0d", error_count), UVM_NONE)
        `uvm_info("SCB_REPORT", "========================================", UVM_NONE)
        
        if (error_count > 0)
            `uvm_error("SCB_FAIL", "Test finished with mismatches!")
        else
            `uvm_info("SCB_PASS", "All transmitted data successfully matched!", UVM_NONE)
    endfunction

endclass
