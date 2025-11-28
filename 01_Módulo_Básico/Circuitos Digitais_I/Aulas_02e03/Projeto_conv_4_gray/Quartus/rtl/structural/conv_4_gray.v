// ============================================================================
// Arquivo  : conv_4_gray.v  (implementacao STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Conversor combinacional de 4 bits de binário para Gray descrito
//            em estilo estrutural, interconectando instâncias de portas XOR
//            elementares. Estrutura explicita o caminho de dados e facilita
//            o mapeamento em bibliotecas de células padrão ou LUTs de FPGA.
//            Implementação puramente combinacional, com latência lógica
//            mínima e sem elementos de memória.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module xor2_gate (
    input  wire a,  // Primeira entrada da porta XOR de 2 entradas
    input  wire b,  // Segunda entrada da porta XOR de 2 entradas
    output wire y   // Saída da porta XOR (a ^ b)
);
    // ------------------------------------------------------------------------
    // Implementação elementar da função XOR.
    // - Esta porta será reutilizada na descrição estrutural do conversor.
    // ------------------------------------------------------------------------
    assign y = a ^ b; // Saída recebe o XOR entre as entradas a e b
endmodule

module conv_4_gray_structural (
    input  wire [3:0] bin_in,   // Vetor de entrada em código binário (4 bits)
    output wire [3:0] gray_out  // Vetor de saída em código Gray (4 bits)
);
    // ------------------------------------------------------------------------
    // Sinais internos
    // ------------------------------------------------------------------------
    wire g3_internal;     // Sinal interno para o bit G3
    wire g2_internal;     // Sinal interno para o bit G2
    wire g1_internal;     // Sinal interno para o bit G1
    wire g0_internal;     // Sinal interno para o bit G0

    // ------------------------------------------------------------------------
    // Interconexão estrutural
    // ------------------------------------------------------------------------

    assign g3_internal = bin_in[3]; // Atribuição direta para o bit mais significativo do Gray

    xor2_gate u_xor_g2 (           // Instância para cálculo de G2
        .a(bin_in[3]),             // Entrada A recebe B3
        .b(bin_in[2]),             // Entrada B recebe B2
        .y(g2_internal)           // Saída gera G2 = B3 ^ B2
    );

    xor2_gate u_xor_g1 (           // Instância para cálculo de G1
        .a(bin_in[2]),             // Entrada A recebe B2
        .b(bin_in[1]),             // Entrada B recebe B1
        .y(g1_internal)           // Saída gera G1 = B2 ^ B1
    );

    xor2_gate u_xor_g0 (           // Instância para cálculo de G0
        .a(bin_in[1]),             // Entrada A recebe B1
        .b(bin_in[0]),             // Entrada B recebe B0
        .y(g0_internal)           // Saída gera G0 = B1 ^ B0
    );

    // ------------------------------------------------------------------------
    // Atribuições finais às saídas do módulo
    // ------------------------------------------------------------------------
    assign gray_out[3] = g3_internal; // Conecta o sinal interno G3 à saída
    assign gray_out[2] = g2_internal; // Conecta o sinal interno G2 à saída
    assign gray_out[1] = g1_internal; // Conecta o sinal interno G1 à saída
    assign gray_out[0] = g0_internal; // Conecta o sinal interno G0 à saída

endmodule
