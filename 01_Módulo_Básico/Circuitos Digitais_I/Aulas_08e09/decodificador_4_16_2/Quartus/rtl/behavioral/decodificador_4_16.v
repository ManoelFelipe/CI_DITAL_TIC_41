// =============================================================
// Projeto: Decodificador 4→16 (saídas ativas em nível BAIXO - one-cold)
// Autor: Manoel Furtado
// Data: 27/10/2025
// Compatibilidade: Verilog-2001 (Quartus / Questa)
// Descrição: Diferente do exemplo one-hot, aqui as saídas são
//            ativas em '0' (one-cold). Somente uma linha vai a '0'.
// =============================================================

// ------------------------------
// Arquivo: decodificador_4_16.v
// Estilo: Comportamental (Behavioral)
// ------------------------------
`timescale 1ns/1ps

// Nome único para permitir simulação lado a lado
module decodificador_4_16_behavioral
(
    input       [3:0] a,   // Entrada binária 0..15
    output reg [15:0] y_n  // Saídas ativas em BAIXO (one-cold)
//           ^ nota: _n indica ativo-baixo
);
    // Inicializa todas as saídas em '1' (inativas)
    initial y_n = 16'hFFFF;

    // Lógica combinacional: coloca um '0' na posição indicada por 'a'
    always @(*) begin
        // Cria um one-hot ativo-alto e inverte para obter ativo-baixo
        y_n = ~(16'h0001 << a);
    end
endmodule
