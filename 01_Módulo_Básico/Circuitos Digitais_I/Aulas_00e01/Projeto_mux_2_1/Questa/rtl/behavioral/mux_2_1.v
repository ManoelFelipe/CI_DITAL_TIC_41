// ============================================================================
// Arquivo  : mux_2_1.v  (implementação BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Mux 2:1 combinacional de 1 bit de saída, com entradas agrupadas
//            em vetor d[1:0] e seleção de uma das linhas por sel. O bloco é
//            livre de registradores, com latência puramente combinacional e
//            sintetiza em poucos recursos lógicos (portas AND/OR/INV ou LUT).
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Descrição comportamental usando bloco always @* e atribuição a reg.
// A saída y é atualizada de forma combinacional a cada mudança em d ou sel.
module mux_2_1 (
    input  wire [1:0] d,   // d[1:0] : vetor de entradas de dados (duas linhas)
    input  wire       sel, // sel    : sinal de seleção (0 escolhe d[0], 1 escolhe d[1])
    output reg        y    // y      : saída única do multiplexador
);
    // Bloco always sensível a qualquer variação das entradas (modelo combinacional)
    always @* begin
        // Estrutura if-else para escolher qual bit do vetor d irá para a saída y
        if (sel == 1'b0) begin
            // Quando sel = 0, a saída recebe o bit menos significativo d[0]
            y = d[0];
        end else begin
            // Quando sel = 1, a saída recebe o bit mais significativo d[1]
            y = d[1];
        end
    end
endmodule
