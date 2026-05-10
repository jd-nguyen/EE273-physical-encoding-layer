package pcs_sym_table_pkg;

  // Quinary symbol encoding (3-bit signed):
  //   -2 = 3'sb110, -1 = 3'sb111, 0 = 3'sb000, +1 = 3'sb001, +2 = 3'sb010

  // Packed entry format: {TA[2:0], TB[2:0], TC[2:0], TD[2:0]} = 12 bits

  // Symbol condition codes
  typedef enum logic [3:0] {
    COND_NORMAL       = 4'd0,
    COND_XMT_ERR      = 4'd1,
    COND_CSRESET      = 4'd2,
    COND_CSEXTEND     = 4'd3,
    COND_CSEXTEND_ERR = 4'd4,
    COND_SSD1         = 4'd5,
    COND_SSD2         = 4'd6,
    COND_ESD1         = 4'd7,
    COND_ESD2_EXT_0   = 4'd8,
    COND_ESD2_EXT_1   = 4'd9,
    COND_ESD2_EXT_2   = 4'd10,
    COND_ESD_EXT_ERR  = 4'd11,
    COND_IDLE         = 4'd12
  } sym_condition_t;

  // Normal data symbol ROM (512 entries x 12 bits)
  // Address = {Sdn[8:6], Sdn[5:0]} = Sdn[8:0]
  // Subset mapping:
  //   Sdn[8:6]=000 -> subset 0 (Table 40-1 col [000])
  //   Sdn[8:6]=001 -> subset 1 (Table 40-1 col [100])
  //   Sdn[8:6]=010 -> subset 2 (Table 40-1 col [010])
  //   Sdn[8:6]=011 -> subset 3 (Table 40-1 col [110])
  //   Sdn[8:6]=100 -> subset 4 (Table 40-2 col [001])
  //   Sdn[8:6]=101 -> subset 5 (Table 40-2 col [101])
  //   Sdn[8:6]=110 -> subset 6 (Table 40-2 col [011])
  //   Sdn[8:6]=111 -> subset 7 (Table 40-2 col [111])

  function automatic logic [11:0] normal_sym_lookup(input logic [8:0] sd);
    case (sd)
      9'd0: return 12'h000; // subset=0 row=000000
      9'd1: return 12'hc00; // subset=0 row=000001
      9'd2: return 12'h180; // subset=0 row=000010
      9'd3: return 12'hd80; // subset=0 row=000011
      9'd4: return 12'h030; // subset=0 row=000100
      9'd5: return 12'hc30; // subset=0 row=000101
      9'd6: return 12'h1b0; // subset=0 row=000110
      9'd7: return 12'hdb0; // subset=0 row=000111
      9'd8: return 12'h006; // subset=0 row=001000
      9'd9: return 12'hc06; // subset=0 row=001001
      9'd10: return 12'h186; // subset=0 row=001010
      9'd11: return 12'hd86; // subset=0 row=001011
      9'd12: return 12'h036; // subset=0 row=001100
      9'd13: return 12'hc36; // subset=0 row=001101
      9'd14: return 12'h1b6; // subset=0 row=001110
      9'd15: return 12'hdb6; // subset=0 row=001111
      9'd16: return 12'h249; // subset=0 row=010000
      9'd17: return 12'he49; // subset=0 row=010001
      9'd18: return 12'h3c9; // subset=0 row=010010
      9'd19: return 12'hfc9; // subset=0 row=010011
      9'd20: return 12'h279; // subset=0 row=010100
      9'd21: return 12'he79; // subset=0 row=010101
      9'd22: return 12'h3f9; // subset=0 row=010110
      9'd23: return 12'hff9; // subset=0 row=010111
      9'd24: return 12'h24f; // subset=0 row=011000
      9'd25: return 12'he4f; // subset=0 row=011001
      9'd26: return 12'h3cf; // subset=0 row=011010
      9'd27: return 12'hfcf; // subset=0 row=011011
      9'd28: return 12'h27f; // subset=0 row=011100
      9'd29: return 12'he7f; // subset=0 row=011101
      9'd30: return 12'h3ff; // subset=0 row=011110
      9'd31: return 12'hfff; // subset=0 row=011111
      9'd32: return 12'h400; // subset=0 row=100000
      9'd33: return 12'h580; // subset=0 row=100001
      9'd34: return 12'h430; // subset=0 row=100010
      9'd35: return 12'h5b0; // subset=0 row=100011
      9'd36: return 12'h406; // subset=0 row=100100
      9'd37: return 12'h586; // subset=0 row=100101
      9'd38: return 12'h436; // subset=0 row=100110
      9'd39: return 12'h5b6; // subset=0 row=100111
      9'd40: return 12'h010; // subset=0 row=101000
      9'd41: return 12'hc10; // subset=0 row=101001
      9'd42: return 12'h190; // subset=0 row=101010
      9'd43: return 12'hd90; // subset=0 row=101011
      9'd44: return 12'h016; // subset=0 row=101100
      9'd45: return 12'hc16; // subset=0 row=101101
      9'd46: return 12'h196; // subset=0 row=101110
      9'd47: return 12'hd96; // subset=0 row=101111
      9'd48: return 12'h080; // subset=0 row=110000
      9'd49: return 12'hc80; // subset=0 row=110001
      9'd50: return 12'h0b0; // subset=0 row=110010
      9'd51: return 12'hcb0; // subset=0 row=110011
      9'd52: return 12'h086; // subset=0 row=110100
      9'd53: return 12'hc86; // subset=0 row=110101
      9'd54: return 12'h0b6; // subset=0 row=110110
      9'd55: return 12'hcb6; // subset=0 row=110111
      9'd56: return 12'h002; // subset=0 row=111000
      9'd57: return 12'hc02; // subset=0 row=111001
      9'd58: return 12'h182; // subset=0 row=111010
      9'd59: return 12'hd82; // subset=0 row=111011
      9'd60: return 12'h032; // subset=0 row=111100
      9'd61: return 12'hc32; // subset=0 row=111101
      9'd62: return 12'h1b2; // subset=0 row=111110
      9'd63: return 12'hdb2; // subset=0 row=111111
      9'd64: return 12'h048; // subset=1 row=000000
      9'd65: return 12'hc48; // subset=1 row=000001
      9'd66: return 12'h1c8; // subset=1 row=000010
      9'd67: return 12'hdc8; // subset=1 row=000011
      9'd68: return 12'h078; // subset=1 row=000100
      9'd69: return 12'hc78; // subset=1 row=000101
      9'd70: return 12'h1f8; // subset=1 row=000110
      9'd71: return 12'hdf8; // subset=1 row=000111
      9'd72: return 12'h04e; // subset=1 row=001000
      9'd73: return 12'hc4e; // subset=1 row=001001
      9'd74: return 12'h1ce; // subset=1 row=001010
      9'd75: return 12'hdce; // subset=1 row=001011
      9'd76: return 12'h07e; // subset=1 row=001100
      9'd77: return 12'hc7e; // subset=1 row=001101
      9'd78: return 12'h1fe; // subset=1 row=001110
      9'd79: return 12'hdfe; // subset=1 row=001111
      9'd80: return 12'h201; // subset=1 row=010000
      9'd81: return 12'he01; // subset=1 row=010001
      9'd82: return 12'h381; // subset=1 row=010010
      9'd83: return 12'hf81; // subset=1 row=010011
      9'd84: return 12'h231; // subset=1 row=010100
      9'd85: return 12'he31; // subset=1 row=010101
      9'd86: return 12'h3b1; // subset=1 row=010110
      9'd87: return 12'hfb1; // subset=1 row=010111
      9'd88: return 12'h207; // subset=1 row=011000
      9'd89: return 12'he07; // subset=1 row=011001
      9'd90: return 12'h387; // subset=1 row=011010
      9'd91: return 12'hf87; // subset=1 row=011011
      9'd92: return 12'h237; // subset=1 row=011100
      9'd93: return 12'he37; // subset=1 row=011101
      9'd94: return 12'h3b7; // subset=1 row=011110
      9'd95: return 12'hfb7; // subset=1 row=011111
      9'd96: return 12'h448; // subset=1 row=100000
      9'd97: return 12'h5c8; // subset=1 row=100001
      9'd98: return 12'h478; // subset=1 row=100010
      9'd99: return 12'h5f8; // subset=1 row=100011
      9'd100: return 12'h44e; // subset=1 row=100100
      9'd101: return 12'h5ce; // subset=1 row=100101
      9'd102: return 12'h47e; // subset=1 row=100110
      9'd103: return 12'h5fe; // subset=1 row=100111
      9'd104: return 12'h211; // subset=1 row=101000
      9'd105: return 12'he11; // subset=1 row=101001
      9'd106: return 12'h391; // subset=1 row=101010
      9'd107: return 12'hf91; // subset=1 row=101011
      9'd108: return 12'h217; // subset=1 row=101100
      9'd109: return 12'he17; // subset=1 row=101101
      9'd110: return 12'h397; // subset=1 row=101110
      9'd111: return 12'hf97; // subset=1 row=101111
      9'd112: return 12'h281; // subset=1 row=110000
      9'd113: return 12'he81; // subset=1 row=110001
      9'd114: return 12'h2b1; // subset=1 row=110010
      9'd115: return 12'heb1; // subset=1 row=110011
      9'd116: return 12'h287; // subset=1 row=110100
      9'd117: return 12'he87; // subset=1 row=110101
      9'd118: return 12'h2b7; // subset=1 row=110110
      9'd119: return 12'heb7; // subset=1 row=110111
      9'd120: return 12'h04a; // subset=1 row=111000
      9'd121: return 12'hc4a; // subset=1 row=111001
      9'd122: return 12'h1ca; // subset=1 row=111010
      9'd123: return 12'hdca; // subset=1 row=111011
      9'd124: return 12'h07a; // subset=1 row=111100
      9'd125: return 12'hc7a; // subset=1 row=111101
      9'd126: return 12'h1fa; // subset=1 row=111110
      9'd127: return 12'hdfa; // subset=1 row=111111
      9'd128: return 12'h009; // subset=2 row=000000
      9'd129: return 12'hc09; // subset=2 row=000001
      9'd130: return 12'h189; // subset=2 row=000010
      9'd131: return 12'hd89; // subset=2 row=000011
      9'd132: return 12'h039; // subset=2 row=000100
      9'd133: return 12'hc39; // subset=2 row=000101
      9'd134: return 12'h1b9; // subset=2 row=000110
      9'd135: return 12'hdb9; // subset=2 row=000111
      9'd136: return 12'h00f; // subset=2 row=001000
      9'd137: return 12'hc0f; // subset=2 row=001001
      9'd138: return 12'h18f; // subset=2 row=001010
      9'd139: return 12'hd8f; // subset=2 row=001011
      9'd140: return 12'h03f; // subset=2 row=001100
      9'd141: return 12'hc3f; // subset=2 row=001101
      9'd142: return 12'h1bf; // subset=2 row=001110
      9'd143: return 12'hdbf; // subset=2 row=001111
      9'd144: return 12'h240; // subset=2 row=010000
      9'd145: return 12'he40; // subset=2 row=010001
      9'd146: return 12'h3c0; // subset=2 row=010010
      9'd147: return 12'hfc0; // subset=2 row=010011
      9'd148: return 12'h270; // subset=2 row=010100
      9'd149: return 12'he70; // subset=2 row=010101
      9'd150: return 12'h3f0; // subset=2 row=010110
      9'd151: return 12'hff0; // subset=2 row=010111
      9'd152: return 12'h246; // subset=2 row=011000
      9'd153: return 12'he46; // subset=2 row=011001
      9'd154: return 12'h3c6; // subset=2 row=011010
      9'd155: return 12'hfc6; // subset=2 row=011011
      9'd156: return 12'h276; // subset=2 row=011100
      9'd157: return 12'he76; // subset=2 row=011101
      9'd158: return 12'h3f6; // subset=2 row=011110
      9'd159: return 12'hff6; // subset=2 row=011111
      9'd160: return 12'h409; // subset=2 row=100000
      9'd161: return 12'h589; // subset=2 row=100001
      9'd162: return 12'h439; // subset=2 row=100010
      9'd163: return 12'h5b9; // subset=2 row=100011
      9'd164: return 12'h40f; // subset=2 row=100100
      9'd165: return 12'h58f; // subset=2 row=100101
      9'd166: return 12'h43f; // subset=2 row=100110
      9'd167: return 12'h5bf; // subset=2 row=100111
      9'd168: return 12'h250; // subset=2 row=101000
      9'd169: return 12'he50; // subset=2 row=101001
      9'd170: return 12'h3d0; // subset=2 row=101010
      9'd171: return 12'hfd0; // subset=2 row=101011
      9'd172: return 12'h256; // subset=2 row=101100
      9'd173: return 12'he56; // subset=2 row=101101
      9'd174: return 12'h3d6; // subset=2 row=101110
      9'd175: return 12'hfd6; // subset=2 row=101111
      9'd176: return 12'h089; // subset=2 row=110000
      9'd177: return 12'hc89; // subset=2 row=110001
      9'd178: return 12'h0b9; // subset=2 row=110010
      9'd179: return 12'hcb9; // subset=2 row=110011
      9'd180: return 12'h08f; // subset=2 row=110100
      9'd181: return 12'hc8f; // subset=2 row=110101
      9'd182: return 12'h0bf; // subset=2 row=110110
      9'd183: return 12'hcbf; // subset=2 row=110111
      9'd184: return 12'h242; // subset=2 row=111000
      9'd185: return 12'he42; // subset=2 row=111001
      9'd186: return 12'h3c2; // subset=2 row=111010
      9'd187: return 12'hfc2; // subset=2 row=111011
      9'd188: return 12'h272; // subset=2 row=111100
      9'd189: return 12'he72; // subset=2 row=111101
      9'd190: return 12'h3f2; // subset=2 row=111110
      9'd191: return 12'hff2; // subset=2 row=111111
      9'd192: return 12'h041; // subset=3 row=000000
      9'd193: return 12'hc41; // subset=3 row=000001
      9'd194: return 12'h1c1; // subset=3 row=000010
      9'd195: return 12'hdc1; // subset=3 row=000011
      9'd196: return 12'h071; // subset=3 row=000100
      9'd197: return 12'hc71; // subset=3 row=000101
      9'd198: return 12'h1f1; // subset=3 row=000110
      9'd199: return 12'hdf1; // subset=3 row=000111
      9'd200: return 12'h047; // subset=3 row=001000
      9'd201: return 12'hc47; // subset=3 row=001001
      9'd202: return 12'h1c7; // subset=3 row=001010
      9'd203: return 12'hdc7; // subset=3 row=001011
      9'd204: return 12'h077; // subset=3 row=001100
      9'd205: return 12'hc77; // subset=3 row=001101
      9'd206: return 12'h1f7; // subset=3 row=001110
      9'd207: return 12'hdf7; // subset=3 row=001111
      9'd208: return 12'h208; // subset=3 row=010000
      9'd209: return 12'he08; // subset=3 row=010001
      9'd210: return 12'h388; // subset=3 row=010010
      9'd211: return 12'hf88; // subset=3 row=010011
      9'd212: return 12'h238; // subset=3 row=010100
      9'd213: return 12'he38; // subset=3 row=010101
      9'd214: return 12'h3b8; // subset=3 row=010110
      9'd215: return 12'hfb8; // subset=3 row=010111
      9'd216: return 12'h20e; // subset=3 row=011000
      9'd217: return 12'he0e; // subset=3 row=011001
      9'd218: return 12'h38e; // subset=3 row=011010
      9'd219: return 12'hf8e; // subset=3 row=011011
      9'd220: return 12'h23e; // subset=3 row=011100
      9'd221: return 12'he3e; // subset=3 row=011101
      9'd222: return 12'h3be; // subset=3 row=011110
      9'd223: return 12'hfbe; // subset=3 row=011111
      9'd224: return 12'h441; // subset=3 row=100000
      9'd225: return 12'h5c1; // subset=3 row=100001
      9'd226: return 12'h471; // subset=3 row=100010
      9'd227: return 12'h5f1; // subset=3 row=100011
      9'd228: return 12'h447; // subset=3 row=100100
      9'd229: return 12'h5c7; // subset=3 row=100101
      9'd230: return 12'h477; // subset=3 row=100110
      9'd231: return 12'h5f7; // subset=3 row=100111
      9'd232: return 12'h051; // subset=3 row=101000
      9'd233: return 12'hc51; // subset=3 row=101001
      9'd234: return 12'h1d1; // subset=3 row=101010
      9'd235: return 12'hdd1; // subset=3 row=101011
      9'd236: return 12'h057; // subset=3 row=101100
      9'd237: return 12'hc57; // subset=3 row=101101
      9'd238: return 12'h1d7; // subset=3 row=101110
      9'd239: return 12'hdd7; // subset=3 row=101111
      9'd240: return 12'h288; // subset=3 row=110000
      9'd241: return 12'he88; // subset=3 row=110001
      9'd242: return 12'h2b8; // subset=3 row=110010
      9'd243: return 12'heb8; // subset=3 row=110011
      9'd244: return 12'h28e; // subset=3 row=110100
      9'd245: return 12'he8e; // subset=3 row=110101
      9'd246: return 12'h2be; // subset=3 row=110110
      9'd247: return 12'hebe; // subset=3 row=110111
      9'd248: return 12'h20a; // subset=3 row=111000
      9'd249: return 12'he0a; // subset=3 row=111001
      9'd250: return 12'h38a; // subset=3 row=111010
      9'd251: return 12'hf8a; // subset=3 row=111011
      9'd252: return 12'h23a; // subset=3 row=111100
      9'd253: return 12'he3a; // subset=3 row=111101
      9'd254: return 12'h3ba; // subset=3 row=111110
      9'd255: return 12'hfba; // subset=3 row=111111
      9'd256: return 12'h001; // subset=4 row=000000
      9'd257: return 12'hc01; // subset=4 row=000001
      9'd258: return 12'h181; // subset=4 row=000010
      9'd259: return 12'hd81; // subset=4 row=000011
      9'd260: return 12'h031; // subset=4 row=000100
      9'd261: return 12'hc31; // subset=4 row=000101
      9'd262: return 12'h1b1; // subset=4 row=000110
      9'd263: return 12'hdb1; // subset=4 row=000111
      9'd264: return 12'h007; // subset=4 row=001000
      9'd265: return 12'hc07; // subset=4 row=001001
      9'd266: return 12'h187; // subset=4 row=001010
      9'd267: return 12'hd87; // subset=4 row=001011
      9'd268: return 12'h037; // subset=4 row=001100
      9'd269: return 12'hc37; // subset=4 row=001101
      9'd270: return 12'h1b7; // subset=4 row=001110
      9'd271: return 12'hdb7; // subset=4 row=001111
      9'd272: return 12'h248; // subset=4 row=010000
      9'd273: return 12'he48; // subset=4 row=010001
      9'd274: return 12'h3c8; // subset=4 row=010010
      9'd275: return 12'hfc8; // subset=4 row=010011
      9'd276: return 12'h278; // subset=4 row=010100
      9'd277: return 12'he78; // subset=4 row=010101
      9'd278: return 12'h3f8; // subset=4 row=010110
      9'd279: return 12'hff8; // subset=4 row=010111
      9'd280: return 12'h24e; // subset=4 row=011000
      9'd281: return 12'he4e; // subset=4 row=011001
      9'd282: return 12'h3ce; // subset=4 row=011010
      9'd283: return 12'hfce; // subset=4 row=011011
      9'd284: return 12'h27e; // subset=4 row=011100
      9'd285: return 12'he7e; // subset=4 row=011101
      9'd286: return 12'h3fe; // subset=4 row=011110
      9'd287: return 12'hffe; // subset=4 row=011111
      9'd288: return 12'h401; // subset=4 row=100000
      9'd289: return 12'h581; // subset=4 row=100001
      9'd290: return 12'h431; // subset=4 row=100010
      9'd291: return 12'h5b1; // subset=4 row=100011
      9'd292: return 12'h407; // subset=4 row=100100
      9'd293: return 12'h587; // subset=4 row=100101
      9'd294: return 12'h437; // subset=4 row=100110
      9'd295: return 12'h5b7; // subset=4 row=100111
      9'd296: return 12'h011; // subset=4 row=101000
      9'd297: return 12'hc11; // subset=4 row=101001
      9'd298: return 12'h191; // subset=4 row=101010
      9'd299: return 12'hd91; // subset=4 row=101011
      9'd300: return 12'h017; // subset=4 row=101100
      9'd301: return 12'hc17; // subset=4 row=101101
      9'd302: return 12'h197; // subset=4 row=101110
      9'd303: return 12'hd97; // subset=4 row=101111
      9'd304: return 12'h081; // subset=4 row=110000
      9'd305: return 12'hc81; // subset=4 row=110001
      9'd306: return 12'h0b1; // subset=4 row=110010
      9'd307: return 12'hcb1; // subset=4 row=110011
      9'd308: return 12'h087; // subset=4 row=110100
      9'd309: return 12'hc87; // subset=4 row=110101
      9'd310: return 12'h0b7; // subset=4 row=110110
      9'd311: return 12'hcb7; // subset=4 row=110111
      9'd312: return 12'h24a; // subset=4 row=111000
      9'd313: return 12'he4a; // subset=4 row=111001
      9'd314: return 12'h3ca; // subset=4 row=111010
      9'd315: return 12'hfca; // subset=4 row=111011
      9'd316: return 12'h27a; // subset=4 row=111100
      9'd317: return 12'he7a; // subset=4 row=111101
      9'd318: return 12'h3fa; // subset=4 row=111110
      9'd319: return 12'hffa; // subset=4 row=111111
      9'd320: return 12'h049; // subset=5 row=000000
      9'd321: return 12'hc49; // subset=5 row=000001
      9'd322: return 12'h1c9; // subset=5 row=000010
      9'd323: return 12'hdc9; // subset=5 row=000011
      9'd324: return 12'h079; // subset=5 row=000100
      9'd325: return 12'hc79; // subset=5 row=000101
      9'd326: return 12'h1f9; // subset=5 row=000110
      9'd327: return 12'hdf9; // subset=5 row=000111
      9'd328: return 12'h04f; // subset=5 row=001000
      9'd329: return 12'hc4f; // subset=5 row=001001
      9'd330: return 12'h1cf; // subset=5 row=001010
      9'd331: return 12'hdcf; // subset=5 row=001011
      9'd332: return 12'h07f; // subset=5 row=001100
      9'd333: return 12'hc7f; // subset=5 row=001101
      9'd334: return 12'h1ff; // subset=5 row=001110
      9'd335: return 12'hdff; // subset=5 row=001111
      9'd336: return 12'h200; // subset=5 row=010000
      9'd337: return 12'he00; // subset=5 row=010001
      9'd338: return 12'h380; // subset=5 row=010010
      9'd339: return 12'hf80; // subset=5 row=010011
      9'd340: return 12'h230; // subset=5 row=010100
      9'd341: return 12'he30; // subset=5 row=010101
      9'd342: return 12'h3b0; // subset=5 row=010110
      9'd343: return 12'hfb0; // subset=5 row=010111
      9'd344: return 12'h206; // subset=5 row=011000
      9'd345: return 12'he06; // subset=5 row=011001
      9'd346: return 12'h386; // subset=5 row=011010
      9'd347: return 12'hf86; // subset=5 row=011011
      9'd348: return 12'h236; // subset=5 row=011100
      9'd349: return 12'he36; // subset=5 row=011101
      9'd350: return 12'h3b6; // subset=5 row=011110
      9'd351: return 12'hfb6; // subset=5 row=011111
      9'd352: return 12'h449; // subset=5 row=100000
      9'd353: return 12'h5c9; // subset=5 row=100001
      9'd354: return 12'h479; // subset=5 row=100010
      9'd355: return 12'h5f9; // subset=5 row=100011
      9'd356: return 12'h44f; // subset=5 row=100100
      9'd357: return 12'h5cf; // subset=5 row=100101
      9'd358: return 12'h47f; // subset=5 row=100110
      9'd359: return 12'h5ff; // subset=5 row=100111
      9'd360: return 12'h210; // subset=5 row=101000
      9'd361: return 12'he10; // subset=5 row=101001
      9'd362: return 12'h390; // subset=5 row=101010
      9'd363: return 12'hf90; // subset=5 row=101011
      9'd364: return 12'h216; // subset=5 row=101100
      9'd365: return 12'he16; // subset=5 row=101101
      9'd366: return 12'h396; // subset=5 row=101110
      9'd367: return 12'hf96; // subset=5 row=101111
      9'd368: return 12'h280; // subset=5 row=110000
      9'd369: return 12'he80; // subset=5 row=110001
      9'd370: return 12'h2b0; // subset=5 row=110010
      9'd371: return 12'heb0; // subset=5 row=110011
      9'd372: return 12'h286; // subset=5 row=110100
      9'd373: return 12'he86; // subset=5 row=110101
      9'd374: return 12'h2b6; // subset=5 row=110110
      9'd375: return 12'heb6; // subset=5 row=110111
      9'd376: return 12'h202; // subset=5 row=111000
      9'd377: return 12'he02; // subset=5 row=111001
      9'd378: return 12'h382; // subset=5 row=111010
      9'd379: return 12'hf82; // subset=5 row=111011
      9'd380: return 12'h232; // subset=5 row=111100
      9'd381: return 12'he32; // subset=5 row=111101
      9'd382: return 12'h3b2; // subset=5 row=111110
      9'd383: return 12'hfb2; // subset=5 row=111111
      9'd384: return 12'h008; // subset=6 row=000000
      9'd385: return 12'hc08; // subset=6 row=000001
      9'd386: return 12'h188; // subset=6 row=000010
      9'd387: return 12'hd88; // subset=6 row=000011
      9'd388: return 12'h038; // subset=6 row=000100
      9'd389: return 12'hc38; // subset=6 row=000101
      9'd390: return 12'h1b8; // subset=6 row=000110
      9'd391: return 12'hdb8; // subset=6 row=000111
      9'd392: return 12'h00e; // subset=6 row=001000
      9'd393: return 12'hc0e; // subset=6 row=001001
      9'd394: return 12'h18e; // subset=6 row=001010
      9'd395: return 12'hd8e; // subset=6 row=001011
      9'd396: return 12'h03e; // subset=6 row=001100
      9'd397: return 12'hc3e; // subset=6 row=001101
      9'd398: return 12'h1be; // subset=6 row=001110
      9'd399: return 12'hdbe; // subset=6 row=001111
      9'd400: return 12'h241; // subset=6 row=010000
      9'd401: return 12'he41; // subset=6 row=010001
      9'd402: return 12'h3c1; // subset=6 row=010010
      9'd403: return 12'hfc1; // subset=6 row=010011
      9'd404: return 12'h271; // subset=6 row=010100
      9'd405: return 12'he71; // subset=6 row=010101
      9'd406: return 12'h3f1; // subset=6 row=010110
      9'd407: return 12'hff1; // subset=6 row=010111
      9'd408: return 12'h247; // subset=6 row=011000
      9'd409: return 12'he47; // subset=6 row=011001
      9'd410: return 12'h3c7; // subset=6 row=011010
      9'd411: return 12'hfc7; // subset=6 row=011011
      9'd412: return 12'h277; // subset=6 row=011100
      9'd413: return 12'he77; // subset=6 row=011101
      9'd414: return 12'h3f7; // subset=6 row=011110
      9'd415: return 12'hff7; // subset=6 row=011111
      9'd416: return 12'h408; // subset=6 row=100000
      9'd417: return 12'h588; // subset=6 row=100001
      9'd418: return 12'h438; // subset=6 row=100010
      9'd419: return 12'h5b8; // subset=6 row=100011
      9'd420: return 12'h40e; // subset=6 row=100100
      9'd421: return 12'h58e; // subset=6 row=100101
      9'd422: return 12'h43e; // subset=6 row=100110
      9'd423: return 12'h5be; // subset=6 row=100111
      9'd424: return 12'h251; // subset=6 row=101000
      9'd425: return 12'he51; // subset=6 row=101001
      9'd426: return 12'h3d1; // subset=6 row=101010
      9'd427: return 12'hfd1; // subset=6 row=101011
      9'd428: return 12'h257; // subset=6 row=101100
      9'd429: return 12'he57; // subset=6 row=101101
      9'd430: return 12'h3d7; // subset=6 row=101110
      9'd431: return 12'hfd7; // subset=6 row=101111
      9'd432: return 12'h088; // subset=6 row=110000
      9'd433: return 12'hc88; // subset=6 row=110001
      9'd434: return 12'h0b8; // subset=6 row=110010
      9'd435: return 12'hcb8; // subset=6 row=110011
      9'd436: return 12'h08e; // subset=6 row=110100
      9'd437: return 12'hc8e; // subset=6 row=110101
      9'd438: return 12'h0be; // subset=6 row=110110
      9'd439: return 12'hcbe; // subset=6 row=110111
      9'd440: return 12'h00a; // subset=6 row=111000
      9'd441: return 12'hc0a; // subset=6 row=111001
      9'd442: return 12'h18a; // subset=6 row=111010
      9'd443: return 12'hd8a; // subset=6 row=111011
      9'd444: return 12'h03a; // subset=6 row=111100
      9'd445: return 12'hc3a; // subset=6 row=111101
      9'd446: return 12'h1ba; // subset=6 row=111110
      9'd447: return 12'hdba; // subset=6 row=111111
      9'd448: return 12'h040; // subset=7 row=000000
      9'd449: return 12'hc40; // subset=7 row=000001
      9'd450: return 12'h1c0; // subset=7 row=000010
      9'd451: return 12'hdc0; // subset=7 row=000011
      9'd452: return 12'h070; // subset=7 row=000100
      9'd453: return 12'hc70; // subset=7 row=000101
      9'd454: return 12'h1f0; // subset=7 row=000110
      9'd455: return 12'hdf0; // subset=7 row=000111
      9'd456: return 12'h046; // subset=7 row=001000
      9'd457: return 12'hc46; // subset=7 row=001001
      9'd458: return 12'h1c6; // subset=7 row=001010
      9'd459: return 12'hdc6; // subset=7 row=001011
      9'd460: return 12'h076; // subset=7 row=001100
      9'd461: return 12'hc76; // subset=7 row=001101
      9'd462: return 12'h1f6; // subset=7 row=001110
      9'd463: return 12'hdf6; // subset=7 row=001111
      9'd464: return 12'h209; // subset=7 row=010000
      9'd465: return 12'he09; // subset=7 row=010001
      9'd466: return 12'h389; // subset=7 row=010010
      9'd467: return 12'hf89; // subset=7 row=010011
      9'd468: return 12'h239; // subset=7 row=010100
      9'd469: return 12'he39; // subset=7 row=010101
      9'd470: return 12'h3b9; // subset=7 row=010110
      9'd471: return 12'hfb9; // subset=7 row=010111
      9'd472: return 12'h20f; // subset=7 row=011000
      9'd473: return 12'he0f; // subset=7 row=011001
      9'd474: return 12'h38f; // subset=7 row=011010
      9'd475: return 12'hf8f; // subset=7 row=011011
      9'd476: return 12'h23f; // subset=7 row=011100
      9'd477: return 12'he3f; // subset=7 row=011101
      9'd478: return 12'h3bf; // subset=7 row=011110
      9'd479: return 12'hfbf; // subset=7 row=011111
      9'd480: return 12'h440; // subset=7 row=100000
      9'd481: return 12'h5c0; // subset=7 row=100001
      9'd482: return 12'h470; // subset=7 row=100010
      9'd483: return 12'h5f0; // subset=7 row=100011
      9'd484: return 12'h446; // subset=7 row=100100
      9'd485: return 12'h5c6; // subset=7 row=100101
      9'd486: return 12'h476; // subset=7 row=100110
      9'd487: return 12'h5f6; // subset=7 row=100111
      9'd488: return 12'h050; // subset=7 row=101000
      9'd489: return 12'hc50; // subset=7 row=101001
      9'd490: return 12'h1d0; // subset=7 row=101010
      9'd491: return 12'hdd0; // subset=7 row=101011
      9'd492: return 12'h056; // subset=7 row=101100
      9'd493: return 12'hc56; // subset=7 row=101101
      9'd494: return 12'h1d6; // subset=7 row=101110
      9'd495: return 12'hdd6; // subset=7 row=101111
      9'd496: return 12'h289; // subset=7 row=110000
      9'd497: return 12'he89; // subset=7 row=110001
      9'd498: return 12'h2b9; // subset=7 row=110010
      9'd499: return 12'heb9; // subset=7 row=110011
      9'd500: return 12'h28f; // subset=7 row=110100
      9'd501: return 12'he8f; // subset=7 row=110101
      9'd502: return 12'h2bf; // subset=7 row=110110
      9'd503: return 12'hebf; // subset=7 row=110111
      9'd504: return 12'h042; // subset=7 row=111000
      9'd505: return 12'hc42; // subset=7 row=111001
      9'd506: return 12'h1c2; // subset=7 row=111010
      9'd507: return 12'hdc2; // subset=7 row=111011
      9'd508: return 12'h072; // subset=7 row=111100
      9'd509: return 12'hc72; // subset=7 row=111101
      9'd510: return 12'h1f2; // subset=7 row=111110
      9'd511: return 12'hdf2; // subset=7 row=111111
      default: return 12'h000;
    endcase
  endfunction

  function automatic logic [11:0] xmt_err_lookup(input logic [2:0] subset);
    case (subset)
      3'd0: return 12'h090;
      3'd1: return 12'h44a;
      3'd2: return 12'h252;
      3'd3: return 12'h451;
      3'd4: return 12'h481;
      3'd5: return 12'h290;
      3'd6: return 12'h08a;
      3'd7: return 12'h450;
      default: return 12'h000;
    endcase
  endfunction

  function automatic logic [11:0] csreset_lookup(input logic [2:0] subset);
    case (subset)
      3'd0: return 12'h5b2;
      3'd1: return 12'he97;
      3'd2: return 12'h4bf;
      3'd3: return 12'heba;
      3'd4: return 12'h597;
      3'd5: return 12'hf92;
      3'd6: return 12'h5ba;
      3'd7: return 12'h5f2;
      default: return 12'h000;
    endcase
  endfunction

  function automatic logic [11:0] csextend_lookup(input logic [2:0] subset);
    case (subset)
      3'd0: return 12'h402;
      3'd1: return 12'h291;
      3'd2: return 12'h489;
      3'd3: return 12'h28a;
      3'd4: return 12'h411;
      3'd5: return 12'h212;
      3'd6: return 12'h40a;
      3'd7: return 12'h442;
      default: return 12'h000;
    endcase
  endfunction

  function automatic logic [11:0] csextend_err_lookup(input logic [2:0] subset);
    case (subset)
      3'd0: return 12'hc96;
      3'd1: return 12'h5fa;
      3'd2: return 12'hfd2;
      3'd3: return 12'h5d7;
      3'd4: return 12'h4b7;
      3'd5: return 12'he96;
      3'd6: return 12'hcba;
      3'd7: return 12'h5d6;
      default: return 12'h000;
    endcase
  endfunction

  // Fixed symbol entries (subset 0 only, used for SSD/ESD/Idle)
  localparam logic [11:0] SYM_SSD1 = 12'h492; // (2, 2, 2, 2)
  localparam logic [11:0] SYM_SSD2 = 12'h496; // (2, 2, 2, -2)
  localparam logic [11:0] SYM_ESD1 = 12'h492; // (2, 2, 2, 2)
  localparam logic [11:0] SYM_ESD2_E0 = 12'h496; // (2, 2, 2, -2)
  localparam logic [11:0] SYM_ESD2_E1 = 12'h4b2; // (2, 2, -2, 2)
  localparam logic [11:0] SYM_ESD2_E2 = 12'h592; // (2, -2, 2, 2)
  localparam logic [11:0] SYM_ESD_EERR = 12'hc92; // (-2, 2, 2, 2)

  // Master symbol lookup: condition + Sdn[8:0] -> packed {TA,TB,TC,TD}
  function automatic logic [11:0] sym_lookup(
    input sym_condition_t condition,
    input logic [8:0]     sd
  );
    case (condition)
      COND_NORMAL:       return normal_sym_lookup(sd);
      COND_IDLE:         return normal_sym_lookup({3'b000, sd[5:0]});  // subset 0 only
      COND_XMT_ERR:      return xmt_err_lookup(sd[8:6]);
      COND_CSRESET:      return csreset_lookup(sd[8:6]);
      COND_CSEXTEND:     return csextend_lookup(sd[8:6]);
      COND_CSEXTEND_ERR: return csextend_err_lookup(sd[8:6]);
      COND_SSD1:         return SYM_SSD1;
      COND_SSD2:         return SYM_SSD2;
      COND_ESD1:         return SYM_ESD1;
      COND_ESD2_EXT_0:   return SYM_ESD2_E0;
      COND_ESD2_EXT_1:   return SYM_ESD2_E1;
      COND_ESD2_EXT_2:   return SYM_ESD2_E2;
      COND_ESD_EXT_ERR:  return SYM_ESD_EERR;
      default:           return 12'h000;
    endcase
  endfunction

endpackage
