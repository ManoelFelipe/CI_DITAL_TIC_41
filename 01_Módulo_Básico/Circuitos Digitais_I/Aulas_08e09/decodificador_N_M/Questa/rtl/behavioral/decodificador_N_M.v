// =============================================================
// Projeto: Decodificador Parametrizável N→M (M = 2^N) - Atividade 3
// Autor: Manoel Furtado
// Data: 31/10/2025
// Compatibilidade: Verilog-2001 (Quartus / Questa)
// Notas:
//  - Três abordagens: Behavioral, Dataflow e Structural.
//  - Parâmetros: N (bits de entrada), M (=1<<N) derivado via localparam.
//  - Saídas ativas em ALTO (one-hot). Parâmetro opcional ACTIVE_LOW.
// =============================================================

// ------------------------------
// Arquivo: decodificador_N_M.v
// Estilo: Comportamental (Behavioral)
// ------------------------------
`timescale 1ns/1ps

module decodificador_N_M_behavioral
#(
    parameter integer N = 4,           // Largura da entrada
    parameter integer ACTIVE_LOW = 0   // 0: ativo-alto | 1: ativo-baixo
)
(
    input      [N-1:0] a,              // Entrada binária
    output reg [(1<<N)-1:0] y          // Vetor de saídas (M = 2^N)
);
    localparam integer M = (1<<N);

    initial y = {M{1'b0}};

    always @(*) begin
        // One-hot: zera e seta apenas o índice 'a'
        y = {M{1'b0}};
        y[a] = 1'b1;
        if (ACTIVE_LOW) y = ~y;
    end
endmodule
