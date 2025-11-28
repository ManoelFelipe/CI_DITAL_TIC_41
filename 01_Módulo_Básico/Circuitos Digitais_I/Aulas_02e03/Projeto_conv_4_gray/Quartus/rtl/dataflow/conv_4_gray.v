// ============================================================================
// Arquivo  : conv_4_gray.v  (implementacao DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Conversor combinacional de código binário para código Gray de
//            4 bits, implementado em estilo dataflow com atribuições
//            contínuas (assign). Expressões XOR são mapeadas diretamente em
//            portas lógicas otimizáveis pelo sintetizador, mantendo baixa
//            latência e reduzida utilização de área. Bloco sem registradores,
//            adequado a trajetórias críticas curtas.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module conv_4_gray_dataflow (
    input  wire [3:0] bin_in,   // Vetor de entrada em código binário (4 bits)
    output wire [3:0] gray_out  // Vetor de saída em código Gray (4 bits)
);
    // ------------------------------------------------------------------------
    // Implementação em estilo dataflow
    // - Cada bit da saída é descrito por uma expressão lógica contínua.
    // - Não há bloco always; o hardware é inferido diretamente das equações.
    // ------------------------------------------------------------------------
    assign gray_out[3] = bin_in[3];             // G3 = B3
    assign gray_out[2] = bin_in[3] ^ bin_in[2]; // G2 = B3 ^ B2
    assign gray_out[1] = bin_in[2] ^ bin_in[1]; // G1 = B2 ^ B1
    assign gray_out[0] = bin_in[1] ^ bin_in[0]; // G0 = B1 ^ B0

endmodule
