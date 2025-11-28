// ============================================================================
// Arquivo  : mux_2_1.v  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Mux 2:1 combinacional de 1 bit de saída, com entradas agrupadas
//            em vetor d[1:0] e seleção de uma das linhas por sel. O bloco é
//            livre de registradores, com latência puramente combinacional e
//            sintetiza em poucos recursos lógicos (portas AND/OR/INV ou LUT).
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Descrição em nível de fluxo de dados, usando operador condicional (? :)
// para selecionar diretamente qual bit de d vai para a saída y.
module mux_2_1 (
    input  wire [1:0] d,   // d[1:0] : vetor de entradas de dados (d[0] e d[1])
    input  wire       sel, // sel    : sinal de seleção de uma das linhas de d
    output wire       y    // y      : saída única do multiplexador 2:1
);
    // Atribuição contínua que escolhe d[0] ou d[1] com base em sel.
    // Quando sel = 0, y recebe d[0]; quando sel = 1, y recebe d[1].
    assign y = (sel == 1'b0) ? d[0] : d[1];
endmodule
