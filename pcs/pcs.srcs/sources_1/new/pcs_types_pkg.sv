package pcs_types_pkg;
    // Quinary symbol needs 3 bits to represent {-2, -1, 0, 1, 2}
    // Using signed logic to represent the negative values
    typedef logic signed [2:0] quinary_sym_t;

    // SYMB_4D vector consists of four quinary symbols (An, Bn, Cn, Dn)
    typedef struct packed {
        quinary_sym_t A;
        quinary_sym_t B;
        quinary_sym_t C;
        quinary_sym_t D;
    } symb_4d_t;

    // Configuration modes
    typedef enum logic {MASTER, SLAVE} config_mode_t;
    
    // Transmit modes
    typedef enum logic [1:0] {SEND_N, SEND_I, SEND_Z} tx_mode_t;
endpackage