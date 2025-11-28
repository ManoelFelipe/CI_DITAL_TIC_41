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
// Estilo: Fluxo de Dados (Dataflow)
// ------------------------------
`timescale 1ns/1ps

module decodificador_4_16_dataflow
(
    input  [3:0]  a,    // Entrada 0..15
    output [15:0] y_n   // Saídas ativas em BAIXO (uma linha em '0')
);
    // Expressão direta em dataflow: inverte o one-hot
    assign y_n = ~(16'h0001 << a);

endmodule
