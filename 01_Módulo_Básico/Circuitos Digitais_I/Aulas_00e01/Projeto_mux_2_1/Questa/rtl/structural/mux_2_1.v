// ============================================================================
// Arquivo  : mux_2_1.v  (implementação STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Mux 2:1 combinacional de 1 bit de saída, com entradas agrupadas
//            em vetor d[1:0] e seleção de uma das linhas por sel. O bloco é
//            livre de registradores, com latência puramente combinacional e
//            sintetiza em poucos recursos lógicos (portas AND/OR/INV ou LUT).
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Descrição estrutural utilizando portas lógicas primitivas (not, and, or)
// para construir o multiplexador 2:1 a partir de blocos básicos.
module mux_2_1 (
    input  wire [1:0] d,   // d[1:0] : vetor de entradas (d[0] e d[1])
    input  wire       sel, // sel    : sinal de seleção
    output wire       y    // y      : saída combinacional do multiplexador
);
    // Declaração dos fios internos usados para interconectar as portas lógicas.
    wire not_sel;     // not_sel   : complemento de sel
    wire and_d0;      // and_d0    : resultado de d[0] AND not_sel
    wire and_d1;      // and_d1    : resultado de d[1] AND sel

    // Inversor: gera o complemento de sel (not_sel = ~sel)
    not u_not_sel (
        not_sel,      // primeira porta: saída do inversor
        sel           // segunda porta : entrada (sinal sel)
    );

    // Porta AND para a linha d[0], habilitada quando sel = 0 (ou seja, not_sel = 1)
    and u_and_d0 (
        and_d0,       // primeira porta: saída da AND (d[0] filtrado)
        d[0],         // segunda porta : bit menos significativo do vetor d
        not_sel       // terceira porta: complemento de sel
    );

    // Porta AND para a linha d[1], habilitada quando sel = 1
    and u_and_d1 (
        and_d1,       // primeira porta: saída da AND (d[1] filtrado)
        d[1],         // segunda porta : bit mais significativo do vetor d
        sel           // terceira porta: sinal de seleção original
    );

    // Porta OR que combina as duas contribuições e gera a saída final y
    or u_or_y (
        y,            // primeira porta: saída do multiplexador
        and_d0,       // segunda porta : contribuição da linha d[0]
        and_d1        // terceira porta: contribuição da linha d[1]
    );
endmodule
