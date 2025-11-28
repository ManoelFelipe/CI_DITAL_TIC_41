// ============================================================================
// Arquivo  : conv_4_gray.v  (implementacao BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Conversor combinacional de código binário para código Gray de
//            4 bits, implementado em estilo behavioral utilizando bloco
//            procedural always @*. A lógica garante que valores sucessivos
//            diferem em apenas 1 bit, reduzindo glitches em contadores e
//            interfaces assíncronas. Implementação puramente combinacional,
//            sem registradores, com latência de 0 ciclos de clock.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module conv_4_gray_behavioral (
    input  wire [3:0] bin_in,   // Vetor de entrada em código binário (4 bits)
    output reg  [3:0] gray_out  // Vetor de saída em código Gray (4 bits)
);
    // ------------------------------------------------------------------------
    // Bloco combinacional principal
    // - Utiliza atribuições procedurais para cada bit da saída.
    // - Implementa as equações clássicas do conversor binário -> Gray:
    //      G3 = B3
    //      G2 = B3 ^ B2
    //      G1 = B2 ^ B1
    //      G0 = B1 ^ B0
    // ------------------------------------------------------------------------
    always @* begin
        gray_out[3] = bin_in[3];                 // Bit mais significativo do Gray recebe diretamente B3
        gray_out[2] = bin_in[3] ^ bin_in[2];     // G2 é o XOR entre B3 e B2
        gray_out[1] = bin_in[2] ^ bin_in[1];     // G1 é o XOR entre B2 e B1
        gray_out[0] = bin_in[1] ^ bin_in[0];     // G0 é o XOR entre B1 e B0
    end

endmodule
